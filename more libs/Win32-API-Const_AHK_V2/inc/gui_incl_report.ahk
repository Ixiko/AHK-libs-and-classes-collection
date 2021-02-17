incl_report() {
    g3 := Gui.New("-MinimizeBox -MaximizeBox +Owner" g.hwnd,"#INCLUDES Report")
    g3.OnEvent("close","g3_close")
    g3.OnEvent("escape","g3_escape")
    
    g3.Add("Edit","xm w370 vFilter").OnEvent("change","gui_events3")
    g3.Add("Button","x+0 w30 vClearFilter","X").OnEvent("click","gui_events3")
    ctl := g3.Add("Edit","xm w400 h400 ReadOnly y+2 vReport")
    
    incl_report_filter()
    
    g3.Add("Button","xm y+0 w400 vCopy","Copy").OnEvent("click","gui_events3")
    
    g3.Show()
    
    WinSetEnabled False, g.hwnd
}

g3_close(_gui) {
    WinActivate "ahk_id " g.hwnd
    WinSetEnabled True, g.hwnd
}

g3_escape(_gui) {
    g3_close(_gui)
    g3.Destroy()
}

gui_events3(ctl,info) {
    If (ctl.Name = "Filter") {
        SetTimer "incl_report_filter", -500
    } Else If (ctl.Name = "ClearFilter") {
        ctl.gui["Filter"].Value := ""
        SetTimer "incl_report_filter", -500
    } Else If (ctl.Name = "Copy")
        A_Clipboard := ctl.gui["Report"].Value
}

incl_report_filter() {
    filter_txt := g3["Filter"].Value
    final_list := Map()
    
    If (filter_txt != "") {
        For incl, list in IncludesList {
            incl := StrReplace(incl,"|","\")
            SplitPath incl, inc_file
            
            If InStr(inc_file,filter_txt) {
                new_list := []
                For k, v in list {
                    SplitPath v, sub_inc
                    new_list.Push(sub_inc)
                }
                final_list[inc_file] := new_list
            } Else {
                add_list := false
                final_list[inc_file] := []
                new_list := []
                
                For k, v in list {
                    SplitPath v, sub_inc
                    
                    if InStr(sub_inc,filter_txt) {
                        add_list := true
                        new_list.Push(sub_inc " <---------- match")
                    } Else
                        new_list.Push(sub_inc)
                }
                
                If add_list
                    final_list[inc_file] := new_list
            }
            
            If !final_list[inc_file].Length
                final_list.Delete(inc_file)
        }
    } Else {
        For incl, list in IncludesList {
            incl := StrReplace(incl,"|","\")
            SplitPath incl, inc_file
            final_list[inc_file] := []
            For v in list {
                SplitPath v, sub_file
                final_list[inc_file].Push(sub_file)
            }
        }
    }
    
    rData := StrReplace(jxon_dump(final_list,4),"\\","\")
    rData := StrReplace(rData,Chr(34),"")
    g3["Report"].Value := rData
}
