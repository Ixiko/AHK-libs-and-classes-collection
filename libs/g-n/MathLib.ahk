; Title:   	
; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

; -- Math ---------------------------------------------------------
epsilon := 2.71828182845905


Pow(a, x) {
    return Exp(x * Ln(a))
}

LogBase(base, n)
{
    return Ln(n)/Ln(base)
}

; calculs to value
LinearToLogarithmic(sli, floor := false) {
    val := Exp(sli / 100)
    if (floor)
        val := Floor(val)
    return val
}

; value to calculs
LogarithmicToLinear(val) {
    if (val == 0)
        val = 0.000000001
    sli := Ln(val) * 100
    return sli
}
; ----


; -- Variables File Dumping ----------------------------------
global arrayStartSep := "[    "
global arrayEndSep := "    ]"
global dictStartSep := "{    "
global dictEndSep := "    }"
global dictKeyValSep := "  :  "
global objectIndexSep := "  ,  "
global dumpSepLen := StrLen(objectIndexSep)

dumpToFile(val, path, section, name)
{
    dumpableVal := valToDumpableVal(val)
    IniWrite, %dumpableVal%, %path%, %section%, %name%
}

loadDumpedToFile(path, section, name)
{
    IniRead, dumpedVal, %path%, %section%, %name%
    return dumpedValToVal(dumpedVal)
}

deleteDumpedToFile(path, section, name)
{
    IniDelete, %path%, %section%, %name%
}
; --
; -- objects in file --
; -- save
valToDumpableVal(val)
{
    obj := objType(val)
    if (obj == "dict")
        val := dictToDumpableDict(val)
    else if (obj == "array")
        val := arrayToDumpableArray(val)
    return val
}

arrayToDumpableArray(array)
{
    str := arrayStartSep
    for i, val in array
    {
        val := valToDumpableVal(val)
        str := str "" val
        if (i < array.MaxIndex())
            str := str "" objectIndexSep
    }
    return str "" arrayEndSep
}

dictToDumpableDict(dict)
{
    str := dictStartSep
    i := 1
    for key, val in dict
    {
        key := valToDumpableVal(key)
        val := valToDumpableVal(val)
        str := str "" key "" dictKeyValSep "" val
        if (i < dict.Count())
            str := str "" objectIndexSep
        i := i + 1
    }
    return str "" dictEndSep
}

; -- load
dumpedValToVal(dumpedVal)
{
    obj := dumpedObjType(dumpedVal)
    if (obj == "dict")
        val := dumpedDictToDict(dumpedVal)
    else if (obj == "array")
        val := dumpedArrayToArray(dumpedVal)
    else
        val := dumpedVal
    return val
}

dumpedArrayToArray(dumpedArray)
{
    array := []
    dumpedArray := removeDumpedObjDelimiters(dumpedArray)
    dumpedArray := StrSplit(dumpedArray)

    numSubObject := 0
    val := ""

    i := 1
    while (i <= dumpedArray.MaxIndex())
    {
        char := dumpedArray[i]
        nextSepLenChars := getNextSepLenChars(i, dumpedArray)

        if (nextSepLenChars == dictStartSep or nextSepLenChars == arrayStartSep)
            numSubObject := numSubObject + 1
        else if (nextSepLenChars == dictEndSep or nextSepLenChars == arrayEndSep)
            numSubObject := numSubObject - 1

        if ((numSubObject == 0 and nextSepLenChars == objectIndexSep) or i == dumpedArray.MaxIndex())
        {
            if (i == dumpedArray.MaxIndex())
                val := val "" char

            val := dumpedValToVal(val)
            array.Push(val)
            val := ""        
            i := i + dumpSepLen
            continue
        }

        val := val "" char
        i := i + 1
    }
    return array
}

