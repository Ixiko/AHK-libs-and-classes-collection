; AHK v2

; great win32 api constant sources:
; https://raw.githubusercontent.com/GroggyOtter/GroggyRepo/master/Files/List%20-%20Win32%20Constants
; https://www.autoitscript.com/forum/files/file/16-win32-api-constants/

; Thanks to GroggyOtter on GitHub and to GaryFrost on autoIt
; forums for posting thier lists of Win32 API constants.

Global const_list:="", g:="", doReset:=false, timerDelay := -500, unkFilter := false

load_gui()

scan_const()

; saved_const := FileRead("const_list.txt")
; const_list := jxon_load(saved_const)

relist_const()

OnMessage(0x0100,"WM_KEYDOWN") ; WM_KEYDOWN

return

#INCLUDE _JXON.ahk

load_gui() {
    g := Gui.New("","Win32 API Constants")
    g.OnEvent("close","close_gui")
    g.SetFont("s10","Consolas")
    
    g.Add("Text","y10","Name:")
    g.Add("Edit","yp-4 x+2 w100 vNameFilter","").OnEvent("change","gui_events")
    g.Add("Button","x+0 vNameFilterClear","X").OnEvent("click","gui_events")
    g.Add("CheckBox","x+12 yp+4 vNameBW","Begins with").OnEvent("click","gui_events")
    
    g.Add("Text","x400 yp+4","Value:")
    g.Add("Edit","yp-4 x+2 w100 vValueFilter","").OnEvent("change","gui_events")
    g.Add("Button","x+0 vValueFilterClear","X").OnEvent("click","gui_events")
    g.Add("CheckBox","x+12 yp+4 vValueEQ","Exact").OnEvent("click","gui_events")
    
    g.Add("Button","x725 yp-4 vUnk","UNK").OnEvent("click","gui_events")
    g.Add("Button","x+0 w50 vReset","Reset").OnEvent("click","gui_events")
    
    ctl := g.Add("ListView","xm w800 h400 vConstList",["Name","Value"])
    ctl.ModifyCol(1,385), ctl.ModifyCol(2,385)
    ctl.OnEvent("click","gui_events")
    
    g.Add("Edit","xm y+5 w800 r6 vDetails ReadOnly","")
    g.Add("Text","xm y+5 w800 vTotal","Please Wait...")
    
    g.Show()
}

close_gui(*) {
    ExitApp
}

