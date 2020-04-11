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

; ==============================================================================
; ==============================================================================
; class ManagedResourcesClass
; ==============================================================================
; ==============================================================================

class ManagedResourcesClass
{
	Resources:=Object()

	__New(ResourceFile, Language="English", DefaultLanguage="English")
	{
		this.Language:=Language
		this.DefaultLanguage:=DefaultLanguage
		IfExist, %ResourceFile%
		{
			ObjLoad(this.Resources, ResourceFile)
		}
		else
		{
			Throw, "Resource file not found: " ResourceFile
		}
	}

	__Get(ResName)
	{
    If (TryKey(this.Resources, "Common", ResName))
      return, this.Resources["Common"][ResName]
    else
    If (TryKey(this.Resources, this.Language, ResName))
      return, this.Resources[this.Language][ResName]
    else
    If (TryKey(this.Resources, this.DefaultLanguage, ResName))
      return, this.Resources[this.DefaultLanguage][ResName]
    else
    {
      Throw, "Undefined resource: " ResName
      ListLines
    }
	}

	__Set()
	{
	}

}

; ==============================================================================
; ==============================================================================
; class ManagedVariableClass
; ==============================================================================
; ==============================================================================

class ManagedVariableClass
{

  __New(IniFile="", Section="Main")
  {
    ManagedVariableClass.hidden[this]:= { Values: [], Vars: [], Consts: [], Inis: []}
    ManagedVariableClass.hidden[this].Inis.DefaultIniFilePath:=IniFile
    ManagedVariableClass.hidden[this].Inis.DefaultIniSection:=Section
    ManagedVariableClass.hidden[this].Inis.INIValues:=Object()
  }

  __Get(VarName)
  {
    If (ManagedVariableClass.hidden[this].Values.HasKey(VarName))
      return, ManagedVariableClass.hidden[this].Values[VarName]
    else
    {
      Throw, "Read from undefined variable: " VarName
      ListLines
    }
  }

  _NewEnum()
  {
    return, ManagedVariableClass.hidden[this].Values._NewEnum()
  }

  __Set(VarName, byref Value)
  {
    If (ManagedVariableClass.hidden[this].Consts.HasKey(VarName))
    {
      Throw, "Attempt to write to constant: " VarName
      return
    }
    else If (ManagedVariableClass.hidden[this].Inis.INIValues.HasKey(VarName))
    {
      If (ManagedVariableClass.hidden[this].Inis.INIValues[VarName]["Type"]<>"")
      {
        If Value is not % ManagedVariableClass.hidden[this].Inis.INIValues[VarName]["Type"]
          throw "Invalid type set for variable: " VarName ". Type must be " ManagedVariableClass.hidden[this].Inis.INIValues[VarName]["Type"] ". Attempted to set to: " Value
        If (ManagedVariableClass.hidden[this].Inis.INIValues[VarName]["MinValue"]<>"")
        {
          If (ManagedVariableClass.hidden[this].Inis.INIValues[VarName]["MinValue"]=" " and Value="")
          {
            Value:=ManagedVariableClass.hidden[this].Inis.INIValues[VarName]["DefaultValue"]
          }
          else
          If (Value<ManagedVariableClass.hidden[this].Inis.INIValues[VarName]["MinValue"])
          {
            Value:=ManagedVariableClass.hidden[this].Inis.INIValues[VarName]["MinValue"]
          }
        }
        If (Value<>"" and Value>ManagedVariableClass.hidden[this].Inis.INIValues[VarName]["MaxValue"])
        {
          Value:=ManagedVariableClass.hidden[this].Inis.INIValues[VarName]["MaxValue"]
        }
      }
      If (ManagedVariableClass.hidden[this].Inis.INIValues[VarName].HasKey("File"))
        File:=ManagedVariableClass.hidden[this].Inis.INIValues[VarName]["File"]
      else
        File:=ManagedVariableClass.hidden[this].Inis.DefaultIniFilePath
      If (ManagedVariableClass.hidden[this].Inis.INIValues[VarName].HasKey("Section"))
        Section:=ManagedVariableClass.hidden[this].Inis.INIValues[VarName]["Section"]
      else
        Section:=ManagedVariableClass.hidden[this].Inis.DefaultIniSection
      If (File<>"")
      {
        IniWrite, %Value%, %File%, %Section%, %VarName%
      }
      ManagedVariableClass.hidden[this].Values[VarName]:=Value
      return Value
    }
    else
    {
      ManagedVariableClass.hidden[this].Values[VarName]:=Value
      ManagedVariableClass.hidden[this].Vars[VarName]:=1
      return, Value
    }
  }

