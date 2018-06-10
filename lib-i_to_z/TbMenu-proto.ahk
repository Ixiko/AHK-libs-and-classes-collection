OnMessage(0x111, "WM_COMMAND")

tbm := TbMenu_Create(0x80800044|0x1000)
;TbMenu_SetImageList(tbm, IL_Create(2,5,1))
TbMenu_SetMetrics(tbm, 8,8, 2,0, 2,1)
TbMenu_Add(tbm, "item 1", A_AhkPath, 1)
TbMenu_Add(tbm, "button 2", A_AhkPath, 2)
TbMenu_Add(tbm, "number 3", A_AhkPath, 3)
TbMenu_Show(tbm)

WM_COMMAND(wParam, lParam)
{
    global tbm
    if (lParam = tbm) {
        WinClose, ahk_id %tbm%
        msgbox %wParam%
        ExitApp
    }
}

; Styles:
;    0x800  Flat    Transparent buttons + hot-tracking. Text below bitmap.
;   0x1000  List    Transparent buttons + hot-tracking. Text left of bitmap.
;   0x8000  Trans   Transparent buttons.
;    0x200  Wrap    Buttons "wrap" to the next line when the menu is too narrow.
;  --
; 0x800000  WS_BORDER       Thin-line border around the menu.
;     0x40  CCS_NODIVIDER   Removes the two-pixel border from the top of the control.
;      0x4  CCS_NORESIZE    Prevents automatic resizing.
TbMenu_Create(Style=0x80800044, ExStyle=0, Owner=0)
{
    if !TbMenu_RegisterClass() {
        MsgBox, 16, Error, TbMenu window class registration failed.
        return 0
    }

;     Style = 0x40
;     ExStyle = 0
;     TbMenu_ParseOptions(Options, Style, ExStyle, lParam)

    if ! Owner {
        Process, Exist
        dhw := A_DetectHiddenWindows
        DetectHiddenWindows, On
        Owner := WinExist("ahk_class AutoHotkey ahk_pid " ErrorLevel)
        DetectHiddenWindows, %dhw%
    }

    tbm := DllCall("CreateWindowEx","uint",ExStyle,"str","AhkTbMenu","uint",0
        ,"uint",Style,"int",0,"int",0,"int",100,"int",100,"uint",Owner
        ,"uint",0,"uint",0,"uint",0)
    
    DllCall("SendMessage","uint",tbm,"uint",0x41E,"uint",20,"uint",0)
    ;SendMessage, 0x41E, 20, 0,, ahk_id %hTb%  ; TB_SETBUTTONSTRUCTSIZE, sizeof(TBBUTTON)
    
    return tbm
}

TbMenu_Add(tbm, Text, ImageFileOrIndex="", IconNumber=1, State=0x4, Style=0)
{
    static id=1
    
    if ImageFileOrIndex !=
        if ImageFileOrIndex is not integer
        {
            hIL := TbMenu_GetImageList(tbm)
            if !hIL
                hIL := IL_Create(), TbMenu_SetImageList(tbm, hIL)
            ImageFileOrIndex := IL_Add(hIL, ImageFileOrIndex, IconNumber)
        }
    
    VarSetCapacity(btn, 20, 0)
    NumPut(ImageFileOrIndex-1, btn, 0)
    NumPut(id++,    btn, 4)
    NumPut(State,   btn, 8,"char")
    NumPut(Style,   btn, 9,"char")
    NumPut(&Text,   btn, 16)
    
    dhw := A_DetectHiddenWindows
    DetectHiddenWindows, On
    SendMessage, 0x414, 1, &btn ,, ahk_id %tbm% ; TB_ADDBUTTONSA
    SendMessage, 0x418, 0, 0    ,, ahk_id %tbm% ; TB_BUTTONCOUNT
    bc := ErrorLevel
    VarSetCapacity(rc,16,0)
    SendMessage, 0x427, bc, &rc ,, ahk_id %tbm% ; TB_SETROWS
    w := NumGet(rc,8)-NumGet(rc,0)
    h := NumGet(rc,12)-NumGet(rc,4)
    WinMove, ahk_id %tbm%,, , , w+2, h+2
    DetectHiddenWindows, %dhw%
}

