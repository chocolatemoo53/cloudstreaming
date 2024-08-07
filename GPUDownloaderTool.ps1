$specialFolder = "c:\cloudstreaming"

$GamingBucket = "nvidia-gaming"
$GamingKeyPrefix = "windows/latest"
$GamingLocalPath = "$home\Desktop\NVIDIA"

$Bucket = "ec2-windows-nvidia-drivers"
$KeyPrefix = "latest"
$LocalPath = "$home\Desktop\NVIDIA"

Write-Host "Welcome! This script will install your GPU drivers."

Write-Host "Choose your cloud provider"
Write-Host "1. AWS"
Write-Host "2. Google Cloud"

$provider = Read-Host -Prompt 'Type the number corresponding to your choice'

if ($provider -eq 1) {
    $access = Read-Host -Prompt 'Enter AWS access key'
    $secret = Read-Host -Prompt 'Enter AWS secret key'
    Write-Host "Setting credentials, this may take a while..." -ForegroundColor Yellow
    Set-AWSCredential -AccessKey $access -SecretKey $secret -StoreAs default
    Write-Host "Credentials set!" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "Choose your instance type"
    Write-Host "1. G4DN instance"
    Write-Host "2. G5 instance"
    $instanceType = Read-Host -Prompt 'Type the number corresponding to your instance type'
    Write-Host ""
    
    Write-Host "Choose your driver type"
    Write-Host "1. Gaming"
    Write-Host "2. GRID"
    $driverType = Read-Host -Prompt 'Type the number corresponding to your choice'
    
    if ($driverType -eq 1) {
        Write-Host "Downloading gaming driver..."
        if (-not (Test-Path $GamingLocalPath)) {
            New-Item -Path $GamingLocalPath -ItemType Directory | Out-Null
        }

        $GamingObjects = Get-S3Object -BucketName $GamingBucket -KeyPrefix $GamingKeyPrefix -Region us-east-1

        foreach ($GamingObject in $GamingObjects) {
            if ($GamingObject.Key -and $GamingObject.Size -gt 0) {
                $GamingLocalFilePath = Join-Path $GamingLocalPath $GamingObject.Key
                $GamingLocalDir = [System.IO.Path]::GetDirectoryName($GamingLocalFilePath)
                
                if (-not (Test-Path $GamingLocalDir)) {
                    New-Item -Path $GamingLocalDir -ItemType Directory | Out-Null
                }

                Write-Output "Downloading $($GamingObject.Key) to $GamingLocalFilePath"

                try {
                    Copy-S3Object -BucketName $GamingBucket -Key $GamingObject.Key -LocalFile $GamingLocalFilePath -Region us-east-1
                    Write-Output "Successfully downloaded $($GamingObject.Key)"
                } catch {
                    Write-Error "Failed to copy $($GamingObject.Key): $_"
                }
            }
        }
        
        Write-Host "Installing gaming driver..."
        Start-Process -FilePath "$([Environment]::GetFolderPath('Desktop'))\NVIDIA\windows\latest\*.exe" -Wait -ArgumentList "/s /n"
        Write-Host "Registering driver..." 
        New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global" -Name "vGamingMarketplace" -PropertyType "DWord" -Value 2 -Force
        Write-Host "Driver installed!" -ForegroundColor Green
    }

    if ($driverType -eq 2) {
        if (-not (Test-Path $LocalPath)) {
            New-Item -Path $LocalPath -ItemType Directory | Out-Null
        }

        $Objects = Get-S3Object -BucketName $Bucket -KeyPrefix $KeyPrefix -Region us-east-1

        foreach ($Object in $Objects) {
            if ($Object.Key -ne '' -and $Object.Size -ne 0) {
                $LocalFilePath = Join-Path $LocalPath $Object.Key
                $LocalDir = [System.IO.Path]::GetDirectoryName($LocalFilePath)
                
                if (-not (Test-Path $LocalDir)) {
                    New-Item -Path $LocalDir -ItemType Directory | Out-Null
                }

                try {
                    Copy-S3Object -BucketName $Bucket -Key $Object.Key -LocalFile $LocalFilePath -Region us-east-1
                } catch {
                    Write-Error "Failed to copy $($Object.Key): $_"
                }
            }
        }
        
        Write-Host "Installing GRID driver..."
        Start-Process -FilePath "$([Environment]::GetFolderPath('Desktop'))\NVIDIA\latest\*.exe" -Wait -ArgumentList "/s /n"
        Write-Host "Registering driver..."
        New-Item -Path "HKLM:\SOFTWARE\NVIDIA Corporation\Global" -Name GridLicensing -Force
        New-ItemProperty -Path "HKLM:\SOFTWARE\NVIDIA Corporation\Global\GridLicensing" -Name "NvCplDisableManageLicensePage" -PropertyType "DWord" -Value 1 -Force
        Write-Host "Driver installed!" -ForegroundColor Green
    }

    if ($instanceType -eq 1) {
        Start-Process cmd.exe -ArgumentList "/c cd C:\Windows\System32\DriverStore\FileRepository\nvgrid*\ && .\nvidia-smi -ac 5001,1590" -Wait
    }

    if ($instanceType -eq 2) {
        Start-Process cmd.exe -ArgumentList "/c cd C:\Windows\System32\DriverStore\FileRepository\nvgrid*\ && .\nvidia-smi -ac 6250,1710" -Wait
    }
}

if ($provider -eq 2) {
    Invoke-WebRequest -Uri "https://github.com/GoogleCloudPlatform/compute-gpu-installation/raw/main/windows/install_gpu_driver.ps1" -OutFile "$specialFolder\install_gpu_driver.ps1"
    & "$specialFolder\install_gpu_driver.ps1"
}

$restart = (Read-Host "To finish installation, you should restart. Restart now? (y/n)").ToLower()
if ($restart -eq "y") {
    Restart-Computer -Force
}
