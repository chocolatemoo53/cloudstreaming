$WorkDir = "$PSScriptRoot\..\Bin"
$SunshineDir = "$ENV:HOMEDRIVE\sunshine"
$specialFolder = "c:\cloudstreaming"
Function GetFile([string]$Url, [string]$Path, [string]$Name) {
    try {
        if(![System.IO.File]::Exists($Path)) {
	        Write-Host "Downloading"$Name"..."
	        Start-BitsTransfer $Url $Path
        }
    } catch {
        throw "Download failed"
    }
}

Write-Host "Removing IE restrictions..."
Set-Itemproperty "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -name IsInstalled -value 0 -force | Out-Null
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" -Name IsInstalled -Value 0 -Force | Out-Null
Stop-Process -Name Explorer -Force

GetFile "https://aka.ms/vs/16/release/vc_redist.x64.exe" "$WorkDir\redist.exe" "Visual C++ Redist (2015-19)"
Write-Host "Installing Visual C++ Redist (2015-19)..."
$ExitCode = (Start-Process -FilePath "$WorkDir\redist.exe" -ArgumentList "/install","/quiet","/norestart" -NoNewWindow -Wait -Passthru).ExitCode
if($ExitCode -eq 0) { Write-Host "Installed." -ForegroundColor Green }
elseif($ExitCode -eq 1638) { Write-Host "Newer version already installed." -ForegroundColor Green }
else { 
    throw "Installation failed (Error: $ExitCode)."
}

    Write-Host "Choose your streaming technology"
    Write-Host "1. Parsec (Best for most people)"
    Write-Host "2. NiceDCV (For AWS customers)"
    Write-Host "3. Sunshine (For use with Moonlight)"

$streamTech = Read-Host -Prompt 'Type the number corresponding your choice'

if ($streamTech -eq 1) {
    Write-Host ""
    GetFile "https://builds.parsecgaming.com/package/parsec-windows.exe" "$WorkDir\parsec.exe" "Parsec"
    Write-Host "Installing Parsec..."
    Start-Process -FilePath "$WorkDir\parsec.exe" -ArgumentList "/norun /silent" -NoNewWindow -Wait -Passthru
}

if ($streamTech -eq 2) {
    Write-Host ""
    GetFile "https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-server-x64-Release.msi" "$specialFolder\nicedcv.msi" "NiceDCV" 
    Write-Host "Installing NiceDCV..."
    Start-Process -FilePath "msiexec.exe" -Wait -ArgumentList '/qn /i C:\cloudstreaming\nicedcv.msi'
}

if ($streamTech -eq 3) {
GetFile "https://github.com/LizardByte/Sunshine/releases/latest/download/sunshine-windows-portable.zip" "$WorkDir\Sunshine-Windows.zip" "Sunshine"
Expand-Archive -Path "$WorkDir\Sunshine-Windows.zip" -DestinationPath "$SunshineDir" -Force
Write-Host ""
Write-Host "Making sure Sunshine begins at startup..." -ForegroundColor Yellow

if (!(Get-ScheduledTask -TaskName "StartSunshine" -ErrorAction SilentlyContinue)) {
$action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c start /min sunshine.exe" -WorkingDirectory "$SunshineDir"
$trigger = New-ScheduledTaskTrigger -AtLogon -RandomDelay "00:00:20"
$principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "StartSunshine" -Principal $principal -Description "Runs Sunshine at startup" | Out-Null
}

Write-Host ""
Write-Host "Please choose a username and password to configure Sunshine..."
$NewUsername = Read-Host "Username"
$NewPassword = Read-Host "Password" -AsSecureString
$NewPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($NewPassword))
$NewSalt = (([char[]]([char]'a'..[char]'z') + 0..9 | Sort-Object {get-random})[0..16] -join '')
$NewHash = $NewPassword + $NewSalt
$NewHash = new-object System.Security.Cryptography.SHA256Managed | ForEach-Object {$_.ComputeHash([System.Text.Encoding]::UTF8.GetBytes("$NewHash"))} | ForEach-Object {$_.ToString("x2")}
[array]::Reverse($NewHash)
$NewHash = ($NewHash -join '').ToUpper()
@{username="$NewUsername";salt="$NewSalt";password="$NewHash"} | ConvertTo-Json | Out-File "$SunshineDir\sunshine_state.json" -Encoding ascii
Start-Process -FilePath "$SunshineDir\sunshine.exe"
Write-Host ""
Write-Host "Adding Desktop shortcuts..." -ForegroundColor Green
Copy-Item "$WorkDir\cog.ico" -Destination "$SunshineDir"
Copy-Item "$WorkDir\sunshine.ico" -Destination "$SunshineDir"
$TargetFile = "cmd.exe"
$ShortcutFile = "$env:Public\Desktop\Start Sunshine.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Arguments = "/c start sunshine.exe"
$Shortcut.WorkingDirectory = $SunshineDir
$Shortcut.IconLocation = "$SunshineDir\sunshine.ico"
$Shortcut.Save()
$TargetFile = "$ENV:windir\explorer.exe"
$ShortcutFile = "$env:Public\Desktop\Sunshine Settings.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.IconLocation = "$SunshineDir\cog.ico"
$Shortcut.Arguments = "https://127.0.0.1:47990"
$Shortcut.Save()
Write-Host "Adding Sunshine rules to Windows Firewall..."
New-NetFirewallRule -DisplayName "Sunshine/Moonlight TCP" -Direction inbound -LocalPort 47984,47989,48010,47990 -Protocol TCP -Action Allow | Out-Null
New-NetFirewallRule -DisplayName "Sunshine/Moonlight UDP" -Direction inbound -LocalPort 47998,47999,48000,48010,47990 -Protocol UDP -Action Allow | Out-Null
Write-Host "Setting up gamepad support..." -ForegroundColor Green
GetFile "http://www.download.windowsupdate.com/msdownload/update/v3-19990518/cabpool/2060_8edb3031ef495d4e4247e51dcb11bef24d2c4da7.cab" "$specialFolder\Drivers\xbox360.cab" "Xbox 360 Driver"
cmd.exe /c "C:\Windows\System32\expand.exe C:\cloudstreaming\Drivers\xbox360.cab -F:* C:\cloudstreaming\Drivers\" | Out-Null
cmd.exe /c 'C:\cloudstreaming\Drivers\xusb21.inf' | Out-Null
GetFile "https://github.com/ViGEm/ViGEmBus/releases/latest/download/ViGEmBusSetup_x64.msi" "$specialFolder\Drivers\vigembus.msi" "ViGEmBus Driver"
Start-Process -FilePath "msiexec.exe" -Wait -ArgumentList '/qn /i C:\cloudstreaming\Drivers\vigembus.msi'
Write-Host "Setup for Sunshine has completed!" -ForegroundColor Green
} 

