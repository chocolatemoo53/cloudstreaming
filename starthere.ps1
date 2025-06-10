Param([Parameter(Mandatory=$false)] [Switch]$RebootSkip)
$host.ui.RawUI.WindowTitle = "cloudstreaming"
Start-Transcript -Path "$PSScriptRoot\Log.txt"
function Elevated {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object System.Security.Principal.WindowsPrincipal($id)
    if ($p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))
   { Write-Output $true }      
    else
   { Write-Output $false }   
 }

 if (-not(Elevated))
 { throw "Please run this script as a built-in or elevated Administrator" 
   Stop-Transcript
   Pause
}

function Write-HostCenter { param($Message) Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Message.Length / 2)))), $Message) }

Clear-Host

Write-HostCenter "Starting up..."
New-Item -Path C:\cloudstreaming -ItemType directory | Out-Null
New-Item -Path C:\cloudstreaming\Installers -ItemType directory | Out-Null
New-Item -Path C:\cloudstreaming\Drivers -ItemType directory | Out-Null
Write-HostCenter "The script is now ready to begin!" -ForegroundColor Green
Write-Host ""

if(!$RebootSkip) {
    Write-Host "Your machine may restart at least once during this setup!" -ForegroundColor Red
    Write-Host ""
    $OldVersion = (Read-Host "Are you using Windows Server 2019 and below? (y/n)").ToLower() -eq "y"
    if($OldVersion) {
      Write-Host "Removing IE restrictions..."
      Set-Itemproperty "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -name IsInstalled -value 0 -force | Out-Null
      Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" -Name IsInstalled -Value 0 -Force | Out-Null
      Stop-Process -Name Explorer -Force
    }
    Write-Host "Step 1 - Installing required software..." -ForegroundColor Yellow
    & $PSScriptRoot\Steps\step1.ps1 -Main
} else {
if(Get-ScheduledTask | Where-Object {$_.TaskName -like "Continue" }) {
  Unregister-ScheduledTask -TaskName "Continue" -Confirm:$false
}
Write-Host "Welcome back, let's continue with step two!"
}
  Write-Host ""
  Write-Host "Step 2 - Applying general fixes and installing Windows Features..." -ForegroundColor Yellow
  & $PSScriptRoot\Steps\step2.ps1
  Write-Host ""
  Write-Host "Step 3 - Installing applications..." -ForegroundColor Yellow
  & $PSScriptRoot\Steps\step3.ps1
	Write-Host ""
  Write-Host "Script and server setup is now complete!"
	$ip = (Invoke-WebRequest ifconfig.me/ip).Content
	Write-Host "Your IP address is $ip" -ForegroundColor Red
  Write-Host "Use this IP address in Moonlight or Amazon DCV." -ForegroundColor Yellow
  Write-Host "Connect to your server with Tailscale or setup a dynamic DNS service." -ForegroundColor Yellow
	Write-Host "If you liked the script, please star it on GitHub!" -ForegroundColor Green

    $restart = (Read-Host "It is recommenended to restart your server. Restart now? (y/n)").ToLower();
    if($restart -eq "y") {
    Restart-Computer -Force 
}
