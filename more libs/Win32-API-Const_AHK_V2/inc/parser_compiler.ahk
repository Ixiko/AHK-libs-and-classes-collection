parser_by_compiler() { ; total header files: 3,505
    ; Static q := Chr(34)
    root := g["ApiPath"].Text
    SplitPath root, rootFile, rootDir
    already_scanned := Map(), IncludesList := Map(), const_list := Map()
    dupe_list := []
    ; cppConst := ""
    
    cppConst := parse_includes([root])
    const_list := cppConst
    
    ; msgbox "count: " const_list.length
    
    prevList := ""
    Loop {
        curList := resolve_const(A_Index)
        If (curList = prevList or curList = "")
            Break
        prevList := curList
    }
    
    ; msgbox "resolving done?"
    
    result := compile_list()
    A_Clipboard := result
    
    ; Run "notepad.exe test_const.cpp"
    ; A_Clipboard := jxon_dump(cppConst,4)
    ; A_Clipboard := jxon_dump(dupe_list,4)
    
    Msgbox "done`r`n`r`n" result
}

compile_list() {
    Static q := Chr(34)
    root := g["ApiPath"].Text
    SplitPath root, rootFile, rootDir
    cppFile := "#include <iostream>`r`n#include <" rootFile ">`r`n`r`nint main() {`r`n"
    cppFileEnd := "`r`n    return 0;`r`n}"
    
    If (FileExist("test_const.cpp"))
        FileDelete "test_const.cpp"
    If (FileExist("test_const.exe"))
        FileDelete "test_const.exe"
    FileAppend cppFile, "test_const.cpp"
    
    cppChunk := ""
    
    ; msgbox "count: " const_list.count
    
    For const, obj in const_list { ; std::cout << "test = " << WINAPI;
        If obj["type"] != "unresolved"
            cppChunk .= "    std::cout << " q const "=" q " << " const " << std::endl;`r`n"
    }
    FileAppend cppChunk cppFileEnd, "test_const.cpp"
    
    ; run A_Comspec " /K " Settings["x64compiler"] " test_const.cpp"
    compiler := Settings["x64compiler"]
    If (InStr(compiler,"g++.exe") Or InStr(compiler,"c++.exe") Or InStr(compiler,"gcc.exe"))
        cmd := A_Comspec " /C " compiler " -o test_const.exe test_const.cpp"
    Else
        cmd := A_Comspec " /K " compiler " test_const.cpp"
    
    c := cli.New(cmd)
    
    return c.stdout
}

parse_includes(inArr,cppConst:="") {
    Static q := Chr(34)
    Static rg1 := "i)^\#include[ `t]+(<|\" q ")([^>" q "]+)(>|\" q ")"
    Static rg2 := "i)^#define[ `t]+(\w+)[ `t]+(.+)"
    If (cppConst = "")
        cppConst := Map()
    
    root := g["ApiPath"].Text, newArr := []
    SplitPath root, rootFile, rootDir
    
    For i, fullFileName in inArr {
        SplitPath fullFileName, fileName
        If (already_scanned.Has(fileName)) {
            ; debug.msg("already scanned: " fileName)
            Continue
        }
        
        ; msgbox fileName
        If (FileExist(fileName))
            fullFileName := fileName
        
        If (!FileExist(fullFileName))
            fullFileName := get_full_path(fileName)
        
        If (!FileExist(fullFileName)) {
            msgbox "Include not found:`r`n`r`n" fileName "`r`n`r`n> " rootDir
            Continue
        }
        
        ; debug.msg(fullFileName)
        
        fileText := FileRead(fullFileName)
        t := StrSplit(fileText,"`n","`r"), i := 1
        
        While (i <= t.Length) { ; parsing file lines
            line := t[i]
            If (RegExMatch(line,rg1,m)) { ; if include add to next list
                incFile := m.Value(2)
                newArr.Push(rootDir "\" incFile)
            } Else If (RegExMatch(line,rg2,m)) { ; if const, capture and validate
                cName := m.Value(1), cValue := m.Value(2), lineNum := i
                
                ; msgbox cName "`r`n`r`n" cValue
                
                If (constCheck(cName) And !RegExMatch(cValue,"^[_a-zA-Z]+\x28")) {
                    cValue := Trim(RegExReplace(cValue,"(/\*.*\*/|//.*)|/\*.*","")," `t")
                    While (SubStr(cValue,-1) = "\") {
                        cValue := SubStr(cValue,1,-2)
                        cValue .= t[++i] ; increment i and add next line
                        cValue := Trim(RegExReplace(cValue,"(/\*.*\*/|//.*|/\*.*)","")," `t")
                    }
                    cValue := RegExReplace(StrReplace(cValue,"`t"," "),"[ ]{2,}"," ")
                    If (!valueCheck(cValue)) {
                        i++
                        Continue
                    }
                    
                    If (cppConst.Has(cName))
                        dupe_list.Push(Map("name",cName,"exp",cValue,"value",cValue,"type","unknown","file",fileName,"line",lineNum))
                    Else
                        cppConst[cName] := Map("exp",cValue,"value",cValue,"type","unknown","file",fileName,"line",lineNum)
                }
            }
            i++
        }
        already_scanned[fileName] := ""
    }
    
    ; msgbox "cppConst:`r`n`r`n" cppConst
    ; msgbox jxon_dump(newArr,4)
    
    If (newArr.Length) {
        cppConst := parse_includes(newArr,cppConst)
    }
    
    return cppConst
}