relist_const(nFilter:="",vFilter:="") {
    ctl := g["ConstList"]
    ctl.Opt("-Redraw")
    ctl.Delete()
    t := 0, u := 0, i := 0, s := 0
    
    nFilter := StrReplace(nFilter,"*",".*")
    
    If (unkFilter) {
        For const, obj in const_list {
            value := obj["value"]
            If (obj["type"] = "unknown")
                ctl.Add(,const,value), t++, u++
        }
        unkFilter := false
    } Else {
        For const, obj in const_list {
            value := obj["value"]
            
            If (g["NameBW"].Value) {
                If (g["ValueEQ"].Value) {
                    If (!nFilter And !vFilter)
                        ctl.Add(,const,value), t++, u := ((obj["type"] = "unknown") ? u+1 : u), i := ((obj["type"] = "integer") ? i+1 : i), s := ((obj["type"] = "string") ? s+1 : s)
                    Else If ((nFilter And !vFilter) And RegExMatch(const,"i)" nFilter) = 1)
                        ctl.Add(,const,value), t++, u := ((obj["type"] = "unknown") ? u+1 : u), i := ((obj["type"] = "integer") ? i+1 : i), s := ((obj["type"] = "string") ? s+1 : s)
                    Else If ((!nFilter And vFilter) And value=vFilter)
                        ctl.Add(,const,value), t++, u := ((obj["type"] = "unknown") ? u+1 : u), i := ((obj["type"] = "integer") ? i+1 : i), s := ((obj["type"] = "string") ? s+1 : s)
                    Else If ((nFilter And vFilter) And (RegExMatch(const,"i)" nFilter) = 1 And value=vFilter))
                        ctl.Add(,const,value), t++, u := ((obj["type"] = "unknown") ? u+1 : u), i := ((obj["type"] = "integer") ? i+1 : i), s := ((obj["type"] = "string") ? s+1 : s)
                } Else {
                    If (!nFilter And !vFilter)
                        ctl.Add(,const,value), t++, u := ((obj["type"] = "unknown") ? u+1 : u), i := ((obj["type"] = "integer") ? i+1 : i), s := ((obj["type"] = "string") ? s+1 : s)
                    Else If ((nFilter And !vFilter) And RegExMatch(const,"i)" nFilter) = 1)
                        ctl.Add(,const,value), t++, u := ((obj["type"] = "unknown") ? u+1 : u), i := ((obj["type"] = "integer") ? i+1 : i), s := ((obj["type"] = "string") ? s+1 : s)
                    Else If ((!nFilter And vFilter) And InStr(value,vFilter))
                        ctl.Add(,const,value), t++, u := ((obj["type"] = "unknown") ? u+1 : u), i := ((obj["type"] = "integer") ? i+1 : i), s := ((obj["type"] = "string") ? s+1 : s)
                    Else If ((nFilter And vFilter) And (RegExMatch(const,"i)" nFilter) = 1 And InStr(value,vFilter)))
                        ctl.Add(,const,value), t++, u := ((obj["type"] = "unknown") ? u+1 : u), i := ((obj["type"] = "integer") ? i+1 : i), s := ((obj["type"] = "string") ? s+1 : s)
                }
            } Else {
                If (g["ValueEQ"].Value) {
                    If (!nFilter And !vFilter)
                        ctl.Add(,const,value), t++, u := ((obj["type"] = "unknown") ? u+1 : u), i := ((obj["type"] = "integer") ? i+1 : i), s := ((obj["type"] = "string") ? s+1 : s)
                    Else If ((nFilter And !vFilter) And RegExMatch(const,"i)" nFilter))
                        ctl.Add(,const,value), t++, u := ((obj["type"] = "unknown") ? u+1 : u), i := ((obj["type"] = "integer") ? i+1 : i), s := ((obj["type"] = "string") ? s+1 : s)
                    Else If ((!nFilter And vFilter) And value=vFilter)
                        ctl.Add(,const,value), t++, u := ((obj["type"] = "unknown") ? u+1 : u), i := ((obj["type"] = "integer") ? i+1 : i), s := ((obj["type"] = "string") ? s+1 : s)
                    Else If ((nFilter And vFilter) And (RegExMatch(const,"i)" nFilter) And value=vFilter))
                        ctl.Add(,const,value), t++, u := ((obj["type"] = "unknown") ? u+1 : u), i := ((obj["type"] = "integer") ? i+1 : i), s := ((obj["type"] = "string") ? s+1 : s)
                } Else {
                    If (!nFilter And !vFilter)
                        ctl.Add(,const,value), t++, u := ((obj["type"] = "unknown") ? u+1 : u), i := ((obj["type"] = "integer") ? i+1 : i), s := ((obj["type"] = "string") ? s+1 : s)
                    Else If ((nFilter And !vFilter) And RegExMatch(const,"i)" nFilter))
                        ctl.Add(,const,value), t++, u := ((obj["type"] = "unknown") ? u+1 : u), i := ((obj["type"] = "integer") ? i+1 : i), s := ((obj["type"] = "string") ? s+1 : s)
                    Else If ((!nFilter And vFilter) And InStr(value,vFilter))
                        ctl.Add(,const,value), t++, u := ((obj["type"] = "unknown") ? u+1 : u), i := ((obj["type"] = "integer") ? i+1 : i), s := ((obj["type"] = "string") ? s+1 : s)
                    Else If ((nFilter And vFilter) And (RegExMatch(const,"i)" nFilter) And InStr(value,vFilter)))
                        ctl.Add(,const,value), t++, u := ((obj["type"] = "unknown") ? u+1 : u), i := ((obj["type"] = "integer") ? i+1 : i), s := ((obj["type"] = "string") ? s+1 : s)
                }
            }
        }
    }
    
    ctl.Opt("+Redraw")
    g["Total"].Text := "Total: " t "    /    Unknown: " u "    /    Known: " t-u "    /    Integers: " i "    /    Strings: " s
    
    If (doReset) {
        doReset:=false
        g["NameFilter"].Focus()
    }
}

