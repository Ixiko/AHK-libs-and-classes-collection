# UIAutomation

UIAutomation related files for AutoHotkey.
Main library files:
1) UIA_Interface.ahk, which is based on jethrow's project, and contains wrapper functions for the UIAutomation framework. In addition it has some helper functions for easier use of UIA.
2) UIA_Constants.ahk, which contains most (all?) necessary constants to use UIA. It is mostly based on an Autoit3 project by LarsJ. Note that this file creates a lot of global variables, so make sure your script doesn't change any of these during runtime.
3) UIA_Browser.ahk, which contains helper functions for Chrome (and Edge mostly too) automation (fetching URLs, switching tabs etc).

Additionally UIAViewer.ahk is included to view UIA elements and browse the UIA tree.

More info is available here: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=104999