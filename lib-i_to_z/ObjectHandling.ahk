; ==============================================================================
; ==============================================================================
; Object handling functions
;
; object EnsureObj(BaseObject, params*)
; boolean TryKey(BaseObject, params*)
; boolean TryObj(ByRef BaseObject, params*)
; integer ObjGetCount(BaseObject)
; ObjMerge(SourceObject, TargetObject, Mode="", CallBack="")
;
; string ObjToStr(ByRef InObject)
; string ObjToXML(InObject)
; XMLToObj(BaseObject, InString)
;
; ObjLoad(BaseObject, FileName)
; ObjSave(InObject, FileName, Mode="w")
;
; ==============================================================================
; ==============================================================================

#Include StringHandling.ahk

EnsureObj(BaseObject, Params*) {                                                                                                            	; creates an object following params* from the base object
  
  ; ==============================================================================
; ==============================================================================
; object EnsureObj(BaseObject, params*)

; Example:
; EnsureObj(BS, "Level1", "Level2", "Level3")
; creates:
; BS["Level1"]["Level2"]["Level3"] = Object()
; if it did not previously exist
; ==============================================================================
; ==============================================================================
  
  If !(IsObject(BaseObject))
    BaseObject:=Object()
  TempBase:=BaseObject
  for Index, Param in Params
  {
    If !(TempBase.HasKey(param)) or !(IsObject(TempBase[Param]))
      TempBase[Param]:=Object()
    TempBase:=TempBase[Param]
  }
  return, TempBase
}

TryKey(BaseObject, Params*) {                                                                                                                 	; tests if a key following params* from the base object exists
  
  ; ==============================================================================
; ==============================================================================
; boolean TryKey(BaseObject, params*)

; Example:
; TryObject(BS, "Level1", "Level2", "Level3")
; returns true if:
; BS["Level1"]["Level2"]["Level3"] exists
; ==============================================================================
; ==============================================================================
  
  If !(IsObject(BaseObject))
    return, 0
  TempBase:=BaseObject
  for Index,Param in Params
  {
    If (Index=Params.MaxIndex())
    {
      If (!TempBase.HasKey(Param))
        return, 0
    }
    else
    If !(TempBase.HasKey(Param)) or !(IsObject(TempBase[Param]))
      return, 0
    TempBase:=TempBase[Param]
  }
  return, 1
}

TryObj(BaseObject, Params*) {                                                                                                                	; tests if an object following params* from the base object exists
  
  ; ==============================================================================
; ==============================================================================
; boolean TryObj(ByRef BaseObject, params*)

; Example:
; TryObj(BS, "Level1", "Level2", "Level3")
; returns true if:
; BS["Level1"]["Level2"]["Level3"] = Object()
; exists
; ==============================================================================
; ==============================================================================
  
  If !(IsObject(BaseObject))
    return, 0
  TempBase:=BaseObject
  for Index,Param in Params
  {
    If !(TempBase.HasKey(Param)) or !(IsObject(TempBase[Param]))
      return, 0
    TempBase:=TempBase[Param]
  }
  return, 1
}

ObjGetCount(BaseObject) {                                                                                                                       	; return the number of keys in an object
  If !(IsObject(BaseObject))
    return, 0
  cnt:=0
  for Index in BaseObject
  {
    cnt++
  }
  return, cnt
}

