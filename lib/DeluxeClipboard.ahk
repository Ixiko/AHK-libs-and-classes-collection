; http://www.autohotkey.com/forum/topic2665.html

; Deluxe Clipboard
; AutoHotkey Version: 1.0.35+
; Language:  English
; Platform:  Win2000/XP
; Author:    Laszlo Hars <www.Hars.US>
;
; Script Function:
;     Provides unlimited number of private, named clipboards
;     Hotkeys = CapsLock & …
;        c: Copy, x: Cut, v: Paste, a: Append and y: CutAppend any selections
;     In applications using ^c, ^x, ^v for copy, cut, paste to/from the Windows clipboard
;     Private clipboard names consist of any ANSI characters except "|"
;        The already used names are shown in a sorted drop down list with
;            incremental search (beginning of a name and Up or Down arrow)
;        The last-used name is pre-selected, Enter accepts
;     New hotkey replaces function
;
; Version history:
;     1.0: 2005.03.05 Initial creation
;     1.1: 2005.03.07 Error check added for clipboard names
;                     Legible version of A_ThisHotKey in Gui 3:text
;                     2nd hotkey while 1st is active replaces function
;                     Repeated hotkey is detected from saved current hotkey
;     1.2: 2005.03.12 Append: by arrays of private clipboards, $ separated
;                     Paste: each entry of the array one-by-one
;                     ClipBoardAll is used
;     1.3: 2005.05.01 ClipWait up to 2s added for handling large clipboards
;                     Sleep between setup the clipboard and pasting it
;                     ClipBoardAll is used at Append and CutAppend
;     2.0: 2005.10.03 CapsLock & … hotkeys
;                     Use functions, Simplified code
;                     ClipBoard Name -> hex, avoiding naming restrictions, except "|"

#SingleInstance Force
AutoTrim Off
names =                          ; | after each name, || after last used (default)

CapsLock & c::WINDOW("&Copy")    ; COPY to private clipboard
CapsLock & v::WINDOW("&Paste")   ; PASTE from private clipboard
CapsLock & x::WINDOW("&Cut")     ; CUT to private clipboard
CapsLock & a::WINDOW("&Append")  ; APPEND to private clipboard
CapsLock & y::WINDOW("Cut&Append") ; CUT+APPEND to private clipboard

WINDOW(Actn)
{
   Global
   Gui 3:Destroy                 ; needed for 2nd hotkey while 1st is active
   WinGet CallerID, ID, A        ; save caller's ID as the window to return to

   Gui 3:Font, s10, Arial        ; ADJUST BELOW FOR YOUR SCREEN RESOLUTION
   Gui 3:Add, Text,    x028 y14 w220 h40, Private clipboard name:
   Gui 3:Add, ComboBox,x026 y44 w220 h20 r5 Sort vName, %names%
   Gui 3:Add, Button,  x146 y84 w100 h30, Cancel
   Gui 3:Add, Button,  x026 y84 w100 h30  Default, %Actn%
   Gui 3:Show, h133 w271 Center, Deluxe Clipboard
}

3GuiClose:
3GuiEscape:
3ButtonCancel:
   Gui 3:Destroy
Return

3ButtonCopy:
   Gosub GoBack
   IfEqual NameError,1, Return   ; Gui remains after wrong name
   Loop % %HexName%_0
      %HexName%_%A_Index% =      ; clear memory used by the array, if any
   %HexName%_0 = 1               ; chain length = 1
   ClipBoard0  = %ClipBoardAll%  ; save original clipboard
   ClipBoard   =
   Send ^c                       ; copy new data to clipboard
   ClipWait 2, 1                 ; wait up to 2 seconds or until clipboard contains data
   %HexName%_1 = %ClipBoardAll%  ; transfer new clipboard to array
   ClipBoard   = %ClipBoard0%    ; restore original clipboard
Return

