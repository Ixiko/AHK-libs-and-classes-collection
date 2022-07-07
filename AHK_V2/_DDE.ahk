; Thanks to Joy2DWorld and all who helped him!
; Link:
; http://www.autohotkey.com/board/topic/20174-ahk-dde-functions-including-asyncbatchmulti-channel/
/* ======================================================


Step 1:  Connect to a DDE Server.

DDE_connection_Number1 := DDE_Connect("NAME_OF_DDE_SERVER","TOPIC_REQUESTED", OPTIONAL_CONNECTION_NUMBER_1_TO_20, OPTIONAL_HANDLE_OF_DDE_SERVER_WINDOW ) 



if you have more than one connection,  you use the "DDE_connection_Number1", "DDE_connection_Number2"  var to designate in Requests, Pokes, etc..


You can have up to 20 connections WITH THE SAME SERVER ON THE SAME TOPIC.

You do not need a new connection# for different Servers or Different topics!!!!




Step 2:  Send a command:

result := DDE_Execute("[COMMAND YOU WANT TO SEND]", OPTIONAL_CONNECTION_ID_EG_DDE_connection_Number, OPTIONAL_DELAY_NUMBER) 

note:   you do not need to pay attention or use connection ID's unless you have multiple connections.  THE LAST ACCESSED CONNECTION IS THE DEFAULT,  SO DOES NOT NEED TO BE REDESIGNATED, UNLESS YOU WANT TO CHANGE IT.


also can:

result := DDE_Request("[COMMAND]", OPTIONAL_connection_ID, OPTIONAL_DELAY) 
usually_not_one := DDE_Poke("[COMMAND]", "[DATASET FOR COMMAND]",  OPTIONAL_connection_ID, OPTIONAL_DELAY) 




Step 3: (when you're all done!)   Terminate Connection

DDE_KILL("SERVER_NAME","TOPIC", OPTIONAL_CONNECTION_NUMBER) 

DDE_KILL() = kills all open connectinos.


;DDE_Connect("mIRC","COMMAND")
;DDE_Execute("echo -a DDE works")
;DDE_KILL("mIRC","COMMAND")


Super-Powers:  (in additional to multiple connections to same server&topic)

1. You don't need to track open servers & topics,  all done for you.
DDE_Connect(Server,Topic) to existing open topic on that server returns you the Conversation_ID  contained in the "DDE_connection_Number1"  variable in example above.  ie.  Connection_X := DDE_Connect(Server,Topic)  fills Connection_X with the conversation ID for taht conversation.   Can have multiple conversationID's for same topic/server if made on different DDE connection ports:  eg.  DDE_Connect(Server,Topic,2), etc.


2.  BATCH MODE!

uses following Global Bars:

__DDE_Answer_Table  = holds your batch responses.  (You can clear & modify it.. but best to do it in a CRITICAL segment!!  so  not get accidental conflict with new data recepiet)

__DDE_BatchMode = Set this to use batch mode!!

if set,  you do not get Answer := Request('[xxxx')  instead answer goes only to answer table.  IE NO DELAY WAITING FOR ANSWER!!!!!!

__DDE_Use_Answer_Table  =  you DO get an answer, and you ALSO build an answer table

__DDE_SafeMode = for multiple connection  used at same time, etc.  if set TRACKS MESSAGE INCOMING DATA AGAINST INTENDED CONNECTION and SERVER.   This is **IMPORTANT** where you have data comming in from multiple servers and/or connections in NON-BATCH mode.

it makes sure that the answer you get actually comes from the CONNECTION and the SERVER you are expecting it to be from.


usage note:  [and this is well beyond basic use.. if you want to control word, etc.  likely this is not something you even need to read]   __DDE_Use_Answer_Table  and __DDE_SafeMode  should be normal operation mode for multiple active servers & connections with much async data exchange.

if you seek specific response to command X...  all other's will be either qued,  or saved in the answer table....





3. Debug AHK stuff:

__DDE_UseAHKMessages  set to use AHK sendmessage in place of DLL,

will cause crash (eventually)....

option to allow debugging... or 

for those bored with too much stability....



*/   ;======================================================

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  HERE STARTS THE ACTUAL DDE WRAPPER ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;------------------  DDE CLIENT WRAPPER ---------------------------------------

