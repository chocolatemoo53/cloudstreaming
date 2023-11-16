$osType = Get-CimInstance -ClassName Win32_OperatingSystem
$WorkDir = "$PSScriptRoot\..\Bin"
$specialFolder = "c:\cloudstreaming"
$vddFolder = "c:\IddSampleDriver"
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

if($osType.ProductType -eq 3) {
Write-Host "Removing IE restrictions..."
Set-Itemproperty "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -name IsInstalled -value 0 -force | Out-Null
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" -Name IsInstalled -Value 0 -Force | Out-Null
Stop-Process -Name Explorer -Force
}

    Write-Host "Choose your streaming technology"
    Write-Host "1. Parsec (Best for most people)"
    Write-Host "2. NiceDCV (For AWS customers)"
    Write-Host "3. Sunshine (For use with Moonlight)"
    Write-Host "Consult the wiki for more information"

$streamTech = Read-Host -Prompt 'Type the number corresponding your choice'

if ($streamTech -eq 1) {
Write-Host ""
GetFile "https://builds.parsecgaming.com/package/parsec-windows.exe" "$WorkDir\parsec.exe" "Parsec"
Write-Host "Installing Parsec..."
Start-Process -FilePath "$WorkDir\parsec.exe" -ArgumentList "/norun /silent" -NoNewWindow -Wait -Passthru
Write-Host "Getting the headless display driver and monitor"
GetFile "https://github.com/itsmikethetech/Virtual-Display-Driver/releases/download/23.10.20.2/VDD.23.10.20.2.zip" "$WorkDir\vdd.zip"
New-Item -ItemType directory -Path "c:\IddSampleDriver"
Expand-Archive -Path "$WorkDir\vdd.zip" -DestinationPath "$specialFolder\vdd"
Move-Item -Path "$specialFolder\vdd\option.txt" -Destination "$vddFolder\option.txt"
Start-Process cmd.exe /c 'c:\cloudstreaming\vdd\InstallCert.bat'
Write-Host "Now install the display driver using add legacy hardware in device manager"
Write-Host "Select display adapters, then have disk, then browse to c:\cloudstreaming\vdd\IddSampleDriver\IddSampleDriver.inf"
}

if ($streamTech -eq 2) {
    Write-Host ""
    GetFile "https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-server-x64-Release.msi" "$specialFolder\nicedcv.msi" "NiceDCV" 
    Write-Host "Installing NiceDCV..."
    Start-Process -FilePath "msiexec.exe" -Wait -ArgumentList '/qn /i C:\cloudstreaming\nicedcv.msi'
}

if ($streamTech -eq 3) {
Write-Host ""
GetFile "https://github.com/LizardByte/Sunshine/releases/latest/download/sunshine-windows-installer.exe" "$WorkDir\sunshine.exe" "Sunshine"
Write-Host "Installing Sunshine..."
Start-Process -FilePath "$WorkDir\sunshine.exe" -ArgumentList "/s" -NoNewWindow -Wait -Passthru
Write-Host "Getting the headless display driver and monitor"
GetFile "https://github.com/itsmikethetech/Virtual-Display-Driver/releases/download/23.10.20.2/VDD.23.10.20.2.zip" "$WorkDir\vdd.zip"
New-Item -ItemType directory -Path "c:\IddSampleDriver"
Expand-Archive -Path "$WorkDir\vdd.zip" -DestinationPath "$specialFolder\vdd"
Move-Item -Path "$specialFolder\vdd\option.txt" -Destination "$vddFolder\option.txt"
Start-Process cmd.exe /c 'c:\cloudstreaming\vdd\InstallCert.bat'
Write-Host "Now install the display driver using add legacy hardware in device manager"
Write-Host "Select display adapters, then have disk, then browse to c:\cloudstreaming\vdd\IddSampleDriver\IddSampleDriver.inf"
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

$Video = (Read-Host "Would you like to install video drivers? (skip if AWS, y/n)").ToLower() -eq "y"
 
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
