/*
	Class RHotkey ; Modified class name form RHotkey to RHotkey by Boulmers
	Written by: Runar "RUNIE" Borge with help from A_AhkUser

	Usage: check out the example.

	Methods:
	__New(Key, Target [, Window, Type])		- create a new hotkey instance
	Key		- The key to bind
	Target	- Function referece, boundfunc or label name to run when Key is pressed
	Window	- *OPTIONAL* The window the hotkey should be related to
	Type		- *OPTIONAL* What context the hotkey has to the window (Active, Exist, NotActive, NotExist)

	Delete()		- Delete hotkey. Do this when you're done with the hotkey. It differs from Disable() since it releases the object the key is bound to.
	Enable()		- Enable hotkey
	Disable()		- Disable hotkey
	Toggle()		- Enable/Disable toggle

	Base object methods:
	RHotkey.GetKey(Key, Window [, Type])	- Parameters are the same as in __New() without the Target param.
	RHotkey.DeleteAll()		- Delete all hotkeys
	RHotkey.EnableAll()		- Enable all disabled hotkeys
	RHotkey.DisableAll()		- Disable all enabled hotkeys
*/

; all methods return false on failure
Class RHotkey
{
	static Keys 	:= {} ; keep track of instances
	static KeyEnabled := {} ; keep track of state of hotkeys

	; create a new hotkey
	__New(Key, Target, Window := false, Type := "Active")
	{

		; check input
		if !StrLen(Window)
			Window := false

		if !StrLen(Key)
			return false, ErrorLevel := 2

		if !(Bind := IsLabel(Target) ? Target : this.CallFunc.Bind(this, Target))
			return false, ErrorLevel := 1

		if !(Type ~= "im)^(Not)?(Active|Exist)$")
			return false, ErrorLevel := 4

		; set values
		this.Key := Key
		this.Window := Window
		this.Type := Type

		; enable if previously disabled
		if ( RHotkey.KeyEnabled[Type, Window, Key] = false )
			this.Apply("On")

		; bind the key
		if !this.Apply(Bind)
			return false

		this.Enabled := true ; set to enabled
		return RHotkey.Keys[Type, Window, Key] := this
	}

	; 'delete' a hotkey. call this when you're done with a hotkey
	; this is superior to Disable() as it releases the function references
	Delete()
	{
		static JunkFunc := Func("WinActive")
		if this.Disable()
			if this.Apply(JunkFunc)
				return true, RHotkey.Keys[this.Type, this.Window].Remove(this.Key)
		return false
	}

	; enable hotkey
	Enable()
	 {
		if this.Apply("On")
			return true, this.Enabled := true
		return false
	}

	; disable hotkey
	Disable()
	{
		if this.Apply("Off")
			return true, this.Enabled := false
		return false
	}

	; toggle enabled/disabled
	Toggle()
	{
		return this[this.Enabled ? "Disable" : "Enable"].Call(this)
	}

	; ===== CALLED VIA BASE OBJECT =====

	; enable all hotkeys
	EnableAll()
	{
		RHotkey.CallAll("Enable")
	}

	; disable all hotkeys
	DisableAll()
	{
		RHotkey.CallAll("Disable")
	}

	; delete all hotkeys
	DeleteAll()
	{
		RHotkey.CallAll("Delete")
	}

	; get a hotkey instance from it's properties
	GetKey(Key, Window := false, Type := "Active")
	{
		return RHotkey.Keys[Type, Window, Key]
	}

	; ===== PRIVATE =====

	Enabled[]
	{
		get {
			return RHotkey.KeyEnabled[this.Type, this.Window, this.Key]
		}

		set {
			return RHotkey.KeyEnabled[this.Type, this.Window, this.Key] := value
		}
	}

	CallFunc(Target)
	{
		Target.Call()
	}

	Apply( Label_ )
	{
		Hotkey, % "IfWin" this.Type, % this.Window ? this.Window : ""

		if ErrorLevel
			return false

		Hotkey, % this.Key, % Label_, UseErrorLevel

		if ErrorLevel
		{
			_Logger.ERROR(A_ThisFunc, "Key", this.Key, "Label_", Label_, "ErrorLevel", ErrorLevel)
			return false
		}


		return true
	}

	CallAll(Method)
	{
		Instances := []
		for Index, Type in RHotkey.Keys
			for Index, Window in Type
				for Index, Htk in Window
					Instances.Push(Htk)

		for Index, Instance in Instances
			Instance[Method].Call(Instance)
	}
}