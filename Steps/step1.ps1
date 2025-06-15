$WorkDir = "$PSScriptRoot\..\Bin"
$specialFolder = "c:\cloudstreaming"
$driverFolder = "$specialFolder\Drivers"
$installerFolder = "$specialFolder\Installers"

Function GetFile([string]$Url, [string]$Path, [string]$Name) {
    try {
        if (![System.IO.File]::Exists($Path)) {
            Write-Host "Downloading"$Name"..."
            Start-BitsTransfer $Url $Path
        }
    }
    catch {
        throw "Download failed"
    }
}

Write-Host "Choose your streaming technology"
Write-Host "1. Parsec (Best for most people)"
Write-Host "2. Amazon DCV (For AWS customers)"
Write-Host "3. Sunshine (For use with Moonlight)"
Write-Host "Consult the wiki for more information"

$streamTech = Read-Host -Prompt 'Type the number corresponding your choice'

if ($streamTech -eq 1) {
    Write-Host ""
    GetFile "https://builds.parsecgaming.com/package/parsec-windows.exe" "$installerFolder\parsec.exe" "Parsec"
    Write-Host "Installing Parsec..."
    Start-Process -FilePath "$installerFolder\parsec.exe" -ArgumentList "/norun /silent" -NoNewWindow -Wait 
}

if ($streamTech -eq 2) {
    Write-Host ""
    GetFile "https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-server-x64-Release.msi" "$installerFolder\nicedcv.msi" "NiceDCV" 
    Write-Host "Installing Amazon DCV..."
    Start-Process -FilePath "msiexec.exe" -Wait -ArgumentList '/qn /i C:\cloudstreaming\Installers\nicedcv.msi'
}

if ($streamTech -eq 3) {
    Write-Host ""
    GetFile "https://github.com/LizardByte/Sunshine/releases/latest/download/sunshine-windows-installer.exe" "$installerFolder\sunshine.exe" "Sunshine"
    Write-Host "Installing Sunshine..."
    Start-Process -FilePath "$installerFolder\sunshine.exe" -Wait
    Write-Host "Sunshine installed successfully!" -ForegroundColor Green
    Copy-Item -Path "$WorkDir\sunshine.ico" -Destination $specialfolder
    $URL = "https://127.0.0.1:47990"
    $TargetFile = "cmd.exe"
    $ShortcutFile = "$env:Public\Desktop\Sunshine Settings.lnk"
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
    $Shortcut.TargetPath = $TargetFile
    $Shortcut.Arguments = "/c start $URL"
    $Shortcut.IconLocation = "$specialfolder\sunshine.ico"
    $Shortcut.Save()
    Write-Host "Sunshine Settings shortcut created successfully!" -ForegroundColor Green
} 

if ($streamTech -in 1, 3) {
    Write-Host ""
    $Audio = (Read-Host "Would you like to download audio drivers? (y/n)").ToLower() -eq "y"
    if ($Audio) { 
        GetFile "https://download.vb-audio.com/Download_CABLE/VBCABLE_Driver_Pack45.zip" "$driverFolder\vbcable.zip" "VBCABLE"
        Write-Host "Installing VBCABLE..."
        Expand-Archive -Path "$driverFolder\vbcable.zip" -DestinationPath "$driverFolder\vbcable"
(Get-AuthenticodeSignature -FilePath "$driverFolder\vbcable\vbaudio_cable64_win10.cat").SignerCertificate | Export-Certificate -Type CERT -FilePath "c:\cloudstreaming\Drivers\vbcable\vbcable.cer" | Out-Null
        Import-Certificate -FilePath "C:\$driverFolder\vbcable\vbcable.cer" -CertStoreLocation 'Cert:\LocalMachine\TrustedPublisher' | Out-Null
        Start-Process -FilePath "$driverFolder\vbcable\VBCABLE_Setup_x64.exe" -ArgumentList "-i", "-h" -NoNewWindow -Wait 
    }
}

$Video = (Read-Host "Would you like to install video drivers (AWS and GCP, y/n)?").ToLower() -eq "y"

if ($Video) {
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
    Start-Process -FilePath "powershell.exe" -ArgumentList "-Command `"$PSScriptRoot\GPUDownloaderTool.ps1`""
    Write-Host "The script will continue in a new window..."
    [Environment]::Exit(0)
}
