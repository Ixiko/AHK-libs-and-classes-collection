; --------------------------------------
; Drag&Drop Library for listbox
; by Dadepp
; Version 1.3
; AHK_B / AHK_L and ANSI / Unicode compatible
; http://www.autohotkey.com/forum/viewtopic.php?t=32660
; Thanks goes out to majkinetor for corrections and suggestions.
/* List of functions the User may call:
;
; --------------------------------------
; LBDDLib_Init(Options)
; Must be called once or Drag&Drop won't work!
; Leave the Options blank to start with default values!
; The Options are a list of any of the following options in any order,
; separated with a space inside a string:
;
; The following three options specify function names. They will be called
; when the corresponding events take place. They will be called before any
; control specific functions, and they ignore any return values as they are
; only there to inform, not to allow/disallow an action (use the control specific
; functions for that)!
;   V: Specify v followed with the name of a function that will be
;      called when the Drag-Event starts.
;   H: Specify h followed with the name of a function that will be
;      called when the Drag-Event is taking place.
;   G: Specify g followed with the name of a function that will be
;      called when the Drop-Event takes place.
; The following two options are mutually exclusiv, and "UseEventNumbers"
; is the default value, if no such option is set.
;   "UseEventNames":
;      When "UseEventNames" is used the return value of the function
;      LBDDLib_UserVar("Event")
;      will be strings corresponding to the Event taking place, instead of numbers.
;     (See function below for more info!)
;   "UseEventNumbers":
;      When "UseEventNumbers" is used the return value of the function
;      LBDDLib_UserVar("Event")
;      will be numbers corresponding to the Event taking place, instead of strings.
;     (See function below for more info!)
;
; --------------------------------------
; LBDDLib_Add(hWnd, Switch, Options)
; Adds an existing control to the internal list of possible drop targets.
;
; The first parameter MUST be the handle to the control.
; To get the handle of a control see:
; http://www.autohotkey.com/docs/commands/Gui.htm#HwndOutputVar
;
; The second parameter can be one of the following:
;   "ddlb" or 0:
;      Identifies the handle as a handle to a listbox, and makes it Drag&Drop-able.
;      Note: This is the default, if the second parameter is omited!
;  "lb" or "target" or "droponly" or 1:
;      Identifies the handle as a handle to a listbox, and makes it
;      a Drop-Target ONLY, meaning u can't drag from it only onto it.
;  "eb" or "editbox" or "edit" or 2:
;      Identifies the handle as a handle to an EditBox, and makes it a Drop-Target ONLY.
;   "custom" or 3:
;      Identifies the handle as a handle to a not supported control,
;      and requires an User defined CallBack-Function.
;
; The third parameter MUST be a string if it is used, and it is optional!
; The possible options are:
; (Write the value directly after the Option-Switch, and seperate the options with a
; space.The order of the Option-Switches do not matter, they can be put in any order,
; and they are non case-sensitive! If you don't define an
; Option-Switch the default Value will be used instead!)
; For listboxes:
;   T: Specify T and afterwards a number greater than 0. This is the height in Pixel
;      for the Rect on Top of the listbox, that is used to indicate when the listbox
;      should be scrolled up.
;      Default value: 20
;   B: Specify T and afterwards a number greater than 0. This is the height in Pixel
;      for the Rect on the Bottom of the Listbox, that is used to indicate when the
;      listbox should be scrolled down.
;      (Same as the T-option, but for the bottom!)
;      Default value: 20
;   S: Specify S and afterwards either 0 or 1 or 2.
;      If you specified 0, it means the listbox accepts Drops from other listboxes,
;      and allows its own entries to be dragged onto other controls.
;      If you specified 1, the listbox ONLY accepts items from itself and allows
;      only for dragging its own item onto itself.
;      If you specified 2, the listbox accepts items from other listboxes, BUT ONLY
;      allows items to be dragged onto itself.
;      Default value: 0
;   Instead of using the S Option-Switch, the following substitutes can be used:
;      "global": Has the same effect as using S0
;      "OnlySelf": Has the same effect as using S1
;      "accept" or "drop": Has the same effect as using S2
;   I: Specify I and afterwards either 1 or 2 or 3.
;      If you specified 1, it means the listbox will draw an arrow as an insertion-mark.
;      If you specified 2, it means the listbox will draw a line as an insertion-mark.
;      If you specified 3, it means the listbox will draw both,
;      an arrow and a line as an insertion-mark.
;   Instead of using the I Option-Switch, the following substitutes can be used:
;      "InsArrow": Has the same effect as using I1
;      "InsArrow": Has the same effect as using I2
;      "InsArrowLine": Has the same effect as using I3
;   ThickLine: If the insertion-mark is a line (any combination containing a line
;      option) then setting this option draws a thicker line. Is mutually exclusive
;      with the option NoThickLine. (NoThickLine is default)
;   NoThickLine: If the insertion-mark is a line (any combination containing a line
;      option) then setting this option draws a normal line. This option is mutually
;      exclusive with the option ThickLine. (NoThickLine is default)
;   #: Specify # and afterwards a RGB value in hex-form without the preceding 0x or
;      one of the following values (case insensitive):
;      Silver, Gray, Maroon, Red, Purple, Fuchsia, Green, Lime, Olive,
;      Yellow, Navy, Blue, Teal, Aqua
;   V: Specify V and afterwards a string containing the name of a Function (NOT a Label,
;      it must be a function), that will be called if a Drag-Event occurs!
;      The Function MUST return True if the Drag-Event is allowed, or False if the
;      Drag-Even is not allowed! The default behaviour (if no return is called or if an
;      invalid value is returned!) is False, meaning NO drag-event is started.
;      The Function MUST NOT have any parameters!
;      To retrieve information on what listbox the item comes from what number the
;      original item has, use the Provided function:
;      LBDDLib_UserVar. (refer below on how to use it!)
;      Default value: "" (meaning non-existant)
; Note: The Options for EditBoxes only apply if u don't use a custom function to handle
;       the drop event, meaning if u let the lib do the moving of the listbox item.
; For EditBoxes:
;   M: Specify M and afterwards either 0 or 1.
;      If you specified 0, the original text of the EditBox will be preserved and the
;      text of the Listbox's item will be added after (appended) the original EditBox text.
;      If you specified 1, the original text of the EditBox will be deleted, and
;      replaced with the listbox item's.
;      Default value: 1
;   Instead of using the M Option-Switch, the following substitutes can be used:
;      "add": Has the same effect as using M0
;      "del": Has the same effect as using M1
;   D: Used in conjuction with M1 or "add"!
;      Specify D and afterwards a string, that will be used as a Delimiter,
;      when text will be added to the EditBox. Can be a string of undefined length.
;      WARNING: Do not use a space character inside this string, or the options might
;      not be identified correctly. Use %A_Space% instead (inside the string),
;      like this: "D|%A_Space%|" would produce "| |" between the
;      EditBox's original text and the appended text (Note The "" are NOT included!)
;      Default value: " " (meaning A_Space!)
; Option-Switches that can be applied to any control:
;   O: Specify O and afterwards either 0 or 1.
;      (Note: This Option-Switch only applies if u use the lib's function to move item.
;             (Same note as with EditBoxes!!))
;      If you specified 0, the original listbox item will NOT be deleted if u drop it
;      onto the control that has this option set.
;      If you specified 1, the original listbox item will be deleted if u drop it onto
;      the control that has this option set.
;      Default value: 1
;   Instead of using the O Option-Switch, the following substitute can be used:
;      "NoRemove": Has the same effect as using O0
;      "Remove": Has the same effect as using O1
;   G: Specify G and afterwards a string containing the name of a Function (NOT a Label,
;      it must be a function), that will be called when the drop-event occurs!
;      The Function MUST NOT have any parameters!
;      (Note: You can specify different functions to different controls!)
;      To retrieve information on what listbox the item comes from, onto what control it's
;      item is dropped and what number the original item, and the insertion point has,
;      use the Provided function: LBDDLib_UserVar. (refer below on how to use it!)
;      If u only want to use this function to retrieve this info and don't want to do the
;      moving of the items yourself, use LBDDLib_CallBack at the end of your function.
;      Default value: "" (meaning non-existant)
; --------------------------------------

; LBDDLib_Modify(hWnd, Options)
; Modify the options that were set during adding of the control.
; Leave options blank to reset every option to its default value!
; --------------------------------------
; LBDDLib_ModifyGlobal(Options)
; Modify the Global Options set with LBDDLib_Init().
; --------------------------------------
; LBDDLib_Remove(hWnd)
; Removes a control from the internal list of possible drop targets.
; If it is a Listbox, then its subclassing wont be undone!
; --------------------------------------
; LBDDLib_ReplaceHandle(OldhWnd, NewhWnd)
; Replaces a control from the internal list of possible drop targets with a new one,
; retaining the set options! This is useful if the control is on a "dynamic" GUI, that is
; often destroyed and recreated.
; --------------------------------------
; LBDDLib_UserVar(Switch)
; Retrieve information on which listbox the item, was dragged from, what number it has,
; which control will recieve the drop and if that is a listbox, the number to insert the item,
; or if a drag event is occuring.
;
; Note: Only a handle will be retrieved, NOT the Variable associated with the control!
;       To compare two handles declare the variable containing the controls handle as Global
;       inside the function, and use this method to comapre them:
;
;       Global VarContainingControlHandle
;       if (VarContainingControlHandle+0 == VarcontainingRetrievedHandle)
;
;       The +0 is needed, because AutoHotKey stores the handle as Hex values,
;       and my Lib stores them as normal decimal values!
;
; The param can be any of the following (a number or a non case-sensitive string)
;   "ThWnd" or 1:
;     With this parameter the function returns the handle of the control, onto which
;     the item is dropped.
;   "ShWnd" or 2:
;     With this parameter the function returns the handle of the listbox, from which
;     the item originates.
;   "ItemToMove" or 3:
;     With this parameter the function returns the position-number of the item,
;     that is being dragged.
;   "NewPosition" or 4:
;     If the target of the Drag&Drop event is a listbox, then this parameter returns
;     the position-number of the target's listbox, into which the dragged item is to
;     be inserted. Otherwise it return the value -10.
;   "event" or 5:
;     This is only used with the custom-function assigned in the the V Option-Switch!
;     This returns 0 if the custom function is called to allow/disallow the start of a
;     drag-event.
;     This returns 1 if the custom function is called to allow/disallow the current
;     drag-event to be droped onto the control specified with the param "ThWnd"!
;     Otherwise this returns -10.
;     Other return values: (only applies for the Global functions, defined in LBDDLib_Init())
;     (Note the numbers will be used as default, unless the "UseEventNames" options is used
;     within the LBDDLib_Init() options.)
;       -9 or "Verify":
;         This means the v-Label function is called at the start of the Drag-Event.
;       -8 or "Hover":
;         This means the h-Label function is called during the Drag-Event.
;         The mouse is over a valid control, that accepts drops.
;         (Note: If the listbox has the "OnlySelf" option set, LBDDLib_UserVar("NewPosition")
;                will return -10 )
;       -7 or "OutOfBounds":
;       The following returns are used only used for the g-Label functions!
;       -6 or "Drop":
;         This means a Drop-Event occured onto an valid target.
;       -5 or "DropOutOfBounds":
;         This means a Drop-Event occured onto an InValid target.
;       -4 or "DragCancel":
;         The user aborted the Drag-Event, by pressing ESC or the right mouse button.
;   "isdrag" or 6:
;     This returns 1 if a drag-event is in progress, 0 otherwise.
; --------------------------------------
; LBDDLib_CallBack()
; If you specified a custom function that is called when the drop event occurs, but do not
; want to handle the moving of the item. The specified options will be considered this way!
; --------------------------------------
; LBDDLib_LBGetItemText(hWnd, Item)
; Wrapper function that retrieves the Text of an Item in an listbox, defined through its handle.
; --------------------------------------
; LBDDLib_LBDelItem(hWnd, Item)
; Wrapper function that deletes an Item in an listbox, defined through its handle.
; --------------------------------------
; LBDDLib_LBInsItem(hWnd, MyPos, MyText)
; Wrapper function that inserts an Item, defines through MyPos (the position to insert it)
; and MyText (the item-text) in an listbox, defined through its handle.

*/


