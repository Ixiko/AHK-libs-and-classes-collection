/* Execute (What you want) On (Element) changes.

Introduction:___________________________________________________________________
  These functions are supposed to monitoring specific element until it's changed
  then will go to specified label. advantages of using these functions are vario
  us things can be done in easier way and shorter such as automation for Applica
  tion installation and auto-healing or any other similar automation for games.
  Also killing infinite monitoring loop can be done in one line. especially as i
  t's abstraction for beginners it's intuitive and handy.
  The biggest benefit is these functions are running asynchronously which means
  it will not freeze the caller script's work line while monitoring.
  Moreover plural monitoring processes can be running at the same time.

Installation:___________________________________________________________________
  Put ON.ahk in your Standard Library (AhkPath\lib) folder. then you can call th
  ese functions without #include

Example #1: Basic Usage (Automation of Application Installation)
////////////////////////////////Example begin///////////////////////////////////
  WinTitle = Some Application Install Window
  On_ControlList(Title, "AutoClick") ;if controllist changes go to Label
  Return

  AutoClick:
  Loop, Parse, OnControlList, `n
  {
    ControlGetText, Output, %A_LoopField%, %WinTitle%
    If Output in Next,Install,Confirm ;If Control(button) text is match.
    ControlClick, %A_LoopField%, %WinTitle% ;auto click it
  }
  IfWinNotExist, %WinTitle%
    SetTimer, OnControlList, Off
  On_ControlList(Title, "AutoClick")
  Return

;Note that %OnControlList% variable is passed from the function. some functions
;will have variable with same name (exclude _) so you can call it
/////////////////////////////////Example end////////////////////////////////////


Example #2: If you want to watch infinitely. make self recurrence.
////////////////////////////////Example begin///////////////////////////////////
  On_ActiveWindow("Watch")
  Return

  Watch:
  ToolTip, ActiveWindow has been changed.
  On_ActiveWindow("Watch") ;recurrence
  Return
/////////////////////////////////Example end////////////////////////////////////

Example #3: Killing an infinite monitoring function
////////////////////////////////Example begin///////////////////////////////////
  On_ActiveWindow("Watch")
  Return

  Watch:
  ToolTip, ActiveWindow has been changed.
  On_ActiveWindow("Watch") ;recurrence
  Return

  ESC::SetTimer, OnActiveWindow, Off
;Every Functions have their own Timer with same name (exclude _)
/////////////////////////////////Example end////////////////////////////////////

Example #4: Simple Popup killer using On_WinOpen() with filter list
////////////////////////////////Example begin///////////////////////////////////
  FilterList = /popup,/ads/,/sponsor/,/pagead/,/banner/,etc
  On_WinOpen("ahk_class IEFrame", "Filter")
  Return

  Filter:
  ControlGetText, PopupUrl, Edit1, ahk_class IEFrame ;check url
  if PopupUrl Contains %Filterlist%
    SendMessage,0x111,165,0,,ahk_class IEFrame       ;close
  Return
/////////////////////////////////Example end////////////////////////////////////

Example #5: Two liner Auto-Healing script for online games using On_Pixel()
////////////////////////////////Example begin///////////////////////////////////
  On_Pixel("40", "40", "Heal") ;assuming lowest point of health-bar is x40 y40
  Return

  Heal:
  Send {1}                     ;ingame quickbar for self-heal
  On_Pixel("40", "40", "Heal")
  Return
/////////////////////////////////Example end////////////////////////////////////


Usage:__________________________________________________________________________
  On_ActiveWindow(Label, Interval=200)
  On_ControlList(WinTitle, Label, TitleMatchMode=3, Interval=200)
  On_File(Filename, Label, Interval=1000)
  On_Pixel(X, Y, Label, Method="", Interval=200) ;Method = RGB|Slow|Alt
  On_StatusBar(WinTitle, Label, Part=1, TitleMatchMode=3, Interval=200)
  On_WinTitle(WinTitle, Label, TitleMatchMode=3, Interval=200)
  On_WinPos(WinTitle, Label, TitleMatchMode=3, Interval=200)
  On_WinSize(WinTitle, Label, TitleMatchMode=3, Interval=200)
  On_WinOpen(WinTitle, Label, TitleMatchMode=3, DetectHidden=0, Interval=200)
  On_WinClose(WinTitle, Label, TitleMatchMode=3, DetectHidden=0, Interval=200)

Return:_________________________________________________________________________
  Return of Functions will be empty with successful execution. else if necessary
  parameters is wrong (eg: non exist label) will return 1 rather than interrupt
  the whole runtime

Remarks:________________________________________________________________________
  Since these functions are all SetTimer based. when you meet unexpected circums
  tances such as thread interruption, Check help pages below.

  http://www.autohotkey.com/docs/commands/SetTimer.htm
  http://www.autohotkey.com/docs/commands/Critical.htm
  http://www.autohotkey.com/docs/commands/Thread.htm

  eg) Thread, NoTimers


Pending:
  On_Var
  On_Reg
  On_Memory
  On_Process
  On_Tab
  On_CheckBox

- heresy
*/
Return

