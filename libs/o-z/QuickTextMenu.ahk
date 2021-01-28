; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=70736&hilit=punctuation
; Author:	Lorien
; Date:   	14.12.2019
; for:     	AHK_L

/*
#SingleInstance Force

QuickTextMenu("QTPunctuation", StrSplit("°,–,—,§,¶,«,»,‹,›,"
									  . "¡ +Break,¿,‼,‽,‰,©,®,™", ",")* )

QuickTextMenu("QTSymbols", StrSplit("↑,↓,←,→,"
								  . "▲ +Break,▼,◄,►,"
								  . "△ +Break,▽,◁,▷,"
								  . "■ +Break,□,▪,▫,"
								  . "○ +Break,●,◦,•,"
								  . "† +Break,‡,◊", ",")* )

; Even Greek and accented characters are case-insensitive menu shortcuts, so
; you need to make 2 separate menus for upper and lower cases.
QuickTextMenu("QTGreekUpper", StrSplit("Α,Β,Γ,Δ,Ε,Ζ,Η,Θ,"
									 . "Ι +Break,Κ,Λ,Μ,Ν,Ξ,Ο,Π,"
									 . "Ρ +Break,Σ,Τ,Υ,Φ,Χ,Ψ,Ω", ",")* )
QuickTextMenu("QTGreekLower", StrSplit("α,β,γ,δ,ε,ζ,η,θ,"
									 . "ι +Break,κ,λ,μ,ν,ξ,ο,π,"
									 . "ρ +Break,σ,τ,υ,φ,χ,ψ,ω", ",")* )

QuickTextMenu("QTAccentUpper", StrSplit("À,Á,Â,Ã,Ä,Å,Æ,Ç,"
									  . "È +Break,É,Ê,Ë,Ì,Í,Î,Ï,"
									  . "Ð +Break,Ñ,Ò,Ó,Ô,Õ,Ö,Ø,"
									  . "Ù +Break,Ú,Û,Ü,Ý,Þ,ß", ",")* )
QuickTextMenu("QTAccentLower", StrSplit("à,á,â,ã,ä,å,æ,ç,"
									  . "è +Break,é,ê,ë,ì,í,î,ï,"
									  . "ð +Break,ñ,ò,ó,ô,õ,ö,ø,"
									  . "ù +Break,ú,û,ü,ý,þ", ",")* )

QuickTextMenu("QTChain1", StrSplit("
(LTrim Comments
		&Hello&_	+Next QTChain2
		H&owdy&_	+Next QTChain2
		H&i&_		+Next QTChain2
		&Yo!
)", "`n")* )
QuickTextMenu("QTChain2", StrSplit("
(LTrim Comments
		&world!
		&dude!
		&y'all!
		&there.
)", "`n")* )

QuickTextMenu("QTBlurbs", StrSplit("
(LTrim Join^ Comments		;Join lines with caret, because newlines are embedded in the insert text.
							;Don't use pipe either, due to call syntax, just in case.
		42
		This is line 1.`nThis is line 2.
		Fox				+Text Something about a fox...`n`tand a log, right?
)", "^")* )

QuickTextMenu("QTInfo1", StrSplit("
(LTrim Comments
		&Name			+Text Santa Claus
		&Address		+Text 1 North Pole Lane
		&City			+Text North Pole
		&Zip			+Text 00000
		Cell &Phone		+Text (111) REINDEER
)", "`n")* )

QuickTextMenu("QTMain", StrSplit("
(LTrim Comments
		&Chaining example	+Menu QTChain1
		&Blurbs				+Menu QTBlurbs
		&Information		+Menu QTInfo1
		&Punctuation		+Menu QTPunctuation
		&Symbols			+Menu QTSymbols
		&Greek Upper		+Menu QTGreekUpper
		&Greek Lower		+Menu QTGreekLower
		&Accented Upper		+Menu QTAccentUpper
		&Accented Lower		+Menu QTAccentLower
		&ctLabel			+Call calltest							;Example of calling an label.
		ctFunc1				+Call calltestfunc|Hello world!|		;Example of calling a function!
		ctFunc2				+Call calltestfunc|Bye cruel world!|
)", "`n")* )

Return	;end auto-exec section

; Use %A_CaretX%, %A_CaretY% to have the menu popup at the text cursor.  For some reason, this is
; also necessary for the chained menus to function properly.
:x*:]``::Menu, QTChain1, Show, %A_CaretX%, %A_CaretY%
:x*:]\::Menu, QTMain, Show, %A_CaretX%, %A_CaretY%

calltest:
	msgbox Call label test!
	Return

calltestfunc(msg) {
	msgbox % "Call function test with argument:`n" msg
}

*/

