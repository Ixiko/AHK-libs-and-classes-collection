;;;;;;;;;;;;;;;;;;
;;Base Interface;;
;;;;;;;;;;;;;;;;;;

class IBase
{
	__new(p=0){
		if (this.__:=p)
			this._v:=NumGet(p+0)
		else return
	}
	__delete(){
		ObjRelease(this.__)
	}
	vt(n){
		return NumGet(this._v+n*A_PtrSize)
	}
}

;;;;;;;;;;;;;;;;;
;;IUIAutomation;;
;;;;;;;;;;;;;;;;;

class IUIAutomation extends IBase
{
	__new(){
		this.__:=ComObjCreate("{ff48dba4-60ef-4201-aa87-54103eef594e}","{30cbe57d-d9d0-452a-ab13-7ac5ac4825ee}"),this._v:=NumGet(this.__+0)
	}
	
	; Compares two UI Automation elements to determine whether they represent the same underlying UI element.
	CompareElements(el1,el2){
		UIA_Error(DllCall(this.vt(3),"ptr",this.__,"ptr",el1.__,"ptr",el2.__,"int*",areSame),"CompareElements")
		return areSame
	}
	
	; Compares two integer arrays containing run-time identifiers (IDs) to determine whether their content is the same and they belong to the same UI element.
	CompareRuntimeIds(runtimeId1,runtimeId2){
		UIA_Error(DllCall(this.vt(4),"ptr",this.__,"ptr",runtimeId1,"ptr",runtimeId2,"int*",areSame),"CompareRuntimeIds")
		return areSame
	}
	
	; Retrieves the UI Automation element that represents the desktop.
	GetRootElement(){
		UIA_Error(DllCall(this.vt(5),"ptr",this.__,"ptr*",root),"GetRootElement")
		return new IUIAutomationElement(root)
	}
	
	; Retrieves a UI Automation element for the specified window.
	ElementFromHandle(hwnd){
		UIA_Error(DllCall(this.vt(6),"ptr",this.__,"ptr",hwnd,"ptr*",element),"ElementFromHandle")
		return new IUIAutomationElement(element)
	}
	
	; Retrieves the UI Automation element at the specified point on the desktop.
	ElementFromPoint(pt){
		UIA_Error(DllCall(this.vt(7),"ptr",this.__,"int64",pt,"ptr*",element),"ElementFromPoint") ; pt := x|y<<32
		return new IUIAutomationElement(element)
	}
	
	; Retrieves the UI Automation element that has the input focus.
	GetFocusedElement(){
		UIA_Error(DllCall(this.vt(8),"ptr",this.__,"ptr*",element),"GetFocusedElement")
		return new IUIAutomationElement(element)
	}
	
	; Retrieves the UI Automation element that has the input focus, prefetches the requested properties and control patterns, and stores the prefetched items in the cache.
	GetRootElementBuildCache(cacheRequest){
		UIA_Error(DllCall(this.vt(9),"ptr",this.__,"ptr",cacheRequest.__,"ptr*",root),"GetRootElementBuildCache")
		return new IUIAutomationElement(root)
	}
	
	; Retrieves a UI Automation element for the specified window, prefetches the requested properties and control patterns, and stores the prefetched items in the cache.
	ElementFromHandleBuildCache(hwnd,cacheRequest){
		UIA_Error(DllCall(this.vt(10),"ptr",this.__,"ptr",hwnd,"ptr",cacheRequest.__,"ptr*",element),"ElementFromHandleBuildCache")
		return new IUIAutomationElement(element)
	}
	
	; Retrieves the UI Automation element at the specified point on the desktop, prefetches the requested properties and control patterns, and stores the prefetched items in the cache.
	ElementFromPointBuildCache(pt,cacheRequest){
		UIA_Error(DllCall(this.vt(11),"ptr",this.__,"int64",pt,"ptr",cacheRequest.__,"ptr*",element),"ElementFromPointBuildCache")
		return new IUIAutomationElement(element)
	}
	
	; Retrieves the UI Automation element that has the input focus, prefetches the requested properties and control patterns, and stores the prefetched items in the cache.
	GetFocusedElementBuildCache(cacheRequest){
		UIA_Error(DllCall(this.vt(12),"ptr",this.__,"ptr",cacheRequest.__,"ptr*",element),"GetFocusedElementBuildCache")
		return new IUIAutomationElement(element)
	}
	
	; Retrieves a tree walker object that can be used to traverse the Microsoft UI Automation tree.
	CreateTreeWalker(pCondition){
		UIA_Error(DllCall(this.vt(13),"ptr",this.__,"ptr",pCondition.__,"ptr*",walker),"CreateTreeWalker")
		return new IUIAutomationTreeWalker(walker)
	}
	
	; Retrieves an IUIAutomationTreeWalker interface used to discover control elements.
	ControlViewWalker(){
		UIA_Error(DllCall(this.vt(14),"ptr",this.__,"ptr*",walker),"ControlViewWalker")
		return new IUIAutomationTreeWalker(walker)
	}
	
	; Retrieves an IUIAutomationTreeWalker interface used to discover content elements.
	ContentViewWalker(){
		UIA_Error(DllCall(this.vt(15),"ptr",this.__,"ptr*",walker),"ContentViewWalker")
		return new IUIAutomationTreeWalker(walker)
	}
	
	; Retrieves a tree walker object used to traverse an unfiltered view of the UI Automation tree.
	RawViewWalker(){
		UIA_Error(DllCall(this.vt(16),"ptr",this.__,"ptr*",walker),"RawViewWalker")
		return new IUIAutomationTreeWalker(walker)
	}
	
	; Retrieves a predefined IUIAutomationCondition interface that selects all UI elements in an unfiltered view.
	RawViewCondition(){
		UIA_Error(DllCall(this.vt(17),"ptr",this.__,"ptr*",condition),"RawViewCondition")
		return new IUIAutomationCondition(condition)
	}
	
	; Retrieves a predefined IUIAutomationCondition interface that selects control elements.
	ControlViewCondition(){
		UIA_Error(DllCall(this.vt(18),"ptr",this.__,"ptr*",condition),"ControlViewCondition")
		return new IUIAutomationCondition(condition)
	}
	
	; Retrieves a predefined IUIAutomationCondition interface that selects content elements.
	ContentViewCondition(){
		UIA_Error(DllCall(this.vt(19),"ptr",this.__,"ptr*",condition),"ContentViewCondition")
		return new IUIAutomationCondition(condition)
	}
	
	; Creates a cache request.
	; After obtaining the IUIAutomationCacheRequest interface, use its methods to specify properties and control patterns to be cached when a UI Automation element is obtained. 
	CreateCacheRequest(){
		UIA_Error(DllCall(this.vt(20),"ptr",this.__,"ptr*",cacheRequest),"CreateCacheRequest")
		return new IUIAutomationCacheRequest(cacheRequest)
	}
	
	; Retrieves a predefined condition that selects all elements.
	CreateTrueCondition(){
		UIA_Error(DllCall(this.vt(21),"ptr",this.__,"ptr*",newCondition),"CreateTrueCondition")
		return new IUIAutomationBoolCondition(newCondition)
	}
	
	; Creates a condition that is always false.
	; This method exists only for symmetry with IUIAutomation::CreateTrueCondition. A false condition will never enable a match with UI Automation elements, and it cannot usefully be combined with any other condition.
	CreateFalseCondition(){
		UIA_Error(DllCall(this.vt(22),"ptr",this.__,"ptr*",newCondition),"CreateFalseCondition")
		return new IUIAutomationBoolCondition(newCondition)
	}
	
	; Creates a condition that selects elements that have a property with the specified value.
	CreatePropertyCondition(propertyId,value){ ; not test
		UIA_Error(DllCall(this.vt(23),"ptr",this.__,"int",propertyId,"ptr",variant(ptr,UIA_PropertyVariantType(propertyId),value),"ptr*",newCondition),"CreatePropertyCondition")
		return new IUIAutomationPropertyCondition(newCondition)
	}
	
	; Creates a condition that selects elements that have a property with the specified value, using optional flags.
	CreatePropertyConditionEx(propertyId,value,flags){
		UIA_Error(DllCall(this.vt(24),"ptr",this.__,"int",propertyId,"ptr",variant(ptr,UIA_PropertyVariantType(propertyId),value),"int",flags,"ptr*",newCondition),"CreatePropertyConditionEx")
		return new IUIAutomationPropertyCondition(newCondition)
	}
	
	; The Create**Condition** method calls AddRef on each pointers. This means you can call Release on those pointers after the call to Create**Condition** returns without invalidating the pointer returned from Create**Condition**. When you call Release on the pointer returned from Create**Condition**, UI Automation calls Release on those pointers.

	; Creates a condition that selects elements that match both of two conditions.
	CreateAndCondition(condition1,condition2){
		UIA_Error(DllCall(this.vt(25),"ptr",this.__,"ptr",condition1.__,"ptr",condition2.__,"ptr*",newCondition),"CreateAndCondition")
		return new IUIAutomationAndCondition(newCondition)
	}
	
	; Creates a condition that selects elements based on multiple conditions, all of which must be true.
	CreateAndConditionFromArray(conditions){
		UIA_Error(DllCall(this.vt(26),"ptr",this.__,"ptr",IsObject(conditions)?ComObjValue(conditions):conditions,"ptr*",newCondition),"CreateAndConditionFromArray")
		return new IUIAutomationAndCondition(newCondition)
	}
	
	; Creates a condition that selects elements based on multiple conditions, all of which must be true.
	CreateAndConditionFromNativeArray(conditions,conditionCount){
		UIA_Error(DllCall(this.vt(27),"ptr",this.__,"ptr",conditions,"int",conditionCount,"ptr*",newCondition),"CreateAndConditionFromNativeArray")
		return new IUIAutomationAndCondition(newCondition)
	}
	
	; Creates a combination of two conditions where a match exists if either of the conditions is true. 
	CreateOrCondition(condition1,condition2){
		UIA_Error(DllCall(this.vt(28),"ptr",this.__,"ptr",condition1.__,"ptr",condition2.__,"ptr*",newCondition),"CreateOrCondition")
		return new IUIAutomationOrCondition(newCondition)
	}
	
	; Creates a combination of two or more conditions where a match exists if any of the conditions is true. 
	CreateOrConditionFromArray(conditions){
		UIA_Error(DllCall(this.vt(29),"ptr",this.__,"ptr",IsObject(conditions)?ComObjValue(conditions):conditions,"ptr*",newCondition),"CreateOrConditionFromArray")
		return new IUIAutomationOrCondition(newCondition)
	}
	
	; Creates a combination of two or more conditions where a match exists if any one of the conditions is true.
	CreateOrConditionFromNativeArray(conditions,conditionCount){
		UIA_Error(DllCall(this.vt(30),"ptr",this.__,"ptr",conditions,"ptr",conditionCount,"ptr*",newCondition),"CreateOrConditionFromNativeArray")
		return new IUIAutomationOrCondition(newCondition)
	}
	
	; Creates a condition that is the negative of a specified condition.
	CreateNotCondition(condition){
		UIA_Error(DllCall(this.vt(31),"ptr",this.__,"ptr",condition.__,"ptr*",newCondition),"CreateNotCondition")
		return new IUIAutomationNotCondition(newCondition)
	}
	
	; Note:  Before implementing an event handler, you should be familiar with the threading issues described in Understanding Threading Issues. http://msdn.microsoft.com/en-us/library/ee671692(v=vs.85).aspx
	; A UI Automation client should not use multiple threads to add or remove event handlers. Unexpected behavior can result if one event handler is being added or removed while another is being added or removed in the same client process.
	; It is possible for an event to be delivered to an event handler after the handler has been unsubscribed, if the event is received simultaneously with the request to unsubscribe the event. The best practice is to follow the Component Object Model (COM) standard and avoid destroying the event handler object until its reference count has reached zero. Destroying an event handler immediately after unsubscribing for events may result in an access violation if an event is delivered late.
	
	; Registers a method that handles Microsoft UI Automation events.
	AddAutomationEventHandler(eventId,element,scope,cacheRequest,handler){
		return UIA_Error(DllCall(this.vt(32),"ptr",this.__,"int",eventId,"ptr",element.__,"int",scope,"ptr",cacheRequest?cacheRequest.__:0,"ptr",handler),"AddAutomationEventHandler")
	}
	
	; Removes the specified UI Automation event handler.
	RemoveAutomationEventHandler(eventId,element,handler){
		return UIA_Error(DllCall(this.vt(33),"ptr",this.__,"int",eventId,"ptr",element.__,"ptr",handler),"RemoveAutomationEventHandler")
	}
	
	; Registers a method that handles property-changed events. 
	; The UI item specified by element might not support the properties specified by the propertyArray parameter. 
	; This method serves the same purpose as IUIAutomation::AddPropertyChangedEventHandler, but takes a normal array of property identifiers instead of a SAFEARRAY. 
	AddPropertyChangedEventHandlerNativeArray(element,scope,cacheRequest,handler,propertyArray,propertyCount){
		return UIA_Error(DllCall(this.vt(34),"ptr",this.__,"ptr",element.__,"int",scope,"ptr",cacheRequest?cacheRequest.__:0,"ptr",handler,"ptr",propertyArray,"int",propertyCount),"AddPropertyChangedEventHandlerNativeArray")
	}
	
	; Registers a method that handles property-changed events. 
	; The UI item specified by element might not support the properties specified by the propertyArray parameter. 
	AddPropertyChangedEventHandler(element,scope,cacheRequest,handler,propertyArray){
		return UIA_Error(DllCall(this.vt(35),"ptr",this.__,"ptr",element.__,"int",scope,"ptr",cacheRequest?cacheRequest.__:0,"ptr",handler,"ptr",propertyArray),"AddPropertyChangedEventHandler")
	}
	
	; Removes a property-changed event handler.
	RemovePropertyChangedEventHandler(element,handler){
		return UIA_Error(DllCall(this.vt(36),"ptr",this.__,"ptr",element.__,"ptr",handler),"RemovePropertyChangedEventHandler")
	}
	
	; Registers a method that handles structure-changed events.
	AddStructureChangedEventHandler(element,scope,cacheRequest,handler){
		return UIA_Error(DllCall(this.vt(37),"ptr",this.__,"ptr",element.__,"int",scope,"ptr",cacheRequest?cacheRequest.__:0,"ptr",handler),"AddStructureChangedEventHandler")
	}
	
	; Removes a structure-changed event handler.
	RemoveStructureChangedEventHandler(element,handler){
		return UIA_Error(DllCall(this.vt(38),"ptr",this.__,"ptr",element.__,"ptr",handler),"RemoveStructureChangedEventHandler")
	}
	
	; Registers a method that handles focus-changed events.
	; Focus-changed events are system-wide; you cannot set a narrower scope.
	AddFocusChangedEventHandler(cacheRequest,handler){
		return UIA_Error(DllCall(this.vt(39),"ptr",this.__,"ptr",cacheRequest?cacheRequest.__:0,"ptr",handler),"AddFocusChangedEventHandler")
	}
	
	; Removes a focus-changed event handler. 
	RemoveFocusChangedEventHandler(handler){
		return UIA_Error(DllCall(this.vt(40),"ptr",this.__,"ptr",handler),"RemoveFocusChangedEventHandler")
	}
	
	; Removes all registered Microsoft UI Automation event handlers.
	RemoveAllEventHandlers(){
		return UIA_Error(DllCall(this.vt(41),"ptr",this.__),"RemoveAllEventHandlers")
	}
	
	; Converts an array of integers to a SAFEARRAY.
	IntNativeArrayToSafeArray(array,arrayCount){
		UIA_Error(DllCall(this.vt(42),"ptr",this.__,"ptr",array,"int",arrayCount,"ptr*",safeArray),"IntNativeArrayToSafeArray")
		return safeArray
	}
	
	; Converts a SAFEARRAY of integers to an array.
	IntSafeArrayToNativeArray(intArray){
		UIA_Error(DllCall(this.vt(43),"ptr",this.__,"ptr",intArray,"ptr*",array,"int*",arrayCount),"IntSafeArrayToNativeArray")
		return [array,arrayCount]
	}
	
	; Creates a VARIANT that contains the coordinates of a rectangle.
	; The returned VARIANT has a data type of VT_ARRAY | VT_R8. 
	RectToVariant(rc){
		UIA_Error(DllCall(this.vt(44),"ptr",this.__,"ptr",rc,"ptr*",var),"RectToVariant")
		return var
	}
	
	; Converts a VARIANT containing rectangle coordinates to a RECT.
	VariantToRect(var){
		UIA_Error(DllCall(this.vt(45),"ptr",this.__,"ptr",var,"ptr*",rc),"VariantToRect")
		return rc
	}
	
	; Converts a SAFEARRAY containing rectangle coordinates to an array of type RECT. 
	SafeArrayToRectNativeArray(rects){
		UIA_Error(DllCall(this.vt(46),"ptr",this.__,"ptr",rects,"ptr*",rectArray,"int*",rectArrayCount),"SafeArrayToRectNativeArray")
		return [rectArray,rectArrayCount]
	}
	
	; Creates a new instance of a proxy factory object.
	; Use the IUIAutomationProxyFactoryMapping interface to enter the proxy factory into the table of available proxies. 
	CreateProxyFactoryEntry(factory){
		UIA_Error(DllCall(this.vt(47),"ptr",this.__,"ptr",factory.__,"ptr*",factoryEntry),"CreateProxyFactoryEntry")
		return new IUIAutomationProxyFactoryEntry(factoryEntry)
	}
	
	; Retrieves an object that represents the mapping of Window classnames and associated data to individual proxy factories. This property is read-only.
	ProxyFactoryMapping(){
		UIA_Error(DllCall(this.vt(48),"ptr",this.__,"ptr*",factoryMapping),"ProxyFactoryMapping")
		return new IUIAutomationProxyFactoryMapping(factoryMapping)
	}
	
	; The programmatic name is intended for debugging and diagnostic purposes only. The string is not localized.
	; This property should not be used in string comparisons. To determine whether two properties are the same, compare the property identifiers directly.
	
	; Retrieves the registered programmatic name of a property.
	GetPropertyProgrammaticName(property){
		UIA_Error(DllCall(this.vt(49),"ptr",this.__,"int",property,"ptr*",name),"GetPropertyProgrammaticName")
		return StrGet(name,"utf-16")
	}
	
	; Retrieves the registered programmatic name of a control pattern.
	GetPatternProgrammaticName(pattern){
		UIA_Error(DllCall(this.vt(50),"ptr",this.__,"int",pattern,"ptr*",name),"GetPatternProgrammaticName")
		return StrGet(name,"utf-16")
	}
	
	; This method is intended only for use by Microsoft UI Automation tools that need to scan for properties. It is not intended to be used by UI Automation clients.
	; There is no guarantee that the element will support any particular control pattern when asked for it later.
	
	; Retrieves the control patterns that might be supported on a UI Automation element.
	PollForPotentialSupportedPatterns(pElement){
		UIA_Error(DllCall(this.vt(51),"ptr",this.__,"ptr",pElement.__,"ptr*",patternIds,"ptr*",patternNames),"PollForPotentialSupportedPatterns")
		return [patternIds,patternNames] ; SafeArray
	}
	
	; Retrieves the properties that might be supported on a UI Automation element.
	PollForPotentialSupportedProperties(pElement){
		UIA_Error(DllCall(this.vt(52),"ptr",this.__,"ptr",pElement.__,"ptr*",propertyIds,"ptr*",propertyNames),"PollForPotentialSupportedProperties")
		return [propertyIds,propertyNames] ; SafeArray
	}
	
	; Checks a provided VARIANT to see if it contains the Not Supported identifier.
	; After retrieving a property for a UI Automation element, call this method to determine whether the element supports the retrieved property. CheckNotSupported is typically called after calling a property retrieving method such as GetCurrentPropertyValue. 
	CheckNotSupported(value){ ; not completed
		UIA_Error(DllCall(this.vt(53),"ptr",this.__,"ptr",value,"int*",isNotSupported),"CheckNotSupported")
		return isNotSupported
	}
	
	; Retrieves a static token object representing a property or text attribute that is not supported. This property is read-only.
	; This object can be used for comparison with the results from IUIAutomationElement::GetCurrentPropertyValue or IUIAutomationTextRange::GetAttributeValue.
	ReservedNotSupportedValue(){
		UIA_Error(DllCall(this.vt(54),"ptr",this.__,"ptr*",notSupportedValue),"ReservedNotSupportedValue")
		return notSupportedValue ; Iunknown
	}
	
