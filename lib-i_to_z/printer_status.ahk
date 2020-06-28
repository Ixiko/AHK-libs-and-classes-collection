; Link:
; Author:
; Date:
; for:     	AHK_L

/*

	Defaultprinter :=GetDefaultPrinter()
	status := printerstatus(Defaultprinter)  ;0/1
	if (status<>"")
		msgbox, % Defaultprinter " - status: " (status ? "on" : "off")
	else
		msgbox, % Defaultprinter " - not defined"

	ExitApp

*/



GetDefaultPrinter() {
	If A_OSVersion in WIN_NT4,WIN_95,WIN_98,WIN_ME
		RegRead, var, HKLM\Config\0001\System\CurrentControlSet\Control\Print\Printers, Default
	Else
		RegRead, var, HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows, Device
	StringSplit,var, var, `,
	return var1
}

printerstatus(pn) {
	for objItem in ComObjGet("winmgmts:\\.\root\CIMV2").ExecQuery("SELECT * FROM Win32_Printer where Name='" pn "'",,48)
		return, objItem.WorkOffline+1  ;workoffline (-1/0) -> mit +1 erhalte ich 0 für offline und 1 für online
}
