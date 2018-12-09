/*
class: UIAutomationNotCondition
wraps the *IUIAutomationNotCondition* interface and represents a condition that is the negative of another condition.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/UIAutomationNotCondition)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ee696106)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 7, Windows Vista with SP2 and Platform Update for Windows Vista, Windows XP with SP3 and Platform Update for Windows Vista, Windows Server 2008 R2, Windows Server 2008 with SP2 and Platform Update for Windows Server 2008, Windows Server 2003 with SP2 and Platform Update for Windows Server 2008
	Base classes - _CCF_Error_Handler_, Unknown, UIAutomationCondition
*/
class UIAutomationNotCondition extends UIAutomationCondition
{
	/*
	Field: IID
	This is IID_IUIAutomationNotCondition. It is required to create an instance.
	*/
	static IID := "{f528b657-847b-498c-8896-d52b565407a1}"

	/*
	Field: ThrowOnCreation
	Indicates that attempting to create an instance of this class without supplying a valid pointer should throw an exception.
	*/
	static ThrowOnCreation := true

	/*
	Method: GetChild
	Retrieves the condition of which this condition is the negative.

	Returns:
		UIAutomationCondition child - the retrieved condition as UIAutomationCondition instance
	*/
	GetChild()
	{
		local out
		this._Error(DllCall(NumGet(this.vt+03*A_PtrSize), "ptr", this.ptr, "ptr*", out))
		return new UIAutomationCondition(out)
	}
}