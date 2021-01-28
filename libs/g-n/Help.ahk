#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
;#include <_filesystem>
;#include <shell>
;#include <ini\ini>
;#include <GUI>

runasadmin()
if not A_iscompiled
	runwait, Ahk2Exe.exe /in Help.ahk /out Help.exe /icon Help.ico

global g_ini := new ini("main.ini")
global credits :=
(
"
<h2 id=""Credits"" class=""banner"">Credits\Licence\Support</h2>
All code by Peixoto, for support check trhis thread:<br>
<a id=""peixoto"" href=""javascript:dummy()"">http://www.moddb.com/members/peixoto/downloads</a> <br><br>

DONATIONS are WELCOME !<br><br>

<input id=""Donate"" type=""image""
src=""https://www.paypalobjects.com/en_US/GB/i/btn/btn_donateCC_LG.gif""/>
<br><br>
"
)

global short_credits :=
(
"
<br><br>
<input id=""Donate"" type=""image""
src=""https://www.paypalobjects.com/en_US/GB/i/btn/btn_donateCC_LG.gif""/>
<br><br>
"
)

global static_htmlcode :=
(
"
<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN"">
<html>
	<head>
	<script>
		function dummy() {}
	</script>

	<style>
	    body {background-color:#EEEEEE; text-align: justify;
    		  text-justify: inter-word; font-size:17px}
		.banner {{background-color:MediumTurquoise }
		a:link {color: #0000FF;}

		/* visited link */
		a:visited {color: #0000FF;}

	</style>

<title></title>
</head>
<body></body>
"
)
global hmain
global g_current_batch
global parent := GetParentDir()
global links := {}

Menu, Popup, Add, Learn More, LearnMore
Menu, Popup, Add, Customize

gui,+hwndhmain
gui, add, Tab2, h700 w1080 vtabs gtabs(), Help|Games
Gui, Tab, 1
gui add, activeX, w200 h660 vLinks_Pannel, Shell.Explorer
gui add, activeX, x+10 w850 h660 vHELP, Shell.Explorer
Gui, Tab, 2
gui, add, activeX, section y+80 h450 w300 vGames_list, Shell.Explorer
gui, add, activeX, xs+310 ys-80 w750 h660 vGAME_HELP, Shell.Explorer
gui, add, button, ys+480 xs w300 h30, Start
gui, add, button, y+10 w300 h30, Create Shortcut
gui, add, button, y+10 w300 h30, Edit
gui, add, button, ys-50 xs w300 h30, Add New
gui, show

setHTMLData(help_file)
{
	fileread, help, %help_file%
    links := {}
	body := "<body>"
	links_body := "<body><div style=""height:850px;width:500px;overflow:auto;"">"
	help := strsplit(help, "::")
	for k, v in help
	{
		if (Trim(v) = "Title")
		{
			body .= "<h1 id=""Title"">" help[k+1] "</h1>" help[k+2]
			links_body .= "<a id=""Title"" href=""javascript:dummy()"">Home</a><br>"
		}
		if (Trim(v) = "Section")
		{
			body .= "<h2 id=" """" help[k+1] """" " class=""banner"">" help[k+1] "</h2>" help[k+2]
			links_body .= "<a id=" """" help[k+1] """"  " href=""javascript:dummy()"">"  help[k+1] "</a><br>"
		}
		if (Trim(v) = "link")
		{
			link := strsplit(help[k+1], "->")
			dir := link[3]
			links[link[1]] := {}
			links[link[1]].command := link[2]
			links[link[1]].dir := dir
		}
		if (Trim(v) = "credits")
		{
			body .= credits
			links_body .= "<a id=""credits"" href=""javascript:dummy()"">Credits</a><br>"
		}
		if (Trim(v) = "LinkPannel")
			Link_Pannel_Width :=  help[k+1]
	}
	body .= "</body>"
	links_body .= short_credits
	links_body .= "</div></body>"

	for k, v in ["APPDATA", "LOCAL_APPDATA", "COMMON_APPDATA"] {
		path := GetCommonPath(v)
		stringreplace, body, body, CSIDL_%v%, %path%, 1
		stringreplace, body, body, CSIDL_PERSONAL, %A_mydocuments%, 1
		stringreplace, body, body, _AHKI_, AHK Injector, 1
	}

	links["ON"] := True
	links["OFF"] := True
	links["FAIL"] := True
	links["peixoto"] := {"command" : "http://ahkscript.org/boards/viewtopic.php?f=6&t=9341"}
	links["donate"] := {"command" : "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=P4ENPU5R7MYUJ"}
	links["device"] := {"command" : "control.exe /name Microsoft.DevicesAndPrinters"}
	links["Xemu"] := {"command" : "http://www.x360ce.com/default.aspx"}
	links["Compiler"] := {"command" : "Textures\Dumps\Compiler.exe"}

	stringreplace, body, body, tb||,<table border="1" style="width:100`%">, All
	stringreplace, body, body, tb|,<table style="width:100`%">, All
	stringreplace, body, body, |tb,</table>, All
	stringreplace, body, body, tr|r, </tr><td align="right">, All
	stringreplace, body, body, tr|, </tr><td>, All
	stringreplace, body, body, |tr, <td></tr>, All
	stringreplace, body, body, |||r, </td><td align="right">,, All
	stringreplace, body, body, |||, </td><td>, All
	stringreplace, body, body, ||n, <br><br>, All
	stringreplace, body, body, ||n, <br><br>, All
	stringreplace, body, body, |n, <br>, All
	stringreplace, body, body, bi|, <i><b>, All
	stringreplace, body, body, |bi, </i></b>, All
	stringreplace, body, body, i|, <i>, All
	stringreplace, body, body, |i, </i>, All
	stringreplace, body, body, b|, <b>, All
	stringreplace, body, body, |b, </b>, All
	stringreplace, body, body, l|, <li>, All
	stringreplace, body, body, u|, <ul>, All
	stringreplace, body, body, a|, <a id=", All
	stringreplace, body, body, %A_space%^%A_space%, "`, href="javascript:dummy()">, All
	stringreplace, body, body, |a, </a>, All
	stringreplace, body, body
	, `%Xinput`%, <a id=Xinput href="javascript:dummy()">Support for Xinput controllers</a> (Xbox 360`, Xbox one and similar) with working triggers and dpad
	stringreplace, body, body, `%Textures`%, <a id=Textures href="javascript:dummy()">A method to replace the game's textures</a>
	stringreplace, body, body, `%Mods`%, <a id=Mods href="javascript:dummy()">Mods management</a>
	stringreplace, body, body, `%Replace`%, <a id=ed href="javascript:dummy()">replace</a>, All
	stringreplace, body, body, `%Replacing`%, <a id=ed href="javascript:dummy()">replacing</a>, All
	stringreplace, body, body, `%Change`%, <a id=ed href="javascript:dummy()">change</a>, All

	return [body, links_body]
}

global html := setHTMLData("help\main.txt")
global HELPdocument
HELP.Navigate("about:blank")
HELPdocument := HELP.document
HELPdocument.write(static_htmlcode)
HELPdocument.body.innerHTML := html[1]
ComObjConnect(HELPdocument, "help_")

global Links_Pannel_document
Links_Pannel.Navigate("about:blank")
Links_Pannel_document := Links_Pannel.document
Links_Pannel_document.write(static_htmlcode)
Links_Pannel_document.body.innerHTML := html[2]
ComObjConnect(Links_Pannel_document, "Links_Pannel_")

global GHELPdocument
GAME_HELP.Navigate("about:blank")
GHELPdocument := GAME_HELP.document
GHELPdocument.write(static_htmlcode)
GHELPdocument.body.innerHTML := html[1]
ComObjConnect(GHELPdocument, "Ghelp_")

global Games_list_document
Games_list.Navigate("about:blank")
Games_list_document := Games_list.document
Games_list_document.write(static_htmlcode)
Games_list_document.body.innerHTML := GetGamesList()
ComObjConnect(Games_list_document, "List_")

tabs():
	if (tabs = "Help") {
		Games_list_document.body.innerHTML := GetGamesList()
		List_onclick()
		Gameslist("")
		} else {
			html := setHTMLData("help\main.txt")
			HELPdocument.body.innerHTML := html[1]
			Links_Pannel_document.body.innerHTML := html[2]
		}
return

help_onclick()
{
	command := links[HELPdocument.activeElement.id]
	cmd := command.command
	dir := command.dir
	batch := HELPdocument.activeElement.innerText
	;msgbox % HELPdocument.activeElement.id
	if (HELPdocument.activeElement.id = "ON")
		soundplay, *64
	else if (HELPdocument.activeElement.id = "OFF")
		soundplay, *-1
	else if (HELPdocument.activeElement.id = "FAIL")
		soundplay, *16
	else if (HELPdocument.activeElement.id = "BATCH")
		run, %batch%
	else if (HELPdocument.activeElement.id = "EDIT")
		run, notepad.exe %batch%, %A_workingdir%
	else run, %cmd%, %dir%
}

Ghelp_onclick()
{
	command := links[GHELPdocument.activeElement.id]
	cmd := command.command
	dir := command.dir
	batch := GHELPdocument.activeElement.innerText
	;msgbox % HELPdocument.activeElement.id
	if (GHELPdocument.activeElement.id = "ON")
		soundplay, *64
	else if (GHELPdocument.activeElement.id = "OFF")
		soundplay, *-1
	else if (GHELPdocument.activeElement.id = "FAIL")
		soundplay, *16
	else if (GHELPdocument.activeElement.id = "BATCH")
		run, %batch%
	else if (GHELPdocument.activeElement.id = "EDIT")
		run, notepad.exe %batch%, %A_workingdir%
	else if (GHELPdocument.activeElement.id = "Xinput")
		showInfo("Xinput")
	else if (GHELPdocument.activeElement.id = "Textures")
		showInfo("Textures")
	else if (GHELPdocument.activeElement.id = "Mods")
		showInfo("Mods")
	else if (GHELPdocument.activeElement.id = "ed") {
		if g_current_batch
			run  notepad.exe %g_current_batch%, %A_workingdir%\Scripts
	}
	else run, %cmd%, %dir%
}

Links_Pannel_onclick()
{
	if Links_Pannel_document.activeElement.id = "Donate"
		run "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=P4ENPU5R7MYUJ"
	else HELPdocument.getElementByid(Links_Pannel_document.activeElement.id).scrollIntoView()
	;msgbox % Links_Pannel_document.activeElement.id
}

List_onclick(flag="")
{
	if (Games_list_document.activeElement.id = "div")
		return
	else if (Games_list_document.activeElement.id = "Game")
		Gameslist((g_current_batch := Games_list_document.activeElement.innerText))

	loop
	{
		try
			(_html:= Games_list_document.getElementsByName("Game")[A_index-1]).innerText = g_current_batch
			? _html.style.color := 0x0000ff : _html.style.color := 0x000000
		catch
			break
	}
}

GetGamesList()
{
	body := "<body><br><br>"
	loop, scripts\*.bat
		body .=  "<a id=""game"" href=""javascript:dummy()"" style=""color:rgb(0,0,0);text-decoration:none"">" A_Loopfilename "<br> </a>"

	loop,  peixoto\*.*
	{
		splitpath, A_loopfilefullpath, , , ext
		if (ext = "bat") or (ext = "ahk")
			body .=  "<a id=""game"" href=""javascript:dummy()"" style=""color:rgb(0,0,0);text-decoration:none"">" A_Loopfilename "<br> </a>"
	}

	body .= "</body>"
	return body
}

Gameslist(dummy)
{
	static current
	stringreplace, current, g_current_batch, .bat, ,

	if not g_current_batch
	{
		local_html := ["<body><br><br><br><br><br> <font size=""6""> &#8592 Select a game from the list</font></body>", ""]
		GHELPdocument.body.innerHTML := local_html[1]
		return
	}

	if fileexist("help\" trim(g_ini.read(current, "Help")) ".txt")
		local_html := setHTMLData("help\" trim(g_ini.read(current, "Help")) ".txt")
	else local_html := ["<body><center><font size=""6""><br><br><br><br><br>No help available</font></center></body>", ""]
	GHELPdocument.body.innerHTML := local_html[1]
	return

	buttonstart:
		if not docheck()
			return

		if not (target := checkpath(current))
			return
		splitpath, target, , dir
		if A_iscompiled
			run "%A_scriptdir%\scripts\%current%" "%Target%" "%dir%", %A_scriptdir%\scripts
		else
		{
			args := g_ini.read(current, "devflags")
			try run "%A_scriptdir%\scripts\%current%" "%Target%" "%dir%" "%args%", %A_scriptdir%\scripts
			catch
				run "%A_scriptdir%\peixoto\%current%" "%Target%" "%dir%" "%args%", %A_scriptdir%\peixoto
		}
	return

	buttonedit:
		if not docheck()
			return

		editor := g_ini.read("editor", "Settings")
		editor ?: editor := "notepad.exe"
		try run %editor% "%A_scriptdir%\scripts\%g_current_batch%"
		catch
		{
			run notepad.exe "%A_scriptdir%\scripts\%g_current_batch%"
			return
		}
	return

	buttonCreateShortcut:
		if not docheck()
			return

		if not (target := checkpath(current))
			return
		splitpath, target, , dir
		stringreplace, name, current, .bat, .lnk
		name .= ".lnk"
		if A_iscompiled
			filecreateshortcut, "%A_scriptdir%\scripts\%current%", %A_desktop%\%name%, %A_scriptdir%\scripts, "%Target%" "%dir%", ,%Target%
		else
		{
			args := g_ini.read(current, "devflags")
			if fileexist("%A_scriptdir%\scripts\%current%")
				filecreateshortcut, "%A_scriptdir%\scripts\%current%", %A_desktop%\%name%, %A_scriptdir%\scripts
				, "%Target%" "%dir%" "%args%", ,%Target%
			else
				filecreateshortcut, "%A_scriptdir%\scripts\%current%", %A_desktop%\%name%, %A_scriptdir%\peixoto
				, "%Target%" "%dir%" "%args%", ,%Target%
		}
		if not errorlevel
			msgbox, 64, ,A shortcut was created on your desktop !
		else msgbox, 16, ,An error has ocurred !
	return

}

docheck() {
	if not g_current_batch	{
		msgbox, 16, , Please select a game from the list
			return False
	} return True
}

checkpath(current) {
	if not g_ini.read(current, "Target") or not fileexist(g_ini.read(current, "Target")) {
		msgbox, 64, ,Prease indicate the path of the game's executable`nThis is a one time only procedure
		FileSelectFile, target, Options, , , (*.exe)
		if not target
			return False
		g_ini.edit(current, target, "Target")
		g_ini.save()
	} return g_ini.read(current, "Target")
}

showInfo(lnk) {
	menu, popup, show
	return

	LearnMore:
		GuiControl, Choose, tabs, 1
		HELPdocument.body.innerHTML := html[1]
		Links_Pannel_document.body.innerHTML := html[2]
		if (lnk = "Xinput") {
			HELPdocument.getElementByid("-controller").scrollIntoView()
		} else if (lnk = "Textures") {
			HELPdocument.getElementByid("-textswap").scrollIntoView()
		} else if (lnk =  "Mods") {
			HELPdocument.getElementByid("-mods and -basepath").scrollIntoView()
		} HELPdocument.body.innerHTML := html[1]
	return

	customize:
		editor := g_ini.read("editor", "Settings")
		editor ?: editor := "notepad.exe"
		try run %editor% "%A_scriptdir%\scripts\%g_current_batch%"
		catch
			run notepad.exe "%A_scriptdir%\scripts\%g_current_batch%"
	return
}

addnew(){
	static
	;gui, +disabled
	gui, addnew: default
	gui, destroy
	gui, +hwndh_addnew
	;gui, +owner%hmain%
	;gui, +parent%hmain%
	gui, +0x40000000
	dllcall("SetParent", uint, h_addnew, uint, hmain)

	gui, add, edit, x30 y40 hwndname w300 h20, New game entry
	gui, add, link, hwndGpath w300 x+40 h20, <a>New entry path</a>

	gui, add, checkbox, hwndText x30 y+50 vTswap gTextSwap() checked0, Texture Swap
	gui, add, text, y+20 w50 h20 +right, API
	gui, add, DropDownList, x+20 yp-6 w80 hwndAPI v_API altsubmit, Direct3D|Direct3D2|Direct3D3|Direct3D7||OpenGl

	gui, add, text, section x30 y+15 w50 h20 +right, Next
	gui, add, text, y+10 w50 h20 +right, Prev
	gui, add, text, y+10 w50 h20 +right, Dump
	gui, add, text, y+10 w50 h20 +right, Quick
	gui, add, text, y+10 w50 h20 +right, Switch
	gui, add, Hotkey, xs+70 ys-6 w60 h20 vNext hwndhNext, PgUP
	gui, add, Hotkey, y+10 w60 h20 vPrev hwndhPrev, PgDn
	gui, add, Hotkey, y+10 w60 h20 vDump hwndhDump, Home
	gui, add, Hotkey, y+10 w60 h20 vQuick hwndhQuick, shift
	gui, add, Hotkey, y+10 w60 h20 vSwitch hwndhSW, end

	gui, add, text, x+10 ys-2 w80 h20 section +right, Color Switch
	gui, add, text, y+10 w80 h20 +right, Samples
	gui, add, text, y+10 w80 h20 +right, Thumbail size
	gui, add, text, y+10 w80 h20 +right, No 16bit Alpha
	gui, add, text, y+10 w80 h20 +right, Alt swap
	gui, add, Hotkey, xs+100 ys-6 w60 vClr hwndhClr, ins
	gui, add, DropDownList, y+10 w50 vSamples hwndhSamples, 4||8|16
	gui, add, DropDownList, y+10 w60 vSize hwndhSize, 128||256
	gui, add, DropDownList, y+10 w60 vAlpha hwndhAlpha, False||True
	gui, add, DropDownList, y+10 w60 vAltswap hwndhAltswap, False||True

	gui, add, text, x30 y+20 w50 h20 +right, Path
	gui, add, edit, x+20 yp-3 w230 h20 hwndpath v_path

	guicontrolget, pos, pos, Tswap
	gui, add, checkbox, hwndDInput x370 y%posy% vD_Input gDInput() checked0, Direct Input Emulation
	gui, add, text, section y+15 w75 h20 +right, A -
	gui, add, DropDownlist, x+5 yp-3 w60 h20 vA hwndhA, 1||2|3|4|5|6|7|8|9|10|11|12
	gui, add, text, x+20 ys w75 h20 +right, B -
	gui, add, DropDownlist, x+5 yp-3 w60 h20 vB hwndhB, 1|2||3|4|5|6|7|8|9|10|11|12
	gui, add, text, xs y+10 w75 h20 +right, X -
	gui, add, DropDownlist, x+5 yp-3 w60 h20 vX hwndhX, 1|2|3||4|5|6|7|8|9|10|11|12
	gui, add, text, x+20 yp+3 w75 h20 +right, Y -
	gui, add, DropDownlist, x+5 yp-3 w60 h20 vY hwndhY, 1|2|3|4||5|6|7|8|9|10|11|12
	gui, add, text, xs y+10 w75 h20 +right, Left Button -
	gui, add, DropDownlist, x+5 yp-3 w60 h20 vLEFT_SHOULDER hwndhC, 1|2|3|4|5||6|7|8|9|10|11|12
	gui, add, text, x+20 yp+3 w75 h20 +right, Right Button -
	gui, add, DropDownlist, x+5 yp-3 w60 h20 vRIGHT_SHOULDER hwndhD, 1|2|3|4|5|6||7|8|9|10|11|12
	gui, add, text, xs y+10 w75 h20 +right, Left Trigger -
	gui, add, DropDownlist, x+5 yp-3 w60 h20 vbLeftTrigger hwndhF, 1|2|3|4|5|6|7||8|9|10|11|12
	gui, add, text, x+20 yp+3 w75 h20 +right, Right Trigger -
	gui, add, DropDownlist, x+5 yp-3 w60 h20 vbRightTrigger hwndhG, 1|2|3|4|5|6|7|8||9|10|11|12
	gui, add, text, xs y+10 w75 h20 +right, Back -
	gui, add, DropDownlist, x+5 yp-3 w60 h20 vBack hwndhH, 1|2|3|4|5|6|7|8|9||10|11|12
	gui, add, text, x+20 yp+3 w75 h20 +right, Start -
	gui, add, DropDownlist, x+5 yp-3 w60 h20 vStart hwndhI, 1|2|3|4|5|6|7|8|9|10||11|12
	gui, add, text, xs y+10 w75 h20 +right, Left Stick -
	gui, add, DropDownlist, x+5 yp-3 w60 h20 vLEFT_THUMB hwndhJ, 1|2|3|4|5|6|7|8|9|10||11|12
	gui, add, text, x+20 yp+3 w75 h20 +right, Right Stick -
	gui, add, DropDownlist, x+5 yp-3 w60 h20 vRIGHT_THUMB hwndhK, 1|2|3|4|5|6|7|8|9|10|11|12||
	gui, add, text, xs y+40 w75 h20 +right, Dead Zone -
	gui, add, DropDownlist, x+5 yp-3 w60 h20 hwnddeadzone v_dzone, 0.||0.05|0.10|0.15|0.20|0.25

	gui, add, checkbox, x30 y+40 hwndsinglecore, Single Core
	gui, add, checkbox, x+20, 8bit Color Fix
	gui, add, checkbox, x+20, no argv[0]
	gui, add, checkbox, x+20, /saves
	gui, add, link, x+20 yp, <a>-saves/</a>
	gui, add, Text, x30 y+20 w80, Command Line
	gui, add, edit, x+20 yp-3 w80 w540 hwndcommandline
	gui, add, text, x30 y+10 w80, Compatibility
	gui, add, edit, x+20 yp-3 w150
	gui, add, link, x+20 yp+3 hwndmods, <a>-mods</a>

	ui_GroupControls(DInput, deadzone, hK, "Direct Unput Emulation")
	ui_GroupControls(Text, path, Altswap, "Texture Swap")
	ui_GroupControls(name, name, ,"Name")
	ui_GroupControls(gpath, gpath, ,"Path")
	ui_GroupControls(singlecore, mods, commandline, "Other settings")
	gui, add, button, x+-100 y+20 w100 h30 gAddNew() ,Add New

	gosub TextSwap()
	gosub DInput()
	gui, addnew: show, ,Add New
	winwaitclose, Add New
	gui, %hmain%: default
	;gui, -disabled
	return

	TextSwap():
		gui, submit, nohide
		for k, v in [hNext, hPrev, hDump, hQuick, hSW, hClr, API, hSamples, hSize, hAlpha, hAltswap, path]
			guicontrol, enable%Tswap%, %v%
	return

	DInput():
		gui, submit, nohide
		for k, v in [hA ,hB, hX, hY, hC, hD, hE, hF, hG, hH, hI, hJ, hK, deadzone]
			guicontrol, enable%D_Input%, %v%
	return

	AddNew():
		gui, submit, nohide
		cmd =
		(LTrim
		set target=`%~1
		set injector=..\Injector.exe `%~3`%
		start `%injector`% -target "`%target`%" ^`n
		)
		if Tswap {
			(_API = 4) ? _API := 7
			(_API = 5) ? _API := -1
			_cmd =
			(LTrim
			-d3D %_API% -TextSwap "samples=%samples%;^`nnext=%next%;^`nprev=%prev%;^`ndump=%dump%;^`nquick=%quick%;^`nswitch=%switch%;^`ncolor_switch=%clr%;^
			thumbnail=%size%;^`nno16bitAlpha=%Alpha%;^`naltSwap=%Altswap%;^`npath=%_path%" ^`n
			)
			cmd .= _cmd
		}
		if D_Input {
			_cmd =
			(LTrim
			-Controller A=%A%;^B=%B%;^X=%X%;^Y=%Y%;^`nLEFT_SHOULDER=%LEFT_SHOULDER%;^`nRIGHT_SHOULDER=%RIGHT_SHOULDER%;^
			bRightTrigger=%bRightTrigger%;^`nbLeftTrigger=%bLeftTrigger%;^`nLEFT_THUMB=%LEFT_THUMB%;^`nRIGHT_THUMB=%RIGHT_THUMB%;^
			start=%start%;^`nback=%back%;^`ndeadzone=%_dzone% ^`n
			)
			cmd .= _cmd
		}
		MsgBox % cmd
		gui, destroy
	return

}

RunAsAdmin() {

hModule := DllCall("Kernel32.dll\LoadLibrary", Str, "Advapi32.dll", "UInt")

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Opens current process and gets the token
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; OpenProcess - http://msdn.microsoft.com/en-us/library/windows/desktop/ms684320.aspx
; PROCESS_QUERY_INFORMATION = 0x0400
hProcess := DllCall(	"Kernel32.dll\OpenProcess"
						, UInt, 0x0400
						, Int, 0
						, UInt, DllCall("Kernel32.dll\GetCurrentProcessId")
						, "UInt")

; OpenProcessToken - http://msdn.microsoft.com/en-us/library/windows/desktop/aa379295.aspx
; TOKEN_ASSIGN_PRIMARY = 0x0001
; TOKEN_DUPLICATE = 0x0002
; TOKEN_QUERY = 0x0008
; TOKEN_ADJUST_DEFAULT = 0x0080;
DllCall(	"Advapi32.dll\OpenProcessToken"
			, UInt, hProcess
			, UInt, 0x0001 | 0x0002 | 0x0008 | 0x0080
			, UIntP, hToken)

if A_OSVersion in WIN_2000,WIN_XP		; The flag LUA_TOKEN doesn't work on XP, then we need to deny the Administrators SID
{
	oldSys = 1

	; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	; Creates an Administrators SID and fills SID structure
	; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	; GetSidLengthRequired - http://msdn.microsoft.com/en-us/library/windows/desktop/aa446656.aspx
	; *** [IMPORTANT]
	; *** The Well-Known Administrators SID needs 2 subauthorities:
	; *** SECURITY_BUILTIN_DOMAIN_RID and DOMAIN_ALIAS_RID_ADMINS
	; *** http://msdn.microsoft.com/en-us/library/windows/desktop/aa379597.aspx
	sidSize := DllCall(		"Advapi32.dll\GetSidLengthRequired"
							, UChar, 2
							, "UInt")

	VarSetCapacity(pAdminSid, sidSize, 0)

	; CreateWellKnownSid - http://msdn.microsoft.com/en-us/library/windows/desktop/aa446585.aspx
	; Well-Known SID Structures - http://msdn.microsoft.com/en-us/library/cc980032.aspx
	; WELL_KNOWN_SID_TYPE { ... WinBuiltinAdministratorsSid = 26 ...}
	DllCall(	"Advapi32.dll\CreateWellKnownSid"
				, UInt, 26
				, UInt, 0
				, UInt, &pAdminSid
				, UIntP, sidSize)

	; SID_AND_ATTRIBUTES - http://msdn.microsoft.com/en-us/library/aa379595
	VarSetCapacity(sAdminSidAttr, 8, 0)		; Assuming 32bit pointer size
	NumPut(&pAdminSid, sAdminSidAttr, 0, "UInt")
}

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Restricts the token (denies the Administrators SID on XP)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; CreateRestrictedToken - http://msdn.microsoft.com/en-us/library/Aa446583
; DISABLE_MAX_PRIVILEGE = 0x1
; LUA_TOKEN = 0x4
DllCall(	"Advapi32.dll\CreateRestrictedToken"
			, UInt, hToken
			, UInt, oldSys ? 0x1 : 0x4
			, UInt, oldSys ? 1 : 0
			, UInt, oldSys ? &sAdminSidAttr : 0
			, UInt, 0
			, UInt, 0
			, UInt, 0
			, UInt, 0
			, UIntP, hResToken)

if A_OSVersion in WIN_VISTA		; We can set integrity levels only on Windows Vista/7
{
	newSys = 1

	; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	; Creates an integrity SID and sets the integrity level
	; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	; *** [IMPORTANT]
	; *** The Well-Known Integrity SIDs need 1 subauthority:
	; *** In our case, we need SECURITY_MANDATORY_LOW_RID or SECURITY_MANDATORY_MEDIUM_RID.
	; *** http://msdn.microsoft.com/en-us/library/bb625963.aspx

	; GetSidLengthRequired - http://msdn.microsoft.com/en-us/library/windows/desktop/aa446656.aspx
	sidSize := DllCall(		"Advapi32.dll\GetSidLengthRequired"
							, UChar, 1
							, "UInt")

	VarSetCapacity(pIntegritySid, sidSize, 0)

	; CreateWellKnownSid - http://msdn.microsoft.com/en-us/library/windows/desktop/aa446585.aspx
	; Well-Known SID Structures - http://msdn.microsoft.com/en-us/library/cc980032.aspx
	; WELL_KNOWN_SID_TYPE { ... WinLowLabelSid = 66, WinMediumLabelSid = 67 ...}
	DllCall(	"Advapi32.dll\CreateWellKnownSid"
				, UInt, 67
				, UInt, 0
				, UInt, &pIntegritySid
				, UIntP, sidSize)

	; SID_AND_ATTRIBUTES - http://msdn.microsoft.com/en-us/library/aa379595
	; SE_GROUP_INTEGRITY = 0x00000020L
	VarSetCapacity(sIntegritySidAttr, 8, 0)		; Assuming 32bit pointer size
	NumPut(&pIntegritySid, sIntegritySidAttr, 0, "UInt")
	NumPut(0x00000020L, sIntegritySidAttr, 4, "UInt")

	; *** [IMPORTANT]
	; *** SetTokenInformation's 3rd parameter is the TOKEN_MANDATORY_LABEL structure, but,
	; *** if we encapsulate the sIntegritySidAttr inside it (as written in Windows docs),
	; *** the function returns a 1337 error (ERROR_INVALID_SID).
	; *** http://msdn.microsoft.com/en-us/library/windows/desktop/bb394727.aspx

	; SetTokenInformation - http://msdn.microsoft.com/en-us/library/windows/desktop/aa379591.aspx
	; TOKEN_INFORMATION_CLASS = {... TokenIntegrityLevel = 25 ...}
	DllCall(	"Advapi32.dll\SetTokenInformation"
				, UInt, hResToken
				, UInt, 25
				, UInt, &sIntegritySidAttr
				, UInt, NumGet(sidSize, 0, "UInt") + 8)
}

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Starts the process with the restricted token
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; STARTUPINFO - http://msdn.microsoft.com/en-us/library/ms686331
VarSetCapacity(sStartInfo, 68, 0)		; Assuming 32bit pointer size
NumPut(68, sStartInfo, 0, "UInt")
NumPut("winsta0\\default", sStartInfo, 8, "Str")

; PROCESS_INFORMATION - http://msdn.microsoft.com/en-us/library/ms684873
VarSetCapacity(sProcInfo, 16, 0)		; Assuming 32bit pointer size

; CreateProcessAsUser - http://msdn.microsoft.com/en-us/library/ms682429
; NORMAL_PRIORITY_CLASS = 0x00000020
DllCall(	"Advapi32.dll\CreateProcessAsUserA"
			, UInt, hResToken
			, Int, "NULL"
			, Str, "C:\\Windows\\System32\\cmd.exe"
			, UInt, 0
			, UInt, 0
			, Int, 0
			, UInt, 0x00000020
			, UInt, 0
			, Int, "NULL"
			, UInt, &sStartInfo
			, UInt, &sProcInfo)

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Closes handles and frees libraries and structures
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DllCall("Kernel32.dll\CloseHandle", UInt, hProcess)
DllCall("Kernel32.dll\CloseHandle", UInt, hToken)
DllCall("Kernel32.dll\CloseHandle", UInt, hResToken)
DllCall("Kernel32.dll\CloseHandle", UInt, NumGet(sProcInfo, 0, "UInt"))
DllCall("Kernel32.dll\CloseHandle", UInt, NumGet(sProcInfo, 4, "UInt"))
if oldSys
{
	DllCall("Advapi32.dll\FreeSid", UInt, &pAdminSid)
}
if newSys
{
	DllCall("Advapi32.dll\FreeSid", UInt, &pIntegritySid)
}
DllCall("Kernel32.dll\FreeLibrary", UInt, hModule)

; RunAsAdmin - Thanks to shajul (http://www.autohotkey.com/forum/viewtopic.php?t=50448)
RunAsAdmin() {
	global
	Loop, %0%  ; For each parameter:
		params .= A_Space . %A_Index%
	local ShellExecute
	ShellExecute := A_IsUnicode ? "shell32\ShellExecute":"shell32\ShellExecuteA"
	if not A_IsAdmin
	{
		A_IsCompiled
		? DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_ScriptFullPath, str, params , str, A_WorkingDir, int, 1)
		: DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_AhkPath, str, """" . A_ScriptFullPath . """" . A_Space . params, str, A_WorkingDir, int, 1)
		ExitApp
	}
}
}


buttonaddnew:
	msgbox, 64, , Soon...
	return
	addnew()
return

guiclose:
exitapp