ObjMerge(SourceObject, TargetObject, Mode="", CallBack="") {                                                           	; merges contents of SourceObject into TargetObject
  
  ; ==============================================================================
; ==============================================================================
; ObjMerge(SourceObject, TargetObject, Mode="", CallBack="")
; Mode: w - overwrite, s - skip, else - warn through CallBack function
; Callback should return:
; -1: skip all
; 0: skip one
; 1: overwrite one
; 2: overwrite all
; ==============================================================================
; ==============================================================================
  
  CBResultSave:=0
  for Index, Value in SourceObject
  {
    if (IsObject(Value))
    {
      If (!TargetObject.HasKey(Index))
        TargetObject[Index]:=Object()
      ObjMerge(Value,TargetObject[Index], Mode, CallBack)
    }
    else
    {
      If (Mode="w")
        TargetObject[Index]:=Value
      else
      {
        If (Mode="s") 
        {
          if (!TargetObject.Haskey(Index))
            TargetObject[Index]:=Value
        }
        else
        {
          if (TargetObject.Haskey(Index) and CallBack<>"" and IsFunc(CallBack))
          {
            If (CBResultSave<>0)
            {
              CBResult:=%CallBack%(Index, Value)
            }
            else
              CBResult:=CBResultSave
            If (CBResult=-1)
            {
              CBResultSave:=CBResult
            }
            else
            If (CBResult=2)
            {
              CBResultSave:=CBResult
              TargetObject[Index]:=Value
            }
            else
            If (CBResult=1)
            {
              TargetObject[Index]:=Value
            }           
          }
          else
            TargetObject[Index]:=Value
        }
      } 
    }
  }
}

ObjToStr(InObject, Depth=1) {                                                                                                                	; attempts to output a string showing the structure and values of InObject
  OutStr:=""
  DepthString:=""
  Loop, % Depth-2
    DepthString.="   "
  If (Depth>1)
    DepthString.="└ "
  DepthStringVal:= DepthString "└ "
  try
  {
    For Index, Value in InObject
    {
      If (IsObject(Value))
      {
        OutStr.=DepthString Index "`r`n"
        OutStr.=ObjToStr(Value, Depth+1)
      }
      else
      {
        if Value is number
          OutStr.=DepthString Index " := " Value "`r`n"
        else
          If (Value="")
            OutStr.=DepthString  Index " := """"`r`n"
          else  
            Loop, Parse, Value, `n, `r
            {
              If (A_Index=1)
              {
                OutStr.=DepthString  Index " := " """" A_LoopField """`r`n"
              }
              else
                OutStr.=DepthStringVal """" A_LoopField """`r`n"
            }
      }    
    }
  }
  catch
  {
    OutStr.=DepthString  "  Object cannot be enumerated.`r`n"
  }
  return, OutStr
}

