; ---------------------------------------------------------------------------------------
; Advanced Library for ListViews
; by Dadepp
; Version 1.1 (minor bugfixes)
; http://www.autohotkey.com/forum/viewtopic.php?t=43242
; ---------------------------------------------------------------------------------------
;
; Warning:    This uses the OnNotify Message handler. If you already have an
;             OnNotify handler please merge these two lines into your script:
;
;  if lva_hWndInfo(NumGet(lParam + 0),2)
;    return lva_OnNotifyProg(wParam, lParam, msg, hwnd)
;
;             If this is not done, the coloring can not take place!
;             If there is NO OnNotify handler in the script, please set one by using:
;
;  OnMessage("0x4E", "LVA_OnNotify")
;
; ---------------------------------------------------------------------------------------
; Notes:
;             A Color Reference inside these functions are the same as with AHK itself:
;             Either the name of one of the 16 Standart Colors
;             (http://www.autohotkey.com/docs/commands/Progress.htm#colors)
;             or an RGB color reference such as 0x0000FF (the 0x is optional).
;             So if a color reference is to be used these are all equal:
;             red = rEd = Red = 0xFF0000 = 0xfF0000 = FF0000 = ff0000 = fF0000
;
;             All row and column numbers are 1-Based indexes !!
; ---------------------------------------------------------------------------------------
;
; List of functions the User may call:
;
; ---------------------------------------------------------------------------------------
;
; LVA_OnNotify(wParam, lParam, msg, hwnd)
;
; The OnNotify handler that can be used, if no OnNotify handler is already in place
; Please dont use otherwise! Only for use with "OnMessage("0x4E", "LVA_OnNotify")"
;
; ---------------------------------------------------------------------------------------
;
; LVA_ListViewAdd(LVvar, Options="", UseFix=true, Opt="")
;
; Makes it possible to color Cells/Rows/Columns/etc... inside the ListView.
; If this is NOT used, every other functions wont work!
; Params:
; LVvar       The associated control Variable (the name of the variable,
;             NOT the handle to the control!). Must be inside Quotationmarks ""
;
; Options     A Space delimited list of one or more of the following:
;             "AR"/"+AR"  Sets the Alternating Row Coloring to active
;             "-AR"       Removes the Alternating Row Coloring
;             "RB"        Followed by a Color Reference to set the Background Color
;                         for the alternating rows!
;             "RF"        Same as "RB" except that it controls the Text Color
;             "AC"/"+AC"  Sets the Alternating Column Coloring to active
;             "-AC"       Removes the Alternating Column Coloring
;             "CB"        Followed by a Color Reference to set the Background Color
;                         for the alternating Columns!
;             "CF"        Same as "CB" except that it controls the Text Color
;             The standard values are:
;             "-AR RB0xEFEFEF RF0x000000 -AC CB0xEFEFEF CF0x000000"
;
; UseFix      A Boolean that if set true forces the subclassing of the ListView.
;             This is done to apply a "Fix" that Microsoft seem to not want to fix,
;             since it affects all ListViews. The problem is if this is not used
;             and the user scrolls the ListView up by means of the arrow button
;             then  extra grid lines (if used!) will be drawn at half the heigth
;             of the row, same goes for custom drawn cells.
;             The option to NOT apply this fix is pressent because of possible
;             subclassing problems with AHK (for example if there are already too
;             many subclassed controls present).
;
; Opt         The Options for the RegisterCallBack() functions, used for the
;             subclassing. ONLY USE IF U KNOW WHAT YOU ARE DOING !!!
;
; ---------------------------------------------------------------------------------------
;
; LVA_ListViewModify(LVvar, Options)
;
; A way to modify the Options set with LVA_ListViewAdd().
; Params:
; LVvar       The name of the associated control's variable.
;
; Options     The same as in LVA_ListViewAdd()
;
; ---------------------------------------------------------------------------------------
;
; LVA_Refresh(LVvar)
;
; A helper function to force a ListView to ReDraw itself
; (Works only with ListViews Specified with LVA_ListViewAdd() !)
;
; ---------------------------------------------------------------------------------------
;
; LVA_SetProgressBar(LVvar, Row, Col, cInfo="")
;
; Allows the use of a ProgressBar inside a specific Cell.
; Call without the cInfo param to remove a ProgressBar from the ListView
; Params:
; LVvar       The name of the associated control's variable.
;
; Row         The number of the row to be used
;
; Col         The number of the column to be used
;
; cInfo       A Space delimited list of one or more of the following:
;             "R"       Followed by a number sets the range of the ProgressBar
;             "B"       Followed by a Color Reference to set the Background Color
;             "S"       Followed by a Color Reference to set the Starting Color
;             "E"       Followed by a Color Reference to set the Ending Color
;                       (if not used the Ending Color will be the same as the
;                       Starting Color)
;             "Smooth"  Use this Option to create a different acting ProgressBar
;             The standard values are: "R100 B0xFFFFFF S0x000080"
;
; ---------------------------------------------------------------------------------------
;
; LVA_Progress(Name, Row, Col, pProgress)
;
; If a ProgressBar has been set with LVA_SetProgressBar() then this sets the
; current value of this specific ProgressBar. (This repaints the ProgressBar,
; and ONLY the ProgressBar!)
; Params:
; LVvar       The name of the associated control's variable.
;
; Row         The number of the row to be used
;
; Col         The number of the column to be used
;
; cProgress   The new value. If it exceeds the Range set for this ProgressBar,
;             the maximum allowed Range is used instead!
;
; ---------------------------------------------------------------------------------------
;
; LVA_SetCell(Name, Row, Col, cBGCol="", cFGCol="")
;
; Sets the Color to a specific Cell. To remove a Color, use the function
; without the "cBGCol" and "cFGCol" params! If one param is empty then
; the other one will be automaticly filled with the standard values for this
; specific ListView (these infos will be determined internally!)
; Params:
; LVvar       The name of the associated control's variable.
;
; Row         The number of the row to be used
;
; Col         The number of the column to be used
;
; cBGCol      The Color Reference for the Cells BackGround
;
; cFGCol      The Color Reference for the Cells Text
;
; Note:       Setting Row or Col to 0 will affect the whole Row/Column.
;             The order of priority for the cells color goes:
;             if specific the use this
;             else if column has color
;             else if row has color
;             else if is an alternating column and bool is set
;             else if is an alternating row and bool is set
;             else standard colors
;
; ---------------------------------------------------------------------------------------
; LVA_EraseAllCells(Name)
;
; Resets ALL Color/ProgressBar Informations, for the complete ListView
; (Use with caution!)
;
; LVvar       The name of the associated control's variable.
;
; ---------------------------------------------------------------------------------------
;
; The Following Functions CAN BE USED even on ListViews not specified with
; LVA_ListViewAdd()
;
; ---------------------------------------------------------------------------------------
; LVA_GetCellNum(Switch=0, LVvar="")
;
; A function to retrieve Cell-Information (Row/Column) from the cell under
; the Mouse Pointer!
; Params:
;
; Switch      If set to 0 and LVvar set to the ListView in question, it
;             retrieves the informations and stores the internally!
;             Afterwards the LVvar param is no longer needed, and these
;             infos can be requested with the following:
;             (Note: These values will still hold the values from when it was
;             used with Switch set to 0 even if the MousePosition changed!)
;             1  or "Row"     Returns the row-number
;             2  or "Col"     Returns the Column-number
;             -1 or "Row-1"   Returns the row-number (0-Based Index)
;             -2 or "Row-2"   Returns the Column-number (0-Based Index)
;             "Rows"          Returns the total number of Rows
;             "Cols"          Returns the total number of Columns
;
;             The following values for Switch are special, since with them
;             the Cell-Information wont be evaluated (and changed !!).
;             But the LVvar param is needed again !!
;             "GetRows"       Returns the total number of Rows
;             "GetCols"       Returns the total number of Columns
;
; LVvar       The name of the associated control's variable.
;             Can also be a Handle !!
;
; ---------------------------------------------------------------------------------------
;
; LVA_SetSubItemImage(LVvar, Row, Col, iNum)
;
; A helper function to set an Image to any Cell. An ImageList MUST be
; associated with that ListView, and the ListView MUST have "+LV0x2" set inside
; its Style Options.
; (Note: Using a number < 1 for Row is the Same as using 1.
;        Using 1 for Col , is the same as using: LV_Modify(Row, "Icon" . iNum) !)
; Params:
; LVvar       The name of the associated control's variable.
;
; Row         The number of the row to be used
;
; Col         The number of the column to be used
;
; iNum        The number of the ImageList-Icon to be used
;
; ---------------------------------------------------------------------------------------



; ---------------------------------------------------------------------------------------
; Public functions, for use look at the docu above!
; ---------------------------------------------------------------------------------------

LVA_OnNotify(wParam, lParam, msg, hwnd)
{
  Critical, 500
  if lva_hWndInfo(NumGet(lParam + 0),2)
    return lva_OnNotifyProg(wParam, lParam, msg, hwnd)
}

LVA_ListViewAdd(LVvar, Options="", UseFix=false, Opt="")
{
  tmp := lva_hWndInfo(LVvar, 1)
  tmp2 :=lva_hWndInfo(0, -2, tmp)
  lva_Info("SetARowBool", LVvar,0,0,false)
  lva_Info("SetARowColB", LVvar,0,0,"0xEFEFEF")
  lva_Info("SetARowColF", LVvar,0,0,"0x000000")
  lva_Info("SetAColBool", LVvar,0,0,false)
  lva_Info("SetAColColB", LVvar,0,0,"0xEFEFEF")
  lva_Info("SetAColColF", LVvar,0,0,"0x000000")
  SendMessage, 4096,0,0,, ahk_id %tmp2%
  lva_Info("SetStdColorBG", LVvar,0,0,ErrorLevel)
  SendMessage, 4131,0,0,, ahk_id %tmp2%
  lva_Info("SetStdColorFG", LVvar,0,0,ErrorLevel)
  LVA_ListViewModify(LVvar, Options)
  if UseFix
    lva_Subclass(tmp2, "lva_OnLVScroll", Opt)
  LVA_Refresh(LVvar)
}

LVA_ListViewModify(LVvar, Options)
{
  Loop, Parse, Options, %A_Space%
  {
    if (A_LoopField = "+AR")||(A_LoopField = "AR")
      lva_Info("SetARowBool", LVvar,0,0,true)
    if (A_LoopField = "-AR")
      lva_Info("SetARowBool", LVvar,0,0,false)
    if (A_LoopField = "+AC")||(A_LoopField = "AC")
      lva_Info("SetAColBool", LVvar,0,0,true)
    if (A_LoopField = "-AC")
      lva_Info("SetAColBool", LVvar,0,0,false)
    cmd := SubStr(A_LoopField,1,2)
    if (cmd = "RB")
      lva_Info("SetARowColB", LVvar,0,0, lva_VerifyColor(SubStr(A_LoopField, 3)))
    if (cmd = "RF")
      lva_Info("SetARowColF", LVvar,0,0, lva_VerifyColor(SubStr(A_LoopField, 3)))
    if (cmd = "CB")
      lva_Info("SetAColColB", LVvar,0,0, lva_VerifyColor(SubStr(A_LoopField, 3)))
    if (cmd = "CF")
      lva_Info("SetAColColF", LVvar,0,0, lva_VerifyColor(SubStr(A_LoopField, 3)))
  }
}

LVA_Refresh(LVvar)
{
  tmp := LVA_hWndInfo(LVvar,0,2)
  WinSet, Redraw,, ahk_id %tmp%
}

LVA_SetProgressBar(LVvar, Row, Col, cInfo="")
{
  if (cInfo = "")
  {
    lva_Info("SetPB", LVvar, Row, Col, false)
    lva_Refresh(LVvar)
    return
  }
  lva_Info("SetPB", LVvar, Row, Col, true)
  lva_Info("SetProgress", LVvar, Row, Col, 0)
  lva_Info("SetPBR", LVvar, Row, Col, 100)
  lva_Info("SetPCB", LVvar, Row, Col, "0x00FFFFFF")
  lva_Info("SetPCS", LVvar, Row, Col, "0x000080")
  Loop, Parse, cInfo, %A_Space%
  {
    cmd := SubStr(A_LoopField,1,1)
    if (A_LoopField = "Smooth")
      lva_Info("SetPB", LVvar, Row, Col, 2)
    else if (cmd = "R")
      lva_Info("SetPBR", LVvar, Row, Col, SubStr(A_LoopField, 2))
    else if (cmd = "B")
      lva_Info("SetPCB", LVvar, Row, Col, lva_VerifyColor(SubStr(A_LoopField, 2),1))
    else if (cmd = "S")
      lva_Info("SetPCS", LVvar, Row, Col, lva_VerifyColor(SubStr(A_LoopField, 2), 2))
    else if (cmd = "E")
      lva_Info("SetPCE", LVvar, Row, Col, lva_VerifyColor(SubStr(A_LoopField, 2), 2))
  }
  if (lva_Info("GetPCE", LVvar, Row, Col) = "")
    lva_Info("SetPCE", LVvar, Row, Col, lva_Info("GetPCS", LVvar, Row, Col))
}

LVA_Progress(Name, Row, Col, pProgress)
{
  lva_Info("SetProgress", lva_hWndInfo(Name), Row, Col, pProgress)
  lva_DrawProgress(Row, Col, lva_hWndInfo(Name,0,2))
}

LVA_SetCell(Name, Row, Col, cBGCol="", cFGCol="")
{
  if ((cBGCol = "")&&(cFGCol = ""))
  {
    lva_Info("SetCol", Name, Row, Col, false)
    return
  }
  if (cBGCol <> "")
    lva_Info("SetCellColorBG", Name, Row, Col, lva_VerifyColor(cBGCol))
  if (cFGCol <> "")
    lva_Info("SetCellColorFG", Name, Row, Col, lva_VerifyColor(cFGCol))
  if (cFont <> "")
    lva_Info("SetCellFont", Name, Row, Col, cFont)
  lva_Info("SetCol", Name, Row, Col, true)
}

LVA_EraseAllCells(Name)
{
  lva_Info(0, Name)
}

LVA_GetCellNum(Switch=0, LVvar="")
{
  Static LastResR, LastResC, LastColCount, LastRowCount, LastLVvar
  if ((Switch = 1)||(Switch = "Row"))
    return LastResR
  else if ((Switch = 2)||(Switch = "Col"))
    return LastResC
  else if ((Switch = -1)||(Switch = "Row-1"))
    return LastResR-1
  else if ((Switch = -2)||(Switch = "Col-1"))
    return LastResC-1
  else if (Switch = "Rows")
    return LastRowCount
  else if (Switch = "Cols")
    return LastColCount
  if (LVvar = "")
    LVvar := LastLVvar
  else
    LastLVvar := LVvar
  if LVvar is not Integer
    GuiControlGet, hLV, Hwnd, %LVvar%
  else
    hLV := LVvar
  SendMessage, 4100,0,0,, ahk_id %hLV%
  RowCount := ErrorLevel
  if (Switch = "GetRows")
    return RowCount
  SendMessage, 4127,0,0,, ahk_id %hLV%
  hHeader := ErrorLevel
  SendMessage, 4608,0,0,, ahk_id %hHeader%
  ColCount := ErrorLevel
  if (Switch = "GetCols")
    return ColCount
  LastRowCount := RowCount
  LastColCount := ColCount
  VarSetCapacity(spt, 8, 0)
  VarSetCapacity(pt, 8, 0)
  DllCall("GetCursorPos", "UInt", &spt)
  NumPut(NumGet(spt, 0), pt, 0)
  NumPut(NumGet(spt, 4), pt, 4)
  DllCall("ScreenToClient", "UInt", hLV, "UInt", &pt)
  VarSetCapacity(LVHitTest, 24, 0)
  NumPut(NumGet(pt, 0), LVHitTest, 0)
  NumPut(NumGet(pt, 4), LVHitTest, 4)
  SendMessage, 4153, 0, &LVHitTest,, ahk_id %hLV%
  LastResR := NumGet(LVHitTest, 12)+1
  if (LastResR > RowCount)
    LastResR := 0
  LastResC := NumGet(LVHitTest, 16)+1
  if ((LastResC > ColCount)||(LastResR = 0))
    LastResC := 0
  return
}

LVA_SetSubItemImage(LVvar, Row, Col, iNum)
{
  GuiControlGet, hLV, Hwnd, %LVvar%
  VarSetCapacity(LVItem, 60, 0)
  if (Row < 1)
    Row := 1
  NumPut(2, LVItem, 0)
  NumPut(Row-1, LVItem, 4)
  NumPut(Col, LVItem, 8)
  NumPut(iNum-1, LVItem, 28)
  SendMessage, 4102, 0, &LVItem,, ahk_id %hLV%
}

; ------------------------------------------------------------------------------------------------------------
; Private Functions! Please use only if u know what your doing
; ------------------------------------------------------------------------------------------------------------

lva_VerifyColor(cColor, Switch=0)
{
  if cColor is not Integer
  {
    if (cColor = "Black")
      cColor := (Switch = 1) ? "FFFFFF" : "010101"
    else if (cColor = "White")
      cColor := (Switch = 1) ? "010101" : "FFFFFF"
    else if (cColor = "Silver")
      cColor := "C0C0C0"
    else if (cColor = "Gray")
      cColor := "808080"
    else if (cColor = "Maroon")
      cColor := "800000"
    else if (cColor = "Red")
      cColor := "FF0000"
    else if (cColor = "Purple")
      cColor := "800080"
    else if (cColor = "Fuchsia")
      cColor := "FF00FF"
    else if (cColor = "Green")
      cColor := "008000"
    else if (cColor = "Lime")
      cColor := "00FF00"
    else if (cColor = "Olive")
      cColor := "808000"
    else if (cColor = "Yellow")
      cColor := "FFFF00"
    else if (cColor = "Navy")
      cColor := "000080"
    else if (cColor = "Blue")
      cColor := "0000FF"
    else if (cColor = "Teal")
      cColor := "008080"
    else if (cColor = "Aqua")
      cColor := "00FFFF"
  }
  if (SubStr(cColor,1,2) = "0x")
    cColor := SubStr(cColor, 3)
  if ((Switch = 1)&&(SubStr(cColor,1,2) = "00"))
    cColor := SubStr(cColor, 3)
  if (StrLen(cColor) <> 6)
    return "0xFFFFFF"
  if (Switch = 1)
    return "0x00" . SubStr(cColor,5,2) . SubStr(cColor,3,2) . SubStr(cColor,1,2)
  if (Switch = 0)
    return "0x" . SubStr(cColor,5,2) . SubStr(cColor,3,2) . SubStr(cColor,1,2)
  else
    return "0x" . cColor
}

lva_DrawProgressGetStatus(Switch, Row=0, Col=0, Name="")
{
  Static BGCol, SColR, SColG, SColB, EColR, EColG, EColB, pProgressMax, pProgress, pProgressType
  if !Switch
  {
    BGCol := lva_Info("GetPCB", Name, Row, Col)
    SCol := lva_Info("GetPCS", Name, Row, Col)
    ECol := lva_Info("GetPCE", Name, Row, Col)
    pProgressMax := lva_Info("GetPBR", Name, Row, Col)
    pProgress := lva_Info("GetProgress", Name, Row, Col)
    SColR := "0x" . SubStr(SCol, 3, 2) . "00"
    SColG := "0x" . SubStr(SCol, 5, 2) . "00"
    SColB := "0x" . SubStr(SCol, 7, 2) . "00"
    EColR := "0x" . SubStr(ECol, 3, 2) . "00"
    EColG := "0x" . SubStr(ECol, 5, 2) . "00"
    EColB := "0x" . SubStr(ECol, 7, 2) . "00"
    pProgressType := lva_Info("GetPB", Name, Row, Col)
  }
  if (Switch = 1)
    return BGCol
  else if (Switch = 2)
    return SColR
  else if (Switch = 3)
    return SColG
  else if (Switch = 4)
    return SColB
  else if (Switch = 5)
    return EColR
  else if (Switch = 6)
    return EColG
  else if (Switch = 7)
    return EColB
  else if (Switch = 8)
  {
    max := col-row
    if (pProgress > pProgressMax)
      return max
    res := Ceil((max / 100) * (Round(pProgress / (pProgressMax / 100))))
    if res > max
      return max
    else
      return res
  }
  else if (Switch = 9)
    return pProgressType
}

lva_GetStatusColor(Switch, Row=0, Col=0, LVvar=0)
{
  Static cFGCol, cBGCol
  if (Switch = -1)
  {
    return cFGCol
  }
  else if (Switch = -2)
  {
    return cBGCol
  }
  else if (switch = 0)
  {
    if lva_Info("GetCol", LVvar, 0, Col)
    {
      cBGCol := lva_Info("GetCellColorBG", LVvar, 0, Col)
      if !cBGCol
        cBGCol := lva_Info("GetStdColorBG", LVvar)
      cFGCol := lva_Info("GetCellColorFG", LVvar, 0, Col)
      if !cFGCol
        cFGCol := lva_Info("GetStdColorFG", LVvar)
    }
    else if lva_Info("GetCol", LVvar, Row)
    {
      cBGCol := lva_Info("GetCellColorBG", LVvar, Row)
      if !cBGCol
        cBGCol := lva_Info("GetStdColorBG", LVvar)
      cFGCol := lva_Info("GetCellColorFG", LVvar, Row)
      if !cFGCol
        cFGCol := lva_Info("GetStdColorFG", LVvar)
    }
    else if (lva_Info("GetAColBool", LVvar))&&(mod(Col, 2) = 0)
    {
      cBGCol := lva_Info("GetAColColB", LVvar)
      cFGCol := lva_Info("GetAColColF", LVvar)
    }
    else if (lva_Info("GetARowBool", LVvar))&&(mod(Row, 2) = 0)
    {
      cBGCol := lva_Info("GetARowColB", LVvar)
      cFGCol := lva_Info("GetARowColF", LVvar)
    }
    else
    {
      cBGCol := lva_Info("GetStdColorBG", LVvar)
      cFGCol := lva_Info("GetStdColorFG", LVvar)
    }
  }
  else if (switch = 1)
  {
    cBGCol := lva_Info("GetCellColorBG", LVvar, Row, Col)
    if !cBGCol
      if (lva_Info("GetAColBool", LVvar))&&(mod(Col, 2) = 0)
        cBGCol := lva_Info("GetAColColB", LVvar)
      else if (lva_Info("GetARowBool", LVvar))&&(mod(Row, 2) = 0)
        cBGCol := lva_Info("GetARowColB", LVvar)
      else
        cBGCol := lva_Info("GetStdColorBG", LVvar)
    cFGCol := lva_Info("GetCellColorFG", LVvar, Row, Col)
    if !cFGCol
      if (lva_Info("GetAColBool", LVvar))&&(mod(Col, 2) = 0)
        cFGCol := lva_Info("GetAColColF", LVvar)
      else if (lva_Info("GetARowBool", LVvar))&&(mod(Row, 2) = 0)
        cFGCol := lva_Info("GetARowColF", LVvar)
      else
        cFGCol := lva_Info("GetStdColorFG", LVvar)
  }
}

lva_hWndInfo(hwnd, switch=0, data=1)
{
  Static
  Local tmp, found
  if ((switch = 0)||(switch = 2))
  {
    if hwnd is Integer
      hwnd := hwnd+0

    found := false
    Loop, %LVCount%
    {
      tmp := A_Index
      Loop, 3
      {
        if (LVA_hWndInfo_%tmp%_%A_Index% = hwnd)
        {
          found := true
          break
        }
      }
      if found
        break
    }
    if !found
      return ""
    else
    {
      if (switch = 0)
        return LVA_hWndInfo_%tmp%_%data%
      else if (switch = 2)
        return true
    }
  }
  else if (switch = -1)
    return LVA_hWndInfo_%data%_1
  else if (switch = -2)
    return LVA_hWndInfo_%data%_2
  else if (switch = -3)
    return LVA_hWndInfo_%data%_3
  else if (switch = 1)
  {
    if !LVCount
      LVCount := 1
    else
      LVCount++
    LVA_hWndInfo_%LVCount%_1 := hwnd
    GuiControlGet, tmp, Hwnd, %hwnd%
    LVA_hWndInfo_%LVCount%_2 := tmp+0
    SendMessage, 4127,0,0,, ahk_id %tmp%
    LVA_hWndInfo_%LVCount%_3 := ErrorLevel+0
    return LVCount
  }
}

lva_OnNotifyProg(wParam, lParam, msg, hwnd)
{
  Critical, 500
  hHandle := NumGet(lParam + 0)
  NotifyMsg := NumGet(lParam + 8, 0, "Int")
  if ((NotifyMsg == -307)||(NotifyMsg == -327))
    LVA_Refresh(hHandle)
  else if (NotifyMsg == -12)
  {
    Row := NumGet(lParam + 36) +1
    Col := NumGet(lParam + 56) +1
    st := NumGet(lParam + 12)
    if st = 1
      Return, 0x20
    else if (st == 0x10001)
      Return, 0x20
    else if (st == 0x30001)
    {
      LVvar := LVA_hWndInfo(hHandle)
      CellType := lva_Info("GetCellType", LVvar, Row, Col)
      if (CellType = 0)
      {
        lva_GetStatusColor(0, Row, Col, LVvar)
        NumPut(lva_GetStatusColor(-1), lParam + 48)
        NumPut(lva_GetStatusColor(-2), lParam + 52)
      }
      else if (CellType = 1)
      {
        lva_GetStatusColor(1, Row, Col, LVvar)
        NumPut(lva_GetStatusColor(-1), lParam + 48)
        NumPut(lva_GetStatusColor(-2), lParam + 52)
      }
      else if (CellType = 2)
      {
        lva_DrawProgress(Row, Col, hHandle)
        return 0x4
      }
      else if (CellType = 3)
      {
;        lva_DrawMultiImage(Row, Col, hHandle)
        return 0x4
      }
    }
  }
}

lva_OnLVScroll(hwnd, uMsg, wParam, lParam)
{
  Critical, 500
  if (uMsg = 0x115)
  {
    DLow := wParam & 0xFFFF
    if !DLow
      DllCall("LockWindowUpdate", "UInt", hwnd)
    else
      DllCall("LockWindowUpdate", "UInt", 0)
  }
  return DllCall("CallWindowProcA", "UInt", A_EventInfo, "UInt", hwnd, "UInt", uMsg, "UInt", wParam, "UInt", lParam)
}

lva_DrawProgress(Row, Col, hHandle)
{
  if !lva_Info("GetPB", lva_hwndInfo(hHandle,0,1), Row, Col)
    return
  VarSetCapacity(pRect, 16, 0)
  NumPut(0, pRect, 0)
  NumPut(Col-1, pRect, 4)
  SendMessage, 4152, Row-1, &pRect,, ahk_id %hHandle%
  pLeft := NumGet(pRect, 0) > 0x7FFFFFFF ? -(~NumGet(pRect, 0)) - 1 : NumGet(pRect, 0)
  pTop := NumGet(pRect, 4) > 0x7FFFFFFF ? -(~NumGet(pRect, 4)) - 1 : NumGet(pRect, 4)
  pRight := NumGet(pRect, 8) > 0x7FFFFFFF ? -(~NumGet(pRect, 8)) - 1 : NumGet(pRect, 8)
  pBottom := NumGet(pRect, 12) > 0x7FFFFFFF ? -(~NumGet(pRect, 12)) - 1 : NumGet(pRect, 12)
  if ((pRight < 0)||(pBottom < 0))
    return
  VarSetCapacity(pRect2, 16, 0)
  SendMessage, 4135,0,0,, ahk_id %hHandle%
  SendMessage, 4152, ErrorLevel, &pRect2,, ahk_id %hHandle%
  if (pTop < NumGet(pRect2, 4))
    return
  lva_DrawProgressGetStatus(0, Row, Col, lva_hWndInfo(hHandle))
  hDC := DllCall("GetDC", "UInt", hHandle)
  if (pLeft < 0)
    pWidth := NumGet(pRect, 8) + -pLeft-3
  else
    pWidth := NumGet(pRect, 8) - NumGet(pRect, 0)-3
  pHeight := NumGet(pRect, 12) - NumGet(pRect, 4)-3
  mDC := DllCall("CreateCompatibleDC", "UInt", hDC)
  mBitmap := DllCall("CreateCompatibleBitmap", "UInt", hDC, "Int", pWidth, "Int", pHeight)
  DllCall("SelectObject", "UInt", mDC, "UInt", mBitmap)
  VarSetCapacity(pVertex, 32, 0)
  NumPut(1, pVertex, 0, "Int")
  NumPut(1, pVertex, 4, "Int")
  NumPut(lva_DrawProgressGetStatus(2), pVertex, 8, "Ushort")
  NumPut(lva_DrawProgressGetStatus(3), pVertex, 10, "Ushort")
  NumPut(lva_DrawProgressGetStatus(4), pVertex, 12, "Ushort")
  NumPut(0x0000, pVertex, 14, "Ushort")
  ProgLen := lva_DrawProgressGetStatus(8, 1, pWidth-1)
  if (lva_DrawProgressGetStatus(9) = 1)
    NumPut(1+ProgLen, pVertex, 16, "Int")
  else
    NumPut(pWidth-1, pVertex, 16, "Int")
  NumPut(pHeight-1, pVertex, 20, "Int")
  NumPut(lva_DrawProgressGetStatus(5), pVertex, 24, "Ushort")
  NumPut(lva_DrawProgressGetStatus(6), pVertex, 26, "Ushort")
  NumPut(lva_DrawProgressGetStatus(7), pVertex, 28, "Ushort")
  NumPut(0x0000, pVertex, 30, "Ushort")
  VarSetCapacity(gRect, 8, 0)
  NumPut(0, gRect, 0, "UInt")
  NumPut(1, gRect, 4, "UInt")
  DllCall("msimg32\GradientFill", "UInt", mDC, "UInt", &pVertex, "Int", 2, "UInt", &gRect, "Int", 1, "UInt", 0x0)
  NumPut(ProgLen+1, pRect2, 0)
  NumPut(1, pRect2, 4)
  NumPut(pWidth-1, pRect2, 8)
  NumPut(pHeight-1, pRect2, 12)
  hBrush := DllCall("Gdi32\CreateSolidBrush", "UInt", lva_DrawProgressGetStatus(1))
  DllCall("FillRect", "UInt", mDC, "UInt", &pRect2, "UInt", hBrush)
  DllCall("Gdi32\DeleteObject", "UInt", hBrush)
  if (pLeft < 0)
    DllCall("Gdi32\BitBlt", "UInt", hDC, "UInt", NumGet(pRect, 0)-pLeft-1, "UInt", NumGet(pRect, 4)+1, "UInt", NumGet(pRect, 8), "UInt", NumGet(pRect, 12)-1, "UInt", mDC, "UInt", -pLeft-3, "UInt", 0, "UInt", 0xCC0020)
  else
    DllCall("Gdi32\BitBlt", "UInt", hDC, "UInt", NumGet(pRect, 0)+2, "UInt", NumGet(pRect, 4)+1, "UInt", NumGet(pRect, 8), "UInt", NumGet(pRect, 12)-1, "UInt", mDC, "UInt", 0, "UInt", 0, "UInt", 0xCC0020)
  DllCall("DeleteDC", "UInt", mDC)
  DllCall("ReleaseDC", "UInt", hHandle, "UInt", hDC)
}

lva_Info(Switch, Name, Row=0, Col=0, Data=0)
{
  Static
  if (Switch = 0)
  {
    Loop, % LVA_GetCellNum("GetRows", Name)
    {
      lRow := A_Index
      if LVA_InfoArray_%Name%_%lRow%_0_HasCellColor
        LVA_InfoArray_%Name%_%lRow%_0_HasCellColor := ""
      Loop, % LVA_GetCellNum("GetCols", Name)
      {
        if LVA_InfoArray_%Name%_%lRow%_%A_Index%_HasProgressBar
          LVA_InfoArray_%Name%_%lRow%_%A_Index%_HasProgressBar := ""
        if LVA_InfoArray_%Name%_%lRow%_%A_Index%_HasMultiImage
          LVA_InfoArray_%Name%_%lRow%_%A_Index%_HasMultiImage := ""
        if LVA_InfoArray_%Name%_%lRow%_%A_Index%_HasCellColor
          LVA_InfoArray_%Name%_%lRow%_%A_Index%_HasCellColor := ""
        if LVA_InfoArray_%Name%_0_%A_Index%_HasCellColor
          LVA_InfoArray_%Name%_0_%A_Index%_HasCellColor := ""
      }
    }
    return
  }
  else if (Switch = "GetStdColorBG")
    return LVA_InfoArray_%Name%_BGColor
  else if (Switch = "GetStdColorFG")
    return LVA_InfoArray_%Name%_FGColor
  else if (Switch = "GetCellColorBG")
    return LVA_InfoArray_%Name%_%Row%_%Col%_BGColor
  else if (Switch = "GetCellColorFG")
    return LVA_InfoArray_%Name%_%Row%_%Col%_FGColor
  else if (Switch = "GetCellType")
  {
    if LVA_InfoArray_%Name%_%Row%_%Col%_HasCellColor
      return 1
    else if LVA_InfoArray_%Name%_%Row%_%Col%_HasProgressBar
      return 2
    else if LVA_InfoArray_%Name%_%Row%_%Col%_HasMultiImage
      return 3
    else
      return 0
  }
  else if (Switch = "GetPB")
    return LVA_InfoArray_%Name%_%Row%_%Col%_HasProgressBar
  else if (Switch = "GetProgress")
    return LVA_InfoArray_%Name%_%Row%_%Col%_ProgressBarProgress
  else if (Switch = "GetPBR")
    return LVA_InfoArray_%Name%_%Row%_%Col%_ProgressBarRange
  else if (Switch = "GetPCB")
    return LVA_InfoArray_%Name%_%Row%_%Col%_ProgressBarBckCol
  else if (Switch = "GetPCS")
    return LVA_InfoArray_%Name%_%Row%_%Col%_ProgressBarSCol
  else if (Switch = "GetPCE")
    return LVA_InfoArray_%Name%_%Row%_%Col%_ProgressBarECol
  else if (Switch = "GetMI")
    return LVA_InfoArray_%Name%_%Row%_%Col%_HasMultiImage
  else if (Switch = "GetCol")
    return LVA_InfoArray_%Name%_%Row%_%Col%_HasCellColor
  else if (Switch = "GetARowBool")
    return LVA_InfoArray_%Name%_ARowColor_Alternate
  else if (Switch = "GetARowColB")
    return LVA_InfoArray_%Name%_ARowColor_BColor
  else if (Switch = "GetARowColF")
    return LVA_InfoArray_%Name%_ARowColor_FColor
  else if (Switch = "GetAColBool")
    return LVA_InfoArray_%Name%_AColColor_Alternate
  else if (Switch = "GetAColColB")
    return LVA_InfoArray_%Name%_AColColor_BColor
  else if (Switch = "GetAColColF")
    return LVA_InfoArray_%Name%_AColColor_FColor
  else if (Switch = "SetStdColorBG")
    LVA_InfoArray_%Name%_BGColor := Data
  else if (Switch = "SetStdColorFG")
    LVA_InfoArray_%Name%_FGColor := Data
  else if (Switch = "SetCellColorBG")
    LVA_InfoArray_%Name%_%Row%_%Col%_BGColor := Data
  else if (Switch = "SetCellColorFG")
    LVA_InfoArray_%Name%_%Row%_%Col%_FGColor := Data
  else if (Switch = "SetPB")
    LVA_InfoArray_%Name%_%Row%_%Col%_HasProgressBar := Data
  else if (Switch = "SetProgress")
    LVA_InfoArray_%Name%_%Row%_%Col%_ProgressBarProgress := Data
  else if (Switch = "SetPBR")
    LVA_InfoArray_%Name%_%Row%_%Col%_ProgressBarRange := Data
  else if (Switch = "SetPCB")
    LVA_InfoArray_%Name%_%Row%_%Col%_ProgressBarBckCol := Data
  else if (Switch = "SetPCS")
    LVA_InfoArray_%Name%_%Row%_%Col%_ProgressBarSCol := Data
  else if (Switch = "SetPCE")
    LVA_InfoArray_%Name%_%Row%_%Col%_ProgressBarECol := Data
  else if (Switch = "SetMI")
    LVA_InfoArray_%Name%_%Row%_%Col%_HasMultiImage := Data
  else if (Switch = "SetCol")
    LVA_InfoArray_%Name%_%Row%_%Col%_HasCellColor := Data
  else if (Switch = "SetARowBool")
    LVA_InfoArray_%Name%_ARowColor_Alternate := Data
  else if (Switch = "SetARowColB")
    LVA_InfoArray_%Name%_ARowColor_BColor := Data
  else if (Switch = "SetARowColF")
    LVA_InfoArray_%Name%_ARowColor_FColor := Data
  else if (Switch = "SetAColBool")
    LVA_InfoArray_%Name%_AColColor_Alternate := Data
  else if (Switch = "SetAColColB")
    LVA_InfoArray_%Name%_AColColor_BColor := Data
  else if (Switch = "SetAColColF")
    LVA_InfoArray_%Name%_AColColor_FColor := Data
}

lva_Subclass(hCtrl, Fun, Opt="", ByRef $WndProc="") {
   if Fun is not integer
   {
       oldProc := DllCall("GetWindowLong", "uint", hCtrl, "uint", -4)
       ifEqual, oldProc, 0, return 0
       $WndProc := RegisterCallback(Fun, Opt, 4, oldProc)
       ifEqual, $WndProc, , return 0
   }
   else $WndProc := Fun

    return DllCall("SetWindowLong", "UInt", hCtrl, "Int", -4, "Int", $WndProc, "UInt")
}

