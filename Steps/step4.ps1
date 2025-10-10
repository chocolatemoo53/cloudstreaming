$adapterToKeep = "VDD by MTT"
$gpuToKeep = "NVIDIA"
$remoteDisplayKeywords = @("Microsoft Basic Display Adapter", "Microsoft Remote Display Adapter")

if (-not (Get-InstalledModule -Name DisplayConfig -ErrorAction SilentlyContinue)) {
    Install-Module -Name DisplayConfig -Force -Scope CurrentUser
}

$displayAdapters = Get-PnpDevice -Class "Display"

foreach ($adapter in $displayAdapters) {
    if ($remoteDisplayKeywords -contains $adapter.FriendlyName) {
        if ($adapter.Status -eq "OK") {
            Disable-PnpDevice -InstanceId $adapter.InstanceId -Confirm:$false
        }
    }
}

$disp = Get-DisplayInfo | Where-Object { $_.DisplayName -eq $adapterToKeep }

if ($disp) {
    Set-DisplayPrimary -DisplayId $disp.DisplayId
}
else {
    Write-Host "Error: $adapterToKeep not found. Could not set primary display."
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
