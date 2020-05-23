; A simple script to see how Struct interprets various WinStructs structures
#SingleInstance force

#Include <_Struct>
#Include <WinStructs>

sl := ""
Count := 0
for key, value in WinStructs {
    if (key = "__class" || key = "defines"){
        continue
    }
    if (Count){
        sl .= "|"
    }
    sl .= key
    Count++
}

Gui, Add, Text, Center w400 , % "RUNNING AS: " (A_PtrSize = 4? "32" : "64") "-Bit ( PtrSize: " A_PtrSize ")"
Gui, Add, Text, Section, Structure Name:
Gui, Add, DDL, w250 ys vStructName gDecode, %sl%
;Gui, Add, Edit, ys w250 vStructName Section
Gui, Add, Button, ys gDecode, Decode
Gui, Add, Edit, xm w400 h400 vOutput
Gui, Show

return

Decode:
    Gui, Submit, NoHide
    out := GetOffsets(StructName)
    GuiControl, , Output, % out
    return

;Esc::
GuiClose:
    ExitApp

GetOffsets(name){
    if (!ObjHasKey(WinStructs, name)){
        return "Not Found"
    }
    struct := new _Struct("WinStructs." name)
    arr := []
    obj := struct.ToObj()

    for key, value in obj {
        arr[struct.Offset(key)] := key
    }

    for key, value in arr {
        s .= value ": NumGet(data, b + " key ",""" struct.AhkType(value) """)`n"
    }
    s .= "`n`nSize: " sizeof(struct)
    ;Clipboard := s
    ;msgbox % s
    return s
}
