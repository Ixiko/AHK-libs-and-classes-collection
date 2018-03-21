#include FcnLib.ahk
#include thirdParty/httpQuery.ahk
;#include thirdParty/httpQueryInfo.ahk
#include thirdParty/infogulchEncodings.ahk

;lib that TodWulff posted in the channel randomly. And I am forever grateful

;------------------------------------------------------------------------------------------
/* Tool script to work with paste2.org's pastebin service
	requires the http query module: v0.3.5 (w) Sep, 8 2008 by Heresy & derRaphael / zLib-Style release
    requires uriswap (search the forums)
*/

Paste2(Paste_Content, Paste_Description="", Paste_Language="text")	{
	if (Paste_Content="") {
        return "Paste to Paste2.org not affected - null Paste Contents"
		}
    ;FIXME camerb commented this out because he couldn't find the correct lib
    ;Paste_Description := uriSwap(Paste_Description, 3)

    ; =========== Paste_Content := uriSwap(Paste_Content, 3) <-- inlined below...
	f := A_FormatInteger
	p :=
	SetFormat, Integer, Hex
	StringReplace, Paste_Content, Paste_Content,`%,`%25, All
	Loop
		If RegExMatch(Paste_Content, "i)[^\w\.~%/:]", char)	;%
			if asc(char)>0xf
				StringReplace, Paste_Content, Paste_Content, %char%, % "%" . SubStr(Asc(char),3), All
			else
				StringReplace, Paste_Content, Paste_Content, %char%, % "%0" . SubStr(Asc(char),3), All
		Else Break
	SetFormat, Integer, %f%
    ; =========== Paste_Content := uriSwap(Paste_Content, 3) <-- inlined above...

	StringReplace, Paste_Content, Paste_Content,`%01,, All
	StringReplace, Paste_Content, Paste_Content,`%02,, All

	; filedelete, resources/Paste_Content_postencode.txt  								; debug shite
	; fileappend, %Paste_Content%, resources/Paste_Content_postencode.txt  ; debug shite

    URL  := "http://paste2.org/new-paste"
    POST := "lang="   . Paste_Language
         .  "&description="   . Paste_Description
         .  "&code="          . Paste_Content
         .  "&parent=0"

    httpquery(Result_url := "", URL, POST)
    VarSetCapacity(Result_url, -1)

    RegexMatch(Result_url, "Paste\s(\b\d+)", Match)
    if !Match1
		{
			return "Paste to Paste2.org Failed"
		}
    Result_url := "http://paste2.org/p/" . Match1

	return %Result_url%
	}

;------------------------------------------------------------------------------------------

/* Tool script to work with bit.ly's j.mp url shortening service
	it requires the http query module: v0.3.5 (w) Sep, 8 2008 by Heresy & derRaphael / zLib-Style release
	and an api account with bit.ly
*/

ShortURL(LURL)    {
    Global

; FIXME - need to do some return results checking to ensure that there wasn't any server errors
; such as being throttled due to useage, etc.

	if ((lurl = "") or (lurl = " "))
		return

	stringleft, test, lurl, 4
	if (test <> "http")
		lurl := "http://" . lurl

	jmp_login	:= "<snip>"
	jmp_apiKey	:= "<snip>"

	longURL		:= jmp_Enc_Uri(LURL)
    preURL		:= "http://api.j.mp/v3/shorten"
    Auth		:= "?login=" jmp_login "&apiKey=" jmp_apiKey
    longURL		:= "&longUrl=" . longURL
    format		:= "&format=xml"
    URL			:= preURL . Auth . longURL . format
    POSTdata	:= ""

	httpQueryOps := "storeHeader"

    httpQuery(buffer:="",URL,POSTdata,HEADER)
    VarSetCapacity(buffer,-1)

	Short_URL := ""

	Loop, parse, buffer, `n, `r
		{
		ifinstring, A_LoopField, <url>
			{
			Start := instr(A_LoopField, "<url>")
			finish := instr(A_LoopField, "</url>")
			len := finish - start - 5
			Short_URL := substr(A_LoopField,Start+5,len)
			}
		}

	if (Short_URL = "")
		return "Shortener Failed on: ->" . LURL . "<-"
	else
		Return Short_URL
	}
;------------------------------------------------------------------------------------------
jmp_Enc_Uri(uri) {

	; a hack ass butchering of some of titan's encoding scriptz here, but it works...

	StringReplace, uri, uri,`r,, All
	StringReplace, uri, uri,`n,, All
	f = %A_FormatInteger%
	SetFormat, Integer, Hex
	If RegExMatch(uri, "^\w+:/{0,2}", pr)
		StringTrimLeft, uri, uri, StrLen(pr)
	StringReplace, uri, uri,`%,`%25, All
	Loop
		If RegExMatch(uri, "i)[^\w\.~%/:]", char)	;%
			StringReplace, uri, uri, %char%, % "%" . SubStr(Asc(char),3), All
		Else Break
	SetFormat, Integer, %f%
	url := pr . uri

	StringReplace, url, url,`r,, All
	StringReplace, url, url,`n,, All

	StringReplace, url, url,:,`%3A, All
	StringReplace, url, url,`/,`%2F, All
	StringReplace, url, url,(,`%28, All
	StringReplace, url, url,),`%29, All
	StringReplace, url, url,`,,`%2C, All
	StringReplace, url, url,%a_space%,`%20, All

	Return, url

	}
;------------------------------------------------------------------------------------------
/* Tool script to work with goo.gl url shortening service
	it requires a uri encoder - i use titan's
	it requires the http query module: v0.3.5 (w) Sep, 8 2008 by Heresy & derRaphael / zLib-Style release

	note: using j.mp (above) now as goo.gl has useage throttling - 100 per 24 hours I believe...
*/

Goo_gl(url) {
	global
	url = %url%
        enc_url := Enc_Uri(url)
	httpAgent := "toolbar"
	httpQueryOps := "storeHeader"
	httpQuery(html, "http://goo.gl/api/url?url=" . enc_url, " ")
	Loop, parse, HttpQueryHeader, `n, `r
		{
			StringSplit, hdr_Fld, A_LoopField, %A_Space%
			If (hdr_Fld1 = "Location:")
				{
				Short_URL := hdr_Fld2
				break
				}
		}
	Return Short_URL
	}
;------------------------------------------------------------------------------------------
