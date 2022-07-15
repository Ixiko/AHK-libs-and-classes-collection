; Title:   	SetTaskbarProgress
; Link:     	autohotkey.com/boards/viewtopic.php?f=76&t=87383&sid=d5a1dd8d6825fc76b3189e6a83755907
; Author:
; Date:
; for:     	AHK_L

/*


*/

SetTaskbarProgress(pct, state="", hwnd="") {

	Static tbl, s0:=0, sI:=1, sN:=2, sE:=4, sP:=8
	If !tbl
		Try tbl := ComObjCreate("{56FDF344-FD6D-11d0-958A-006097C9A090}"
	, "{ea1afb91-9e28-4b86-90e9-9e9f8a5eefaf}")
	Catch
		Return 0
	If hwnd =
		hwnd := WinExist()
	If pct is not number
		state := pct, pct := ""
	Else If (pct = 0 && state="")
		state := 0, pct := ""
	If state in 0,I,N,E,P
		DllCall(NumGet(NumGet(tbl+0)+10*A_PtrSize), "uint", tbl, "uint", hwnd, "uint", s%state%)
	If pct !=
		DllCall(NumGet(NumGet(tbl+0)+9*A_PtrSize), "uint", tbl, "uint", hwnd, "int64", pct*10, "int64", 1000)
	Return 1
}