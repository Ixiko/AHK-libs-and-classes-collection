/*********************** Custom Message Box ************************************
By r0k. Original idea by Icarus (Danny Ben Shitrit)
Requirements : AHK_L
-------------------------------------------------------------------------------
How to use :
Save this file as fn_CMsgBox.ahk in your user lib (My Documents\Autohotkey\lib) or the main library
(Program Files\Autohotkey\Lib)
In you script, use the following call : Answer := fn_CMsgBox(title, text, [, buttons=OK, options] )
Where :
	Answer	 = A variable to store the answer for later use
	title	 = The title of the message box.
	text     = The text to display.
	[buttons]= Pipe (|) separated list of buttons.
			   Putting an asterisk (*) in front of a button will make it the default.
			   Putting plus sign (+) in front of a button will make it "non-closing".
			   If no buttons are defined, a default OK button will be added.
	[options]= One or more of the following options, separated by commas (order does not matter).
		Own_<gui label>  = Label of the parent GUI
		Icon_<icon name> = Name of the icon to use (Search, Question, Warn, Error, Question2, Info
						   or Security) The name of the icon will also determine the system sound.
						   Default = Info
		Align_V(Vertical)= Buttons will be vertically aligned on the right side of the box rather
						   than on an horizontal line at the bottom.
		Font_<font name> = Font to use in the dialog box (rather than system default font)
		Fontsize_<size>  = Size of the font (rather than system default font size)
		Textarea_<area>  = Size of the text area in the form wXXX hXXX or wXXX rX. If not provided,
						   a default size will be used based on alignment
		Style_<(ex)style>= Add one or more control styles or extanded styles. Put all your styles
						   after the Style_ part with spaces as you would use them on normal GUI
						   call.

When a non closing button is pressed the Message Box won't be terminated and the function will try 
to call an external subroutine whose label matches Ctrl_MsgBox_<button> where <button> is the name 
of the button with whitespace replaced by underscore (_). You need to define this subroutine 
somewhere in your script. This allows eg a custom help button that can be clicked while leaving the
message box open.
*/

fn_CMsgBox(prm_title,prm_text,prm_buttons="*OK",prm_options*) {
  ; Associate message type with dll icon number and system sound number.
	arr_Icon := Object("Search", 23, "Question", 24, "Warn", 78 ,"Error", 110
					 , "Question2", 211, "Info", 222, "Security", 245)
	arr_SSnd := Object("Search", 32, "Question", 32, "Warn", 48 ,"Error", 16
					 , "Question2", 32, "Info", 64, "Security", 48)
					 
	Gui CMsg:+0x80880000 +AlwaysOnTop -Resize -MinimizeBox hwnd__MsgBox
	for option_I, option_V in prm_Options { ; Check the options
		option_sep := InStr(option_V,"_")
		if (SubStr(option_V,1,option_sep) = "Own_") { ; Message Box has an owner
			Gui, % SubStr(option_V, ++option_sep)":+Disabled"
			Gui, % "CMsg:+Owner" SubStr(option_V, ++option_sep)
		}
		if (SubStr(option_V,1,option_sep) = "Icon_") { ; Message Box has specified icon
			prm_icon := SubStr(option_V, ++option_sep)
		}
		if (SubStr(option_V,1,option_sep) = "Align_") { ; Message Box has alignment
			prm_align := SubStr(option_V, ++option_sep)
		}
		if (SubStr(option_V,1,option_sep) = "Font_") { ; Message Box has custom font
			gui, CMsg:font,, % SubStr(option_V, ++option_sep)
		}
		if (SubStr(option_V,1,option_sep) = "Fontsize_") { ; Message Box has custom font size
			gui, CMsg:font, % "s" SubStr(option_V, ++option_sep)
		}
		if (SubStr(option_V,1,option_sep) = "Textarea_") { ; Message Box has custom sized text area
			MsgBoxText := "x+12 yp " SubStr(option_V, ++option_sep)
		}
		if (SubStr(option_V,1,option_sep) = "Style_") { ; Message Box has no sys menu
			gui, % "CMsg:" SubStr(option_V, ++option_sep)
		}
	}

	if !loc_Icon := arr_Icon[(prm_icon)] ; If wrong icon was specified, use default
		loc_Icon := 222
	if !loc_SSnd := arr_SSnd[(prm_icon)] ; Same for sound
		loc_SSnd := 64
	if (prm_align="V"||prm_align="Vertical") { ; set position for buttons depending on alignment
		MsgBoxText ? : MsgBoxText := "x+12 yp w180 r8"
		MsgBoxB1   := "x+5 ys w100"
		MsgBoxB2   := "xp y+5 w100"
	} else {
		MsgBoxText ? : MsgBoxText := "x+12 yp w280 r6"
		MsgBoxB1   := "xs y+5 w100"
		MsgBoxB2   := "x+5 yp w100"
	}
	
	Gui CMsg:Add, Picture, section Icon%loc_Icon% , Shell32.dll
	Gui CMsg:Add, Text, %MsgBoxText% , %prm_text%
 
	Loop, Parse, prm_buttons, | , %A_Space%%A_Tab%
	{
		Gui CMsg:Add, Button
				, % ( A_Index=1 ? MsgBoxB1 : MsgBoxB2 )
				. ( InStr( A_LoopField, "*" ) ? " Default " : " " )
				. ( InStr( A_LoopField, "+" ) ? "gCtrl_CMsg_ButtonNC" : "gCtrl_CMsg_Button" )
				, % RegExReplace( A_LoopField, "\*|\+" )
	}

	Gui CMsg:Show,,%prm_title%
	SoundPlay, *%loc_SSnd%
 
	WinWaitClose, ahk_id %__MsgBox%
 
	If( prm_owner )
		Gui %prm_owner%:-Disabled
	
Return _CMsg_Result

CMsgGuiEscape:
CMsgGuiClose:
  _CMsg_Result := "Close"
  Gui CMsg:Destroy 
Return

Ctrl_CMsg_ButtonNC:
	v_GoTo := "Ctrl_MsgBox_"
	v_GoTo .= RegExReplace(A_GuiControl, "\s", "_")
	if IsLabel(v_Goto)
		Gosub %v_Goto%
return
Ctrl_CMsg_Button:
	StringReplace _CMsg_Result, A_GuiControl, &,, All
	  Gui CMsg:Destroy 
Return
}
