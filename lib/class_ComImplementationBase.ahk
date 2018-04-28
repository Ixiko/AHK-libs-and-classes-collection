/*

  Version: MPL 2.0/GPL 3.0/LGPL 3.0

  The contents of this file are subject to the Mozilla Public License Version
  2.0 (the "License"); you may not use this file except in compliance with
  the License. You may obtain a copy of the License at

  http://www.mozilla.org/MPL/

  Software distributed under the License is distributed on an "AS IS" basis,
  WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
  for the specific language governing rights and limitations under the License.

  The Initial Developer of the Original Code is
  cpriest <https://autohotkey.com/boards/memberlist.php?mode=viewprofile&u=81878>.
  Minor changes by Elgin <Elgin_1@zoho.eu>.
  Portions created by the Initial Developer are Copyright (C) 2017
  the Initial Developer. All Rights Reserved.

  Contributor(s):

  Alternatively, the contents of this file may be used under the terms of
  either the GNU General Public License Version 3 or later (the "GPL"), or
  the GNU Lesser General Public License Version 3.0 or later (the "LGPL"),
  in which case the provisions of the GPL or the LGPL are applicable instead
  of those above. If you wish to allow use of your version of this file only
  under the terms of either the GPL or the LGPL, and not to allow others to
  use your version of this file under the terms of the MPL, indicate your
  decision by deleting the provisions above and replace them with the notice
  and other provisions required by the GPL or the LGPL. If you do not delete
  the provisions above, a recipient may use your version of this file under
  the terms of any one of the MPL, the GPL or the LGPL.

*/

; ==============================================================================
; ==============================================================================
; This file provides the basis classes for implementing COM objects in AHK
; for use with the libraries created by TypeLib2AHK.
; This file needs to be included in the schript if a used library contains
; implemented COM objects.
; ==============================================================================
; ==============================================================================

class Heap {
	ProcessHeap {
		get {
			static heap := DllCall("GetProcessHeap", "Ptr")
			return heap
		}
	}
	Allocate(bytes) {
		static HEAP_GENERATE_EXCEPTIONS := 0x00000004, HEAP_ZERO_MEMORY := 0x00000008
		return DllCall("HeapAlloc", "Ptr", Heap.ProcessHeap, "UInt", HEAP_GENERATE_EXCEPTIONS|HEAP_ZERO_MEMORY, "UInt", bytes, "UPtr")
	}
	GetSize(buffer) {
		return DllCall("HeapSize", "Ptr", Heap.ProcessHeap, "UInt", 0, "Ptr", buffer, "Ptr" )
	}
	Release(buffer) {

		return DllCall("HeapFree", "Ptr", Heap.ProcessHeap, "UInt", 0, "Ptr", buffer, "Int")
	}
}

StringFromCLSID(riid) {
	res := DllCall("ole32\StringFromCLSID", "Ptr", riid, "PtrP", pStrCLSID := 0)
	sCLSID := StrGet(pStrCLSID, "UTF-16")
	DllCall("ole32\CoTaskMemFree", "Ptr", pStrCLSID)
	return sCLSID
}

global 	VT 		:= 0
	   ,REFS 	:= 1

/**
 *	Base implementation for all Com Objects
 *		- Handles creation of static vTable
 *		- Registers new class instance with vtoMap for efficient memory management of vTable use
 *		- Creates global pObject pointer for use with COM
 *
 *	 NOTE - Tested that:
 *		- this.vTable and this.vtoMap accesses the static declaration in the top level class declaration
 */
class ComObjImpl {

	; Pointers to vTables by this.IID
	static vTables := { }
	; Map of Interface Pointers to Object by this.IID
	static ObjMap := { }

	; Array of string GUID Com Interfaces that this object implements
	ImplementsInterfaces := []

	; Array of Com Functions that are implemented in the class hierarchy
	ComFunctions := []