	; Retrieves a static token object representing a text attribute that is a mixed attribute. This property is read-only.
	; The object retrieved by IUIAutomation::ReservedMixedAttributeValue can be used for comparison with the results from IUIAutomationTextRange::GetAttributeValue to determine if a text range contains more than one value for a particular text attribute.
	ReservedMixedAttributeValue(){
		UIA_Error(DllCall(this.vt(55),"ptr",this.__,"ptr*",mixedAttributeValue),"ReservedMixedAttributeValue")
		return mixedAttributeValue ; Iunknown
	}
	
	; This method enables UI Automation clients to get IUIAutomationElement interfaces for accessible objects implemented by a Microsoft Active Accessiblity server. 
	; This method may fail if the server implements UI Automation provider interfaces alongside Microsoft Active Accessibility support. 
	; The method returns E_INVALIDARG if the underlying implementation of the Microsoft UI Automation element is not a native Microsoft Active Accessibility server; that is, if a client attempts to retrieve the IAccessible interface for an element originally supported by a proxy object from Oleacc.dll, or by the UIA-to-MSAA Bridge.
	
	; Retrieves a UI Automation element for the specified accessible object from a Microsoft Active Accessibility server.
	ElementFromIAccessible(accessible,childId){
		UIA_Error(DllCall(this.vt(56),"ptr",this.__,"ptr",accessible,"int",childId,"ptr*",element),"ElementFromIAccessible")
		return new IUIAutomationElement(element)
	}
	
