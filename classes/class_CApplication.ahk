; Include IO library
#include <IO>
; Include CIniFile
#include <class_CIniFile>
; Include CInCLocalizeriFile
#include <class_CLocalizer>
; This is just for convenience because the function is included when it is called.
#include <IsEmpty>

;
; Function: CApplication
; Description:
;		Creates an instance of the CApplication class without initializing it.
; Syntax: app := new CApplication()
;
class CApplication
{
  conf := {}
  
  CompanyName := ""
  ProductName := ""
  ProductVersion := ""
  
  StartupPath := ""
  ExecutablePath := ""
  AppDataPath := ""
  AppPropertiesPath := ""
  AppLanguagesPath := ""
  
  Forms := {}
  Menus := {}
  OpenForms := {}
  DisallowedForms := ""
  Hotkeys := {}
  
  DefaultStrings := ""
  
  
  ini := ""
  loc := ""
  
  StartupObject := ""
  
  __New()
  {
    this.StartupPath := A_ScriptDir
    this.ExecutablePath := A_ScriptFullPath
    this.AppDataPath := A_ScriptDir "\AppData"
    this.AppPropertiesPath := this.AppDataPath "\config.ini"
    this.AppLanguagesPath := this.AppDataPath "\Languages"
  }
   
  __Delete()
  {
    for name, form in this.Forms
    {
      form.Destroy()
    }
    ; TODO: free resources
    this.conf := ""
    this.ini := ""
    this.forms := ""
    this.openforms := ""
    this.menus := ""
  }

;
; Function: Get
; Description:
;		Gets an application setting.
; Syntax: value := CApplication.Get(name)
; Parameters:
;		name - The setting name.
;   read - (Optional) The flag indicating that the setting should be updated from an INI file (false by default).
; Return Value:
; 	Returns the setting value.
; Remarks:
;		If the setting is not set or does not exist, the function tries to read it from the INI file even if read = false.
;       If the setting is absent from the INI file, an ErrorLevel is set to 1, and false is returned.
;

; SIDE-EFFECT Overwrites CApplication.conf[name] if the value was read from the INI file, i.e. either if the key was absent prior to the method call, or if the read flag is present and set to true. If you set the setting manually, e.g. CApplication.Set("number", 1) which is equal to CApplication.Set("number", 1, false), and then call Get("number", true), the "number" key value 5 will be overwritten with the value read from an INI file.