  HasKey(Key) ; 0 not found, 1 constant, 2 ini, 3 variable
  {
    If (ManagedVariableClass.hidden[this].Consts.HasKey(Key))
      return, 1
    else
    If (ManagedVariableClass.hidden[this].Inis.INIValues.HasKey(Key))
      return, 2
    else
    If (ManagedVariableClass.hidden[this].Vars.HasKey(Key))
      return, 3
    else
      return, 0
  }

  SetConstant(VarName, byref Value)
  {
    If (ManagedVariableClass.hidden[this].Consts.HasKey(VarName))
    {
      Throw, "Attempt to write to constant: " VarName
	  return
    }
    else
    {
      ManagedVariableClass.hidden[this].Consts[VarName]:=1
      ManagedVariableClass.hidden[this].Values[VarName]:=Value
      return, value
    }
  }

  CreateIni(VarName, DefaultValue, IniSection="", IniFile="", Type="", MinValue="", MaxValue="") ; MinValue, MaxValue for numbers, setting MinValue to " " means it must not be empty
  {
    If (ManagedVariableClass.hidden[this].Consts.HasKey(VarName))
    {
      Throw, "Attempt to overload constant: " VarName
	  return
    }
    else
    {
      If (IniFile<>"")
        ReadFile:=IniFile
      else
        ReadFile:=ManagedVariableClass.hidden[this].Inis.DefaultIniFilePath
      If (IniSection<>"")
        ReadSection:=IniSection
      else
        ReadSection:=ManagedVariableClass.hidden[this].Inis.DefaultIniSection
      If (ReadFile<>"")
      {
        IniRead, Value, %ReadFile%, %ReadSection%, %VarName%, EMPTYVALUE
        If (Value="EMPTYVALUE")
        {
          IniWrite, %DefaultValue%, %ReadFile%, %ReadSection%, %VarName%
          Value:=DefaultValue
        }
        If (Type<>"")
          If Value is not %Type%
            Value:=DefaultValue
        If (MinValue<>"")
        {
          If (MinValue=" " and Value="")
          {
            Value:=DefaultValue
          }
          else
          If (Value<MinValue)
          {
            Value:=DefaultValue
          }
        }
        If (MaxValue<>"" and Value<>"" and Value>MaxValue)
        {
          Value:=DefaultValue
        }
        ManagedVariableClass.hidden[this].Inis.INIValues[VarName]:=Object()
        ManagedVariableClass.hidden[this].Values[VarName]:=Value
        If (IniFile<>"")
          ManagedVariableClass.hidden[this].Inis.INIValues[VarName]["File"]:=IniFile
        If (IniSection<>"")
          ManagedVariableClass.hidden[this].Inis.INIValues[VarName]["Section"]:=IniSection
        If (Type<>"")
          ManagedVariableClass.hidden[this].Inis.INIValues[VarName]["Type"]:=Type
        If (MinValue<>"")
          ManagedVariableClass.hidden[this].Inis.INIValues[VarName]["MinValue"]:=MinValue
        If (MaxValue<>"")
          ManagedVariableClass.hidden[this].Inis.INIValues[VarName]["MaxValue"]:=MaxValue
        ManagedVariableClass.hidden[this].Inis.INIValues[VarName]["DefaultValue"]:=DefaultValue
        return Value
      }
      else
        Throw, "Error creating ini variable " VarName " : No ini file defined. Variable will not be defined."
    }
  }

  GetIniFilePath(VarName)
  {
    If (ManagedVariableClass.hidden[this].Inis.INIValues.HasKey(VarName))
    {
      rval:=Object()
      If (ManagedVariableClass.hidden[this].Inis.INIValues[VarName].HasKey("File"))
        rval.File:=ManagedVariableClass.hidden[this].Inis.INIValues[VarName]["File"]
      else
        rval.File:=ManagedVariableClass.hidden[this].Inis.DefaultIniFilePath
      If (ManagedVariableClass.hidden[this].Inis.INIValues[VarName].HasKey("Section"))
        rval.Section:=ManagedVariableClass.hidden[this].Inis.INIValues[VarName]["Section"]
      else
        rval.Section:=ManagedVariableClass.hidden[this].Inis.DefaultIniSection
      return, rval
    }
    else
      return, ""
  }

  __Delete()
  {
    this.Delete("Values")
    this.Delete("Vars")
    this.Delete("Consts")
    this.Delete("Inis")
  }
}
