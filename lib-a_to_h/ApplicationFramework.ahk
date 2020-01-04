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
; todo
; ==============================================================================
; ==============================================================================

; make set and normal vars check types and ranges

; ==============================================================================
; ==============================================================================
; Contents
; ==============================================================================
; ==============================================================================
/*
Provides:
- class ApplicationFramework
Basic fle and variable management for generic applications.

- class ManagedVariableClass
Protected class for variables, constants and values in ini-files.

- function LogLine(TxtLn,LogFile="Default")
Writes logfile entries. Uses buffered write after 3 sec to reduce performance 
impact of writes.

- function LogWrite()
Writes logfile buffer to disk.

*/
; ==============================================================================
; ==============================================================================
; Code
; ==============================================================================
; ==============================================================================

#Include ObjectHandling.ahk
#Include ManagedResources.ahk
#Include ManagedGuis.ahk
#Include HelperFunctions.ahk


; ==============================================================================
; ==============================================================================
; class ApplicationFramework
;   Settings
;   __New(ApplicationName="NoName", Version=0, DefaultUILanguage="English")
;   ApplicationName[]
;   SettingsPath[]
;   UserFilePath[]
;   UserSettingsFile[]
;   LogFile[]
; ==============================================================================
; ==============================================================================

class ApplicationFramework
{
  Data:=Object()
  Resources:=""
  Settings:=""

  __New(ApplicationName="NoName", Version=0, DefaultUILanguage="English")
  {
    global
    local SettingsPath, UserFilePath, UserSettingsFile, FirstRun, LogFileSize
    SettingsPath:= A_AppData "\" ApplicationName
    UserFilePath:= A_MyDocuments "\" ApplicationName
    UserSettingsFile:=UserFilePath "\UserSettings.ini"
    
    IfNotExist, % SettingsPath
    {
     FileCreateDir, % SettingsPath
    }
    IfNotExist, % UserFilePath
    {
     FileCreateDir, % UserFilePath
    }
    IfNotExist, % UserSettingsFile
      FirstRun:=1
    else
      FirstRun:=0
    this.Settings:=new ManagedVariableClass(UserSettingsFile, "Main")
    this.Settings.SetConstant("ApplicationName", ApplicationName)
    this.Settings.SetConstant("ApplicationVersion", Version)
    this.Settings.SetConstant("SettingsPath", SettingsPath)
    this.Settings.SetConstant("UserFilePath", UserFilePath)
    this.Settings.SetConstant("UserSettingsFile", UserSettingsFile)
    this.Settings.SetConstant("FirstRun", FirstRun)  
    
    this.Settings.SetConstant("LogFile", UserFilePath "\LogFile.txt")
    this.Settings["DebugModeEnabled"]:=0
    Loop, %0%
    {
      LogLine("Command line parameter" A_Index ": " %A_Index%)
      If (%A_Index%="-debug")
        this.Settings["DebugModeEnabled"]:=1
    }  
    If (!A_IsCompiled)
      this.Settings["DebugModeEnabled"]:=1
    LogWriteBuffer:=Object()
    LogWriteBuffer["DefaultLogFile"]:=this.LogFile
    FileGetSize, LogFileSize, % this.LogFile, K
    If (LogFileSize>1000)
    {
      FileMove, % this.LogFile, % this.LogFile ".bak", 1
    }
    LogLine("*----------------------------------------------------------------*")
    LogLine(ApplicationName " Version: " Version " started.")

    this.Settings.CreateIni("UILanguage", DefaultUILanguage)     ; language for GUI strings
    this.Settings.SetConstant("ResourceFile", this.SettingsPath "\UIStrings.Res")
    If (this.Settings["DebugModeEnabled"])
    {
      FileDelete, % this.Settings.ResourceFile
    }
    fileinstall, Resources\UIStrings.Res, % this.Settings.ResourceFile
    this.Resources:=new ManagedResourcesClass(this.Settings["ResourceFile"], this.Settings["UILanguage"], DefaultUILanguage)
    this.ManagedGuis:=new GuiManagerMainClass(this.Settings)
  }
	
	CleanUp(ExitReason, ExitCode)
	{
    LogLine(this.ApplicationName " Version: " this.Settings["ApplicationVersion"] " exit: " ExitReason)
    LogLine("*----------------------------------------------------------------*")
    LogWrite()
	}
  
  ApplicationName[]
  {
    get 
    {
      return this.Settings.ApplicationName
    }
    
    set 
    {
      return this.Settings.ApplicationName
    }
  }

  SettingsPath[]
  {
    get 
    {
      return this.Settings.SettingsPath
    }
    
    set 
    {
      return this.Settings.SettingsPath
    }
  }

  UserFilePath[]
  {
    get 
    {
      return this.Settings.UserFilePath
    }
    
    set 
    {
      return this.Settings.UserFilePath
    }
  }

  UserSettingsFile[]
  {
    get 
    {
      return this.Settings.UserSettingsFile
    }
    
    set 
    {
      return this.Settings.UserSettingsFile
    }
  }

  LogFile[]
  {
    get 
    {
      return this.Settings.LogFile
    }
    
    set 
    {
      return this.Settings.LogFile
    }
  }
}


