/*
Version 2021-10-25
Partly thanks to Tidbit.
Also handles strings.

Inspired by Lexikos's ExploreObj().

ObjectToString(object, Depth=5, indentLevel="", IncludeBase=False)
   Prints an object in text form so that you can easily
   see the layout of it.

   * Object = The input.
   * Depth = How deep should we go if there are objects within objects?
   * indentLevel should not be touched as it's hard-coded in! DO NOT TOUCH.
*/


ObjectToString(object, Depth=5, indentLevel="", IncludeBase=False){
   ObjectType := ObjType(object)
   List =

   If not IsObject(object) and object != ""
      list .= indentLevel "[" object "]"
   Else if (ObjectType = "Match")
   {
      object := MatchToObject(object)
      List .= indentLevel "MATCH`n" ObjectToString(object, depth-1, indentLevel . ".   ")
   }
   Else if (ObjectType = "File")
      List .= indentLevel "File`n"
   Else if (ObjectType = "Enumerator")
      List .= indentLevel "ENUMERATOR`n"
   Else if (ComObjType(object, "Name"))
      List .= indentLevel "COM " ComObjType(object, "Name") "`n"
   Else if (ComObjType(object, "Class"))
      List .= indentLevel "COM " ComObjType(object, "Class") "`n"
   Else if IsFunc(object)
      list .="FUNCTION`n"
   ; Else if (IsClass(object))
   ;    List .= indentLevel "CLASS " object.__Class "`n"
   Else
   {
      Looped := False
      Try
      {
         for key,value in object
         {
            Looped := A_Index
            ; list.= indentLevel "[" key "]"
            If IsObject(ObjGetBase(Object))
                  and ObjGetBase(Object).HasKey("__Class")
                  and ObjGetBase(Object).__Class ~= "\.RegExMatchObject\.SingleMatch$"
                  and Key~="^\d+$"
               List .= indentLevel key (Key = 0 ? " FULL MATCH" 
                  : Object.HasKey("_Name") and Object._Name.HasKey(Key) ? " " Object._Name[Key] : "")  ; With Regex match objects, show the name of the group next to its number.
            Else list .= indentLevel key

            if (IsObject(value) && depth>1)
            {
               if IsFunc(value)
                  list.=" => FUNCTION"
               else
               {
                  Type := ObjType(value)
                  If (Type = "Match")
                  {
                     value := MatchToObject(value)
                     List .= " => MATCH`n" ObjectToString(value, depth-1, indentLevel . ".   ")
                  }
                  Else if (Type = "File")
                     List .= " => " "FILE`n"
                  Else if (Type = "Enumerator")
                     List .= " => " "ENUMERATOR`n"
                  ; Else if (Type = "Exception")
                  ;    List := indentLevel "EXCEPTION`n"
                  Else if (ComObjType(value, "Name"))
                     List .= " => COM " ComObjType(value, "Name") "`n"
                  Else if (ComObjType(value, "Class"))
                     List .= " => COM " ComObjType(value, "Class") "`n"
                  ; Else if (IsClass(value))
                     ; List .= " => " "CLASS " value.__Class "`n"
                  Else
                  {
                     list.=":`n" ObjectToString(value, depth-1, indentLevel . ".   ")
                     If IncludeBase and IsObject(Object) and (Object.Base or Object.Base != "")
                        List .=  indentLevel "BASE`n" ObjectToString(object.base, depth-1, indentLevel . ".   ")
                  }
               }
            }
            Else
            {
               list .= " => "
               list
                  .= value = ""
                     ? "EMPTY STRING"
                  : (depth <= 2 and IsObject(Value))
                     ? "NESTING TOO DEEP"
                  : "[" value "]"
            }
            ; list.="`n"
            list:=rtrim(list, "`r`n `t") "`n"
         }
      }
      If IsObject(Object) and not Looped
      {
         If (Object.Length() = "0")            
            List .= indentLevel . "EMPTY OBJECT"
         Else
            List .= indentLevel . "NON-ITERABLE OBJECT"
      }
      
      If IncludeBase and IsObject(Object) and (Object.Base or Object.Base != "")
         List .=  indentLevel "BASE`n" ObjectToString(object.base, depth-1, indentLevel . ".   ")
   }

   list := rtrim(list)
   return list
}

; MatchToObjectOld(Object){  ; The old method was different from the default way a match object is structured in Autohotkey.
;    StandardObject := {}
;    Loop, % Object.Count + 1  ; Number of subpatterns + 1 for the full match.
;    {
;       Group := A_Index - 1
;       Name := "(" Group ") " Object.Name(Group)
;       Name := RegExReplace(Name, " $", "")
;       If (Group = 0)
;          Name .= " FULL MATCH"
;       ; StandardObject[Name] := Object[Group]
;       StandardObject[Name] := { Value: Object[Group]
;                               , Position: Object.Pos(Group)
;                               , Length: Object.Len(Group) }
;    }
;    StandardObject.Mark := Object.Mark()
;    StandardObject.Count := Object.Count()
;    Return StandardObject
; }

MatchToObject(Match){
   StandardObject := {}
   Loop, % Match.Count + 1  ; Number of subpatterns + 1 for the full match.
   {
      Group := A_Index - 1
      StandardObject[Group]          := Match[Group]
      If Match.Name(Group)
         StandardObject .Name[Group] := Match.Name(Group)
      StandardObject.Position[Group] := Match .Pos(Group)
      StandardObject  .Length[Group] := Match .Len(Group)
   }
   StandardObject .Mark := Match.Mark()
   StandardObject.Count := Match.Count()
   Return StandardObject
}

ObjType(o) {
   static   M, init:=RegExMatch("","O)",M)
      ,  F := FileOpen("NUL", "r"), Ignore := F.Close()
      ,  E := {}.NewEnum()
      ,  X := Exception("")

   Type :=  NumGet(&o)==NumGet(&M)? "Match"
        :   NumGet(&o)==NumGet(&F)? "File"
        :   NumGet(&o)==NumGet(&E)? "Enumerator"
        ; :   NumGet(&o)==NumGet(&X)? "Exception"  ; Somehow, the address of any object is identical to the address of any exception object, so this doesn't work.
        :   ""
   Return Type
}

IsClass(o){
   Return o.__Class && !o.base.__Class ? "Class" : ""
}

; RegexEnum(MatchObject) {
;    FakeMatchObject := {}
;    FakeMatchObject._NewEnum := Func("RegexNewEnum")
;    FakeMatchObject.this := MatchObject

;    return FakeMatchObject
; }
; RegexNewEnum(MatchObject) {
;    MatchObject := MatchObject.this

;    return {"Next": Func("RegexEnumNext"), "Count": MatchObject.Count(), "Index": 1, "Match": MatchObject}
; }
; RegexEnumNext(this, ByRef K, ByRef V) {
;    K := this.Index
;    V := this.Match.Value(K)

;    ; this.Index++

;    return this.Index++ != this.Count + 1
; }

