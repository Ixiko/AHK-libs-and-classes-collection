load_gui() {
    g := Gui.New("+OwnDialogs +Resize +MinSize1076x488","C++ Constants Scanner")
    g.OnEvent("close","close_gui"), g.OnEvent("size","size_gui")
    g.SetFont("s10","Consolas")
    
    load_menubar(g)
    
    g.SetFont("s10","Consolas")
    
    g.Add("Text","xm y+10","Name:")
    g.Add("Edit","Section yp-4 x+2 w100 vNameFilter","").OnEvent("change","gui_events")
    g.Add("Button","x+0 hp vNameFilterClear","X").OnEvent("click","gui_events")
    g.Add("CheckBox","x+4 yp+4 vNameBW","Begins with").OnEvent("click","gui_events")
    
    g.Add("Text","x+20 ys+4","Value:")
    g.Add("Edit","Section yp-4 x+2 w100 vValueFilter","").OnEvent("change","gui_events")
    g.Add("Button","x+0 hp vValueFilterClear","X").OnEvent("click","gui_events")
    g.Add("CheckBox","x+4 yp+4 vValueEQ","Exact").OnEvent("click","gui_events")
    
    g.Add("Text","x+20 ys+4","Expression:")
    g.Add("Edit","Section yp-4 x+2 w100 vExpFilter","").OnEvent("change","gui_events")
    g.Add("Button","x+0 hp vExpFilterClear","X").OnEvent("click","gui_events")
    
    g.Add("Button","x+15 hp vMoreFilters","More Filters").OnEvent("click","gui_events")
    g.Add("Button","x+0 w85 hp vReset","Reset All").OnEvent("click","gui_events")
    g.Add("Button","x+15 h25 vIncludes","Includes").OnEvent("click","gui_events")
    
    ctl := g.Add("ListView","xm y+5 w1051 h300 vConstList Checked",["Name","Value","Type","File","D","C"]) ; w1050
    ctl.ModifyCol(1,435), ctl.ModifyCol(2,190), ctl.ModifyCol(3,135), ctl.ModifyCol(4,200), ctl.ModifyCol(5,30), ctl.ModifyCol(6,30)
    ctl.OnEvent("click","gui_events")
    
    ; g.Add("Text","xm y+5 vHelper","Press CTRL+D to copy selected constant details.")
    g.Add("Text","x500 y+5 w560 Right vFile","Data File:")
    
    tabCtl := g.Add("Tab3","Section xm y+5 w1050 h142 vTabs",["Details","Duplicates","Critical Dependencies","Settings"]) ; Critical Dependencies
    
    tabCtl.UseTab("Details")
    g.Add("Edit","xm y+5 w1050 r7 vDetails ReadOnly","")
    
    tabCtl.UseTab("Duplicates")
    g.Add("Edit","xm y+5 w1050 r7 vDuplicates ReadOnly","")
    
    tabCtl.UseTab("Critical Dependencies")
    g.Add("Edit","xm y+5 w1050 r7 vCritDep ReadOnly","")
    
    tabCtl.UseTab("Settings")
    ctl := g.Add("CheckBox","vAutoLoad","Auto-Load most recent file on start")
    ctl.OnEvent("click","gui_events")
    ctl.Value := Settings["AutoLoad"]
    
    ColW := 525
    ctl := g.Add("Text","y+10 Section","MSVC compiler environment command.")
    ctl.SetFont("s8","Verdana")
    ctl := g.Add("Text","ys xs+" ColW,"GCC compiler environment command.")
    ctl.SetFont("s8","Verdana")
    
    g.Add("Radio","xs ys+25 vx64_MSVC_Sel Group","x64:").OnEvent("click","gui_events")
    g.Add("Radio","xs y+10 vx86_MSVC_Sel","x86:").OnEvent("click","gui_events")
    g.Add("Radio","xs+" ColW " yp-25 vx64_GCC_Sel","x64:").OnEvent("click","gui_events")
    g.Add("Radio","xs+" CoLW " y+10 vx86_GCC_Sel","x86:").OnEvent("click","gui_events")
    g[Settings["CompilerType"]].Value := 1
    
    width := 450
    g.Add("Edit","xs+45 ys+22 w" width " vx64_MSVC",Settings["x64_MSVC"]).OnEvent("change","gui_events")
    g.Add("Edit","xs+45 y+2 w" width " vx86_MSVC",Settings["x86_MSVC"]).OnEvent("change","gui_events")
    g.Add("Edit","xs+" (ColW+45) " ys+22 w" width " vx64_GCC",Settings["x64_GCC"]).OnEvent("change","gui_events")
    g.Add("Edit","xs+" (ColW+45) " y+2 w" width " vx86_GCC",Settings["x86_GCC"]).OnEvent("change","gui_events")
    
    ; g.Add("Checkbox","ys xs+700 Section vAddIncludes","Add #INCLUDES for selected constants.")
    ; g.Add("Button","xs y+5 vTestIncludes","Test Includes").OnEvent("click","gui_events")
    ; g.Add("Button","xp y+0 vUncheckAll","Uncheck All")
    
    tabCtl.UseTab()
    ctl := g.Add("Text","xm ys+70 w1050 vTotal","")
    ctl.SetFont("s8","Verdana")
    
    If (!FileExist("const_list.txt"))
        ctl.Text := "No list of constants."
    Else
        ctl.Text := "Please Wait ..."
    
    g.Show("")
    g["NameFilter"].Focus()
}

