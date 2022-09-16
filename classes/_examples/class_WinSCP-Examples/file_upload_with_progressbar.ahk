;~ ---------------------------------------------------
;~ Upload File with Progressbar
;~ ---------------------------------------------------

; Include lib
;~ #Include ..\WinSCP.ahk

;Define GUI
Gui, Font, S18 CDefault Bold, Arial
Gui, Add, Text, x17 y30 w450 h40 +Center vtxtTitle, Uploading @ Speed
Gui, Add, GroupBox, x17 ys+35 w450 h190 ,
Gui, Font, ,
Gui, Add, Text, x42 ys+60 , Filename:
Gui, Add, Edit, x+40 w300 h20 vedtFileName Disabled, Edit
Gui, Add, Progress, x36 yp+30 cBlue BackgroundCCCCCC w400 h20 vproFileName, 1
Gui, Add, Text, x42 yp+30 w80 h20 , Overall
Gui, Add, Progress, x36 yp+30 w400 h20 cRed BackgroundCCCCCC vproOverall, 0
Gui, Add, Button, x222 yp+30 w100 h30 Disabled vbtnClose gbtnClose, Close
Gui, Add, Button, x+20 w100 h30 vbtnAbort gbtnAbort, Abort
Gui, Show, , File Transfere
return

btnClose:
btnAbort:
ExitApp

;Define function which is called on Event FileTransferProgress
session_FileTransferProgress(sender, e)
{
	;Parse e Properties
	RegExMatch(e.FileName, ".*\\(.+?)$", match)
	FileName        := match1
	CPS             := Round(e.CPS / 1024)
	FileProgress    := Round(e.FileProgress * 100)
	OverallProgress := Round(e.OverallProgress * 100)
	action          := (e.Side==0) ? "Uploading" : "Downloading"

	;Change GUI elements
	GuiControl,, txtTitle, % action " @ " CPS " kbps"
	GuiControl,, edtFileName, % FileName
	GuiControl,, proFileName, % FileProgress
	GuiControl,, proOverall, % OverallProgress
	if (OverallProgress==100)
		GuiControl, Enable, btnClose

	;Show GUI
	Gui, Show, , File Transfere
}

;create instance
FTPSession := new WinSCP
try
{
	;Open Conenction
	FTPSession.OpenConnection("ftp://myserver.com","username","password")

	;File Name
	fName := "Windows10_InsiderPreview_x64_EN-US_10074.iso"
	;File Path on local computer
	fPath := "C:\temp"
	;File Path on the server
	tPath := "/Win10beta/"

	;Check if Path on server exists
	if (!FTPSession.FileExists(tPath))
		;Create Path on server
		FTPSession.CreateDirectory(tPath)
	;Upload file
	FTPSession.PutFiles(fPath "\" fName, tPath)
} catch e
	;Catch Exeptions
	msgbox % "Oops. . . Something went wrong``n" e.Message