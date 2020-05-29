# galaxy-integration-rclone
A GOG Galaxy 2.0 integration for Rclone.org

## Features: (To be implemented...)
- Store your own games on a cloud based service (Microsoft OneDrive, Dropbox, Google Drive etc.) and access them via the GOG client, (See https://rclone.org/#providers for more details on available service providers...)
- Owned games are expected to be stored in a folder on your cloud storage provider making them easier to manage.
- Specify a folder when enabling the plugin. Multiple folders containing files can be setup (separated by semicolon ";". Ie "c:\RcloneGameLibraryPath\;d:\MoreRcloneGameLibraryPath")
- Only Windows is supported.

## Background
Have some old games on CD? Laying around, not getting played? – games like The Operative: No One Lives Forever, No One Lives Forever 2: A Spy in H.A.R.M.'s Way, Vietcong, Stubbs The Zombie, Pray (2006) etc. – games that you can no longer legally buy on any digital store front.

The unfortunate side effect of owning physical media is that it deteriorates over time, most newer modern computer systems don't even come with a disk drive to access this media. 

If you're lucky, it will get re-released on a digital store front, but there are games that are just not, with Rclone.org integration its possible to rip those games that you legally own to a cloud storage provider such as (Microsoft OneDrive, Dropbox, Google Drive etc.), using GOG, it will make it easier to keep track of, and curate the games that you own, and when you eventually get around to revisiting the backlog of the older titles that you have, they'll be there for you! On demand; just run the plugin and pull it down to your computer system, just like any other GOG game. 
 
*you may still be required to patch some older games. – the hope is to develop community driven installation and patch scripts to achieve this automatically.

## How to Install:
Download the .zip from the GitHub as a ZIP file, and extract the contents into your installed plugins folder.
The default folderis at `%localappdata%\GOG.com\Galaxy\plugins\installed`

## How to add games:
- On your Cloud Storage Provider, make a new folder to store your games, place each game in its own sub folder, for example "Pray (2006)", as long as it complies with the naming schemed allowed by your Cloud Storage provider.

- Next either rip the Disc or install the game to a system and copy the contents of the games folder to your hard Drive and then upload it into the folder made on your Cloud Storage Provider.

- Run rclone config (there might be a UI interface for this as part of RcloneWrapper.exe), setup a remote path in Rclone using instructions provided by Rclones website, (See the config page alongside Supported providers, https://rclone.org/#providers)

- Run RcloneWrapper.exe from command line with the following switches, for example if you named your remote path OneDriveGames: and make a subfolder call games run `RcloneWrapper.exe -AddPath OneDriveGames:\Games`

- A new file should now appear in the `OneDriveGames:\Games` folder called `GameLibrary.db3`

- To add a game run the following command line switch: `RcloneWrapper.exe -AddGame OneDriveGames:\Games\Prey (2006),C:\GameInstallPath\FileToExecute.exe,"Prey (2006)"`

- To run a game run the following command line switch: `RcloneWrapper.exe -RunGame FileToExecute.exe`

*Plugin is Beta use at own risk! 

## Known Issues/Caveats/Requirements:
- The plugin will be listed as ATARI JAGUAR in GOG Galaxy... as custom platforms are a supported at this time.
(there will be an option to change the platform type in the future)
- A version of Rclone is included. It might be out of date, and as such a mechanism needs to be implemented  to update it automatically.
- RcloneWrapper.exe is written with the Microsoft Macro Assembler or MASM32 SDK (https://www.masm32.com) and as such doesn't require any dependencies to run. 

## Acknowledgements
- Rclone is a command line program to manage files on cloud storage Created by Nick Craig-Wood 2014-2020, read more at: https://rclone.org/
- RcloneWrapper.exe uses SQLite (sqlite3.dll) to manage Game libraries, run time paths etc. (https://www.sqlite.org/)
- The GOG Galaxy API and templates were made by GOG.
- This integration plugin was forked from RoorMakurosu/galaxy-integration-dosbox (https://github.com/RoorMakurosu/galaxy-integration-dosbox), because I couldn't figure out GOG's API and wanted an example to start from. 