dumpedDictToDict(dumpedDict)
{
    dict := {}
    dumpedDict := removeDumpedObjDelimiters(dumpedDict)
    dumpedDict := StrSplit(dumpedDict)

    numSubObject := 0
    key := ""
    val := ""
    solving := "key"

    i := 1
    while (i <= dumpedDict.MaxIndex())
    {
        char := dumpedDict[i]
        nextSepLenChars := getNextSepLenChars(i, dumpedDict)

        if (nextSepLenChars == dictStartSep or nextSepLenChars == arrayStartSep)
            numSubObject := numSubObject + 1
        else if (nextSepLenChars == dictEndSep or nextSepLenChars == arrayEndSep)
            numSubObject := numSubObject - 1

        if ((numSubObject == 0 and nextSepLenChars == objectIndexSep) or i == dumpedDict.MaxIndex())
        {
            if (i == dumpedDict.MaxIndex())
                val := val "" char

            key := dumpedValToVal(key)
            val := dumpedValToVal(val)
            dict.Insert(key, val)
            key := ""
            val := ""        
            solving := "key"
            i := i + dumpSepLen
            continue
        }
        else if (numSubObject == 0 and nextSepLenChars == dictKeyValSep)
        {
            solving := "val"
            i := i + dumpSepLen
            continue
        }

        if (solving == "key")
            key := key "" char
        else if (solving == "val")
            val := val "" char
        i := i + 1
    }
    return dict
}

removeDumpedObjDelimiters(dumpedObj)
{
    dumpedObj := SubStr(dumpedObj, StrLen(dictStartSep)+1)
    dumpedObj := SubStr(dumpedObj, 1, StrLen(dumpedObj) - StrLen(dictStartSep))
    return dumpedObj
}

getNextSepLenChars(i, dumpedDict)
{
    nextSepLenChars := ""
    j := 0
    while (j < dumpSepLen and i+j <= dumpedDict.MaxIndex())
    {
        nextSepLenChars := nextSepLenChars "" dumpedDict[i+j]
        j := j + 1
    }
    return nextSepLenChars
}
;--

objType(obj)
{    
    if (IsObject(obj))
    {
        i := 0
        for k, v in obj {
            if (++i != k)
                return "dict"
        }
        return "array"
    }
    return False
}

dumpedObjType(str)
{
    res := False
    sepLen := StrLen(arrayStartSep)
    if (everySepIsClosed(str))
    {
        start := SubStr(str, 1 , sepLen)
        end := SubStr(str, 1-sepLen , sepLen)
        if (start == dictStartSep and end == dictEndSep)
            res := "dict"
        else if (start == arrayStartSep and end == arrayEndSep)
            res := "array"
    }
    return res
}

everySepIsClosed(str)
{
    openCurlyBracket := 0
    openCurlySquareBracket := 0
    str := StrSplit(str)
    for _, c in str
    {
        if (c == "{")
            openCurlyBracket := openCurlyBracket + 1
        else if (c == "}")
            openCurlyBracket := openCurlyBracket - 1
        else if (c == "[")
            openCurlySquareBracket := openCurlySquareBracket + 1
        else if (c == "]")
            openCurlySquareBracket := openCurlySquareBracket - 1
    }
    res :=  openCurlyBracket == 0 and openCurlySquareBracket == 0
    return res
}
; ----



; ------ RANDOMS --------------------------------------------
;offset: values close to 0 drag the exepcted result closer to min
RandomLog(min, max, offset := .1) {
    r_min := LogarithmicToLinear(offset)
    r_max := LogarithmicToLinear(max - min + offset)
    Random, r, %r_min%, %r_max%
    r := LinearToLogarithmic(r)
    r := r + min - offset
    return r
}
                                                ; c =.1: far from center
centeredExpRand(min, max, c = 1, center = "")   ; c = 5: close
{                                               ; c = 1: normal
    if (center == "")
        center := (max-min)/2
    val := expRand(center, max, c)
    if (oneChanceOver(2))
        val := center - (((val-center)/(max-center)) * (center-min))
    return val
    
}

                                                ; c =.1: close to max
expRand(min, max, c = 1)                        ; c = 5: close to min
{        
    Random, n, 0.0, 1.0
    res :=  min + (max-min)*Pow(n, c)
    return res
}

randInt(min, max)
{
    Random, r, %min%, %max%
    return r
}

randomChoice(values)
{
    max := values.MaxIndex()
    Random, r, 1, %max%
    return values[r]
}

