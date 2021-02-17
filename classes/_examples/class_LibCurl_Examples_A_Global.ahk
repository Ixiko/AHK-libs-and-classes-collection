#NoEnv
#Warn All
#Warn LocalSameAsGlobal, Off
#Include LibCurl.ahk


; First function to call is Curl.Initialize.
; Point it to the folder with all necessary dll-files.
Curl.Initialize("Libs")


; Example 1: GetVersion
; ======================
; Returns version string
MsgBox % "Example 1: GetVersion`n"
. "`n" . Curl.GetVersion()


; Example 2: GetVersionInfo
; ==========================
; Returns object with all possible information about this particular build of libcurl
versionInfo := Curl.GetVersionInfo()

versionMsg  := ""
For key, value In versionInfo {
	versionMsg .= key ":`t" value "`n"
}

MsgBox % "Example 2: GetVersionInfo`n"
. "`n" . versionMsg


; Example 3: GetDate
; ===================
; Converts date-string to unix-time integer
; Almost all date-string formats used in HTTP are supported.
; YMDH24MISS is also supported. Default value is A_NowUTC.
MsgBox % "Example 3: GetDate`n"
. "`n" . Curl.GetDate()
. "`n" . Curl.GetDate(19940825012257)
. "`n" . Curl.GetDate("Sun, 06 Nov 1994 08:49:37 GMT")
. "`n" . Curl.GetDate("Sat, 11 Sep 2004 21:32:11 +0200")
. "`n" . Curl.GetDate("20040912 15:05:58 -0700")


; Example 4: EscapeStr / UnescapeStr
; ===================================
; Url-encodes given string.
; You can set encoding as a second argument.
; By default string is converted to UTF-8 prior to encoding.
; Alternatively, you can get pointer to resulting string.

MsgBox % "Example 4.1: EscapeStr"
. "`n"
. "`n  String:"
. "`n" . Curl.EscapeStr("Привет мир")
. "`n"
. "`n  String with encoding:"
. "`n" . Curl.EscapeStr("Γεια Σας Κόσμο", "CP1253")
. "`n"
. "`n  Pointer:"
. "`n" . (strPtr := Curl.EscapeStr("你好世界", "", True))
. "`n"
. "`n  String from pointer:"
. "`n" . StrGet(strPtr, "CP0")

; If you get pointers, free them yourself
Curl._Free(strPtr)


; Url-decodes given string
; You can set encoding as a second argument.
; By default string is converted from UTF-8 after decoding.
; Alternatively, you can get pointer to resulting string.
; If you pass variable as third argument, it will be set to length of resulting string.
MsgBox % "Example 4.2: UnescapeStr"
. "`n"
. "`n  String:"
. "`n" . Curl.UnescapeStr("%E3%83%8F%E3%83%AD%E3%83%BC%E3%83%BB%E3%83%AF%E3%83%BC%E3%83%AB%E3%83%89")
. "`n"
. "`n  String with encoding:"
. "`n" . Curl.UnescapeStr("Merhaba%20D%FCnya", "CP1254")
. "`n"
. "`n  Pointer and length:"
. "`n" . (strPtr := Curl.UnescapeStr("Hej%20v%C3%A4rlden", "", varLen := 0))
. "`n"
. "`n  String from pointer:"
. "`n" . StrGet(strPtr, varLen, "UTF-8") . " (" . varLen . " chars)"

Curl._Free(strPtr)


; Example 5: SniffMimeType
; ========================
; Not a libcurl function, but it's quite handy.
; Tries to detect mime-type from url-string or data buffer.
testData := ""
VarSetCapacity(testData, 256, 0)

testFile := FileOpen("C:\Windows\Web\Wallpaper\Nature\img1.jpg", "r")
testFile.RawRead(&testData, 256)
testFile.Close()

MsgBox % "Example 5: SniffMimeType`n"
. "`n" . Curl.SniffMimeType("http://example.com/test.png")
. "`n" . Curl.SniffMimeType("http://example.com/test.jpg")
. "`n" . Curl.SniffMimeType("http://example.com/test.dll")
. "`n" . Curl.SniffMimeType("", &testData, 16)