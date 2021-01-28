;------------------------------------------------------------------------------------------------------------------------------------
;Function:     Progress_Add
;Parameters:   Gui      = Gui Number
;              Position = The progressbar's position within the gui, x y w h, like the standard controls
;              Range    = The value's range, default is 0 to 100
;              Value    = The progressbar's start value, default is 0
;              Text     = The text to show on top of the progressbar, may contain any of the following "variables:"
;                         $Percent  - Replaced with the progressbar's percent value
;                         $Range    - Replaced with the progressbar's range (the highest possible value)
;                         $Position - Replaced with the progressbar's current position
;                         Text is only valid and added if Vertical=0
;              Vertical = If this value is 1 a vertical progressbar will be created
;Return Value: Handle for all other functions
;------------------------------------------------------------------------------------------------------------------------------------
Progress_Add(Gui,Position,Range="0-100",Value=0,Text="",Vertical=0) {
 global
 static Progress_Count
 local File1,File2,PosX,PosY,PosW,PosH,Handle

  ;Parse through the positions
  Loop, Parse, Position, % A_Space, % A_Space
    N := SubStr(A_LoopField,1,1),Pos%N% := SubStr(A_LoopField,2,StrLen(A_LoopField))
  ;Retrieve the last set graphics
  File1 := Progress_SetFile("@Get"),File2 := Progress_SetFile("","@Get")

  ;If the graphics don't exist, or the position is incomplete, indicate the error
  If (!PosX || !PosY || !PosW || !PosH || !InStr(Range,"-") || !FileExist(File1) || !FileExist(File2))
    Return 0
  ;Increase the count of added progressbars
  Progress_Count ++
  ;Create the bar graphics and add them onto the gui
  If (Vertical = 0) {
    ;Create the handle to this progressbar
    Handle := Gui "|" Value "|" Range "|" PosW "|" Progress_Count "|" Vertical "|" Text "|" File1 "|" File2
    Gui, % Gui ":Add", Picture, % "x" PosX " y" PosY " w" PosW " h" PosH " +BackgroundTrans vPBar_" Gui "_" Progress_Count "N", % File1
    Gui, % Gui ":Add", Picture, % "x" PosX " y" PosY " w1 h" PosH " +BackgroundTrans vPBar_" Gui "_" Progress_Count "R", % File2
    If (Text != "")
      Gui, %Gui%:Add, Text, x%PosX% y%PosY% w%PosW% h%PosH% +BackgroundTrans +Center +0x200 vPBar_%Gui%_%Progress_Count%T
  } Else {
    ;Create the handle to this progressbar
    Handle := Gui "|" Value "|" Range "|" PosH "|" Progress_Count "|" Vertical "||" File1 "|" File2
    Gui, % Gui ":Add", Picture, % "x" PosX " y" PosY " w" PosW "h "PosH " +BackgroundTrans vPBar_" Gui "_" Progress_Count "N", % File1
    Gui, % Gui ":Add", Picture, % "x" PosX " y" PosY " w" PosW "h1 +BackgroundTrans vPBar_" Gui "_" Progress_Count "R", % File2
  }
  ;Apply the starting value
  Progress_Set(Handle,Value),Progress_SetText(Handle)
  ;Return all values as a handle
  Return Handle
}

;------------------------------------------------------------------------------------------------------------------------------------
;Function:     Progress_Get
;Parameters:   ID   = The handle returned by Progress_Add
;              Type = "Position" or "1" to retrieve the current value / position
;                     "Percent" or "2" to retrieve the percent of the current value / position
;                     "Range" or "3" to retrieve the range (highest possible value)
;                     "Visibility" or "4" to retrieve the progressbars visibility (Boolean)
;                     "Text" or "5" to retrieve the progressbars current text, if there's any
;Return Value: Depends on the used Type
;------------------------------------------------------------------------------------------------------------------------------------
Progress_Get(ByRef ID,Type=1) {
  ;Retrieve every value from the handle
  Loop, Parse, ID, |
    PB%A_Index% := A_LoopField
  ;Only retrieve the endvalue of the range
  PB3 := SubStr(PB3,InStr(PB3,"-") + 1,StrLen(PB3))
  ;Return the position or percent, based on the passed type
  If (Type = "Position" || Type = 1)
    Out := PB2
  Else If (Type = "Percent" || Type = 2)
    Out := Round(PB2 / PB3 * 100)
  Else If (Type = "Range" || Type = 3)
    Out := PB3
  Else If (Type = "Visibility" || Type = 4)
    GuiControlGet, Out, Visible, PBar_%PB1%_%PB5%R
  Else If (Type = "Text" || Type = 5)
    Out := PB7
  Else If (Type = "BackgroundImage" || Type = 6)
    Out := PB8
  Else If (Type = "ProgressImage" || Type = 7)
    Out := PB9
  Return Out
}

