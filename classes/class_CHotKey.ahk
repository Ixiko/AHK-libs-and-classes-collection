class CHotKey
{
  hk := ""
  label := ""
  enabled := false
  up := true
  _hkString := ""
  
  boundControls := {}
  
  __New(hk, label, up=true)
  {
    this.hk := hk
    this.label := label
    this.up := true
    this.enabled := false
    this._hkString := this._ToString()
    if(!this.Create())
      ErrorLevel = 1
  }

  _GetInternalName()
  {
    hk := this.hk
    if(this.up)
      hk .= " Up"
    return hk
  }
  
  Create()
  {
    Hotkey, % this._GetInternalName(), % this.label, off UseErrorLevel
;     OutputDebug % "created hk " this.hk ", " ErrorLevel
    if ErrorLevel
      return false
    else
      return true
  }
  
  Enable()
  {
    Hotkey, % this._GetInternalName(), on, UseErrorLevel
;     OutputDebug % "enabled hk " this.hk ", " ErrorLevel
    if ErrorLevel
      return false
    else
    {
      this.enabled := true
      return true
    }
  }
  
  Disable()
  {
;     OutputDebug % "CHotKey.Disable()`n`tHK = " this.hk
;     OutputDebug % "`tInternal name = " this._GetInternalName()
    Hotkey, % this._GetInternalName(), off, UseErrorLevel
;     OutputDebug `tErrorLevel = %ErrorLevel%
    if ErrorLevel
      return false
    else
    {
      this.enabled := false
      return true
    }
  }

;
; Function: ToString
; Description:
;		Gets the hotkey display text as shown in a Hotkey GUI control.
; Syntax: CHotKey.ToString()
; Return Value:
; 	The display text of the hotkey. 
;

  ToString()
  {
    return this._hkString
  }
  
;
; Function: _ToString
; Description:
;		Transforms AutoHotkey hotkeys that can be obtained from Hotkey GUI control into the format displayed in the said control.
; Syntax: CHotKey._ToString()
; Return Value:
; 	The display text of the hotkey. 
; Remarks:
;		This method is for internal use (use ToString instead).
;
  _ToString()
  {
    kstring := ""
    if(InStr(this.hk, "^"))
      kstring .= "Ctrl + "
    if(InStr(this.hk, "+"))
      kstring .= "Shift + "
    if(InStr(this.hk, "!"))
      kstring .= "Alt + "
    
    hk := this.hk
    StringReplace, hk, hk, ^
    StringReplace, hk, hk, +
    StringReplace, hk, hk, !
    
    StringReplace, hk, hk, Numpad, Num%A_Space%
		StringReplace, hk, hk, Add, +
    StringReplace, hk, hk, Sub, -
    StringReplace, hk, hk, Mult, *
    StringReplace, hk, hk, Div, /

    kstring .= hk
    return kstring
  }
}
