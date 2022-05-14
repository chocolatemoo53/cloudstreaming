$WorkDir = "$PSScriptRoot\..\Bin"
$path = [Environment]::GetFolderPath("Desktop")
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

Import-Module BitsTransfer

Write-Host "All software after this point is optional, it should install silently..."
$InstallFirefox = (Read-Host "Would you like to download and install Firefox? (y/n)").ToLower() -eq "y"

if($InstallFirefox) {
    Write-Host ""
    New-Item -Path $path\FirefoxTemp -ItemType directory | Out-Null
    GetFile "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=en-US" "$path\FirefoxTemp\firefox.msi" "Firefox" 
    Write-Host "Installing Firefox..."
    Start-Process -FilePath "msiexec.exe" -Wait -ArgumentList '/quiet /i C:\Users\Administrator\Desktop\FirefoxTemp\firefox.msi'
    Write-Host ""
    Write-Host "Removing temporary folder from the desktop..."
    Remove-Item -Path $path\FirefoxTemp -force -Recurse | Out-Null
}
else {
    Write-Host ""
    Write-Host "Skipping Firefox..."
}

Write-Host ""
$InstallSteam = (Read-Host "Would you like to download and install Steam? (y/n)").ToLower() -eq "y"

if($InstallSteam) {
    Write-Host ""
    GetFile "https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe" "$WorkDir\SteamSetup.exe" "Steam"
    Write-Host "Installing Steam..."
    Start-Process -FilePath "$WorkDir\SteamSetup.exe" -ArgumentList "/S" -NoNewWindow -Wait -Passthru
}
else {
    Write-Host ""
    Write-Host "Skipping Steam..."
}

$Install7Zip = (Read-Host "Would you like to download and install 7Zip? (y/n)").ToLower() -eq "y"

if($Install7Zip) {
    Write-Host ""
    GetFile "https://www.7-zip.org/a/7z1900-x64.exe" "$WorkDir\7zip.exe" "7Zip"
    Write-Host "Installing 7Zip..."
    Start-Process -FilePath "$WorkDir\7Zip.exe" -ArgumentList "/S" -NoNewWindow -Wait -Passthru
}
else {
    Write-Host ""
    Write-Host "Skipping 7Zip..."
}

$InstallEpic = (Read-Host "Would you like to download and install Epic Games? (y/n)").ToLower() -eq "y"

if($InstallEpic) {
    Write-Host ""
    New-Item -Path $path\EpicTemp -ItemType directory | Out-Null
    GetFile "https://launcher-public-service-prod06.ol.epicgames.com/launcher/api/installer/download/EpicGamesLauncherInstaller.msi" "$path\EpicTemp\epic.msi" "Epic Games"
    Write-Host "Installing Epic Games..."
    Start-Process -FilePath "msiexec.exe" -Wait -ArgumentList '/qn /i C:\Users\Administrator\Desktop\EpicTemp\epic.msi'
    Write-Host ""
    Write-Host "Removing temporary folder from the desktop..."
    Remove-Item -Path $path\EpicTemp -force -Recurse | Out-Null
}
else {
    Write-Host ""
    Write-Host "Skipping Epic Games..."
}

$InstallUplay = (Read-Host "Would you like to install UPlay? (y/n)").ToLower() -eq "y"

if($InstallUplay) {
    Write-Host ""
    GetFile "https://ubistatic3-a.akamaihd.net/orbit/launcher_installer/UplayInstaller.exe" "$WorkDir\uplay.exe" "UPlay"
    Write-Host "Installing UPlay..."
    Start-Process -FilePath "$WorkDir\uplay.exe" -ArgumentList "/S" -NoNewWindow -Wait -PassThru
}
else {
    Write-Host ""
    Write-Host "Skipping UPlay..."
}