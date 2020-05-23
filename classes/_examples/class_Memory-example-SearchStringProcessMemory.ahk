#SingleInstance force
; #classmemory.ahk ; This is incorrect.
#Include <classMemory> ; classMemory.ahk must be placed in your 'lib' folder. Refer to the ahk manual
 
if (_ClassMemory.__Class != "_ClassMemory")
    msgbox class memory not correctly installed. Or the (global class) variable "_ClassMemory" has been overwritten
 
 
winwait, ahk_class Exetic      ; ** Note the capital 'N' in Notepad i.e. ahk_class Notepad vs ahk_class notepad
winget, pid, pid, ahk_class Exetic
notepad := new _ClassMemory("ahk_pid " pid, "", hProcessCopy) ; *** Note the space in "ahk_pid " pid ***
; You can also just do this:
; notepad := new _ClassMemory("ahk_exe notepad.exe", "", hProcessCopy) 
 
if !isObject(notepad) 
{
    msgbox failed to open a handle
    if (hProcessCopy = 0)
        msgbox The program isn't running (not found) or you passed an incorrect program identifier parameter. 
    else if (hProcessCopy = "")
        msgbox OpenProcess failed. If the target process has admin rights, then the script also needs to be ran as admin. Consult A_LastError for more information.
}
 
 
text := "You have been selected"
 
pattern := notepad.stringToPattern(text, "UTF-16") ; My notepad stores this string as unicode, hence I have to specify 'UTF-16' (unicode) as the encoding
 
stringAddress := notepad.processPatternScan(,, pattern*) 

count := 0
address := 0 

if stringAddress > 0  ; you had a typo in stringAddress 
{
    while (address := memObject.processPatternScan(address + 1,, pattern*))  > 0  
          count += 1
    msgbox % count
}
else
{
    msgbox Not Found!`nReturn Value: %stringAddress%
}
 
 
 
ConvertBase(InputBase, OutputBase, number)
{
    static u := A_IsUnicode ? "_wcstoui64" : "_strtoui64"
    static v := A_IsUnicode ? "_i64tow"    : "_i64toa"
    VarSetCapacity(s, 65, 0)
    value := DllCall("msvcrt.dll\" u, "Str", number, "UInt", 0, "UInt", InputBase, "CDECL Int64")
    DllCall("msvcrt.dll\" v, "Int64", value, "Str", s, "UInt", OutputBase, "CDECL")
    return s
}