DDE_Connect(DDE_Server,DDE_Topic = "", DDEConnection_ = 0, DDE_Init_To = 0xFFFF )  { 
		; DDE_Init_To = 0 to test to see if connection exists & activate as default
	global
	
	static  DDE_Assigned_Messages
	
	
	local nDDE_Topic, nAppli, Conversation, hAH , sDDE_Topic,sDDE_Server ; , hAHK

	DDE_Connection_ReNumber(DDEConnection_)
	
	if (DDE_Topic = "")
		DDE_Topic := DDE_Server	
		
	if InStr(DDE_Topic . DDE_Server, "\E" , 1) {
		sDDE_Topic := regexreplace(DDE_Topic,"\\E","\E\\E\Q")
		sDDE_Server := regexreplace(DDE_Server,"\\E","\E\\E\Q")
	} else {
		sDDE_Topic = %DDE_Topic%
		sDDE_Server = %DDE_Server%
	}
	
	DDE_Topic_List_Matchme := 
				
	if regexmatch( __DDEM_DDE_Topic_List
				 ,  "\n\Q" 
				. sDDE_Topic 
				. "|" 
				. sDDE_Server 
				.  "|" 
				. DDEConnection_ 
				. "|\E" 
				. "(?<DDE_Server_ID>[^|]++)" 
				. "\|" 
				.  "(?<Client_ID>[^`n]++)", __DDEM_ )  {
				
			__Conversation_BASE := DDEConnection_
							. "|" 
							.  DDE_HEX(__DDEM_DDE_Server_ID)
							. "|" 
							. DDE_HEX(__DDEM_Client_ID)
							
			return __Conversation_BASE
		
	} else if !DDE_Init_To
		return


	if __DDE_UseAHKMessages
		DetectHiddenWindows, On  

	if !DDE_Assigned_Messages {
		CF_TEXT := 1
		WM_DDE_INITIATE   := 0x3E0
		WM_DDE_TERMINATE:= 0x3E1
		WM_DDE_ADVISE   := 0x3E2
		WM_DDE_UNADVISE   := 0x3E3
		WM_DDE_ACK   := 0x3E4
		WM_DDE_DATA   := 0x3E5
		WM_DDE_REQUEST   := 0x3E6
		WM_DDE_POKE   := 0x3E7
		WM_DDE_EXECUTE   := 0x3E8	
		
		__DDE_TableDiv :=  "`n$[_DDE_TABLE_DIV_]$" 
		__DDE_NULL :=  "$[_DDE_NULL_]$"
		
		OnMessage(WM_DDE_ACK , "DDE_ACK")
		OnMessage(WM_DDE_DATA, "DDE_DATA")
		DDE_Assigned_Messages = 1
		
	}


	if !regexmatch(__DDEConnection_Table , "x)\n\Q" 
								. DDEConnection_ 
								. "|\E" 
								. "(?<K>[^`n]++)", hAH ) 
	{
		Gui, %DDEConnection_%: +LastFound 
		Gui, %DDEConnection_%: Show, hide w1 h1 ,__DDEConnection_%DDEConnection_%
		hAHK := WinExist()
		__DDEConnection_Table .= "`n" . DDEConnection_ . "|" . DDE_HEX(hAHK)  ; msgbox % 
	}  	
	
	Ack_W = 

	nAppli := DllCall("GlobalAddAtom", "str", DDE_Server, "Ushort")
	nDDE_Topic := DllCall("GlobalAddAtom", "str", DDE_Topic, "Ushort")

	initWait := 120000
	
	loop 10 {
		sleep 500
		if !__DDE_UseAHKMessages 
			DllCall("SendMessage", "UInt", DDE_Init_To, "UInt", WM_DDE_INITIATE , "UInt", hAHK , "UInt", nAppli | nDDE_Topic << 16) 		
		else
			SendMessage, WM_DDE_INITIATE, hAHK, nAppli | nDDE_Topic << 16,, ahk_id %DDE_Init_To%
		;;
		if (__DDEM_DDE_Server_ID := DDE_WaitA(hAHK, initWait)) 
			break
	}
	
	DllCall("DeleteAtom", "Ushort", nAppli)
	DllCall("DeleteAtom", "Ushort", nDDE_Topic)

	if !(__DDEM_DDE_Server_ID)
		return ( DDE__Tooltips("  ++DDE INITIALIZATION ERROR " . DDE_Topic . hAHK . "++ " , 6000, 4) * 0)

	if !(__DDEM_Client_ID := Ack_Hwnd)  {  ; hAHK ; Ack_Hwnd 
		__DDEM_Client_ID := DDE_HEX(hAHK)
		DDE__Tooltips("++DDE CLIENT HANDLE INITIALIZATION ERROR " . hAHK . " ++" , 3000, 3) 

	}
	
	Conversation :=DDEConnection_  
				. "|" 
				. DDE_HEX(__DDEM_DDE_Server_ID)
				. "|" 
				. DDE_HEX(__DDEM_Client_ID)
	
	__DDEM_DDE_Topic_List .= "`n"  				 
					. DDE_Topic 
					. "|" 
					. DDE_Server 
					. "|" 
					. Conversation
	
	Return (__Conversation_BASE := Conversation ) 
	
}
; :::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	
DDE_Select( byref Conversation) {

	global   
			
	if ( Conversation or (Conversation := __Conversation_BASE) ) and 	Regexmatch(Conversation, "^(?<Connection>[^|]++)\|(?<__DDE_Server_ID>[^|]++)\|(?<Client_ID>.++)$", __DDEM_)
		return 1
		
}

