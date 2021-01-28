;~ UI Automation Constants: http://msdn.microsoft.com/en-us/library/windows/desktop/ee671207(v=vs.85).aspx
;~ UI Automation Enumerations: http://msdn.microsoft.com/en-us/library/windows/desktop/ee671210(v=vs.85).aspx
;~ http://www.autohotkey.com/board/topic/94619-ahk-l-screen-reader-a-tool-to-get-text-anywhere/

/* Questions:
	- better way to do __properties?
	- support for Constants?
	- if method returns a SafeArray, should we return a Wrapped SafeArray, Raw SafeArray, or AHK Array
	- on UIA Interface conversion methods, how should the data be returned? wrapped/extracted or raw? should raw data be a ByRef param?
	- do variants need cleared? what about SysAllocString BSTRs?
	- do RECT struts need destroyed?
	- if returning wrapped data & raw is ByRef, will the wrapped data being released destroy the raw data?
	- returning varaint data other than vt=3|8|9|13|0x2000
	- Cached Members?
	- UIA Element existance - dependent on window being visible (non minimized)?
	- function(params, ByRef out="……")
*/

class UIA_Base {
	__New(p="", flag=1) {
		ObjInsert(this,"__Type","IUIAutomation" SubStr(this.__Class,5))
		,ObjInsert(this,"__Value",p)
		,ObjInsert(this,"__Flag",flag)
	}
	__Get(member) {
		if member not in base,__UIA ; base & __UIA should act as normal
		{	if raw:=SubStr(member,0)="*" ; return raw data - user should know what they are doing
				member:=SubStr(member,1,-1)
			if RegExMatch(this.__properties, "im)^" member ",(\d+),(\w+)", m) { ; if the member is in the properties. if not - give error message
				if (m2="VARIANT")	; return VARIANT data - DllCall output param different
					return UIA_Hr(DllCall(this.__Vt(m1), "ptr",this.__Value, "ptr",UIA_Variant(out)))? (raw?out:UIA_VariantData(out)):
				else if (m2="RECT") ; return RECT struct - DllCall output param different
					return UIA_Hr(DllCall(this.__Vt(m1), "ptr",this.__Value, "ptr",&(rect,VarSetCapacity(rect,16))))? (raw?out:UIA_RectToObject(rect)):
				else if UIA_Hr(DllCall(this.__Vt(m1), "ptr",this.__Value, "ptr*",out))
					return raw?out:m2="BSTR"?StrGet(out):RegExMatch(m2,"i)IUIAutomation\K\w+",n)?new UIA_%n%(out):out ; Bool, int, DWORD, HWND, CONTROLTYPEID, OrientationType?
			}
			else throw Exception("Property not supported by the " this.__Class " Class.",-1,member)
		}
	}
	__Set(member) {
		throw Exception("Assigning values not supported by the " this.__Class " Class.",-1,member)
	}
	__Call(member) {
		if !ObjHasKey(UIA_Base,member)&&!ObjHasKey(this,member)
			throw Exception("Method Call not supported by the " this.__Class " Class.",-1,member)
	}
	__Delete() {
		this.__Flag? ObjRelease(this.__Value):
	}
	__Vt(n) {
		return NumGet(NumGet(this.__Value+0,"ptr")+n*A_PtrSize,"ptr")
	}
}

