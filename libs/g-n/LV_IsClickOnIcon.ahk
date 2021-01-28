; Link:   	https://www.autohotkey.com/boards/viewtopic.php?t=71801
; Author:
; Date:
; for:     	AHK_L

/*


*/

; ----------------------------------------------------------------------------------------------------------------------
; Checks whether the left mouse button was pressed upon a check box icon
; ----------------------------------------------------------------------------------------------------------------------
LV_IsClickOnIcon(HLV, POINTS, ByRef Row, ByRef Col) {
   ; LVM_SUBITEMHITTEST =0x1039
   Col := Row := 0
   VarSetCapacity(LVHTI, 24, 0)
   VarSetCapacity(PTS, 4, 0)
   NumPut(POINTS, PTS, "Int")
   NumPut(NumGet(PTS, 0, "Short"), LVHTI, 0, "Int")
   NumPut(NumGet(PTS, 2, "Short"), LVHTI, 4, "Int")
   If (DllCall("SendMessage", "Ptr", HLV, "UInt", 0x1039, "Ptr", 0, "Ptr", &LVHTI, "Int") <> -1) {
      If (NumGet(LVHTI, 8, "UInt") = 2) {    ; Flags: LVHT_ONITEMICON = 2
         Row := NumGet(LVHTI, 12, "Int") + 1 ; Item
         Col := NumGet(LVHTI, 16, "Int") + 1 ; SubItem
         Return True
      }
   }
   Return False
}