;------------------------------------------------------------------------------------------------------------------------------------
;Function:     Progress_Set
;Parameters:   ID    = The handle returned by Progress_Add
;              Value = The new value / position of the progressbar, if Range=0, you may use + - operators (+10, -5,...,...)
;              Range = If this value is equal to one, not the value / position will be set, but the range (highest possible value)
;Return Value: 0 - Invalid handle
;------------------------------------------------------------------------------------------------------------------------------------
Progress_Set(ByRef ID,Value,Range=0) {
  ;Retrieve every value from the handle
  Loop, Parse, ID, |
    PB%A_Index% := A_LoopField
  ;Break if any of the neccessary values isn't set
  If ((Range = 0 && Value = PB2) || (Range != 0 && Value = PB3) || (PB1 = "" || PB3 = "" || PB4 = "" || PB5 = ""))
    Return 0
  ;If Range is set to one, then set the value range to the passed value
  If (Range = 1)
    PB3 := Value,Value := PB2
  ;If Range is set to zero, then also recognize the + - operators
  Else
    ;Check if value was passed with an operator
    If (SubStr(Value,1,1) = "+")
      Value := PB2 + SubStr(Value,2,StrLen(Value))
    Else If (SubStr(Value,1,1) = "-")
      Value := PB2 - SubStr(Value,2,StrLen(Value))
  ;Split the start and end range value
  Start := SubStr(PB3,1,InStr(PB3,"-") - 1)
  End   := SubStr(PB3,InStr(PB3,"-") + 1,StrLen(PB3))
  ;If the value is higher than the range, use the range, and if it's lower than 0, use 0
  Value := (Value > End) ? End : (Value < Start) ? Start : Value
  ;Calculate the current percent
  Percent  := Value / End * 100
  ;Calculate and apply the new size
  If (PB6 = 0)
    GuiControl, % PB1 ":Move", % "PBar_" PB1 "_" PB5 "R", % "w" PB4 * Percent / 100
  Else GuiControl, % PB1 ":Move", % "PBar_" PB1 "_" PB5 "R", % "h" PB4 * Percent / 100
  ;Update the handles content
  ID := PB1 "|" Value "|" PB3 "|" PB4 "|" PB5 "|" PB6 "|" PB7 "|" PB8 "|" PB9
  Progress_SetText(ID)
  ;If new range was set, apply the value again
  If (Range = 1)
    Progress_Set(Handle,Value)
  Return 1
}

;------------------------------------------------------------------------------------------------------------------------------------
;Function:     Progress_SetFile
;Parameters:   Background = Path to the new background picture, or @Get to retrieve the current path
;              Progress   = Path to the new progress picture, or @Get to retrieve the current path
;              ID         = If this parameter is empty, the specified images only count for progressbars that are added afterwards
;                           Otherwise, the images of the specified progressbar will be changed
;Return Value: Depends on the parameters
;------------------------------------------------------------------------------------------------------------------------------------
Progress_SetFile(Background="",Progress="",ByRef ID="") {
 static Progress_File1,Progress_File2

  ;ID was passed, that means the functions needs to update an existing progessbar
  If (ID) {
    ;Retrieve every value from the handle
    Loop, Parse, ID, |
      PB%A_Index% := A_LoopField
    ;Invalid ID - GUI number or Progressbar Index is missing
    If (!PB1 || !PB5)
      Return 0
    ;Update the file paths within the id
    ID := PB1 "|" Value "|" PB3 "|" PB4 "|" PB5 "|" PB6 "|" PB7 "|" Background "|" Progress
  }

  ;If existing background picture passed, store or apply it
  If (FileExist(Background))
    If (!ID)
      Progress_File1 := Background
    Else GuiControl, % PB1 ":", % "PBar_" PB1 "_" PB5 "N", % Background
  ;If existing progress picture passed, store or apply it
  If (FileExist(Progress))
    If (!ID)
      Progress_File2 := Progress
    Else GuiControl, % PB1 ":", % "PBar_" PB1 "_" PB5 "R", % Progress

  ;Return either the background or progress, based on passed @Get
  Return (Background = "@Get") ? Progress_File1 : (Progress = "@Get") ? Progress_File2 : (ID) ? 1 : ""
}

;------------------------------------------------------------------------------------------------------------------------------------
;Function:     Progress_SetText
;Parameters:   ID   = The handle returned by Progress_Add
;              Text = The new text to use (Optional)
;Return Value: 0 - Invalid handle
;------------------------------------------------------------------------------------------------------------------------------------
Progress_SetText(ByRef ID,Text="") {
  ;Retrieve every value from the handle
  Loop, Parse, ID, |
    PB%A_Index% := A_LoopField
  ;Break if any of the neccessary values isn't set
  If (PB1 = "" || PB3 = "" || PB4 = "" || PB5 = "" || PB7 = "")
    Return 0
  ;If new text specified, create the new handle
  If (Text != "")
    PB7 := Text,ID := PB1 "|" Value "|" PB3 "|" PB4 "|" PB5 "|" PB6 "|" PB7 "|" PB8 "|" PB9
  ;Replace all "variables"
  If (InStr(PB7,"$")) {
    StringReplace, PB7, PB7, $Position, % PB2, 1
    StringReplace, PB7, PB7, $Range, % SubStr(PB3,InStr(PB3,"-") + 1,StrLen(PB3)), 1
    StringReplace, PB7, PB7, $Percent, % Round(PB2 / PB3 * 100), 1
  }
  ;Update the text
  GuiControl, % PB1 ":", % "PBar_" PB1 "_" PB5 "T", % PB7
}

