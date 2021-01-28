
Gui, ec: Add, Text	, xm ym 	 Center             	, Choose example
Gui, ec: Add, Button, xm y+20 vBtn1 gExample	, Example1
Gui, ec: Add, Button, xm      	 vBtn2 gExample	, Example2
Gui, ec: Show

return

Example:

	Gui, ec: Submit, NoHide
	RegExMatch(A_GuiControl, "\d+", nr)
	goto % "Example" nr
	Gui, ec: Show
	Gui, ec: Default

return

ecGuiClose:
ecGuiEscape:
return

Example1: ;{

	sd := ComObjCreate("Scripting.Dictionary")
	Members := EnumComMembers(sd)

	Gui, ex: Add, ListView, x12 y5 w200 h420, ID|Name|Kind
	Loop Parse, Members, `n
	{
	  StringSplit, item, A_LoopField, `t
	  LV_Add("", item1, item2, item3)
	}
	LV_ModifyCol()
	Gui, ex: Show, , Excel Members

return ;}

Example2: ;{

	;;
	;; iTypeInfo - Enum Com Members - By jethrow
	;;
	;; small Mod by Blackholyman to output member Name and Doc string in "UTF-16" and put it in a listview
	;;
	;; GUI & furthers Mods by TLM
	;;

	Gui, ex: Add, Text,, Enter COM Object
	Gui, ex: Add, Edit, vComObject w200, MSXML2.DOMDocument.6.0 ; , % Format( "{:50}", A_Space )
	Gui, ex: Add, Button, gSearch Section, Search Members
	Gui, ex: Add, Text, vDisp ys5, % Format( "{:190}", A_Space )
	Gui, ex: Add, ListView, r20 w700 xs Section, #|ID|Name|Kind|DocString  ; Create a ListView.

	Loop % LV_GetCount( "Col" )
	   LV_ModifyCol( A_Index, "AutoHdr" )

	Gui, ex: Show,, Enum COM Members

Return

Search:

	Gui, ex: Submit, NoHide

	Try ( sd := ComObjCreate( ComObject ) )
	Catch Err
	{
	   MsgBox, 0x10, Whoops!, % Err.Message "!`nTry a valid object eg: Shell.Explorer"
	   Return
	}

	GuiControl, ex: Disable, Search
	GuiControl, ex: , Disp, % "Interface: " ComObjType( sd, "Name" )

	Loop, Parse, % ( EnumComMembers( GetTypeInfo( sd ) ), LV_Delete() ), `n
	{
	   Fields := StrSplit( A_LoopField, "|" )
	   LV_Add(, A_Index, Fields[1], Fields[2], Fields[3], Fields[4], Fields[5] )
	}

	For Each, Column in Fields
	   LV_ModifyCol( Each, "Auto" )

	GuiControl, ex: Enable, Search

return

exGuiClose:
	Gui, ex: Destroy
return ;}


#include %A_ScriptDir%\..\EnumComMembers.ahk

