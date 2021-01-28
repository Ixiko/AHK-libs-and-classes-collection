#NoEnv
#SingleInstance, Off
#NoTrayIcon
SetWorkingDir %A_ScriptDir%
#Include %A_ScriptDir%\..\IAutoComplete.ahk
FileEncoding, UTF-8

T := ["and"
    , "array"
    , "as"
    , "asm"
    , "begin"
    , "Blockierung der BWS{M43.89G}"
    , "case"
    , "class"
    , "const"
    , "constructor"
    , "destructor"
    , "dispinterface"
    , "div"
    , "do"
    , "downto"
    , "else"
    , "end"
    , "except"
    , "exports"
    , "file"
    , "finalization"
    , "finally"
    , "for"
    , "function"
    , "goto"
    , "if"
    , "implementation"
    , "in"
    , "inherited"
    , "initialization"
    , "inline"
    , "interface"
    , "is"
    , "label"
    , "library"
    , "mod"
    , "nil"
    , "not"
    , "object"
    , "of"
    , "or"
    , "out"
    , "packed"
    , "procedure"
    , "program"
    , "property"
    , "raise"
    , "record"
    , "repeat"
    , "resourcestring"
    , "set"
    , "shl"
    , "shr"
    , "string"
    , "then"
    , "threadvar"
    , "to"
    , "try"
    , "type"
    , "unit"
    , "until"
    , "uses"
    , "var"
    , "while"
    , "with"
    , "xor"]



S:= Object()
Path = %A_ScriptDir%\AutoList1.txt

S:= ArrayLoad(Path)

inputter:

        KeyWord := InputGui("Find a Keyword...", "`n   Search for:", , S)
        
        ; MsgBox, % KeyWord
        a:=0
       For key, value in S
        {
                ToolTip, % key ": " S[key], 200, 200, 1
                If (S[key]=KeyWord) {
                        a:=1
                        break
                }
        }
        
       
        
        If (a=0) {
                S.Push(KeyWord)
                SortArray(S, "A")
               ArraySave(S, Path)
        }

       

goto Inputter

ExitApp
; Esc::ExitApp

ArraySave(Array, Path) {
    
    If FileExist(Path)
            FileDelete, % path
    
    For each, value in Array
        FileAppend, % value . "`n", % path
    
}

ArrayLoad(Path) {
 
    o:= Object()
 
    If !FileExist(Path)
            return {1: 0}
            
    FileRead, file, % path
    MsgBox, % file
    
    Loop, Parse, file, `n
    {
        ;ToolTip, % A_Index "`n" A_LoopField, 200, 200, 1
         o[A_Index]:= A_LoopField
    }
    
    return o
}


InputGui(Title, Prompt, Default := "", Suggestions := "", Owner := "") {
    
           If( Owner <> "" ) {
              Gui %Owner%:+Disabled
              Gui InputGui:+Owner%Owner%
           }
           Gui, InputGui: +AlwaysOnTop +LabelInputGui +LastFound -SysMenu +OwnDialogs
           Gui, InputGui: Margin, 0, 0
           Gui, InputGui: Color, White
           Gui, InputGui: Font, s12 w400, Segoe UI
           Gui, InputGui: Add, Text, x10 y10 w320 c002299, %Prompt%
           Gui, InputGui: Font, s9 Normal
           Gui, InputGui: Add, Edit, x10 y+30 w320 hwndhEdit, %Default%
           Gui, InputGui: Add, Text, x0 y+30 w340 h30 -Background hwndhTxt
           Gui, InputGui: Font, s12
           Gui, InputGui: Add, Button, x120 yp+10 w100 gInputGuiOK Default, OK
           Gui, InputGui: Add, Button, x+10 yp w100 gInputGuiClose hwndhBtn, Cancel
           
           GuiControlGet, P, InputGui:Pos, %hBtn%
           GuiControl, InputGui:Move, %hTxt%, % "h" . (PH + 20)
           Gui, InputGui:Show, AutoSize, %Title%

           If IsObject(Suggestions)
              ACInput := IAutoComplete_Create(hEdit, Suggestions, ["AutoSuggest", "UseTab", "Word_Filter"])

           WinWaitClose
           
   Return Result
   ; ------------------------------------------------------------------------------
   InputGuiOK:
        GuiControlGet, Result, , %hEdit%
   ; InputGuiEscape:
   InputGuiClose:
       If(Owner <> "")
          Gui %Owner%:-Disabled
       Gui, Destroy
   Return
}

SortArray(Array, Order="A") {															;-- ordered sort: Ascending, Descending, Reverse

    ;Order A: Ascending, D: Descending, R: Reverse
    MaxIndex := ObjMaxIndex(Array)
    If (Order = "R") {
        count := 0
        Loop, % MaxIndex
            ObjInsert(Array, ObjRemove(Array, MaxIndex - count++))
        Return
    }
    Partitions := "|" ObjMinIndex(Array) "," MaxIndex
    Loop {
        comma := InStr(this_partition := SubStr(Partitions, InStr(Partitions, "|", False, 0)+1), ",")
        spos := pivot := SubStr(this_partition, 1, comma-1) , epos := SubStr(this_partition, comma+1)
        if (Order = "A") {
            Loop, % epos - spos {
                if (Array[pivot] > Array[A_Index+spos])
                    ObjInsert(Array, pivot++, ObjRemove(Array, A_Index+spos))
            }
        } else {
            Loop, % epos - spos {
                if (Array[pivot] < Array[A_Index+spos])
                    ObjInsert(Array, pivot++, ObjRemove(Array, A_Index+spos))
            }
        }
        Partitions := SubStr(Partitions, 1, InStr(Partitions, "|", False, 0)-1)
        if (pivot - spos) > 1    ;if more than one elements
            Partitions .= "|" spos "," pivot-1        ;the left partition
        if (epos - pivot) > 1    ;if more than one elements
            Partitions .= "|" pivot+1 "," epos        ;the right partition
    } Until !Partitions
}

