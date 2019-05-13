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
	Class: MfQueue
		Represents a first-in, first-out collection of objects.
	Inherits: MfEnumerableBase
*/
class MfQueue extends MfEnumerableBase
{
	m_list 		:= Null
	m_version 	:= 0
;{ Constructor
	/*!
		Constructor: ()
			Initializes a new instance of the MfQueue class
	*/
	__New() {
		base.__New()
		this.m_isInherited := this.__Class != "MfQueue"
		this.m_list := new MfList()
		this.m_version := 0
	}
; End:Constructor ;}
;{ Methods
;{ 	Clear()
/*
	Clear()
		Removes all objects from the MfQueue.
*/
	Clear() {
		this.m_list.Clear()
		this.m_version++
	}
; End:Clear() ;}
;{ 	Clone
	; since 0.4
	Clone() {
		q := new MfQueue()
		if (this.Count > 0)
		{
			q.m_list := this.m_list.Clone()
		}
		q.m_version := this.m_version
		return q
	}
; 	End:Clone ;}
;{ 	Contains(obj)
/*
	Method: Contains()

	OutputVar := instance.Contains(obj)

	Contains()
		Determines whether the MfQueue contains a specific element.
	Parameters:
		obj
			The Object to locate in the MfQueue.
	Returns:
		Returns var with value of true if the MfQueue contains the specified value otherwise, false.
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
					return new true
				}
			}
			else
			{
				cObj := this.m_list.Item[size]
				if (IsObject(cObj)) {
					if ((objIsAhkObj) && (MfObject.IsObjInstance(cObj))) {
						if (cObj.CompareTo(obj) = 0) { ; both objects are MfObject instances so we can call compare to
							return new true
						}
					}
				} else {
					if (!objIsAhkObj) {
						if (cObj = obj) { ; both are vars and not object so simple compare
							return new true
						}
					}
				}
				
			}
			size--
		}
		return new false
	}
; End:Contains(obj) ;}
;{ 	Dequeue()
/*
	Method: Dequeue()

	OutputVar := instance.Dequeue()

	Dequeue()
		Removes and returns the object at the beginning of the MfQueue.
	Returns:
		Returns he object that is removed from the beginning of the MfQueue.
	Throws:
		Throws MfInvalidOperationException if the MfQueue is empty.
	Remarks:
		If current Dequeue value is a null or empty then Null is returned.
*/
	Dequeue() {
		if (this.Count = 0)
		{
			ex := new MfInvalidOperationException(MfEnvironment.Instance.GetResourceString("InvalidOperation_Empty_Quence"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		obj := this.m_list.RemoveAt(0)
		this.m_version++
		if (MfNull.IsNull(obj)) {
			return Null
		}
		return obj
	}
; End:Dequeue() ;}
;{ 	Enqueue(obj)
/*
	Method: Enqueue()
	Enqueue(obj)
		Adds an object to the end of the MfQueue.
	Parameters:
		obj
			The object to add to the MfQueue. The value can be Null.
*/
	Enqueue(obj) {
		if (MfNull.IsNull(obj)) {
			this.m_list.Add(MfNull.Null)
		} else {
			this.m_list.Add(obj)
		}
		this.m_version++
	}
; End:Enqueue(obj) ;}
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
        return new MfQueue.Enumerator(this)
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
        
       Next(ByRef key, ByRef value) {
		
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
;{ 	Peek()
/*
	Method: Peek()

	OutputVar := instance.Peek()

	Peek()
		Returns the object at the beginning of the MfQueue without removing it.
	Returns:
		Returns The object at the beginning of the MfQueue.
	Throws:
		Throws MfInvalidOperationException if the MfQueue is empty.
	Remarks:
		If current Peek value is a null or empty then Null is returned.
*/
	Peek() {
		if (this.Count = 0)
		{
			ex := new MfInvalidOperationException(MfEnvironment.Instance.GetResourceString("InvalidOperation_Empty_Quence"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		obj := this.m_list.Item[0]
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
		Gets a value indicating count of objects in the current MfQueue
	Value:
		Var integer
	Gets:
		Get the count as integer
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