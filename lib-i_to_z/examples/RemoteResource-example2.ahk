; Without rRes (example)
#include %A_ScriptDir%\..\RemoteResource.ahk
#include %A_ScriptDir%\..\..\lib-a_to_h\HashFile.ahk

; # Example 1. Image

TrayTip, Example 1, Download an image`, then add it to a GUI,, 1
KeyWait, Enter, Up
pic := remoteResource("AHK-Logo.png", "https://raw.githubusercontent.com/ahkscript/homepage/gh-pages/assets/images/ahk-logo-no-text241x78-180.png")
Gui, Add, Pic,, %pic%
Gui, Add, Text,, Press Enter to continue (to example 1b)
Gui, Show,, Example 1

; # Example 1b. Use the image again

KeyWait, Enter, D T10
Gui, Destroy
Traytip, Example 1b, Note that the image can now be directly accessed without downloading it,, 1
Gui, Add, Pic, x10 w50 h30, %pic%
Gui, Add, Pic, xp+60 yp w50 h30, %pic%
Gui, Add, Pic, x10 yp+40 w100 h60, %pic%
Gui, Add, Text,, Press Enter to continue (to example 2)
Gui, Show,, Example 1b

KeyWait, Enter, D T10

; # Example 2. Download a sound file.

Gui, Destroy
Traytip, Example 2, Any file can be downloaded this way (f.ex. a sound file),, 1
music := remoteResource("lifehacker.png", "https://github.com/ahkscript/homepage/blob/gh-pages/assets/images/lifehacker267x80-171.png")
Run %music%

Sleep 5000
TrayTip, Storage, Press Enter to see where the files are stored
KeyWait, Enter, D T15
DefaultDir := remoteResource("getDir")
Run %DefaultDir%
TrayTip, Finished, Demonstration is finished!
return

Esc:: ExitApp
