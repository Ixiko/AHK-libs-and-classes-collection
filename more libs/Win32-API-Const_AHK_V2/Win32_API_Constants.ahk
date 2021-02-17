; AHK v2

; great win32 api constant sources:
; https://raw.githubusercontent.com/GroggyOtter/GroggyRepo/master/Files/List%20-%20Win32%20Constants
; https://www.autoitscript.com/forum/files/file/16-win32-api-constants/

; Thanks to GroggyOtter on GitHub and to GaryFrost on autoIt
; forums for posting thier lists of Win32 API constants.

; For a list of win32 headers by category / technology:
; https://docs.microsoft.com/en-us/windows/win32/api/

Global g:="", g3:="" ; Gui obj
Global c:="" ; console obj
Global SearchControlList := ["NameFilter","ValueFilter","ExpFilter"], recent_handle := 0
Global IncludesList := Map()
Global calcListCount := 1, calcListTotal := 0, calcErrorList := "", Mprog := "", mb := menubar.new()
Global doReset:=false, timerDelay := -500
Global const_list:=Map(), Settings:=Map(), filteredList := Map()

Global already_scanned := Map(), dupe_list:=[]
Global errMsg := "" ; for progress bar during calculations??

If (FileExist("settings.json")) {
    sText := FileRead("settings.json")
    Settings := jxon_load(sText)
}

(!Settings.Has("LastFile"))     ? Settings["LastFile"]     := "" : ""       ; init default values
(!Settings.Has("AutoLoad"))     ? Settings["AutoLoad"]     := false : ""
(!Settings.Has("baseFiles"))    ? Settings["baseFiles"]    := [] : ""
(!Settings.Has("ApiPath"))      ? Settings["ApiPath"]      := "" : ""
(!Settings.Has("ScanType"))     ? Settings["ScanType"]     := "C&ollect" : ""
(!Settings.Has("x64_MSVC"))     ? Settings["x64_MSVC"]     := "" : ""
(!Settings.Has("x86_MSVC"))     ? Settings["x86_MSVC"]     := "" : ""
(!Settings.Has("x64_GCC"))      ? Settings["x64_GCC"]      := "" : ""
(!Settings.Has("x86_GCC"))      ? Settings["x86_GCC"]      := "" : ""
(!Settings.Has("CompilerType")) ? Settings["CompilerType"] := "x64_MSVC_Sel" : ""
(!Settings.Has("AddIncludes"))  ? Settings["AddIncludes"]  := true : ""
(!Settings.Has("var_copy"))     ? Settings["var_copy"]     := "&var := value" : ""

(!Settings.Has("FileFilter"))   ? Settings["FileFilter"]   := "" : ""
(!Settings.Has("CheckInteger")) ? Settings["CheckInteger"] := 1 : ""
(!Settings.Has("CheckFloat"))   ? Settings["CheckFloat"]   := 1 : ""
(!Settings.Has("CheckString"))  ? Settings["CheckString"]  := 1 : ""
(!Settings.Has("CheckUnknown")) ? Settings["CheckUnknown"] := 1 : ""
(!Settings.Has("CheckOther"))   ? Settings["CheckOther"]   := 1 : ""
(!Settings.Has("CheckExpr"))    ? Settings["CheckExpr"]    := 1 : ""
(!Settings.Has("CheckDupe"))    ? Settings["CheckDupe"]    := 1 : ""
(!Settings.Has("CheckCrit"))    ? Settings["CheckCrit"]    := 1 : ""

load_gui()

If (Settings["AutoLoad"] And FileExist(Settings["LastFile"])) { ; load data if Auto-Load enabled
    UnlockGui(false)
    LoadFile(Settings["LastFile"])
    UnlockGui(true)
    g["File"].Value := "File: " Settings["LastFile"]
}

OnMessage(0x0100,"WM_KEYDOWN") ; WM_KEYDOWN

return ; end auto-exec section

#INCLUDE libs\_JXON.ahk
#INCLUDE libs\TheArkive_CliSAK.ahk
#INCLUDE libs\TheArkive_Progress2.ahk
#INCLUDE libs\TheArkive_eval.ahk

#INCLUDE "*i libs\TheArkive_Debug.ahk"

#INCLUDE inc\gui_extra_dirs.ahk
#INCLUDE inc\gui_filters.ahk
#INCLUDE inc\gui_incl_report.ahk
#INCLUDE inc\gui_main.ahk
#INCLUDE inc\header_parser.ahk
; #INCLUDE inc\parser_compiler.ahk


listFiles() {
    list_of_files := Map(), fileList := []
    
    For const, obj in const_list {
        file := obj["file"]
        list_of_files[file] := ""
    }
    
    For file in list_of_files
        fileList.Push(file)
    
    return fileList
}

