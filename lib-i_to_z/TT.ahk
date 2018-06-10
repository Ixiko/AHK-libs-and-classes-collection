/*
Gosub, Example1 ;Simple ToolTip

Gosub, Example2 ;Links in ToolTip

Gosub, Example3 ;ToolTips for Controls

Gosub, Example4 ;ToolTip follows mouse

Gosub, Example5 ;View Icons included in dll

~Esc::ExitApp

;-------------------------------------------------

Example1:
TT:=TT("Icon=1","text","Title") ;create a ToolTip
Loop 50 {
   TT.Show() ;show ToolTip at mouse coordinates
   Sleep, 50
}
TT.Remove() ;delete ToolTip
MsgBox ToolTip Deleted, click ok for next ToolTip example
Return
;-------------------------------------------------

Example2:
TT:=TT("CloseButton OnClick=TT_Msg OnClose=TT_MsgClose"
      ,"<a click>Click Me</a>`n<a Second action>Click Me Too</a>"
      ,"Title (Click close Button to proceed)")
TT.Show()
Exit
TT_Msg(TT,option){
   MsgBox % option
}
TT_MsgClose(TT){
   SetTimer, Example3,-100
}

;-------------------------------------------------

Example3:
TT:=TT("GUI=1")
Gui,Add,Edit,,I'm an Edit Box
TT.Add("Edit1","Edit Control","Center RTL HWND")
Gui,Add,Button,,I'm a Button
TT.Add("Button1","<a>You can't click me :)</a>","PARSELINKS")
Gui,Show
Return
GuiClose:
Gui,Destroy
TT_Remove() ;remove all tooltips
;-------------------------------------------------

Example4:
TT:=TT("ClickTrough Balloon"
      ,""
      ,"ClickTrough activated (Hold Ctrl and clict trough ToolTip)") ;create new tooltip
TT.Color("White","Black")
Loop 100 {
   If !GetKeyState("Ctrl","P")
      TT.Show(A_Hour ":" A_Min ":" A_Sec)
   Sleep 50
}
TT.Remove()
;-------------------------------------------------

Example5:
i:=0
File:="c:\Windows\system32\shell32.dll"
TT:=TT("OnClick=TTmsg OnClose=TTMsgClose CloseButton")
TT.Show("<a>Click Me</a>`nhello there I'm a ToolTip`n`nPress Ctrl & + or Ctrl & - to see icons of:`n<a>" File "</a>`n<a newFile>>>> Select another file</a>" ;Text
         ,"","" ;x and y coordinates
         ,"ToolTip Title") ;Title
Return
^+::
^-::
If A_ThisHotkey=^+
   i++
else
   i--
TT.Title("Icon Number: " i)
TT.Icon(File,i) ;iconFile and icon index
Return
TTMsg(TT,key){
   global File,i
   If key=
      ExitApp
   else if key=newFile
  {
      i:=1
      FileSelectFile,File,,%A_WinDir%\system32\,Select a file,*.dll;*.exe;*.*
      TT.Show("<a>Click Me</a>`nhello there I'm a ToolTip`n`nPress Ctrl & + or Ctrl & - to see icons of:`n<a>" File "</a>`n<a newFile>>>> Select another file</a>",,,"Icon Number: " i,file,i)
  }
   else if key=Click Me
      MsgBox % key
   else
      Run % "explorer.exe /e,/n,/select," key
}
TTMsgClose(TT){
   ExitApp
}
Return
*/
;: Title: TT.ahk Object based ToolTip Library by HotKeyIt
;

