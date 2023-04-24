# Welcome!
Hello there, thanks for visiting. This is a GitHub repo containing PowerShell scripts that I created for cloud app/game streaming. This is a fork of cloudgamestream and it is largely based off of that. The purpose of this repo is to make setting up a cloud computer for gaming, work, or school easier. This used to be a personal project before publicizing it's existence on GitHub and various mediums. It's intended purpose is to run on Windows Server 2016, 19 and 22 servers that are hosted on Google Cloud Platform, Amazon Web Services, Microsoft Azure and others. If you're using Windows 10 on your server instance, it is possible to run this script, however, certain features will not be installed. This script is very recommeneded to run on Server 2019, however, some applications do run better on Server 22. These scripts are meant to make your system feel like a normal desktop computer, but since it's running on Windows Server, there is some minor game/app performance improvements.  

To learn more about the script including how to use the script in specific use cases, please visit the official Wiki located [here](https://github.com/nonsensemaker/cloudstreaming/wiki). If you ever need help, please [submit an issue](https://github.com/nonsensemaker/cloudstreaming/issues) to GitHub. I can follow up on any question that you may have. The wiki also has step-by-steps guides for some cloud providers to get up and running!

To explain how it all works, let's start with the initiator script (`starthere.ps1`), this script checks the server for compatibility. For example, the script needs to run with an Administrator account. This user is activated by default on most cloud providers and is most likely the user you are using to log in to the server. Afterward, it seemlessly begins the next step, that being step one. 

If you just want to get audio/video drivers, only need the apps, or the various fixes, each step is completely independent from one another. Just click the step you want to start and use it.  

## A note on "streaming technology"
Streaming technology refers to what you prefer to stream your server instance to your local computer. This depends on your setup and needs. A summary of the differences between the technologies provided in the script is available in the wiki. Also, NiceDCV is exclusively for AWS customers unless you have a license. **If you're looking to use Moonlight with your incompatible server GPU, like the Tesla T4, then choose Sunshine.**

### Thank you to: 
| Team or Person  | GitHub                             | Project                                                                |
|-----------------|------------------------------------|------------------------------------------------------------------------|
| LizardByte      | https://github.com/LizardByte/     | https://github.com/LizardByte/Sunshine/releases                        |
| The Parsec Team | https://github.com/parsec-cloud    | https://github.com/parsec-cloud/Cloud-GPU-Updater / https://parsec.app |
| NiceDCV/AWS     | https://github.com/aws             | https://aws.amazon.com/hpc/dcv/                                        |
