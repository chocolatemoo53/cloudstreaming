$osType = Get-CimInstance -ClassName Win32_OperatingSystem
$WorkDir = "$PSScriptRoot\..\Bin"
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

$OldVersion = (Read-Host "Would you like to turn off Internet Explorer restrictions on Server 2019 and below? (y/n)").ToLower() -eq "y"
if($OldVersion) {
Write-Host "Removing IE restrictions..."
Set-Itemproperty "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -name IsInstalled -value 0 -force | Out-Null
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" -Name IsInstalled -Value 0 -Force | Out-Null
Stop-Process -Name Explorer -Force
}

Write-Host "Choose your streaming technology"
Write-Host "1. Parsec (Best for most people)"
Write-Host "2. Amazon DCV (For AWS customers)"
Write-Host "3. Sunshine (For use with Moonlight)"
Write-Host "Consult the wiki for more information"

$streamTech = Read-Host -Prompt 'Type the number corresponding your choice'

if($streamTech -eq 1) {
Write-Host ""
GetFile "https://builds.parsecgaming.com/package/parsec-windows.exe" "$WorkDir\parsec.exe" "Parsec"
Write-Host "Installing Parsec..."
Start-Process -FilePath "$WorkDir\parsec.exe" -ArgumentList "/norun /silent" -NoNewWindow -Wait -Passthru
}

if($streamTech -eq 2) {
Write-Host ""
GetFile "https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-server-x64-Release.msi" "$specialFolder\nicedcv.msi" "NiceDCV" 
Write-Host "Installing Amazon DCV..."
Start-Process -FilePath "msiexec.exe" -Wait -ArgumentList '/qn /i C:\cloudstreaming\nicedcv.msi'
}

if($streamTech -eq 3) {
Write-Host ""
GetFile "https://github.com/LizardByte/Sunshine/releases/latest/download/sunshine-windows-installer.exe" "$WorkDir\sunshine.exe" "Sunshine"
Write-Host "Installing Sunshine..."
Start-Process -FilePath "$WorkDir\sunshine.exe" -Wait
Copy-Item -Path "$WorkDir\sunshine.ico" -Destination $specialfolder
$TargetFile = "$ENV:windir\explorer.exe"
$ShortcutFile = "$env:Public\Desktop\Sunshine Settings.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.IconLocation = "$specialfolder\sunshine.ico"
$Shortcut.Arguments = "https://127.0.0.1:47990"
$Shortcut.Save()
Write-Host "Sunshine Settings shortcut created successfully!" -ForegroundColor Green
Write-Host "Sunshine installed successfully!" -ForegroundColor Green
} 

if($streamTech -in 1, 3) {
Write-Host ""
$Audio = (Read-Host "Would you like to download audio drivers? (y/n)").ToLower() -eq "y"
if($Audio) { 
GetFile "https://download.vb-audio.com/Download_CABLE/VBCABLE_Driver_Pack43.zip" "$WorkDir\vbcable.zip" "VBCABLE"
Write-Host "Installing VBCABLE..."
Expand-Archive -Path "$WorkDir\vbcable.zip" -DestinationPath "$WorkDir\vbcable"
(Get-AuthenticodeSignature -FilePath "$WorkDir\vbcable\vbaudio_cable64_win7.cat").SignerCertificate | Export-Certificate -Type CERT -FilePath "c:\cloudstreaming\vbcable.cer" | Out-Null
Import-Certificate -FilePath "C:\cloudstreaming\vbcable.cer" -CertStoreLocation 'Cert:\LocalMachine\TrustedPublisher' | Out-Null
Start-Process -FilePath "$WorkDir\vbcable\VBCABLE_Setup_x64.exe" -ArgumentList "-i","-h" -NoNewWindow -Wait }
}

if($streamTech -in 1, 3) {
    Write-Host ""
    $Monitor = (Read-Host "You may need a headless display/monitor. Would you like to install one? (y/n)").ToLower() -eq "y"
    if($Monitor) {
        GetFile "https://github.com/ge9/IddSampleDriver/releases/download/0.0.1.4/IddSampleDriver.zip" "$WorkDir\idd.zip" "IddSampleDriver"
        Expand-Archive -Path "$WorkDir\idd.zip" -DestinationPath "c:\" | Out-Null
        Start-Process cmd.exe -ArgumentList "/c c:\IddSampleDriver\InstallCert.bat"
        Write-Host "This process is not done, you need to manually install the driver."
        Write-Host "Go to Device Manager, click on the main window, and click on Action > Add legacy hardware."
        Write-Host "Select Install the hardware that I manually select from a list (Advanced)."
        Write-Host "Select Display Adapters, Have Disk, then navigate to c:\IddSampleDriver."
        Write-Host "Select the INF file and continue. Select reboot later." 
        Write-Host "Only remove the basic display adapters after you have successfully connected to your stream tech of choice."
        Write-Host ""
    }
}

$Video = (Read-Host "Would you like to install video drivers (AWS and GCP, y/n)?").ToLower() -eq "y"

if($Video) {
$Shell = New-Object -comObject WScript.Shell
$Shortcut = $Shell.CreateShortcut("$Home\Desktop\Continue.lnk")
$Shortcut.TargetPath = "powershell.exe"
$Shortcut.Arguments = "-Command `"Set-ExecutionPolicy Unrestricted; & '$PSScriptRoot\...\starthere.ps1'`" -RebootSkip"
$Shortcut.Save()
$script = "-Command `"Set-ExecutionPolicy Unrestricted; & '$PSScriptRoot\..\starthere.ps1'`" -RebootSkip";
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $script
$trigger = New-ScheduledTaskTrigger -AtLogon -RandomDelay "00:00:30"
$principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName "Continue" -Description "Continue script" | Out-Null
Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$PSScriptRoot\GPUDownloaderTool.ps1`""
Stop-Transcript
exit
}