shuffle(array)
{
    newArray := []
    while (array.HasKey(1))
    {
        max := array.MaxIndex()
        Random, r, 1, %max%
        el := array.RemoveAt(r)
        newArray.Push(el)      
    }
    return newArray
}
; [[v,w], [v,w], [v,w]]
weightedRandomChoice(valuesAndWeight)
{
    sumOfWeight := 0
    for _, couple in valuesAndWeight
    {
        w := couple[2]
        sumOfWeight := sumOfWeight + w
    }
    sumOfWeight := sumOfWeight-1
    Random, r, 0, %sumOfWeight%

    for _, couple in valuesAndWeight
    {
        w := couple[2]
        if (r < w)
        {
            val := couple[1]
            break
        }
        r := r - w
    }
    return val
}

weightedRandomChoiceIndexOnly(weights)
{
    sumOfWeight := 0
    for _, w in weights
        sumOfWeight := sumOfWeight + w
    sumOfWeight := sumOfWeight-1
    Random, r, 0, %sumOfWeight%

    for index, w in weights
    {
        if (r < w)
            break
        r := r - w
    }
    return index
}

oneChanceOver(prob = 2, mode = "normal")
{
    Random, n, 1, %prob%
    res := n == 1
    if (mode == "invert")
        res := !res
    return res
}

; -- Random Strings  ----
randomizeStringOrder(string)
{
    string := StrSplit(string)
    string := shuffle(string)
    newString := ""
    for _, c in string
        newString := newString "" c
    return newString
}

randString(len)
{
   CharStr := ""
   Loop % len
   {
        c := exprand(0.00001, .4, 0.1)
        r := Floor(expRand(1, 255, c))
        if (oneChanceOver(3, "invert"))
            r := Floor(r / 3)

        CharStr := CharStr . chr(r)
   }
   return CharStr
}

arabToRomanNum(n)
{
    Switch n
    {
    Case 1:
        n := "I"
    Case 2:
        n := "II"
    Case 3:
        n := "III"
    Case 4:
        n := "IV"
    Case 5:
        n := "V"
    Case 6:
        n := "VI"
    Case 7:
        n := "VII"
    Case 8:
        n := "VIII"
    Case 9:
        n := "IX"
    Case 10:
        n := "X"
    Case 11:
        n := "XI"
    Case 12:
        n := "XII"
    Case 13:
        n := "XIII"
    Case 14:
        n := "XIV"
    Case 15:
        n := "XV"
    Case 16:
        n := "XVII"
    }
    return n
}

romanToArabNum(n)
{
    Switch n
    {
    Case "I":
        n := 1
    Case "II":
        n := 2
    Case "III":
        n := 3
    Case "IV":
        n := 4
    Case "V":
        n := 5
    Case "VI":
        n := 6
    Case "VII":
        n := 7
    Case "VIII":
        n := 8
    Case "IX":
        n := 9
    Case "X":
        n := 10
    Case "XI":
        n := 11
    Case "XII":
        n := 12
    Case "XIII":
        n := 13
    Case "XIV":
        n := 14
    Case "XV":
        n := 15
    Case "XVII":
        n := 16
    }
    return n    
}

isRomanNum(n)
{
    res := False
    if (n is alpha and n != "")
    {
        res := True
        splitN := StrSplit(n)
        for _, char in splitN
        {
            if (!hasVal(["I", "V", "X"], char))
            {
                res := False
                break
            }
        }
    }
    return res
}
; ----


; -- System --------------------------------
HideTaskbar(action)
{
    static ABM_SETSTATE := 0xA, ABS_AUTOHIDE := 0x1, ABS_ALWAYSONTOP := 0x2
    VarSetCapacity(APPBARDATA, size := 2*A_PtrSize + 2*4 + 16 + A_PtrSize, 0)
    NumPut(size, APPBARDATA), NumPut(WinExist("ahk_class Shell_TrayWnd"), APPBARDATA, A_PtrSize)
    NumPut(action ? ABS_AUTOHIDE : ABS_ALWAYSONTOP, APPBARDATA, size - A_PtrSize)
    DllCall("Shell32\SHAppBarMessage", UInt, ABM_SETSTATE, Ptr, &APPBARDATA)
}