if ($streamTech -eq 1) {
$Audio = (Read-Host "Would you like to download audio drivers for Parsec? (y/n)").ToLower() -eq "y"
if($Audio) { 
GetFile "https://download.vb-audio.com/Download_CABLE/VBCABLE_Driver_Pack43.zip" "$WorkDir\vbcable.zip" "VBCABLE"
Write-Host "Installing VBCABLE..."
Expand-Archive -Path "$WorkDir\vbcable.zip" -DestinationPath "$WorkDir\vbcable"
(Get-AuthenticodeSignature -FilePath "$WorkDir\vbcable\vbaudio_cable64_win7.cat").SignerCertificate | Export-Certificate -Type CERT -FilePath "c:\cloudstreaming\vbcable.cer" | Out-Null
Import-Certificate -FilePath "C:\cloudstreaming\vbcable.cer" -CertStoreLocation 'Cert:\LocalMachine\TrustedPublisher' | Out-Null
Start-Process -FilePath "$WorkDir\vbcable\VBCABLE_Setup_x64.exe" -ArgumentList "-i","-h" -NoNewWindow -Wait }
}

if ($streamTech -eq 3) {
$Audio = (Read-Host "Would you like to download audio drivers for Sunshine? (y/n)").ToLower() -eq "y"
if($Audio) { 
GetFile "https://download.vb-audio.com/Download_CABLE/VBCABLE_Driver_Pack43.zip" "$WorkDir\vbcable.zip" "VBCABLE"
Write-Host "Installing VBCABLE..."
Expand-Archive -Path "$WorkDir\vbcable.zip" -DestinationPath "$WorkDir\vbcable"
(Get-AuthenticodeSignature -FilePath "$WorkDir\vbcable\vbaudio_cable64_win7.cat").SignerCertificate | Export-Certificate -Type CERT -FilePath "c:\cloudstreaming\vbcable.cer" | Out-Null
Import-Certificate -FilePath "C:\cloudstreaming\vbcable.cer" -CertStoreLocation 'Cert:\LocalMachine\TrustedPublisher' | Out-Null
Start-Process -FilePath "$WorkDir\vbcable\VBCABLE_Setup_x64.exe" -ArgumentList "-i","-h" -NoNewWindow -Wait }
}

$Video = (Read-Host "Would you like to install video drivers? (y/n)").ToLower() -eq "y"
 
if($Video) {
  $Shell = New-Object -comObject WScript.Shell
  $Shortcut = $Shell.CreateShortcut("$Home\Desktop\Continue.lnk")
  $Shortcut.TargetPath = "powershell.exe"
  $Shortcut.Arguments = "-Command `"Set-ExecutionPolicy Unrestricted; & '$PSScriptRoot\...\starthere.ps1'`" -RebootSkip"
  $Shortcut.Save()
  GetFile "https://raw.githubusercontent.com/parsec-cloud/Cloud-GPU-Updater/master/GPUUpdaterTool.ps1" "$PSScriptRoot\GPUUpdaterTool.ps1" "Cloud GPU Updater" 
  $script = "-Command `"Set-ExecutionPolicy Unrestricted; & '$PSScriptRoot\..\starthere.ps1'`" -RebootSkip";
  $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $script
  $trigger = New-ScheduledTaskTrigger -AtLogon -RandomDelay "00:00:30"
  $principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
  Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName "Continue" -Description "Continue script" | Out-Null
  Write-Host "Please restart the server when Parsec asks, the script will start back up upon login" -ForegroundColor Red
  & $PSScriptRoot\GPUUpdaterTool.ps1
  Stop-Transcript
  Pause
}
