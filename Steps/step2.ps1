$osType = Get-CimInstance -ClassName Win32_OperatingSystem
$specialFolder = "C:\cloudstreaming"
$installerFolder = "$specialFolder\Installers"

Function InstallMSI([string]$name, [string]$url, [string]$path) {
    GetFile $url $path $name
    Write-Host "Installing $name..."
    Start-Process -FilePath "msiexec.exe" -Wait -ArgumentList "/qn /i `"$path`""
    Write-Host ""
}

Function Request-UserInput([string]$Prompt) {
    return (Read-Host $Prompt).Trim().ToLower() -eq 'y'
}

Write-Host "Turning on various settings..."
Enable-MMAgent -MemoryCompression | Out-Null
Set-Service -Name Audiosrv -StartupType Automatic | Out-Null
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" /v ShutDownReasonOn /t REG_DWORD /d 0 /f | Out-Null
Set-ItemProperty "HKCU:\Control Panel\Accessibility\StickyKeys" "Flags" "506" | Out-Null
Set-ItemProperty "HKCU:\Control Panel\Accessibility\Keyboard Response" "Flags" "122" | Out-Null
Set-ItemProperty "HKCU:\Control Panel\Accessibility\ToggleKeys" "Flags" "58" | Out-Null

Write-Host ""
if ($osType.ProductType -eq 3) {
    Write-Host "Installing Windows Media Foundation..."
    Install-WindowsFeature Server-Media-Foundation | Out-Null
}

if (Request-UserInput "Would you like to download and install Tailscale? (y/n)") {
    InstallMSI "Tailscale" "https://pkgs.tailscale.com/stable/tailscale-setup-latest-amd64.msi" "$installerFolder\tailscale.msi"
}
else {
    Write-Host "Skipping Tailscale..."
}

$Login = (Read-Host "Do you need to setup auto login? (not needed for Amazon DCV, y/n)").ToLower() -eq "y"

if ($Login) {
    Write-Host ""
    Write-Host 'Configuring automatic login...'
    $RegPath = "hklm:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String | Out-Null
    $username = Read-Host -Prompt 'Enter your username'
    $securedValue = Read-Host -AsSecureString -Prompt 'Please input your password'
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securedValue)
    $value = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    Set-ItemProperty $RegPath "DefaultPassword" -Value "$value" -type String | Out-Null
    Set-ItemProperty $RegPath "DefaultUserName" -Value "$username" -type String | Out-Null
    Set-ItemProperty $RegPath "DefaultDomainName" -Value "" -type String | Out-Null
}

Write-Host ""
$timeZoneQuestion = (Read-Host "Do you want to set a time zone? (y/n)").ToLower() -eq "y"

if ($timeZoneQuestion) {
    Write-Host "Please use the full name (example: Pacific Standard Time)" -ForegroundColor Red
    $timeZone = Read-Host -Prompt 'What is your time zone?'
    Set-TimeZone -Name "$timezone"
}

Write-Host ""
Write-Host "You can remove system info from the desktop by forcing a wallpaper."
$setWallpaper = (Read-Host -Prompt 'Would you like to do so? (y/n)').ToLower() -eq "y"

if ($setWallpaper) {
    GetFile "https://www.goodfreephotos.com/albums/sky-and-clouds/clouds-above-the-cloud-sea.jpg" "$specialFolder\wallpaper.jpg" "Cloud wallpaper"
    Write-Host "Setting the wallpaper..."
    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies" -Name "System" | Out-Null
    New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name Wallpaper -value "C:\cloudstreaming\wallpaper.jpg" | Out-Null
    New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name WallpaperStyle -value 2 | Out-Null
    Stop-Process -Name Explorer -Force
    Write-Host "You can change the wallpaper by going to C:\cloudstreaming\wallpaper.jpg"
}	