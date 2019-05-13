;{ License
/* This file is part of Mini-Framework For AutoHotkey.
 * 
 * Mini-Framework is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 2 of the License.
 * 
 * Mini-Framework is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with Mini-Framework.  If not, see <http://www.gnu.org/licenses/>.
 */
; End:License ;}
;{ Class Comments
/*
	Class:
		MfFlagsAttribute
			Indicates that an enumeration can be treated as a bit field; that is, a set of flags.
			This attribute is usually added to MfEnum derived classes that require the ability to set flags such as MfNumberStyles.
			To add this attribute to derived class override the AddAttributes() of MfEnum.
	Inherits
		MfAttribute
*/
; End:Class Comments ;}
class MfFlagsAttribute extends MfAttribute
{
	static _instance := "" ; Static var to contain the singleton instance
;{ Constructor: ()
/*!
	Constructor: ()
		Initializes a new instance of the MfFlagsAttribute class.
	Remarks
		MfFlagsAttribute is Singleton, Use Instance property to access instead of Constructing a new instance.
*/
	__New() {
		if (this.__Class != "MfFlagsAttribute") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfFlagsAttribute"))
		}
		base.__New()
		this.m_isInherited := false
	}
; End:Constructor: () ;}
;{ Method
/*
	Method: DestroyInstance()
		Overrides MfSingletonBase.DestroyInstance()
	instance.DestroyInstance()
	
	DestroyInstance()
		Set current Instance to null.
	Remarks
		Call to Property Instance will create a new instance automatically if DestroyInstance() is called.
*/
	DestroyInstance() {
	   MfFlagsAttribute._instance := Null ; Clears current instance and releases memory
	}
/*
	Method: GetInstance()
		Overrides MfSingletonBase.GetInstance()
		Gets the instance of the Singleton MfFlagsAttribute.
	Returns
		Returns Singleton instance for the derived class.
	Throws
		Throws MfNotImplementedException if method is not overridden in derived classes
	Remarks
		Protected static method.
		This method must be overridden in derived classes.
*/
	GetInstance() { ; Overrides base
		if (MfNull.IsNull(MfFlagsAttribute._instance)) {
		   MfFlagsAttribute._instance := new MfFlagsAttribute()
		}
		return MfFlagsAttribute._instance
	}
; Sealed Class Following methods cannot be overriden ; Do Not document for this class
; VerifyIsInstance([ClassName, LineFile, LineNumber, Source])
; VerifyIsNotInstance([MethodName, LineFile, LineNumber, Source])
; Sealed Class Following methods cannot be overriden
; VerifyReadOnly()
;{ MfObject Attribute Overrides - methods not used from MfObject - Do Not document for this class
;{	AddAttribute()
/*
	Method: AddAttribute()
	AddAttribute(attrib)
		Overrides MfObject.AddAttribute Sealed Class will never have attribute
	Parameters:
		attrib
			The object instance derived from MfAttribute to add.
	Throws:
		Throws MfNotSupportedException
*/
	AddAttribute(attrib) {
		ex := new MfNotSupportedException()
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex		
	}
;	End:AddAttribute() ;}
;{	GetAttribute()
/*
	Method: GetAttribute()

	OutputVar := instance.GetAttribute(index)

	GetAttribute(index)
		Overrides MfObject.GetAttribute Sealed Class will never have attribute
	Parameters:
		index
			the zero-based index. Can be MfInteger or var containing Integer number.
	Throws:
		Throws MfNotSupportedException
*/
	GetAttribute(index) {
		ex := new MfNotSupportedException()
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
;	End:GetAttribute() ;}
;	GetAttributes ;}
/*
	Method: GetAttributes()

	OutputVar := instance.GetAttributes()

	GetAttributes()
		Overrides MfObject.GetAttributes Sealed Class will never have attribute
	Throws:
		Throws MfNotSupportedException
*/
	GetAttributes()	{
		ex := new MfNotSupportedException()
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
;	End:GetAttributes ;}
;{	GetIndexOfAttribute()
/*
	GetIndexOfAttribute(attrib)
		Overrides MfObject.GetIndexOfAttribute. Sealed Class will never have attribute
	Parameters:
		attrib
			The object instance derived from MfAttribute.
	Throws:
		Throws MfNotSupportedException
*/
	GetIndexOfAttribute(attrib) {
		ex := new MfNotSupportedException()
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
;	End:GetIndexOfAttribute() ;}
;{	HasAttribute()
/*
	HasAttribute(attrib)
		Overrides MfObject.HasAttribute. Sealed Class will never have attribute
	Parameters:
		attrib
			The object instance derived from MfAttribute.
	Throws:
		Throws MfNotSupportedException
*/
	HasAttribute(attrib) {
		ex := new MfNotSupportedException()
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
;	End:HasAttribute() ;}
; End:MfObject Attribute Overrides ;}
; End:Method ;}
	
}
/*!
	End of class
*/