  Get(name, read = false)
  {
    if(read || !this.conf.haskey(name))
    {
      val := this.ini.read("General", name)
      if(val = this.ini.defaultValue)
      {
        ErrorLevel = 1
        return val
      }
      else
      {
        this.conf[name] := val
      }
    }
    
    return this.conf[name]
  }

;
; Function: Set
; Description:
;		Sets an application setting to a specified value and optionally saves it into the INI file.
; Syntax: CApplication.Set(name, value [, write])
; Parameters:
;		name - The name of the setting.
; 	value - The new value for the setting.
;   write - (Optional) The flag indicating if the new value should be written to the INI file (false by default). 
;
  Set(name, value, write = false)
  {
    if(write)
    {
      this.StoreSetting(name, value)
    }
    else
    {
      this.conf[name] := value
    }
  }

;
; Function: StoreSetting
; Description:
;		Sets an application setting to a specified value and saves it into the INI file.
; Syntax: CApplication.StoreSetting(name, value)
; Parameters:
;		name - The name of the setting.
; 	value - The new value for the setting.
;
  StoreSetting(name, value)
  {
;     OutputDebug In StoreSetting(%name%, %value%)
    this.conf[name] := value
    this.ini.write("General", name, value)
  }

;
; Function: SaveSettings
; Description:
;		Saves all settings in the INI file.
; Syntax: CApplication.SaveSettings()
;
  SaveSettings()
  {
    for name, value in this.conf
    {
      this.StoreSetting(name, value)
    }
  }

;
; Function: Initialize
; Description:
;		Initializes an application object using the settings file or using default settings if the settings file is not available.
; Syntax: CApplication.Initialize([ConfigData])
; Parameters:
;		ConfigData - (Optional) An associative array to get settings from (e.g. {ProductName:"MyProductName", ProductVersion:"1.0.0.0"}).
; Remarks:
;   All settings that are not properties of this class will be written into the INI file if it does not exist. This may be used to create the default settings file.
;       On success ErrorLevel is 0.
;		    On error, ErrorLevel is set to one of the following values:
;       1 - Could not create AppDataPath upon the first start. A_LastError is set to the result of the operating system's GetLastError() function. (See AutoHotkey documentation for FileCreateDir.)
;       2 - Could not create AppPropertiesPath upon the first start.
;       3 - Could not create AppLanguagesPath upon the first start.
;       4 - Could not store a setting in the INI file.
;
  Initialize(ConfigData = "")
  {
    if(!IsEmpty(ConfigData))
    {
      if(ConfigData.CompanyName)
        this.CompanyName := ConfigData.CompanyName
      if(ConfigData.ProductName)
        this.ProductName := ConfigData.ProductName
      if(ConfigData.ProductVersion)
        this.ProductVersion := ConfigData.ProductVersion
      
      for name, value in ConfigData
      {
        if name not in StartupPath,ExecutablePath,AppDataPath,AppPropertiesPath,AppLanguagesPath,CompanyName,ProductName,ProductVersion,DefaultStrings
        {
          this.Set(name, value)
        }
      }
    }
    
    if(!CDirectory.Exists(this.AppDataPath))
    {
      CDirectory.Create(this.AppDataPath)
      if ErrorLevel
      {
        ErrorLevel := 1
        return
      }
    }
    
    this.ini := new CIniFile(this.AppPropertiesPath)
    if(!this.ini.Exists())
    {
      if(!this.ini.CreateIfNotExists())
      {
        ErrorLevel := 2
        return
      }
    }
    
    if(!CDirectory.Exists(this.AppLanguagesPath))
    {
      CDirectory.Create(this.AppLanguagesPath)
      if ErrorLevel
      {
        ErrorLevel := 3
        return
      }
    }
    
    ; Read all settings or save if they are absent from the INI file.
    
    for name, value in this.conf
    {
      if(this.Get(name, true) = this.ini.defaultValue)
      {
        this.StoreSetting(name, value)
        if ErrorLevel
        {
          ErrorLevel := 4
          return
        }
      }
    }

    this.ReadSettings()
    
    this.DefaultStrings := ConfigData.DefaultStrings
    this.loc := new CLocalizer(this.AppLanguagesPath)
    il := this.Get("InterfaceLanguage")
;     OutputDebug app.Init before load ErrorLevel = %ErrorLevel%
    this.loc.LoadStrings(il, ConfigData.DefaultStrings)
;     OutputDebug app.Init after load ErrorLevel = %ErrorLevel%
    if ErrorLevel = 1
      ErrorLevel := 5
    else if ErrorLevel = 2
      ErrorLevel := 6
  }

;
; Function: ReadSettings
; Description:
;		Reads settings from an INI file.
; Syntax: CApplication.ReadSettings()
;
  ReadSettings()
  {
    ; TODO: this may be a vulnerability without checking values
    this.conf := this.ini.ReadSection("General")
  }

;
; Function: Run
; Description:
;		Starts the application using the supplied object if any.
; Syntax: CApplication.Run([StartupObject])
; Parameters:
;		StartupObject - (Optional) an object that has a Start() method which is called by the Run method.
;
  Run(StartupObject = "")
  {
    for i, m in this.menus
    { 
      m.create()
    }
    
    for i, hk in this.hotkeys
    { 
      hk.Create()
      if(hk.enabled)
        hk.enable()
    }
    
    for i, g in this.Forms
    {
      g.create()
    }
    
    if(StartupObject)
    {
      this.StartupObject := StartupObject
      this.StartupObject.Start()
    }
    else if(this.StartupObject)
      this.StartupObject.Start()
  }

;
; Function: Exit
; Description:
;		Closes and destroys all forms by calling __Delete method and exits the application with the supplied code if any.
; Syntax: CApplication.Exit([ExitCode])
; Parameters:
;		ExitCode - (Optional) An integer between -2147483648 and 2147483647 (can be an expression in v1.0.48.01+) that is returned to its caller when the script exits. This code is accessible to any program that spawned the script, such as another script (via RunWait) or a batch (.bat) file. If omitted, ExitCode defaults to zero. Zero is traditionally used to indicate success. Note: Windows 95 may be limited in how large ExitCode can be.
;
  Exit(ExitCode = 0)
  {
    this.__Delete()
    ExitApp, %ExitCode%
  }
  
  GetString(strId)
  {
    if(this.loc.strings.haskey(strId))
      return this.loc.strings[strId]
    else
      return strId ; Pass recent file names, etc. without localization
  }
  
  GetLanguageList()
  {
    return this.loc.GetLanguageList()
  }
  
  Localize(langId)
  {
    this.StoreSetting("InterfaceLanguage", langId)
    this.loc.LoadStrings(langId, this.DefaultStrings)
    for i, m in this.menus
    { 
      m.localize()
    }
    
    for i, g in this.Forms
    {
      g.localize()
    }
  }
  
; ================================= Hotkeys ====================================