;-------------------------------------------------------------------------------
;On Active Window Changes
On_ActiveWindow(Label, Interval=200)
{
  If isLabel(Label)
  {
    WinGetActiveTitle, ActiveWindow
    Global OnActiveWindowSub := Label, OActiveWindow := ActiveWindow
    SetTimer, OnActiveWindow, %Interval%
  }
  Else
    Return 1
}

OnActiveWindow:
WinGetActiveTitle, OnActiveWindow
If OActiveWindow != %OnActiveWindow%
{
  SetTimer, OnActiveWindow, Off
  Gosub, %OnActiveWindowSub%
}
Return
;-------------------------------------------------------------------------------
;On ControlList of an window changes
On_ControlList(WinTitle, Label, TitleMatchMode=3, Interval=200)
{
  SetTitleMatchMode, %TitleMatchMode%
  If WinExist(WinTitle) && IsLabel(Label)
  {
    WinGet, O, ControlList, %WinTitle%
    Global OControlListT := WinTitle, OnControlListSub := Label, OControlList := O
    SetTimer, OnControlList, %Interval%
  }
  Else
    Return 1
}

OnControlList:
WinGet, OnControlList, ControlList, %OControlListT%
If OControlList != %OnControlList%
{
  SetTimer, OnControlList, Off
  Gosub, %OnControlListSub%
}
Return
;-------------------------------------------------------------------------------
;On File Changes (File Delete/Move/Name/Size/Attrib/Time Changes)
On_File(Filename, Label, Interval=1000)
{
  If FileExist(FileName) && IsLabel(Label)
  {
    FileGetSize, Size, %FileName%
    FileGetAttrib, Attrib, %FileName%
    FileGetTime, Time, %Filename%
    Global OFile := FileName, OnFileSub := Label, OFileState:=Size Attrib Time
    SetTimer, OnFile, %Interval%
  }
  Else
    Return 1
}

OnFile:
If OFile
{
  FileGetSize, NFileSize, %OFile%
  FileGetAttrib, NFileAttrib, %OFile%
  FileGetTime, NFileTime, %OFile%
  OnFile := NFileSize NFileAttrib NFileTime
  IF OFileState = %OnFile%
    Return
  Else
  {
    SetTimer, OnFile, Off
    Gosub, %OnFileSub%
    Return
  }
}
Return
;-------------------------------------------------------------------------------
;On Pixel Color Changes
On_Pixel(X, Y, Label, Method="", Interval=200)
{
  If (X>=0 && Y>=0 && IsLabel(Label))
  {
    Method := Method="" ? "RGB" : Method
    CoordMode, Pixel, Screen
    PixelGetColor, Color, %X%, %Y%, %Method%
    Global OnPixelSub := Label, OPixel := Color, PixelX := X, PixelY := Y
    SetTimer, OnPixel, %Interval%
  }
  Else
    Return 1
}

OnPixel:
PixelGetColor, OnPixel, PixelX, PixelY
If OPixel != %OnPixel%
{
  SetTimer, OnPixel, Off
  Gosub, %OnPixelSub%
}
Return
;-------------------------------------------------------------------------------
;On Statusbar Text Changes
On_StatusBar(WinTitle, Label, Part=1, TitleMatchMode=3, Interval=200)
{
  SetTitleMatchMode, %TitleMatchMode%
  If WinExist(WinTitle) && IsLabel(Label)
  {
    StatusBarGetText, Output, %Part%, %WinTitle%
    Global OStatusBarT := WinTitle, OnStatusBarSub := Label
          ,OStatusBarText := Output, OStatusBarPart := Part
    SetTimer, OnStatusBar, %Interval%
  }
  Else
    Return 1
}

