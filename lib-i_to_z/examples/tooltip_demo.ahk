; #Include tooltip.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; Demo Script by HotKeyIt
;-- Build GUI
gui -MinimizeBox
Gui +LastFound
GuiHwnd:=WinExist()
gui Add,Button,w150 hwndButton1_hWnd gButton1,Test Button 1
Tip:="Button 1: Press me to change my tooltip"
ToolTip(1,Tip,"","A" . Button1_hWnd . " P" . GuiHwnd)

gui Add,Button,y+0 w150 hwndButton2_hWnd gButton2,Test Button 2
Tip:="Button 2: Press me to turn off the tooltip for this button"
ToolTip(2,Tip,"","A" . Button2_hWnd . " P" . GuiHwnd)

gui Add,Button,y+0 w150 hwndButton3_hWnd gButton3,Test Button 3
Tip=
   (ltrim
    A Multiline Test Tooltip
    2nd line
    3rd line
    4th line.
    Press me to turn off all tooltips
   )
ToolTip(3,Tip,"","A" . Button3_hWnd . " P" . GuiHwnd)

gui Add,Checkbox,w150 hwndCheckbox_hWnd,Checkbox Control
Tip:="Tooltip for the Checkbox control"
ToolTip(4,Tip,"","A" . Checkbox_hWnd . " P" . GuiHwnd)

gui Add,Radio,w150 hwndRadio_hWnd,Radio Control
Tip:="Tooltip for the Radio control"
ToolTip(5,Tip,"","A" . Radio_hWnd . " P" . GuiHwnd)

gui Add,Edit,w150 hwndEdit_hWnd,Edit Control
Tip:="Tooltip for the Edit control"
ToolTip(6,Tip,"","A" . Edit_hWnd . " P" . GuiHwnd)

gui Add,Text,w150 hwndText_hWnd gNull,Text Control
Tip=
   (ltrim join`s
    Tooltip for the Text control.`nNote that the Tooltip for a Text control does
    not show unless a g-label for the control is defined.
   )
ToolTip(7,Tip,"","A" . Text_hWnd . " P" . GuiHwnd)

gui Add,Picture,w150 h100 hwndPicture_hWnd gNull,Picture.bmp
Tip=
   (ltrim join`s
    Tooltip for the Picture control.`nNote that the Tooltip for a Picture
    control does not show unless a g-label for the control is defined.   
   )
ToolTip(9,Tip,"","A" . Picture_hWnd . " P" . GuiHwnd)

gui Add,DropDownList,w150 r3 hwndDropDownList_hWnd,DropDownList Control||2|3
Tip:="Tooltip for the DropDownList control"
ToolTip(10,Tip,"","A" . DropDownList_hWnd . " P" . GuiHwnd)

gui Add,ComboBox,w150 r3 hwndComboBox_hWnd,ComboBox Control||2|3
    ;-- A ComboBox is actually two controls:  An Edit control and a Drop-down
    ;   button. Note that handle returned for this control is for the
    ;   drop-down button, not for the Edit control.
Tip=
   (ltrim join`s
    Tooltip for the drop-down button piece of the ComboBox control.`nNote that
    this tip is different than the Edit piece of the control.
   )
ToolTip(11,Tip,"","A" . ComboBox_hWnd . " P" . GuiHwnd)

gui Add,ListBox,w150 r3 hwndListBox_hWnd,ListBox Control||2|3
Tip:="Tooltip for the ListBox control"
ToolTip(12,Tip,"","A" . ListBox_hWnd . " P" . GuiHwnd)

gui Add,ListView,w150 h50 hwndListView_hWnd,ListView Control
Tip=
   (ltrim join`s
    Tooltip for the ListView control.`nNote that this tip is different than
    the header piece of the control.
   )
ToolTip(13,Tip,"","A" . ListView_hWnd . " P" . GuiHwnd)

gui Add,DateTime,w150 hwndDateTime_hWnd  ;,DateTime Control
Tip:="Tooltip for the DateTime control"
ToolTip(14,Tip,"","A" . DateTime_hWnd . " P" . GuiHwnd)

gui Add, UpDown, hwndUpDown_hWnd Range 1-100, 5
Tip:="Tooltip for the UpDown control"
ToolTip(20,Tip,"","A" . UpDown_hWnd . " P" . GuiHwnd)

gui Show,,Tooltip Test

;-- Note: The following information cannot be collected until after the window
;   has been rendered

;-- Get hWnd to the Edit control piece of the ComboBox
ControlGet EditComboBox_hWnd,hWnd,,Edit2,Tooltip Test
Tip=
   (ltrim join`s
    Tooltip for the Edit piece of the ComboBox control.`nNote that this tip is
    different than the drop-down button piece of this control.
   )
ToolTip(11,Tip,"","A" . EditComboBox_hWnd . " P" . GuiHwnd)

;-- Get hWnd to the Edit control piece of the ComboBox
ControlGet ListViewHeader_hWnd,hWnd,,SysHeader321,Tooltip Test
Tip=
   (ltrim join`s
    Tooltip for the header of the ListView control.`nNote that this tip is
    different than the rest of the ListView control.
   )
ToolTip(13,Tip,"","A" . ListViewHeader_hWnd . " P" . GuiHwnd)
return

Button1:
ToolTip(1,"Button 1: New Text","","AButton1 P" . GuiHwnd)
return

Button2:
ToolTip(2)
return

Button3:
ToolTip()
MsgBox 64,ToolTips Cleared,All Tooltips destroyed.  %A_Space%
return

Null:
return

GUIClose:
GUIescape:
Gui,Destroy
ExitApp
Return