LBDDLib_Init(Options=0){
  Static DRAGLISTMSGSTRING="commctrl_DragListMsg"
  OnMessage(DllCall("RegisterWindowMessage", "str", DRAGLISTMSGSTRING), "LBDDLib_msgFunc")
  LBDDLib_resetOptionsMain()
  if (Options <> 0)
    LBDDLib_parseOptionsMain(Options)
}

LBDDLib_Add(hWnd, Switch=0, Options=0){
  ArrayNum := LBDDLib_info("add", Switch, hWnd)
  if (Options == 0)
    return
  LBDDLib_parseOptions(ArrayNum, Options)
}

LBDDLib_Remove(hWnd){
  ArrayNum := LBDDLib_info("isvalid", hWnd)
  if (ArrayNum == 0)
    return
  LBDDLib_info("sethandle", ArrayNum)
}

LBDDLib_ReplaceHandle(OldhWnd, NewhWnd){
  ArrayNum := LBDDLib_info("isvalid", OldhWnd)
  if (ArrayNum == 0)
    return
  LBDDLib_info("sethandle", ArrayNum, NewhWnd)
}

LBDDLib_Modify(hWnd, Options=0){
  ArrayNum := LBDDLib_info("isvalid", hwnd)
  if (ArrayNum == 0)
    return
  if (Options == 0)
    LBDDLib_resetOptions(ArrayNum)
  else
    LBDDLib_parseOptions(ArrayNum, Options)
}

LBDDLib_ModifyGlobal(Options=0){
  if (Options == 0)
    LBDDLib_resetOptionsMain()
  else
    LBDDLib_parseOptionsMain(Options)
}

