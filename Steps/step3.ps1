$WorkDir = "$PSScriptRoot\..\Bin"
$specialFolder = "C:\cloudstreaming"
$InstallersFolder = "$specialFolder\Installers"

if (-not (Test-Path -Path $InstallersFolder)) {
    New-Item -Path $InstallersFolder -ItemType Directory | Out-Null
}

Import-Module BitsTransfer

Function Get-File ([string]$Url, [string]$Path, [string]$Name) {
    try {
        if (-not [System.IO.File]::Exists($Path)) {
            Write-Host "Downloading $Name..."
            Start-BitsTransfer -Source $Url -Destination $Path
        }
    } catch {
        Write-Error "Failed to download $Name. Error: $_"
        throw
    }
}

Function Install-Msi ([string]$Path, [string]$Name) {
    Write-Host "Installing $Name..."
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/qn /norestart /i $Path" -Wait -NoNewWindow
}

Function Install-Exe ([string]$Path, [string]$Name) {
    Write-Host "Installing $Name..."
    Start-Process -FilePath $Path -ArgumentList "/S" -NoNewWindow -Wait
}

Function Handle-Installation ([string]$Name, [string]$Url, [string]$FileName, [string]$Type) {
    $Install = (Read-Host "Would you like to download and install $Name? (y/n)").ToLower() -eq "y"
    if ($Install) {
        Write-Host ""
        Get-File -Url $Url -Path "$InstallersFolder\$FileName" -Name $Name
        if ($Type -eq "msi") {
            Install-Msi -Path "$InstallersFolder\$FileName" -Name $Name
        } elseif ($Type -eq "exe") {
            Install-Exe -Path "$WorkDir\$FileName" -Name $Name
        }
    } else {
        Write-Host ""
        Write-Host "Skipping $Name..."
        Write-Host ""
    }
}

Write-Host ""
Write-Host "All software after this point is optional, it should install silently..."
Write-Host ""

$InstallTailscale = (Read-Host "Would you like to download and install Tailscale? (y/n)").ToLower() -eq "y"
if $InstallTailscale {
    Handle-Installation -Name "Tailscale" -Url "https://pkgs.tailscale.com/stable/tailscale-setup-latest.msi" -FileName "tailscale.msi" -Type "msi"
} else {
    Write-Host ""
    Write-Host "Skipping Tailscale..."
    Write-Host ""
}

$Browsers = @{
    "Firefox" = "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=en-US"
    "Microsoft Edge" = "http://go.microsoft.com/fwlink/?LinkID=2093437"
    "Google Chrome" = "https://dl.google.com/tag/s/dl/chrome/install/googlechromestandaloneenterprise64.msi"
}

$InstallBrowsers = (Read-Host "Would you like to download and install web browsers? (y/n)").ToLower() -eq "y"
if ($InstallBrowsers) {
    Write-Host ""
    Write-Host "Choose your browser..." -ForegroundColor Green
    Write-Host ""

    foreach ($Browser in $Browsers.GetEnumerator()) {
        Handle-Installation -Name $Browser.Key -Url $Browser.Value -FileName "$($Browser.Key.ToLower()).msi" -Type "msi"
    }
} else {
    Write-Host ""
    Write-Host "Skipping browsers..."
    Write-Host ""
}

$Launchers = @{
    "Steam" = "https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe"
    "Epic Games" = "https://launcher-public-service-prod06.ol.epicgames.com/launcher/api/installer/download/EpicGamesLauncherInstaller.msi"
}

$InstallLaunchers = (Read-Host "Would you like to download and install game launchers? (y/n)").ToLower() -eq "y"
if ($InstallLaunchers) {
    Write-Host ""
    Write-Host "Choose your game launchers..." -ForegroundColor Green
    Write-Host ""

    foreach ($Launcher in $Launchers.GetEnumerator()) {
        if ($Launcher.Key -eq "Steam") {
            Handle-Installation -Name $Launcher.Key -Url $Launcher.Value -FileName "SteamSetup.exe" -Type "exe"
        } else {
            Handle-Installation -Name $Launcher.Key -Url $Launcher.Value -FileName "$($Launcher.Key.ToLower()).msi" -Type "msi"
        }
    }
} else {
    Write-Host ""
    Write-Host "Skipping game launchers..."
    Write-Host ""
}
