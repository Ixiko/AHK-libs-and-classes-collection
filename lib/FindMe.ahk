/*
Name:        Find Me
Version:     2.0.2 (Mon August 29, 2011)
Author:      tidbit
credits:     camerb
Description: Find all matching text/phrases inside of files of a specified directory.

right-click: context Menu
esc: stop searching and replacing
ctrl+w: exit the program

add a * (asterisks) as the first letter in the File text field to recurse into all sub folders.
   Example: *C:\Documents and Settings\USER\Desktop\
   NOTE: Use with caution. it may take much longer.
*/

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force
SetBatchLines, -1
OnExit, ExitLabel

menu, tray, add, Options, Options

; load everything on startup, if anything exists
inifile:=A_ScriptDir "\FindMe_Config.ini"
IniRead, wX,      %inifile%, Settings, X, -1
IniRead, wY,      %inifile%, Settings, Y, -1
IniRead, wWidth,  %inifile%, Settings, Width, -1
IniRead, wHeight, %inifile%, Settings, Height, -1
IniRead, seldir,  %inifile%, Settings, LastDir, -1
IniRead, word,    %inifile%, Settings, LastSearch, Regex is Enabled. Case Insensitive
IniRead, replace, %inifile%, Settings, LastReplace, Regex is Enabled. Case Insensitive
IniRead, editor,  %inifile%, Settings, Editor, %A_WinDir%\notepad.exe
IniRead, editorOptions,  %inifile%, Settings, EditorOptions,
if (SubStr(seldir, 1, 1)=="*")
	seldir:=SubStr(seldir, 2)

; [LOAD]
	SaveCount:=10
	; syntax: DDL_Load(file [, max, cur, section, keyname, default])
	listfile   := DDL_Load(inifile, SaveCount, "Logs", "LastFile", A_MyDocuments)
	listsearch := DDL_Load(inifile, SaveCount, "Logs", "LastSearch")
	listreplace:= DDL_Load(inifile, SaveCount, "Logs", "LastReplace")
; [/LOAD]

Menu, copymenu, Add, Edit, editmenu
Menu, copymenu, Add, Copy Text, copymenu
Menu, copymenu, Add, Select All, selmenu
Menu, copymenu, Add, Export Checked, exportmenu
selall:=0

; ecb = Export CheckBox
Gui, 2: add, Checkbox, x6  y6 w72 +checked vecb1, File
Gui, 2: add, Checkbox, x+2 yp w72 +checked vecb2, Line
Gui, 2: add, Checkbox, x+2 yp w72 +checked vecb3, Sample
Gui, 2: add, Checkbox, x+2 yp w72 +checked vecb4, Path
Gui, 2: add, Button, x6 y+8 w288  gexport, Save



gui, +Resize

w:=((wWidth>-100) ? wWidth-72 : 190)
Gui, 1: Add, ComboBox,   x6  y10 w%w% r10 vseldir, %listfile%
Gui, 1: Add, Button, x+2 y10 w58  h20 vseldirbtn gbrowse, Browse