/*
	QuickTextMenu.ahk
		Inspired/derived/robbed from jackdunning's HotstringMenu
			https://www.autohotkey.com/boards/viewtopic.php?f=6&t=69791

	Requires AHK 1.1.28+.

	QuickTextMenu(MenuName, MenuArray*)
		MenuName	String, Name of the AutoHotkey menu created by the function call.
		MenuArray*	Array of strings, each string defines a menu entry of the following form:

		<Label/insertion text>([ `t]+)[<Options>]
			- Options begin with the first plus ('+') preceded by either a space or tab.
				(i.e. the string is split on " +" and "`t+")
			- The portion before the first option is the label/insertion text.
			- The label and options are trimmed of leading/ending spaces and tabs, so that
				a line continuation can be aligned in columns for ease of reading.  See below
				for how to add leading/endig spaces and tabs.


		Labels follow AHK rules, plus the following features and limitations.
			- By default, the text appearing before the options defines the menu item's
				label AND the text to be inserted.

			- Auto-shortcut keys.
				- "&#" will be replaced with the numeric position of the item in the menu.
				- "&@" will be replaced with the lettered position of the item in the menu.
				- NOTE: The above are stripped from the insert text.
				- Don't combine with the standard AHK shortcut.  (Untested, but probably a bad idea.)

			- Leading/ending space and tab
				- "&_" will be replaced with a single space.
				- "&>" with be replaced with a single tab ("`t").

			- Normal AHK shortcuts will be cleaned to make the insert text.
				- For example, "&Hello world!" will be triggered by hitting the H key, and the
				  text inserted at the cursor will be "Hello world!".

		Options:
			+Label <string>		-	Defines a different label, separating it from the insertion text.
			+Text <string>		-	Defines a different insertion text, separating it from the label.
			+Menu <menuname>	-	Opens <menuname> as a submenu.  No text is output.
			+Next <menuname>	-	Inserts the text for the current menu item, then opens <menuname>
									and the new cursor location.  (I call this "chaining" menus.)
			+Break				-	Make the current item the first item in the next column of this
									menu.  (Sets the AHK option +BarBreak.)
			+Call <label>		-	Invokes the label <label>, when the menu item is chosen.  No
									text is output by menu label/text.

			+Call <funcname>|<pipe-seperated list of arguments>
								-	Invokes the function, passing it the arguments, when the menu
									item is chosen. No text is output by menu label/text.
								-	NOTE: Parentheses cannot be used, because this would conflict
									with the line continuation syntax of AHK 1.1.

		NOTES:
			-	When defining menus using line continuation sections, make sure the Join string
				and the StrSplit() delimiter are the same.
			-	If labels and/or text use "`n" or "`t", then it is suggested that the caret ('^')
				be used as the Join/StrSplit delimiter.
			-	It is recommended that the pipe ('|') not be used, as it used by the
				function calling syntax.

	Author: Lorien
	History:
		14-Dec-2019		Initial release.
		15-Dec-2019		Fix leading/ending space/tabs.  Honor "&&"s.  Add WinWaitNotActive to handler function.
*/

