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

/*!
	Class: MfResourceSingletonBase
		MfResourceSingletonBase Abstract
	Inherits: MfSingletonBase
	Extra:
		The MfResourceSingletonBase class is not intended to be use by developer but rather by the Mini-Framwork.  
		Internal Sealed Class  
*/
class MfResourceSingletonBase extends MfSingletonBase
{

;{ Constructor
/*
	Method: Constructor()
		Constructor new instance of MfResourceSingletonBase class

	OutPutVar := new MfResourceSingletonBase()

		Throws MfNotSupportedException is class is extended.
	Remarks:
		Internal Sealed Class.
*/
	 __New() {
       ; Throws MfNotSupportedException if MfSingletonBase Abstract class constructor is called directly.
		if (this.__Class = "MfResourceSingletonBase") {
			throw new MfNotSupportedException("ABSTRACT CLASS", "MfResourceSingletonBase")
		}
        base.__New()
        this.m_isInherited := this.__Class != "MfResourceSingletonBase"
    }
; End:Constructor ;}

;{ 	DestroyInstance()
/*
	Method: DestroyInstance()
		Overrides MfSingletonBase.DestroyInstance()
		Abstract Method.
	DestroyInstance()
		Set current instance of singleton derived class to null.
	Throws:
		Throws MfNotImplementedException if not implemented in derived class.
	Remarks:
		Abstract Method.
		DestroyInstance() is an abstract method and must be implemeted in derived class.
*/
	DestroyInstance() {
		throw new MfNotImplementedException("NOT IMPLEMENTED - DestroyInstance")
		ex.Source := A_ThisFunc
		throw ex
	}
; End:DestroyInstance() ;}
;{ GetResourceString
/*
	Method: GetResourceString()
		Abstract Method

	OutputVar := GetResourceString(key)
	OutputVar := GetResourceString(key, args)

	GetResourceString(key)
		Gets a resource string from the current resource file for the given key.

	GetResourceString(key, args*)
		Gets a resource string from the current resource file for the given key and formats the resource string with the args*.
	Parameters:
		key
			The key of the resource string
			args*
			arguments that can be passed in to format a string.
	Throws:
		Throws MfNotImplementedException if not overridden in derived classes.
	Remarks:
		Abstract Method.
		Must be overridden in derived classes.
*/
	GetResourceString(key , args*) {
       throw new MfNotImplementedException("NOT IMPLEMENTED - GetResourceString")          
	}
; End:GetResourceString ;}
;{ GetResourceStringBySection
/*
	Method: GetResourceStringBySection()
		Abstract Method

	OutputVar := instance.GetResourceStringBySection(Key, section)
	OutputVar := instance..GetResourceStringBySection(Key, section, args)

	GetResourceStringBySection(Key, section)
		Gets a resource string from the current resource file for the specified section and key.

	GetResourceStringBySection(Key, section, args*)
		Gets a resource string from the current resource file for the specified section and key.
		The resource string is formated by the args*.
	Parameters:
		key
			The key of the resource string
		section
			Section of resource ini to get string value from.
			args*
			arguments that can be passed in to format a string.
	Throws:
		Throws MfNotImplementedException if not overridden in derived classes.
	Remarks:
		Abstract Method.
		Must be overridden in derived classes.
*/
	GetResourceStringBySection(key, section, args*) {
       throw new MfNotImplementedException("NOT IMPLEMENTED - GetResourceStringBySection")        
	}
; End:GetResourceString ;}
;{ 	GetInstance()
/*
	Method: GetInstance()
		Overrides MfSingletonBase.GetInstance()
		Protected Abstract Method

	OutputVar := GetInstance()

	GetInstance()
		Protected Abstract method. Gets the instance of the Singleton
	Returns:
		Returns Singleton instance for the derived class.
	Throws:
		Throws MfNotImplementedException if method is not overridden in derived classes
	Remarks:
		This method must be overridden in derived classes.
*/
	GetInstance() {
		throw new MfNotImplementedException("NOT IMPLEMENTED - GetInstance")
	}
; 	End:GetInstance() ;}

}
/*!
	End of class
*/