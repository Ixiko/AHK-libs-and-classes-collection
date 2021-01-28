#NoEnv
#SingleInstance Force
gui 1:-DPIScale +LastFound +Resize +LabelForm1_
gui,1:Show,w400 h300,Form1
hForm1 :=WinExist()

gui 2:+LastFound +Resize +ToolWindow -Sysmenu
gui 2:Add,Button,gOnButton,Toggle dock
gui 2:Show,w300 h200,Form2
hForm2 :=WinExist()

DockA(hForm1,hForm2,"x(1) y() h(1)")
DockA(hForm1)
bDockOn :=1

ShowForms(true)
return

Form1_Size:
DockA(hForm1)
return


Form1_Escape:
Form1_Close:
ShowForms(False)
ExitApp
return


OnButton:
if (bDockOn)
    DockA(hForm1,hForm2,"-")
else
    DockA(hForm1,hForm2)

bDockOn :=!bDockOn
return


ShowForms(BShow)
    {
    global

    if BShow
        DockA(hForm1)

    Loop 2
        if BShow
            gui %A_Index%:Show
         else
            gui %A_Index%:Hide
    }


F1:: ShowForms(true)

#include DockA.ahk