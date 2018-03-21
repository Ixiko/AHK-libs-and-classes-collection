;?add 2010 Modified by Tuncay
;?add Function prefix changed from MI_ExtractIcon() to ToolTip_ExtractIcon()
;?add and prefix added at ToolTip_GetAssociatedIcon().
/*
ToolTip() by HotKeyIt http://www.autohotkey.com/forum/viewtopic.php?t=40165

Syntax: ToolTip(Number,Text,Title,Options)

Return Value: ToolTip returns hWnd of the ToolTip

|-------------------------------------------------------------------------------------------------------------------|
|         Options can include any of following parameters separated by space
|-------------------------------------------------------------------------------------------------------------------|
| Option   |      Meaning
|-------------------------------------------------------------------------------------------------------------------|
| A      |   Aim ConrolId or ClassNN (Button1, Edit2, ListBox1, SysListView321...)
|         |   - using this, ToolTip will be shown when you point mouse on a control
|         |   - D (delay) can be used to change how long ToolTip is shown
|         |   - W (wait) can wait for specified seconds before ToolTip will be shown
|         |   - Some controls like Static require a subroutine to have a ToolTip!!!
|-------------------------------------------------------------------------------------------------------------------|
| B + F   |   Specify here the color for ToolTip in 6-digit hexadecimal RGB code
|         |   - B = Background color, F = Foreground color (text color)
|         |   - this can be 0x00FF00 or 00FF00 or Blue, Lime, Black, White...
|-------------------------------------------------------------------------------------------------------------------|
| C      |   Close button for ToolTip/BalloonTip. See ToolTip actions how to use it
|-------------------------------------------------------------------------------------------------------------------|
| D      |   Delay. This option will determine how long ToolTip should be shown.30 sec. is maximum
|         |   - this option is also available when assigning the ToolTip to a control.
|-------------------------------------------------------------------------------------------------------------------|
| E      |   Edges for ToolTip, Use this to set margin of ToolTip window (space between text and border)
|         |   - Supply Etop.left.bottom.right in pixels, for example: E10.0.10.5
|-------------------------------------------------------------------------------------------------------------------|
| G      |   Execute one or more internal Labels of ToolTip function only.
|         |   For example:
|         |   - Track the position only, use ToolTip(1,"","","Xcaret Ycaret gTTM_TRACKPOSITION")
|         |      - When X+Y are empty (= display near mouse position) you can use TTM_UPDATE
|         |   - Update text only, use ToolTip(1,"text","","G1"). Note specify L1 if links are used.
|         |   - Update title only, use ToolTip(1,"","Title","G1")
|         |   - Hide ToolTip, use ToolTip(1,"","","gTTM_POP")
|         |      - To show ToolTip again use ToolTip(1,"","","gTTM_TRACKPOSITION.TTM_TRACKACTIVATE")
|         |   - Update background color + text color, specify . between gLabels to execute several:
|         |      - ToolTip(1,"","","BBlue FWhite gTTM_SETTIPBKCOLOR.TTM_SETTIPTEXTCOLOR")
|         |   - Following labels can be used: TTM_SETTITLEA + TTM_SETTITLEW (title+I), TTM_POPUP, TTM_POP
|         |     TTM_SETTIPBKCOLOR (B), TTM_SETTIPTEXTCOLOR (F), TTM_TRACKPOSITION (N+X+Y),
|         |     TTM_SETMAXTIPWIDTH (R), TTM_SETMARGIN (E), TT_SETTOOLINFO (text+A+P+N+X+Y+S+L)
|         |     TTM_SETWINDOWTHEME (Q)
|-------------------------------------------------------------------------------------------------------------------|
| H      |   Hide ToolTip after a link is clicked.See L option
|-------------------------------------------------------------------------------------------------------------------|
| I      |   Icon 1-3, e.g. I1. If this option is missing no Icon will be used (same as I0)
|         |   - 1 = Info, 2 = Warning, 3 = Error, > 3 is meant to be a hIcon (handle to an Icon)
|         |   Use Included ToolTip_ExtractIcon and ToolTip_GetAssociatedIcon functions to get hIcon
|-------------------------------------------------------------------------------------------------------------------|
| J      |   Justify ToolTip to center of control
|-------------------------------------------------------------------------------------------------------------------|
| L      |   Links for ToolTips. See ToolTip actions how Links for ToolTip work.
|-------------------------------------------------------------------------------------------------------------------|
| M      |   Mouse click-trough. So a click will be forwarded to the window underneath ToolTip
|-------------------------------------------------------------------------------------------------------------------|
| N      |   Do NOT activate ToolTip (N1), To activate (show) call ToolTip(1,"","","gTTM_TRACKACTIVATE")
|-------------------------------------------------------------------------------------------------------------------|
| O      |   Oval ToolTip (BalloonTip). Specify O1 to use a BalloonTip instead of ToolTip.
|-------------------------------------------------------------------------------------------------------------------|
| P      |   Parent window hWnd or GUI number. This will assign a ToolTip to a window.
|         |   - Reqiered to assign ToolTip to controls and actions.
|-------------------------------------------------------------------------------------------------------------------|
| Q      |   Quench Style/Theme. Use this to disable Theme of ToolTip.
|         |   Using this option you can have for example colored ToolTips in Vista.
|-------------------------------------------------------------------------------------------------------------------|
| R      |   Restrict width. This will restrict the width of the ToolTip.
|         |   So if Text is to long it will be shown in several lines
|-------------------------------------------------------------------------------------------------------------------|
| S      |   Show at coordinates regardless of position. Specify S1 to use that feature
|         |   - normally it is fed automaticaly to show on screen
|-------------------------------------------------------------------------------------------------------------------|
| T      |   Transparency. This option will apply Transparency to a ToolTip.
|         |   - this option is not available to ToolTips assigned to a control.
|-------------------------------------------------------------------------------------------------------------------|
| V      |   Visible: even when the parent window is not active, a control-ToolTip will be shown
|-------------------------------------------------------------------------------------------------------------------|
| W      |   Wait time in seconds (max 30) before ToolTip pops up when pointing on one of controls.
|-------------------------------------------------------------------------------------------------------------------|
| X + Y   |   Coordinates where ToolTip should be displayed, e.g. X100 Y200
|         |   - leave empty to display ToolTip near mouse
|         |   - you can specify Xcaret Ycaret to display at caret coordinates
|-------------------------------------------------------------------------------------------------------------------|
|
|          To destroy a ToolTip use ToolTip(Number), to destroy all ToolTip()
|
|-------------------------------------------------------------------------------------------------------------------|
|               ToolTip Actions (NOTE, OPTION P MUST BE PRESENT TO USE THAT FEATURE)
|-------------------------------------------------------------------------------------------------------------------|
|      Assigning an action to a ToolTip to works using OnMessage(0x4e,"Function") - WM_NOTIFY
|      Parameter/option P must be present so ToolTip will forward messages to script
|      All you need to do inside this OnMessage function is to include:
|         - If wParam=0
|            ToolTip("",lParam[,Label])
|
|      Additionally you need to have one or more of following labels in your script
|      - ToolTip: when clicking a link
|      - ToolTipClose: when closing ToolTip
|         - You can also have a diferent label for one or all ToolTips
|         - Therefore enter the number of ToolTip in front of the label
|            - e.g. 99ToolTip: or 1ToolTipClose:
|
|      - Those labels names can be customized as well
|         - e.g. ToolTip("",lParam,"MyTip") will use MyTip: and MyTipClose:
|         - you can enter the number of ToolTip in front of that label as well.
|
|      - Links have following syntax:
|         - <a>Link</a> or <a link>LinkName</a>
|         - When a Link is clicked, ToolTip() will jump to the label
|            - Variable ErrorLevel will contain clicked link
|
|         - So when only LinkName is given, e.g. <a>AutoHotkey</a> Errorlevel will be AutoHotkey
|         - When using Link is given as well, e.g. <a http://www.autohotkey.com>AutoHotkey</a>
|            - Errorlevel will be set to http://www.autohotkey.com
|
|-------------------------------------------------------------------------------------------------------------------|
|      Please note some options like Close Button and Links will require Win2000++ (+version 6.0 of comctl32.dll)
|        AutoHotKey Version 1.0.48++ is required due to "assume static mode"
|        If you use 1 ToolTip for several controls, the only difference between those can be the text.
|           - Rest, like Title, color and so on, will be valid globally
|-------------------------------------------------------------------------------------------------------------------|
|      Example for LinkClick and ToolTip close!
|-------------------------------------------------------------------------------------------------------------------|
         OnMessage(0x201,"WM_LBUTTONDOWN") ;Will make ToolTip Click possible
         WM_LBUTTONDOWN(wParam,lParam,msg,hWnd){
            If tt%hwnd% {
               MsgBox, 262148,ToolTip Clicked, Close ToolTip
               IfMsgBox Yes
                  ToolTip(tt%hwnd%)
            }
         }
         OnMessage(0x4e,"WM_NOTIFY") ;Will make LinkClick and ToolTipClose possible
         WM_NOTIFY(wParam, lParam, msg, hWnd){
            ToolTip("",lParam,"")
         }
         Sleep, 10
         ToolTip(1,"<a>Click</a>`n<a>Onother one</a>`n"
         . "<a This link is different`nit uses different text>Different</a>`n"
         . "<a>ExitApp</a>","ClickMe","L1 P99 C1")
         hwnd:=ToolTip(2,"Click me anywhere!","Click Me","P99 C1")
         tt%hwnd%:= 1
         Return
         
         ToolTip:
         link:=ErrorLevel
         SetTimer, MsgBox, -10
         Return

         ToolTipClose:
         ExitApp

         MsgBox:
         If Link=ExitApp
            ExitApp
         MsgBox % Link
         Return
|-------------------------------------------------------------------------------------------------------------------|
|      Example for dynamic text!
|-------------------------------------------------------------------------------------------------------------------|
      OnMessage(0x4e,"WM_NOTIFY")
      Gui,Add,Button,,Time
      Gui,Add,Button,,Username
      Gui,Add,Button,,User is Admin?
      Gui,Add,Button,,IP addresses
      Loop 4
         ToolTip("Button1"," ","","p1 aButton" . A_Index)
      gui,show
      Sleep, 3000
      Return

      WM_NOTIFY(wParam,lParam){
         If (control:=ToolTip("",lparam)){
            Tool:=ErrorLevel
            MouseGetPos,,,,ClassNN
            If (ClassNN="Button1"){
               FormatTime,text,%A_Now%,HH:mm:ss
               Title:="Time"
            } else if (ClassNN="Button2"){
               text:=A_UserName,title:="UserName"
            } else if (ClassNN="Button3"){
               text:=(A_ISAdmin ? "Yes" : "No"),title:="User is Admin?"
            } else if (ClassNN="Button4"){
               text:= "1: " A_IPAddress1 "`n2: " A_IPAddress2 "`n3: " A_IPAddress3 "`n4: " A_IPAddress4
               title:="IP Addresses"
            }
            ToolTip(control,text,title,"G1 A" . Tool . " I" (ClassNN="Button1" ? "2" : "1"))
         }
      }

      GuiClose:
      ExitApp
|-------------------------------------------------------------------------------------------------------------------|
*/

