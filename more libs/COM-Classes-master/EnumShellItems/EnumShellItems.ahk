/*
class: EnumShellItems
wraps the *IEnumShellItems* interface and exposes enumeration of IShellItem interfaces.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/EnumShellItems)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb761962)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows Vista / Windows Server 2008 or higher
	Base classes - _CCF_Error_Handler_, Unknown
	Other classes - ShellItem
*/
class EnumShellItems
{
	/*
	Field: IID
	This is IID_IEnumShellItems. It is required to create an instance.
	*/
	static IID := "{70629033-e363-4a28-a567-0db78006e6d7}"

	/*
	Field: ThrowOnCreation
	Indicates that attempting to create an instance of this class without supplying a valid pointer should throw an exception.
	*/
	static ThrowOnCreation := true

	/*
	Method: Next
	Gets an array of one or more IShellItem interfaces from the enumeration.

	Parameters:
		UINT count - the number of items to retrieve
		byRef var array - receives an array of pointers to IShellItem interfaces that receive the enumerated item or items. The calling application is responsible for freeing the IShellItem interfaces by calling the IUnknown::Release method.
		[opt] byRef UINT retrievedCount - receives the number of items actually retrieved.

	Returns:
		BOOL success - true on success, false otherwise

	Example:
		(start code)
		enum := new EnumShellItems(ptr) ; ptr must be a valid pointer
		enum.Next(2, array)
		MsgBox % "The first item's memory pointer: " . NumGet(&array, 0, "UPtr")
		(end code)
	*/
	Next(count, byRef array, byRef retrievedCount := "")
	{
		VarSetCapacity(array, count * A_PtrSize, 0)
		return this._Error(DllCall(NumGet(this.vt+03*A_PtrSize), "ptr", this.ptr, "uint", count, "ptr", &array, "uint*", retrievedCount))
	}

	/*
	Method: Skip
	Skips a given number of IShellItem interfaces in the enumeration.

	Parameters:
		UINT count - the number of items to skip

	Returns:
		BOOL success - true on success, false otherwise
	*/
	Skip(count)
	{
		return this._Error(DllCall(NumGet(this.vt+04*A_PtrSize), "ptr", this.ptr, "uint", count))
	}

	/*
	Method: Reset
	Resets the internal count of retrieved IShellItem interfaces in the enumeration.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	Reset()
	{
		return this._Error(DllCall(NumGet(this.vt+05*A_PtrSize), "ptr", this.ptr))
	}

	/*
	Method: Clone
	Gets a copy of the current enumeration.

	Returns:
		EnumShellItems copy - a copy of this enumeration
	*/
	Clone()
	{
		local out
		this._Error(DllCall(NumGet(this.vt+06*A_PtrSize), "ptr", this.ptr, "ptr*", out))
		return new EnumShellItems(out)
	}
}