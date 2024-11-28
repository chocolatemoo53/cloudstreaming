$WorkDir = "$PSScriptRoot\..\Bin"
$specialFolder = "C:\cloudstreaming"

Function GetFile([string]$Url, [string]$Path, [string]$Name) {
    if(!(Test-Path $Path)) {
        Write-Host "Downloading $Name..."
        try { Start-BitsTransfer $Url $Path }
        catch { Write-Error "Download failed for $Name" }
    }
}

Import-Module BitsTransfer

$installations = @{
    "Utilities" = @{
        "Tailscale" = @{
            Url = "https://pkgs.tailscale.com/stable/tailscale-setup-latest.msi";
            Path = "$specialFolder\Installers\tailscale.msi";
            InstallArgs = '/qn /i'
        }
        "7-Zip" = @{
            Url = "https://ninite.com/7zip/ninite.exe";
            Path = "$specialFolder\Installers\7zip.exe";
            InstallArgs = '/S'
        }
        "Notepad++" = @{
            Url = "https://ninite.com/notepadplusplus/ninite.exe";
            Path = "$specialFolder\Installers\notepadpp.exe";
            InstallArgs = '/S'
        }
    }
    "Browsers" = @{
        "Firefox" = @{
            Url = "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=en-US";
            Path = "$specialFolder\Installers\firefox.msi";
            InstallArgs = '/q /i'
        }
        "Edge" = @{
            Url = "http://go.microsoft.com/fwlink/?LinkID=2093437";
            Path = "$specialFolder\Installers\edge.msi";
            InstallArgs = '/qn /i'
        }
        "Chrome" = @{
            Url = "https://dl.google.com/tag/s/dl/chrome/install/googlechromestandaloneenterprise64.msi";
            Path = "$specialFolder\Installers\chrome.msi";
            InstallArgs = '/qn /i'
        }
    }
    "Launchers" = @{
        "Steam" = @{
            Url = "https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe";
            Path = "$WorkDir\SteamSetup.exe";
            InstallArgs = "/S"
        }
        "Epic" = @{
            Url = "https://launcher-public-service-prod06.ol.epicgames.com/launcher/api/installer/download/EpicGamesLauncherInstaller.msi";
            Path = "$specialFolder\Installers\epic.msi";
            InstallArgs = '/qn /i'
        }
    }
}

function InstallSoftware($category, $softwareList) {
    $installCategory = (Read-Host "Would you like to download and install $category? (y/n)").ToLower() -eq "y"
    if ($installCategory) {
        Write-Host "`nChoose your $category..." -ForegroundColor Green
        foreach ($software in $softwareList.Keys) {
            $install = (Read-Host "Would you like to download and install $software? (y/n)").ToLower() -eq "y"
            if ($install) {
                $item = $softwareList[$software]
                GetFile $item.Url $item.Path $software
                Write-Host "Installing $software..."
                
                if ($software -in @("Steam", "7-Zip", "Notepad++")) {
                    Start-Process -FilePath $item.Path -ArgumentList $item.InstallArgs -NoNewWindow -Wait
                } else {
                    Start-Process -FilePath "msiexec.exe" -Wait -ArgumentList "$($item.InstallArgs) $($item.Path)"
                }
            } else {
                Write-Host "`nSkipping $software...`n"
            }
        }
    } else {
        Write-Host "`nSkipping $category...`n"
    }
}

InstallSoftware "Utilities" $installations.Utilities
InstallSoftware "Browsers" $installations.Browsers
InstallSoftware "Launchers" $installations.Launchers