ToolTip(ID="", text="", title="",options=""){
   ;____  Assume Static Mode for internal variables and structures  ____
   
   static
   ;________________________  ToolTip Messages  ________________________
   
   static TTM_POPUP:=0x422,         TTM_ADDTOOL:=0x404,        TTM_UPDATETIPTEXT:=0x40c
   ,TTM_POP:=0x41C,           TTM_DELTOOL:=0x405,        TTM_GETBUBBLESIZE:=0x41e
   ,TTM_UPDATE:=0x41D,        TTM_SETTOOLINFO:=0x409,      TTN_FIRST:=0xfffffdf8
   ,TTM_TRACKPOSITION:=0x412,    TTM_SETTIPBKCOLOR:=0x413,   TTM_SETTIPTEXTCOLOR:=0x414
   ,TTM_SETTITLEA:=0x420,      TTM_SETTITLEW:=0x421,      TTM_SETMARGIN:=0x41a
   ,TTM_SETWINDOWTHEME:=0x200b,   TTM_SETMAXTIPWIDTH:=0x418, TTM_NEWTOOLRECT:=0x406
   
   ;_______________Remote Buffer Messages for TrayIcon pos______________
   
   ;MEM_COMMIT:=0x1000,       PAGE_READWRITE:=4,          MEM_RELEASE:=0x8000
   
   ;________________________  ToolTip colors  ________________________
   
   ,Black:=0x000000,    Green:=0x008000,      Silver:=0xC0C0C0
   ,Lime:=0x00FF00,      Gray:=0x808080,          Olive:=0x808000
   ,White:=0xFFFFFF,    Yellow:=0xFFFF00,      Maroon:=0x800000
    ,Navy:=0x000080,      Red:=0xFF0000,          Blue:=0x0000FF
   ,Purple:=0x800080,   Teal:=0x008080,         Fuchsia:=0xFF00FF
    ,Aqua:=0x00FFFF
   ,RemoteBuf:="RemoteBuf"

   ;________________________  Local variables for options ________________________
   
   local option,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,v,w,x,y,xc,yc,xw,yw,update,RECT
   
   If ((#_DetectHiddenWindows:=A_DetectHiddenWindows)="Off")
      DetectHiddenWindows, On
   
   ;____________________________  Delete all ToolTips or return link _____________

   If !ID
   {
      If text
         If text is Xdigit
            GoTo, TTN_LINKCLICK
      Loop, Parse, hWndArray, % Chr(2) ;Destroy all ToolTip Windows
      {
         If WinExist("ahk_id " . A_LoopField)
            DllCall("DestroyWindow","Uint",A_LoopField)
         hWndArray%A_LoopField%=
      }
      hWndArray=
      Loop, Parse, idArray, % Chr(2) ;Destroy all ToolTip Structures
      {
         TT_ID:=A_LoopField
         If TT_ALL_%TT_ID%
            Gosub, TT_DESTROY
      }
      idArray=
      DetectHiddenWindows,%#_DetectHiddenWindows%
      Return
   }
   
   TT_ID:=ID
   TT_HWND:=TT_HWND_%TT_ID%
   
   ;___________________  Load Options Variables and Structures ___________________
   
   If (options){
      Loop,Parse,options,%A_Space%
         If (option:= SubStr(A_LoopField,1,1))
            %option%:= SubStr(A_LoopField,2)
   }
   If (G){
      If (Title!=""){
         Gosub, TTM_SETTITLEA
         Gosub, TTM_UPDATE
      }
      If (Text!=""){
         If (A!="")
            ID:=A
         If (InStr(text,"<a") and L){
            TOOLTEXT_%TT_ID%:=text
            text:=RegExReplace(text,"<a\K[^<]*?>",">")
         } else
            TOOLTEXT_%TT_ID%:=
         If (ID=TT_ID and !TOOLINFO_%TT_ID%){
            Loop,Parse,TT_ALL_%TT_ID%,% Chr(2)
               If (TOOLINFO_%A_LoopField%){
                  ID:=A_LoopField
                  NumPut(&text,TOOLINFO_%ID%,36)
                  Gosub, TTM_UPDATETIPTEXT
                  Gosub, TTM_UPDATE
                  Loop, Parse,G,.
                     If IsLabel(A_LoopField)
                        Gosub, %A_LoopField%
               }
            DetectHiddenWindows,%#_DetectHiddenWindows%
            Return
         } else {
            NumPut(&text,TOOLINFO_%ID%,36)
            Gosub, TTM_UPDATETIPTEXT
            Gosub, TTM_UPDATE
         }
      }
      Loop, Parse,G,.
         If IsLabel(A_LoopField)
            Gosub, %A_LoopField%
      DetectHiddenWindows,%#_DetectHiddenWindows%
      Return
   }
   ;__________________________  Save TOOLINFO Structures _________________________
   
   If P {
      If (p<100 and !WinExist("ahk_id " p)){
         Gui,%p%:+LastFound
         P:=WinExist()
      }
      If !InStr(TT_ALL_%TT_ID%,Chr(2) . Abs(P) . Chr(2))
         TT_ALL_%TT_ID% .= Chr(2) . Abs(P) . Chr(2)
   }
   If !InStr(TT_ALL_%TT_ID%,Chr(2) . ID . Chr(2))
      TT_ALL_%TT_ID% .= Chr(2) . ID . Chr(2)
   If H
      TT_HIDE_%TT_ID%:=1
   ;__________________________  Create ToolTip Window  __________________________
   
   If (!TT_HWND and text)
   {
      TT_HWND := DllCall("CreateWindowEx", "Uint", 0x8, "str", "tooltips_class32", "str", "", "Uint", 0x02 + (v ? 0x1 : 0) + (l ? 0x100 : 0) + (C ? 0x80 : 0)+(O ? 0x40 : 0), "int", 0x80000000, "int", 0x80000000, "int", 0x80000000, "int", 0x80000000, "Uint", P ? P : 0, "Uint", 0, "Uint", 0, "Uint", 0)
      TT_HWND_%TT_ID%:=TT_HWND
      hWndArray.=(hWndArray ? Chr(2) : "") . TT_HWND
      idArray.=(idArray ? Chr(2) : "") . TT_ID
      Gosub, TTM_SETMAXTIPWIDTH
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", 0x403, "Uint", 2, "Uint", (D ? D*1000 : -1)) ;TTDT_AUTOPOP
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", 0x403, "Uint", 3, "Uint", (W ? W*1000 : -1)) ;TTDT_INITIAL
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", 0x403, "Uint", 1, "Uint", (W ? W*1000 : -1)) ;TTDT_RESHOW
   } else if (!text and !options){
      DllCall("DestroyWindow","Uint",TT_HWND)
      TT_HWND_%TT_ID%=
      Gosub, TT_DESTROY
      DetectHiddenWindows,%#_DetectHiddenWindows%
      Return
   }
   
   ;______________________  Create TOOLINFO Structure  ______________________
   
   Gosub, TT_SETTOOLINFO

   If (Q!="")
      Gosub, TTM_SETWINDOWTHEME
   If (E!="")
      Gosub, TTM_SETMARGIN
   If (F!="")
      Gosub, TTM_SETTIPTEXTCOLOR
   If (B!="")
      Gosub, TTM_SETTIPBKCOLOR
   If (title!="")
      Gosub, TTM_SETTITLEA
   
   If (!A){
      Gosub, TTM_UPDATETIPTEXT
      Gosub, TTM_UPDATE
      If D {
         A_Timer := A_TickCount, D *= 1000
         Gosub, TTM_TRACKPOSITION
         Gosub, TTM_TRACKACTIVATE
         Loop
         {
            Gosub, TTM_TRACKPOSITION
            If (A_TickCount - A_Timer > D)
               Break
         }
         Gosub, TT_DESTROY
         DllCall("DestroyWindow","Uint",TT_HWND)
         TT_HWND_%TT_ID%=
      } else {
         Gosub, TTM_TRACKPOSITION
         Gosub, TTM_TRACKACTIVATE
         If T
            WinSet,Transparent,%T%,ahk_id %TT_HWND%
         If M
            WinSet,ExStyle,^0x20,ahk_id %TT_HWND%
      }
   }

   ;________  Restore DetectHiddenWindows and return HWND of ToolTip  ________

   DetectHiddenWindows, %#_DetectHiddenWindows%
   ErrorLevel:=ID
   Return TT_HWND
   
   ;________________________  Internal Labels  ________________________
   
   TTM_POP:    ;Hide ToolTip
   TTM_POPUP:    ;Causes the ToolTip to display at the coordinates of the last mouse message.
   TTM_UPDATE: ;Forces the current tool to be redrawn.
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", %A_ThisLabel%, "Uint", 0, "Uint", 0)
   Return
   TTM_TRACKACTIVATE: ;Activates or deactivates a tracking ToolTip.
   DllCall("SendMessage", "Uint", TT_HWND, "Uint", 0x411, "Uint", (N ? 0 : 1), "Uint", &TOOLINFO_%ID%)
   Return
   TTM_UPDATETIPTEXT:
   TTM_GETBUBBLESIZE:
   TTM_ADDTOOL:
   TTM_DELTOOL:
   TTM_SETTOOLINFO:
   TTM_NEWTOOLRECT:
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", %A_ThisLabel%, "Uint", 0, "Uint", &TOOLINFO_%ID%)
   Return
   TTM_SETTITLEA:
   TTM_SETTITLEW:
      title := (StrLen(title) < 96) ? title : ("…" . SubStr(title, -97))
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", %A_ThisLabel%, "Uint", I, "Uint", &Title)
   Return
   TTM_SETWINDOWTHEME:
      If Q
         DllCall("uxtheme\SetWindowTheme", "Uint", TT_HWND, "Uint", 0, "UintP", 0)
      else
         DllCall("SendMessage", "Uint", TT_HWND, "Uint", %A_ThisLabel%, "Uint", 0, "Uint", &Q)
   Return
   TTM_SETMAXTIPWIDTH:
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", %A_ThisLabel%, "Uint", 0, "Uint", R ? R : A_ScreenWidth)
   Return
   TTM_TRACKPOSITION:
      VarSetCapacity(xc, 20, 0), xc := Chr(20)
      DllCall("GetCursorInfo", "Uint", &xc)
      yc := NumGet(xc,16), xc := NumGet(xc,12)
      xc+=15,yc+=15
      If (x="caret" or y="caret"){
         WinGetPos,xw,yw,,,A
         If x=caret
         {
            SysGet,xl,76
            SysGet,xr,78
            xc:=xw+A_CaretX +1
            xc:=(xl>xc ? xl : (xr<xc ? xr : xc))
         }
         If (y="caret"){
            SysGet,yl,77
            SysGet,yr,79
            yc:=yw+A_CaretY+15
            yc:=(yl>yc ? yl : (yr<yc ? yr : yc))
         }
      } else if (x="TrayIcon" or y="TrayIcon"){
         Process, Exist
         PID:=ErrorLevel
         hWndTray:=WinExist("ahk_class Shell_TrayWnd")
         ControlGet,hWndToolBar,Hwnd,,ToolbarWindow321,ahk_id %hWndTray%
         If (Isfunc(RemoteBuf . "_Open") and Isfunc(RemoteBuf . "_Read") and Isfunc(RemoteBuf . "_Close") and Isfunc(RemoteBuf . "_Get")){
            %RemoteBuf%_Open(TrayH,hWndToolBar,20)
            DataH:=NumGet(TrayH,0)
            SendMessage, 0x418,0,0,,ahk_id %hWndToolBar%
            Loop % ErrorLevel
            {
               SendMessage,0x417,A_Index-1,%RemoteBuf%_Get(TrayH),,ahk_id %hWndToolBar%
               %RemoteBuf%_Read(TrayH,lpData,20)
               VarSetCapacity(dwExtraData,8)
               pwData:=NumGet(lpData,12)
               DllCall( "ReadProcessMemory", "uint", DataH, "uint", pwData, "uint", &dwExtraData, "uint", 8, "uint", 0 )
               BWID:=NumGet(dwExtraData,0)
               WinGet,BWPID,PID, ahk_id %BWID%
               If (BWPID!=PID)
                  continue
               SendMessage, 0x41d,A_Index-1,%RemoteBuf%_Get(TrayH),,ahk_id %hWndToolBar%
               %RemoteBuf%_Read(TrayH,rcPosition,20)
               ControlGetPos,xc,yc,xw,yw,Button2,ahk_id %hWndTray%
               If (NumGet(lpData,8)>7){
                  ControlGetPos,xc,yc,xw,yw,Button2,ahk_id %hWndTray%
                  xc+=xw/2, yc+=yw/4
               } else {
                  ControlGetPos,xc,yc,,,ToolbarWindow321,ahk_id %hWndTray%
                  halfsize:=NumGet(rcPosition,12)/2
                  xc+=NumGet(rcPosition,0)+ halfsize
                  yc+=NumGet(rcPosition,4)+ (halfsize/2)
               }
               WinGetPos,xw,yw,,,ahk_id %hWndTray%
               xc+=xw,yc+=yw
               break
            }
            %RemoteBuf%_close(TrayH)
         } else
            ControlGetPos,xc,yc,,,ToolbarWindow321,ahk_id %hWndTray%
      }
      If (!x and !y)
         Gosub, TTM_UPDATE
      else if !WinActive("ahk_id " . TT_HWND)
         DllCall("SendMessage", "Uint", TT_HWND, "Uint", %A_ThisLabel%, "Uint", 0, "Uint", (x<9999999 ? x : xc & 0xFFFF)|(y<9999999 ? y : yc & 0xFFFF)<<16)
   Return
   TTM_SETTIPBKCOLOR:
      If B is alpha
         If (%b%)
            B:=%b%
      B := (StrLen(B) < 8 ? "0x" : "") . B
      B := ((B&255)<<16)+(((B>>8)&255)<<8)+(B>>16) ; rgb -> bgr
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", %A_ThisLabel%, "Uint", B, "Uint", 0)
   Return
   TTM_SETTIPTEXTCOLOR:
      If F is alpha
         If (%F%)
            F:=%f%
      F := (StrLen(F) < 8 ? "0x" : "") . F
      F := ((F&255)<<16)+(((F>>8)&255)<<8)+(F>>16) ; rgb -> bgr
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", %A_ThisLabel%, "Uint",F & 0xFFFFFF, "Uint", 0)
   Return
   TTM_SETMARGIN:
      VarSetCapacity(RECT,16)
      Loop,Parse,E,.
         NumPut(A_LoopField,RECT,(A_Index-1)*4)
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", %A_ThisLabel%, "Uint", 0, "Uint", &RECT)
   Return
   TT_SETTOOLINFO:
      If A {
         If A is not Xdigit
            ControlGet,A,Hwnd,,%A%,ahk_id %P%
         ID :=Abs(A)
         If !InStr(TT_ALL_%TT_ID%,Chr(2) . ID . Chr(2))
            TT_ALL_%TT_ID% .= Chr(2) . ID . Chr(2) . ID+Abs(P) . Chr(2)
         If !TOOLINFO_%ID%
            VarSetCapacity(TOOLINFO_%ID%, 40, 0),TOOLINFO_%ID%:=Chr(40)
         else
            Gosub, TTM_DELTOOL
         Numput((N ? 0 : 1)|(J ? 2 : 0)|16,TOOLINFO_%ID%,4),Numput(P,TOOLINFO_%ID%,8),Numput(ID,TOOLINFO_%ID%,12)
         If (text!="")
            NumPut(&text,TOOLINFO_%ID%,36)
         Gosub, TTM_ADDTOOL
         ID :=ID+Abs(P)
         If !TOOLINFO_%ID%
         {
            VarSetCapacity(TOOLINFO_%ID%, 40, 0),TOOLINFO_%ID%:=Chr(40)
            Numput(0|16,TOOLINFO_%ID%,4), Numput(P,TOOLINFO_%ID%,8), Numput(P,TOOLINFO_%ID%,12)
         }
         Gosub, TTM_ADDTOOL
         ID :=Abs(A)
      } else {
         If !TOOLINFO_%ID%
            VarSetCapacity(TOOLINFO_%ID%, 40, 0),TOOLINFO_%ID%:=Chr(40)
         If (text!=""){
            If InStr(text,"<a"){
               TOOLTEXT_%ID%:=text
               text:=RegExReplace(text,"<a\K[^<]*?>",">")
            } else
               TOOLTEXT_%ID%:=
            NumPut(&text,TOOLINFO_%ID%,36)
         }
         NumPut((J ? 2 : 0)|(!(x . y) ? 0 : 0x20)|(S ? 0x80 : 0)|(L ? 0x1000 : 0x100),TOOLINFO_%ID%,4), Numput(P,TOOLINFO_%ID%,8), Numput(P,TOOLINFO_%ID%,12)
         Gosub, TTM_ADDTOOL
      }
   Return
   TTN_LINKCLICK:
      Loop 4
         m += *(text + 8 + A_Index-1) << 8*(A_Index-1)
      If !(TTN_FIRST-1=m or TTN_FIRST-2=m or TTN_FIRST-3=m)
         Return
      Loop 4
         p += *(text + A_Index-1) << 8*(A_Index-1)
      If (TTN_FIRST-3=m)
         Loop 4
            option += *(text + 16 + A_Index-1) << 8*(A_Index-1)
      Loop,Parse,hWndArray,% Chr(2)
         If (p=A_LoopField and i:=A_Index)
            break
      Loop,Parse,idArray,% Chr(2)
      {
         If (i=A_Index){
            If (TTN_FIRST-1=m){
               Loop 4
                  ErrorLevel += *(text + 4 + A_Index-1) << 8*(A_Index-1)
               Return A_LoopField
            }
            text:=TOOLTEXT_%A_LoopField%
            If (TTN_FIRST-2=m){
               If Title
               {
                  If IsLabel(A_LoopField . title . "Close")
                     Gosub % A_LoopField . title . "Close"
                  else If IsLabel(title . "Close")
                     Gosub % title . "Close"
               } else {
                  If IsLabel(A_LoopField . A_ThisFunc . "Close")
                     Gosub % A_LoopField . A_ThisFunc . "Close"
                  else If IsLabel(A_ThisFunc . "Close")
                     Gosub % A_ThisFunc . "Close"
               }
            } else If (InStr(TOOLTEXT_%A_LoopField%,"<a")){
               Loop % option+1
                  StringTrimLeft,text,text,% InStr(text,"<a")+1
               If TT_HIDE_%A_LoopField%
                  ToolTip(A_LoopField,"","","gTTM_POP")
               If ((a:=A_AutoTrim)="Off")
                  AutoTrim, On
               ErrorLevel:=SubStr(text,1,InStr(text,">")-1)
               StringTrimLeft,text,text,% InStr(text,">")
               text:=SubStr(text,1,InStr(text,"</a>")-1)
               If !ErrorLevel
                  ErrorLevel:=text
               ErrorLevel=%ErrorLevel%
               AutoTrim, %a%
               If Title
               {
                  If IsFunc(f:=(A_LoopField . title))
                     %f%(ErrorLevel)
                  else if IsLabel(A_LoopField . title)
                     Gosub % A_LoopField . title
                  else if IsFunc(title)
                     %title%(ErrorLevel)
                  else If IsLabel(title)
                     Gosub, %title%
               } else {
                  if IsFunc(f:=(A_LoopField . A_ThisFunc))
                     %f%(ErrorLevel)
                  else If IsLabel(A_LoopField . A_ThisFunc)
                     Gosub % A_LoopField . A_ThisFunc
                  else If IsLabel(A_ThisFunc)
                     Gosub % A_ThisFunc
               }
            }
            break
         }
      }
      DetectHiddenWindows, %#_DetectHiddenWindows%
   Return
   TT_DESTROY:
      Loop, Parse, TT_ALL_%TT_ID%,% Chr(2)
         If A_LoopField
         {
            ID:=A_LoopField
            Gosub, TTM_DELTOOL
            TOOLINFO_%A_LoopField%:="", TT_HWND_%A_LoopField%:="", TOOLTEXT_%A_LoopField%:="", TT_HIDE_%A_LoopField%:=""
         }
      TT_ALL_%TT_ID%=
   Return
}

ToolTip_ExtractIcon(Filename, IconNumber, IconSize)
{
   If A_OSVersion in WIN_VISTA,WIN_2003,WIN_XP,WIN_2000
   {
     DllCall("PrivateExtractIcons", "Str", Filename, "Int", IconNumber-1, "Int", IconSize, "Int", IconSize, "UInt*", hIcon, "UInt*", 0, "UInt", 1, "UInt", 0, "Int")
      If !ErrorLevel
      Return hIcon
   }
   If DllCall("shell32.dll\ExtractIconExA", "Str", Filename, "Int", IconNumber-1, "UInt*", hIcon, "UInt*", hIcon_Small, "UInt", 1)
   {
      SysGet, SmallIconSize, 49
      
      If (IconSize <= SmallIconSize) {
       DllCall("DeStroyIcon", "UInt", hIcon)
       hIcon := hIcon_Small
      }
     Else
      DllCall("DeStroyIcon", "UInt", hIcon_Small)
      
      If (hIcon && IconSize)
         hIcon := DllCall("CopyImage", "UInt", hIcon, "UInt", 1, "Int", IconSize, "Int", IconSize, "UInt", 4|8)
   }
   Return, hIcon ? hIcon : 0
}
ToolTip_GetAssociatedIcon(File){
   static
   sfi_size:=352
   local Ext,Fileto,FileIcon,FileIcon#
   If !File
      Loop, Parse, #_hIcons, |
         If A_LoopField
            DllCall("DestroyIcon",UInt,A_LoopField)
   If not sfi
      VarSetCapacity(sfi, sfi_size)
   SplitPath, File,,, Ext
   If !Ext
      Return
   else if Ext in EXE,ICO,ANI,CUR,LNK
   {
      If ext=LNK
      {
         FileGetShortcut,%File%,Fileto,,,,FileIcon,FileIcon#
         File:=!FileIcon ? FileTo : FileIcon
      }
      SplitPath, File,,, Ext
      hIcon%Ext%:=ToolTip_ExtractIcon(file,FileIcon# ? FileIcon# : 1,32)
   } else If (!hIcon%Ext% or !InStr(hIcons,"|" . hIcon%Ext% . "|")){
      If DllCall("Shell32\SHGetFileInfoA", "str", File, "uint", 0, "str", sfi, "uint", sfi_size, "uint", 0x101){
         Loop 4
            hIcon%Ext% += *(&sfi + A_Index-1) << 8*(A_Index-1)
      }
      hIcons.= "|" . hIcon%Ext% . "|"
   }
   return hIcon%Ext%
}