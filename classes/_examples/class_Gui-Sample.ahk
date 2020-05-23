#SingleInstance, Force



; create new instance, adjust font
; SetMargins(), SetCoords(), SetPos(), SetOptions() methods are also available
TestGui := new GuiObj("MyGui")
TestGui.SetFont(12, "Arial", "cBlue")



; Add()
;
; str param1 = control type
;
; str param2 = text of the control
;
; str param3 = control options
;
; str param4 = the control's label, used to access the control's object
;              example: TestGui.Controls["Label"].SetText("sample text")
;              this parameter defaults to a 'stripped' version of the control's text
;              for example, control text of "Hello World!" would correspond to
;              a control label of "HelloWorld."  anything that is not a letter,
;              number, or underscore is stripped to create the label
;
; int param5 = specifies whether the control is a data control. see below

TestGui.Add("Text", "Hello World!", "+Section",, 0)
TestGui.Add("Edit", "MyEditField", "xs")


; AddTextField()
; creates a text control with a control of your choice directly beneath it
TestGui.AddTextField("ComboBox", "ComboBox1", "Option1|Option2", 160, "xs +Center")



; 'BindMethod' supports handling events with a class method
TestGui.Add("Button", "Activate Method", "w160 xs",, 0)
TestGui.Controls["ActivateMethod"].BindMethod(TrapCard.Activate.Bind(TrapCard))

; specify a gLabel to use a subroutine instead
TestGui.Add("Button", "Activate Subroutine", "w160 xs gTestRoutine",, 0)



; the 'Controls' property of the Gui class holds key-value pairs of all controls and their labels
for Label, CtrlObj in TestGui.Controls
    MsgBox % "Ctrl Label = " Label " | Ctrl Text = " CtrlObj.GetText()


; the 'DataControls' property holds key-value pairs of only specified controls.
; the 5th parameter of Add() specifies which controls are DataControls
; this is useful for populating only controls that normally hold data
for Label, CtrlObj in TestGui.DataControls { 
    CtrlObj.SetColor(000000, "ffffff")
    CtrlObj.SetText("data control text")
}



; Hide(), Minimize(), Activate() are also available
TestGui.SetTitle("Custom Title")
TestGui.Show()



; GetText() to retrieve control data
MsgBox % TestGui.Controls["MyEditField"].GetText()



; Focus() and IsFocused() 
TestGui.Controls["MyEditField"].Focus()
if TestGui.Controls["MyEditField"].IsFocused()
    MsgBox Focused!
else
    MsgBox Not focused!

return

#Include %A_ScriptDir%\Class_Gui.ahk
#Include %A_ScriptDir%\Class_CtlColors.ahk

class TrapCard
{
    __new(Name) { 
        This.Name := Name
    }

    Activate(CtrlHwnd, GuiEvent, EventInfo, ErrLevel:="") { 
        MsgBox % "You've really done it now.`r`nCtrlHwnd= " CtrlHwnd "`r`nGuiEvent = " GuiEvent "`r`nEventInfo = " EventInfo "`r`nErrLevel = " ErrLevel
    }
}

TestRoutine:
    MsgBox % "You've activated the test subroutine!"
return