LBDDLib_UserVar(Switch){
  if ((Switch == 1) || (Switch = "ThWnd"))
    return LBDDLib_info("getuservar", 1)
  else if ((Switch == 2) || (Switch = "ShWnd"))
    return LBDDLib_info("getuservar", 2)
  else if ((Switch == 3) || (Switch = "ItemToMove"))
    return LBDDLib_info("getuservar", 3)
  else if ((Switch == 4) || (Switch = "NewPosition"))
    return LBDDLib_info("getuservar", 4)
  else if ((Switch == 5) || (Switch = "Event"))
    return LBDDLib_info("getuservar", 5)
  else if ((Switch == 6) || (Switch = "isDrag"))
    return LBDDLib_info("getuservar", 6)
  else
    return
}

LBDDLib_CallBack(){
  _ArrayNum := LBDDLib_info("getcallvar", 3)
  _Type := LBDDLib_info("get", _ArrayNum, "Type")
  if (_Type == 1)
    LBDDLib_moveLB2LB(LBDDLib_info("getcallvar", 1), LBDDLib_info("getcallvar", 4)
                    , LBDDLib_info("getcallvar", 2), _ArrayNum)
  else if (_Type == 2){
    LBDDLib_moveLB2EB(LBDDLib_info("getcallvar", 1), LBDDLib_info("getcallvar", 2), _ArrayNum)
  }
}

LBDDLib_LBGetItemText(hWnd, Item){
  Static LB_GETTEXT=0x189, LB_GETTEXTLEN=0x18A
  SendMessage, LB_GETTEXTLEN, Item, 0,, ahk_id %hWnd%
  VarSetCapacity(TempVar, ErrorLevel*( A_IsUnicode ? 2 : 1))
  SendMessage, LB_GETTEXT, Item, &TempVar,, ahk_id %hWnd%
  return TempVar
}

LBDDLib_LBDelItem(hWnd, Item){
  Static LB_DELETESTRING=0x182
  SendMessage, LB_DELETESTRING, Item, 0,, ahk_id %hWnd%
}

LBDDLib_LBInsItem(hWnd, MyPos, MyText){
  Static LB_INSERTSTRING=0x181
  SendMessage, LB_INSERTSTRING, MyPos, &MyText,, ahk_id %hWnd%
}

;-----------------------------------------------------------------------------------------
; Below here are the private functions. Only call these if you know what you are doing!!!
;-----------------------------------------------------------------------------------------

LBDDLib_info(switch="", p1="", p2="", p3=""){
  Static
  Static HWND_DESKTOP=0x0
  Local hWnd, rcListBox, rcount, tvar, tvar_0, tvar_1, tvar_2, tvar_3, tvar_4, tvar_5

  if (switch = "set"){
    LBDDLibArray_%p1%_%p2% := p3
  } else if (switch = "get"){
    return LBDDLibArray_%p1%_%p2%
  } else if (switch = "add"){
    tvar := 0
    Loop, %LBDDLibArray_0%
      if (LBDDLibArray_%A_Index% == 0)
        tvar := A_Index, break
    if not tvar {
      LBDDLibArray_0 ++
      tvar := LBDDLibArray_0
    }
    if ((p1 = 0) || (p1 = "DDLB"))
      DllCall("MakeDragList", "Uint", p2), p1 := 1
    else if ((p1 = "LB") || (p1 = "target") || (p1 = "droponly"))
      p1 := 1
    else if ((p1 = "EB") || (p1 = "editbox") || (p1 = "edit"))
      p1 := 2
    else if (p1 = "custom")
      p1 := 3
    LBDDLibArray_%tvar% := p2
    LBDDLibArray_%tvar%_Type := p1
    LBDDLib_resetOptions(tvar)
    return tvar
  } else if (switch = "sethandle") {
    LBDDLibArray_%p1% := p2
  } else if (switch = "isvalid") {
    p1 := p1+0
    tvar := 0
    Loop, %LBDDLibArray_0%
      if (LBDDLibArray_%A_Index% == p1)
        tvar := A_Index, break
    return tvar
  } else if (switch = "gethandle"){
    return LBDDLibArray_%p1%
  } else if (switch = "calcrect") {
    VarSetCapacity(rcListBox, 16, 0)
    Loop, %LBDDLibArray_0%
    {
      if (LBDDLibArray_%A_Index%_Type == 1){
        rcount ++
        hWnd := LBDDLibArray_%A_Index%
        DllCall("GetClientRect", "UInt", hWnd, "UInt", &rcListBox)
        DllCall("MapWindowPoints", "UInt", hWnd, "UInt", HWND_DESKTOP, "UInt", &rcListBox, "Int", 2)
        tvar := NumGet(rcListBox, 0, "Int")
        LBDDLibArrayRect_%rcount% := tvar
        tvar := NumGet(rcListBox, 4, "Int")
        tvar -= LBDDLibArray_%A_Index%_LBT
        tvar ++
        LBDDLibArrayRect_%rcount% .= "|"tvar
        tvar := NumGet(rcListBox, 8, "Int")
        LBDDLibArrayRect_%rcount% .= "|"tvar
        tvar := NumGet(rcListBox, 12, "Int")
        tvar += LBDDLibArray_%A_Index%_LBB
        tvar --
        LBDDLibArrayRect_%rcount% .= "|"tvar
        LBDDLibArrayRect_%rcount% .= "|"A_Index
      }
    }
    LBDDLibArrayRect_0 := rcount
  } else if (switch = "isvalidrect") {
    p3 := 0
    Loop, %LBDDLibArrayRect_0%
    {
      tvar := LBDDLibArrayRect_%A_Index%
      StringSplit, tvar_, tvar, |
      if (LBDDLib_ptInRect(tvar_1, tvar_2, tvar_3, tvar_4, p1, p2)){
        p3 := tvar_5
        break
      }
    }
    return p3
  } else if (switch = "setuservar") {
    LBDDLibUserVar_%p1% := p2
  } else if (switch = "getuservar") {
    return LBDDLibUserVar_%p1%
  } else if (switch = "setcallvar") {
    LBDDLibCallBackVar_%p1% := p2
  } else if (switch = "getcallvar") {
    return LBDDLibCallBackVar_%p1%
  }
}

LBDDLib_resetOptions(ArrayNum){
  Switch := LBDDLib_info("get", ArrayNum, "Type")
  LBDDLib_info("set", ArrayNum, "FuncG", "")
  LBDDLib_info("set", ArrayNum, "FuncV", "")
  LBDDLib_info("set", ArrayNum, "FuncH", "")
  LBDDLib_info("set", ArrayNum, "DeleteOrig", 1)
  if (Switch == 1) {
    LBDDLib_info("set", ArrayNum, "LBT", 20)
    LBDDLib_info("set", ArrayNum, "LBB", 20)
    LBDDLib_info("set", ArrayNum, "OnlySelf", 0)
    LBDDLib_info("set", ArrayNum, "Insert", 1)
    LBDDLib_info("set", ArrayNum, "InsertColor", 0)
    LBDDLib_info("set", ArrayNum, "ThickLine", 0)
  } else if (Switch == 2) {
    LBDDLib_info("set", ArrayNum, "AddModus", 1)
    LBDDLib_info("set", ArrayNum, "AddDelimiter", " ")
  }
}

