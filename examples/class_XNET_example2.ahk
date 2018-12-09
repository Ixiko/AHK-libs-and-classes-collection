#SingleInstance, Force
#Include %A_ScriptDir%\..\class_XNET.ahk
#Warn

Net := new XNET( True ) ; Auto select interface ( interface used  by web browsers )

Gui +AlwaysOnTop -MaximizeBox -Minimizebox +Owner
Gui, Font, S10, Arial
Gui, Add, Text, xm   h25 w80  0x200 Right, Transmitted
Gui, Add, Edit, x+20 hp  w120       Right ReadOnly -Tabstop  vTX
Gui, Add, Text, xm   h25 w80  0x200 Right, BPS
Gui, Add, Edit, x+20 hp  w120       Right ReadOnly -Tabstop  vTXBPS
Gui, Add, Text, xm   h25 w80  0x200 Right, Received
Gui, Add, Edit, x+20 hp  w120       Right ReadOnly -Tabstop  vRX
Gui, Add, Text, xm   h25 w80  0x200 Right, BPS
Gui, Add, Edit, x+20 hp  w120       Right ReadOnly -Tabstop  vRXBPS
Gui, Add, StatusBar
Gui, Show,, % Net.Alias
SetTimer, Update, 200

Update:
  Net.Update()
  GuiControl,, TX,    % Net.Tx
  GuiControl,, TXBPS, % Net.TxBPS
  GuiControl,, RX,    % Net.Rx
  GuiControl,, RXBPS, % Net.RxBPS
  SB_SetText( A_Space Net.State )
Return

GuiClose:
GuiEscape:
  ExitApp
 
