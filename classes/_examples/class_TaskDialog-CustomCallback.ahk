; Link:
; Author:
; Date:
; for:     	AHK_L

/*


*/

#NoEnv
; ----------------------------------------------------------------------------------------------------------------------
#Include %A_ScriptDir%\..\Class_TaskDialog.ahk
; ----------------------------------------------------------------------------------------------------------------------
Gui, +HwndHGUI
Gui, Add, ListView, w400 r10 vUserAction, Notification|wParam|lParam|Page
LV_ModifyCol(1, 200)
Gui, Show, x50 y50, User Action
Title := "Task Dialog"
Main   := "Main instruction text."
Content  := "Content text."
CommonBtns := ["Yes", "No"]
CustomBtns := ["CustomButton 1", "CustomButton 2", "CustomButton 3", "CustomButton 4"]
; ----------------------------------------------------------------------------------------------------------------------
; Task Dialog ----------------------------------------------------------------------------------------------------------
; ----------------------------------------------------------------------------------------------------------------------
TD := New TaskDialog(Main, Content, Title, CommonBtns, "Green")
TD.SetAlwaysOnTop()
TD.SetCallbackFunc("TaskDialogCustomCallback")
TD.SetParent(HGUI)
; ----------------------------------------------------------------------------------------------------------------------
; Title ----------------------------------------------------------------------------------------------------------------
; ----------------------------------------------------------------------------------------------------------------------
; TD.SetTitle("Task Dialog")
; ----------------------------------------------------------------------------------------------------------------------
; Main -----------------------------------------------------------------------------------------------------------------
; ----------------------------------------------------------------------------------------------------------------------
; TD.SetMain("Main instruction text.", "Blue")
; TD.SetMainText("Main instruction text.")
; TD.SetMainIcon("Blue")
; ----------------------------------------------------------------------------------------------------------------------
; Content --------------------------------------------------------------------------------------------------------------
; ----------------------------------------------------------------------------------------------------------------------
; TD.SetContent("Content text.")
; ----------------------------------------------------------------------------------------------------------------------
; ProgressBar ----------------------------------------------------------------------------------------------------------
; ----------------------------------------------------------------------------------------------------------------------
TD.SetProgressBar()
; ----------------------------------------------------------------------------------------------------------------------
; Radios ---------------------------------------------------------------------------------------------------------------
; ----------------------------------------------------------------------------------------------------------------------
TD.SetRadios(3, "Radio 3", "Radio 2", "Radio 1")
; TD.SetRadioBtns("Radio 1", "Radio 2", "Radio 3")
; TD.SetDefRadio(3)
; TD.NoDefRadio()
; ----------------------------------------------------------------------------------------------------------------------
; Buttons --------------------------------------------------------------------------------------------------------------
; ----------------------------------------------------------------------------------------------------------------------
TD.SetButtons(CommonBtns, CustomBtns, "No", 1, 1)
; TD.SetCommonBtns("No", "Yes")
; TD.SetCustomBtns("CustomButton 1", "CustomButton 2", "CustomButton 3")
; TD.SetDefButton("No")
; TD.SetElevatedButton(2)
; TD.UseCmdLinks()
; ----------------------------------------------------------------------------------------------------------------------
; Expand ---------------------------------------------------------------------------------------------------------------
; ----------------------------------------------------------------------------------------------------------------------
TD.SetExpand("Expanded information text.", "Collapsed control text.", "Expanded control text.", True)
; TD.SetCollapsedCtrl("Collapsed control text.")
; TD.SetExpandedCtrl("Expanded control text.")
; TD.SetExpandedInfo("Expanded information text.")
; TD.ExpandToFooter()
; TD.ExpandByDefault()
; ----------------------------------------------------------------------------------------------------------------------
; Verification ---------------------------------------------------------------------------------------------------------
; ----------------------------------------------------------------------------------------------------------------------
TD.SetVerification("Verification text.")
; ----------------------------------------------------------------------------------------------------------------------
; Footer ---------------------------------------------------------------------------------------------------------------
; ----------------------------------------------------------------------------------------------------------------------
TD.SetFooter("Footer text.`nFor more details visit <A HREF=""http://ahkscript.org"">AutoHotkey</A>", 3)
; TD.SetFooterText("Footer text.")
; TD.SetFooterIcon(3)
; ----------------------------------------------------------------------------------------------------------------------
; Some Flags -----------------------------------------------------------------------------------------------------------
; ----------------------------------------------------------------------------------------------------------------------
; TD.ActivateTimer()
TD.AllowCancel()
TD.CanBeMinimized() ; won't take effect if TD.SetParent() was set
TD.EnableLinks()
; TD.PosRelToWin()
; TD.RtlLayout()
; TD.SizeToContent()
; ----------------------------------------------------------------------------------------------------------------------
Result := TD.Show(RadioID, Verified)
MsgBox, 0, TaskDialog(), Return value: %Result%`nRadioID: %RadioID%`nVerified: %Verified% ; 262144
ExitApp
; ======================================================================================================================
TaskDialogCustomCallback(H, N, W, L, D) {
   ; H : HWND, N : Notificationcode, W : WPARAM, L : LPARAM, D : Data
   Static TDM := {NAVIGATE_PAGE:                 0x0465
                , CLICK_BUTTON:                  0x0466
                , SET_MARQUEE_PROGRESS_BAR:      0x0467
                , SET_PROGRESS_BAR_STATE:        0x0468
                , SET_PROGRESS_BAR_RANGE:        0x0469
                , SET_PROGRESS_BAR_POS:          0x046A
                , SET_PROGRESS_BAR_MARQUEE:      0x046B
                , SET_ELEMENT_TEXT:              0x046C
                , CLICK_RADIO_BUTTON:            0x046E
                , ENABLE_BUTTON:                 0x046F
                , ENABLE_RADIO_BUTTON:           0x0470
                , CLICK_VERIFICATION:            0x0471
                , UPDATE_ELEMENT_TEXT:           0x0472
                , SET_BUTTON_ELEVATION_REQUIRED: 0x0473
                , UPDATE_ICON:                   0x0474}
   Static TDN := {0:  "TDN_CREATED"
                , 1:  "TDN_NAVIGATED"
                , 2:  "TDN_BUTTON_CLICKED"
                , 3:  "TDN_HYPERLINK_CLICKED"
                , 4:  "TDN_TIMER"
                , 5:  "TDN_DESTROYED"
                , 6:  "TDN_RADIO_BUTTON_CLICKED"
                , 7:  "TDN_DIALOG_CONSTRUCTED"
                , 8:  "TDN_VERIFICATION_CLICKED"
                , 9:  "TDN_HELP"
                , 10: "TDN_EXPANDO_BUTTON_CLICKED"
                , CREATED:                0
                , NAVIGATED:              1
                , BUTTON_CLICKED:         2
                , HYPERLINK_CLICKED:      3
                , TIMER:                  4
                , DESTROYED:              5
                , RADIO_BUTTON_CLICKED:   6
                , DIALOG_CONSTRUCTED:     7
                , VERIFICATION_CLICKED:   8
                , HELP:                   9
                , EXPAND_BUTTON_CLICKED:  10}
   TD := Object(D)
   Page := TD.Pages[TD.CurrentPage]
   If (N = TDN.HYPERLINK_CLICKED)
      L := StrGet(L, "UTF-16")
   LV_Modify(LV_Add("", TDN[N], W, L, TD.CurrentPage), "Vis")
   If (N = TDN.BUTTON_CLICKED) && (W > 10) ; user button click
      Return 1 ; S_FALSE -> do not close the task dialog
   Return 0    ; S_OK
}