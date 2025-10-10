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

Function InstallMSI([string]$name, [string]$url, [string]$path) {
    GetFile $url $path $name
    Write-Host "Installing $name..."
    Start-Process -FilePath "msiexec.exe" -Wait -ArgumentList "/qn /i `"$path`""
    Write-Host ""
}

Function Request-UserInput([string]$Prompt) {
    return (Read-Host $Prompt).Trim().ToLower() -eq 'y'
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
    Request-UserInput "Would you like to download and install Amazon DCV? (y/n)" {
        InstallMSI "Amazon DCV" "https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-server-x64-Release.msi" "$installerFolder\tailscale.msi"
    }
}

if ($streamTech -eq 3) {
    Write-Host ""
    GetFile "https://github.com/LizardByte/Sunshine/releases/latest/download/Sunshine-Windows-AMD64-installer.exe
" "$installerFolder\sunshine.exe" "Sunshine"
    Write-Host "Installing Sunshine..."
    Start-Process -FilePath "$installerFolder\sunshine.exe" -ArgumentList "/S" -NoNewWindow -Wait 
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
    GetFile "https://github.com/VirtualDrivers/Virtual-Display-Driver/raw/refs/heads/master/Community%20Scripts/silent-install.ps1" "$driverFolder\VDD.ps1" "VDD by MTT silent install script"
    & $driverFolder\VDD.ps1
} 