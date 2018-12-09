#NoEnv
#SingleInstance Force
SetWorkingDir, %A_ScriptDir%
SetControlDelay, -1
SetBatchLines, -1

    Test := new SideMenu
    Test.AddTab("  BASIC")
    Test.AddTab("  SETTINGS")
    Test.AddTab("  VIEW")
    Test.Show(300, 150)

return ; end of auto-execute section

GuiClose:
ExitApp



;===============================================================================
class SideMenu { ; shows vertical menu on the left to switch tabarea
;===============================================================================

    ;{ class variables
    static Font := "Segoe UI Semibold"  ; font name
    static FontSize := 12               ; font size
    static ColorGui := "444444"         ; gui color background
    static ColorTab := "696969"         ; tab color background
    static ColorTxt := "CCCCCC"         ; text color
    static ColorHov := "FF8000"         ; hover color
    static TButtons := []               ; store all the Buttons
    static TButtonx := []               ;} cross over fast access

    __New() { ; SideMenu GUI
        Gui, SideMenu: New, LabelGui, SideMenu
        Gui, Color, % this.ColorGui
        Gui, Font, % "s" this.FontSize, % this.Font
        Gui, Add, Progress, % "x131 y13 w392 h178 Background" this.ColorTab
        Gui, Add, Tab2, x131 y0 w0 h0, 1|2|3
        Gui, Tab ; reset needed

        OnMessage(0x200, this.WM_MOUSEMOVE.Bind(this))
    }

    AddTab(Caption) { ; populate GUI with 'fake' Buttons and tabs
        static n := 0
        y := 23 * ++n - 10

        ; side button
        Gui, Add, Progress, % "x10 w120 h22 y" y " HWNDhProg Hidden Disabled"
            . " c" this.ColorGui " Background" this.ColorTab
        Gui, Add, Text, % "x10 w120 h22 0x200 y" y " HWNDhText"
            . " c" this.ColorTxt " BackgroundTrans", %Caption%
        this.TButtons[n] := {hProg: hProg, hText: hText, Caption: Caption}
        this.TButtonx[hText] := n
        Txt_onClick := this.SwitchTab.Bind(this)
        GuiControl, +g, %hText%, % Txt_onClick

        ; tab
        Gui, Tab, %n%
        Gui, Add, Text, x140 y16 BackgroundTrans, %Caption% ....................
        Gui, Tab ; reset needed
    }

    SwitchTab(hWnd) { ; 'fake' buttons come here
        n := this.TButtonx[hWnd]
        GuiControl, Choose, SysTabControl321, %n%

        for i, Btn in this.TButtons {
            act := Btn.Active := (i = n) ; set state
            GuiControl, % act ? "Show" : "Hide", % Btn.hProg
            GuiControl,, % Btn.hText, % Btn.Caption
        }
    }

    Show(x, y) { ; Tada
        this.SwitchTab(this.TButtons[1].hText)
        Gui, Add, Pic, x105 y10 w26 h178 BackgroundTrans, shadow.png
        Gui, Show, x%x% y%y%
    }

    WM_MOUSEMOVE() { ; mouse_move events
        static prev_Hover := ""

        _Ctrl := _hWnd := 0
        MouseGetPos,,,, _Ctrl
        GuiControlGet, _hWnd, hWnd, %_Ctrl%

        if (Hover := this.TButtonx[_hWnd]) != prev_Hover {
            prev_Hover := Hover
            for i, Btn in this.TButtons {
                showMe := (Btn.Active || i = Hover) ? "Show" : "Hide"
                GuiControl, %showMe% , % Btn.hProg
                Gui, Font, % "c" ((i = Hover) ? this.ColorHov : this.ColorTxt)
                GuiControl, Font, % Btn.hText
            }
        }
    }

} ; end of class