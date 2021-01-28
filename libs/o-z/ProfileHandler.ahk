/*
Proof of concept for making the .value property of an Object "Persistent" and also allowing Per-Profile values for the Object.
*/

; =================================== ProfileHandler Class =========================================
; Ensure JSON library exists in the global namespace
#include <JSON>		; https://github.com/cocobelgica/AutoHotkey-JSON

/*
Injects a DropDownList GuiControl which contains a list of Profiles.
Can be passed a list of Objects to make persistent (Saves value in INI file), and also allows per-profile settings for each object.
Objects can also be declared "Global", and their value will NOT be dependant on the current profile
The .value property of each passed object will be stored in the INI.
If the current profile changes, every Per-Profile object will have it's .value property set to the value for that profile
If any object changes value, it should call the SettingChanged() method to announce it's change
Objects can be grouped into "Sections".
If the Object has a ._PHDefaultValue property, then that will be used as the default value, if no value is found for it in the settings file

Pass Objects in an array of the following Structure:
Section Name keys MUST be present, even if you use only one Section
However, the Global or PerProfile keys can be omitted if not used.
{
	Global: {
		SectionName: {
			Object1: <Object>,
			Object2: <Object>
		}
	},
	PerProfile: {
		SectionName: {
			Object1: <Object>,
			Object2: <Object>
		}
	}
}

Width param dictates the overall width of added GuiControls
SingleRow param dictates whether GuiControls should all be on one row or split across two rows
*/
class ProfileHandler {
	__New(width := 300, singlerow := 0){
		; Inject the Profile Handler GuiControls
		; Work out sizes of the various elements
		this._Width := width
		this._SingleRow := singlerow
		this.ProfileLoading:= 0
		
		SplitPath, % A_ScriptName,,,,ScriptName
		this._ININame := ScriptName ".ini"
		if (singlerow){
			;wbutton := ((width / 4) - 1)
			wbutton := 48
			wddl := width - 100 - ((wbutton + 2) * 4)
			opt := "yp-1 xp+" wddl
		} else {
			wbutton := ((width / 4) - 1)
			wddl := width - 100
			opt := "xm"
		}

		Gui, Add, Text, w100 xm, Current Profile
		Gui Add, DDL, % "hwndhwnd xp+100 yp-3 w" wddl
		this.hProfileSelectDDL := hwnd
		
		; Profile Add / Delete / Copy / Rename buttons
		Gui, Add, Button, % "hwndhwnd " opt " w" wbutton, Add
		this.hAddProfile := hwnd
		fn := this.AddProfile.Bind(this)
		GuiControl +g, % hwnd, % fn
		
		Gui, Add, Button, % "hwndhwnd xp+" wbutton + 2 " w" wbutton, Delete
		this.hDeleteProfile := hwnd
		fn := this.DeleteProfile.Bind(this)
		GuiControl +g, % hwnd, % fn

		Gui, Add, Button, % "hwndhwnd xp+" wbutton + 2 " w" wbutton, Copy
		this.hCopyProfile := hwnd
		fn := this.CopyProfile.Bind(this)
		GuiControl +g, % hwnd, % fn

		Gui, Add, Button, % "hwndhwnd xp+" wbutton + 2 " w" wbutton, Rename
		this.hRenameProfile := hwnd
		fn := this.RenameProfile.Bind(this)
		GuiControl +g, % hwnd, % fn

		fn := this.ProfileSelectDDLChanged.Bind(this)
		GuiControl +g, % this.hProfileSelectDDL, % fn
	}
	
	; Initialize the ProfileHandler
	; Reads settings file and initializes state of all objects
	Init(objects := -1){
		if (objects = -1){
			objects := {}
		}
		this._PersistentData := {}
		this._PersistentObjects := objects

		this.ReadProfiles()
		; Set profile
		this.ChangeProfile()
	}
	
	; Optional Callback to be called before profile load
	SetPreLoadCallback(callback){
		this._PreLoadCallback := callback
	}
	
	; Optional Callback to be called after profile load
	SetPostLoadCallback(callback){
		this._PostLoadCallback := callback
	}
	
	; Adds a new profile
	AddProfile(){
		InputBox, profile, Add Profile, Enter new profile name,,300, 100
		if (!ErrorLevel){
			; value entered
			this._PersistentData._Internal.ProfileList[profile] := 1
			this.SetProfileSelectDDLOptions()
			this._PersistentData._Internal.CurrentProfile := profile
			this.ChangeProfile()
		}
	}
	
	; Deletes the current profile
	DeleteProfile(){
		oldprofile := this._PersistentData._Internal.CurrentProfile
		if (oldprofile = "Default"){
			SoundBeep
			return 0
		}
		this._PersistentData._Internal.ProfileList.Delete(oldprofile)
		this.SetProfileSelectDDLOptions()
		this._PersistentData._Internal.CurrentProfile := "Default"
		this._PersistentData.PerProfile.Delete(oldprofile)
		this.ChangeProfile()
	}
	
	; Duplicates the current profile
	CopyProfile(){
		oldprofile := this._PersistentData._Internal.CurrentProfile
		InputBox, profile, Copy Profile, Enter new profile name,,300, 100
		if (!ErrorLevel){
			; value entered
			this._PersistentData._Internal.ProfileList[profile] := 1
			this.SetProfileSelectDDLOptions()
			this._PersistentData._Internal.CurrentProfile := profile
			this._PersistentData.PerProfile[profile] := this.ObjFullyClone(this._PersistentData.PerProfile[oldprofile])
			this.ChangeProfile()
		}
	}
	
