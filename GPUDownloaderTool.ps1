$specialFolder = "c:\cloudstreaming"

Write-Host "Welcome! This script will install your GPU drivers."

Write-Host "Choose your cloud provider"
Write-Host "1. AWS"
Write-Host "2. Google Cloud"

$provider = Read-Host -Prompt 'Type the number corresponding your choice'

if ($provider -eq 1) {
    $access = Read-Host -Prompt 'Enter a AWS access key'
    $secret = Read-Host -Prompt 'Enter a AWS secret key'
    Set-AWSCredential `
                 -AccessKey $access `
                 -SecretKey $secret `
                 -StoreAs default
    Write-Host "Choose your instance type"
    Write-Host "1. G4DN instance"
    Write-Host "2. G5 instance"
    $instanceType = Read-Host -Prompt 'Type the number corresponding to your instance type'
    Write-Host "Choose your driver type"
    Write-Host "1. Gaming"
    Write-Host "2. GRID"
    $driverType = Read-Host -Prompt 'Type the number corresponding your choice'
    if ($driverType -eq 1) {
        $Bucket = "nvidia-gaming"
        $KeyPrefix = "windows/latest"
        $LocalPath = "$home\Desktop\NVIDIA"
        $Objects = Get-S3Object -BucketName $Bucket -KeyPrefix $KeyPrefix -Region us-east-1
        foreach ($Object in $Objects) {
            $LocalFileName = $Object.Key
            if ($LocalFileName -ne '' -and $Object.Size -ne 0) {
                $LocalFilePath = Join-Path $LocalPath $LocalFileName
                Copy-S3Object -BucketName $Bucket -Key $Object.Key -LocalFile $LocalFilePath -Region us-east-1
            }
        }
    Start-Process -FilePath "$([Environment]::GetFolderPath('Desktop'))\NVIDIA\windows\latest\*.exe" -Wait -ArgumentList "/s /n"
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global" -Name "vGamingMarketplace" -PropertyType "DWord" -Value "2"
    Invoke-WebRequest -Uri "https://nvidia-gaming.s3.amazonaws.com/GridSwCert-Archive/GridSwCertWindows_2021_10_2.cert" -OutFile "$Env:PUBLIC\Documents\GridSwCert.txt"
    }
    if ($driverType -eq 2) {
        $Bucket = "ec2-windows-nvidia-drivers"
        $KeyPrefix = "latest"
        $LocalPath = "$home\Desktop\NVIDIA"
        $Objects = Get-S3Object -BucketName $Bucket -KeyPrefix $KeyPrefix -Region us-east-1
        foreach ($Object in $Objects) {
            $LocalFileName = $Object.Key
            if ($LocalFileName -ne '' -and $Object.Size -ne 0) {
                $LocalFilePath = Join-Path $LocalPath $LocalFileName
                Copy-S3Object -BucketName $Bucket -Key $Object.Key -LocalFile $LocalFilePath -Region us-east-1
            }
        }
    Start-Process -FilePath "$([Environment]::GetFolderPath('Desktop'))\NVIDIA\latest\*.exe" -Wait -ArgumentList "/s /n"
    New-Item -Path "HKLM:\SOFTWARE\NVIDIA Corporation\Global" -Name GridLicensing
    New-ItemProperty -Path "HKLM:\SOFTWARE\NVIDIA Corporation\Global\GridLicensing" -Name "NvCplDisableManageLicensePage" -PropertyType "DWord" -Value "1"
    }
    if ($instanceType -eq 1) {
        Start-Process cmd.exe "cd C:\Windows\System32\DriverStore\FileRepository\nvgrid*\ && .\nvidia-smi -ac "5001,1590""
    }
    if ($instanceType -eq 2) {
        Start-Process cmd.exe "cd C:\Windows\System32\DriverStore\FileRepository\nvgrid*\ && .\nvidia-smi -ac "6250,1710""
    }
}
if ($provider -eq 2) {
    Invoke-WebRequest -Uri "https://github.com/GoogleCloudPlatform/compute-gpu-installation/raw/main/windows/install_gpu_driver.ps1" -OutFile "$specialFolder\install_gpu_driver.ps1"
    & $specialFolder\install_gpu_driver.ps1
}

$restart = (Read-Host "To finish installation, you should restart. Restart now? (y/n)").ToLower();
    if($restart -eq "y") {
    Restart-Computer -Force
}

