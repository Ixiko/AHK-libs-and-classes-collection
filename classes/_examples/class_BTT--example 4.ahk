#SingleInstance Force
SetBatchLines, -1

Text=
(
当坐标模式为 窗口 或 客户区 时，默认使用活动窗口作为目标，同时也能自行指定。
更多可设置的参数，自行查看 btt() 函数中的说明。

When the CoordMode is window or client.
By default, the active window is used as target.
But you can also specify your own target.
For more parameters that can be set, see the description in btt() function.
)

Gui, +Hwndtarget		; get Hwnd
Gui, Font, s60
Gui, Add, Text, x0 y0 w800 h600 Center vt, 试试移动窗口。`n`nTry Move this window.
Gui, Show, w800 h600 x0 y0 NA

CoordMode, ToolTip, Client

SetTimer, Show, 10
Sleep, 10000
ExitApp

Show:
	btt(Text,800-1,600-1,,"Style1",{targethwnd:target})
return