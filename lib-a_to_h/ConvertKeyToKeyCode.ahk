; #############################################################################################################
; # This script was originally developed for the TradeMacro (https://github.com/PoE-TradeMacro/POE-TradeMacro)
; # It allows to run script and use hotkeys regardless of the current keyboard layout
; #
; # Github: https://github.com/dein0s
; # Twitter: https://twitter.com/dein0s
; # Discord: dein0s#2248
; #############################################################################################################


Global ENG_US := 0x4090409
Global DetectHiddenWindowsDefault := A_DetectHiddenWindows
Global TitleMatchModeDefault := A_TitleMatchMode
Global FormatIntegerDefault := A_FormatInteger
Global ScriptID := GetCurrentScriptID()
Global ScriptThread := DllCall("GetWindowThreadProcessId", "UInt", ScriptID, "UInt", 0)

Global ExcludeModifiersPattern := "[^\#\!\^\+\&\<\>\*\~\$\s]+"
Global PrefixSC := "SC"
Global PrefixVK := "VK"


SetSettingsExecution() {
  DetectHiddenWindows, On
  SetTitleMatchMode, 2
  SetFormat, IntegerFast, H
  Return
}


SetSettingsDefault() {
  DetectHiddenWindows, %DetectHiddenWindowsDefault%
  SetTitleMatchMode, %TitleMatchModeDefault%
  SetFormat, IntegerFast, %FormatIntegerDefault%
  Return
}


GetCurrentScriptID() {
  SetSettingsExecution()
  WinGet, _ScriptID, ID, %A_ScriptName% ahk_class AutoHotkey
  SetSettingsDefault()
  Return _ScriptID
}


GetCurrentLayout() {
  ; Get current keyboard layout for the active script
  SetSettingsExecution()
  _Layout := DllCall("GetKeyboardLayout", "UInt", ScriptThread)
  SetSettingsDefault()
  Return _Layout
}


SwitchLayout(LayoutID) {
  ; Switch keyboard layout for the active script
  SetSettingsExecution()
  ; Switch the script keyboard layout to the layout identical to the active window
  ; 0x50 - WM_INPUTLANGCHANGEREQUEST
  SendMessage, 0x50,, %LayoutID%,, ahk_id %ScriptID%
  ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms724947%28v=vs.85%29.aspx
  ; update user profile and broadcast WM_SETTINGCHANGE message
  DllCall("SystemParametersInfo", "UInt", 0x005A, "UInt", 0, "UInt", LayoutID, "UInt", 2)
  SetSettingsDefault()
  Return
}


CustomGetKeyCode(Key, SC:=true) {
  _Defaultlayout := GetCurrentLayout()
  _KeyCode := (SC=true) ? GetKeySC(Key) : GetKeyVK(Key)
  If (_KeyCode = 0 and _Defaultlayout != ENG_US) {
    ; Retrieving key code can fail (0 returned from GetKeySC()/GetKeyVK()) if the Key couldn't be found
    ; in a current keyboard layout (ie. "d" key in a russian layout)  or if it's MouseKey or some MediaKey

    ; NB: workaround for the issues caused by https://github.com/PoE-TradeMacro/POE-TradeMacro/pull/540
    while (GetCurrentLayout() != ENG_US) {
      SwitchLayout(ENG_US)
      Sleep, 50
    }
    _KeyCode := (SC=true) ? GetKeySC(Key) : GetKeyVK(Key)
    SwitchLayout(_Defaultlayout)
  }
  Return _KeyCode
}


CustomGetKeyName(KeyCode, ForceENG:=true) {
  _Defaultlayout := GetCurrentLayout()
  If (ForceENG and _Defaultlayout != ENG_US) {
    SwitchLayout(ENG_US)
  }
  _KeyName := GetKeyName(KeyCode)
  If (_Defaultlayout != GetCurrentLayout()) {
    SwitchLayout(_Defaultlayout)
  }
  Return _KeyName
}


KeyCodeToKeyName(KeyCode, ForceENG:=true) {
  _Result := KeyCode
  _Pos := 1
  While (_Pos := RegExMatch(KeyCode, ExcludeModifiersPattern, _Match, _Pos + StrLen(_Match))) {
    If InStr(_Match, PrefixSC) or InStr(_Match, PrefixVK) {
      _KeyName := CustomGetKeyName(_Match, ForceENG)
      _Result := RegExReplace(_Result, _Match, _KeyName)
    }
  }
  Return _Result
}


KeyNameToKeyCode(Key, SC:=true) {
  _Result := Key
  _Pos := 1
  _CodePrefix := (SC=true) ? PrefixSC : PrefixVK
  _NotCodePrefix := (SC=true) ? PrefixVK : PrefixSC
  While (_Pos := RegExMatch(Key, ExcludeModifiersPattern, _Match, _Pos + StrLen(_Match))) {
    If !InStr(_Match, _CodePrefix) {
      _NameToConvert := _Match
      If InStr(_Match, _NotCodePrefix) {
        _NameToConvert := KeyCodeToKeyName(_Match)
      }
      _KeyCode := CustomGetKeyCode(_NameToConvert, SC)
      _Result := (_KeyCode=0) ? _Result : RegExReplace(_Result, _Match, Format("{1:s}{2:X}", _CodePrefix, _KeyCode))
    }
  }
  Return _Result
}


KeyToSC(Key) {
  Return KeyNameToKeyCode(Key, true)
}


KeyToVK(Key) {
  Return KeyNameToKeyCode(Key, false)
}
