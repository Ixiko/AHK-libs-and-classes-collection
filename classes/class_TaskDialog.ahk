; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=5711
; Author:	just me
; Date:
; for:     	AHK_L

/*


*/

; ======================================================================================================================
Class TaskDialog {
   ; ===================================================================================================================
   ; Instance Variables                =================================================================================
   ; ===================================================================================================================
   ; Do not set this variables directly, use the corresponding methods!!!
   AlwaysOnTop := 0
   CallbackFunc := 0
   HWND := 0
   Parent := 0
   Pages := {Current: 0}
   Width := 0
   ; ===================================================================================================================
   ; Properties                        =================================================================================
   ; ===================================================================================================================
   CurrentPage {
      Get {
         Return This.Pages.Current
      }
      Set {
         If Value Is Integer
            If This.Pages[Value]
               This.Pages.Current := Value
         Return This.CurrentPage
      }
   }
   ; ===================================================================================================================
   ; Constructor                       =================================================================================
   ; ===================================================================================================================
   __New(MainText := "", Content := "", Title := "", CommonBtns := "", MainIcon := "") {
      If ((DllCall("Kernel32.dll\GetVersion", "UInt") & 0xFF) < 6) {
         MsgBox, 16, Class TaskDialog, "You need at least Win Vista / Server 2008 to use this class."
         Return False
      }
      This.AddPage()
      Page := This.Pages[This.CurrentPage]
      If (Title <> "")
      This.SetTitle(Title <> "" ? Title : A_ScriptName)
      If (MainText <> "")
         This.SetMainText(MainText)
      If (MainIcon <> "")
         This.SetMainIcon(MainIcon)
      If (Content <> "")
         This.SetContent(Content)
      If (CommonBtns <> "")
         This.SetCommonBtns(CommonBtns*)
   }
   ; ===================================================================================================================
   ; Task Dialog                       =================================================================================
   ; ===================================================================================================================
   Show(ByRef RadioID := 0, ByRef Verified := 0) {
      Static CommonBtns := ["OK", "CANCEL", , "RETRY", , "YES", "NO", "CLOSE"]
      If !(This.Pages[1])
         Return False
      This.CurrentPage := 1
      This.Create_TDC(TDC)
      If !(RV := DllCall("Comctl32.dll\TaskDialogIndirect"
                       , "Ptr", &TDC, "IntP", ButtonID, "IntP", RadioID, "UIntP", Verified, "UInt")) {
         If (RadioID > 20)
            RadioID -= 20
         If (ButtonID < 10)
            ButtonID := CommonBtns[ButtonID]
         Else
            ButtonID -= 10
         Return This.TimedOut ? "TIMEOUT" : ButtonID
      }
      Throw, "The call of TaskDialogIndirect() failed!`nReturn value: " . RV . "`nLast error: " . A_LastError
      Return False
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetAlwaysOnTop(AOT := True) {
      Return (This.AlwaysOnTop := !!AOT)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetCallbackFunc(FuncName := "") {
      This.CallbackFunc := ""
      If !IsFunc(FuncName) || (Func(FuncName).MaxParams <> 5)
         Return False
      This.CallbackFunc := Func(FuncName)
      Return True
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetParent(Parent) {
      If Parent Is Integer
         If (Parent = 0) Or DllCall("User32.dll\IsWindow", "Ptr", Parent, "UInt")
            This.Parent := Parent
      Return This.Parent
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetWidth(Width) {
      If Width Is Integer
         This.Width := Width
      Return This.Width
   }
   ; ===================================================================================================================
   ; Pages                             =================================================================================
   ; ===================================================================================================================
   AddPage() {
      This.Pages[This.Pages.Current += 1] := New This.TD_Page
      Return This.CurrentPage
   }
   ; -------------------------------------------------------------------------------------------------------------------
   Navigate(Page) { ; short form of TDM_NAVIGATE_PAGE()
      Return This.TDM_NAVIGATE_PAGE(Page)
   }
   ; ===================================================================================================================
   ; Page Title                        =================================================================================
   ; ===================================================================================================================
   SetTitle(TitleText) {
      If (TitleText = "")
         TitleText := A_ScriptName
      Return This.Set_Elem_Text("Title", TitleText)
   }
   ; ===================================================================================================================
   ; Page Main                         =================================================================================
   ; ===================================================================================================================
   SetMain(MainText, MainIcon := 0) {
      Return (This.SetMainText(MainText) && This.SetMainIcon(MainIcon))
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetMainText(MainText) {
      If (MainText = "")
         Return False
      Return This.Set_Elem_Text("Main", MainText)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetMainIcon(MainIcon) {
      Return This.Set_Elem_Icon("MainIcon", MainIcon)
   }
   ; ===================================================================================================================
   ; Page Content                      =================================================================================
   ; ===================================================================================================================
   SetContent(ContentText) {
      Return This.Set_Elem_Text("Content", ContentText)
   }
   ; ===================================================================================================================
   ; Page ProgressBar                  =================================================================================
   ; ===================================================================================================================
   SetProgressBar(Type := "MARQUEE", Show := True) {
      ; TDF_SHOW_PROGRESS_BAR = 0x0200, TDF_SHOW_MARQUEE_PROGRESS_BAR = 0x0400
      Flags := This.SetFlags(0x0600, False)
      If (Show) {
         IF (Type = "MARQUEE")
            Return This.ShowMarqueeProgressBar()
         Else
            Return This.ShowProgressBar()
      }
      Return Flags
   }
   ; ===================================================================================================================
   ; Page Radios                       =================================================================================
   ; First Radio ID   = 21             =================================================================================
   ; Maximum Radio ID = 29             =================================================================================
   ; ===================================================================================================================
   SetRadios(DefRadio := 1, Radios*) {
      ; DefRadio : index of a radio in the Radios array or 0 to set no default radio
      RadiosCount := This.SetRadioBtns(Radios*)
      If (DefRadio < 1)
         This.NoDefRadio()
      Else
         This.SetDefRadio(DefRadio)
      Return RadiosCount
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetRadioBtns(Radios*) {
      ; Radios* : array of radio captions (strings)
      Page := This.Pages[This.CurrentPage]
      Page.Radios := 0
      Page.RadiosCount := 0
      If (Radios.MaxIndex() = "")
         Return True
      If (Radios.MaxIndex() > 9)
         Return False
      Page.RadiosBuf := []
      For ID, Radio In Radios
         If (A_IsUnicode)
            Page.RadiosBuf[ID + 20] := Radio
         Else
            This.To_Unicode(Page.RadiosBuf, ID + 20, Radio)
      Page.RadiosCount := Radios.MaxIndex()
      Page.SetCapacity("RadiosArray", (4 + A_PtrSize) * Page.RadiosCount)
      Addr := Page.Radios := Page.GetAddress("RadiosArray")
      For ID In Page.RadiosBuf {
         Addr := NumPut(ID, Addr + 0, "Int")
         Addr := NumPut(Page.RadiosBuf.GetAddress(ID), Addr + 0, "Ptr")
      }
      Return Page.RadiosCount
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetDefRadio(Radio) {
      ; Radio : radio button number (integer)
      Page := This.Pages[This.CurrentPage]
      Return !!(Page.DefRadio := Page.RadiosBuf.HasKey(Radio + 20) ? Radio + 20 : 0)
   }
   ; ===================================================================================================================
   ; Page Buttons                      =================================================================================
   ; First custom button ID   = 11     =================================================================================
   ; Maximum custom button ID = 19     =================================================================================
   ; ===================================================================================================================
   SetButtons(CommonBtns := "", CustomBtns := "", DefButton := "", UseCmdLinks := 0, ElevatedButton := "") {
      This.SetCommonBtns(CommonBtns*)
      This.SetCustomBtns(CustomBtns*)
      This.SetDefButton(DefButton)
      This.SetElevatedButton(ElevatedButton)
      This.UseCmdLinks(UseCmdLinks)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetCommonBtns(Buttons*) {
      ; Buttons* : array of common button names (strings)
      Static TDBTNS := {OK: 1, YES: 2, NO: 4, CANCEL: 8, RETRY: 16, CLOSE: 32}
      Page := This.Pages[This.CurrentPage]
      BTNS := 0
      For Each, Btn In Buttons
         BTNS |= (B := TDBTNS[Btn]) ? B : 0
      Page.CommonBtns := BTNS
      Return True
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetCustomBtns(Buttons*) {
      ; Buttons* : array of button captions (strings)
      Page := This.Pages[This.CurrentPage]
      Page.Buttons := 0
      Page.ButtonsCount := 0
      If (Buttons.MaxIndex() = "")
         Return True
      If (Buttons.MaxIndex() > 9)
         Return False
      Page.ButtonsBuf := []
      For Index, Button In Buttons
         If (A_IsUnicode)
            Page.ButtonsBuf[Index + 10] := Button
         Else
            This.To_Unicode(Page.ButtonsBuf, Index + 10, Button)
      Page.ButtonsCount := Buttons.MaxIndex()
      Page.SetCapacity("ButtonsArray", (4 + A_PtrSize) * Page.ButtonsCount)
      Addr := Page.Buttons := Page.GetAddress("ButtonsArray")
      For ID In Page.ButtonsBuf {
         Addr := NumPut(ID, Addr + 0, "Int")
         Addr := NumPut(Page.ButtonsBuf.GetAddress(ID), Addr + 0, "Ptr")
      }
      Return True
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetDefButton(Button) {
      ; Button: common button name (string) or custom button index (integer)
      Return !!(This.Pages[This.CurrentPage].DefButton := This.GetButtonID(Button))
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetElevatedButton(Button, State := True) {
      ; Button: common button name (string) or custom button index (integer)
      Return !!(This.Pages[This.CurrentPage].ElevatedBtn := (State ? This.GetButtonID(Button) : 0))
   }
   ; -------------------------------------------------------------------------------------------------------------------
   GetButtonID(Button) {
      ; Button: common button name (string) or custom button index (integer)
      Static CommonBtns := {OK: 1, CANCEL: 2, RETRY: 4, YES: 6, NO: 7, CLOSE: 8}
      If CommonBtns.HasKey(Button)
         ID := CommnonBtns[Button]
      Else If This.Pages[This.CurrentPage].ButtonsBuf.HasKey(Button + 10)
         ID := Button + 10
      Else
         ID := 0
      Return ID
   }
   ; ===================================================================================================================
   ; Page Expand                       =================================================================================
   ; ===================================================================================================================
   SetExpand(ExpandedInfo, CollapsedCtrl := "", ExpandedCtrl := "", ExpandToFooter := False) {
      Return This.SetExpandedInfo(ExpandedInfo) && This.SetCollapsedCtrl(CollapsedCtrl)
             && This.SetExpandedCtrl(ExpandedCtrl) && This.ExpandToFooter(ExpandToFooter)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetCollapsedCtrl(CollapsedCtrlText := "") {
      Return This.Set_Elem_Text("CollapsedCtrl", CollapsedCtrlText)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetExpandedCtrl(ExpandedCtrlText := "") {
      Return This.Set_Elem_Text("ExpandedCtrl", ExpandedCtrlText)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetExpandedInfo(ExpandedInfoText := "") {
      Return This.Set_Elem_Text("ExpandedInfo", ExpandedInfoText)
   }
   ; ===================================================================================================================
   ; Page Verification                 =================================================================================
   ; ===================================================================================================================
   SetVerification(VerificationText := "", VerificationChecked := False) {
      This.VerificationChecked((VerificationText <> "") && (VerificationChecked))
      Return This.Set_Elem_Text("Verification", VerificationText)
   }
   ; ===================================================================================================================
   ; Page Footer                       =================================================================================
   ; ===================================================================================================================
   SetFooter(FooterText, FooterIcon := 0) {
      Return (This.SetFooterText(FooterText) && This.SetFooterIcon(FooterIcon))
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetFooterText(FooterText) {
      Return This.Set_Elem_Text("Footer", FooterText)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetFooterIcon(FooterIcon) {
      Return This.Set_Elem_Icon("FooterIcon", FooterIcon)
   }
   ; ===================================================================================================================
   ; Page Flags                        =================================================================================
   ; ===================================================================================================================
   ; see dwFlags on msdn.microsoft.com/en-us/library/bb787473(v=vs.85).aspx
   ; -------------------------------------------------------------------------------------------------------------------
   ActivateTimer(Activate := True) {
      ; TDF_CALLBACK_TIMER = 0x0800
      Return This.SetFlags(0x0800, Activate)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   AllowCancel(Allow := True) {
      ; TDF_ALLOW_DIALOG_CANCELLATION = 0x0008
      Return This.SetFlags(0x0008, Allow)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   CanBeMinimized(CanBe := True) {
      ; TDF_CAN_BE_MINIMIZED = 0x8000
      Return This.SetFlags(0x8000, CanBe)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   EnableLinks(Enable := True) {
      ; TDF_ENABLE_HYPERLINKS = 0x0001
      Return This.SetFlags(0x0001, Enable)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ExpandByDefault(Expand := True) {
      ; TDF_EXPANDED_BY_DEFAULT = 0x0080
      Return This.SetFlags(0x0080, Expand)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ExpandToFooter(ToFooter := True) {
      ; TDF_EXPAND_FOOTER_AREA = 0x0040
      Return This.SetFlags(0x0040, ToFooter)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   NoDefRadio(NoDef := True) {
      ; TDF_NO_DEFAULT_RADIO_BUTTON = 0x4000
      Return This.SetFlags(0x4000, NoDef)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   PosRelToWin(Rel := True) {
      ; TDF_POSITION_RELATIVE_TO_WINDOW = 0x1000
      Return This.SetFlags(0x1000, Rel)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   RtlLayout(Rtl := True) {
      ; TDF_RTL_LAYOUT = 0x2000
      Return This.SetFlags(0x2000, Rtl)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ShowMarqueeProgressBar(Show := True) {
      ; TDF_SHOW_MARQUEE_PROGRESS_BAR = 0x0400
      Return This.SetFlags(0x0400, Show)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ShowProgressBar(Show := True) {
      ; TDF_SHOW_PROGRESS_BAR = 0x0200
      Return This.SetFlags(0x0200, Show)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SizeToContent(ToContent := True) {
      ; TDF_SIZE_TO_CONTENT = 0x01000000
      Return This.SetFlags(0x01000000, ToContent)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   UseCmdLinks(Use := 1) {
      ; TDF_USE_COMMAND_LINKS = 0x0010, TDF_USE_COMMAND_LINKS_NO_ICON = 0x0020
      Static UCL := {1: 0x0010, 2: 0x0020}
      This.SetFlags(0x0030, False)
      If UCL.HasKey(Use)
         This.SetFlags(UCL[Use], True)
      Return This.Pages[This.CurrentPage].Flags
   }
   ; -------------------------------------------------------------------------------------------------------------------
   VerificationChecked(Checked := True) {
      ; TDF_VERIFICATION_FLAG_CHECKED = 0x0100
      Return This.SetFlags(0x0100, Checked)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetFlags(Flags, Set := True) { ; !!! for advanced users only !!!
      This.Pages[This.CurrentPage].Flags &= ~Flags
      If (Set)
         This.Pages[This.CurrentPage].Flags |= Flags
      Return This.Pages[This.CurrentPage].Flags
   }
   ; ===================================================================================================================
   ; Task Dialog Messsages             =================================================================================
   ; ===================================================================================================================
   TDM_CLICK_BUTTON(BtnID) {
      ; TDM_CLICK_BUTTON = 0x0466 -> http://msdn.microsoft.com/en-us/library/bb787499(v=vs.85).aspx
      If !(This.HWND)
         Return False
      DllCall("User32.dll\PostMessage", "Ptr", This.HWND, "Int", 0x0466, "Ptr", BtnID, "Ptr", 0)
      Return BtnID
   }
   ; -------------------------------------------------------------------------------------------------------------------
   TDM_CLICK_RADIO_BUTTON(RadioID) {
      ; TDM_CLICK_RADIO_BUTTON = 0x046E -> http://msdn.microsoft.com/en-us/library/bb787501(v=vs.85).aspx
      If !(This.HWND)
         Return False
      DllCall("User32.dll\PostMessage", "Ptr", This.HWND, "Int", 0x046E, "Ptr", RadioID, "Ptr", 0)
      Return RadioID
   }
   ; -------------------------------------------------------------------------------------------------------------------
   TDM_CLICK_VERIFICATION(Check := True, Focus := True) {
      ; TDM_CLICK_VERIFICATION = 0x0471 -> http://msdn.microsoft.com/en-us/library/bb787503(v=vs.85).aspx
      If !(This.HWND)
         Return False
      DllCall("User32.dll\PostMessage", "Ptr", This.HWND, "Int", 0x0471, "Ptr", !!Check, "Ptr", !!Focus)
      Return !!Check
   }
   ; -------------------------------------------------------------------------------------------------------------------
   TDM_ENABLE_BUTTON(BtnID, Enable := True) {
      ; TDM_ENABLE_BUTTON = 0x046F -> http://msdn.microsoft.com/en-us/library/bb787505(v=vs.85).aspx
      If !(This.HWND)
         Return False
      DllCall("User32.dll\PostMessage", "Ptr", This.HWND, "UInt", 0x046F, "Ptr", BtnID, "Ptr", !!Enable)
      Return BtnID
   }
   ; -------------------------------------------------------------------------------------------------------------------
   TDM_ENABLE_RADIO_BUTTON(RadioID, Enable := True) {
      ; TDM_ENABLE_RADIO_BUTTON = 0x0470 -> http://msdn.microsoft.com/en-us/library/bb787507(v=vs.85).aspx
      If !(This.HWND)
         Return False
      DllCall("User32.dll\PostMessage", "Ptr", This.HWND, "UInt", 0x046F, "Ptr", BtnID, "Ptr", !!Enable)
      Return BtnID
   }
   ; -------------------------------------------------------------------------------------------------------------------
   TDM_NAVIGATE_PAGE(Page) {
      ; TDM_NAVIGATE_PAGE = 0x0465 -> http://msdn.microsoft.com/en-us/library/bb787509(v=vs.85).aspx
      If !(This.HWND)
         Return False
      If This.Pages[Page]
         This.CurrentPage := Page
      Else
         Return False
      This.Create_TDC(TDC)
      Return DllCall("User32.dll\SendMessage", "Ptr", This.HWND, "UInt", 0x0465, "Ptr", 0, "Ptr", &TDC)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   TDM_SET_BUTTON_ELEVATION_REQUIRED(BtnID, Required := True) {
      ; TDM_SET_BUTTON_ELEVATION_REQUIRED = 0x0473 -> http://msdn.microsoft.com/en-us/library/bb787511(v=vs.85).aspx
      If !(This.HWND)
         Return False
      DllCall("User32.dll\PostMessage", "Ptr", This.HWND, "Int", 0x0473, "Ptr", BtnID, "Ptr", !!Required)
      Return BtnID
   }
   ; -------------------------------------------------------------------------------------------------------------------
   TDM_SET_ELEMENT_TEXT(Elem, Text) {
      ; TDM_SET_ELEMENT_TEXT = 0x046C -> http://msdn.microsoft.com/en-us/library/bb787513(v=vs.85).aspx
      Static TDE := {0: 0, 1: 1, 2: 2, 3: 3, CONTENT: 0, EXPANDED: 1, FOOTER: 2, MAIN: 3}
      If !(This.HWND)
         Return False
      If !(Elem := TDE[Elem])
         Return False
      Return DllCall("User32.dll\SendMessage", "Ptr", This.HWND, "Int", 0x046C, "Ptr", Elem, "WStr", Text)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   TDM_SET_MARQUEE_PROGRESS_BAR(Marquee := True) {
      ; TDM_SET_MARQUEE_PROGRESS_BAR = 0x0467 -> http://msdn.microsoft.com/en-us/library/bb787515(v=vs.85).aspx
      If !(This.HWND)
         Return False
      DllCall("User32.dll\PostMessage", "Ptr", This.HWND, "Int", 0x0467, "Ptr", !!Marquee, "Ptr", 0)
      Return !!Marquee
   }
   ; -------------------------------------------------------------------------------------------------------------------
   TDM_SET_PROGRESS_BAR_MARQUEE(Marquee := True, Refresh := 0) {
      ; TDM_SET_PROGRESS_BAR_MARQUEE = 0x046B -> http://msdn.microsoft.com/en-us/library/bb787517(v=vs.85).aspx
      If !(This.HWND)
         Return False
      If Refresh Is Not Integer
         Refresh = 0
      DllCall("User32.dll\PostMessage", "Ptr", This.HWND, "Int", 0x046B, "Ptr", !!Marquee, "Ptr", Abs(Refresh))
      Return !!Marquee
   }
   ; -------------------------------------------------------------------------------------------------------------------
   TDM_SET_PROGRESS_BAR_POS(Pos) {
      ; TDM_SET_PROGRESS_BAR_POS = 0x046A -> http://msdn.microsoft.com/en-us/library/bb760530(v=vs.85).aspx
      If !(This.HWND)
         Return False
      If Pos Is Not Integer
         Return False
      Return DllCall("User32.dll\PostMessage", "Ptr", This.HWND, "Int", 0x046A, "Ptr", Pos, "Ptr", 0)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   TDM_SET_PROGRESS_BAR_RANGE(Min := 0, Max := 100) {
      ; TDM_SET_PROGRESS_BAR_RANGE = 0x0469 -> http://msdn.microsoft.com/en-us/library/bb760532(v=vs.85).aspx
      If !(This.HWND)
         Return False
      If Min Is Not Integer
         Return False
      If Max Is Not Integer
         Return False
      Range := (Min & 0xFFFF) | ((Max & 0xFFFF) << 16)
      Return DllCall("User32.dll\PostMessage", "Ptr", This.HWND, "Int", 0x0469, "Ptr", 0, "Ptr", Range)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   TDM_SET_PROGRESS_BAR_STATE(State) {
      ; TDM_SET_PROGRESS_BAR_STATE = 0x0468 -> http://msdn.microsoft.com/en-us/library/bb760534(v=vs.85).aspx
      Static PBST := {1: 1, 2: 2, 3: 3, ERROR: 2, NOEMAL: 1, PAUSED: 3}
      If !(This.HWND)
         Return False
      If !(State := PBST[State])
         Return False
      Return DllCall("User32.dll\PostMessage", "Ptr", This.HWND, "Int", 0x0468, "Ptr", State, "Ptr", 0)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   TDM_UPDATE_ELEMENT_TEXT(Elem, Text) {
      ; TDM_UPDATE_ELEMENT_TEXT = 0x0472 -> http://msdn.microsoft.com/en-us/library/bb760536(v=vs.85).aspx
      Static TDE := {0: 0, 1: 1, 2: 2, 3: 3, CONTENT: 0, EXPANDED: 1, FOOTER: 2, MAIN: 3}
      If !(This.HWND)
         Return False
      If !(Elem := TDE[Elem])
         Return False
      Return DllCall("User32.dll\SendMessage", "Ptr", This.HWND, "Int", 0x0472, "Ptr", Elem, "WStr", Text)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   TDM_UPDATE_ICON(Elem, Text) { ; Not implemented!!!
      ; TDM_UPDATE_ICON = 0x0474 -> http://msdn.microsoft.com/en-us/library/bb760538(v=vs.85).aspx
      Return False
   }
   ; ===================================================================================================================
   ; Private classes / methods         =================================================================================
   ; ===================================================================================================================
   Class TD_Page {
      Parent            := 0
      Instance          := 0
      Flags             := 0
      CommonBtns        := 0
      Title             := 0
      MainIcon          := 0
      Main              := 0
      Content             := 0
      ButtonsCount      := 0
      Buttons           := 0
      DefButton         := 0
      RadiosCount       := 0
      Radios            := 0
      DefRadio          := 0
      Verification      := 0
      ExpandedInfo      := 0
      ExpandedCtrl      := 0
      CollapsedCtrl     := 0
      FooterIcon        := 0
      Footer            := 0
      Width             := 0
      TitleBuf          := ""
      MainBuf           := ""
      ContentBuf          := ""
      ButtonsBuf        := []
      ButtonsArray      := ""
      RadiosBuf         := []
      RadiosArray       := ""
      VerificationBuf   := ""
      ExpandedInfoBuf   := ""
      ExpandedCtrlBuf   := ""
      CollapsedCtrlBuf  := ""
      FooterBuf         := ""
   }
   ; -------------------------------------------------------------------------------------------------------------------
   Create_TDC(ByRef TDC) {
      Static TDCB             := RegisterCallback("TaskDialogCallback") ; , "Fast")
           , DBUX             := DllCall("User32.dll\GetDialogBaseUnits", "UInt") & 0xFFFF
           , TDCSize          := (4 * 8) + (A_PtrSize * 16)
           , OffParent        := 4
           , OffInstance      := 4  +  A_PtrSize
           , OffFlags         := 4  + (A_PtrSize * 2)
           , OffCommonBtns    := 8  + (A_PtrSize * 2)
           , OffTitle         := 12 + (A_PtrSize * 2)
           , OffMainIcon      := 12 + (A_PtrSize * 3)
           , OffMain          := 12 + (A_PtrSize * 4)
           , OffContent       := 12 + (A_PtrSize * 5)
           , OffButtonsCount  := 12 + (A_PtrSize * 6)
           , OffButtons       := 16 + (A_PtrSize * 6)
           , OffDefButton     := 16 + (A_PtrSize * 7)
           , OffRadiosCount   := 20 + (A_PtrSize * 7)
           , OffRadios        := 24 + (A_PtrSize * 7)
           , OffDefRadio      := 24 + (A_PtrSize * 8)
           , OffVerification  := 28 + (A_PtrSize * 8)
           , OffExpandedInfo  := 28 + (A_PtrSize * 9)
           , OffExpandedCtrl  := 28 + (A_PtrSize * 10)
           , OffCollapsedCtrl := 28 + (A_PtrSize * 11)
           , OffFooterIcon    := 28 + (A_PtrSize * 12)
           , OffFooter        := 28 + (A_PtrSize * 13)
           , OffCallback      := 28 + (A_PtrSize * 14)
           , OffCallbackData  := 28 + (A_PtrSize * 15)
           , OffWidth         := 28 + (A_PtrSize * 16)
      Page := This.Pages[This.CurrentPage]
      TDFlags := This.Width < 0 ? 0x01000000 : 0 ; TDF_SIZE_TO_CONTENT = 0x01000000
      Page.Width := This.Width >= 0 ? This.Width : 0
      VarSetCapacity(TDC, TDCSize, 0)  ; TASKDIALOGCONFIG structure
      NumPut(TDCSize,               TDC, "UInt")
      NumPut(This.Parent,           TDC, OffParent, "Ptr")
      NumPut(Page.Flags | TDFlags,  TDC, OffFlags, "UInt")
      NumPut(Page.CommonBtns,       TDC, OffCommonBtns, "Int")
      NumPut(Page.Title,            TDC, OffTitle, "Ptr")
      NumPut(Page.MainIcon,         TDC, OffMainIcon, "Ptr")
      NumPut(Page.Main,             TDC, OffMain, "Ptr")
      NumPut(Page.Content,          TDC, OffContent, "Ptr")
      NumPut(Page.ButtonsCount,     TDC, OffButtonsCount, "Int")
      NumPut(Page.Buttons,          TDC, OffButtons, "Ptr")
      NumPut(Page.DefButton,        TDC, OffDefButton, "Int")
      NumPut(Page.RadiosCount,      TDC, OffRadiosCount, "Int")
      NumPut(Page.Radios,           TDC, OffRadios, "Ptr")
      NumPut(Page.DefRadio,         TDC, OffDefRadio, "Int")
      NumPut(Page.Verification,     TDC, OffVerification, "Ptr")
      NumPut(Page.ExpandedInfo,     TDC, OffExpandedInfo, "Ptr")
      NumPut(Page.ExpandedCtrl,     TDC, OffExpandedCtrl, "Ptr")
      NumPut(Page.CollapsedCtrl,    TDC, OffCollapsedCtrl, "Ptr")
      NumPut(Page.FooterIcon,       TDC, OffFooterIcon, "Ptr")
      NumPut(Page.Footer,           TDC, OffFooter, "Ptr")
      NumPut(Page.Width * 4 / DBUX, TDC, OffWidth, "UInt")
      NumPut(TDCB,                  TDC, OffCallback, "Ptr")
      NumPut(&This,                 TDC, OffCallbackData, "Ptr")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   Set_Elem_Icon(Elem, Icon) {
      ; TDF_USE_HICON_MAIN = 0x0002, TDF_USE_HICON_FOOTER = 0x0004
      Static HQUES := DllCall("User32.dll\LoadIcon", "Ptr", 0, "Ptr", 0x7F02, "UPtr")
      Static TDFHICON  := {MAINICON: 0x0002, FOOTERICON: 0x0004}
      Static TDICON    := {FOOTERICON: {1: 1, 2: 2, 3: 3, 4: 4, WARN: 1, ERROR: 2, INFO: 3, SHIELD: 4}
                         , MAINICON:   {1: 1, 2: 2, 3: 3, 4: 4, 5: 5, 6: 6, 7: 7, 8: 8, 9: 9
                                      , WARN: 1, ERROR: 2, INFO: 3, SHIELD: 4, BLUE: 5, YELLOW: 6, RED: 7, GREEN: 8
                                      , GRAY: 9, QUESTION: 0}}
      If !TDFHICON.HasKey(Elem)
         Return False
      Page := This.Pages[This.CurrentPage]
      Page.Flags &= ~TDFHICON[Elem]
      ICO := (I := TDICON[Elem, Icon]) ? 0x10000 - I : 0
      If Icon Is Integer
         If ((Icon & 0xFFFF) <> Icon) ; caller presumably passed HICON
            ICO := Icon
      If (Icon = "Question") && (Elem = "MainIcon")
         ICO := HQUES
      If ((ICO & 0xFFFF) <> ICO)
         Page.Flags |= TDFHICON[Elem]
      Page[Elem] := ICO
      Return True
   }
   ; -------------------------------------------------------------------------------------------------------------------
   Set_Elem_Text(Elem, Text) {
      Page := This.Pages[This.CurrentPage]
      If !Page.HasKey(Elem)
         Return False
      Ptr := Elem
      Buf := Elem . "Buf"
      If (Text = "")
         Page[Ptr] := 0
      Else {
         If (A_IsUnicode)
            Page[Buf] := Text
         Else
            This.To_Unicode(Page, Buf, Text)
         Page[Ptr] := Page.GetAddress(Buf)
      }
      Return True
   }
   ; -------------------------------------------------------------------------------------------------------------------
   To_Unicode(Obj, FieldName, String) {
      Obj.SetCapacity(FieldName, StrPut(String, "UTF-16") << 1)
      StrPut(String, Obj.GetAddress(FieldName), "UTF-16")
   }
}
; ======================================================================================================================
; Private callback function            =================================================================================
; ======================================================================================================================
TaskDialogCallback(H, N, W, L, D) {
   Static TDM_CLICK_BUTTON := 0x0466
        , TDM_SET_BUTTON_ELEVATION_REQUIRED := 0x0473
        , TDN_CREATED := 0
        , TDN_TIMER   := 4
        , TDN_DESTROYED := 5
   Critical
   TD := Object(D)
   Page := TD.Pages[TD.CurrentPage]
   If (N = TDN_CREATED) {
      TD.HWND := H
      If TD.AlwaysOnTop
         DllCall("User32.dll\SetWindowPos", "Ptr", H, "Ptr", -1, "Int", 0, "Int", 0, "Int", 0, "Int" , 0, "UInt", 0x03)
      If Page.ElevatedBtn
         TD.TDM_SET_BUTTON_ELEVATION_REQUIRED(Page.ElevatedBtn)
   }
   Else If (N = TDN_DESTROYED)
      TD.HWND := 0
   Return TD.CallbackFunc ? (TD.CallbackFunc).(H, N, W, L, D) : 0
}