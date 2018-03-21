#SingleInstance Force

#include thirdParty\Functions.ahk
;#include thirdParty\Notify.ahk ;this causes windows to be open forever
#include thirdParty\Cycle.ahk
#include thirdParty\Format4Csv.ahk
#include FcnLib-Rewrites.ahk

;Takes a screenshot and saves it to the specified path
;Useful for debugging macros afterward
;Includes an optional text parameter that will allow you to
;begin the filename with a relevant text description, and
;end it with a timestamp
;TODO adjust image quality ;TODO change image format
/*#include thirdParty\ScreenCapture.ahk
SaveScreenShot(descriptiveText="", directoryPath="dropbox", options="")
{
   captureArea=0
   if InStr(options, "activeWindow")
      captureArea=1

   ; OR directoryPath="")
   if (directoryPath="dropbox")
      directoryPath=C:\Dropbox\AHKs\gitExempt\screenshots\%A_ComputerName%
   else if (directoryPath="local")
      directoryPath=C:\DataExchange\PrintScreen

   FileCreateDir, %directoryPath%
   FormatTime FileNameText,, yyyyMMddHHmmss
   fullfilename = %directoryPath%\%descriptiveText%%FileNameText%.bmp
   CaptureScreen(captureArea,true,fullfilename)
}
*/
;Sleeps for a specified number of minutes
SleepMinutes(minutes)
{
   SleepSeconds(minutes*60)
}

;Sleeps for a specified number of seconds
SleepSeconds(seconds)
{
   Sleep 1000*seconds
}

;Determines whether or not we should show debug msgs
;TODO add a logging mode?
;not yet finished, just throwing around some ideas
;OptionalDebug(options="", millionParams="...really, lots of params, like 15..")
OptionalDebug(textOrOptions="Hello World!", text1="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text2="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text3="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text4="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text5="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text6="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text7="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text8="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text9="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text10="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text11="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text12="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text13="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text14="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text15="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ")
{
   global A_Debug
   global A_Log
   if ( InStr(options, "Debug") || A_Debug )
      debug(textOrOptions, text1, text2, text3, text4, text5, text6, text7, text8, text9, text10, text11, text12, text13, text14, text15)
   if ( InStr(options, "Log") || A_Log )
      delog(textOrOptions, text1, text2, text3, text4, text5, text6, text7, text8, text9, text10, text11, text12, text13, text14, text15)
}

CustomTitleMatchMode(options="")
{
   ;By default this uses RegEx and Fast (no hidden window text detected)
   if (InStr(options, "Start"))
      SetTitleMatchMode, 1
   else if (InStr(options, "Contain") || InStr(options, "Anywhere"))
      SetTitleMatchMode, 2
   else if (InStr(options, "Exact"))
      SetTitleMatchMode, 3
   else if (InStr(options, "RegEx"))
      SetTitleMatchMode, RegEx
   else if (InStr(options, "Default"))
   {
      SetTitleMatchMode, 2
      ;SetTitleMatchMode, Fast
   }
   else
      SetTitleMatchMode, RegEx

   ;FIXME haxor... wrong method (will cause side effects)
   ;SendMode, Event
}

ForceWinFocus(titleofwin, options="")
{
   returned:=false
   CustomTitleMatchMode(options)

   OptionalDebug(options, titleofwin)

   Loop
   {
      WinWait, %titleofwin%, , 1
      IfWinNotActive, %titleofwin%,
         WinActivate, %titleofwin%,
      WinWaitActive, %titleofwin%, , 1
      IfWinActive, %titleofwin%,
      {
         returned:=true
         break
      }
   }

   CustomTitleMatchMode("Default")

   return returned
}

;NOTE this is not the same because it checks if the window already exists first
;  rather than just waiting forever for the window
;TODO probably should merge these two methods (with an ifexist option)
;or we could have a timeout option that waits for the specified
;number of seconds and then just returns false
ForceWinFocusIfExist(titleofwin, options="")
{
   returned:=false
   CustomTitleMatchMode(options)

   OptionalDebug(options, titleofwin)

   IfWinExist, %titleofwin%,
   {
      WinWait, %titleofwin%,
      IfWinNotActive, %titleofwin%,
      WinActivate, %titleofwin%,
      WinWaitActive, %titleofwin%,
      returned:=true
   }

   CustomTitleMatchMode("Default")

   return returned
}

;TODO not sure if the return values here are good or if they suck!
;Closes the window if it exists, then returns true if it actually did exist in the first place
CloseWin(titleofwin, options="")
{
   CustomTitleMatchMode(options)

   OptionalDebug(options, titleofwin)

   IfWinExist, %titleofwin%,
   {
      WinClose, %titleofwin%,
      returned:=true
   }

   CustomTitleMatchMode("Default")

   return returned
}

;TESTME
SendViaClipboard(text)
{
   Sleep 100

   ;Save previous clipboard item
   ClipSaved := ClipboardAll

   Sleep 100

   ;Put item on the clipboard
   Clipboard := text

   ;May need to wait for a while
   ClipWait, 1

   MaxTimeToWait:=CurrentTimePlus(1)
   while (!CurrentlyAfter(MaxTimeToWait))
   {
      if (text==Clipboard)
         break
      if (text==ClipboardAll)
         break
      Sleep 50
   }

   Sleep 100

   ;Paste
   Send, ^v

   Sleep 100

   ;Restore clipboard contents, clear memory for storage variable
   Clipboard := ClipSaved
   ClipSaved=

   Sleep 100
}

;If you see the image, move the mouse there
MouseMoveIfImageSearch(filename)
{
   if NOT FileExist(filename)
   {
      errord(A_ThisFunc, filename, "the aforementioned file does not exist")
      return false
   }

   WinGetPos, no, no, winWidth, winHeight
   ImageSearch, xvar, yvar, 0, 0, winWidth, winHeight, %filename%

   MouseMove, xvar, yvar

   return NOT ErrorLevel
}

;If you see the image, click it
ClickIfImageSearch(filename, clickOptions="left Mouse")
{
   ;TODO make this look a little more like:
   ;if NOT VerifyFileExist(A_ThisFunc, filename)
      ;return false
   ;if ErrordIfFileNotExist(A_ThisFunc, filename)
      ;return false

   if NOT FileExist(filename)
   {
      errord(A_ThisFunc, filename, "the aforementioned file does not exist")
      return false
   }

   WinGetPos, no, no, winWidth, winHeight
   ImageSearch, xvar, yvar, 0, 0, winWidth, winHeight, %filename%

   if NOT ErrorLevel
      Click(xvar, yvar, clickOptions)

   return NOT ErrorLevel
}

