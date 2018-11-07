/*
class: UIAutomationCondition
wraps the *IUIAutomationCondition* interface and serves as an abstract base class for other condition types.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/UIAutomationCondition)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ee671420)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 7, Windows Vista with SP2 and Platform Update for Windows Vista, Windows XP with SP3 and Platform Update for Windows Vista, Windows Server 2008 R2, Windows Server 2008 with SP2 and Platform Update for Windows Server 2008, Windows Server 2003 with SP2 and Platform Update for Windows Server 2008
	Base classes - _CCF_Error_Handler_, Unknown
*/
class UIAutomationCondition extends Unknown
{
	/*
	Field: IID
	This is IID_IUIAutomationCondition. It is required to create an instance.
	*/
	static IID := "{352ffba8-0973-437c-a61f-f64cafd81df9}"

	/*
	Field: ThrowOnCreation
	ndicates that attempting to create an instance of this class without supplying a valid pointer should throw an exception.
	*/
	static ThrowOnCreation := true
}