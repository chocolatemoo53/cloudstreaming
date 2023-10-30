Clear-Host
Write-Host "Opening in a new window..." -ForegroundColor Red
Write-Host "Thank you for using this script! Remember that all steps taken in the script are reversable..." -ForegroundColor Green
Start-Process powershell.exe -verb RunAS -argument "-file $PSScriptRoot\starthere.ps1"
