; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

MsgBox, % "GW " getGateway() "`nIP " getIP()

return

	getGateway(){
		objWMIService := ComObjGet("winmgmts:\\.\root\cimv2")
		colItems := objWMIService.ExecQuery("Select * from Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")._NewEnum
		while colItems[objItem]
			loop,4
				if (objItem.IPAddress[0] == A_IPAddress%a_index%) and !(objItem.DefaultIPGateway[0] = 0)
					return objItem.DefaultIPGateway[0]
		return
	}
	
	getIP(){
		objWMIService := ComObjGet("winmgmts:\\.\root\cimv2")
		colItems := objWMIService.ExecQuery("Select * from Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")._NewEnum
		while colItems[objItem]
			loop,4
				if (objItem.IPAddress[0] == A_IPAddress%a_index%) and !(objItem.DefaultIPGateway[0] = 0)
					return A_IPAddress%a_index%
		return
	}
   