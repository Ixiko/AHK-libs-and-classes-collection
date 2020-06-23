; WinHttpRequest
; Version: 1.00 / 2014-4-3 / tmplinshi
; Tested On: [AHK] 1.1.14.03 A32/U32 | [OS] WinXP SP3
; 
; Usage is similar to HTTPRequest (by VxE),
; Please visit the HTTPRequest page (http://goo.gl/CcnNOY) for more details.
; 
; Supported Options:
; 	NO_AUTO_REDIRECT
; 	Timeout: Seconds
; 	Proxy: IP:Port
; 	Codepage: 65001
; 	Charset: utf-8
; 	SaveAs: FileName
; Return:
; 	Success = -1, Timeout = 0, No response = Empty String
; 
; How to clear cookie:
; 	WinHttpRequest( [] )
; 
; Thanks:
; 	VxE for his HTTPRequest (http://goo.gl/CcnNOY)
WinHttpRequest( URL, ByRef In_POST__Out_Data="", ByRef In_Out_HEADERS="", Options="" )
{
	static nothing := ComObjError(0)
	static oHTTP   := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	static oADO    := ComObjCreate("adodb.stream")

	; Clear cookie: WinHttpRequest( [] )
	If IsObject(URL) {
		oHTTP := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		Return
	}

	; POST or GET
	If (In_POST__Out_Data != "") || InStr(Options, "Method: POST")
		oHTTP.Open("POST", URL, True)
	Else
		oHTTP.Open("GET", URL, True)

	; HEADERS
	If In_Out_HEADERS
	{
		In_Out_HEADERS := Trim(In_Out_HEADERS, " `t`r`n")
		Loop, Parse, In_Out_HEADERS, `n, `r
		{
			If !( _pos := InStr(A_LoopField, ":") )
				Continue

			Header_Name  := SubStr(A_LoopField, 1, _pos-1)
			Header_Value := SubStr(A_LoopField, _pos+1)

			If (  Trim(Header_Value) != ""  )
				oHTTP.SetRequestHeader( Header_Name, Header_Value )
		}
	}

	If (In_POST__Out_Data != "")
		oHTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")

	; Options
	If Options
	{
		Loop, Parse, Options, `n, `r
		{
			If ( _pos := InStr(A_LoopField, "Timeout:") )
				Timeout := SubStr(A_LoopField, _pos+8)
			Else If ( _pos := InStr(A_LoopField, "Proxy:") )
				oHTTP.SetProxy( 2, SubStr(A_LoopField, _pos+6) )
			Else If ( _pos := InStr(A_LoopField, "Codepage:") )
				oHTTP.Option(2) := SubStr(A_LoopField, _pos+9)
		}

		oHTTP.Option(6) := InStr(Options, "NO_AUTO_REDIRECT") ? 0 : 1
	}

	; Send...
	oHTTP.Send(In_POST__Out_Data)
	ReturnCode := oHTTP.WaitForResponse(Timeout ? Timeout : -1)

	; Handle "SaveAs:" and "Charset:"
	If InStr(Options, "SaveAs:")
	{
		RegExMatch(Options, "i)SaveAs:[ \t]*\K[^\r\n]+", SavePath)

		oADO.Type := 1
		oADO.Open()
		oADO.Write( oHTTP.ResponseBody )
		oADO.SaveToFile( SavePath, 2 )
		oADO.Close()

		In_POST__Out_Data := ""
	}
	Else If InStr(Options, "Charset:")
	{
		RegExMatch(Options, "i)Charset:[ \t]*\K\w+", Encoding)

		oADO.Type     := 1
		oADO.Mode     := 3
		oADO.Open()
		oADO.Write( oHTTP.ResponseBody() )
		oADO.Position := 0
		oADO.Type     := 2
		oADO.Charset  := Encoding
		In_POST__Out_Data := IsByRef(In_POST__Out_Data) ? oADO.ReadText() : ""
	}
	Else
		In_POST__Out_Data := IsByRef(In_POST__Out_Data) ? oHTTP.ResponseText : ""
	
	; output headers
	In_Out_HEADERS := "HTTP/1.1 " oHTTP.Status() "`n" oHTTP.GetAllResponseHeaders()

	Return, ReturnCode ; Success = -1, Timeout = 0, No response = Empty String
}