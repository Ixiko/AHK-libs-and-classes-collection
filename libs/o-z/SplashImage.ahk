SplashImage_Struct(){
  static MAX_SPLASHIMAGE_WINDOWS,SplashType,g_SplashImage
  if !MAX_SPLASHIMAGE_WINDOWS
    MAX_SPLASHIMAGE_WINDOWS:=10,SplashType:="int width;int height;int bar_pos;int margin_x;int margin_y;int text1_height;int object_width;int object_height;HWND hwnd;int pic_type;union{HBITMAP pic_bmp;HICON pic_icon};HWND hwnd_bar;HWND hwnd_text1;HWND hwnd_text2;HFONT hfont1;HFONT hfont2;HBRUSH hbrush;COLORREF color_bk;COLORREF color_text"
    ,g_SplashImage:=Struct("SplashImage_Struct(SplashType)[" MAX_SPLASHIMAGE_WINDOWS "]")
  return g_SplashImage
}
SplashImage_OnMessage(wParam,lParam,msg,hwnd){
  static MAX_SPLASHIMAGE_WINDOWS,SW_SHOWNOACTIVATE,WM_SETTEXT,WS_DISABLED,WS_POPUP,WS_CAPTION,WS_EX_TOPMOST,COORD_UNSPECIFIED,WS_SIZEBOX,WS_MINIMIZEBOX,WS_MAXIMIZEBOX,WS_SYSMENU,LOGPIXELSY,IMAGE_BITMAP
        ,FW_DONTCARE,CLR_DEFAULT,CLR_NONE,DEFAULT_GUI_FONT,IMAGE_ICON,SS_LEFT,FW_SEMIBOLD,DEFAULT_CHARSET,OUT_TT_PRECIS,CLIP_DEFAULT_PRECIS,PROOF_QUALITY,FF_DONTCARE
        ,DT_CALCRECT,DT_WORDBREAK,DT_EXPANDTABS,SPI_GETWORKAREA,IDI_MAIN,LR_SHARED,ICON_SMALL,ICON_BIG,WS_CHILD,WS_VISIBLE,SS_NOPREFIX,SS_CENTER,SS_LEFTNOWORDWRAP,PBM_GETPOS,PBM_SETPOS,PBM_SETRANGE
        ,PBM_SETRANGE32,WS_EX_CLIENTEDGE,PBS_SMOOTH,WM_PAINT,WM_SIZE,PBM_SETBARCOLOR,PBM_SETBKCOLOR,WM_SETFONT,SRCCOPY,DI_NORMAL,COLOR_BTNFACE,WM_ERASEBKGND,WM_CTLCOLORSTATIC
        ,Black,Silver,Gray,White,Maroon,Red,Purple,Fuchsia,Green,Lime,Olive,Yellow,Navy,Blue,Teal,Aqua,Default
        ,g_SplashImage,RECT,client_rect,draw_rect,main_rect,work_rect
  if !MAX_SPLASHIMAGE_WINDOWS
    MAX_SPLASHIMAGE_WINDOWS:=10,SW_SHOWNOACTIVATE:=4,WM_SETTEXT:=12
    ,WS_DISABLED:=134217728,WS_POPUP:=2147483648,WS_CAPTION:=12582912,WS_EX_TOPMOST:=8,COORD_UNSPECIFIED:=(-2147483647 - 1)
    ,WS_SIZEBOX:=262144,WS_MINIMIZEBOX:=131072,WS_MAXIMIZEBOX:=65536,WS_SYSMENU:=524288,LOGPIXELSY:=90,IMAGE_BITMAP:=0
    ,FW_DONTCARE:=0,CLR_DEFAULT:=4278190080,CLR_NONE:=4294967295,DEFAULT_GUI_FONT:=17,IMAGE_ICON:=1,SS_LEFT:=0
    ,FW_SEMIBOLD:=600, DEFAULT_CHARSET:=1, OUT_TT_PRECIS:=4, CLIP_DEFAULT_PRECIS:=0, PROOF_QUALITY:=2,FF_DONTCARE:=0
    ,DT_CALCRECT:=1024, DT_WORDBREAK:=16, DT_EXPANDTABS:=64,SPI_GETWORKAREA:=48,IDI_MAIN:=159,LR_SHARED:=32768,ICON_SMALL:=0,ICON_BIG:=1
    ,WS_CHILD:=1073741824,WS_VISIBLE:=268435456,SS_NOPREFIX:=0x80,SS_CENTER:=1,SS_LEFTNOWORDWRAP:=12,PBM_GETPOS:=1032,PBM_SETPOS:=1026
    ,PBM_SETRANGE:=1025,PBM_SETRANGE32:=1030,WS_EX_CLIENTEDGE:=512,PBS_SMOOTH:=1,WM_PAINT:=15,WM_SIZE:=5
    ,PBM_SETBARCOLOR:=1033,PBM_SETBKCOLOR:=8193,WM_SETFONT:=48,SRCCOPY:=13369376,DI_NORMAL:=3,COLOR_BTNFACE:=15,WM_ERASEBKGND:=20,WM_CTLCOLORSTATIC:=312
    ,Black:=0,Silver:=0xC0C0C0,Gray:=0x808080,White:=0xFFFFFF,Maroon:=0x000080,Red:=0x0000FF
    ,Purple:=0x800080,Fuchsia:=0xFF00FF,Green:=0x008000,Lime:=0x00FF00,Olive:=0x008080
    ,Yellow:=0x00FFFF,Navy:=0x800000,Blue:=0xFF0000,Teal:=0x808000,Aqua:=0xFFFF00,Default:=CLR_DEFAULT
    ,g_SplashImage:=SplashImage_Struct(),RECT:="LONG left,LONG top,LONG right,LONG bottom",client_rect:=Struct(RECT), draw_rect:=Struct(RECT), main_rect:=Struct(RECT), work_rect:=Struct(RECT)
  Loop % MAX_SPLASHIMAGE_WINDOWS
    if (g_SplashImage[i:=A_Index].hwnd == hwnd)
      break
  if (i == MAX_SPLASHIMAGE_WINDOWS){ ; It's not a progress window either.
    ; Let DefWindowProc() handle it (should probably never happen since currently the only
    ; other type of window is SplashText, which never receive this msg?)
    Return
  }
  splash := g_SplashImage[i]

  If (msg=WM_SIZE){
    new_width := lParam & 0xFFFF
    new_height := (lParam>>16) & 0xFFFF
    if (new_width != splash.width || new_height != splash.height)
    {
      GetClientRect(splash.hwnd, client_rect[])
      control_width := client_rect.right - (splash.margin_x * 2)
      bar_y := splash.margin_y + (splash.text1_height ? (splash.text1_height + splash.margin_y) : 0)
      sub_y := bar_y + splash.object_height + (splash.object_height ? splash.margin_y : 0)  ;  Calculate the Y position of each control in the window.
      ; The Y offset for each control should match those used in Splash():
      if (new_width != splash.width)
      {
        if (splash.hwnd_text1) ; This control doesn't exist if the main text was originally blank.
          MoveWindow(splash.hwnd_text1, splash.margin_x, splash.margin_y, control_width, splash.text1_height, FALSE)
        if (splash.hwnd_bar)
          MoveWindow(splash.hwnd_bar, splash.margin_x, bar_y, control_width, splash.object_height, FALSE)
        splash.width := new_width
      }
      ; Move the window EVEN IF new_height == splash.height because otherwise the text won't
      ; get re-centered when only the width of the window changes:
      MoveWindow(splash.hwnd_text2, splash.margin_x, sub_y, control_width, (client_rect.bottom - client_rect.top) - sub_y, FALSE) ; Negative height seems handled okay.
      ; Specifying true for "repaint" in MoveWindow() is not always enough refresh the text correctly,
      ; so this is done instead:
      InvalidateRect(splash.hwnd, client_rect[], TRUE)
      ; If the user resizes the window, have that size retained (remembered) until the script
      ; explicitly changes it or the script destroys the window.
      splash.height := new_height
    }
    return 0 ; i.e. completely handled here.
  }	else if (msg=WM_CTLCOLORSTATIC){
    if (!splash.hbrush && splash.color_text == CLR_DEFAULT) ; Let DWP handle it.
      Return DefWindowProc(hWnd, Msg, wParam, lParam)
    ; Since we're processing this msg and not DWP, must set background color unconditionally,
    ; otherwise plain white will likely be used:
    SetBkColor(wParam, splash.hbrush ? splash.color_bk : GetSysColor(COLOR_BTNFACE))
    if (splash.color_text != CLR_DEFAULT)
      SetTextColor(wParam, splash.color_text)
    ; Always return a real HBRUSH so that Windows knows we altered the HDC for it to use:
    return splash.hbrush ? splash.hbrush : GetSysColorBrush(COLOR_BTNFACE)
  } else if (msg=WM_ERASEBKGND){
    if (splash.pic_bmp) ; And since there is a pic, its object_width/height should already be valid.
    {
      ypos := splash.margin_y + (splash.text1_height ? (splash.text1_height + splash.margin_y) : 0)
      if (splash.pic_type == IMAGE_BITMAP)
      {
        hdc := CreateCompatibleDC(wParam)
        ,hbmpOld := SelectObject(hdc, splash.pic_bmp)
        ,BitBlt(wParam, splash.margin_x, ypos, splash.object_width, splash.object_height, hdc, 0, 0, SRCCOPY)
        ,SelectObject(hdc, hbmpOld)
        ,DeleteDC(hdc)
      }
      else ; IMAGE_ICON
        DrawIconEx(wParam, splash.margin_x, ypos, splash.pic_icon, splash.object_width, splash.object_height, 0, 0, DI_NORMAL)
      ; Prevent "flashing" by erasing only the part that hasn't already been drawn:
      ExcludeClipRect(wParam, splash.margin_x, ypos, splash.margin_x + splash.object_width, ypos + splash.object_height)
      ,hrgn := CreateRectRgn(0, 0, 1, 1)
      ,GetClipRgn(wParam, hrgn)
      ,FillRgn(wParam, hrgn, splash.hbrush ? splash.hbrush : GetSysColorBrush(COLOR_BTNFACE))
      ,DeleteObject(hrgn)
      return 1
    }
    ; Otherwise, it's a Progress window (or a SplashImage window with no picture):
    if (splash.hbrush){ ; Let DWP handle it.
      GetClipBox(hdc, client_rect[])
      ,FillRect(hdc, client_rect[], splash.hbrush)
    }
  }
  ;~ DllCall("InvalidateRect","PTR",splash.hwnd,"PTR", NULL,"Int", TRUE)
  return DefWindowProc(hWnd, Msg, wParam, lParam) ;ret
}
SplashImage(aImageFile,aOptions:="",aSubText:="", aMainText:="", aTitle:="",aFontName:=""){
  static MAX_SPLASHIMAGE_WINDOWS:=10,SW_SHOWNOACTIVATE:=4,WM_SETTEXT:=12
        ,WS_DISABLED:=134217728,WS_POPUP:=2147483648,WS_CAPTION:=12582912,WS_EX_TOPMOST:=8,COORD_UNSPECIFIED:=(-2147483647 - 1)
        ,WS_SIZEBOX:=262144,WS_MINIMIZEBOX:=131072,WS_MAXIMIZEBOX:=65536,WS_SYSMENU:=524288,LOGPIXELSX:=88,LOGPIXELSY:=90,IMAGE_BITMAP:=0
        ,FW_DONTCARE:=0,CLR_NONE:=4294967295,DEFAULT_GUI_FONT:=17,IMAGE_ICON:=1,CLR_DEFAULT:=4278190080
        ,SPLASH_DEFAULT_WIDTH:=MulDiv(300, GetDeviceCaps(hdc:=GetDC(),LOGPIXELSX),96),rel:=ReleaseDC(0, hdc)
        , FW_SEMIBOLD:=600, DEFAULT_CHARSET:=1, OUT_TT_PRECIS:=4, CLIP_DEFAULT_PRECIS:=0, PROOF_QUALITY:=2,FF_DONTCARE:=0,SS_LEFT:=0
        ,DT_CALCRECT:=1024, DT_WORDBREAK:=16, DT_EXPANDTABS:=64,SPI_GETWORKAREA:=48,IDI_MAIN:=159,LR_SHARED:=32768,ICON_SMALL:=0,ICON_BIG:=1
        ,WS_CHILD:=1073741824,WS_VISIBLE:=268435456,SS_NOPREFIX:=0x80,SS_CENTER:=1,SS_LEFTNOWORDWRAP:=12,PBM_GETPOS:=1032,PBM_SETPOS:=1026
        ,PBM_SETRANGE:=1025,PBM_SETRANGE32:=1030,WS_EX_CLIENTEDGE:=512,PBS_SMOOTH:=1,WM_PAINT:=15,WM_SIZE:=5
        ,PBM_SETBARCOLOR:=1033,PBM_SETBKCOLOR:=8193,WM_SETFONT:=48,SRCCOPY:=13369376,DI_NORMAL:=3,COLOR_BTNFACE:=15,WM_ERASEBKGND:=20,WM_CTLCOLORSTATIC:=312
        ,Black:=0,Silver:=0xC0C0C0,Gray:=0x808080,White:=0xFFFFFF,Maroon:=0x000080,Red:=0x0000FF
        ,Purple:=0x800080,Fuchsia:=0xFF00FF,Green:=0x008000,Lime:=0x00FF00,Olive:=0x008080
        ,Yellow:=0x00FFFF,Navy:=0x800000,Blue:=0xFF0000,Teal:=0x808000,Aqua:=0xFFFF00,Default:=CLR_DEFAULT
        ,CStringW:="UInt m_sNull,PTR m_pData,bool m_bDirty"
        ,Script:="PTR **mVar,**mLazyVar;int mVarCount,mVarCountMax,mLazyVarCount;PTR *mFirstGroup,*mLastGroup;int mCurrentFuncOpenBlockCount;bool mNextLineIsFunctionBody;int mClassObjectCount;PTR *mClassObject[5];TCHAR mClassName[256];PTR *mUnresolvedClasses;PTR *mClassProperty;LPTSTR mClassPropertyDef;int mCurrFileIndex;UINT mCombinedLineNumber;bool mNoHotkeyLabels,mMenuUseErrorLevel;PTR mNIC;PTR *mFirstLine,*mLastLine,*mFirstStaticLine,*mLastStaticLine;PTR *mFirstLabel,*mLastLabel;PTR **mFunc;int mFuncCount,mFuncCountMax;PTR *mTempLine;PTR *mTempLabel;PTR *mTempFunc;PTR *mCurrLine;PTR *mPlaceholderLabel;TCHAR mThisMenuItemName[261],mThisMenuName[261];LPTSTR mThisHotkeyName,mPriorHotkeyName;HWND mNextClipboardViewer;bool mOnClipboardChangeIsRunning;PTR *mOnClipboardChangeFunc,*mOnExitFunc;int mExitReason;PTR *mFirstTimer,*mLastTimer;UINT mTimerCount,mTimerEnabledCount;PTR *mFirstMenu,*mLastMenu;UINT mMenuCount;DWORD mThisHotkeyStartTime,mPriorHotkeyStartTime;TCHAR mEndChar;BYTE mThisHotkeyModifiersLR;LPTSTR mFileSpec,mFileDir,mFileName,mOurEXE,mOurEXEDir,mMainWindowTitle;bool mIsReadyToExecute,mAutoExecSectionIsRunning,mIsRestart,mErrorStdOut;PTR *mIncludeLibraryFunctionsThenExit;int mUninterruptedLineCountMax,mUninterruptibleTime;DWORD mLastPeekTime;SplashImage(CStringW) mRunAsUser,mRunAsPass,mRunAsDomain;HICON mCustomIcon,mCustomIconSmall;LPTSTR mCustomIconFile;bool mIconFrozen;LPTSTR mTrayIconTip;UINT mCustomIconNumber;PTR *mTrayMenu"
        ,g_script:=Struct(Script,A_ScriptStruct)
        ,g_SplashImage:=SplashImage_Struct()
        ,tm:=Struct("LONG tmHeight;LONG tmAscent;LONG tmDescent;LONG tmInternalLeading;LONG tmExternalLeading;LONG tmAveCharWidth;LONG tmMaxCharWidth;LONG tmWeight;LONG tmOverhang;LONG tmDigitizedAspectX;LONG tmDigitizedAspectY;WCHAR tmFirstChar;WCHAR tmLastChar;WCHAR tmDefaultChar;WCHAR tmBreakChar;BYTE tmItalic;BYTE tmUnderlined;BYTE tmStruckOut;BYTE tmPitchAndFamily;BYTE tmCharSet") ;TEXTMETRICW
        ,iconinfo:=Struct("BOOL fIcon;DWORD xHotspot;DWORD yHotspot;HBITMAP hbmMask;HBITMAP hbmColor") ;ICONINFO
        ,RECT:="LONG left,LONG top,LONG right,LONG bottom",client_rect:=Struct(RECT), draw_rect:=Struct(RECT), main_rect:=Struct(RECT), work_rect:=Struct(RECT)
        ,bmp:=Struct("LONG bmType;LONG bmWidth;LONG bmHeight;LONG bmWidthBytes;WORD bmPlanes;WORD bmBitsPixel;LPVOID bmBits") ;BITMAP
        ,initGui:=Gui("SPLASH_GUI_Init:Show","HIDE") Gui("SPLASH_GUI_Init:Destroy") ; required to init ahk_class AutoHotkeyGUI
        ,_ttoi:=DynaCall("msvcrt\_wtoi","t==t")
  ErrorLevel := 0    ; Set default
  window_index := 1  ;  Set the default window to operate upon (the first).
  image_filename := aImageFile  ;  Set default.
  turn_off := false
  show_it_only := false
  bar_pos_has_been_set := false
  options_consist_of_bar_pos_only := false
  if (aImageFile!=""){
    colon_pos := InStr(aImageFile, ":")
    image_filename_omit_leading_whitespace := lTrim(image_filename) ;  Added in v1.0.38.04 per someone's suggestion.
    if (colon_pos && colon_pos < 32){
        window_number_str:=SubStr(aImageFile,1,colon_pos-1)
        if (window_number_str+0!=""){ ;  Seems best to allow float at runtime.
          ;  Note that filenames can start with spaces, so omit_leading_whitespace() is only
          ;  used if the string is entirely blank:
          ; image_filename := colon_pos + 1
          image_filename := SubStr(aImageFile,colon_pos)
          image_filename_omit_leading_whitespace := ltrim(image_filename) ;  Update to reflect the change above.
          if (image_filename_omit_leading_whitespace!="")
            image_filename := image_filename_omit_leading_whitespace
          window_index := window_number_str
          if (window_index < 0 || window_index >= MAX_SPLASHIMAGE_WINDOWS){
            MsgBox,0,Error in Function %A_ThisFunc%,% "Max window number is " MAX_SPLASHIMAGE_WINDOWS "."
            ErrorLevel:=-1
            return
          }

        }
    }
    if (image_filename_omit_leading_whitespace="Off") ;  v1.0.38.04: Ignores leading whitespace per someone's suggestion.
      turn_off := true
    else if (image_filename_omit_leading_whitespace = "Show") ;  v1.0.38.04: Ignores leading whitespace per someone's suggestion.
      show_it_only := true

  }

  splash := g_SplashImage[window_index]

  ;  In case it's possible for the window to get destroyed by other means (WinClose?).
  ;  Do this only after the above options were set so that the each window's settings
  ;  will be remembered until such time as "Command, Off" is used:
  if (splash.hwnd && !IsWindow(splash.hwnd))
    OnMessage(WM_ERASEBKGND,splash.hwnd,"Progress_OnMessage",0)
		,OnMessage(WM_CTLCOLORSTATIC,splash.hwnd,"Progress_OnMessage",0)
    ,OnMessage(WM_SIZE,splash.hwnd,"Progress_OnMessage",0),splash.hwnd := 0

  if (show_it_only)
  {
    if (splash.hwnd && !IsWindowVisible(splash.hwnd))
      ShowWindow(splash.hwnd, SW_SHOWNOACTIVATE) ;  See bottom of this function for comments on SW_SHOWNOACTIVATE.
    ; else for simplicity, do nothing.
    return
  }

  if (!turn_off && splash.hwnd && image_filename="" && (options_consist_of_bar_pos_only || aOptions="")) ;  The "modify existing window" mode is in effect.
  {
    ;  If there is an existing window, just update its bar position and text.
    ;  If not, do nothing since we don't have the original text of the window to recreate it.
    ;  Since this is our thread's window, it shouldn't be necessary to use SendMessageTimeout()
    ;  since the window cannot be hung since by definition our thread isn't hung.  Also, setting
    ;  a text item from non-blank to blank is not supported so that elements can be omitted from an
    ;  update command without changing the text that's in the window.  The script can specify %a_space%
    ;  to explicitly make an element blank.
    if (!aSplashImage && bar_pos_has_been_set && splash.bar_pos != bar_pos) ; Avoid unnecessary redrawing.
    {
      splash.bar_pos := bar_pos
      if (splash.hwnd_bar)
        SendMessage_(splash.hwnd_bar, PBM_SETPOS, bar_pos, 0)
    }
    ;  SendMessage() vs. SetWindowText() is used for controls so that tabs are expanded.
    ;  For simplicity, the hwnd_text1 control is not expanded dynamically if it is currently of
    ;  height zero.  The user can recreate the window if a different height is needed.
    if (aMainText!="" && splash.hwnd_text1)
      SendMessage_(splash.hwnd_text1, WM_SETTEXT, 0, &aMainText)
    if (aSubText!="")
      SendMessage_(splash.hwnd_text2, WM_SETTEXT, 0, &aSubText)
    if (aTitle!="")
      SetWindowText(splash.hwnd, aTitle) ;  Use the simple method for parent window titles.
    return
  }

    if (splash.hwnd)
      OnMessage(WM_ERASEBKGND,splash.hwnd,"SplashImage_OnMessage",0)
      ,OnMessage(WM_CTLCOLORSTATIC,splash.hwnd,"SplashImage_OnMessage",0)
      ,OnMessage(WM_SIZE,splash.hwnd,"SplashImage_OnMessage",0)
  ;  Otherwise, destroy any existing window first:
  if (splash.hwnd)
    DestroyWindow(splash.hwnd)
  if (splash.hfont1) ;  Destroy font only after destroying the window that uses it.
    DeleteObject(splash.hfont1)
  if (splash.hfont2)
    DeleteObject(splash.hfont2)
  if (splash.hbrush)
    DeleteObject(splash.hbrush)
  if (splash.pic_bmp)
  {
    if (splash.pic_type == IMAGE_BITMAP)
      DeleteObject(splash.pic_bmp)
    else
      DestroyIcon(splash.pic_icon)
  }
  splash.Fill() ;  Set the above and all other fields to zero.

  if (turn_off)
    return

  ;  Otherwise, the window needs to be created or recreated.

  if (aTitle="") ;  Provide default title.
    aTitle := A_ScriptName ? A_ScriptName : ""

  ;  Since there is often just one progress/splash window, and it defaults to always-on-top,
  ;  it seems best to default owned to be true so that it doesn't get its own task bar button:
  owned := true          ;  Whether this window is owned by the main window.
  centered_main := true  ;  Whether the main text is centered.
  centered_sub := true   ;  Whether the sub text is centered.
  initially_hidden := false  ;  Whether the window should kept hidden (for later showing by the script).
  style := WS_DISABLED|WS_POPUP|WS_CAPTION  ;  WS_CAPTION implies WS_BORDER
  exstyle := WS_EX_TOPMOST
  xpos := COORD_UNSPECIFIED
  ypos := COORD_UNSPECIFIED
  range_min := 0, range_max := 0  ;  For progress bars.
  font_size1 := 0 ;  0 is the flag to "use default size".
  font_size2 := 0
  font_weight1 := FW_DONTCARE  ;  Flag later logic to use default.
  font_weight2 := FW_DONTCARE  ;  Flag later logic to use default.
  bar_color := CLR_DEFAULT
  splash.color_bk := CLR_DEFAULT
  splash.color_text := CLR_DEFAULT
  splash.height := COORD_UNSPECIFIED
  splash.width := COORD_UNSPECIFIED
  splash.object_height := COORD_UNSPECIFIED
  splash.object_width := COORD_UNSPECIFIED  ;  Currently only used for SplashImage, not Progress.
  if (aMainText!="" || aSubText!="")
  {
    splash.margin_x := 10
    splash.margin_y := 5
  }
  else ;  Displaying only a naked image, so don't use borders.
    splash.margin_x := splash.margin_y := 0
  cp:=(&aOptions)-2
  while (""!=cp_:=StrGet(cp:=cp+2,1)){
  ;for (cp2, cp = options; cp!=""; ++cp)
    If (cp_="a"){  ;  Non-Always-on-top.  Synonymous with A0 in early versions.
      ;  Decided against this enforcement.  In the enhancement mentioned below is ever done (unlikely),
      ;  it seems that A1 can turn always-on-top on and A0 or A by itself can turn it off:
      ; if (cp[1] == '0') ;  The zero is required to allow for future enhancement: modify attrib. of existing window.
      exstyle &= ~WS_EX_TOPMOST
    } else if (cp_="b"){ ;  Borderless and/or Titleless
      style &= ~WS_CAPTION
      if (StrGet(cp+2,1) = "1")
        style |= WS_BORDER
      else if (StrGet(cp+2,1) = "2")
        style |= WS_DLGFRAME
    } else if (cp_="c"){ ;  Colors
      if (""=SubStr(cp+2,1)) ;  Avoids out-of-bounds when the loop's own ++cp is done.
        continue
      cp+=2 ;  Always increment to omit the next char from consideration by the next loop iteration.
      If InStr("btw",cp_:=StrGet(cp,1)){
      ; 'B': ;  Bar color.
      ; 'T': ;  Text color.
      ; 'W': ;  Window/Background color.
        color_str:=StrGet(cp+2,32)
        If (space_pos:=InStr(color_str," ")) ^ (tab_pos:=InStr(color_str,A_Tab))
          StrPut("",(&color_str)+(space_pos&&space_pos<tab_pos?space_pos:tab_pos?tab_pos:space_pos)*2-2)
        VarSetCapacity(color_str,-1)
        ; else a color name can still be present if it's at the end of the string.
        color := ( !color_str || !InStr(".black.silver.gray.white.maroon.red.purple.fuchsia.green.lime.olive.yellow.navy.blue.teal.aqua.default.","." color_str ".",0) )
                ? CLR_NONE : %color_str%
        if (color == CLR_NONE) ;  A matching color name was not found, so assume it's in hex format.
        {
          if (StrLen(color_str) > 6)
            color_str:=SubStr(color_str,1,6)+0 ;  Shorten to exactly 6 chars, which happens if no space/tab delimiter is present.
          color := ((Color_str&255)<<16) + (((Color_str>>8)&255)<<8) + (Color_str>>16)
          ;  if color_str does not contain something hex-numeric, black (0x00) will be assumed,
          ;  which seems okay given how rare such a problem would be.
        }
        if (cp_="b"){
          bar_color := color
        } else if (cp_="t"){
          splash.color_text := color
        } else if (cp_="w"){
          splash.color_bk := color
          splash.hbrush := CreateSolidBrush(color) ;  Used for window & control backgrounds.
        }
        ;  Skip over the color string to avoid interpreting hex digits or color names as option letters:
        cp += StrLen(color_str)*2+2
      } else {
      ; default:
        centered_sub := (StrGet(cp,1) != "")
        centered_main := (StrGet(cp+2,1) != "0")
      }
    } else if (cp_="F"){
      if (""=SubStr(cp+2,1)) ;  Avoids out-of-bounds when the loop's own ++cp is done.
        continue
      cp+=2 ;  Always increment to omit the next char from consideration by the next loop iteration.
      If ("m"=cp_:=StrGet(cp,1)) {
        if ((font_size1 := _ttoi[cp + 2]) < 0)
          font_size1 := 0
      } else if (cp_="s"){
        if ((font_size2 := _ttoi[cp + 2]) < 0)
          font_size2 := 0
      }
    }else if (cp_="M"){ ;  Movable and (optionally) resizable.
      style &= ~WS_DISABLED
      if (StrGet(cp + 2,1) = "1")
        style |= WS_SIZEBOX
      if (StrGet(cp + 2,1) = "2")
        style |= WS_SIZEBOX|WS_MINIMIZEBOX|WS_MAXIMIZEBOX|WS_SYSMENU
    } else if (cp_="p"){ ;  Starting position of progress bar [v1.0.25]
      bar_pos := _ttoi[cp + 2]
      bar_pos_has_been_set := true
    } else if (cp_="r"){ ;  Range of progress bar [v1.0.25]
      if (""=SubStr(cp+2,1)) ;  Ignore it because we don't want cp to ever poto the NULL terminator due to the loop's increment.
        continue
      range_min := _ttoi[cp + 2] ;  Increment cp to poit to range_min.
      if (cp < cp2 := cp+(InStr(StrGet(cp), "-")-1)*2)  ;  +1 to omit the min's minus sign, if it has one.
      {
        cp := cp2
        if (""=SubStr(cp+2,1)) ;  Ignore it because we don't want cp to ever poto the NULL terminator due to the loop's increment.
          continue
        range_max := _ttoi[cp + 2] ;  Increment cp to poit to range_max, which can be negative as in this example: R-100--50
      }
    } else if (cp_="t"){ ;  Give it a task bar button by making it a non-owned window.
      owned := false
    ;  For options such as W, X and Y:
    ;  Use atoi() vs. ATOI() to avoid interpreting something like 0x01B as hex when in fact
    ;  the B was meant to be an option letter:
    } else if (cp_="w"){
      if (""=SubStr(cp+2,1)) ;  Avoids out-of-bounds when the loop's own ++cp is done.
        continue
      cp+= 2 ;  Always increment to omit the next char from consideration by the next loop iteration.
      if ("m"=cp_:=StrGet(cp,1)){
        if ((font_weight1 := _ttoi[cp + 2]) < 0)
          font_weight1 := 0
        break
      } else if (cp_="s"){
        if ((font_weight2:=_ttoi[cp + 2]) < 0)
          font_weight2 := 0
      } else
        splash.width := _ttoi[cp]
    } else if (cp_="h"){
      if (StrGet(cp,4)="Hide"){ ;  Hide vs. Hidden is debatable.
        initially_hidden := true
        cp+= 2*3 ;  +3 vs. +4 due to the loop's own ++cp.
      }	else ;  Allow any width/height to be specified so that the window can be "rolled up" to its title bar:
        splash.height := _ttoi[cp + 2]
    } else if (cp_="x"){
      xpos := _ttoi[cp + 2]
    } else if (cp_="y"){
      ypos := _ttoi[cp + 2]
    } else if (cp_="z"){
      if (""=SubStr(cp+2,1)) ;  Avoids out-of-bounds when the loop's own ++cp is done.
        continue
      cp+=2 ;  Always increment to omit the next char from consideration by the next loop iteration.
      If InStr("bh",cp_:=StrGet(cp,1)){
        splash.object_height := _ttoi[cp + 2] ;  Allow it to be zero or negative to omit the object.
      } else if (cp_="w"){
        splash.object_width := _ttoi[cp + 2] ;  Allow it to be zero or negative to omit the object.
      } else if (cp_="x"){
        splash.margin_x := _ttoi[cp + 2]
      } else if (cp_="y"){
        splash.margin_y := _ttoi[cp + 2]
      }
    ;  Otherwise: Ignore other characters, such as the digits that occur after the P/X/Y option letters.
    } ;  switch()
  } ;  for()

  hdc := CreateDC("DISPLAY", 0, 0, 0)
  pixels_per_point_y := GetDeviceCaps(hdc,LOGPIXELSY)

  ;  Get name and size of default font.
  hfont_default := GetStockObject(DEFAULT_GUI_FONT)
  hfont_old := SelectObject(hdc, hfont_default)
  VarSetCapacity(default_font_name,65*A_IsUnicode)
  GetTextFace(hdc, 65 - 1, &default_font_name)
  VarSetCapacity(default_font_name,-1)
  GetTextMetrics(hdc, tm[])
  default_gui_font_height := tm.tmHeight

  ;  If both are zero or less, reset object height/width for maintainability and sizing later.
  ;  However, if one of them is -1, the caller is asking for that dimension to be auto-calc'd
  ;  to "keep aspect ratio" with the the other specified dimension:
  if (   splash.object_height < 1 && splash.object_height != COORD_UNSPECIFIED
    && splash.object_width < 1 && splash.object_width != COORD_UNSPECIFIED
    || !splash.object_height || !splash.object_width   )
    splash.object_height := splash.object_width := 0
  ;  If there's an image, handle it first so that automatic-width can be applied (if no width was specified)
  ;  for later font calculations:
  if (image_filename!="" && splash.object_height)
  {
    use_gdi_plus := false
    while (A_Index=1 || use_gdi_plus:=true){ 
      splash.pic_bmp := LoadPicture(image_filename
          ,splash.object_width == COORD_UNSPECIFIED ? 0 : splash.object_width
          ,splash.object_height == COORD_UNSPECIFIED ? 0 : splash.object_height
          ,temp_pic_type, 0, use_gdi_plus)
      splash.pic_type:=temp_pic_type
      if (splash.pic_bmp || use_gdi_plus)
        break
        ;  Re-attempt with GDI+. The first attempt is made without it for backward compatibility.
        ;  In particular, GDI+ causes some issues with WinSet TransColor on Windows XP.
    }
    if (splash.pic_bmp && (splash.object_height < 0 || splash.object_width < 0))
    {
      hbmp_to_measure := 0
      if (splash.pic_type == IMAGE_BITMAP)
        hbmp_to_measure := splash.pic_bmp
      else ;  IMAGE_ICON
        if (GetIconInfo(splash.pic_icon, iconinfo[]))
          hbmp_to_measure := iconinfo.hbmColor
      if (hbmp_to_measure)
      {
        bmp.Fill()
        if (GetObject(hbmp_to_measure, sizeof(bmp), bmp[]))
        {
          if (splash.object_height == -1 && splash.object_width > 0)
          {
            ;  Caller wants height calculated based on the specified width (keep aspect ratio).
            if (bmp.bmWidth) ;  Avoid any chance of divide-by-zero.
              splash.object_height := ((bmp.bmHeight / bmp.bmWidth) * splash.object_width + .5) ;  Round.
          }
          else if (splash.object_width == -1 && splash.object_height > 0)
          {
            ;  Caller wants width calculated based on the specified height (keep aspect ratio).
            if (bmp.bmHeight) ;  Avoid any chance of divide-by-zero.
              splash.object_width := ((bmp.bmWidth // bmp.bmHeight) * splash.object_height + .5) ;  Round.
          }
          else
          {
            ;  Use actual width/height where unspecified:
            if (splash.object_height == COORD_UNSPECIFIED)
              splash.object_height := bmp.bmHeight
            if (splash.object_width == COORD_UNSPECIFIED)
              splash.object_width := bmp.bmWidth
          }
          if (splash.width == COORD_UNSPECIFIED)
            splash.width := splash.object_width + (2 * splash.margin_x)
        }
        if (splash.pic_type == IMAGE_ICON)
        {
          ;  Delete the bitmaps created by GetIconInfo above:
          DeleteObject(iconinfo.hbmColor)
          ,DeleteObject(iconinfo.hbmMask)
        }
      }
    }
  }

  ;  If width is still unspecified -- which should only happen if it's a SplashImage window with
  ;  no image, or there was a problem getting the image above -- set it to be the default.
  if (splash.width == COORD_UNSPECIFIED)
    splash.width := SPLASH_DEFAULT_WIDTH
  ;  Similarly, object_height is set to zero if the object is not present:
  if (splash.object_height == COORD_UNSPECIFIED)
    splash.object_height := 0

  ;  Lay out client area.  If height is COORD_UNSPECIFIED, use a temp value for now until
  ;  it can be later determined.
  client_rect.Fill(), draw_rect.Fill()
  SetRect(client_rect[], 0, 0, splash.width, splash.height == COORD_UNSPECIFIED ? 500 : splash.height)

  ;  Create fonts based on specified point sizes.  A zero value for font_size1 & 2 are correctly handled
  ;  by CreateFont():
  if (aMainText!="")
  {
    ;  If a zero size is specified, it should use the default size.  But the default brought about
    ;  by passing a zero here is not what the system uses as a default, so instead use a font size
    ;  that is 25% larger than the default size (since the default size itself is used for aSubtext).
    ;  On a typical system, the default GUI font's point size is 8, so this will make it 10 by default.
    ;  Also, it appears that changing the system's font size in Control Panel -> Display -> Appearance
    ;  does not affect the reported default font size.  Thus, the default is probably 8/9 for most/all
    ;  XP systems and probably other OSes as well.
    ;  By specifying PROOF_QUALITY the nearest matching font size should be chosen, which should avoid
    ;  any scaling artifacts that might be caused if default_gui_font_height is not 8.
    if (   !(splash.hfont1 := CreateFont(font_size1 ? - MulDiv(font_size1, pixels_per_point_y, 72) : (1.25 * default_gui_font_height)
      , 0, 0, 0, font_weight1 ? font_weight1 : FW_SEMIBOLD, 0, 0, 0, DEFAULT_CHARSET, OUT_TT_PRECIS
      , CLIP_DEFAULT_PRECIS, PROOF_QUALITY, FF_DONTCARE, aFontName!="" ? aFontName : default_font_name))   )
      ;  Call it again with default font in case above failed due to non-existent aFontName.
      ;  Update: I don't think this actually does any good, at least on XP, because it appears
      ;  that CreateFont() does not fail merely due to a non-existent typeface.  But it is kept
      ;  in case it ever fails for other reasons:
      splash.hfont1 := CreateFont(font_size1 ? - MulDiv(font_size1, pixels_per_point_y, 72) : (1.25 * default_gui_font_height)
        , 0, 0, 0, font_weight1 ? font_weight1 : FW_SEMIBOLD, 0, 0, 0, DEFAULT_CHARSET, OUT_TT_PRECIS
        , CLIP_DEFAULT_PRECIS, PROOF_QUALITY, FF_DONTCARE, default_font_name)
    ;  To avoid showing a runtime error, fall back to the default font if other font wasn't created:
    SelectObject(hdc, splash.hfont1 ? splash.hfont1 : hfont_default)
    ;  Calc height of text by taking into account font size, number of lines, and space between lines:
    draw_rect[] := client_rect
    draw_rect.left += splash.margin_x
    draw_rect.right -= splash.margin_x
    splash.text1_height := DrawText(hdc, aMainText, -1, draw_rect[], DT_CALCRECT | DT_WORDBREAK | DT_EXPANDTABS)
  }
  ;  else leave the above fields set to the zero defaults.

  if (font_size2 || font_weight2 || aFontName)
    if (   !(splash.hfont2 := CreateFont(-MulDiv(font_size2, pixels_per_point_y, 72), 0, 0, 0
      , font_weight2, 0, 0, 0, DEFAULT_CHARSET, OUT_TT_PRECIS, CLIP_DEFAULT_PRECIS
      , PROOF_QUALITY, FF_DONTCARE, aFontName!="" ? aFontName : default_font_name))   )
      ;  Call it again with default font in case above failed due to non-existent aFontName.
      ;  Update: I don't think this actually does any good, at least on XP, because it appears
      ;  that CreateFont() does not fail merely due to a non-existent typeface.  But it is kept
      ;  in case it ever fails for other reasons:
      if (font_size2 || font_weight2)
        splash.hfont2 := CreateFont(-MulDiv(font_size2, pixels_per_point_y, 72), 0, 0, 0
          , font_weight2, 0, 0, 0, DEFAULT_CHARSET, OUT_TT_PRECIS, CLIP_DEFAULT_PRECIS
          , PROOF_QUALITY, FF_DONTCARE, default_font_name)
  ; else leave it NULL so that hfont_default will be used.

  ;  The font(s) will be deleted the next time this window is destroyed or recreated,
  ;  or by the g_script destructor.

  bar_y := splash.margin_y + (splash.text1_height ? (splash.text1_height + splash.margin_y) : 0)
  sub_y := bar_y + splash.object_height + (splash.object_height ? splash.margin_y : 0)  ;  Calculate the Y position of each control in the window.

  if (splash.height == COORD_UNSPECIFIED)
  {
    ;  Since the window height was not specified, determine what it should be based on the height
    ;  of all the controls in the window:
    if (aSubText!="")
    {
      SelectObject(hdc, splash.hfont2 ? splash.hfont2 : hfont_default)
      ;  Calc height of text by taking into account font size, number of lines, and space between lines:
      ;  Reset unconditionally because the previous DrawText() sometimes alters the rect:
      draw_rect[] := client_rect
      draw_rect.left += splash.margin_x
      draw_rect.right -= splash.margin_x
      subtext_height := DrawText(hdc, aSubText, -1, draw_rect[], DT_CALCRECT | DT_WORDBREAK)
    }
    else
      subtext_height := 0
    ;  For the below: sub_y was previously calc'd to be the top of the subtext control.
    ;  Also, splash.margin_y is added because the text looks a little better if the window
    ;  doesn't end immediately beneath it:
    splash.height := subtext_height + sub_y + splash.margin_y
    client_rect.bottom := splash.height
  }

  SelectObject(hdc, hfont_old) ;  Necessary to avoid memory leak.
  if !DeleteDC(hdc){
    ErrorLevel := -1
    return  ;  Force a failure to detect bugs such as hdc still having a created handle inside.
  }
  ;  Based on the client area determined above, expand the main_rect to include title bar, borders, etc.
  ;  If the window has a border or caption this also changes top & left *slightly* from zero.
  main_rect[] := client_rect
  AdjustWindowRectEx(main_rect[], style, FALSE, exstyle)
  main_width := main_rect.right - main_rect.left  ;  main.left might be slightly less than zero.
  main_height := main_rect.bottom - main_rect.top ;  main.top might be slightly less than zero.

  work_rect.Fill()
  SystemParametersInfo(SPI_GETWORKAREA, 0, work_rect[], 0)  ;  Get desktop rect excluding task bar.
  work_width := work_rect.right - work_rect.left  ;  Note that "left" won't be zero if task bar is on left!
  work_height := work_rect.bottom - work_rect.top  ;  Note that "top" won't be zero if task bar is on top!

  ;  Seems best (and easier) to unconditionally restrict window size to the size of the desktop,
  ;  since most users would probably want that.  This can be overridden by using WinMove afterward.
  if (main_width > work_width)
    main_width := work_width
  if (main_height > work_height)
    main_height := work_height

  ;  Centering doesn't currently handle multi-monitor systems explicitly, since those calculations
  ;  require API functions that don't exist in Win95/NT (and thus would have to be loaded
  ;  dynamically to allow the program to launch).  Therefore, windows will likely wind up
  ;  being centered across the total dimensions of all monitors, which usually results in
  ;  half being on one monitor and half in the other.  This doesn't seem too terrible and
  ;  might even be what the user wants in some cases (i.e. for really big windows).
  ;  See comments above for why work_rect.left and top are added in (they aren't always zero).
  if (xpos = COORD_UNSPECIFIED)
    xpos := work_rect.left + ((work_width - main_width) // 2)  ;  Don't use splash.width.
  if (ypos = COORD_UNSPECIFIED)
    ypos := work_rect.top + ((work_height - main_height) // 2)  ;  Don't use splash.width.

  ;  CREATE Main Splash Window
  ;  It seems best to make this an unowned window for two reasons:
  ;  1) It will get its own task bar icon then, which is usually desirable for cases where
  ;     there are several progress/splash windows or the window is monitoring something.
  ;  2) The progress/splash window won't prevent the main window from being used (owned windows
  ;     prevent their owners from ever becoming active).
  ;  However, it seems likely that some users would want the above to be configurable,
  ;  so now there is an option to change this behavior.
  dialog_owner := 0 ;THREAD_DIALOG_OWNER  ;  Resolve macro only once to reduce code size.
  If (!splash.hwnd := CreateWindowEx(exstyle, "AutoHotkeyGUI", aTitle, style, xpos, ypos
                ;  v1.0.35.01: For flexibility, allow these windows to be owned by GUIs via +OwnDialogs.
                , main_width, main_height, owned ? (dialog_owner ? dialog_owner : A_ScriptHwnd) : 0
                , 0, A_ModuleHandle, 0))
    return
  OnMessage(WM_ERASEBKGND,splash.hwnd,"SplashImage_OnMessage")
  ,OnMessage(WM_CTLCOLORSTATIC,splash.hwnd,"SplashImage_OnMessage")
  ,OnMessage(WM_SIZE,splash.hwnd,"SplashImage_OnMessage")
  if !(splash.hwnd){
    ErrorLevel:=-1
    return   ;  No error msg since so rare.
  }
  
  if ((style & WS_SYSMENU) || !owned)
  {
    ;  Setting the small icon puts it in the upper left corner of the dialog window.
    ;  Setting the big icon makes the dialog show up correctly in the Alt-Tab menu (but big seems to
    ;  have no effect unless the window is unowned, i.e. it has a button on the task bar).
    
    ;  L17: Use separate big/small icons for best results.
    if (g_script.mCustomIcon)
    {
      big_icon := g_script.mCustomIcon
      small_icon := g_script.mCustomIconSmall ;  Should always be non-NULL when mCustomIcon is non-NULL.
    }
    else
      big_icon := small_icon := LoadImage(A_ModuleHandle, IDI_MAIN & 0xFFFF, IMAGE_ICON, 0, 0, LR_SHARED) ;  Use LR_SHARED to conserve memory (since the main icon is loaded for so many purposes).

    if (style & WS_SYSMENU)
      SendMessage_(splash.hwnd, WM_SETICON, ICON_SMALL, small_icon)
    if (!owned)
      SendMessage_(splash.hwnd, WM_SETICON, ICON_BIG, big_icon)
  }

  ;  Update client rect in case it was resized due to being too large (above) or in case the OS
  ;  auto-resized it for some reason.  These updated values are also used by SPLASH_CALC_CTRL_WIDTH
  ;  to position the static text controls so that text will be centered properly:
  GetClientRect(splash.hwnd, client_rect[])
  splash.height := client_rect.bottom
  splash.width := client_rect.right
  control_width := client_rect.right - (splash.margin_x * 2)

  ;  CREATE Main label
  if (aMainText!="")
  {
    splash.hwnd_text1 := CreateWindowEx(0, "static", aMainText
      , WS_CHILD|WS_VISIBLE|SS_NOPREFIX|(centered_main ? SS_CENTER : SS_LEFT)
      , splash.margin_x, splash.margin_y, control_width, splash.text1_height, splash.hwnd, 0, A_ModuleHandle, 0)
    SendMessage_(splash.hwnd_text1, WM_SETFONT, (splash.hfont1 ? splash.hfont1 : hfont_default), ((1 & 0xffff) | (0 & 0xffff) << 16) & 0xFFFF)
  }

  ;  CREATE Sub label
  if (splash.hwnd_text2 := CreateWindowEx(0, "static", aSubText
    , WS_CHILD|WS_VISIBLE|SS_NOPREFIX|(centered_sub ? SS_CENTER : SS_LEFT)
    , splash.margin_x, sub_y, control_width, (client_rect.bottom - client_rect.top) - sub_y, splash.hwnd, 0, A_ModuleHandle, 0))
    SendMessage_(splash.hwnd_text2, WM_SETFONT, (splash.hfont2 ? splash.hfont2 : hfont_default), ((1 & 0xffff) | (0 & 0xffff) << 16) & 0xFFFF)
  ;  Show it without activating it.  Even with options that allow the window to be activated (such
  ;  as movable), it seems best to do this to prevent changing the current foreground window, which
  ;  is usually desirable for progress/splash windows since they should be seen but not be disruptive:
  if (!initially_hidden)
    ShowWindow(splash.hwnd, SW_SHOWNOACTIVATE)
  return
}