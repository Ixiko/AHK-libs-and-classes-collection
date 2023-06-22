;-------------------------------------------------------------------------------
; Custom Msgbox
; Filename: cmsgbox.ahk
; Author  : Danny Ben Shitrit (aka Icarus)
;-------------------------------------------------------------------------------
; Copy this script or include it in your script (without the tester on top).
;
; Usage:
;   Answer := CMsgBox( title, text, buttons, icon="", owner=0 )
;   Where:
;     title   = The title of the message box.
;     text    = The text to display.
;     buttons = Pipe-separated list of buttons. Putting an asterisk in front of
;               a button will make it the default.
;     icon    = If blank, we will use an info icon.
;               If a number, we will take this icon from Shell32.dll
;               If a letter ("I", "E" or "Q") we will use some predefined icons
;               from Shell32.dll (Info, Error or Question).
;     owner   = If 0, this will be a standalone dialog. If you want this dialog
;               to be owned by another GUI, place its number here.
;
;-------------------------------------------------------------------------------
;~ /*

  ; --- TESTER BEGIN - comment out the entire section when including -------------
  #SingleInstance Force

  ; • Simple example
    Pressed := CMsgbox( "Hello World", "Are you sure you want to say hello to the world?`n`nWarning! This operation is irreversible.", "&Yes|*Not &Sure|&Not at All|&HELP!", "280" )
    Msgbox 32,,"%pressed%" was pressed

  ; • Custom icon
    Pressed := CMsgbox( "Where Is It?", "Do you want to find the holy grail?`n`n(Custom icons from Shell32.dll)", "*&Yes Please|&Not Today|Not &Ever", "280" )
    Msgbox 32,,"%pressed%" was pressed

  ; • Example for msgbox that is owned by our own GUI
    Gui Add, Text  ,w200, This is my GUI and I'll cry if I want to.
    Gui Add, Button,wp  , Cry
    Gui Show, x200 y200
    Pressed := CMsgbox( "Owned", "I am owned by GUI 1", "*&Ok|&Whatever","",1 )
    Msgbox 32,,"%pressed%" was pressed
    Return
  ; --- TESTER END ---------------------------------------------------------------

;~ */


CMsgBox(title, text, buttons, w="", h="", bsep=3, icon="", icon_h=64, owner=0, rows=8 ) {

  Global _CMsg_Result

  GuiID := 9      ; If you change, also change the subroutines below

  Button := StrSplit(buttons, "|")

  If( owner <> 0 ) {
    Gui % owner ":+Disabled"
    Gui % GuiID ":+Owner" owner
  }

  Gui % GuiID ":+Toolwindow +AlwaysOnTop"

	IF InStr(icon, exe)	{
		Gui % GuiID ":Add", Picture, % "h" icon_h " w-1", % icon
	}
	else	{
		MyIcon := (icon="I" || icon="") ? 222 : icon = "Q" ? 24 : icon = "E" ? 110 : icon
		Gui % GuiID ":Add", Picture, % "Icon" MyIcon , Shell32.dll
	}

	w_text      	:= (w ? round(.50*w) : round(.50*200))
	w         	:= w="" ? 200 : w
	h      	:= h="" ? 200 : h


  Gui % GuiID ":Add", Text, % "x+12 yp w" w_text " r" rows " section" , % text

  Loop % Button.Count()
    Gui % GuiID ":Add", Button, % ( A_Index=1 ? "x+12 ys+10" : "xp y+" bsep) . ( InStr(Button[A_Index], "*") ? "Default " : " " ) . "w100 gCMsgButton", % RegExReplace(Button[A_Index], "\*")

  Gui % GuiID ":Show", % "w" w " h" h ,% title

  ;GuiControl, Move, %GuiID%, w200 h200

  Loop
    If _CMsg_Result
      Break

  If owner
    Gui % owner ":-Disabled"

  Gui % GuiID ":Destroy"
  Result := _CMsg_Result
  _CMsg_Result := ""
  Return Result

9GuiEscape:
9GuiClose:
  _CMsg_Result := "Close"
Return

CMsgButton:
  _CMsg_Result := StrReplace(A_GuiControl, "&",, All)
Return

}