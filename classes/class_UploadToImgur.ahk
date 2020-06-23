; Link:   	https://gist.github.com/tmplinshi/352830d69874dd70ef0c8ea04ab8a732
; Author:
; Date:
; for:     	AHK_L


; Create Imgurl ClientID -- https://api.imgur.com/oauth2/addclient

/*

	ImageFile := "D:\Desktop\test.gif"

	try {
		result := UploadToImgur(ImageFile)
		MsgBox, 64, Upload Successful!, % result
	} catch errMsg {
		MsgBox, 48, Error, % errMsg
	}

*/

UploadToImgur(FileName, ClientID = "fbf77ff49c42c8a") {
	return UploadToImgur.DoIt(FileName, ClientID)
}

Class UploadToImgur {

	DoIt(FileName, ClientID) {
		postData := this.FileToStream(FileName)
		header := {"Authorization": "Client-ID " ClientID}
		whr := this.Http("POST", "https://api.imgur.com/3/image", postData, header)

		if RegExMatch(whr.ResponseText, """link"":""\K[^""]+", result) {
			return StrReplace(result, "\")
		} else {
			RegExMatch(whr.ResponseText, """error"":""\K[^""]+", errMsg)
			throw, errMsg ? errMsg : "Unkown Error"
		}
	}

	FileToStream(FileName) {
		ADO := ComObjCreate("ADODB.Stream")
		ADO.Type := 1 ; adTypeBinary
		ADO.Open()
		ADO.LoadFromFile(FileName)
		Stream := ADO.Read()
		ADO.Close()
		return Stream
	}

	Http(Method, Url, PostData="", Obj_Headers="") {
		whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		whr.Open(Method, Url, True)

		for k, v in Obj_Headers {
			whr.SetRequestHeader(k, v)
		}
		if (Method = "POST") && !Obj_Headers["Content-Type"] {
			whr.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
		}

		whr.Send(PostData)
		whr.WaitForResponse()
		return whr
	}
}