	; Renames the current profile
	RenameProfile(){
		oldprofile := this._PersistentData._Internal.CurrentProfile
		if (oldprofile = "Default"){
			SoundBeep
			return 0
		}
		InputBox, profile, Rename Profile, Enter new profile name,,300, 100
		if (!ErrorLevel){
			; value entered
			this._PersistentData._Internal.ProfileList.Delete(oldprofile)
			this._PersistentData._Internal.ProfileList[profile] := 1
			this.SetProfileSelectDDLOptions()
			this._PersistentData._Internal.CurrentProfile := profile
			this._PersistentData.PerProfile[profile] := this.ObjFullyClone(this._PersistentData.PerProfile[oldprofile])
			this._PersistentData.PerProfile.Delete(oldprofile)
			this.ChangeProfile()
		}
	}
	
	; An object changed value.
	; Objects should call this method if they change.
	SettingChanged(){
		if (!ObjHasKey(this._PersistentObjects, "PerProfile")){
			this._PersistentObjects.PerProfile := {}
		}
		if (!ObjHasKey(this._PersistentObjects, "Global")){
			this._PersistentObjects.Global := {}
		}
		; Process PerProfile Objects
		for Section, items in this._PersistentObjects.PerProfile {
			for name, obj in items {
				; Remove keys for Objects that are the default value, to avoid clutter in INI files, and allow changing of the default value
				if (obj.value = obj._PHDefaultValue){
					this._PersistentData.PerProfile[this._PersistentData._Internal.CurrentProfile, Section].Delete(name)
				} else {
					this._PersistentData.PerProfile[this._PersistentData._Internal.CurrentProfile, Section, name] := obj.value
				}
			}
		}
		; Process Global Objects
		for Section, items in this._PersistentObjects.Global {
			for name, obj in items {
				if (obj.value = obj._PHDefaultValue){
					this._PersistentData.Global[Section].Delete(name)
				} else {
					this._PersistentData.Global[Section, name] := obj.value
				}
			}
		}
		g := this._PersistentObjects.Global
		this.WriteProfiles()
	}

	; Change to a new profile.
	; this._PersistentData._Internal.CurrentProfile should hold the name for the new profile
	ChangeProfile(){
		this.ProfileLoading := 1
		;this._PersistentData._Internal.CurrentProfile := this._PersistentData._Internal.CurrentProfile
		this.SetProfileSelectDDLOption(this._PersistentData._Internal.CurrentProfile)
		if (IsObject(this._PreLoadCallback)){
			this._PreLoadCallback.()
		}
		; Process PerProfile Objects
		for Section, items in this._PersistentObjects.PerProfile {
			for name, obj in items {
				newval := this._PersistentData.PerProfile[this._PersistentData._Internal.CurrentProfile, Section, name]
				if (newval = ""){
					; Value not found in this._PersistentData - use default value
					newval := this._PersistentObjects.PerProfile[Section, name]._PHDefaultValue
				}
				obj.value := newval
			}
		}
		; Process Global Objects
		for Section, items in this._PersistentObjects.Global {
			for name, obj in items {
				newval := this._PersistentData.Global[Section, name]
				if (newval = ""){
					; Value not found in this._PersistentData - use default value
					newval := this._PersistentObjects.Global[Section, name]._PHDefaultValue
				}
				obj.value := newval
			}
		}
		; Flush profile to disk
		this.WriteProfiles()
		if (IsObject(this._PostLoadCallback)){
			this._PostLoadCallback.()
		}
		this.ProfileLoading := 0
	}
	
	; Reads this._PersistentData from disk
	; If INI file does not exist, sets up this._PersistentData to default state
	ReadProfiles(){
		FileRead, str, % this._ININame
		if (ErrorLevel){
			; Non-existant file.
			this._PersistentData := {_Internal: {CurrentProfile: "Default", ProfileList: {Default: 1}}, Global: {}, PerProfile: {}}
		} else {
			try {
				this._PersistentData := JSON.Load(str)
			} catch {
				msgbox % "Failed to load settings"
				ExitApp
			}
		}
		this.SetProfileSelectDDLOptions()
	}
	
	; Writes this._PersistentData to disk
	WriteProfiles(){
		; Asynchronously call _WriteProfiles, so that if disk is spun down, execution does not halt
		fn := this._WriteProfiles.Bind(this)
		SetTimer, % fn, -0
	}
	
	_WriteProfiles(){
		str := JSON.Dump(this._PersistentData, true)
		file := FileOpen(this._ININame, "w")
		file.Write(str)
		file.Close()
	}

	; The Profile Select DDL changed through user interaction
	ProfileSelectDDLChanged(){
		GuiControlGet, profile,, % this.hProfileSelectDDL
		this._PersistentData._Internal.CurrentProfile := profile
		this.ChangeProfile()
	}
	
	; Set the Profile Select DDL to a specified option
	SetProfileSelectDDLOption(profile){
		GuiControl, ChooseString, % this.hProfileSelectDDL, % profile
	}
	
	; Populate the list of profiles in the Profile Select DLL
	SetProfileSelectDDLOptions(){
		list := "Default"
		for key in this._PersistentData._Internal.ProfileList {
			if (key = "Default"){
				continue
			}
			list .= "|" key
		}
		GuiControl,, % this.hProfileSelectDDL, % list
	}
	
	; Deep Clone an object
	; http://www.autohotkey.com/board/topic/103411-cloned-object-modifying-original-instantiation/#entry638500
	ObjFullyClone(obj) {
		nobj := ObjClone(obj)
		for k,v in nobj {
			if IsObject(v){
				nobj[k] := this.ObjFullyClone(v)
			}
		}
		return nobj
	}
}
