$osType = Get-CimInstance -ClassName Win32_OperatingSystem
$WorkDir = "$PSScriptRoot\..\Bin"
$specialFolder = "c:\cloudstreaming"
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

Write-Host "If you are not running Windows Server, a portion of this step is skipped" -ForegroundColor Red

if($osType.ProductType -eq 3) {
Write-Host "Applying general fixes..."
Enable-MMAgent -MemoryCompression | Out-Null
New-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "ServicesPipeTimeout" -Value 600000 -PropertyType "DWord" | Out-Null
Set-Service -Name Audiosrv -StartupType Automatic | Out-Null
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" /v ShutDownReasonOn /t REG_DWORD /d 0 /f | Out-Null
}

Write-Host ""
if ($osType.ProductType -eq 3) {
    Write-Host "Applying accessibility flags..."
    Set-ItemProperty "HKCU:\Control Panel\Accessibility\StickyKeys" "Flags" "506" | Out-Null
    Set-ItemProperty "HKCU:\Control Panel\Accessibility\Keyboard Response" "Flags" "122"| Out-Null
    Set-ItemProperty "HKCU:\Control Panel\Accessibility\ToggleKeys" "Flags" "58" | Out-Null
}

Write-Host ""
if($osType.ProductType -eq 3) {
    Write-Host "Installing .NET Framework 3.5..."
    Install-WindowsFeature NET-Framework-Features | Out-Null
}

Write-Host ""
if($osType.ProductType -eq 3) {
    Write-Host "Installing Quality Windows Audio/Video Experience..."
    Install-WindowsFeature -Name QWAVE | Out-Null 
}

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

Write-Host ""
Write-Host 'Please use the full name (example: Pacific Standard Time)' -ForegroundColor Red
$timezone = Read-Host -Prompt 'What is your time zone?'
Set-TimeZone -Name "$timezone"

Write-Host ""
Write-Host 'You may be able to remove system info from the desktop by forcing a wallpaper'
$setWallpaper = (Read-Host -Prompt 'Would you like to do so? (y/n)').ToLower() -eq "y"

if($setWallpaper) {
GetFile "https://cdn.wallpaperhub.app/cloudcache/7/c/2/f/3/4/7c2f345bdfcadb8a3faf483ebaa2e9aea712bbdb.jpg" "$WorkDir\wallpaper.jpg" "Default Server 2019 Wallpaper"
Move-Item -Path "$WorkDir\wallpaper.jpg" -Destination "$specialfolder\wallpaper.jpg"
Write-Host "Setting the wallpaper..."
New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies" -Name "System" | Out-Null
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name Wallpaper -value "c:\cloudstreaming\wallpaper.jpg" | Out-Null
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name WallpaperStyle -value 2 | Out-Null
Stop-Process -Name Explorer -Force
}	