LBDDLib_resetOptionsMain(){
  LBDDLib_info("set", 0, "FuncG", "")
  LBDDLib_info("set", 0, "FuncV", "")
  LBDDLib_info("set", 0, "FuncH", "")
  LBDDLib_info("set", 0, "Options", 1)
}

LBDDLib_parseOptionsMain(Options=0){
  Loop, Parse, Options, %A_Space%
  {
    if (A_LoopField = "UseEventNames")
      LBDDLib_info("set", 0, "Options", 0)
    if (A_LoopField = "UseEventNumbers")
      LBDDLib_info("set", 0, "Options", 1)
    if (SubStr(A_LoopField, 1, 1) = "g")
      LBDDLib_info("set", 0, "FuncG", SubStr(A_LoopField, 2))
    if (SubStr(A_LoopField, 1, 1) = "v")
      LBDDLib_info("set", 0, "FuncV", SubStr(A_LoopField, 2))
    if (SubStr(A_LoopField, 1, 1) = "h")
      LBDDLib_info("set", 0, "FuncH", SubStr(A_LoopField, 2))
  }
}

LBDDLib_parseOptions(ArrayNum, Options=0){
  Switch := LBDDLib_info("get", ArrayNum, "Type")
  Loop, Parse, Options, %A_Space%
  {
    if ((Switch == 1) && (A_LoopField = "global"))
      LBDDLib_info("set", ArrayNum, "OnlySelf", 0)
    else if ((Switch == 1) && (A_LoopField = "OnlySelf"))
      LBDDLib_info("set", ArrayNum, "OnlySelf", 1)
    else if ((Switch == 1) && (A_LoopField = "accept"))
      LBDDLib_info("set", ArrayNum, "OnlySelf", 2)
    else if ((Switch == 1) && (A_LoopField = "drop"))
      LBDDLib_info("set", ArrayNum, "OnlySelf", 2)
    else if ((Switch == 1) && (A_LoopField = "InsArrow"))
      LBDDLib_info("set", ArrayNum, "Insert", 1)
    else if ((Switch == 1) && (A_LoopField = "InsLine"))
      LBDDLib_info("set", ArrayNum, "Insert", 2)
    else if ((Switch == 1) && (A_LoopField = "InsArrowLine"))
      LBDDLib_info("set", ArrayNum, "Insert", 3)
    else if ((Switch == 1) && (A_LoopField = "ThickLine"))
      LBDDLib_info("set", ArrayNum, "ThickLine", 1)
    else if ((Switch == 1) && (A_LoopField = "NoThickLine"))
      LBDDLib_info("set", ArrayNum, "ThickLine", 0)
    else if ((Switch == 2) && (A_LoopField = "add"))
      LBDDLib_info("set", ArrayNum, "AddModus", 0)
    else if ((Switch == 2) && (A_LoopField = "del"))
      LBDDLib_info("set", ArrayNum, "AddModus", 1)
    else if (A_LoopField = "noremove")
      LBDDLib_info("set", ArrayNum, "DeleteOrig", 0)
    else if (A_LoopField = "remove")
      LBDDLib_info("set", ArrayNum, "DeleteOrig", 1)
    else if ((Switch == 1) && (SubStr(A_LoopField, 1, 1) = "t"))
      LBDDLib_info("set", ArrayNum, "LBT", SubStr(A_LoopField, 2))
    else if ((Switch == 1) && (SubStr(A_LoopField, 1, 1) = "b"))
      LBDDLib_info("set", ArrayNum, "LBB", SubStr(A_LoopField, 2))
    else if ((Switch == 1) && (SubStr(A_LoopField, 1, 1) = "s"))
      LBDDLib_info("set", ArrayNum, "OnlySelf", SubStr(A_LoopField, 2))
    else if ((Switch == 1) && (SubStr(A_LoopField, 1, 1) = "i"))
      LBDDLib_info("set", ArrayNum, "Insert", SubStr(A_LoopField, 2))
    else if ((Switch == 1) && (Asc(A_LoopField) = 35))
      LBDDLib_info("set", ArrayNum, "InsertColor", LBDDLib_cswap(SubStr(A_LoopField, 2)))
    else if ((Switch == 2) && (SubStr(A_LoopField, 1, 1) = "m"))
      LBDDLib_info("set", ArrayNum, "AddModus", SubStr(A_LoopField, 2))
    else if ((Switch == 2) && (SubStr(A_LoopField, 1, 1) = "d")){
      tmpvar := SubStr(A_LoopField, 2)
      StringReplace, tmpvar, tmpvar, `%A_Space`%, %A_Space%, A
      LBDDLib_info("set", ArrayNum, "AddDelimiter", tmpvar)
    } else if (SubStr(A_LoopField, 1, 1) = "o")
      LBDDLib_info("set", ArrayNum, "DeleteOrig", SubStr(A_LoopField, 2))
    else if (SubStr(A_LoopField, 1, 1) = "g")
      LBDDLib_info("set", ArrayNum, "FuncG", SubStr(A_LoopField, 2))
    else if (SubStr(A_LoopField, 1, 1) = "v")
      LBDDLib_info("set", ArrayNum, "FuncV", SubStr(A_LoopField, 2))
    else if (SubStr(A_LoopField, 1, 1) = "h")
      LBDDLib_info("set", ArrayNum, "FuncH", SubStr(A_LoopField, 2))
  }
}

LBDDLib_cswap(col){
  Static _Silver="C0C0C0", _Gray="808080", _Maroon="800000", _Red="FF0000"
  Static _Purple="800080", _Fuchsia="FF00FF", _Green="008000", _Lime="00FF00"
  Static _Olive="808000", _Yellow="FFFF00", _Navy="000080", _Blue="0000FF"
  Static _Teal="008080", _Aqua="00FFFF"
  if !col
    return
  if _%col%
    col := _%col%
  return "0x00" . SubStr(col,5,2) . SubStr(col,3,2) . SubStr(col,1,2)
}

LBDDLib_getVerifyEvent(EventNum){
  if (EventNum == -9)
    return "Verify"
  else if (EventNum == -8)
    return "Hover"
  else if (EventNum == -7)
    return "OutOfBounds"
  else if (EventNum == -6)
    return "Drop"
  else if (EventNum == -5)
    return "DropOutOfBounds"
  else if (EventNum == -4)
    return "DragCancel"
  else
    return -10
}

