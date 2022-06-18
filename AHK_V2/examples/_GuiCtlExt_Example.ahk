; AHK v2
#INCLUDE _GuiCtlExt.ahk
#Include _JXON.ahk

Global g

IL := IL_Create(2)
IL_Add(IL, "shell32.dll", 128)
IL_Add(IL, "shell32.dll", 129)
IL_Add(IL, "shell32.dll", 256)

g := Gui("-MinimizeBox -MaximizeBox","Test")
g.OnEvent("close",gui_close)
g.OnEvent("escape",gui_close)
ctl := g.Add("ListView","+Report w210 h100 vLV Checked Icon2",["test"])
ctl.SetImageList(IL,1)
ctl.Add("check Icon3","Row1"), hwnd := ctl.hwnd
ctl.Add("icon1","Row2")
ctl.Opt("+Report")
ctl.ModifyCol()

g.Add("ListBox","w100 h100 vLB",["ListBox Item 1","ListBox Item 2","ListBox Item 3"])
ctl := g.Add("ComboBox","x+10 yp w150 h100 vCB Section",["ComboBox Item 1","ComboBox Item 2","ComboBox Item 3","ComboBox Item 4","AutoC Test"])
ctl.CueText := "Test Cue Text"
ctl.AutoComplete := true
ctl.Text := "abcdefg"
ctl.SetSel(1,3) ; set selection

btn := g.AddPicButton("vPicBtn w50 h24","netshell.dll","Icon151 w20 h20","Test") ; 24 x 24
btn.OnEvent("click",gui_events)

btn := g.Add("Button","vData x+0","Show Data")
btn.OnEvent("Click",gui_events)

btn := g.AddSplitButton("vDropBtn1 xs h32 w80","Test",gui_events) ; here the callback is only for clicking the split down arrow
btn.OnEvent("click",gui_events) ; this is for when you click the "normal" part of the button
btn.SetImg("netshell.dll","Icon151 w20 h20")

btn := g.AddToggleButton("vToggleBtn w80 h32","Test")   ; Icons+Text on a ToggleButton don't seem to work with native AHK gui.
btn.OnEvent("click",gui_events)                         ; Remove button text to get a ToggleButton with an icon.
btn.SetImg("netshell.dll","Icon151 w20 h20")            ; Maybe a different combo of buttons styles will work?

ctl := g.Add("Edit","xm w200 vMyEdit1")
ctl.CueText[true] := "Test Cue Edit Text"
; ctl.CueText("blah blah",1)
ctl.Value := "abcdefg"
ctl.SetCueText("Test Cue Edit Text",true) ; set/change option of cue to persist on control focus (instead of disappear)
                                          ; ctl.CueText also works with edit control

g.show("h300 w300")

gui_close(*) {
    ExitApp
}

gui_events(ctl, info) {
    Global g
    
    If (ctl.name = "DropBtn1") && IsObject(info) {
        m(info)
    } Else If (ctl.name = "DropBtn1") {
        msgbox "You clicked the button portion of the drop button.`r`n`r`nTry clicking the arrow."
    } Else If (ctl.Name = "PicBtn")
        msgbox "You clicked the pic btn."
    Else If (ctl.name = "Data") {
        LVr := 1, LBr := 2, CBr := 3, LBi := "", CBi := ""
        
        For item in g["LB"].GetItems()
            LBi .= (LBi?"`r`n`t":"`t") item 
        
        For item in g["CB"].GetItems()
            CBi .= (CBi?"`r`n`t":"`t") item 
        
        MsgBox "ListView`r`n`r`n"
             . "`tIconIndex Row " LVr ": " g["LV"].IconIndex(LVr) "`r`n"
             . "`tChecked Row " LVr ": " (g["LV"].Checked(LVr)?"true":"false") "`r`n"
             . "`trow count: " g["LV"].GetCount() "`r`n"
             . "`tsecond row text:  " g["LV"].GetText(2) "`r`n`r`n" ; original LV.GetText() still works as expected
             
             . "ListBox`r`n`r`n"
             . "`tItemText Row " LBr ": " g["LB"].GetText(LBr) "`r`n" ; .GetText() method added to ListBox
             . "`tRow Count: " g["LB"].GetCount() "`r`n`r`n"
             . "`tItems:`r`n" LBI "`r`n`r`n"
             
             . "ComboBox`r`n`r`n"
             . "`tItemText Row " CBr ": " g["CB"].GetText(CBr) "`r`n"
             . "`tRow Count: " g["CB"].GetCount() "`r`n`r`n"
             . "`tItems:`r`n" CBi
    } Else If (ctl.name = "ToggleBtn") {
        Msgbox "Value: " ctl.Value
    }
}

m(coords) {
    me := Menu()
    me.Add("Item 1",m_event)
    me.Add("Item 2",m_event)
    me.Show(coords.x, coords.y)
}

m_event(item, pos, m) {
    msgbox "You clicked: " item
}

dbg(_in) { ; AHK v2
    Loop Parse _in, "`n", "`r"
        OutputDebug "AHK: " A_LoopField
}

F2::{
    Global g
    g["MyEdit1"].CueText := "Change the cue!"
    g["MyEdit1"].SetSel(3,5)
}
F3::{
    Global g
    g["MyEdit1"].SetSel()
}
F4::{
    Global g
    msgbox g["CB"].SelText
}
F5::{
    Global g
    ; dbg( g["CB"].CaretPos )
    g["CB"].SetSel(-1)
}