;------------------------------------------------------------------------------------------------------------------------------------
;Function:     Progress_SetVisibility
;Parameters:   ID      = The handle returned by Progress_Add
;              Visible = Boolean; 0 um die Progressbar zu verstecken, 1 zum anzeigen
;Return Value: 0 - Invalid handle
;------------------------------------------------------------------------------------------------------------------------------------
Progress_SetVisibility(ByRef ID,Visible) {
  ;Retrieve every value from the handle
  Loop, Parse, ID, |
    PB%A_Index% := A_LoopField
  ;Break if any of the neccessary values isn't set
  If (PB1 = "" || PB3 = "" || PB4 = "" || PB5 = "")
    Return 0
  ;Check whether the controls should be hidden or shown
  Visible := (Visible = 0) ? "Hide" : "Show"
  ;Apply the new visibility state
  GuiControl, % PB1 ":" Visible, % "PBar_" PB1 "_" PB5 "N"
  GuiControl, % PB1 ":" Visible, % "PBar_" PB1 "_" PB5 "R"
  GuiControl, % PB1 ":" Visible, % "PBar_" PB1 "_" PB5 "T"
}

;------------------------------------------------------------------------------------------------------------------------------------
;Function:     Progress_Show
;Parameters:   ID = The handle returned by Progress_Add
;Return Value: 0 - Invalid handle
;------------------------------------------------------------------------------------------------------------------------------------
Progress_Show(ByRef ID) {
  Return Progress_SetVisibility(ID,1)
}

;------------------------------------------------------------------------------------------------------------------------------------
;Function:     Progress_Hide
;Parameters:   ID = The handle returned by Progress_Add
;Return Value: 0 - Invalid handle
;------------------------------------------------------------------------------------------------------------------------------------
Progress_Hide(ByRef ID) {
  Return Progress_SetVisibility(ID,0)
}

;------------------------------------------------------------------------------------------------------------------------------------
;Function:     Progress_IsID
;Parameters:   ID = Any value that should be checked
;Return Value: Checks whether the provided ID is an actual and valid Progressbar ID or not
;------------------------------------------------------------------------------------------------------------------------------------
Progress_IsID(ID) {
  ;Check how many separators are within the id
  Loop, Parse, ID, |
    PB%A_Index% := A_LoopField,PB0 := A_Index
  ;Check if it's valid
  Return (PB0 = 9 && (PB1 > 0 && PB1 <= 99) && (PB2+0 != "" && (PB2 >= SubStr(PB3,1,(Pos := InStr(PB3,"-")) - 1) && PB2 <= SubStr(PB3,Pos + 1,StrLen(PB3))))) ? 1 : 0
}

;------------------------------------------------------------------------------------------------------------------------------------
;Function:     Progress_CopyFiles
;Parameters:   /
;Return Value: /
;------------------------------------------------------------------------------------------------------------------------------------
Progress_CopyFiles(Gui,Position,SourceFolder,DestFolder,Pattern="",Sleep=10) {
  ;Create the loop flags
  Wildcard := "*.*",IncludeFolders := 0,Recurse := 1
  Loop, Parse, Pattern, |
    If (InStr("Wildcard,IncludeFolders,Recurse",(PatternName := SubStr(A_LoopField,1,(PatternPos := InStr(A_LoopField,"=")) - 1))))
      %PatternName% := SubStr(A_LoopField,PatternPos + 1,StrLen(A_LoopField))
  ;Stop if either the source folder doesn't exist, or the progressbar can't be created
  hBar := Progress_Add(Gui,Position,"0-1",0,"$Position/$Range")
  If (FileExist(SourceFolder) = "" || hBar = 0)
    Return 0
  ;Retrieve the count of all files within the sourcefolder
  Loop, % SourceFolder "\" Wildcard, % IncludeFolders, % Recurse
    Count := A_Index
  ;Stop if source folder doesn't contain any files
  If (Count = 0 || Count = "")
    Return 0
  ;Update the progressbar range
  Progress_Set(hBar,"0-" Count,1)
  ;Create the destination folder
  FileCreateDir, % DestFolder
  ;Copy all files now
  Loop, % SourceFolder "\" Wildcard, % IncludeFolders, % Recurse
  {
    Progress_Set(hBar,A_Index)
    FileCreateDir, % Folder := DestFolder SubStr(A_LoopFileDir,StrLen(SourceFolder) + 1,StrLen(SourceFolder))
    FileCopy, % A_LoopFileFullPath, % Folder "\" A_LoopFileName
    Sleep, % Sleep
  }
  ;Return the count of copied files
  Return Count
}