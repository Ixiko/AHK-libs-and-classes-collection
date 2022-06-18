if (!A_IsCompiled && A_LineFile == A_ScriptFullPath) {
  MsgBox % "This file was not #included."
  ExitApp
}
/*

  Title:  Class_StringList.ahk
  About:  An Object to manage a list of strings
  Usage:  #Include <AHKEZ> 
          #Include <Class_StringList>
          SL := New StringList
          index := Add("string")
          index := Add("Name:value")
  Legal:  Dedicated to the public domain (CC0 1.0) <http://creativecommons.org/publicdomain/zero/1.0/>
  Inspired by:
    AutoHotkey: https://www.autohotkey.com/docs/objects/Object.htm 
    Delphi:     http://docwiki.embarcadero.com/Libraries/Sydney/en/System.Classes.TStringList_Methods
    FreePascal: https://www.freepascal.org/docs-html/rtl/classes/tstringlist.html
    Java:       https://processing.github.io/processing-javadocs/core/index.html?processing/data/StringList.html

  Overview:
    A StringList can be used in two ways:
      1. An array of Strings          (Strings with integer indexes)
      2. An array of Name:Value pairs (Strings with "Name" indexes)
    All Strings and Name:Value pairs are added without a line terminator (no CRLF)
    It's recommended to use the StringList for Strings or Name:Value pairs, not both in the same instance

  Properties:
    Count                     count of items in the StringList with either integer or string indexes
    CaseSensitive             default is False
    NameValueSeparator        default is colon ":"

  Methods:
    [index]                   Return the String or Value: String[index] or Value["Name"]
    Add(String)               Add String to end of StringList
                              Add String, CSV String, Text with LF/CRLF, or array of Strings (StringList)
                              Return the index of added String
                              AddArray([Array])
                              AddCSV(CSV)
                              AddString(String)
                              AddText(String . CRLF)
    Append(String)            Appends to end of StringList, Return = none
    Clear()                   Clears all items without destroying the StringList
    GetText()                 Return all Strings or Name:Value pairs as Text. CRLF
    IndexOf(String or Value)  IndexOf(String) Return the integer index of the String
                              IndexOf(Value)  Return the Name index of the Value
    LoadFromFile(Filename)    Loads from text file, see Add() for supported values
    SaveToFile(Filename)      Saves to text file: String . CRLF or Name:Value . CRLF
    SetText(Text)             Loads from Text variable, see Add() for supported values
    Sort(Ascending := True)   Sorts an integer indexed StringList. Ignores if Name:Value StringList
    Value(Index or "Name")    Value(1) Returns the string value at integer (Index)
                              Value("1") (Index) can be an integer String
                              Value("Name") Returns the Value part of Name:Value pair
                              Value(1) Returns "" if attempt to Integer index a Name:Value pair

    The following are AHK Object built-in methods, hence no duplicate methods in Class_StringList:
      https://www.autohotkey.com/docs/objects/Object.htm

    Properties:
      Base                                    See AHK docs

    Methods:
      InsertAt / RemoveAt                     See AHK docs - doesn't leave blanks
      Push / Pop                              To/From end of StringList
      Delete                                  See AHK docs - leaves blanks
      MinIndex / MaxIndex / Length / Count    Use .Count property instead - see above and AHK docs
      SetCapacity / GetCapacity               See AHK docs
      GetAddress                              See AHK docs
      _NewEnum                                See AHK docs
      HasKey                                  HasKey(Index) or HasKey("Name")
      Clone                                   See AHK docs - returns a shallow copy of StringList

    Functions:
      ObjRawGet                               See AHK docs
      ObjRawSet                               See AHK docs
      ObjGetBase                              See AHK docs
      ObjSetBase                              See AHK docs

*/

#Include <AHKEZ>
;#Include <AHKEZ_Debug>