LBDDLib_drawInsert(hWnd, Switch, ArrayNum=0, ItemNum=0){
  Static LastUsedInsert, OldItemRect, OldLineRect, hArrow, oldhWnd=0
  Static LB_ERR=-1, LB_GETITEMRECT=0x198, LB_GETCOUNT=0x18B, LB_GETTOPINDEX=0x18E
  Static HWND_DESKTOP=0x0, RDW_INTERNALPAINT=0x2, RDW_ERASE=0x4, RDW_INVALIDATE=0x1, RDW_UPDATENOW=0x100
  Static PS_SOLID=0x0, COLOR_WINDOWTEXT=0x8
  Static DRAGICON_HOTSPOT_X=15, DRAGICON_HOTSPOT_Y=7, DRAGICON_HEIGHT=32

  if (Switch == 1){
    hArrowStr := "Shell32\ExtractIcon" . (A_IsUnicode ? "W" : "A")
    hArrow := DllCall(hArrowStr, "UInt", hWnd, "str", "comctl32.dll", "Int", 0)
    VarSetCapacity(OldItemRect, 16, 0)
    NumPut(0, OldItemRect, 0, "Int")
    NumPut(0, OldItemRect, 4, "Int")
    NumPut(0, OldItemRect, 8, "Int")
    NumPut(0, OldItemRect, 12, "Int")
    VarSetCapacity(OldLineRect, 16, 0)
    NumPut(0, OldLineRect, 0, "Int")
    NumPut(0, OldLineRect, 4, "Int")
    NumPut(0, OldLineRect, 8, "Int")
    NumPut(0, OldLineRect, 12, "Int")
    OldTopIndex := 0
    return
  } else if (Switch == -1){
    DllCall("DestroyIcon", "UInt", hArrow)
    DllCall("RedrawWindow", "UInt", hWnd, "UInt", &OldItemRect, "Int", 0, "UInt", RDW_INTERNALPAINT | RDW_ERASE | RDW_INVALIDATE | RDW_UPDATENOW)
    DllCall("RedrawWindow", "UInt", hWnd, "UInt", &OldLineRect, "Int", 0, "UInt", RDW_INTERNALPAINT | RDW_ERASE | RDW_INVALIDATE | RDW_UPDATENOW)
    return
  }
  if ((Switch == -2) || (ItemNum = -1)){
    if ((LastUsedInsert == 1) || (LastUsedInsert == 3))
      DllCall("RedrawWindow", "UInt", hWnd, "UInt", &OldItemRect, "Int", 0, "UInt", RDW_INTERNALPAINT | RDW_ERASE | RDW_INVALIDATE | RDW_UPDATENOW)
    if ((LastUsedInsert == 2) || (LastUsedInsert == 3))
      DllCall("RedrawWindow", "UInt", hWnd, "UInt", &OldLineRect, "Int", 0, "UInt", RDW_INTERNALPAINT | RDW_ERASE | RDW_INVALIDATE | RDW_UPDATENOW)
    NumPut(0, OldItemRect, 0, "Int")
    NumPut(0, OldItemRect, 4, "Int")
    NumPut(0, OldItemRect, 8, "Int")
    NumPut(0, OldItemRect, 12, "Int")
    NumPut(0, OldLineRect, 0, "Int")
    NumPut(0, OldLineRect, 4, "Int")
    NumPut(0, OldLineRect, 8, "Int")
    NumPut(0, OldLineRect, 12, "Int")
    return
  }

  if (Switch == -3)
    hWnd := oldhWnd
  LB_hWnd := LBDDLib_info("gethandle", ArrayNum)
  VarSetCapacity(rcItem, 16, 0)
  VarSetCapacity(rcListBox, 16, 0)
  VarSetCapacity(rcDragIcon, 16, 0)
  VarSetCapacity(rcDragLine, 16, 0)
  SendMessage, LB_GETCOUNT, 0, 0,, ahk_id %LB_hWnd%
  ItemCount := ErrorLevel-1
  if (ItemNum <= ItemCount)
    SendMessage, LB_GETITEMRECT, ItemNum, &rcItem,, ahk_id %LB_hWnd%
  else
    SendMessage, LB_GETITEMRECT, ItemCount, &rcItem,, ahk_id %LB_hWnd%
  if (ErrorLevel == LB_ERR)
    return
  if (ItemNum <= ItemCount)
    LB_ItemTop := NumGet(rcItem, 4, "Int")
  else
    LB_ItemTop := NumGet(rcItem, 12, "Int")
  if not DllCall("GetWindowRect", "UInt", LB_hWnd, "UInt", &rcListBox)
    return
  if not DllCall("MapWindowPoints", "UInt", LB_hWnd, "UInt", hWnd, "UInt", &rcItem, "Int", 2)
    return
  if not DllCall("MapWindowPoints", "UInt", HWND_DESKTOP, "UInt", hWnd, "UInt", &rcListBox, "Int", 2)
    return
  NumPut(NumGet(rcListBox, 0, "Int") - DRAGICON_HOTSPOT_X, rcDragIcon, 0, "Int")
  if (ItemNum <= ItemCount)
    NumPut(NumGet(rcItem, 4, "Int") - DRAGICON_HOTSPOT_Y, rcDragIcon, 4, "Int")
  else
    NumPut(NumGet(rcItem, 12, "Int") - DRAGICON_HOTSPOT_Y, rcDragIcon, 4, "Int")
  NumPut(NumGet(rcListBox, 0, "Int"), rcDragIcon, 8, "Int")
  NumPut(NumGet(rcDragIcon, 4, "Int") + DRAGICON_HEIGHT, rcDragIcon, 12, "Int")
  NumPut(NumGet(rcItem, 0, "Int"), rcDragLine, 0, "Int")
  NumPut(NumGet(rcItem, 4, "Int") - 5, rcDragLine, 4, "Int")
  NumPut(NumGet(rcItem, 8, "Int"), rcDragLine, 8, "Int")
  NumPut(NumGet(rcItem, 12, "Int") + 6, rcDragLine, 12, "Int")

  if (not DllCall("EqualRect", "UInt", &rcDragIcon, "UInt", &OldItemRect)){
    if ((LastUsedInsert == 1) || (LastUsedInsert == 3))
      DllCall("RedrawWindow", "UInt", hWnd, "UInt", &OldItemRect, "Int", 0, "UInt", RDW_INTERNALPAINT | RDW_ERASE | RDW_INVALIDATE | RDW_UPDATENOW)
    if ((LastUsedInsert == 2) || (LastUsedInsert == 3))
      DllCall("RedrawWindow", "UInt", hWnd, "UInt", &OldLineRect, "Int", 0, "UInt", RDW_INTERNALPAINT | RDW_ERASE | RDW_INVALIDATE | RDW_UPDATENOW)
    DllCall("CopyRect", "UInt", &OldItemRect, "UInt", &rcDragIcon)
    DllCall("CopyRect", "UInt", &OldLineRect, "UInt", &rcDragLine)
    oldhWnd := hWnd
    if (ItemNum >= 0){
      InsertType := LBDDLib_info("get", ArrayNum, "Insert")
      LastUsedInsert := InsertType
      if ((InsertType == 1) || (InsertType == 3)){
        hdc := DllCall("GetDC", "Uint", hWnd)
        DllCall("DrawIcon", "UInt", hdc, "Int", NumGet(rcDragIcon, 0, "Int"), "Int", NumGet(rcDragIcon, 4, "Int"), "UInt", hArrow)
        DllCall("ReleaseDC", "UInt", hWnd, "UInt", hdc)
      }
      if ((InsertType == 2) || (InsertType == 3)){
        if !(syscolor := LBDDLib_info("get", ArrayNum, "InsertColor"))
          syscolor := DllCall("GetSysColor", "UInt", COLOR_WINDOWTEXT)
        hdc := DllCall("GetDC", "Uint", LB_hWnd)
        hPen := DllCall("Gdi32\CreatePen", "UInt", PS_SOLID, "UInt", 1, "UInt", syscolor)
        DllCall("Gdi32\SelectObject", "UInt", hdc, "UInt", hPen)
        LB_Width := NumGet(rcDragLine, 8, "Int") - NumGet(rcDragLine, 0, "Int")
        ; InsertLine
        DllCall("Gdi32\MoveToEx", "UInt", hdc, "Int", 0, "Int", LB_ItemTop, "UInt", 0)
        DllCall("Gdi32\LineTo", "UInt", hdc, "Int", LB_Width, "Int", LB_ItemTop)
        DllCall("Gdi32\MoveToEx", "UInt", hdc, "Int", 0, "Int", LB_ItemTop-1, "UInt", 0)
        DllCall("Gdi32\LineTo", "UInt", hdc, "Int", LB_Width, "Int", LB_ItemTop-1)
        if (LBDDLib_info("get", ArrayNum, "ThickLine")){
          DllCall("Gdi32\MoveToEx", "UInt", hdc, "Int", 0, "Int", LB_ItemTop-2, "UInt", 0)
          DllCall("Gdi32\LineTo", "UInt", hdc, "Int", LB_Width, "Int", LB_ItemTop-2)
          DllCall("Gdi32\MoveToEx", "UInt", hdc, "Int", 0, "Int", LB_ItemTop+1, "UInt", 0)
          DllCall("Gdi32\LineTo", "UInt", hdc, "Int", LB_Width, "Int", LB_ItemTop+1)
          ; Arrow on the left
          DllCall("Gdi32\MoveToEx", "UInt", hdc, "Int", 0, "Int", LB_ItemTop-5, "UInt", 0)
          DllCall("Gdi32\LineTo", "UInt", hdc, "Int", 0, "Int", LB_ItemTop+4)
          DllCall("Gdi32\MoveToEx", "UInt", hdc, "Int", 1, "Int", LB_ItemTop-4, "UInt", 0)
          DllCall("Gdi32\LineTo", "UInt", hdc, "Int", 1, "Int", LB_ItemTop+3)
          DllCall("Gdi32\MoveToEx", "UInt", hdc, "Int", 2, "Int", LB_ItemTop-3, "UInt", 0)
          DllCall("Gdi32\LineTo", "UInt", hdc, "Int", 2, "Int", LB_ItemTop+2)
          ; Arrow on the right
          DllCall("Gdi32\MoveToEx", "UInt", hdc, "Int", LB_Width-1, "Int", LB_ItemTop-5, "UInt", 0)
          DllCall("Gdi32\LineTo", "UInt", hdc, "Int", LB_Width-1, "Int", LB_ItemTop+4)
          DllCall("Gdi32\MoveToEx", "UInt", hdc, "Int", LB_Width-2, "Int", LB_ItemTop-4, "UInt", 0)
          DllCall("Gdi32\LineTo", "UInt", hdc, "Int", LB_Width-2, "Int", LB_ItemTop+3)
          DllCall("Gdi32\MoveToEx", "UInt", hdc, "Int", LB_Width-3, "Int", LB_ItemTop-3, "UInt", 0)
          DllCall("Gdi32\LineTo", "UInt", hdc, "Int", LB_Width-3, "Int", LB_ItemTop+2)
        } else {
          ; Arrow on the left
          DllCall("Gdi32\MoveToEx", "UInt", hdc, "Int", 0, "Int", LB_ItemTop-3, "UInt", 0)
          DllCall("Gdi32\LineTo", "UInt", hdc, "Int", 0, "Int", LB_ItemTop+3)
          DllCall("Gdi32\MoveToEx", "UInt", hdc, "Int", 1, "Int", LB_ItemTop-2, "UInt", 0)
          DllCall("Gdi32\LineTo", "UInt", hdc, "Int", 1, "Int", LB_ItemTop+2)
          ; Arrow on the right
          DllCall("Gdi32\MoveToEx", "UInt", hdc, "Int", LB_Width-1, "Int", LB_ItemTop-3, "UInt", 0)
          DllCall("Gdi32\LineTo", "UInt", hdc, "Int", LB_Width-1, "Int", LB_ItemTop+3)
          DllCall("Gdi32\MoveToEx", "UInt", hdc, "Int", LB_Width-2, "Int", LB_ItemTop-2, "UInt", 0)
          DllCall("Gdi32\LineTo", "UInt", hdc, "Int", LB_Width-2, "Int", LB_ItemTop+2)
        }
        ; cleanup
        DllCall("Gdi32\DeleteObject", "UInt", hPen)
        DllCall("ReleaseDC", "UInt", hWnd, "UInt", hdc)
      }
    }
  }
}

