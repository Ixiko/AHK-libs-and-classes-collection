/*
	ListBox, ComboBox and DDLs should extend from this
*/

Class ChoiceControlType extends GuiBase.ControlType {
	
	_NewEnum() {
		this._i := 0
		this._EnumList := StrSplit(this.ControlGet("List"), "`n")
		return this
	}
	
	Next(ByRef k, ByRef v) {
		this._i++
		if !this._EnumList.HasKey(this._i) {
			this._i := ""
			this._EnumList := ""
			return false
		}
		k := this._i
		v := this._EnumList[this._i]
		return true
	}
	
	Choose(Item) {
		this.Control("Choose", Item)
	}
	
	ChooseString(String) {
		this.Control("ChooseString", String)
	}
	
	GetSelected() {
		return this.GuiControlGet()
	}
	
	Selected {
		get {
			return this.GetSelected()
		}
		
		set {
			this.Choose(value)
		}
	}
}