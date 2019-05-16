#Include SyntaxTree.ahk
#Persistent

handle := DllCall( "LoadLibrary", "Str", "SciLexer.dll" )
if !handle
{
	Msgbox % "Failed to load SciLexer.dll - Exiting"
	ExitApp
}

Gui, Add, Custom, ClassScintilla x10 y10 w600 h600 vOutPut hwndSciIn, 
ScintillaSetUnicode( SciIn )
ScintillaSetText( SciIn, "1.1+1.1" )
ScintillaSetHighlight( SciIn, "back", 0xCCCCCC )
ScintillaSetHighlight( SciIn, "eolFilled", 1 )

Gui, Add, Button, gEval, Evaluate

Gui, Add, Custom, ClassScintilla x620 y10 w600 h600 vInput hwndSciOut
ScintillaSetUnicode( SciOut )
ScintillaSetReadOnly( SciOut, 1 )
ScintillaSetHighlight( SciOut, "eolFilled", 1 )

selectFile := ""
Loop, Files,% A_ScriptFullPath . "\..\*.xml"
	selectFile .= ( firstFile ? A_LoopFileName : firstFile := A_LoopFileName ) . "|", max := A_Index
Gui, Add, DropDownList, gSelect vParseMode, % SubStr( selectFile, 1, -1 )
GuiControl,Choose , ParseMode, %max%
GoSub, Select
Gui, Show
return
Eval:
Gui, Submit, NoHide
ScintillaSetReadOnly( SciIn, 1 )
ScintillaSetEmptySelection( SciIn, 1 )
Msgbox % ShowParsedSyntaxTree( new expressionElement( OutPut ) )
ScintillaSetReadOnly( SciIn, 0 )
return
GUIClose:
ExitApp
Select:
GUI, Submit, NoHide
expressionElement := new SyntaxTree( ParseMode )
expressionElement.enableDebugging( debugHelper )
ScintillaSetReadOnly( SciOut, 0 )
ScintillaSetText( SciOut, expressionElement.xmlText )
ScintillaSetReadOnly( SciOut, 1 )
;Msgbox % disp( expressionElement.debugInfo )
return

class debugHelper
{
	
	startTry( baseTree, textPos, element, MentionIndex )
	{
		global SciOut, SciIn
		ScintillaSetHighlight( SciOut, "back", 0xFF9999 )
		debug := baseTree.debugInfo[ element.getID() ].MentionInfo[ MentionIndex ]
		ScintillaHighlightText( SciOut, debug.start - 1, debug.end - 1 )
		ScintillaHighlightText( SciIn, 0, textPos - 1 )
		Sleep 500
	}
	
	succeedTry( baseTree, textPos, element, MentionIndex, em )
	{
		global SciOut, SciIn
		ScintillaSetHighlight( SciOut, "back", 0x99FF99 )
		debug := baseTree.debugInfo[ element.getID() ].MentionInfo[ MentionIndex ]
		ScintillaHighlightText( SciOut, debug.start - 1, debug.end - 1 )
		ScintillaHighlightText( SciIn, 0, textPos - 1 )
		Sleep 500
	}
	
	failTry( baseTree, textPos, element, MentionIndex, em, e )
	{
		global SciOut
		debug := baseTree.debugInfo[ element.getID() ].MentionInfo[ MentionIndex ]
		ScintillaHighlightText( SciOut, debug.start - 1, debug.end - 1 )
		ScintillaSetHighlight( SciOut, "back", 0x9999FF )
		Sleep 500
	}
	
}

ShowParsedSyntaxTree( parsedSyntaxTree )
{
	return ShowContent( parsedSyntaxTree.document )
}

ShowContent( parsedSyntaxTree )
{
	if !hasClass( parsedSyntaxTree, SyntaxTree.ContainerElement )
		return parsedSyntaxTree.getText()
	s := "["
	For each, element in parsedSyntaxTree.content
		s .= showContent( element ) . ", "
	return SubStr( s, 1, -2 ) . "] "
}

ShowSyntaxTreeStructure( syntaxTree )
{
	return ShowStructure( syntaxTree.parseData )
}

ShowStructure( parsedSyntaxTree )
{
	static instances := 0, objList := {}, typeList := {}
	instances++
	if ( !id := objList[ &parsedSyntaxTree ] )
	{
		if ( parsedSyntaxTree.getID() )
			id := parsedSyntaxTree.getID()
		else
		{
			regExMatch( parsedSyntaxTree.__class, "\.(\w+)Element", out )
			if !typeList.hasKey( out1 )
				typeList[out1] := 0
			id := out1 . "." . ++typeList
		}
		objList[ &parsedSyntaxTree ] := id
	}
	s := id . "`t:"
	if !isObject( parsedSyntaxTree.parseData.1 )
		s .= """" . parsedSyntaxTree.parseData.1 . """`n"
	else
	{
		a := []
		for each, element in parsedSyntaxTree.parseData
		{
			if ( !id := objList[ &element ] )
			{
				if ( element.getID() )
					id := element.getID()
				else
				{
					regExMatch( element.__class, "\.(\w+)Element", out )
					if !typeList.hasKey( out1 )
						typeList[out1] := 0
					id := out1 . "." . ++typeList[out1]
				}
				objList[ &element ] := id
				a.Push( ShowStructure( element ) )
			}
			s .= " " . id
		}
		s .= "`n"
		for each, entry in a
			s .= entry
	}
	if ( --instances = 0 )
		objList := {}, typeList := {}
	return s
}

ScintillaSetReadOnly( sci, readOnly )
{
	SendMessage, 2171, %readOnly%, 0, , ahk_id %sci%
}

ScintillaSetUnicode( sci )
{
	SendMessage, 2037, 65001, 0, , ahk_id %sci%
}

ScintillaSetText( sci, text )
{
	size := StrPut( text , "Utf-8" )
	VarSetCapacity( var, size, 0 )
	StrPut( text, &var, size, "Utf-8" )
	SendMessage, 2181, 0,% &var, , ahk_id %Sci%
}

ScintillaHighlightText( sci, start, end, level := 1 )
{
	static storage := []
	if ( range := storage[ sci, level ] )
	{
		SendMessage, 2032,% range.1, 0, , ahk_id %Sci%
		SendMessage, 2033,% range.2 - range.1,% 32, , ahk_id %Sci%
	}
	SendMessage, 2032,% start, 0, , ahk_id %Sci%
	SendMessage, 2033,% end-start,% level + 39, , ahk_id %Sci%
	storage[ sci, level ] := [start, end]
}

ScintillaSetHighlight( sci, option, value, level := 1 )
{
	static options := { italic:2054, underline:2059, bold:2053, font:2056, back:2052, fore:2051, eolFilled:2057 }
	if !( value * 0 = 0 ) ;value is not numerical
	{
		size := StrPut( text , "Utf-8" )
		VarSetCapacity( var, size, 0 )
		StrPut( text, value := &var, size, "Utf-8" )
	}
	SendMessage, % options[option], % level + 39, % value, , ahk_id %sci%
}

ScintillaSetPosition( sci, pos )
{
	SendMessage, 2141, %pos%, 0, , ahk_id %sci%
}

ScintillaSetEmptySelection( sci, pos )
{
	SendMessage, 2556, %pos%, 0, , ahk_id %sci%
}