size_gui(o, MinMax, gW, gH) {
    g["ConstList"].Move(,,gW-25,gH-240)
    g["Tabs"].Move(,gH-170,gW-25)
    g["Tabs"].ReDraw()
    g["Details"].Move(,,gW-25)
    g["Duplicates"].Move(,,gW-25)
    g["CritDep"].Move(,,gW-25)
    
    ; g["Helper"].Move(,gH-190)
    g["File"].Move(,gH-190,gW-515)
    g["File"].ReDraw()
    g["Total"].Move(,gH-20,gW-25)
}

close_gui(*) {
    Settings["ApiPath"] := ""
    sText := jxon_dump(Settings,4)
    If (FileExist("settings.json"))
        FileDelete "settings.json"
    FileAppend sText, "settings.json"
    ExitApp
}

gui_events(ctl,info) { ; i, f, s, u, m, st, d ; filters
    n := ctl.Name
    If (n = "Includes") {
        incl_report()
    } Else If (n = "MoreFilters") {
        load_filters()
    } Else If (n="integer" Or n="float" Or n="string" Or n="unknown" Or n="other" Or n="expr" Or n="dupe" Or n="crit") {
        Settings["Check" n] := ctl.Value
    } Else If (n = "Reset") {
        g["NameFilter"].Value := ""
        g["ValueFilter"].Value := ""
        g["ExpFilter"].Value := ""
        g["Details"].Value := ""
        g["Duplicates"].Value := ""
        g["CritDep"].Value := ""
        g["NameBW"].Value := 0
        g["ValueEQ"].Value := 0
        g["Tabs"].Choose(1)
        
        Settings["FileFilter"] := ""
        Settings["CheckInteger"] := 1
        Settings["CheckFloat"] := 1
        Settings["CheckString"] := 1
        Settings["CheckUnknown"] := 1
        Settings["CheckOther"] := 1
        Settings["CheckExpr"] := 1
        Settings["CheckDupe"] := 0
        
        doReset := true
        relist_const()
    } Else If (n = "ConstList") {
        If (!info)
            return
        
        constName := ctl.GetText(info)
        constValue := const_list[constName]["value"]
        constType := const_list[constName]["type"]
        constExp := const_list[constName]["exp"]
        constLine := const_list[constName]["line"]
        constFile := const_list[constName]["file"]
        dupes := const_list[constName].Has("dupe")
        critDep := const_list[constName].Has("critical")
        
        g["Details"].Value := (dupes ? "Duplicate Values Exist`r`n`r`n" : "")
                            . constName " := " constValue . (IsInteger(constValue) ? "    (" Format("0x{:X}",constValue) ")`r`n" : "`r`n")
                            . "`r`nValue: " constValue "`r`nExpr:  " constExp "`r`nType:  " constType "    /    File:  " constFile "    /    Line:  " constLine
        
        g["Duplicates"].Value := ""
        If (dupes) {
            dupeStr := "", dupeArr := const_list[constName]["dupe"]
            For i, obj in dupeArr {
                dValue := obj["value"], dExp := obj["exp"]
                dLine := obj["line"], dFile := obj["file"]
                sLine := "Value: " dValue "`r`nExpr:  " dExp "`r`nFile:  " dFile "    /    Line: " dLine "`r`n`r`n"
                
                dupeStr .= sLine
            }
            dupeStr := Trim(dupeStr,"`r`n")
            g["Duplicates"].Value := dupeStr
        }
        
        g["CritDep"].Value := ""
        If (critDep) { ; item := Map("exp",constExp,"comment",comment,"file",file,"line",i,"value",vConst.value,"type",vConst.type)
            crit := const_list[constName]["critical"], critList := "Entries: " crit.Count "`r`n`r`n"
            For const, o in crit {
                critList .= const " / Type: " o["type"] " / Value: " o["value"] " / Dupes: Yes`r`n`r`n"
            }
            g["CritDep"].Value := Trim(critList,"`r`n")
        }
    } Else If (n = "NameFilterClear") {
        g["NameFilter"].Value := ""
        g["NameBW"].Value := 0
        g["NameFilter"].Focus()
    } Else If (n = "ValueFilterClear") {
        g["ValueFilter"].Value := ""
        g["ValueEQ"].Value := 0
        g["ValueFilter"].Focus()
    } Else If (n = "ExpFilterClear") {
        g["ExpFilter"].Value := ""
        g["ExpFilter"].Focus()
    } Else If (n = "FileFilterClear") {
        ctl.gui["FileFilter"].Text := ""
    } Else If (n = "FileFilter") {
        Settings["FileFilter"] := ctl.gui["FileFilter"].Text
    } Else If (n = "AutoLoad")
        Settings["AutoLoad"] := ctl.Value
    Else If (n = "AddBaseFile") {
        If (!Settings.Has("baseFiles"))
            Settings["baseFiles"] := []
        curFile := g["ApiPath"].Text
        If (!curFile)
            return
        curList := Settings["baseFiles"], success := true
        For i, file in curList {
            If (file = curFile) {
                success := false
                Break
            }
        }
        
        If (success) {
            Settings["baseFiles"].Push(curFile)
            g["ApiPath"].Delete()
            g["ApiPath"].Add(Settings["baseFiles"])
            g["ApiPath"].Text := curFile
        }
    } Else If (n = "RemBaseFile") {
        curFile := g["ApiPath"].Text
        curBase := Settings["baseFiles"], newList := []
        For i, file in curBase {
            If (file != curFile)
                newList.Push(file)
        }
        g["ApiPath"].Delete()
        g["ApiPath"].Add(newList)
        Settings["baseFiles"] := newList
        g["ApiPath"].Text := curFile
    } Else If (n="x64_MSVC_Sel" Or n="x86_MSVC_Sel" Or n="x64_GCC_Sel" Or n="x86_GCC_Sel")
        Settings["CompilerType"] := n
    Else If (n="x64_MSVC") Or (n="x86_MSVC") Or (n="x64_GCC") Or (n="x86_GCC")
        Settings[n] := ctl.Value
}

