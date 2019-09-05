#ADHD-AHK-Dynamic-Hotkeys-for-Dummies

An AutoHotKey GUI library that allows authors to easily create AHK macros.   
Provides functionality to allow the end-user to configure which button triggers a macro via a GUI.(Similar to binding a key to a function in a game's options.)   
Key bindings and other settings are stored in an INI file and are remembered between runs.   

##Features
* Bind any key (Except Escape), mouse button (With optional Ctrl, Shift, Alt, Win modifiers), or Joystick Button to each macro   
Powered by a user-friendly custom binding system   
![Gihub Logo](http://evilc.com/files/ahk/adhd/bindmode.gif)
* Supports 9 mouse buttons (L,R,M,WheelUp/Down/Left/Right,Extra buttons 1+2) 
* Library to handle loading and saving of settings, with with default settings removed from INI
* Supports up and key down events for each trigger button
* Profile support
* Provides app detection (Limiting hotkeys to only work inside an app)
* Hooks to make sure that timers etc are stopped to help ensure app-specific hotkey functions stay app-specific
* Sample macro included
* Easy for someone with even a basic knowledge of AHK to write scripts with these features
* Built-in system to link to a URL for information on your macro
* Built-in system to notify users of updates.
 
##Using this library in your projects
####Setup
#####Easy Method
1. Clone this project using GitHub for Windows.  
If viewing this page on Github, click **Clone in Desktop** on the right edge of the page.  
This will clone this Project ("Repository") onto your computer.  
If there are updates to this Library, you can then Synch with GitHub to get the latest version. 
1. Run `Setup.exe` from the repoistory you just downloaded.  
This will check you are all set up to use the library and configure AutoHotkey so you can easily include the library in any script in any folder on your computer.
2. Check the *DEVELOPER NOTES* section to see if there are any special instructions, then click *Install*.
3. You are now set up and can use this library by putting the following line at the start of your script:  
`#include <ADHDLib>`

#####Manual Method
If you know what you are doing, or paranoid, or both, you can just obtain the files and `#include` as normal. The Setup app simply makes it easy for people who don't really know what they are doing to get up and running with this library.

###Usage
Please see the [Wiki](https://github.com/evilC/ADHD-AHK-Dynamic-Hotkeys-for-Dummies/wiki)