w:=((wWidth>-100) ? wWidth-95 : 168)
Gui, 1: Add, Radio, x6  y+2   w80  h20 vextmode +Checked cblue, Extensions:
Gui, 1: Add, Radio, x6  y+2   w80  h20 cred, Ignore:
Gui, 1: Add, Edit,  x+2 yp-22 w%w% h20 vexts  gext, txt`,ahk`,htm`,html
Gui, 1: Add, Edit,  xp  y+2   w%w% h20 vXexts gext, bmp`,gif`,jpg`,png`,svg`,tif`,mid`,mp3`,wav`,wma`,avi`,flv`,mov`,mp4`,mpg`,swf`,vob`,wmv`,app`,exe`,msi`,pif`,wsf

w:=((wWidth>-100) ? wWidth-162 : 108)
Gui, 1: Add, Text,   x6  y+2 w60  h20 , Find:
Gui, 1: Add, ComboBox,   x+8 yp  w%w% r10 vword, %listsearch%
Gui, 1: Add, Button, x+2 yp  w20  h20 vwordhelp gregexhelp,?
Gui, 1: Add, Button, x+2 yp  w58  h20 vwordsearch gsearch +Default, Search

w:=((wWidth>-100) ? wWidth-140 : 122)
Gui, 1: Add, Checkbox, x6  yp+22   h20 gusereplace vusereplace, Replace?
Gui, 1: Add, ComboBox,     x+2 yp w%w% r10 vreplace +Disabled, %listreplace%
Gui, 1: Add, Button,   x+2 yp w58  h20 greplace vreplacebtn , Replace
;~ MsgBox %yp%

w:=((wWidth>-100)  ? wWidth-12   : 250)
h:=((wHeight>-100) ? wHeight-140 : 210)
Gui, 1: Add, ListView, x6 y+6 w%w% h%h% vlist hwndhListView glistview Count5000 +Checked, File|Line|Sample|Path

LV_ModifyCol(1, "80 Left")
LV_ModifyCol(2, "40 Integer right")
LV_ModifyCol(3, "250 Left")
LV_ModifyCol(4, "80 Left")

Gui, Add, StatusBar,,


; if _anything_ was missing or deformed or oddly placed, autosize it. safety first.
SysGet, VirtualWidth, 78
SysGet, VirtualHeight, 79

if ((wX<-100 || xX>VirtualWidth) || (wY<-100 || wY>VirtualHeight) || wWidth<-100 || wHeight<-100)
	Gui, 1: Show, AutoSize, Find Me
else
	Gui, 1: Show, x%wX% y%wY% w%wWidth% h%wHeight%, Find Me
ScriptID:=WinActive("A")

Gosub, guisize
SB_SetText("Awaiting Action.", 1, 0)
Return

Guisize:
	SB_SetParts((A_GuiWidth/3)+30, A_GuiWidth/3, A_GuiWidth/3)
	SB_SetText("Press Escape to abort a search.", 2, 0)
	SB_SetText("Right-click for context menu..", 3, 0)

	Anchor("seldir", "w")
	Anchor("seldirbtn", "x")

	Anchor("exts", "w")
	Anchor("Xexts", "w")

	Anchor("word", "w")
	Anchor("wordhelp", "x")
	Anchor("wordsearch", "x")

	Anchor("replace", "w")
	Anchor("replacebtn", "x")

	Anchor("list", "wh")
Return



ext:
	gui, 1: Submit, NoHide
	If exts Contains .,%A_Space%
	{
		StringReplace, exts, exts, .,, All
		StringReplace, exts, exts, %A_Space%,, All
		GuiControl, text, exts, %exts%
	}
Return



browse:
	Gui, 1: Submit, NoHide

	if (SubStr(seldir, 1, 1)=="*")
		browsedir:=SubStr(seldir, 2)

	FileSelectFolder, seldir, *%browsedir%, 3, Select a folder.
	If (RegExMatch(seldir, "^\s*$"))
		Return
	Else
		Load_DDL_Values(inifile, "seldir", seldir, SaveCount, "Logs", "LastFile", A_MyDocuments)
Return



listview:
	If (A_GuiEvent=="DoubleClick")
	{
		LV_GetText(Filetorun, A_EventInfo,4)
		If (filetorun=="File")
			Return
		run, %filetorun%
	}
	If (A_GuiEvent = "ColClick")
		LV_SortArrow(hListView, A_EventInfo)
Return


GuiContextMenu:
	If (A_GuiControl!="list")
		return
	RCrow:=A_EventInfo ; Right-Clicked row
	Menu, copymenu, Show, %A_GuiX%, %A_GuiY%
return


editmenu:

	; short variables for editor options in the INI.
	; F = File to run.
	; L = Line to open to.
	LV_GetText(F, RCrow,4)
	LV_GetText(L, RCrow,2)
	IniRead, editor,  %inifile%, Settings, Editor, %A_WinDir%\notepad.exe
	IniRead, editorOptions,  %inifile%, Settings, EditorOptions,

	If (filetorun=="File")
		Return

	if (InStr(F, A_Space))
		F:= """" F """"
	Transform, editorOptions, Deref, %editorOptions%

	ToolTip, %editor% %editorOptions%

	run, %editor% %editorOptions%
	; run, %A_ProgramFiles%\notepad++\notepad++.exe %filetorun%
Return

copymenu:
	LV_GetText(copytext, RCrow, 3)
	Clipboard:=copytext
Return


selmenu:
	selall:=!selall
	if (selall==1)
		LV_Modify(0, "Check")
	else
		LV_Modify(0, "-Check")
Return


exportmenu:
	Gui, 2: Show, w300 autosize, Export - Find Me
return


usereplace:
	gui, 1: Submit, NoHide
	If (usereplace==1)
		guiControl, Enable, replace
	Else
		guiControl, Disable, replace
Return



replace:
	gui, 1: Submit, NoHide
	Load_DDL_Values(inifile, "replace", replace, SaveCount, "Logs", "LastReplace")

	IniWrite, %replace%, %inifile%, Settings, LastReplace
	If (usereplace==0)
		Return

	SB_SetText("Replacing... ", 1, 0)

	Loop % LV_GetCount()
	{
		If (escIsPressed())
			Break

		SendMessage, 4140, A_index - 1, 0xF000, SysListView321  ; 4140 is LVM_GETITEMSTATE.  0xF000 is LVIS_STATEIMAGEMASK.
		isChecked := (ErrorLevel >> 12) - 1
		; isChecked := LV_GetNext(iteration, "Checked")

		If (isChecked==0)
			Continue

		LV_GetText(line, A_index, 2)
		LV_GetText(file, A_index, 4)
		LV_Modify(A_Index, "-Check")

		SB_SetText("Replacing in: " file, 1, 0)

		TF_RegExReplaceInLines("!" file, line, line, "i)" word, replace)
	}

	SB_SetText("Awaiting Action.", 1, 0)
Return



export:
	FileSelectFile, ExportFile, 16, %seldir%\Log.csv, Save the selected rows.
	if (ErrorLevel)
		return

	Gui, 2: submit
	gui, 1: Submit, nohide
	Gui, 1: +LastFound
	Gui, 1: Default

	Exportlist:=""
	SB_SetText("Exporting... ", 1, 0)

	Loop % LV_GetCount()
	{
		If (escIsPressed())
			Break

		SendMessage, 4140, A_index - 1, 0xF000, SysListView321  ; 4140 is LVM_GETITEMSTATE.  0xF000 is LVIS_STATEIMAGEMASK.
		isChecked := (ErrorLevel >> 12) - 1

		If (isChecked==0)
			Continue

		; export Column info in CSV format.
		; doing some voodoo to make it fit on as few amount of lines as possible.
		if (ecb1==1)
			Exportlist.="""" substr(LV_GetText(eCol, A_index, 1), 2) eCol """`,"
		if (ecb2==1)
			Exportlist.=substr(LV_GetText(eCol, A_index, 2), 2) eCol "`,"
		if (ecb3==1)
			Exportlist.="""" substr(LV_GetText(eCol, A_index, 3), 2) eCol """`,"
		if (ecb4==1)
			Exportlist.="""" substr(LV_GetText(eCol, A_index, 4), 2) eCol """`,"

		; remove the trailing comma and append a newline.
		; felt like being fancy and not using stringtrimright.
		; some people also hate stringtrimright as much as goto/gui,destroy. I don't though.
		Exportlist:=SubStr(Exportlist, 1, StrLen(Exportlist)-1) "`n"
		Exportcount:=A_Index
	}
	FileAppend, %Exportlist%, %ExportFile%

	; reuseing the variable since the important full path is no longer needed.
	SplitPath, ExportFile, ExportFile
	SB_SetText(Exportcount " items appended to " ExportFile ", Awaiting Action.", 1, 0)
