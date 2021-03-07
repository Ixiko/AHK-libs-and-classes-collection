#SingleInstance Force
SetBatchLines, -1
CoordMode, ToolTip, Screen

Text=
(
指定靠近屏幕底部的坐标时，应该显示在屏幕底部，但 ToolTip 会出现在错误的位置。

When specifying x,y near the bottom of the screen, it should be displayed at the bottom of the screen.
But ToolTip will appear in the wrong place.

1234567890
qwertyuiop[]
asdfghjkl;'
zxcvbnm,./
)

SetTimer, Show, 10
Sleep, 10000
ExitApp

Show:
	ToolTip, %Text%,, A_ScreenHeight-1
	btt(Text,,A_ScreenHeight-1,,"Style1")
return