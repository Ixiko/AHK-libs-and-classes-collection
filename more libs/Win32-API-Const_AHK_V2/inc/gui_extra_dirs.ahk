extra_dirs() {
    If (!Settings.Has("dirs"))
        Settings["dirs"] := Map()
    
    root := Settings["ApiPath"]
    
    If !root {
        Msgbox "You must select a C++ Source Header first."
        return
    } Else If !FileExist(root) {
        Msgbox "Selected C++ Source Header file doesn't exist."
        return
    }
    
    SplitPath root, file
    r := StrReplace(root,"\","|")
    If (!Settings["dirs"].Has(r))
        Settings["dirs"][r] := Map("files",[])
        
    other_dirs := Settings["dirs"][r]["files"]
    
    g2 := Gui.New("-MinimizeBox -MaximizeBox +Owner" g.hwnd,"Other Files (grouped with primary C++ Source File)")
    g2.OnEvent("close","g2_close")
    g2.OnEvent("escape","g2_escape")
    
    g2.Add("Edit","xm r3 w560 vOtherDir")
    g2.Add("Button","x+0 w40 h47 vAddOtherDir","Add").OnEvent("click","gui_events2")
    
    g2.Add("Text","xm yp+55 w100 Right","Search:")
    g2.Add("Edit","x+5 yp-4 w465 vSearch").OnEvent("change","gui_events2")
    g2.Add("Button","x+0 vClearSearch w30","X").OnEvent("click","gui_events2")
    
    g2.Add("Listbox","xm y+5 w600 r10 vOtherDirList Multi Sort",other_dirs).OnEvent("doubleclick","gui_events2")
    
    msg := "Add one file per line above.`r`n`r`nDefine extra files, file patterns, or directories to scan.`r`n`r`n"
         . "    Files (full path):  X:\folder\folder\file.h`r`n"
         . "    Files (no path):    file.h (these entries will trigger a search)`r`n"
         . "    File Pattern:       X:\folder\file*.h`r`n"
         . "    Directory:          x:\folder\folder\*.h   (recursive)"
    
    g2.Add("Button","xm+550 y+5 w50 vRemOtherDir","Remove").OnEvent("click","gui_events2")
    ctl := g2.Add("Text","xm yp w550 h130", msg)
    ctl.SetFont("s10","Consolas")
    
    g2.Show()
    
    WinSetEnabled False, g.hwnd
}

gui_events2(ctl,info) {
    root := Settings["ApiPath"]
    SplitPath root, file
    r := StrReplace(root,"\","|")
    other_dirs := Settings["dirs"][r]["files"]
    
    If (ctl.Name = "AddOtherDir" And ctl.gui["OtherDir"].Value) {
        v := Trim(StrReplace(ctl.gui["OtherDir"].Value,Chr(34),""),"`r`n`t ")
        a := StrSplit(v,"`n","`r")
        
        ctl.gui["OtherDirList"].Opt("-Redraw")
        For path in a {
            path := Trim(path,"`t ")
            ; (!FileExist(path)) ? path := get_full_path(path) : ""   ; file not found, parse main folder, and one folder higher
            
            If (path And !dupe_item_check(other_dirs,path))    ; check for dupe and .Push() to other_dirs
                other_dirs.Push(path), ctl.gui["OtherDirList"].Add([path])
        }
        ctl.gui["OtherDirList"].Opt("Sort")
        ctl.gui["OtherDirList"].Opt("+Redraw")
        ctl.gui["OtherDir"].Value := ""
        ctl.gui["OtherDir"].Focus()
    } Else If (ctl.Name = "RemOtherDir" And ctl.gui["OtherDirList"].Value) {
        v := ctl.gui["OtherDirList"].Value
        Loop v.Length {
            idx := v[v.Length - (A_Index - 1)]
            other_dirs.RemoveAt(idx)
            ctl.Gui["OtherDirList"].Delete(idx)
        }
        
        If (v[v.Length] <= other_dirs.Length)
            ctl.gui["OtherDirList"].Choose(v[v.Length])
        Else
            ctl.gui["OtherDirList"].Choose(other_dirs.Length)
        
        ctl.gui["OtherDir"].Focus()
    } Else If (ctl.Name = "OtherDirList" And ctl.Value)
        ctl.Delete(ctl.Value), other_dirs.RemoveAt(ctl.Value)
    Else If (ctl.Name = "Search") {
        ctl.gui["OtherDirList"].Opt("-Redraw")
        ctl.gui["OtherDirList"].Delete()
        For path in other_dirs {
            If ((ctl.Value != "") And InStr(path,ctl.Value)) Or (ctl.Value = "")
                ctl.gui["OtherDirList"].Add([path])
        }
        ctl.gui["OtherDirList"].Opt("+Redraw")
    } Else If (ctl.Name = "ClearSearch") {
        ctl.gui["Search"].Value := ""
        ctl.gui["OtherDirList"].Opt("-Redraw")
        ctl.gui["OtherDirList"].Delete()
            For path in other_dirs
                ctl.gui["OtherDirList"].Add(path)
        ctl.gui["OtherDirList"].Opt("+Redraw")
    }
    
    Settings["dirs"][r]["files"] := other_dirs
}

g2_close(g2) {
    WinActivate "ahk_id " g.hwnd
    WinSetEnabled True, g.hwnd
    g["NameFilter"].Focus()
}

g2_escape(g2) {
    g2_close(g2)
    g2.Destroy()
}