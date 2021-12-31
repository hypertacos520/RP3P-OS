# RP4P-OS v0.9a

![Main Menu](https://github.com/hypertacos520/RP4P-OS/blob/master/assets/images/screenshots/MainMenu.png?raw=true)

## RP4P-OS theme for Pegasus Frontend | Based on switchOS and skylineOS

A theme that aims to recreate a game console-like experience through the Pegasus Frontend. RP4P-OS is a theme for [Pegasus Frontend](http://pegasus-frontend.org/).

Platform logos courtesy of [lilbud](https://github.com/lilbud/es-theme-switch).

## Notes on Theme Layout

Retropie settings are located in the settings menu under 'OS Settings' instead of in the games library. This is to help create the feel of an actual game console. The OS Settings tab is only visable if there is a 'retropie' collection present. 

## Installation

Simply download the theme and place it in your [Pegasus theme directory](http://pegasus-frontend.org/docs/user-guide/installing-themes/) under a folder called RP4P-OS.

## Version history
v0.9a
- OS Settings tab now only appears if a 'retropie' collection is present
- 'retropie' collection items do not appear in full library list
- 'retropie' collection items do not appear in recently played on the main menu
- Started to add code for battery life monitoring
- Started to add code for dynamic 'theme' list
- Removed 'show OS settings' option as it is now unnecessary

v0.8a
- Added Video Background support
- Added Background Music support
- Added skylineOS based settings menu
- Enabled 12/24 hr clock setting
- Enabled 'theme' setting
- Added OS settings (based on retropie collection)

v0.3
- Added proper support for variable aspect ratios without decreasing size. Now properly supports 4:3 aspect ratios and should look correct on smaller screens
- Added logos or collection text for missing eslogos
- Fixed issue with navigation audio

v0.2.2
- Fixed bottom bar alignment on non-16:9 screens

v0.2.1
- Removed Qt.QML inclusion as it apparently is no longer supported

v0.2
- Adding new platform logos courtesy of [lilbud](https://github.com/lilbud/es-theme-switch)

v0.1
- Initial release