LBDDLib_ptInRect(RLeft, RTop, RRight, RBottom, PX, PY){
  return (((PX >= RLeft) && (PX <= RRight)) && ((PY >= RTop) && (PY <= RBottom)))
}

LBDDLib_itemFromPt(ArrayNum, Mx, My, bAutoScroll, dwInterval=300){
  Static dwScrollTime=0, oldhWnd=0, t1=0, oldnIndex=0
  Static LB_ERR=-1, LB_GETITEMRECT=0x198, LB_GETCOUNT=0x18B, LB_GETTOPINDEX=0x18E, LB_SETTOPINDEX=0x197

  hWnd := LBDDLib_info("gethandle", ArrayNum)
  if (oldhWnd <> hWnd)
    t1:=0, oldhWnd:=hWnd
  VarSetCapacity(rcItem, 16, 0)
  VarSetCapacity(rcListBox, 16, 0)
  VarSetCapacity(pt, 8, 0)
  NumPut(Mx, pt, 0, "Int")
  NumPut(My, pt, 4, "Int")
  DllCall("ScreenToClient", "UInt", hWnd, "UInt", &pt)
  Mx := NumGet(pt, 0, "Int")
  My := NumGet(pt, 4, "Int")
  DllCall("GetClientRect", "UInt", hWnd, "UInt", &rcListBox)
  SendMessage, LB_GETTOPINDEX, 0, 0,, ahk_id %hWnd%
  nIndex := ErrorLevel
  SendMessage, LB_GETCOUNT, 0, 0,, ahk_id %hWnd%
  ItemCount := ErrorLevel-1
  if (ItemCount == -1)
    return 0
  if (LBDDLib_ptInRect(NumGet(rcListBox, 0, "Int"), NumGet(rcListBox, 4, "Int"), NumGet(rcListBox, 8, "Int"), NumGet(rcListBox, 12, "Int"), Mx, My)){
    Loop,
    {
      SendMessage, LB_GETITEMRECT, nIndex, &rcItem,, ahk_id %hWnd%
      if (ErrorLevel == LB_ERR){
        res := -1
        break
      }
      if (LBDDLib_ptInRect(NumGet(rcItem, 0, "Int"), NumGet(rcItem, 4, "Int"), NumGet(rcItem, 8, "Int"), NumGet(rcItem, 12, "Int"), Mx, My)){
        res := nIndex
        break
      }
      nIndex ++
      if (nIndex > ItemCount){
        res := nIndex
        break
      }
    }
    t1 := 0
    return res
  } else {
    if ((Mx > NumGet(rcListBox, 8, "Int")) || (Mx < NumGet(rcListBox, 0, "Int")))
      return -1
    if ((My < 0) && (My > (0-LBDDLib_info("get", ArrayNum, "LBT")))){
      res := nIndex
      nIndex --
      if (t1 = 0)
        t1 := 1
    } else {
      if ((My > NumGet(rcListBox, 12, "Int")) && (My < (NumGet(rcListBox, 12, "Int")+LBDDLib_info("get", ArrayNum, "LBB")))){
        tnIndex := nIndex
        Loop,
        {
          SendMessage, LB_GETITEMRECT, tnIndex, &rcItem,, ahk_id %hWnd%
          if (ErrorLevel == LB_ERR){
            tnIndex := -1
            break
          }
          if (tnIndex >= ItemCount)
            break
          if (LBDDLib_ptInRect(NumGet(rcItem, 0, "Int"), NumGet(rcItem, 4, "Int"), NumGet(rcItem, 8, "Int"), NumGet(rcItem, 12, "Int"), NumGet(rcListBox, 0, "Int")+2, NumGet(rcListBox, 12, "Int")-2))
            break
          tnIndex ++
        }
        res := tnIndex+1
        nIndex ++
        if (t1 = 0)
          t1 := 1
      } else
        res := -1
    }
    if (nIndex < 0)
      return 0
    if not bAutoScroll
      return res
    if ((A_TickCount - dwScrollTime) > dwInterval){
      dwScrollTime := A_TickCount
      if (t1 = 2){
        if (oldnIndex <> nIndex)
          LBDDLib_drawinsert(0, -3, ArrayNum, res)
        SendMessage, LB_SETTOPINDEX, nIndex, 0,, ahk_id %hWnd%
        oldnIndex := nIndex
      }
      if (t1 = 1)
        t1 := 2
    }
    return res
  }
  return -1
}

