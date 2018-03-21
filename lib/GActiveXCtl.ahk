#Include <GuiCtl>

class GActiveXCtl extends GuiCtl
{
	static Type := "ActiveX"

	Ptr {
		get {
			if !this.__Ptr
				this.__Ptr := this.Value ; store in internal property
			return this.__Ptr
		}
		set {
			throw Exception("This property is read-only", -1, "Ptr")
		}
	}
}