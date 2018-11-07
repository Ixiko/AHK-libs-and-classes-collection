/*
class: ProvideClassInfo
wraps the *IProvideClassInfo* interface and provides access to the type information for an object's coclass entry in its type library.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/ProvideClassInfo)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms687303)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 2000 / Windows 2000 Server or higher
	Base classes - _CCF_Error_Handler_, Unknown
	Other classes - TypeInfo
*/
class ProvideClassInfo extends Unknown
{
	/*
	Field: IID
	This is IID_IProvideClassInfo. It is required to create an instance.
	*/
	static IID := "{B196B283-BAB4-101A-B69C-00AA00341D07}"

	/*
	Field: ThrowOnCreation
	indicates that attempting to create an instance of this class without supplying a valid pointer should throw an exception.
	*/
	static ThrowOnCreation := true

	/*
	Method: GetClassInfo
	Retrieves a pointer to the ITypeInfo interface for the object's type information.

	Returns:
		TypeInfo info - the information,  either as class instance (if available) or as raw interface pointer
	*/
	GetClassInfo()
	{
		local out
		this._Error(DllCall(NumGet(this.vt, 03*A_PtrSize, "Ptr"), "Ptr", this.ptr, "Ptr*", out, "Int"))
		return IsObject(TypeInfo) ? new TypeInfo(out) : out
	}
}