	__New() {
		; Using the last Interface in the implementation array, this *should* be the highest IID in the chain
		this.IID := this.ImplementsInterfaces[this.ImplementsInterfaces.Length()]

		this.PopulateVirtualMethodTable()

		this.pInterface := Heap.Allocate(A_PtrSize + 4)
		ComObjImpl.ObjMap[this.pInterface] := this
		ObjRelease(&this)	; Release the reference just created, this reference will be free'd when __Delete is actually called

		NumPut(ComObjImpl.vTables[this.IID][VT], this.pInterface, 0, "Ptr")
		ComObjImpl.vTables[this.IID][REFS] += 1

		Refs := this._AddRef(this.pInterface)	; Adding our own reference, on delete should be 0
	}

	/**
	 *	Populates the static this.vTable with the callback points
	 *		NOTE: vTable is being passed in ByRef because it would seem using this.vTable with
	 *		VarSetCapacity/NumPut does not function correctly, using them on a ByRef of it works
	 *		just fine.
	 */
	PopulateVirtualMethodTable() {
		if (!ComObjImpl.vTables[this.IID]) {
			; Allocate a Ptr record for each method in ComFunctions
			ComObjImpl.vTables[this.IID, VT] := Heap.Allocate(this.ComFunctions.Length() * A_PtrSize)
			ComObjImpl.vTables[this.IID, REFS] := 0

			for i, func in this.ComFunctions {
				callback := RegisterCallback(this["_" func].Name)

				NumPut(callback, ComObjImpl.vTables[this.IID][VT], (i-1) * A_PtrSize)
			}
		}
	}

	__Delete() {
		ComObjImpl.ObjMap[this.pInterface] :=
		ComObjImpl.vTables[this.IID][REFS] -= 1

		Heap.Release(this.pInterface)

		if (ComObjImpl.vTables[this.IID][REFS] == 0) {
			Heap.Release(ComObjImpl.vTables[this.IID][VT])
			ComObjImpl.vTables[this.IID] :=
		}
	}
}

class IUnknownImpl extends ComObjImpl {
	; Declare the functions our class is implementing (expected to be over-ridden by sub-classes)
	; This array should be complete for the interface and in the correct vTable order per the Type Library
	ComFunctions := ["QueryInterface", "AddRef", "Release"]

	__New() {
		; Add the GUID of the interface this class is implementing
		this.ImplementsInterfaces.InsertAt(1, "{00000000-0000-0000-C000-000000000046}")		; IUnknown
		base.__New()
	}
	/**
	 *	Implementation of IUnknown::QueryInterface
	 *		Each class level that implements some part of the final vTable should have its interface GUID
	 *		declared in this.ImplementsInterface array
	 */
	_QueryInterface(pInterface, riid, ppvObject) {
		if (!IsObject(this))
			return ComObjImpl.ObjMap[this]._QueryInterface(this, pInterface, riid)

		sCLSID := StringFromCLSID(riid)

		for i, sIID in this.ImplementsInterfaces {
			if (sCLSID == sIID) {
				NumPut(pInterface, ppvObject+0, "Ptr")

				this._AddRef(pInterface)
				return 0 ; S_OK
			}
		}

		NumPut(pInterface, ppvObject+0, "Ptr")
		return -2147467262 ; 0x80004002 0xFFFFFFFF80004002 E_NOINTERFACE
	}

	; Implementation of IUnknown::AddRef
	_AddRef(pInterface) {
		if (!IsObject(this))
			return ComObjImpl.ObjMap[this]._AddRef(this)

		NumPut((RefCount := NumGet(pInterface+0, A_PtrSize, "UInt") + 1), pInterface+0, A_PtrSize, "UInt")

		return RefCount
	}

	; Implementation of IUnknown::Release
	_Release(pInterface) {
		if (!IsObject(this))
			return ComObjImpl.ObjMap[this]._Release(this)

		if ((RefCount := this.GetRefs()) > 0) {
			RefCount -= 1
			NumPut(RefCount, pInterface+0, A_PtrSize, "UInt")
		}

		return RefCount
	}

	GetRefs() {
		return NumGet(this.pInterface+0, A_PtrSize, "UInt")
	}

	__Delete() {
		if ( (RefCount := this.GetRefs()) != 1)
			OutputDebug % Format("WARNING: RefCount={} in {}, should be 1 (our own reference)", RefCount, A_ThisFunc "()")
		base.__Delete()
	}
}