	; Retrieves a UI Automation element for the specified accessible object from a Microsoft Active Accessibility server, prefetches the requested properties and control patterns, and stores the prefetched items in the cache.
	ElementFromIAccessibleBuildCache(accessible,childId,cacheRequest){
		UIA_Error(DllCall(this.vt(57),"ptr",this.__,"ptr",accessible,"int",childId,"ptr",cacheRequest.__,"ptr*",element),"ElementFromIAccessibleBuildCache")
		return new IUIAutomationElement(element)
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;
;;IUIAutomationElement;;will be modified
;;;;;;;;;;;;;;;;;;;;;;;;

class IUIAutomationElement extends IBase
{
	
	; Sets the keyboard focus to this UI Automation element.
	SetFocus(){
	return UIA_Error(DllCall(this.vt(3),"ptr",this.__),"SetFocus")
	}
	
	; Retrieves the unique identifier assigned to the UI element. 
	; The identifier is only guaranteed to be unique to the UI of the desktop on which it was generated. Identifiers can be reused over time.
	; The format of run-time identifiers might change in the future. The returned identifier should be treated as an opaque value and used only for comparison; for example, to determine whether a Microsoft UI Automation element is in the cache.
	GetRuntimeId(){
	UIA_Error(DllCall(this.vt(4),"ptr",this.__,"ptr*",runtimeId),"GetRuntimeId")
	return runtimeId ; safearray
	}
	
	; The scope of the search is relative to the element on which the method is called. Elements are returned in the order in which they are encountered in the tree.
	; This function cannot search for ancestor elements in the Microsoft UI Automation tree; that is, TreeScope_Ancestors is not a valid value for the scope parameter.
	; When searching for top-level windows on the desktop, be sure to specify TreeScope_Children in the scope parameter, not TreeScope_Descendants. A search through the entire subtree of the desktop could iterate through thousands of items and lead to a stack overflow.
	; If your client application might try to find elements in its own user interface, you must make all UI Automation calls on a separate thread. 
	
	; Retrieves the first child or descendant element that matches the specified condition. 
	FindFirst(scope,condition){
	UIA_Error(DllCall(this.vt(5),"ptr",this.__,"int",scope,"ptr",condition.__,"ptr*",found),"FindFirst")
	return new IUIAutomationElement(found)
	}
	
	; Returns all UI Automation elements that satisfy the specified condition. 
	FindAll(scope,condition){
	UIA_Error(DllCall(this.vt(6),"ptr",this.__,"int",scope,"ptr",condition.__,"ptr*",found),"FindAll")
	return new IUIAutomationElementArray(found)
	}
	
	; Retrieves the first child or descendant element that matches the specified condition, prefetches the requested properties and control patterns, and stores the prefetched items in the cache.
	FindFirstBuildCache(scope,condition,cacheRequest){
	UIA_Error(DllCall(this.vt(7),"ptr",this.__,"int",scope,"ptr",condition.__,"ptr",cacheRequest.__,"ptr*",found),"FindFirstBuildCache")
	return new IUIAutomationElement(found)
	}
	
	; Returns all UI Automation elements that satisfy the specified condition, prefetches the requested properties and control patterns, and stores the prefetched items in the cache.
	FindAllBuildCache(scope,condition,cacheRequest){
	UIA_Error(DllCall(this.vt(8),"ptr",this.__,"int",scope,"ptr",condition.__,"ptr",cacheRequest.__,"ptr*",found),"FindAllBuildCache")
	return new IUIAutomationElementArray(found)
	}
	
	; Retrieves a new UI Automation element with an updated cache.
	; The original UI Automation element is unchanged. The new IUIAutomationElement interface refers to the same element and has the same runtime identifier. 
	BuildUpdatedCache(cacheRequest){
	UIA_Error(DllCall(this.vt(9),"ptr",this.__,"ptr",cacheRequest.__,"ptr*",updatedElement),"BuildUpdatedCache")
	return new IUIAutomationElement(updatedElement)
	}
	
	; Microsoft UI Automation properties of the double type support Not a Number (NaN) values. When retrieving a property of the double type, a client can use the _isnan function to determine whether the property is a NaN value. 
	
	; Retrieves the current value of a property for this UI Automation element.
	GetCurrentPropertyValue(propertyId){ ; not test
	static _,_v:=variant(_)
	UIA_Error(DllCall(this.vt(10),"ptr",this.__,"int",propertyId,"ptr",_v),"GetCurrentPropertyValue")
	return GetVariantValue(_v)
	}
	
	; Retrieves a property value for this UI Automation element, optionally ignoring any default value.
	; Passing FALSE in the ignoreDefaultValue parameter is equivalent to calling IUIAutomationElement::GetCurrentPropertyValue.
	; If the Microsoft UI Automation provider for the element itself supports the property, the value of the property is returned. Otherwise, if ignoreDefaultValue is FALSE, a default value specified by UI Automation is returned. 
	; This method returns a failure code if the requested property was not previously cached.
	GetCurrentPropertyValueEx(propertyId,ignoreDefaultValue){
	static _,_v:=variant(_)
	UIA_Error(DllCall(this.vt(11),"ptr",this.__,"int",propertyId,"int",ignoreDefaultValue,"ptr",_v),"GetCurrentPropertyValueEx")
	return GetVariantValue(_v)
	}
	
	; Retrieves a property value from the cache for this UI Automation element.
	GetCachedPropertyValue(propertyId){
	static _,_v:=variant(_)
	UIA_Error(DllCall(this.vt(12),"ptr",this.__,"int",propertyId,"ptr",_v),"GetCachedPropertyValue")
	return GetVariantValue(_v)
	}
	
	; Retrieves a property value from the cache for this UI Automation element, optionally ignoring any default value.
	GetCachedPropertyValueEx(propertyId,ignoreDefaultValue,retVal){
	static _,_v:=variant(_)
	UIA_Error(DllCall(this.vt(13),"ptr",this.__,"int",propertyId,"int",ignoreDefaultValue,"ptr",_v),"GetCachedPropertyValueEx")
	return GetVariantValue(_v)
	}
	
	; Retrieves the control pattern interface of the specified pattern on this UI Automation element.
	GetCurrentPatternAs(patternId,riid){ ; not completed
	UIA_Error(DllCall(this.vt(14),"ptr",this.__,"int",patternId,"ptr",riid,"ptr*",patternObject),"GetCurrentPatternAs")
	return patternObject
	}
	
	; Retrieves the control pattern interface of the specified pattern from the cache of this UI Automation element.
	GetCachedPatternAs(patternId,riid){ ; not completed
	UIA_Error(DllCall(this.vt(15),"ptr",this.__,"int",patternId,"ptr",riid,"ptr*",patternObject),"GetCachedPatternAs")
	return patternObject
	}
	
	; Retrieves the IUnknown interface of the specified control pattern on this UI Automation element. 
	; This method gets the specified control pattern based on its availability at the time of the call.
	; For some forms of UI, this method will incur cross-process performance overhead. Applications can reduce overhead by caching control patterns and then retrieving them by using IUIAutomationElement::GetCachedPattern.
	GetCurrentPattern(patternId){
	UIA_Error(DllCall(this.vt(16),"ptr",this.__,"int",patternId,"ptr*",patternObject),"GetCurrentPattern")
	if name:=UIA_Pattern(patternID)
	return (name:=UIA_Pattern(patternID))?new IUIAutomation%name%Pattern(patternObject):patternObject
	}
	
	; Retrieves from the cache the IUnknown interface of the specified control pattern of this UI Automation element. 
	GetCachedPattern(patternId){
	UIA_Error(DllCall(this.vt(17),"ptr",this.__,"int",patternId,"ptr*",patternObject),"GetCachedPattern")
	return (name:=UIA_Pattern(patternID))?new IUIAutomation%name%Pattern(patternObject):patternObject
	}
	
	; Retrieves from the cache the parent of this UI Automation element. 
	GetCachedParent(){
	UIA_Error(DllCall(this.vt(18),"ptr",this.__,"ptr*",parent),"GetCachedParent")
	return new IUIAutomationElement(parent)
	}
	
	; Retrieves the cached child elements of this UI Automation element. 
	; The view of the returned collection is determined by the TreeFilter property of the IUIAutomationCacheRequest that was active when this element was obtained.
	; Children are cached only if the scope of the cache request included TreeScope_Subtree, TreeScope_Children, or TreeScope_Descendants.
	; If the cache request specified that children were to be cached at this level, but there are no children, the value of this property is 0. However, if no request was made to cache children at this level, an attempt to retrieve the property returns an error.
	GetCachedChildren(){
	UIA_Error(DllCall(this.vt(19),"ptr",this.__,"ptr*",children),"GetCachedChildren")
	return new IUIAutomationElementArray(children)
	}

	; Retrieves the identifier of the process that hosts the element.
	CurrentProcessId(){
	UIA_Error(DllCall(this.vt(20),"ptr",this.__,"int*",retVal),"get_CurrentProcessId")
	return retVal
	}
	
	; Retrieves the control type of the element.
	; Control types describe a known interaction model for UI Automation elements without relying on a localized control type or combination of complex logic rules. This property cannot change at run time unless the control supports the IUIAutomationMultipleViewPattern interface. An example is the Win32 ListView control, which can change from a data grid to a list, depending on the current view.
	CurrentControlType(){
	UIA_Error(DllCall(this.vt(21),"ptr",this.__,"int*",retVal),"get_CurrentControlType")
	return retVal
	}
	
	; Retrieves a localized description of the control type of the element.
	CurrentLocalizedControlType(){
	UIA_Error(DllCall(this.vt(22),"ptr",this.__,"ptr*",retVal),"get_CurrentLocalizedControlType")
	return StrGet(retVal,"utf-16")
	}
	
	; Retrieves the name of the element.
	CurrentName(){
	UIA_Error(DllCall(this.vt(23),"ptr",this.__,"ptr*",retVal),"get_CurrentName")
	return StrGet(retVal,"utf-16")
	}
	
	; Retrieves the accelerator key for the element.
	CurrentAcceleratorKey(){
	UIA_Error(DllCall(this.vt(24),"ptr",this.__,"ptr*",retVal),"get_CurrentAcceleratorKey")
	return StrGet(retVal,"utf-16")
	}
	
	; Retrieves the access key character for the element.
	; An access key is a character in the text of a menu, menu item, or label of a control such as a button that activates the attached menu function. For example, the letter "O" is often used to invoke the Open file common dialog box from a File menu. Microsoft UI Automation elements that have the access key property set always implement the Invoke control pattern.
	CurrentAccessKey(){
	UIA_Error(DllCall(this.vt(25),"ptr",this.__,"ptr*",retVal),"get_CurrentAccessKey")
	return StrGet(retVal,"utf-16")
	}
	
	; Indicates whether the element has keyboard focus.
	CurrentHasKeyboardFocus(){
	UIA_Error(DllCall(this.vt(26),"ptr",this.__,"int*",retVal),"get_CurrentHasKeyboardFocus")
	return retVal
	}
	
	; Indicates whether the element can accept keyboard focus.
	CurrentIsKeyboardFocusable(){
	UIA_Error(DllCall(this.vt(27),"ptr",this.__,"int*",retVal),"get_CurrentIsKeyboardFocusable")
	return retVal
	}
	
	; Retrieves a cached value that indicates whether the element is enabled.
	CurrentIsEnabled(){
	UIA_Error(DllCall(this.vt(28),"ptr",this.__,"int*",retVal),"get_CurrentIsEnabled")
	return retVal
	}
	
	; Retrieves the Microsoft UI Automation identifier of the element. 
	; The identifier is unique among sibling elements in a container, and is the same in all instances of the application.
	CurrentAutomationId(){
	UIA_Error(DllCall(this.vt(29),"ptr",this.__,"ptr*",retVal),"get_CurrentAutomationId")
	return retVal
	}
	
	; Retrieves the class name of the element.
	; The value of this property is implementation-defined. The property is useful in testing environments.
	CurrentClassName(){
	UIA_Error(DllCall(this.vt(30),"ptr",this.__,"ptr*",retVal),"get_CurrentClassName")
	return StrGet(retVal,"utf-16")
	}
	
	; Retrieves the help text for the element. This information is typically obtained from tooltips.
	; Caution  Do not retrieve the CachedHelpText property from a control that is based on the SysListview32 class. Doing so could cause the system to become unstable and data to be lost. A client application can discover whether a control is based on SysListview32 by retrieving the CachedClassName or CurrentClassName property from the control.
	CurrentHelpText(){
	UIA_Error(DllCall(this.vt(31),"ptr",this.__,"ptr*",retVal),"get_CurrentHelpText")
	return StrGet(retVal,"utf-16")
	}
	
	; Retrieves the culture identifier for the element.
	CurrentCulture(){
	UIA_Error(DllCall(this.vt(32),"ptr",this.__,"int*",retVal),"get_CurrentCulture")
	return retVal
	}
	
	; Indicates whether the element is a control element.
	CurrentIsControlElement(){
	UIA_Error(DllCall(this.vt(33),"ptr",this.__,"int*",retVal),"get_CurrentIsControlElement")
	return retVal
	}
	
	; Indicates whether the element is a content element.
	; A content element contains data that is presented to the user. Examples of content elements are the items in a list box or a button in a dialog box. Non-content elements, also called peripheral elements, are typically used to manipulate the content in a composite control; for example, the button on a drop-down control.
	CurrentIsContentElement(){
	UIA_Error(DllCall(this.vt(34),"ptr",this.__,"int*",retVal),"get_CurrentIsContentElement")
	return retVal
	}
	
	; Indicates whether the element contains a disguised password.
	; This property enables applications such as screen-readers to determine whether the text content of a control should be read aloud.
	CurrentIsPassword(){
	UIA_Error(DllCall(this.vt(35),"ptr",this.__,"int*",retVal),"get_CurrentIsPassword")
	return retVal
	}
	
	; Retrieves the window handle of the element.
	CurrentNativeWindowHandle(){
	UIA_Error(DllCall(this.vt(36),"ptr",this.__,"ptr*",retVal),"get_CurrentNativeWindowHandle")
	return retVal
	}
	
	; Retrieves a description of the type of UI item represented by the element.
	; This property is used to obtain information about items in a list, tree view, or data grid. For example, an item in a file directory view might be a "Document File" or a "Folder". 
	CurrentItemType(){
	UIA_Error(DllCall(this.vt(37),"ptr",this.__,"ptr*",retVal),"get_CurrentItemType")
	return StrGet(retVal,"utf-16")
	}
	
	; Indicates whether the element is off-screen.
	CurrentIsOffscreen(){
	UIA_Error(DllCall(this.vt(38),"ptr",this.__,"int*",retVal),"get_CurrentIsOffscreen")
	return retVal
	}
	
	; Retrieves a value that indicates the orientation of the element.
	; This property is supported by controls such as scroll bars and sliders that can have either a vertical or a horizontal orientation.
	CurrentOrientation(){
	UIA_Error(DllCall(this.vt(39),"ptr",this.__,"int*",retVal),"get_CurrentOrientation")
	return retVal ; OrientationType
	}
	
	; Retrieves the name of the underlying UI framework. The name of the UI framework, such as "Win32", "WinForm", or "DirectUI".
	CurrentFrameworkId(){
	UIA_Error(DllCall(this.vt(40),"ptr",this.__,"ptr*",retVal),"get_CurrentFrameworkId")
	return StrGet(retVal,"utf-16")
	}
	
	; Indicates whether the element is required to be filled out on a form.
	CurrentIsRequiredForForm(){
	UIA_Error(DllCall(this.vt(41),"ptr",this.__,"int*",retVal),"get_CurrentIsRequiredForForm")
	return retVal
	}
	
	; Retrieves the description of the status of an item in an element.
	; This property enables a client to ascertain whether an element is conveying status about an item. For example, an item associated with a contact in a messaging application might be "Busy" or "Connected".
	CurrentItemStatus(){
	UIA_Error(DllCall(this.vt(42),"ptr",this.__,"ptr*",retVal),"get_CurrentItemStatus")
	return StrGet(retVal,"utf-16")
	}
	
	; Retrieves the coordinates of the rectangle that completely encloses the element, in screen coordinates.
	CurrentBoundingRectangle(){
	UIA_Error(DllCall(this.vt(43),"ptr",this.__,"int64*",retVal),"get_CurrentBoundingRectangle")
	return [retVal&0xFF,(retVal>>16)&0xFF,(retVal>>32)&0xFF,retVal>>48]
	}
	
	; This property maps to the Accessible Rich Internet Applications (ARIA) property.
	
	; Retrieves the element that contains the text label for this element.
	; This property could be used to retrieve, for example, the static text label for a combo box.
	CurrentLabeledBy(){
	UIA_Error(DllCall(this.vt(44),"ptr",this.__,"ptr*",retVal),"get_CurrentLabeledBy")
	return retVal ; IUIAutomationElement
	}
	
	; Retrieves the Accessible Rich Internet Applications (ARIA) role of the element.
	CurrentAriaRole(){
	UIA_Error(DllCall(this.vt(45),"ptr",this.__,"ptr*",retVal),"get_CurrentAriaRole")
	return StrGet(retVal,"utf-16")
	}
	
	; Retrieves the ARIA properties of the element.
	CurrentAriaProperties(){
	UIA_Error(DllCall(this.vt(46),"ptr",this.__,"ptr",retVal),"get_CurrentAriaProperties")
	return StrGet(retVal,"utf-16")
	}
	
	; Indicates whether the element contains valid data for a form.
	CurrentIsDataValidForForm(){
	UIA_Error(DllCall(this.vt(47),"ptr",this.__,"int*",retVal),"get_CurrentIsDataValidForForm")
	return retVal
	}
	
	; Retrieves an array of elements for which this element serves as the controller.
	CurrentControllerFor(){
	UIA_Error(DllCall(this.vt(48),"ptr",this.__,"ptr*",retVal),"get_CurrentControllerFor")
	return retVal ; IUIAutomationElementArray
	}
	
	; Retrieves an array of elements that describe this element.
	CurrentDescribedBy(){
	UIA_Error(DllCall(this.vt(49),"ptr",this.__,"ptr*",retVal),"get_CurrentDescribedBy")
	return retVal ; IUIAutomationElementArray
	}
	
	; Retrieves an array of elements that indicates the reading order after the current element.
	CurrentFlowsTo(){
	UIA_Error(DllCall(this.vt(50),"ptr",this.__,"ptr*",retVal),"get_CurrentFlowsTo")
	return retVal ; IUIAutomationElementArray
	}
	
	; Retrieves a description of the provider for this element.
	CurrentProviderDescription(){
	UIA_Error(DllCall(this.vt(51),"ptr",this.__,"ptr*",retVal),"get_CurrentProviderDescription")
	return StrGet(retVal,"utf-16")
	}
	
	; Retrieves the cached ID of the process that hosts the element.
	CachedProcessId(){
	UIA_Error(DllCall(this.vt(52),"ptr",this.__,"int*",retVal),"get_CachedProcessId")
	return retVal
	}
	
	; Retrieves a cached value that indicates the control type of the element.
	CachedControlType(){
	UIA_Error(DllCall(this.vt(53),"ptr",this.__,"int*",retVal),"get_CachedControlType")
	return retVal
	}
	
	; Retrieves the cached localized description of the control type of the element.
	CachedLocalizedControlType(){
	UIA_Error(DllCall(this.vt(54),"ptr",this.__,"ptr*",retVal),"get_CachedLocalizedControlType")
	return StrGet(retVal,"utf-16")
	}
	
	; Retrieves the cached name of the element.
	CachedName(){
	UIA_Error(DllCall(this.vt(55),"ptr",this.__,"ptr*",retVal),"get_CachedName")
	return StrGet(retVal,"utf-16")
	}
	
	; Retrieves the cached accelerator key for the element.
	CachedAcceleratorKey(){
	UIA_Error(DllCall(this.vt(56),"ptr",this.__,"ptr*",retVal),"get_CachedAcceleratorKey")
	return StrGet(retVal,"utf-16")
	}
	
	; Retrieves the cached access key character for the element.
	CachedAccessKey(){
	UIA_Error(DllCall(this.vt(57),"ptr",this.__,"ptr*",retVal),"get_CachedAccessKey")
	return StrGet(retVal,"utf-16")
	}
	
	; A cached value that indicates whether the element has keyboard focus.
	CachedHasKeyboardFocus(){
	UIA_Error(DllCall(this.vt(58),"ptr",this.__,"int*",retVal),"get_CachedHasKeyboardFocus")
	return retVal
	}
	
	; Retrieves a cached value that indicates whether the element can accept keyboard focus.
	CachedIsKeyboardFocusable(){
	UIA_Error(DllCall(this.vt(59),"ptr",this.__,"int*",retVal),"get_CachedIsKeyboardFocusable")
	return retVal
	}
	
	; Retrieves a cached value that indicates whether the element is enabled.
	CachedIsEnabled(){
	UIA_Error(DllCall(this.vt(60),"ptr",this.__,"int*",retVal),"get_CachedIsEnabled")
	return retVal
	}
	
	; Retrieves the cached UI Automation identifier of the element.
	CachedAutomationId(){
	UIA_Error(DllCall(this.vt(61),"ptr",this.__,"ptr*",retVal),"get_CachedAutomationId")
	return retVal
	}
	
	; Retrieves the cached class name of the element.
	CachedClassName(){
	UIA_Error(DllCall(this.vt(62),"ptr",this.__,"ptr*",retVal),"get_CachedClassName")
	return StrGet(retVal,"utf-16")
	}
	
	; 
	CachedHelpText(){
	UIA_Error(DllCall(this.vt(63),"ptr",this.__,"ptr*",retVal),"get_CachedHelpText")
	return StrGet(retVal,"utf-16")
	}
	
	; Retrieves the cached help text for the element.
	CachedCulture(){
	UIA_Error(DllCall(this.vt(64),"ptr",this.__,"int*",retVal),"get_CachedCulture")
	return retVal
	}
	
	; Retrieves a cached value that indicates whether the element is a control element.
	CachedIsControlElement(){
	UIA_Error(DllCall(this.vt(65),"ptr",this.__,"int*",retVal),"get_CachedIsControlElement")
	return retVal
	}
	
	; A cached value that indicates whether the element is a content element.
	CachedIsContentElement(){
	UIA_Error(DllCall(this.vt(66),"ptr",this.__,"int*",retVal),"get_CachedIsContentElement")
	return retVal
	}
	
	; Retrieves a cached value that indicates whether the element contains a disguised password.
	CachedIsPassword(){
	UIA_Error(DllCall(this.vt(67),"ptr",this.__,"int*",retVal),"get_CachedIsPassword")
	return retVal
	}
	
	; Retrieves the cached window handle of the element.
	CachedNativeWindowHandle(){
	UIA_Error(DllCall(this.vt(68),"ptr",this.__,"ptr*",retVal),"get_CachedNativeWindowHandle")
	return retVal
	}
	
	; Retrieves a cached string that describes the type of item represented by the element.
	CachedItemType(){
	UIA_Error(DllCall(this.vt(69),"ptr",this.__,"ptr*",retVal),"get_CachedItemType")
	return StrGet(retVal,"utf-16")
	}
	
	; Retrieves a cached value that indicates whether the element is off-screen.
	CachedIsOffscreen(){
	UIA_Error(DllCall(this.vt(70),"ptr",this.__,"int*",retVal),"get_CachedIsOffscreen")
	return retVal
	}
	
	; Retrieves a cached value that indicates the orientation of the element.
	CachedOrientation(){
	UIA_Error(DllCall(this.vt(71),"ptr",this.__,"ptr*",retVal),"get_CachedOrientation")
	return retVal ; OrientationType
	}
	
	; Retrieves the cached name of the underlying UI framework associated with the element.
	CachedFrameworkId(){
	UIA_Error(DllCall(this.vt(72),"ptr",this.__,"ptr*",retVal),"get_CachedFrameworkId")
	return StrGet(retVal,"utf-16")
	}
	
	; Retrieves a cached value that indicates whether the element is required to be filled out on a form. 
	CachedIsRequiredForForm(){
	UIA_Error(DllCall(this.vt(73),"ptr",this.__,"int*",retVal),"get_CachedIsRequiredForForm")
	return retVal
	}
	
	; Retrieves a cached description of the status of an item within an element.
	CachedItemStatus(){
	UIA_Error(DllCall(this.vt(74),"ptr",this.__,"ptr*",retVal),"get_CachedItemStatus")
	return StrGet(retVal,"utf-16")
	}
	
	; Retrieves the cached coordinates of the rectangle that completely encloses the element.
	CachedBoundingRectangle(){
	UIA_Error(DllCall(this.vt(75),"ptr",this.__,"int64*",retVal),"get_CachedBoundingRectangle")
	return [retVal&0xFF,(retVal>>16)&0xFF,(retVal>>32)&0xFF,retVal>>48]
	}
	
	; Retrieves the cached element that contains the text label for this element.
	CachedLabeledBy(){
	UIA_Error(DllCall(this.vt(76),"ptr",this.__,"ptr*",retVal),"get_CachedLabeledBy")
	return new IUIAutomationElement(retVal) ; IUIAutomationElement
	}
	
	; Retrieves the cached ARIA role of the element.
	CachedAriaRole(){
	UIA_Error(DllCall(this.vt(77),"ptr",this.__,"ptr*",retVal),"get_CachedAriaRole")
	return StrGet(retVal,"utf-16")
	}
	
	; Retrieves the cached ARIA properties of the element.
	CachedAriaProperties(){
	UIA_Error(DllCall(this.vt(78),"ptr",this.__,"ptr*",retVal),"get_CachedAriaProperties")
	return StrGet(retVal,"utf-16")
	}
	
	; Retrieves a cached value that indicates whether the element contains valid data for the form.
	CachedIsDataValidForForm(){
	UIA_Error(DllCall(this.vt(79),"ptr",this.__,"int*",retVal),"get_CachedIsDataValidForForm")
	return retVal
	}
	
	; Retrieves a cached array of UI Automation elements for which this element serves as the controller.
	CachedControllerFor(){
	UIA_Error(DllCall(this.vt(80),"ptr",this.__,"ptr*",retVal),"get_CachedControllerFor")
	return new IUIAutomationElementArray(retVal) ; IUIAutomationElementArray
	}
	
	; Retrieves a cached array of elements that describe this element.
	CachedDescribedBy(){
	UIA_Error(DllCall(this.vt(81),"ptr",this.__,"ptr*",retVal),"get_CachedDescribedBy")
	return new IUIAutomationElementArray(retVal) ; IUIAutomationElementArray
	}
	
	; Retrieves a cached array of elements that indicate the reading order after the current element.
	CachedFlowsTo(){
	UIA_Error(DllCall(this.vt(82),"ptr",this.__,"ptr*",retVal),"get_CachedFlowsTo")
	return new IUIAutomationElementArray(retVal) ; IUIAutomationElementArray
	}
	
	; Retrieves a cached description of the provider for this element.
	CachedProviderDescription(){
	UIA_Error(DllCall(this.vt(83),"ptr",this.__,"ptr*",retVal),"get_CachedProviderDescription")
	return StrGet(retVal,"utf-16")
	}
	
	; Retrieves a point on the element that can be clicked. 
	; A client application can use this method to simulate clicking the left or right mouse button. For example, to simulate clicking the right mouse button to display the context menu for a control: 
	; • Call the GetClickablePoint method to find a clickable point on the control.
	; • Call the SendInput function to send a right-mouse-down, right-mouse-up sequence.
	GetClickablePoint(){
	UIA_Error(DllCall(this.vt(84),"ptr",this.__,"int64*",clickable,"int*",gotClickable),"GetClickablePoint")
	return [clickable,gotClickable]
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;IUIAutomationElementArray;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

class IUIAutomationElementArray extends IBase
{
	; Retrieves the number of elements in the collection.
	Length(){
	UIA_Error(DllCall(this.vt(3),"ptr",this.__,"int*",length),"get_Length")
	return length
	}
	
	; Retrieves a Microsoft UI Automation element from the collection.
	Element(index){ ; zero-based
	UIA_Error(DllCall(this.vt(4),"ptr",this.__,"int",index,"ptr*",element),"GetElement")
	return new IUIAutomationElement(element)
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;IUIAutomationCacheRequest;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

class IUIAutomationCacheRequest extends IBase
{
	__get(aName){
		if (aName="TreeScope"){
			UIA_Error(DllCall(this.vt(6),"ptr",this.__,"int*",scope),"get_TreeScope")
			return scope ; TreeScope
		}else if (aName="TreeFilter"){
			UIA_Error(DllCall(this.vt(8),"ptr",this.__,"ptr*",filter),"get_TreeFilter")
			return filter ; IUIAutomationCondition
		}else if (aName="AutomationElementMode"){
			UIA_Error(DllCall(this.vt(10),"ptr",this.__,"int*",mode),"get_AutomationElementMode")
			return mode ; AutomationElementMode
		}
	}
	__set(aName,aValue){
		if (aName="TreeScope")
			return UIA_Error(DllCall(this.vt(7),"ptr",this.__,"int",aValue),"put_TreeScope")
		else if (aName="TreeFilter")
			return UIA_Error(DllCall(this.vt(9),"ptr",this.__,"ptr",aValue),"put_TreeFilter") 
		else if (aName="AutomationElementMode")
			return UIA_Error(DllCall(this.vt(11),"ptr",this.__,"int",aValue),"put_AutomationElementMode")
	}
	
	; Adds a property to the cache request.
	AddProperty(propertyId){
	if IsObject(propertyId)
		loop % propertyId.maxindex()
			UIA_Error(DllCall(this.vt(3),"ptr",this.__,"int",propertyId[A_Index]),"AddProperty")
	else return UIA_Error(DllCall(this.vt(3),"ptr",this.__,"int",propertyId),"AddProperty")
	}
	
	; Adds a control pattern to the cache request. Adding a control pattern that is already in the cache request has no effect.
	AddPattern(patternId){
	if IsObject(patternId)
		loop % patternId.maxindex()
			UIA_Error(DllCall(this.vt(4),"ptr",this.__,"int",patternId[A_Index]),"AddPattern")
	else return UIA_Error(DllCall(this.vt(4),"ptr",this.__,"int",patternId),"AddPattern")
	}
	
	; Creates a copy of the cache request.
	Clone(){
	UIA_Error(DllCall(this.vt(5),"ptr",this.__,"ptr*",clonedRequest),"Clone")
	return new IUIAutomationCacheRequest(clonedRequest) ; IUIAutomationCacheRequest
	}
	
	; TreeScope Specifies the scope of caching.
	; When an element is retrieved, caching can be performed for only the element itself (the default behavior), or for the element and its children or descendants. This property describes the scope of the request.
	
	; TreeFilter Specifies the view of the UI Automation element tree that is used when caching.

	; AutomationElementMode Indicates whether returned elements contain full references to the underlying UI, or only cached information. 
	; AutomationElementMode_Full is the default value, and specifies that returned elements contain a full reference to the underlying UI. AutomationElementMode_None specifies that the returned elements have no reference to the underlying UI, and contain only cached information.
	; Certain operations on elements, including GetCurrentPropertyValue, and SetFocus, require a full reference; attempting to perform these on an element that has none results in an error.
	; Using AutomationElementMode_None can be more efficient when only properties are needed, as it avoids the overhead involved in setting up full references.
}

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;IUIAutomationCondition;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

class IUIAutomationCondition extends IBase
{
}

class IUIAutomationBoolCondition extends IBase
{
	; Retrieves the value of the condition: either TRUE or FALSE.
	value(){
		UIA_Error(DllCall(this.vt(3),"ptr",this.__,"int*",boolVal),"get_BooleanValue")
		return boolVal
	}
}

class IUIAutomationPropertyCondition extends IBase
{
		
	; Retrieves the identifier of the property on which this condition is based.
	id(){
		UIA_Error(DllCall(this.vt(3),"ptr",this.__,"int*",propertyId),"get_PropertyId")
		return propertyId
	}
	
	; Retrieves the property value that must be matched for the condition to be true.
	value(){
		static _,propertyValue:=variant(_)
		UIA_Error(DllCall(this.vt(4),"ptr",this.__,"ptr",propertyValue),"get_PropertyValue")
		return GetVariantValue(propertyValue) ;
	}
	
	; Retrieves a set of flags that specify how the condition is applied.
	flags(){
		UIA_Error(DllCall(this.vt(5),"ptr",this.__,"int*",flags),"get_PropertyConditionFlags")
		return flags ; PropertyConditionFlags
	}
}

class IUIAutomationAndCondition extends IBase
{
	; Retrieves the number of conditions that make up this condition.
	count(){
		UIA_Error(DllCall(this.vt(3),"ptr",this.__,"int*",childCount),"get_ChildCount")
		return childCount
	}
	
	; Retrieves the conditions that make up this condition, as an ordinary array.
	ChildrenAsNativeArray(){
		UIA_Error(DllCall(this.vt(4),"ptr",this.__,"ptr*",childArray,"int*",childArrayCount),"GetChildrenAsNativeArray")
		return [childArray,childArrayCount]
	}
	
	; Retrieves the conditions that make up this condition.
	Children(){
		UIA_Error(DllCall(this.vt(5),"ptr",this.__,"ptr*",childArray),"GetChildren")
		return childArray ; SafeArray , iunknown
	}
}

class IUIAutomationOrCondition extends IBase
{
	; Retrieves the number of conditions that make up this condition.
	count(){
		UIA_Error(DllCall(this.vt(3),"ptr",this.__,"int*",childCount),"get_ChildCount")
		return childCount
	}
	
	; Retrieves the conditions that make up this condition, as an ordinary array.
	ChildrenAsNativeArray(){
		UIA_Error(DllCall(this.vt(4),"ptr",this.__,"ptr*",childArray,"int*",childArrayCount),"GetChildrenAsNativeArray")
		return [childArray,childArrayCount]
	}
	
	; Retrieves the conditions that make up this condition.
	Children(){
		UIA_Error(DllCall(this.vt(5),"ptr",this.__,"ptr*",childArray),"GetChildren")
		return childArray ; SafeArray , iunknown
	}
}

class IUIAutomationNotCondition extends IBase
{
	; Retrieves the condition of which this condition is the negative. The returned condition is the one that was used in creating this condition. 
	Child(){
		UIA_Error(DllCall(this.vt(3),"ptr",this.__,"ptr*",condition),"GetChild")
		return new IUIAutomationCondition(condition)
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;IUIAutomationTreeWalker;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

class IUIAutomationTreeWalker extends IBase
{
	; The structure of the Microsoft UI Automation tree changes as the visible UI elements on the desktop change.
	; An element can have additional child elements that do not match the current view condition and thus are not returned when navigating the element tree.

	; Retrieves the parent element of the specified UI Automation element.
	GetParentElement(element){
	UIA_Error(DllCall(this.vt(3),"ptr",this.__,"ptr",element.__,"ptr*",parent),"ParentElement")
	return new IUIAutomationElement(parent)
	}
	
	; Retrieves the first child element of the specified UI Automation element.
	GetFirstChildElement(element){
	UIA_Error(DllCall(this.vt(4),"ptr",this.__,"ptr",element.__,"ptr*",first),"FirstChildElement")
	return new IUIAutomationElement(first)
	}
	
	; Retrieves the last child element of the specified UI Automation element.
	GetLastChildElement(element){
	UIA_Error(DllCall(this.vt(5),"ptr",this.__,"ptr",element.__,"ptr*",last),"LastChildElement")
	return new IUIAutomationElement(last)
	}
	
	; Retrieves the next sibling element of the specified UI Automation element, and caches properties and control patterns.
	GetNextSiblingElement(element){
	UIA_Error(DllCall(this.vt(6),"ptr",this.__,"ptr",element.__,"ptr*",next),"NextSiblingElement")
	return new IUIAutomationElement(next)
	}
	
	; Retrieves the previous sibling element of the specified UI Automation element, and caches properties and control patterns.
	GetPreviousSiblingElement(element){
	UIA_Error(DllCall(this.vt(7),"ptr",this.__,"ptr",element.__,"ptr*",previous),"PreviousSiblingElement")
	return new IUIAutomationElement(previous)
	}
	
	; Retrieves the ancestor element nearest to the specified Microsoft UI Automation element in the tree view. 
	; The element is normalized by navigating up the ancestor chain in the tree until an element that satisfies the view condition (specified by a previous call to IUIAutomationTreeWalker::Condition) is reached. If the root element is reached, the root element is returned, even if it does not satisfy the view condition. 
	; This method is useful for applications that obtain references to UI Automation elements by hit-testing. The application might want to work only with specific types of elements, and can use IUIAutomationTreeWalker::Normalize to make sure that no matter what element is initially retrieved (for example, when a scroll bar gets the input focus), only the element of interest (such as a content element) is ultimately retrieved. 
	NormalizeElement(element){
	UIA_Error(DllCall(this.vt(8),"ptr",this.__,"ptr",element.__,"ptr*",normalized),"NormalizeElement")
	return normalized
	}
	
	; Retrieves the parent element of the specified UI Automation element, and caches properties and control patterns.
	GetParentElementBuildCache(element,cacheRequest){
	UIA_Error(DllCall(this.vt(9),"ptr",this.__,"ptr",element.__,"ptr",cacheRequest.__,"ptr*",parent),"ParentElementBuildCache")
	return new IUIAutomationElement(parent)
	}
	
	; Retrieves the first child element of the specified UI Automation element, and caches properties and control patterns.
	GetFirstChildElementBuildCache(element,cacheRequest){
	UIA_Error(DllCall(this.vt(10),"ptr",this.__,"ptr",element.__,"ptr",cacheRequest.__,"ptr*",first),"FirstChildElementBuildCache")
	return new IUIAutomationElement(first)
	}
	
	; Retrieves the last child element of the specified UI Automation element, and caches properties and control patterns.
	GetLastChildElementBuildCache(element,cacheRequest){
	UIA_Error(DllCall(this.vt(11),"ptr",this.__,"ptr",element.__,"ptr",cacheRequest.__,"ptr*",last),"LastChildElementBuildCache")
	return new IUIAutomationElement(last)
	}
	
	; Retrieves the next sibling element of the specified UI Automation element, and caches properties and control patterns.
	GetNextSiblingElementBuildCache(element,cacheRequest){
	UIA_Error(DllCall(this.vt(12),"ptr",this.__,"ptr",element.__,"ptr",cacheRequest.__,"ptr*",next),"NextSiblingElementBuildCache")
	return new IUIAutomationElement(next)
	}
	
	; Retrieves the previous sibling element of the specified UI Automation element, and caches properties and control patterns.
	GetPreviousSiblingElementBuildCache(element,cacheRequest){
	UIA_Error(DllCall(this.vt(13),"ptr",this.__,"ptr",element.__,"ptr",cacheRequest.__,"ptr*",previous),"PreviousSiblingElementBuildCache")
	return new IUIAutomationElement(previous)
	}
	
	; Retrieves the ancestor element nearest to the specified Microsoft UI Automation element in the tree view, prefetches the requested properties and control patterns, and stores the prefetched items in the cache.
	NormalizeElementBuildCache(element,cacheRequest){
	UIA_Error(DllCall(this.vt(14),"ptr",this.__,"ptr",element.__,"ptr",cacheRequest.__,"ptr*",normalized),"NormalizeElementBuildCache")
	return new IUIAutomationElement(normalized)
	}
	
	; Retrieves the condition that defines the view of the UI Automation tree. This property is read-only.
	; The condition that defines the view. This is the interface that was passed to CreateTreeWalker.
	Condition(){
	UIA_Error(DllCall(this.vt(15),"ptr",this.__,"ptr*",condition),"_Condition")
	return new IUIAutomationCondition(condition)
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;
;;IUIAutomationPattern;;
;;;;;;;;;;;;;;;;;;;;;;;;

class IUIAutomationInvokePattern extends IBase
{
	; Invokes the action of a control, such as a button click. 
	; Calls to this method should return immediately without blocking. However, this behavior depends on the implementation.
	Invoke(){
	return UIA_Error(DllCall(this.vt(3),"ptr",this.__),"Invoke")
	}

}
class IUIAutomationDockPattern extends IBase
{
	; Sets the dock position of this element.
	SetDockPosition(dockPos){ ; DockPosition
	return UIA_Error(DllCall(this.vt(3),"ptr",this.__,"int",dockPos),"SetDockPosition")
	}
	
	; Retrieves the dock position of this element within its docking container.
	CurrentDockPosition(){
	UIA_Error(DllCall(this.vt(4),"ptr",this.__,"int*",retVal),"CurrentDockPosition")
	return retVal ; DockPosition
	}
	
	; Retrieves the cached dock position of this element within its docking container.
	CachedDockPosition(){
	UIA_Error(DllCall(this.vt(5),"ptr",this.__,"int*",retVal),"CachedDockPosition")
	return retVal ; DockPosition
	}
}
class IUIAutomationExpandCollapsePattern extends IBase
{
	; This is a blocking method that returns after the element has been collapsed.
	; There are cases when a element that is marked as a leaf node might not know whether it has children until either the IUIAutomationExpandCollapsePattern::Collapse or the IUIAutomationExpandCollapsePattern::Expand method is called. This behavior is possible with a tree view control that does delayed loading of its child items. For example, Microsoft Windows Explorer might display the expand icon for a node even though there are currently no child items; when the icon is clicked, the control polls for child items, finds none, and removes the expand icon. In these cases clients should listen for a property-changed event on the IUIAutomationExpandCollapsePattern::CurrentExpandCollapseState property.

	; Displays all child nodes, controls, or content of the element. 
	Expand(){
	return UIA_Error(DllCall(this.vt(3),"ptr",this.__),"Expand")
	}
	
	; Hides all child nodes, controls, or content of the element.
	Collapse(){
	return UIA_Error(DllCall(this.vt(4),"ptr",this.__),"Collapse")
	}
	
	; Retrieves a value that indicates the state, expanded or collapsed, of the element.
	CurrentExpandCollapseState(){
	UIA_Error(DllCall(this.vt(5),"ptr",this.__,"int*",retVal),"CurrentExpandCollapseState")
	return retVal ; ExpandCollapseState
	}
	
	; Retrieves a cached value that indicates the state, expanded or collapsed, of the element.
	CachedExpandCollapseState(){
	UIA_Error(DllCall(this.vt(6),"ptr",this.__,"int*",retVal),"CachedExpandCollapseState")
	return retVal ; ExpandCollapseState
	}
}
class IUIAutomationGridPattern extends IBase
{
	; Retrieves a UI Automation element representing an item in the grid.
	GetItem(row,column){
	UIA_Error(DllCall(this.vt(3),"ptr",this.__,"int",row,"int",column,"ptr*",element),"GetItem")
	return new IUIAutomationGridItemPattern(element)
	}
		
	; Hidden rows and columns, depending on the provider implementation, may be loaded in the Microsoft UI Automation tree and will therefore be reflected in the row count and column count properties. If the hidden rows and columns have not yet been loaded they are not counted.
	
	; Retrieves the number of rows in the grid.
	CurrentRowCount(){
	UIA_Error(DllCall(this.vt(4),"ptr",this.__,"int*",retVal),"CurrentRowCount")
	return retVal
	}
	
	; The number of columns in the grid.
	CurrentColumnCount(){
	UIA_Error(DllCall(this.vt(5),"ptr",this.__,"int*",retVal),"CurrentColumnCount")
	return retVal
	}
	
	; Retrieves the cached number of rows in the grid.
	CachedRowCount(){
	UIA_Error(DllCall(this.vt(6),"ptr",this.__,"int*",retVal),"CachedRowCount")
	return retVal
	}
	
	; Retrieves the cached number of columns in the grid.
	CachedColumnCount(){
	UIA_Error(DllCall(this.vt(7),"ptr",this.__,"int*",retVal),"CachedColumnCount")
	return retVal
	}
}
class IUIAutomationGridItemPattern extends IBase
{
	; Retrieves the element that contains the grid item. 
	CurrentContainingGrid(){
	UIA_Error(DllCall(this.vt(3),"ptr",this.__,"ptr*",retVal),"CurrentContainingGrid")
	return retVal
	}
	
	; Retrieves the zero-based index of the row that contains the grid item.
	CurrentRow(){
	UIA_Error(DllCall(this.vt(4),"ptr",this.__,"int*",retVal),"CurrentRow")
	return retVal
	}
	
	; Retrieves the zero-based index of the column that contains the item.
	CurrentColumn(){
	UIA_Error(DllCall(this.vt(5),"ptr",this.__,"int*",retVal),"CurrentColumn")
	return retVal
	}
	
	; Retrieves the number of rows spanned by the grid item. 
	CurrentRowSpan(){
	UIA_Error(DllCall(this.vt(6),"ptr",this.__,"int*",retVal),"CurrentRowSpan")
	return retVal
	}
	
	; Retrieves the number of columns spanned by the grid item.
	CurrentColumnSpan(){
	UIA_Error(DllCall(this.vt(7),"ptr",this.__,"int*",retVal),"CurrentColumnSpan")
	return retVal
	}
	
	; Retrieves the cached element that contains the grid item. 
	CachedContainingGrid(){
	UIA_Error(DllCall(this.vt(8),"ptr",this.__,"ptr*",retVal),"CachedContainingGrid")
	return retVal
	}
	
	; Retrieves the cached zero-based index of the row that contains the item. 
	CachedRow(){
	UIA_Error(DllCall(this.vt(9),"ptr",this.__,"int*",retVal),"CachedRow")
	return retVal
	}
	
	; Retrieves the cached zero-based index of the column that contains the grid item.
	CachedColumn(){
	UIA_Error(DllCall(this.vt(10),"ptr",this.__,"int*",retVal),"CachedColumn")
	return retVal
	}
	
	; Retrieves the cached number of rows spanned by a grid item. 
	CachedRowSpan(){
	UIA_Error(DllCall(this.vt(11),"ptr",this.__,"int*",retVal),"CachedRowSpan")
	return retVal
	}
	
	; Retrieves the cached number of columns spanned by the grid item.
	CachedColumnSpan(){
	UIA_Error(DllCall(this.vt(12),"ptr",this.__,"int*",retVal),"CachedColumnSpan")
	return retVal
	}
}
class IUIAutomationMultipleViewPattern extends IBase
{
	; Retrieves the name of a control-specific view.
	GetViewName(view){
	UIA_Error(DllCall(this.vt(3),"ptr",this.__,"int",view,"ptr*",name),"GetViewName")
	return StrGet(name,"utf-16")
	}
	
	; Sets the view of the control.
	SetCurrentView(view){
	return UIA_Error(DllCall(this.vt(4),"ptr",this.__,"int",view),"SetCurrentView")
	}
	
	; Retrieves the control-specific identifier of the current view of the control.
	CurrentCurrentView(){
	UIA_Error(DllCall(this.vt(5),"ptr",this.__,"int*",retVal),"CurrentCurrentView")
	return retVal
	}
	
	; Retrieves a collection of control-specific view identifiers.
	GetCurrentSupportedViews(){
	UIA_Error(DllCall(this.vt(6),"ptr",this.__,"ptr*",retVal),"GetCurrentSupportedViews")
	return GetSafeArrayValue(retVal,3)
	}
	
	; Retrieves the cached control-specific identifier of the current view of the control.
	CachedCurrentView(){
	UIA_Error(DllCall(this.vt(7),"ptr",this.__,"int*",retVal),"CachedCurrentView")
	return retVal
	}
	
	; Retrieves a collection of control-specific view identifiers from the cache.
	GetCachedSupportedViews(){
	UIA_Error(DllCall(this.vt(8),"ptr",this.__,"ptr*",retVal),"GetCachedSupportedViews")
	return GetSafeArrayValue(retVal,3)
	}
}
class IUIAutomationRangeValuePattern extends IBase
{
	; Sets the value of the control.
	SetValue(val){
	return UIA_Error(DllCall(this.vt(3),"ptr",this.__,"double",val),"SetValue")
	}
	
	; Retrieves the value of the control.
	CurrentValue(){
	UIA_Error(DllCall(this.vt(4),"ptr",this.__,"double*",retVal),"CurrentValue")
	return retVal
	}
	
	; Indicates whether the value of the element can be changed.
	CurrentIsReadOnly(){
	UIA_Error(DllCall(this.vt(5),"ptr",this.__,"int*",retVal),"CurrentIsReadOnly")
	return retVal
	}
	
	; Retrieves the maximum value of the control.
	CurrentMaximum(){
	UIA_Error(DllCall(this.vt(6),"ptr",this.__,"double*",retVal),"CurrentMaximum")
	return retVal
	}
	
	; Retrieves the minimum value of the control.
	CurrentMinimum(){
	UIA_Error(DllCall(this.vt(7),"ptr",this.__,"double*",retVal),"CurrentMinimum")
	return retVal
	}
	
	; The LargeChange and SmallChange property can support a Not a Number (NaN) value. When retrieving this property, a client can use the _isnan function to determine whether the property is a NaN value. 

	; Retrieves the value that is added to or subtracted from the value of the control when a large change is made, such as when the PAGE DOWN key is pressed.
	CurrentLargeChange(){
	UIA_Error(DllCall(this.vt(8),"ptr",this.__,"double*",retVal),"CurrentLargeChange")
	return retVal
	}
	
	; Retrieves the value that is added to or subtracted from the value of the control when a small change is made, such as when an arrow key is pressed.
	CurrentSmallChange(){
	UIA_Error(DllCall(this.vt(9),"ptr",this.__,"double*",retVal),"CurrentSmallChange")
	return retVal
	}
	
	; Retrieves the cached value of the control.
	CachedValue(){
	UIA_Error(DllCall(this.vt(10),"ptr",this.__,"double*",retVal),"CachedValue")
	return retVal
	}
	
	; Retrieves a cached value that indicates whether the value of the element can be changed.
	CachedIsReadOnly(){
	UIA_Error(DllCall(this.vt(11),"ptr",this.__,"int*",retVal),"CachedIsReadOnly")
	return retVal
	}
	
	; Retrieves the cached maximum value of the control.
	CachedMaximum(){
	UIA_Error(DllCall(this.vt(12),"ptr",this.__,"double*",retVal),"CachedMaximum")
	return retVal
	}
	
	; Retrieves the cached minimum value of the control.
	CachedMinimum(){
	UIA_Error(DllCall(this.vt(13),"ptr",this.__,"double*",retVal),"CachedMinimum")
	return retVal
	}
	
	; Retrieves, from the cache, the value that is added to or subtracted from the value of the control when a large change is made, such as when the PAGE DOWN key is pressed.
	CachedLargeChange(){
	UIA_Error(DllCall(this.vt(14),"ptr",this.__,"double*",retVal),"CachedLargeChange")
	return retVal
	}
	
	; Retrieves, from the cache, the value that is added to or subtracted from the value of the control when a small change is made, such as when an arrow key is pressed.
	CachedSmallChange(){
	UIA_Error(DllCall(this.vt(15),"ptr",this.__,"double*",retVal),"CachedSmallChange")
	return retVal
	}
}
class IUIAutomationScrollPattern extends IBase
{
	; Scrolls the visible region of the content area horizontally and vertically.
	Scroll(horizontalAmount,verticalAmount){
	return UIA_Error(DllCall(this.vt(3),"ptr",this.__,"int",horizontalAmount,"int",verticalAmount),"Scroll")
	}
	
	; Sets the horizontal and vertical scroll positions as a percentage of the total content area within the UI Automation element.
	; This method is useful only when the content area of the control is larger than the visible region.
	SetScrollPercent(horizontalPercent,verticalPercent){
	return UIA_Error(DllCall(this.vt(4),"ptr",this.__,"double",horizontalPercent,"double",verticalPercent),"SetScrollPercent")
	}
	
	; Retrieves the horizontal scroll position.
	CurrentHorizontalScrollPercent(){
	UIA_Error(DllCall(this.vt(5),"ptr",this.__,"double*",retVal),"CurrentHorizontalScrollPercent")
	return retVal
	}
	
	; Retrieves the vertical scroll position.
	CurrentVerticalScrollPercent(){
	UIA_Error(DllCall(this.vt(6),"ptr",this.__,"double*",retVal),"CurrentVerticalScrollPercent")
	return retVal
	}
	
	; Retrieves the horizontal size of the viewable region of a scrollable element.
	CurrentHorizontalViewSize(){
	UIA_Error(DllCall(this.vt(7),"ptr",this.__,"double*",retVal),"CurrentHorizontalViewSize")
	return retVal
	}
	
	; Retrieves the vertical size of the viewable region of a scrollable element.
	CurrentVerticalViewSize(){
	UIA_Error(DllCall(this.vt(8),"ptr",this.__,"double*",retVal),"CurrentVerticalViewSize")
	return retVal
	}
	
	; Indicates whether the element can scroll horizontally.
	; This property can be dynamic. For example, the content area of the element might not be larger than the current viewable area, meaning that the property is FALSE. However, resizing the element or adding child items can increase the bounds of the content area beyond the viewable area, making the property TRUE.
	CurrentHorizontallyScrollable(){
	UIA_Error(DllCall(this.vt(9),"ptr",this.__,"int*",retVal),"CurrentHorizontallyScrollable")
	return retVal
	}
	
	; Indicates whether the element can scroll vertically.
	CurrentVerticallyScrollable(){
	UIA_Error(DllCall(this.vt(10),"ptr",this.__,"int*",retVal),"CurrentVerticallyScrollable")
	return retVal
	}
	
	; Retrieves the cached horizontal scroll position.
	CachedHorizontalScrollPercent(){
	UIA_Error(DllCall(this.vt(11),"ptr",this.__,"double*",retVal),"CachedHorizontalScrollPercent")
	return retVal
	}
	
	; Retrieves the cached vertical scroll position.
	CachedVerticalScrollPercent(){
	UIA_Error(DllCall(this.vt(12),"ptr",this.__,"double*",retVal),"CachedVerticalScrollPercent")
	return retVal
	}
	
	; Retrieves the cached horizontal size of the viewable region of a scrollable element.
	CachedHorizontalViewSize(){
	UIA_Error(DllCall(this.vt(13),"ptr",this.__,"double*",retVal),"CachedHorizontalViewSize")
	return retVal
	}
	
	; Retrieves the cached vertical size of the viewable region of a scrollable element.
	CachedVerticalViewSize(){
	UIA_Error(DllCall(this.vt(14),"ptr",this.__,"double*",retVal),"CachedVerticalViewSize")
	return retVal
	}
	
	; Retrieves a cached value that indicates whether the element can scroll horizontally.
	CachedHorizontallyScrollable(){
	UIA_Error(DllCall(this.vt(15),"ptr",this.__,"int*",retVal),"CachedHorizontallyScrollable")
	return retVal
	}
	
	; Retrieves a cached value that indicates whether the element can scroll vertically.
	CachedVerticallyScrollable(){
	UIA_Error(DllCall(this.vt(16),"ptr",this.__,"int*",retVal),"CachedVerticallyScrollable")
	return retVal
	}
}
class IUIAutomationScrollItemPattern extends IBase
{
	; Scrolls the content area of a container object to display the UI Automation element within the visible region (viewport) of the container.
	; This method does not provide the ability to specify the position of the element within the viewport.
	ScrollIntoView(){
	return UIA_Error(DllCall(this.vt(3),"ptr",this.__),"ScrollIntoView")
	}
}
class IUIAutomationSelectionPattern extends IBase
{
	; Retrieves the selected elements in the container.
	GetCurrentSelection(){
	UIA_Error(DllCall(this.vt(3),"ptr",this.__,"ptr*",retVal),"GetCurrentSelection")
	return retVal
	}
	
	; Indicates whether more than one item in the container can be selected at one time.
	CurrentCanSelectMultiple(){
	UIA_Error(DllCall(this.vt(4),"ptr",this.__,"int*",retVal),"CurrentCanSelectMultiple")
	return retVal
	}
	
	; Indicates whether at least one item must be selected at all times.
	CurrentIsSelectionRequired(){
	UIA_Error(DllCall(this.vt(5),"ptr",this.__,"int*",retVal),"CurrentIsSelectionRequired")
	return retVal
	}
	
	; Retrieves the cached selected elements in the container.
	GetCachedSelection(){
	UIA_Error(DllCall(this.vt(6),"ptr",this.__,"ptr*",retVal),"GetCachedSelection")
	return retVal
	}
	
	; Retrieves a cached value that indicates whether more than one item in the container can be selected at one time.
	CachedCanSelectMultiple(){
	UIA_Error(DllCall(this.vt(7),"ptr",this.__,"int*",retVal),"CachedCanSelectMultiple")
	return retVal
	}
	
	; Retrieves a cached value that indicates whether at least one item must be selected at all times.
	CachedIsSelectionRequired(){
	UIA_Error(DllCall(this.vt(8),"ptr",this.__,"int*",retVal),"CachedIsSelectionRequired")
	return retVal
	}
}
class IUIAutomationSelectionItemPattern extends IBase
{
	; Clears any selected items and then selects the current element.
	Select(){
	return UIA_Error(DllCall(this.vt(3),"ptr",this.__),"Select")
	}
	
	; Adds the current element to the collection of selected items.
	AddToSelection(){
	return UIA_Error(DllCall(this.vt(4),"ptr",this.__),"AddToSelection")
	}
	
	; Removes this element from the selection. 
	; An error code is returned if this element is the only one in the selection and the selection container requires at least one element to be selected. 
	RemoveFromSelection(){
	return UIA_Error(DllCall(this.vt(5),"ptr",this.__),"RemoveFromSelection")
	}
	
	; Indicates whether this item is selected.
	CurrentIsSelected(){
	UIA_Error(DllCall(this.vt(6),"ptr",this.__,"int*",retVal),"CurrentIsSelected")
	return retVal
	}
	
	; Retrieves the element that supports IUIAutomationSelectionPattern and acts as the container for this item. 
	CurrentSelectionContainer(){
	UIA_Error(DllCall(this.vt(7),"ptr",this.__,"ptr*",retVal),"CurrentSelectionContainer")
	return retVal
	}
	
	; A cached value that indicates whether this item is selected.
	CachedIsSelected(){
	UIA_Error(DllCall(this.vt(8),"ptr",this.__,"int*",retVal),"CachedIsSelected")
	return retVal
	}
	
	; Retrieves the cached element that supports IUIAutomationSelectionPattern and acts as the container for this item.
	CachedSelectionContainer(){
	UIA_Error(DllCall(this.vt(9),"ptr",this.__,"ptr*",retVal),"CachedSelectionContainer")
	return retVal
	}
}
class IUIAutomationSynchronizedInputPattern extends IBase
{
	; Causes the Microsoft UI Automation provider to start listening for mouse or keyboard input.
	; When matching input is found, the provider checks whether the target element matches the current element. If they match, the provider raises the UIA_InputReachedTargetEventId event; otherwise it raises the UIA_InputReachedOtherElementEventId or UIA_InputDiscardedEventId event.
	; After receiving input of the specified type, the provider stops checking for input and continues as normal.
	; If the provider is already listening for input, this method returns E_INVALIDOPERATION.
	StartListening(inputType){ ; SynchronizedInputType
	return UIA_Error(DllCall(this.vt(3),"ptr",this.__,"int",inputType),"StartListening")
	}
	
	; Causes the Microsoft UI Automation provider to stop listening for mouse or keyboard input.
	Cancel(){
	return UIA_Error(DllCall(this.vt(4),"ptr",this.__),"Cancel")
	}
}
class IUIAutomationTablePattern extends IBase
{
	; Retrieves a collection of UI Automation elements representing all the row headers in a table.
	GetCurrentRowHeaders(){
	UIA_Error(DllCall(this.vt(3),"ptr",this.__,"ptr*",retVal),"GetCurrentRowHeaders")
	return new IUIAutomationElementArray(retVal) 
	}
	
	; Retrieves a collection of UI Automation elements representing all the column headers in a table.
	GetCurrentColumnHeaders(){
	UIA_Error(DllCall(this.vt(4),"ptr",this.__,"ptr*",retVal),"GetCurrentColumnHeaders")
	return new IUIAutomationElementArray(retVal) 
	}
	
	; Retrieves the primary direction of traversal for the table.
	CurrentRowOrColumnMajor(){
	UIA_Error(DllCall(this.vt(5),"ptr",this.__,"int*",retVal),"CurrentRowOrColumnMajor")
	return retVal ;RowOrColumnMajor
	}
	
	; Retrieves a cached collection of UI Automation elements representing all the row headers in a table.
	GetCachedRowHeaders(){
	UIA_Error(DllCall(this.vt(6),"ptr",this.__,"ptr*",retVal),"GetCachedRowHeaders")
	return new IUIAutomationElementArray(retVal) 
	}
	
	; Retrieves a cached collection of UI Automation elements representing all the column headers in a table.
	GetCachedColumnHeaders(){
	UIA_Error(DllCall(this.vt(7),"ptr",this.__,"ptr*",retVal),"GetCachedColumnHeaders")
	return new IUIAutomationElementArray(retVal) 
	}
	
	; Retrieves the cached primary direction of traversal for the table.
	CachedRowOrColumnMajor(){
	UIA_Error(DllCall(this.vt(8),"ptr",this.__,"int*",retVal),"CachedRowOrColumnMajor")
	return retVal ; RowOrColumnMajor
	}
}
class IUIAutomationTableItemPattern extends IBase
{
	; Retrieves the row headers associated with a table item or cell.
	GetCurrentRowHeaderItems(){
	UIA_Error(DllCall(this.vt(3),"ptr",this.__,"ptr*",retVal),"GetCurrentRowHeaderItems")
	return new IUIAutomationElementArray(retVal)
	}
	
	; Retrieves the column headers associated with a table item or cell.
	GetCurrentColumnHeaderItems(){
	UIA_Error(DllCall(this.vt(4),"ptr",this.__,"ptr*",retVal),"GetCurrentColumnHeaderItems")
	return new IUIAutomationElementArray(retVal)
	}
	
	; Retrieves the cached row headers associated with a table item or cell.
	GetCachedRowHeaderItems(){
	UIA_Error(DllCall(this.vt(5),"ptr",this.__,"ptr*",retVal),"GetCachedRowHeaderItems")
	return new IUIAutomationElementArray(retVal)
	}
	
	; Retrieves the cached column headers associated with a table item or cell.
	GetCachedColumnHeaderItems(){
	UIA_Error(DllCall(this.vt(6),"ptr",this.__,"ptr*",retVal),"GetCachedColumnHeaderItems")
	return new IUIAutomationElementArray(retVal)
	}
}
class IUIAutomationTogglePattern extends IBase
{
	; Cycles through the toggle states of the control.
	; A control cycles through its states in this order: ToggleState_On, ToggleState_Off and, if supported, ToggleState_Indeterminate.
	Toggle(){
	return UIA_Error(DllCall(this.vt(3),"ptr",this.__),"Toggle")
	}
	
	; Retrieves the state of the control.
	CurrentToggleState(){
	UIA_Error(DllCall(this.vt(4),"ptr",this.__,"int*",retVal),"CurrentToggleState")
	return retVal ; ToggleState
	}
	
	; Retrieves the cached state of the control.
	CachedToggleState(){
	UIA_Error(DllCall(this.vt(5),"ptr",this.__,"int*",retVal),"CachedToggleState")
	return retVal ; ToggleState
	}
}
class IUIAutomationTransformPattern extends IBase
{
	; An element cannot be moved, resized or rotated such that its resulting screen location would be completely outside the coordinates of its container and inaccessible to the keyboard or mouse. For example, when a top-level window is moved completely off-screen or a child object is moved outside the boundaries of the container's viewport, the object is placed as close to the requested screen coordinates as possible with the top or left coordinates overridden to be within the container boundaries.
	
	; Moves the UI Automation element.
	Move(x,y){
	return UIA_Error(DllCall(this.vt(3),"ptr",this.__,"double",x,"double",y),"Move")
	}
	
	; Resizes the UI Automation element.
	; When called on a control that supports split panes, this method can have the side effect of resizing other contiguous panes. 
	Resize(width,height){
	return UIA_Error(DllCall(this.vt(4),"ptr",this.__,"double",width,"double",height),"Resize")
	}
	
	; Rotates the UI Automation element.
	Rotate(degrees){
	return UIA_Error(DllCall(this.vt(5),"ptr",this.__,"double",degrees),"Rotate")
	}
	
	; Indicates whether the element can be moved.
	CurrentCanMove(){
	UIA_Error(DllCall(this.vt(6),"ptr",this.__,"int*",retVal),"CurrentCanMove")
	return retVal
	}
	
	; Indicates whether the element can be resized.
	CurrentCanResize(){
	UIA_Error(DllCall(this.vt(7),"ptr",this.__,"int*",retVal),"CurrentCanResize")
	return retVal
	}
	
	; Indicates whether the element can be rotated.
	CurrentCanRotate(){
	UIA_Error(DllCall(this.vt(8),"ptr",this.__,"int*",retVal),"CurrentCanRotate")
	return retVal
	}
	
	; Retrieves a cached value that indicates whether the element can be moved.
	CachedCanMove(){
	UIA_Error(DllCall(this.vt(9),"ptr",this.__,"int*",retVal),"CachedCanMove")
	return retVal
	}
	
	; Retrieves a cached value that indicates whether the element can be resized.
	CachedCanResize(){
	UIA_Error(DllCall(this.vt(10),"ptr",this.__,"int*",retVal),"CachedCanResize")
	return retVal
	}
	
	; Retrieves a cached value that indicates whether the element can be rotated.
	CachedCanRotate(){
	UIA_Error(DllCall(this.vt(11),"ptr",this.__,"int*",retVal),"CachedCanRotate")
	return retVal
	}
}
class IUIAutomationValuePattern extends IBase
{
	; Sets the value of the element.
	; The CurrentIsEnabled property must be TRUE, and the IUIAutomationValuePattern::CurrentIsReadOnly property must be FALSE. 
	SetValue(val){
	UIA_Error(DllCall(this.vt(3),"ptr",this.__,"str",val),"SetValue")
	return 
	}
	
	; Retrieves the value of the element.
	; Single-line edit controls support programmatic access to their contents through IUIAutomationValuePattern. However, multiline edit controls do not support this control pattern, and their contents must be retrieved by using IUIAutomationTextPattern.
	; This property does not support the retrieval of formatting information or substring values. IUIAutomationTextPattern must be used in these scenarios as well.
	CurrentValue(){
	UIA_Error(DllCall(this.vt(4),"ptr",this.__,"ptr*",retVal),"CurrentValue")
	return StrGet(retVal,"utf-16")
	}
	
	; Indicates whether the value of the element is read-only.
	CurrentIsReadOnly(){
	UIA_Error(DllCall(this.vt(5),"ptr",this.__,"int*",retVal),"CurrentIsReadOnly")
	return retVal
	}
	
	; Retrieves the cached value of the element.
	CachedValue(){
	UIA_Error(DllCall(this.vt(6),"ptr",this.__,"ptr*",retVal),"CachedValue")
	return StrGet(retVal,"utf-16")
	}
	
	; Retrieves a cached value that indicates whether the value of the element is read-only.
	; This property must be TRUE for IUIAutomationValuePattern::SetValue to succeed.
	CachedIsReadOnly(){
	UIA_Error(DllCall(this.vt(7),"ptr",this.__,"int*",retVal),"CachedIsReadOnly")
	return retVal
	}
}
class IUIAutomationWindowPattern extends IBase
{
	; Closes the window.
	; When called on a split pane control, this method closes the pane and removes the associated split. This method may also close all other panes, depending on implementation.
	Close(){
	return UIA_Error(DllCall(this.vt(3),"ptr",this.__),"Close")
	}
	
	; Causes the calling code to block for the specified time or until the associated process enters an idle state, whichever completes first. 
	WaitForInputIdle(milliseconds){
	UIA_Error(DllCall(this.vt(4),"ptr",this.__,"int",milliseconds,"int*",success),"WaitForInputIdle")
	return success
	}
	
	; Minimizes, maximizes, or restores the window.
	SetWindowVisualState(state){
	UIA_Error(DllCall(this.vt(5),"ptr",this.__,"int",state),"SetWindowVisualState")
	return 
	}
	
	; Indicates whether the window can be maximized.
	CurrentCanMaximize(){
	UIA_Error(DllCall(this.vt(6),"ptr",this.__,"int*",retVal),"CurrentCanMaximize")
	return retVal
	}
	
	; Indicates whether the window can be minimized.
	CurrentCanMinimize(){
	UIA_Error(DllCall(this.vt(7),"ptr",this.__,"int*",retVal),"CurrentCanMinimize")
	return retVal
	}
	
	; Indicates whether the window is modal.
	CurrentIsModal(){
	UIA_Error(DllCall(this.vt(8),"ptr",this.__,"int*",retVal),"CurrentIsModal")
	return retVal
	}
	
	; Indicates whether the window is the topmost element in the z-order.
	CurrentIsTopmost(){
	UIA_Error(DllCall(this.vt(9),"ptr",this.__,"int*",retVal),"CurrentIsTopmost")
	return retVal
	}
	
	; Retrieves the visual state of the window; that is, whether it is in the normal, maximized, or minimized state.
	CurrentWindowVisualState(){
	UIA_Error(DllCall(this.vt(10),"ptr",this.__,"int*",retVal),"CurrentWindowVisualState")
	return retVal ; WindowVisualState
	}
	
	; Retrieves the current state of the window for the purposes of user interaction.
	CurrentWindowInteractionState(){
	UIA_Error(DllCall(this.vt(11),"ptr",this.__,"int*",retVal),"CurrentWindowInteractionState")
	return retVal ; WindowInteractionState
	}
	
	; Retrieves a cached value that indicates whether the window can be maximized.
	CachedCanMaximize(){
	UIA_Error(DllCall(this.vt(12),"ptr",this.__,"int*",retVal),"CachedCanMaximize")
	return retVal
	}
	
	; Retrieves a cached value that indicates whether the window can be minimized.
	CachedCanMinimize(){
	UIA_Error(DllCall(this.vt(13),"ptr",this.__,"int*",retVal),"CachedCanMinimize")
	return retVal
	}
	
	; Retrieves a cached value that indicates whether the window is modal.
	CachedIsModal(){
	UIA_Error(DllCall(this.vt(14),"ptr",this.__,"int*",retVal),"CachedIsModal")
	return retVal
	}
	
	; Retrieves a cached value that indicates whether the window is the topmost element in the z-order.
	CachedIsTopmost(){
	UIA_Error(DllCall(this.vt(15),"ptr",this.__,"int*",retVal),"CachedIsTopmost")
	return retVal
	}
	
	; Retrieves a cached value that indicates the visual state of the window; that is, whether it is in the normal, maximized, or minimized state.
	CachedWindowVisualState(){
	UIA_Error(DllCall(this.vt(16),"ptr",this.__,"int*",retVal),"CachedWindowVisualState")
	return retVal ; WindowVisualState
	}
	
	; Retrieves a cached value that indicates the current state of the window for the purposes of user interaction.
	CachedWindowInteractionState(){
	UIA_Error(DllCall(this.vt(17),"ptr",this.__,"int*",retVal),"CachedWindowInteractionState")
	return retVal ; WindowInteractionState
	}
}
class IUIAutomationTextRangePattern extends IBase
{
	; Retrieves a new IUIAutomationTextRange identical to the original and inheriting all properties of the original.
	; The new range can be manipulated independently of the original.
	Clone(){
	UIA_Error(DllCall(this.vt(3),"ptr",this.__,"ptr*",clonedRange),"Clone")
	return new IUIAutomationTextRange(clonedRange) 
	}
	
	; Retrieves a value that specifies whether this text range has the same endpoints as another text range.
	; This method compares the endpoints of the two text ranges, not the text in the ranges. The ranges are identical if they share the same endpoints. If two text ranges have different endpoints, they are not identical even if the text in both ranges is exactly the same. 
	Compare(range){
	UIA_Error(DllCall(this.vt(4),"ptr",this.__,"ptr",range,"int*",areSame),"Compare")
	return areSame
	}
	
	; Retrieves a value that specifies whether the start or end endpoint of this text range is the same as the start or end endpoint of another text range.
	CompareEndpoints(srcEndPoint,range,targetEndPoint){
	UIA_Error(DllCall(this.vt(5),"ptr",this.__,"int",srcEndPoint,"ptr",range,"int",targetEndPoint,"int*",compValue),"CompareEndpoints") ; TextPatternRangeEndpoint
	return compValue
	}
	
	; Normalizes the text range by the specified text unit. The range is expanded if it is smaller than the specified unit, or shortened if it is longer than the specified unit.
	; Client applications such as screen readers use this method to retrieve the full word, sentence, or paragraph that exists at the insertion point or caret position.
	; Despite its name, the ExpandToEnclosingUnit method does not necessarily expand a text range. Instead, it "normalizes" a text range by moving the endpoints so that the range encompasses the specified text unit. The range is expanded if it is smaller than the specified unit, or shortened if it is longer than the specified unit. If the range is already an exact quantity of the specified units, it remains unchanged. The following diagram shows how ExpandToEnclosingUnit normalizes a text range by moving the endpoints of the range. 
	; ExpandToEnclosingUnit defaults to the next largest text unit supported if the specified text unit is not supported by the control. The order, from smallest unit to largest, is as follows: Character Format Word Line Paragraph Page Document
	; ExpandToEnclosingUnit respects both visible and hidden text. 
	ExpandToEnclosingUnit(textUnit){ ; textUnit
	return UIA_Error(DllCall(this.vt(6),"ptr",this.__,"int",textUnit),"ExpandToEnclosingUnit") ; textUnit
	}
	
	; Retrieves a text range subset that has the specified text attribute value.
	; The FindAttribute method retrieves matching text regardless of whether the text is hidden or visible. Use UIA_IsHiddenAttributeId to check text visibility.
	FindAttribute(attr,val,backward){
	UIA_Error(DllCall(this.vt(7),"ptr",this.__,"int",attr,"ptr",variant(v,UIA_AttributeVariantType(attr),val),"int",backward,"ptr*",found),"FindAttribute")
	return new IUIAutomationTextRange(found) 
	}
	
	; Retrieves a text range subset that contains the specified text. There is no differentiation between hidden and visible text. 
	FindText(text,backward,ignoreCase){
	UIA_Error(DllCall(this.vt(8),"ptr",this.__,"str",text,"int",backward,"int",ignoreCase,"ptr*",found),"FindText")
	return new IUIAutomationTextRange(found)
	}
	
	; Retrieves the value of the specified text attribute across the entire text range.
	; The type of value retrieved by this method depends on the attr parameter. For example, calling GetAttributeValue with the attr parameter set to UIA_FontNameAttributeId returns a string that represents the font name of the text range, while calling GetAttributeValue with attr set to UIA_IsItalicAttributeId would return a boolean. 
	; If the attribute specified by attr is not supported, the value parameter receives a value that is equivalent to the IUIAutomation::ReservedNotSupportedValue property. 
	; A text range can include more than one value for a particular attribute. For example, if a text range includes more than one font, the FontName attribute will have multiple values. An attribute with more than one value is called a mixed attribute. You can determine if a particular attribute is a mixed attribute by comparing the value retrieved from GetAttributeValue with the UIAutomation::ReservedMixedAttributeValue property.
	; The GetAttributeValue method retrieves the attribute value regardless of whether the text is hidden or visible. Use UIA_ IsHiddenAttributeId to check text visibility.
	GetAttributeValue(attr,value){
	UIA_Error(DllCall(this.vt(9),"ptr",this.__,"int",attr,"ptr",variant(value)),"GetAttributeValue") ; Text Attribute
	return GetVariantValue(value)
	}
	
	; Retrieves a collection of bounding rectangles for each fully or partially visible line of text in a text range.
	GetBoundingRectangles(){
	UIA_Error(DllCall(this.vt(10),"ptr",this.__,"ptr*",boundingRects),"GetBoundingRectangles")
	return GetSafeArrayValue(boundingRects,5)
	}
	
	; Returns the innermost UI Automation element that encloses the text range.
	GetEnclosingElement(){
	UIA_Error(DllCall(this.vt(11),"ptr",this.__,"ptr*",enclosingElement),"GetEnclosingElement")
	return new IUIAutomationElement(enclosingElement)
	}
	
	; Returns the plain text of the text range.
	GetText(maxLength=-1){
	UIA_Error(DllCall(this.vt(12),"ptr",this.__,"int",maxLength,"ptr*",text),"GetText")
	return StrGet(text,"utf-16")
	}
	
	; Moves the text range forward or backward by the specified number of text units .
	/*
	IUIAutomationTextRange::Move moves the text range to span a different part of the text; it does not alter the text in any way.
	For a non-degenerate (non-empty) text range, IUIAutomationTextRange::Move normalizes and moves the range by performing the following steps.
		The text range is collapsed to a degenerate (empty) range at the starting endpoint.
		If necessary, the resulting text range is moved backward in the document to the beginning of the requested text unit boundary.
		The text range is moved forward or backward in the document by the requested number of text unit boundaries.
		The text range is expanded from the degenerate state by moving the ending endpoint forward by one requested text unit boundary.
	If any of the preceding steps fail, the text range is left unchanged. If the text range cannot be moved as far as the requested number of text units, but can be moved by a smaller number of text units, the text range is moved by the smaller number of text units and moved is set to the number of text units moved.
	For a degenerate text range, IUIAutomationTextRange::Move simply moves the text insertion point by the specified number of text units.
	When moving a text range, IUIAutomationTextRange::Move ignores the boundaries of any embedded objects in the text.
	IUIAutomationTextRange::Move respects both hidden and visible text.
	If a text-based control does not support the text unit specified by the unit parameter, IUIAutomationTextRange::Move substitutes the next larger supported text unit. The size of the text units, from smallest unit to largest, is as follows.
		Character
		Format
		Word
		Line
		Paragraph
		Page
		Document
	*/
	Move(unit,count){ ; TextUnit
	UIA_Error(DllCall(this.vt(13),"ptr",this.__,"int",unit,"int",count,"int*",moved),"Move") ; TextUnit
	return moved
	}
	
	; Moves one endpoint of the text range the specified number of text units within the document range.
	MoveEndpointByUnit(endpoint,unit,count){ ; TextPatternRangeEndpoint , TextUnit
	UIA_Error(DllCall(this.vt(14),"ptr",this.__,"int",endpoint,"int",unit,"int",count,"int*",moved),"MoveEndpointByUnit") ; TextPatternRangeEndpoint,TextUnit
	return moved
	}
	
	; Moves one endpoint of the current text range to the specified endpoint of a second text range.
	; If the endpoint being moved crosses the other endpoint of the same text range, that other endpoint is moved also, resulting in a degenerate (empty) range and ensuring the correct ordering of the endpoints (that is, the start is always less than or equal to the end).
	MoveEndpointByRange(srcEndPoint,range,targetEndPoint){ ; TextPatternRangeEndpoint , IUIAutomationTextRange , TextPatternRangeEndpoint
	return UIA_Error(DllCall(this.vt(15),"ptr",this.__,"int",srcEndPoint,"ptr",range,"int",targetEndPoint),"MoveEndpointByRange")
	}
	
	; Selects the span of text that corresponds to this text range, and removes any previous selection.
	; If the Select method is called on a text range object that represents a degenerate (empty) text range, the text insertion point moves to the starting endpoint of the text range.
	Select(){
	return UIA_Error(DllCall(this.vt(16),"ptr",this.__),"Select")
	}
	
	; Adds the text range to the collection of selected text ranges in a control that supports multiple, disjoint spans of selected text.
	; The text insertion point moves to the newly selected text. If AddToSelection is called on a text range object that represents a degenerate (empty) text range, the text insertion point moves to the starting endpoint of the text range.
	AddToSelection(){
	return UIA_Error(DllCall(this.vt(17),"ptr",this.__),"AddToSelection")
	}
	
	; Removes the text range from an existing collection of selected text in a text container that supports multiple, disjoint selections.
	; The text insertion point moves to the area of the removed highlight. Providing a degenerate text range also moves the insertion point.
	RemoveFromSelection(){
	return UIA_Error(DllCall(this.vt(18),"ptr",this.__),"RemoveFromSelection")
	}
	
	; Causes the text control to scroll until the text range is visible in the viewport.
	; The method respects both hidden and visible text. If the text range is hidden, the text control will scroll only if the hidden text has an anchor in the viewport. 
	; A Microsoft UI Automation client can check text visibility by calling IUIAutomationTextRange::GetAttributeValue with the attr parameter set to UIA_IsHiddenAttributeId. 
	ScrollIntoView(alignToTop){
	return UIA_Error(DllCall(this.vt(19),"ptr",this.__,"int",alignToTop),"ScrollIntoView")
	}
	
	; Retrieves a collection of all embedded objects that fall within the text range.
	GetChildren(){
	UIA_Error(DllCall(this.vt(20),"ptr",this.__,"ptr*",children),"GetChildren")
	return new IUIAutomationElementArray(children) 
	}
}
class IUIAutomationTextRangeArrayPattern extends IBase
{
	; Retrieves the number of text ranges in the collection.
	Length(){
	UIA_Error(DllCall(this.vt(3),"ptr",this.__,"int*",length),"Length")
	return length
	}
	
	; Retrieves a text range from the collection. 
	GetElement(index){ ; zero-based.
	UIA_Error(DllCall(this.vt(4),"ptr",this.__,"int",index,"ptr*",element),"GetElement")
	return new IUIAutomationTextRangePattern(element)
	}
}
class IUIAutomationTextPattern extends IBase
{
	; Retrieves the degenerate (empty) text range nearest to the specified screen coordinates.
	/*
	A text range that wraps a child object is returned if the screen coordinates are within the coordinates of an image, hyperlink, Microsoft Excel spreadsheet, or other embedded object.
	Because hidden text is not ignored, this method retrieves a degenerate range from the visible text closest to the specified coordinates.
	The implementation of RangeFromPoint in Windows Internet Explorer 9 does not return the expected result. Instead, clients should:
		1. Call the GetVisibleRanges method to retrieve an array of visible text ranges.Call the GetVisibleRanges method to retrieve an array of visible text ranges.
		2. Call the GetVisibleRanges method to retrieve an array of visible text ranges.For each text range in the array, call IUIAutomationTextRange::GetBoundingRectangles to retrieve the bounding rectangles.
		3. Call the GetVisibleRanges method to retrieve an array of visible text ranges.Check the bounding rectangles to find the text range that occupies the particular screen coordinates.
	*/
	RangeFromPoint(pt){ ; x|y<<32
	UIA_Error(DllCall(this.vt(3),"ptr",this.__,"int64",pt,"ptr*",range),"RangeFromPoint")
	return new IUIAutomationTextRange(range)
	}
	
	; Retrieves a text range enclosing a child element such as an image, hyperlink, Microsoft Excel spreadsheet, or other embedded object.
	; If there is no text in the range that encloses the child element, a degenerate (empty) range is returned.
	; The child parameter is either a child of the element associated with a IUIAutomationTextPattern or from the array of children of a IUIAutomationTextRange.
	RangeFromChild(child){ ; IUIAutomationElement
	UIA_Error(DllCall(this.vt(4),"ptr",this.__,"ptr",child.__,"ptr*",range),"RangeFromChild")
	return new IUIAutomationTextRange(range)
	}
	
	; Retrieves a collection of text ranges that represents the currently selected text in a text-based control. 
	; If the control supports the selection of multiple, non-contiguous spans of text, the ranges collection receives one text range for each selected span. 
	; If the control contains only a single span of selected text, the ranges collection receives a single text range. 
	; If the control contains a text insertion point but no text is selected, the ranges collection receives a degenerate (empty) text range at the position of the text insertion point.
	; If the control does not contain a text insertion point or does not support text selection, ranges is set to NULL.
	; Use the IUIAutomationTextPattern::SupportedTextSelection property to test whether a control supports text selection.
	GetSelection(){
	UIA_Error(DllCall(this.vt(5),"ptr",this.__,"ptr*",ranges),"GetSelection")
	return new IUIAutomationTextRangeArray(ranges)
	}
	
	; Retrieves an array of disjoint text ranges from a text-based control where each text range represents a contiguous span of visible text.
	; If the visible text consists of one contiguous span of text, the ranges array will contain a single text range that represents all of the visible text. 
	; If the visible text consists of multiple, disjoint spans of text, the ranges array will contain one text range for each visible span, beginning with the first visible span, and ending with the last visible span. Disjoint spans of visible text can occur when the content of a text-based control is partially obscured by an overlapping window or other object, or when a text-based control with multiple pages or columns has content that is partially scrolled out of view. 
	; IUIAutomationTextPattern::GetVisibleRanges retrieves a degenerate (empty) text range if no text is visible, if all text is scrolled out of view, or if the text-based control contains no text.
	GetVisibleRanges(){
	UIA_Error(DllCall(this.vt(6),"ptr",this.__,"ptr*",ranges),"GetVisibleRanges")
	return new IUIAutomationTextRangeArray(ranges)
	}
	
	; Retrieves a text range that encloses the main text of a document.
	; Some auxiliary text such as headers, footnotes, or annotations might not be included. 
	DocumentRange(){
	UIA_Error(DllCall(this.vt(7),"ptr",this.__,"ptr*",range),"DocumentRange")
	return new IUIAutomationTextRange(range) 
	}
	
	; Retrieves a value that specifies the type of text selection that is supported by the control. 
	SupportedTextSelection(){
	UIA_Error(DllCall(this.vt(8),"ptr",this.__,"int*",supportedTextSelection),"SupportedTextSelection")
	return supportedTextSelection ; SupportedTextSelection
	}
}
class IUIAutomationLegacyIAccessiblePattern extends IBase
{

; IUIAutomationLegacyIAccessiblePattern

	; Performs a Microsoft Active Accessibility selection.
	Select(flagsSelect){ ; SELFLAG
	return UIA_Error(DllCall(this.vt(3),"ptr",this.__,"int",flagsSelect),"Select") ; SELFLAG
	}
	
	; Performs the Microsoft Active Accessibility default action for the element.
	DoDefaultAction(){
	return UIA_Error(DllCall(this.vt(4),"ptr",this.__),"DoDefaultAction")
	}
	
	; Sets the Microsoft Active Accessibility value property for the element. This method is supported only for some elements (usually edit controls). 
	SetValue(szValue){
	return UIA_Error(DllCall(this.vt(5),"ptr",this.__,"str",szValue),"SetValue")
	}
	
	; Retrieves the Microsoft Active Accessibility child identifier for the element. If the element is not a child element, CHILDID_SELF (0) is returned.
	CurrentChildId(){
	UIA_Error(DllCall(this.vt(6),"ptr",this.__,"int*",pRetVal),"CurrentChildId")
	return pRetVal
	}
	
	; Retrieves the Microsoft Active Accessibility name property of the element. The name of an element can be used to find the element in the element tree when the automation ID property is not supported on the element.
	CurrentName(){
	UIA_Error(DllCall(this.vt(7),"ptr",this.__,"ptr*",pszName),"CurrentName")
	return StrGet(pszName,"utf-16")
	}
	
	; Retrieves the Microsoft Active Accessibility value property.
	CurrentValue(){
	UIA_Error(DllCall(this.vt(8),"ptr",this.__,"ptr*",pszValue),"CurrentValue")
	return StrGet(pszValue,"utf-16")
	}
	
	; Retrieves the Microsoft Active Accessibility description of the element.
	CurrentDescription(){
	UIA_Error(DllCall(this.vt(9),"ptr",this.__,"ptr*",pszDescription),"CurrentDescription")
	return StrGet(pszDescription,"utf-16")
	}
	
	; Retrieves the Microsoft Active Accessibility role identifier of the element.
	CurrentRole(){
	UIA_Error(DllCall(this.vt(10),"ptr",this.__,"uint*",pdwRole),"CurrentRole") ; role
	return pdwRole ; Roles
	}
	
	; Retrieves the Microsoft Active Accessibility state identifier for the element.
	CurrentState(){
	UIA_Error(DllCall(this.vt(11),"ptr",this.__,"uint*",pdwState),"CurrentState") ; state id
	return pdwState ; State
	}
	
	; Retrieves the Microsoft Active Accessibility help string for the element.
	CurrentHelp(){
	UIA_Error(DllCall(this.vt(12),"ptr",this.__,"ptr*",pszHelp),"CurrentHelp")
	return StrGet(pszHelp,"utf-16")
	}
	
	; Retrieves the Microsoft Active Accessibility keyboard shortcut property for the element.
	CurrentKeyboardShortcut(){
	UIA_Error(DllCall(this.vt(13),"ptr",this.__,"ptr*",pszKeyboardShortcut),"CurrentKeyboardShortcut")
	return StrGet(pszKeyboardShortcut,"utf-16")
	}
	
	; Retrieves the Microsoft Active Accessibility property that identifies the selected children of this element.
	GetCurrentSelection(){
	UIA_Error(DllCall(this.vt(14),"ptr",this.__,"ptr*",pvarSelectedChildren),"GetCurrentSelection")
	return new IUIAutomationElementArray(pvarSelectedChildren)
	}
	
	; Retrieves the Microsoft Active Accessibility default action for the element.
	CurrentDefaultAction(){
	UIA_Error(DllCall(this.vt(15),"ptr",this.__,"ptr*",pszDefaultAction),"CurrentDefaultAction")
	return StrGet(pszDefaultAction,"utf-16")
	}
	
	; Retrieves the cached Microsoft Active Accessibility child identifier for the element.
	CachedChildId(){
	UIA_Error(DllCall(this.vt(16),"ptr",this.__,"int*",pRetVal),"CachedChildId")
	return pRetVal
	}
	
	; Retrieves the cached Microsoft Active Accessibility name property of the element.
	CachedName(){
	UIA_Error(DllCall(this.vt(17),"ptr",this.__,"ptr*",pszName),"CachedName")
	return StrGet(pszName,"utf-16")
	}
	
	; Retrieves the cached Microsoft Active Accessibility value property.
	CachedValue(){
	UIA_Error(DllCall(this.vt(18),"ptr",this.__,"ptr*",pszValue),"CachedValue")
	return StrGet(pszValue,"utf-16")
	}
	
	; Retrieves the cached Microsoft Active Accessibility description of the element.
	CachedDescription(){
	UIA_Error(DllCall(this.vt(19),"ptr",this.__,"ptr*",pszDescription),"CachedDescription")
	return StrGet(pszDescription,"utf-16")
	}
	
	; Retrieves the cached Microsoft Active Accessibility role of the element.
	CachedRole(){
	UIA_Error(DllCall(this.vt(20),"ptr",this.__,"uint*",pdwRole),"CachedRole")
	return pdwRole ; Roles
	}
	
	; Retrieves the cached Microsoft Active Accessibility state identifier for the element.
	CachedState(){
	UIA_Error(DllCall(this.vt(21),"ptr",this.__,"uint*",pdwState),"CachedState")
	return pdwState ; State
	}
	
	; Retrieves the cached Microsoft Active Accessibility help string for the element.
	CachedHelp(){
	UIA_Error(DllCall(this.vt(22),"ptr",this.__,"ptr*",pszHelp),"CachedHelp")
	return StrGet(pszHelp,"utf-16")
	}
	
	; Retrieves the cached Microsoft Active Accessibility keyboard shortcut property for the element.
	CachedKeyboardShortcut(){
	UIA_Error(DllCall(this.vt(23),"ptr",this.__,"ptr*",pszKeyboardShortcut),"CachedKeyboardShortcut")
	return StrGet(pszKeyboardShortcut,"utf-16")
	}
	
	; Retrieves the cached Microsoft Active Accessibility property that identifies the selected children of this element.
	GetCachedSelection(){
	UIA_Error(DllCall(this.vt(24),"ptr",this.__,"ptr*",pvarSelectedChildren),"GetCachedSelection")
	return new IUIAutomationElementArray(pvarSelectedChildren)
	}
	
	; Retrieves the Microsoft Active Accessibility default action for the element.
	CachedDefaultAction(){
	UIA_Error(DllCall(this.vt(25),"ptr",this.__,"ptr*",pszDefaultAction),"CachedDefaultAction")
	return StrGet(pszDefaultAction,"utf-16")
	}
	
	; Retrieves an IAccessible object that corresponds to the Microsoft UI Automation element.
	; This method returns NULL if the underlying implementation of the UI Automation element is not a native Microsoft Active Accessibility server; that is, if a client attempts to retrieve the IAccessible interface for an element originally supported by a proxy object from OLEACC.dll, or by the UIA-to-MSAA Bridge.
	GetIAccessible(){
	UIA_Error(DllCall(this.vt(26),"ptr",this.__,"ptr*",ppAccessible),"GetIAccessible")
	return ppAccessible ; IAccessible
	}
}
class IUIAutomationItemContainerPattern extends IBase
{
	; IUIAutomationItemContainerPattern

	; Retrieves an element within a containing element, based on a specified property value.
	; The provider may return an actual IUIAutomationElement interface or a placeholder if the matching element is virtualized. 
	; This method returns E_INVALIDARG if the property requested is not one that the container supports searching over. It is expected that most containers will support Name property, and if appropriate for the container, AutomationId and IsSelected. 
	; This method can be slow, because it may need to traverse multiple objects to find a matching one. When used in a loop to return multiple items, no specific order is defined so long as each item is returned only once (that is, the loop should terminate). This method is also item-centric, not UI-centric, so items with multiple UI representations need to be hit only once. 
	; When the propertyId parameter is specified as 0 (zero), the provider is expected to return the next item after pStartAfter. If pStartAfter is specified as NULL with a propertyId of 0, the provider should return the first item in the container. When propertyId is specified as 0, the value parameter should be VT_EMPTY. 
	FindItemByProperty(pStartAfter,propertyId,value){ ; IUIAutomationElement
	UIA_Error(DllCall(this.vt(3),"ptr",this.__,"ptr",pStartAfter,"int",propertyId,"ptr",variant(_,UIA_PropertyVariantType(propertyId),value),"ptr*",pFound),"FindItemByProperty")
	return new IUIAutomationElement(pFound)
	}

}
class IUIAutomationVirtualizedItemPattern extends IBase
{
	; Creates a full UI Automation element for a virtualized item.
	; A virtualized item is represented by a placeholder automation element in the UI Automation tree. The Realize method causes the provider to make full information available for the item so that a full UI Automation element can be created for the item. 
	Realize(){
	return UIA_Error(DllCall(this.vt(3),"ptr",this.__),"Realize")
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;IUIAutomationEventHandle;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UIA_OnEvent(ByRef ptr,name){
	if !IsFunc(name){
		msgbox %name% ia not a function.
		return
	}
	VarSetCapacity(ptr,A_PtrSize*5)
	,NumPut(&ptr+A_PtrSize,ptr)
	,NumPut(RegisterCallback("_UIA_QueryInterface","F"),ptr,A_PtrSize*1)
	,NumPut(RegisterCallback("_UIA_AddRef","F"),ptr,A_PtrSize*2)
	,NumPut(RegisterCallback("_UIA_Release","F"),ptr,A_PtrSize*3)
	,NumPut(RegisterCallback(name,"F"),ptr,A_PtrSize*4)
	return &ptr
}
_UIA_QueryInterface(pSelf, pRIID, pObj){
	DllCall("ole32\StringFromIID","ptr",pRIID,"ptr*",sz),str:=StrGet(sz)
	return (str="{00000000-0000-0000-C000-000000000046}")||(str="{146c3c17-f12e-4e22-8c27-f894b9b79c69}")||(str="{40cd37d4-c756-4b0c-8c6f-bddfeeb13b50}")||(str="{e81d1b4e-11c5-42f8-9754-e7036c79f054}")||(str="{c270f6b5-5c69-4290-9745-7a7f97169468}")?NumPut(pSelf,pObj+0)*0:0x80004002 ; E_NOINTERFACE
}
_UIA_AddRef(pSelf){
}
_UIA_Release(pSelf){
}

/*	event handle sample
HandleAutomationEvent(pself,sender,eventId) ; IUIAutomationElement , EVENTID
HandleFocusChangedEvent(pself,sender)
HandlePropertyChangedEvent(pself,sender,propertyId,newValue) ; PROPERTYID , VARIANT
HandleStructureChangedEvent(pself,sender,changeType,runtimeId) ; StructureChangeType , SAFEARRAY
*/

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;IUIAutomationProxyFactory;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;
;;Wrapped Functions;;
;;;;;;;;;;;;;;;;;;;;;

; create nativearray
CreateNativeArrary(ptr,type,p*){ ; not completed
	count:=0
	VarSetCapacity(ptr,p.maxindex())
	loop{
		
	}
}

; transform to

; create variant
variant(ByRef var,type=0,val=0){ ; //not completed, type not defined
	static _:={2:"short",3:"int",4:"float",5:"double",0xA:"int",0xB:"short",0x10:"uchar",0x11:"char",0x12:"ushort",0x13:"uint",0x14:"int64",0x15:"uint64"}
	return (VarSetCapacity(var,8+2*A_PtrSize)+NumPut(type,var,0,"short")+NumPut(val,var,8,_.haskey(type)?t[type]:"ptr"))*0+&var
}

; variant type
VariantType(type){
	static _:={2:[2,"short"]	; 16 位有符号整数
	,3:[4,"int"]	; 32 位有符号整数
	,4:[4,"float"]	; 32 位浮点数
	,5:[8,"double"]	; 64 位浮点数
	,0xA:[4,"uint"]	; Error 码 (32 位整数)
	,0xB:[2,"short"]	; 布尔值 True (-1) 或 False (0)
	,0x10:[1,"char"]	; 8 位有符号整数
	,0x11:[1,"uchar"]	; 8 位无符号整数
	,0x12:[2,"ushort"]	; 16 位无符号整数
	,0x13:[4,"uint"]	; 32 位无符号整数
	,0x14:[8,"int64"]	; 64 位有符号整数
	,0x15:[8,"uint64"]}	; 64 位无符号整数
	return _.haskey(type)?_[type]:[A_PtrSize,"ptr"]
}

; Get Value in variant
GetVariantValue(v){
	if (type:=NumGet(v+0,"ushort"))&0x2000
		return GetSafeArrayValue(NumGet(v+8),type&0xFF)
	else{
	return (type=8)?StrGet(NumGet(v+8,varianttype(type).2),"utf-16"):NumGet(v+8,varianttype(type).2)
	}
}

; create safearray
SafeArray(ByRef array,type,count,p*){
	array:=ComObjArray(type,count)
	loop % p.maxindex()
		array[A_Index-1]:=p[A_Index]
	return ComObjValue(array)
}

; Get Value in SafeArray
GetSafeArrayValue(p,type){ ; //not completed, only 1 dim
	/*
	cDims:=NumGet(p+0,"ushort")
	fFeatures:=NumGet(p+2,"ushort")
	cbElements:=NumGet(p+4,"uint")
	cLocks:=NumGet(p+8,"uint")
	pvData:=NumGet(p+8+A_PtrSize,"ptr")
	;dim 1
	cElements:=NumGet(p+8+2*A_PtrSize,"uint") 
	lLbound:=NumGet(p+12+2*A_PtrSize,"uint")
	;dim 2
	cElements:=NumGet(p+16+2*A_PtrSize,"uint") 
	lLbound:=NumGet(p+20+2*A_PtrSize,"uint")
	
	r1:=NumGet(pvData+0)
	*/
	t:=varianttype(type),item:={},pv:=NumGet(p+8+A_PtrSize,"ptr")
	loop % NumGet(p+8+2*A_PtrSize,"uint")
		item.Insert((type=8)?StrGet(NumGet(pv+(A_Index-1)*t.1,t.2),"utf-16"):NumGet(pv+(A_Index-1)*t.1,t.2))
	return item
}

; uia error code
UIA_Error(a,b){
	static err:={0x8000FFFF:"Catastrophic failure error.",0x80004001:"Not implemented error.",0x8007000E:"Out of memory error.",0x80070057:"One or more arguments are not valid error.",0x80004002:"Interface not supported error.",0x80004003:"Pointer not valid error.",0x80070006:"Handle not valid error.",0x80004004:"Operation aborted error.",0x80004005:"Unspecified error.",0x80070005:"General access denied error.",0x800401E5:"The object identified by this moniker could not be found."
		,0x80040201:"UIA_E_ELEMENTNOTAVAILABLE",0x80040200:"UIA_E_ELEMENTNOTENABLED",0x80131509:"UIA_E_INVALIDOPERATION",0x80040202:"UIA_E_NOCLICKABLEPOINT",0x80040204:"UIA_E_NOTSUPPORTED",0x80040203:"UIA_E_PROXYASSEMBLYNOTLOADED"}
	if a && (a&=0xFFFFFFFF)
		msgbox, % b " : " (err.haskey(a)?err[a]:a)
	return a
}

;;;;;;;;;;;;;;;;;
;;UIA Constants;;
;;;;;;;;;;;;;;;;;

; Property Identifiers
UIA_Property(n){
	static id:={RuntimeId:30000,BoundingRectangle:30001,ProcessId:30002,ControlType:30003,LocalizedControlType:30004,Name:30005,AcceleratorKey:30006,AccessKey:30007,HasKeyboardFocus:30008,IsKeyboardFocusable:30009,IsEnabled:30010,AutomationId:30011,ClassName:30012,HelpText:30013,ClickablePoint:30014,Culture:30015,IsControlElement:30016,IsContentElement:30017,LabeledBy:30018,IsPassword:30019,NativeWindowHandle:30020,ItemType:30021,IsOffscreen:30022,Orientation:30023,FrameworkId:30024,IsRequiredForForm:30025,ItemStatus:30026,IsDockPatternAvailable:30027,IsExpandCollapsePatternAvailable:30028,IsGridItemPatternAvailable:30029,IsGridPatternAvailable:30030,IsInvokePatternAvailable:30031,IsMultipleViewPatternAvailable:30032,IsRangeValuePatternAvailable:30033,IsScrollPatternAvailable:30034,IsScrollItemPatternAvailable:30035,IsSelectionItemPatternAvailable:30036,IsSelectionPatternAvailable:30037,IsTablePatternAvailable:30038,IsTableItemPatternAvailable:30039,IsTextPatternAvailable:30040,IsTogglePatternAvailable:30041,IsTransformPatternAvailable:30042,IsValuePatternAvailable:30043,IsWindowPatternAvailable:30044,ValueValue:30045,ValueIsReadOnly:30046,RangeValueValue:30047,RangeValueIsReadOnly:30048,RangeValueMinimum:30049,RangeValueMaximum:30050,RangeValueLargeChange:30051,RangeValueSmallChange:30052,ScrollHorizontalScrollPercent:30053,ScrollHorizontalViewSize:30054,ScrollVerticalScrollPercent:30055,ScrollVerticalViewSize:30056,ScrollHorizontallyScrollable:30057,ScrollVerticallyScrollable:30058,SelectionSelection:30059,SelectionCanSelectMultiple:30060,SelectionIsSelectionRequired:30061,GridRowCount:30062,GridColumnCount:30063,GridItemRow:30064,GridItemColumn:30065,GridItemRowSpan:30066,GridItemColumnSpan:30067,GridItemContainingGrid:30068,DockDockPosition:30069,ExpandCollapseExpandCollapseState:30070,MultipleViewCurrentView:30071,MultipleViewSupportedViews:30072,WindowCanMaximize:30073,WindowCanMinimize:30074,WindowWindowVisualState:30075,WindowWindowInteractionState:30076,WindowIsModal:30077,WindowIsTopmost:30078,SelectionItemIsSelected:30079,SelectionItemSelectionContainer:30080,TableRowHeaders:30081,TableColumnHeaders:30082,TableRowOrColumnMajor:30083,TableItemRowHeaderItems:30084,TableItemColumnHeaderItems:30085,ToggleToggleState:30086,TransformCanMove:30087,TransformCanResize:30088,TransformCanRotate:30089,IsLegacyIAccessiblePatternAvailable:30090,LegacyIAccessibleChildId:30091,LegacyIAccessibleName:30092,LegacyIAccessibleValue:30093,LegacyIAccessibleDescription:30094,LegacyIAccessibleRole:30095,LegacyIAccessibleState:30096,LegacyIAccessibleHelp:30097,LegacyIAccessibleKeyboardShortcut:30098,LegacyIAccessibleSelection:30099,LegacyIAccessibleDefaultAction:30100,AriaRole:30101,AriaProperties:30102,IsDataValidForForm:30103,ControllerFor:30104,DescribedBy:30105,FlowsTo:30106,ProviderDescription:30107,IsItemContainerPatternAvailable:30108,IsVirtualizedItemPatternAvailable:30109,IsSynchronizedInputPatternAvailable:30110}
	, name:={30000:"UIA_RuntimeIdPropertyId",30001:"UIA_BoundingRectanglePropertyId",30002:"UIA_ProcessIdPropertyId",30003:"UIA_ControlTypePropertyId",30004:"UIA_LocalizedControlTypePropertyId",30005:"UIA_NamePropertyId",30006:"UIA_AcceleratorKeyPropertyId",30007:"UIA_AccessKeyPropertyId",30008:"UIA_HasKeyboardFocusPropertyId",30009:"UIA_IsKeyboardFocusablePropertyId",30010:"UIA_IsEnabledPropertyId",30011:"UIA_AutomationIdPropertyId",30012:"UIA_ClassNamePropertyId",30013:"UIA_HelpTextPropertyId",30014:"UIA_ClickablePointPropertyId",30015:"UIA_CulturePropertyId",30016:"UIA_IsControlElementPropertyId",30017:"UIA_IsContentElementPropertyId",30018:"UIA_LabeledByPropertyId",30019:"UIA_IsPasswordPropertyId",30020:"UIA_NativeWindowHandlePropertyId",30021:"UIA_ItemTypePropertyId",30022:"UIA_IsOffscreenPropertyId",30023:"UIA_OrientationPropertyId",30024:"UIA_FrameworkIdPropertyId",30025:"UIA_IsRequiredForFormPropertyId",30026:"UIA_ItemStatusPropertyId",30027:"UIA_IsDockPatternAvailablePropertyId",30028:"UIA_IsExpandCollapsePatternAvailablePropertyId",30029:"UIA_IsGridItemPatternAvailablePropertyId",30030:"UIA_IsGridPatternAvailablePropertyId",30031:"UIA_IsInvokePatternAvailablePropertyId",30032:"UIA_IsMultipleViewPatternAvailablePropertyId",30033:"UIA_IsRangeValuePatternAvailablePropertyId",30034:"UIA_IsScrollPatternAvailablePropertyId",30035:"UIA_IsScrollItemPatternAvailablePropertyId",30036:"UIA_IsSelectionItemPatternAvailablePropertyId",30037:"UIA_IsSelectionPatternAvailablePropertyId",30038:"UIA_IsTablePatternAvailablePropertyId",30039:"UIA_IsTableItemPatternAvailablePropertyId",30040:"UIA_IsTextPatternAvailablePropertyId",30041:"UIA_IsTogglePatternAvailablePropertyId",30042:"UIA_IsTransformPatternAvailablePropertyId",30043:"UIA_IsValuePatternAvailablePropertyId",30044:"UIA_IsWindowPatternAvailablePropertyId",30045:"UIA_ValueValuePropertyId",30046:"UIA_ValueIsReadOnlyPropertyId",30047:"UIA_RangeValueValuePropertyId",30048:"UIA_RangeValueIsReadOnlyPropertyId",30049:"UIA_RangeValueMinimumPropertyId",30050:"UIA_RangeValueMaximumPropertyId",30051:"UIA_RangeValueLargeChangePropertyId",30052:"UIA_RangeValueSmallChangePropertyId",30053:"UIA_ScrollHorizontalScrollPercentPropertyId",30054:"UIA_ScrollHorizontalViewSizePropertyId",30055:"UIA_ScrollVerticalScrollPercentPropertyId",30056:"UIA_ScrollVerticalViewSizePropertyId",30057:"UIA_ScrollHorizontallyScrollablePropertyId",30058:"UIA_ScrollVerticallyScrollablePropertyId",30059:"UIA_SelectionSelectionPropertyId",30060:"UIA_SelectionCanSelectMultiplePropertyId",30061:"UIA_SelectionIsSelectionRequiredPropertyId",30062:"UIA_GridRowCountPropertyId",30063:"UIA_GridColumnCountPropertyId",30064:"UIA_GridItemRowPropertyId",30065:"UIA_GridItemColumnPropertyId",30066:"UIA_GridItemRowSpanPropertyId",30067:"UIA_GridItemColumnSpanPropertyId",30068:"UIA_GridItemContainingGridPropertyId",30069:"UIA_DockDockPositionPropertyId",30070:"UIA_ExpandCollapseExpandCollapseStatePropertyId",30071:"UIA_MultipleViewCurrentViewPropertyId",30072:"UIA_MultipleViewSupportedViewsPropertyId",30073:"UIA_WindowCanMaximizePropertyId",30074:"UIA_WindowCanMinimizePropertyId",30075:"UIA_WindowWindowVisualStatePropertyId",30076:"UIA_WindowWindowInteractionStatePropertyId",30077:"UIA_WindowIsModalPropertyId",30078:"UIA_WindowIsTopmostPropertyId",30079:"UIA_SelectionItemIsSelectedPropertyId",30080:"UIA_SelectionItemSelectionContainerPropertyId",30081:"UIA_TableRowHeadersPropertyId",30082:"UIA_TableColumnHeadersPropertyId",30083:"UIA_TableRowOrColumnMajorPropertyId",30084:"UIA_TableItemRowHeaderItemsPropertyId",30085:"UIA_TableItemColumnHeaderItemsPropertyId",30086:"UIA_ToggleToggleStatePropertyId",30087:"UIA_TransformCanMovePropertyId",30088:"UIA_TransformCanResizePropertyId",30089:"UIA_TransformCanRotatePropertyId",30090:"UIA_IsLegacyIAccessiblePatternAvailablePropertyId",30091:"UIA_LegacyIAccessibleChildIdPropertyId",30092:"UIA_LegacyIAccessibleNamePropertyId",30093:"UIA_LegacyIAccessibleValuePropertyId",30094:"UIA_LegacyIAccessibleDescriptionPropertyId",30095:"UIA_LegacyIAccessibleRolePropertyId",30096:"UIA_LegacyIAccessibleStatePropertyId",30097:"UIA_LegacyIAccessibleHelpPropertyId",30098:"UIA_LegacyIAccessibleKeyboardShortcutPropertyId",30099:"UIA_LegacyIAccessibleSelectionPropertyId",30100:"UIA_LegacyIAccessibleDefaultActionPropertyId",30101:"UIA_AriaRolePropertyId",30102:"UIA_AriaPropertiesPropertyId",30103:"UIA_IsDataValidForFormPropertyId",30104:"UIA_ControllerForPropertyId",30105:"UIA_DescribedByPropertyId",30106:"UIA_FlowsToPropertyId",30107:"UIA_ProviderDescriptionPropertyId",30108:"UIA_IsItemContainerPatternAvailablePropertyId",30109:"UIA_IsVirtualizedItemPatternAvailablePropertyId",30110:"UIA_IsSynchronizedInputPatternAvailablePropertyId"}
	if n is integer
		return name[n]
	else return id[n]
}

; Property Variant Type
UIA_PropertyVariantType(id){
	static type:={30000:0x2003,30001:0x2005,30002:3,30003:3,30004:8,30005:8,30006:8,30007:8,30008:0xB,30009:0xB,30010:0xB,30011:8,30012:8,30013:8,30014:0x2005,30015:3,30016:0xB,30017:0xB,30018:0xD,30019:0xB,30020:3,30021:8,30022:0xB,30023:3,30024:8,30025:0xB,30026:8,30027:0xB,30028:0xB,30029:0xB,30030:0xB,30031:0xB,30032:0xB,30033:0xB,30034:0xB,30035:0xB,30036:0xB,30037:0xB,30038:0xB,30039:0xB,30040:0xB,30041:0xB,30042:0xB,30043:0xB,30044:0xB,30045:8,30046:0xB,30047:5,30048:0xB,30049:5,30050:5,30051:5,30052:5,30053:5,30054:5,30055:5,30056:5,30057:0xB,30058:0xB,30059:0x200D,30060:0xB,30061:0xB,30062:3,30063:3,30064:3,30065:3,30066:3,30067:3,30068:0xD,30069:3,30070:3,30071:3,30072:0x2003,30073:0xB,30074:0xB,30075:3,30076:3,30077:0xB,30078:0xB,30079:0xB,30080:0xD,30081:0x200D,30082:0x200D,30083:0x2003,30084:0x200D,30085:0x200D,30086:3,30087:0xB,30088:0xB,30089:0xB,30090:0xB,30091:3,30092:8,30093:8,30094:8,30095:3,30096:3,30097:8,30098:8,30099:0x200D,30100:8,30101:8,30102:8,30103:0xB,30104:0xD,30105:0xD,30106:0xD,30107:8,30108:0xB,30109:0xB,30110:0xB}
	return type[id]
}

; Control Pattern Identifiers
UIA_Pattern(n){
	static id:={Invoke:10000,Selection:10001,Value:10002,RangeValue:10003,Scroll:10004,ExpandCollapse:10005,Grid:10006,GridItem:10007,MultipleView:10008,Window:10009,SelectionItem:10010,Dock:10011,Table:10012,TableItem:10013,Text:10014,Toggle:10015,Transform:10016,ScrollItem:10017,LegacyIAccessible:10018,ItemContainer:10019,VirtualizedItem:10020,SynchronizedInput:10021}
	, name:={10000:"UIA_InvokePatternId",10001:"UIA_SelectionPatternId",10002:"UIA_ValuePatternId",10003:"UIA_RangeValuePatternId",10004:"UIA_ScrollPatternId",10005:"UIA_ExpandCollapsePatternId",10006:"UIA_GridPatternId",10007:"UIA_GridItemPatternId",10008:"UIA_MultipleViewPatternId",10009:"UIA_WindowPatternId",10010:"UIA_SelectionItemPatternId",10011:"UIA_DockPatternId",10012:"UIA_TablePatternId",10013:"UIA_TableItemPatternId",10014:"UIA_TextPatternId",10015:"UIA_TogglePatternId",10016:"UIA_TransformPatternId",10017:"UIA_ScrollItemPatternId",10018:"UIA_LegacyIAccessiblePatternId",10019:"UIA_ItemContainerPatternId",10020:"UIA_VirtualizedItemPatternId",10021:"UIA_SynchronizedInputPatternId"}
	if n is integer
		return name[n]
	else return id[n]
}

; Text Attribute Identifiers
UIA_Attribute(n){
	static id:={AnimationStyle:40000,BackgroundColor:40001,BulletStyle:40002,CapStyle:40003,Culture:40004,FontName:40005,FontSize:40006,FontWeight:40007,ForegroundColor:40008,HorizontalTextAlignment:40009,IndentationFirstLine:40010,IndentationLeading:40011,IndentationTrailing:40012,IsHidden:40013,IsItalic:40014,IsReadOnly:40015,IsSubscript:40016,IsSuperscript:40017,MarginBottom:40018,MarginLeading:40019,MarginTop:40020,MarginTrailing:40021,OutlineStyles:40022,OverlineColor:40023,OverlineStyle:40024,StrikethroughColor:40025,StrikethroughStyle:40026,Tabs:40027,TextFlowDirections:40028,UnderlineColor:40029,UnderlineStyle:40030}
	, name:={40000:"UIA_AnimationStyleAttributeId",40001:"UIA_BackgroundColorAttributeId",40002:"UIA_BulletStyleAttributeId",40003:"UIA_CapStyleAttributeId",40004:"UIA_CultureAttributeId",40005:"UIA_FontNameAttributeId",40006:"UIA_FontSizeAttributeId",40007:"UIA_FontWeightAttributeId",40008:"UIA_ForegroundColorAttributeId",40009:"UIA_HorizontalTextAlignmentAttributeId",40010:"UIA_IndentationFirstLineAttributeId",40011:"UIA_IndentationLeadingAttributeId",40012:"UIA_IndentationTrailingAttributeId",40013:"UIA_IsHiddenAttributeId",40014:"UIA_IsItalicAttributeId",40015:"UIA_IsReadOnlyAttributeId",40016:"UIA_IsSubscriptAttributeId",40017:"UIA_IsSuperscriptAttributeId",40018:"UIA_MarginBottomAttributeId",40019:"UIA_MarginLeadingAttributeId",40020:"UIA_MarginTopAttributeId",40021:"UIA_MarginTrailingAttributeId",40022:"UIA_OutlineStylesAttributeId",40023:"UIA_OverlineColorAttributeId",40024:"UIA_OverlineStyleAttributeId",40025:"UIA_StrikethroughColorAttributeId",40026:"UIA_StrikethroughStyleAttributeId",40027:"UIA_TabsAttributeId",40028:"UIA_TextFlowDirectionsAttributeId",40029:"UIA_UnderlineColorAttributeId",40030:"UIA_UnderlineStyleAttributeId"}
	if n is integer
		return name[n]
	else return id[n]
}

; Text Attribute Variant type
UIA_AttributeVariantType(id){
	Static type:={40000:3,40001:3,40002:3,40003:3,40004:3,40005:8,40006:5,40007:3,40008:3,40009:3,40010:5,40011:5,40012:5,40013:0xB,40014:0xB,40015:0xB,40016:0xB,40017:0xB,40018:5,40019:5,40020:5,40021:5,40022:3,40023:3,40024:3,40025:3,40026:3,40027:0x2005,40028:3,40029:3,40030:3}
	return type[id]
}

; Control Type Identifiers
UIA_ControlType(n){
	static id:={Button:50000,Calendar:50001,CheckBox:50002,ComboBox:50003,Edit:50004,Hyperlink:50005,Image:50006,ListItem:50007,List:50008,Menu:50009,MenuBar:50010,MenuItem:50011,ProgressBar:50012,RadioButton:50013,ScrollBar:50014,Slider:50015,Spinner:50016,StatusBar:50017,Tab:50018,TabItem:50019,Text:50020,ToolBar:50021,ToolTip:50022,Tree:50023,TreeItem:50024,Custom:50025,Group:50026,Thumb:50027,DataGrid:50028,DataItem:50029,Document:50030,SplitButton:50031,Window:50032,Pane:50033,Header:50034,HeaderItem:50035,Table:50036,TitleBar:50037,Separator:50038}
	, name:={50000:"UIA_ButtonControlTypeId",50001:"UIA_CalendarControlTypeId",50002:"UIA_CheckBoxControlTypeId",50003:"UIA_ComboBoxControlTypeId",50004:"UIA_EditControlTypeId",50005:"UIA_HyperlinkControlTypeId",50006:"UIA_ImageControlTypeId",50007:"UIA_ListItemControlTypeId",50008:"UIA_ListControlTypeId",50009:"UIA_MenuControlTypeId",50010:"UIA_MenuBarControlTypeId",50011:"UIA_MenuItemControlTypeId",50012:"UIA_ProgressBarControlTypeId",50013:"UIA_RadioButtonControlTypeId",50014:"UIA_ScrollBarControlTypeId",50015:"UIA_SliderControlTypeId",50016:"UIA_SpinnerControlTypeId",50017:"UIA_StatusBarControlTypeId",50018:"UIA_TabControlTypeId",50019:"UIA_TabItemControlTypeId",50020:"UIA_TextControlTypeId",50021:"UIA_ToolBarControlTypeId",50022:"UIA_ToolTipControlTypeId",50023:"UIA_TreeControlTypeId",50024:"UIA_TreeItemControlTypeId",50025:"UIA_CustomControlTypeId",50026:"UIA_GroupControlTypeId",50027:"UIA_ThumbControlTypeId",50028:"UIA_DataGridControlTypeId",50029:"UIA_DataItemControlTypeId",50030:"UIA_DocumentControlTypeId",50031:"UIA_SplitButtonControlTypeId",50032:"UIA_WindowControlTypeId",50033:"UIA_PaneControlTypeId",50034:"UIA_HeaderControlTypeId",50035:"UIA_HeaderItemControlTypeId",50036:"UIA_TableControlTypeId",50037:"UIA_TitleBarControlTypeId",50038:"UIA_SeparatorControlTypeId"}
	if n is integer
		return name[n]
	else return id[n]
}

; Event Identifiers
UIA_Event(n){
	static id:={ToolTipOpened:20000,ToolTipClosed:20001,StructureChanged:20002,MenuOpened:20003,AutomationPropertyChanged:20004,AutomationFocusChanged:20005,AsyncContentLoaded:20006,MenuClosed:20007,LayoutInvalidated:20008,Invoke_Invoked:20009,SelectionItem_ElementAddedToSelection:20010,SelectionItem_ElementRemovedFromSelection:20011,SelectionItem_ElementSelected:20012,Selection_Invalidated:20013,Text_TextSelectionChanged:20014,Text_TextChanged:20015,Window_WindowOpened:20016,Window_WindowClosed:20017,MenuModeStart:20018,MenuModeEnd:20019,InputReachedTarget:20020,InputReachedOtherElement:20021,InputDiscarded:20022}
	, name:={20000:"UIA_ToolTipOpenedEventId",20001:"UIA_ToolTipClosedEventId",20002:"UIA_StructureChangedEventId",20003:"UIA_MenuOpenedEventId",20004:"UIA_AutomationPropertyChangedEventId",20005:"UIA_AutomationFocusChangedEventId",20006:"UIA_AsyncContentLoadedEventId",20007:"UIA_MenuClosedEventId",20008:"UIA_LayoutInvalidatedEventId",20009:"UIA_Invoke_InvokedEventId",20010:"UIA_SelectionItem_ElementAddedToSelectionEventId",20011:"UIA_SelectionItem_ElementRemovedFromSelectionEventId",20012:"UIA_SelectionItem_ElementSelectedEventId",20013:"UIA_Selection_InvalidatedEventId",20014:"UIA_Text_TextSelectionChangedEventId",20015:"UIA_Text_TextChangedEventId",20016:"UIA_Window_WindowOpenedEventId",20017:"UIA_Window_WindowClosedEventId",20018:"UIA_MenuModeStartEventId",20019:"UIA_MenuModeEndEventId",20020:"UIA_InputReachedTargetEventId",20021:"UIA_InputReachedOtherElementEventId",20022:"UIA_InputDiscardedEventId"}
	if n is integer
		return name[n]
	else return id[n]
}

; UI Automation Enumerations
UIA_Enum(t){
	static _:={0:0
; enum TreeScope Contains values that specify the scope of various operations in the Microsoft UI Automation tree.
	,TreeScope_Element:0x1
	,TreeScope_Children:0x2
	,TreeScope_Descendants:0x4
	,TreeScope_Parent:0x8
	,TreeScope_Ancestors:0x10
	,TreeScope_Subtree:0x7
; enum PropertyConditionFlags Contains values used in creating property conditions.
	,PropertyConditionFlags_None:0
	,PropertyConditionFlags_IgnoreCase:1
; enum AutomationElementMode Contains values that specify the type of reference to use when returning UI Automation elements.
	,AutomationElementMode_None:0
	,AutomationElementMode_Full:1
;; pattern
; enum NavigateDirection Contains values used to specify the direction of navigation within the Microsoft UI Automation tree.
	,NavigateDirection_Parent:0
	,NavigateDirection_NextSibling:1
	,NavigateDirection_PreviousSibling:2
	,NavigateDirection_FirstChild:3
	,NavigateDirection_LastChild:4
; enum StructureChangeType Contains values that specify the type of change in the Microsoft UI Automation tree structure.
	,StructureChangeType_ChildAdded:0
	,StructureChangeType_ChildRemoved:1
	,StructureChangeType_ChildrenInvalidated:2
	,StructureChangeType_ChildrenBulkAdded:3
	,StructureChangeType_ChildrenBulkRemoved:4
	,StructureChangeType_ChildrenReordered:5   
; enum OrientationType Contains values that specify the orientation of a control.
    ,OrientationType_None:0
	,OrientationType_Horizontal:1
	,OrientationType_Vertical:2
; enum DockPosition Contains values that specify the location of a docking window represented by the Dock control pattern.
	,DockPosition_Top:0
	,DockPosition_Left:1
	,DockPosition_Bottom:2
	,DockPosition_Right:3
	,DockPosition_Fill:4
	,DockPosition_None:5
; enum ExpandCollapseState Contains values that specify the state of a UI element that can be expanded and collapsed.
	,ExpandCollapseState_Collapsed:0
	,ExpandCollapseState_Expanded:1
	,ExpandCollapseState_PartiallyExpanded:2
	,ExpandCollapseState_LeafNode:3
; enum ScrollAmount Contains values that specify the direction and distance to scroll.
	,ScrollAmount_LargeDecrement:0
	,ScrollAmount_SmallDecrement:1
	,ScrollAmount_NoAmount:2
	,ScrollAmount_LargeIncrement:3
	,ScrollAmount_SmallIncrement:4
; enum RowOrColumnMajor Contains values that specify whether data in a table should be read primarily by row or by column.
	,RowOrColumnMajor_RowMajor:0
	,RowOrColumnMajor_ColumnMajor:1
	,RowOrColumnMajor_Indeterminate:2   
; enum ToggleState Contains values that specify the toggle state of a Microsoft UI Automation element that implements the Toggle control pattern.
	,ToggleState_Off:0
	,ToggleState_On:1
	,ToggleState_Indeterminate:2	
; enum WindowVisualState Contains values that specify the visual state of a window.
	,WindowVisualState_Normal:0
	,WindowVisualState_Maximized:1
	,WindowVisualState_Minimized:2
; enum SynchronizedInputType Contains values that specify the type of synchronized input.
	,SynchronizedInputType_KeyUp:0x1
	,SynchronizedInputType_KeyDown:0x2
	,SynchronizedInputType_LeftMouseUp:0x4
	,SynchronizedInputType_LeftMouseDown:0x8
	,SynchronizedInputType_RightMouseUp:0x10
	,SynchronizedInputType_RightMouseDown:0x20
; enum WindowInteractionState Contains values that specify the current state of the window for purposes of user interaction.
	,WindowInteractionState_Running:0
	,WindowInteractionState_Closing:1
	,WindowInteractionState_ReadyForUserInteraction:2
	,WindowInteractionState_BlockedByModalWindow:3
; enum textUnit Contains values that specify units of text for the purposes of navigation.
	,TextUnit_Character:0
	,TextUnit_Format:1
	,TextUnit_Word:2
	,TextUnit_Line:3
	,TextUnit_Paragraph:4
	,TextUnit_Page:5
	,TextUnit_Document:6
; enum TextPatternRangeEndpoint Contains values that specify the endpoints of a text range.
	,TextPatternRangeEndpoint_Start:0
	,TextPatternRangeEndpoint_End:1
; enum SupportedTextSelection Contains values that specify the supported text selection attribute.
	,SupportedTextSelection_Multiple:2
	,SupportedTextSelection_None:0
	,SupportedTextSelection_Single:1}
/*
;; IAccessible
; enum SELFLAG specify how an accessible object becomes selected or takes the focus. http://msdn.microsoft.com/en-us/library/dd373634(v=vs.85).aspx
	,SELFLAG_NONE:0
	,SELFLAG_TAKEFOCUS:0x1
	,SELFLAG_TAKESELECTION:0x2
	,SELFLAG_EXTENDSELECTION:0x4
	,SELFLAG_ADDSELECTION:0x8
	,SELFLAG_REMOVESELECTION:0x10
	,SELFLAG_VALID:0x1f
; enum Roles describe the roles of various UI objects in an application. http://msdn.microsoft.com/en-us/library/dd373608%28v=vs.85%29.aspx
	,ROLE_SYSTEM_TITLEBAR:0x1
	,ROLE_SYSTEM_MENUBAR:0x2
	,ROLE_SYSTEM_SCROLLBAR:0x3
	,ROLE_SYSTEM_GRIP:0x4
	,ROLE_SYSTEM_SOUND:0x5
	,ROLE_SYSTEM_CURSOR:0x6
	,ROLE_SYSTEM_CARET:0x7
	,ROLE_SYSTEM_ALERT:0x8
	,ROLE_SYSTEM_WINDOW:0x9
	,ROLE_SYSTEM_CLIENT:0xa
	,ROLE_SYSTEM_MENUPOPUP:0xb
	,ROLE_SYSTEM_MENUITEM:0xc
	,ROLE_SYSTEM_TOOLTIP:0xd
	,ROLE_SYSTEM_APPLICATION:0xe
	,ROLE_SYSTEM_DOCUMENT:0xf
	,ROLE_SYSTEM_PANE:0x10
	,ROLE_SYSTEM_CHART:0x11
	,ROLE_SYSTEM_DIALOG:0x12
	,ROLE_SYSTEM_BORDER:0x13
	,ROLE_SYSTEM_GROUPING:0x14
	,ROLE_SYSTEM_SEPARATOR:0x15
	,ROLE_SYSTEM_TOOLBAR:0x16
	,ROLE_SYSTEM_STATUSBAR:0x17
	,ROLE_SYSTEM_TABLE:0x18
	,ROLE_SYSTEM_COLUMNHEADER:0x19
	,ROLE_SYSTEM_ROWHEADER:0x1a
	,ROLE_SYSTEM_COLUMN:0x1b
	,ROLE_SYSTEM_ROW:0x1c
	,ROLE_SYSTEM_CELL:0x1d
	,ROLE_SYSTEM_LINK:0x1e
	,ROLE_SYSTEM_HELPBALLOON:0x1f
	,ROLE_SYSTEM_CHARACTER:0x20
	,ROLE_SYSTEM_LIST:0x21
	,ROLE_SYSTEM_LISTITEM:0x22
	,ROLE_SYSTEM_OUTLINE:0x23
	,ROLE_SYSTEM_OUTLINEITEM:0x24
	,ROLE_SYSTEM_PAGETAB:0x25
	,ROLE_SYSTEM_PROPERTYPAGE:0x26
	,ROLE_SYSTEM_INDICATOR:0x27
	,ROLE_SYSTEM_GRAPHIC:0x28
	,ROLE_SYSTEM_STATICTEXT:0x29
	,ROLE_SYSTEM_TEXT:0x2a
	,ROLE_SYSTEM_PUSHBUTTON:0x2b
	,ROLE_SYSTEM_CHECKBUTTON:0x2c
	,ROLE_SYSTEM_RADIOBUTTON:0x2d
	,ROLE_SYSTEM_COMBOBOX:0x2e
	,ROLE_SYSTEM_DROPLIST:0x2f
	,ROLE_SYSTEM_PROGRESSBAR:0x30
	,ROLE_SYSTEM_DIAL:0x31
	,ROLE_SYSTEM_HOTKEYFIELD:0x32
	,ROLE_SYSTEM_SLIDER:0x33
	,ROLE_SYSTEM_SPINBUTTON:0x34
	,ROLE_SYSTEM_DIAGRAM:0x35
	,ROLE_SYSTEM_ANIMATION:0x36
	,ROLE_SYSTEM_EQUATION:0x37
	,ROLE_SYSTEM_BUTTONDROPDOWN:0x38
	,ROLE_SYSTEM_BUTTONMENU:0x39
	,ROLE_SYSTEM_BUTTONDROPDOWNGRID:0x3a
	,ROLE_SYSTEM_WHITESPACE:0x3b
	,ROLE_SYSTEM_PAGETABLIST:0x3c
	,ROLE_SYSTEM_CLOCK:0x3d
	,ROLE_SYSTEM_SPLITBUTTON:0x3e
	,ROLE_SYSTEM_IPADDRESS:0x3f
	,ROLE_SYSTEM_OUTLINEBUTTON:0x40
; enum State describe the state of objects in an application UI. http://msdn.microsoft.com/en-us/library/dd373609%28v=vs.85%29.aspx
	,STATE_SYSTEM_NORMAL:0
	,STATE_SYSTEM_UNAVAILABLE:0x1
	,STATE_SYSTEM_SELECTED:0x2
	,STATE_SYSTEM_FOCUSED:0x4
	,STATE_SYSTEM_PRESSED:0x8
	,STATE_SYSTEM_CHECKED:0x10
	,STATE_SYSTEM_MIXED:0x20
	,STATE_SYSTEM_INDETERMINATE:0x20
	,STATE_SYSTEM_READONLY:0x40
	,STATE_SYSTEM_HOTTRACKED:0x80
	,STATE_SYSTEM_DEFAULT:0x100
	,STATE_SYSTEM_EXPANDED:0x200
	,STATE_SYSTEM_COLLAPSED:0x400
	,STATE_SYSTEM_BUSY:0x800
	,STATE_SYSTEM_FLOATING:0x1000
	,STATE_SYSTEM_MARQUEED:0x2000
	,STATE_SYSTEM_ANIMATED:0x4000
	,STATE_SYSTEM_INVISIBLE:0x8000
	,STATE_SYSTEM_OFFSCREEN:0x10000
	,STATE_SYSTEM_SIZEABLE:0x20000
	,STATE_SYSTEM_MOVEABLE:0x40000
	,STATE_SYSTEM_SELFVOICING:0x80000
	,STATE_SYSTEM_FOCUSABLE:0x100000
	,STATE_SYSTEM_SELECTABLE:0x200000
	,STATE_SYSTEM_LINKED:0x400000
	,STATE_SYSTEM_TRAVERSED:0x800000
	,STATE_SYSTEM_MULTISELECTABLE:0x1000000
	,STATE_SYSTEM_EXTSELECTABLE:0x2000000
	,STATE_SYSTEM_ALERT_LOW:0x4000000
	,STATE_SYSTEM_ALERT_MEDIUM:0x8000000
	,STATE_SYSTEM_ALERT_HIGH:0x10000000
	,STATE_SYSTEM_PROTECTED:0x20000000
	,STATE_SYSTEM_VALID:0x7fffffff
	,STATE_SYSTEM_HASPOPUP:0x40000000
; enum Event describes the events that are generated by the operating system and by server applications. http://msdn.microsoft.com/en-us/library/dd318066%28v=vs.85%29.aspx
	,EVENT_MIN:0x00000001
	,EVENT_MAX:0x7FFFFFFF
	,EVENT_SYSTEM_SOUND:0x0001
	,EVENT_SYSTEM_ALERT:0x0002
	,EVENT_SYSTEM_FOREGROUND:0x0003
	,EVENT_SYSTEM_MENUSTART:0x0004
	,EVENT_SYSTEM_MENUEND:0x0005
	,EVENT_SYSTEM_MENUPOPUPSTART:0x0006
	,EVENT_SYSTEM_MENUPOPUPEND:0x0007
	,EVENT_SYSTEM_CAPTURESTART:0x0008
	,EVENT_SYSTEM_CAPTUREEND:0x0009
	,EVENT_SYSTEM_MOVESIZESTART:0x000A
	,EVENT_SYSTEM_MOVESIZEEND:0x000B
	,EVENT_SYSTEM_CONTEXTHELPSTART:0x000C
	,EVENT_SYSTEM_CONTEXTHELPEND:0x000D
	,EVENT_SYSTEM_DRAGDROPSTART:0x000E
	,EVENT_SYSTEM_DRAGDROPEND:0x000F
	,EVENT_SYSTEM_DIALOGSTART:0x0010
	,EVENT_SYSTEM_DIALOGEND:0x0011
	,EVENT_SYSTEM_SCROLLINGSTART:0x0012
	,EVENT_SYSTEM_SCROLLINGEND:0x0013
	,EVENT_SYSTEM_SWITCHSTART:0x0014
	,EVENT_SYSTEM_SWITCHEND:0x0015
	,EVENT_SYSTEM_MINIMIZESTART:0x0016
	,EVENT_SYSTEM_MINIMIZEEND:0x0017
	,EVENT_SYSTEM_DESKTOPSWITCH:0x0020
	,EVENT_SYSTEM_END:0x00FF
	,EVENT_OEM_DEFINED_START:0x0101
	,EVENT_OEM_DEFINED_END:0x01FF
	,EVENT_UIA_EVENTID_START:0x4E00
	,EVENT_UIA_EVENTID_END:0x4EFF
	,EVENT_UIA_PROPID_START:0x7500
	,EVENT_UIA_PROPID_END:0x75FF
	,EVENT_CONSOLE_CARET:0x4001
	,EVENT_CONSOLE_UPDATE_REGION:0x4002
	,EVENT_CONSOLE_UPDATE_SIMPLE:0x4003
	,EVENT_CONSOLE_UPDATE_SCROLL:0x4004
	,EVENT_CONSOLE_LAYOUT:0x4005
	,EVENT_CONSOLE_START_APPLICATION:0x4006
	,EVENT_CONSOLE_END_APPLICATION:0x4007
	,EVENT_CONSOLE_END:0x40FF
	,EVENT_OBJECT_CREATE:0x8000
	,EVENT_OBJECT_DESTROY:0x8001
	,EVENT_OBJECT_SHOW:0x8002
	,EVENT_OBJECT_HIDE:0x8003
	,EVENT_OBJECT_REORDER:0x8004
	,EVENT_OBJECT_FOCUS:0x8005
	,EVENT_OBJECT_SELECTION:0x8006
	,EVENT_OBJECT_SELECTIONADD:0x8007
	,EVENT_OBJECT_SELECTIONREMOVE:0x8008
	,EVENT_OBJECT_SELECTIONWITHIN:0x8009
	,EVENT_OBJECT_STATECHANGE:0x800A
	,EVENT_OBJECT_LOCATIONCHANGE:0x800B
	,EVENT_OBJECT_NAMECHANGE:0x800C
	,EVENT_OBJECT_DESCRIPTIONCHANGE:0x800D
	,EVENT_OBJECT_VALUECHANGE:0x800E
	,EVENT_OBJECT_PARENTCHANGE:0x800F
	,EVENT_OBJECT_HELPCHANGE:0x8010
	,EVENT_OBJECT_DEFACTIONCHANGE:0x8011
	,EVENT_OBJECT_ACCELERATORCHANGE:0x8012
	,EVENT_OBJECT_INVOKED:0x8013
	,EVENT_OBJECT_TEXTSELECTIONCHANGED:0x8014
	,EVENT_OBJECT_CONTENTSCROLLED:0x8015
	,EVENT_SYSTEM_ARRANGMENTPREVIEW:0x8016
	,EVENT_OBJECT_END:0x80FF
	,EVENT_AIA_START:0xA000
	,EVENT_AIA_END:0xAFFF
; enum Navigation indicate the spatial (up, down, left, and right) or logical (first child, last, next, and previous) direction observed when clients use IAccessible::accNavigate to navigate from one user interface element to another within the same container. http://msdn.microsoft.com/en-us/library/dd373600%28v=vs.85%29.aspx
	,NAVDIR_MIN:0
	,NAVDIR_UP:1
	,NAVDIR_DOWN:2
	,NAVDIR_LEFT:3
	,NAVDIR_RIGHT:4
	,NAVDIR_NEXT:5
	,NAVDIR_PREVIOUS:6
	,NAVDIR_FIRSTCHILD:7
	,NAVDIR_LASTCHILD:8
	,NAVDIR_MAX:9
; enum Object Identifiers determine the object to which a WM_GETOBJECT message request refers. http://msdn.microsoft.com/en-us/library/dd373606%28v=vs.85%29.aspx
	,OBJID_WINDOW:0
	,OBJID_SYSMENU:-1
	,OBJID_TITLEBAR:-2
	,OBJID_MENU:-3
	,OBJID_CLIENT:-4
	,OBJID_VSCROLL:-5
	,OBJID_HSCROLL:-6
	,OBJID_SIZEGRIP:-7
	,OBJID_CARET:-8
	,OBJID_CURSOR:-9
	,OBJID_ALERT:-10
	,OBJID_SOUND:-11
	,OBJID_QUERYCLASSNAMEIDX:-12
	,OBJID_NATIVEOM:-16
*/
	return _[t]
}

;;;;;;;;;;;;;;;;;;
;;Base Functions;;
;;;;;;;;;;;;;;;;;;

; vtable
vt(p,n){
	return NumGet(NumGet(p+0,"ptr")+n*A_PtrSize,"ptr")
}

; riid
GUID(ByRef GUID, sGUID){
	  VarSetCapacity(GUID, 16, 0)
	  return DllCall("ole32\CLSIDFromString", "wstr", sGUID, "ptr", &GUID) >= 0 ? &GUID : ""
}
