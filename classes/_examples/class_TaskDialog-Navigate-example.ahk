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
; ----------------------------------------------------------------------------------------------------------------------
; Task Dialog ----------------------------------------------------------------------------------------------------------
; ----------------------------------------------------------------------------------------------------------------------
Title   := "Task Dialog"
Main    := "Main instruction text."
Content := "Content text."
TD := New TaskDialog(Main, Content, Title, , "Green")
TD.SetAlwaysOnTop()
TD.SetCallbackFunc("TaskDialogCustomCallback")
TD.SetParent(A_ScriptHwnd)
; ----------------------------------------------------------------------------------------------------------------------
TD.SetRadios(3, "Radio 1", "Radio 2", "Radio 3")
; ----------------------------------------------------------------------------------------------------------------------
TD.SetCustomBtns("Next")
; ----------------------------------------------------------------------------------------------------------------------
TD.SetVerification("Verification text.", 0)
; ----------------------------------------------------------------------------------------------------------------------
TD.SetFooter("Footer text.", 3)
; ----------------------------------------------------------------------------------------------------------------------
TD.AllowCancel()
; TD.CanBeMinimized() ; won't take effect if TD.SetParent() was set
; ----------------------------------------------------------------------------------------------------------------------
; Page 2 ---------------------------------------------------------------------------------------------------------------
; ----------------------------------------------------------------------------------------------------------------------
TD.AddPage()
; ----------------------------------------------------------------------------------------------------------------------
TD.SetTitle("Task Dialog Page 2")
; ----------------------------------------------------------------------------------------------------------------------
TD.SetMain("Second main instruction.", "Red")
; ----------------------------------------------------------------------------------------------------------------------
TD.SetContent("Second content text.")
; ----------------------------------------------------------------------------------------------------------------------
TD.SetCustomBtns("Previous", "Next")
; ----------------------------------------------------------------------------------------------------------------------
TD.AllowCancel()
; TD.CanBeMinimized() ; won't take effect if TD.SetParent() was set
; ----------------------------------------------------------------------------------------------------------------------
; Page 2 ---------------------------------------------------------------------------------------------------------------
; ----------------------------------------------------------------------------------------------------------------------
TD.AddPage()
; ----------------------------------------------------------------------------------------------------------------------
TD.SetTitle("Task Dialog Page 3")
; ----------------------------------------------------------------------------------------------------------------------
TD.SetMain("Third main instruction.", "Gray")
; ----------------------------------------------------------------------------------------------------------------------
TD.SetContent("Third content text.")
; ----------------------------------------------------------------------------------------------------------------------
TD.SetCustomBtns("Previous")
TD.SetCommonBtns("OK")
; ----------------------------------------------------------------------------------------------------------------------
TD.AllowCancel()
; TD.CanBeMinimized() ; won't take effect if TD.SetParent() was set
; ----------------------------------------------------------------------------------------------------------------------
Result := TD.Show(RadioID, Verified)
MsgBox, 262144, TaskDialog(), Return value: %Result%`nRadioID: %RadioID%`nVerified: %Verified%
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
   LV_Modify(LV_Add("", TDN[N], W, L, TD.CurrentPage), "Vis")
   ; Each click on a common or custom button will close the task dialog,
   ; unless the callback function returns 1 (S_FALSE).
   If (N = TDN.BUTTON_CLICKED) && (W > 10) {    ; custom button click
      If (TD.CurrentPage = 1) && (W = 11)       ; first custom button on page 1 (Next)
         TD.Navigate(2)
      Else If (TD.CurrentPage = 2) && (W = 11)  ; first custom button on page 2 (Previous)
         TD.Navigate(1)
      Else If (TD.CurrentPage = 2) && (W = 12)  ; second custom button on page 2 (Next)
         TD.Navigate(3)
      Else If (TD.CurrentPage = 3) && (W = 11)  ; first custom button on page 3 (Previous)
         TD.Navigate(2)
      Return 1 ; S_FALSE -> do not close the task dialog
   }
   Return 0    ; S_OK
}