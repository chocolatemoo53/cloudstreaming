$WorkDir = "$PSScriptRoot\..\Bin"
$specialFolder = "C:\cloudstreaming"
$installerFolder = "$specialFolder\Installers"

Function GetFile([string]$Url, [string]$Path, [string]$Name) {
    try {
        if (!(Test-Path $Path)) {
            Write-Host "Downloading $Name..."
            Start-BitsTransfer $Url $Path
        }
    } catch {
        throw "Download failed for $Name"
    }
}

Import-Module BitsTransfer

Function InstallMSI([string]$name, [string]$url, [string]$path) {
    GetFile $url $path $name
    Write-Host "Installing $name..."
    Start-Process -FilePath "msiexec.exe" -Wait -ArgumentList "/qn /i `"$path`""
    Write-Host ""
}

Function Ask-User([string]$Prompt) {
    return (Read-Host $Prompt).Trim().ToLower() -eq 'y'
}

Write-Host "All software after this point is optional and should install silently..."

# Tailscale
if (Ask-User "Would you like to download and install Tailscale? (y/n)") {
        $tailscaleInstaller = "$installerFolder\tailscale.exe"
        GetFile "https://pkgs.tailscale.com/stable/tailscale-setup-latest.exe" $tailscaleInstaller "Tailscale"
        Write-Host "Installing Tailscale..."
        Start-Process -FilePath $tailscaleInstaller -ArgumentList "/S" -NoNewWindow -Wait
} else {
    Write-Host "Skipping Tailscale..."
}

# Browsers
if (Ask-User "Would you like to download and install web browsers? (y/n)") {
    if (Ask-User "Would you like to download and install Mozilla Firefox? (y/n)") {
        InstallMSI "Firefox" "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=en-US" "$installerFolder\firefox.msi"
    }

    if (Ask-User "Would you like to download and install Microsoft Edge? (y/n)") {
        InstallMSI "Microsoft Edge" "http://go.microsoft.com/fwlink/?LinkID=2093437" "$installerFolder\edge.msi"
    }

    if (Ask-User "Would you like to download and install Google Chrome? (y/n)") {
        InstallMSI "Google Chrome" "https://dl.google.com/tag/s/dl/chrome/install/googlechromestandaloneenterprise64.msi" "$installerFolder\chrome.msi"
    }
} else {
    Write-Host "Skipping browsers..."
}

# Game Launchers
if (Ask-User "Would you like to download and install game launchers? (y/n)") {
    if (Ask-User "Would you like to download and install Steam? (y/n)") {
        $steamInstaller = "$installerFolder\SteamSetup.exe"
        GetFile "https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe" $steamInstaller "Steam"
        Write-Host "Installing Steam..."
        Start-Process -FilePath $steamInstaller -ArgumentList "/S" -NoNewWindow -Wait
    }

    if (Ask-User "Would you like to download and install Epic Games? (y/n)") {
        InstallMSI "Epic Games" "https://launcher-public-service-prod06.ol.epicgames.com/launcher/api/installer/download/EpicGamesLauncherInstaller.msi" "$installerFolder\epic.msi"
    }
} else {
    Write-Host "Skipping game launchers..."
}
