$nugetInstalled = Get-PackageProvider -Name NuGet -Force -ErrorAction SilentlyContinue
if (-not $nugetInstalled) {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
}

$moduleName = "DisplayConfig"
$moduleInstalled = Get-InstalledModule -Name $moduleName -ErrorAction SilentlyContinue
if (-not $moduleInstalled) {
    Install-Module -Name $moduleName -Force -Scope CurrentUser -AllowClobber
}

Import-Module $moduleName -Force

$adapterToKeep = @("Virtual Display Driver", "Parsec Virtual Display Adapter")
$gpuToKeep = "NVIDIA"
$remoteDisplayKeywords = @("Microsoft Basic Display Adapter", "Microsoft Remote Display Adapter")

$displayAdapters = Get-PnpDevice -Class "Display"
foreach ($adapter in $displayAdapters) {
    if ($remoteDisplayKeywords -contains $adapter.FriendlyName) {
        if ($adapter.Status -eq "OK") {
            Disable-PnpDevice -InstanceId $adapter.InstanceId -Confirm:$false
        }
    }
}

if (Get-Command Get-DisplayInfo -ErrorAction SilentlyContinue) {
    $disp = Get-DisplayInfo | Where-Object { $_.DisplayName -eq $adapterToKeep }
    if ($disp) {
        Set-DisplayPrimary -DisplayId $disp.DisplayId
    }
    else {
        Write-Host "Error: $adapterToKeep not found. Could not set primary display."
    }
} else {
    Write-Host "Error: Get-DisplayInfo cmdlet not found. Please ensure DisplayConfig module is installed correctly."
}

foreach ($adapter in $displayAdapters) {
    if ($adapter.FriendlyName -notmatch $adapterToKeep -and $adapter.FriendlyName -notmatch $gpuToKeep) {
        if ($adapter.Status -eq "OK") {
            Disable-PnpDevice -InstanceId $adapter.InstanceId -Confirm:$false
        }
    }
}

$primaryDisplay = Get-DisplayInfo | Where-Object { $_.IsPrimary }
if ($primaryDisplay.DisplayName -eq $adapterToKeep) {
    Write-Host "$adapterToKeep is now the primary display."
}
else {
    Write-Host "Error: $adapterToKeep is not the primary display."
}
