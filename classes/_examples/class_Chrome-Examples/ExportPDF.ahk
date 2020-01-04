#NoEnv
SetBatchLines, -1

#Include ../Chrome.ahk


; --- Create a new headless Chrome instance ---

FileCreateDir, ChromeProfile
ChromeInst := new Chrome("ChromeProfile", "https://example.com", "--headless")


; --- Connect to the page ---

if !(PageInst := ChromeInst.GetPage())
{
	MsgBox, Could not retrieve page!
	ChromeInst.Kill()
}
else
{
	PageInst.WaitForLoad()
	
	
	; --- Export a PDF of the page ---
	
	; Get the PDF in Base64
	Base64PDF := PageInst.Call("Page.printToPDF").data
	
	; Convert to a normal binary PDF
	Size := Base64_Decode(BinaryPDF, Base64PDF)
	
	; Write the binary PDF to a file
	FileName := "Exported_" A_TickCount ".pdf"
	FileOpen(FileName, "w").RawWrite(BinaryPDF, Size)
	
	; Open the file
	Run, %FileName%
	
	
	; --- Close the Chrome instance ---
	
	try
		PageInst.Call("Browser.close") ; Fails when running headless
	catch
		ChromeInst.Kill()
	PageInst.Disconnect()
}

ExitApp
return


Base64_Encode(ByRef Out, ByRef In, InLen)
{
	DllCall("Crypt32.dll\CryptBinaryToString", "Ptr", &In
	, "UInt", InLen, "UInt", 0x40000001, "Ptr", 0, "UInt*", OutLen)
	VarSetCapacity(Out, OutLen * (1+A_IsUnicode))
	DllCall("Crypt32.dll\CryptBinaryToString", "Ptr", &In
	, "UInt", InLen, "UInt", 0x40000001, "Str", Out, "UInt*", OutLen)
	return OutLen
}

Base64_Decode(ByRef Out, ByRef In)
{
	DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &In, "UInt", StrLen(In)
	, "UInt", 0x1, "Ptr", 0, "UInt*", OutLen, "Ptr", 0, "Ptr", 0)
	VarSetCapacity(Out, OutLen)
	DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &In, "UInt", StrLen(In)
	, "UInt", 0x1, "Str", Out, "UInt*", OutLen, "Ptr", 0, "Ptr", 0)
	return OutLen
}