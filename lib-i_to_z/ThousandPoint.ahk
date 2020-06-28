; Link:
; Author:
; Date:
; for:     	AHK_L

/*

	MsgBox % ts(100000)													; 100.000
	MsgBox % ts(34)														; 34
	MsgBox % ts(21890)													; 21.890
	MsgBox % ts(100.99)													; 100.99	(thousand sep. will be generated based on your local currency settings!).
	MsgBox % ts("4321,99")												; 4.321,99
	MsgBox % ts("4321,9876")											; 4.321,9876

*/


ts(number) {
	Static E, UD													; muß static oder global deklariert werden
	dcpl:=	InStr(number,",") ? (StrSplit(number,","), del := ",")	; evtl vorhandene nachkommastellen ermitteln
		:	InStr(number,".") ?	(StrSplit(number,"."), del := ".")	; ... decimal place (anglo-american style).
		:	""
	Gui, Add, Edit, vE												; 'buddy-control' des folgenden UD. Diese variable enthält den ts-formatierten wert.
	Gui, Add, UpDown, Range-2147483648-2147483647 vUD, % number		; vUD = unformatierter wert: https://ahkde.github.io/docs/commands/GuiControls.htm#UpDown
	GuiControlGet, ConvNo,, E										; abfrage des ts-formatierten wertes
	Gui, Destroy													; Nero-Befehl
	Return ConvNo . del . dcpl[2]									; rückgabe des ts-formatierten wertes (mit ggf nachkommastellen)
	}