return



search:
	gui, 1: Submit, NoHide
	Load_DDL_Values(inifile, "Word", Word, SaveCount, "Logs", "lastSearch")
	Load_DDL_Values(inifile, "seldir", seldir, SaveCount, "Logs", "LastFile", A_MyDocuments)

	start:=A_TickCount

	LV_ModifyCol(3, "AutoHdr", "Sample: (0)")

	If (RegExMatch(seldir, "^\s*$"))
		Return

	if (SubStr(seldir, 1, 1)=="*")
	{
		recurseMode:=1
		seldir:=SubStr(seldir, 2)
	}
	Else
		recurseMode:=0

        if NOT InStr( FileExist(seldir), "D" )
        {
                msgbox, The selected directory does not exist.
                return
        }

	LV_Delete()
	selall:=0
	flist:=""
	max:=0
	Loop,%seldir%\*.*, 0, %recurseMode%
	{
		If (escIsPressed())
			Break

		if (extmode==1)
		{
			If A_LoopFileExt in %exts%
			{
				max+=1
				flist.=A_LoopFileFullPath "`n"
				SB_SetText("Counting files: " max, 1, 0)
			}
		}
		Else
		{
			If A_LoopFileExt in %Xexts%
				Continue
			max+=1
			flist.=A_LoopFileFullPath "`n"
			SB_SetText("Counting files: " max, 1, 0)
		}
		Continue
	}
	StringTrimRight, flist, flist, 1 ; remove the ending blank line.
	sort, flist, R ; mainly used for files with dates in the name. put the newer items at the top.
; MsgBox %flist%

	loop, parse, flist, `n, `r
	{
		If (escIsPressed())
			Break

		filePath:=A_LoopField
		SplitPath, a_loopfield, fileName
		SB_SetText("file: " A_Index "/" max " -- " fileName, 1, 0)
		curFileNumber:=A_Index

		FileRead, fileText, %filePath%
		filetext:=unHTM(filetext)

		output:=agrep(fileText, word, 1)

		;------ debugging GUI (pretty ugly, :D)
		; xpos+=101
		; gui, 92:add, text, x%xpos% y6 y6 w100, %fileName%
		; gui, 92:add, edit, x%xpos% y6 y32 w100 h300, %output%
		; gui, 92:show, w1000 x6 h356

		loop, parse, fileText, `n, `r
		{
			If (escIsPressed())
				Break
			if (!RegExMatch(a_loopfield, "i`n)" word))
				continue

			line:=A_LoopField
			linenum:=A_Index
			loop, parse, output, `n, `r
			{
				if (InStr(line, A_LoopField))
				{
					LV_Add("", fileName, linenum, ConvertEntities(unHTM(line)), filePath)
					LV_ModifyCol(3, "AutoHdr", "Sample: (" LV_GetCount() ")")
					Break
				}
				else
					continue
			}
			LV_ModifyCol(3, "AutoHdr", "Sample: (" LV_GetCount() ")")
		}
	}

	LV_ModifyCol(1, "Auto")
	LV_ModifyCol(2, "Auto")
	LV_ModifyCol(3, "Auto")
	stop:=round((A_TickCount-start)/1000, 3)
	SB_SetText(curFileNumber " files in " stop " seconds. Awaiting Action.", 1, 0)
Return



