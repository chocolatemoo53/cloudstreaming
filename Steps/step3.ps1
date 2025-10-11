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

Write-Host ""
$Audio = (Read-Host "Would you like to download audio drivers? (y/n)").ToLower() -eq "y"
if ($Audio) { 
    GetFile "https://download.vb-audio.com/Download_CABLE/VBCABLE_Driver_Pack45.zip" "$driverFolder\vbcable.zip" "VBCABLE"
    Write-Host "Installing VBCABLE..."
    Expand-Archive -Path "$driverFolder\vbcable.zip" -DestinationPath "$driverFolder\vbcable"
    (Get-AuthenticodeSignature -FilePath "$driverFolder\vbcable\vbaudio_cable64_win10.cat").SignerCertificate | Export-Certificate -Type CERT -FilePath "c:\cloudstreaming\Drivers\vbcable\vbcable.cer" | Out-Null
    Import-Certificate -FilePath "$driverFolder\vbcable\vbcable.cer" -CertStoreLocation 'Cert:\LocalMachine\TrustedPublisher' | Out-Null
    Start-Process -FilePath "$driverFolder\vbcable\VBCABLE_Setup_x64.exe" -ArgumentList "-i", "-h" -NoNewWindow -Wait 
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
else {
    Write-Host "The next step may break your RDP connection, you must reconnect using your streaming technology."
    Read-Host "Press enter to continue"
}