class UIA_Interface extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee671406(v=vs.85).aspx
	static __IID := "{30cbe57d-d9d0-452a-ab13-7ac5ac4825ee}"
		,  __properties := "ControlViewWalker,14,IUIAutomationTreeWalker`r`nContentViewWalker,15,IUIAutomationTreeWalker`r`nRawViewWalker,16,IUIAutomationTreeWalker`r`nRawViewCondition,17,IUIAutomationCondition`r`nControlViewCondition,18,IUIAutomationCondition`r`nContentViewCondition,19,IUIAutomationCondition`r`nProxyFactoryMapping,48,IUIAutomationProxyFactoryMapping`r`nReservedNotSupportedValue,54,IUnknown`r`nReservedMixedAttributeValue,55,IUnknown"

	CompareElements(e1,e2) {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr",e1.__Value, "ptr",e2.__Value, "int*",out))? out:
	}
	CompareRuntimeIds(r1,r2) {
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "ptr",ComObjValue(r1), "ptr",ComObjValue(r2), "int*",out))? out:
	}
	GetRootElement() {
		return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr*",out))? new UIA_Element(out):
	}
	ElementFromHandle(hwnd) {
		return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "ptr",hwnd, "ptr*",out))? new UIA_Element(out):
	}
	ElementFromPoint(x="", y="") {
		return UIA_Hr(DllCall(this.__Vt(7), "ptr",this.__Value, "int64",x==""||y==""?0*DllCall("GetCursorPos","Int64*",pt)+pt:x&0xFFFFFFFF|y<<32, "ptr*",out))? new UIA_Element(out):
	}
	GetFocusedElement() {
		return UIA_Hr(DllCall(this.__Vt(8), "ptr",this.__Value, "ptr*",out))? new UIA_Element(out):
	}
	;~ GetRootElementBuildCache 	9
	;~ ElementFromHandleBuildCache 	10
	;~ ElementFromPointBuildCache 	11
	;~ GetFocusedElementBuildCache 	12
	CreateTreeWalker(condition) {
		return UIA_Hr(DllCall(this.__Vt(13), "ptr",this.__Value, "ptr",Condition.__Value, "ptr*",out))? new UIA_TreeWalker(out):
	}
	;~ CreateCacheRequest 	20

	CreateTrueCondition() {
		return UIA_Hr(DllCall(this.__Vt(21), "ptr",this.__Value, "ptr*",out))? new UIA_Condition(out):
	}
	CreateFalseCondition() {
		return UIA_Hr(DllCall(this.__Vt(22), "ptr",this.__Value, "ptr*",out))? new UIA_Condition(out):
	}
	CreatePropertyCondition(propertyId, ByRef var, type="Variant") {
		if (type!="Variant")
			UIA_Variant(var,type,var)
		return UIA_Hr(DllCall(this.__Vt(23), "ptr",this.__Value, "int",propertyId, "ptr",&var, "ptr*",out))? new UIA_PropertyCondition(out):
	}
	CreatePropertyConditionEx(propertyId, ByRef var, type="Variant", flags=0x1) { ; NOT TESTED
	; PropertyConditionFlags_IgnoreCase = 0x1
		if (type!="Variant")
			UIA_Variant(var,type,var)
		return UIA_Hr(DllCall(this.__Vt(24), "ptr",this.__Value, "int",propertyId, "ptr",&var, "uint",flags, "ptr*",out))? new UIA_PropertyCondition(out):
	}
	CreateAndCondition(c1,c2) {
		return UIA_Hr(DllCall(this.__Vt(25), "ptr",this.__Value, "ptr",c1.__Value, "ptr",c2.__Value, "ptr*",out))? new UIA_AndCondition(out):
	}
	CreateAndConditionFromArray(array) { ; ComObj(0x2003)??
	;->in: AHK Array or Wrapped SafeArray
		if ComObjValue(array)&0x2000
			SafeArray:=array
		else {
			SafeArray:=ComObj(0x2003,DllCall("oleaut32\SafeArrayCreateVector", "uint",13, "uint",0, "uint",array.MaxIndex()),1)
			for i,c in array
				SafeArray[A_Index-1]:=c.__Value, ObjAddRef(c.__Value) ; AddRef - SafeArrayDestroy will release UIA_Conditions - they also release themselves
		}
		return UIA_Hr(DllCall(this.__Vt(26), "ptr",this.__Value, "ptr",ComObjValue(SafeArray), "ptr*",out))? new UIA_AndCondition(out):
	}
	CreateAndConditionFromNativeArray(p*) { ; Not Implemented
		return UIA_NotImplemented()
	/*	[in]           IUIAutomationCondition **conditions,
		[in]           int conditionCount,
		[out, retval]  IUIAutomationCondition **newCondition
	*/
		;~ return UIA_Hr(DllCall(this.__Vt(27), "ptr",this.__Value,
	}
	CreateOrCondition(c1,c2) {
		return UIA_Hr(DllCall(this.__Vt(28), "ptr",this.__Value, "ptr",c1.__Value, "ptr",c2.__Value, "ptr*",out))? new UIA_OrCondition(out):
	}
	CreateOrConditionFromArray(array) {
	;->in: AHK Array or Wrapped SafeArray
		if ComObjValue(array)&0x2000
			SafeArray:=array
		else {
			SafeArray:=ComObj(0x2003,DllCall("oleaut32\SafeArrayCreateVector", "uint",13, "uint",0, "uint",array.MaxIndex()),1)
			for i,c in array
				SafeArray[A_Index-1]:=c.__Value, ObjAddRef(c.__Value) ; AddRef - SafeArrayDestroy will release UIA_Conditions - they also release themselves
		}
		return UIA_Hr(DllCall(this.__Vt(29), "ptr",this.__Value, "ptr",ComObjValue(SafeArray), "ptr*",out))? new UIA_AndCondition(out):
	}
	CreateOrConditionFromNativeArray(p*) { ; Not Implemented
		return UIA_NotImplemented()
	/*	[in]           IUIAutomationCondition **conditions,
		[in]           int conditionCount,
		[out, retval]  IUIAutomationCondition **newCondition
	*/
		;~ return UIA_Hr(DllCall(this.__Vt(27), "ptr",this.__Value,
	}
	CreateNotCondition(c) {
		return UIA_Hr(DllCall(this.__Vt(31), "ptr",this.__Value, "ptr",c.__Value, "ptr*",out))? new UIA_NotCondition(out):
	}

	;~ AddAutomationEventHandler 	32
	;~ RemoveAutomationEventHandler 	33
	;~ AddPropertyChangedEventHandlerNativeArray 	34
	AddPropertyChangedEventHandler(element,scope=0x1,cacheRequest=0,handler="",propertyArray="") {
		SafeArray:=ComObjArray(0x3,propertyArray.MaxIndex())
		for i,propertyId in propertyArray
			SafeArray[i-1]:=propertyId
		return UIA_Hr(DllCall(this.__Vt(35), "ptr",this.__Value, "ptr",element.__Value, "int",scope, "ptr",cacheRequest,"ptr",handler.__Value,"ptr",ComObjValue(SafeArray)))
	}
	;~ RemovePropertyChangedEventHandler 	36
	;~ AddStructureChangedEventHandler 	37
	;~ RemoveStructureChangedEventHandler 	38
	AddFocusChangedEventHandler(cacheRequest, handler) {
		return UIA_Hr(DllCall(this.__Vt(39), "ptr",this.__Value, "ptr",cacheRequest, "ptr",handler.__Value))
	}
	;~ RemoveFocusChangedEventHandler 	40
	;~ RemoveAllEventHandlers 	41

	IntNativeArrayToSafeArray(ByRef nArr, n="") {
		return UIA_Hr(DllCall(this.__Vt(42), "ptr",this.__Value, "ptr",&nArr, "int",n?n:VarSetCapacity(nArr)/4, "ptr*",out))? ComObj(0x2003,out,1):
	}
/*	IntSafeArrayToNativeArray(sArr, Byref nArr="", Byref arrayCount="") { ; NOT WORKING
		VarSetCapacity(nArr,(sArr.MaxIndex()+1)*4)
		return UIA_Hr(DllCall(this.__Vt(43), "ptr",this.__Value, "ptr",ComObjValue(sArr), "ptr*",nArr, "int*",arrayCount))? arrayCount:
	}
*/
	RectToVariant(ByRef rect, ByRef out="") {	; in:{left,top,right,bottom} ; out:(left,top,width,height)
		; in:	RECT Struct
		; out:	AHK Wrapped SafeArray & ByRef Variant
		return UIA_Hr(DllCall(this.__Vt(44), "ptr",this.__Value, "ptr",&rect, "ptr",UIA_Variant(out)))? UIA_VariantData(out):
	}
/*	VariantToRect(ByRef var, ByRef out="") { ; NOT WORKING
		; in:	VT_VARIANT (SafeArray)
		; out:	AHK Wrapped RECT Struct & ByRef Struct
		return UIA_Hr(DllCall(this.__Vt(45), "ptr",this.__Value, "ptr",var, "ptr",&(out,VarSetCapacity(out,16))))? UIA_RectToObject(out):
	}
*/
	;~ SafeArrayToRectNativeArray 	46
	;~ CreateProxyFactoryEntry 	47
	GetPropertyProgrammaticName(Id) {
		return UIA_Hr(DllCall(this.__Vt(49), "ptr",this.__Value, "int",Id, "ptr*",out))? StrGet(out):
	}
	GetPatternProgrammaticName(Id) {
		return UIA_Hr(DllCall(this.__Vt(50), "ptr",this.__Value, "int",Id, "ptr*",out))? StrGet(out):
	}
	PollForPotentialSupportedPatterns(e, Byref Ids="", Byref Names="") {
		return UIA_Hr(DllCall(this.__Vt(51), "ptr",this.__Value, "ptr",e.__Value, "ptr*",Ids, "ptr*",Names))? UIA_SafeArraysToObject(Names:=ComObj(0x2008,Names,1),Ids:=ComObj(0x2003,Ids,1)):
	}
	PollForPotentialSupportedProperties(e, Byref Ids="", Byref Names="") {
		return UIA_Hr(DllCall(this.__Vt(52), "ptr",this.__Value, "ptr",e.__Value, "ptr*",Ids, "ptr*",Names))? UIA_SafeArraysToObject(Names:=ComObj(0x2008,Names,1),Ids:=ComObj(0x2003,Ids,1)):
	}
	CheckNotSupported(value) { ; Useless in this Framework???
	/*	Checks a provided VARIANT to see if it contains the Not Supported identifier.
		After retrieving a property for a UI Automation element, call this method to determine whether the element supports the
		retrieved property. CheckNotSupported is typically called after calling a property retrieving method such as GetCurrentPropertyValue.
	*/
		return UIA_Hr(DllCall(this.__Vt(53), "ptr",this.__Value, "ptr",value, "int*",out))? out:
	}
	ElementFromIAccessible(IAcc, childId=0) {
	/* The method returns E_INVALIDARG - "One or more arguments are not valid" - if the underlying implementation of the
	Microsoft UI Automation element is not a native Microsoft Active Accessibility server; that is, if a client attempts to retrieve
	the IAccessible interface for an element originally supported by a proxy object from Oleacc.dll, or by the UIA-to-MSAA Bridge.
	*/
		return UIA_Hr(DllCall(this.__Vt(56), "ptr",this.__Value, "ptr",ComObjValue(IAcc), "int",childId, "ptr*",out))? new UIA_Element(out):
	}
	;~ ElementFromIAccessibleBuildCache 	57
}

class UIA_Element extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee671425(v=vs.85).aspx
	static __IID := "{d22108aa-8ac5-49a5-837b-37bbb3d7591e}"
		,  __properties := "CurrentProcessId,20,int`r`nCurrentControlType,21,CONTROLTYPEID`r`nCurrentLocalizedControlType,22,BSTR`r`nCurrentName,23,BSTR`r`nCurrentAcceleratorKey,24,BSTR`r`nCurrentAccessKey,25,BSTR`r`nCurrentHasKeyboardFocus,26,BOOL`r`nCurrentIsKeyboardFocusable,27,BOOL`r`nCurrentIsEnabled,28,BOOL`r`nCurrentAutomationId,29,BSTR`r`nCurrentClassName,30,BSTR`r`nCurrentHelpText,31,BSTR`r`nCurrentCulture,32,int`r`nCurrentIsControlElement,33,BOOL`r`nCurrentIsContentElement,34,BOOL`r`nCurrentIsPassword,35,BOOL`r`nCurrentNativeWindowHandle,36,UIA_HWND`r`nCurrentItemType,37,BSTR`r`nCurrentIsOffscreen,38,BOOL`r`nCurrentOrientation,39,OrientationType`r`nCurrentFrameworkId,40,BSTR`r`nCurrentIsRequiredForForm,41,BOOL`r`nCurrentItemStatus,42,BSTR`r`nCurrentBoundingRectangle,43,RECT`r`nCurrentLabeledBy,44,IUIAutomationElement`r`nCurrentAriaRole,45,BSTR`r`nCurrentAriaProperties,46,BSTR`r`nCurrentIsDataValidForForm,47,BOOL`r`nCurrentControllerFor,48,IUIAutomationElementArray`r`nCurrentDescribedBy,49,IUIAutomationElementArray`r`nCurrentFlowsTo,50,IUIAutomationElementArray`r`nCurrentProviderDescription,51,BSTR`r`nCachedProcessId,52,int`r`nCachedControlType,53,CONTROLTYPEID`r`nCachedLocalizedControlType,54,BSTR`r`nCachedName,55,BSTR`r`nCachedAcceleratorKey,56,BSTR`r`nCachedAccessKey,57,BSTR`r`nCachedHasKeyboardFocus,58,BOOL`r`nCachedIsKeyboardFocusable,59,BOOL`r`nCachedIsEnabled,60,BOOL`r`nCachedAutomationId,61,BSTR`r`nCachedClassName,62,BSTR`r`nCachedHelpText,63,BSTR`r`nCachedCulture,64,int`r`nCachedIsControlElement,65,BOOL`r`nCachedIsContentElement,66,BOOL`r`nCachedIsPassword,67,BOOL`r`nCachedNativeWindowHandle,68,UIA_HWND`r`nCachedItemType,69,BSTR`r`nCachedIsOffscreen,70,BOOL`r`nCachedOrientation,71,OrientationType`r`nCachedFrameworkId,72,BSTR`r`nCachedIsRequiredForForm,73,BOOL`r`nCachedItemStatus,74,BSTR`r`nCachedBoundingRectangle,75,RECT`r`nCachedLabeledBy,76,IUIAutomationElement`r`nCachedAriaRole,77,BSTR`r`nCachedAriaProperties,78,BSTR`r`nCachedIsDataValidForForm,79,BOOL`r`nCachedControllerFor,80,IUIAutomationElementArray`r`nCachedDescribedBy,81,IUIAutomationElementArray`r`nCachedFlowsTo,82,IUIAutomationElementArray`r`nCachedProviderDescription,83,BSTR"

	SetFocus() {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value))
	}
	GetRuntimeId(ByRef stringId="") {
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "ptr*",sa))? ComObj(0x2003,sa,1):
	}
	FindFirst(c="", scope=0x2) {
		static tc	; TrueCondition
		if !tc
			tc:=this.__uia.CreateTrueCondition()
		return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "uint",scope, "ptr",(c=""?tc:c).__Value, "ptr*",out))? new UIA_Element(out):
	}
	FindAll(c="", scope=0x2) {
		static tc	; TrueCondition
		if !tc
			tc:=this.__uia.CreateTrueCondition()
		return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "uint",scope, "ptr",(c=""?tc:c).__Value, "ptr*",out))? UIA_ElementArray(out):
	}
	;~ Find (First/All, Element/Children/Descendants/Parent/Ancestors/Subtree, Conditions)
	;~ FindFirstBuildCache 	7	IUIAutomationElement
	;~ FindAllBuildCache 	8	IUIAutomationElementArray
	;~ BuildUpdatedCache 	9	IUIAutomationElement
	GetCurrentPropertyValue(propertyId, ByRef out="") {
		return UIA_Hr(DllCall(this.__Vt(10), "ptr",this.__Value, "uint",propertyId, "ptr",UIA_Variant(out)))? UIA_VariantData(out):
	}
	GetCurrentPropertyValueEx(propertyId, ignoreDefaultValue=1, ByRef out="") {
	; Passing FALSE in the ignoreDefaultValue parameter is equivalent to calling GetCurrentPropertyValue
		return UIA_Hr(DllCall(this.__Vt(11), "ptr",this.__Value, "uint",propertyId, "uint",ignoreDefaultValue, "ptr",UIA_Variant(out)))? UIA_VariantData(out):
	}
	;~ GetCachedPropertyValue 	12	VARIANT
	GetCachedPropertyValue(propertyId) {
	static _,_v:=variant(_)
				UIA_Hr(DllCall(this.vt(12),"ptr",this.__,"int",propertyId,"ptr",_v),"GetCachedPropertyValue")
	return GetVariantValue(_v)
	}
	;~ GetCachedPropertyValueEx 	13	VARIANT
	GetCurrentPatternAs(pattern="") {
		if IsObject(UIA_%pattern%Pattern)&&(iid:=UIA_%pattern%Pattern.__iid)&&(pId:=UIA_%pattern%Pattern.__PatternID)
			return UIA_Hr(DllCall(this.__Vt(14), "ptr",this.__Value, "int",pId, "ptr",UIA_GUID(riid,iid), "ptr*",out))? new UIA_%pattern%Pattern(out):
		else throw Exception("Pattern not implemented.",-1, "UIA_" pattern "Pattern")
	}
	;~ GetCachedPatternAs 	15	void **ppv
	;~ GetCurrentPattern 	16	Iunknown **patternObject
	;~ GetCachedPattern 	17	Iunknown **patternObject
	;~ GetCachedParent 	18	IUIAutomationElement
	GetCachedChildren() { ; Haven't successfully tested
		return UIA_Hr(DllCall(this.__Vt(19), "ptr",this.__Value, "ptr*",out))&&out? UIA_ElementArray(out):
	}
	;~ GetClickablePoint 	84	POINT, BOOL
}