;Wait until a certain image appears
WaitForImageSearch(filename, variation=0, timeToWait=20, sleepTime=20) ;TODO option to exit ahk if image was not found
{
   if NOT FileExist(filename)
   {
      errord(A_ThisFunc, filename, "the aforementioned file does not exist")
      return false
   }

   TimeToStop:=CurrentTimePlus(timeToWait)
   while (CurrentlyBefore(TimeToStop))
   {
      WinGetPos, no, no, winWidth, winHeight
      ImageSearch, no, no, 0, 0, winWidth, winHeight, *%variation% %filename%

      if NOT ErrorLevel
         return true

      Sleep, sleepTime
   }

   return false
}

IsRegExMatch(Haystack, Needle)
{
   return RegExMatch(Haystack, Needle)<>""
}

Remap(input, remap1, replace1, remap2=0, replace2=0, remap3=0, replace3=0, remap4=0, replace4=0, remap5=0, replace5=0, remap6=0, replace6=0)
{
   if input=remap1
      return %replace1%
   if input=remap2
      return %replace2%
   if input=remap3
      return %replace3%
   if input=remap4
      return %replace4%
   if input=remap5
      return %replace5%
   if input=remap6
      return %replace6%
   return input
}

;I now think that moving to 0,0 is a better solution
MoveToRandomSpotInWindow()
{
   WinGetPos, no, no, winWidth, winHeight
   Random, xCoordinate, 0, winWidth
   Random, yCoordinate, 0, winHeight
   MouseMove, xCoordinate, yCoordinate
}

WeightedRandom(OddsOfa1, OddsOfa2, OddsOfa3=0, OddsOfa4=0, OddsOfa5=0)
{
   Random, input, 1, 100
   ;debug(input)
   OddsOfa2+=OddsOfa1
   OddsOfa3+=OddsOfa2
   OddsOfa4+=OddsOfa3
   OddsOfa5+=OddsOfa4
   if % input<=OddsOfa1
      return 1
   if % input<=OddsOfa2
      return 2
   if % input<=OddsOfa3
      return 3
   if % input<=OddsOfa4
      return 4
   if % input<=OddsOfa5
      return 5
   return 6
}

;TODO need to expand this so that it is called for each argument (warnings for true, false, 0, 1, or null string)
;Shows a debug message for a bool ("true" or "false")
DebugBool(bool)
{
   ;possible msgs:
   ;WARNING: This variable may be equal to false, 0, or may be undefined or empty
   ;WARNING: This variable may be equal to true or 1
   if (bool==1)
      msg:="This variable may be true or 1"
   else if (bool==0)
      msg:="This variable may be false or 0"
   else if (bool=="")
      msg:="This variable may be undef or an empty string"
   else
      msg:=bool
   ;Debug(msg) ;this must go before we put it into debug (endless recursion?)
   return msg
}

;TODO maybe get rid of this in favor of debugbool
;Change a boolean to a string (more readable)
BoolToString(bool)
{
   if (bool)
      return "true"
   else
      return "false"
}

;TODO write
;Returns true if color1 is darker than color2
ColorIsDarkerThan(color1, color2)
{
;split into rgb numbers
;add rgb
;determine difference
}

;TODO write
;Continuously checks a pixel's color until it stabilizes at a certain color
;returns the color that it is holding at
WaitUntilColorStopsChanging(x, y)
{
   PixelGetColor, lastColor, x, y
   while lastColor<>currentColor
   {
      PixelGetColor, currentColor, x, y
      Sleep, 50
   }
   return currentColor
}

;TODO write
;Keeps clicking a spot until it is as dark/as light as possible
;(for selecting/deselecting a checkbox)
ForcePixelColorChangeByClicking(x, y, lightestOrDarkest, checkboxStates=2)
{
;MouseMove x, y
;current=WaitUntilColorStopsChanging(x, y)
;max=current
;Loop % checkboxStates
;{
;current=WaitUntilColorStopsChanging(x, y)
;if ColorIsDarkerThan(current, max)
;   max=current
;}
;while ColorIsDarkerThan(current, max)
;{
;
;current=WaitUntilColorStopsChanging(x, y)
;}
}

;TODO write
;Clicks at a specified location with ControlClick, MouseClick or Click
Click(xCoord, yCoord, options="Left Mouse")
{
   if (InStr(options, "Standard"))
   {
      if (InStr(options, "Right"))
         Click, right, %xCoord%, %yCoord%
      else
         Click, left, %xCoord%, %yCoord%
   }
   else if (InStr(options, "Mouse"))
   {
      if (InStr(options, "Right"))
         MouseClick, right, %xCoord%, %yCoord%
      else
         MouseClick, left, %xCoord%, %yCoord%
   }
   else if (InStr(options, "Control"))
   {
      if (InStr(options, "Right"))
      {
         debug("r c")
         ControlClick, x%xCoord% y%yCoord%, , , RIGHT
      }
      else
         ControlClick, x%xCoord% y%yCoord%, , , LEFT
   }
   else
   {
      if (InStr(options, "Right"))
         Click, right, %xCoord%, %yCoord%
      else
         Click, left, %xCoord%, %yCoord%
   }
}

;TODO write
;Closes a window as gracefully as possible
CloseWindowGracefully(title, text="", xClickToClose="", yClickToClose="")
{
;Check if winexist each time (then return)

}

;TODO enable slashes or colons?
;Gets the current time (unique, increasing)
; pass in a FormatTime-style string to customize your format
; or use one of the custom styles already thought up like hyphendate and slashdate
CurrentTime(options="")
{
;use flags
;   date time datetime
;   separator
;   ordering? YYYYMMDD or MMDDYYYY
   if InStr(options, "hyphen")
      hyphen:=true
   if InStr(options, "slash")
      slash:=true
   if InStr(options, "colons")
      colon:=true
   if InStr(options, "date")
      date:=true
   if InStr(options, "time")
      time:=true
   if InStr(options, "zeropad")
      zeropad:=true
   if InStr(options, "year")
      month:=true
   if InStr(options, "month")
      time:=true

   if InStr(options, "slashdate")
      FormatTime, returned,, MM/dd/yyyy
   else if InStr(options, "hyphenated")
      FormatTime, returned,, yyyy-MM-dd_HH-mm-ss
   else if InStr(options, "hyphendate")
      FormatTime, returned,, yyyy-MM-dd
   else if InStr(options, "month")
      FormatTime, returned,, MM
   else if InStr(options, "year")
      FormatTime, returned,, yyyy
   else if options
      FormatTime, returned,, %options%
   else
      FormatTime, returned,, yyyyMMddHHmmss

   ;got forced into using this
   return returned
}