OnStatusBar:
StatusBarGetText, OnStatusBar, %OStatusBarPart%, %OStatusBarT%
If OnStatusBar != %OStatusBarText%
{
  SetTimer, OnStatusBar, Off
  Gosub, %OnStatusBarSub%
}
Return
;-------------------------------------------------------------------------------
;On Window Title Changes
On_WinTitle(WinTitle, Label, TitleMatchMode=3, Interval=200)
{
  SetTitleMatchMode, %TitleMatchMode%
  If WinExist(WinTitle) && IsLabel(Label)
  {
    WinGetTitle, WinTitle, %WinTitle%
    Global OWinTitleT := WinTitle, OnWinTitleSub := Label
    SetTimer, OnWinTitle, %Interval%
  }
  Else
    Return 1
}

OnWinTitle:
WinGetTitle, OnWinTitle, %OWinTitleT%
If OnWinTitle != %OWinTitleT%
{
  SetTimer, OnWinTitle, Off
  GoSub, %OnWinTitleSub%
}
Return
;-------------------------------------------------------------------------------
;On Window Position Changes
On_WinPos(WinTitle, Label, TitleMatchMode=3, Interval=200)
{
  SetTitleMatchMode, %TitleMatchMode%
  If WinExist(WinTitle) && IsLabel(Label)
  {
    WinGetPos,X,Y,,,%WinTitle%
    Pos := X Y
    Global OWinPosT := WinTitle, OnWinPosSub := Label, OPos := Pos
    SetTimer, OnWinPos, %Interval%
  }
  Else
    Return 1
}

OnWinPos:
WinGetPos,NX,NY,,,%OWinPosT%
OnWinPos := NX NY
If OPos != %OnWinPos%
{
  SetTimer, OnWinPos, Off
  Gosub, %OnWinPosSub%
}
Return
;-------------------------------------------------------------------------------
;On Window Size Changes
On_WinSize(WinTitle, Label, TitleMatchMode=3, Interval=200)
{
  SetTitleMatchMode, %TitleMatchMode%
  If WinExist(WinTitle) && IsLabel(Label)
  {
    WinGetPos,,,Width,Height,%WinTitle%
    Size := Width Height
    Global OWinSizeT := WinTitle, OnWinSizeSub := Label, OSize := Size
    SetTimer, OnWinSize, %Interval%
  }
  Else
    Return 1
}

OnWinSize:
WinGetPos,,,NWidth,NHeight,%OWinSizeT%
OnWinSize := NWidth NHeight
If OSize != %OnWinSize%
{
  SetTimer, OnWinSize, Off
  Gosub, %OnWinSizeSub%
}
Return
;-------------------------------------------------------------------------------
;On Window Open (actually it's WinExist but still applicable. see Example #4)
On_WinOpen(WinTitle, Label, TitleMatchMode=3, DetectHidden=0, Interval=200)
{
  Switch := DetectHidden=0 ? "Off" : "On"
  DetectHiddenWindows, %Switch%
  SetTitleMatchMode, %TitleMatchMode%
  If IsLabel(Label)
  {
    Global OWinOpenT := WinTitle, OnWinOpenSub := Label
    SetTimer, OnWinOpen, %Interval%
  }
  Else
    Return 1
}

OnWinOpen:
IfWinExist, %OWinOpenT%
{
  SetTimer, OnWinOpen, Off
  Gosub, %OnWinOpenSub%
}
Return
;-------------------------------------------------------------------------------
;On Window Close
On_WinClose(WinTitle, Label, TitleMatchMode=3, DetectHidden=0, Interval=200)
{
  Switch := DetectHidden=0 ? "Off" : "On"
  DetectHiddenWindows, %Switch%
  SetTitleMatchMode, %TitleMatchMode%
  If WinExist(WinTitle) && IsLabel(Label)
  {
    Global OWinClose := WinTitle, OnWinCloseSub := Label
    SetTimer, OnWinClose, %Interval%
  }
  Else
    Return 1
}

OnWinClose:
IfWinNotExist, %OWinClose%
{
  SetTimer, OnWinClose, Off
  GoSub, %OnWinCloseSub%
}
Return