LBDDLib_msgFunc(wParam, lParam, uMsg, MsgParentWindow){
;Def of function parameters: http://www.autohotkey.com/docs/commands/OnMessage.htm
;Def of use of parameters: http://msdn.microsoft.com/en-us/library/bb761711(VS.85).aspx#drag_list_box_messages
  Static DL_BEGINDRAG=0x485, DL_DRAGGING=0x486, DL_DROPPED=0x487, DL_CANCELDRAG=0x488
  Static DL_STOPCURSOR=0x1, DL_COPYCURSOR=0x2, DL_MOVECURSOR=0x3
  Static DraggedItem, LBOnlySelf, SourceArrayNum, AllowedToDrag, hres
;  MsgParentWindow := WinExist()
;
; Use RtlMoveMemory, because lParam is only a pointer to a DRAGLISTINFO structure
; http://msdn.microsoft.com/en-us/library/bb761715(VS.85).aspx
;
  VarSetCapacity(lParam_Temp, 16, 0)
  DllCall("RtlMoveMemory", "UInt", &lParam_Temp, "UInt", lParam, "Int", 16)
  uNotification := NumGet(lParam_Temp, 0, "UInt")
  hWnd := NumGet(lParam_Temp, 4, "UInt")
  ptCursor_X := NumGet(lParam_Temp, 8, "Int")
  ptCursor_Y := NumGet(lParam_Temp, 12, "Int")
  SourceArrayNum := LBDDLib_info("isvalid", hwnd)
  if !SourceArrayNum
    return
  MouseGetPos,,, MyCustomWindowhWnd, MyCustomhWnd,2
  if (MyCustomWindowhWnd+0 <> MsgParentWindow+0)
    MsgParentWindow := MyCustomWindowhWnd+0
  if (uNotification == DL_BEGINDRAG){
    LBDDLib_info("setuservar", 6, 1)
    LBOnlySelf := LBDDLib_info("get", SourceArrayNum, "OnlySelf")
    DraggedItem := LBDDLib_itemFromPt(SourceArrayNum, ptCursor_X, ptCursor_Y, 0)
    GFuncLabel := LBDDLib_info("get", 0, "FuncV")
    if (GFuncLabel <> "")
      LBDDLib_callUser(GFuncLabel, SourceArrayNum, hWnd, DraggedItem, -10, -9)
    FuncLabel := LBDDLib_info("get", SourceArrayNum, "FuncV")
    res := True
    if (FuncLabel <> ""){
      res := LBDDLib_callUser(FuncLabel, SourceArrayNum, hWnd, DraggedItem, -10, 0)
    }
    if not res {
      AllowedToDrag := False
      return False
    } else {
      AllowedToDrag := True
      LBDDLib_drawInsert(MsgParentWindow, 1)
      LBDDLib_info("calcrect")
      return True
    }
  } else if (uNotification == DL_DRAGGING){
    if (AllowedToDrag == False)
      return
    CurrentArray := LBDDLib_info("isvalidrect", ptCursor_X, ptCursor_Y)
    if !CurrentArray {
      CurrentArray := LBDDLib_info("isvalid", MyCustomhWnd)
      if !CurrentArray {
        GFuncLabel := LBDDLib_info("get", 0, "FuncH")
        if (GFuncLabel <> "")
          LBDDLib_callUser(GFuncLabel, SourceArrayNum, hWnd, DraggedItem, -10, -7)
        LBDDLib_drawInsert(MsgParentWindow, -2)
        return DL_STOPCURSOR
      }
    }
    CurrentType := LBDDLib_info("get", CurrentArray, "Type")
    GFuncLabel := LBDDLib_info("get", 0, "FuncH")
    if (LBOnlySelf <> 0)
      if  (CurrentArray <> SourceArrayNum){
        if (GFuncLabel <> "")
          LBDDLib_callUser(GFuncLabel, CurrentArray, hWnd, DraggedItem, -10, -8)
        LBDDLib_drawInsert(MsgParentWindow, -2)
        return DL_STOPCURSOR
      }
    LBOnlySelfTarget := LBDDLib_info("get", CurrentArray, "OnlySelf")
    if (LBOnlySelfTarget == 1)
      if  (CurrentArray <> SourceArrayNum){
        LBDDLib_drawInsert(MsgParentWindow, -2)
        return DL_STOPCURSOR
      }
    FuncLabel := LBDDLib_info("get", CurrentArray, "FuncH")
    if (CurrentType == 1){
      CurrentItem := LBDDLib_itemFromPt(CurrentArray, ptCursor_X, ptCursor_Y, 1)
      if (GFuncLabel <> "")
        LBDDLib_callUser(GFuncLabel, CurrentArray, hWnd, DraggedItem, CurrentItem, -8)
      hres := True
      if (FuncLabel <> ""){
        hres := LBDDLib_callUser(FuncLabel, CurrentArray, hWnd, DraggedItem, CurrentItem, 1)
      }
      if not hres
      {
        LBDDLib_drawInsert(MsgParentWindow, -2)
        return DL_STOPCURSOR
      } else {
        LBDDLib_drawInsert(MsgParentWindow, 0, CurrentArray, CurrentItem)
        return DL_COPYCURSOR
      }
    } else {
      LBDDLib_drawInsert(MsgParentWindow, -2)
      if (GFuncLabel <> "")
        LBDDLib_callUser(GFuncLabel, CurrentArray, hWnd, DraggedItem, -10, -8)
      res := True
      if (FuncLabel <> ""){
        res := LBDDLib_callUser(FuncLabel, CurrentArray, hWnd, DraggedItem, -10, 1)
      }
      if not res
        return DL_STOPCURSOR
      else
        return DL_COPYCURSOR
    }
  } else if (uNotification == DL_CANCELDRAG){
    LBDDLib_info("setuservar", 6, 0)
    LBDDLib_drawInsert(MsgParentWindow, -1)
    GFuncLabel := LBDDLib_info("get", 0, "FuncG")
      if (GFuncLabel <> "")
        LBDDLib_callUser(GFuncLabel, SourceArrayNum, hWnd, DraggedItem, -10, -4)
  } else if (uNotification == DL_DROPPED){
    LBDDLib_info("setuservar", 6, 0)
    if (AllowedToDrag == False)
      return
    ValidhWnd := LBDDLib_info("isvalid", MyCustomhWnd)
    if (ValidhWnd == 0){
      ValidRect := LBDDLib_info("isvalidrect", ptCursor_X, ptCursor_Y)
      if (ValidRect == 0){
        GFuncLabel := LBDDLib_info("get", 0, "FuncG")
          if (GFuncLabel <> "")
            LBDDLib_callUser(GFuncLabel, SourceArrayNum, hWnd, DraggedItem, -10, -5)
        LBDDLib_drawInsert(MsgParentWindow, -1)
      } else {
        CurrentType := LBDDLib_info("get", ValidRect, "Type")
        CurrentArray := ValidRect
      }
    } else {
      CurrentType := LBDDLib_info("get", ValidhWnd, "Type")
      CurrentArray := ValidhWnd
    }
    LBDDLib_drawInsert(MsgParentWindow, -1)
    if (LBOnlySelf <> 0)
      if (CurrentArray <> SourceArrayNum)
        return
    LBDDLib_info("setcallvar", 1, DraggedItem)
    LBDDLib_info("setcallvar", 2, hWnd)
    LBDDLib_info("setcallvar", 3, CurrentArray)
    FuncLabel := LBDDLib_info("get", CurrentArray, "FuncG")
    GFuncLabel := LBDDLib_info("get", 0, "FuncG")
    LBOnlySelfTarget := LBDDLib_info("get", CurrentArray, "OnlySelf")
    if (LBOnlySelfTarget == 1)
      if (CurrentArray <> SourceArrayNum)
        return
    if (CurrentType == 1){
      CurrentItem := LBDDLib_itemFromPt(CurrentArray, ptCursor_X, ptCursor_Y, 0)
      LBDDLib_info("setcallvar", 4, CurrentItem)
      if (GFuncLabel <> "")
        LBDDLib_callUser(GFuncLabel, CurrentArray, hWnd, DraggedItem, CurrentItem, -6)
      if (FuncLabel <> "")
        LBDDLib_callUser(FuncLabel, CurrentArray, hWnd, DraggedItem, CurrentItem)
      else if hres
        LBDDLib_moveLB2LB(DraggedItem, CurrentItem, hWnd, CurrentArray)
    }
    else if (CurrentType == 2){
      if (GFuncLabel <> "")
        LBDDLib_callUser(GFuncLabel, CurrentArray, hWnd, DraggedItem, -10, -6)
      if (FuncLabel <> "")
        LBDDLib_callUser(FuncLabel, CurrentArray, hWnd, DraggedItem)
      else if hres
        LBDDLib_moveLB2EB(DraggedItem, hWnd, CurrentArray)
    }
    else if (CurrentType == 3){
      if (GFuncLabel <> "")
        LBDDLib_callUser(GFuncLabel, CurrentArray, hWnd, DraggedItem, -10, -6)
      if (FuncLabel <> "")
        LBDDLib_callUser(FuncLabel, CurrentArray, hWnd, DraggedItem)
    }
  }
}

