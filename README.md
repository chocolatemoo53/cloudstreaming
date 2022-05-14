# Welcome!
Hello there, thanks for visiting. This is a GitHub repo containing four PowerShell scripts that I created. Their purpose is to make setting up a cloud computer for gaming, work, or school easier. This used to be a personal project before publicizing it's existence on GitHub and various mediums. It's intended purpose is to run on Windows Server 2016, 19 and 22 servers that are hosted on Google Cloud Platform, Amazon Web Services, and Microsoft Azure. If you're using Windows 10 on your server instance, it is possible to run this script, however, certain features will not be installed.

To learn more about the script including how to use the script in specific use cases, please visit the official Wiki located [here](https://github.com/chocolatemoo53/cloudopenstream/wiki). If you ever need help, please [submit an issue](https://github.com/chocolatemoo53/cloudopenstream/issues) to GitHub. I can follow up on any question that you may have. However, I prefer to keep the issues on topic (meaning they are about the script) and less to get help with creating a cloud gaming server. I hope you can understand. 

To explain how it all works, let's start with the initiator script (`starthere.ps1`), this script checks the server for compatibility. For example, the script needs to run on the BUILT-IN Administrator. This user is activated by default on most cloud providers and is most likely the user you are using to log in to the server. Afterward, it seemlessly begins the next step, that being step one. 

As quoted from the Wiki:

"Step one is not very complicated, it uses some basic code to download then install a file from the internet..."

This step also installs essential drivers for audio and video. Please check the official GitHub repo for the Parsec GPU Updater to [see if your GPU is compatible](https://github.com/parsec-cloud/Cloud-GPU-Updater). For audio, the driver is a free piece of software called "VBCable" downloaded from the official source. 

All other steps are explained in details by reading the Wiki. 

## Streaming technology
Streaming technology refers to what you prefer to stream your server instance to your local computer. This depends on your setup and needs. A summary of the differences between the technologies provided in the script are that Parsec and NiceDCV are closed sourced, while Sunshine is open-source. Also, NiceDCV is exclusively for AWS customers unless you have a license. **If you're looking to use Moonlight with your incompatible server GPU, like the Tesla T4, then choose Sunshine.**

### Thank you to: 
| Team or Person  | GitHub                            | Project                                                                |
|-----------------|-----------------------------------|------------------------------------------------------------------------|
| loki-47-6F-64   | https://github.com/loki-47-6F-64/ | https://github.com/loki-47-6F-64/sunshine                              |
| The Parsec Team | https://github.com/parsec-cloud   | https://github.com/parsec-cloud/Cloud-GPU-Updater / https://parsec.app |
| NiceDCV/AWS     | https://github.com/aws            | https://aws.amazon.com/hpc/dcv/                                        |

This repository contains icons from the Noun Project. These include: 
- cog by Vectors Market from the Noun Project
