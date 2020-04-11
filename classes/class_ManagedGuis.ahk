/*
  Version: MPL 2.0/GPL 3.0/LGPL 3.0
  The contents of this file are subject to the Mozilla Public License Version
  2.0 (the "License"); you may not use this file except in compliance with
  the License. You may obtain a copy of the License at
  http://www.mozilla.org/MPL/
  Software distributed under the License is distributed on an "AS IS" basis,
  WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
  for the specific language governing rights and limitations under the License.
  The Initial Developer of the Original Code is
  Elgin <Elgin_1@zoho.eu>.
  Portions created by the Initial Developer are Copyright (C) 2010-2017
  the Initial Developer. All Rights Reserved.
  Contributor(s):
  Alternatively, the contents of this file may be used under the terms of
  either the GNU General Public License Version 3 or later (the "GPL"), or
  the GNU Lesser General Public License Version 3.0 or later (the "LGPL"),
  in which case the provisions of the GPL or the LGPL are applicable instead
  of those above. If you wish to allow use of your version of this file only
  under the terms of either the GPL or the LGPL, and not to allow others to
  use your version of this file under the terms of the MPL, indicate your
  decision by deleting the provisions above and replace them with the notice
  and other provisions required by the GPL or the LGPL. If you do not delete
  the provisions above, a recipient may use your version of this file under
  the terms of any one of the MPL, the GPL or the LGPL.
*/

; todo

; Menu, SB_ commads in status bar

#Include WindowsBase.ahk

class GuiManagerMainClass {
  ; variables for internal use only
  ; use properties to access the values
  Settings :=
  ManagedGuisByName := Object()
  ManagedGuisByHWND := Object()
  ManagedControls := Object()
  DefaultFont:=Object()

  __New(ManagedVariableObject="") {
    global GuiManagerCallback
    this.Settings := ManagedVariableObject
    GuiManagerCallback:=this
    ; retrieve Windows default font settings as AHK normally uses a different font and size
    ncm:=GetNONCLIENTMETRICS()
    If (IsObject(ncm)) {
      this.DefaultFont.Name:=ncm.lfMenuFont.lfFaceName
      this.DefaultFont.Size:=-ncm.lfMenuFont.lfHeight*72/A_ScreenDPI
      this.DefaultFont.Weight:=ncm.lfMenuFont.lfWeight
      this.DefaultFont.Italic:=ncm.lfMenuFont.lfItalic
      this.DefaultFont.Underline:=ncm.lfMenuFont.lfUnderline
      this.DefaultFont.StrikeOut:=ncm.lfMenuFont.lfStrikeOut
    }
  }

  NewGUI(GuiName, Title="", Options="") {
    this.ManagedGuisByName[GuiName]:=new ManagedGui(GuiName, this, Title, Options)
    this.ManagedGuisByHWND[this.ManagedGuisByName[GuiName].HWND]:=this.ManagedGuisByName[GuiName]
    return, this.ManagedGuisByName[GuiName]
  }

  ; Close gui GuiHwnd. GuiHwnd=0 to close all managed Guis.
  Close(GuiHwnd=0) {
    If (GuiHwnd=0) {
      ret:=0
      For HWND, ManagedGui in ManagedGuisByHWND
        ManagedGui.Close()
    }
    return, this.ManagedGuisByHWND[GuiHwnd].Close()
  }

  ContextMenu(GuiHwnd, CtrlHwnd, EventInfo, IsRightClick, X, Y) {
    return, this.ManagedGuisByHWND[GuiHwnd].ContextMenu(CtrlHwnd, EventInfo, IsRightClick, X, Y)
  }

