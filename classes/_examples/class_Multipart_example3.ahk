If A_IsUnicode
{
	MsgBox, 48, :(, Please use AutoHotkey ANSI version to run!
	ExitApp
}

#Include <HTTPRequest> ; http://www.autohotkey.com/board/topic/67989-func-httprequest-for-web-apis-ahk-b-ahk-lunicodex64/
#Include <Class_Multipart>

; curl http://pastebin.com/post.php -F "submit_hidden=submit_hidden" -F "post_key=" -F "paste_private=0" -F "paste_name=Test Title" -F "paste_format=149" -F "paste_expire_date=N" -F "paste_code=<test.ahk"
Multipart.Make(PostData, PostHeader
	, "submit_hidden=submit_hidden"
	, "post_key="
	, "paste_private=0"
	, "paste_name=Test Title"
	, "paste_format=149"
	, "paste_expire_date=N"
	, "paste_code=<test.ahk") ; Read content from test.ahk. Or "paste_code=MsgBox, Hi"
HttpRequest("http://pastebin.com/post.php", PostData, PostHeader, "+NO_AUTO_REDIRECT")
Run, % "http://pastebin.com" RegExReplace(PostHeader, "i)^.*Location: ([^\r\n]+).*$", "$1")
Return