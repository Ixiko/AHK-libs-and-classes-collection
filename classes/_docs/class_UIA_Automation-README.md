# UIAutomation

UIAutomation related files for AutoHotkey.
Main library files:
1) UIA_Interface.ahk, which is based on jethrow's project, and contains wrapper functions for the UIAutomation framework. In addition it has some helper functions for easier use of UIA.
2) UIA_Browser.ahk, which contains helper functions for Chrome (and Edge mostly too) automation (fetching URLs, switching tabs etc).
3) OPTIONAL: UIA_Constants.ahk, which contains most necessary constants to use UIA. It is mostly based on an Autoit3 project by LarsJ. Note that this file creates a lot of global variables, so make sure your script doesn't change any of these during runtime. The preferred option is to use constants/enumerations from the UIA_Interface.ahk UIA_Enum class (details are available in the AHK forum thread).

Additionally UIAViewer.ahk is included to view UIA elements and browse the UIA tree. It can be ran as a standalone file without the UIA_Interface.ahk library.

More info is available here: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=104999