regexhelp:
	Gui, 11: Destroy
	Gui, 11: Default
	help=
	(
.	Matches any character.	cat. matches catT and cat2 but not catty
[]	Bracket expression. Matches one of any characters enclosed.	gr[ae]y matches gray or grey
[^]	Negates a bracket expression. Matches one of any characters EXCEPT those enclosed.	1[^02] matches 13 but not 10 or 12
[-]	Range. Matches any characters within the range.	[1-9] matches any single digit EXCEPT 0
?	Preceeding item must match one or zero times.	colou?r matches color or colour but not colouur
()	Parentheses. Creates a substring or item that metacharacters can be applied to	a(bee)?t matches at or abeet but not abet
{n}	Bound. Specifies exact number of times for the preceeding item to match.	[0-9]{3} matches any three digits
{n,}	Bound. Specifies minimum number of times for the preceeding item to match.	[0-9]{3,} matches any three or more digits
{n,m}	Bound. Specifies minimum and maximum number of times for the preceeding item to match.	[0-9]{3,5} matches any three, four, or five digits
|	Alternation. One of the alternatives has to match.	July (first|1st|1) will match July 1st but not July 2
[:alnum:]	alphanumeric character	[[:alnum:]]{3} matches any three letters or numbers, like 7Ds
[:alpha:]	alphabetic character, any case	[[:alpha:]]{5} matches five alphabetic characters, any case, like aBcDe
[:blank:]	space and tab	[[:blank:]]{3,5} matches any three, four, or five spaces and tabs
[:digit:]	digits	[[:digit:]]{3,5} matches any three, four, or five digits, like 3, 05, 489
[:lower:]	lowercase alphabetics	[[:lower:]] matches a but not A
[:punct:]	punctuation characters	[[:punct:]] matches ! or . or , but not a or 3
[:space:]	all whitespace characters, including newline and carriage return	[[:space:]] matches any space, tab, newline, or carriage return
[:upper:]	uppercase alphabetics	[[:upper:]] matches A but not a
//	Default delimiters for pattern	/colou?r/ matches color or colour
i	Append to pattern to specify a case insensitive match	/colou?r/i matches COLOR or Colour
\b	A word boundary, the spot between word (\w) and non-word (\W) characters	/\bfred\b/i matches Fred but not Alfred or Frederick
\B	A non-word boundary	/fred\B/i matches Frederick but not Fred
\d	A single digit character	/a\db/i matches a2b but not acb
\D	A single non-digit character	/a\Db/i matches aCb but not a2b
\n	The newline character. (ASCII 10)	/\n/ matches a newline
\r	The carriage return character. (ASCII 13)	/\r/ matches a carriage return
\s	A single whitespace character	/a\sb/ matches a b but not ab
\S	A single non-whitespace character	/a\Sb/ matches a2b but not a b
\t	The tab character. (ASCII 9)	/\t/ matches a tab.
\w	A single word character - alphanumeric and underscore	/\w/ matches 1 or _ but not ?
\W	A single non-word character	/a\Wb/i matches a!b but not a2b
	)

	Gui, 11: add, text, y6 x6, Basic Regex Help
	Gui, 11:add, ListView, y26 x6 w450 r25 vlist, Key|Description|Example


	Loop, Parse, help, `n
	{
		StringSplit, col, A_LoopField, %A_Tab%
		LV_Add( "", col1, col2, col3)
	}

	LV_ModifyCol(1, "Auto")
	LV_ModifyCol(2, 200)
	LV_ModifyCol(3, "Auto")

	gui, 11: show, x45 , Regex Help
Return



; ------ Functions ---
; --------------------



; thanks SKAN! http://www.autohotkey.com/forum/viewtopic.php?t=51342&highlight=remove+html
UnHTM( HTM ) {   ; Remove HTML formatting / Convert to ordinary text   by SKAN 19-Nov-2009
 Static HT,C=";" ; Forum Topic: www.autohotkey.com/forum/topic51342.html  Mod: 16-Sep-2010
 IfEqual,HT,,   SetEnv,HT, % "&aacuteá&acircâ&acute´&aeligæ&agrave? &amp&aringå&atildeã&au"
 . "mlä&bdquo„&brvbar¦&bull•&ccedilç&cedil¸&cent¢&circˆ&copy©&curren¤&dagger? &dagger‡&deg"
 . "°&divide÷&eacuteé&ecircê&egraveè&ethð&eumlë&euro€&fnofƒ&frac12½&frac14¼&frac34¾&gt>&h"
 . "ellip…&iacuteí&icircî&iexcl¡&igraveì&iquest¿&iumlï&laquo«&ldquo“&lsaquo‹&lsquo‘&lt<&m"
 . "acr¯&mdash—&microµ&middot·&nbsp &ndash–&not¬&ntildeñ&oacuteó&ocircô&oeligœ&ograveò&or"
 . "dfª&ordmº&oslashø&otildeõ&oumlö&para¶&permil‰&plusmn±&pound£&quot""&raquo»&rdquo”&reg"
 . "®&rsaquo›&rsquo’&sbquo‚&scaronš&sect§&shy &sup1¹&sup2²&sup3³&szligß&thornþ&tilde˜&tim"
 . "es×&trade™&uacuteú&ucircû&ugraveù&uml¨&uumlü&yacuteý&yen¥&yumlÿ"
 $ := RegExReplace( HTM,"<[^>]+>" )               ; Remove all tags between  "<" and ">"
 Loop, Parse, $, &`;                              ; Create a list of special characters
   L := "&" A_LoopField C, R .= (!(A_Index&1)) ? ( (!InStr(R,L,1)) ? L:"" ) : ""
 StringTrimRight, R, R, 1
 Loop, Parse, R , %C%                               ; Parse Special Characters
  If F := InStr( HT, L := A_LoopField )             ; Lookup HT Data
    StringReplace, $,$, %L%%C%, % SubStr( HT,F+StrLen(L), 1 ), All
  Else If ( SubStr( L,2,1)="#" )
    StringReplace, $, $, %L%%C%, % Chr(((SubStr(L,3,1)="x") ? "0" : "" ) SubStr(L,3)), All
Return RegExReplace( $, "(^\s*|\s*$)")            ; Remove leading/trailing white spaces
}

