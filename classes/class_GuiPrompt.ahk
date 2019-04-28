/**

Class:
    GuiPrompt.ahk - Utility class for making prompts

Version: 
    v1.0.0

Requirements:
    AutoHotkey v1.1.21.00+

Usage:
    prompt := new GuiPrompt({ promptTitle: "PDF Splitter" })
    prompt.AddInput({ textLabel: "How many pages per PDF?"
     , variable: "amountInput" })
     
    inputResult := prompt.Show()

    if (inputResult) {
     msgBox % inputResult["amountInput"]
    } else {
     msgBox % "User canceled"
    }

Links:
    Github - https://github.com/sidola/AHK-Utils

*/
class GuiPrompt {

    __New(optionObject) {
        this.promptTitle := optionObject.promptTitle
        this.promptText := optionObject.promptText

        this.elements := []
    }

    /**
     * Adds an input to the prompt.
     * 
     * @param optionObject 
     *        An object containing the following properties:
     *        - textLabel, The field label
     *        - variable, The field variable
     *        - value (optional), An initial value
     */
    AddInput(optionObject) {
        this.elements.Push(optionObject)
    }

    /**
     * Shows the prompt and blocks the current thread.
     *
     * When done, returns either an empty var if the user canceled,
     * or an object containing key/value pairs of the input.
     */
    Show() {
        guiMargin := 10
        innerGuiWidth := 200
        outerGuiWidth := innerGuiWidth + (guiMargin * 2)

        Gui, GuiPrompt:New, +LastFound +Border -SysMenu
        Gui, Margin, %guiMargin%, %guiMargin%
        Gui, Font, s9, Segoe UI ; Set Windows default Font

        if (this.promptText) {
            Gui, Add, Text, w%innerGuiWidth%, % this.promptText
        }

        for k, options in this.elements {
            editVar := options.variable

            Gui, Add, Text,, % options.textLabel
            Gui, Add, Edit, w%innerGuiWidth% Hwnd%editVar%, % options.value

            options.hwnd := %editVar%
        }
        
        Gui, Add, Button, w95 HwndOkBtn Section, OK
        Gui, Add, Button, w95 HwndCancelBtn ys Default, Cancel

        onOkFunc := ObjBindMethod(this, "OnOk")
        onCancelFunc := ObjBindMethod(this, "OnCancel")

        GuiControl +g, %OkBtn%, % onOkFunc
        GuiControl +g, %CancelBtn%, % onCancelFunc

        Gui, Show, w%outerGuiWidth%, % this.promptTitle

        ; "Threading" magic Pt. 1
        Pause, On
        Gui, Destroy

        return this.inputResult
    }

    ; ----------------------------------
    ; Private API
    ; ----------------------------------

    OnOk() {
        this.inputResult := {}

        for k, options in this.elements {
            hwnd := options.hwnd
            GuiControlGet, editOutput,, %hwnd%
           
            this.inputResult[options.variable] := editOutput
        }

        ; "Threading" magic Pt. 2
        Pause, Off
    }

    OnCancel() {
        this.inputResult := ""

        ; "Threading" magic Pt. 2
        Pause, Off   
    }

}