class UIA_ElementArray extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee671426(v=vs.85).aspx
	static __IID := "{14314595-b4bc-4055-95f2-58f2e42c9855}"
		,  __properties := "Length,3,int"

	GetElement(i) {
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "int",i, "ptr*",out))? new UIA_Element(out):
	}
}

class UIA_TreeWalker extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee671470(v=vs.85).aspx
	static __IID := "{4042c624-389c-4afc-a630-9df854a541fc}"
		,  __properties := "Condition,15,IUIAutomationCondition"

	GetParentElement(e) {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr",e.__Value, "ptr*",out))? new UIA_Element(out):
	}
	GetFirstChildElement(e) {
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "ptr",e.__Value, "ptr*",out))&&out? new UIA_Element(out):
	}
	GetLastChildElement(e) {
		return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr",e.__Value, "ptr*",out))&&out? new UIA_Element(out):
	}
	GetNextSiblingElement(e) {
		return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "ptr",e.__Value, "ptr*",out))&&out? new UIA_Element(out):
	}
	GetPreviousSiblingElement(e) {
		return UIA_Hr(DllCall(this.__Vt(7), "ptr",this.__Value, "ptr",e.__Value, "ptr*",out))&&out? new UIA_Element(out):
	}
	NormalizeElement(e) {
		return UIA_Hr(DllCall(this.__Vt(8), "ptr",this.__Value, "ptr",e.__Value, "ptr*",out))&&out? new UIA_Element(out):
	}