; Function: TT() - Object based ToolTip Library by HotKeyIt
; Description:
;      TT is based on AHK_L Objects and supports both, ANSI and UNICODE version, so to use it you will require <a href=http://www.autohotkey.com/forum/viewtopic.php?t=43049>Lexikos AutoHotkey_L.exe</a>
;      or other versions based on it that supports objects.<br><br>TT is used to work with ToolTip controls. You can create standalone ToolTips but also ToolTips for Controls of your GUI.
;      Syntax: TTObj:=TT(Options,Text,Title)
; Parameters:
;	   TTObj - ToolTip Object to control ToolTip using its functions and ToolTip messages.
;	   <b>Options</b> - <b>Description</b> (If Options is a digit or hexadecimal number TT will assume this is the parent window)
;	   <b>Options requiring a value</b> - All these options need to be followed by = and a value. For example Parent=99
;	   GUI/PARENT - Parent HWND or Gui Id (Parent can be 1-99 as well). When no Parent or GUI ID is given, GUI +LastFound will be used, when you do not want to have a parent use PARENT=0 (OnShow,OnClick,OnClose is only possible if PARENT is an AutoHotkey window)
;	   AUTOPOP / INITIAL / RESHOW - Option for Control ToolTips.<br>AUTOPOP - How long to remain visible.<br>INITIAL - Delay showing.<br>RESHOW - Delay showing between tools.<br>
;       For reference see <a href=http://msdn.microsoft.com/en-us/library/bb760404.aspx>TTM_SETDELAYTIME Message</a>.
;	   MAXWIDTH - Maximum tooltip window width, or -1 to allow any width.<br>For reference see <a href=http://msdn.microsoft.com/en-us/library/bb760408.aspx>TTM_SETMAXTIPWIDTH Message</a>.
;	    ICON - 0=none 1=info 2=warning 3=error (> 3 = hIcon). (!!! Use "" to show the image as icon from a jpg, bmp and other image files.<br>For reference see
;       <a href=http://msdn.microsoft.com/en-us/library/bb760414.aspx>TTM_SETTITLE Message</a>.<br>Since the Icon is in the title, it will appear only if there is a title.
;	   Color - RGB color for ToolTip text color.<br>For reference see <a href=http://msdn.microsoft.com/en-us/library/bb760413.aspx>TTM_SETTIPTEXTCOLOR Message</a>.
;	   BackGround - RGB ToolTip background color.<br>For reference see <a href=http://msdn.microsoft.com/en-us/library/bb760411.aspx>TTM_SETTIPBKCOLOR  Message</a>.
;	   OnClose/OnClick - A function to be launched when a ToolTip was closed or a link was clicked. ParseLinks option will be set automatically.<br><br>Links are created using <a [action]>Text</a>.
;       <br>Your OnClick function can accept up to two parameters ToolTip_Message(action[,Tool]).<br>When action is not specified Text will be used.<br>Tool is your ToolTip object that you can access
;       inside your function.<br>OnClose uses same parameters but first passed parameter will be empty.
;	   <b>Options not requiring a value<b> - <b>HWND CENTER RTL SUB TRACK ABSOLUTE TRANSPARENT PARSELINKS</b> - For reference see <a href=http://msdn.microsoft.com/en-us/library/bb760256.aspx>TOOLINFO Structure</a><br> - <b>CloseButton</b> for your ToolTip<br> - <b>ClickTrough</b> will enable clicking trough ToolTip<br> - <b>Balloon</b> ToolTip<br> - <b>Style</b> uses themed hyperlinks.<br> - <b>NoFade</b> disables fading in.<br> - <b>NoAnimate</b> disables sliding on Win2000.<br> - <b>NoPrefix</b> Prevents the system from stripping ampersand characters from a string or terminating a string at a tab character.<br> - <b>AlwaysTip</b> - Indicates that the tooltip control appears even if the tooltip control's owner window is inactive.<br> - <b>Theme</b> - Disable Theme for ToolTip, required to use features like Color, Background, Margins and more.
;	   <b>ToolTip functions</b> - <b>All function beside Add, Del, Show, Color, Remove and Text are ToolTip messages, for reference see <a href=http://msdn.microsoft.com/en-us/library/ff486069.aspx>ToolTip Messages</a>.<br>To call them use for example TTObj.TRACKACTIVATE(x,y)</b>
;	   ToolTip.<b>Add()</b> - ToolTip.Add(Control[,text,uFlags/options,parent])<br> - <b>Control</b> can be text like Button1 or hwnd of control.<br> - <b>Text</b> to be displayed.<br> - <b>uFlags/options</b> can be a value or list of strings <b>HWND CENTER RTL SUB TRACK ABSOLUTE TRANSPARENT PARSELINKS</b>.<br> - <b>Parent</b> can be a parent window, default is set in TT function, see above.<br>To enable ToolTip for Static controls like Text and Picture add 0x100 to Controls options.
;	   ToolTip.<b>Remove()</b> - Removes a ToolTip object and all control associations. Call TT_Remove() to remove all ToolTips (will be called automatically when TT object is deleted).
;	   ToolTip.<b>Del()</b> - ToolTip.Del(Control)<br>Delete a ToolTip associated with a control only, other ToolTips will remain.
;	   ToolTip.<b>Show()</b> - ToolTip.Show([Text,x,y,title,icon,iconIdx])<br>Show a ToolTip. x and y can be TrayIcon to show ToolTip at TrayIcon coordinates of your app.
;	   ToolTip.<b>Hide()</b> - Hides a ToolTip. Same as ToolTip.TrackPosition(0).<br>Note NoFade only disables fade in, to have no fade out use ToolTip.Text("")!
;	   ToolTip.<b>Color()</b> - ToolTip.Color(textcolor,backgroundcolor)<br>Used to set both colors and string colors like White,Black,Yellow,Red,Blue.... You can also use wrapped message straight away: TTObj.SETTIPBKCOLOR(RGBValue) and ToolTip.SETTIPTEXTCOLOR(RGBValue)
;	   ToolTip.<b>Font()</b> - ToolTip.Font(Font)<br>Change Font of ToolTip. Example ToolTip.Font("S20 bold italic striceout underline, Arial")
;	   ToolTip.<b>Text()</b> - ToolTip.Text(text)<br>Update text for main ToolTip (created when TT() is called).
;	   ToolTip.<b>Title()</b> - ToolTip.Title([title,icon,iconIdx])<br>Update title and icon for ToolTip. Icon can be 0 - 3 or a hIcon or a file path and iconIdx if it is an exe,dll or cur file.<br>IconIdx must be an empty string ("") if you want to load an icon from jpg, png, bmp, gif or other supported files by gdi as well as from HEX string.<br>Otherwise associated icon for given file type will be loaded.
;	   ToolTip.<b>Icon()</b> - ToolTip.Icon([icon,iconIdx])<br>Update only icon for ToolTip. Icon can be a file path, see title function. TT_GetIcon can be used to get a hIcon. "" for iconIdx will load the image as icon from jpg, bmp ... file.<br>Since the Icon is in the title, it will appear only if there is a title.
; Return Value:
;     TT returns a ToolTip object that can be used to perform all action on a ToolTip.
; Remarks:
;		When no Parent is given when calling TT(), Gui +LastFound will be used, when first parameter of TT(0x283475) is digit or xdigit, it will be used as parent.<br>Options TRACK and NOPREFIX are forced by default, to disable use TRACK=0 NOPREFIX=0.
; Related:
; Example:
;		file:TT_Example.ahk
;
TT_Init(){ ;initialize structures function
  global _TOOLINFO:="cbSize,uFlags,PTR hwnd,PTR uId,_RECT rect,PTR hinst,LPTSTR lpszText,PTR lParam,void *lpReserved"
  ,_RECT:="left,top,right,bottom"
  ,_NMHDR:="HWND hwndFrom,UINT_PTR idFrom,UINT code"
  ,_NMTVGETINFOTIP:="_NMHDR hdr,UINT uFlags,UInt link"
  ,_CURSORINFO:="cbSize,flags,HCURSOR hCursor,x,y"
  ,_ICONINFO:="fIcon,xHotspot,yHotSpot,HBITMAP hbmMask,HBITMAP hbmColor"
  ,_BITMAP:="LONG bmType,LONG bmWidth,LONG bmHeight,LONG bmWidthBytes,WORD bmPlanes,WORD bmBitsPixel,LPVOID bmBits"
  ,_SHFILEINFO:="HICON hIcon,iIcon,DWORD dwAttributes,TCHAR szDisplayName[260],TCHAR szTypeName[80]"
  ,_TBBUTTON:="iBitmap,idCommand,BYTE fsState,BYTE fsStyle,BYTE bReserved[" (A_PtrSize=8?6:2) "],DWORD_PTR dwData,INT_PTR iString"
  static _:={base:{__Delete:"TT_Delete"}}
  return _
}
TT(options:="",text:="",title:=""){
  global _RECT,_TOOLINFO
  ; Options
  ;WS_POPUP=0x80000000,TTS_ALWAYSTIP=0x1,TTS_NOPREFIX=0x2,TTS_USEVISUALSTYLE=0x100,TTS_NOFADE=0x20,TTS_NOANIMATE=0x10
  static HWND_TOPMOST:=-1,SWP_NOMOVE:=0x2, SWP_NOSIZE:=0x1, SWP_NOACTIVATE:=0x10
	;~ static _RECT:="left,top,right,bottom"
	;~ static _TOOLINFO:="cbSize,uFlags,PTR hwnd,PTR uId,_RECT rect,PTR hinst,LPTSTR lpszText,PTR lParam,void *lpReserved"
  ; Objects
  static _:=TT_Init(),base:={Color:"TT_Color",Show:"TT_Show",Hide:"TTM_Trackactivate",Close:"TT_Close",Add:"TT_Add",AddTool:"TTM_AddTool"
      ,Del:"TT_Del",Title:"TTM_SetTitle",Text:"TT_Text",ACTIVATE:"TTM_ACTIVATE",Set:"TT_Set"
      ,ADDTOOL:"TTM_ADDTOOL",Remove:"TT_Remove",Icon:"TT_Icon",Font:"TT_Font",ADJUSTRECT:"TTM_ADJUSTRECT"
      ,DELTOOL:"TTM_DELTOOL",ENUMTOOLS:"TTM_ENUMTOOLS",GETBUBBLESIZE:"TTM_GETBUBBLESIZE"
      ,GETCURRENTTOOL:"TTM_GETCURRENTTOOL",GETDELAYTIME:"TTM_GETDELAYTIME",GETMARGIN:"TTM_GETMARGIN"
      ,GETMAXTIPWIDTH:"TTM_GETMAXTIPWIDTH",GETTEXT:"TTM_GETTEXT",GETTIPBKCOLOR:"TTM_GETTIPBKCOLOR"
      ,GETTIPTEXTCOLOR:"TTM_GETTIPTEXTCOLOR",GETTITLE:"TTM_GETTITLE",GETTOOLCOUNT:"TTM_GETTOOLCOUNT"
      ,GETTOOLINFO:"TTM_GETTOOLINFO",HITTEST:"TTM_HITTEST",NEWTOOLRECT:"TTM_NEWTOOLRECT",POP:"TTM_POP"
      ,POPUP:"TTM_POPUP",RELAYEVENT:"TTM_RELAYEVENT",SETDELAYTIME:"TTM_SETDELAYTIME",SETMARGIN:"TTM_SETMARGIN"
      ,SETMAXTIPWIDTH:"TTM_SETMAXTIPWIDTH",SETTIPBKCOLOR:"TTM_SETTIPBKCOLOR",SETTIPTEXTCOLOR:"TTM_SETTIPTEXTCOLOR"
      ,SETTITLE:"TTM_SETTITLE",SETTOOLINFO:"TTM_SETTOOLINFO",SETWINDOWTHEME:"TTM_SETWINDOWTHEME"
      ,TRACKACTIVATE:"TTM_TRACKACTIVATE",TRACKPOSITION:"TTM_TRACKPOSITION",UPDATE:"TTM_UPDATE"
      ,UPDATETIPTEXT:"TTM_UPDATETIPTEXT",WINDOWFROMPOINT:"TTM_WINDOWFROMPOINT"
      ,"base":{__Call:"TT_Set"}}
  Parent:="",Gui:="",ClickTrough:="",Style:="",NOFADE:="",NoAnimate:="",NOPREFIX:="",AlwaysTip:="",ParseLinks:="",CloseButton:="",Balloon:="",maxwidth:=""
  ,INITIAL:="",AUTOPOP:="",RESHOW:="",OnClick:="",OnClose:="",OnShow:="",ClickHide:="",HWND:="",Center:="",RTL:="",SUB:="",Track:="",Absolute:=""
  ,TRANSPARENT:="",Color:="",Background:="",icon:=0
  if (options+0!="")
    Parent:=options
  else If (options){
    Loop,Parse,options,%A_Space%,%A_Space%
      If (istext){
        If (SubStr(A_LoopField,0)="'")
          %istext%:=string A_Space SubStr(A_LoopField,1,StrLen(A_LoopField)-1),istext:="",string:=""
        else
          string.= A_Space A_LoopField
      } else If (A_LoopField ~= "i)AUTOPOP|INITIAL|PARENT|RESHOW|MAXWIDTH|ICON|Color|BackGround|OnClose|OnClick|OnShow|GUI|NOPREFIX|TRACK")
      {
        RegExMatch(A_LoopField,"^(\w+)=?(.*)?$",option)
        If ((Asc(option2)=39 && SubStr(A_LoopField,0)!="'") && (istext:=option1) && (string:=SubStr(option2,2)))
          Continue
        %option1%:=option2
      } else if ( option2:=InStr(A_LoopField,"=")){
        option1:=SubStr(A_LoopField,1,option2-1)
        %option1%:=SubStr(A_LoopField,option2+1)
      } else if (A_LoopField)
        %A_LoopField% := 1
  }
	If (Parent && Parent<100 && !DllCall("IsWindow","PTR",Parent)){
    Gui,%Parent%:+LastFound
    Parent:=WinExist()
  } else if (GUI){
    Gui, %GUI%:+LastFound
    Parent:=WinExist()
  } else if (Parent=""){
    Parent:=A_ScriptHwnd
  }
  T:=Object("base",base)
  ,T.HWND := DllCall("CreateWindowEx", "UInt", (ClickTrough?0x20:0)|0x8, "str", "tooltips_class32", "PTR", 0
         , "UInt",0x80000000|(Style?0x100:0)|(NOFADE?0x20:0)|(NoAnimate?0x10:0)|((NOPREFIX+1)?(NOPREFIX?0x2:0x2):0x2)|(AlwaysTip?0x1:0)|(ParseLinks?0x1000:0)|(CloseButton?0x80:0)|(Balloon?0x40:0)
         , "int",0x80000000,"int",0x80000000,"int",0x80000000,"int",0x80000000, "PTR",Parent?Parent:0,"PTR",0,"PTR",0,"PTR",0,"PTR")
  ,DllCall("SetWindowPos","PTR",T.HWND,"PTR",HWND_TOPMOST,"Int",0,"Int",0,"Int",0,"Int",0
                           ,"UInt",SWP_NOMOVE|SWP_NOSIZE|SWP_NOACTIVATE)
  ,_.Insert(T)
  ,T.SETMAXTIPWIDTH(MAXWIDTH?MAXWIDTH:A_ScreenWidth)
  If !(AUTOPOP INITIAL RESHOW)
    T.SETDELAYTIME()
  else T.SETDELAYTIME(2,AUTOPOP?AUTOPOP:-1),T.SETDELAYTIME(3,INITIAL?INITIAL:-1),T.SETDELAYTIME(1,RESHOW?RESHOW:-1)
  T.fulltext:=text,T.maintext:=RegExReplace(text,"<a\K[^<]*?>",">")
  If (OnClick)
    ParseLinks:=1
  T.rc:=Struct(_RECT) ;for TTM_SetMargin
  ;Tool for Main ToolTip
  ,T.P:=Struct(_TOOLINFO),P:=T.P,P.cbSize:=sizeof(_TOOLINFO)
	,P.uFlags:=(HWND?0x1:0)|(Center?0x2:0)|(RTL?0x4:0)|(SUB?0x10:0)|(Track+1?(Track?0x20:0):0x20)|(Absolute?0x80:0)|(TRANSPARENT?0x100:0)|(ParseLinks?0x1000:0)
	,P.hwnd:=Parent
	,P.uId:=Parent
	,P.lpszText[""]:=T.GetAddress("maintext")?T.GetAddress("maintext"):0
	,T.AddTool(P[])
  If (Theme)
    T.SETWINDOWTHEME()
  If (Color)
    T.SETTIPTEXTCOLOR(Color)
  If (Background)
    T.SETTIPBKCOLOR(BackGround)
  T.SetTitle(T.maintitle:=title,icon)
  If ((T.OnClick:=OnClick)||(T.OnClose:=OnClose)||(T.OnShow:=OnShow))
    T.OnClose:=OnClose,T.OnShow:=OnShow,T.ClickHide:=ClickHide,OnMessage(0x4e,A_ScriptHwnd,"TT_OnMessage")
  Return T
}
TT_Delete(this){ ;delete all ToolTips (will be executed OnExit)
	Loop % this.MaxIndex()
	{
	  this[i:=A_Index].DelTool(this[i].P[])
	  ,DllCall("DestroyWindow","PTR",this[i].HWND)
	  for id,tool in this[i].T
		this[i].DelTool(tool[])
	  this.Remove(i)
	}
	TT_GetIcon() ;delete ToolTips and Destroy all icon handles
}
TT_Remove(T:=""){
	static _:=TT_Init() ;Get main object that holds all ToolTips
	for id,Tool in _
	{
	  If (T=Tool){
			_[id]:=_[_.MaxIndex()],_.Remove(id)
			for id,tools in Tool.T
			  Tool.DelTool(tools[])
			Tool.DelTool(Tool.P[])
			,DllCall("DestroyWindow","PTR",Tool.HWND)
			break
	  }
	}
}
TT_OnMessage(wParam,lParam,msg,hwnd){
  global _NMTVGETINFOTIP,_NMHDR
  static TTN_FIRST:=0xfffffdf8, _:=TT_Init() ;Get main object that holds all ToolTips
        ,HDR:=Struct(_NMTVGETINFOTIP)
  HDR[]:=lParam
  If !InStr(".1.2.3.","." (m:= TTN_FIRST-HDR.hdr.code) ".")
    Return
  p:=HDR.hdr.hwndFrom
  for id,T in _
    If (p=T.hwnd)
      break
  for id,object in _
    If (p=object.hwnd && T:=object)
      break
  text:=T.fulltext
  If (m=1){ 							;Show
    If IsFunc(T.OnShow)
      T.OnShow(T,"")
  } else If (m=2){ 					;Close
    If IsFunc(T.OnClose)
      T.OnClose(T,"")
    T.TRACKACTIVATE(0,T.P[])
  } else If InStr(text,"<a"){	;Click
    If (T.ClickHide)
      T.TRACKACTIVATE(0,T.P[])
    If (SubStr(LTrim(text:=SubStr(text,InStr(text,"<a",0,1,HDR.link+1)+2)),1,1)=">")
      action:=SubStr(text,InStr(text,">")+1,InStr(text,"</a>")-InStr(text,">")-1)
    else action:=Trim(action:=SubStr(text,1,InStr(text,">")-1))
    If IsFunc(func:=T.OnClick)
      T.OnClick(T,action)
  }
  Return true
}
TT_ADD(T,Control,Text:="",uFlags:="",Parent:=""){
  Global _TOOLINFO
  ;	uFlags http://msdn.microsoft.com/en-us/library/bb760256.aspx
  ; TTF_ABSOLUTE=0x80, TTF_CENTERTIP=0x0002, TTF_IDISHWND=0x1, TTF_PARSELINKS=0x1000 ,TTF_RTLREADING = 0x4
  ; TTF_SUBCLASS=0x10, TTF_TRAMsgCK=0x20, TTF_TRANSPARENT=0x100
	;~  _TOOLINFO:="cbSize,uFlags,PTR hwnd,PTR uId,_RECT rect,PTR hinst,LPTSTR lpszText,PTR lParam,void *lpReserved"
  DetectHiddenWindows:=A_DetectHiddenWindows
  DetectHiddenWindows,On
  if (Parent){
    If (Parent && Parent<100 and !DllCall("IsWindow","PTR",Parent)){
      Gui %Parent%:+LastFound
      Parent:=WinExist()
    }
    T["T",Abs(Parent)]:=Tool:=Struct(_TOOLINFO)
    ,Tool.uId:=Parent,Tool.hwnd:=Parent,Tool.uFlags:=(0|16)
    ,DllCall("GetClientRect","PTR",T.HWND,"PTR", T[Abs(Parent)].rect[])
    ,T.ADDTOOL(T["T",Abs(Parent)][])
  }
  If (text="")
    ControlGetText,text,%Control%,% "ahk_id " (Parent?Parent:T.P.hwnd)
  If (Control+0="")
    ControlGet,Control,Hwnd,,%Control%,% "ahk_id " (Parent?Parent:T.P.hwnd)
  If (uFlags)
    If (uFlags+0="")
    {
      Loop,Parse,uflags,%A_Space%,%A_Space%
        If (A_LoopField)
          %A_LoopField% := 1
      uFlags:=(HWND?0x1:HWND=""?0x1:0)|(Center?0x2:0)|(RTL?0x4:0)|(SUB?0x10:0)|(Track?0x20:0)|(Absolute?0x80:0)|(TRANSPARENT?0x100:0)|(ParseLinks?0x1000:0)
    }
  Tool:=T["T",Abs(Control)]:=Struct(_TOOLINFO)
  ,Tool.cbSize:=sizeof(_TOOLINFO)
  ,T[Abs(Control),"text"]:=RegExReplace(text,"<a\K[^<]*?>",">")
  ,Tool.uId:=Control,Tool.hwnd:=Parent?Parent:T.P.hwnd,Tool.uFlags:=uFlags?(uFlags|16):(1|16)
  ,Tool.lpszText[""]:=T[Abs(Control)].GetAddress("text")
  ,DllCall("GetClientRect","PTR",T.HWND,"PTR",Tool.rect[])
  T.ADDTOOL(Tool[])
  DetectHiddenWindows,%DetectHiddenWindows%
}
TT_DEL(T,Control){
  If (!Control)
    Return 0
  If (Control+0="")
    ControlGet,Control,Hwnd,,%Control%,% "ahk_id " t.P.hwnd
   T.DELTOOL(T.T[Abs(Control)][]),T.T.Remove(Abs(Control))
}
TT_Color(T,Color:="",Background:=""){
  static TTM_SETTIPBKCOLOR:=0x413,TTM_SETTIPTEXTCOLOR:=0x414
    ,Black:=0x000000,Green:=0x008000,Silver:=0xC0C0C0,Lime:=0x00FF00,Gray:=0x808080,Olive:=0x808000
    ,White:=0xFFFFFF,Yellow:=0xFFFF00,Maroon:=0x800000,Navy:=0x000080,Red:=0xFF0000,Blue:=0x0000FF
    ,Purple:=0x800080,Teal:=0x008080,Fuchsia:=0xFF00FF,Aqua:=0x00FFFF
  If (Color!="")
    T.SETTIPTEXTCOLOR(Color)
  If (BackGround!="")
    T.SETTIPBKCOLOR(BackGround)
}
TT_Text(T,text){
  static TTM_UPDATETIPTEXT:=0x400+(A_IsUnicode?57:12),TTM_UPDATE:=0x400+29
	T.fulltext:=text,T.maintext:=RegExReplace(text,"<a\K[^<]*?>",">"),T.P.lpszText[""]:=text!=""?T.GetAddress("maintext"):0
  ,T.UPDATETIPTEXT()
}
TT_Icon(T,icon:=0,icon_:=1,default:=1){
   static TTM_SETTITLE := 0x400 + (A_IsUnicode ? 33 : 32)
  If icon
    If (icon+0="")
      If !icon:=TT_GetIcon(icon,icon_)
				icon:=default
   Return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_SETTITLE,"PTR",icon+0,"PTR",T.GetAddress("maintitle"),"PTR"),T.UPDATE()
}
TT_GetIcon(File:="",Icon_:=1){
  global _ICONINFO,_SHFILEINFO
  static hIcon:={},AW:=A_IsUnicode?"W":"A",pToken:=0
   ,temp1:=DllCall( "LoadLibrary", "Str","gdiplus","PTR"),temp2:=VarSetCapacity(si, 16, 0) (si := Chr(1)) DllCall("gdiplus\GdiplusStartup", "PTR*",pToken, "PTR",&si, "PTR",0)
	;~ static _ICONINFO:="fIcon,xHotspot,yHotSpot,HBITMAP hbmMask,HBITMAP hbmColor"
	;~ static _SHFILEINFO:="HICON hIcon,iIcon,DWORD dwAttributes,TCHAR szDisplayName[260],TCHAR szTypeName[80]"
	static sfi:=Struct(_SHFILEINFO),sfi_size:=sizeof(_SHFILEINFO),SmallIconSize:=DllCall("GetSystemMetrics","Int",49)
	If !File {
    for file,obj in hIcon
      If IsObject(obj){
        for icon,handle in obj
          DllCall("DestroyIcon","PTR",handle)
      } else
        DllCall("DestroyIcon","PTR",handle)
    ; DllCall("gdiplus\GdiplusShutdown", "PTR",pToken) ; not done anymore since it is loaded before script starts
    Return
  }
	If (CR:=InStr(File,"`r") || LF:=InStr(File,"`n"))
		File:=SubStr(file,1,CR<LF?CR-1:LF-1) ; this is a local parameter so we can change the memory
  If (hIcon[File,Icon_])
    Return hIcon[file,Icon_]
  else if (hIcon[File] && !IsObject(hIcon[File]))
    return hIcon[File]
  SplitPath,File,,,Ext
  if (hIcon[Ext] && !IsObject(hIcon[Ext]))
    return hIcon[Ext]
  else If (ext = "cur")
    Return hIcon[file,Icon_]:=DllCall("LoadImageW", "PTR", 0, "str", File, "uint", ext="cur"?2:1, "int", 0, "int", 0, "uint", 0x10,"PTR")
  else if InStr(",EXE,ICO,DLL,LNK,","," Ext ","){
    If (ext="LNK"){
       FileGetShortcut,%File%,Fileto,,,,FileIcon,FileIcon_
       File:=!FileIcon ? FileTo : FileIcon
    }
    SplitPath,File,,,Ext
    DllCall("PrivateExtractIcons", "Str", File, "Int", Icon_-1, "Int", SmallIconSize, "Int", SmallIconSize, "PTR*", Icon, "PTR*", 0, "UInt", 1, "UInt", 0, "Int")
    Return hIcon[File,Icon_]:=Icon
  } else if (Icon_=""){
    If !FileExist(File){
      if RegExMatch(File,"^[0-9A-Fa-f]+$") ;assume Hex string
      {
        nSize := StrLen(File)//2
        VarSetCapacity( Buffer,nSize )
        Loop % nSize
          NumPut( "0x" . SubStr(File,2*A_Index-1,2), Buffer, A_Index-1, "Char" )
      } else Return
    } else {
      FileGetSize,nSize,%file%
      FileRead,Buffer,*c %file%
    }
    hData := DllCall("GlobalAlloc", "UInt",2, "UInt", nSize,"PTR")
    ,pData := DllCall("GlobalLock", "PTR",hData,"PTR")
    ,DllCall( "RtlMoveMemory", "PTR",pData, "PTR",&Buffer, "UInt",nSize )
    ,DllCall( "GlobalUnlock", "PTR",hData )
    ,DllCall( "ole32\CreateStreamOnHGlobal", "PTR",hData, "Int",True, "PTR*",pStream )
    ,DllCall( "gdiplus\GdipCreateBitmapFromStream", "UInt",pStream, "PTR*",pBitmap )
    ,DllCall( "gdiplus\GdipCreateHBITMAPFromBitmap", "PTR",pBitmap, "PTR*",hBitmap, "UInt",0 )
    ,DllCall( "gdiplus\GdipDisposeImage", "PTR",pBitmap )
    ,ii:=Struct(_ICONINFO)
    ,ii.ficon:=1,ii.hbmMask:=hBitmap,ii.hbmColor:=hBitmap
    return hIcon[File]:=DllCall("CreateIconIndirect","PTR",ii[],"PTR")
  } else If DllCall("Shell32\SHGetFileInfo" AW, "str", File, "uint", 0, "PTR", sfi[], "uint", sfi_size, "uint", 0x101,"PTR")
      Return hIcon[Ext] := sfi.hIcon
}
TT_Close(T){
  T.text("")
}
TT_Show(T,text:="",x:="",y:="",title:="",icon:=0,icon_:=1,defaulticon:=1){
  global _TBBUTTON,_BITMAP,_ICONINFO,_CURSORINFO,_RECT
  ;~ static _TBBUTTON:="iBitmap,idCommand,BYTE fsState,BYTE fsStyle,BYTE bReserved[" (A_PtrSize=8?6:2) "],DWORD_PTR dwData,INT_PTR iString"
	;~ static _BITMAP:="LONG bmType,LONG bmWidth,LONG bmHeight,LONG bmWidthBytes,WORD bmPlanes,WORD bmBitsPixel,LPVOID bmBits"
	;~ static _ICONINFO:="fIcon,xHotspot,yHotSpot,HBITMAP hbmMask,HBITMAP hbmColor"
	;~ static _CURSORINFO:="cbSize,flags,HCURSOR hCursor,x,y"
  static pcursor:= Struct(_CURSORINFO),init:=(pcursor.cbSize:=sizeof(_CURSORINFO))
        ,picon:=Struct(_ICONINFO) ,pbitmap:=Struct(_BITMAP)
        ,TB:=Struct(_TBBUTTON) ,RC:=Struct(_RECT)
  xo:=0,xs:=0,yo:=0,ys:=0
  If (Text!="")
    T.Text(text)
  If (title!="")
    T.SETTITLE(title,icon,icon_,defaulticon)
  If (x="TrayIcon" || y="TrayIcon"){
    DetectHiddenWindows,% (DetectHiddenWindows:=A_DetectHiddenWindows ? "On" : "On")
		PID:=DllCall("GetCurrentProcessId")
    hWndTray:=WinExist("ahk_class Shell_TrayWnd")
    ControlGet,hWndToolBar,Hwnd,,ToolbarWindow321,ahk_id %hWndTray%
    WinGet, procpid, Pid, ahk_id %hWndToolBar%
    DataH   := DllCall( "OpenProcess", "uint", 0x38, "int", 0, "uint", procpid,"PTR") ;0x38 = PROCESS_VM_OPERATION+READ+WRITE
    ,bufAdr  := DllCall( "VirtualAllocEx", "PTR", DataH, "PTR", 0, "uint", sizeof(_TBBUTTON), "uint", MEM_COMMIT:=0x1000, "uint", PAGE_READWRITE:=0x4,"PTR")
	Loop % max:=DllCall("SendMessage","PTR",hWndToolBar,"UInt",0x418,"PTR",0,"PTR",0,"PTR")
    {
      i:=max-A_Index
      DllCall("SendMessage","PTR",hWndToolBar,"UInt",0x417,"PTR",i,"PTR",bufAdr,"PTR")
      ,DllCall("ReadProcessMemory", "PTR", DataH, "PTR", bufAdr, "PTR", TB[], "ptr", sizeof(TB), "ptr", 0)
      ,DllCall("ReadProcessMemory", "PTR", DataH, "PTR", TB.dwData, "PTR", RC[], "PTR", 8, "PTR", 0)
	  WinGet,BWPID,PID,% "ahk_id " NumGet(RC[],0,"PTR")
	  If (BWPID!=PID)
        continue
      If (TB.fsState>7){
        ControlGetPos,xc,yc,xw,yw,Button2,ahk_id %hWndTray%
        xc+=xw/2, yc+=yw/4
      } else {
        ControlGetPos,xc,yc,,,ToolbarWindow321,ahk_id %hWndTray%
        DllCall("SendMessage","PTR",hWndToolBar,"UInt",0x41d,"PTR",i,"PTR",bufAdr,"PTR")
        ,DllCall( "ReadProcessMemory", "PTR", DataH, "PTR", bufAdr, "PTR", RC[], "PTR", sizeof(RC), "PTR", 0 )
        ,halfsize:=RC.bottom/2
        ,xc+=RC.left + halfsize
        ,yc+=RC.top + (halfsize/1.5)
      }
      WinGetPos,xw,yw,,,ahk_id %hWndTray%
      xc+=xw,yc+=yw
      ;~ xc:=Round(xc,0),yc:=Round(yc,0)
      break
    }
    If (!xc && !yc){
      If (A_OsVersion~="i)Win_7|WIN_VISTA")
          ControlGetPos,xc,yc,xw,yw,Button1,ahk_id %hWndTray%
        else
          ControlGetPos,xc,yc,xw,yw,Button2,ahk_id %hWndTray%
      xc+=xw/2, yc+=yw/4
      WinGetPos,xw,yw,,,ahk_id %hWndTray%
      xc+=xw,yc+=yw
    }
    DllCall( "VirtualFreeEx", "PTR", DataH, "PTR", bufAdr, "PTR", 0, "uint", MEM_RELEASE:=0x8000)
    ,DllCall( "CloseHandle", "PTR", DataH )
    DetectHiddenWindows % DetectHiddenWindows
    If (x="TrayIcon")
      x:=xc
    If (y="TrayIcon")
      y:=yc
  }
  If (x ="" || y =""){
    pCursor.cbSize:=sizeof(pCursor)
    ,DllCall("GetCursorInfo", "ptr", pCursor[])
    ,DllCall("GetIconInfo", "ptr", pCursor.hCursor, "ptr", pIcon[])
    If (picon.hbmColor)
      DllCall("DeleteObject", "ptr", pIcon.hbmColor)
    DllCall("GetObject", "ptr", pIcon.hbmMask, "uint", sizeof(_BITMAP), "ptr", pBitmap[])
    ,hbmo := DllCall("SelectObject", "ptr", cdc:=DllCall("CreateCompatibleDC", "ptr", sdc:=DllCall("GetDC","ptr",0,"ptr"),"ptr"), "ptr", pIcon.hbmMask)
    ,w:=pBitmap.bmWidth,h:=pBitmap.bmHeight, h:= h=w*2 ? (h//2,c:=0xffffff,s:=32) : (h,c:=s:=0)
    Loop % w {
      xi := A_Index - 1
      Loop % h {
        yi := A_Index - 1 + s
        if (DllCall("GetPixel", "ptr", cdc, "uint", xi, "uint", yi) = c) {
          if (xo < xi)
             xo := xi
          if (xs = "" || xs > xi)
             xs := xi
          if (yo < yi)
             yo := yi
          if (ys = "" || ys > yi)
             ys := yi
        }
      }
    }
    DllCall("ReleaseDC", "ptr", 0, "ptr", sdc)
    ,DllCall("DeleteDC", "ptr", cdc)
    ,DllCall("DeleteObject", "ptr", hbmo)
    ,DllCall("DeleteObject", "ptr", picon.hbmMask)
    If (y=""){
      SysGet,yl,77
      SysGet,yr,79
      y:=pCursor.y-pIcon.yHotspot+ys+(yo-ys)-s+1
      If !(y >= yl && y <= yr)
        y:=y<yl ? yl : yr
      If (y > yr - 20)
        y := yr - 20
    }
    If (x=""){
      SysGet,xr,78
      SysGet,xl,76
      x:=pCursor.x-pIcon.xHotspot+xs+(xo-xs)+1
      If !(x >= xl && x <= xr)
        x:=x<xl ? xl : xr
    }
  }
  ; ControlFocus,Edit1,% "ahk_id " A_ScriptHwnd
  ; ControlFocus,,% "ahk_id " T.hwnd
  T.TRACKPOSITION(x,y),T.TRACKACTIVATE(1)
  ;DllCall("SetWindowPos","PTR",T.hwnd,"PTR",0,"Int",0,"Int",0,"Int",0,"Int",0x1|0x2|0x10|0x8|0x200|0x400)
  ; ControlFocus,,% "ahk_id " T.hwnd
}
TT_Set(T,option:="",OnOff:=1){
  static Style:=0x100,NOFADE:=0x20,NoAnimate:=0x10,NOPREFIX:=0x2,AlwaysTip:=0x1,ParseLinks:=0x1000,CloseButton:=0x80,Balloon:=0x40,ClickTrough:=0x20
  If (option ~="i)Style|NOFADE|NoAnimate|NOPREFIX|AlwaysTip|ParseLinks|CloseButton|Balloon"){
    If ((opt:=DllCall("GetWindowLong","PTR",T.HWND,"UInt",-16) & %option%) && !OnOff) || (!opt && OnOff)
      DllCall("SetWindowLong","PTR",T.HWND,"UInt",-16,"UInt",DllCall("GetWindowLong","PTR",T.HWND,"UInt",-16)+(OnOff?(%option%):(-%option%)))
	T.Update()
  } else If (option="ClickTrough"){
    If ((opt:=DllCall("GetWindowLong","PTR",T.HWND,"UInt",-20) & %option%) && !OnOff) || (!opt && OnOff)
      DllCall("SetWindowLong","PTR",T.HWND,"UInt",-20,"UInt",DllCall("GetWindowLong","PTR",T.HWND,"UInt",-20)+(OnOff?(%option%):(-%option%)))
	T.Update()
  } else if !InStr(",__Delete,Push,Pop,InsertAt,Remove,RemoveAt,GetCapacity,SetCapacity,GetAddress,Length,_NewEnum,NewEnum,HasKey,Clone,Count,","," option ",")
    MsgBox Invalid option: %option%
}
TT_Font(T, pFont:="") { ;Taken from HE_SetFont, thanks majkinetor. http://www.autohotkey.com/forum/viewtopic.php?p=124450#124450
   static WM_SETFONT := 0x30

 ;parse font
   italic      := InStr(pFont, "italic")    ?  1    :  0
   underline   := InStr(pFont, "underline") ?  1    :  0
   strikeout   := InStr(pFont, "strikeout") ?  1    :  0
   weight      := InStr(pFont, "bold")      ? 700   : 400

 ;height
   RegExMatch(pFont, "O)(?<=[S|s])(\d{1,2})(?=[ ,])?", height)
   if (!height.count())
      height := [10]
   RegRead,LogPixels,HKEY_LOCAL_MACHINE,SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontDPI, LogPixels

   height := -DllCall("MulDiv", "int", Height.1, "int", LogPixels, "int", 72)

 ;face
   RegExMatch(pFont, "O)(?<=,).+", fontFace)
   if (fontFace.Value())
    fontFace := Trim( fontFace.Value())      ;trim
   else fontFace := "MS Sans Serif"
  If (pFont && !InStr(pFont,",") && (italic+underline+strikeout+weight)=400)
    fontFace:=pFont

 ;create font
  If (T.hFont)
      DllCall("DeleteObject","PTR",T.hfont)
  T.hFont   := DllCall("CreateFont", "int",  height, "int",  0, "int",  0, "int", 0
                      ,"int",  weight,   "Uint", italic,   "Uint", underline
                      ,"uint", strikeOut, "Uint", nCharSet, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0, "str", fontFace,"PTR")
  Return DllCall("SendMessage","PTR",T.hwnd,"UInt",WM_SETFONT,"PTR",T.hFont,"PTR",TRUE,"PTR")
}
TTM_ACTIVATE(T,Activate:=0){
   static TTM_ACTIVATE := 0x400 + 1
   Return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_ACTIVATE,"PTR",activate,"PTR",0,"PTR")
}
TTM_ADDTOOL(T,pTOOLINFO){
   static TTM_ADDTOOL := A_IsUnicode ? 0x432 : 0x404
   Return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_ADDTOOL,"PTR",0,"PTR",pTOOLINFO,"PTR")
}
TTM_ADJUSTRECT(T,action,prect){
   static TTM_ADJUSTRECT := 0x41f
   Return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_ADJUSTRECT,"PTR",action,"PTR",prect,"PTR")
}
TTM_DELTOOL(T,pTOOLINFO){
   static TTM_DELTOOL := A_IsUnicode ? 0x433 : 0x405
   Return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_DELTOOL,"PTR",0,"PTR",pTOOLINFO,"PTR")
}
TTM_ENUMTOOLS(T,idx,pTOOLINFO){
   static TTM_ENUMTOOLS := A_IsUnicode?0x43a:0x40e
   Return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_ENUMTOOLS,"PTR",idx,"PTR",pTOOLINFO,"PTR")
}
TTM_GETBUBBLESIZE(T,pTOOLINFO){
   static TTM_GETBUBBLESIZE := 0x41e
   Return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_GETBUBBLESIZE,"PTR",0,"PTR",pTOOLINFO,"PTR")
}
TTM_GETCURRENTTOOL(T,pTOOLINFO){
   static TTM_GETCURRENTTOOL := 0x400 + (A_IsUnicode ? 59 : 15)
   return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_GETCURRENTTOOL,"PTR",0,"PTR",pTOOLINFO,"PTR")
}
TTM_GETDELAYTIME(T,whichtime){
  ;TTDT_RESHOW = 1; TTDT_AUTOPOP = 2; TTDT_INITIAL = 3
   static TTM_GETDELAYTIME := 0x400 + 21
   return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_GETDELAYTIME,"PTR",whichtime,"PTR",0,"PTR")
}
TTM_GETMARGIN(T,pRECT){
   static TTM_GETMARGIN := 0x41b
   Return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_GETMARGIN,"PTR",0,"PTR",pRECT,"PTR")
}
TTM_GETMAXTIPWIDTH(T,wParam:=0,lParam:=0){
   static TTM_GETMAXTIPWIDTH := 0x419
   return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_GETMAXTIPWIDTH,"PTR",0,"PTR",0,"PTR")
}
TTM_GETTEXT(T,buffer,pTOOLINFO){
   static TTM_GETTEXT := A_IsUnicode?0x438:0x40b
   Return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_GETTEXT,"PTR",buffer,"PTR",pTOOLINFO,"PTR")
}
TTM_GETTIPBKCOLOR(T,wParam:=0,lParam:=0){
   static TTM_GETTIPBKCOLOR := 0x416
   return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_GETTIPBKCOLOR,"PTR",0,"PTR",0,"PTR")
}
TTM_GETTIPTEXTCOLOR(T,wParam:=0,lParam:=0){
   static TTM_GETTIPTEXTCOLOR := 0x417
   return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_GETTIPTEXTCOLOR,"PTR",0,"PTR",0,"PTR")
}
TTM_GETTITLE(T,pTTGETTITLE){
  ;struct("TTGETTITLE:DWORD dwSize,PTR uTitleBitmap,PTR cch,WCHAR *pszTitle")
   static TTM_GETTITLE := 0x423
   Return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_GETTITLE,"PTR",0,"PTR",pTTGETTITLE,"PTR")
}
TTM_GETTOOLCOUNT(T,wParam:=0,lParam:=0){
   static TTM_GETTOOLCOUNT := 0x40d
   return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_GETTOOLCOUNT,"PTR",0,"PTR",0,"PTR")
}
TTM_GETTOOLINFO(T,pTOOLINFO){
   static TTM_GETTOOLINFO := 0x400 + (A_IsUnicode ? 53 : 8)
   return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_GETTOOLINFO,"PTR",0,"PTR",pTOOLINFO,"PTR")
}
TTM_HITTEST(T,pTTHITTESTINFO){
  ;struct("TTHITTESTINFO:HWND hwnd,POINT pt,TOOLINFO ti")
   static TTM_HITTEST := A_IsUnicode?0x437:0x40a
   return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_HITTEST,"PTR",0,"PTR",pTTHITTESTINFO,"PTR")
}
TTM_NEWTOOLRECT(T,pTOOLINFO:=0){
   static TTM_NEWTOOLRECT := 0x400 + (A_IsUnicode ? 52 : 6)
   Return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_NEWTOOLRECT,"PTR",0,"PTR",pTOOLINFO?pTOOLINFO:T.P[],"PTR")
}
TTM_POP(T,wParam:=0,lParam:=0){
   static TTM_POP := 0x400 + 28
   Return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_POP,"PTR",0,"PTR",0,"PTR")
}
TTM_POPUP(T,wParam:=0,lParam:=0){
   static TTM_POPUP := 0x422
   Return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_POPUP,"PTR",0,"PTR",0,"PTR")
}
TTM_RELAYEVENT(T,wParam:=0,lParam:=0){
  ;struct("MSG:HWND hwnd,PTR message,WPARAM wParam,LPARAM lParam,DWORD time,POINT pt")
   static TTM_RELAYEVENT := 0x407
   Return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_RELAYEVENT,"PTR",0,"PTR",0,"PTR")
}
TTM_SETDELAYTIME(T,whichTime:=0,mSec:=-1){
  ;TTDT_AUTOMATIC = 0; TTDT_RESHOW = 1; TTDT_AUTOPOP = 2; TTDT_INITIAL = 3
   static TTM_SETDELAYTIME := 0x400 + 3
   Return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_SETDELAYTIME,"PTR",whichTime,"PTR",mSec,"PTR")
}
TTM_SETMARGIN(T,left:=0,top:=0,right:=0,bottom:=0){
   static TTM_SETMARGIN := 0x41a
  rc:=T.rc,rc.top:=top,rc.left:=left,rc.bottom:=bottom,rc.right:=right
  Return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_SETMARGIN,"PTR",0,"PTR",rc[],"PTR")
}
TTM_SETMAXTIPWIDTH(T,maxwidth:=-1){
   static TTM_SETMAXTIPWIDTH := 0x418
   return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_SETMAXTIPWIDTH,"PTR",0,"PTR",maxwidth,"PTR")
}
TTM_SETTIPBKCOLOR(T,color:=0){
   static TTM_SETTIPBKCOLOR := 0x413
      ,Black:=0x000000,    Green:=0x008000,		Silver:=0xC0C0C0,		Lime:=0x00FF00
      ,Gray:=0x808080,    	Olive:=0x808000,		White:=0xFFFFFF,   	Yellow:=0xFFFF00
      ,Maroon:=0x800000,	Navy:=0x000080,		Red:=0xFF0000,    	Blue:=0x0000FF
      ,Purple:=0x800080,   Teal:=0x008080,		Fuchsia:=0xFF00FF,	Aqua:=0x00FFFF
  If InStr(",Black,Green,Silver,Lime,gray,olive,white,yellow,maroon,Navy,Red,Blue,Purple,Teal,Fuchsia,Aqua,","," color ",")
      Color:=%color%
  Color := (StrLen(Color) < 8 ? "0x" : "") . Color
  Color := ((Color&255)<<16)+(((Color>>8)&255)<<8)+(Color>>16) ; rgb -> bgr
   Return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_SETTIPBKCOLOR,"PTR",color,"PTR",0,"PTR")
}
TTM_SETTIPTEXTCOLOR(T,color:=0){
   static TTM_SETTIPTEXTCOLOR := 0x414
      ,Black:=0x000000,    Green:=0x008000,		Silver:=0xC0C0C0,		Lime:=0x00FF00
      ,Gray:=0x808080,    	Olive:=0x808000,		White:=0xFFFFFF,   	Yellow:=0xFFFF00
      ,Maroon:=0x800000,	Navy:=0x000080,		Red:=0xFF0000,    	Blue:=0x0000FF
      ,Purple:=0x800080,   Teal:=0x008080,		Fuchsia:=0xFF00FF,	Aqua:=0x00FFFF
  If InStr(",Black,Green,Silver,Lime,gray,olive,white,yellow,maroon,Navy,Red,Blue,Purple,Teal,Fuchsia,Aqua,","," color ",")
      Color:=%color%
  Color := (StrLen(Color) < 8 ? "0x" : "") . Color
  Color := ((Color&255)<<16)+(((Color>>8)&255)<<8)+(Color>>16) ; rgb -> bgr
   Return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_SETTIPTEXTCOLOR,"PTR",color,"PTR",0,"PTR")
}
TTM_SETTITLE(T,title:="",icon:="",Icon_:=1,default:=1){
  static TTM_SETTITLE := 0x400 + (A_IsUnicode ? 33 : 32)
	If (icon)
    If (icon+0="")
      If !icon:=TT_GetIcon(icon,Icon_)
				icon:=default
  T.maintitle := (StrLen(title) < 96) ? title : (Chr(A_IsUnicode ? 8230 : 133) SubStr(title, -96))
   Return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_SETTITLE,"PTR",icon+0,"PTR",T.GetAddress("maintitle"),"PTR"),T.UPDATE()
}
TTM_SETTOOLINFO(T,pTOOLINFO:=0){
   static TTM_SETTOOLINFO := A_IsUnicode?0x436:0x409
   Return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_SETTOOLINFO,"PTR",0,"PTR",pTOOLINFO?pTOOLINFO:T.P[],"PTR")
}
TTM_SETWINDOWTHEME(T,theme:=""){
  If !theme
    Return DllCall("UxTheme\SetWindowTheme","PTR",T.HWND,"str","","str","")
  else Return DllCall("SendMessage","PTR",T.HWND,"UInt",0x200b,"PTR",0,"PTR",&theme,"PTR")
}
TTM_TRACKACTIVATE(T,activate:=0,pTOOLINFO:=0){
   Return DllCall("SendMessage","PTR",T.HWND,"UInt",0x411,"PTR",activate,"PTR",(pTOOLINFO)?(pTOOLINFO):(T.P[]),"PTR")
}
TTM_TRACKPOSITION(T,x:=0,y:=0){
  Return DllCall("SendMessage","PTR",T.HWND,"UInt",0x412,"PTR",0,"PTR",(x & 0xFFFF)|(y & 0xFFFF)<<16,"PTR")
}
TTM_UPDATE(T){
   Return DllCall("SendMessage","PTR",T.HWND,"UInt",0x41D,"PTR",0,"PTR",0,"PTR")
}
TTM_UPDATETIPTEXT(T,pTOOLINFO:=0){
   static TTM_UPDATETIPTEXT := A_IsUnicode?0x439:0x40c
   Return DllCall("SendMessage","PTR",T.HWND,"UInt",TTM_UPDATETIPTEXT,"PTR",0,"PTR",pTOOLINFO?pTOOLINFO:T.P[],"PTR")
}
TTM_WINDOWFROMPOINT(T,pPOINT){
   Return DllCall("SendMessage","PTR",T.HWND,"UInt",0x410,"PTR",0,"PTR",pPOINT,"PTR")
}