  ControlEvent(CtrlHwnd="", GuiEvent="", EventInfo="", ErrorLvl="") {
    ;~ ToolTip, Hwnd: %CtrlHwnd%`nGuiEvent: %GuiEvent%`nEventInfo: %EventInfo%`nErrorLvl: %ErrorLvl%
    CallToFunc:=this.ManagedControls[CtrlHwnd].SendEvents
    %CallToFunc%(CtrlHwnd, GuiEvent, EventInfo, ErrorLvl)
  }

  DropFiles(GuiHwnd, FileArray, CtrlHwnd, X, Y) {
    return, this.ManagedGuisByHWND[GuiHwnd].DropFiles(FileArray, CtrlHwnd, X, Y)
  }

  Escape(GuiHwnd) {
    return, this.ManagedGuisByHWND[GuiHwnd].Escape()
  }

  Show(GuiName, Title="", Options="") {
    this.ManagedGuisByName[GuiName].Show(Title, Options)
  }

  Size(GuiHwnd, EventInfo, Width, Height) {
    return, this.ManagedGuisByHWND[GuiHwnd].Size(EventInfo, Width, Height)
  }

  Submit(GuiName, Hide=0) {
    return, this.ManagedGuisByName[GuiName].Submit(Hide)
  }

}

class ManagedGui {
  GuiManager:=""
  GuiHWND:=0
  GuiName:=""
  Title:=""
  Handlers:=Object()
  Handlers.OnClose:=Object()
  Handlers.OnContextMenu:=Object()
  Handlers.OnDropFiles:=Object()
  Handlers.OnEscape:=Object()
  Handlers.OnSize:=Object()
  Controls:=Object()
  AutoSize:=0
  AutoSizeReady:=0
  SizingInfo:=Object()

  __New(GuiName, GuiManager, Title="", Options="") {
    Gui, New, %Options% +HwndGuiHwnd, %Title%
    this.GuiManager := GuiManager
    this.GuiName:=GuiName
    this.GuiHWND:=GuiHwnd
    this.Title:=Title
    this.Font("S"this.GuiManager.DefaultFont.Size " W"this.GuiManager.DefaultFont.Weight " " (this.GuiManager.DefaultFont.Italic ? "italic " : "") (this.GuiManager.DefaultFont.Underline ? "underline " : "") (this.GuiManager.DefaultFont.StrikeOut ? "strike" : ""),this.GuiManager.DefaultFont.Name)
  }

  Add(ControlType, Name, Content="", Options="", GetEvents=0, GetData=0)
  {
    global
    local HWND, CNum
    HWND:=this.GuiHWND
    this.Controls.Push(Object())
    CNum:=this.Controls.MaxIndex()
    If (GetEvents)
    {
      Options.= " gManagedControlEventHandler"
    }
    If (GetData)
    {
      vVar:="ManagedGui" Name CNum
      Options.=" v" vVar
    }
    else
      vVar:=""
    Gui, %HWND%: Add, %ControlType%, %Options% +HwndControlHwnd, %Content%
    this.Controls[CNum]:=new Managed%ControlType%(ControlHwnd, Name, vVar, GetEvents, GetData)
    this.GuiManager.ManagedControls[ControlHwnd]:=this.Controls[CNum]
    return, this.Controls[CNum]
  }

  ; AddSizingInfo("X", "*", 1, "M", 0, "MyButton", 0, "C", 0, "*", 1, "M", 0)
  AddSizingInfo(Axis, params*)
  {
    If (Mod(params.MaxIndex(),4)<>0 or params.MaxIndex()<4)
      throw, "Invalid number of arguments passed to AddSizingInfo"
    If (SubStr(Axis,1,1)="X" or Substr(Axis,1,1)="Y")
    {
      tSizingInfo:=Object()
      tSizingInfo.Axis:=Axis
      tSizingInfo.Elements:=Object()
      v1:=""
      v2:=""
      v3:=""
      ; if first or last element is not a space add a margin sized space
      If (params[1]<>"*" and params[1]<>"0")
          tSizingInfo.Elements.Push({"ID":0,"Scale":0,"MinValue":"M","MaxValue":0})
      For index, value in params
      {
        If (v1<>"" and v2<>"" and v3<>"")
        {
          to:=Object()
          If !(IsObject(v1))
          {
            val:=v1
            v1:=Object()
            v1.Push(val)
          }
          for index, cc in v1
          {
            If cc is not integer
            {
              If (cc="*")
                v1[index]:=0
              for index2, control in this.Controls
              {
                if (control.Name=cc)
                  v1[index]:=control.HWND
              }
              If v1 is integer
              {
                throw "Invalid control passed to AddSizingInfo: " v1
              }
            }
          }
          to.ID:=v1
          to.Scale:=v2
          to.MinValue:=v3
          to.MaxValue:=value
          tSizingInfo.Elements.Push(to)
          v1:=""
          v2:=""
          v3:=""
        }
        else
        If (v1<>"" and v2<>"")
        {
          v3:=value
        }
        else
        If (v1<>"")
        {
          v2:=value
        }
        else
        {
          v1:=value
        }
      }
      ; if first or last element is not a space add a margin sized space
      If (params[params.MaxIndex()-3]<>"*" and params[params.MaxIndex()-3]<>"0")
          tSizingInfo.Elements.Push({"ID":0,"Scale":0,"MinValue":"M","MaxValue":0})
      LastElemWasSpacer:=0
      for index, element in tSizingInfo.Elements
      {
        if (element.id=0)
        {
          If(LastElemWasSpacer)
          {
            throw "Invalid sizing info passed. No more than one spacer between two controls allowed."
          }
          else
          {
            LastElemWasSpacer:=1
          }
        }
        else
        {
          LastElemWasSpacer:=0
        }
      }
      return this.AddSizingInfoByObj(tSizingInfo)
    }
    else
      throw "Invalid sizing info: " Axis
  }

  /*  Structure for SizingInfo object
  optional: Index for several SI o's in one object
  Axis:="X" or "Y"; nMin nMax to use current rule to set minimum/maximum size of GUI
  Elements:=Object()
  Elements[Index].ID:=single space */0 or array of "control name"/"hwnd"
  Elements[Index].Scale:=number  ; >0 relative scaling <0 absolute scaling
  Elements[Index].MinValue:=C/D/M/R/number ; C: calculated by CalculateSizingInfo on Show; D: elements are not resized but spaced evenly in the available space; M is set to current margin; R: use size of referenced control; number MinValue for scaling if >0; used as size if scale=0
  Elements[Index].MaxValue:="C"/number ; C: calculated by CalculateSizingInfo on Show; MaxValue for scaling if >0
  */
  AddSizingInfoByObj(InObj)
  {
    this.AutoSize:=1
    this.SizingInfo.Push(InObj)
    return this.SizingInfo.MaxIndex()
  }

  CalculateSizingInfo(SizingInfo)
  {
    HWND:=this.GuiHWND
    If (TryKey(SizingInfo, "Axis"))
    {
      ; get information of main window and prepare
      GuiRect:=GetClientRect(this.GuiHWND)
      Coords:=Object()
      If (SubStr(SizingInfo.Axis,1,1)="X")
      {
        Coords[0]:={"v":GuiRect.x, "e":0}
        Coords[SizingInfo.Elements.MaxIndex()]:={"v":GuiRect.w,"e":0}
        cv:="x"
        ce:="w"
        Margin:=Floor(this.GuiManager.DefaultFont.Size*1.25)
      }
      else
      {
        Coords[0]:={"v":GuiRect.y, "e":0}
        Coords[SizingInfo.Elements.MaxIndex()]:={"v":GuiRect.w,"e":0}
        cv:="y"
        ce:="h"
        Margin:=Floor(this.GuiManager.DefaultFont.Size*0.75)
      }
      ; get information about current real elements
      for index, elcontain in SizingInfo.Elements
      {
        vmax:=0
        emax:=0
        If (elcontain.MinValue="D")
        {
          Minval:=0
          for index, elem in elcontain.ID
          {
            GuiControlGet, cpos, Pos, % elem
            vmax:=vmax<cpos%cv% ? cpos%cv% : vmax
            Minval+=cpos%ce% + Margin
          }
          If (Minval)
            Minval-=Margin
          Coords[index]:={"v":vmax, "e":Minval}
        }
        else
        {
          for ind2, ehwnd in elcontain.ID
          {
            if (ehwnd<>0)
            {
              GuiControlGet, cpos, Pos, % ehwnd
              vmax:=vmax<cpos%cv% ? cpos%cv% : vmax
              emax:=emax<cpos%ce% ? cpos%ce% : emax
            }
          }
          Coords[index]:={"v":vmax, "e":emax}
        }
      }
      ; get information about spacer elements
      for index, element in SizingInfo.Elements
      {
        if (element.ID[1]=0)
        {
          Coords[index]:={"v":Coords[A_Index-1].v+Coords[A_Index-1].e, "e":Coords[A_Index+1].v-Coords[A_Index].v}
        }
      }
      ; calculate "C"/"M"/"R"
      for index, element in SizingInfo.Elements
      {
        if (element.Minvalue="C")
        {
          element.Minvalue:=Coords[index].e
        }
        if (element.Maxvalue="C")
        {
          element.Maxvalue:=Coords[index].e
        }
        if (element.Minvalue="M")
        {
          element.Minvalue:=Margin
        }
        if (element.Maxvalue="M")
        {
          element.Maxvalue:=Margin
        }
        if (Instr(element.Minvalue,"R")=1)
        {
          v:=Substr(element.Minvalue,2)
          If v is not integer
          {
            for index, control in this.Controls
            {
              if (control.Name=v)
                v:=control.HWND
            }
          }
          GuiControlGet, cpos, Pos, % v
          element.Minvalue:=cpos%ce%
        }
        if (element.Maxvalue="R")
        {
          v:=Substr(element.Minvalue,2)
          If v is not integer
          {
            for index, control in this.Controls
            {
              if (control.Name=v)
                v:=control.HWND
            }
          }
          GuiControlGet, cpos, Pos, % v
          element.Maxvalue:=cpos%ce%
        }
      }
      If (SubStr(SizingInfo.Axis,2)="Min")
      {
        size:=0
        for index, element in SizingInfo.Elements
        {
          If (element.MinValue="D")
          {
            size+=Coords[index].e
          }
          else
            size+=element.MinValue
        }
        If (SubStr(SizingInfo.Axis,1,1)="X")
        {
          Gui, %HWND%: +MinSize%size%x
        }
        else
          Gui, %HWND%: +MinSizex%size%
      }
      If (SubStr(SizingInfo.Axis,2)="Max")
      {
        size:=0
        for index, element in SizingInfo.Elements
        {
          size+=element.MaxValue
        }
        If (SubStr(SizingInfo.Axis,1,1)="X")
          Gui, %HWND%: +MaxSize%size%x
        else
          Gui, %HWND%: +MaxSizex%size%
      }

    }
    else
    If (IsObject(SizingInfo))
    {
      For index, obj in SizingInfo
        this.CalculateSizingInfo(obj)
    }
  }

  ContextMenu(CtrlHwnd, EventInfo, IsRightClick, X, Y)
  {
    If (this.OnContextMenuFunc)
    {
      return, %OnContextMenuFunc%(CtrlHwnd, EventInfo, IsRightClick, X, Y)
    }
    else
      return, 0
  }

  Cancel()
  {
    HWND:=this.GuiHWND
    Gui, %HWND%: Cancel
  }

  Close()
  {
    If (this.GuiManager.Settings)
    {
      WinGetPos, x, y, , , % "ahk_id " this.GuiHWND
      this.GuiManager.Settings[this.GuiName "_X"]:=x
      this.GuiManager.Settings[this.GuiName "_Y"]:=y
    }
    retval:=0
    for key, function in this.Handlers.OnClose
    {
      retval+=%function%()
    }
    return retval
  }

  Color(WindowColor="", ControlColor="")
  {
    HWND:=this.GuiHWND
    Gui, %HWND%: Color, %WindowColor%, %ControlColor%
  }

  Default()
  {
    HWND:=this.GuiHWND
    Gui, %HWND%: Default
  }

  Destroy()
  {
    HWND:=this.GuiHWND
    Gui, %HWND%: Destroy
  }

  DropFiles(FileArray, CtrlHwnd, X, Y)
  {
    for key, function in this.Handlers.OnDropFiles
    {
      %function%(FileArray, CtrlHwnd, X, Y)
    }
  }

  Escape()
  {
    If (this.GuiManager.Settings)
    {
      WinGetPos, x, y, , , % "ahk_id " this.GuiHWND
      this.GuiManager.Settings[this.GuiName "_X"]:=x
      this.GuiManager.Settings[this.GuiName "_Y"]:=y
    }
    retval:=0
    for key, function in this.Handlers.OnEscape
    {
      retval+=%function%()
    }
    return retval
  }

  Flash(Off=0)
  {
    HWND:=this.GuiHWND
    If (Off)
      Gui, %HWND%: Flash, Off
    else
      Gui, %HWND%: Flash
  }

  Font(Options="", FontName="")
  {
    HWND:=this.GuiHWND
    Gui, %HWND%: Font, %Options%, %FontName%
  }

  Hide()
  {
    HWND:=this.GuiHWND
    Gui, %HWND%: Hide
  }

  Margin(X="", Y="")
  {
    HWND:=this.GuiHWND
    Gui, %HWND%: Margin, %X%, %Y%
  }

  Maximize()
  {
    HWND:=this.GuiHWND
    Gui, %HWND%: Maximize
  }

  Menu(MenuName="")
  {
    HWND:=this.GuiHWND
    Gui, %HWND%: Menu, %MenuName%
  }

  Minimize()
  {
    HWND:=this.GuiHWND
    Gui, %HWND%: Minimize
  }

  Restore()
  {
    HWND:=this.GuiHWND
    Gui, %HWND%: Restore
  }

  SelectViewControl(Name)
  {
    For i, Control in this.Controls
    {
      If (Control.Name=Name)
      {
        HWND:=this.GuiHWND
        If (Control.ControlType="ListView")
        {
          Gui, %HWND%: ListView, % Name
        }
        else
        If (Control.ControlType="TreeView")
        {
          Gui, %HWND%: TreeView, % Name
        }
      }
    }
  }

  SetOption(Option)
  {
    HWND:=this.GuiHWND
    Gui, %HWND%: %Option%
  }

  Show(Title="", Options="")
  {
    HWND:=this.GuiHWND
    If (Title="")
    {
      If (this.Title="")
      {
        Title:=this.GuiName
      }
      else
      {
        Title:=this.Title
      }
    }
    else
    {
      this.Title:=Title
    }
    If (Options="" or Options="Minimize" or Options="Maximize" or Options="" or Options="Restore" or Options="NoActivate" or Options="NA" or Options="Hide")
    {
      If (this.GuiManager.Settings)
      {
        x:=this.GuiManager.Settings.CreateIni(this.GuiName "_X","empty", this.GuiName)
        y:=this.GuiManager.Settings.CreateIni(this.GuiName "_Y","empty", this.GuiName)
        w:=this.GuiManager.Settings.CreateIni(this.GuiName "_Width","empty", this.GuiName)
        h:=this.GuiManager.Settings.CreateIni(this.GuiName "_Height","empty", this.GuiName)
        If !IsInsideVisibleArea(x,y,w,h)
          x:=""
        if x is integer
          if y is integer
            if h is integer
              if w is integer
              {
                Options.=" X" x " Y" y " W" w " H" h
              }
              else
                Options.=" X" x " Y" y " H" h
            else
              Options.=" X" x " Y" y " AutoSize"
          else
            Options.=" X" x " yCenter AutoSize"
      }
      else
        Options.=" Center"
    }
    this.CalculateSizingInfo(this.SizingInfo)
    this.AutoSizeReady:=1
    GuiRect:=GetClientRect(this.GuiHWND)
    ;~ this.Size(0,GuiRect.w, GuiRect.h)
    Gui %HWND%: Show, %Options%, %Title%
  }

  Size(EventInfo, Width, Height)
  {
    If (this.GuiManager.Settings)
    {
      this.GuiManager.Settings[this.GuiName "_Width"]:=Width
      this.GuiManager.Settings[this.GuiName "_Height"]:=Height
    }
    If (this.AutoSize and this.AutoSizeReady)
    {
      this.SizeSet(this.SizingInfo, Width, Height)
    }
    for key, function in this.Handlers.OnSize
    {
      %function%(EventInfo, Width, Height)
    }
  }

  SizeSet(SizingInfo, Width, Height)
  {
    HWND:=this.GuiHWND
    If (TryKey(SizingInfo, "Axis"))
    {
      If (SubStr(SizingInfo.Axis,1,1)="X")
      {
        WinExtent:=Width
        cv:="x"
        ce:="w"
        Margin:=this.GuiManager.DefaultFont.Size*1.25
      }
      else
      {
        WinExtent:=Height
        cv:="y"
        ce:="h"
        Margin:=this.GuiManager.DefaultFont.Size*0.75
      }
      ; iterate positions
      SizeSet:=Object()
      for index, element in SizingInfo.Elements
      {
        SizeSet[index]:=Object()
        SizeSet[index].Extent:=0
        SizeSet[index].Fixed:=0
      }
      Loop,
      {
        ; set all non-fixed elements to MinValue
        for index, element in SizingInfo.Elements
        {
          If !(SizeSet[index].Fixed)
          {
            If (element.MinValue="D")
            {
              Minval:=0
              for index, elem in element.ID
              {
                GuiControlGet, cpos, Pos, % elem
                Minval+=cpos%ce% + Margin
              }
              If (Minval)
                Minval-=Margin
              SizeSet[index].Extent:=MinVal
              SizeSet[index].Fixed:=0
            }
            else
            {
              SizeSet[index].Extent:=element.MinValue
              SizeSet[index].Fixed:=0
              If (element.Scale=0)
              {
                SizeSet[index].Fixed:=1
              }
              If (element.Scale<0)
              {
                SizeSet[index].Extent:=-Round(WinExtent*element.Scale/100)
                If (element.Maxvalue>0 and SizeSet[index].Extent>element.Maxvalue)
                  SizeSet[index].Extent:=element.Maxvalue
                SizeSet[index].Fixed:=1
              }
            }
          }
        }
        ; calculate available rubber
        rv:=WinExtent
        rub:=0
        for index, element in SizingInfo.Elements
        {
          rv-=SizeSet[index].Extent
          If (element.Scale>0)
            rub+=element.Scale
        }
        if (rv<0)
          rv:=0
        rubber:=Round(rv/rub)
        ; calculate extents with rubber
        for index, element in SizingInfo.Elements
        {
          If (element.Scale>0)
          {
            SizeSet[index].Extent+=rubber*element.Scale
          }
        }
        ; check if anything got too big
        rerun:=0
        for index, element in SizingInfo.Elements
        {
          If (element.Scale>0)
          {
            If (element.Maxvalue>0 and SizeSet[index].Extent>element.Maxvalue)
            {
              SizeSet[index].Extent:=element.Maxvalue
              SizeSet[index].Fixed:=1
              rerun:=1
            }
          }
        }
      } until rerun=0
      ; set the positions
      vpos:=0
      for index, element in SizingInfo.Elements
      {
        If (element.ID[1]=0)
        {
          vpos+=SizeSet[index].Extent
        }
        else
        {
          If (element.MinValue="D")
          {
            Midspacing:=SizeSet[index].Extent/(element.ID.Maxindex())
            ; check if elements can be placed with their centers evenly distributed
            ; if not distribute with even spacing inbetween
            distribute:=1
            for index2, elem in element.ID
            {
              GuiControlGet, cpos, Pos, % elem
              If (index2=1 or index2=element.ID.Maxindex())
              {
                If ((cpos%ce%+Margin)>Midspacing)
                  distribute:=0
              }
              else
              If (index2>1)
              {
                If ((savesize+cpos%ce%)/2>Midspacing)
                  distribute=0
              }
              savesize:=cpos%ce%
            }
            If (distribute)
            {
              dpos:=vpos+Midspacing/2
              for index2, elem in element.ID
              {
                GuiControlGet, cpos, Pos, % elem
                GuiControl, % this.GuiManager.ManagedControls[elem].MoveMode, %elem%, % cv dpos-(cpos%ce%/2)
                dpos+=Midspacing
              }
            }
            else
            {
              Minval:=0
              for index, elem in element.ID
              {
                GuiControlGet, cpos, Pos, % elem
                Minval+=cpos%ce% + Margin
              }
              If (Minval)
                Minval-=Margin
              Drubber:=(SizeSet[index].Extent-Minval)/(element.ID.Maxindex()+1)
              dpos:=vpos+Drubber
              for index2, elem in element.ID
              {
                GuiControl, % this.GuiManager.ManagedControls[elem].MoveMode, %elem%, % cv dpos
                GuiControlGet, cpos, Pos, % elem
                dpos+=cpos%ce% + DRubber + Margin
              }
            }
          }
          else
          {
            for index2, elem in element.ID
            {
              GuiControl, % this.GuiManager.ManagedControls[elem].MoveMode, %elem%, % cv vpos " " ce SizeSet[index].Extent
            }
          }
          vpos+=SizeSet[index].Extent
        }
      }
    }
    else
    If (IsObject(SizingInfo))
    {
      For index, obj in SizingInfo
      {
        this.SizeSet(obj, Width, Height)
      }
    }
  }

  Submit(Hide=0)
  {
    global
    local Options, HWND, RetObj, Index, Control, Var
    HWND:=this.GuiHWND
    If !(Hide)
      Options:="NoHide"
    else
      Options:=""
    Gui %HWND%: Submit, %Options%
    RetObj:=Object()
    for Index, Control in this.Controls
    {
      If (this.Controls[Index]["SubmitTo"])
      {
        Var:=Control["Var"]
        RetObj[this.Controls[Index]["SubmitTo"]]:=%Var%
      }
    }
    return, RetObj
  }

  HWND[]
  {
    get
    {
      return, this.GuiHWND
    }

    set
    {
      return, this.GuiHWND
    }
  }

  Name[]
  {
    get
    {
      return, this.GuiName
    }

    set
    {
      return, this.GuiName
    }
  }

  OnClose[]
  {
    Get
    {
      return, this.Handlers.OnClose.MaxIndex
    }

    Set
    {
      return, this.Handlers.OnClose.Push(value)
    }
  }

  OnContextMenu[]
  {
    Get
    {
      return, this.Handlers.OnContextMenu.MaxIndex
    }

    Set
    {
      return, this.Handlers.OnContextMenu.Push(value)
    }
  }

  OnDropFiles[]
  {
    Get
    {
      return, this.Handlers.OnDropFiles.MaxIndex
    }

    Set
    {
      return, this.Handlers.OnDropFiles.Push(value)
    }
  }

  OnEscape[]
  {
    Get
    {
      return, this.Handlers.OnEscape.MaxIndex
    }

    Set
    {
      return, this.Handlers.OnEscape.Push(value)
    }
  }

  OnSize[]
  {
    Get
    {
      return, this.Handlers.OnSize.MaxIndex
    }

    Set
    {
      return, this.Handlers.OnSize.Push(value)
    }
  }
}

class ManagedButton extends ManagedControl {
}

class ManagedText extends ManagedControl {
}

class ManagedEdit extends ManagedControl {
}

class ManagedUpDown extends ManagedControl {
}

class ManagedPicture extends ManagedControl {
}

class ManagedCheckBox extends ManagedControl {
}

class ManagedRadio extends ManagedControl {
}

class ManagedDropDownList extends ManagedControl {
}

class ManagedComboBox extends ManagedControl {
}

class ManagedListBox extends ManagedControl {
}

class ManagedLink extends ManagedControl {
}

class ManagedHotkey extends ManagedControl {
}

class ManagedDateTime extends ManagedControl {
}

class ManagedMonthCal extends ManagedControl {
}

class ManagedSlider extends ManagedControl {
}

class ManagedProgress extends ManagedControl {
}

class ManagedGroupBox extends ManagedControl {
}

class ManagedTab2 extends ManagedControl {
}

class ManagedStatusBar extends ManagedControl {
}

class ManagedActiveX extends ManagedControl {
  __New(ControlHwnd, Name, vVar, GetEvents="", GetData="")
  {
    base.__New(ControlHwnd, Name, vVar, GetEvents, GetData)
    this.EmbeddedControl:=%vVar%
  }
}

class ManagedCustom extends ManagedControl {
}

class ManagedListView extends ManagedControl {
  Add(param*)
  {
    return LV_Add(param*)
  }

  Delete(param*)
  {
    return LV_Delete(param*)
  }

  DeleteCol(ColumnNumber)
  {
    return LV_DeleteCol(ColumnNumber)
  }

  GetCount(param*)
  {
    return LV_GetCount(param*)
  }

  GetNext(param*)
  {
    return LV_GetNext(param*)
  }

  GetText(byref OutputVar, RowNumber, param*)
  {
    return LV_GetText(OutputVar, RowNumber, param*)
  }

  Insert(RowNumber, param*)
  {
    return LV_Insert(RowNumber, param*)
  }

  InsertCol(ColumnNumber, param*)
  {
    return LV_InsertCol(ColumnNumber, param*)
  }

  Modify(RowNumber, Options, NewCol*)
  {
    return LV_Modify(RowNumber, Options, NewCol*)
  }

  ModifyCol(param*)
  {
    return LV_ModifyCol(param*)
  }

  SetImageList(ImageListID, param*)
  {
    return LV_SetImageList(ImageListID, Option)
  }
}

class ManagedExtendedTreeView extends ManagedTreeView {
  Resources:=Object()

  Add(Name, ParentItemID=0, Options="", Resource="")
  {
    Item:=base.Add(Name, ParentItemID, Options)
    this.Resources[Item]:=Object()
    this.Resources[Item]["Depth"]:=this.Resources[ParentItemID]["Depth"]+1
    this.Resources[Item]["Name"]:=Name
    this.Resources[Item]["Resource"]:=Resource
    return Item
  }

  FindInName(SearchText, addline=1)
  {
    fr:=TV_GetSelection()
    frs:=fr
    Loop, %addline%
    {
      frs:=TV_GetNext(frs, "Full")
    }
    found:=0
    while (frs<>0)
    {
      TV_GetText(Output, frs)
      if (InStr(Output, SearchText))
      {
        found:=1
        break
      }
      frs:=TV_GetNext(frs, "Full")
    }
    if (!found)
    {
      frs:=TV_GetNext()
      while (frs<>fr)
      {
        TV_GetText(Output, frs)
        if (InStr(Output, SearchText))
        {
          found:=1
          break
        }
        frs:=TV_GetNext(frs, "Full")
      }
    }
    if (found)
    {
      return frs
    }
    else
    {
      return 0
    }
  }

  GetResource(Item=0)
  {
    return Reources[Item]["Resource"]
  }

  GetDepth(Item=0)
  {
    return Reources[Item]["Depth"]
  }

  Modify(ItemID, Options="", NewName="")
  {
    If (NewName<>"")
    {
      this.Resources[ItemID]["Name"]:=NewName
    }
    return TV_Modify(ItemID, Options, NewName)
  }

}

class ManagedTreeView extends ManagedControl {
  Add(Name, ParentItemID=0, Options="")
  {
    return TV_Add(Name, ParentItemID, Options)
  }

  Delete(ItemID="")
  {
    return TV_Delete(ItemID)
  }

  Get(ItemID, Attribute="")
  {
    return TV_Get(ItemID, Attribute)
  }

  GetChild(ParentItemID)
  {
    return TV_GetChild(ParentItemID)
  }

  GetCount()
  {
    return TV_GetCount()
  }

  GetNext(ItemID=0, Attribute="")
  {
    return TV_GetNext(ItemID, Attribute)
  }

  GetParent(ItemId)
  {
    return TV_GetParent(ItemId)
  }

  GetPrev(ItemID)
  {
    return TV_GetPrev(ItemID)
  }

  GetSelection()
  {
    return TV_GetSelection()
  }

  GetText(byref OutputVar, ItemID)
  {
    return TV_GetText(OutputVar, ItemID)
  }

  Modify(ItemID, Options="", NewName="")
  {
    return TV_Modify(ItemID, Options, NewName)
  }
}

class ManagedControl {
  MoveMode:="Move"

  __New(ControlHwnd, Name, vVar="", GetEvents="", GetData="")
  {
    this.HWND:=ControlHwnd
    this.Name:=Name
    this.Type:=SubStr(this.__Class,8)
    this.SendEvents:=GetEvents
    this.SubmitTo:=GetData
    this.Var:=vVar
  }

  Control(SubCommand="", Param3="")
  {
    GuiControl, %SubCommand%, % this.HWND, %Param3%
  }

  ControlGet(SubCommand="", Param4="")
  {
    GuiControlGet, OutputVar, %SubCommand%, % this.HWND, %Param4%
    If (SubCommand="Pos")
    {
      TempOut:=Object()
      tempOut.X:=OutputVarX
      tempOut.Y:=OutputVarY
      tempOut.W:=OutputVarW
      tempOut.H:=OutputVarH
    }
    else
    return OutputVar
  }
}


ManagedControlEventHandler(CtrlHwnd="", GuiEvent="", EventInfo="", ErrorLvl="") {
  global GuiManagerCallback
  GuiManagerCallback.ControlEvent(CtrlHwnd, GuiEvent, EventInfo, ErrorLvl)
}

GuiClose(GuiHwnd) {
  global GuiManagerCallback
  return, GuiManagerCallback.Close(GuiHwnd)
}

GuiEscape(GuiHwnd) {
  global GuiManagerCallback
  return, GuiManagerCallback.Escape(GuiHwnd)
}

GuiSize(GuiHwnd, EventInfo, Width, Height) {
  global GuiManagerCallback
  return, GuiManagerCallback.Size(GuiHwnd, EventInfo, Width, Height)
}

GuiContextMenu(GuiHwnd, CtrlHwnd, EventInfo, IsRightClick, X, Y) {
  global GuiManagerCallback
  return, GuiManagerCallback.ContextMenu(GuiHwnd, CtrlHwnd, EventInfo, IsRightClick, X, Y)
}

GuiDropFiles(GuiHwnd, FileArray, CtrlHwnd, X, Y) {
  global GuiManagerCallback
  return, GuiManagerCallback.DropFiles(GuiHwnd, FileArray, CtrlHwnd, X, Y)
}

/*
Gui commands:
-------------
GuiCreate([Title, Options, FuncPrefixOrObj])
  Creates a new Gui object (Same as v1 Gui, New).
  The third parameter specifies the function prefix or object to bind events to.
  If a function prefix is specified, Gui events such as OnClose or OnDropFiles are automatically bound.
  If an object is specified, it is used as an event sink; meaning event names are used as method names
  to invoke on the object.
  This mechanism is both similar to that of ComObjConnect() and the old v1 +Label system.
GuiFromHwnd(Hwnd [, RecurseParent := false])
  Returns the Gui object associated with the specified Gui HWND.
  If RecurseParent is true, the closest parent to the specified HWND that is a Gui is automatically
  searched for and retrieved.
GuiCtrlFromHwnd(Hwnd)
  Returns the Gui Control object associated with the specified Gui Control HWND.
Gui object:
-----------
gui.Destroy()
  Destroys the window. Same as v1 Gui, Destroy.
  If the Gui is closed and there are no references to the Gui object, the Gui is destroyed.
gui.Add(Ctrl [, Text, Options])
gui.AddCtrl([Text, Options]) where Ctrl is a valid control type
  Adds a new control to the Gui. (Text was renamed to Label).
  In v1.x, some control types such as ListView accept a string with a changeable delimiter (by default |).
  In v2, arrays are also supported, and this obviates the need to support changing the delimiter.
  The g-label option now specifies the function or method name to call in order to receive
  events from the control (equivalent to v1 g-labels).
  The 'v' option is now repurposed to give an explicit name to the control, instead of binding a variable.
  For Button controls, if the g-label is omitted, the same v1 transformation rules are applied to
  automatically generate a function or method name (expanded to accomodate for stricter identifier
  names).
  Returns a GuiControl object.
gui.Show([Options, Title])
  Same as v1 Gui, Show
gui.Submit([Hide := false])
  Returns an associative array containing the values of all the controls that have been explicitly named.
  Similar to v1 Gui, Submit
gui.Hide()
gui.Cancel()
  Same as v1 Gui, Hide (Cancel)
gui.SetFont([Options, FontName])
  Same as v1 Gui, Font
gui.BgColor := color
gui.CtrlColor := color
  Same as v1 Gui, Color
gui.MarginX := value
gui.MarginY := value
  Same as v1 Gui, Margin
gui.Opt(options)
gui.Options(options)
  Same as v1 Gui +/-Option1 +/-Option2
gui.Menu := menuObj
  Same as v1 Gui, Menu
gui.Hide()
gui.Minimize()
gui.Maximize()
gui.Restore()
  Same as v1 Gui, Hide/Minimize/Maximize/Restore
gui.Flash([onOrOff := true])
  Same as v1 Gui, Flash [, Off]
gui.Hwnd
  Retrieves the Gui's Hwnd
gui.Title
  Sets or retrieves the Gui's title
gui.Control[Name]
  Retrieves the GuiControl object associated with the specified name, ClassNN or HWND.
  Compare:
    GuiControl,, Static1, SomeValue
    gui.Control["Static1"].Value := "SomeValue"
gui._NewEnum()
  Iterates through the Gui's controls.
  The first output variable is the HWND, and the second is the control object.
gui.OnClose
gui.OnEscape
gui.OnSize
gui.OnContextMenu
gui.OnDropFiles
  These properties can be get/set in order to change the event handlers, especially for
  binding an arbitrary callable object.
Events:
OnClose(gui)
OnEscape(gui)
OnSize(gui, eventInfo, width, height)
OnContextMenu(gui, control, eventInfo, isRightClick, x, y)
OnDropFiles(gui, fileArray, control, x, y)
OnClose now has a return value. If OnClose() returns a false value (such as nothing), the Gui is closed
(as if the OnClose event handler did not exist). If it returns a true value, the Gui is not closed.
GuiControl object
-----------------
ctrl.Type
  Retrieves the type of the control. (Not implemented yet)
ctrl.Hwnd
  Retrieves the HWND of the control.
ctrl.Name
  Retrieves or sets the explicit name of the control.
ctrl.ClassNN
  Retrieves the ClassNN of the control.
ctrl.Gui
  Retrieves the control's Gui parent.
ctrl.Event
  Retrieves or sets the control's event handler, which can be either a function/method name
  or an arbitrary callable object.
ctrl.Opt(options)
ctrl.Options(options)
  Same as v1 GuiControl, +/-Option1 +/-Option2
ctrl.Move(pos[, draw:=false])
  Same as v1 GuiControl Move(Draw)
ctrl.Focus()
  Same as v1 GuiControl Focus
ctrl.Choose(Value [, additionalActions := 0])
  Same as v1 GuiControl Choose(String). If Value is a pure integer, it is an item index;
  otherwise it is treated as the item text. additionalActions replaces the pipe-prepending
  mechanism of the v1 command (instead of prepending N pipes, this parameter is set to N).
ctrl.UseTab([Value, exactMatch := false])
  Same as v1 Gui Tab. If Value is a pure intege, it is a tab index; otherwise it is text.
  Omit all parameters to stop adding controls inside this Tab control.
ctrl.Value
  Same as v1 GuiControl/Get with no subcommand
ctrl.Text
  Same as v1 GuiControl/Get Text
ctrl.Enabled
  Specifies whether the user can interact with the control
ctrl.Visible
  Same as v1 GuiControl/Get Visible
ctrl.Focused
  Same as v1 GuiControlGet Focused
ctrl.Pos
  Returns the position in an object containing x,y,w,h fields.
Control event function:
  ControlEvent(ctrl, guiEvent, eventInfo, extra)
  The 'extra' parameter is only passed on Link or Custom control events.
LV_/TV_/SB_ functions are now methods of LV/TV/SB control objects.
tv.GetText() and lv.GetText() now return the text directly instead of having an
OutputVar (failure results in an exception being thrown).
-------------------------------------------------------------------------------
; Converted Example: Simple image viewer:
GuiCreate gui, ImageViewer, Resize, MyGui_
gui.AddButton &Load New Image, Default
radio := gui.AddRadio("Load &actual size", "ym+5 x+10 checked")
gui.AddRadio Load to &fit screen, ym+5 x+10
pic := gui.AddPic(, "xm")
gui.Show()
; Due to v2's Persistence rules, it is no longer necessary to include a
; GuiClose() { ExitApp } event handler in order for the script to properly close.
MyGui_ButtonLoadNewImage() ; using automatic event handler name
{
  global gui, radio, pic
  FileSelect file, a,, Select an image:, Images (*.gif; *.jpg; *.bmp; *.png; *.tif; *.ico; *.cur; *.ani; *.exe; *.dll)
  if !file
    return
  if radio.Value = 1 ; Display image at its actual size.
  {
    Width := 0
    Height := 0
  }
  else ; Second radio is selected: Resize the image to fit the screen.
  {
    Width := A_ScreenWidth - 28  ; Minus 28 to allow room for borders and margins inside.
    Height := -1  ; "Keep aspect ratio" seems best.
  }
  pic.Value := "*w%width% *h%height% %file%"  ; Load the image.
  gui.Show xCenter y0 AutoSize, %file% - Image Viewer  ; Resize the window to match the picture size.
}
-----------------------------------------------------------------------
; Converted Example: A moving progress bar overlayed on a background image.
GuiCreate gui, Progress Example,, MyGui_
gui.BgColor := "White"
gui.AddPicture %A_WinDir%\system32\ntimage.gif, x0 y0 h350 w450
gui.AddButton Start the Bar Moving, Default xp+20 yp+250
MyProgress := gui.AddProgress(, "w416")
MyText := gui.AddLabel(, "wp")  ; wp means "use width of previous".
gui.Show()
MyGui_ButtonStartTheBarMoving()
{
  global MyProgress, MyText
  Loop Files, %A_WinDir%\*.*
  {
    if A_Index > 100
      break
    MyProgress.Value := A_Index
    MyText.Value := A_LoopFileName
    Sleep 50
  }
  MyText.Value := "Bar finished."
}
© 2018 GitHub, Inc.
Terms
Privacy
Security
Status
Help
Contact GitHub
API
Training
Shop
Blog
About
Press h to open a hovercard with more details.