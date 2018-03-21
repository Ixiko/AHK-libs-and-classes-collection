; ST - Stack Library by Banane
; http://www.autohotkey.com/forum/viewtopic.php?t=54153

;-----------------------------------------------------------------------------------------------------------------------------
;Function:    ST_Dim
;Parameters:  Stack = Specify a new variable
;Description: Declares the specified variable as a stack
;-----------------------------------------------------------------------------------------------------------------------------
ST_Dim(ByRef Stack) {
  If (ST_IsValid(Stack,1) = 1) {
    If (ST_Debug() = 1)
      MsgBox, 48, ST Error, Specified Stack is already declared.
    Return 0
  }
  Stack :="[]"
}


;-----------------------------------------------------------------------------------------------------------------------------
;Function:    ST_Undim
;Parameters:  Stack = Declared Stack
;Description: Deletes all contents from the stack variable
;-----------------------------------------------------------------------------------------------------------------------------
ST_Undim(ByRef Stack) {
  If (ST_IsValid(Stack) = 0)
    Return 0
  Stack := ""
}

;-----------------------------------------------------------------------------------------------------------------------------
;Function:    ST_Del
;Parameters:  Stack = Declared Stack
;Description: Deletes all entrys from the stack
;-----------------------------------------------------------------------------------------------------------------------------
ST_Del(ByRef Stack) {
  If (ST_IsValid(Stack) = 0)
    Return 0
  Stack := "[]"
}

;-----------------------------------------------------------------------------------------------------------------------------
;Function:    ST_Push
;Parameters:  Stack = Declared Stack
              Value = Entry's value
;Description: Adds an entry to the stack
;-----------------------------------------------------------------------------------------------------------------------------
ST_Push(ByRef Stack,Value) {
  ;Check if it's a valid stack
  If (ST_IsValid(Stack) = 0)
    Return 0
  ;Add the value
  Stack := "[" . ST_Convert(Value) . "|" . SubStr(Stack,2,StrLen(Stack) - 2) . "]"
}

;-----------------------------------------------------------------------------------------------------------------------------
;Function:    ST_Pop
;Parameters:  Stack = Declared Stack
;Description: Removes and returns the newest entrys contents
;-----------------------------------------------------------------------------------------------------------------------------
ST_Pop(ByRef Stack) {
  ;Check if it's a valid stack
  If (ST_IsValid(Stack) = 0)
    Return 0
  Else If (ST_Len(Stack) < 1)
    Return 1
  ;Get first entry
  Value := SubStr(Stack,2,InStr(Stack,"|") - 2)
  ;Remove from stack
  Stack := "[" . SubStr(Stack,InStr(Stack,"|") + 1,StrLen(Stack))
  Return ST_Convert(Value,1)
}

;-----------------------------------------------------------------------------------------------------------------------------
;Function:    ST_Peek
;Parameters:  Stack = Declared Stack
;Description: Returns the newest entrys contents without removing
;-----------------------------------------------------------------------------------------------------------------------------
ST_Peek(ByRef Stack) {
  ;Check if it's a valid stack
  If (ST_IsValid(Stack) = 0)
    Return 0
  Else If (ST_Len(Stack) < 1)
    Return 1
  ;Return first entry
  Return ST_Convert(SubStr(Stack,2,InStr(Stack,"|") - 2),1)
}

;-----------------------------------------------------------------------------------------------------------------------------
;Function:    ST_Len
;Parameters:  Stack = Declared Stack
;Description: Returns the count of entrys
;-----------------------------------------------------------------------------------------------------------------------------
ST_Len(ByRef Stack) {
  ;Check if it's a valid stack
  If (ST_IsValid(Stack) = 0)
    Return 0
  ;Check how many entrys are in it
  Loop, Parse, Stack
    If (A_LoopField = "|")
      Length ++
  ;If Stack doesn't have any entrys
  If (ST_Debug() = 1 and Length = "")
    MsgBox, 48, ST Error, Specified Stack doesn't have any entrys.
  ;Return the length
  Return Length
}

;-----------------------------------------------------------------------------------------------------------------------------
;Function:    ST_Debug
;Parameters:  OnOff = Boolean - 1 to activate, 0 to deactivate
;Description: Actiavtes error messages
;-----------------------------------------------------------------------------------------------------------------------------
ST_Debug(OnOff="") {
 static Debug

  ;Change Debug State
  Debug := (OnOff = "") ? Debug : OnOff
  ;Return Debug State
  Return Debug
}

;=============================================================================================================================
;Internal Functions
;=============================================================================================================================
ST_Convert(Value,Mode=0) {
  ;Mode 0 = Convert to Stack Format
  ;Mode 1 = Convert from Stack Format
  If (Mode = 0)
    StringReplace, Value, Value, |, <'D'>, 1 ;Replace Delimiter
  Else
    StringReplace, Value, Value, <'D'>, |, 1 ;Change to Delimiter
  Return Value
}

ST_IsValid(ByRef Stack,Dim=0) {
  If (SubStr(Stack,1,1) = "[" and SubStr(Stack,StrLen(Stack),1) = "]")
    Return 1
  If (ST_Debug() = 1 and Dim = 0)
    MsgBox, 48, ST Error, Specified Stack isn't valid.
  Return 0
}