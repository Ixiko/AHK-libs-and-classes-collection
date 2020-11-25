; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

TabActivate(TabName, WinTitle) {
	;~ Set Constants / Static Variables
	static	UIA_ControlTypePropertyId := 30003
		,	UIA_NamePropertyId := 30005
		,	TabItem := 50019
		,	VT_I4 := 3
		,	VT_BSTR := 8
		,	TreeScope_Descendants := 0x4
		,	uia := UIA_Interface()
		,	Condition1

	;~ Get Internet Explorer UIA Element
	WinGet, hwnd, ID, %WinTitle%
	ie := uia.ElementFromHandle(hwnd)
	
	;~ Set Conditions to find sub-element (TabItem)
	if Not Condition1
		Condition1 := uia.CreatePropertyCondition(UIA_ControlTypePropertyId, TabItem, VT_I4)
	Condition2 := uia.CreatePropertyCondition(UIA_NamePropertyId, TabName, VT_BSTR)
	AndCondition := uia.CreateAndCondition(Condition1,Condition2)
	
	;~ Query for the first matching sub-element
	tab := ie.FindFirst(AndCondition, TreeScope_Descendants)
	
	;~ Access the Legacy Pattern
		;~ Legacy Pattern is similar to the Accessible Interface, which has the DoDefaultAction method (Press)
	legacy := tab.GetCurrentPatternAs("LegacyIAccessible")
	legacy.DoDefaultAction()
}