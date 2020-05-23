#SingleInstance Force
#NoEnv	; Recommended for performance and compatibility with future AutoHotkey releases.

#Include %A_ScriptDir%\..\lib-a_to_h\BinReadWrite.ahk	; http://www.autohotkey.com/forum/viewtopic.php?t=7549

fileName1 = C:\tmp\Unicode Text.txt
fileName2 = C:\tmp\Unicode+Bom Text.txt
textToConvert =
(
��This ��impl�� to �v� t��d렻`r
It has �Windows� CP�1252� characters like � � to see how they are translated�
)

; Convert the Ansi text to Unicode

textLength := StrLen(textToConvert)
uniLength := textLength * 2
VarSetCapacity(uniText, uniLength + 1, 0)

DllCall("SetLastError", "UInt", 0)
; http://msdn.microsoft.com/library/default.asp?url=/library/en-us/intl/unicode_17si.asp
r := DllCall("MultiByteToWideChar"
		, "UInt", 0            ; CodePage: CP_ACP=0 (current Ansi), CP_UTF7=65000, CP_UTF8=65001
		, "UInt", 0            ; dwFlags
		, "Str", textToConvert ; LPSTR lpMultiByteStr
		, "Int", textLength    ; cbMultiByte: -1=null terminated
		, "UInt", &uniText     ; LPCWSTR lpWideCharStr
		, "Int", textLength)   ; cchWideChar: 0 to get required size
; Error codes in A_LastError:
; ERROR_INSUFFICIENT_BUFFER = 122
; ERROR_INVALID_FLAGS = 1004
; ERROR_INVALID_PARAMETER = 87
; ERROR_NO_UNICODE_TRANSLATION = 1113

;~ MsgBox % DumpDWORDs(uniText, textLength * 2, true)

; Write it as binary blob to a file

fh := OpenFileForWrite(fileName1)
If (ErrorLevel != 0)
{
	MsgBox 16, Test, Can't open file '%fileName1%': %ErrorLevel%
	Exit
}
WriteInFile(fh, uniText, uniLength)
If (ErrorLevel != 0)
{
	MsgBox 16, Test, Can't write in file '%fileName1%': %ErrorLevel%
	Exit
}
CloseFile(fh)

; Let's re-read this file!

FileGetSize fileSize, %fileName1%
FileRead fileBuffer, %fileName1%

textSize := fileSize / 2
VarSetCapacity(ansiText, textSize, 0)

DllCall("SetLastError", "UInt", 0)
r := DllCall("WideCharToMultiByte"
		, "UInt", 0           ; CodePage: CP_ACP=0 (current Ansi), CP_UTF7=65000, CP_UTF8=65001
		, "UInt", 0           ; dwFlags
		, "UInt", &fileBuffer ; LPCWSTR lpWideCharStr
		, "Int", textSize     ; cchWideChar: size in WCHAR values, -1=null terminated
		, "Str", ansiText     ; LPSTR lpMultiByteStr
		, "Int", textSize     ; cbMultiByte: 0 to get required size
		, "UInt", 0           ; LPCSTR lpDefaultChar
		, "UInt", 0)          ; LPBOOL lpUsedDefaultChar

MsgBox %ansiText%`n---`n=> %ErrorLevel% / %A_LastError% / %r%


;===== Use a Bom

; Convert the Ansi text to Unicode

textLength := StrLen(textToConvert)
uniLength := textLength * 2 + 2
VarSetCapacity(uniText, uniLength + 1, 0)
; Write Bom
DllCall("RtlFillMemory", "UInt", &uniText, "UInt", 1, "UChar", 0xFF)
DllCall("RtlFillMemory", "UInt", &uniText+1, "UInt", 1, "UChar", 0xFE)

DllCall("SetLastError", "UInt", 0)
r := DllCall("MultiByteToWideChar"
		, "UInt", 0             ; CodePage: CP_ACP=0 (current Ansi), CP_UTF7=65000, CP_UTF8=65001
		, "UInt", 0             ; dwFlags
		, "Str", textToConvert  ; LPSTR lpMultiByteStr
		, "Int", textLength     ; cbMultiByte: -1=null terminated
		, "UInt", &uniText + 2  ; LPCWSTR lpWideCharStr
		, "Int", textLength)    ; cchWideChar: 0 to get required size

;~ MsgBox % DumpDWORDs(uniText, textLength * 2, true)

; Write it as binary blob to a file

fh := OpenFileForWrite(fileName2)
If (ErrorLevel != 0)
{
	MsgBox 16, Test, Can't open file '%fileName2%': %ErrorLevel%
	Exit
}
WriteInFile(fh, uniText, uniLength)
If (ErrorLevel != 0)
{
	MsgBox 16, Test, Can't write in file '%fileName2%': %ErrorLevel%
	Exit
}
CloseFile(fh)

; Let's re-read this file!

FileGetSize fileSize, %fileName2%
FileRead fileBuffer, %fileName2%
bufferAddress := &fileBuffer
If (*bufferAddress != 0xFF || *(bufferAddress + 1) != 0xFE)
{
	MsgBox 16, Test, Not a valid Windows Unicode file! (no little-endian Bom)
	Exit
}

textSize := fileSize / 2 - 1
VarSetCapacity(ansiText, textSize, 0)

DllCall("SetLastError", "UInt", 0)
r := DllCall("WideCharToMultiByte"
		, "UInt", 0           ; CodePage: CP_ACP=0 (current Ansi), CP_UTF7=65000, CP_UTF8=65001
		, "UInt", 0           ; dwFlags
		, "UInt", bufferAddress + 2  ; LPCWSTR lpWideCharStr
		, "Int", textSize     ; cchWideChar: size in WCHAR values, -1=null terminated
		, "Str", ansiText     ; LPSTR lpMultiByteStr
		, "Int", textSize     ; cbMultiByte: 0 to get required size
		, "UInt", 0           ; LPCSTR lpDefaultChar
		, "UInt", 0)          ; LPBOOL lpUsedDefaultChar

MsgBox %ansiText%`n---`n=> %ErrorLevel% / %A_LastError% / %r%


;===== UTF-8 handling

textToConvert = « – € œ Œ — »
textLength := StrLen(textToConvert)
VarSetCapacity(uniText, textLength * 2 + 1, 0) ; Worse case (all Ascii)
r := DllCall("MultiByteToWideChar"
		, "UInt", 65001        ; CodePage: CP_ACP=0 (current Ansi), CP_UTF7=65000, CP_UTF8=65001
		, "UInt", 0            ; dwFlags
		, "Str", textToConvert ; LPSTR lpMultiByteStr
		, "Int", textLength    ; cbMultiByte: -1=null terminated
		, "UInt", &uniText     ; LPCWSTR lpWideCharStr
		, "Int", textLength)   ; cchWideChar: 0 to get required size
VarSetCapacity(ansiText, textLength, 0)
r := DllCall("WideCharToMultiByte"
		, "UInt", 0            ; CodePage: CP_ACP=0 (current Ansi), CP_UTF7=65000, CP_UTF8=65001
		, "UInt", 0            ; dwFlags
		, "UInt", &uniText     ; LPCWSTR lpWideCharStr
		, "Int", textLength    ; cchWideChar: size in WCHAR values, -1=null terminated
		, "Str", ansiText      ; LPSTR lpMultiByteStr
		, "Int", textLength    ; cbMultiByte: 0 to get required size
		, "UInt", 0            ; LPCSTR lpDefaultChar
		, "UInt", 0)           ; LPBOOL lpUsedDefaultChar
MsgBox % ansiText


DisplayJapaneseFromUTF8:

WM_SETTEXT = 0x0C

; Do you want to display Japanese?
utf8 = キャッシュ
utf8 = 日本語�ページを検索
charNb := StrLen(utf8)
VarSetCapacity(utf16, charNb * 2 + 1, 0)
DllCall("SetLastError", "UInt", 0)
r := DllCall("MultiByteToWideChar"
		, "UInt", 65001        ; CodePage: CP_ACP=0 (current Ansi), CP_UTF7=65000, CP_UTF8=65001
		, "UInt", 0            ; dwFlags
		, "Str", utf8          ; LPSTR lpMultiByteStr
		, "Int", -1            ; cbMultiByte: -1=null terminated
		, "UInt", &utf16      ; LPCWSTR lpWideCharStr
		, "Int", charNb)       ; cchWideChar: 0 to get required size

; MS Mincho & MS Gothic are two (more or less) free Japanese fonts from Microsoft.
; Available if you install Asian support for IE or can be found on the Net.
; Arial Unicode MS works too... It is found on MS Office CDs.
; http://www.alanwood.net/unicode/fonts.html
Gui Font, s48 w800 c8000FF, MS Mincho
Gui Font, s48 w800 c8000FF, MS Gothic
Gui Font, s48 w800 c8000FF, Arial Unicode MS
Gui Add, Text, w700 h100 x10 y20 center vword, OK
Gui Show, w720 h120, Japanese Text

id := WinExist("A")
ControlGet hWnd, Hwnd, , Static1, ahk_id %id%

; This doesn't work...
;~ SendMessage WM_SETTEXT, , &utf16, Static1, ahk_id %id%
DllCall("SendMessageW"
		,  "UInt", hWnd
		,  "UInt", WM_SETTEXT
		, "UInt", 0
		, "UInt", &utf16)
Return

GuiClose:
GuiEscape:
ExitApp
