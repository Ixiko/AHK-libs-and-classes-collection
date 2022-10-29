#NoEnv
#Warn
SendMode Input
SetWorkingDir %A_ScriptDir%
#SingleInstance force

html =
(
<!DOCTYPE html>
<html lang="en">
<head>
	<meta http-equiv="X-UA-Compatible" content="IE=edge" charset="utf-8">
	<title>title</title>
		<style>
		#test {
			display: flex;
			flex-flow: column nowrap;
			position: fixed;
			top: 0;
			bottom: 0;
			left: 0;
			right: 0;
			margin: 0;
			padding: 20px 20px 20px 20px;
		}
		div.row {
			display: flex;
			flex-flow: row nowrap;
			margin: 4px 4px;
			height: 100`%;
		}
		img.pic {
			margin: 4px 4px;
			width: 100`%;
			height: 100`%;
		}
		</style>
</head>
	<body>
		<ul id="test">
			<div class="row"></div>
		</ul>
	</body>
</html>
)
GUI, New
GUI Add, ActiveX, vAXWrapperObject xm y30 w400 h400, about:<!DOCTYPE html><meta http-equiv="X-UA-Compatible" content="IE=edge" charset="utf-8">
doc := AXWrapperObject.document
doc.open(), doc.write(html), doc.close()
pics := doc.getElementsByClassName("pic")
;<><><><><><><><><><><><><><><><><><><>

GUI, +Resize
GUI, Margin, 5, 5
pathToPic := A_Desktop . "\AutoHotkey modern logo.svg"
UrlDownloadToFile, % "https://www.autohotkey.com/static/ahk_logo.svg", % pathToPic ; let's download the AutoHotkey logo for testing purpose
GUI Add, Button, xm ym w400 vMyButton gpushPic, OK ; add a button and set its g-label to be 'pushPic' (https://www.autohotkey.com/docs/commands/Gui.htm#label)
GUI, Show, AutoSize
rowMax := 5, columnMax := 2
rowCurrent := 0, columnCurrent := 0
cells := rowMax * columnMax
return

GUISize: ; https://www.autohotkey.com/docs/commands/Gui.htm#GuiSize
	GuiControl, Move, MyButton, % "w" A_GuiWidth - 10
	GuiControl, Move, AXWrapperObject, % "w" A_GuiWidth - 10 "h" A_GuiHeight - 40 ; resize the control so that it fits the new GUI dimensions
return


pushPic:
	if not (pics.length < cells)
		return
	FileSelectFile, path, 3, % pathToPic, Select a picture, Pictures (*.png; *.svg) ; displays a standard dialog that allows the user to choose a picture
	if (columnCurrent < columnMax) {
		Gosub, subLabel
	return
	} else {
		columnCurrent := 0
		doc.getElementById("test").innerHTML .= "<div class='row'></div>" ; create a new row
		rowCurrent++
	}
	subLabel:
		doc.getElementsByClassName("row")[rowCurrent].innerHTML .= "<img class='pic' src='" . path . "'>" ; create a new column and fill it with a picture (https://www.w3schools.com/tags/tag_img.asp)
		columnCurrent++
return