ObjToTreeView(InObject, FormatFunc=0, MaxDepth=0, Depth=1, Parent=0) {                                     	; transfers data from InObject to the currently active TreeView control
  
  ; ==============================================================================
; ==============================================================================
; void ObjToTreeView(InObject, FormatObj=0, MaxDepth=0)

; FormatObj can contain a callable reference to a function 
; FormatCallBack(Depth, Index, Value)
; that returns and object with the following keys:
;   Text        : the text of the node or object holding treenodes to be added
;   Options     : the options for the node
;   Add         : 1 to add this node; 0 to ignore
;   Continue    : 1 to continue with the next index; 0 to stop
;   RecurseInto : 1 to recurse into this object; 0 to stop (overrides MaxDepth)
; ==============================================================================
; ==============================================================================
  
  thisItem:=0
  try
  {
    For Index, Value in InObject
    {
      If (FormatFunc and ret:=%FormatFunc%(Depth, Index, Value))
      {
        If (ret.Add)
        {
          If (IsObject(ret.Text))
          {
            thisItem:=ObjToTreeView(ret.Text, 0, 0, 1, Parent)
          }
          else
            thisItem:=TV_Add(ret.Text, Parent, ret.Options)
        }
        else
          thisItem:=Parent
        If !(ret.Continue)
          break
        If (ret.RecurseInto)
        {
          If (IsObject(Value))
          {
            ObjToTreeView(Value, FormatFunc, MaxDepth, Depth+1, thisItem)
          }
          else
          {
            if Value is number
              TV_Add(Value, thisItem)
            else
              TV_Add("""" Value """", thisItem)
          }
        }
      }
      else
      {
        thisItem:=TV_Add(Index, Parent)
        If (IsObject(Value) and (MaxDepth=0 or Depth<MaxDepth))
        {
          ObjToTreeView(Value, FormatFunc, MaxDepth, Depth+1, thisItem)
        }
        else
        {
          if Value is number
            TV_Add(Value, thisItem)
          else
            TV_Add("""" Value """", thisItem)
        }        
      }
    }
  }
  catch
  {
    ; skip non-enumerable objects
  }
  return thisItem
}

ObjToXML(InObject, Depth=1) {                                                                                                               	; attempts to output a string showing the structure and values of InObject as
  
  ; ==============================================================================
; ==============================================================================
; string ObjToXML(InObject)

; simplified XML
; ==============================================================================
; ==============================================================================
  
  OutStr:=""
  DepthString:=""
  Loop, % Depth-1
    DepthString.="    "
  DepthStringVal:= DepthString "    "
  try
  {
    For Index, Value in InObject
    {
      OutStr.=DepthString "<" Index ">`r`n"
      If (IsObject(Value))
      {
        OutStr.=ObjToXML(Value, Depth+1)
      }
      else
      {
        if Value is number
          OutStr.=DepthStringVal Value "`r`n"
        else
          If (Value="")
            OutStr.=DepthStringVal """""`r`n"
          else  
            Loop, Parse, Value, `n, `r
            {
              OutStr.=DepthStringVal """" EscapeVarStr(A_LoopField) """`r`n"
            }
      }    
      OutStr.=DepthString "<\" Index ">`r`n"
    }
  }
  catch
  {
    OutStr.=DepthString  "  Object cannot be enumerated.`r`n"
  }
  return, OutStr
}

XMLToObj(BaseObject, InString) {                                                                                                             	; attempts to convert simplified XML InString into an object in BaseObject
  Value:=""
  CurrentLevel:=1
  KeyStarted:=0
  LevelObjects:={}
  LevelObjects[1]:=BaseObject
  KeyChain:=Object()
  Loop, Parse, InString, `n, `r
  {
    Line:=Trim(A_LoopField)
    If (Instr(Line,"<\")=1)
    {
      starttag:=Keychain.Pop()
      If (starttag=Substr(Line, 3, -1))
      {
        CurrentLevel--
        If (KeyValue<>"")
        {
          LevelObjects[CurrentLevel][KeyName]:=KeyValue
          KeyValue:=""
        }
      }
      else
      {
        throw {message: "Error in input string: end tag " Substr(Line, 3, -1) " does not match start tag " starttag " in line " A_Index, line: A_Index}
      }
    }
    else If (Instr(Line,"<")=1)
    {
      KeyName:=Substr(Line, 2, -1)
      KeyChain.Push(KeyName)
      If not IsObject(LevelObjects[CurrentLevel][KeyName])
      {
        LevelObjects[CurrentLevel][KeyName]:=Object()
      }
      CurrentLevel++
      LevelObjects[CurrentLevel]:=LevelObjects[CurrentLevel-1][KeyName]
      KeyValue:=""
    }
    else
    {
      If (KeyValue<>"")
        KeyValue.="`r`n"
      If (InStr(Line,"""")=1)
        KeyValue.=UnEscapeVarStr(Line)
    }
  }
}

ObjSave(InObject, FileName, Mode="w") {                                                                                                	; saves the structure and values of InObject as simplified XML
  FESave:=A_FileEncoding
  FileEncoding, UTF-16
  File:=FileOpen(FileName, Mode " `n")
  If (File=0)
  {
    RVal:="Error opening file """ FileName """: " A_LastError
  }
  else
  {
    File.Write(ObjToXML(InObject))
    File.Close()
    RVal:=0
  }
  FileEncoding, %FESave%
  return, rval
}

ObjLoad(BaseObject, FileName) {                                                                                                             	; loads the structure and values of an object from simplified XML
  FileRead, InString, %FileName%
  XMLToObj(BaseObject, InString)
}


