/*
class: Persist
wraps the *IPersist* interface and provides the CLSID of an object that can be stored persistently in the system.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/Persist)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms688695)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 2000 Professional / Windows XP / Windows Server 2003 or higher
	Base classes - _CCF_Error_Handler_, Unknown
	Other classes - CCFramework
*/
class Persist extends Unknown
{
	/*
	Field: IID
	This is IID_IPersist. It is required to create an instance.
	*/
	static IID := "{0000010c-0000-0000-C000-000000000046}"

	/*
	Field: ThrowOnCreation
	indicates that attempting to create an instance of this class without supplying a valid pointer should throw an exception.
	*/
	static ThrowOnCreation := true

	/*
	Method: GetClassID
	Retrieves the class identifier (CLSID) of the object.

	Returns:
		STR clsid - the CLSID of the object (as string)
	*/
	GetClassID()
	{
		local guid
		VarSetCapacity(guid, 16, 0)
		this._Error(DllCall(NumGet(this.vt+3*A_PtrSize), "ptr", this.ptr, "ptr", &guid))
		return CCFramework.GUID2String(&guid)
	}
}