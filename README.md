# Welcome

Hello there, thanks for visiting. This script will help you configure a cloud Windows Server to stream games or applications. To learn more about the script please visit the wiki located [here](https://github.com/chocolatemoo53/cloudstreaming/wiki). If you ever need help, please [submit an issue](https://github.com/chocolatemoo53/cloudstreaming/issues) to GitHub.

This script is targeted at users looking to use AWS or Google Cloud with Windows Server 2025. Older versions and other cloud platforms are supported but some parts are skipped.

``` bash
iex "(New-Object Net.WebClient).DownloadFile('https://is.gd/UTAo8K', '$env:UserProfile\cloudstreaming.zip'); Expand-Archive '$env:UserProfile\cloudstreaming.zip' -Force; & '$env:UserProfile\cloudstreaming\cloudstreaming-main\starthere.ps1'"
```

## A note on "streaming technology"

Streaming technologies are what streams the cloud computer to your local devices. The wiki has a table of the different technologies you can choose with their pros and cons which you should check to decide for yourself what the best streaming technology is for you.

### Thank you to

| Team or Person  | GitHub                             | Project                                                                |
|-----------------|------------------------------------|------------------------------------------------------------------------|
| LizardByte      | <https://github.com/LizardByte/>     | <https://github.com/LizardByte/Sunshine/releases>                        |
| The Parsec Team | <https://github.com/parsec-cloud>    | Parsec application, cloud preperation tool and cloud GPU updater tool  |
| Nice/AWS        | <https://github.com/aws>             | <https://aws.amazon.com/hpc/dcv/>, AWS platform and drivers              |
| acceleration3   | <https://github.com/acceleration3>   | <https://github.com/acceleration3/cloudgamestream>                       |
| tomgrice        | <https://github.com/tomgrice>        | <https://github.com/tomgrice/cloudgamestream-sunshine>                   |

And anyone who makes issues or contributes words/code.
