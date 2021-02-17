extra_dirs() {
    If (!Settings.Has("dirs"))
        Settings["dirs"] := Map()
    
    root := g["ApiPath"].Text
    SplitPath root, file
    r := StrReplace(root,"\","|")
    If (!Settings["dirs"].Has(r)) {
        Settings["dirs"][r] := Map()
        Settings["dirs"][r]["files"] := []
        Settings["dirs"][r]["all"] := 0
    }
        
    other_dirs := Settings["dirs"][r]["files"]
    
    g2 := Gui.New("-DPIScale -MinimizeBox -MaximizeBox +Owner" g.hwnd,"Other Files (grouped with primary C++ Source File)")
    g2.OnEvent("close","g2_close")
    
    g2.Add("Edit","xm w560 vOtherDir")
    g2.Add("Button","x+0 w20 vAddOtherDir","+").OnEvent("click","gui_events2")
    g2.Add("Button","x+0 w20 vRemOtherDir","-").OnEvent("click","gui_events2")
    g2.Add("Listbox","xm y+5 w600 r10 vOtherDirList",other_dirs).OnEvent("doubleclick","gui_events2")
    ctl := g2.Add("Checkbox","x400 y+4 vAll","Scan all files in all specified root folders.")
    ctl.OnEvent("click","gui_events2")
    ctl.Value := Settings["dirs"][r]["all"]
    
    g2.Show()
    
    WinSetEnabled False, g.hwnd
}

gui_events2(ctl,info) {
    root := g["ApiPath"].Text
    SplitPath root, file
    r := StrReplace(root,"\","|")
    other_dirs := Settings["dirs"][r]["files"]
    If (ctl.Name = "AddOtherDir" And ctl.gui["OtherDir"].Value) {
        v := ctl.gui["OtherDir"].Value
        
        ctl.gui["OtherDirList"].Add([v]), other_dirs.Push(v)
        ctl.gui["OtherDir"].Value := ""
    } Else If (ctl.Name = "RemOtherDir" And ctl.gui["OtherDirList"].Value) {
        v := ctl.gui["OtherDirList"].Value
        ctl.gui["OtherDirList"].Delete(v), other_dirs.RemoveAt(v)
    } Else If (ctl.Name = "OtherDirList" And ctl.Value) {
        v := ctl.Value
        ctl.Delete(v), other_dirs.RemoveAt(v)
    } Else If (ctl.Name = "All")
        Settings["dirs"][r]["all"] := ctl.gui["All"].Value
    Settings["dirs"][r]["files"] := other_dirs
}

g2_close(g2) {
    WinSetEnabled True, g.hwnd
}