  AddHotkeyCmd(hkCmd, mi = "")
  {
;     OutputDebug In AddHotkeyCmd(%hkCmd%, %mi%)
    if(app.Get(hkCmd, true))
    {
      newHk := new CHotKey(app.Get(hkCmd), hkCmd)
      if ErrorLevel
      {
;         OutputDebug `tCreated hotkey ErrorLevel = %ErrorLevel%
        app.Set(hkCmd, "", true)
        ErrorLevel := el
      }
      else
      {
        newHk.enabled := true
        if(mi)
        {
          mi.hk := newHk
          hk.boundControls.insert(mi)
        }
      }
      app.hotkeys[newHk.hk] := newHk
      app.hotkeys[newHk.hk].boundControls[mi.name] := mi
    }
    if ErrorLevel
      return false
     else
      return true 
  }
  
  AddHotkey(newHk, boundCtrl = "")
  {
;     OutputDebug % "In AddHotkey(" newHk.hk "[" newHk.label "], " boundCtrl.name ")"
    if(!this.hotkeys.hasKey(newHk.hk))
      this.hotkeys[newHk.hk] := newHk
    
    if(boundCtrl)
    {
;       OutputDebug `tSetting hk for boundCtrl
      boundCtrl.ReplaceHotkey(newHk)
      hk.boundControls[boundCtrl.name] := boundCtrl
    }
  }
  
  ReplaceHotkey(oldHkString, newHkString)
  {
;     OutputDebug In ReplaceHotkey(%oldHkString%, %newHkString%)
    if(oldHkString = newHkString)
      return
      
    oldHk := this.Hotkeys[oldHkString]
    newHk := new CHotKey(newHkString, oldHk.label)
;     OutputDebug `tCreated new hotkey %newHkString%
    if not ErrorLevel
    {
      this.AddHotkey(newHk)
      for name, ctrl in oldHk.boundControls
      {
        this.AddHotkey(newHk, ctrl)
      }
      
      this.Set(newHk.label, newHk.hk, true)
      this.RemoveHotkey(oldHkString)
      
      return true
    }
    else
    {
;       OutputDebug `tErrorLevel = %ErrorLevel% 
      return false
    }
  }
  
  DisableHotkeys()
  {
    success := true
    for strHk, hk in this.hotkeys
    {
      if(!hk.Disable())
      {
        success := false
;         OutputDebug Could not disable hotkey %strHk%
      }
    }
    return success
  }
  
  EnableHotkeys()
  {
    success := true
    for strHk, hk in this.hotkeys
    {
      if(!hk.Enable())
      {
        success := false
;         OutputDebug Could not enable hotkey %strHk%
      }
    }
    return success
  }
  
  RemoveHotkey(strHk)
  {
    oldHk := this.hotkeys.remove(strHk)
    oldHk.Disable()
    oldHk := ""
  }
; ================================== Forms =====================================
  
  ShowForm(formName, disallowedForms = "")
  {
    if(this.IsDisallowed(formName))
      return
      
    if(!IsEmpty(this.DisallowedForms))
    {
      dforms := this.DisallowedForms
      if formName in %dforms%
        return
    }
    
    if(disallowedForms)
    {
      if(disallowedForms = "A" || disallowedForms = "All")
      {
        result := ""
        for fName, form in this.forms
        {
          if(fname <> formName)
          {
            this.DisallowedForms .= fname ","
          }
        }
        if(result && SubStr(result, 0) = ",")
          StringTrimRight, result, result, 1
      }
      this.DisallowForms(disallowedForms)
    }
    this.Forms[formName].DisallowedForms := disallowedForms
    this.OpenForms[formName] := this.Forms[formName]
    this.Forms[formName].Show()
  }
  
  HideForm(formName)
  {
    this.Forms[formName].Hide()
    this.OpenForms.remove(formName)
    this.AdjustDisallowedForms()
  }
  
  DisallowForms(forms)
  {
    if(this.DisallowedForms)
      this.DisallowedForms .= "," forms
    else
      this.DisallowedForms := forms
  }
  
  IsDisallowed(formName)
  {
    dforms := this.DisallowedForms
    if formName in %dforms%
      return true
    else
      return false 
  }
  
  AllowForms(forms)
  {
    result := ""
    dforms := this.DisallowedForms
    loop, parse, dforms, `,
    {
      if A_LoopField not in %forms% 
      {
        result .= A_LoopField ","
      }
    }
    if(result && SubStr(result, 0) = ",")
      StringTrimRight, result, result, 1
    this.DisallowedForms := result
  }
  
  AdjustDisallowedForms()
  {
    this.DisallowedForms := ""
    for fName, form in this.OpenForms
    {
      if(form.DisallowedForms)
      {
        this.AddDisallowedForms(form.DisallowedForms)
      }
    }
  }
  
; ================================== Events ====================================
  
  handlers := {}
 
  RaiseEvent(e)
  {
;     OutputDebug In CApplication.RaiseEvent(%e%)
    if(!this.handlers.haskey(e))
      return
    
;     OutputDebug `tRaising event %e%
    for i, handler in this.handlers[e]
    {
;       OutputDebug `tCalling handler %handler%
      handler.()
    }
  }
  
  Subscribe(handler, e)
  {
    
    if(!this.handlers.haskey(e))
      this.handlers[e] := []
    
    handlerName := handler
    if(handler.name <> "")
      handlerName := handler.name
    
;     OutputDebug In Events.Subscribe(%handlerName%, %e%)
    
    if(!Contains(this.handlers[e], handlerName))
      this.handlers[e].insert(handlerName)
  }
  
  Unsubscribe(handler, e)
  {
    if(!this.handlers.haskey(e))
      return
    
    handlerName := handler
    if(handler.name <> "")
      handlerName := handler.name
    
    for i, registeredHandler in this.handlers[e]
    {
      if(registeredHandler = handlerName)
        this.handlers[e].remove(i)
        
      if(count(this.handlers[e]) = 0)
        this.handlers.remove(e)
    }
  }
}