parse_other_files() {
    Static q := Chr(34)
    Static rg1 := "i)^\#include[ `t]+(<|\" q ")([^>" q "]+)(>|\" q ")"
    Static rg2 := "i)^#define[ `t]+(\w+)[ `t]+(.+)"
    If (cppConst = "")
        cppConst := Map()
    
    root := g["ApiPath"].Value, newArr := []
    SplitPath root, rootFile, rootDir
    
    
}

resolve_const(pass) { ; constants that point to a single constant / any type
    t := 0, list := ""
    prog := progress2.New(0,const_list.Count,"title:Reparse 1")
    prog.Update(A_Index,"Reparse 1 - Pass #" pass)
    
    For const, obj in const_list {
        prog.Update(A_Index)
        
        cValue := obj["value"], cType := obj["type"], cExp := obj["exp"]
        If (InStr(cValue,"`t"))
            Continue
        
        If (cType = "unknown") {
            searched := false, newPos := 1
            
            If IsInteger(obj["value"]) {
                obj["type"] := "integer", const_list[const] := obj
                Continue
            }
            
            r := RegExMatch(cValue,"([\w]+)",m), match := ""
            If (IsObject(m))
                match := m.Value(1)
            
            While (r And match) {
                searched := true ; a substitution ws actually made
                
                If (!IsInteger(match)) {
                    If (!const_list.Has(match)) {
                        obj["type"] := "unresolved"
                        const_list[const] := obj
                        Break
                    }
                    
                    prep := cValue
                    mObj := const_list[match], mValue := mObj["value"]
                    cValue := StrReplace(cValue,match,mValue,true,,1)
                    newPos := m.Pos(1) + StrLen(mValue)
                    
                    If (!obj.Has("depn"))
                        obj["depn"] := [match]
                    Else
                        obj["depn"].Push(match)
                } Else {
                    newPos += m.Pos(1) + m.Len(1)
                }
                
                If (eval(cValue,true))
                    Break
                
                r := RegExMatch(cValue,"([\w]+)",m,newPos), match := ""
                If (IsObject(m))
                    match := m.Value(1)
            }
            
            If (searched And eval(cValue,true)) {
                obj["type"] := "expr", obj["value"] := cValue 
                const_list[const] := obj
                
                t++, list .= const "`r`n"
            }
        }
    }
    
    prog.Close() ; msgbox "reparse1: " t
    return list
}

valueCheck(sInput) {
    isUp := true
    Loop Parse sInput
    {
        z := Ord(A_LoopField)
        If !(z = 32 Or z = 38
                    Or (z >= 40 And z <= 43)
                    Or z = 45 Or z = 47
                    Or (z >= 48 And z <= 57)
                    Or (z >= 60 And z <= 62)
                    Or (z >= 65 And z <= 90)
                    Or z = 94 Or z = 95 Or z = 120 Or z = 124 Or z = 126) {
            isUp := false
            Break
        }
    }
    
    return isUp
}

constCheck(sInput) { ; 48 - 57, 65 - 90, 95
    isUp := true
    Loop Parse sInput
    {
        z := Ord(A_LoopField)
        If !((z >= 48 And z <= 57) Or (z >= 65 And z <= 90) Or z = 95) {
            isUp := false
            Break
        }
    }
    
    return isUp
}