recents_menu() {
    mb_recent := menu.new(), recent_handle := mb_recent.handle
    mb_recent.Add("Clear &Recents","menu_events")
    mb_recent.Add()
    For file in Settings["baseFiles"]
        mb_recent.Add(file,"menu_events")
    
    return mb_recent
}

load_menubar(_gui) {
    mb_scan := menu.new()
    mb_scan.Add("&Scan Now","menu_events")
    mb_scan.Add()
    mb_scan.Add("Select Scan Type:","menu_events")
    mb_scan.Disable("Select Scan Type:")
    mb_scan.Add("C&ollect","menu_events","+Radio")
    mb_scan.Add("&Includes Only","menu_events","+Radio")
    mb_scan.Check(Settings["ScanType"])
    
    mb_src := menu.new()
    mb_src.Add("&Select C++ source header","menu_events")
    mb_src.Add("&Recent",recents_menu())
    mb_src.Add("&Other Files/Folders","menu_events")
    mb_src.Add()
    mb_src.Add("S&canning",mb_scan)
    
    mb_data := menu.new()
    mb_data.Add("&Load constants","menu_events")
    mb_data.Add("&Save constants","menu_events")
    
    mb_copy := menu.new()
    mb_copy.Add("Copy &selected constant details (single - CTRL+SHIFT+D)","menu_events")
    mb_copy.Add("Copy selected constant &name only (single - CTRL+D)","menu_events")
    mb_copy.Add()
    mb_copy.Add("&Copy selected constants (group)","menu_events")
    mb_copy.Add()
    mb_copy.Add("&var := value","menu_events","+Radio")
    mb_copy.Add("var &only","menu_events","+Radio")
    
    var_cpy := (Settings.Has("var_copy")) ? Settings["var_copy"] : "&var := value"
    mb_copy.Check(var_cpy)
    
    mb_compile := menu.new()
    mb_compile.Add("&Unselect all constants","menu_events")
    mb_compile.Add("&Add #INCLUDES for selected constants","menu_events")
    mb_compile.Add()
    mb_compile.Add("&Compile and test selected constants","menu_events")
    If Settings["AddIncludes"]
        mb_compile.Check("&Add #INCLUDES for selected constants")
    
    mb.Add("&Source", mb_src)
    mb.Add("&Data", mb_data)
    mb.Add("&List", mb_copy)
    mb.Add("&Compile",mb_compile)
    
    _gui.menubar := mb
    
}