LoadFile(selFile:="") {
    If (selFile != "" And !FileExist(selFile)) {
        msgbox "Previous loaded file no longer exist.`r`n`r`nLoad failed."
        return
    } Else If (selFile="") {
        selFile := FileSelect("1",A_ScriptDir "\data\","Load Constant File:","Data file (*.data)")
        If (!selFile) ; user cancelled
            return
        SplitPath selFile,,,ext
        If (ext != "data") Or (!FileExist(selFile)) {
            Msgbox "You must select a data file."
            return
        }
    }
    
    g["Details"].Value := "", g["Duplicates"].Value := ""
    UnlockGui(false)
    SplitPath selFile, fileName
    g["Total"].Value := "Loading data file.  Please Wait ..."
    
    fileData := FileRead(selFile)
    
    in_load_data := jxon_load(fileData)
    If (in_load_data.Count = 2 And in_load_data.Has("__const_list")) {
        const_list := in_load_data["__const_list"]
        IncludesList := in_load_data["__includes_list"]
        in_load_data := "" ; free input array
    } Else
        const_list := in_load_data
    
    relist_const()
    g["File"].Value := "Data File: " fileName
    Settings["LastFile"] := selFile
    
    UnlockGui(true)
}

SaveFile() {
    lastFile := Settings["LastFile"]
    SplitPath lastFile, lastName
    saveFile := FileSelect("S 18",A_ScriptDir "\data\" lastName,"Save Data File:")
    
    If (saveFile) {
        save_data := Map("__const_list",const_list, "__includes_list",IncludesList)
        
        UnlockGui(false)
        
        FileExist(saveFile) ? FileDelete(saveFile) : ""
        fileData := Jxon_dump(save_data)
        saveFile := (SubStr(saveFile,-5) != ".data") ? saveFile ".data" : saveFile
        
        FileAppend fileData, saveFile
        
        Settings["LastFile"] := saveFile
        MsgBox "Data file successfully saved."
        UnlockGui(true)
        
        SplitPath saveFile, fileName
        g["File"].Value := "Data File: " fileName
    }
}

UnlockGui(bool) {
    g["Includes"].Enabled := bool
    
    g["NameFilter"].Enabled := bool, g["NameFilterClear"].Enabled := bool, g["NameBW"].Enabled := bool
    g["ValueFilter"].Enabled := bool, g["ValueFilterClear"].Enabled := bool, g["ValueEQ"].Enabled := bool
    g["ExpFilter"].Enabled := bool, g["ExpFilterClear"].Enabled := bool
    
    g["MoreFilters"].Enabled := bool, g["Reset"].Enabled := bool ; , g["Copy"].Enabled := bool, g["CopyType"].Enabled := bool
    g["ConstList"].Enabled := bool, g["Tabs"].Enabled := bool
    
    If (bool)
        mb.Enable("&Source"), mb.Enable("&Data"), mb.Enable("&List"), mb.Enable("&Compile")
    Else mb.Disable("&Source"), mb.Disable("&Data"), mb.Disable("&List"), mb.Enable("&Compile")
}

relist_const() {
    Static q := Chr(34)
    Static oopsStr := "\|(){}[]-+^$&%?.,<>" q
    
    n_fil := g["NameFilter"].value
    v_fil := g["ValueFilter"].value
    e_fil := g["ExpFilter"].Value
    f_fil := Settings["FileFilter"]
    
    If RegExMatch(n_fil,"[\\\|\(\)\{\}\[\]\-\+\^\$\&\%\?\.\,\<\>\" q "]") Or RegExMatch(f_fil,"\\\?\|<>:/" q) ; invalid chars in name and file filters
        return
    
    filteredList := Map()
    ctl := g["ConstList"]
    ctl.Opt("-Redraw")
    ctl.Delete()
    tot := 0
    
    i:=0, f:=0, s:=0, u:=0, o:=0, e:=0, d:=0, c:=0 ; i, f, s, u, o, e, d, c ; tallies for each type
    i_f := Settings["CheckInteger"], f_f := Settings["CheckFloat"], s_f := Settings["CheckString"] ; checkbox type filters
    u_f := Settings["CheckUnknown"], o_f := Settings["CheckOther"], e_f := Settings["CheckExpr"]
    d_f := Settings["CheckDupe"],    c_f := Settings["CheckCrit"]
    
    nFilter := !n_fil ? "*" : n_fil
    nFilter := StrReplace(nFilter,"*",".*")
    nFilter := g["NameBW"].Value ? "^" nFilter : nFilter
    
    vFilter := ""
    Loop Parse v_fil
    {
        If (InStr(oopsStr,ch := A_LoopField))
            vFilter .= "\" ch
        Else vFilter .= ch
    }
    vFilter := StrReplace(vFilter,"*",".*")
    vFilter := g["ValueEQ"].Value ? "^" vFilter "$" : vFilter
    
    eFilter := ""
    Loop Parse e_fil
    {
        If (InStr(oopsStr,ch := A_LoopField))
            eFilter .= "\" ch
        Else eFilter .= ch
    }
    eFilter := StrReplace(eFilter,"*",".*")
    
    fFilter := !f_fil ? "*" : f_fil
    fFilter := StrReplace(fFilter,".","\.")
    fFilter := StrReplace(fFilter,"*",".*")
    
    prog := progress2.New(0,const_list.Count,"title:Loading...,parent:" g.hwnd)
    
    do_all := (!n_fil And !v_fil And !e_fil And !f_fil) ? true : false
    
    For const, obj in const_list {
        prog.Update(A_Index)
        do_filter := false
        value := obj["value"], expr := obj["exp"], file := obj["file"], t := obj["type"]
        dupe := (obj.Has("dupe")) ? true : false
        crit := (obj.Has("critical")) ? true : false
        
        If (RegExMatch(const,"i)" nFilter) And RegExMatch(value,"i)" vFilter) And RegExMatch(expr,"i)" eFilter) And RegExMatch(file,"i)" fFilter))
            do_filter := true
        
        If (dupe And !d_f) Or (crit And !c_f) ; skip dupes and crits if check filter is unchecked
            Continue
        
        If (t="integer" And !i_f) Or (t="float" And !f_f) Or (t="string" And !s_f) Or (t="unknown" And !u_f) Or (t="other" And !o_f) Or (t="expr" And !e_f) ; skip if unchecked
            Continue
        
        If do_filter {
            filteredList[const] := obj
            c_disp := (crit)?"X":""
            d_disp := (dupe)?"X":""
            ctl.Add(,const,value,obj["type"],file,d_disp,c_disp), tot++ ; i, f, s, u, o, e, d    ; type filters
            
            Switch obj["type"] {
                Case "Integer": i+=1
                Case "Float"  : f+=1
                Case "String" : s+=1
                Case "Unknown": u+=1
                Case "Expr"   : e+=1
                Case "Other"  : o+=1
            }
            
            (dupe) ? d+=1 : ""
            (crit) ? c+=1 : ""
        }
    }
    prog.close()
    
    ctl.Opt("+Redraw")
    g["Total"].Text := "Total: " tot " / Unk: " u " / Known: " tot-u " / Int: " i " / Float: " f " / Str: " s " / Other: " o " / Expr: " e " / Dupes: " d " / Crit: " c
    
    If (doReset) {
        doReset:=false
        g["NameFilter"].Focus()
    }
}

filter_check(hwnd) {
    For ctl in SearchControlList ; global defined above
        If (hwnd = g[ctl].hwnd)
            return true
    return false
}

WM_KEYDOWN(wParam, lParam, msg, hwnd) { ; up / down scrolling with keyboard
    If (filter_check(hwnd) And wParam = 13) ; pressing enter for filters
        relist_const()
    Else If (g["ConstList"].hwnd = hwnd And (wParam = 38 Or wParam = 40))
        up_down_nav(wParam)
}

up_down_nav(key) {
    ctl := g["ConstList"]
    rMax := ctl.GetCount()
    curRow := ctl.GetNext()
    nextRow := (key=40) ? curRow+1 : (key=38) ? curRow-1 : curRow
    nextRow := (nextRow > rMax) ? 0 : nextRow
    gui_events(ctl,nextRow)
}

copy_const_details() {
    A_Clipboard := g["Details"].Value
}

copy_const_only() {
    n := g["ConstList"].GetNext()
    If (n) {
        t := g["ConstList"].GetText(n)
        A_Clipboard := t
    }
}

copy_const_group() {
    list := "", n := 0
    While(n := g["ConstList"].GetNext(n)) {
        If StrReplace(Settings["var_copy"],"&","") = "var only"
            list .= g["ConstList"].GetText(n) "`r`n"
        Else If StrReplace(Settings["var_copy"],"&","") = "var := value"
            list .= g["ConstList"].GetText(n) " := " g["ConstList"].GetText(n,2) "`r`n"
        
    }
    A_Clipboard := list
}

#HotIf WinActive("ahk_id " g.hwnd)

^+d::copy_const_details()
^d::copy_const_only()

F2::{
    critList := "", i := 0
    For const, obj in const_list {
        If obj.has("critical") And obj["critical"].Count > 0 {
            critList .= const "`r`n"
            For crit, obj2 in obj["critical"] {
                critList .= "    - " crit "`r`n"
                i++
            }
            critList .= "`r`n"
        }
    }
    critList := Trim(critList)
    Msgbox "Critical constants.`r`nFull list is copied to clipboard.`r`n`r`nCount: " i "`r`n`r`n" (!critList ? "* None *" : critList)
    A_Clipboard := critList
}