/*	GetParentElementBuildCache(e, cacheRequest) {
		return UIA_Hr(DllCall(this.__Vt(9), "ptr",this.__Value, "ptr",e.__Value, "ptr",cacheRequest.__Value.__Value, "ptr*",out))? new UIA_Element(out):
	}
	GetFirstChildElementBuildCache(e, cacheRequest) {
		return UIA_Hr(DllCall(this.__Vt(10), "ptr",this.__Value, "ptr",e.__Value, "ptr",cacheRequest.__Value, "ptr*",out))? new UIA_Element(out):
	}
	GetLastChildElementBuildCache(e, cacheRequest) {
		return UIA_Hr(DllCall(this.__Vt(11), "ptr",this.__Value, "ptr",e.__Value, "ptr",cacheRequest.__Value, "ptr*",out))? new UIA_Element(out):
	}
	GetNextSiblingElementBuildCache(e, cacheRequest) {
		return UIA_Hr(DllCall(this.__Vt(12), "ptr",this.__Value, "ptr",e.__Value, "ptr",cacheRequest.__Value, "ptr*",out))? new UIA_Element(out):
	}
	GetPreviousSiblingElementBuildCache(e, cacheRequest) {
		return UIA_Hr(DllCall(this.__Vt(13), "ptr",this.__Value, "ptr",e.__Value, "ptr",cacheRequest.__Value, "ptr*",out))? new UIA_Element(out):
	}
	NormalizeElementBuildCache(e, cacheRequest) {
		return UIA_Hr(DllCall(this.__Vt(14), "ptr",this.__Value, "ptr",e.__Value, "ptr",cacheRequest.__Value, "ptr*",out))? new UIA_Element(out):
	}
*/
}