;FIXME does not account for 60-99 seconds, etc...
;Gets the current time so that later a time comparison is possible
CurrentTimePlus(seconds)
{
   return CurrentTime() + seconds
}

;WRITEME TESTME
TimePlus(one, two)
{
   returned:=0
   returned+=Mod(one, 100) + Mod(two, 100)
   ;one/=100
   ;two/=100
   returned+=one
   return returned
}

;Checks if the current time is before the time that is passed in
CurrentlyBefore(time)
{
   ;remove hyphens for flexibility
   time:=StringReplace(time, "-")
   return CurrentTime() < time
}

;Checks if the current time is after the time that is passed in
CurrentlyAfter(time)
{
   ;remove hyphens for flexibility
   time:=StringReplace(time, "-")
   return CurrentTime() > time

;i.e.:
;Debug("starting timer")
;TimeToStop:=CurrentTimePlus(2)
;while true
;{
;   sleep 100 ; CheckSomeFooBar()...
;
;   if (CurrentlyAfter(TimeToStop))
;      break
;}
;Debug(TimeToStop)

}

;Starts a timer--to be used in conjunction with ElapsedTime()
StartTimer()
{
   return A_TickCount
}

;TODO rename to StopTimer?
;Provides the elapsed time since StartTimer() was called
ElapsedTime(StartTime)
{
   if (StartTime = "")
      Errord("You didn't pass a valid StartTime in to the ElapsedTime() function.", "Be sure to use StartTimer() to get the start time.")
   returned := A_TickCount - StartTime
   return returned
}

;TODO write
;Formats a millisec-time into something a bit more pretty
PrettyTime(TimeToFormat)
{

}

;Determines if the specified window is minimized
IsMinimized(title="", text="")
{
   SetTitleMatchMode, RegEx
   WinGet, winstate, MinMax, %title%, %text%
   IfWinExist, %title%, %text%
   {
      if (winstate=-1)
         return true
   }
   return false
}

;Determines if the specified window is minimized
IsMaximized(title="", text="")
{
   SetTitleMatchMode, RegEx
   WinGet, winstate, MinMax, %title%, %text%
   IfWinExist, %title%, %text%
   {
      if (winstate=1)
         return true
   }
   return false
}

;Closes open applications that usually are difficult for windows to shut down (preps for a restart)
CloseDifficultApps()
{
   ProcessClose("hpupdate.exe")
   ProcessClose("DesktopWeather.exe")

   if ForceWinFocusIfExist("Irssi ahk_class PuTTY")
      Send, /quit Ragequit{ENTER}

   if ForceWinFocusIfExist("ahk_class VMPlayerFrame")
   {
      Sleep, 500
      ForceWinFocus("ahk_class VMPlayerFrame")
      Send, {ALT}fx
   }

   while true
   {
      IfWinNotExist ahk_class MozillaUIWindowClass
         break
      WinClose ahk_class MozillaUIWindowClass
   }

   while true
   {
      IfWinNotExist, Microsoft SQL Server Management Studio ahk_class wndclass_desked_gsk
         break
      WinClose, Microsoft SQL Server Management Studio ahk_class wndclass_desked_gsk
      WinWait, Microsoft SQL Server Management Studio ahk_class #32770, Save changes to the following items?, 5
      WinActivate, Microsoft SQL Server Management Studio ahk_class #32770, Save changes to the following items?
      if NOT ErrorLevel
         ControlClick, &No
   }

   while true
   {
      IfWinNotExist, pgAdmin III ahk_class wxWindowClassNR
         break
      WinClose, pgAdmin III ahk_class wxWindowClassNR
      WinWait, Query ahk_class #32770, Do you want to save changes?, 5
      WinActivate, Query ahk_class #32770, Do you want to save changes?
      if NOT ErrorLevel
         ControlClick, &No
   }

   while true
   {
      Process, Exist, chrome.exe
      pid:=ERRORLEVEL
      if NOT pid
         break
      PostMessage,0x111,65405,0,,ahk_pid %pid%
      Process, WaitClose, %pid%, 1

      ;if it exists
      Process, Exist, %pid%
      pid:=ERRORLEVEL
      if pid
      {
         ;debug("closing")
         Process, Close, %pid%
      }
   }
}

CloseDifficultAppsAllScreens()
{
   Loop 5
      Send, {BROWSER_BACK}

   Loop 5
   {
      Sleep, 100
      CloseDifficultApps()
      Send, {BROWSER_FORWARD}
   }

   Process, WaitClose, ssms.exe, 15
   Process, Close, ssms.exe
   Process, WaitClose, vmware-vmx.exe, 15
   Process, Close, vmware-vmx.exe
   Process, WaitClose, vmplayer.exe, 15
   Process, Close, vmplayer.exe
   Process, Close, FindAndRunRobot.exe
   Process, Close, dsidebar.exe
   Process, Close, hpupdate.exe

   ;close the stupid thing that comes with ZoneAlarm
   Process, Close, ForceField.exe
}

;WRITEME
;Gets the parent directory of the specified directory

;WRITEME
;Returns true if the specified path is a directory, false if it is a file

;WRITEME
;Returns true if the specified path is a file, or false if it is a directory

;WRITEME
;Creates the parent dir if necessary
;TODO if path is a directory, this ensures that that dir exists
EnsureDirExists(path)
{
   ;if path is a file, this ensures that the parent dir exists
   dir:=ParentDir(path)
   ;simply: this ensures that the entire specified dir structure exists

   ;figure out if it is a file or dir
   ;split off filename if applicable
   FileCreateDir, %dir%
}

