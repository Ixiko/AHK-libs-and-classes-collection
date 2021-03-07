#SingleInstance Force
SetBatchLines, -1
CoordMode, ToolTip, Screen

Text1=
(
ToolTip 会闪烁.
ToolTip will blinking.

1234567890
qwertyuiop[]
asdfghjkl;'
zxcvbnm,./
)

Text2=
(
BeautifulToolTip 不会闪烁.
BeautifulToolTip will not blinking.

1234567890
qwertyuiop[]
asdfghjkl;'
zxcvbnm,./
)

SetTimer, Show, 10
Sleep, 10000
ExitApp

Show:
	ToolTip, %Text1%, 500, 200
	btt(Text2, 800, 200, 2)
	btt(Text2, 500, 350,, "Style4")
return