SysCommand(vTarget, vSize:="")
{
	DetectHiddenWindows, On
	vComSpec := A_ComSpec ? A_ComSpec : ComSpec
	Run, % vComSpec,, Hide, vPID
	WinWait, % "ahk_pid " vPID
	DllCall("kernel32\AttachConsole", "UInt",vPID)
	oShell := ComObjCreate("WScript.Shell")
	oExec := oShell.Exec(vTarget)
	vStdOut := ""
	if !(vSize = "")
		VarSetCapacity(vStdOut, vSize)
	while !oExec.StdOut.AtEndOfStream
		vStdOut := oExec.StdOut.ReadAll()
	DllCall("kernel32\FreeConsole")
	Process, Close, % vPID
	return vStdOut
}

soundNumInDir(dir)
{
    dirSplit := StrSplit(dir)
    if (dirSplit[dirSplit.MaxIndex()] != "\")
        dir := dir "\"

    extensions := ["wav", "wv", "mp3", "aif", "aiff", "ogg"]
    num := 0
    Loop, %dir%*.*
    {
        splitName := StrSplit(A_LoopFileName, ".")
        currExt := splitName[splitName.MaxIndex()]
        StringLower, currExt, currExt
        if (hasVal(extensions, currExt))
            num := num + 1
    }
    return num
}

fileNumInDir(dir)
{
    dirSplit := StrSplit(dir)
    if (dirSplit[dirSplit.MaxIndex()] != "\")
        dir := dir "\"

    Loop, %dir%*.*
        Number := A_Index
    return Number
}
; ----



; -- Messages ------------------------------
msgBox(msg = "")
{
    msg := objToString(msg)
    MsgBox %msg%
    WinGet, exe, ProcessName, A
    if (exe != "FL64.exe") {
        WinActivate, ahk_exe FL64.exe
    }
}

msgTip(msg, t = 1000, n = 1)
{
    msg := objToString(msg)
    ToolTip %msg%,,, %n%
    Sleep, %t%
    ToolTip,,,, %n%
}

msg(msg, t = 1000, n = 1)
{
    msgTip(msg, t, n)
}

logVar(var, t = 1000, n = 1)    ; var should be the name of the variable in a string
{
    val := %var%
    msg(var ": " val)
}

toolTip(msg = "", n = 1)
{
    msg := objToString(msg)
    ToolTip, %msg%,,, %n%
}

objToString(obj, tabs = 0)
{
    if (IsObject(obj))
    {
        str := ""
        if (tabs > 0)
            str := str "`r`n"
        for key, val in obj
        {
            Loop, %tabs%            
                str := str "  "
            str := str "" objToString(key, tabs+1) " : " objToString(val, tabs+1) "`r`n"
        }
    }
    else
        str := obj
    return str
}

concat(s1, s2)
{
    return s1 s2
}
; ----

global debugOn
debugOn := False
debug(msg = "")
{
    if (debugOn)
    {
        msgTip(msg)
        Sleep, 700
    }
}



; -- ToolTipOpt v1.004 --------------------------------------------------------------------
; Changes:
;  v1.001 - Pass "Default" to restore a setting to default
;  v1.002 - ANSI compatibility
;  v1.003 - Added workarounds for ToolTip's parameter being overwritten
;           by code within the message hook.
;  v1.004 - Fixed text colour.
 
ToolTipFont(Options := "", Name := "", hwnd := "")
{
    static hfont := 0
    if (hwnd = "")
        hfont := Options="Default" ? 0 : _TTG("Font", Options, Name), _TTHook()
    else
        DllCall("SendMessage", "ptr", hwnd, "uint", 0x30, "ptr", hfont, "ptr", 0)
}
 
ToolTipColor(Background := "", Text := "Black", hwnd := "")
{
    static bc := "", tc := ""
    if (hwnd = "") {
        if (Background != "")
            bc := Background="Default" ? "" : _TTG("Color", Background)
        if (Text != "")
            tc := Text="Default" ? "" : _TTG("Color", Text)
        _TTHook()
    }
    else {
        VarSetCapacity(empty, 2, 0)
        DllCall("UxTheme.dll\SetWindowTheme", "ptr", hwnd, "ptr", 0
            , "ptr", (bc != "" && tc != "") ? &empty : 0)
        if (bc != "")
            DllCall("SendMessage", "ptr", hwnd, "uint", 1043, "ptr", bc, "ptr", 0)
        if (tc != "")
            DllCall("SendMessage", "ptr", hwnd, "uint", 1044, "ptr", tc, "ptr", 0)
    }
}

_TTHook()
{
    static hook := 0
    if !hook
        hook := DllCall("SetWindowsHookExW", "int", 4
            , "ptr", RegisterCallback("_TTWndProc"), "ptr", 0
            , "uint", DllCall("GetCurrentThreadId"), "ptr")
}
 
_TTWndProc(nCode, _wp, _lp)
{
    Critical 999
   ;lParam  := NumGet(_lp+0*A_PtrSize)
   ;wParam  := NumGet(_lp+1*A_PtrSize)
    uMsg    := NumGet(_lp+2*A_PtrSize, "uint")
    hwnd    := NumGet(_lp+3*A_PtrSize)
    if (nCode >= 0 && (uMsg = 1081 || uMsg = 1036)) {
        _hack_ = ahk_id %hwnd%
        WinGetClass wclass, %_hack_%
        if (wclass = "tooltips_class32") {
            ToolTipColor(,, hwnd)
            ToolTipFont(,, hwnd)
        }
    }
    return DllCall("CallNextHookEx", "ptr", 0, "int", nCode, "ptr", _wp, "ptr", _lp, "ptr")
}
 
_TTG(Cmd, Arg1, Arg2 := "")
{
    static htext := 0, hgui := 0
    if !htext {
        Gui _TTG: Add, Text, +hwndhtext
        Gui _TTG: +hwndhgui +0x40000000
    }
    Gui _TTG: %Cmd%, %Arg1%, %Arg2%
    if (Cmd = "Font") {
        GuiControl _TTG: Font, %htext%
        SendMessage 0x31, 0, 0,, ahk_id %htext%
        return ErrorLevel
    }
    if (Cmd = "Color") {
        hdc := DllCall("GetDC", "ptr", htext, "ptr")
        SendMessage 0x138, hdc, htext,, ahk_id %hgui%
        clr := DllCall("GetBkColor", "ptr", hdc, "uint")
        DllCall("ReleaseDC", "ptr", htext, "ptr", hdc)
        return clr
    }
}
; ----


; ---- AddAnimatedGIF function by boiler -------------------------------------------------------------------------------
; imagefullpath: must be the full path to the animated GIF image file
; x, y: optional strings containing position info that would normally follow x and y options, such as 10, "p+3", "m"
; w, h: optional width and height values that would normally follow w and h options; blank for full size image
; guiname:  optional name of the gui to add the image to if not the main one
;
; function returns the name of the control that was added so that you can modify it (move, hide) with GuiControl
; can add up to animated GIF images.  to increase the limit, add AG11,AG12,... to the global statement
;
AddAnimatedGIF(imagefullpath , x="", y="", w="", h="", guiname = "1")
{
	global AG1,AG2,AG3,AG4,AG5,AG6,AG7,AG8,AG9,AG10
	static AGcount:=0, pic
	AGcount++
	html := "<html><body style='background-color: transparent' style='overflow:hidden' leftmargin='0' topmargin='0'><img src='" imagefullpath "' width=" w " height=" h " border=0 padding=0></body></html>"
	Gui, AnimGifxx:Add, Picture, vpic, %imagefullpath%
	GuiControlGet, pic, AnimGifxx:Pos
	Gui, AnimGifxx:Destroy
	Gui, %guiname%:Add, ActiveX, % (x = "" ? " " : " x" x ) . (y = "" ? " " : " y" y ) . (w = "" ? " w" picW : " w" w ) . (h = "" ? " h" picH : " h" h ) " vAG" AGcount, Shell.Explorer
	AG%AGcount%.navigate("about:blank")
	AG%AGcount%.document.write(html)
	return "AG" AGcount
}
; ----


; ---- HEXADECIMAL ----------------------------------------------------------------
decimal2hex( int, pad=6 )
{ ; Function by [VxE]. Formats an integer (decimals are truncated) as hex.
; "Pad" may be the minimum number of digits that should appear on the right of the "0x".
	Static hx := "0123456789ABCDEF"
	If !( 0 < int |= 0 )
		return !int ? "0x0" : "-" decimal2hex( -int, pad )

	s := 1 + Floor( Ln( int ) / Ln( 16 ) )
	h := SubStr( "0x0000000000000000", 1, pad := pad < s ? s + 2 : pad < 16 ? pad + 2 : 18 )
	u := A_IsUnicode = 1

	Loop % s
		NumPut( *( &hx + ( ( int & 15 ) << u ) ), h, pad - A_Index << u, "UChar" ), int >>= 4

	return h
}

hexToDecimal(str)
{
    static _0:=0,_1:=1,_2:=2,_3:=3,_4:=4,_5:=5,_6:=6,_7:=7,_8:=8,_9:=9,_a:=10,_b:=11,_c:=12,_d:=13,_e:=14,_f:=15
    str:=ltrim(str,"0x `t`n`r"),   len := StrLen(str),  ret:=0
    Loop,Parse,str
      ret += _%A_LoopField%*(16**(len-A_Index))
    return ret
}

hex2Rgb(hex)
{
    StringUpper, hex, hex
    if (StrLen(hex) != 8 or SubStr(hex, 1, 2) != "0X")
        return

    hex := SubStr(hex, 3)
    for _, c in StrSplit(hex)
    {
        c := Ord(c)
        isHexDigit := (c >= 65 and c <= 70) or (c >= 48 and c <= 57) ; A to F or 0 to 9
        if (!isHexDigit)
            return 
    }
    r := "0x" SubStr(hex, 1, 2)
    r := hexToDecimal(r)

    g := "0x" SubStr(hex, 3, 2)
    g := hexToDecimal(g)

    b := "0x" SubStr(hex, 5, 2)
    b := hexToDecimal(b)
    return [r, g, b]
}

hexColorVariation(h1, h2)
{
    diff := 0
    h1 := hex2Rgb(h1)
    h2 := hex2Rgb(h2)
    diffR := Abs(h1[1]-h2[1])
    diffG := Abs(h1[2]-h2[2])
    diffB := Abs(h1[3]-h2[3])
    diff := Max(diff, diffR)
    diff := Max(diff, diffB)
    diff := Max(diff, diffG)
    return diff
}
; ----


; -- Other --------------------
timeOfDaySeconds()
{
    FormatTime, vDate,, HH:mm:ss
    oTemp := StrSplit(vDate, ":")
    vSec := oTemp.1*3600+oTemp.2*60+oTemp.3
    return vSec
}


typeText(txt)
{
    prevClipboard := clipboard
    clipboard := txt
    Send {CtrlDown}v{CtrlUp}
    clipboard := prevClipboard
}

removeBreakLines(text)
{
    return RegExReplace(text,"\.? *(\n|\r)+","")
}

; check if element is in list
hasVal(haystack, needle)
{
	if !(IsObject(haystack)) || (haystack.Length() == 0)
		return 0
	for index, value in haystack
		if (value == needle)
			return index
	return 0
}

; cut at index until end of list
cutEndOfList(list, index)
{
    list.RemoveAt(index , list.MaxIndex() - index)
    return list
}

keyDown(key)
{
    return GetKeyState(key , "P")
}

windowSpy()
{
	wp = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\AutoHotkey\Active Window Info (Window Spy).lnk"
	SysCommand(wp)
}

sendAllKeysUp()
{
    toolTip("Release keys")
    Loop, 0xFF
    {
        Key := Format("VK{:02X}",A_Index)
        IF GetKeyState(Key)
            Send, {%Key% Up}
    }
    Sleep, 400
    toolTip()
}

winIdAtCoords(x, y)         ; not totally reliable
{
    return DllCall("GetAncestor", UInt, DllCall("WindowFromPoint", Int, x, Int, y), UInt, GA_ROOT := 2)
}

keyIsDown(key)
{
    GetKeyState, ks, %key%
    return ks == "D"
}

; ----