DDE_Connection_ReNumber(byref DDEConnection) {

	if !DDEConnection or (DDEConnection < 1) or (DDEConnection > 21)
		DDEConnection := 20
	else
		DDEConnection += 20
		
}



DDE_Wait(byRef Var, max = 120000) {

	loop  %max% { 
		if (Var <> "") 
			break
		AX++
	}
	if ( AX < MAX  )  ; ie. loop count
		return Var  ; A
}

DDE_WaitS(byRef VarKey, KeyValue, max = 120000) {

	loop  %max% { 
		if (VarKey = KeyValue) 
			break
		AX++
	}
	
	if ( AX < MAX  )  ; ie. loop count
		return 1 
}


DDE_WaitA(Var, max = 60000) {
	global Ack_Hwnd,Ack_W
	; max =60000
	loop  %max% {  ; 1200000 {
		if  (Var = Ack_Hwnd) 
			break
		AX++
	}
	if ( AX < MAX  )  ; ie. loop count
		return Ack_W
}

DDE_Request(Item, Conversation = "", delay = 90000) {

	local hItem 
	
	if !DDE_Select( Conversation)
		return DDE__Tooltips("  DDE UNDEFINED DDE REQUEST ERROR " . Conversation . " ** "  , 6000, 3) 
	
	hItem := DllCall("GlobalAddAtom", "str", Item, "Ushort")	
	DDE__myAnswer =
	DDE__myAnswerKey =
	DDE__Data_Title = 

	if !__DDE_UseAHKMessages
		DllCall("PostMessage", "UInt", __DDEM___DDE_Server_ID, "UInt", WM_DDE_REQUEST , "UInt", __DDEM_Client_ID , "UInt", CF_TEXT | hItem << 16) 
	else
		PostMessage, WM_DDE_REQUEST, __DDEM_Client_ID, CF_TEXT | hItem << 16,, ahk_id %__DDEM___DDE_Server_ID%
	DllCall("DeleteAtom", "Ushort", hItem)	
	
	if __DDE_BatchMode  ; ie. no waiting... just  >>  __DDE_Use_Answer_Table 
		return
		
	If DDE_SafeMode 
		return DDE_WaitS(DDE__myAnswerKey, __DDEM_Client_ID . "|" . __DDEM___DDE_Server_ID, delay) ? DDE__myAnswer : ""
	else if  (DDE_Wait(DDE__myAnswer, delay) = "$[_~~::NULL::~~_]$")
		return
		
	return DDE__myAnswer
}



DDE_Poke(item= "", data = "", Conversation = "", delay = 20000 ) {  

	Global  
	
	local hItem,hData,pData, lParam
	
	if !DDE_Select( Conversation) 
		return DDE__Tooltips("  DDE UNDEFINED DDE POKE  ERROR " . Conversation . " ** "  , 6000, 3) 

	
	DDE__myAnswer =
	Ack_Hwnd =
	 DDE__Data_Title =
	
	If SubStr(Data, -1) <> "`r`n"
	      Data .= "`r`n"

	   hItem := DllCall("GlobalAddAtom", "str", Item, "Ushort")
	   hData := DllCall("GlobalAlloc", "Uint", 0x0002, "Uint", 2+2+StrLen(Data)+1)   
	   pData := DllCall("GlobalLock" , "Uint", hData)
	   
	   
	   DllCall("ntdll\RtlFillMemoryUlong", "Uint", pData, "Uint", 4, "Uint", 1<<13|1<<16) 
	   DllCall("lstrcpy", "Uint", pData+4, "Uint",&Data)
	   DllCall("GlobalUnlock", "Uint", hData)
	   
	   
	   lParam := DllCall("PackDDElParam", "Uint", WM_DDE_POKE, "Uint", hData, "Uint", hItem)
	   
	if !__DDE_UseAHKMessages
		DllCall("PostMessage", "UInt", __DDEM___DDE_Server_ID, "UInt", WM_DDE_POKE , "UInt", __DDEM_Client_ID , "UInt", lParam) 
	else
		PostMessage, WM_DDE_POKE, __DDEM_Client_ID, lParam,, ahk_id %__DDEM___DDE_Server_ID%

	  If ErrorLevel
	   {
	      DllCall("DeleteAtom", "Ushort", hItem)
	   ;   DllCall("GlobalFree", "Uint"  , hData)
	   ;   DllCall("FreeDDElParam", "Uint", WM_DDE_POKE, "Uint", lParam)
	   }
   

	return DDE_WaitA(__DDEM_Client_ID, delay)

}





DDE_Execute(item, Conversation = "", delay = 60000) {

	Global  
	
	local hCmd, pCmd
	
	; WM_DDE_EXECUTE,__DDEM_Client_ID,__DDEM___DDE_Server_ID, DDE__myAnswer, Ack_Hwnd 
	
	
	if !DDE_Select( Conversation) 
		return DDE__Tooltips("  UNDEFINED DDE EXECUTE  ERROR " . Conversation . " ** "  , 6000, 3) 

	
	   hCmd := DllCall("GlobalAlloc", "Uint", 0x0002, "Uint", StrLen(item)+1)
	   pCmd := DllCall("GlobalLock" , "Uint", hCmd)
	   DllCall("lstrcpy", "Uint", pCmd, "str",item)
	   DllCall("GlobalUnlock", "Uint", hCmd)
	   
	DDE__myAnswer =
	Ack_Hwnd =
	 DDE__Data_Title =
	
	if !__DDE_UseAHKMessages
		DllCall("PostMessage", "UInt", __DDEM___DDE_Server_ID, "UInt", WM_DDE_EXECUTE , "UInt", __DDEM_Client_ID , "UInt", hCmd) 
	else
		PostMessage, WM_DDE_EXECUTE, __DDEM_Client_ID, hCmd,, ahk_id %__DDEM___DDE_Server_ID%
	;If ErrorLevel
		 ;  DllCall("GlobalFree", "Uint", hCmd)
	   
	return DDE_WaitA(__DDEM_Client_ID, delay )
	   
}


DDE_ACK(wParam, LParam, MsgID, hWnd) {
	Critical 24
	global Ack_W,Ack_L,Ack_Hwnd,Ack_MsgID
	
	Ack_W := wParam
	Ack_L := LParam
	Ack_MsgID := MsgID
	Ack_Hwnd := hWnd

}


DDE_DATA(wParam, lParam, MsgID, hWnd) {

	Critical 250
	
	Global WM_DDE_ACK, DDE__myAnswer , DDE__myAnswerKey, DDE_SafeMode,__DDE_BatchMode, Data_MsgID, DDE__Data_Title , __DDE_NULL, __DDE_Answer_Table,__DDE_Use_Answer_Table, __DDE_TableDiv,__DDE_UseAHKMessages ; , sInfo
   
					
	nITem = "Defined!"
   
	DllCall("UnpackDDElParam", "Uint", MsgID, "Uint", lParam, "UintP", hData, "UINTP", nItem)
	DllCall(  "FreeDDElParam", "Uint", MsgID, "Uint", lParam)

	pData := DllCall("GlobalLock", "Uint", hData)
	VarSetCapacity(sInfo, DllCall("lstrlen", "Uint", pData+4))
	DllCall("lstrcpy", "str", sInfo, "Uint", pData+4)
	DllCall("GlobalUnlock", "Uint", hData)
	If (*(pData+1) & 0x20)
	DllCall("GlobalFree", "Uint", hData)
	If (*(pData+1) & 0x80) {
		if !__DDE_UseAHKMessages
			DllCall("PostMessage", "UInt", wParam, "UInt", WM_DDE_ACK , "UInt",  hWnd , "UInt", 0x80 << 8 | nItem << 16) 
		else {
			DetectHiddenWindows, On  
			PostMessage, WM_DDE_ACK, hWnd, 0x80 << 8 | nItem << 16,, ahk_id %wParam%
		}
	}
	Data_MsgID := MsgID
	DDE__Data_Title := "Undefined!"
    
	DllCall("GlobalGetAtomName", "UintP", nItem, "STR", DDE__Data_Title, "SHORT", 512)


	DDE__myAnswer := sInfo
	if (DDE__myAnswer = "") and !DDE_SafeMode
		DDE__myAnswer := __DDE_NULL
	DDE__myAnswerKey := DDE_HEX(hWnd) . "|" . DDE_HEX(wParam)  
	
	if ( __DDE_BatchMode or __DDE_Use_Answer_Table )
		__DDE_Answer_Table .= __DDE_TableDiv 
					. DDE__myAnswerKey 
					. "|" 
					.  DDE__Data_Title 
					.  "|" 
					. DDE__myAnswer
					
	return 0

}


DDE_KILL(__DDE_Server="",__DDE_Topic = "", __DDE_DDEConnection_ = 0) {

	local s__DDE_Topic,s__DDE_Server

	DDE_Connection_ReNumber( __DDE_DDEConnection_)
	if (__DDE_Server = "") {
		Loop, Parse, __DDEM_DDE_Topic_List ,`n
		{
			if !A_loopfield
				continue
			 if regexmatch(A_Loopfield, "(?<__DDE_Topic>[^|]++)" 
									. "\|" 
									. "(?<__DDE_Server>[^|]++)" 
									. "\|" 
									. "(?<DDEConnection>[^|]++)",Kill_) and (!__DDE_No_mass_Termination)
				DDE_KILL(Kill___DDE_Server,Kill___DDE_Topic, Kill_DDEConnection - 20)
		}
		
		__DDEM_DDE_Topic_List = 
		__DDEConnection_Table = 
		
		return
	}
	
	if (__DDE_Topic = "")
		__DDE_Topic := __DDE_Server	
	
	if InStr(__DDE_Topic . __DDE_Server, "\E" , 1) {
		s__DDE_Topic := regexreplace(__DDE_Topic,"\\E","\E\\E\Q")
		s__DDE_Server := regexreplace(__DDE_Server,"\\E","\E\\E\Q")
	} else {
		s__DDE_Topic = %__DDE_Topic%
		s__DDE_Server = %__DDE_Server%
	}

	if regexmatch(__DDEM_DDE_Topic_List
				, "\n\Q" 
				. s__DDE_Topic 
				. "|" 
				. s__DDE_Server 
				.  "|" 
				. __DDE_DDEConnection_ 
				. "|\E" 
				. "(?<__DDE_Server_ID>[^|]++)" 
				. "\|" 
				. "(?<Client_ID>[^`n]++)", __DDEM_)  

		__DDEM_DDE_Topic_List := regexreplace(__DDEM_DDE_Topic_List,"x)" 
										. "\n"
										. "[^|]+"  ; __DDE_Topic
										. "\|" 
										. "[^|]+"  ; __DDE_Server
										.  "\|" 
										. "[^|]+"  ; any connection.. (is same id#s!!!)
										. "\Q|" 
										. __DDEM___DDE_Server_ID
										. "|" 
										. __DDEM_Client_ID 
										. "\E(?=\n|$)" , "")  

	if __DDE_Kill_window_on_Kill and  !regexmatch(__DDEM_DDE_Topic_List, "x)"
										. "\n" 
										. "[^|]+" 
										. "\|" 
										. "[^|]+" 
										.  "\|\Q" 
										. __DDE_DDEConnection_ 
										. "|\E" , __DDEM_)   
	{
		__DDEConnection_Table := regexreplace(__DDEConnection_Table,"\n\Q" . __DDE_DDEConnection_ . "|\E[^`n]++","")
		if ( __DDE_DDEConnection_ > 20) and ( __DDE_DDEConnection_ < 51) 
			Gui, %__DDE_DDEConnection_%: destroy
	}
	
	if __DDEM___DDE_Server_ID {
		if !__DDE_UseAHKMessages
			DllCall("PostMessage", "UInt", __DDEM___DDE_Server_ID, "UInt", WM_DDE_TERMINATE , "UInt", hAHK , "Int", 0) 
		else {
			DetectHiddenWindows, On  
			PostMessage,   WM_DDE_TERMINATE,  hAHK  , 0,,ahk_id %__DDEM___DDE_Server_ID%
		}
	} else
	
		return  DDE__Tooltips( " ++DDE UNDEFINED TERMINATION ERROR " . __DDE_Topic . "|" . __DDE_Server . "  " . __DDE_DDEConnection_ . " ** "  , 4000,3) 

	if __DDEM_DDE_Topic_List 
		regexmatch(__DDEM_DDE_Topic_List, "\n" 
					. "[^|]++"					
					. "\|" 
					. "[^|]++" 
					. "\|" 
					.  "(?<Connection_>[^|]++)"
					. "\|" 
					.  "(?<M___DDE_Server_ID>[^|]++)"
					 .  "\|" 
					. "(?<M_Client_ID>[^|]++)"
					. "$", DDE)
	
	if __DDEM___DDE_Server_ID 
		__Conversation_BASE := __DDE_DDEConnection_  
							. "|" 
							.  hex ( __DDEM___DDE_Server_ID )
							. "|" 
							. hex ( __DDEM_Client_ID )

}


DDE_exitapp() {
	DDE_KILL() 
	exitapp
}

DDE__Tooltips(text = "", delay = 3000, id = 1, x = "", y = "") {

	if (id < 1) or (id > 5)
		id := 1
	delay := (delay) ? delay : 3000
	ToolTip, %text%,%x%,%y%,%id%
	if text
		SetTimer, DDE__RemoveToolTip%id%, %delay%
	return 1  ; ie. is set
}
DDE__RemoveToolTips(id = 1) {
	if (id < 1) or (id > 5)
		id := 1
	SetTimer, DDE__RemoveToolTip%id%, Off
	ToolTip,,,,%id%
return


DDE__RemoveToolTip1:
	DDE__RemoveToolTips(2)
return


DDE__RemoveToolTip2:
	DDE__RemoveToolTips(2)
return

DDE__RemoveToolTip3:
	DDE__RemoveToolTips(3)
return

DDE__RemoveToolTip4:
	DDE__RemoveToolTips(4)
return

DDE__RemoveToolTip5:
	DDE__RemoveToolTips(5)
return

}


DDE_hex(HEXME_number) {

	if ((format := A_FormatInteger) != "H") {
		SetFormat Integer, Hex  
		HEXME_number := round(HEXME_number) + 0
		SetFormat Integer, %format%  
		return HEXME_number
	} else 
		return HEXME_number + 0
}



;
; v1.08  [3/20/10]
;
; Copr. 2007,2010.  See License.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END OF DDE CLIENT WRAPPER ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;