LBDDLib_callUser(fName, ArrayNum, hWnd, DraggedItem, CurrentItem=-10, VerifyEvent=-10){
  Static UserF
  LBDDLib_info("setuservar", 1, LBDDLib_info("gethandle", ArrayNum))
  LBDDLib_info("setuservar", 2, hWnd)
  LBDDLib_info("setuservar", 3, DraggedItem)
  LBDDLib_info("setuservar", 4, CurrentItem)
  if ((VerifyEvent <> 0) && (VerifyEvent <> 1)){
    MyBool := LBDDLib_info("get", 0, "Options")
    if MyBool
      LBDDLib_info("setuservar", 5, VerifyEvent)
    else
      LBDDLib_info("setuservar", 5, LBDDLib_getVerifyEvent(VerifyEvent))
  } else
    LBDDLib_info("setuservar", 5, VerifyEvent)
  UserF := RegisterCallback(fName)
  res := DllCall(UserF)
  DllCall("GlobalFree", "Uint", UserF)
  return res
}

LBDDLib_moveLB2EB(ItemToMove, hWnd_source, ArrayNum){
  Static LB_GETTEXT=0x189, LB_GETTEXTLEN=0x18A, LB_DELETESTRING=0x182
  hWnd := LBDDLib_info("gethandle", ArrayNum)
  TempVar := LBDDLib_LBGetItemText(hWnd_source, ItemToMove)
  if (LBDDLib_info("get", ArrayNum, "DeleteOrig") == 1)
    LBDDLib_LBDelItem(hWnd_source, ItemToMove)
  if (LBDDLib_info("get", ArrayNum, "AddModus") == 0){
    ControlGetText, EditBoxText,, ahk_id %hWnd%
    if (EditBoxText <> "")
      EditBoxText .= LBDDLib_info("get", ArrayNum, "AddDelimiter")
    EditBoxText .= TempVar
    ControlSetText,, %EditBoxText%, ahk_id %hWnd%
  } else if (LBDDLib_info("get", ArrayNum, "AddModus") == 1){
    ControlSetText,, %TempVar%, ahk_id %hWnd%
  }
}

LBDDLib_moveLB2LB(ItemToMove, NewPosition, hWnd_source, ArrayNum){
  Static LB_GETTEXT=0x189, LB_GETTEXTLEN=0x18A
  Static LB_DELETESTRING=0x182, LB_INSERTSTRING=0x181, LB_SETCARETINDEX=0x19E
  if (NewPosition < 0)
    return
  hWnd_target := LBDDLib_info("gethandle", ArrayNum)
  TempVar := LBDDLib_LBGetItemText(hWnd_source, ItemToMove)
  if ((LBDDLib_info("get", ArrayNum, "DeleteOrig") == 1) || (hWnd_source == hWnd_target))
    LBDDLib_LBDelItem(hWnd_source, ItemToMove)
  if (hWnd_Source+0 == hWnd_target)
    if (ItemToMove < NewPosition)
      NewPosition --
  LBDDLib_LBInsItem(hWnd_target, NewPosition, TempVar)
  SendMessage, LB_SETCARETINDEX, NewPosition, 0,, ahk_id %hWnd_target%
}
