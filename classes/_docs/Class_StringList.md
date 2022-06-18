
<!-- reminder: replace = \"\" with = \\"\\" -->

---
title: Class_StringList
author: jasc2v8
date: March 19, 2021
---

# About

An Object to manage a list of strings

To Use:

```AutoHotkey

  #Include <AHKEZ>  
  #Include <Class_StringList>
  SL := New StringList
  index := Add("String")
  index := Add("Name:Value")


```

A StringList can be used in two ways:

1. An array of Strings          (Strings with integer indexes)  
1. An array of Name:Value pairs (String "Values" with "Name" indexes)  

All Strings and Name:Value pairs are added without a line terminator (no CRLF)  
It's recommended to use the StringList for Strings or Name:Value pairs, not both in the same instance

Inspired by:

- [AutoHotkey](https://www.autohotkey.com/docs/objects/Object.htm)  
- [Delphi](http://docwiki.embarcadero.com/Libraries/Sydney/en/System.Classes.TStringList_Methods)  
- [FreePascal](https://www.freepascal.org/docs-html/rtl/classes/tstringlist.html)  
- [Java](https://processing.github.io/processing-javadocs/core/index.html?processing/data/StringList.html)  

License: Dedicated to the public domain without warranty or liability [(CC0 1.0)](http://creativecommons.org/publicdomain/zero/1.0)

<a href="#top" class="back-to-top-link" aria-label="Scroll to Top">🔝</a>


# Properties

```AutoHotkey

  Count                     count of items in the StringList with either integer or string indexes
  CaseSensitive             default is False
  NameValueSeparator        default is colon ":"


```

<a href="#top" class="back-to-top-link" aria-label="Scroll to Top">🔝</a>

# Methods

```AutoHotkey

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


```

<a href="#top" class="back-to-top-link" aria-label="Scroll to Top">🔝</a>

# Built-in Methods for an AHK Object

 The following are AHK Object built-in methods, hence no duplicate methods in Class_StringList.  
 See the AHK docs for an [Object](https://www.autohotkey.com/docs/objects/Object.htm)  

```AutoHotkey

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


```

<a href="#top" class="back-to-top-link" aria-label="Scroll to Top">🔝</a>