menu_events(ItemName, ItemPos, _o) {
    n := ItemName
    If (n = "&Select C++ Source Header") {
        select_header(_o,n)
    } Else If (n = "C&ollect") Or (n = "&Includes Only") {
        Static scan_type := ["C&ollect","&Includes Only"] ; ,"x64 &MSVC","x86 M&SVC","x64 &GCC","x86 G&CC"]
        For typ in scan_type
            _o.Uncheck(typ)
        _o.Check(n)
        Settings["ScanType"] := n
    } Else If (n = "&Other Files/Folders") {
        If Settings["ApiPath"]
            extra_dirs()
    } Else If (n = "&Scan Now") {
        scan_now()
    } Else If (n = "&Load Constants") {
        LoadFile()
    } Else If (n = "&Save Constants") {
        SaveFile()
    } Else If (n = "&Copy Constants") {
        row := 0, txt := "", ct := StrReplace(Settings["var_copy"],"&","")
        While (row := g["ConstList"].GetNext(row)) {
            txt .= "`r`n" (const := g["ConstList"].GetText(row))
            if (ct = "var := value")
                txt .= " := " const_list[const]["value"]
        }
        
        A_Clipboard := Trim(txt,"`r`n")
        
        msgbox "List copied to clipboard."
    } Else If (n = "&var := value") Or (n = "var &only") {
        Settings["var_copy"] := n
        _o.Uncheck("&var := value"), _o.Uncheck("var &only")
        _o.Check(n)
    } Else If (n = "Clear &Recents") {
        Loop Settings["baseFiles"].Length {
            num := 2 + Settings["baseFiles"].Length - (A_Index - 1)
            _o.Delete(num "&")
        }
        Settings["baseFiles"] := []
    } Else If (_o.Handle = recent_handle) {
        select_header(_o,n)
    } Else If (n="&Unselect all constants") {
        row := 0
        While (row := g["ConstList"].GetNext(row,"C"))
            g["ConstList"].Modify(row,"-Check")
    } Else If (n="&Add #INCLUDES for selected constants") {
        Settings["AddIncludes"] := !Settings["AddIncludes"]
        _o.ToggleCheck(n)
    } Else if (n="&Compile and test selected constants") {
        If !Settings["ApiPath"] Or !FileExist(Settings["ApiPath"]) {
            Msgbox "You must select the C++ Source Header file from the Source menu."
            return
        }
        
        create_cpp_file()
        RegExMatch(Settings["CompilerType"],"^(x86|x64)_(MSVC|GCC)",m)
        
        If (IsObject(m) And m.Count() = 2) {
            If (m.Value(2) = "MSVC")
                error_check := CliData("vcvars " m.Value(1) " & cl /EHsc test_const.cpp")
            Else If (m.Value(2) = "GCC")
                error_check := CliData("msystem mingw" StrReplace(m.Value(1),"x","") " & g++ -o test_const.exe test_const.cpp")
            
            If FileExist("test_const.exe")
                result_gui( CliData("test_const.exe") )
            Else
                result_gui( "The file did not compile.`r`n`r`n===================================`r`n`r`n" error_check )
        }
    } Else if (n="Copy &selected constant details (single - CTRL+SHIFT+D)") {
        copy_const_details()
    } Else If (n="Copy selected constant &name only (single - CTRL+D)") {
        copy_const_only()
    } Else if (n="&Copy selected constants (group)") {
        copy_const_group()
    }
}

