/*
class: UIAutomationElementArray
wraps the *IUIAutomationElementArray* interface and represents a collection of UI Automation elements.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/UIAutomationElementArray)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ee671426)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 7, Windows Vista with SP2 and Platform Update for Windows Vista, Windows XP with SP3 and Platform Update for Windows Vista, Windows Server 2008 R2, Windows Server 2008 with SP2 and Platform Update for Windows Server 2008, Windows Server 2003 with SP2 and Platform Update for Windows Server 2008
	Base classes - _CCF_Error_Handler_, Unknown
*/
class UIAutomationElementArray extends Unknown
{
	/*
	Field: IID
	This is IID_IUIAutomationElementArray. It is required to create an instance.
	*/
	static IID := "{14314595-b4bc-4055-95f2-58f2e42c9855}"

	/*
	Field: ThrowOnCreation
	ndicates that attempting to create an instance of this class without supplying a valid pointer should throw an exception.
	*/
	static ThrowOnCreation := true

	/*
	Method: get_Length
	Retrieves the length of the array.

	Returns:
		UINT length - the number of elements in the array
	*/
	get_Length()
	{
		local length
		this._Error(DllCall(NumGet(this.vt+3*A_PtrSize), "ptr", this.ptr, "Int*", length))
		return length
	}

	/*
	Method: GetElement
	Retrieves an element from the array.

	Parameters:
		INT index - The zero-based index of the element.

	Returns:
		UIAutomationElement element - the element, either as class instance (if available) or as raw interface pointer
	*/
	GetElement(index)
	{
		local out
		this._Error(DllCall(NumGet(this.vt+03*A_PtrSize), "ptr", this.ptr, "Int", index, "ptr*", out))
		return IsObject(UIAutomationElement) ? new UIAutomationElement(out) : out
	}

	/*
	group: meta-functions

	Method: __Get
	meta-function for reading pseudo-properties
	*/
	__Get(property)
	{
		if (property = "Length")
			return this.get_Length()
	}

	/*
	group: dynamic properties

	========================================================================================================
	Field: Length
	Retrieves the length of the array.

	Access: read-only

	corresponding methods: <get_Length>
	*/
}