; Requires XP or later.
TbMenu_SetMetrics(tbm, xPad="", yPad="", xButtonMargin="", yButtonMargin="", xMargin="", yMargin="")
{
    VarSetCapacity(met,32,0), NumPut(32,met)
    NumPut( ((xPad yPad)!="" ? 1:0)
        | ((xMargin yMargin)!="" ? 2:0)
        | ((xButtonMargin yButtonMargin)!="" ? 4:0), met, 4)
    NumPut(xPad,met,8), NumPut(yPad,met,12)
    NumPut(0,met,16), NumPut(yMargin,met,20)
    NumPut(xButtonMargin,met,24), NumPut(yButtonMargin,met,28)
    DllCall("SendMessage","uint",tbm,"uint",0x466,"uint",0,"uint",&met) ; TB_SETMETRICS
    DllCall("SendMessage","uint",tbm,"uint",0x42F,"int",xMargin,"uint",0) ; TB_SETINDENT
}

TbMenu_SetImageList(tbm, hIL)
{
    DllCall("SendMessage","uint",tbm,"uint",0x430,"uint",0,"uint",hIL)
    ;SendMessage, 0x430, 0, hIL,, ahk_id %tbm% ; TB_SETIMAGELIST
}

TbMenu_GetImageList(tbm)
{
    return DllCall("SendMessage","uint",tbm,"uint",0x431,"uint",0,"uint",0)
    ;SendMessage, 0x431, 0, 0,, ahk_id %tbm% ; TB_GETIMAGELIST
    ;return ErrorLevel="FAIL" ? "" : ErrorLevel
}

TbMenu_Show(tbm)
{
    WinShow, ahk_id %tbm%
}

; INTERNAL. Called by TbMenu_Create() to register the window class.
TbMenu_RegisterClass()
{
    static ClassAtom, ClassName="AhkTbMenu"
    if ClassAtom
        return ClassAtom
    
    VarSetCapacity(wcl,40)
    if ! DllCall("GetClassInfo","uint",0,"str","ToolbarWindow32","uint",&wcl)
        return false
    NumPut(NumGet(wcl)|0x20000,wcl) ; wcl->style |= CS_DROPSHADOW
    NumPut(&ClassName,wcl,36)       ; wcl->lpszClassName = &ClassName
    NumPut(DllCall("GetModuleHandle","uint",0),wcl,16)  ; wcl->hInstance = NULL
    ; Create a callback for TbMenu_WndProc, passing ToolbarWindow32's
    ; WindowProc as A_EventInfo. lpfnWndProc := the callback.
    NumPut(RegisterCallback("TbMenu_WndProc","",4,NumGet(wcl,4)),wcl,4)
    
    return DllCall("RegisterClass","uint",&wcl)
}

; INTERNAL. Handles window messages sent to the menu window.
TbMenu_WndProc(hwnd, Msg, wParam, lParam)
{
    Critical 500    ; tell AHK not to process any other messages while here.
    
;     SetFormat, Integer, H
;     Msg += 0
;     SetFormat, Integer, D
;     if Msg in 0x5,0x46,0x47,0x1
;     {
;         DetectHiddenWindows, On
;         WinGetPos,,, w, h, ahk_id %hwnd%
;         StdOut(SubStr(Msg,3) " " w "x" h)
;     }
    
    return DllCall("CallWindowProc","uint",A_EventInfo,"uint",hwnd,"uint",Msg,"uint",wParam,"uint",lParam)
}



; INTERNAL.
/*
TbMenu_ParseOptions(Options, ByRef Style, ByRef ExStyle, ByRef lParam)
{
    static  Style_Flat = 0x800, Style_List = 0x1000
        ,   Style_Wrap = 0x200, Style_Trans = 0x8000
    
    lParam = 0
    ;    lParam := DllCall("GlobalAlloc","uint",0x40,"uint",8)

    Options := RegExReplace(Options,"\s+"," ")
    Loop, Parse, Options, %A_Space%
    {
        op := SubStr(opt:=A_LoopField,1,1)
        if op in +,-,g
            StringTrimLeft, opt, opt, 1
        else
            op =
            
        if op in ,+,-
        {
            if RegExMatch(opt,"^.?\w+$")
                if Style_%opt%
                    opt := Style_%opt%
            
            if opt is integer
            {
                if op = -
                    Style &= ~opt
                else
                    Style |=  opt
            }
            else if SubStr(opt,1,1) = "E"
            {
                StringTrimLeft, opt, opt, 1
                if opt is integer
                {
                    if op = -
                        ExStyle &= ~opt
                    else
                        ExStyle |=  opt
                }
            }
        }
    }
}
*/
