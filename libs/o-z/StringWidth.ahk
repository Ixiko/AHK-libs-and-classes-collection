; Title:   	AutoGuiSwitch/AutoGuiSwitch.ahk at main · tthreeoh/AutoGuiSwitch
; Link:     	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

StringWidth(String, Font:="", FontSize:=10){
		Gui StringWidth:Font, s%FontSize%, %Font%
		Gui StringWidth:Add, Text, R1, %String%
		GuiControlGet T, StringWidth:Pos, Static1
		Gui StringWidth:Destroy
		return TW
		}