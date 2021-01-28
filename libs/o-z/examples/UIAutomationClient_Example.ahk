; to use this example code first convert the type library UIAutomationClient with TypeLib2AHK

#Include UIAutomationClient_1_0_64bit.ahk  ; comment out as necessary
;~ #Include UIAutomationClient_1_0_32bit.ahk  ; uncomment as necessary

^LButton::gosub, UILoad

return

UILoad:
; Instantiate the CoClass; retrieves wrapper for IUIAutomation interface
UIA:=CUIAutomation()

; definition to set the correct variant type for CreatePropertyCondition below
Vt_Bool:=11

; Call an interface function; retrieves wrapper of the root IUIAutomationElement in the active window
CurrentWinRootElem := UIA.ElementFromHandle(WinExist("A"))

t:= "Root element:`n"
; gather information about the element
t.= ElemInfo(CurrentWinRootElem)
t.= "`n"

; The function CreateAndConditionFromArray expects a SAFEARRAY. The SAFEARRAY can be passed directly
; or as shown here as an AHK object which is then converted by the wrapper
Conditions:=Object()
; only collect elements which are not offscreen
Conditions.Push(UIA.CreatePropertyCondition(UIAutomationClientTLConst.UIA_IsOffscreenPropertyId, False, Vt_Bool))
; only collect elements which are controls
Conditions.Push(UIA.ControlViewCondition)
; combine the above conditions with and
Condition := UIA.CreateAndConditionFromArray(Conditions)

; retrieve all decendants of the root element which meet the conditions
Descendants:=CurrentWinRootElem.FindAll(UIAutomationClientTLConst.TreeScope_Descendants, Condition)

; retrieve how many descendants were found
t.="Number of descendants: " Descendants.Length "`n`n"

; gather information about the first descendant element
t.= "First descendant element:`n"
; gather information about the first descendant element
t.=ElemInfo(Descendants.GetElement(1))

; display the result
msgbox, % t
return

ElemInfo(elem)
{
	; retrieve various properties of the IUIAutomationElement
	t := "Type: " UIAutomationClientTLConst.UIA_ControlTypeIds(elem.CurrentControlType) "`n"
	t .= "Name:`t " elem.CurrentName "`n"
	; CurrentBoundingRectangle returns a tagRECT structure which is defined in the type library and also wrapped into an AHK object
	rect := elem.CurrentBoundingRectangle
	t .= "Location:`t Left: " rect.Left " Top: " rect.Top " Right: " rect.Right " Bottom: " rect.Bottom "`n"
	; GetClickablePoint expects a tagPOINT structure as parameter
	; the structure can either be passed as an instance of the tagPOINT-wrapper as defined in the type library
	point:=new tagPOINT()
	out:=elem.GetClickablePoint(point)
	t.="Clickable point (using tagPoint structure): x: " point.x " y: " point.y " Has clickable point: " out "`n"
	; or it can be passed as a buffer of the right size
	VarSetCapacity(p,tagPOINT.__SizeOf(),0)
	out:=elem.GetClickablePoint(p)
	point:=new tagPOINT(p)
	t.="Clickable point (using buffer): x: " point.x " y: " point.y " Has clickable point: " out "`n"
	return t
}