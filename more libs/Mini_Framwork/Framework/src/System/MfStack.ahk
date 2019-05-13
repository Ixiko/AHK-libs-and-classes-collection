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
	Class: MfStack
		Represents a simple last-in-first-out (LIFO) collection of objects.
	Inherits: MfEnumerableBase
*/
class MfStack extends MfEnumerableBase
{
	m_list 		:= Null
	m_version 	:= 0
;{ Constructor
/*
	Constructor: ()
		Initializes a new instance of the MfStack class.
*/
	__New() {
		base.__New()
		this.m_isInherited := this.__Class != "MfStack"
		this.m_list := new MfList()
		this.m_version := 0
	}
; End:Constructor ;}
;{ Methods
;{ 	Clear()
/*
	Method: Clear()
		Clear() Removes all objects from the [MfStack](MfStack.html).
*/
	Clear() {
		this.m_list.Clear()
		this.m_version ++
	}
; End:Clear() ;}
;{ 	Clone
	; since 0.4
	Clone() {
		st := new MfStack()
		if (this.Count > 0)
		{
			st.m_list := this.m_list.Clone()
		}
		st.m_version := this.m_version
		return st
	}
; 	End:Clone ;}
;{ 	Contains(obj)
/*
	Method: Contains()

	OutputVar := instance.Contains(obj)

	Contains()
		Determines whether the MfStack contains a specific element.
	Parameters:
		obj
			The Object to locate in the MfStack.
	Returns:
		Returns var with value of true if the MfStack contains the specified value; Otherwise false.
*/
	Contains(obj) {
		size := this.Count - 1
		objIsAhkObj := MfObject.IsObjInstance(Obj)
		while (size > -1)
		{
			
			if (MfNull.IsNull(obj))
			{
				if (this.m_list.Item[size] = Null)
				{
					return true
				}
			}
			else
			{
				cObj := this.m_list.Item[size]
				if (IsObject(cObj)) {
					if ((objIsAhkObj) && (MfObject.IsObjInstance(cObj))) {
						if (cObj.CompareTo(obj) = 0) { ; both objects are MfObject instances so we can call compare to
							return true
						}
					}
				} else {
					if (!objIsAhkObj) {
						if (cObj = obj) { ; both are vars and not object so simple compare
							return true
						}
					}
				}
				
			}
			size--
		}
		return new false
	}
; End:Contains(obj) ;}
;{ 	Pop()
/*
	Method: Pop()

	OutputVar := instance.Pop()

	Pop()
		Removes and returns the object at the top of the MfStack.
	Returns:
		Returns he object that is removed from the top of the MfStack.
	Throws:
		Throws MfInvalidOperationException if the MfStack is empty.
	Remarks:
		If current Pop value is a null or empty then Null is returned.
*/
	Pop() {
		if (this.Count = 0)
		{
			ex := new MfInvalidOperationException(MfEnvironment.Instance.GetResourceString("InvalidOperation_Empty_Stack"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_Index := this.Count - 1
		obj := this.m_list.RemoveAt(_Index)
		this.m_version++
		if (MfNull.IsNull(obj)) {
			return Null
		}
		return obj
	}
; End:Dequeue() ;}
;{ Enumerator

; insert this snipit inside the body of a list based class
;{ 		_NewEnum
/*
	Method: _NewEnum()
		Overrides MfEnumerableBase._NewEnum()
	_NewEnum()
		Returns a new enumerator to enumerate this object's key-value pairs.
		This method is usually not called directly, but by the for-loop or by GetEnumerator()
	Remarks:
		Protected Method.
*/
	_NewEnum() {
        return new MfStack.Enumerator(this)
    }
; 		End:_NewEnum ;}
;{ 		class Enumerator
    class Enumerator
	{
		m_Parent := Null
		m_KeyEnum := Null
		m_index := 0
		m_count := 0
		m_InnerList := ""
        __new(ParentClass) {
            this.m_Parent := ParentClass
			this.m_count := this.m_Parent.m_list.Count
			this.m_InnerList := this.m_Parent.m_list.m_InnerList
        }
        
       Next(ByRef key, ByRef value)
	   {
		
			if (this.m_index < this.m_count) {
				key := this.m_index
				value := this.m_InnerList[key + 1]
			}
			this.m_index++
			if (this.m_index > this.m_count) {
				return 0
			} else {
				return true
			}
        }
		
		
    }
; 		End:class Enumerator ;}
; End:Enumerator ;}
;{ 	Push(obj)
/*
	Method: Push()

	OutputVar := instance.Push(obj)

	Push()
		Inserts an object at the top of the MfStack.
	Parameters:
		obj
			The object to push to the MfStack. The value can be Null.
*/
	Push(obj) {
		if (MfNull.IsNull(obj)) {
			this.m_list.Add(MfNull.Null)
		} else {
			this.m_list.Add(obj)
		}
		
		this.m_version++
	}
; End:Enqueue(obj) ;}
;{ 	Peek()
/*
	Method: Peek()

	OutputVar := instance.Peek()

	Peek()
		Returns the object at the top of the MfStack without removing it.
	Returns:
		Returns The object at the top of the MfStack.
	Throws:
		Throws MfInvalidOperationException if the MfStack is empty.
	Remarks:
		If current Peek value is a null or empty then Null is returned.
*/
	Peek() {
		if (this.Count = 0)
		{
			ex := new MfInvalidOperationException(MfEnvironment.Instance.GetResourceString("InvalidOperation_Empty_Stack"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_Index := this.Count - 1
		obj := this.m_list.Item[_Index]
		if (MfNull.IsNull(obj)) {
			return Null
		}
		return obj
	}
; End:Peek() ;}
; End:Methods ;}
;{ Properties
/*
	Property: Count [get]
		Gets a value indicating count of objects in the current MfStack
	Value:
		Var integer
	Gets:
		Get the count as integer
	Remarks:
		Read-only Property
*/
	Count[]
	{
		get {
			if (this.m_list) {
				return this.m_list.Count
			}
			return 0
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; End:Properties ;}
}
/*!
	End of class
*/