/*
    RegisterSyncCallback

    A replacement for RegisterCallback for use with APIs that will call
    the callback on the wrong thread.  Synchronizes with the script's main
    thread via a window message.

    This version tries to emulate RegisterCallback as much as possible
    without using RegisterCallback, so shares most of its limitations,
    and some enhancements that could be made are not.

    Other differences from v1 RegisterCallback:
      - Variadic mode can't be emulated exactly, so is not supported.
      - A_EventInfo can't be set in v1, so is not supported.
      - Fast mode is not supported (the option is ignored).
      - ByRef parameters are allowed (but ByRef is ignored).
      - Throws instead of returning "" on failure.
*/
RegisterSyncCallback(FunctionName, Options:="", ParamCount:="") {
    
    if !(fn := Func(FunctionName)) || fn.IsBuiltIn
        throw Exception("Bad function", -1, FunctionName)
    if (ParamCount == "")
        ParamCount := fn.MinParams
    if (ParamCount > fn.MaxParams && !fn.IsVariadic || ParamCount+0 < fn.MinParams)
        throw Exception("Bad param count", -1, ParamCount)

    static sHwnd := 0, sMsg, sSendMessageW
    if !sHwnd
    {
        Gui RegisterSyncCallback: +Parent%A_ScriptHwnd% +hwndsHwnd
        OnMessage(sMsg := 0x8000, Func("RegisterSyncCallback_Msg"))
        sSendMessageW := DllCall("GetProcAddress", "ptr", DllCall("GetModuleHandle", "str", "user32.dll", "ptr"), "astr", "SendMessageW", "ptr")
    }

    if !(pcb := DllCall("GlobalAlloc", "uint", 0, "ptr", 96, "ptr"))
        throw
    DllCall("VirtualProtect", "ptr", pcb, "ptr", 96, "uint", 0x40, "uint*", 0)

    p := pcb
    if (A_PtrSize = 8)
    {
        /*
        48 89 4c 24 08  ; mov [rsp+8], rcx
        48 89 54'24 10  ; mov [rsp+16], rdx
        4c 89 44 24 18  ; mov [rsp+24], r8
        4c'89 4c 24 20  ; mov [rsp+32], r9
        48 83 ec 28'    ; sub rsp, 40
        4c 8d 44 24 30  ; lea r8, [rsp+48]  (arg 3, &params)
        49 b9 ..        ; mov r9, .. (arg 4, operand to follow)
        */
        p := NumPut(0x54894808244c8948, p+0)
        p := NumPut(0x4c182444894c1024, p+0)
        p := NumPut(0x28ec834820244c89, p+0)
        p := NumPut(  0xb9493024448d4c, p+0) - 1
        lParamPtr := p, p += 8

        p := NumPut(0xba, p+0, "char") ; mov edx, nmsg
        p := NumPut(sMsg, p+0, "int")
        p := NumPut(0xb9, p+0, "char") ; mov ecx, hwnd
        p := NumPut(sHwnd, p+0, "int")
        p := NumPut(0xb848, p+0, "short") ; mov rax, SendMessageW
        p := NumPut(sSendMessageW, p+0)
        /*
        ff d0        ; call rax
        48 83 c4 28  ; add rsp, 40
        c3           ; ret
        */
        p := NumPut(0x00c328c48348d0ff, p+0)
    }
    else ;(A_PtrSize = 4)
    {
        p := NumPut(0x68, p+0, "char")      ; push ... (lParam data)
        lParamPtr := p, p += 4
        p := NumPut(0x0824448d, p+0, "int") ; lea eax, [esp+8]
        p := NumPut(0x50, p+0, "char")      ; push eax
        p := NumPut(0x68, p+0, "char")      ; push nmsg
        p := NumPut(sMsg, p+0, "int")
        p := NumPut(0x68, p+0, "char")      ; push hwnd
        p := NumPut(sHwnd, p+0, "int")
        p := NumPut(0xb8, p+0, "char")      ; mov eax, &SendMessageW
        p := NumPut(sSendMessageW, p+0, "int")
        p := NumPut(0xd0ff, p+0, "short")   ; call eax
        p := NumPut(0xc2, p+0, "char")      ; ret argsize
        p := NumPut((InStr(Options, "C") ? 0 : ParamCount*4), p+0, "short")
    }
    NumPut(p, lParamPtr+0) ; To be passed as lParam.
    p := NumPut(&fn, p+0)
    p := NumPut(ParamCount, p+0, "int")
    return pcb
}

RegisterSyncCallback_Msg(wParam, lParam) {
    if (A_Gui != "RegisterSyncCallback")
        return
    fn := Object(NumGet(lParam + 0))
    paramCount := NumGet(lParam + A_PtrSize, "int")
    params := []
    Loop % paramCount
        params.Push(NumGet(wParam + A_PtrSize * (A_Index-1)))
    return %fn%(params*)
}