parse_constants(inFile) {

}

; 32-bit LONG max value = 2147483647
; 32-bit ULONG max value = 4294967296
;                          4294967295
; 32-bit convert LONG to ULONG >>> add 2147483648

; 64-bit LONG LONG max value = 9223372036854775807
; 64-bit ULONG LONG max vlue = 18446744073709551616
; 64-bit convert LONGLONG to ULONGLONG >>> add 9223372036854775808

value_parser_cleanup(inValue) { ; value_cleanup()
    Static q := Chr(34)
    cType := "unknown"
    
    If (RegExMatch(inValue,"^\w+\x28")) {       ; Macros likely won't be resolved, so identify them as such
        cType := "macro", cValue := inValue     ; so we don't continually recurse them.
        Goto Finish
    }
    
    inValue := Trim(RegExReplace(inValue,";$","")," `t")
    cValue := inValue ; init cValue
    
    If (IsInteger(inValue)) { ; type = integer / no conversion needed
        cType := "integer", cValue := Integer(inValue)
        Goto Finish
    }
    
    If (RegExMatch(inValue,"\x28?\d+U\-\d+U\x29?")) {
        newValue := StrReplace(inValue,"U","")
        cType := "expr", cValue := newValue
        Goto Finish
    }
    
    ; If (RegExMatch(inValue,"i)^\x28ULONG\x29([ ]*)?(0x[\dA-F]+)L?$",m)) {
        ; If (IsInteger(m.Value(2))) {
            ; inValue := Integer(m.Value(2)) + 2147483648 ; convert to unsigned long
            ; cType := "integer", cValue := inValue
            ; Goto Finish
        ; }
    ; }
    
    If (RegExMatch(inValue,"^\x28?((0x)?[\-0-9A-Fa-f ]+)(L|l|LL)?\x29?$",m)) {
        If (IsInteger(m.Value(1))) {
            cType := "integer", cValue := Integer(m.Value(1))
            Goto Finish
        }
    }
    
    If (RegExMatch(inValue,"^\x28?\x28ULONG\x29 ?((0x)?[0-9A-Fa-f]+)\x29?$",m)) { ; simple ULONG conversion
        If (IsInteger(m.Value(1))) {
            cType := "integer", cValue := Integer(m.Value(1))
            Goto Finish
        }
    }
    
    newValue := RegExReplace(inValue,"^\x28? ?((0x)?\-?[a-fA-F0-9]+)(U|L|UL|ULL|LL|ui|ul|UI)(8|16|32|64)? ?\x29?$","$1")
    If (newValue != inValue And IsInteger(newValue)) { ; type = numeric literal
        cType := "integer", cValue := Integer(newValue)
        Goto Finish
    }
    
    If (RegExMatch(inValue,"^\x28? ?(\-?[0-9\.]+)(f)? ?\x29?$",m)) {
        cType := "float", cValue := m.Value(1)
        Goto Finish
    }
    
    If (RegExMatch(inValue,"^\{.*\}$")) {
        cType := "array", cValue := inValue
        Goto Finish
    }
    
    If (RegExMatch(inValue,"^\x28? ?L?\'.+?\' ?\x29?$")) {
        cType := "string", cValue := inValue
        Goto Finish
    }
    
    If (RegExMatch(inValue,"^\x28? ?L?\" q ".*\" q " ?\x29?$")) { ; wchar_t string
        cType := "string", cValue := inValue
        Goto Finish
    }
    
    Finish:
    inValue := RegExReplace(inValue,"[ ]{2,}"," ") ; attempt to remove consecutive spaces, hopefully won't break anything
    inValue := Trim(inValue," `t")
    return {value:cValue, type:cType}
}

; isMathExpr(mathStr) {
    ; If mathStr = ""
        ; return false
    ; Loop Parse mathStr
    ; {
        ; c := Ord(A_LoopField)
        ; If !(c=32 Or c=38 Or (c>=40 And c<=43) Or (c>=45 And c<=57) Or (c>=60 And c<=62) Or (c>=65 And c<=70) Or c=94 Or c=120 Or c=124 Or c=126)
            ; return false ; actual string evaluated MUST be purely numerical with operators
    ; }
    ; return true
; }

