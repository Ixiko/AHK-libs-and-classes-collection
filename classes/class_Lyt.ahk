; https://autohotkey.com/boards/viewtopic.php?t=28258


; System keyboard layout manager
Class Lyt
{
  static SISO639LANGNAME              := 0x0059 ; ISO abbreviated language name, eg "EN"
  static LOCALE_SENGLANGUAGE          := 0x1001 ; Full language name, eg "English"
  static WM_INPUTLANGCHANGEREQUEST    := 0x0050
  static INPUTLANGCHANGE_FORWARD      := 0x0002
  static INPUTLANGCHANGE_BACKWARD     := 0x0004
  static KLIDsREG_PATH                := "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layouts\"
  
  static Layouts := 0
  static TaskBarHwnd := 0
  
  ; =========================================================================================================
  ; PUBLIC METHOD Set()
  ; Parameters:     arg (optional)   - (switch / forward / backward / 2-letter locale indicator name (EN) /
  ;  / number of layout in system loaded layout list / language id e.g. HKL (0x04090409)). Default: switch
  ;                 win (optional)   - (ahk format WinTitle / hWnd / "global"). Default: Active Window
  ; Return value:   empty or description of error
  ; =========================================================================================================
  Set(arg := "switch", win := "")
  {
    IfEqual win, 0, Return "Window not found"
    hWnd := (win = "")
            ? WinExist("A")
            : ( win + 0
                ? WinExist("ahk_id" win)
                : win = "global"
                  ? win
                  : WinExist(win) )
    IfEqual hWnd, 0, Return "Window not found" ; WinExist() return 0

    if (arg = "forward")
    {
      Return this.Change(, this.INPUTLANGCHANGE_FORWARD, hWnd)
    }
    else if (arg = "backward")
    {
      Return this.Change(, this.INPUTLANGCHANGE_BACKWARD, hWnd)
    }
    else if (arg = "switch")
    {
      tmphWnd := (hWnd = "global") ? WinExist("A") : hWnd
      HKL := this.GetInputHKL(tmphWnd)
      HKL_Number := this.GetNum(,HKL)
      LytList := this.GetList()
      Loop % HKL_Number - 1
      {
        If (LytList[A_Index].hkl & 0xFFFF  !=  HKL & 0xFFFF)
          Return this.Change(LytList[A_Index].hkl,, hWnd)
      }
      Loop % LytList.MaxIndex() - HKL_Number
        If (LytList[A_Index + HKL_Number].hkl & 0xFFFF  !=  HKL & 0xFFFF)
          Return this.Change(LytList[A_Index + HKL_Number].hkl,, hWnd)
    }
    else if (arg ~= "^-?[A-z]{2}")
    {
      invert := ((SubStr(arg, 1, 1) = "-") && (arg := SubStr(arg, 2, 2))) ? true : false
      For index, layout in this.GetList()
        if (InStr(layout.LocName, arg) ^ invert)
          Return this.Change(layout.hkl,, hWnd)
      Return "HKL from this locale not found in system loaded layout list"
    }
    else if (arg > 0 && arg <= this.GetList().MaxIndex())
    {
      ; HKL number in system loaded layout list
      Return this.Change(this.GetList()[arg].hkl,, hWnd)
    }
    else if (arg > 0x400 || arg < 0) ; HKL handle input
    {
      For index, layout in this.GetList()
        if layout.hkl = arg
          Return this.Change(arg,, hWnd)
      Return "This HKL not found in system loaded layout list"
    }
    else
      Return "Not valid input"
  }

  Change(HKL := 0, INPUTLANGCHANGE := 0, hWnd := 0)
  {
    Return (hWnd = "global")
      ? this.ChangeGlobal(HKL, INPUTLANGCHANGE)
      : this.ChangeLocal(HKL, INPUTLANGCHANGE, hWnd)
  }

  ChangeGlobal(HKL, INPUTLANGCHANGE) ; in all windows
  {
    If (INPUTLANGCHANGE != 0)
      Return "FORWARD and BACKWARD not support with global parametr."
    IfNotEqual A_DetectHiddenWindows, On, DetectHiddenWindows % (prevDHW := "Off") ? "On" : ""
    WinGet List, List
    Loop % List
      this.ChangeLangRequest(HKL, INPUTLANGCHANGE, List%A_Index%)
    DetectHiddenWindows % prevDHW
  }

  ChangeLocal(HKL, INPUTLANGCHANGE, hWnd)
  {
    (hWnd = this.GetTaskBarHwnd()) ? this.ChangeTaskBar(HKL, INPUTLANGCHANGE) : this.ChangeLangRequest(HKL, INPUTLANGCHANGE, hWnd)
  }

  GetTaskBarHwnd()
  {
    Return this.TaskBarHwnd ? this.TaskBarHwnd : (this.TaskBarHwnd := WinExist("ahk_class Shell_TrayWnd ahk_exe explorer.exe"))
  }

  ChangeTaskBar(HKL, INPUTLANGCHANGE)
  {
    IfNotEqual A_DetectHiddenWindows, On, DetectHiddenWindows % (prevDHW := "Off") ? "On" : ""
    this.ChangeLangRequest(HKL, INPUTLANGCHANGE, hWnd := WinExist("ahk_class Shell_TrayWnd ahk_exe explorer.exe"))
    this.ChangeLangRequest(HKL, INPUTLANGCHANGE, hWnd := WinExist("ahk_class NativeHWNDHost ahk_exe explorer.exe"))
    Sleep 20
    HKL := this.GetInputHKL(hWnd), INPUTLANGCHANGE := 0
    this.ChangeLangRequest(HKL, INPUTLANGCHANGE, hWnd := WinExist("ahk_class CiceroUIWndFrame ahk_exe explorer.exe")) ; to update the Indicator
    this.ChangeLangRequest(HKL, INPUTLANGCHANGE, WinExist("ahk_class DV2ControlHost ahk_exe explorer.exe"))
    DetectHiddenWindows % prevDHW
  }

  ChangeLangRequest(HKL, INPUTLANGCHANGE, hWnd)
  {
    PostMessage, this.WM_INPUTLANGCHANGEREQUEST, % HKL ? "" : INPUTLANGCHANGE, % HKL ? HKL : "",
    , % "ahk_id" ((hWndOwn := DllCall("GetWindow", Ptr, hWnd, UInt, GW_OWNER := 4, Ptr)) ? hWndOwn : hWnd)
  }

  GetNum(win := "", HKL := 0) ; layout Number in system loaded layout list
  {
    HKL ? : HKL := this.GetInputHKL(win)
    If HKL
    {
      For index, layout in this.GetList()
        if (layout.hkl = HKL)
          Return index
    }
    Else If (KLID := this.KLID, this.KLID := "")
      For index, layout in this.GetList()
        if (layout.KLID = KLID)
          Return index
  }

  GetList() ; List of system loaded layouts
  {
    If (!this.Layouts) {
      VarSetCapacity(List, A_PtrSize*5)
      Size := DllCall("GetKeyboardLayoutList", Int, 5, Str, List)
      this.Layouts := []
      Loop % Size
      {
        this.Layouts[A_Index] := {}
        this.Layouts[A_Index].hkl := NumGet(List, A_PtrSize*(A_Index - 1))
        this.Layouts[A_Index].LocName := this.GetLocaleName(, this.Layouts[A_Index].hkl)
        this.Layouts[A_Index].LocFullName := this.GetLocaleName(, this.Layouts[A_Index].hkl, true)
        this.Layouts[A_Index].LayoutName := this.GetLayoutName(, this.Layouts[A_Index].hkl)
        this.Layouts[A_Index].KLID := this.GetKLIDfromHKL(this.Layouts[A_Index].hkl)
      }
    }
    Return this.Layouts
  }

  GetLocaleName(win := "", HKL := false, FullName := false) ; e.g. "EN"
  {
    HKL ? : HKL := this.GetInputHKL(win)
    If HKL
      LocID := HKL & 0xFFFF
    Else If (HKL = 0)  ;ConsoleWindow
      LocID := "0x" . SubStr(this.KLID, -3), this.KLID := ""
    Else
      Return

    LCType := FullName ? this.LOCALE_SENGLANGUAGE : this.SISO639LANGNAME
    Size := (DllCall("GetLocaleInfo", UInt, LocID, UInt, LCType, UInt, 0, UInt, 0) * 2)
    VarSetCapacity(localeSig, Size, 0)
    DllCall("GetLocaleInfo", UInt, LocID, UInt, LCType, Str, localeSig, UInt, Size)
    Return localeSig
  }

  ; Layout name in OS display language - "US" or "United States-Dvorak"
  GetLayoutName(win := "", HKL := false)
  {
    HKL ? : HKL := this.GetInputHKL(win)
    If HKL
      KLID := this.GetKLIDfromHKL(HKL)
    Else If (HKL = 0)  ;ConsoleWindow
      KLID := this.KLID, this.KLID := ""
    Else
      Return

    RegRead LayoutName, % this.KLIDsREG_PATH KLID, Layout Display Name
    DllCall("Shlwapi.dll\SHLoadIndirectString", "Ptr", &LayoutName, "Ptr", &LayoutName, "UInt", outBufSize:=50, "UInt", 0)
    if !LayoutName
      RegRead LayoutName, % this.KLIDsREG_PATH KLID, Layout Text

    Return LayoutName
  }

  ; Only for loaded in system HKL
  GetKLIDfromHKL(HKL)
  {
    VarSetCapacity(KLID, 8 * (A_IsUnicode ? 2 : 1))

    priorHKL := DllCall("GetKeyboardLayout", "Ptr", DllCall("GetWindowThreadProcessId", "Ptr", 0, "UInt", 0, "Ptr"), "Ptr")
    if !DllCall("ActivateKeyboardLayout", "Ptr", HKL, "UInt", 0)
    || !DllCall("GetKeyboardLayoutName", "Ptr", &KLID)
      Return false
    DllCall("ActivateKeyboardLayout", "Ptr", priorHKL, "UInt", 0)

    Return StrGet(&KLID)
  }

  ; =========================================================================================================
  ; PUBLIC METHOD GetInputHKL()
  ; Parameters:     win (optional)   - ("" / hWnd / WinTitle). Default: "" — Active Window
  ; Return value:   HKL of window / if handle incorrect, system default layout HKL return / 0 - if KLID found
  ; =========================================================================================================
  GetInputHKL(win := "")
  {
    If win = 0
      Return,, ErrorLevel := "Window not found"
    hWnd := (win = "")
            ? WinExist("A")
            : win + 0
              ? WinExist("ahk_id" win)
              : WinExist(win)
    If hWnd = 0
      Return,, ErrorLevel := "Window " win " not found"

    WinGetClass, class
    if (class == "ConsoleWindowClass")
    {
        WinGet, consolePID, PID
        DllCall("AttachConsole", Ptr, consolePID)
        VarSetCapacity(KLID, 16)
        DllCall("GetConsoleKeyboardLayoutName", Str, KLID)
        DllCall("FreeConsole")
        this.KLID := KLID
        Return 0
    }
    else
    {
      ; Dvorak on OSx64 0xfffffffff0020409 = -268303351   ->   0xf0020409 = 4026663945 Dvorak on OSx86
      HKL_8B := DllCall("GetKeyboardLayout", Ptr, DllCall("GetWindowThreadProcessId", Ptr, hWnd, UInt, 0, Ptr), Ptr)
      Return (A_PtrSize = 4) ? HKL_8B & 0xFFFFffff : HKL_8B
    }
  }
}
