$specialFolder = "c:\cloudstreaming"

$GamingBucket = "nvidia-gaming"
$GamingKeyPrefix = "windows/latest"

$GRIDBucket = "ec2-windows-nvidia-drivers"
$GRIDKeyPrefix = "latest"

$LocalPath = "$home\Desktop\NVIDIA"

Start-Transcript -Path "$specialfolder\GPUDownloaderLog.txt"

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

Write-Host "Welcome! This tool will install your GPU drivers."
Write-Host "Choose your cloud provider"
Write-Host "1. AWS"
Write-Host "2. Google Cloud"
$provider = Read-Host -Prompt 'Type the number corresponding to your cloud provider'

if ($provider -eq 1) {
    Write-Host "Checking for AWS credentials, this may take a while..."
    if ($null -ne (Get-AWSCredential -ProfileName default)) {
        Write-Host "AWS credentials already set!" -ForegroundColor Green
    }
    else {
        Write-Host "AWS credentials not found. Make ones and set them."
        $access = Read-Host -Prompt 'Enter AWS access key'
        $secret = Read-Host -Prompt 'Enter AWS secret key'
        Write-Host "Setting credentials, this may take a while..." -ForegroundColor Yellow
        Set-AWSCredential -AccessKey $access -SecretKey $secret -StoreAs default
        Write-Host "Credentials set!" -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "Choose your instance type"
    Write-Host "1. G3 instance"
    Write-Host "2. G4DN instance"
    Write-Host "3. G5 instance"
    Write-Host "4. G6 instance"
    Write-Host "5. Gr6 instance"
    Write-Host "6. G6e instance"
    $instanceType = Read-Host -Prompt 'Type the number corresponding to your instance type'
    if ($instanceType -in 2, 3, 4, 6) {
        Write-Host ""
        Write-Host "Choose your driver type"
        Write-Host "1. Gaming"
        Write-Host "2. GRID"
        Write-Host "Gaming drivers have specific game enhancements while GRID is for professional workstations."
        $driverType = Read-Host -Prompt 'Type the number corresponding to your choice'
    }
    else {
        Write-Host "Your instance is only compatible with GRID drivers."
        Write-Host "If you want gaming drivers, you must use a different instance."
        $acknowledge = Read-Host "Would you like to continue with GRID driver installation? (y/n)"
        if ($acknowledge.ToLower() -eq "y") {
            Write-Host "Continuing with GRID driver installation..."
            $driverType = 2 
        }
        else {
            Write-Host "Exiting the script as the user chose not to continue."
            exit 1 
        }
    }
    
    if ($driverType -eq 1) {
        Write-Host ""
        Write-Host "Downloading gaming driver..."
        $GamingObjects = Get-S3Object -BucketName $GamingBucket -KeyPrefix $GamingKeyPrefix -Region us-east-1
        foreach ($GamingObject in $GamingObjects) {
            if ($GamingObject.Key -and $GamingObject.Size -gt 0) {
                $GamingLocalFilePath = Join-Path $LocalPath $GamingObject.Key

                Write-Output "Downloading $($GamingObject.Key) to $GamingLocalFilePath"

                try {
                    Copy-S3Object -BucketName $GamingBucket -Key $GamingObject.Key -LocalFile $GamingLocalFilePath -Region us-east-1
                    Write-Output "Successfully downloaded $($GamingObject.Key)"
                }
                catch {
                    Write-Error "Failed to copy $($GamingObject.Key): $_"
                    Write-Host "Press enter to exit"
                    Read-Host
                    Stop-Transcript
                    Throw "Error noted in the log file"
                }
            }
        }
        
        Write-Host "Installing gaming driver..."
        Start-Process -FilePath "$([Environment]::GetFolderPath('Desktop'))\NVIDIA\windows\latest\*.exe" -Wait -ArgumentList "/s /n"
        Write-Host "Registering driver..." 
        New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global" -Name "vGamingMarketplace" -PropertyType "DWord" -Value 2 -Force
        Start-BitsTransfer -Source "https://nvidia-gaming.s3.amazonaws.com/GridSwCert-Archive/GridSwCertWindows_2023_9_22.cert" -Destination "$Env:PUBLIC\Documents\GridSwCert.txt"   
        Write-Host "Driver installed!" -ForegroundColor Green
    }

    if ($driverType -eq 2) {
        if (-not (Test-Path $LocalPath)) {
            New-Item -Path $LocalPath -ItemType Directory | Out-Null
        }

        $Objects = Get-S3Object -BucketName $GRIDBucket -KeyPrefix $GRIDKeyPrefix -Region us-east-1

        foreach ($Object in $Objects) {
            if ($Object.Key -ne '' -and $Object.Size -ne 0) {
                $LocalFilePath = Join-Path $LocalPath $Object.Key
                
                try {
                    Copy-S3Object -BucketName $GRIDBucket -Key $Object.Key -LocalFile $LocalFilePath -Region us-east-1
                }
                catch {
                    Write-Error "Failed to copy $($Object.Key): $_"
                    Write-Host "Press enter to exit"
                    Read-Host
                    Stop-Transcript
                    Throw "Error noted in the log file"
                }
            }
        }
        
        Write-Host ""
        Write-Host "Installing GRID driver..."
        Start-Process -FilePath "$([Environment]::GetFolderPath('Desktop'))\NVIDIA\latest\*.exe" -Wait -ArgumentList "/s /n"
        Write-Host "Registering driver..."
        New-Item -Path "HKLM:\SOFTWARE\NVIDIA Corporation\Global" -Name GridLicensing -Force
        New-ItemProperty -Path "HKLM:\SOFTWARE\NVIDIA Corporation\Global\GridLicensing" -Name "NvCplDisableManageLicensePage" -PropertyType "DWord" -Value 1 -Force
        Write-Host "Driver installed!" -ForegroundColor Green
    }

    if ($instanceType -eq 1) {
        Start-Process cmd.exe -ArgumentList "/c cd C:\Windows\System32\DriverStore\FileRepository\nvgrid*\ && .\nvidia-smi -ac 2505,1177" -Wait
    }
    if ($instanceType -eq 2) {
        Start-Process cmd.exe -ArgumentList "/c cd C:\Windows\System32\DriverStore\FileRepository\nvgrid*\ && .\nvidia-smi -ac 5001,1590" -Wait
    }
    if ($instanceType -eq 3) {
        Start-Process cmd.exe -ArgumentList "/c cd C:\Windows\System32\DriverStore\FileRepository\nvgrid*\ && .\nvidia-smi -ac 6250,1710" -Wait
    }
    if ($instanceType -eq 4, 5) {
        Start-Process cmd.exe -ArgumentList "/c cd C:\Windows\System32\DriverStore\FileRepository\nvgrid*\ && .\nvidia-smi -ac 6251,2040" -Wait
    }
    if ($instanceType -eq 6) {
        Start-Process cmd.exe -ArgumentList "/c cd C:\Windows\System32\DriverStore\FileRepository\nvgrid*\ && .\nvidia-smi -ac 9001,2520" -Wait
    }

    if ($osType.ProductType -eq 3) {
        Write-Host "Installing Quality Windows Audio/Video Experience..."
        Install-WindowsFeature -Name QWAVE | Out-Null 
    }
}

if ($provider -eq 2) {
    GetFile "https://github.com/GoogleCloudPlatform/compute-gpu-installation/raw/main/windows/install_gpu_driver.ps1" "$specialFolder\install_gpu_driver.ps1" "Google Cloud GPU Driver Script"
    Start-Process -FilePath "powershell.exe" -ArgumentList "-Command `"$specialFolder\install_gpu_driver.ps1`"" -NoNewWindow
}

if ($provider -eq 1) {
    Stop-Transcript
    Write-Host "The system will now restart to finalize the installation."
    Write-Host "If you restart, the script will continue automatically on next boot, or you can select Continue on the desktop." 
    $restart = (Read-Host "Would you like to restart now? (y/n)").ToLower()
    if ($restart -eq "y") {
        Restart-Computer -Force
    }
}
