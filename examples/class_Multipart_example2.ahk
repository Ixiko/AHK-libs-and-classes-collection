If A_IsUnicode
{
	MsgBox, 48, :(, Please use AutoHotkey ANSI version to run!
	ExitApp
}

#Include <HTTPRequest> ; http://www.autohotkey.com/board/topic/67989-func-httprequest-for-web-apis-ahk-b-ahk-lunicodex64/
#Include <Class_Multipart>

; curl http://uploadpie.com/ -F "uploadedfile=@smile.gif" -F "expire=1" -F "MAX_FILE_SIZE=3145728" -F "upload=1"

Multipart.Make(PostData, PostHeader, "uploadedfile=@smile.gif", "expire=1", "MAX_FILE_SIZE=3145728", "upload=1")
HttpRequest("http://uploadpie.com/", PostData, PostHeader)
Run, % RegExReplace(PostData, "s)^.*id=""uploaded"" value=""([^""]+).*", "$1")
Return