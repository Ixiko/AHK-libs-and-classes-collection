incl_report() {
    g3 := Gui.New("-DPIScale -MinimizeBox -MaximizeBox +Owner" g.hwnd,"#INCLUDES Report")
    g3.OnEvent("close","g3_close")
    
    g3.Add("Edit","xm w370 vFilter").OnEvent("change","gui_events3")
    g3.Add("Button","x+0 w30 vClearFilter","X").OnEvent("click","gui_events3")
    ctl := g3.Add("Edit","xm w400 h400 ReadOnly y+2 vReport")
    rData := StrReplace(jxon_dump(IncludesList,4),"\\","\")
    rData := StrReplace(rData,Chr(34),"")
    ctl.Value := rData
    g3.Add("Button","xm y+0 w400 vCopy","Copy").OnEvent("click","gui_events3")
    
    g3.Show()
    
    WinSetEnabled False, g.hwnd
}

g3_close(*) {
    WinSetEnabled True, g.hwnd
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
    (filter_txt != "") ? final_list := Map() : final_list := IncludesList
    
    If (filter_txt != "") {
        For incl, list in IncludesList {
            If InStr(incl,filter_txt)
                final_list[incl] := list
            Else {
                For k, v in list {
                    if InStr(v,filter_txt) {
                        final_list[incl] := list
                        Break
                    }
                }
            }
        }
    }
    
    rData := StrReplace(jxon_dump(final_list,4),"\\","\")
    rData := StrReplace(rData,Chr(34),"")
    g3["Report"].Value := rData
}
