; #Include st.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

;Declare our new stack
ST_Dim(Script)

;Create our sample gui, which adds entrys to the stack
Gui, 1:+ToolWindow

  Gui, 1:Add, Edit, x5 y5 w350 h20 vEdit
  Gui, 1:Add, Edit, x5 y30 w350 h65 +ReadOnly vAll
  Gui, 1:Add, Text, x5 y105 w100 h15 vCount
  Gui, 1:Add, Button, x250 y105 w50 h20 gRun, Show
  Gui, 1:Add, Button, x305 y105 w50 h20 gAdd, Add

  Gui, 1:Show, w360 h130, Stack Example
  Return

Add:
  ;Retrieve edit content
  GuiControlGet, Edit, 1:
  ;Clear edit
  GuiControl, 1:, Edit,
  ;Add to stack
  ST_Push(Script,Edit)
  ;Update count text
  GuiControl, 1:, Count, % ST_Len(Script)
  Return

Run:
  ;Loop trough the stack
  Loop, % ST_Len(Script) {
    ;Retrieve current contents
    GuiControlGet, All, 1:
    ;Add new value to old contents
    GuiControl, 1:, All, % All . ST_Pop(Script) . "`n"
    ;Update count text
    GuiControl, 1:, Count, % ST_Len(Script)
  }
  Return

GuiClose:
  ExitApp