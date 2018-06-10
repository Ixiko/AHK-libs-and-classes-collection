; LintaList Include
; Purpose: Show info about Lintalist, version + website
; Version: 1.7
; Date:    20151003

ShowAbout:

; AppWindow:="Lintalist v1.7" ; debug only

Gui, 55:Destroy
Gui, 55:Add, Picture, x10 y10 w100 h100 ,docs\img\lintalist200x200.png
Gui, 55:Add, Picture, xp+140 yp+15 ,docs\img\lintalist.png
Gui, 55:Add, Picture, xp+280 yp-15 ,docs\img\poweredbyahk.png
Gui, 55:font, bold
Gui, 55:Add, Text, x10 yp+115, %AppWindow%
Gui, 55:font, 
Gui, 55:Add,Link,  x10 yp+30, Website: <a href="https://lintalist.github.com">lintalist.github.com</a>, source code: <a href="https://github.com/lintalist">github.com/lintalist</a> (Language <a href="http://autohotkey.com/">AutoHotkey</a>)
Gui, 55:Add, Text, x10 yp+30,
(
Searchable interactive texts to copy && paste text, run scripts, using easily exchangeable bundles.

Copyright (c) 2009-2017 Lintalist.

This program is free software; you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software Foundation;
either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

See license.txt and docs\credits.txt for further details.
)
Gui, 55:Add, Button, x130 yp+180 w110 g55GuiUpdates, &Check for updates
Gui, 55:Add, Button, xp+120 yp w110 g55GuiClose Default, &OK
Gui, 55:Show, w500 h410, About %AppWindow%
ControlFocus, Button2, About %AppWindow%
Return

55GuiUpdates:
Run, %A_AhkPath% %A_ScriptDir%\include\update.ahk
Return

;55GuiClose: ; debug only - label is already part of QuickStart.ahk
;Gui, 55:Destroy
;Return