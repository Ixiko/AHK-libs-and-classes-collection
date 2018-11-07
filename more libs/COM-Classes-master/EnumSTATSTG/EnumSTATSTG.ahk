/*
class: EnumSTATSTG
wraps the *IEnumSTATSTG* interface and enumerates an array of STATSTG structures.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/EnumSTATSTG)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/aa379217)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows Vista / Windows Server 2008 or higher
	Base classes - _CCF_Error_Handler_, Unknown
	Structure classes - STATSTG
*/
class EnumSTATSTG extends Unknown
{
	/*
	Field: IID
	This is IID_IEnumSTATSTG. It is required to create an instance.
	*/
	static IID := "{70629033-e363-4a28-a567-0db78006e6d7}"

	/*
	Field: ThrowOnCreation
	Indicates that attempting to create an instance of this class without supplying a valid pointer should throw an exception.
	*/
	static ThrowOnCreation := true

	/*
	Method: Next
	Gets an array of one or more STATSTG structures from the enumeration.

	Parameters:
		UINT count - the number of items to retrieve
		byRef STATSTG[] array - receives an AHK-array of STATSTG structures either as class instances (if available) or pointers
		[opt] byRef UINT retrievedCount - receives the number of items actually retrieved.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	Next(count, byRef array, byRef retrievedCount := "")
	{
		local mem_array, bool
		static stat_size := STATSTG.GetRequiredSize()

		bool := this._Error(DllCall(NumGet(this.vt+03*A_PtrSize), "Ptr", this.ptr, "UInt", count, "Ptr*", mem_array, "UInt*", retrievedCount))
		, array := []

		Loop retrievedCount
		{
			offset := mem_array + (A_Index - 1) * stat_size
			, array.Insert(IsObject(STATSTG) ? STATSTG.FromStructPtr(offset, false) : offset)
		}
		return bool
	}

	/*
	Method: Skip
	Skips a given number of STATSTG structures in the enumeration.

	Parameters:
		UINT count - the number of items to skip

	Returns:
		BOOL success - true on success, false otherwise
	*/
	Skip(count)
	{
		return this._Error(DllCall(NumGet(this.vt+04*A_PtrSize), "Ptr", this.ptr, "UInt", count))
	}

	/*
	Method: Reset
	resets the enumeration sequence to the beginning of the STATSTG structure array.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	Reset()
	{
		return this._Error(DllCall(NumGet(this.vt+05*A_PtrSize), "Ptr", this.ptr))
	}

	/*
	Method: Clone
	Gets a copy of the current enumeration.

	Returns:
		EnumSTATSTG copy - a copy of this enumeration
	*/
	Clone()
	{
		local out
		this._Error(DllCall(NumGet(this.vt+06*A_PtrSize), "Ptr", this.ptr, "Ptr*", out))
		return new EnumSTATSTG(out)
	}
}