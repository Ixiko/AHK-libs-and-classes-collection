/*
	Title: Windy, v0.15.4
		
	Windy provides a collection of classes, which allow a class based approach of handling windows, monitors, etc.
		
	Following classes exist:
	* <Mony at http://hoppfrosch.github.io/AHK_Windy/files/Mony-ahk.html> - Single Monitor
	* <Mousy at http://hoppfrosch.github.io/AHK_Windy/files/Mousy-ahk.html> - Mouse
	* <MultiMony at http://hoppfrosch.github.io/AHK_Windy/files/MultiMony-ahk.html> - Multi Monitor Environments
	* <Pointy at http://hoppfrosch.github.io/AHK_Windy/files/Pointy-ahk.html> - Points (geometric 2D-points) - this is mostly a helper class being used within this package, but maybe helpful anyway ...
	* <Recty at http://hoppfrosch.github.io/AHK_Windy/files/Recty-ahk.html> - Rectangles (consisting of two <points at http://hoppfrosch.github.io/AHK_Windy/files/Pointy-ahk.html>) -  - this is mostly a helper class being used within this package, but maybe helpful anyway ...
	* <Windy at http://hoppfrosch.github.io/AHK_Windy/files/Windy-ahk.html> - Windows
	* <WindLy at http://hoppfrosch.github.io/AHK_Windy/files/WindLy-ahk.html> - Collection (List) of Windows
		
	Authors:
	<hoppfrosch at hoppfrosch@gmx.de>: Original

	About: License
	This program is free software. It comes without any warranty, to the extent permitted by applicable law. You can redistribute it and/or modify it under the terms of the Do What The Fuck You Want To Public License, Version 2, as published by Sam Hocevar. See <WTFPL at http://www.wtfpl.net/> for more details.

*/
#include %A_LineFile%\..\Windy
#include _WindowHandlerEvent.ahk
#include Const_WinUser.ahk
#include Mony.ahk
#include Mousy.ahk
#include MultiMony.ahk
#include Pointy.ahk
#include Recty.ahk
#include WindLy.ahk
#include Windy.ahk


Version := "0.15.4"