#SingleInstance, Off
#NoTrayIcon
SetBatchLines, -1
SetWinDelay, 1
CoordMode, Mouse, Screen

;Bugs:
;	Right click takes two clicks (perhaps doesn't have focus on first one)
;Things to configure:
;	Font,color,size title
;	Font,color,size body
;	duration
;	pop in location/behavior

titleSize := 30
titleColor := "7FA2CF"
titleFont := "Segoe UI Light"
messageSize := 11
messageColor := "White"
messageFont := "Segoe UI"
backgroundColor := "2A2B2F"
padSize := 30

;Loop through parameters and split apart on equals sign
loop %0%
{
	if % %A_Index%
	{
		chunks := StrSplit(%A_Index%, "=")
		varName := trim(chunks[1])
		varValue := trim(chunks[2])
		if varName
			%varName% := varValue
	}
}

;Show help if no text was passed in
if(!(notificationTitle or notificationText))
{
	params=
	loop %0%
	{
		params := params "`t[" A_Index "] " %A_Index% "`n"
	}
	params := RTrim(params)
	msg=
	(
Call script with parameters specified as below:
	Notification.ahk "notificationText=Some Text" "NotificationTitle=A Title"

Available Parameters (case insensitive):
	notificationTitle
	notificationText
	titleSize
	titleColor
	titleFont
	messageSize
	messageColor
	messageFont
	backgroundColor
	logPath (save a record of notification calls)
	padSize

You Passed
%params%
	)
	MsgBox, % msg
	ExitApp
}

;Log call if file path provided
if logPath
{
	FormatTime, RightNow
	FileAppend, %RightNow%`n%notificationTitle%`n%notificationText%`n, %logPath%
}

; pad the title for a default width
notificationTitle := pad(notificationTitle,padSize)

; get the count of any existing notification windows
WinGet, winCount, Count, AHKNotification

; adjust this notification y offset according to the existing count
yPosition := 125*winCount

; set a unique notification title
winTitle := "AHKNotification - " newGuid_Small()
;msgbox % messageColor
; notification display settings
Gui, +ToolWindow +AlwaysOnTop -Caption +Border
Gui, Color, %backgroundColor%
Gui, Margin, 0, 0
Gui, Font, s%titleSize% c%titleColor%, %titleFont%
Gui, Add, Text, x10 vtxtMessageTitle, %notificationTitle%
Gui, Font
Gui, Font, s%messageSize% c%messageColor%, %messageFont%
if notificationText
	Gui, Add, Text, xm x15 r3 vtxtMessageText, %notificationText%
Gui, Add, Text, ym
Gui, Show, % "y" yPosition " " ShowParams " NoActivate", %winTitle%
WinGetPos x, x, width, height, %winTitle%

; start a 1 second timer to watch the position of the mouse
SetTimer, WatchMouse, 1000
return

#If (WinActive(winTitle))
	; catch left clicks for copying the text
	~$LButton::
	{
		; get the id of the window the mouse is over
		MouseGetPos,,, mouseWin

		; get the window title
		WinGetTitle, win, ahk_id %mouseWin%

		; if the mouse is over this notification, send the title and text to the clipboard
		if (win == winTitle) {
			GuiControlGet, messageTitle,, txtMessageTitle
			GuiControlGet, messageText,, txtMessageText
			Clipboard := messageTitle " - " messageText
		}
		return
	}
	~$RButton::
	{
		; Close window
		winclose %winTitle%
		return
	}

; watch the mouse to see if it's over the notification
WatchMouse:
{
	; start the transparency at full
	t := 255
	yPixelsToMoveUp := (yPosition + height) / 128

	; loop 128 times (~1/2 of 255)
	WinGetPos x, y, width, height, %winTitle%
	NewY := y
	Loop, 128
	{
		; get the id of the window the mouse is over
		MouseGetPos,,, mouseWin

		; get the window title
		WinGetTitle, win, ahk_id %mouseWin%

		; if the mouse is over this notification
		if (win == winTitle) {

			; set the transparency of the notification back to full and exit the loop
			WinSet, Trans, 255, %winTitle%
			NewY := y
			WinMove %winTitle%,, x, %NewY%
			break
		}

		; otherwise set a new transparency level
		WinSet, Trans, %t%, %winTitle%
		NewY := NewY-yPixelsToMoveUp
		;msgbox NewY %NewY%
		WinMove %winTitle%,,x,%NewY%
		;msgbox % yPixelsToMoveUp

		; adjust the transparency for the next iteration
		t := t-2

		; throttle the looping for performance
		;Sleep, 1

		; if the current transparency level is less then or equal to 0, exit
		if (t <= 0) {
			ExitApp
		}
	}
	return
}

; quick and dirty function for creating a small pseudo-guid
newGuid_Small() {
	charList := ["0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"]
	guid := ""
	Loop, 8
	{
		Random, var, 1, 16
		guid := guid . charList[var]
	}
	return guid
}
pad(x,padSize) {
	Loop, % padSize - StrLen(x)
		x .= A_Space
	return x
}