class UIA_Condition extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee671420(v=vs.85).aspx
	static __IID := "{352ffba8-0973-437c-a61f-f64cafd81df9}"
}

class UIA_PropertyCondition extends UIA_Condition {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696121(v=vs.85).aspx
	static __IID := "{99ebf2cb-5578-4267-9ad4-afd6ea77e94b}"
		,  __properties := "PropertyId,3,PROPERTYID`r`nPropertyValue,4,VARIANT`r`nPropertyConditionFlags,5,PropertyConditionFlags"
}
; should returned children have a condition type (property/and/or/bool/not), or be a generic uia_condition object?
class UIA_AndCondition extends UIA_Condition {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee671407(v=vs.85).aspx
	static __IID := "{a7d0af36-b912-45fe-9855-091ddc174aec}"
		,  __properties := "ChildCount,3,int"

	;~ GetChildrenAsNativeArray	4	IUIAutomationCondition ***childArray
	GetChildren() {
		return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr*",out))&&out? ComObj(0x2003,out,1):
	}
}
class UIA_OrCondition extends UIA_Condition {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696108(v=vs.85).aspx
	static __IID := "{8753f032-3db1-47b5-a1fc-6e34a266c712}"
		,  __properties := "ChildCount,3,int"

	;~ GetChildrenAsNativeArray	4	IUIAutomationCondition ***childArray
	;~ GetChildren	5	SAFEARRAY
}
class UIA_BoolCondition extends UIA_Condition {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee671411(v=vs.85).aspx
	static __IID := "{8753f032-3db1-47b5-a1fc-6e34a266c712}"
		,  __properties := "BooleanValue,3,boolVal"
}
class UIA_NotCondition extends UIA_Condition {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696106(v=vs.85).aspx
	static __IID := "{f528b657-847b-498c-8896-d52b565407a1}"

	;~ GetChild	3	IUIAutomationCondition
}

class UIA_IUnknown extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ms680509(v=vs.85).aspx
	static __IID := "{00000000-0000-0000-C000-000000000046}"
}

class UIA_CacheRequest  extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee671413(v=vs.85).aspx
	static __IID := "{b32a92b5-bc25-4078-9c08-d7ee95c48e03}"
}

class _UIA_EventHandler {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696044(v=vs.85).aspx
	static __IID := "{146c3c17-f12e-4e22-8c27-f894b9b79c69}"

/*	HandleAutomationEvent	3
		[in]  IUIAutomationElement *sender,
		[in]  EVENTID eventId
*/
}
class _UIA_FocusChangedEventHandler {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696051(v=vs.85).aspx
	static __IID := "{c270f6b5-5c69-4290-9745-7a7f97169468}"

/*	HandleFocusChangedEvent	3
		[in]  IUIAutomationElement *sender
*/
}
class _UIA_PropertyChangedEventHandler {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696119(v=vs.85).aspx
	static __IID := "{40cd37d4-c756-4b0c-8c6f-bddfeeb13b50}"

/*	HandlePropertyChangedEvent	3
		[in]  IUIAutomationElement *sender,
		[in]  PROPERTYID propertyId,
		[in]  VARIANT newValue
*/
}
class _UIA_StructureChangedEventHandler {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696197(v=vs.85).aspx
	static __IID := "{e81d1b4e-11c5-42f8-9754-e7036c79f054}"

/*	HandleStructureChangedEvent	3
		[in]  IUIAutomationElement *sender,
		[in]  StructureChangeType changeType,
		[in]  SAFEARRAY *runtimeId[int]
*/
}
class _UIA_TextEditTextChangedEventHandler { ; Windows 8.1 Preview [desktop apps only]
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/dn302202(v=vs.85).aspx
	static __IID := "{92FAA680-E704-4156-931A-E32D5BB38F3F}"

	;~ HandleTextEditTextChangedEvent	3
}


;~ 		UIA_Patterns - http://msdn.microsoft.com/en-us/library/windows/desktop/ee684023
class UIA_DockPattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee671421
	static	__IID := "{fde5ef97-1464-48f6-90bf-43d0948e86ec}"
		,	__PatternID := 10011
		,	__Properties := "CurrentDockPosition,4,int`r`nCachedDockPosition,5,int"

	SetDockPosition(Pos) {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "uint",pos))
	}
/*	DockPosition_Top	= 0,
	DockPosition_Left	= 1,
	DockPosition_Bottom	= 2,
	DockPosition_Right	= 3,
	DockPosition_Fill	= 4,
	DockPosition_None	= 5
*/
}
class UIA_ExpandCollapsePattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696046
	static	__IID := "{619be086-1f4e-4ee4-bafa-210128738730}"
		,	__PatternID := 10005
		,	__Properties := "CachedExpandCollapseState,6,int`r`nCurrentExpandCollapseState,5,int"

	Expand() {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value))
	}
	Collapse() {
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value))
	}