gui_events(ctl,info) {
    If (ctl.Name = "NameFilter") {
        SetTimer "relist_timer", timerDelay
    } Else If (ctl.Name = "ValueFilter") {
        SetTimer "relist_timer", timerDelay
    } Else If (ctl.Name = "NameBW") {
        SetTimer "relist_timer", timerDelay
    } Else If (ctl.Name = "ValueEQ") {
        SetTimer "relist_timer", timerDelay
    } Else If (ctl.Name = "Reset") {
        g["NameFilter"].Value := ""
        g["ValueFilter"].Value := ""
        g["NameBW"].Value := 0
        g["ValueEQ"].Value := 0
        doReset := true
        SetTimer "relist_timer", timerDelay
    } Else If (ctl.Name = "ConstList") {
        If (!info)
            return
        
        constName := ctl.GetText(info)
        constValue := const_list[constName]["value"]
        constType := const_list[constName]["type"]
        constExp := const_list[constName]["exp"]
        constComplete := const_list[constName]["complete"]
        
        g["Details"].Value := "Name:  " constName "`r`nValue: " constValue "`r`nExpr:  " constExp "`r`nType:  " constType
    } Else If (ctl.Name = "Unk") {
        unkFilter := true
        g["NameFilter"].Value := ""
        g["NameBW"].Value := 0
        g["ValueFilter"].Value := ""
        g["ValueEQ"].Value := 0
        SetTimer "relist_timer", timerDelay
    } Else If (ctl.Name = "NameFilterClear") {
        g["NameFilter"].Value := ""
        g["NameBW"].Value := 0
        SetTimer "relist_timer", timerDelay
    } Else If (ctl.Name = "ValueFilterClear") {
        g["ValueFilter"].Value := ""
        g["ValueEQ"].Value := 0
        SetTimer "relist_timer", timerDelay
    }
}

relist_timer() {
    relist_const(g["NameFilter"].value,g["ValueFilter"].value)
}

scan_const() {
    const_list := Map(), const_exp := Map(), const_basic := Map(), delete_list := Map()
    
    arr := StrSplit(FileRead("constants.txt"),"`n","`r")
    
    For i, line in arr {
        If (line = "[CONSTANT]")
            Continue
        
        eq := InStr(line,"=")
        const := Trim(SubStr(line,1,eq-1))
        value := Trim(SubStr(line,eq+1)," =,")
        
        If (InStr(value,"(") = 1 And SubStr(value,-1) = ")")
            value := SubStr(value,2,-1)
        
        If (value = "NUL" Or value = "NULL" Or value = "false")
            value := 0
        
        If (value = "true")
            value := 1
        
        If (InStr(value,"|"))
            value := StrReplace(value,"|"," | ")
        
        curVal := ""
        Try curVal := Integer(value)
        
        If curVal = ""
            Try curVal := eval(value)
        
        If (IsInteger(curVal)) {
            const_list[const] := Map("const",const,"type","integer","value",curVal,"exp",value,"complete",true)
            Continue
        }
        
        If (SubStr(value,1,1) = Chr(34) And SubStr(value,-1) = Chr(34) And !InStr(value,"+")) {
            const_list[const] := Map("const",const,"type","string","value",Trim(value,Chr(34)),"exp",value,"complete",true)
            Continue
        }
        
        If (InStr(value,Chr(34)) And InStr(value,"+")) {
            const_list[const] := Map("const",const,"type","string","value",value,"exp",value,"complete",false)
            Continue
        }
        
        const_list[const] := Map("const",const,"type","unknown","value",value,"exp",value,"complete",false)
    }
    
    If (const_list.Has(""))
        const_list.Delete("")
    
    Loop 2
        reparse1()
    
    Loop 18 ; re-use until no replacements
        reparse2()
    
    Loop 3 ; re-use until no replacements
        reparse3()
    
    reparse4()
    
    reparse5()
    
    reparse2()
}

F2::{
    FileAppend jxon_dump(const_list,4), "const_list.txt"
}

WM_KEYDOWN(wParam, lParam, msg, hwnd) { ; up / down scrolling with keyboard
    If (g["ConstList"].hwnd = hwnd And (wParam = 38 Or wParam = 40))
        SetTimer "gui_timer", -100
}

gui_timer() {
    gui_events(g["ConstList"],g["ConstList"].GetNext())
}

