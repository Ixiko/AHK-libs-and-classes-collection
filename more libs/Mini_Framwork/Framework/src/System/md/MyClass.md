mc := new MyClass()
mc.Name := "Nice Guy"
mc.Age := 25
MsgBox % mc.ToString() ; displays Nice Guy is Age:25
ExitApp

class MyClass extends MfPropertiesBase
{
	m_Name := ""
	m_Age := 0
	
	__New() {
		base.__New()
		
	}
	; Tostring overided base class
	ToString() {
		return this.Formated
	}
	; Is override from base class
	Is(type) {
		typeName := null
		if (IsObject(type)) {
			if (type.__Class) {
				typeName := type.__Class
			} else if (type.base.__Class) {
		} else if (type ~= "^[a-zA-Z0-9]+$") {
			typeName := type
		}
		if (typeName = "MyClass") {
			return true
		}
		return base.Is(type)
	}
	
	; extends MfPropertiesBase Get for Get properties
	class __Get extends MfPropertiesBase.__Get {
		Name() {
			return this.m_Name
		}
		Age() {
			return this.m_Age
		}
		; Formated is a readonly property
		Formated() {
			str := this.m_Name . " is age :" . this.m_Age
			return str
		}
	}
	
	; extends MfPropertiesBase Get for Set properties
	class __Set extends MfPropertiesBase.__Set {
		Name(value) {
			this.m_Name := value
			return this.m_Name
		}
		Age(value) {
			this.m_Age := value
			return this.m_Age
		}
	}
}