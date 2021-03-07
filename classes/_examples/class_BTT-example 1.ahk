#SingleInstance Force

btt("This is BeautifulToolTip")
Sleep, 3000

CoordMode, ToolTip, Screen
btt("This is BeautifulToolTip`n`nCoordMode = Screen`n`nWhichToolTip = 2",500,500,2)
Sleep, 5000

btt()
btt(,,,2)

ExitApp