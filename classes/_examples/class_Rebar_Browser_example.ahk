#NoEnv
#SingleInstance, Force
SetBatchLines, -1
Process, Priority,, High
#Include <Class_Toolbar> ; http://www.autohotkey.com/board/topic/94750-class-toolbar-create-and-modify
#Include <Class_Rebar>

Gui, +Resize
Gui, Add, Custom, ClassToolbarWindow32 hwndhToolbar x0 y0 h23 w500 0x0800 0x0100 0x0040 0x0008 0x0004
Gui, Add, Custom, ClassReBarWindow32 hwndhRebar gRB_Notifications 0x0200 0x0400 0x0040 0x8000
Gui, Add, Combobox, hwndhNavBar vNavBar, http://www.autohotkey.com||http://www.autohotkey.com/board
Gui, Add, Button, Default hwndhGo gGo, Go
Gui, Add, ActiveX, x0 y40 w980 h640 vWB, Shell.Explorer
Gui, Show, w980 h640, AHK Browser
; WB.Silent := True
GoSub, DefineToolbar

; ========== Rebar ==========

TB.Get("", "", "", "", tbBtnHeight)

RB := New Rebar(hRebar)

RB.SetImageList(IL)

RB.InsertBand(hToolbar, 0, "", 10, "", 140, 0, "", tbBtnHeight, 45, 120)
RB.InsertBand(hNavBar, 0, "", 20, "", 800)
RB.InsertBand(hGo, 0, "", 30, "", 50)

GoSub, Go
return

RB_Notifications:
If (A_GuiEvent = "N")
    If (RB.OnNotify(A_EventInfo, MX, MY, BandID))
        ShowChevronMenu(BandID, MX, MY)
Return

ShowChevronMenu(Band, X, Y)
{
    Global TB
    HidBtns := TB.GetHiddenButtons()
    Loop, % HidBtns.MaxIndex()
        Menu, TestMenu, Add, % HidBtns[A_Index].Text, % HidBtns[A_Index].Label
    Menu, TestMenu, Show, %X%, %Y%
    Menu, TestMenu, DeleteAll
}

; ========== Toolbar ==========
; http://www.autohotkey.com/board/topic/94750-class-toolbar-create-and-modify

DefineToolbar:
ILA := IL_Create(2, 2, 1)
IL_Add(ILA, "wmploc.dll", 202)
IL_Add(ILA, "wmploc.dll", 201)
IL_Add(ILA, "wmploc.dll", 154)

TB := New Toolbar(hToolbar)
TB.SetImageList(ILA)
TB.Add("", "Back=Back:1", "Forward=Forward:2", "", "Refresh=Refresh:3")
TB.SetMaxTextRows(0)
TB.SetExStyle(0x10)
OnMessage(0x111, "TB_Messages")
return

TB_Messages(wParam, lParam)
{
    Global
    TB.OnMessage(wParam)
}

; =============================

Go:
Gui, Submit, NoHide
WB.Navigate(NavBar)
IELoad(WB)
Gui, Show,, % WB.LocationName
return

Back:
WB.GoBack
IELoad(WB)
Gui, Show,, % WB.LocationName
return

Forward:
WB.GoForward
IELoad(WB)
Gui, Show,, % WB.LocationName
return

Refresh:
WB.Refresh
IELoad(WB)
Gui, Show,, % WB.LocationName
return

GuiClose:
ExitApp
return

GuiSize:
RB.ShowBand(1)
GuiControl, Move, WB, w%A_GuiWidth% h%A_GuiHeight%
return

IELoad(Pwb)
{
    If !Pwb
        Return False
    While !(Pwb.busy)
        Sleep, 100
    While (Pwb.busy)
        Sleep, 100
    While !(Pwb.document.Readystate = "Complete")
        Sleep, 100
    Return True
}