scan_now() {
    If !Settings["ApiPath"] {
        Msgbox "Select a C++ Source Header file first."
        return
    }
    
    res := MsgBox("Start scan now?`r`n`r`nThis will destroy the current list and scan the specified C++ Source Header and includes.","Confirm Scan",4)
    If (res = "no")
        return
    
    g["NameFilter"].Value := ""
    g["NameBW"].Value := 0
    g["ValueFilter"].Value := ""
    g["ValueEQ"].Value := 0
    g["ExpFilter"].Value := ""
    Settings["FileFilter"] := ""
    
    g["Details"].Value := ""
    g["Duplicates"].Value := ""
    g["CritDep"].Value := ""
    
    g["Tabs"].Choose(1)
    UnlockGui(false)
    
    g["ConstList"].Delete()
    g["Total"].Text := "Scanning header files..."
    
    root := Settings["ApiPath"]
    
    fexist := FileExist(root)
    If (!fexist) {
        Msgbox "Specify the path for the Win32 headers first."
        UnlockGui(true)
        return
    }
    
    ScanType := StrReplace(Settings["ScanType"],"&","")
    
    If (ScanType = "Collect")
        header_parser()
    Else If (ScanType = "Includes Only")
        includes_report()
    Else if InStr(ScanType,"x86") Or InStr(ScanType,"x64")
        header_parser()
    
    relist_const()
    UnlockGui(true)
}

select_header(_o,n) {
    If (n = "&Select C++ Source Header")
        selFile := FileSelect("1",,"Select C++ source header file:")
    Else selFile := n ; use recent
    
    If !selFile ; user cancels
        return
    
    SplitPath selFile,,,ext
    If (selFile) And (ext="h") {
        Settings["ApiPath"] := selFile
        If !dupe_item_check(Settings["baseFiles"],selFile)
            Settings["baseFiles"].Push(selFile)
        _o.Add("2&",recents_menu())
        g.title := "C++ Constants Scanner - " selFile
    } Else If (ext!="h")
        MsgBox "You must select a header file."
}

result_gui(txt) {
    _gui := Gui.New("-MinimizeBox -MaximizeBox +AlwaysOnTop","Compiler Output")
    _gui.OnEvent("escape","result_close")
    
    _gui.Add("Edit","w500 r10 ReadOnly",txt)
    _gui.Add("Text","","Press ESC or close to exit.")
    _gui.Add("Button","w50 yp xp+450 vClose","Close").OnEvent("click","result_close2")
    _gui.Show("")
}

result_close2(ctl,info) {
    ctl.gui.Destroy()
}

result_close(_gui) {
    _gui.Destroy()
}