reparse5() {
    t := 0, opers := "+-*/^"
    For const, obj in const_list {
        cValue := obj["value"], cType := obj["type"]
        cComp := obj["complete"], cExp := obj["exp"]
        newVal := 0, finalVal := "", success := true
        
        If (cType = "unknown" And InStr(cValue," ")) {
            arr := StrSplit(cValue," ")
            
            If (arr[1] = "") 
                Continue
            
            For i, v in arr {
                v := Trim(v)
                If (const_list.Has(v) And const_list[v]["type"] = "integer") {
                    newVal := Integer(const_list[v]["value"])
                } Else If (IsInteger(v)) {
                    newVal := v
                } Else If (InStr(opers,v)) {
                    newVal := v
                } Else {
                    newVal := 0, finalVal := "", success := false
                    Break ; MUST break / cancel changes to obj
                }
                
                finalVal .= newVal " "
            }
            finalVal := Trim(finalVal)
            
            If (success) {
                Try {
                    old := finalVal
                    finalVal := eval(finalVal)
                    If (!IsInteger(finalVal))
                        Continue
                } Catch e
                    Continue
                
                obj["value"] := finalVal, obj["complete"] := true, obj["type"] := "integer"
                const_list[const] := obj
                t++
            }
        }
        c := A_Index
    }
    
    ; msgbox "reparse5: " t " / " c
}

reparse4() {
    t := 0
    For const, obj in const_list {
        cValue := obj["value"], cType := obj["type"]
        cComp := obj["complete"], cExp := obj["exp"]
        newVal := 0, finalVal := 0, success := true
        
        If (cType = "unknown" And InStr(cValue,"-")) {
            arr := StrSplit(cValue,"-")
            
            If (arr.Length != 2 Or arr[1] = "") 
                Continue
            
            For i, v in arr {
                v := Trim(v)
                If (const_list.Has(v) And const_list[v]["type"] = "integer") {
                    newVal := Integer(const_list[v]["value"])
                } Else If (IsInteger(v)) {
                    newVal := Integer(v)
                } Else {
                    newVal := 0, finalVal := 0, success := false
                    Break ; MUST break / cancel changes to obj
                }
                
                finalVal -= newVal
            }
            
            If (success) {
                obj["value"] := finalVal, obj["complete"] := true, obj["type"] := "integer"
                const_list[const] := obj
                t++
            }
        }
        c := A_Index
    }
    
    ; msgbox "reparse4: " t " / " c
}

reparse3() { ; const integer with bitwise OR "|"
    t := 0
    For const, obj in const_list {
        cValue := obj["value"], cType := obj["type"]
        cComp := obj["complete"], cExp := obj["exp"]
        newVal := 0, finalVal := 0, success := true
        
        If (cType = "unknown" And InStr(cValue,"|")) {
            arr := StrSplit(cValue,"|")
            
            For i, v in arr {
                v := Trim(v)
                If (IsInteger(v))
                    newVal := Integer(v)
                Else If (const_list.Has(v) And const_list[v]["type"] = "integer") {
                    newVal := const_list[v]["value"]
                } Else {
                    success := false
                    Break
                }
                
                finalVal := finalVal | newVal
            }
            
            If (success) {
                obj["value"] := finalVal, obj["complete"] := true, obj["type"] := "integer"
                const_list[const] := obj
                t++
            }
        }
        c := A_Index
    }
    ; msgbox "reparse3: " t " / " c
}

reparse2() { ; only trying to calc [ const + number ] or similar
    t := 0
    For const, obj in const_list {
        cValue := obj["value"], cType := obj["type"]
        cComp := obj["complete"], cExp := obj["exp"]
        newVal := 0, finalVal := 0, success := true
        
        If (cType = "unknown" And InStr(cValue,"+")) {
            arr := StrSplit(cValue,"+")
            
            If (arr.Length != 2 Or arr[1] = "") 
                Continue
            
            For i, v in arr {
                v := Trim(v)
                If (const_list.Has(v) And const_list[v]["type"] = "integer") {
                    newVal := Integer(const_list[v]["value"])
                } Else If (IsInteger(v)) {
                    newVal := Integer(v)
                } Else {
                    newVal := 0, finalVal := 0, success := false
                    Break ; MUST break / cancel changes to obj
                }
                
                finalVal += newVal
            }
            
            If (success) {
                obj["value"] := finalVal, obj["complete"] := true, obj["type"] := "integer"
                const_list[const] := obj
                t++
            }
        }
        c := A_Index
    } ; end FOR loop
    
    ; msgbox "reparse2: " t " / " c
}