3ButtonPaste:
   Gosub GoBack
   IfEqual NameError,1, Return   ; Gui remains after wrong name
   ClipBoard0 = %ClipBoardAll%   ; save original clipboard (ClipBoardAll)
   Loop % %HexName%_0
   {                             ; load clipboard from array
     Clipboard =
     Clipboard := %HexName%_%A_Index%
     ClipWait 3                  ; wait for new ClipBoard content
     Send ^v                     ; paste data to window
   }
   ClipBoard  = %ClipBoard0%     ; restore original clipboard
return

3ButtonCut:
   Gosub GoBack
   IfEqual NameError,1, Return   ; Gui remains after wrong name
   Loop % %HexName%_0
     %HexName%_%A_Index% =       ; clear memory used by the array, if any
   %HexName%_0 = 1               ; chain length = 1
   ClipBoard0  = %ClipBoardAll%  ; save original clipboard
   ClipBoard   =
   Send ^x                       ; copy new data to clipboard
   ClipWait 2, 1                 ; wait up to 2 seconds or until clipboard contains data
   %HexName%_1 = %ClipBoardAll%  ; transfer new clipboard to array
   ClipBoard   = %ClipBoard0%    ; restore original clipboard
Return

3ButtonAppend:                   ; Problems with MS Office
   Gosub GoBack
   IfEqual NameError,1, Return   ; Gui remains after wrong name
   ClipBoard0 = %ClipBoardAll%   ; save original clipboard
   ClipBoard  =
   Send ^c                       ; copy new data to clipboard
   ClipWait 2, 1                 ; wait up to 2 seconds or until clipboard contains data
   %HexName%_0++                 ; increment number of clipboards in the chain
   idx := %HexName%_0
   %HexName%_%idx%=%ClipBoardAll% ; store new clipboard at the next array location
   ClipBoard = %ClipBoard0%      ; restore original clipboard
Return

3ButtonCutAppend:                ; Problems with MS Office
   Gosub GoBack
   IfEqual NameError,1, Return   ; Gui remains after wrong name
   ClipBoard0= %ClipBoardAll%    ; save original clipboard
   ClipBoard =
   Send ^x                       ; copy new data to clipboard
   ClipWait 2, 1                 ; wait up to 2 seconds or until clipboard contains data
   %HexName%_0++                 ; increment number of clipboards in the chain, init = 1
   idx := %HexName%_0
   %HexName%_%idx%= %ClipBoardAll% ; store new clipboard at the next array location
   ClipBoard = %ClipBoard0%      ; restore original clipboard
Return

GoBack:
   Gui 3:Submit, NoHide          ; assign Gui variables
   NameError =
   IfEqual Name,, SetEnv NameError,1
   If Name contains |
      NameError = 1
   IfEqual NameError, 1, {
      WinGet GuiID, ID, A        ; save Gui ID as the window to return to
      MsgBox,,,Please provide a valid`nClipboard Name!,2
      WinActivate ahk_id %GuiID%   ; get back to GUI
      return
   }
   Gui 3:Destroy                 ; GUI's done its task
   WinActivate ahk_id %CallerID% ; get back to caller window
   StringReplace names,names,||,|  ; remove marker of last-used name
   StringGetPos Pos, names,%Name%| ; was this clipboard name used?
   if Pos < 0                    ; new name appended
      names = %names%%Name%||
   else                          ; old name marked as last used
      StringReplace names,names,%Name%|,%Name%||
   HexName := String2Hex(Name)
return

String2Hex(x)                    ; Convert a string to hex digits
{
   format = %A_FormatInteger%
   SetFormat Integer, H
   hex = X
   Loop Parse, x
   {
      y := ASC(A_LoopField)      ; 2 digit ASCII code of chars of x, 15 < y < 256
      StringTrimLeft y, y, 2     ; Remove leading 0x
      hex = %hex%%y%
   }
   SetFormat Integer, %format%
   Return hex
}