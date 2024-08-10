# Welcome!
Hello there, thanks for visiting. This is a GitHub repo containing PowerShell scripts acting as one large one which make Windows Server closer to Windows 10 plus automate and ease the first time setup of a cloud server made for streaming games or applications. To learn more about the script including how to use the script in specific use cases like running this on AWS, please visit the wiki located [here](https://github.com/chocolatemoo53/cloudstreaming/wiki). If you ever need help, please [submit an issue](https://github.com/chocolatemoo53/cloudstreaming/issues) to GitHub. If there is something you don't want to run, most functions are independent from each other. Just erase the line from the step or skip the step entirely. 

If you're ready to get started, start your cloud computer running Windows Server 2019/22 and paste the following code into PowerShell to download the script. 

```
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls" 
$DownloadScript = "https://github.com/chocolatemoo53/cloudstreaming/archive/refs/heads/main.zip"  
$ArchivePath = "$ENV:UserProfile\Downloads\cloudstreaming"  
(New-Object System.Net.WebClient).DownloadFile($DownloadScript, "$ArchivePath.zip")  
Expand-Archive "$ArchivePath.zip" -DestinationPath $ArchivePath -Force
CD $ArchivePath\cloudstreaming-main | powershell.exe .\welcome.ps1
```

## A note on "streaming technology"
Streaming technologies are what streams the cloud computer to your local devices. The wiki has a table of the different technologies you can choose with their pros and cons which you should check to decide for yourself what the best streaming technology is for you. 

### Thank you to: 
| Team or Person  | GitHub                             | Project                                                                |
|-----------------|------------------------------------|------------------------------------------------------------------------|
| LizardByte      | https://github.com/LizardByte/     | https://github.com/LizardByte/Sunshine/releases                        |
| The Parsec Team | https://github.com/parsec-cloud    | Parsec application, cloud preperation tool and cloud GPU updater tool  |
| NiceDCV/AWS     | https://github.com/aws             | https://aws.amazon.com/hpc/dcv/, AWS platform and drivers              |
| acceleration3   | https://github.com/acceleration3   | https://github.com/acceleration3/cloudgamestream                       |
| tomgrice        | https://github.com/tomgrice        | https://github.com/tomgrice/cloudgamestream-sunshine                   |

And anyone who makes issues or contributes words/code.
