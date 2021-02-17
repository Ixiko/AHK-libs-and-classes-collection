/*
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
Global TME

Menus :=
( LTrim Join Comments
    {
        "Menu1": {
            "Title": "Files",
            "SubMenus": "New,Open...,Save,Save As...,,Page Setup...,Print...,,Exit"
        },

        "Menu2": {
            "Title": "Edit",
            "SubMenus": "Undo,,Cut,Copy,Paste,Delete"
        },

        "Menu3":{
            "Title": "Format",
            "SubMenus": "Font,Word Wrap"
        },

        "Menu4":{
            "Title": "View",
            "SubMenus": "Zoom,StatusBar"
        },

        "Menu5":{
            "Title": "Help",
            "SubMenus": "View Help,Send Feedback,,About Notepad"
        },

        "Icon":A_WinDir . "\system32\notepad.exe"
    }
)

new Toolbar_Class(Menus)


Gui Font, s12 c000000
Gui Add, Edit, x0 y+ w517 h365 +Multi -caption
Gui Font,

Gui Add, StatusBar,
SB_SetParts(100,100,100,100,100)
SB_SetText("Ln 1, Col 1",2)
SB_SetText("100%",3)
SB_SetText("Windows (CLRF)",4)
SB_SetText("UTF-8",5)

Gui Show, , Untitled - Notepad

Exit

MenuHandler(MenuTitle) {
    MsgBox % "User Has Clicked Menu Item: " MenuTitle
}
*/

;#######################################################################################
;################################### TOOLBAR CLASS #####################################
;#######################################################################################
;
;   Example Menu Object - Menus Created in Order of Menu No.'s ie Menu1 is Fisrt,
;   Menu2 is Second.
;
;       Menus :=
;       ( LTrim Join Comments
;           {
;               "Menu1": {
;                   "Title": "Files",
;                   "SubMenus": "New,Open...,Save,Save As...,,Page Setup...,Print...,,Exit"
;               },
;
;               "Menu2": {
;                   "Title": "Edit",
;                   "SubMenus": "Undo,,Cut,Copy,Paste,Delete"
;               },
;
;               "Icon":A_WinDir . "\system32\notepad.exe"
;           }
;       )

Class Toolbar_Class{
    __New(Menus)
    {
        Static

        Menu, Tray, Icon, % Menus["Icon"]
        Gui, +HWNDhGUI +resize +lastfound

        this.Menus  := Menus
        this.GuiObj := {}

        OnMessage(0x200, ObjBindMethod(this,"WM_MOUSEMOVE"))
        OnMessage(0x202, ObjBindMethod(this,"WM_LBUTTONUP"))
        VarSetCapacity(TME, 16, 0), NumPut(16, TME, 0), NumPut(2, TME, 4), NumPut(hGUI, TME, 8)

        This.CreateToolbar()
    }

    WM_MOUSEMOVE(wParam, lParam, Msg, Hwnd) {
        DllCall("TrackMouseEvent", "UInt", &TME)
        MouseGetPos,,,, MouseCtrl, 2

        For each, Item in this.Menus
            GuiControl, % (MouseCtrl = This.GuiObj["ButtonMenu" . This.Menus[Each]["Title"] . "T"].Handle) ? "Show" : "Hide", % This.GuiObj["ButtonMenu" . This.Menus[Each]["Title"] . "H"].Handle
    }

    WM_LBUTTONUP(wParam, lParam, Msg, Hwnd) {
        DllCall("TrackMouseEvent", "UInt", &TME)
        MouseGetPos,,,, MouseCtrl, 2

        For each, Item in this.Menus {
            If (MouseCtrl = This.GuiObj["ButtonMenu" . This.Menus[Each]["Title"] . "T"].Handle) {
                ControlGetPos, ctlX, ctlY, ctlW, ctlH,, % "ahk_id " This.GuiObj["ButtonMenu" . This.Menus[Each]["Title"] . "T"].Handle
                Menu, % each, Show, %ctlX%, % ctlY + ctlH+1
            }
        }
    }

    CreateDIB(Input, W, H, ResizeW := 0, ResizeH := 0, Gradient := 1 ) {
        _WB := Ceil((W * 3) / 2) * 2, VarSetCapacity(BMBITS, (_WB * H) + 1, 0), _P := &BMBITS
        Loop, Parse, Input, |
            _P := Numput("0x" . A_LoopField, _P + 0, 0, "UInt") - (W & 1 && Mod(A_Index * 3, W * 3) = 0 ? 0 : 1)
        hBM := DllCall("CreateBitmap", "Int", W, "Int", H, "UInt", 1, "UInt", 24, "Ptr", 0, "Ptr")
        hBM := DllCall("CopyImage", "Ptr", hBM, "UInt", 0, "Int", 0, "Int", 0, "UInt", 0x2008, "Ptr")
        DllCall("SetBitmapBits", "Ptr", hBM, "UInt", _WB * H, "Ptr", &BMBITS)
        If (Gradient != 1)
            hBM := DllCall("CopyImage", "Ptr", hBM, "UInt", 0, "Int", 0, "Int", 0, "UInt", 0x0008, "Ptr")
        return DllCall("CopyImage", "Ptr", hBM, "Int", 0, "Int", ResizeW, "Int", ResizeH, "Int", 0x200C, "UPtr")
    }

    AddControl(ControlType, Name_Control, Options := "", Function := "", Value := "", DIB := ""){
        Static
        Gui, Add, %ControlType%, HWNDh%Name_Control% v%Name_Control% %Options%, %Value%
        Handle_Control := h%Name_Control%
        This.GuiObj[Name_Control, "Handle"] := Handle_Control
        ControlHandler := Func(Function).Bind(This.GuiObj[Name_Control, "Handle"])
        GuiControl +g, %Handle_Control%, %ControlHandler%

        If (DIB != "")
            DllCall("SendMessage", "Ptr", Handle_Control, "UInt", 0x172, "Ptr", 0, "Ptr", this.CreateDIB(DIB, 1, 1))
    }

    CreateToolbar() {
        Static
        Gui, Margin, 0,0
        Gui Font, s9 cFFFFFF, Segoe UI ; Set font options
        Gui, Color, 0173C7

        loop % This.Menus.count()-1 {
            wCalc := % This.CalcTextWidth(This.Menus["Menu" A_Index]["Title"])
            this.AddControl("Picture", "ButtonMenu" . This.Menus["Menu" A_Index]["Title"] . "N", " x+ yp " wCalc " h29 Hidden0 +0x4E ", "", "","0173C7")
            this.AddControl("Picture", "ButtonMenu" . This.Menus["Menu" A_Index]["Title"] . "H", " xp yp wp hp Hidden1 +0x4E ", "", "","2A8AD4")
            this.AddControl("Text"   , "ButtonMenu" . This.Menus["Menu" A_Index]["Title"] . "T", " xp yp wp hp  +BackgroundTrans   +0x201 ","", This.Menus["Menu" A_Index]["Title"])
        }

        For each, Item in this.Menus {
            Array := StrSplit(This.Menus[each]["SubMenus"] , ",")
                Loop % Array.Length()
                    Menu, % each, Add, % Array[A_Index], MenuHandler
        }
    }

    CalcTextWidth(List, Font:="", FontSize:=09, Padding:=30) {
        X := ""
        Loop, Parse, List, |
        {
            if Font
                Gui Size:Font, s%FontSize%, %Font%

            Gui Size:Add, Text, R1, %A_LoopField%
            GuiControlGet T, Size:Pos, Static1
            Gui Size:Destroy
            TW > X ? X := TW :
        }
        return "w" X + Padding
    }
}
