# DPI() - function for writing friendlier DPI-Aware AutoHotkey GUIs

DPI() can help you quickly transform your current GUI code to make it (more) DPI-Aware making your UI looks consistent
across a wide variety of DPI display settings. It hopefully avoids "illegible" text or buttons.  
It can either return the scaling factor **or** calculate position/values for AHK controls (font size, position (x y), width, height).

AutoHotkey forum: https://autohotkey.com/boards/viewtopic.php?f=6&t=37913

Preview - screenshots at 144 DPI (150%) before and after using DPI(): 
![before and after](https://raw.githubusercontent.com/hi5/_resources/master/before-after-dpi.png "before - after")

## DPI and the Desktop Scaling Factor

*  96 DPI = 100% scaling
* 120 DPI = 125% scaling
* 144 DPI = 150% scaling
* 192 DPI = 200% scaling

Source and more info at https://msdn.microsoft.com/en-us/library/windows/desktop/dn469266(v=vs.85).aspx

## Parameters

### *DPI([in,setdpi])*

__in__

> When empty it returns the scaling factor. Otherwise it will parse the options
> and update the numeric values based on the scaling factor.  
> Example: "w100", scaling is 125% -> 100 * 1.25 = 100 -> the returned string is "w125"

__setdpi__

> For testing purposes you can set the DPI value to use.  
> Example: If your current DPI is 120 (125%) and you would like to test 150% scaling
> use ```dpi(,144)```.  
> If you want to (temporarily) disable dpi() use ```dpi(,96)```.   
> (see "DPI and the Desktop Scaling Factor" above)

## Notes

* Although DPI scaling is enabled by default - see https://autohotkey.com/docs/commands/Gui.htm#DPIScale - and it scales properly, the end result can still be "too small" to be friendly to use, hence DPI().
* Tip: Define a font size for all your GUIs, that way you can easily use DPI() to also scale the font size. See GuiDefaultFont() code below by SKAN on how to obtain the current default font/fontsize.
* DPI() will use the DPI setting reported by the system in use for the primary screen. If you have a multimonitor setup with different settings for each monitor it may not work correctly.

## Code Examples

### Example 1

Get the scaling factor like so:

```autohotkey
factor:=dpi() ; will be 1.250000 at 120 DPI
```

### Example 2

If this is your current GUI code:

```autohotkey
Gui, Font, s10
Gui, Add, Text, x5 y5, Hello
Gui, Add, Edit, xp yp+20 w200 h100 vVar, Goodbye
Gui, Add, Button, xp yp+110 w100 gMyLabel, OK
Gui, Add, Button, xp+110 yp w50 gGuiClose, Cancel
Gui, Show, w220 h200, DPI() test GUI
Return

MyLabel:
Gui, Submit, Destroy
MsgBox % var
Gosub, GuiClose
Return

Esc::
GuiClose:
ExitApp
```

You can simply call the **dpi()** function by wrapping it arround the Gui command options like so:

```autohotkey
Gui, Font, % dpi("s10")
Gui, Add, Text, % dpi("x5 y5"), Hello
Gui, Add, Edit, % dpi("xp yp+20 w200 h100 vVar"), Goodbye
Gui, Add, Button, % dpi("xp yp+110 w100 gMyLabel"), OK
Gui, Add, Button, % dpi("xp+110 yp w50 gGuiClose"), Cancel
Gui, Show, % dpi("w220 h200"), DPI() test GUI
Return
```

### Example 3

Various examples on how to call dpi()

```autohotkey

Gui, Add, GroupBox, % dpi("x16 y7 w540 h45") , GroupboxTitle

Gui, Add, Text,     % dpi("x25 y25 w300 h20") , Text

Gui, Add, Edit,     % dpi("x25 yp-5 w300 h20 Number vVar"), EditText

SelectMenuPos:=2
Gui, Add, DropDownList, % dpi("xp yp+10 w200 h25 r4 Choose" SelectMenuPos) " vVar", 1 - Option|2 - Option|3 - Option
; Choose + the SelectMenuPos selects "2 - Option" in the DropDownList

Check:=1
Gui, Add, Checkbox, % dpi("x25 yp+20 w200 h16 Checked" Check " vVar"), Option
; Checked + the Check variable ticks the checkbox
```

### GuiDefaultFont

Code by SKAN, cleaned up formatting errors from old forum post (simply removed BB color code tags):

```autohotkey
A_GuiFont     := GuiDefaultFont()
A_GuiFontSize := A_LastError

GuiDefaultFont() {        ; By SKAN www.autohotkey.com/forum/viewtopic.php?p=465438#465438
 hFont := DllCall( "GetStockObject", UInt,17 ) ; DEFAULT_GUI_FONT
 VarSetCapacity( LF, szLF := 60*( A_IsUnicode ? 2:1 ) )
 DllCall("GetObject", UInt,hFont, Int,szLF, UInt,&LF )
 hDC := DllCall( "GetDC", UInt,hwnd ), DPI := DllCall( "GetDeviceCaps", UInt,hDC, Int,90 )
 DllCall( "ReleaseDC", Int,0, UInt,hDC ), S := Round( ( -NumGet( LF,0,"Int" )*72 ) / DPI )
Return DllCall( "MulDiv",Int,&LF+28, Int,1,Int,1, Str ), DllCall( "SetLastError", UInt,S )
}
```