/*	ExpandCollapseState_Collapsed	= 0,
	ExpandCollapseState_Expanded	= 1,
	ExpandCollapseState_PartiallyExpanded	= 2,
	ExpandCollapseState_LeafNode	= 3
*/
}
class UIA_GridItemPattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696053
	static	__IID := "{78f8ef57-66c3-4e09-bd7c-e79b2004894d}"
		,	__PatternID := 10007
		,	__Properties := "CurrentContainingGrid,3,IUIAutomationElement`r`nCurrentRow,4,int`r`nCurrentColumn,5,int`r`nCurrentRowSpan,6,int`r`nCurrentColumnSpan,7,int`r`nCachedContainingGrid,8,IUIAutomationElement`r`nCachedRow,9,int`r`nCachedColumn,10,int`r`nCachedRowSpan,11,int`r`nCachedColumnSpan,12,int"
}
class UIA_GridPattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696064
	static	__IID := "{414c3cdc-856b-4f5b-8538-3131c6302550}"
		,	__PatternID := 10006
		,	__Properties := "CurrentRowCount,4,int`r`nCurrentColumnCount,5,int`r`nCachedRowCount,6,int`r`nCachedColumnCount,7,int"

	GetItem(row,column) { ; Hr!=0 if no result, or blank output?
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "uint",row, "uint",column, "ptr*",out))? new UIA_Element(out):
	}
}
class UIA_InvokePattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696070
	static	__IID := "{fb377fbe-8ea6-46d5-9c73-6499642d3059}"
		,	__PatternID := 10000

	Invoke() {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value))
	}
}
class UIA_ItemContainerPattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696072
	static	__IID := "{c690fdb2-27a8-423c-812d-429773c9084e}"
		,	__PatternID := 10019

	FindItemByProperty(startAfter, propertyId, ByRef value, type=8) {	; Hr!=0 if no result, or blank output?
		if (type!="Variant")
			UIA_Variant(value,type,value)
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr",startAfter.__Value, "int",propertyId, "ptr",&value, "ptr*",out))? new UIA_Element(out):
	}
}
class UIA_LegacyIAccessiblePattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696074
	static	__IID := "{828055ad-355b-4435-86d5-3b51c14a9b1b}"
		,	__PatternID := 10018
		,	__Properties := "CurrentChildId,6,int`r`nCurrentName,7,BSTR`r`nCurrentValue,8,BSTR`r`nCurrentDescription,9,BSTR`r`nCurrentRole,10,DWORD`r`nCurrentState,11,DWORD`r`nCurrentHelp,12,BSTR`r`nCurrentKeyboardShortcut,13,BSTR`r`nCurrentDefaultAction,15,BSTR`r`nCachedChildId,16,int`r`nCachedName,17,BSTR`r`nCachedValue,18,BSTR`r`nCachedDescription,19,BSTR`r`nCachedRole,20,DWORD`r`nCachedState,21,DWORD`r`nCachedHelp,22,BSTR`r`nCachedKeyboardShortcut,23,BSTR`r`nCachedDefaultAction,25,BSTR"

	Select(flags=3) {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "int",flags))
	}
	DoDefaultAction() {
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value))
	}
	SetValue(value) {
		return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr",&value))
	}
	GetCurrentSelection() { ; Not correct
		;~ if (hr:=DllCall(this.__Vt(14), "ptr",this.__Value, "ptr*",array))=0
			;~ return new UIA_ElementArray(array)
		;~ else
			;~ MsgBox,, Error, %hr%
	}
	;~ GetCachedSelection	24	IUIAutomationElementArray
	GetIAccessible() {
	/*	This method returns NULL if the underlying implementation of the UI Automation element is not a native
	Microsoft Active Accessibility server; that is, if a client attempts to retrieve the IAccessible interface
	for an element originally supported by a proxy object from OLEACC.dll, or by the UIA-to-MSAA Bridge.
	*/
		return UIA_Hr(DllCall(this.__Vt(26), "ptr",this.__Value, "ptr*",pacc))&&pacc? ComObj(9,pacc,1):
	}
}
class UIA_MultipleViewPattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696099
	static	__IID := "{8d253c91-1dc5-4bb5-b18f-ade16fa495e8}"
		,	__PatternID := 10008
		,	__Properties := "CurrentCurrentView,5,int`r`nCachedCurrentView,7,int"

	GetViewName(view) { ; need to release BSTR?
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "int",view, "ptr*",name))? StrGet(name):
	}
	SetCurrentView(view) {
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "int",view))
	}
	GetCurrentSupportedViews() {
		return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "ptr*",out))? ComObj(0x2003,out,1):
	}
	GetCachedSupportedViews() {
		return UIA_Hr(DllCall(this.__Vt(8), "ptr",this.__Value, "ptr*",out))? ComObj(0x2003,out,1):
	}
}
class UIA_RangeValuePattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696147
	static	__IID := "{59213f4f-7346-49e5-b120-80555987a148}"
		,	__PatternID := 10003
		,	__Properties := "CurrentValue,4,double`r`nCurrentIsReadOnly,5,BOOL`r`nCurrentMaximum,6,double`r`nCurrentMinimum,7,double`r`nCurrentLargeChange,8,double`r`nCurrentSmallChange,9,double`r`nCachedValue,10,double`r`nCachedIsReadOnly,11,BOOL`r`nCachedMaximum,12,double`r`nCachedMinimum,13,double`r`nCachedLargeChange,14,double`r`nCachedSmallChange,15,double"

	SetValue(val) {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "double",val))
	}
}
class UIA_ScrollItemPattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696165
	static	__IID := "{b488300f-d015-4f19-9c29-bb595e3645ef}"
		,	__PatternID := 10017

	ScrollIntoView() {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value))
	}
}
class UIA_ScrollPattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696167
	static	__IID := "{88f4d42a-e881-459d-a77c-73bbbb7e02dc}"
		,	__PatternID := 10004
		,	__Properties := "CurrentHorizontalScrollPercent,5,double`r`nCurrentVerticalScrollPercent,6,double`r`nCurrentHorizontalViewSize,7,double`r`CurrentHorizontallyScrollable,9,BOOL`r`nCurrentVerticallyScrollable,10,BOOL`r`nCachedHorizontalScrollPercent,11,double`r`nCachedVerticalScrollPercent,12,double`r`nCachedHorizontalViewSize,13,double`r`nCachedVerticalViewSize,14,double`r`nCachedHorizontallyScrollable,15,BOOL`r`nCachedVerticallyScrollable,16,BOOL"

	Scroll(horizontal, vertical) {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "uint",horizontal, "uint",vertical))
	}
	SetScrollPercent(horizontal, vertical) {
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "double",horizontal, "double",vertical))
	}
