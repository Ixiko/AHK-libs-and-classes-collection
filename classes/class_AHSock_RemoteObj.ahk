; Link:		https://www.autohotkey.com/boards/viewtopic.php?f=6&t=79623
; Author:	RazorHalo
; Date:
; for:     	AHK_L

/*





*/

/*  By RazorHalo
	RemoteObj_AHKsock - Using Remote Objects with AHKsock
    Version 1.0 - August 8, 2020

	*** Required Libraries ***
	AHKsock.ahk by TheGood
		https://autohotkey.com/board/topic/53827-ahksock-a-simple-ahk-implementation-of-winsock-tcpip/page-1
	Jxon.ahk by Coco
		https://www.autohotkey.com/boards/viewtopic.php?t=627

	Adapted for AHKsock from the original RemoteObj.ahk by GeekDude
	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=35242
*/


;##############################################################################################
;	REMOTE OBJECT SERVER
;##############################################################################################

Global rObj

class RemoteObjServer {
	;Create a listening port
	__New(Port) {
		If (i := AHKsock_Listen(Port, "rObjServer")) {
            OutputDebug, % "AHKsock_Listen() failed with return value = " i " and ErrorLevel = " ErrorLevel
        }
		rObj := this
	}

	;Add Object to the server
	Add(Obj, ObjID) {
		this[ObjID] := Obj
	}

	;Remove Object from the server
	Remove(ObjID) {
		this.Delete(ObjID)
	}
}

rObjServer(sEvent, iSocket = 0, sName = 0, sAddr = 0, sPort = 0, ByRef bRecvData = 0, bRecvDataLength = 0) {

	If (sEvent = "ACCEPTED") {
		OutputDebug, % "Server - A client connected!"

	} Else If (sEvent = "DISCONNECTED") {
		OutputDebug, % "Server - The client disconnected. Going back to listening..."
		bConnected := False

   } Else If (sEvent = "RECEIVED") {

		OutputDebug, % "Server - We received " bRecvDataLength " bytes."
		OutputDebug, % "Server - Data: " bRecvData

		;We received data.
		Query := Jxon_Load(bRecvData)

		if (Query.Action == "__Get")
			RetVal := rObj[Query.Object][Query.Key]
		else if (Query.Action == "__Set")
			RetVal := rObj[Query.Object][Query.Key] := Query.Value
		else if (Query.Action == "__Call")
			RetVal := rObj[Query.Object][Query.Name].Call(rObj[Query.Object], Query.Params*)

		bData := Jxon_Dump({"RetVal": RetVal})
		bDataLength := StrLen(bData) * 2

		;Send the actual data now
		If ((i := AHKsock_Send(iSocket, &bData, bDataLength)) < 0 ) {
			OutputDebug, % "Server AHKsock_Send failed with return value = " i " and error code = " ErrorLevel " at line " A_LineNumber
		} Else OutputDebug, % "Server - Sent " i " bytes!"
	}
}

;##############################################################################################
;	REMOTE OBJECT CLIENT
;##############################################################################################

class RemoteObjClient {
	__New(Addr, Port) {
		ObjRawSet(this, "__Addr", Addr)
		ObjRawSet(this, "__Port", Port)
	}

	;Add Object to the server
	Add(ObjID) {
		this[ObjID] := new this.rObject
		ObjRawSet(this[ObjID], "__ObjID", ObjID)
		ObjRawSet(this[ObjID], "__Addr", this.__Addr)
		ObjRawSet(this[ObjID], "__Port", this.__Port)
	}

	;Remove Object from the client
	Remove(ObjID) {
		this.Delete(ObjID)
	}

	Class rObject {
		__Get(Key) {
			return rObjSend(this.__Addr, this.__Port, {"Object": this.__ObjID, "Action": "__Get", "Key": Key})
		}

		__Set(Key, Value) {
			return rObjSend(this.__Addr, this.__Port, {"Object": this.__ObjID, "Action": "__Set", "Key": Key, "Value": Value})
		}

		__Call(Name, Params*) {
			return rObjSend(this.__Addr, this.__Port, {"Object": this.__ObjID, "Action": "__Call", "Name": Name, "Params": Params})
		}
	}
}

rObjSend(Addr, Port, Obj) {
	Global oData, oDataLength
	, RetVal := ""
	, WaitForResponse := True

	;Prepare the data for sending
	oData := Jxon_Dump(Obj)
	;Get text length
    oDataLength := StrLen(oData) * 2

	;Connect to the server and initiate the transaction of data
    If (i := AHKsock_Connect(Addr, Port, "rObjClient")) {
        OutputDebug, % "AHKsock_Connect() failed with return value = " i " and ErrorLevel = " ErrorLevel
		WaitForResponse := False
        Return
    }

	OutputDebug % "WAITING for Response from Server"
	;Wait for the server to process the request and respond
	While (WaitForResponse) {
		Sleep 50
	}

	Return RetVal
}

rObjClient(sEvent, iSocket = 0, sName = 0, sAddr = 0, sPort = 0, ByRef bData = 0, iLength = 0) {
	Global oData, oDataLength
	, RetVal
	, WaitForResponse

    If (sEvent = "CONNECTED") {

        ;Check if the connection attempt was succesful
        If (iSocket = -1) {
            OutputDebug, % "Client - AHKsock_Connect() failed."
			WaitForResponse := False
        } Else OutputDebug, % "Client - AHKsock_Connect() successfully connected!"

    } Else If (sEvent = "DISCONNECTED") {

        OutputDebug, % "Client - The server closed the connection."

    } Else If (sEvent = "RECEIVED") {

        OutputDebug, % "Client - We received " iLength " bytes."
        OutputDebug, % "Client - Data: " bData

		;Process the returned value
		RetVal := Jxon_Load(bData).RetVal

		;Exchange is over, close the socket and notify rObjSend()
		AHKsock_Close(iSocket)
		WaitForResponse := False

    } Else If (sEvent = "SEND") {

		If ((i := AHKsock_Send(iSocket, &oData, oDataLength)) < 0) {
			OutputDebug, % "Client AHKsock_Send failed with return value = " i " and error code = " ErrorLevel " at line " A_LineNumber
		} Else OutputDebug, % "Client - Sent " i " bytes!"
	}
}