Class StringList {

  ;PROPERTIES

  Class prop {
    NameValueSeparator := ""
    CaseSensitive := ""
    NameIndex := []
  }

  CaseSensitive
  {
    get {
      return this.prop.CaseSensitive
    }
    set {
      this.prop.CaseSensitive := value
    }
  }

  Count
  {
    get {
      return this._Count()
    }
    set {
      ;read-only
    }
  }

  NameValueSeparator
  {
    get {
      return this.prop.NameValueSeparator
    }
    set {
      this.prop.NameValueSeparator := value
    }
  }

  ;INTERNAL HELPER METHODS

  _IsPair(String) {
    Result := False
    if StrContains(String, this.NameValueSeparator)
      Result := True
    Return Result
  }

  _Count() {
    count := 0
    for k, v in this
      count++
    Return count
  }

  _GetKey(KeyValue) {
    Return Trim(RegExReplace(KeyValue, "(.*)" this.NameValueSeparator ".*",   "$1"))
  }

  _GetValue(KeyValue) {
    Return Trim(RegExReplace(KeyValue, ".*" this.NameValueSeparator "(.*)",   "$1"))
  }

  ;CLASS METHODS

  Add(String = "") {

    if IsType(String, "object") {
      ;MB("Add Object[1]: " String[1])
      index := this.AddObj(String)

    } else if StrEndsWith(String, LF) {
      ;MB("Add Text: " String)
      index := this.AddText(String)

    } else if StrContains(String, ",") {
      ;MB("Add CSV: " String)
      index := this.AddCSV(String)
      
    } else if this._IsPair(String){
      ;MB("Add Pair: " String)
      index := this.AddPair(String)

    } else {
      ;MB("Add String: " String)
      index := this.AddString(String)
    }
    
    Return index
  }

  AddArray(Array) {
    For key, value in Array {
      if this._IsPair(value) {
        ObjRawSet(this, this._GetKey(value), this._GetValue(value))
      } else { 
        this.Add(Trim(value))
      }
    }
    Return this.Count
  }

  AddCSV(StringCSV) {
    split := StrSplit(StringCSV, ",")
    for key, value in split {
      if this._IsPair(value) {
        ObjRawSet(this, this._GetKey(value), this._GetValue(value))
      } else { 
        this.Add(Trim(value))
      }
    }
    Return this.Count
  }

  AddObj(ArrayObj) {
    for key, value in ArrayObj {
      if this._IsPair(value) {
        key   := this._GetKey(value)
        value := this._GetValue(value)
      }
       ObjRawSet(this, Trim(key), Trim(value))
    }
    Return this.Count
  }

  AddString(String) {
    if this._IsPair(String) {
      ObjRawSet(this, this._GetKey(String), this._GetValue(String))
    } else { 
      this.Push(String)
    }
    Return this.Count
  }

  AddText(Text) {
    Text := RTrim(Text, " `r`n")
    Loop, Parse, Text, `n, `r
    {
      this.Push(A_LoopField)
    }
    Return this.Count
  }

  AddPair(Key, Value = "") {
    ;if Name is Name:Value, ignore Value if present
    if this._IsPair(Key) {
      Pair := Trim(Key)
    } else {
      Pair := Trim(Key) . this.NameValueSeparator . Trim(Value)
    }
    ObjRawSet(this, this._GetKey(Pair), this._GetValue(Pair))
    Return this.Count
  }

  Append(String) {
    this.Add(String)
  }

  Clear() {
    if (this[1] = "") {
      temp := []
      for key, value in this
        temp[A_Index] := key
      for index, value in temp
        this.Delete(temp[A_Index])
      temp := ""
    } else {
      Loop % this.MaxIndex() {
        this.RemoveAt(this.MaxIndex())
      }
    }
  }

  GetText() {
    text := ""
    for k, v in this
      text .= v . NL
    Return text
  }

  IndexOf(String) {    
    For key, value in this {
      if (!this.CaseSensitive) {
        value  := StrUpper(value)
        String := StrUpper(String)
      }
      if (value == String) {
        Return key
      }
    }
    Return 0
  }

  LoadFromFile(Filename) {
    TextBuffer := FileRead(Filename)
    ;TextBuffer := SubStr(TextBuffer, 1, -2)
    this.Clear()
    Loop, Parse, TextBuffer, `n, `r
    {
      if (A_LoopField != "")
        this.Append(A_LoopField)
    }
    TextBuffer := ""
  }

  SaveToFile(Filename) {
    TextBuffer := ""
    for k, v in this
      TextBuffer .= v . "`n"
    FileWrite(TextBuffer, Filename, OverWrite := True)
    TextBuffer := ""
  }

  SetText(Text) {
    this.Clear()
    index := this.AddText(Text)
    Return index
  }

  Sort(Ascending := True) {
    if (this[1] = "")
      Return
    for index, value in this
      list .= value "|"
    list := SubStr(list,1,-1)
    Sort, list, % "D|" (Ascending ? "" : " R") (this.CaseSensitive ? " C" : "")
    temp := []
    loop, parse, list, |
    {
      if (A_LoopField != "")
        temp.Insert(A_LoopField)
    }
    this.Clear()
    this.AddArray(temp)
    temp := ""
  }

  Value(Name) {
    Return this[Name]
  }

  __New(String = "") {
    this.CaseSensitive := False
    this.NameValueSeparator := ":"
    ;this := {}
  }

  __Destroy() {
    this.Clear()
    this := ""
  }

} ; End_Class_StringList