/*	UIA_ScrollPatternNoScroll	=	-1
	ScrollAmount_LargeDecrement	= 0,
	ScrollAmount_SmallDecrement	= 1,
	ScrollAmount_NoAmount	= 2,
	ScrollAmount_LargeIncrement	= 3,
	ScrollAmount_SmallIncrement	= 4
*/
}
;~ class UIA_SelectionItemPattern extends UIA_Base {10010
;~ class UIA_SelectionPattern extends UIA_Base {10001
;~ class UIA_SpreadsheetItemPattern extends UIA_Base {10027
;~ class UIA_SpreadsheetPattern extends UIA_Base {10026
;~ class UIA_StylesPattern extends UIA_Base {10025
;~ class UIA_SynchronizedInputPattern extends UIA_Base {10021
;~ class UIA_TableItemPattern extends UIA_Base {10013
;~ class UIA_TablePattern extends UIA_Base {10012
;~ class UIA_TextChildPattern extends UIA_Base {10029
;~ class UIA_TextEditPattern extends UIA_Base {10032
;~ class UIA_TextPattern extends UIA_Base {10014
;~ class UIA_TextPattern2 extends UIA_Base {10024
;~ class UIA_TogglePattern extends UIA_Base {10015
;~ class UIA_TransformPattern extends UIA_Base {10016
;~ class UIA_TransformPattern2 extends UIA_Base {10028
;~ class UIA_ValuePattern extends UIA_Base {10002
;~ class UIA_VirtualizedItemPattern extends UIA_Base {10020
;~ class UIA_WindowPattern extends UIA_Base {10009
;~ class UIA_AnnotationPattern extends UIA_Base {10023		; Windows 8 [desktop apps only]
;~ class UIA_DragPattern extends UIA_Base {10030			; Windows 8 [desktop apps only]
;~ class UIA_DropTargetPattern extends UIA_Base {10031		; Windows 8 [desktop apps only]
/* class UIA_ObjectModelPattern extends UIA_Base {			; Windows 8 [desktop apps only]
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/hh437262(v=vs.85).aspx
	static	__IID := "{71c284b3-c14d-4d14-981e-19751b0d756d}"
		,	__PatternID := 10022

	GetUnderlyingObjectModel() {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value))
	}
}
*/

;~ class UIA_PatternHandler extends UIA_Base {
;~ class UIA_PatternInstance extends UIA_Base {
;~ class UIA_TextRange extends UIA_Base {
;~ class UIA_TextRange2 extends UIA_Base {
;~ class UIA_TextRangeArray extends UIA_Base {




;{  ;~ UIA Functions
	UIA_Interface() {
		try {
			if uia:=ComObjCreate("{ff48dba4-60ef-4201-aa87-54103eef594e}","{30cbe57d-d9d0-452a-ab13-7ac5ac4825ee}")
				return uia:=new UIA_Interface(uia), uia.base.base.__UIA:=uia
			throw "UIAutomation Interface failed to initialize."
		} catch e
			MsgBox, 262160, UIA Startup Error, % IsObject(e)?"IUIAutomation Interface is not registered.":e.Message
	}
	UIA_Hr(hr) {
		;~ http://blogs.msdn.com/b/eldar/archive/2007/04/03/a-lot-of-hresult-codes.aspx
		static err:={0x8000FFFF:"Catastrophic failure.",0x80004001:"Not implemented.",0x8007000E:"Out of memory.",0x80070057:"One or more arguments are not valid.",0x80004002:"Interface not supported.",0x80004003:"Pointer not valid.",0x80070006:"Handle not valid.",0x80004004:"Operation aborted.",0x80004005:"Unspecified error.",0x80070005:"General access denied.",0x800401E5:"The object identified by this moniker could not be found.",0x80040201:"UIA_E_ELEMENTNOTAVAILABLE",0x80040200:"UIA_E_ELEMENTNOTENABLED",0x80131509:"UIA_E_INVALIDOPERATION",0x80040202:"UIA_E_NOCLICKABLEPOINT",0x80040204:"UIA_E_NOTSUPPORTED",0x80040203:"UIA_E_PROXYASSEMBLYNOTLOADED"} ; //not completed
		if hr&&(hr&=0xFFFFFFFF) {
			RegExMatch(Exception("",-2).what,"(\w+).(\w+)",i)
			throw Exception(UIA_Hex(hr) " - " err[hr], -2, i2 "  (" i1 ")")
		}
		return !hr
	}
	UIA_NotImplemented() {
		RegExMatch(Exception("",-2).What,"(\D+)\.(\D+)",m)
		MsgBox, 262192, UIA Message, Class:`t%m1%`nMember:`t%m2%`n`nMethod has not been implemented yet.
	}
	UIA_ElementArray(p, uia="") { ; should AHK Object be 0 or 1 based?
		a:=new UIA_ElementArray(p),out:=[]
		Loop % a.Length
			out[A_Index]:=a.GetElement(A_Index-1)
		return out, out.base:={UIA_ElementArray:a}
	}
	UIA_RectToObject(ByRef r) { ; rect.__Value work with DllCalls?
		static b:={__Class:"object",__Type:"RECT",Struct:Func("UIA_RectStructure")}
		return {l:NumGet(r,0,"Int"),t:NumGet(r,4,"Int"),r:NumGet(r,8,"Int"),b:NumGet(r,12,"Int"),base:b}
	}
	UIA_RectStructure(this, ByRef r) {
		static sides:="ltrb"
		VarSetCapacity(r,16)
		Loop Parse, sides
			NumPut(this[A_LoopField],r,(A_Index-1)*4,"Int")
	}
	UIA_SafeArraysToObject(keys,values) {
	;~	1 dim safearrays w/ same # of elements
		out:={}
		for key in keys
			out[key]:=values[A_Index-1]
		return out
	}
	UIA_Hex(p) {
		setting:=A_FormatInteger
		SetFormat,IntegerFast,H
		out:=p+0 ""
		SetFormat,IntegerFast,%setting%
		return out
	}
	UIA_GUID(ByRef GUID, sGUID) { ;~ Converts a string to a binary GUID and returns its address.
		VarSetCapacity(GUID,16,0)
		return DllCall("ole32\CLSIDFromString", "wstr",sGUID, "ptr",&GUID)>=0?&GUID:""
	}
	UIA_Variant(ByRef var,type=0,val=0) {
		; Does a variant need to be cleared? If it uses SysAllocString?
		return (VarSetCapacity(var,8+2*A_PtrSize)+NumPut(type,var,0,"short")+NumPut(type=8? DllCall("oleaut32\SysAllocString", "ptr",&val):val,var,8,"ptr"))*0+&var
	}
	UIA_IsVariant(ByRef vt, ByRef type="") {
		size:=VarSetCapacity(vt),type:=NumGet(vt,"UShort")
		return size>=16&&size<=24&&type>=0&&(type<=23||type|0x2000)
	}
	UIA_Type(ByRef item, ByRef info) {
	}
	UIA_VariantData(ByRef p, flag=1) {
		; based on Sean's COM_Enumerate function
		; need to clear varaint? what if you still need it (flag param)?
		return !UIA_IsVariant(p,vt)?"Invalid Variant"
				:vt=3?NumGet(p,8,"int")
				:vt=8?StrGet(NumGet(p,8))
				:vt=9||vt=13||vt&0x2000?ComObj(vt,NumGet(p,8),flag)
				:vt<0x1000&&UIA_VariantChangeType(&p,&p)=0?StrGet(NumGet(p,8)) UIA_VariantClear(&p)
				:NumGet(p,8)
	/*
		VT_EMPTY     =      0  		; No value
		VT_NULL      =      1 		; SQL-style Null
		VT_I2        =      2 		; 16-bit signed int
		VT_I4        =      3 		; 32-bit signed int
		VT_R4        =      4 		; 32-bit floating-point number
		VT_R8        =      5 		; 64-bit floating-point number
		VT_CY        =      6 		; Currency
		VT_DATE      =      7  		; Date
		VT_BSTR      =      8 		; COM string (Unicode string with length prefix)
		VT_DISPATCH  =      9 		; COM object
		VT_ERROR     =    0xA  10	; Error code (32-bit integer)
		VT_BOOL      =    0xB  11	; Boolean True (-1) or False (0)
		VT_VARIANT   =    0xC  12	; VARIANT (must be combined with VT_ARRAY or VT_BYREF)
		VT_UNKNOWN   =    0xD  13	; IUnknown interface pointer
		VT_DECIMAL   =    0xE  14	; (not supported)
		VT_I1        =   0x10  16	; 8-bit signed int
		VT_UI1       =   0x11  17	; 8-bit unsigned int
		VT_UI2       =   0x12  18	; 16-bit unsigned int
		VT_UI4       =   0x13  19	; 32-bit unsigned int
		VT_I8        =   0x14  20	; 64-bit signed int
		VT_UI8       =   0x15  21	; 64-bit unsigned int
		VT_INT       =   0x16  22	; Signed machine int
		VT_UINT      =   0x17  23	; Unsigned machine int
		VT_RECORD    =   0x24  36	; User-defined type
		VT_ARRAY     = 0x2000  		; SAFEARRAY
		VT_BYREF     = 0x4000  		; Pointer to another type of value
					 = 0x1000  4096

		COM_VariantChangeType(pvarDst, pvarSrc, vt=8) {
			return DllCall("oleaut32\VariantChangeTypeEx", "ptr",pvarDst, "ptr",pvarSrc, "Uint",1024, "Ushort",0, "Ushort",vt)
		}
		COM_VariantClear(pvar) {
			DllCall("oleaut32\VariantClear", "ptr",pvar)
		}
		COM_SysAllocString(str) {
			Return	DllCall("oleaut32\SysAllocString", "Uint", &str)
		}
		COM_SysFreeString(pstr) {
				DllCall("oleaut32\SysFreeString", "Uint", pstr)
		}
		COM_SysString(ByRef wString, sString) {
			VarSetCapacity(wString,4+nLen:=2*StrLen(sString))
			Return	DllCall("kernel32\lstrcpyW","Uint",NumPut(nLen,wString),"Uint",&sString)
		}
	*/
	}
	UIA_VariantChangeType(pvarDst, pvarSrc, vt=8) { ; written by Sean
		return DllCall("oleaut32\VariantChangeTypeEx", "ptr",pvarDst, "ptr",pvarSrc, "Uint",1024, "Ushort",0, "Ushort",vt)
	}
	UIA_VariantClear(pvar) { ; Written by Sean
		DllCall("oleaut32\VariantClear", "ptr",pvar)
	}
;}
MsgBox(msg) {
	MsgBox %msg%
}

/*
enum TreeScope
    {	TreeScope_Element	= 0x1,
	TreeScope_Children	= 0x2,
	TreeScope_Descendants	= 0x4,
	TreeScope_Parent	= 0x8,
	TreeScope_Ancestors	= 0x10,
	TreeScope_Subtree	= ( ( TreeScope_Element | TreeScope_Children )  | TreeScope_Descendants )
    } ;

DllCall("oleaut32\SafeArrayGetVartype", "ptr*",ComObjValue(SafeArray), "uint*",pvt)
HRESULT SafeArrayGetVartype(
  _In_   SAFEARRAY *psa,
  _Out_  VARTYPE *pvt
);

DllCall("oleaut32\SafeArrayDestroy", "ptr",ComObjValue(SafeArray))
HRESULT SafeArrayDestroy(
  _In_  SAFEARRAY *psa
);


