; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=31547
; Author:	TheDewd
; Date:   	2013-05-29
; for:     	AHK_L

/* The Tinify API allows you to compress and optimize JPEG and PNG images. It is designed as a REST service.

	The Tinify function for AutoHotkey doesn't require authentication or have a maximum upload limit quota
	because it uses the free public API used on the Tinify websites.

	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Examples:
	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	; Compress an external image from a URL and save locally
		Tinify("https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png", "TinyGoogle.png")

	; Compress an image from a file upload and save locally
		Tinify("MyBigImage.png", "MyTinyImage.png")

	; Save the URL of the compressed image to a variable and save locally
		ImgURL := Tinify("MyBigImage.png", "MyTinyImage.png")

	; Save the URL of the compressed image to a variable without saving locally
		ImgURL := Tinify("MyBigImage.png")


*/


Tinify(ImageIn, ImageOut := "") {

	IsURL := (InStr(ImageIn, "/") ? 1 : 0)

	If (IsURL) {
		BodyIn := "{""source"":{""url"":""" ImageIn """}}"
	} Else {
		FileIn := FileOpen(ImageIn, "r")
		BodyIn := ComObjArray(0x11, FileIn.Length)
		DataIn := NumGet(ComObjValue(BodyIn) + 8 + A_PtrSize)
		FileIn.RawRead(DataIn + 0, FileIn.Length)
		FileIn.Close()
	}

	HttpReq := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	HttpReq.SetTimeouts(0, 60000, 30000, 120000)
	HttpReq.Open("POST", "https://tinypng.com/web/shrink")
	HttpReq.SetRequestHeader("Content-Type", (IsURL ? "application/json" : "application/x-www-form-urlencoded"))
	HttpReq.Send(BodyIn)
	HttpReq.WaitForResponse()

	If (SubStr(HttpReq.Status, 1, 1) ~= "4|5") {
		return HttpReq.ResponseText
	}

	tinyURL := HttpReq.GetResponseHeader("Location")

	If (ImageOut) {
		HttpReq.Open("GET", tinyURL)
		HttpReq.Send()
		HttpReq.WaitForResponse()
		FileOut := FileOpen(ImageOut, "w")
		BodyOut := HttpReq.ResponseBody
		DataOut := NumGet(ComObjValue(BodyOut) + 8 + A_PtrSize)
		FileOut.RawWrite(DataOut + 0, BodyOut.MaxIndex() + 1)
	}

	HttpReq := ""
	VarSetCapacity(HttpReq, 0)

	return tinyURL
}