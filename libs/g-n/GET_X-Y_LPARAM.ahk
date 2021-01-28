; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=76&t=27857&p=130624&hilit=#p130624
; Author:	just me
; Date:
; for:     	AHK_L

/*


*/

; Numput() stores the value of lParam (DWORD / UInt) in x86 (litte endian / inverse) byte order.
; So 0xHHHLLHLL becomes LLLHHLHH in memory.
; The x-position (low word) is stored at address_of_buffer + 0.
; The y-position (high word) ist stored at address_of_buffer + 2.
; Using "Short" as type for NumGet() returnes the signed value.

GET_X_LPARAM(lParam) {
   NumPut(lParam, Buffer := "    ", "UInt")
   Return NumGet(Buffer, 0, "Short")
}
GET_Y_LPARAM(lParam) {
   NumPut(lParam, Buffer := "    ", "UInt")
   Return NumGet(Buffer, 2, "Short")
}