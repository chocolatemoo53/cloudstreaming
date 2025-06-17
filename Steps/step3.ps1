$specialFolder = "C:\cloudstreaming"
$installerFolder = "$specialFolder\Installers"

Function GetFile([string]$Url, [string]$Path, [string]$Name) {
    try {
        if (!(Test-Path $Path)) {
            Write-Host "Downloading $Name..."
            Start-BitsTransfer $Url $Path
        }
    }
    catch {
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

Function Request-UserInput([string]$Prompt) {
    return (Read-Host $Prompt).Trim().ToLower() -eq 'y'
}

Write-Host "All software after this point is optional and should install silently..."

#Microsoft Store
if (Request-UserInput "Would you link to enable the Microsoft Store? (y/n)") {
    wsreset -i
}
else {
    Write-Host "Skipping the Microsoft Store..."
}

# Tailscale
if (Request-UserInput "Would you like to download and install Tailscale? (y/n)") {
    InstallMSI "Tailscale" "https://pkgs.tailscale.com/stable/tailscale-setup-latest-amd64.msi" "$installerFolder\tailscale.msi"
}
else {
    Write-Host "Skipping Tailscale..."
}

# Browsers
if (Request-UserInput "Would you like to download and install web browsers? (y/n)") {
    if (Request-UserInput "Would you like to download and install Mozilla Firefox? (y/n)") {
        InstallMSI "Firefox" "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=en-US" "$installerFolder\firefox.msi"
    }

    if (Request-UserInput "Would you like to download and install Microsoft Edge? (y/n)") {
        InstallMSI "Microsoft Edge" "http://go.microsoft.com/fwlink/?LinkID=2093437" "$installerFolder\edge.msi"
    }

    if (Request-UserInput "Would you like to download and install Google Chrome? (y/n)") {
        InstallMSI "Google Chrome" "https://dl.google.com/tag/s/dl/chrome/install/googlechromestandaloneenterprise64.msi" "$installerFolder\chrome.msi"
    }
}
else {
    Write-Host "Skipping browsers..."
}

# Game Launchers
if (Request-UserInput "Would you like to download and install game launchers? (y/n)") {
    if (Request-UserInput "Would you like to download and install Steam? (y/n)") {
        $steamInstaller = "$installerFolder\SteamSetup.exe"
        GetFile "https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe" $steamInstaller "Steam"
        Write-Host "Installing Steam..."
        Start-Process -FilePath $steamInstaller -ArgumentList "/S" -NoNewWindow -Wait
    }

    if (Request-UserInput "Would you like to download and install Epic Games? (y/n)") {
        InstallMSI "Epic Games" "https://launcher-public-service-prod06.ol.epicgames.com/launcher/api/installer/download/EpicGamesLauncherInstaller.msi" "$installerFolder\epic.msi"
    }
}
else {
    Write-Host "Skipping game launchers..."
}
