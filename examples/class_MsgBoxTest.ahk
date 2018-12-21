#SingleInstance force

#Include %A_LineFile%\..\..\MsgBox.ahk


$MsgBox 	:= new MsgBox()

$MsgBox
	.message("No title message")
	.message("TITLE", "Message with title")
	.message("TITLE", "Message with timeout", 3)
	.message( "Message with timeout without title", 3)	
	
$MsgBox.confirm("TITLE", "confirm with yes")
$MsgBox.confirm("TITLE", "confirm with no", "no")

$MsgBox.input("TITLE", "Input prompt" )
$MsgBox.input("TITLE", "Input prompt With default text",  { "x":"", "y":"", "w":"", "h":128, "default":"Default text" }	 )

$MsgBox.exit("Exiting script", "Message then ExitApp" )
