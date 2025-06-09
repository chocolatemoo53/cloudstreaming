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

Write-Host "Choose your cloud provider"
Write-Host "1. AWS"
Write-Host "2. Google Cloud"
Write-Host "3. Other cloud provider"
$provider = Read-Host -Prompt 'Type the number corresponding to your cloud provider'

if($provider -in 1, 2) {
Enable-MMAgent -MemoryCompression | Out-Null
New-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "ServicesPipeTimeout" -Value 600000 -PropertyType "DWord" | Out-Null
Set-Service -Name Audiosrv -StartupType Automatic | Out-Null
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" /v ShutDownReasonOn /t REG_DWORD /d 0 /f | Out-Null
Write-Host "Applying accessibility flags..."
Set-ItemProperty "HKCU:\Control Panel\Accessibility\StickyKeys" "Flags" "506" | Out-Null
Set-ItemProperty "HKCU:\Control Panel\Accessibility\Keyboard Response" "Flags" "122"| Out-Null
Set-ItemProperty "HKCU:\Control Panel\Accessibility\ToggleKeys" "Flags" "58" | Out-Null
}

if ($provider -in 1, 2) {
    Write-Host ""
    if($osType.ProductType -eq 3) {
        Write-Host "Installing .NET Framework 3.5..."
        Install-WindowsFeature NET-Framework-Features | Out-Null
    }

    Write-Host ""
    if($osType.ProductType -eq 3) {
        Write-Host "Installing Windows Media Foundation..."
        Install-WindowsFeature Server-Media-Foundation | Out-Null
    }
}

if($provider -eq 1) {
    Write-Host ""
    if($osType.ProductType -eq 3) {
        Write-Host "Installing Quality Windows Audio/Video Experience..."
        Install-WindowsFeature -Name QWAVE | Out-Null 
    }
}

$Login = (Read-Host "Do you need to setup auto login? (not needed for Amazon DCV, y/n)").ToLower() -eq "y"

if($Login) {
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

if($timeZoneQuestion) {
Write-Host "Please use the full name (example: Pacific Standard Time)"-ForegroundColor Red
$timeZone = Read-Host -Prompt 'What is your time zone?'
Set-TimeZone -Name "$timezone"
}