; thanks Uberi!
ConvertEntities(HTML)
{
 static EntityList := "|quot=34|apos=39|amp=38|lt=60|gt=62|nbsp=160|iexcl=161|cent=162|pound=163|curren=164|yen=165|brvbar=166|sect=167|uml=168|copy=169|ordf=170|laquo=171|not=172|shy=173|reg=174|macr=175|deg=176|plusmn=177|sup2=178|sup3=179|acute=180|micro=181|para=182|middot=183|cedil=184|sup1=185|ordm=186|raquo=187|frac14=188|frac12=189|frac34=190|iquest=191|Agrave=192|Aacute=193|Acirc=194|Atilde=195|Auml=196|Aring=197|AElig=198|Ccedil=199|Egrave=200|Eacute=201|Ecirc=202|Euml=203|Igrave=204|Iacute=205|Icirc=206|Iuml=207|ETH=208|Ntilde=209|Ograve=210|Oacute=211|Ocirc=212|Otilde=213|Ouml=214|times=215|Oslash=216|Ugrave=217|Uacute=218|Ucirc=219|Uuml=220|Yacute=221|THORN=222|szlig=223|agrave=224|aacute=225|acirc=226|atilde=227|auml=228|aring=229|aelig=230|ccedil=231|egrave=232|eacute=233|ecirc=234|euml=235|igrave=236|iacute=237|icirc=238|iuml=239|eth=240|ntilde=241|ograve=242|oacute=243|ocirc=244|otilde=245|ouml=246|divide=247|oslash=248|ugrave=249|uacute=250|ucirc=251|uuml=252|yacute=253|thorn=254|yuml=255|OElig=338|oelig=339|Scaron=352|scaron=353|Yuml=376|circ=710|tilde=732|ensp=8194|emsp=8195|thinsp=8201|zwnj=8204|zwj=8205|lrm=8206|rlm=8207|ndash=8211|mdash=8212|lsquo=8216|rsquo=8217|sbquo=8218|ldquo=8220|rdquo=8221|bdquo=8222|dagger=8224|Dagger=8225|hellip=8230|permil=8240|lsaquo=8249|rsaquo=8250|euro=8364|trade=8482|"
 FoundPos = 1
 While, (FoundPos := InStr(HTML,"&",False,FoundPos))
 {
  FoundPos ++, Entity := SubStr(HTML,FoundPos,InStr(HTML,"`;",False,FoundPos) - FoundPos), (SubStr(Entity,1,1) = "#") ? (EntityCode := SubStr(Entity,2)) : (Temp1 := InStr(EntityList,"|" . Entity . "=") + StrLen(Entity) + 2, EntityCode := SubStr(EntityList,Temp1,InStr(EntityList,"|",False,Temp1) - Temp1))
  StringReplace, HTML, HTML, &%Entity%`;, % Chr(EntityCode), All
 }
 Return, HTML
}



; thanks Solar! http://www.autohotkey.com/forum/viewtopic.php?t=69642
; h = ListView handle
; c = 1 based index of the column
; d = Optional direction to set the arrow. "asc" or "up". "desc" or "down".
LV_SortArrow(h, c, d="") {
   static ptr, ptrSize, lvColumn, LVM_GETCOLUMN, LVM_SETCOLUMN
   if (!ptr) {
      ptr := A_PtrSize ? "ptr" : "uint", PtrSize := A_PtrSize ? A_PtrSize : 4
      ,LVM_GETCOLUMN := A_IsUnicode ? 4191 : 4121, LVM_SETCOLUMN := A_IsUnicode ? 4192 : 4122
      ,VarSetCapacity(lvColumn, PtrSize + 4), NumPut(1, lvColumn, 0, "uint")
   }
   c -= 1, DllCall("SendMessage", ptr, h, "uint", LVM_GETCOLUMN, "uint", c, ptr, &lvColumn)
   if ((fmt := NumGet(lvColumn, 4, "int")) & 1024) {
      if (d && d = "asc" || d = "up")
         Return
      NumPut(fmt & ~1024 | 512, lvColumn, 4, "int")
   } else if (fmt & 512) {
      if (d && d = "desc" || d = "down")
         Return
      NumPut(fmt & ~512 | 1024, lvColumn, 4, "int")
   } else {
      Loop % DllCall("SendMessage", ptr, DllCall("SendMessage", ptr, h, "uint", 4127), "uint", 4608) {
         if ((i := A_Index - 1) = c)
            Continue
         DllCall("SendMessage", ptr, h, "uint", LVM_GETCOLUMN, "uint", i, ptr, &lvColumn)
         ,NumPut(NumGet(lvColumn, 4, "int") & ~1536, lvColumn, 4, "int")
         ,DllCall("SendMessage", ptr, h, "uint", LVM_SETCOLUMN, "uint", i, ptr, &lvColumn)
      }
      NumPut(fmt | ((d && d = "desc" || d = "down") ? 512 : 1024), lvColumn, 4, "int")
   }
   return DllCall("SendMessage", ptr, h, "uint", LVM_SETCOLUMN, "uint", c, ptr, &lvColumn)
}



; ------ TF() Stuff ---
; ---------------------
; Thanks hugov! http://www.autohotkey.com/forum/viewtopic.php?t=46195

TF_RegExReplaceInLines(Text, StartLine = 1, EndLine = 0, NeedleRegEx = "", Replacement = "")
	{
	 TF_GetData(OW, Text, FileName)
	 If (RegExMatch(Text, NeedleRegEx) < 1)
	 	Return ; NeedleRegEx not in file or error, do nothing
	 TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine) ; create MatchList
	 Loop, Parse, Text, `n, `r
		{
         	 If A_Index in %TF_MatchList%
			{
			 LoopField := RegExReplace(A_LoopField, NeedleRegEx, Replacement)
			 OutPut .= LoopField "`n"
			}
		 Else
			OutPut .= A_LoopField "`n"
		}
	 Return TF_ReturnOutPut(OW, OutPut, FileName)
	}


TF_Count(String, Char)
	{
	StringReplace, String, String, %Char%,, UseErrorLevel
	Return ErrorLevel
	}