reparse1() { ; constants that point to a single constant / any type
    t := 0, wtfList := ""
    For const, obj in const_list {
        cValue := obj["value"], cType := obj["type"]
        cComp := obj["complete"], cExp := obj["exp"]
        
        ; If (const = "DISPID_EVMETH_ONSCROLL")
            ; msgbox "DISPID_EVMETH_ONSCROLL / " cValue " / " 
        
        If (cType = "unknown" And const_list.Has(cValue)) {
            nObj := const_list[cValue]
            nType := nObj["type"], nValue := nObj["value"]
            
            ; If (const = "DISPID_EVMETH_ONSCROLL")
                ; msgbox "DISPID_EVMETH_ONSCROLL / " cValue " / " nType
            
            ; If (obj["type"] != nType)
                ; t++ ; msgbox const " / " obj["type"] " / " nType
            
            ; wtfList .= cValue "`r`n"
            
            obj["type"] := nType, obj["value"] := nValue 
            obj["complete"] := (nType != "unknown") ? true : obj["complete"]
            const_list[const] := obj
            
            t++
        }
    }
    ; A_Clipboard := wtfList
    ; msgbox "reparse1: " t
}

eval(x) {
    opers := "^/*-+"
    If (!InStr(x,"^") And !InStr(x,"/") And !InStr(x,"*") And !InStr(x,"-") And !InStr(x,"+"))
        return ""
    
    numeric := true
    Loop Parse x, " "
    {
        If (!IsNumber(A_LoopField) And !InStr(opers,A_LoopField)) {
            numeric := false
            Break
        }
    }
    
    If (!numeric)
        return ""
    
    x := StrReplace(x,"**","^")
    
    ; funcExp := "abs|ceil|exp|floor|log|Ln|sqrt|sin|asin|cos|acos|tan|atan"
    ; If (RegExMatch(x,"i)(^(" funcExp ")\x28(.*)\x29)$",m)) {
        ; if (strLen(x) = strLen(m.Value(1))) {
            ; simpleValue := m.Value(3)
            ; funcName := m.Value(2)
            
            ; curVal := eval(simpleValue)
            
            ; funcName := StrLower(funcName)
            ; Switch funcName {
                ; case "abs": result := Abs(curVal)
                ; case "ceil": result := Ceil(curVal)
                ; case "exp": result := Exp(curVal)
                ; case "floor": result := Floor(curVal)
                ; case "log": result := Log(curVal)
                ; case "Ln": result := Ln(curVal)
                ; case "sqrt": result := Sqrt(curVal)
                ; case "sin": result := Sin(curVal)
                ; case "asin": result := ASin(curVal)
                ; case "cos": result := Cos(curVal)
                ; case "acos": result := ACos(curVal)
                ; case "tan": result := Tan(curVal)
                ; case "atan": result := ATan(curVal)
            ; }
        ; }
        
        ; return result
    ; }
    
    result := ""
    If (IsInteger(x))
        return Integer(x)
    Else If (IsFloat(x))
        return Float(x)
    
    order := "^/*-+"
    
    Loop Parse order
    {
        If (o := InStr(x,A_LoopField)) {
            p1 := Trim(SubStr(x,1,o-1)," `t")
            p2 := Trim(SubStr(x,o+1)," `t")
            
            p1 := (IsNumber(p1) And InStr(p1,".")) ? Float(p1) : (IsNumber(p1)) ? Integer(p1) : eval(p1)
            p2 := (IsNumber(p2) And InStr(p2,".")) ? Float(p2) : (IsNumber(p2)) ? Integer(p2) : eval(p2)
            
            If (p1 = "" Or p2 = "")
                return ""
            
            Switch A_LoopField {
                case "+": result := p1 + p2
                case "-": result := p1 - p2
                case "*": result := p1 * p2
                case "/": result := p1 / p2
                case "^": result := p1 ** p2
            }
        }
    }
    
    return result ; msgbox "simple exp type 1: " Type(result) " / " result
}
