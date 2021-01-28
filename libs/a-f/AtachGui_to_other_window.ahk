; e.g. run an internet explorer window and go to the page: "about:blank" so that is the start of the title text
;   then run this script and it adds a gui window onto the internet explorer window.
; Some programs, such as notepad and calculator, don't seem to work properly with this technique.


;or to use the window id of the parent instead of the title:
Set_Parent_by_id(Window_ID, Gui_Number) ; title text is the start of the title of the window, gui number is e.g. 99
{
  Gui, %Gui_Number%: +LastFound
  Return DllCall("SetParent", "uint", WinExist(), "uint", Window_ID) ; success = handle to previous parent, failure =null
}

Set_Parent_by_title(Window_Title_Text, Gui_Number) ; title text is the start of the title of the window, gui number is e.g. 99
{
  WinGetTitle, Window_Title_Text_Complete, %Window_Title_Text%
  Parent_Handle := DllCall( "FindWindowEx", "uint",0, "uint",0, "uint",0, "str", Window_Title_Text_Complete)
  Gui, %Gui_Number%: +LastFound
  Return DllCall( "SetParent", "uint", WinExist(), "uint", Parent_Handle ) ; success = handle to previous parent, failure =null
}

 ;or to use the class instead of the title:
Set_Parent_by_class(Window_Class, Gui_Number) ; class e.g. Shell_TrayWnd, gui number is e.g. 99
{
  Parent_Handle := DllCall( "FindWindowEx", "uint",0, "uint",0, "str", Window_Class, "uint",0)
  Gui, %Gui_Number%: +LastFound
  Return DllCall( "SetParent", "uint", WinExist(), "uint", Parent_Handle ) ; success = handle to previous parent, failure =null
}

; Note that a toolbar title can be hidden by right-clicking & un-locking the Taskbar and then properties of the toolbar.
Set_Parent_to_Toolbar(ToolbarName, Gui_Number) ; title text is the start of the title of the window, gui number is e.g. 99
{
  hw_tray:=FindToolbar(ToolbarName)
  If ! hw_tray
    {
    Msgbox, Toolbar "%ToolbarName%" not found! Exiting.
    Exitapp
    }
  Gui, %Gui_Number%: +LastFound
  Return DllCall("SetParent", "uint", WinExist(), "uint", hw_tray) ; success = handle to previous parent, failure =null
}

FindToolbar(ToolbarName)
{
  WinExist("ahk_class Shell_TrayWnd") ; Find Systemtray
  WinGet, Controls ,ControlList ;Get list of all controls
  Loop, Parse, Controls, `n
  {
    ControlGetText, CurControl , %A_LoopField%
    if CurControl=%ToolbarName% ;Find the toolbar we want by comparing controls Text
       ControlGet, hwnd, Hwnd,,%A_LoopField% ;Get the handle for the toolbar
  }
  Return hwnd
}


/*
Example
Gui, 7: Margin, 0, 0
Gui, 7: -Caption +ToolWindow  ; no title, no taskbar icon
Gui, 7: Add, Text,, BAR TEXT HERE!

Set_Parent_to_Toolbar("Quick Launch", 7) ; (Toolbar title (name) to attach to, gui number)

Gui, 7: Show, x0 y4
Return
*/

/*
Example1:
Gui, 7: Margin, 0, 0
Gui, 7: +ToolWindow ; -Caption ; no title, no taskbar icon
Gui, 7: Add, Text,, This gui is stuck to the parent... `nbut I haven't programmed it to do anything `;-)
Set_Parent_by_class("Progman", 7)
Gui, 7: Show, x200 y200
Return

Set_Parent_by_class(Window_Class, Gui_Number) ; class e.g. Shell_TrayWnd, gui number is e.g. 99
{
  Parent_Handle := DllCall( "FindWindowEx", "uint",0, "uint",0, "str", Window_Class, "uint",0)
  Gui, %Gui_Number%: +LastFound
  Return DllCall( "SetParent", "uint", WinExist(), "uint", Parent_Handle )
}

-------------------------------------------------------------------

Gui, add, text, x-10 y-10, ; need something in the parent window to enable minimizing
Gui, +lastfound
Gui_1_ID := WinExist()

Gui, Show, h140 w200, Parent
Set_Parent_by_id(Gui_1_ID, 2) ; Window_ID, Gui_Number
Gui, 2: Show, x5 y5 h80 w150, Child
Return

Set_Parent_by_id(Window_ID, Gui_Number) ; title text is the start of the title of the window, gui number is e.g. 99
{
  Gui, %Gui_Number%: +LastFound
  Return DllCall("SetParent", "uint", WinExist(), "uint", Window_ID) ; success = handle to previous parent, failure =null
}