TF_GetData(byref OW, byref Text, byref FileName) ; HugoV, helper function to determine if VAR/TEXT or FILE is passed to TF
	{
	OW=0 ; default setting: asume it is a file and create file_copy
    If (SubStr(Text,1,1)="!") ; first we check for "overwrite"
		{
		 Text:=SubStr(Text,2)
		 OW=1 ; overwrite file (if it is a file)
		}
    IfNotExist, %Text% ; now we can check if the file exists, it doesn't so it is a var
		 {
		  If (OW=1) ; the variable started with a ! so we need to put it back because it is variable/text not a file
			Text:= "!" . Text
		  OW=2 ; no file, so it is a var or Text passed on directly to TF
		 }

    If (OW = 0) or (OW = 1)
		{
	 	 Text := (SubStr(Text,1,1)="!") ? (SubStr(Text,2)) : Text
		 FileName=%Text% ; Store FileName
		 FileRead, Text, %Text% ; Read file and return as Text
		}
	Return
	}


	TF_ReturnOutPut(OW, Text, FileName, TrimTrailing = 1, CreateNewFile = 0) { ; HugoV
	If (OW = 0) ; input was file, file_copy will be created, if it already exist file_copy will be overwritten
		{
		 IfNotExist, % FileName ; check if file Exist, if not return otherwise it would create an empty file. Thanks for the idea Murp|e
		 	{
		 	 If (CreateNewFile = 1) ; CreateNewFile used for TF_SplitFileBy* and others
				{
				 OW = 1
		 		 Goto CreateNewFile
				}
			 Else
				Return
			}
		 If (TrimTrailing = 1)
			 StringTrimRight, Text, Text, 1 ; remove trailing `n
		SplitPath, FileName,, Dir, Ext, Name
		 If (Dir = "") ; if Dir is empty Text & script are in same directory
			Dir := A_ScriptDir
		 IfExist, % Dir "\backup" ; if there is a backup dir, copy original file there
			FileCopy, % Dir "\" Name "_copy." Ext, % Dir "\backup\" Name "_copy.bak", 1
		 FileDelete, % Dir "\" Name "_copy." Ext
		 FileAppend, %Text%, % Dir "\" Name "_copy." Ext
		 Return Errorlevel ? False : True
		}
	 CreateNewFile:
	 If (OW = 1) ; input was file, will be overwritten by output
		{
		 IfNotExist, % FileName ; check if file Exist, if not return otherwise it would create an empty file. Thanks for the idea Murp|e
		 	{
		 	If (CreateNewFile = 0) ; CreateNewFile used for TF_SplitFileBy* and others
		 		Return
			}
		 If (TrimTrailing = 1)
			 StringTrimRight, Text, Text, 1 ; remove trailing `n
		 SplitPath, FileName,, Dir, Ext, Name
		 If (Dir = "") ; if Dir is empty Text & script are in same directory
			Dir := A_ScriptDir
		 IfExist, % Dir "\backup" ; if there is a backup dir, copy original file there
			FileCopy, % Dir "\" Name "." Ext, % Dir "\backup\" Name ".bak", 1
		 FileDelete, % Dir "\" Name "." Ext
		 FileAppend, %Text%, % Dir "\" Name "." Ext
		 Return Errorlevel ? False : True
		}
	If (OW = 2) ; input was var, return variable
		{
		 If (TrimTrailing = 1)
			StringTrimRight, Text, Text, 1 ; remove trailing `n
		 Return Text
		}
	}


_MakeMatchList(Text, Start = 1, End = 0)
	{
	ErrorList=
	 (join|
	 Error 01: Invalid StartLine parameter (non numerical character)
	 Error 02: Invalid EndLine parameter (non numerical character)
	 Error 03: Invalid StartLine parameter (only one + allowed)
	 )
	 StringSplit, ErrorMessage, ErrorList, |
	 Error = 0

 	 TF_MatchList= ; just to be sure
	 If (Start = 0 or Start = "")
		Start = 1

	 ; some basic error checking

	 ; error: only digits - and + allowed
	 If (RegExReplace(Start, "[ 0-9+\-\,]", "") <> "")
		 Error = 1

	 If (RegExReplace(End, "[0-9 ]", "") <> "")
		 Error = 2

	 ; error: only one + allowed
	 If (TF_Count(Start,"+") > 1)
		 Error = 3

	 If (Error > 0 )
		{
		 MsgBox, 48, TF Lib Error, % ErrorMessage%Error%
		 ExitApp
		}

 	 ; Option #1
	 ; StartLine has + character indicating startline + incremental processing.
	 ; EndLine will be used
	 ; Make TF_MatchList

	 IfInString, Start, `+
		{
		 If (End = 0 or End = "") ; determine number of lines
			End:= TF_Count(Text, "`n") + 1
		 StringSplit, Section, Start, `, ; we need to create a new "TF_MatchList" so we split by ,
		 Loop, %Section0%
			{
			 StringSplit, SectionLines, Section%A_Index%, `+
			 LoopSection:=End + 1 - SectionLines1
			 Counter=0
	         	 TF_MatchList .= SectionLines1 ","
			 Loop, %LoopSection%
				{
				 If (A_Index >= End) ;
					Break
				 If (Counter = (SectionLines2-1)) ; counter is smaller than the incremental value so skip
					{
					 TF_MatchList .= (SectionLines1 + A_Index) ","
					 Counter=0
					}
				 Else
					Counter++
				}
			}
		 StringTrimRight, TF_MatchList, TF_MatchList, 1 ; remove trailing ,
		 Return TF_MatchList
		}

	 ; Option #2
	 ; StartLine has - character indicating from-to, COULD be multiple sections.
	 ; EndLine will be ignored
	 ; Make TF_MatchList

	 IfInString, Start, `-
		{
		 StringSplit, Section, Start, `, ; we need to create a new "TF_MatchList" so we split by ,
		 Loop, %Section0%
			{
			 StringSplit, SectionLines, Section%A_Index%, `-
			 LoopSection:=SectionLines2 + 1 - SectionLines1
			 Loop, %LoopSection%
				{
				 TF_MatchList .= (SectionLines1 - 1 + A_Index) ","
				}
			}
		 StringTrimRight, TF_MatchList, TF_MatchList, 1 ; remove trailing ,
		 Return TF_MatchList
		}

	 ; Option #3
	 ; StartLine has comma indicating multiple lines.
	 ; EndLine will be ignored
	 IfInString, Start, `,
		{
		 TF_MatchList:=Start
		 Return TF_MatchList
		}

	 ; Option #4
	 ; parameters passed on as StartLine, EndLine.
	 ; Make TF_MatchList from StartLine to EndLine

	 If (End = 0 or End = "") ; determine number of lines
			End:= TF_Count(Text, "`n") + 1
	 LoopTimes:=End-Start
	 Loop, %LoopTimes%
		{
		 TF_MatchList .= (Start - 1 + A_Index) ","
		}
	 TF_MatchList .= End ","
	 StringTrimRight, TF_MatchList, TF_MatchList, 1 ; remove trailing ,
	 Return TF_MatchList
	}




/*
Copyright 2010,2011 Tuncay. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are
permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of
      conditions and the following disclaimer.

   2. Redistributions in binary form must reproduce the above copyright notice, this list
      of conditions and the following disclaimer in the documentation and/or other materials
      provided with the distribution.

THIS SOFTWARE IS PROVIDED BY Tuncay ``AS IS'' AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Tuncay OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those of the
authors and should not be interpreted as representing official policies, either expressed
or implied, of Tuncay.
*/
/*
Function: agrep
    Get all lines matching a regular expression.

Parameters:
    haystack        - Input string variable. Will not be modified directly.
    pattern         - The regex used to match the lines.
    ignoreCase      - Ignores the case of each character, makes lower and upper
        case equivalent.
    invert          - Invert the logic. Get those lines, which do not match.
    lineMatch       - Match only whole lines (internally "^" and "$" are used,
        otherwise ".*?" on both sides).
    replace         - A string to replace the non matching lines (newline
        inclusive) with.

Returns:
    All matching lines.

Remarks:
    ErrorLevel is set to the count of how many lines are leaved out in
    final result.

    The regular expression is enclosed by some constructs, especially by
    the look-ahead assertion. Also depending on the lineMatch option,
    the "^" and "$" is added at front and end of regex or just to match
    somewhere in the line, ".*" is added on both sides. It is possible,
    that some regex will not work within assertions, like backreferences.
    Not sure at this point. Also regex-options cannot be given, as they are
    specified within the function.

Examples:
    > ; Print all lines starting with "tf_".
    > msgbox % agrep(FileContent, "^\s*tf_", true)

About:
    * Version 1.3 by Tuncay, 13 July 2011
    * Discussion: [http://www.autohotkey.com/forum/viewtopic.php?t=74060]
    * License: [http://autohotkey.net/~Tuncay/licenses/simplefiedBSD_tuncay.txt]

Related:
    * grep() by polythene: [http://www.autohotkey.com/forum/viewtopic.php?t=16164]
    * TF_Find() by HugoV: [http://www.autohotkey.net/~hugov/tf-lib.htm#TF_Find]
*/
agrep(ByRef _haystack="", _pattern="", _ignoreCase=false, _invert=false, _lineMatch=false, _replace="")
{
    Return SubStr( RegExReplace(_haystack . "`n", (_ignoreCase ? "i" : "") . "`am)(*BSR_ANYCRLF)(?" . (_invert ? "=" : "!") . "(?:" . (_lineMatch ? "^" . _pattern . "$" : ".*?" . _pattern . ".*?") . "))^.*?\R", _replace, ErrorLevel), 1, -1)
}


/*
	Function: Anchor
		Defines how controls should be automatically positioned relative to the new dimensions of a window when resized.

	Parameters:
		cl - a control HWND, associated variable name or ClassNN to operate on
		a - (optional) one or more of the anchors: 'x', 'y', 'w' (width) and 'h' (height),
			optionally followed by a relative factor, e.g. "x h0.5"
		r - (optional) true to redraw controls, recommended for GroupBox and Button types

	Examples:
> "xy" ; bounds a control to the bottom-left edge of the window
> "w0.5" ; any change in the width of the window will resize the width of the control on a 2:1 ratio
> "h" ; similar to above but directrly proportional to height

	Remarks:
		To assume the current window size for the new bounds of a control (i.e. resetting) simply omit the second and third parameters.
		However if the control had been created with DllCall() and has its own parent window,
			the container AutoHotkey created GUI must be made default with the +LastFound option prior to the call.
		For a complete example see anchor-example.ahk.

	License:
		- Version 4.60a <http://www.autohotkey.net/~Titan/#anchor>
		- Simplified BSD License <http://www.autohotkey.net/~Titan/license.txt>
*/
Anchor(i, a = "", r = false) {
	static c, cs = 12, cx = 255, cl = 0, g, gs = 8, gl = 0, gpi, gw, gh, z = 0, k = 0xffff
	If z = 0
		VarSetCapacity(g, gs * 99, 0), VarSetCapacity(c, cs * cx, 0), z := true
	If (!WinExist("ahk_id" . i)) {
		GuiControlGet, t, Hwnd, %i%
		If ErrorLevel = 0
			i := t
		Else ControlGet, i, Hwnd, , %i%
	}
	VarSetCapacity(gi, 68, 0), DllCall("GetWindowInfo", "UInt", gp := DllCall("GetParent", "UInt", i), "UInt", &gi)
		, giw := NumGet(gi, 28, "Int") - NumGet(gi, 20, "Int"), gih := NumGet(gi, 32, "Int") - NumGet(gi, 24, "Int")
	If (gp != gpi) {
		gpi := gp
		Loop, %gl%
			If (NumGet(g, cb := gs * (A_Index - 1)) == gp) {
				gw := NumGet(g, cb + 4, "Short"), gh := NumGet(g, cb + 6, "Short"), gf := 1
				Break
			}
		If (!gf)
			NumPut(gp, g, gl), NumPut(gw := giw, g, gl + 4, "Short"), NumPut(gh := gih, g, gl + 6, "Short"), gl += gs
	}
	ControlGetPos, dx, dy, dw, dh, , ahk_id %i%
	Loop, %cl%
		If (NumGet(c, cb := cs * (A_Index - 1)) == i) {
			If a =
			{
				cf = 1
				Break
			}
			giw -= gw, gih -= gh, as := 1, dx := NumGet(c, cb + 4, "Short"), dy := NumGet(c, cb + 6, "Short")
				, cw := dw, dw := NumGet(c, cb + 8, "Short"), ch := dh, dh := NumGet(c, cb + 10, "Short")
			Loop, Parse, a, xywh
				If A_Index > 1
					av := SubStr(a, as, 1), as += 1 + StrLen(A_LoopField)
						, d%av% += (InStr("yh", av) ? gih : giw) * (A_LoopField + 0 ? A_LoopField : 1)
			DllCall("SetWindowPos", "UInt", i, "Int", 0, "Int", dx, "Int", dy
				, "Int", InStr(a, "w") ? dw : cw, "Int", InStr(a, "h") ? dh : ch, "Int", 4)
			If r != 0
				DllCall("RedrawWindow", "UInt", i, "UInt", 0, "UInt", 0, "UInt", 0x0101) ; RDW_UPDATENOW | RDW_INVALIDATE
			Return
		}
	If cf != 1
		cb := cl, cl += cs
	bx := NumGet(gi, 48), by := NumGet(gi, 16, "Int") - NumGet(gi, 8, "Int") - gih - NumGet(gi, 52)
	If cf = 1
		dw -= giw - gw, dh -= gih - gh
	NumPut(i, c, cb), NumPut(dx - bx, c, cb + 4, "Short"), NumPut(dy - by, c, cb + 6, "Short")
		, NumPut(dw, c, cb + 8, "Short"), NumPut(dh, c, cb + 10, "Short")
	Return, true
}


; Load_DDL_Values(_File, _Control, _text [, _Max, _Section, _Keyname, _Default])
; *** this is a combination of saving, loading and updating. nothing special. ***
	; _File    - the INI file to read from
	; _Control - the control to update
	; _Text    - the text to save to the ini.
	; _Max     - the max number of items to load in the DDL.
	; _Section - the INI section to search.
	; _Keyname - the name of the key group. DO NOT INCLUDE THE NUMBERS.
	; _Default - the default text to use if the key does not exist.
Load_DDL_Values(_File, _Control="", _text="", _Max=5, _Section="Logs", _Keyname="LastSearch", _Default="Regex is Enabled. Case Insensitive")
{
	; only change the INI if the last Replace option isn't the same.
	; helps prevent duplicates.
	IniRead, _first, %_file%, %_section%, %_keyname%1, %_default%
	if (_first!=_text)
	{
		DDL_Save(_File, _text, _Max, _Section, _keyname, _Default)
		list:=DDL_Load(_File,  _Max, _Section, _keyname, _Default)
		GuiControl,, %_Control%, |%list%
	}
}

; DDL_Load(_file [, _max, _section, _keyname, _default])
	; _file    - the INI file to read from
	; _max     - the max number of items to load in the DDL.
	; _section - the INI section to search.
	; _keyname - the name of the key group. DO NOT INCLUDE THE NUMBERS.
	; _default - the default text to use if the key does not exist.
DDL_Load(_file, _max=5, _section="Logs", _keyname="LastSearch", _default="Regex is Enabled. Case Insensitive")
{
	_list:=""
	loop, %_max%
	{
		IniRead, _search, %_file%, %_section%, %_keyname%%A_index%, %_default%
		_list.=((a_index==1) ? _search "||" : _search "|")
	}
	return _list
}

; DDL_Save(_file, _inputvar [, _max, _section, _keyname, _default])
	; _file     - the INI file to save to.
	; _inputvar - the variable to get the content from. This will be the first item in the list.
	; _max      - the max number of items to save in the ini.
	; _section  - the INI section to save in.
	; _keyname  - the name of the key group. DO NOT INCLUDE THE NUMBERS.
	; _default  - the default text to use if the key does not exist.
DDL_Save(_file, _inputvar="", _max=5, _section="Logs", _keyname="LastSearch", _default="Regex is Enabled. Case Insensitive")
{
	; get everything
	loop, %_max%
		IniRead, _search%A_index%, %_file%, %_section%, %_keyname%%A_index%, %_default%
	; re-order everything. last entered thing first.
	loop, %_max%
	{
		_counteroffset:=A_Index-1
		if (a_index==1)
			IniWrite, %_inputvar%, %_file%, %_section%, %_keyname%1
		if ((a_index)<=_Max && A_Index>=2)
			IniWrite, % _search%_counteroffset%, %_file%, %_section%, %_keyname%%A_Index%
	}
}

escIsPressed()
{
   If (getkeystate("esc","p") == "U")
      return false
   Else If (getkeystate("esc","p") == "D")
      return true
   return getkeystate("esc","p")
}

; ------ On Exit ---
; ------------------
ExitLabel:
	WinGetPos, wX, wY, wWidth, wHeight, ahk_id %ScriptID%
	IniWrite, %wX%,      %inifile%, Settings, X
	IniWrite, %wY%,      %inifile%, Settings, Y
	IniWrite, %wWidth%,  %inifile%, Settings, Width
	IniWrite, %wHeight%, %inifile%, Settings, Height

ExitApp

; ------ Menu ---
; ---------------
Options:
	run, %A_ScriptDir%\FindMe_Config.ini
Return

; ------ Hotkeys ---
; ------------------

#IfWinActive, Find Me
^w::
GuiClose:
	ExitApp
#IfWinActive
