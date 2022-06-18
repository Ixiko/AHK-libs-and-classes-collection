#SingleInstance, Force
#Include %A_ScriptDir%\..\class_XNET.ahk
#Warn

nIfCount := 0,  List := ""
DllCall( "iphlpapi\GetNumberOfInterfaces", "PtrP",nIfCount )

NET := new XNET( False )

Loop % nIfCount {

  NET.InterfaceIndex := A_Index
	List .= "Alias                        	: " 			NET.Alias                                                                                                  	"`r`n"
       .    "Description                 	: " 			NET.Description                                                                                         	"`r`n"
       .	"InterfaceIndex           	: " 			NET.InterfaceIndex                                                                                     	"`r`n"
	   .    "InterfaceLuid               	: " 			NET.InterfaceLuid                                                                                      	"`r`n"
       .    "InterfaceGuid            	: " 			NET.InterfaceGuid                                                                                     	"`r`n"
       .    "Type                          	: " 			"(" NET.Type ") "  			NET.ConvertAlias("Type", NET.Type)                           	"`r`n"
       .    "ConnectionType              	: " 		"(" NET.ConnectionType ") " 	NET.ConvertAlias("ConnectionType", NET.ConnectionType)       	"`r`n"
       .    "TunnelType                 	: " 			"(" NET.TunnelType ") " 	NET.ConvertAlias("TunnelType", NET.TunnelType)       	"`r`n"
	   .	"PhysicalMediumType            	: "			"(" NET.PhysicalMediumType ") " 	NET.ConvertAlias("PhysicalMediumType", NET.PhysicalMediumType)             	"`r`n"
	   .	"AccessType                 	: "				NET.AccessType                                                                                         	"`r`n"
	   .	"DirectionType              	: "				NET.Directiontype                                                                                       	"`r`n"
	   .	"InterfaceAndOperStatusFlags   	: "	NET.InterfaceAndOperStatusFlags                                                               	"`r`n"
	   .	"OperStatus                  	: "				NET.OperStatus                                                                                         	"`r`n"
	   .	"MediaConnectState          	: " 		NET.MediaConnectState                                                                            	"`r`n`r`n"
	}


Gui, Font, S10, Consolas
Gui, Add, Edit, w1600  h880 -Wrap hwndhEdit, % List
Gui, Show,, Network Interfaces (%nIfCount%)
DllCall( "SendMessage", "Ptr",hEdit, "UInt",0xB1, "Ptr",0 , "Ptr",0 ) ; EM_SETSEL
Return


GuiEscape:
GuiClose:
 ExitApp