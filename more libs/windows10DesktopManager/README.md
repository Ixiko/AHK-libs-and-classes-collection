# Windows 10 Virtual Desktop Manager
An autohotkey desktop manager

----

### Description

If you have moved to Windows 10 already then you have to make use of the new Virtual desktop environment! Unfortunately Windows is lacking a few keyboard shortcuts such as jumping to a specific desktop and moving programs to another desktop. 
This script is designed to fill that hole by providing an easy way customisable hotkeys for all your virtual desktop managing needs. 

### Requirements
The script requires both a 32 and 64 bit version of the Autohotkey executable to reliably send windows to other desktops. Download the latest installer from the official Autohotkey website https://autohotkey.com/. The DLL's that are used to move windows to other desktops come from this project https://github.com/jpginc/MoveToDesktop

### Setup
Clone this Repo and run windows10.ahk. Inside windows10.ahk is a default setup that you can use or edit. The JPGIncDesktopManagerClass has the following functions to setup hotkeys. Each of the following functions take a string representing a hotkey (see https://autohotkey.com/docs/Hotkeys.htm for more information about hotkeys). 

- setGoToNextDesktop(**hotkey**)
- setGoToPreviousDesktop(**hotkey**)
- setMoveWindowToNextDesktop(**hotkey**)
- setMoveWindowToPreviousDesktop(**hotkey**)
- setCloseDesktop(**hotkey**)
- setNewDesktop(**hotkey**)

The following functions take a hotkey that will be combined with numbers 0 - 9 for quickly switching to a virtual desktop. As such the hotkey cannot be a custom hotkey (https://autohotkey.com/docs/Hotkeys.htm#Features)
- setGoToDesktop(**hotkey**)
- setMoveWindowToDesktop(**hotkey**)

These two functions accept either a function name, a label name, a class name with a "**call**" function on the class. It can also be a func object (https://autohotkey.com/docs/objects/Func.htm).
- afterGoToDesktop(**name**)
- afterMoveWindowToDesktop(**name**)

You can also set the window manager to switch to the desktop after moving a window to it. By default you won't follow moving a window to another desktop.
- followToDesktopAfterMovingWindow(**bool default is false**)
