$WorkDir = "$PSScriptRoot\..\Bin"
$specialFolder = "C:\cloudopenstream"
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
Write-Host "Choose your browser(s), or not" -ForegroundColor Green
Write-Host ""
$InstallFirefox = (Read-Host "Would you like to download and install Mozilla Firefox? (y/n)").ToLower() -eq "y"

if($InstallFirefox) {
    Write-Host ""
    GetFile "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=en-US" "$specialFolder\Installers\firefox.msi" "Firefox" 
    Write-Host "Installing Firefox..."
    Start-Process -FilePath "msiexec.exe" -Wait -ArgumentList '/q /i C:\cloudopenstream\Installers\firefox.msi'
    Write-Host ""
}
else {
    Write-Host ""
    Write-Host "Skipping Firefox..."
}

$InstallEdge = (Read-Host "Would you like to download and install Microsoft Edge? (y/n)").ToLower() -eq "y"

if($InstallEdge) {
    Write-Host ""
    GetFile "https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/deca85f5-369c-4c01-933d-f1b544563b31/MicrosoftEdgeEnterpriseX64.msi" "$specialFolder\Installers\edge.msi" "Firefox" 
    Write-Host "Installing Microsoft Edge..."
    Start-Process -FilePath "msiexec.exe" -Wait -ArgumentList '/qn /i C:\cloudopenstream\Installers\edge.msi'
    Write-Host ""
}
else {
    Write-Host ""
    Write-Host "Skipping Microsoft Edge..."
}

$InstallChrome = (Read-Host "Would you like to download and install Google Chrome? (y/n)").ToLower() -eq "y"

if($InstallChrome) {
    Write-Host ""
    GetFile "https://dl.google.com/tag/s/dl/chrome/install/googlechromestandaloneenterprise64.msi" "$specialFolder\Installers\chrome.msi" "Google Chrome" 
    Write-Host "Installing Google Chrome..."
    Start-Process -FilePath "msiexec.exe" -Wait -ArgumentList '/qn /i C:\cloudopenstream\Installers\chrome.msi'
    Write-Host ""
}
else {
    Write-Host ""
    Write-Host "Skipping Google Chrome..."
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

Write-Host ""
Write-Host "Choose your game launchers..." -ForegroundColor Green
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

$InstallEpic = (Read-Host "Would you like to download and install Epic Games? (y/n)").ToLower() -eq "y"

if($InstallEpic) {
    Write-Host ""
    GetFile "https://launcher-public-service-prod06.ol.epicgames.com/launcher/api/installer/download/EpicGamesLauncherInstaller.msi" "$specialFolder\Installers\epic.msi" "Epic Games"
    Write-Host "Installing Epic Games..."
    Start-Process -FilePath "msiexec.exe" -Wait -ArgumentList '/qn /i C:\cloudopenstream\Installers\epic.msi'
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