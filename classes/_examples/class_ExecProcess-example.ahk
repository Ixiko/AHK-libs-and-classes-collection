/*
              Multi-process shared functions, chain shutdown and communication

  ProcessVar := New ExecProcess("LabelName")  Create a new associated process, you can pass parameters
  ProcessVar := ""            Clear this "process variable" to close the corresponding process

  Syntax reference AHK_H to thread control, and add the function of mutual communication and mutual control between processes. Support compile and run
  New processes hide the tray icon and disable hotkeys by default to avoid conflicts. To restore hotkeys and controls, refer to F3 and F4 in the following function
*/
#Include <ExecProcess>

; Due to the closed nature of function variables, you can only determine whether to load a new process in the head of the script itself and let the new process run normally
if (A_Args[10]="ExecLabelF2")
    Goto % A_Args[10]

Process1 := New ExecProcess("ExecLabelF2", , , ,"value4") ; Open new process with passing reference

Gosub ExecLabelF2 ; Reuse shared tags and function demos
Return

ExecLabelF2:
Gui -MinimizeBox -MaximizeBox +AlwaysOnTop
Gui Add, Edit, w300 R2 vCommunicationVar gSynchronousSend
Gui Show, % "x850 w330 y" (A_Args[4]="Value4"?500:400), % (A_Args[4]="Value4"?"F2 New Process - ":"Parent - ") "Please enter text"

Loop {
    Sleep 80
    MouseGetPos, x, y
    ToolTip % (A_Args[4]="Value4"?"F2 New":"Parent") " Process -" A_Index, x+10, y-(A_Args[4]="Value4"?30:70)
}
Return

SynchronousSend:
GuiControlGet, OutputVar,, CommunicationVar
if (A_Args[4]="Value4")
    ExecPostFunction( , "GuiSynchronizedUpdate", OutputVar, "CommunicationVar") ; Leave the first parameter blank or fill in "Parent" to send a message to the main process
  else
    ExecPostFunction("ExecLabelF2", "GuiSynchronizedUpdate", OutputVar, "CommunicationVar")
Return

GuiSynchronizedUpdate(Value, ControlID) {
    GuiControl,, %ControlID%, %Value%
}

GuiClose:
    ; if (A_Args[9]="")
        ExitApp
Return

MyLabel:
    Menu Tray, Icon  ; Make new processes show icons
    ; MsgBox, , , % "var Value: " var, 1
Return

F1::
    ; ExecAssign("ExecLabelF2", "var", "123456") ; Assigning values to the variables of the new process
    ExecLabel("ExecLabelF2", "MyLabel") ; Make the new process jump to the specified label
    if (onoff := !onoff)
        ExecPause("ExecLabelF2")  ; Suspend the specified process
      else
        ExecPause("ExecLabelF2", "Off")
Return

; F2 key to do the demonstration of new process on, off, and one-touch switch
F2::
    ; Process1 := New ExecProcess("ExecLabelF2") ; New process without passing parameters
    Process1 := ""
    ; ProcessOnOff:=(Toggle:=!Toggle) ? New ExecProcess("ExecLabelF2",,,,"Value4") : ""
Return
