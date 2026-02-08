$osType = Get-CimInstance -ClassName Win32_OperatingSystem
$specialFolder = "C:\cloudstreaming"
$installerFolder = "$specialFolder\Installers"
$WorkDir = "$PSScriptRoot\..\Bin"
$driverFolder = "$specialFolder\Drivers"

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

if (Request-UserInput "What is your username and password? (skip this if you are an Amazon DCV user, y/n)") {
    Write-Host ""
    Write-Host 'Configuring automatic login...'
    $RegPath = "hklm:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String | Out-Null
    $username = Read-Host -Prompt 'Enter your username (AWS uses Administrator by default)'
    $securedValue = Read-Host -AsSecureString -Prompt 'Please input your password'
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securedValue)
    $value = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    Set-ItemProperty $RegPath "DefaultPassword" -Value "$value" -type String | Out-Null
    Set-ItemProperty $RegPath "DefaultUserName" -Value "$username" -type String | Out-Null
    Set-ItemProperty $RegPath "DefaultDomainName" -Value "" -type String | Out-Null
}
else {
    Write-Host "Skipping automatic login..."
}

Write-Host ""
if (Request-UserInput "Would you like to set a time zone? (y/n)") {
    Write-Host "Please use the full name (example: Pacific Standard Time)" -ForegroundColor Red
    if (Request-UserInput "What is your time zone?") {
    Set-TimeZone -Name "$timezone"
    }
}
else {
    Write-Host "Skipping time zone setup..."
}

Write-Host ""
Write-Host "You can remove system info from the desktop by forcing a wallpaper." -ForegroundColor Yellow
if (Request-UserInput "Would you like to do so? (y/n)") {
    GetFile "https://www.goodfreephotos.com/albums/sky-and-clouds/clouds-above-the-cloud-sea.jpg" "$specialFolder\wallpaper.jpg" "Cloud wallpaper"
    Write-Host "Setting the wallpaper..."
    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies" -Name "System" | Out-Null
    New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name Wallpaper -value "C:\cloudstreaming\wallpaper.jpg" | Out-Null
    New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name WallpaperStyle -value 2 | Out-Null
    Stop-Process -Name Explorer -Force
    Write-Host "You can change the wallpaper by replacing the file at C:\cloudstreaming\wallpaper.jpg"
}	
else {
    Write-Host "Skipping wallpaper change..."
}

if (Request-UserInput "Would you like to download and install Tailscale? (y/n)") {
    Write-Host "If you're using Amazon DCV or Sunshine, you must use Tailscale or have dynamic DNS."
    InstallMSI "Tailscale" "https://pkgs.tailscale.com/stable/tailscale-setup-latest-amd64.msi" "$installerFolder\tailscale.msi"
}
else {
    Write-Host "Skipping Tailscale..."
}

Write-Host "All software after this point is optional and should install silently..."

if (Request-UserInput "Would you link to enable the Microsoft Store? (y/n)") {
    wsreset -i
}
else {
    Write-Host "Skipping the Microsoft Store..."
}

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

Write-Host "Turning off shutdown reason..."
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" /v ShutDownReasonOn /t REG_DWORD /d 0 /f | Out-Null

Write-Host "Getting a useful Windows feature..."
if ($osType.ProductType -eq 3) {
    Write-Host "Installing Windows Media Foundation..."
    Install-WindowsFeature Server-Media-Foundation | Out-Null
}

Write-Host "Choose your streaming technology!"
Write-Host "1. Parsec (Best for most people)"
Write-Host "2. Amazon DCV (For AWS customers)"
Write-Host "3. Sunshine (For use with Moonlight)"
Write-Host "Consult the wiki for more information"

$streamTech = Read-Host -Prompt 'Type the number corresponding your choice'

if ($streamTech -eq 1) {
    Write-Host ""
    GetFile "https://builds.parsecgaming.com/package/parsec-windows.exe" "$installerFolder\parsec.exe" "Parsec"
    Write-Host "Installing Parsec..."
    Start-Process -FilePath "$installerFolder\parsec.exe" -ArgumentList "/norun /silent /vdd" -NoNewWindow -Wait 
}

if ($streamTech -eq 2) {
    Request-UserInput "Would you like to download and install Amazon DCV? (y/n)" {
        InstallMSI "Amazon DCV" "https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-server-x64-Release.msi" "$installerFolder\dcv.msi"
    }
}

if ($streamTech -eq 3) {
    Write-Host ""
    GetFile "https://github.com/LizardByte/Sunshine/releases/latest/download/sunshine-Windows-amd64-installer.exe" "$installerFolder\sunshine.exe" "Sunshine"
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
