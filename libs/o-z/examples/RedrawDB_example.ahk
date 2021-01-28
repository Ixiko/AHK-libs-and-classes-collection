#SingleInstance force
#NoEnv
#Include %A_ScriptDir%\..\RedrawDB.ahk
SetBatchLines -1
SetControlDelay, -1
SetWinDelay, -1

Gui 1: +Resize +hwndGUI1
Gui 1:add, CheckBox, vDB, Double Buffering
Gui 1:Add, Radio, x+0 vMode, #1 - WS_Visible
Gui 1:Add, Radio, y+0 , #2 - LockWindowUpdate
Gui 1:Add, Radio, y+0 Checked, #3 - WM_SETREDRAW (recomm)

Gui 1:Add, Tab2, xm r20  vTAB hwndh_TAB, General|Preview|Source|SETTINGS
Gui 1:Add, ListView, x+2 y+2 r20  altsubmit  hwndLVX vMyListView  Grid +LV0x10000 +LV0x2 +LV0x40 Count10000 , #|Layer|Start|(*)|DUR|CPS|End|Style|Name|MarginL|MarginR|MarginV|Effect|Text
loop 100
LV_Add("", "zzzdfsdfsdf", "yyy" A_Index,"xxx")

gui, 1:show

GuiSize:
; critical 1000 ; <---------- try experiment with that
if A_EventInfo = 1
    return
Gui, 1: Submit , NoHide
tooltip,% "Double Buffering: " (DB?"Enabled":"Disabled") "`nMode: " Mode
    
    If DB ; Disable drawing
    {
        If Mode = 1
            Gui, 1: -0x10000000 ; WS_Visible ; Mode #1
        If Mode = 2
            DllCall("LockWindowUpdate", "Ptr", gui1) ; Mode #2
        If Mode = 3
            DllCall("SendMessage", "Ptr",gui1, "UInt",0xB, "UInt",0, "UInt",0) ; Mode #3
        
    }
    
    GuiControl, Move, tab,    % "W" . (A_GuiWidth-22) . "H" . (A_GuiHeight-62)
    GuiControl, Move, MyListView,    % "W" . (A_GuiWidth-32) . "H" . (A_GuiHeight-92)
    
    If DB ; Enable drawing
    {
        If Mode = 1
            Gui, 1: +0x10000000 ; WS_Visible  ; Mode #1
        If Mode = 2
            DllCall("LockWindowUpdate", "Ptr", "") ; Mode #2
        If Mode = 3
            DllCall("SendMessage", "Ptr",gui1, "UInt",0xB, "UInt",1, "UInt",0) ; Mode #3
    }
    
If DB
    RedrawDB(gui1) ; <------------------- Redraw window. Unomment this line to Enable Double Buffering
return

f4::reload

GuiClose:
ExitApp
Return