ParentDir(fileOrFolder)
{
   if (StringRight(fileOrFolder, 1) == "\")
      fileOrFolder:= StringTrimRight(fileOrFolder, 1)
   RegexMatch(fileOrFolder, "^.*\\", returned)
   return returned
}

;Returns if the directory exists
DirExist(dirPath)
{
   return InStr(FileExist(dirPath), "D") ? 1 : 0
}

;TODO We should keep an ini of paths found previously, and search for it if not in the ini-list
;TODO Perhaps this should be done with other items, like the windows user folder
;Returns the correct program files location (error message if the file doesn't exist)
ProgramFilesDir(relativePath)
{
   ;ensure that the rel path starts with a slash
   if NOT SubStr(relativePath, 1, 1)="\"
      relativePath=\%relativePath%

   ;test the standard dir
   baseDir:="C:\Program Files"
   stdPath=%baseDir%%relativePath%
   if (FileExist(stdPath))
      return stdPath

   ;test the x86 dir
   x86:=" (x86)"
   x86Path=%baseDir%%x86%%relativePath%
   if (FileExist(x86Path))
      return x86Path

   Errord(A_ThisFunc, "was not able to find 'relativePath':", relativePath)
}

;Debug vs Errord: Silent/Traytip/Msgbox/Overlay, Logged/Not, Info/Warning/Error
;
;Send an error message with as many parameters as necessary, save debug information to dropbox logs section
debug(textOrOptions="Hello World!", text1="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text2="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text3="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text4="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text5="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text6="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text7="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text8="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text9="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text10="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text11="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text12="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text13="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text14="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text15="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ")
{
   loggedMode:=false
   silentMode:=false
   trayMsgMode:=false
   errordMode:=false
   displayTime=2
   if (InStr(textOrOptions, "trayMsg"))
      trayMsgMode := true
   if (InStr(textOrOptions, "silent"))
      silentMode := true
   if (InStr(textOrOptions, "log"))
      loggedMode := true
   if (InStr(textOrOptions, "nolog"))
      loggedMode := false
   if (InStr(textOrOptions, "errord"))
   {
      errordMode := true
      displayTime = 20
   }
   ;TODO screenshot mode for debug() fcn
   ;if (InStr(textOrOptions, "screenshot"))
   ;{
      ;savescreenshot()
      ;append filename to the end of the debug message
   ;}
   ;TODO email/text error mode for debug() fcn

   ;put together the message
   if (errordMode)
      messageTitle:="ERROR: "
   else
      messageTitle:="Debug: "
   messageTitle.=CurrentTime("hyphenated")
   messageTitle.=A_Space
   messageTitle.=A_ScriptFullPath

   messageText:="`n   " . textOrOptions
   loop 15
   {
      ;TODO make that true,false,undef helper function for helpful debug suggestions
      ;TODO if the one before has a colon at the end, then just add a space instead of a newline
      if (text%A_Index% == "ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ")
         break
      messageText.="`n   " . DebugBool( text%A_Index% )
   }
   messageText.="`n`n"

   ;log the message right away
   if loggedMode
   {
      logPath=C:\My Dropbox\Public\logs
      FileCreateDir, %logPath%
      FileAppend, %messageTitle% %messageText%, %logPath%\%A_ComputerName%.txt
   }

   ;display info to the user
   if NOT silentMode
   {
      if trayMsgMode
      {
         if (errordMode)
            TrayMsg("AHK Error", messageText, 20, 3)
         else
            TrayMsg("AHK Debug", messageText, 20, 3)
      }
      else if overlayMode
         msgbox, , %messageTitle%, %messageText%, %displayTime%
      else
         msgbox, , %messageTitle%, %messageText%, %displayTime%
   }

   return textOrOptions
}

errord(textOrOptions="Hello World!", text1="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text2="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text3="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text4="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text5="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text6="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text7="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text8="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text9="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text10="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text11="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text12="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text13="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text14="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text15="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ")
{
   textOrOptions=LOG ERRORD %textOrOptions%
   debug(textOrOptions, text1, text2, text3, text4, text5, text6, text7, text8, text9, text10, text11, text12, text13, text14, text15)
   return textOrOptions
}

fatalErrord(textOrOptions="Hello World!", text1="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text2="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text3="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text4="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text5="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text6="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text7="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text8="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text9="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text10="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text11="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text12="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text13="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text14="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text15="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ")
{
   textOrOptions=FATAL %textOrOptions%
   errord(textOrOptions, text1, text2, text3, text4, text5, text6, text7, text8, text9, text10, text11, text12, text13, text14, text15)
   ExitApp
}

delog(textOrOptions="Hello World!", text1="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text2="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text3="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text4="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text5="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text6="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text7="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text8="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text9="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text10="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text11="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text12="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text13="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text14="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text15="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ")
{
   textOrOptions=SILENT LOG %textOrOptions%
   debug(textOrOptions, text1, text2, text3, text4, text5, text6, text7, text8, text9, text10, text11, text12, text13, text14, text15)
   return textOrOptions
}

SelfDestruct()
{
   filename=SelfDestruct.ahk
   ;TODO TESTME filename=%A_ScriptFullPath%
   FileDelete, %filename%
   ;TODO the self destruct macro could have a loop and check if the file exists (pointless?) -- later thought: actually, that will go into FileAppend()
   FileAppend, Sleep 100`nFileDelete`, %A_ScriptFullPath%, %filename%
   Run, %filename%
   Exit

   ;TODO try and TESTME
   ;FileDelete, %A_ScriptFullPath%
   ;Exit
}

RunAhkAndBabysit(filename)
{
   if NOT FileExist(filename)
      errord("silent", A_ThisFunc, filename, "file was not found")

   SetTitleMatchMode, RegEx

   Run, %filename%

   ;TODO move this to persistent - but if we move this to persistent, we won't be able to return if there was an error...
   ;  if we really wanted to return error state, maybe we could do UseErrorLevel, but i think that only applies to EXEs, not sure (prob won't catch AHK compile errors)
   WinWait, %filename%, (The program will exit|The previous version will remain in effect), 10
   sawErrorWindow := NOT ERRORLEVEL
   if sawErrorWindow
   {
      WinGetText, textFromTheWindow
      ControlClick, OK, %filename%
      errord("silent", A_ThisFunc, filename, "AHK file had an error...", textFromTheWindow, "... end of error msg")
      return "error"
   }
}

;TODO make an options param for wait and babysit?
;can you even wait and babysit at the same time?
RunAhk(ahkFilename, params="", options="")
{
   command=AutoHotkey.exe %ahkFilename% %params%
   if InStr(options, "wait")
      RunWait %command%
   else
      Run %command%
}

;Run a program (specify nickname or exe name)
;TODO maybe we could have an "ensure one instance" option
RunProgram(pathOrAppFilenameOrAppNickname)
{
   quote="
   params:=pathOrAppFilenameOrAppNickname
   params    := EnsureEndsWith(params, quote)
   params    := EnsureStartsWith(params, quote)
   RunAhk("FindAndRunProgram.ahk", params, "wait")
}

sendEmail(sSubject, sBody, sAttach="", sTo="cameronbaustian@gmail.com", sReplyTo="cameronbaustian+bot@gmail.com")
{
   timestamp := CurrentTime()
   path=C:\DataExchange\SendEmail
   file=%path%\%timestamp%.txt
   sBody:=RegExReplace(sBody, "(`r`n)", "ZZZnewlineZZZ")
   sBody:=RegExReplace(sBody, "(`r|`n)", "ZZZnewlineZZZ")
   FileCreateDir, %path%
   IniWrite, %sSubject%, %file%, pendingEmail, subject
   IniWrite, %sAttach%, %file%, pendingEmail, attach
   IniWrite, %sTo%, %file%, pendingEmail, to
   IniWrite, %sReplyTo%, %file%, pendingEmail, replyto
   IniWrite, %sBody%, %file%, pendingEmail, body

   Run, SendQueuedEmails.ahk
}

GetProcesses()
{
   d = `n  ; string separator
   s := 4096  ; size of buffers and arrays (4 KB)

   Process, Exist  ; sets ErrorLevel to the PID of this running script
   ; Get the handle of this script with PROCESS_QUERY_INFORMATION (0x0400)
   h := DllCall("OpenProcess", "UInt", 0x0400, "Int", false, "UInt", ErrorLevel)
   ; Open an adjustable access token with this process (TOKEN_ADJUST_PRIVILEGES = 32)
   DllCall("Advapi32.dll\OpenProcessToken", "UInt", h, "UInt", 32, "UIntP", t)
   VarSetCapacity(ti, 16, 0)  ; structure of privileges
   NumPut(1, ti, 0)  ; one entry in the privileges array...
   ; Retrieves the locally unique identifier of the debug privilege:
   DllCall("Advapi32.dll\LookupPrivilegeValueA", "UInt", 0, "Str", "SeDebugPrivilege", "Int64P", luid)
   NumPut(luid, ti, 4, "int64")
   NumPut(2, ti, 12)  ; enable this privilege: SE_PRIVILEGE_ENABLED = 2
   ; Update the privileges of this process with the new access token:
   DllCall("Advapi32.dll\AdjustTokenPrivileges", "UInt", t, "Int", false, "UInt", &ti, "UInt", 0, "UInt", 0, "UInt", 0)
   DllCall("CloseHandle", "UInt", h)  ; close this process handle to save memory

   hModule := DllCall("LoadLibrary", "Str", "Psapi.dll")  ; increase performance by preloading the libaray
   s := VarSetCapacity(a, s)  ; an array that receives the list of process identifiers:
   c := 0  ; counter for process idendifiers
   DllCall("Psapi.dll\EnumProcesses", "UInt", &a, "UInt", s, "UIntP", r)
   Loop, % r // 4  ; parse array for identifiers as DWORDs (32 bits):
   {
      id := NumGet(a, A_Index * 4)
      ; Open process with: PROCESS_VM_READ (0x0010) | PROCESS_QUERY_INFORMATION (0x0400)
      h := DllCall("OpenProcess", "UInt", 0x0010 | 0x0400, "Int", false, "UInt", id)
      VarSetCapacity(n, s, 0)  ; a buffer that receives the base name of the module:
      e := DllCall("Psapi.dll\GetModuleBaseNameA", "UInt", h, "UInt", 0, "Str", n, "UInt", s)
      DllCall("CloseHandle", "UInt", h)  ; close process handle to save memory
      if (n && e)  ; if image is not null add to list:
         l .= n . d, c++
   }
   DllCall("FreeLibrary", "UInt", hModule)  ; unload the library to free memory
   Sort, l, C  ; uncomment this line to sort the list alphabetically
   ;MsgBox, 0, %c% Processes, %l%
   return l
}

GetCpuUsage( ProcNameOrPid )
{
   Process, Exist, %ProcNameOrPid%
   pid := Errorlevel
   if NOT pid
      pid := ProcNameOrPid

   Static oldKrnlTime, oldUserTime
   Static newKrnlTime, newUserTime

   oldKrnlTime := newKrnlTime
   oldUserTime := newUserTime

   hProc := DllCall("OpenProcess", "Uint", 0x400, "int", 0, "Uint", pid)
   DllCall("GetProcessTimes", "Uint", hProc, "int64P", CreationTime, "int64P", ExitTime, "int64P", newKrnlTime, "int64P", newUserTime)

   DllCall("CloseHandle", "Uint", hProc)
   Return Round( (newKrnlTime-oldKrnlTime + newUserTime-oldUserTime)/10000000 * 100 ,2)
}

GetRamUsage(ProcNameOrPid, Units="K") {
   Process, Exist, %ProcNameOrPid%
   pid := Errorlevel
   if NOT pid
      pid := ProcNameOrPid

   ; get process handle
   hProcess := DllCall( "OpenProcess", UInt, 0x10|0x400, Int, false, UInt, pid )

   ; get memory info
   PROCESS_MEMORY_COUNTERS_EX := VarSetCapacity(memCounters, 44, 0)
   DllCall( "psapi.dll\GetProcessMemoryInfo", UInt, hProcess, UInt, &memCounters, UInt, PROCESS_MEMORY_COUNTERS_EX )
   DllCall( "CloseHandle", UInt, hProcess )

   SetFormat, Float, 0.0 ; round up K

   PrivateBytes := NumGet(memCounters, 40, "UInt")
   if (Units == "B")
      return PrivateBytes
   if (Units == "K")
      Return PrivateBytes / 1024
   if (Units == "M")
      Return PrivateBytes / 1024 / 1024
}

;Returns whether or not two files are equal
;TODO make this work for big files, too (this version reads it all into memory first)
IsFileEqual(filename1, filename2)
{
   FileRead, file1, %filename1%
   FileRead, file2, %filename2%

   return file1==file2
}

;TESTME
WaitFileExist(filename)
{
   while NOT FileExist(filename)
   {
      Sleep 100
   }
}

;TESTME (seemed to work well in previous context: de-queueing scheduled ahks)
WaitFileNotExist(filename)
{
   while (FileExist(filename))
   {
      Sleep 100
   }
}

;TODO return the name of the window that it saw instead and allow inf. windows to watch for
;TODO custom title match mode
;TESTME
DualWinWait(successWin, failureWin)
{
   while true
   {
      IfWinActive, %successWin%
         return "SUCCESS"

      IfWinActive, %failureWin%
         return "FAILURE"

      Sleep 50
   }
}

;FIXME seems that traytips don't work sometimes when the PC hasn't been rebooted in a while
;Displays a message in a bubble near the tray
TrayMsg(Title, Text="", TimeInSeconds=20, Icon=1, Options="")
{
   ;Was considering making this run in a separate thread so that the script could proceed without having to wait for the quote bubble to close, but that seems like it would be a lot of work, and if several bubbles popped up right in a row they would run one over the other...
   ;TODO perhaps someday i should make the thread pause for two seconds, then display the bubble for the remaining seconds (to allow it to be seen clearly, but to also allow the ahk to keep going)
   ;TODO make the Icon option straight text for readability

   ;if text is blank, the tooltip won't display
   if (Text=="")
   {
      Text:=Title
      Title:=""
   }

   TrayTip, %Title%, %Text%, %TimeInSeconds%, %Icon%
   SleepSeconds(2)
}

CloseTrayTip(text)
{
   IfWinExist, ahk_class tooltips_class32
   {
      WinGet, ID, LIST,ahk_class tooltips_class32
      Loop, %id%
      {
         this_id := id%A_Index%
         ControlGetText, TTtext,,ahk_id %this_id%
         if (InStr(TTtext, text))
            WinClose ahk_id %this_id%
      }
   }
}

GetOS()
{
   dllresult:=(DllCall("GetVersion") & 0xFF)
   RegRead, vista7, HKLM, SOFTWARE\Microsoft\Windows NT\CurrentVersion, CurrentVersion

   ;yeah... i know it's a problem, no reason to keep filling up the logs with it anymore
   ;debug("silent log", A_ThisFunc, A_LineNumber, "Note: known errors here with detecting that Phosphorus is running Win7","A_ComputerName:", A_ComputerName, "A_OSVERSIONNUM:", A_OSVERSIONNUM, "A_OSVERSION:", A_OSVERSION, "Checked using DLLCALL:", dllresult, "Checked using regread:", vista7)

   if ( A_ComputerName == "PHOSPHORUS" )
      return "WIN_7"
   return %A_OSVersion%
}

;Gets size of the entire directory in bytes
DirGetSize(dirPath)
{
   FolderSize = 0
   Loop, %dirPath%\*.*, , 1
      FolderSize += %A_LoopFileSize%
   return %FolderSize%
}

;Fixes possible issues with folder paths
RepairPath(FullPath)
{
   returned := FullPath
   returned := RegExReplace(returned, "(\\|\/)$")
   returned := RegExReplace(returned, "(\\|\/){2}", "\")
   return returned
}

;Gets the deepest child's folder name
GetFolderName(FullPath)
{

   returned := FullPath
   returned := RepairPath(returned)
   returned := RegExReplace(returned, "^.*(\\|\/)")
   return returned
}

;TODO also need a combobox prompt: provide option1|option2|option3
;TODO need to handle if the user hit cancel or the 'x' - "USER_CANCELLED"
;TODO default text in textbox
;Displays a standard prompt to the user
;if "folder" is specified in options, the prompt will be a folder chooser
Prompt(message, options="")
{
   returned:=""
   if (InStr(options, "folder"))
      FileSelectFolder, returned, , , %message%
   else
      InputBox, returned, , %message%
   return returned
}

;yeah
SexPanther(SexPanther="SexPanther")
{
   IniRead, returned, C:\My Dropbox\misc\config.ini, %SexPanther%, Panther
   IniRead, var, C:\My Dropbox\misc\config.ini, %SexPanther%, Sex
   return returned . var
}

;Make a report file of all the files that match the given pattern in the specified directory
;NOTE that you need to include a wildcard at the end!
DirectoryScan(directoryToScan, reportFilePath="C:/My Dropbox/Public/logs/trace.txt")
{
   time:=CurrentTime("hyphenated")
   timer:=StartTimer()
   count=0
   directoryToScan := EnsureEndsWith(directoryToScan, "\")
   Loop, %directoryToScan%*, 1, 1
   {
      FileAppend, %A_LoopFileFullPath%`n, %reportFilePath%
      count++
   }
   result:=ElapsedTime(timer)
   FileAppend, Time to complete: %result%ms`n, %reportFilePath%
   FileAppend, Total items: %count%`n, %reportFilePath%
   FileAppend, Current Time: %time%`n, %reportFilePath%
}

;returns url response rather than saving to a file
UrlDownloadToVar(URL, Proxy="", ProxyBypass="")
{
   AutoTrim, Off
   hModule := DllCall("LoadLibrary", "str", "wininet.dll")

   If (Proxy != "")
   AccessType=3
   Else
   AccessType=1
   ;INTERNET_OPEN_TYPE_PRECONFIG                    0   // use registry configuration
   ;INTERNET_OPEN_TYPE_DIRECT                       1   // direct to net
   ;INTERNET_OPEN_TYPE_PROXY                        3   // via named proxy
   ;INTERNET_OPEN_TYPE_PRECONFIG_WITH_NO_AUTOPROXY  4   // prevent using java/script/INS

   io_hInternet := DllCall("wininet\InternetOpenA"
   , "str", "" ;lpszAgent
   , "uint", AccessType
   , "str", Proxy
   , "str", ProxyBypass
   , "uint", 0) ;dwFlags

   iou := DllCall("wininet\InternetOpenUrlA"
   , "uint", io_hInternet
   , "str", url
   , "str", "" ;lpszHeaders
   , "uint", 0 ;dwHeadersLength
   , "uint", 0x80000000 ;dwFlags: INTERNET_FLAG_RELOAD = 0x80000000 // retrieve the original item
   , "uint", 0) ;dwContext

   If (ErrorLevel != 0 or iou = 0) {
   DllCall("FreeLibrary", "uint", hModule)
   return 0
   }

   VarSetCapacity(buffer, 512, 0)
   VarSetCapacity(NumberOfBytesRead, 4, 0)
   Loop
   {
     irf := DllCall("wininet\InternetReadFile", "uint", iou, "uint", &buffer, "uint", 512, "uint", &NumberOfBytesRead)
     NOBR = 0
     Loop 4  ; Build the integer by adding up its bytes. - ExtractInteger
       NOBR += *(&NumberOfBytesRead + A_Index-1) << 8*(A_Index-1)
     IfEqual, NOBR, 0, break
     ;BytesReadTotal += NOBR
     DllCall("lstrcpy", "str", buffer, "uint", &buffer)
     res = %res%%buffer%
   }
   ;StringTrimRight, res, res, 2

   DllCall("wininet\InternetCloseHandle",  "uint", iou)
   DllCall("wininet\InternetCloseHandle",  "uint", io_hInternet)
   DllCall("FreeLibrary", "uint", hModule)
   AutoTrim, on
   return, res
}

;return a string where each item is separated by the specified separator
ConcatWithSep(separator, text0, text1, text2="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text3="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text4="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text5="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text6="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text7="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text8="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text9="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text10="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text11="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text12="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text13="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text14="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text15="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ")
{
   returned:=text0
   Loop 15
   {
      if (text%A_Index% == "ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ")
         break
      returned .= separator
      returned .= text%A_Index%
   }
   return returned
}

;figure out if this computer is a VM, if no name is passed, it assumes the local machine
IsVM(ComputerName="")
{
   if (ComputerName=="")
      ComputerName:=A_ComputerName

   return !!InStr(ComputerName, "VM")
}

;Reload the core scripts(as if we just restarted the pc)
ForceReloadAll()
{
   RunWait, ForceReloadAll.exe
   ;CloseAllAhks("", "StartIdleAhks.ahk")
}

;Closes all ahks as gracefully as possible
CloseAllAhks(excludeRegEx="", startAhkAfter="")
{
   excludeRegEx   := EnsureEndsWith(excludeRegEx, quote)
   excludeRegEx   := EnsureStartsWith(excludeRegEx, quote)
   startAhkAfter   := EnsureEndsWith(startAhkAfter, quote)
   startAhkAfter   := EnsureStartsWith(startAhkAfter, quote)

   params:=concatWithSep(" ", excludeRegEx, startAhkAfter)
   RunAhk("CloseAllAhks.ahk", params, "wait")
}

;TESTME
ZeroPad(number, length)
{
   ;Loop length
      ;padding .= "0"
   ;length *= -1
   ;length++

   ;returned := substr(padding . number, length)
   ;return returned

   while (strlen(number) < length)
      number := "0" . number

   return number
}

;WRITEME
IsDirFileOrIndeterminate(path)
{
;DirExist()
;FileExist()

;if it doesn't exist, then all we can do is make a guess
;if it ends with a slash it has got to be a dir

;if it has a one two or three or four letter extension, it is probably a file

}

AddToTrace(var, t1="", t2="", t3="", t4="", t5="", t6="", t7="", t8="", t9="", t10="", t11="", t12="", t13="", t14="", t15="")
{
   Loop 15
      var .= " " . t%A_Index%
   var = %var%
   FileAppendLine(var, "C:\My Dropbox\Public\logs\trace.txt")
}

DeleteTraceFile()
{
   ;lets archive it and create a new file real quick
   timestamp:=CurrentTime("hyphenated")
   archiveFile=C:\My Dropbox\AHKs\gitExempt\logs\traceArchive\%timestamp%.log
   traceFile=C:\My Dropbox\Public\logs\trace.txt

   FileMove(traceFile, archiveFile)
   FileAppendLine("TRACE!!!", traceFile)
}

;RegEx File Processor
REFP(inFile="REFP/in1.txt", regExFile="REFP/regex1.txt", outFile="REFP/out1.txt")
{
   quote="
   infile    := EnsureEndsWith(infile, quote)
   infile    := EnsureStartsWith(infile, quote)
   regExfile := EnsureEndsWith(regExfile, quote)
   regExfile := EnsureStartsWith(regExfile, quote)
   outfile   := EnsureEndsWith(outfile, quote)
   outfile   := EnsureStartsWith(outfile, quote)

   params:=concatWithSep(" ", inFile, regExFile, outFile)
   RunAhk("RegExFileProcessor.ahk", params, "wait")
}

;Ensure that the string given ends with a given char
EnsureEndsWith(string, char)
{
   if ( StringRight(string, strlen(char)) <> char )
      string .= char

   return string
}

;Ensure that the string given starts with a given char
EnsureStartsWith(string, char)
{
   if ( StringLeft(string, strlen(char)) <> char )
      string := char . string

   return string
}

;Instead of actually muting, lets just turn the volume all the way down
SpiffyMute()
{
   ;Turn the volume all the way down
   SoundSet, 0

   ;unmute the volume for consistency
   SoundSet, 1, , mute
   SoundSet, +1, , mute
}

;allows easy access to the contents of XML elements
;path will travel through the XML heirarchy, like: html.head.title
;note that this does not enforce proper traversal of the xml tree
;TODO allow for attributes to be present in the XML element we are searching for
;TODO allow for searching through XML arrays
GetXmlElement(xml, pathToElement)
{
   Loop, parse, pathToElement, .,
   {
      elementName:=A_LoopField
      regex=<%elementName%>(.*)</%elementName%>

      RegExMatch(xml, regex, xml)
      ;TODO switch to use xml1, instead of parsing stuff out
      ;errord("nolog", xml1)
      xml := StringTrimLeft(xml, strlen(elementName)+2)
      xml := StringTrimRight(xml, strlen(elementName)+3)
   }

   return xml
}

fatalIfNotThisPc(computerName)
{
   if (A_ComputerName <> computerName)
   {
      debug(A_ScriptName, A_ComputerName, "this script isn't designed to run on this pc", "it is only designed to run on the following pc", computerName)
      ExitApp
   }
}

;this is a candidate for merging with debug()
;but first options "threaded" "timeToWait=untilPressOkButton" and "hideDebugInfo" need to be implemented
;but right now I think it is different enough
ThreadedMsgbox(message)
{
   message="%message%"
   RunAhk("ThreadedMsgbox.ahk", message)
}

;tells the name of the lead computer
LeadComputer()
{
   return "BAUSTIAN-09PC"
}

MultiWinWait(successWin, successWinText, failureWin, failureWinText)
{
   while true
   {
      IfWinActive, %successWin%, %successWinText%
         return "SUCCESS"

      IfWinActive, %failureWin%, %failureWinText%
         return "FAILURE"

      Sleep 50
   }
}

ClickButton(button)
{
   ;TODO figure out if the button is visible in the wintext
   ;TODO hit the alt key for the button, if it has that & in the name (more reliable)
   ControlClick, %button%
}

AddDatetime(datetime, numberToAdd, unitsOfNumberToAdd)
{
   ;TODO verify that datetime is a datetime
   ;TODO unhyphenate datetime if necessary
   ;TODO verify that number to add is a number
   ;TODO standardize naming of the units (m, mins, min, minute, minutes)
   datetime += %numberToAdd%, %unitsOfNumberToAdd%
   return datetime
}

Format(value, options)
{
   if ( InStr(options, "Dollar") OR InStr(options, "Money") )
   {
      RegExMatch(value, "(-{0,1})\${0,1}(-{0,1}\d*\.{0,1}\d{1,2})", match)
      return match1 . match2
      ;TODO allow values like $100 and $100.1... and 100 and 100.1
      ;if RegExMatch(value, "(-{0,1})\${0,1}(-{0,1}\d*.\d{2})", match)
         ;return match1 . match2
      ;else
         ;Errord("This value doesn't appear to be the correct type", A_ScriptName, A_LineNumber, A_ThisFunc, value, options)
   }
}

InStrCount(String, Needle)
{
   StringReplace, String, String, %Needle%, , UseErrorLevel
   return ErrorLevel
}

;by Berban originally
RegExMatchCount(Count_String, Count_Needle, Count_Type="", Count_SubPattern="")
;{
   ;Global
   ;Local f := 0, n := 0, Output := 0
   ;If (Type = "") {
      ;StringReplace, String, String, %Needle%, , UseErrorLevel
      ;n := ErrorLevel
   ;} Else {
      ;While (f := RegExMatch(String, Needle, Output, f + StrLen(Output))) {
         ;n++
         ;If Type
            ;%Type%%n% := Output%SubPattern%
      ;}
      ;If Type
         ;%Type% := n
   ;}
   ;Return n
;}
{
   Global
   Count_n = 0
   If (Count_Type = "") {
      Count_g := StrLen(Count_Needle)
      Loop {
         Count_f := InStr(Count_String, Count_Needle) - 1
         If (Count_f = -1)
            Break
         Count_n++
         StringTrimLeft, Count_String, Count_String, % Count_f + Count_g
      }
   } Else {
      Loop {
         Count_f := RegExMatch(Count_String, Count_Needle, Count_Output) - 1
         If (Count_f = -1)
            Break
         Count_n++
         If Count_Type
            %Count_Type%%Count_n% := Count_Output%Count_SubPattern%
         StringTrimLeft, Count_String, Count_String, % Count_f + StrLen(Count_Output)
      }
      If Count_Type
         %Count_Type% := Count_n
   }
   Return Count_n
}

;have an option to leave markers where the line endings were? ZZZnewlineZZZ
RemoveLineEndings(page)
{
   return RegExReplace(page, "(`r|`n)", " ")
}

FormatDollar(amount)
{
   RegExMatch(amount, "(\d|,)*\.\d\d", returned)
   returned:=RegExReplace(returned, ",", "")
   return returned
}

MorningStatusAppend(header, item)
{
   text=%header%: %item%
   FileAppendLine(text, "gitExempt\morning_status\finance.txt")
}

;TODO maybe we should save this all in an ini and have an option to prompt if the file isn't found if A_Debug (and save it in the ini automatically)
GetPath(file)
{
   if (file == "NightlyStats.ini")
      return "C:\My Dropbox\AHKs\gitExempt\NightlyStats.ini"
   else if (file == "DailyFinancial.csv") ;deprecated
      return "C:\My Dropbox\AHKs\gitExempt\DailyFinancial.csv"
   else if (file == "FinancialPast.csv")
      return "C:\My Dropbox\AHKs\gitExempt\FinancialPast.csv"
   else if (file == "trace" OR file == "trace.txt")
      return "C:\My Dropbox\Public\logs\trace.txt"
   errord("orange line", "tried to GetPath() for an unknown file", file)
   return ""
}

CommandPromptCopy()
{
   ;might not want to do this if it is already active
   ForceWinFocus("ahk_class ConsoleWindowClass")

   MouseClick, right, 13, 13
   Sleep 100
   Send, {UP 3}{RIGHT}{DOWN 3}
   Sleep 100
   Send, {ENTER}
   Sleep 100
   Send, {ENTER}
}

;maybe this should be moved to a nightly lib?
;write all this info out to the ini, csv and morning status email
;create the csv files afterward (pull the info from from the ini)
;;;TODO we could come up with the var name by getting rid of spaces
NightlyStats(title, data)
{
   if (title == "" OR data == "")
      return

   ini:=GetPath("NightlyStats.ini")
   date:=CurrentTime("hyphendate")

   IniWrite(ini, date, title, data)
   MorningStatusAppend(title, data)
}

;WRITEME make function for getting remote and local path of dropbox public folder
;WRITEME split csv processing out of the create pie chart macro
;WRITEME make monthly financial charts (rather than three-month)

;TODO error if Click() is outside the bounds of the window
;TODO error if Click() is control-clicking on a button that is not in the visible window text

;WRITEME parse and display TODO and WRITEME items from FcnLib
;WRITEME try to run MintTouch once an hour on the VM
;WRITEME macro that updates melinda's resume daily
;WRITEME close specified jira issue (and log work beforehand, too)
;WRITEME abort startup ahk if already started up (after VPNed)
;WRITEME RunDailyTask("HH:MM:SS", "PHOSPHORUS", "asdf.ahk", "params") ;need to make sure it calls SleepSeconds(2) at the end of it
;WRITEME macro that updates melinda's resume daily
;WRITEME close specified jira issue (and log work beforehand, too)

;WRITEME parse the following pages and put them in the morning status
;perhaps i can have updates of my points position, rather than having to look it up ;use blazin pedals site
;WRITEME make widget that will display the latest warnings and debug info (like baretail, but open all the time)
;WRITEME use autologin to make a script that closes out the VPN connection gracefully
;WRITEME WinClose(text, title, options) that allows match modes, and also allows the "Gentle" option described in the docs (PostMessage)


;WRITEME archive log files monthly, archive trace file nightly
;WRITEME use TodWulff lib for url shortening

;WRITEME improve queueing of the three types of queued ahks
;WRITEME fix the 3 types of queued AHKs - nightly, scheduled, and persistent-timed - figure out what the specs really are for each category and why they are different

;WRITEME fix GetOS() - run cmd prompt on startup and get version and save it

;WRITEME FIXME issues where infiniteloop.ahk is run during nightly, but doesn't show as "unfinished" the next morning


;WRITEME fileappendlinecsv
;WRITEME formatdollar()


;WRITEME method to test compile each ahk function lib individually and return if it compiles successfully (well, run it, not compile to exe)
;WRITEME make a function so i can use gocr easily


;WRITEME experiment with a log file using ini (or a trace file)


;WRITEME make FinancialProjection.csv work with new NightlyStats.ini
;WRITEME process old DailyFinancial.csv data into NightlyStats.ini
;WRITEME generate Financial.csv from NightlyStats.ini (nightly script)