QuickTextMenu(MenuName, MenuArray*) {
	ArrayLength := MenuArray.SetCapacity(0) ; Get array size
;	dbgtxt := ""
	For Key, Item in MenuArray {
		args := StrSplit(Item, [" +", "`t+"], " `t") ;Split the string "[ \t]\+", and trim whitespace.

;		dbgtxt .= Key "|" Item "|" "len=" args.MaxIndex() "`n"

		itemLabel := args.RemoveAt(1)
;		dbgtxt .= "`tItem label/text = |" itemLabel "|`n"

		;Make text from itemLabel
		itemString := RegExReplace(itemLabel, "&[#@]\s*", "")	;Remove auto-number/-letter shortcut
		itemString := StrReplace(itemString, "&_", " ") 		;Un-escape space characters.
		itemString := StrReplace(itemString, "&>", "`t") 		;Un-escape tab characters.
		itemString := RegExReplace(itemString, "&(\w)", "$1")	;Menu shortcut '&'.
		itemString := StrReplace(itemString, "&&", "&") 	  	;Replace "&&" with '&'

		;Process any options
		Loop % args.MaxIndex()  {
;			dbgtxt .= "`t|" args[A_Index] "|`n"

			;Spit options into the first word, and the rest of the string as the argument(s).
			pos := InStr(args[A_Index], " ")
			If (pos > 0) {
				option := SubStr(args[A_Index], 1, pos - 1)
				optionArg := SubStr(args[A_Index], pos + 1)
			} Else {
				option := args[A_Index]		;If no space found, than option is the whole string.
				optionArg := ""
			}

			If (option = "Break") {
				itemOptions .= "+BarBreak"
			}
			If (option = "Menu") {
				itemMenu := ":" optionArg
				itemString := ""	;Menus do not insert their text.  Use 'Next' to chain menus.
			}
			If (option = "Next") {
				itemMenu := optionArg
				itemLabel .= "..."  ;Add ellipsis to show that another menu follows to continue the text.
			}
			If (option = "Label") {
				itemLabel := optionArg		;Set the label to the option argument.
			}
			If (option = "Text") {
				itemString := optionArg		;Set the insert string to the option argument.
			}
			If (option = "Call") {			;Call a label or function.
				itemString := ""
				If (InStr(optionArg, "|") = 0) {
					itemCall := optionArg
				} Else {
					farray := StrSplit(optionArg, "|")
					f := farray.RemoveAt(1)
					itemCall := Func(f).Bind(farray*)
				}
			}

		}

		;Auto-label codes applied here, in case +Label was used.
		itemLabel := StrReplace(itemLabel, "&#", "&" Key)			;Convert auto-number to index value
		itemLabel := StrReplace(itemLabel, "&@", "&" Chr(Key+96))	;Convert auto-letter to index letter
		itemLabel := StrReplace(itemLabel, "&_", "") 	;Remove escaped space characters from the label.
		itemLabel := StrReplace(itemLabel, "&>", "") 	;Remove escaped tab characters from the label.

;		dbgtxt .= ">>" MenuName "|" itemLabel " | " itemString " | " itemMenu " | " itemOptions "|" itemCall "`n"

		If (itemString <> "") {
			; Bind output data to the QuickTextMenuHandler()
			Handler := Func("QuickTextMenuHandler").Bind(itemString, itemMenu)
			Menu, % MenuName, Add, % itemLabel, % Handler, % itemOptions

		} Else If (itemCall <> "") {	;Call existing code label/function
			Menu, % MenuName, Add, % itemLabel, % itemCall, % itemOptions

		} Else {
;			msgbox % MenuName "`n" itemLabel " `n " itemString " `n " itemMenu " `n " itemOptions "`n" itemCall "`n"
			Menu, % MenuName, Add, % itemLabel, % itemMenu, % itemOptions
		}

		itemLabel := ""
		itemString := ""
		itemMenu := ""
		itemOptions := ""
		itemCall := ""
	}

;	msgbox % dbgtxt
}

QuickTextMenuHandler(InsertText, NextMenu) {
	If (InsertText != "") {
		WinWaitNotActive, #32768
		SendInput {Raw}%InsertText%%A_EndChar%
	}
	If (NextMenu != "") {
		WinWaitNotActive, #32768
		Menu, %NextMenu%, Show, %A_CaretX%, %A_CaretY%
	}
}