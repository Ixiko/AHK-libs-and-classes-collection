; *************************************************************************
; This file: "UIAutomationClient_1_0_64bit.ahk"
; was generated from the type library:
; UIAutomationClient  version: 1.0
;
; with TypeLib2AHK version: 0.9.5.0 by Elgin.
;
; GUID: "{944DE083-8FB8-45CF-BCB7-C477ACB2F897}"
; LCID: 0
; HelpFile
; HelpContext: 0
; System: WIN64
; Flags: FHASDISKIMAGE
; *************************************************************************

; *************************************************************************
; *************************************************************************
; CoClasses defined in type library
; *************************************************************************
; *************************************************************************

; *************************************************************************
; CUIAutomation
; *************************************************************************

/*
GUID: {FF48DBA4-60EF-4201-AA87-54103EEF594E}
Implements: IUIAutomation; GUID: {30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}; Flags: IMPLTYPEFLAG_FDEFAULT
*/

CUIAutomation()
{
	try
	{
		If (impl:=ComObjCreate("{FF48DBA4-60EF-4201-AA87-54103EEF594E}","{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}"))
			return new IUIAutomation(impl)
		throw "IUIAutomation Interface failed to initialize."
	}
	catch e
		MsgBox, 262160, IUIAutomation Error, % IsObject(e)?"IUIAutomation Interface is not registered.":e.Message
}

; *************************************************************************
; CUIAutomation8
; *************************************************************************

/*
GUID: {E22AD333-B25F-460C-83D0-0581107395C9}
Implements: IUIAutomation2; GUID: {34723AFF-0C9D-49D0-9896-7AB52DF8CD8A}; Flags: IMPLTYPEFLAG_FDEFAULT
Implements: IUIAutomation3; GUID: {73D768DA-9B51-4B89-936E-C209290973E7}; Flags:
Implements: IUIAutomation4; GUID: {1189C02A-05F8-4319-8E21-E817E3DB2860}; Flags:
*/

CUIAutomation8()
{
	try
	{
		If (impl:=ComObjCreate("{E22AD333-B25F-460C-83D0-0581107395C9}","{34723AFF-0C9D-49D0-9896-7AB52DF8CD8A}"))
			return new IUIAutomation2(impl)
		throw "IUIAutomation2 Interface failed to initialize."
	}
	catch e
		MsgBox, 262160, IUIAutomation2 Error, % IsObject(e)?"IUIAutomation2 Interface is not registered.":e.Message
}

; *************************************************************************
; *************************************************************************
; Enumerations defined in type library
; *************************************************************************
; *************************************************************************

class UIAutomationClientTLConst
{
	; *************************************************************************
	; Constants for: TreeScope
	; *************************************************************************

	static TreeScope_None := 0x0
	static TreeScope_Element := 0x1
	static TreeScope_Children := 0x2
	static TreeScope_Descendants := 0x4
	static TreeScope_Parent := 0x8
	static TreeScope_Ancestors := 0x10
	static TreeScope_Subtree := 0x7

	TreeScope(Value)
	{
		static v1:={0x0:"TreeScope_None", 0x1:"TreeScope_Element", 0x2:"TreeScope_Children", 0x4:"TreeScope_Descendants", 0x8:"TreeScope_Parent", 0x10:"TreeScope_Ancestors", 0x7:"TreeScope_Subtree"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: AutomationElementMode
	; *************************************************************************

	static AutomationElementMode_None := 0x0
	static AutomationElementMode_Full := 0x1

	AutomationElementMode(Value)
	{
		static v1:={0x0:"AutomationElementMode_None", 0x1:"AutomationElementMode_Full"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: OrientationType
	; *************************************************************************

	static OrientationType_None := 0x0
	static OrientationType_Horizontal := 0x1
	static OrientationType_Vertical := 0x2

	OrientationType(Value)
	{
		static v1:={0x0:"OrientationType_None", 0x1:"OrientationType_Horizontal", 0x2:"OrientationType_Vertical"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: PropertyConditionFlags
	; *************************************************************************

	static PropertyConditionFlags_None := 0x0
	static PropertyConditionFlags_IgnoreCase := 0x1

	PropertyConditionFlags(Value)
	{
		static v1:={0x0:"PropertyConditionFlags_None", 0x1:"PropertyConditionFlags_IgnoreCase"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: StructureChangeType
	; *************************************************************************

	static StructureChangeType_ChildAdded := 0x0
	static StructureChangeType_ChildRemoved := 0x1
	static StructureChangeType_ChildrenInvalidated := 0x2
	static StructureChangeType_ChildrenBulkAdded := 0x3
	static StructureChangeType_ChildrenBulkRemoved := 0x4
	static StructureChangeType_ChildrenReordered := 0x5

	StructureChangeType(Value)
	{
		static v1:={0x0:"StructureChangeType_ChildAdded", 0x1:"StructureChangeType_ChildRemoved", 0x2:"StructureChangeType_ChildrenInvalidated", 0x3:"StructureChangeType_ChildrenBulkAdded", 0x4:"StructureChangeType_ChildrenBulkRemoved", 0x5:"StructureChangeType_ChildrenReordered"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: TextEditChangeType
	; *************************************************************************

	static TextEditChangeType_None := 0x0
	static TextEditChangeType_AutoCorrect := 0x1
	static TextEditChangeType_Composition := 0x2
	static TextEditChangeType_CompositionFinalized := 0x3
	static TextEditChangeType_AutoComplete := 0x4

	TextEditChangeType(Value)
	{
		static v1:={0x0:"TextEditChangeType_None", 0x1:"TextEditChangeType_AutoCorrect", 0x2:"TextEditChangeType_Composition", 0x3:"TextEditChangeType_CompositionFinalized", 0x4:"TextEditChangeType_AutoComplete"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: DockPosition
	; *************************************************************************

	static DockPosition_Top := 0x0
	static DockPosition_Left := 0x1
	static DockPosition_Bottom := 0x2
	static DockPosition_Right := 0x3
	static DockPosition_Fill := 0x4
	static DockPosition_None := 0x5

	DockPosition(Value)
	{
		static v1:={0x0:"DockPosition_Top", 0x1:"DockPosition_Left", 0x2:"DockPosition_Bottom", 0x3:"DockPosition_Right", 0x4:"DockPosition_Fill", 0x5:"DockPosition_None"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: ExpandCollapseState
	; *************************************************************************

	static ExpandCollapseState_Collapsed := 0x0
	static ExpandCollapseState_Expanded := 0x1
	static ExpandCollapseState_PartiallyExpanded := 0x2
	static ExpandCollapseState_LeafNode := 0x3

	ExpandCollapseState(Value)
	{
		static v1:={0x0:"ExpandCollapseState_Collapsed", 0x1:"ExpandCollapseState_Expanded", 0x2:"ExpandCollapseState_PartiallyExpanded", 0x3:"ExpandCollapseState_LeafNode"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: ScrollAmount
	; *************************************************************************

	static ScrollAmount_LargeDecrement := 0x0
	static ScrollAmount_SmallDecrement := 0x1
	static ScrollAmount_NoAmount := 0x2
	static ScrollAmount_LargeIncrement := 0x3
	static ScrollAmount_SmallIncrement := 0x4

	ScrollAmount(Value)
	{
		static v1:={0x0:"ScrollAmount_LargeDecrement", 0x1:"ScrollAmount_SmallDecrement", 0x2:"ScrollAmount_NoAmount", 0x3:"ScrollAmount_LargeIncrement", 0x4:"ScrollAmount_SmallIncrement"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: SynchronizedInputType
	; *************************************************************************

	static SynchronizedInputType_KeyUp := 0x1
	static SynchronizedInputType_KeyDown := 0x2
	static SynchronizedInputType_LeftMouseUp := 0x4
	static SynchronizedInputType_LeftMouseDown := 0x8
	static SynchronizedInputType_RightMouseUp := 0x10
	static SynchronizedInputType_RightMouseDown := 0x20

	SynchronizedInputType(Value)
	{
		static v1:={0x1:"SynchronizedInputType_KeyUp", 0x2:"SynchronizedInputType_KeyDown", 0x4:"SynchronizedInputType_LeftMouseUp", 0x8:"SynchronizedInputType_LeftMouseDown", 0x10:"SynchronizedInputType_RightMouseUp", 0x20:"SynchronizedInputType_RightMouseDown"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: RowOrColumnMajor
	; *************************************************************************

	static RowOrColumnMajor_RowMajor := 0x0
	static RowOrColumnMajor_ColumnMajor := 0x1
	static RowOrColumnMajor_Indeterminate := 0x2

	RowOrColumnMajor(Value)
	{
		static v1:={0x0:"RowOrColumnMajor_RowMajor", 0x1:"RowOrColumnMajor_ColumnMajor", 0x2:"RowOrColumnMajor_Indeterminate"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: ToggleState
	; *************************************************************************

	static ToggleState_Off := 0x0
	static ToggleState_On := 0x1
	static ToggleState_Indeterminate := 0x2

	ToggleState(Value)
	{
		static v1:={0x0:"ToggleState_Off", 0x1:"ToggleState_On", 0x2:"ToggleState_Indeterminate"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: WindowVisualState
	; *************************************************************************

	static WindowVisualState_Normal := 0x0
	static WindowVisualState_Maximized := 0x1
	static WindowVisualState_Minimized := 0x2

	WindowVisualState(Value)
	{
		static v1:={0x0:"WindowVisualState_Normal", 0x1:"WindowVisualState_Maximized", 0x2:"WindowVisualState_Minimized"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: WindowInteractionState
	; *************************************************************************

	static WindowInteractionState_Running := 0x0
	static WindowInteractionState_Closing := 0x1
	static WindowInteractionState_ReadyForUserInteraction := 0x2
	static WindowInteractionState_BlockedByModalWindow := 0x3
	static WindowInteractionState_NotResponding := 0x4

	WindowInteractionState(Value)
	{
		static v1:={0x0:"WindowInteractionState_Running", 0x1:"WindowInteractionState_Closing", 0x2:"WindowInteractionState_ReadyForUserInteraction", 0x3:"WindowInteractionState_BlockedByModalWindow", 0x4:"WindowInteractionState_NotResponding"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: TextPatternRangeEndpoint
	; *************************************************************************

	static TextPatternRangeEndpoint_Start := 0x0
	static TextPatternRangeEndpoint_End := 0x1

	TextPatternRangeEndpoint(Value)
	{
		static v1:={0x0:"TextPatternRangeEndpoint_Start", 0x1:"TextPatternRangeEndpoint_End"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: TextUnit
	; *************************************************************************

	static TextUnit_Character := 0x0
	static TextUnit_Format := 0x1
	static TextUnit_Word := 0x2
	static TextUnit_Line := 0x3
	static TextUnit_Paragraph := 0x4
	static TextUnit_Page := 0x5
	static TextUnit_Document := 0x6

	TextUnit(Value)
	{
		static v1:={0x0:"TextUnit_Character", 0x1:"TextUnit_Format", 0x2:"TextUnit_Word", 0x3:"TextUnit_Line", 0x4:"TextUnit_Paragraph", 0x5:"TextUnit_Page", 0x6:"TextUnit_Document"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: SupportedTextSelection
	; *************************************************************************

	static SupportedTextSelection_None := 0x0
	static SupportedTextSelection_Single := 0x1
	static SupportedTextSelection_Multiple := 0x2

	SupportedTextSelection(Value)
	{
		static v1:={0x0:"SupportedTextSelection_None", 0x1:"SupportedTextSelection_Single", 0x2:"SupportedTextSelection_Multiple"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: NavigateDirection
	; *************************************************************************

	static NavigateDirection_Parent := 0x0
	static NavigateDirection_NextSibling := 0x1
	static NavigateDirection_PreviousSibling := 0x2
	static NavigateDirection_FirstChild := 0x3
	static NavigateDirection_LastChild := 0x4

	NavigateDirection(Value)
	{
		static v1:={0x0:"NavigateDirection_Parent", 0x1:"NavigateDirection_NextSibling", 0x2:"NavigateDirection_PreviousSibling", 0x3:"NavigateDirection_FirstChild", 0x4:"NavigateDirection_LastChild"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: ZoomUnit
	; *************************************************************************

	static ZoomUnit_NoAmount := 0x0
	static ZoomUnit_LargeDecrement := 0x1
	static ZoomUnit_SmallDecrement := 0x2
	static ZoomUnit_LargeIncrement := 0x3
	static ZoomUnit_SmallIncrement := 0x4

	ZoomUnit(Value)
	{
		static v1:={0x0:"ZoomUnit_NoAmount", 0x1:"ZoomUnit_LargeDecrement", 0x2:"ZoomUnit_SmallDecrement", 0x3:"ZoomUnit_LargeIncrement", 0x4:"ZoomUnit_SmallIncrement"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: LiveSetting
	; *************************************************************************

	static Off := 0x0
	static Polite := 0x1
	static Assertive := 0x2

	LiveSetting(Value)
	{
		static v1:={0x0:"Off", 0x1:"Polite", 0x2:"Assertive"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: TreeTraversalOptions
	; *************************************************************************

	static TreeTraversalOptions_Default := 0x0
	static TreeTraversalOptions_PostOrder := 0x1
	static TreeTraversalOptions_LastToFirstOrder := 0x2

	TreeTraversalOptions(Value)
	{
		static v1:={0x0:"TreeTraversalOptions_Default", 0x1:"TreeTraversalOptions_PostOrder", 0x2:"TreeTraversalOptions_LastToFirstOrder"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: ProviderOptions
	; *************************************************************************

	static ProviderOptions_ClientSideProvider := 0x1
	static ProviderOptions_ServerSideProvider := 0x2
	static ProviderOptions_NonClientAreaProvider := 0x4
	static ProviderOptions_OverrideProvider := 0x8
	static ProviderOptions_ProviderOwnsSetFocus := 0x10
	static ProviderOptions_UseComThreading := 0x20
	static ProviderOptions_RefuseNonClientSupport := 0x40
	static ProviderOptions_HasNativeIAccessible := 0x80
	static ProviderOptions_UseClientCoordinates := 0x100

	ProviderOptions(Value)
	{
		static v1:={0x1:"ProviderOptions_ClientSideProvider", 0x2:"ProviderOptions_ServerSideProvider", 0x4:"ProviderOptions_NonClientAreaProvider", 0x8:"ProviderOptions_OverrideProvider", 0x10:"ProviderOptions_ProviderOwnsSetFocus", 0x20:"ProviderOptions_UseComThreading", 0x40:"ProviderOptions_RefuseNonClientSupport", 0x80:"ProviderOptions_HasNativeIAccessible", 0x100:"ProviderOptions_UseClientCoordinates"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: UIA_PatternIds
	; *************************************************************************

	static UIA_InvokePatternId := 10000  ; Type: Vt_I4
	static UIA_SelectionPatternId := 10001  ; Type: Vt_I4
	static UIA_ValuePatternId := 10002  ; Type: Vt_I4
	static UIA_RangeValuePatternId := 10003  ; Type: Vt_I4
	static UIA_ScrollPatternId := 10004  ; Type: Vt_I4
	static UIA_ExpandCollapsePatternId := 10005  ; Type: Vt_I4
	static UIA_GridPatternId := 10006  ; Type: Vt_I4
	static UIA_GridItemPatternId := 10007  ; Type: Vt_I4
	static UIA_MultipleViewPatternId := 10008  ; Type: Vt_I4
	static UIA_WindowPatternId := 10009  ; Type: Vt_I4
	static UIA_SelectionItemPatternId := 10010  ; Type: Vt_I4
	static UIA_DockPatternId := 10011  ; Type: Vt_I4
	static UIA_TablePatternId := 10012  ; Type: Vt_I4
	static UIA_TableItemPatternId := 10013  ; Type: Vt_I4
	static UIA_TextPatternId := 10014  ; Type: Vt_I4
	static UIA_TogglePatternId := 10015  ; Type: Vt_I4
	static UIA_TransformPatternId := 10016  ; Type: Vt_I4
	static UIA_ScrollItemPatternId := 10017  ; Type: Vt_I4
	static UIA_LegacyIAccessiblePatternId := 10018  ; Type: Vt_I4
	static UIA_ItemContainerPatternId := 10019  ; Type: Vt_I4
	static UIA_VirtualizedItemPatternId := 10020  ; Type: Vt_I4
	static UIA_SynchronizedInputPatternId := 10021  ; Type: Vt_I4
	static UIA_ObjectModelPatternId := 10022  ; Type: Vt_I4
	static UIA_AnnotationPatternId := 10023  ; Type: Vt_I4
	static UIA_TextPattern2Id := 10024  ; Type: Vt_I4
	static UIA_StylesPatternId := 10025  ; Type: Vt_I4
	static UIA_SpreadsheetPatternId := 10026  ; Type: Vt_I4
	static UIA_SpreadsheetItemPatternId := 10027  ; Type: Vt_I4
	static UIA_TransformPattern2Id := 10028  ; Type: Vt_I4
	static UIA_TextChildPatternId := 10029  ; Type: Vt_I4
	static UIA_DragPatternId := 10030  ; Type: Vt_I4
	static UIA_DropTargetPatternId := 10031  ; Type: Vt_I4
	static UIA_TextEditPatternId := 10032  ; Type: Vt_I4
	static UIA_CustomNavigationPatternId := 10033  ; Type: Vt_I4

	UIA_PatternIds(Value)
	{
		static v1:={0x2710:"UIA_InvokePatternId", 0x2711:"UIA_SelectionPatternId", 0x2712:"UIA_ValuePatternId", 0x2713:"UIA_RangeValuePatternId", 0x2714:"UIA_ScrollPatternId", 0x2715:"UIA_ExpandCollapsePatternId", 0x2716:"UIA_GridPatternId", 0x2717:"UIA_GridItemPatternId", 0x2718:"UIA_MultipleViewPatternId", 0x2719:"UIA_WindowPatternId", 0x271A:"UIA_SelectionItemPatternId", 0x271B:"UIA_DockPatternId", 0x271C:"UIA_TablePatternId", 0x271D:"UIA_TableItemPatternId", 0x271E:"UIA_TextPatternId", 0x271F:"UIA_TogglePatternId", 0x2720:"UIA_TransformPatternId", 0x2721:"UIA_ScrollItemPatternId", 0x2722:"UIA_LegacyIAccessiblePatternId", 0x2723:"UIA_ItemContainerPatternId", 0x2724:"UIA_VirtualizedItemPatternId", 0x2725:"UIA_SynchronizedInputPatternId", 0x2726:"UIA_ObjectModelPatternId", 0x2727:"UIA_AnnotationPatternId", 0x2728:"UIA_TextPattern2Id", 0x2729:"UIA_StylesPatternId", 0x272A:"UIA_SpreadsheetPatternId", 0x272B:"UIA_SpreadsheetItemPatternId", 0x272C:"UIA_TransformPattern2Id", 0x272D:"UIA_TextChildPatternId", 0x272E:"UIA_DragPatternId", 0x272F:"UIA_DropTargetPatternId", 0x2730:"UIA_TextEditPatternId", 0x2731:"UIA_CustomNavigationPatternId"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: UIA_EventIds
	; *************************************************************************

	static UIA_ToolTipOpenedEventId := 20000  ; Type: Vt_I4
	static UIA_ToolTipClosedEventId := 20001  ; Type: Vt_I4
	static UIA_StructureChangedEventId := 20002  ; Type: Vt_I4
	static UIA_MenuOpenedEventId := 20003  ; Type: Vt_I4
	static UIA_AutomationPropertyChangedEventId := 20004  ; Type: Vt_I4
	static UIA_AutomationFocusChangedEventId := 20005  ; Type: Vt_I4
	static UIA_AsyncContentLoadedEventId := 20006  ; Type: Vt_I4
	static UIA_MenuClosedEventId := 20007  ; Type: Vt_I4
	static UIA_LayoutInvalidatedEventId := 20008  ; Type: Vt_I4
	static UIA_Invoke_InvokedEventId := 20009  ; Type: Vt_I4
	static UIA_SelectionItem_ElementAddedToSelectionEventId := 20010  ; Type: Vt_I4
	static UIA_SelectionItem_ElementRemovedFromSelectionEventId := 20011  ; Type: Vt_I4
	static UIA_SelectionItem_ElementSelectedEventId := 20012  ; Type: Vt_I4
	static UIA_Selection_InvalidatedEventId := 20013  ; Type: Vt_I4
	static UIA_Text_TextSelectionChangedEventId := 20014  ; Type: Vt_I4
	static UIA_Text_TextChangedEventId := 20015  ; Type: Vt_I4
	static UIA_Window_WindowOpenedEventId := 20016  ; Type: Vt_I4
	static UIA_Window_WindowClosedEventId := 20017  ; Type: Vt_I4
	static UIA_MenuModeStartEventId := 20018  ; Type: Vt_I4
	static UIA_MenuModeEndEventId := 20019  ; Type: Vt_I4
	static UIA_InputReachedTargetEventId := 20020  ; Type: Vt_I4
	static UIA_InputReachedOtherElementEventId := 20021  ; Type: Vt_I4
	static UIA_InputDiscardedEventId := 20022  ; Type: Vt_I4
	static UIA_SystemAlertEventId := 20023  ; Type: Vt_I4
	static UIA_LiveRegionChangedEventId := 20024  ; Type: Vt_I4
	static UIA_HostedFragmentRootsInvalidatedEventId := 20025  ; Type: Vt_I4
	static UIA_Drag_DragStartEventId := 20026  ; Type: Vt_I4
	static UIA_Drag_DragCancelEventId := 20027  ; Type: Vt_I4
	static UIA_Drag_DragCompleteEventId := 20028  ; Type: Vt_I4
	static UIA_DropTarget_DragEnterEventId := 20029  ; Type: Vt_I4
	static UIA_DropTarget_DragLeaveEventId := 20030  ; Type: Vt_I4
	static UIA_DropTarget_DroppedEventId := 20031  ; Type: Vt_I4
	static UIA_TextEdit_TextChangedEventId := 20032  ; Type: Vt_I4
	static UIA_TextEdit_ConversionTargetChangedEventId := 20033  ; Type: Vt_I4
	static UIA_ChangesEventId := 20034  ; Type: Vt_I4

	UIA_EventIds(Value)
	{
		static v1:={0x4E20:"UIA_ToolTipOpenedEventId", 0x4E21:"UIA_ToolTipClosedEventId", 0x4E22:"UIA_StructureChangedEventId", 0x4E23:"UIA_MenuOpenedEventId", 0x4E24:"UIA_AutomationPropertyChangedEventId", 0x4E25:"UIA_AutomationFocusChangedEventId", 0x4E26:"UIA_AsyncContentLoadedEventId", 0x4E27:"UIA_MenuClosedEventId", 0x4E28:"UIA_LayoutInvalidatedEventId", 0x4E29:"UIA_Invoke_InvokedEventId", 0x4E2A:"UIA_SelectionItem_ElementAddedToSelectionEventId", 0x4E2B:"UIA_SelectionItem_ElementRemovedFromSelectionEventId", 0x4E2C:"UIA_SelectionItem_ElementSelectedEventId", 0x4E2D:"UIA_Selection_InvalidatedEventId", 0x4E2E:"UIA_Text_TextSelectionChangedEventId", 0x4E2F:"UIA_Text_TextChangedEventId", 0x4E30:"UIA_Window_WindowOpenedEventId", 0x4E31:"UIA_Window_WindowClosedEventId", 0x4E32:"UIA_MenuModeStartEventId", 0x4E33:"UIA_MenuModeEndEventId", 0x4E34:"UIA_InputReachedTargetEventId", 0x4E35:"UIA_InputReachedOtherElementEventId", 0x4E36:"UIA_InputDiscardedEventId", 0x4E37:"UIA_SystemAlertEventId", 0x4E38:"UIA_LiveRegionChangedEventId", 0x4E39:"UIA_HostedFragmentRootsInvalidatedEventId", 0x4E3A:"UIA_Drag_DragStartEventId", 0x4E3B:"UIA_Drag_DragCancelEventId", 0x4E3C:"UIA_Drag_DragCompleteEventId", 0x4E3D:"UIA_DropTarget_DragEnterEventId", 0x4E3E:"UIA_DropTarget_DragLeaveEventId", 0x4E3F:"UIA_DropTarget_DroppedEventId", 0x4E40:"UIA_TextEdit_TextChangedEventId", 0x4E41:"UIA_TextEdit_ConversionTargetChangedEventId", 0x4E42:"UIA_ChangesEventId"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: UIA_PropertyIds
	; *************************************************************************

	static UIA_RuntimeIdPropertyId := 30000  ; Type: Vt_I4
	static UIA_BoundingRectanglePropertyId := 30001  ; Type: Vt_I4
	static UIA_ProcessIdPropertyId := 30002  ; Type: Vt_I4
	static UIA_ControlTypePropertyId := 30003  ; Type: Vt_I4
	static UIA_LocalizedControlTypePropertyId := 30004  ; Type: Vt_I4
	static UIA_NamePropertyId := 30005  ; Type: Vt_I4
	static UIA_AcceleratorKeyPropertyId := 30006  ; Type: Vt_I4
	static UIA_AccessKeyPropertyId := 30007  ; Type: Vt_I4
	static UIA_HasKeyboardFocusPropertyId := 30008  ; Type: Vt_I4
	static UIA_IsKeyboardFocusablePropertyId := 30009  ; Type: Vt_I4
	static UIA_IsEnabledPropertyId := 30010  ; Type: Vt_I4
	static UIA_AutomationIdPropertyId := 30011  ; Type: Vt_I4
	static UIA_ClassNamePropertyId := 30012  ; Type: Vt_I4
	static UIA_HelpTextPropertyId := 30013  ; Type: Vt_I4
	static UIA_ClickablePointPropertyId := 30014  ; Type: Vt_I4
	static UIA_CulturePropertyId := 30015  ; Type: Vt_I4
	static UIA_IsControlElementPropertyId := 30016  ; Type: Vt_I4
	static UIA_IsContentElementPropertyId := 30017  ; Type: Vt_I4
	static UIA_LabeledByPropertyId := 30018  ; Type: Vt_I4
	static UIA_IsPasswordPropertyId := 30019  ; Type: Vt_I4
	static UIA_NativeWindowHandlePropertyId := 30020  ; Type: Vt_I4
	static UIA_ItemTypePropertyId := 30021  ; Type: Vt_I4
	static UIA_IsOffscreenPropertyId := 30022  ; Type: Vt_I4
	static UIA_OrientationPropertyId := 30023  ; Type: Vt_I4
	static UIA_FrameworkIdPropertyId := 30024  ; Type: Vt_I4
	static UIA_IsRequiredForFormPropertyId := 30025  ; Type: Vt_I4
	static UIA_ItemStatusPropertyId := 30026  ; Type: Vt_I4
	static UIA_IsDockPatternAvailablePropertyId := 30027  ; Type: Vt_I4
	static UIA_IsExpandCollapsePatternAvailablePropertyId := 30028  ; Type: Vt_I4
	static UIA_IsGridItemPatternAvailablePropertyId := 30029  ; Type: Vt_I4
	static UIA_IsGridPatternAvailablePropertyId := 30030  ; Type: Vt_I4
	static UIA_IsInvokePatternAvailablePropertyId := 30031  ; Type: Vt_I4
	static UIA_IsMultipleViewPatternAvailablePropertyId := 30032  ; Type: Vt_I4
	static UIA_IsRangeValuePatternAvailablePropertyId := 30033  ; Type: Vt_I4
	static UIA_IsScrollPatternAvailablePropertyId := 30034  ; Type: Vt_I4
	static UIA_IsScrollItemPatternAvailablePropertyId := 30035  ; Type: Vt_I4
	static UIA_IsSelectionItemPatternAvailablePropertyId := 30036  ; Type: Vt_I4
	static UIA_IsSelectionPatternAvailablePropertyId := 30037  ; Type: Vt_I4
	static UIA_IsTablePatternAvailablePropertyId := 30038  ; Type: Vt_I4
	static UIA_IsTableItemPatternAvailablePropertyId := 30039  ; Type: Vt_I4
	static UIA_IsTextPatternAvailablePropertyId := 30040  ; Type: Vt_I4
	static UIA_IsTogglePatternAvailablePropertyId := 30041  ; Type: Vt_I4
	static UIA_IsTransformPatternAvailablePropertyId := 30042  ; Type: Vt_I4
	static UIA_IsValuePatternAvailablePropertyId := 30043  ; Type: Vt_I4
	static UIA_IsWindowPatternAvailablePropertyId := 30044  ; Type: Vt_I4
	static UIA_ValueValuePropertyId := 30045  ; Type: Vt_I4
	static UIA_ValueIsReadOnlyPropertyId := 30046  ; Type: Vt_I4
	static UIA_RangeValueValuePropertyId := 30047  ; Type: Vt_I4
	static UIA_RangeValueIsReadOnlyPropertyId := 30048  ; Type: Vt_I4
	static UIA_RangeValueMinimumPropertyId := 30049  ; Type: Vt_I4
	static UIA_RangeValueMaximumPropertyId := 30050  ; Type: Vt_I4
	static UIA_RangeValueLargeChangePropertyId := 30051  ; Type: Vt_I4
	static UIA_RangeValueSmallChangePropertyId := 30052  ; Type: Vt_I4
	static UIA_ScrollHorizontalScrollPercentPropertyId := 30053  ; Type: Vt_I4
	static UIA_ScrollHorizontalViewSizePropertyId := 30054  ; Type: Vt_I4
	static UIA_ScrollVerticalScrollPercentPropertyId := 30055  ; Type: Vt_I4
	static UIA_ScrollVerticalViewSizePropertyId := 30056  ; Type: Vt_I4
	static UIA_ScrollHorizontallyScrollablePropertyId := 30057  ; Type: Vt_I4
	static UIA_ScrollVerticallyScrollablePropertyId := 30058  ; Type: Vt_I4
	static UIA_SelectionSelectionPropertyId := 30059  ; Type: Vt_I4
	static UIA_SelectionCanSelectMultiplePropertyId := 30060  ; Type: Vt_I4
	static UIA_SelectionIsSelectionRequiredPropertyId := 30061  ; Type: Vt_I4
	static UIA_GridRowCountPropertyId := 30062  ; Type: Vt_I4
	static UIA_GridColumnCountPropertyId := 30063  ; Type: Vt_I4
	static UIA_GridItemRowPropertyId := 30064  ; Type: Vt_I4
	static UIA_GridItemColumnPropertyId := 30065  ; Type: Vt_I4
	static UIA_GridItemRowSpanPropertyId := 30066  ; Type: Vt_I4
	static UIA_GridItemColumnSpanPropertyId := 30067  ; Type: Vt_I4
	static UIA_GridItemContainingGridPropertyId := 30068  ; Type: Vt_I4
	static UIA_DockDockPositionPropertyId := 30069  ; Type: Vt_I4
	static UIA_ExpandCollapseExpandCollapseStatePropertyId := 30070  ; Type: Vt_I4
	static UIA_MultipleViewCurrentViewPropertyId := 30071  ; Type: Vt_I4
	static UIA_MultipleViewSupportedViewsPropertyId := 30072  ; Type: Vt_I4
	static UIA_WindowCanMaximizePropertyId := 30073  ; Type: Vt_I4
	static UIA_WindowCanMinimizePropertyId := 30074  ; Type: Vt_I4
	static UIA_WindowWindowVisualStatePropertyId := 30075  ; Type: Vt_I4
	static UIA_WindowWindowInteractionStatePropertyId := 30076  ; Type: Vt_I4
	static UIA_WindowIsModalPropertyId := 30077  ; Type: Vt_I4
	static UIA_WindowIsTopmostPropertyId := 30078  ; Type: Vt_I4
	static UIA_SelectionItemIsSelectedPropertyId := 30079  ; Type: Vt_I4
	static UIA_SelectionItemSelectionContainerPropertyId := 30080  ; Type: Vt_I4
	static UIA_TableRowHeadersPropertyId := 30081  ; Type: Vt_I4
	static UIA_TableColumnHeadersPropertyId := 30082  ; Type: Vt_I4
	static UIA_TableRowOrColumnMajorPropertyId := 30083  ; Type: Vt_I4
	static UIA_TableItemRowHeaderItemsPropertyId := 30084  ; Type: Vt_I4
	static UIA_TableItemColumnHeaderItemsPropertyId := 30085  ; Type: Vt_I4
	static UIA_ToggleToggleStatePropertyId := 30086  ; Type: Vt_I4
	static UIA_TransformCanMovePropertyId := 30087  ; Type: Vt_I4
	static UIA_TransformCanResizePropertyId := 30088  ; Type: Vt_I4
	static UIA_TransformCanRotatePropertyId := 30089  ; Type: Vt_I4
	static UIA_IsLegacyIAccessiblePatternAvailablePropertyId := 30090  ; Type: Vt_I4
	static UIA_LegacyIAccessibleChildIdPropertyId := 30091  ; Type: Vt_I4
	static UIA_LegacyIAccessibleNamePropertyId := 30092  ; Type: Vt_I4
	static UIA_LegacyIAccessibleValuePropertyId := 30093  ; Type: Vt_I4
	static UIA_LegacyIAccessibleDescriptionPropertyId := 30094  ; Type: Vt_I4
	static UIA_LegacyIAccessibleRolePropertyId := 30095  ; Type: Vt_I4
	static UIA_LegacyIAccessibleStatePropertyId := 30096  ; Type: Vt_I4
	static UIA_LegacyIAccessibleHelpPropertyId := 30097  ; Type: Vt_I4
	static UIA_LegacyIAccessibleKeyboardShortcutPropertyId := 30098  ; Type: Vt_I4
	static UIA_LegacyIAccessibleSelectionPropertyId := 30099  ; Type: Vt_I4
	static UIA_LegacyIAccessibleDefaultActionPropertyId := 30100  ; Type: Vt_I4
	static UIA_AriaRolePropertyId := 30101  ; Type: Vt_I4
	static UIA_AriaPropertiesPropertyId := 30102  ; Type: Vt_I4
	static UIA_IsDataValidForFormPropertyId := 30103  ; Type: Vt_I4
	static UIA_ControllerForPropertyId := 30104  ; Type: Vt_I4
	static UIA_DescribedByPropertyId := 30105  ; Type: Vt_I4
	static UIA_FlowsToPropertyId := 30106  ; Type: Vt_I4
	static UIA_ProviderDescriptionPropertyId := 30107  ; Type: Vt_I4
	static UIA_IsItemContainerPatternAvailablePropertyId := 30108  ; Type: Vt_I4
	static UIA_IsVirtualizedItemPatternAvailablePropertyId := 30109  ; Type: Vt_I4
	static UIA_IsSynchronizedInputPatternAvailablePropertyId := 30110  ; Type: Vt_I4
	static UIA_OptimizeForVisualContentPropertyId := 30111  ; Type: Vt_I4
	static UIA_IsObjectModelPatternAvailablePropertyId := 30112  ; Type: Vt_I4
	static UIA_AnnotationAnnotationTypeIdPropertyId := 30113  ; Type: Vt_I4
	static UIA_AnnotationAnnotationTypeNamePropertyId := 30114  ; Type: Vt_I4
	static UIA_AnnotationAuthorPropertyId := 30115  ; Type: Vt_I4
	static UIA_AnnotationDateTimePropertyId := 30116  ; Type: Vt_I4
	static UIA_AnnotationTargetPropertyId := 30117  ; Type: Vt_I4
	static UIA_IsAnnotationPatternAvailablePropertyId := 30118  ; Type: Vt_I4
	static UIA_IsTextPattern2AvailablePropertyId := 30119  ; Type: Vt_I4
	static UIA_StylesStyleIdPropertyId := 30120  ; Type: Vt_I4
	static UIA_StylesStyleNamePropertyId := 30121  ; Type: Vt_I4
	static UIA_StylesFillColorPropertyId := 30122  ; Type: Vt_I4
	static UIA_StylesFillPatternStylePropertyId := 30123  ; Type: Vt_I4
	static UIA_StylesShapePropertyId := 30124  ; Type: Vt_I4
	static UIA_StylesFillPatternColorPropertyId := 30125  ; Type: Vt_I4
	static UIA_StylesExtendedPropertiesPropertyId := 30126  ; Type: Vt_I4
	static UIA_IsStylesPatternAvailablePropertyId := 30127  ; Type: Vt_I4
	static UIA_IsSpreadsheetPatternAvailablePropertyId := 30128  ; Type: Vt_I4
	static UIA_SpreadsheetItemFormulaPropertyId := 30129  ; Type: Vt_I4
	static UIA_SpreadsheetItemAnnotationObjectsPropertyId := 30130  ; Type: Vt_I4
	static UIA_SpreadsheetItemAnnotationTypesPropertyId := 30131  ; Type: Vt_I4
	static UIA_IsSpreadsheetItemPatternAvailablePropertyId := 30132  ; Type: Vt_I4
	static UIA_Transform2CanZoomPropertyId := 30133  ; Type: Vt_I4
	static UIA_IsTransformPattern2AvailablePropertyId := 30134  ; Type: Vt_I4
	static UIA_LiveSettingPropertyId := 30135  ; Type: Vt_I4
	static UIA_IsTextChildPatternAvailablePropertyId := 30136  ; Type: Vt_I4
	static UIA_IsDragPatternAvailablePropertyId := 30137  ; Type: Vt_I4
	static UIA_DragIsGrabbedPropertyId := 30138  ; Type: Vt_I4
	static UIA_DragDropEffectPropertyId := 30139  ; Type: Vt_I4
	static UIA_DragDropEffectsPropertyId := 30140  ; Type: Vt_I4
	static UIA_IsDropTargetPatternAvailablePropertyId := 30141  ; Type: Vt_I4
	static UIA_DropTargetDropTargetEffectPropertyId := 30142  ; Type: Vt_I4
	static UIA_DropTargetDropTargetEffectsPropertyId := 30143  ; Type: Vt_I4
	static UIA_DragGrabbedItemsPropertyId := 30144  ; Type: Vt_I4
	static UIA_Transform2ZoomLevelPropertyId := 30145  ; Type: Vt_I4
	static UIA_Transform2ZoomMinimumPropertyId := 30146  ; Type: Vt_I4
	static UIA_Transform2ZoomMaximumPropertyId := 30147  ; Type: Vt_I4
	static UIA_FlowsFromPropertyId := 30148  ; Type: Vt_I4
	static UIA_IsTextEditPatternAvailablePropertyId := 30149  ; Type: Vt_I4
	static UIA_IsPeripheralPropertyId := 30150  ; Type: Vt_I4
	static UIA_IsCustomNavigationPatternAvailablePropertyId := 30151  ; Type: Vt_I4
	static UIA_PositionInSetPropertyId := 30152  ; Type: Vt_I4
	static UIA_SizeOfSetPropertyId := 30153  ; Type: Vt_I4
	static UIA_LevelPropertyId := 30154  ; Type: Vt_I4
	static UIA_AnnotationTypesPropertyId := 30155  ; Type: Vt_I4
	static UIA_AnnotationObjectsPropertyId := 30156  ; Type: Vt_I4
	static UIA_LandmarkTypePropertyId := 30157  ; Type: Vt_I4
	static UIA_LocalizedLandmarkTypePropertyId := 30158  ; Type: Vt_I4
	static UIA_FullDescriptionPropertyId := 30159  ; Type: Vt_I4
	static UIA_FillColorPropertyId := 30160  ; Type: Vt_I4
	static UIA_OutlineColorPropertyId := 30161  ; Type: Vt_I4
	static UIA_FillTypePropertyId := 30162  ; Type: Vt_I4
	static UIA_VisualEffectsPropertyId := 30163  ; Type: Vt_I4
	static UIA_OutlineThicknessPropertyId := 30164  ; Type: Vt_I4
	static UIA_CenterPointPropertyId := 30165  ; Type: Vt_I4
	static UIA_RotationPropertyId := 30166  ; Type: Vt_I4
	static UIA_SizePropertyId := 30167  ; Type: Vt_I4

	UIA_PropertyIds(Value)
	{
		static v1:={0x7530:"UIA_RuntimeIdPropertyId", 0x7531:"UIA_BoundingRectanglePropertyId", 0x7532:"UIA_ProcessIdPropertyId", 0x7533:"UIA_ControlTypePropertyId", 0x7534:"UIA_LocalizedControlTypePropertyId", 0x7535:"UIA_NamePropertyId", 0x7536:"UIA_AcceleratorKeyPropertyId", 0x7537:"UIA_AccessKeyPropertyId", 0x7538:"UIA_HasKeyboardFocusPropertyId", 0x7539:"UIA_IsKeyboardFocusablePropertyId", 0x753A:"UIA_IsEnabledPropertyId", 0x753B:"UIA_AutomationIdPropertyId", 0x753C:"UIA_ClassNamePropertyId", 0x753D:"UIA_HelpTextPropertyId", 0x753E:"UIA_ClickablePointPropertyId", 0x753F:"UIA_CulturePropertyId", 0x7540:"UIA_IsControlElementPropertyId", 0x7541:"UIA_IsContentElementPropertyId", 0x7542:"UIA_LabeledByPropertyId", 0x7543:"UIA_IsPasswordPropertyId", 0x7544:"UIA_NativeWindowHandlePropertyId", 0x7545:"UIA_ItemTypePropertyId", 0x7546:"UIA_IsOffscreenPropertyId", 0x7547:"UIA_OrientationPropertyId", 0x7548:"UIA_FrameworkIdPropertyId", 0x7549:"UIA_IsRequiredForFormPropertyId", 0x754A:"UIA_ItemStatusPropertyId", 0x754B:"UIA_IsDockPatternAvailablePropertyId", 0x754C:"UIA_IsExpandCollapsePatternAvailablePropertyId", 0x754D:"UIA_IsGridItemPatternAvailablePropertyId", 0x754E:"UIA_IsGridPatternAvailablePropertyId", 0x754F:"UIA_IsInvokePatternAvailablePropertyId", 0x7550:"UIA_IsMultipleViewPatternAvailablePropertyId", 0x7551:"UIA_IsRangeValuePatternAvailablePropertyId", 0x7552:"UIA_IsScrollPatternAvailablePropertyId", 0x7553:"UIA_IsScrollItemPatternAvailablePropertyId", 0x7554:"UIA_IsSelectionItemPatternAvailablePropertyId", 0x7555:"UIA_IsSelectionPatternAvailablePropertyId", 0x7556:"UIA_IsTablePatternAvailablePropertyId", 0x7557:"UIA_IsTableItemPatternAvailablePropertyId", 0x7558:"UIA_IsTextPatternAvailablePropertyId", 0x7559:"UIA_IsTogglePatternAvailablePropertyId", 0x755A:"UIA_IsTransformPatternAvailablePropertyId", 0x755B:"UIA_IsValuePatternAvailablePropertyId", 0x755C:"UIA_IsWindowPatternAvailablePropertyId", 0x755D:"UIA_ValueValuePropertyId", 0x755E:"UIA_ValueIsReadOnlyPropertyId", 0x755F:"UIA_RangeValueValuePropertyId", 0x7560:"UIA_RangeValueIsReadOnlyPropertyId", 0x7561:"UIA_RangeValueMinimumPropertyId", 0x7562:"UIA_RangeValueMaximumPropertyId", 0x7563:"UIA_RangeValueLargeChangePropertyId", 0x7564:"UIA_RangeValueSmallChangePropertyId", 0x7565:"UIA_ScrollHorizontalScrollPercentPropertyId", 0x7566:"UIA_ScrollHorizontalViewSizePropertyId", 0x7567:"UIA_ScrollVerticalScrollPercentPropertyId", 0x7568:"UIA_ScrollVerticalViewSizePropertyId", 0x7569:"UIA_ScrollHorizontallyScrollablePropertyId", 0x756A:"UIA_ScrollVerticallyScrollablePropertyId", 0x756B:"UIA_SelectionSelectionPropertyId", 0x756C:"UIA_SelectionCanSelectMultiplePropertyId", 0x756D:"UIA_SelectionIsSelectionRequiredPropertyId", 0x756E:"UIA_GridRowCountPropertyId", 0x756F:"UIA_GridColumnCountPropertyId", 0x7570:"UIA_GridItemRowPropertyId", 0x7571:"UIA_GridItemColumnPropertyId", 0x7572:"UIA_GridItemRowSpanPropertyId", 0x7573:"UIA_GridItemColumnSpanPropertyId", 0x7574:"UIA_GridItemContainingGridPropertyId", 0x7575:"UIA_DockDockPositionPropertyId", 0x7576:"UIA_ExpandCollapseExpandCollapseStatePropertyId", 0x7577:"UIA_MultipleViewCurrentViewPropertyId", 0x7578:"UIA_MultipleViewSupportedViewsPropertyId", 0x7579:"UIA_WindowCanMaximizePropertyId", 0x757A:"UIA_WindowCanMinimizePropertyId", 0x757B:"UIA_WindowWindowVisualStatePropertyId", 0x757C:"UIA_WindowWindowInteractionStatePropertyId", 0x757D:"UIA_WindowIsModalPropertyId", 0x757E:"UIA_WindowIsTopmostPropertyId", 0x757F:"UIA_SelectionItemIsSelectedPropertyId", 0x7580:"UIA_SelectionItemSelectionContainerPropertyId", 0x7581:"UIA_TableRowHeadersPropertyId", 0x7582:"UIA_TableColumnHeadersPropertyId", 0x7583:"UIA_TableRowOrColumnMajorPropertyId", 0x7584:"UIA_TableItemRowHeaderItemsPropertyId", 0x7585:"UIA_TableItemColumnHeaderItemsPropertyId", 0x7586:"UIA_ToggleToggleStatePropertyId", 0x7587:"UIA_TransformCanMovePropertyId", 0x7588:"UIA_TransformCanResizePropertyId", 0x7589:"UIA_TransformCanRotatePropertyId", 0x758A:"UIA_IsLegacyIAccessiblePatternAvailablePropertyId", 0x758B:"UIA_LegacyIAccessibleChildIdPropertyId", 0x758C:"UIA_LegacyIAccessibleNamePropertyId", 0x758D:"UIA_LegacyIAccessibleValuePropertyId", 0x758E:"UIA_LegacyIAccessibleDescriptionPropertyId", 0x758F:"UIA_LegacyIAccessibleRolePropertyId", 0x7590:"UIA_LegacyIAccessibleStatePropertyId", 0x7591:"UIA_LegacyIAccessibleHelpPropertyId", 0x7592:"UIA_LegacyIAccessibleKeyboardShortcutPropertyId", 0x7593:"UIA_LegacyIAccessibleSelectionPropertyId", 0x7594:"UIA_LegacyIAccessibleDefaultActionPropertyId", 0x7595:"UIA_AriaRolePropertyId", 0x7596:"UIA_AriaPropertiesPropertyId", 0x7597:"UIA_IsDataValidForFormPropertyId", 0x7598:"UIA_ControllerForPropertyId", 0x7599:"UIA_DescribedByPropertyId", 0x759A:"UIA_FlowsToPropertyId", 0x759B:"UIA_ProviderDescriptionPropertyId", 0x759C:"UIA_IsItemContainerPatternAvailablePropertyId", 0x759D:"UIA_IsVirtualizedItemPatternAvailablePropertyId", 0x759E:"UIA_IsSynchronizedInputPatternAvailablePropertyId", 0x759F:"UIA_OptimizeForVisualContentPropertyId", 0x75A0:"UIA_IsObjectModelPatternAvailablePropertyId", 0x75A1:"UIA_AnnotationAnnotationTypeIdPropertyId", 0x75A2:"UIA_AnnotationAnnotationTypeNamePropertyId", 0x75A3:"UIA_AnnotationAuthorPropertyId", 0x75A4:"UIA_AnnotationDateTimePropertyId", 0x75A5:"UIA_AnnotationTargetPropertyId", 0x75A6:"UIA_IsAnnotationPatternAvailablePropertyId", 0x75A7:"UIA_IsTextPattern2AvailablePropertyId", 0x75A8:"UIA_StylesStyleIdPropertyId", 0x75A9:"UIA_StylesStyleNamePropertyId", 0x75AA:"UIA_StylesFillColorPropertyId", 0x75AB:"UIA_StylesFillPatternStylePropertyId", 0x75AC:"UIA_StylesShapePropertyId"}
		static v2:={0x75AD:"UIA_StylesFillPatternColorPropertyId", 0x75AE:"UIA_StylesExtendedPropertiesPropertyId", 0x75AF:"UIA_IsStylesPatternAvailablePropertyId", 0x75B0:"UIA_IsSpreadsheetPatternAvailablePropertyId", 0x75B1:"UIA_SpreadsheetItemFormulaPropertyId", 0x75B2:"UIA_SpreadsheetItemAnnotationObjectsPropertyId", 0x75B3:"UIA_SpreadsheetItemAnnotationTypesPropertyId", 0x75B4:"UIA_IsSpreadsheetItemPatternAvailablePropertyId", 0x75B5:"UIA_Transform2CanZoomPropertyId", 0x75B6:"UIA_IsTransformPattern2AvailablePropertyId", 0x75B7:"UIA_LiveSettingPropertyId", 0x75B8:"UIA_IsTextChildPatternAvailablePropertyId", 0x75B9:"UIA_IsDragPatternAvailablePropertyId", 0x75BA:"UIA_DragIsGrabbedPropertyId", 0x75BB:"UIA_DragDropEffectPropertyId", 0x75BC:"UIA_DragDropEffectsPropertyId", 0x75BD:"UIA_IsDropTargetPatternAvailablePropertyId", 0x75BE:"UIA_DropTargetDropTargetEffectPropertyId", 0x75BF:"UIA_DropTargetDropTargetEffectsPropertyId", 0x75C0:"UIA_DragGrabbedItemsPropertyId", 0x75C1:"UIA_Transform2ZoomLevelPropertyId", 0x75C2:"UIA_Transform2ZoomMinimumPropertyId", 0x75C3:"UIA_Transform2ZoomMaximumPropertyId", 0x75C4:"UIA_FlowsFromPropertyId", 0x75C5:"UIA_IsTextEditPatternAvailablePropertyId", 0x75C6:"UIA_IsPeripheralPropertyId", 0x75C7:"UIA_IsCustomNavigationPatternAvailablePropertyId", 0x75C8:"UIA_PositionInSetPropertyId", 0x75C9:"UIA_SizeOfSetPropertyId", 0x75CA:"UIA_LevelPropertyId", 0x75CB:"UIA_AnnotationTypesPropertyId", 0x75CC:"UIA_AnnotationObjectsPropertyId", 0x75CD:"UIA_LandmarkTypePropertyId", 0x75CE:"UIA_LocalizedLandmarkTypePropertyId", 0x75CF:"UIA_FullDescriptionPropertyId", 0x75D0:"UIA_FillColorPropertyId", 0x75D1:"UIA_OutlineColorPropertyId", 0x75D2:"UIA_FillTypePropertyId", 0x75D3:"UIA_VisualEffectsPropertyId", 0x75D4:"UIA_OutlineThicknessPropertyId", 0x75D5:"UIA_CenterPointPropertyId", 0x75D6:"UIA_RotationPropertyId", 0x75D7:"UIA_SizePropertyId"}
		If (v1[Value])
			return v1[Value]
		else
		If (v2[Value])
			return v2[Value]
	}

	; *************************************************************************
	; Constants for: UIA_TextAttributeIds
	; *************************************************************************

	static UIA_AnimationStyleAttributeId := 40000  ; Type: Vt_I4
	static UIA_BackgroundColorAttributeId := 40001  ; Type: Vt_I4
	static UIA_BulletStyleAttributeId := 40002  ; Type: Vt_I4
	static UIA_CapStyleAttributeId := 40003  ; Type: Vt_I4
	static UIA_CultureAttributeId := 40004  ; Type: Vt_I4
	static UIA_FontNameAttributeId := 40005  ; Type: Vt_I4
	static UIA_FontSizeAttributeId := 40006  ; Type: Vt_I4
	static UIA_FontWeightAttributeId := 40007  ; Type: Vt_I4
	static UIA_ForegroundColorAttributeId := 40008  ; Type: Vt_I4
	static UIA_HorizontalTextAlignmentAttributeId := 40009  ; Type: Vt_I4
	static UIA_IndentationFirstLineAttributeId := 40010  ; Type: Vt_I4
	static UIA_IndentationLeadingAttributeId := 40011  ; Type: Vt_I4
	static UIA_IndentationTrailingAttributeId := 40012  ; Type: Vt_I4
	static UIA_IsHiddenAttributeId := 40013  ; Type: Vt_I4
	static UIA_IsItalicAttributeId := 40014  ; Type: Vt_I4
	static UIA_IsReadOnlyAttributeId := 40015  ; Type: Vt_I4
	static UIA_IsSubscriptAttributeId := 40016  ; Type: Vt_I4
	static UIA_IsSuperscriptAttributeId := 40017  ; Type: Vt_I4
	static UIA_MarginBottomAttributeId := 40018  ; Type: Vt_I4
	static UIA_MarginLeadingAttributeId := 40019  ; Type: Vt_I4
	static UIA_MarginTopAttributeId := 40020  ; Type: Vt_I4
	static UIA_MarginTrailingAttributeId := 40021  ; Type: Vt_I4
	static UIA_OutlineStylesAttributeId := 40022  ; Type: Vt_I4
	static UIA_OverlineColorAttributeId := 40023  ; Type: Vt_I4
	static UIA_OverlineStyleAttributeId := 40024  ; Type: Vt_I4
	static UIA_StrikethroughColorAttributeId := 40025  ; Type: Vt_I4
	static UIA_StrikethroughStyleAttributeId := 40026  ; Type: Vt_I4
	static UIA_TabsAttributeId := 40027  ; Type: Vt_I4
	static UIA_TextFlowDirectionsAttributeId := 40028  ; Type: Vt_I4
	static UIA_UnderlineColorAttributeId := 40029  ; Type: Vt_I4
	static UIA_UnderlineStyleAttributeId := 40030  ; Type: Vt_I4
	static UIA_AnnotationTypesAttributeId := 40031  ; Type: Vt_I4
	static UIA_AnnotationObjectsAttributeId := 40032  ; Type: Vt_I4
	static UIA_StyleNameAttributeId := 40033  ; Type: Vt_I4
	static UIA_StyleIdAttributeId := 40034  ; Type: Vt_I4
	static UIA_LinkAttributeId := 40035  ; Type: Vt_I4
	static UIA_IsActiveAttributeId := 40036  ; Type: Vt_I4
	static UIA_SelectionActiveEndAttributeId := 40037  ; Type: Vt_I4
	static UIA_CaretPositionAttributeId := 40038  ; Type: Vt_I4
	static UIA_CaretBidiModeAttributeId := 40039  ; Type: Vt_I4
	static UIA_LineSpacingAttributeId := 40040  ; Type: Vt_I4
	static UIA_BeforeParagraphSpacingAttributeId := 40041  ; Type: Vt_I4
	static UIA_AfterParagraphSpacingAttributeId := 40042  ; Type: Vt_I4
	static UIA_SayAsInterpretAsAttributeId := 40043  ; Type: Vt_I4

	UIA_TextAttributeIds(Value)
	{
		static v1:={0x9C40:"UIA_AnimationStyleAttributeId", 0x9C41:"UIA_BackgroundColorAttributeId", 0x9C42:"UIA_BulletStyleAttributeId", 0x9C43:"UIA_CapStyleAttributeId", 0x9C44:"UIA_CultureAttributeId", 0x9C45:"UIA_FontNameAttributeId", 0x9C46:"UIA_FontSizeAttributeId", 0x9C47:"UIA_FontWeightAttributeId", 0x9C48:"UIA_ForegroundColorAttributeId", 0x9C49:"UIA_HorizontalTextAlignmentAttributeId", 0x9C4A:"UIA_IndentationFirstLineAttributeId", 0x9C4B:"UIA_IndentationLeadingAttributeId", 0x9C4C:"UIA_IndentationTrailingAttributeId", 0x9C4D:"UIA_IsHiddenAttributeId", 0x9C4E:"UIA_IsItalicAttributeId", 0x9C4F:"UIA_IsReadOnlyAttributeId", 0x9C50:"UIA_IsSubscriptAttributeId", 0x9C51:"UIA_IsSuperscriptAttributeId", 0x9C52:"UIA_MarginBottomAttributeId", 0x9C53:"UIA_MarginLeadingAttributeId", 0x9C54:"UIA_MarginTopAttributeId", 0x9C55:"UIA_MarginTrailingAttributeId", 0x9C56:"UIA_OutlineStylesAttributeId", 0x9C57:"UIA_OverlineColorAttributeId", 0x9C58:"UIA_OverlineStyleAttributeId", 0x9C59:"UIA_StrikethroughColorAttributeId", 0x9C5A:"UIA_StrikethroughStyleAttributeId", 0x9C5B:"UIA_TabsAttributeId", 0x9C5C:"UIA_TextFlowDirectionsAttributeId", 0x9C5D:"UIA_UnderlineColorAttributeId", 0x9C5E:"UIA_UnderlineStyleAttributeId", 0x9C5F:"UIA_AnnotationTypesAttributeId", 0x9C60:"UIA_AnnotationObjectsAttributeId", 0x9C61:"UIA_StyleNameAttributeId", 0x9C62:"UIA_StyleIdAttributeId", 0x9C63:"UIA_LinkAttributeId", 0x9C64:"UIA_IsActiveAttributeId", 0x9C65:"UIA_SelectionActiveEndAttributeId", 0x9C66:"UIA_CaretPositionAttributeId", 0x9C67:"UIA_CaretBidiModeAttributeId", 0x9C68:"UIA_LineSpacingAttributeId", 0x9C69:"UIA_BeforeParagraphSpacingAttributeId", 0x9C6A:"UIA_AfterParagraphSpacingAttributeId", 0x9C6B:"UIA_SayAsInterpretAsAttributeId"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: UIA_ControlTypeIds
	; *************************************************************************

	static UIA_ButtonControlTypeId := 50000  ; Type: Vt_I4
	static UIA_CalendarControlTypeId := 50001  ; Type: Vt_I4
	static UIA_CheckBoxControlTypeId := 50002  ; Type: Vt_I4
	static UIA_ComboBoxControlTypeId := 50003  ; Type: Vt_I4
	static UIA_EditControlTypeId := 50004  ; Type: Vt_I4
	static UIA_HyperlinkControlTypeId := 50005  ; Type: Vt_I4
	static UIA_ImageControlTypeId := 50006  ; Type: Vt_I4
	static UIA_ListItemControlTypeId := 50007  ; Type: Vt_I4
	static UIA_ListControlTypeId := 50008  ; Type: Vt_I4
	static UIA_MenuControlTypeId := 50009  ; Type: Vt_I4
	static UIA_MenuBarControlTypeId := 50010  ; Type: Vt_I4
	static UIA_MenuItemControlTypeId := 50011  ; Type: Vt_I4
	static UIA_ProgressBarControlTypeId := 50012  ; Type: Vt_I4
	static UIA_RadioButtonControlTypeId := 50013  ; Type: Vt_I4
	static UIA_ScrollBarControlTypeId := 50014  ; Type: Vt_I4
	static UIA_SliderControlTypeId := 50015  ; Type: Vt_I4
	static UIA_SpinnerControlTypeId := 50016  ; Type: Vt_I4
	static UIA_StatusBarControlTypeId := 50017  ; Type: Vt_I4
	static UIA_TabControlTypeId := 50018  ; Type: Vt_I4
	static UIA_TabItemControlTypeId := 50019  ; Type: Vt_I4
	static UIA_TextControlTypeId := 50020  ; Type: Vt_I4
	static UIA_ToolBarControlTypeId := 50021  ; Type: Vt_I4
	static UIA_ToolTipControlTypeId := 50022  ; Type: Vt_I4
	static UIA_TreeControlTypeId := 50023  ; Type: Vt_I4
	static UIA_TreeItemControlTypeId := 50024  ; Type: Vt_I4
	static UIA_CustomControlTypeId := 50025  ; Type: Vt_I4
	static UIA_GroupControlTypeId := 50026  ; Type: Vt_I4
	static UIA_ThumbControlTypeId := 50027  ; Type: Vt_I4
	static UIA_DataGridControlTypeId := 50028  ; Type: Vt_I4
	static UIA_DataItemControlTypeId := 50029  ; Type: Vt_I4
	static UIA_DocumentControlTypeId := 50030  ; Type: Vt_I4
	static UIA_SplitButtonControlTypeId := 50031  ; Type: Vt_I4
	static UIA_WindowControlTypeId := 50032  ; Type: Vt_I4
	static UIA_PaneControlTypeId := 50033  ; Type: Vt_I4
	static UIA_HeaderControlTypeId := 50034  ; Type: Vt_I4
	static UIA_HeaderItemControlTypeId := 50035  ; Type: Vt_I4
	static UIA_TableControlTypeId := 50036  ; Type: Vt_I4
	static UIA_TitleBarControlTypeId := 50037  ; Type: Vt_I4
	static UIA_SeparatorControlTypeId := 50038  ; Type: Vt_I4
	static UIA_SemanticZoomControlTypeId := 50039  ; Type: Vt_I4
	static UIA_AppBarControlTypeId := 50040  ; Type: Vt_I4

	UIA_ControlTypeIds(Value)
	{
		static v1:={0xC350:"UIA_ButtonControlTypeId", 0xC351:"UIA_CalendarControlTypeId", 0xC352:"UIA_CheckBoxControlTypeId", 0xC353:"UIA_ComboBoxControlTypeId", 0xC354:"UIA_EditControlTypeId", 0xC355:"UIA_HyperlinkControlTypeId", 0xC356:"UIA_ImageControlTypeId", 0xC357:"UIA_ListItemControlTypeId", 0xC358:"UIA_ListControlTypeId", 0xC359:"UIA_MenuControlTypeId", 0xC35A:"UIA_MenuBarControlTypeId", 0xC35B:"UIA_MenuItemControlTypeId", 0xC35C:"UIA_ProgressBarControlTypeId", 0xC35D:"UIA_RadioButtonControlTypeId", 0xC35E:"UIA_ScrollBarControlTypeId", 0xC35F:"UIA_SliderControlTypeId", 0xC360:"UIA_SpinnerControlTypeId", 0xC361:"UIA_StatusBarControlTypeId", 0xC362:"UIA_TabControlTypeId", 0xC363:"UIA_TabItemControlTypeId", 0xC364:"UIA_TextControlTypeId", 0xC365:"UIA_ToolBarControlTypeId", 0xC366:"UIA_ToolTipControlTypeId", 0xC367:"UIA_TreeControlTypeId", 0xC368:"UIA_TreeItemControlTypeId", 0xC369:"UIA_CustomControlTypeId", 0xC36A:"UIA_GroupControlTypeId", 0xC36B:"UIA_ThumbControlTypeId", 0xC36C:"UIA_DataGridControlTypeId", 0xC36D:"UIA_DataItemControlTypeId", 0xC36E:"UIA_DocumentControlTypeId", 0xC36F:"UIA_SplitButtonControlTypeId", 0xC370:"UIA_WindowControlTypeId", 0xC371:"UIA_PaneControlTypeId", 0xC372:"UIA_HeaderControlTypeId", 0xC373:"UIA_HeaderItemControlTypeId", 0xC374:"UIA_TableControlTypeId", 0xC375:"UIA_TitleBarControlTypeId", 0xC376:"UIA_SeparatorControlTypeId", 0xC377:"UIA_SemanticZoomControlTypeId", 0xC378:"UIA_AppBarControlTypeId"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: UIA_AnnotationTypes
	; *************************************************************************

	static AnnotationType_Unknown := 60000  ; Type: Vt_I4
	static AnnotationType_SpellingError := 60001  ; Type: Vt_I4
	static AnnotationType_GrammarError := 60002  ; Type: Vt_I4
	static AnnotationType_Comment := 60003  ; Type: Vt_I4
	static AnnotationType_FormulaError := 60004  ; Type: Vt_I4
	static AnnotationType_TrackChanges := 60005  ; Type: Vt_I4
	static AnnotationType_Header := 60006  ; Type: Vt_I4
	static AnnotationType_Footer := 60007  ; Type: Vt_I4
	static AnnotationType_Highlighted := 60008  ; Type: Vt_I4
	static AnnotationType_Endnote := 60009  ; Type: Vt_I4
	static AnnotationType_Footnote := 60010  ; Type: Vt_I4
	static AnnotationType_InsertionChange := 60011  ; Type: Vt_I4
	static AnnotationType_DeletionChange := 60012  ; Type: Vt_I4
	static AnnotationType_MoveChange := 60013  ; Type: Vt_I4
	static AnnotationType_FormatChange := 60014  ; Type: Vt_I4
	static AnnotationType_UnsyncedChange := 60015  ; Type: Vt_I4
	static AnnotationType_EditingLockedChange := 60016  ; Type: Vt_I4
	static AnnotationType_ExternalChange := 60017  ; Type: Vt_I4
	static AnnotationType_ConflictingChange := 60018  ; Type: Vt_I4
	static AnnotationType_Author := 60019  ; Type: Vt_I4
	static AnnotationType_AdvancedProofingIssue := 60020  ; Type: Vt_I4
	static AnnotationType_DataValidationError := 60021  ; Type: Vt_I4
	static AnnotationType_CircularReferenceError := 60022  ; Type: Vt_I4
	static AnnotationType_Mathematics := 60023  ; Type: Vt_I4

	UIA_AnnotationTypes(Value)
	{
		static v1:={0xEA60:"AnnotationType_Unknown", 0xEA61:"AnnotationType_SpellingError", 0xEA62:"AnnotationType_GrammarError", 0xEA63:"AnnotationType_Comment", 0xEA64:"AnnotationType_FormulaError", 0xEA65:"AnnotationType_TrackChanges", 0xEA66:"AnnotationType_Header", 0xEA67:"AnnotationType_Footer", 0xEA68:"AnnotationType_Highlighted", 0xEA69:"AnnotationType_Endnote", 0xEA6A:"AnnotationType_Footnote", 0xEA6B:"AnnotationType_InsertionChange", 0xEA6C:"AnnotationType_DeletionChange", 0xEA6D:"AnnotationType_MoveChange", 0xEA6E:"AnnotationType_FormatChange", 0xEA6F:"AnnotationType_UnsyncedChange", 0xEA70:"AnnotationType_EditingLockedChange", 0xEA71:"AnnotationType_ExternalChange", 0xEA72:"AnnotationType_ConflictingChange", 0xEA73:"AnnotationType_Author", 0xEA74:"AnnotationType_AdvancedProofingIssue", 0xEA75:"AnnotationType_DataValidationError", 0xEA76:"AnnotationType_CircularReferenceError", 0xEA77:"AnnotationType_Mathematics"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: UIA_StyleIds
	; *************************************************************************

	static StyleId_Custom := 70000  ; Type: Vt_I4
	static StyleId_Heading1 := 70001  ; Type: Vt_I4
	static StyleId_Heading2 := 70002  ; Type: Vt_I4
	static StyleId_Heading3 := 70003  ; Type: Vt_I4
	static StyleId_Heading4 := 70004  ; Type: Vt_I4
	static StyleId_Heading5 := 70005  ; Type: Vt_I4
	static StyleId_Heading6 := 70006  ; Type: Vt_I4
	static StyleId_Heading7 := 70007  ; Type: Vt_I4
	static StyleId_Heading8 := 70008  ; Type: Vt_I4
	static StyleId_Heading9 := 70009  ; Type: Vt_I4
	static StyleId_Title := 70010  ; Type: Vt_I4
	static StyleId_Subtitle := 70011  ; Type: Vt_I4
	static StyleId_Normal := 70012  ; Type: Vt_I4
	static StyleId_Emphasis := 70013  ; Type: Vt_I4
	static StyleId_Quote := 70014  ; Type: Vt_I4
	static StyleId_BulletedList := 70015  ; Type: Vt_I4
	static StyleId_NumberedList := 70016  ; Type: Vt_I4

	UIA_StyleIds(Value)
	{
		static v1:={0x11170:"StyleId_Custom", 0x11171:"StyleId_Heading1", 0x11172:"StyleId_Heading2", 0x11173:"StyleId_Heading3", 0x11174:"StyleId_Heading4", 0x11175:"StyleId_Heading5", 0x11176:"StyleId_Heading6", 0x11177:"StyleId_Heading7", 0x11178:"StyleId_Heading8", 0x11179:"StyleId_Heading9", 0x1117A:"StyleId_Title", 0x1117B:"StyleId_Subtitle", 0x1117C:"StyleId_Normal", 0x1117D:"StyleId_Emphasis", 0x1117E:"StyleId_Quote", 0x1117F:"StyleId_BulletedList", 0x11180:"StyleId_NumberedList"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: UIA_LandmarkTypeIds
	; *************************************************************************

	static UIA_CustomLandmarkTypeId := 80000  ; Type: Vt_I4
	static UIA_FormLandmarkTypeId := 80001  ; Type: Vt_I4
	static UIA_MainLandmarkTypeId := 80002  ; Type: Vt_I4
	static UIA_NavigationLandmarkTypeId := 80003  ; Type: Vt_I4
	static UIA_SearchLandmarkTypeId := 80004  ; Type: Vt_I4

	UIA_LandmarkTypeIds(Value)
	{
		static v1:={0x13880:"UIA_CustomLandmarkTypeId", 0x13881:"UIA_FormLandmarkTypeId", 0x13882:"UIA_MainLandmarkTypeId", 0x13883:"UIA_NavigationLandmarkTypeId", 0x13884:"UIA_SearchLandmarkTypeId"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: UIA_ChangeIds
	; *************************************************************************

	static UIA_SummaryChangeId := 90000  ; Type: Vt_I4

	UIA_ChangeIds(Value)
	{
		static v1:={0x15F90:"UIA_SummaryChangeId"}
		If (v1[Value])
			return v1[Value]
	}

	; *************************************************************************
	; Constants for: UIA_MetadataIds
	; *************************************************************************

	static UIA_SayAsInterpretAsMetadataId := 100000  ; Type: Vt_I4

	UIA_MetadataIds(Value)
	{
		static v1:={0x186A0:"UIA_SayAsInterpretAsMetadataId"}
		If (v1[Value])
			return v1[Value]
	}

}

; *************************************************************************
; *************************************************************************
; Record
; *************************************************************************
; *************************************************************************

; *************************************************************************
; tagRECT
; GUID: {00000000-0000-0000-0000-000000000000}
; *************************************************************************

class tagRECT
{
	__New(byref p="empty")
	{
		If (p="empty")
		{
			VarSetCapacity(p,this.__SizeOf(),0)
		}
		ObjInsert(this, "__Value", &p)
	}

	__Get(VarName)
	{
		If (VarName="__Value")
			return this.__Value
		If (VarName="left")
			return NumGet(this.__Value+0, 0, "Int") ; Type: Vt_I4
		If (VarName="top")
			return NumGet(this.__Value+4, 0, "Int") ; Type: Vt_I4
		If (VarName="right")
			return NumGet(this.__Value+8, 0, "Int") ; Type: Vt_I4
		If (VarName="bottom")
			return NumGet(this.__Value+12, 0, "Int") ; Type: Vt_I4
	}

	__Set(VarName, byref Value)
	{
		If (VarName="left")
			NumPut(Value, this.__Value+0, 0, "Int") ; Type: Vt_I4
		If (VarName="top")
			NumPut(Value, this.__Value+4, 0, "Int") ; Type: Vt_I4
		If (VarName="right")
			NumPut(Value, this.__Value+8, 0, "Int") ; Type: Vt_I4
		If (VarName="bottom")
			NumPut(Value, this.__Value+12, 0, "Int") ; Type: Vt_I4
		return Value
	}

	__SizeOf()
	{
		return 16
	}
}

; *************************************************************************
; tagPOINT
; GUID: {00000000-0000-0000-0000-000000000000}
; *************************************************************************

class tagPOINT
{
	__New(byref p="empty")
	{
		If (p="empty")
		{
			VarSetCapacity(p,this.__SizeOf(),0)
		}
		ObjInsert(this, "__Value", &p)
	}

	__Get(VarName)
	{
		If (VarName="__Value")
			return this.__Value
		If (VarName="x")
			return NumGet(this.__Value+0, 0, "Int") ; Type: Vt_I4
		If (VarName="y")
			return NumGet(this.__Value+4, 0, "Int") ; Type: Vt_I4
	}

	__Set(VarName, byref Value)
	{
		If (VarName="x")
			NumPut(Value, this.__Value+0, 0, "Int") ; Type: Vt_I4
		If (VarName="y")
			NumPut(Value, this.__Value+4, 0, "Int") ; Type: Vt_I4
		return Value
	}

	__SizeOf()
	{
		return 8
	}
}

; *************************************************************************
; UiaChangeInfo
; GUID: {00000000-0000-0000-0000-000000000000}
; *************************************************************************

class UiaChangeInfo
{
	__New(byref p="empty")
	{
		If (p="empty")
		{
			VarSetCapacity(p,this.__SizeOf(),0)
		}
		ObjInsert(this, "__Value", &p)
	}

	__Get(VarName)
	{
		If (VarName="__Value")
			return this.__Value
		If (VarName="uiaId")
			return NumGet(this.__Value+0, 0, "Int") ; Type: Vt_Int
		If (VarName="payload")
			return NumGet(this.__Value+8, 0, "Ptr") ; Type: Vt_Variant
		If (VarName="extraInfo")
			return NumGet(this.__Value+32, 0, "Ptr") ; Type: Vt_Variant
	}

	__Set(VarName, byref Value)
	{
		If (VarName="uiaId")
			NumPut(Value, this.__Value+0, 0, "Int") ; Type: Vt_Int
		If (VarName="payload")
			NumPut(Value, this.__Value+8, 0, "Ptr") ; Type: Vt_Variant
		If (VarName="extraInfo")
			NumPut(Value, this.__Value+32, 0, "Ptr") ; Type: Vt_Variant
		return Value
	}

	__SizeOf()
	{
		return 56
	}
}

; *************************************************************************
; ExtendedProperty
; GUID: {00000000-0000-0000-0000-000000000000}
; *************************************************************************

class ExtendedProperty
{
	__New(byref p="empty")
	{
		If (p="empty")
		{
			VarSetCapacity(p,this.__SizeOf(),0)
		}
		ObjInsert(this, "__Value", &p)
	}

	__Get(VarName)
	{
		If (VarName="__Value")
			return this.__Value
		If (VarName="PropertyName")
			return NumGet(this.__Value+0, 0, "Ptr") ; Type: Vt_Bstr
		If (VarName="PropertyValue")
			return NumGet(this.__Value+8, 0, "Ptr") ; Type: Vt_Bstr
	}

	__Set(VarName, byref Value)
	{
		If (VarName="PropertyName")
			NumPut(Value, this.__Value+0, 0, "Ptr") ; Type: Vt_Bstr
		If (VarName="PropertyValue")
			NumPut(Value, this.__Value+8, 0, "Ptr") ; Type: Vt_Bstr
		return Value
	}

	__SizeOf()
	{
		return 16
	}
}

; *************************************************************************
; *************************************************************************
; Interfaces defined in type library
; *************************************************************************
; *************************************************************************

; *************************************************************************
; IUIAutomationElement
; GUID: {D22108AA-8AC5-49A5-837B-37BBB3D7591E}
; *************************************************************************


class IUIAutomationElement
{
	; Generic definitions

	static __IID := "{D22108AA-8AC5-49A5-837B-37BBB3D7591E}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationElement"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult SetFocus()
	SetFocus() {
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Int")
		return res
	}

	; VTable Positon 4: INVOKE_FUNC Vt_Hresult GetRuntimeId([FOUT] [FRETVAL] Safearray*: runtimeId)
	GetRuntimeId() {
		If (ComObjValue(runtimeId) & 0x2000)
			refruntimeId:=runtimeId
		else
		{
			refruntimeId:=ComObject(0x2003, DllCall("oleaut32\SafeArrayCreateVector", "UInt", 13, "UInt", 0, "UInt", runtimeId.MaxIndex()),1)
			For ind, val in runtimeId
				refruntimeId[A_Index-1]:= val.__Value, ObjAddRef(val.__Value)
		}
		res:=DllCall(this.__Vt(4), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetRuntimeId in IUIAutomationElement")
		return out
	}

	; VTable Positon 5: INVOKE_FUNC Vt_Hresult FindFirst([FIN] TreeScope: scope, [FIN] IUIAutomationCondition*: condition, [FOUT] [FRETVAL] IUIAutomationElement**: found)
	FindFirst(scope, condition) {
		If (IsObject(condition) and (ComObjType(condition)=""))
			refcondition:=condition.__Value
		else
			refcondition:=condition
		res:=DllCall(this.__Vt(5), "Ptr", this.__Value, "UInt", scope, "Ptr", refcondition, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from FindFirst in IUIAutomationElement")
		out:= new IUIAutomationElement(out)
		return out
	}

	; VTable Positon 6: INVOKE_FUNC Vt_Hresult FindAll([FIN] TreeScope: scope, [FIN] IUIAutomationCondition*: condition, [FOUT] [FRETVAL] IUIAutomationElementArray**: found)
	FindAll(scope, condition) {
		If (IsObject(condition) and (ComObjType(condition)=""))
			refcondition:=condition.__Value
		else
			refcondition:=condition
		res:=DllCall(this.__Vt(6), "Ptr", this.__Value, "UInt", scope, "Ptr", refcondition, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from FindAll in IUIAutomationElement")
		out:= new IUIAutomationElementArray(out)
		return out
	}

	; VTable Positon 7: INVOKE_FUNC Vt_Hresult FindFirstBuildCache([FIN] TreeScope: scope, [FIN] IUIAutomationCondition*: condition, [FIN] IUIAutomationCacheRequest*: cacheRequest, [FOUT] [FRETVAL] IUIAutomationElement**: found)
	FindFirstBuildCache(scope, condition, cacheRequest) {
		If (IsObject(condition) and (ComObjType(condition)=""))
			refcondition:=condition.__Value
		else
			refcondition:=condition
		If (IsObject(cacheRequest) and (ComObjType(cacheRequest)=""))
			refcacheRequest:=cacheRequest.__Value
		else
			refcacheRequest:=cacheRequest
		res:=DllCall(this.__Vt(7), "Ptr", this.__Value, "UInt", scope, "Ptr", refcondition, "Ptr", refcacheRequest, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from FindFirstBuildCache in IUIAutomationElement")
		out:= new IUIAutomationElement(out)
		return out
	}

	; VTable Positon 8: INVOKE_FUNC Vt_Hresult FindAllBuildCache([FIN] TreeScope: scope, [FIN] IUIAutomationCondition*: condition, [FIN] IUIAutomationCacheRequest*: cacheRequest, [FOUT] [FRETVAL] IUIAutomationElementArray**: found)
	FindAllBuildCache(scope, condition, cacheRequest) {
		If (IsObject(condition) and (ComObjType(condition)=""))
			refcondition:=condition.__Value
		else
			refcondition:=condition
		If (IsObject(cacheRequest) and (ComObjType(cacheRequest)=""))
			refcacheRequest:=cacheRequest.__Value
		else
			refcacheRequest:=cacheRequest
		res:=DllCall(this.__Vt(8), "Ptr", this.__Value, "UInt", scope, "Ptr", refcondition, "Ptr", refcacheRequest, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from FindAllBuildCache in IUIAutomationElement")
		out:= new IUIAutomationElementArray(out)
		return out
	}

	; VTable Positon 9: INVOKE_FUNC Vt_Hresult BuildUpdatedCache([FIN] IUIAutomationCacheRequest*: cacheRequest, [FOUT] [FRETVAL] IUIAutomationElement**: updatedElement)
	BuildUpdatedCache(cacheRequest) {
		If (IsObject(cacheRequest) and (ComObjType(cacheRequest)=""))
			refcacheRequest:=cacheRequest.__Value
		else
			refcacheRequest:=cacheRequest
		res:=DllCall(this.__Vt(9), "Ptr", this.__Value, "Ptr", refcacheRequest, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from BuildUpdatedCache in IUIAutomationElement")
		out:= new IUIAutomationElement(out)
		return out
	}

	; VTable Positon 10: INVOKE_FUNC Vt_Hresult GetCurrentPropertyValue([FIN] Int: propertyId, [FOUT] [FRETVAL] Variant*: retVal)
	GetCurrentPropertyValue(propertyId) {
		res:=DllCall(this.__Vt(10), "Ptr", this.__Value, "Int", propertyId, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCurrentPropertyValue in IUIAutomationElement")
		out:=ComObject(0x400C, out+0, flag)[]
		return out
	}

	; VTable Positon 11: INVOKE_FUNC Vt_Hresult GetCurrentPropertyValueEx([FIN] Int: propertyId, [FIN] I4: ignoreDefaultValue, [FOUT] [FRETVAL] Variant*: retVal)
	GetCurrentPropertyValueEx(propertyId, ignoreDefaultValue) {
		res:=DllCall(this.__Vt(11), "Ptr", this.__Value, "Int", propertyId, "Int", ignoreDefaultValue, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCurrentPropertyValueEx in IUIAutomationElement")
		out:=ComObject(0x400C, out+0, flag)[]
		return out
	}

	; VTable Positon 12: INVOKE_FUNC Vt_Hresult GetCachedPropertyValue([FIN] Int: propertyId, [FOUT] [FRETVAL] Variant*: retVal)
	GetCachedPropertyValue(propertyId) {
		res:=DllCall(this.__Vt(12), "Ptr", this.__Value, "Int", propertyId, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCachedPropertyValue in IUIAutomationElement")
		out:=ComObject(0x400C, out+0, flag)[]
		return out
	}

	; VTable Positon 13: INVOKE_FUNC Vt_Hresult GetCachedPropertyValueEx([FIN] Int: propertyId, [FIN] I4: ignoreDefaultValue, [FOUT] [FRETVAL] Variant*: retVal)
	GetCachedPropertyValueEx(propertyId, ignoreDefaultValue) {
		res:=DllCall(this.__Vt(13), "Ptr", this.__Value, "Int", propertyId, "Int", ignoreDefaultValue, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCachedPropertyValueEx in IUIAutomationElement")
		out:=ComObject(0x400C, out+0, flag)[]
		return out
	}

	; VTable Positon 14: INVOKE_FUNC Vt_Hresult GetCurrentPatternAs([FIN] Int: patternId, [FIN] GUID*: riid, [FOUT] [FRETVAL] Void**: patternObject)
	GetCurrentPatternAs(patternId, riid) {
		If (IsObject(riid) and (ComObjType(riid)=""))
			refriid:=riid.__Value
		else
			refriid:=&riid
		res:=DllCall(this.__Vt(14), "Ptr", this.__Value, "Int", patternId, "Ptr", refriid, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCurrentPatternAs in IUIAutomationElement")
		return out
	}

	; VTable Positon 15: INVOKE_FUNC Vt_Hresult GetCachedPatternAs([FIN] Int: patternId, [FIN] GUID*: riid, [FOUT] [FRETVAL] Void**: patternObject)
	GetCachedPatternAs(patternId, riid) {
		If (IsObject(riid) and (ComObjType(riid)=""))
			refriid:=riid.__Value
		else
			refriid:=&riid
		res:=DllCall(this.__Vt(15), "Ptr", this.__Value, "Int", patternId, "Ptr", refriid, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCachedPatternAs in IUIAutomationElement")
		return out
	}

	; VTable Positon 16: INVOKE_FUNC Vt_Hresult GetCurrentPattern([FIN] Int: patternId, [FOUT] [FRETVAL] Unknown*: patternObject)
	GetCurrentPattern(patternId) {
		res:=DllCall(this.__Vt(16), "Ptr", this.__Value, "Int", patternId, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCurrentPattern in IUIAutomationElement")
		return out
	}

	; VTable Positon 17: INVOKE_FUNC Vt_Hresult GetCachedPattern([FIN] Int: patternId, [FOUT] [FRETVAL] Unknown*: patternObject)
	GetCachedPattern(patternId) {
		res:=DllCall(this.__Vt(17), "Ptr", this.__Value, "Int", patternId, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCachedPattern in IUIAutomationElement")
		return out
	}

	; VTable Positon 18: INVOKE_FUNC Vt_Hresult GetCachedParent([FOUT] [FRETVAL] IUIAutomationElement**: parent)
	GetCachedParent() {
		res:=DllCall(this.__Vt(18), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCachedParent in IUIAutomationElement")
		out:= new IUIAutomationElement(out)
		return out
	}

	; VTable Positon 19: INVOKE_FUNC Vt_Hresult GetCachedChildren([FOUT] [FRETVAL] IUIAutomationElementArray**: children)
	GetCachedChildren() {
		res:=DllCall(this.__Vt(19), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCachedChildren in IUIAutomationElement")
		out:= new IUIAutomationElementArray(out)
		return out
	}

	; VTable Positon 84: INVOKE_FUNC Vt_Hresult GetClickablePoint([FOUT] tagPOINT*: clickable, [FOUT] [FRETVAL] I4*: gotClickable)
	GetClickablePoint(byref clickable) {
		If (IsObject(clickable) and (ComObjType(clickable)=""))
			refclickable:=clickable.__Value
		else
			refclickable:=&clickable
		res:=DllCall(this.__Vt(84), "Ptr", this.__Value, "Ptr", refclickable, "Int*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetClickablePoint in IUIAutomationElement")
		return out
	}

	; Property: CachedAcceleratorKey; VTable PositonGet: 56; output : Vt_Bstr*: retVal
	CachedAcceleratorKey[]
	{
		get {
			If !DllCall(this.__Vt(56), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CachedAccessKey; VTable PositonGet: 57; output : Vt_Bstr*: retVal
	CachedAccessKey[]
	{
		get {
			If !DllCall(this.__Vt(57), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CachedAriaProperties; VTable PositonGet: 78; output : Vt_Bstr*: retVal
	CachedAriaProperties[]
	{
		get {
			If !DllCall(this.__Vt(78), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CachedAriaRole; VTable PositonGet: 77; output : Vt_Bstr*: retVal
	CachedAriaRole[]
	{
		get {
			If !DllCall(this.__Vt(77), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CachedAutomationId; VTable PositonGet: 61; output : Vt_Bstr*: retVal
	CachedAutomationId[]
	{
		get {
			If !DllCall(this.__Vt(61), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CachedBoundingRectangle; VTable PositonGet: 75; output : tagRECT*: retVal
	CachedBoundingRectangle[]
	{
		get {
			out:=new tagRECT()
			If !DllCall(this.__Vt(75), "Ptr", this.__Value, "Ptr", out.__Value)
			{
				return out
			}
		}
	}
	; Property: CachedClassName; VTable PositonGet: 62; output : Vt_Bstr*: retVal
	CachedClassName[]
	{
		get {
			If !DllCall(this.__Vt(62), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CachedControllerFor; VTable PositonGet: 80; output : IUIAutomationElementArray**: retVal
	CachedControllerFor[]
	{
		get {
			If !DllCall(this.__Vt(80), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationElementArray(out)
				return out
			}
		}
	}
	; Property: CachedControlType; VTable PositonGet: 53; output : Vt_Int*: retVal
	CachedControlType[]
	{
		get {
			If !DllCall(this.__Vt(53), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedCulture; VTable PositonGet: 64; output : Vt_Int*: retVal
	CachedCulture[]
	{
		get {
			If !DllCall(this.__Vt(64), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedDescribedBy; VTable PositonGet: 81; output : IUIAutomationElementArray**: retVal
	CachedDescribedBy[]
	{
		get {
			If !DllCall(this.__Vt(81), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationElementArray(out)
				return out
			}
		}
	}
	; Property: CachedFlowsTo; VTable PositonGet: 82; output : IUIAutomationElementArray**: retVal
	CachedFlowsTo[]
	{
		get {
			If !DllCall(this.__Vt(82), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationElementArray(out)
				return out
			}
		}
	}
	; Property: CachedFrameworkId; VTable PositonGet: 72; output : Vt_Bstr*: retVal
	CachedFrameworkId[]
	{
		get {
			If !DllCall(this.__Vt(72), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CachedHasKeyboardFocus; VTable PositonGet: 58; output : Vt_I4*: retVal
	CachedHasKeyboardFocus[]
	{
		get {
			If !DllCall(this.__Vt(58), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedHelpText; VTable PositonGet: 63; output : Vt_Bstr*: retVal
	CachedHelpText[]
	{
		get {
			If !DllCall(this.__Vt(63), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CachedIsContentElement; VTable PositonGet: 66; output : Vt_I4*: retVal
	CachedIsContentElement[]
	{
		get {
			If !DllCall(this.__Vt(66), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedIsControlElement; VTable PositonGet: 65; output : Vt_I4*: retVal
	CachedIsControlElement[]
	{
		get {
			If !DllCall(this.__Vt(65), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedIsDataValidForForm; VTable PositonGet: 79; output : Vt_I4*: retVal
	CachedIsDataValidForForm[]
	{
		get {
			If !DllCall(this.__Vt(79), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedIsEnabled; VTable PositonGet: 60; output : Vt_I4*: retVal
	CachedIsEnabled[]
	{
		get {
			If !DllCall(this.__Vt(60), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedIsKeyboardFocusable; VTable PositonGet: 59; output : Vt_I4*: retVal
	CachedIsKeyboardFocusable[]
	{
		get {
			If !DllCall(this.__Vt(59), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedIsOffscreen; VTable PositonGet: 70; output : Vt_I4*: retVal
	CachedIsOffscreen[]
	{
		get {
			If !DllCall(this.__Vt(70), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedIsPassword; VTable PositonGet: 67; output : Vt_I4*: retVal
	CachedIsPassword[]
	{
		get {
			If !DllCall(this.__Vt(67), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedIsRequiredForForm; VTable PositonGet: 73; output : Vt_I4*: retVal
	CachedIsRequiredForForm[]
	{
		get {
			If !DllCall(this.__Vt(73), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedItemStatus; VTable PositonGet: 74; output : Vt_Bstr*: retVal
	CachedItemStatus[]
	{
		get {
			If !DllCall(this.__Vt(74), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CachedItemType; VTable PositonGet: 69; output : Vt_Bstr*: retVal
	CachedItemType[]
	{
		get {
			If !DllCall(this.__Vt(69), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CachedLabeledBy; VTable PositonGet: 76; output : IUIAutomationElement**: retVal
	CachedLabeledBy[]
	{
		get {
			If !DllCall(this.__Vt(76), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationElement(out)
				return out
			}
		}
	}
	; Property: CachedLocalizedControlType; VTable PositonGet: 54; output : Vt_Bstr*: retVal
	CachedLocalizedControlType[]
	{
		get {
			If !DllCall(this.__Vt(54), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CachedName; VTable PositonGet: 55; output : Vt_Bstr*: retVal
	CachedName[]
	{
		get {
			If !DllCall(this.__Vt(55), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CachedNativeWindowHandle; VTable PositonGet: 68; output : Vt_Void**: retVal
	CachedNativeWindowHandle[]
	{
		get {
			If !DllCall(this.__Vt(68), "Ptr", this.__Value, "Ptr*",out)
			{
				return out
			}
		}
	}
	; Property: CachedOrientation; VTable PositonGet: 71; output : OrientationType*: retVal
	CachedOrientation[]
	{
		get {
			If !DllCall(this.__Vt(71), "Ptr", this.__Value, "UInt",out)
			{
				return out
			}
		}
	}
	; Property: CachedProcessId; VTable PositonGet: 52; output : Vt_Int*: retVal
	CachedProcessId[]
	{
		get {
			If !DllCall(this.__Vt(52), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedProviderDescription; VTable PositonGet: 83; output : Vt_Bstr*: retVal
	CachedProviderDescription[]
	{
		get {
			If !DllCall(this.__Vt(83), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentAcceleratorKey; VTable PositonGet: 24; output : Vt_Bstr*: retVal
	CurrentAcceleratorKey[]
	{
		get {
			If !DllCall(this.__Vt(24), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentAccessKey; VTable PositonGet: 25; output : Vt_Bstr*: retVal
	CurrentAccessKey[]
	{
		get {
			If !DllCall(this.__Vt(25), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentAriaProperties; VTable PositonGet: 46; output : Vt_Bstr*: retVal
	CurrentAriaProperties[]
	{
		get {
			If !DllCall(this.__Vt(46), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentAriaRole; VTable PositonGet: 45; output : Vt_Bstr*: retVal
	CurrentAriaRole[]
	{
		get {
			If !DllCall(this.__Vt(45), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentAutomationId; VTable PositonGet: 29; output : Vt_Bstr*: retVal
	CurrentAutomationId[]
	{
		get {
			If !DllCall(this.__Vt(29), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentBoundingRectangle; VTable PositonGet: 43; output : tagRECT*: retVal
	CurrentBoundingRectangle[]
	{
		get {
			out:=new tagRECT()
			If !DllCall(this.__Vt(43), "Ptr", this.__Value, "Ptr", out.__Value)
			{
				return out
			}
		}
	}
	; Property: CurrentClassName; VTable PositonGet: 30; output : Vt_Bstr*: retVal
	CurrentClassName[]
	{
		get {
			If !DllCall(this.__Vt(30), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentControllerFor; VTable PositonGet: 48; output : IUIAutomationElementArray**: retVal
	CurrentControllerFor[]
	{
		get {
			If !DllCall(this.__Vt(48), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationElementArray(out)
				return out
			}
		}
	}
	; Property: CurrentControlType; VTable PositonGet: 21; output : Vt_Int*: retVal
	CurrentControlType[]
	{
		get {
			If !DllCall(this.__Vt(21), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentCulture; VTable PositonGet: 32; output : Vt_Int*: retVal
	CurrentCulture[]
	{
		get {
			If !DllCall(this.__Vt(32), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentDescribedBy; VTable PositonGet: 49; output : IUIAutomationElementArray**: retVal
	CurrentDescribedBy[]
	{
		get {
			If !DllCall(this.__Vt(49), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationElementArray(out)
				return out
			}
		}
	}
	; Property: CurrentFlowsTo; VTable PositonGet: 50; output : IUIAutomationElementArray**: retVal
	CurrentFlowsTo[]
	{
		get {
			If !DllCall(this.__Vt(50), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationElementArray(out)
				return out
			}
		}
	}
	; Property: CurrentFrameworkId; VTable PositonGet: 40; output : Vt_Bstr*: retVal
	CurrentFrameworkId[]
	{
		get {
			If !DllCall(this.__Vt(40), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentHasKeyboardFocus; VTable PositonGet: 26; output : Vt_I4*: retVal
	CurrentHasKeyboardFocus[]
	{
		get {
			If !DllCall(this.__Vt(26), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentHelpText; VTable PositonGet: 31; output : Vt_Bstr*: retVal
	CurrentHelpText[]
	{
		get {
			If !DllCall(this.__Vt(31), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentIsContentElement; VTable PositonGet: 34; output : Vt_I4*: retVal
	CurrentIsContentElement[]
	{
		get {
			If !DllCall(this.__Vt(34), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentIsControlElement; VTable PositonGet: 33; output : Vt_I4*: retVal
	CurrentIsControlElement[]
	{
		get {
			If !DllCall(this.__Vt(33), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentIsDataValidForForm; VTable PositonGet: 47; output : Vt_I4*: retVal
	CurrentIsDataValidForForm[]
	{
		get {
			If !DllCall(this.__Vt(47), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentIsEnabled; VTable PositonGet: 28; output : Vt_I4*: retVal
	CurrentIsEnabled[]
	{
		get {
			If !DllCall(this.__Vt(28), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentIsKeyboardFocusable; VTable PositonGet: 27; output : Vt_I4*: retVal
	CurrentIsKeyboardFocusable[]
	{
		get {
			If !DllCall(this.__Vt(27), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentIsOffscreen; VTable PositonGet: 38; output : Vt_I4*: retVal
	CurrentIsOffscreen[]
	{
		get {
			If !DllCall(this.__Vt(38), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentIsPassword; VTable PositonGet: 35; output : Vt_I4*: retVal
	CurrentIsPassword[]
	{
		get {
			If !DllCall(this.__Vt(35), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentIsRequiredForForm; VTable PositonGet: 41; output : Vt_I4*: retVal
	CurrentIsRequiredForForm[]
	{
		get {
			If !DllCall(this.__Vt(41), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentItemStatus; VTable PositonGet: 42; output : Vt_Bstr*: retVal
	CurrentItemStatus[]
	{
		get {
			If !DllCall(this.__Vt(42), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentItemType; VTable PositonGet: 37; output : Vt_Bstr*: retVal
	CurrentItemType[]
	{
		get {
			If !DllCall(this.__Vt(37), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentLabeledBy; VTable PositonGet: 44; output : IUIAutomationElement**: retVal
	CurrentLabeledBy[]
	{
		get {
			If !DllCall(this.__Vt(44), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationElement(out)
				return out
			}
		}
	}
	; Property: CurrentLocalizedControlType; VTable PositonGet: 22; output : Vt_Bstr*: retVal
	CurrentLocalizedControlType[]
	{
		get {
			If !DllCall(this.__Vt(22), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentName; VTable PositonGet: 23; output : Vt_Bstr*: retVal
	CurrentName[]
	{
		get {
			If !DllCall(this.__Vt(23), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentNativeWindowHandle; VTable PositonGet: 36; output : Vt_Void**: retVal
	CurrentNativeWindowHandle[]
	{
		get {
			If !DllCall(this.__Vt(36), "Ptr", this.__Value, "Ptr*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentOrientation; VTable PositonGet: 39; output : OrientationType*: retVal
	CurrentOrientation[]
	{
		get {
			If !DllCall(this.__Vt(39), "Ptr", this.__Value, "UInt",out)
			{
				return out
			}
		}
	}
	; Property: CurrentProcessId; VTable PositonGet: 20; output : Vt_Int*: retVal
	CurrentProcessId[]
	{
		get {
			If !DllCall(this.__Vt(20), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentProviderDescription; VTable PositonGet: 51; output : Vt_Bstr*: retVal
	CurrentProviderDescription[]
	{
		get {
			If !DllCall(this.__Vt(51), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationCondition
; GUID: {352FFBA8-0973-437C-A61F-F64CAFD81DF9}
; *************************************************************************


class IUIAutomationCondition
{
	; Generic definitions

	static __IID := "{352FFBA8-0973-437C-A61F-F64CAFD81DF9}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationCondition"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

}

; *************************************************************************
; IUIAutomationElementArray
; GUID: {14314595-B4BC-4055-95F2-58F2E42C9855}
; *************************************************************************


class IUIAutomationElementArray
{
	; Generic definitions

	static __IID := "{14314595-B4BC-4055-95F2-58F2E42C9855}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationElementArray"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 4: INVOKE_FUNC Vt_Hresult GetElement([FIN] Int: index, [FOUT] [FRETVAL] IUIAutomationElement**: element)
	GetElement(index)
	{
		res:=DllCall(this.__Vt(4), "Ptr", this.__Value, "Int", index, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetElement in IUIAutomationElementArray")
		out:= new IUIAutomationElement(out)
		return out
	}

	; Property: Length; VTable PositonGet: 3; output : Vt_Int*: Length
	Length[]
	{
		get {
			If !DllCall(this.__Vt(3), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationCacheRequest
; GUID: {B32A92B5-BC25-4078-9C08-D7EE95C48E03}
; *************************************************************************


class IUIAutomationCacheRequest
{
	; Generic definitions

	static __IID := "{B32A92B5-BC25-4078-9C08-D7EE95C48E03}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationCacheRequest"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult AddProperty([FIN] Int: propertyId)
	AddProperty(propertyId)
	{
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Int", propertyId, "Int")
		return res
	}

	; VTable Positon 4: INVOKE_FUNC Vt_Hresult AddPattern([FIN] Int: patternId)
	AddPattern(patternId)
	{
		res:=DllCall(this.__Vt(4), "Ptr", this.__Value, "Int", patternId, "Int")
		return res
	}

	; VTable Positon 5: INVOKE_FUNC Vt_Hresult Clone([FOUT] [FRETVAL] IUIAutomationCacheRequest**: clonedRequest)
	Clone()
	{
		res:=DllCall(this.__Vt(5), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from Clone in IUIAutomationCacheRequest")
		out:= new IUIAutomationCacheRequest(out)
		return out
	}

	; Property: AutomationElementMode; VTable PositonGet: 10; output : AutomationElementMode*: mode; VTable PositonPut: 11; input : AutomationElementMode: mode
	AutomationElementMode[]
	{
		get {
			If !DllCall(this.__Vt(10), "Ptr", this.__Value, "UInt",out)
			{
				return out
			}
		}
		set {
			If !DllCall(this.__Vt(11), "Ptr", this.__Value, "UInt", value)
				return value
		}
	}
	; Property: TreeFilter; VTable PositonGet: 8; output : IUIAutomationCondition**: filter; VTable PositonPut: 9; input : IUIAutomationCondition*: filter
	TreeFilter[]
	{
		get {
			If !DllCall(this.__Vt(8), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationCondition(out)
				return out
			}
		}
		set {
			If !DllCall(this.__Vt(9), "Ptr", this.__Value, "Ptr", value)
				return value
		}
	}
	; Property: TreeScope; VTable PositonGet: 6; output : TreeScope*: scope; VTable PositonPut: 7; input : TreeScope: scope
	TreeScope[]
	{
		get {
			If !DllCall(this.__Vt(6), "Ptr", this.__Value, "UInt",out)
			{
				return out
			}
		}
		set {
			If !DllCall(this.__Vt(7), "Ptr", this.__Value, "UInt", value)
				return value
		}
	}
}

; *************************************************************************
; IUIAutomationBoolCondition
; GUID: {1B4E1F2E-75EB-4D0B-8952-5A69988E2307}
; *************************************************************************


class IUIAutomationBoolCondition extends IUIAutomationCondition
{
	; Interface functions

	; Property: BooleanValue; VTable PositonGet: 3; output : Vt_I4*: boolVal
	BooleanValue[]
	{
		get {
			If !DllCall(this.__Vt(3), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationPropertyCondition
; GUID: {99EBF2CB-5578-4267-9AD4-AFD6EA77E94B}
; *************************************************************************


class IUIAutomationPropertyCondition extends IUIAutomationCondition
{
	; Interface functions

	; Property: PropertyConditionFlags; VTable PositonGet: 5; output : PropertyConditionFlags*: flags
	PropertyConditionFlags[]
	{
		get {
			If !DllCall(this.__Vt(5), "Ptr", this.__Value, "UInt",out)
			{
				return out
			}
		}
	}
	; Property: propertyId; VTable PositonGet: 3; output : Vt_Int*: propertyId
	propertyId[]
	{
		get {
			If !DllCall(this.__Vt(3), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: PropertyValue; VTable PositonGet: 4; output : Vt_Variant*: PropertyValue
	PropertyValue[]
	{
		get {
			If !DllCall(this.__Vt(4), "Ptr", this.__Value, "Ptr*",out)
			{
				out:=ComObject(0x400C, out+0, flag)[]
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationAndCondition
; GUID: {A7D0AF36-B912-45FE-9855-091DDC174AEC}
; *************************************************************************


class IUIAutomationAndCondition extends IUIAutomationCondition
{
	; Interface functions

	; VTable Positon 4: INVOKE_FUNC Vt_Hresult GetChildrenAsNativeArray([FOUT] IUIAutomationCondition***: childArray, [FOUT] Int*: childArrayCount)
	GetChildrenAsNativeArray(byref childArray, byref childArrayCount)
	{
		res:=DllCall(this.__Vt(4), "Ptr", this.__Value, "Ptr*", childArray, "Int*", childArrayCount, "Int")
		return res
	}

	; VTable Positon 5: INVOKE_FUNC Vt_Hresult GetChildren([FOUT] [FRETVAL] Safearray*: childArray)
	GetChildren()
	{
		If (ComObjValue(childArray) & 0x2000)
			refchildArray:=childArray
		else
		{
			refchildArray:=ComObject(0x2003, DllCall("oleaut32\SafeArrayCreateVector", "UInt", 13, "UInt", 0, "UInt", childArray.MaxIndex()),1)
			For ind, val in childArray
				refchildArray[A_Index-1]:= val.__Value, ObjAddRef(val.__Value)
		}
		res:=DllCall(this.__Vt(5), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetChildren in IUIAutomationAndCondition")
		return out
	}

	; Property: ChildCount; VTable PositonGet: 3; output : Vt_Int*: ChildCount
	ChildCount[]
	{
		get {
			If !DllCall(this.__Vt(3), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationOrCondition
; GUID: {8753F032-3DB1-47B5-A1FC-6E34A266C712}
; *************************************************************************


class IUIAutomationOrCondition extends IUIAutomationCondition
{
	; Interface functions

	; VTable Positon 4: INVOKE_FUNC Vt_Hresult GetChildrenAsNativeArray([FOUT] IUIAutomationCondition***: childArray, [FOUT] Int*: childArrayCount)
	GetChildrenAsNativeArray(byref childArray, byref childArrayCount)
	{
		res:=DllCall(this.__Vt(4), "Ptr", this.__Value, "Ptr*", childArray, "Int*", childArrayCount, "Int")
		return res
	}

	; VTable Positon 5: INVOKE_FUNC Vt_Hresult GetChildren([FOUT] [FRETVAL] Safearray*: childArray)
	GetChildren()
	{
		If (ComObjValue(childArray) & 0x2000)
			refchildArray:=childArray
		else
		{
			refchildArray:=ComObject(0x2003, DllCall("oleaut32\SafeArrayCreateVector", "UInt", 13, "UInt", 0, "UInt", childArray.MaxIndex()),1)
			For ind, val in childArray
				refchildArray[A_Index-1]:= val.__Value, ObjAddRef(val.__Value)
		}
		res:=DllCall(this.__Vt(5), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetChildren in IUIAutomationOrCondition")
		return out
	}

	; Property: ChildCount; VTable PositonGet: 3; output : Vt_Int*: ChildCount
	ChildCount[]
	{
		get {
			If !DllCall(this.__Vt(3), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationNotCondition
; GUID: {F528B657-847B-498C-8896-D52B565407A1}
; *************************************************************************


class IUIAutomationNotCondition extends IUIAutomationCondition
{
	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult GetChild([FOUT] [FRETVAL] IUIAutomationCondition**: condition)
	GetChild()
	{
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetChild in IUIAutomationNotCondition")
		out:= new IUIAutomationCondition(out)
		return out
	}

}

; *************************************************************************
; IUIAutomationTreeWalker
; GUID: {4042C624-389C-4AFC-A630-9DF854A541FC}
; *************************************************************************


class IUIAutomationTreeWalker
{
	; Generic definitions

	static __IID := "{4042C624-389C-4AFC-A630-9DF854A541FC}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationTreeWalker"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult GetParentElement([FIN] IUIAutomationElement*: element, [FOUT] [FRETVAL] IUIAutomationElement**: parent)
	GetParentElement(element)
	{
		If (IsObject(element) and (ComObjType(element)=""))
			refelement:=element.__Value
		else
			refelement:=element
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Ptr", refelement, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetParentElement in IUIAutomationTreeWalker")
		out:= new IUIAutomationElement(out)
		return out
	}

	; VTable Positon 4: INVOKE_FUNC Vt_Hresult GetFirstChildElement([FIN] IUIAutomationElement*: element, [FOUT] [FRETVAL] IUIAutomationElement**: first)
	GetFirstChildElement(element)
	{
		If (IsObject(element) and (ComObjType(element)=""))
			refelement:=element.__Value
		else
			refelement:=element
		res:=DllCall(this.__Vt(4), "Ptr", this.__Value, "Ptr", refelement, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetFirstChildElement in IUIAutomationTreeWalker")
		out:= new IUIAutomationElement(out)
		return out
	}

	; VTable Positon 5: INVOKE_FUNC Vt_Hresult GetLastChildElement([FIN] IUIAutomationElement*: element, [FOUT] [FRETVAL] IUIAutomationElement**: last)
	GetLastChildElement(element)
	{
		If (IsObject(element) and (ComObjType(element)=""))
			refelement:=element.__Value
		else
			refelement:=element
		res:=DllCall(this.__Vt(5), "Ptr", this.__Value, "Ptr", refelement, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetLastChildElement in IUIAutomationTreeWalker")
		out:= new IUIAutomationElement(out)
		return out
	}

	; VTable Positon 6: INVOKE_FUNC Vt_Hresult GetNextSiblingElement([FIN] IUIAutomationElement*: element, [FOUT] [FRETVAL] IUIAutomationElement**: next)
	GetNextSiblingElement(element)
	{
		If (IsObject(element) and (ComObjType(element)=""))
			refelement:=element.__Value
		else
			refelement:=element
		res:=DllCall(this.__Vt(6), "Ptr", this.__Value, "Ptr", refelement, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetNextSiblingElement in IUIAutomationTreeWalker")
		out:= new IUIAutomationElement(out)
		return out
	}

	; VTable Positon 7: INVOKE_FUNC Vt_Hresult GetPreviousSiblingElement([FIN] IUIAutomationElement*: element, [FOUT] [FRETVAL] IUIAutomationElement**: previous)
	GetPreviousSiblingElement(element)
	{
		If (IsObject(element) and (ComObjType(element)=""))
			refelement:=element.__Value
		else
			refelement:=element
		res:=DllCall(this.__Vt(7), "Ptr", this.__Value, "Ptr", refelement, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetPreviousSiblingElement in IUIAutomationTreeWalker")
		out:= new IUIAutomationElement(out)
		return out
	}

	; VTable Positon 8: INVOKE_FUNC Vt_Hresult NormalizeElement([FIN] IUIAutomationElement*: element, [FOUT] [FRETVAL] IUIAutomationElement**: normalized)
	NormalizeElement(element)
	{
		If (IsObject(element) and (ComObjType(element)=""))
			refelement:=element.__Value
		else
			refelement:=element
		res:=DllCall(this.__Vt(8), "Ptr", this.__Value, "Ptr", refelement, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from NormalizeElement in IUIAutomationTreeWalker")
		out:= new IUIAutomationElement(out)
		return out
	}

	; VTable Positon 9: INVOKE_FUNC Vt_Hresult GetParentElementBuildCache([FIN] IUIAutomationElement*: element, [FIN] IUIAutomationCacheRequest*: cacheRequest, [FOUT] [FRETVAL] IUIAutomationElement**: parent)
	GetParentElementBuildCache(element, cacheRequest)
	{
		If (IsObject(element) and (ComObjType(element)=""))
			refelement:=element.__Value
		else
			refelement:=element
		If (IsObject(cacheRequest) and (ComObjType(cacheRequest)=""))
			refcacheRequest:=cacheRequest.__Value
		else
			refcacheRequest:=cacheRequest
		res:=DllCall(this.__Vt(9), "Ptr", this.__Value, "Ptr", refelement, "Ptr", refcacheRequest, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetParentElementBuildCache in IUIAutomationTreeWalker")
		out:= new IUIAutomationElement(out)
		return out
	}

	; VTable Positon 10: INVOKE_FUNC Vt_Hresult GetFirstChildElementBuildCache([FIN] IUIAutomationElement*: element, [FIN] IUIAutomationCacheRequest*: cacheRequest, [FOUT] [FRETVAL] IUIAutomationElement**: first)
	GetFirstChildElementBuildCache(element, cacheRequest)
	{
		If (IsObject(element) and (ComObjType(element)=""))
			refelement:=element.__Value
		else
			refelement:=element
		If (IsObject(cacheRequest) and (ComObjType(cacheRequest)=""))
			refcacheRequest:=cacheRequest.__Value
		else
			refcacheRequest:=cacheRequest
		res:=DllCall(this.__Vt(10), "Ptr", this.__Value, "Ptr", refelement, "Ptr", refcacheRequest, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetFirstChildElementBuildCache in IUIAutomationTreeWalker")
		out:= new IUIAutomationElement(out)
		return out
	}

	; VTable Positon 11: INVOKE_FUNC Vt_Hresult GetLastChildElementBuildCache([FIN] IUIAutomationElement*: element, [FIN] IUIAutomationCacheRequest*: cacheRequest, [FOUT] [FRETVAL] IUIAutomationElement**: last)
	GetLastChildElementBuildCache(element, cacheRequest)
	{
		If (IsObject(element) and (ComObjType(element)=""))
			refelement:=element.__Value
		else
			refelement:=element
		If (IsObject(cacheRequest) and (ComObjType(cacheRequest)=""))
			refcacheRequest:=cacheRequest.__Value
		else
			refcacheRequest:=cacheRequest
		res:=DllCall(this.__Vt(11), "Ptr", this.__Value, "Ptr", refelement, "Ptr", refcacheRequest, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetLastChildElementBuildCache in IUIAutomationTreeWalker")
		out:= new IUIAutomationElement(out)
		return out
	}

	; VTable Positon 12: INVOKE_FUNC Vt_Hresult GetNextSiblingElementBuildCache([FIN] IUIAutomationElement*: element, [FIN] IUIAutomationCacheRequest*: cacheRequest, [FOUT] [FRETVAL] IUIAutomationElement**: next)
	GetNextSiblingElementBuildCache(element, cacheRequest)
	{
		If (IsObject(element) and (ComObjType(element)=""))
			refelement:=element.__Value
		else
			refelement:=element
		If (IsObject(cacheRequest) and (ComObjType(cacheRequest)=""))
			refcacheRequest:=cacheRequest.__Value
		else
			refcacheRequest:=cacheRequest
		res:=DllCall(this.__Vt(12), "Ptr", this.__Value, "Ptr", refelement, "Ptr", refcacheRequest, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetNextSiblingElementBuildCache in IUIAutomationTreeWalker")
		out:= new IUIAutomationElement(out)
		return out
	}

	; VTable Positon 13: INVOKE_FUNC Vt_Hresult GetPreviousSiblingElementBuildCache([FIN] IUIAutomationElement*: element, [FIN] IUIAutomationCacheRequest*: cacheRequest, [FOUT] [FRETVAL] IUIAutomationElement**: previous)
	GetPreviousSiblingElementBuildCache(element, cacheRequest)
	{
		If (IsObject(element) and (ComObjType(element)=""))
			refelement:=element.__Value
		else
			refelement:=element
		If (IsObject(cacheRequest) and (ComObjType(cacheRequest)=""))
			refcacheRequest:=cacheRequest.__Value
		else
			refcacheRequest:=cacheRequest
		res:=DllCall(this.__Vt(13), "Ptr", this.__Value, "Ptr", refelement, "Ptr", refcacheRequest, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetPreviousSiblingElementBuildCache in IUIAutomationTreeWalker")
		out:= new IUIAutomationElement(out)
		return out
	}

	; VTable Positon 14: INVOKE_FUNC Vt_Hresult NormalizeElementBuildCache([FIN] IUIAutomationElement*: element, [FIN] IUIAutomationCacheRequest*: cacheRequest, [FOUT] [FRETVAL] IUIAutomationElement**: normalized)
	NormalizeElementBuildCache(element, cacheRequest)
	{
		If (IsObject(element) and (ComObjType(element)=""))
			refelement:=element.__Value
		else
			refelement:=element
		If (IsObject(cacheRequest) and (ComObjType(cacheRequest)=""))
			refcacheRequest:=cacheRequest.__Value
		else
			refcacheRequest:=cacheRequest
		res:=DllCall(this.__Vt(14), "Ptr", this.__Value, "Ptr", refelement, "Ptr", refcacheRequest, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from NormalizeElementBuildCache in IUIAutomationTreeWalker")
		out:= new IUIAutomationElement(out)
		return out
	}

	; Property: condition; VTable PositonGet: 15; output : IUIAutomationCondition**: condition
	condition[]
	{
		get {
			If !DllCall(this.__Vt(15), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationCondition(out)
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationEventHandlerImpl

; This class provides a basic implementation wrapper for IUIAutomationEventHandler.
; WARNING: This currently only works in 64bit!
; To use you need to provide an implementation for the exported functions in your script.
; Example:
;~ #Include ComImplementationBase.ahk
;~ class YourClassName extends IUIAutomationEventHandlerImpl
;~ {
;~	HandleAutomationEvent(pInterface, sender, eventId)
;~	{
;~		; your code
;~	}
;~ }
;~
; GUID: {146C3C17-F12E-4E22-8C27-F894B9B79C69}
; *************************************************************************


class IUIAutomationEventHandlerImpl extends IUnknownImpl
{	ComFunctions := ["QueryInterface", "AddRef", "Release", "HandleAutomationEvent"]

	__New()
	{
		; Add the GUID of the interface this class is implementing
		this.ImplementsInterfaces.InsertAt(1, "{146C3C17-F12E-4E22-8C27-F894B9B79C69}")
		base.__New()
	}

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult HandleAutomationEvent([FIN] IUIAutomationElement*: sender, [FIN] Int: eventId)
	_HandleAutomationEvent(pInterface, sender, eventId)
	{
		if (!IsObject(this))
			return ComObjImpl.ObjMap[this]._HandleAutomationEvent(this, pInterface, sender)

		this.HandleAutomationEvent(pInterface, sender, eventId)
	}
}

; *************************************************************************
; IUIAutomationEventHandler
; GUID: {146C3C17-F12E-4E22-8C27-F894B9B79C69}
; *************************************************************************


class IUIAutomationEventHandler
{
	; Generic definitions

	static __IID := "{146C3C17-F12E-4E22-8C27-F894B9B79C69}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationEventHandler"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult HandleAutomationEvent([FIN] IUIAutomationElement*: sender, [FIN] Int: eventId)
	HandleAutomationEvent(sender, eventId)
	{
		If (IsObject(sender) and (ComObjType(sender)=""))
			refsender:=sender.__Value
		else
			refsender:=sender
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Ptr", refsender, "Int", eventId, "Int")
		return res
	}

}

; *************************************************************************
; IUIAutomationPropertyChangedEventHandlerImpl

; This class provides a basic implementation wrapper for IUIAutomationPropertyChangedEventHandler.
; WARNING: This currently only works in 64bit!
; To use you need to provide an implementation for the exported functions in your script.
; Example:
;~ #Include ComImplementationBase.ahk
;~ class YourClassName extends IUIAutomationPropertyChangedEventHandlerImpl
;~ {
;~	HandlePropertyChangedEvent(pInterface, sender, propertyId, newValue)
;~	{
;~		; your code
;~	}
;~ }
;~
; GUID: {40CD37D4-C756-4B0C-8C6F-BDDFEEB13B50}
; *************************************************************************


class IUIAutomationPropertyChangedEventHandlerImpl extends IUnknownImpl
{	ComFunctions := ["QueryInterface", "AddRef", "Release", "HandlePropertyChangedEvent"]

	__New()
	{
		; Add the GUID of the interface this class is implementing
		this.ImplementsInterfaces.InsertAt(1, "{40CD37D4-C756-4B0C-8C6F-BDDFEEB13B50}")
		base.__New()
	}

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult HandlePropertyChangedEvent([FIN] IUIAutomationElement*: sender, [FIN] Int: propertyId, [FIN] Variant: newValue)
	_HandlePropertyChangedEvent(pInterface, sender, propertyId, newValue)
	{
		if (!IsObject(this))
			return ComObjImpl.ObjMap[this]._HandlePropertyChangedEvent(this, pInterface, sender, propertyId)

		this.HandlePropertyChangedEvent(pInterface, sender, propertyId, newValue)
	}
}

; *************************************************************************
; IUIAutomationPropertyChangedEventHandler
; GUID: {40CD37D4-C756-4B0C-8C6F-BDDFEEB13B50}
; *************************************************************************


class IUIAutomationPropertyChangedEventHandler
{
	; Generic definitions

	static __IID := "{40CD37D4-C756-4B0C-8C6F-BDDFEEB13B50}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationPropertyChangedEventHandler"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult HandlePropertyChangedEvent([FIN] IUIAutomationElement*: sender, [FIN] Int: propertyId, [FIN] Variant: newValue)
	HandlePropertyChangedEvent(sender, propertyId, newValue, newValueVariantType)
	{
		if (newValueVariantType!=12) ; newValue is not a variant
		{
			VarSetCapacity(refnewValue,8+2*A_PtrSize)
			variant_ref := ComObject(0x400C, &refnewValue)
			variant_ref[] := newValue
			NumPut(newValueVariantType, refnewValue, 0, "short")
		}
		else
			refnewValue:=newValue
		If (IsObject(sender) and (ComObjType(sender)=""))
			refsender:=sender.__Value
		else
			refsender:=sender
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Ptr", refsender, "Int", propertyId, "Ptr", &refnewValue, "Int")
		return res
	}

}

; *************************************************************************
; IUIAutomationStructureChangedEventHandlerImpl

; This class provides a basic implementation wrapper for IUIAutomationStructureChangedEventHandler.
; WARNING: This currently only works in 64bit!
; To use you need to provide an implementation for the exported functions in your script.
; Example:
;~ #Include ComImplementationBase.ahk
;~ class YourClassName extends IUIAutomationStructureChangedEventHandlerImpl
;~ {
;~	HandleStructureChangedEvent(pInterface, sender, changeType, runtimeId)
;~	{
;~		; your code
;~	}
;~ }
;~
; GUID: {E81D1B4E-11C5-42F8-9754-E7036C79F054}
; *************************************************************************


class IUIAutomationStructureChangedEventHandlerImpl extends IUnknownImpl
{	ComFunctions := ["QueryInterface", "AddRef", "Release", "HandleStructureChangedEvent"]

	__New()
	{
		; Add the GUID of the interface this class is implementing
		this.ImplementsInterfaces.InsertAt(1, "{E81D1B4E-11C5-42F8-9754-E7036C79F054}")
		base.__New()
	}

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult HandleStructureChangedEvent([FIN] IUIAutomationElement*: sender, [FIN] StructureChangeType: changeType, [FIN] Safearray: runtimeId)
	_HandleStructureChangedEvent(pInterface, sender, changeType, runtimeId)
	{
		if (!IsObject(this))
			return ComObjImpl.ObjMap[this]._HandleStructureChangedEvent(this, pInterface, sender, changeType)

		this.HandleStructureChangedEvent(pInterface, sender, changeType, runtimeId)
	}
}

; *************************************************************************
; IUIAutomationStructureChangedEventHandler
; GUID: {E81D1B4E-11C5-42F8-9754-E7036C79F054}
; *************************************************************************


class IUIAutomationStructureChangedEventHandler
{
	; Generic definitions

	static __IID := "{E81D1B4E-11C5-42F8-9754-E7036C79F054}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationStructureChangedEventHandler"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult HandleStructureChangedEvent([FIN] IUIAutomationElement*: sender, [FIN] StructureChangeType: changeType, [FIN] Safearray: runtimeId)
	HandleStructureChangedEvent(sender, changeType, runtimeId)
	{
		If (IsObject(sender) and (ComObjType(sender)=""))
			refsender:=sender.__Value
		else
			refsender:=sender
		If (ComObjValue(runtimeId) & 0x2000)
			refruntimeId:=runtimeId
		else
		{
			refruntimeId:=ComObject(0x2003, DllCall("oleaut32\SafeArrayCreateVector", "UInt", 13, "UInt", 0, "UInt", runtimeId.MaxIndex()),1)
			For ind, val in runtimeId
				refruntimeId[A_Index-1]:= val.__Value, ObjAddRef(val.__Value)
		}
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Ptr", refsender, "UInt", changeType, "Ptr", ComObjValue(refruntimeId), "Int")
		return res
	}

}

; *************************************************************************
; IUIAutomationFocusChangedEventHandlerImpl

; This class provides a basic implementation wrapper for IUIAutomationFocusChangedEventHandler.
; WARNING: This currently only works in 64bit!
; To use you need to provide an implementation for the exported functions in your script.
; Example:
;~ #Include ComImplementationBase.ahk
;~ class YourClassName extends IUIAutomationFocusChangedEventHandlerImpl
;~ {
;~	HandleFocusChangedEvent(pInterface, sender)
;~	{
;~		; your code
;~	}
;~ }
;~
; GUID: {C270F6B5-5C69-4290-9745-7A7F97169468}
; *************************************************************************


class IUIAutomationFocusChangedEventHandlerImpl extends IUnknownImpl
{	ComFunctions := ["QueryInterface", "AddRef", "Release", "HandleFocusChangedEvent"]

	__New()
	{
		; Add the GUID of the interface this class is implementing
		this.ImplementsInterfaces.InsertAt(1, "{C270F6B5-5C69-4290-9745-7A7F97169468}")
		base.__New()
	}

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult HandleFocusChangedEvent([FIN] IUIAutomationElement*: sender)
	_HandleFocusChangedEvent(pInterface, sender)
	{
		if (!IsObject(this))
			return ComObjImpl.ObjMap[this]._HandleFocusChangedEvent(this, pInterface)

		this.HandleFocusChangedEvent(pInterface, sender)
	}
}

; *************************************************************************
; IUIAutomationFocusChangedEventHandler
; GUID: {C270F6B5-5C69-4290-9745-7A7F97169468}
; *************************************************************************


class IUIAutomationFocusChangedEventHandler
{
	; Generic definitions

	static __IID := "{C270F6B5-5C69-4290-9745-7A7F97169468}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationFocusChangedEventHandler"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult HandleFocusChangedEvent([FIN] IUIAutomationElement*: sender)
	HandleFocusChangedEvent(sender)
	{
		If (IsObject(sender) and (ComObjType(sender)=""))
			refsender:=sender.__Value
		else
			refsender:=sender
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Ptr", refsender, "Int")
		return res
	}

}

; *************************************************************************
; IUIAutomationTextEditTextChangedEventHandlerImpl

; This class provides a basic implementation wrapper for IUIAutomationTextEditTextChangedEventHandler.
; WARNING: This currently only works in 64bit!
; To use you need to provide an implementation for the exported functions in your script.
; Example:
;~ #Include ComImplementationBase.ahk
;~ class YourClassName extends IUIAutomationTextEditTextChangedEventHandlerImpl
;~ {
;~	HandleTextEditTextChangedEvent(pInterface, sender, TextEditChangeType, eventStrings)
;~	{
;~		; your code
;~	}
;~ }
;~
; GUID: {92FAA680-E704-4156-931A-E32D5BB38F3F}
; *************************************************************************


class IUIAutomationTextEditTextChangedEventHandlerImpl extends IUnknownImpl
{	ComFunctions := ["QueryInterface", "AddRef", "Release", "HandleTextEditTextChangedEvent"]

	__New()
	{
		; Add the GUID of the interface this class is implementing
		this.ImplementsInterfaces.InsertAt(1, "{92FAA680-E704-4156-931A-E32D5BB38F3F}")
		base.__New()
	}

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult HandleTextEditTextChangedEvent([FIN] IUIAutomationElement*: sender, [FIN] TextEditChangeType: TextEditChangeType, [FIN] Safearray: eventStrings)
	_HandleTextEditTextChangedEvent(pInterface, sender, TextEditChangeType, eventStrings)
	{
		if (!IsObject(this))
			return ComObjImpl.ObjMap[this]._HandleTextEditTextChangedEvent(this, pInterface, sender, TextEditChangeType)

		this.HandleTextEditTextChangedEvent(pInterface, sender, TextEditChangeType, eventStrings)
	}
}

; *************************************************************************
; IUIAutomationTextEditTextChangedEventHandler
; GUID: {92FAA680-E704-4156-931A-E32D5BB38F3F}
; *************************************************************************


class IUIAutomationTextEditTextChangedEventHandler
{
	; Generic definitions

	static __IID := "{92FAA680-E704-4156-931A-E32D5BB38F3F}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationTextEditTextChangedEventHandler"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult HandleTextEditTextChangedEvent([FIN] IUIAutomationElement*: sender, [FIN] TextEditChangeType: TextEditChangeType, [FIN] Safearray: eventStrings)
	HandleTextEditTextChangedEvent(sender, TextEditChangeType, eventStrings)
	{
		If (IsObject(sender) and (ComObjType(sender)=""))
			refsender:=sender.__Value
		else
			refsender:=sender
		If (ComObjValue(eventStrings) & 0x2000)
			refeventStrings:=eventStrings
		else
		{
			refeventStrings:=ComObject(0x2003, DllCall("oleaut32\SafeArrayCreateVector", "UInt", 13, "UInt", 0, "UInt", eventStrings.MaxIndex()),1)
			For ind, val in eventStrings
				refeventStrings[A_Index-1]:= val.__Value, ObjAddRef(val.__Value)
		}
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Ptr", refsender, "UInt", TextEditChangeType, "Ptr", ComObjValue(refeventStrings), "Int")
		return res
	}

}

; *************************************************************************
; IUIAutomationChangesEventHandlerImpl

; This class provides a basic implementation wrapper for IUIAutomationChangesEventHandler.
; WARNING: This currently only works in 64bit!
; To use you need to provide an implementation for the exported functions in your script.
; Example:
;~ #Include ComImplementationBase.ahk
;~ class YourClassName extends IUIAutomationChangesEventHandlerImpl
;~ {
;~	HandleChangesEvent(pInterface, sender, uiaChanges, changesCount)
;~	{
;~		; your code
;~	}
;~ }
;~
; GUID: {58EDCA55-2C3E-4980-B1B9-56C17F27A2A0}
; *************************************************************************


class IUIAutomationChangesEventHandlerImpl extends IUnknownImpl
{	ComFunctions := ["QueryInterface", "AddRef", "Release", "HandleChangesEvent"]

	__New()
	{
		; Add the GUID of the interface this class is implementing
		this.ImplementsInterfaces.InsertAt(1, "{58EDCA55-2C3E-4980-B1B9-56C17F27A2A0}")
		base.__New()
	}

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult HandleChangesEvent([FIN] IUIAutomationElement*: sender, [FIN] UiaChangeInfo*: uiaChanges, [FIN] Int: changesCount)
	_HandleChangesEvent(pInterface, sender, uiaChanges, changesCount)
	{
		if (!IsObject(this))
			return ComObjImpl.ObjMap[this]._HandleChangesEvent(this, pInterface, sender, uiaChanges)

		this.HandleChangesEvent(pInterface, sender, uiaChanges, changesCount)
	}
}

; *************************************************************************
; IUIAutomationChangesEventHandler
; GUID: {58EDCA55-2C3E-4980-B1B9-56C17F27A2A0}
; *************************************************************************


class IUIAutomationChangesEventHandler
{
	; Generic definitions

	static __IID := "{58EDCA55-2C3E-4980-B1B9-56C17F27A2A0}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationChangesEventHandler"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult HandleChangesEvent([FIN] IUIAutomationElement*: sender, [FIN] UiaChangeInfo*: uiaChanges, [FIN] Int: changesCount)
	HandleChangesEvent(sender, uiaChanges, changesCount) {
		If (IsObject(sender) and (ComObjType(sender)=""))
			refsender:=sender.__Value
		else
			refsender:=sender
		If (IsObject(uiaChanges) and (ComObjType(uiaChanges)=""))
			refuiaChanges:=uiaChanges.__Value
		else
			refuiaChanges:=&uiaChanges
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Ptr", refsender, "Ptr", refuiaChanges, "Int", changesCount, "Int")
		return res
	}

}

; *************************************************************************
; IUIAutomationInvokePattern
; GUID: {FB377FBE-8EA6-46D5-9C73-6499642D3059}
; *************************************************************************


class IUIAutomationInvokePattern
{
	; Generic definitions

	static __IID := "{FB377FBE-8EA6-46D5-9C73-6499642D3059}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationInvokePattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult Invoke()
	Invoke()
	{
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Int")
		return res
	}

}

; *************************************************************************
; IUIAutomationDockPattern
; GUID: {FDE5EF97-1464-48F6-90BF-43D0948E86EC}
; *************************************************************************


class IUIAutomationDockPattern
{
	; Generic definitions

	static __IID := "{FDE5EF97-1464-48F6-90BF-43D0948E86EC}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationDockPattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult SetDockPosition([FIN] DockPosition: dockPos)
	SetDockPosition(dockPos)
	{
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "UInt", dockPos, "Int")
		return res
	}

	; Property: CachedDockPosition; VTable PositonGet: 5; output : DockPosition*: retVal
	CachedDockPosition[]
	{
		get {
			If !DllCall(this.__Vt(5), "Ptr", this.__Value, "UInt",out)
			{
				return out
			}
		}
	}
	; Property: CurrentDockPosition; VTable PositonGet: 4; output : DockPosition*: retVal
	CurrentDockPosition[]
	{
		get {
			If !DllCall(this.__Vt(4), "Ptr", this.__Value, "UInt",out)
			{
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationExpandCollapsePattern
; GUID: {619BE086-1F4E-4EE4-BAFA-210128738730}
; *************************************************************************


class IUIAutomationExpandCollapsePattern
{
	; Generic definitions

	static __IID := "{619BE086-1F4E-4EE4-BAFA-210128738730}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationExpandCollapsePattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult Expand()
	Expand()
	{
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Int")
		return res
	}

	; VTable Positon 4: INVOKE_FUNC Vt_Hresult Collapse()
	Collapse()
	{
		res:=DllCall(this.__Vt(4), "Ptr", this.__Value, "Int")
		return res
	}

	; Property: CachedExpandCollapseState; VTable PositonGet: 6; output : ExpandCollapseState*: retVal
	CachedExpandCollapseState[]
	{
		get {
			If !DllCall(this.__Vt(6), "Ptr", this.__Value, "UInt",out)
			{
				return out
			}
		}
	}
	; Property: CurrentExpandCollapseState; VTable PositonGet: 5; output : ExpandCollapseState*: retVal
	CurrentExpandCollapseState[]
	{
		get {
			If !DllCall(this.__Vt(5), "Ptr", this.__Value, "UInt",out)
			{
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationGridPattern
; GUID: {414C3CDC-856B-4F5B-8538-3131C6302550}
; *************************************************************************


class IUIAutomationGridPattern
{
	; Generic definitions

	static __IID := "{414C3CDC-856B-4F5B-8538-3131C6302550}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationGridPattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult GetItem([FIN] Int: row, [FIN] Int: column, [FOUT] [FRETVAL] IUIAutomationElement**: element)
	GetItem(row, column)
	{
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Int", row, "Int", column, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetItem in IUIAutomationGridPattern")
		out:= new IUIAutomationElement(out)
		return out
	}

	; Property: CachedColumnCount; VTable PositonGet: 7; output : Vt_Int*: retVal
	CachedColumnCount[]
	{
		get {
			If !DllCall(this.__Vt(7), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedRowCount; VTable PositonGet: 6; output : Vt_Int*: retVal
	CachedRowCount[]
	{
		get {
			If !DllCall(this.__Vt(6), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentColumnCount; VTable PositonGet: 5; output : Vt_Int*: retVal
	CurrentColumnCount[]
	{
		get {
			If !DllCall(this.__Vt(5), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentRowCount; VTable PositonGet: 4; output : Vt_Int*: retVal
	CurrentRowCount[]
	{
		get {
			If !DllCall(this.__Vt(4), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationGridItemPattern
; GUID: {78F8EF57-66C3-4E09-BD7C-E79B2004894D}
; *************************************************************************


class IUIAutomationGridItemPattern
{
	; Generic definitions

	static __IID := "{78F8EF57-66C3-4E09-BD7C-E79B2004894D}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationGridItemPattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; Property: CachedColumn; VTable PositonGet: 10; output : Vt_Int*: retVal
	CachedColumn[]
	{
		get {
			If !DllCall(this.__Vt(10), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedColumnSpan; VTable PositonGet: 12; output : Vt_Int*: retVal
	CachedColumnSpan[]
	{
		get {
			If !DllCall(this.__Vt(12), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedContainingGrid; VTable PositonGet: 8; output : IUIAutomationElement**: retVal
	CachedContainingGrid[]
	{
		get {
			If !DllCall(this.__Vt(8), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationElement(out)
				return out
			}
		}
	}
	; Property: CachedRow; VTable PositonGet: 9; output : Vt_Int*: retVal
	CachedRow[]
	{
		get {
			If !DllCall(this.__Vt(9), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedRowSpan; VTable PositonGet: 11; output : Vt_Int*: retVal
	CachedRowSpan[]
	{
		get {
			If !DllCall(this.__Vt(11), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentColumn; VTable PositonGet: 5; output : Vt_Int*: retVal
	CurrentColumn[]
	{
		get {
			If !DllCall(this.__Vt(5), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentColumnSpan; VTable PositonGet: 7; output : Vt_Int*: retVal
	CurrentColumnSpan[]
	{
		get {
			If !DllCall(this.__Vt(7), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentContainingGrid; VTable PositonGet: 3; output : IUIAutomationElement**: retVal
	CurrentContainingGrid[]
	{
		get {
			If !DllCall(this.__Vt(3), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationElement(out)
				return out
			}
		}
	}
	; Property: CurrentRow; VTable PositonGet: 4; output : Vt_Int*: retVal
	CurrentRow[]
	{
		get {
			If !DllCall(this.__Vt(4), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentRowSpan; VTable PositonGet: 6; output : Vt_Int*: retVal
	CurrentRowSpan[]
	{
		get {
			If !DllCall(this.__Vt(6), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationMultipleViewPattern
; GUID: {8D253C91-1DC5-4BB5-B18F-ADE16FA495E8}
; *************************************************************************


class IUIAutomationMultipleViewPattern
{
	; Generic definitions

	static __IID := "{8D253C91-1DC5-4BB5-B18F-ADE16FA495E8}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationMultipleViewPattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult GetViewName([FIN] Int: view, [FOUT] [FRETVAL] Bstr*: name)
	GetViewName(view)
	{
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Int", view, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetViewName in IUIAutomationMultipleViewPattern")
		out:= StrGet(out)
		return out
	}

	; VTable Positon 4: INVOKE_FUNC Vt_Hresult SetCurrentView([FIN] Int: view)
	SetCurrentView(view)
	{
		res:=DllCall(this.__Vt(4), "Ptr", this.__Value, "Int", view, "Int")
		return res
	}

	; VTable Positon 6: INVOKE_FUNC Vt_Hresult GetCurrentSupportedViews([FOUT] [FRETVAL] Safearray*: retVal)
	GetCurrentSupportedViews()
	{
		If (ComObjValue(retVal) & 0x2000)
			refretVal:=retVal
		else
		{
			refretVal:=ComObject(0x2003, DllCall("oleaut32\SafeArrayCreateVector", "UInt", 13, "UInt", 0, "UInt", retVal.MaxIndex()),1)
			For ind, val in retVal
				refretVal[A_Index-1]:= val.__Value, ObjAddRef(val.__Value)
		}
		res:=DllCall(this.__Vt(6), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCurrentSupportedViews in IUIAutomationMultipleViewPattern")
		return out
	}

	; VTable Positon 8: INVOKE_FUNC Vt_Hresult GetCachedSupportedViews([FOUT] [FRETVAL] Safearray*: retVal)
	GetCachedSupportedViews()
	{
		If (ComObjValue(retVal) & 0x2000)
			refretVal:=retVal
		else
		{
			refretVal:=ComObject(0x2003, DllCall("oleaut32\SafeArrayCreateVector", "UInt", 13, "UInt", 0, "UInt", retVal.MaxIndex()),1)
			For ind, val in retVal
				refretVal[A_Index-1]:= val.__Value, ObjAddRef(val.__Value)
		}
		res:=DllCall(this.__Vt(8), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCachedSupportedViews in IUIAutomationMultipleViewPattern")
		return out
	}

	; Property: CachedCurrentView; VTable PositonGet: 7; output : Vt_Int*: retVal
	CachedCurrentView[]
	{
		get {
			If !DllCall(this.__Vt(7), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentCurrentView; VTable PositonGet: 5; output : Vt_Int*: retVal
	CurrentCurrentView[]
	{
		get {
			If !DllCall(this.__Vt(5), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationObjectModelPattern
; GUID: {71C284B3-C14D-4D14-981E-19751B0D756D}
; *************************************************************************


class IUIAutomationObjectModelPattern
{
	; Generic definitions

	static __IID := "{71C284B3-C14D-4D14-981E-19751B0D756D}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationObjectModelPattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult GetUnderlyingObjectModel([FOUT] [FRETVAL] Unknown*: retVal)
	GetUnderlyingObjectModel()
	{
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetUnderlyingObjectModel in IUIAutomationObjectModelPattern")
		return out
	}

}

; *************************************************************************
; IUIAutomationRangeValuePattern
; GUID: {59213F4F-7346-49E5-B120-80555987A148}
; *************************************************************************


class IUIAutomationRangeValuePattern
{
	; Generic definitions

	static __IID := "{59213F4F-7346-49E5-B120-80555987A148}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationRangeValuePattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult SetValue([FIN] R8: val)
	SetValue(val)
	{
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Double", val, "Int")
		return res
	}

	; Property: CachedIsReadOnly; VTable PositonGet: 11; output : Vt_I4*: retVal
	CachedIsReadOnly[]
	{
		get {
			If !DllCall(this.__Vt(11), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedLargeChange; VTable PositonGet: 14; output : Vt_R8*: retVal
	CachedLargeChange[]
	{
		get {
			If !DllCall(this.__Vt(14), "Ptr", this.__Value, "Double*",out)
			{
				return out
			}
		}
	}
	; Property: CachedMaximum; VTable PositonGet: 12; output : Vt_R8*: retVal
	CachedMaximum[]
	{
		get {
			If !DllCall(this.__Vt(12), "Ptr", this.__Value, "Double*",out)
			{
				return out
			}
		}
	}
	; Property: CachedMinimum; VTable PositonGet: 13; output : Vt_R8*: retVal
	CachedMinimum[]
	{
		get {
			If !DllCall(this.__Vt(13), "Ptr", this.__Value, "Double*",out)
			{
				return out
			}
		}
	}
	; Property: CachedSmallChange; VTable PositonGet: 15; output : Vt_R8*: retVal
	CachedSmallChange[]
	{
		get {
			If !DllCall(this.__Vt(15), "Ptr", this.__Value, "Double*",out)
			{
				return out
			}
		}
	}
	; Property: CachedValue; VTable PositonGet: 10; output : Vt_R8*: retVal
	CachedValue[]
	{
		get {
			If !DllCall(this.__Vt(10), "Ptr", this.__Value, "Double*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentIsReadOnly; VTable PositonGet: 5; output : Vt_I4*: retVal
	CurrentIsReadOnly[]
	{
		get {
			If !DllCall(this.__Vt(5), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentLargeChange; VTable PositonGet: 8; output : Vt_R8*: retVal
	CurrentLargeChange[]
	{
		get {
			If !DllCall(this.__Vt(8), "Ptr", this.__Value, "Double*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentMaximum; VTable PositonGet: 6; output : Vt_R8*: retVal
	CurrentMaximum[]
	{
		get {
			If !DllCall(this.__Vt(6), "Ptr", this.__Value, "Double*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentMinimum; VTable PositonGet: 7; output : Vt_R8*: retVal
	CurrentMinimum[]
	{
		get {
			If !DllCall(this.__Vt(7), "Ptr", this.__Value, "Double*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentSmallChange; VTable PositonGet: 9; output : Vt_R8*: retVal
	CurrentSmallChange[]
	{
		get {
			If !DllCall(this.__Vt(9), "Ptr", this.__Value, "Double*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentValue; VTable PositonGet: 4; output : Vt_R8*: retVal
	CurrentValue[]
	{
		get {
			If !DllCall(this.__Vt(4), "Ptr", this.__Value, "Double*",out)
			{
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationScrollPattern
; GUID: {88F4D42A-E881-459D-A77C-73BBBB7E02DC}
; *************************************************************************


class IUIAutomationScrollPattern
{
	; Generic definitions

	static __IID := "{88F4D42A-E881-459D-A77C-73BBBB7E02DC}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationScrollPattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult Scroll([FIN] ScrollAmount: horizontalAmount, [FIN] ScrollAmount: verticalAmount)
	Scroll(horizontalAmount, verticalAmount)
	{
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "UInt", horizontalAmount, "UInt", verticalAmount, "Int")
		return res
	}

	; VTable Positon 4: INVOKE_FUNC Vt_Hresult SetScrollPercent([FIN] R8: horizontalPercent, [FIN] R8: verticalPercent)
	SetScrollPercent(horizontalPercent, verticalPercent)
	{
		res:=DllCall(this.__Vt(4), "Ptr", this.__Value, "Double", horizontalPercent, "Double", verticalPercent, "Int")
		return res
	}

	; Property: CachedHorizontallyScrollable; VTable PositonGet: 15; output : Vt_I4*: retVal
	CachedHorizontallyScrollable[]
	{
		get {
			If !DllCall(this.__Vt(15), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedHorizontalScrollPercent; VTable PositonGet: 11; output : Vt_R8*: retVal
	CachedHorizontalScrollPercent[]
	{
		get {
			If !DllCall(this.__Vt(11), "Ptr", this.__Value, "Double*",out)
			{
				return out
			}
		}
	}
	; Property: CachedHorizontalViewSize; VTable PositonGet: 13; output : Vt_R8*: retVal
	CachedHorizontalViewSize[]
	{
		get {
			If !DllCall(this.__Vt(13), "Ptr", this.__Value, "Double*",out)
			{
				return out
			}
		}
	}
	; Property: CachedVerticallyScrollable; VTable PositonGet: 16; output : Vt_I4*: retVal
	CachedVerticallyScrollable[]
	{
		get {
			If !DllCall(this.__Vt(16), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedVerticalScrollPercent; VTable PositonGet: 12; output : Vt_R8*: retVal
	CachedVerticalScrollPercent[]
	{
		get {
			If !DllCall(this.__Vt(12), "Ptr", this.__Value, "Double*",out)
			{
				return out
			}
		}
	}
	; Property: CachedVerticalViewSize; VTable PositonGet: 14; output : Vt_R8*: retVal
	CachedVerticalViewSize[]
	{
		get {
			If !DllCall(this.__Vt(14), "Ptr", this.__Value, "Double*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentHorizontallyScrollable; VTable PositonGet: 9; output : Vt_I4*: retVal
	CurrentHorizontallyScrollable[]
	{
		get {
			If !DllCall(this.__Vt(9), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentHorizontalScrollPercent; VTable PositonGet: 5; output : Vt_R8*: retVal
	CurrentHorizontalScrollPercent[]
	{
		get {
			If !DllCall(this.__Vt(5), "Ptr", this.__Value, "Double*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentHorizontalViewSize; VTable PositonGet: 7; output : Vt_R8*: retVal
	CurrentHorizontalViewSize[]
	{
		get {
			If !DllCall(this.__Vt(7), "Ptr", this.__Value, "Double*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentVerticallyScrollable; VTable PositonGet: 10; output : Vt_I4*: retVal
	CurrentVerticallyScrollable[]
	{
		get {
			If !DllCall(this.__Vt(10), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentVerticalScrollPercent; VTable PositonGet: 6; output : Vt_R8*: retVal
	CurrentVerticalScrollPercent[]
	{
		get {
			If !DllCall(this.__Vt(6), "Ptr", this.__Value, "Double*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentVerticalViewSize; VTable PositonGet: 8; output : Vt_R8*: retVal
	CurrentVerticalViewSize[]
	{
		get {
			If !DllCall(this.__Vt(8), "Ptr", this.__Value, "Double*",out)
			{
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationScrollItemPattern
; GUID: {B488300F-D015-4F19-9C29-BB595E3645EF}
; *************************************************************************


class IUIAutomationScrollItemPattern
{
	; Generic definitions

	static __IID := "{B488300F-D015-4F19-9C29-BB595E3645EF}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationScrollItemPattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult ScrollIntoView()
	ScrollIntoView()
	{
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Int")
		return res
	}

}

; *************************************************************************
; IUIAutomationSelectionPattern
; GUID: {5ED5202E-B2AC-47A6-B638-4B0BF140D78E}
; *************************************************************************


class IUIAutomationSelectionPattern
{
	; Generic definitions

	static __IID := "{5ED5202E-B2AC-47A6-B638-4B0BF140D78E}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationSelectionPattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult GetCurrentSelection([FOUT] [FRETVAL] IUIAutomationElementArray**: retVal)
	GetCurrentSelection()
	{
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCurrentSelection in IUIAutomationSelectionPattern")
		out:= new IUIAutomationElementArray(out)
		return out
	}

	; VTable Positon 6: INVOKE_FUNC Vt_Hresult GetCachedSelection([FOUT] [FRETVAL] IUIAutomationElementArray**: retVal)
	GetCachedSelection()
	{
		res:=DllCall(this.__Vt(6), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCachedSelection in IUIAutomationSelectionPattern")
		out:= new IUIAutomationElementArray(out)
		return out
	}

	; Property: CachedCanSelectMultiple; VTable PositonGet: 7; output : Vt_I4*: retVal
	CachedCanSelectMultiple[]
	{
		get {
			If !DllCall(this.__Vt(7), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedIsSelectionRequired; VTable PositonGet: 8; output : Vt_I4*: retVal
	CachedIsSelectionRequired[]
	{
		get {
			If !DllCall(this.__Vt(8), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentCanSelectMultiple; VTable PositonGet: 4; output : Vt_I4*: retVal
	CurrentCanSelectMultiple[]
	{
		get {
			If !DllCall(this.__Vt(4), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentIsSelectionRequired; VTable PositonGet: 5; output : Vt_I4*: retVal
	CurrentIsSelectionRequired[]
	{
		get {
			If !DllCall(this.__Vt(5), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationSelectionItemPattern
; GUID: {A8EFA66A-0FDA-421A-9194-38021F3578EA}
; *************************************************************************


class IUIAutomationSelectionItemPattern
{
	; Generic definitions

	static __IID := "{A8EFA66A-0FDA-421A-9194-38021F3578EA}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationSelectionItemPattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult Select()
	Select()
	{
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Int")
		return res
	}

	; VTable Positon 4: INVOKE_FUNC Vt_Hresult AddToSelection()
	AddToSelection()
	{
		res:=DllCall(this.__Vt(4), "Ptr", this.__Value, "Int")
		return res
	}

	; VTable Positon 5: INVOKE_FUNC Vt_Hresult RemoveFromSelection()
	RemoveFromSelection()
	{
		res:=DllCall(this.__Vt(5), "Ptr", this.__Value, "Int")
		return res
	}

	; Property: CachedIsSelected; VTable PositonGet: 8; output : Vt_I4*: retVal
	CachedIsSelected[]
	{
		get {
			If !DllCall(this.__Vt(8), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedSelectionContainer; VTable PositonGet: 9; output : IUIAutomationElement**: retVal
	CachedSelectionContainer[]
	{
		get {
			If !DllCall(this.__Vt(9), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationElement(out)
				return out
			}
		}
	}
	; Property: CurrentIsSelected; VTable PositonGet: 6; output : Vt_I4*: retVal
	CurrentIsSelected[]
	{
		get {
			If !DllCall(this.__Vt(6), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentSelectionContainer; VTable PositonGet: 7; output : IUIAutomationElement**: retVal
	CurrentSelectionContainer[]
	{
		get {
			If !DllCall(this.__Vt(7), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationElement(out)
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationSynchronizedInputPattern
; GUID: {2233BE0B-AFB7-448B-9FDA-3B378AA5EAE1}
; *************************************************************************


class IUIAutomationSynchronizedInputPattern
{
	; Generic definitions

	static __IID := "{2233BE0B-AFB7-448B-9FDA-3B378AA5EAE1}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationSynchronizedInputPattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult StartListening([FIN] SynchronizedInputType: inputType)
	StartListening(inputType)
	{
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "UInt", inputType, "Int")
		return res
	}

	; VTable Positon 4: INVOKE_FUNC Vt_Hresult Cancel()
	Cancel()
	{
		res:=DllCall(this.__Vt(4), "Ptr", this.__Value, "Int")
		return res
	}

}

; *************************************************************************
; IUIAutomationTablePattern
; GUID: {620E691C-EA96-4710-A850-754B24CE2417}
; *************************************************************************


class IUIAutomationTablePattern
{
	; Generic definitions

	static __IID := "{620E691C-EA96-4710-A850-754B24CE2417}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationTablePattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult GetCurrentRowHeaders([FOUT] [FRETVAL] IUIAutomationElementArray**: retVal)
	GetCurrentRowHeaders()
	{
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCurrentRowHeaders in IUIAutomationTablePattern")
		out:= new IUIAutomationElementArray(out)
		return out
	}

	; VTable Positon 4: INVOKE_FUNC Vt_Hresult GetCurrentColumnHeaders([FOUT] [FRETVAL] IUIAutomationElementArray**: retVal)
	GetCurrentColumnHeaders()
	{
		res:=DllCall(this.__Vt(4), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCurrentColumnHeaders in IUIAutomationTablePattern")
		out:= new IUIAutomationElementArray(out)
		return out
	}

	; VTable Positon 6: INVOKE_FUNC Vt_Hresult GetCachedRowHeaders([FOUT] [FRETVAL] IUIAutomationElementArray**: retVal)
	GetCachedRowHeaders()
	{
		res:=DllCall(this.__Vt(6), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCachedRowHeaders in IUIAutomationTablePattern")
		out:= new IUIAutomationElementArray(out)
		return out
	}

	; VTable Positon 7: INVOKE_FUNC Vt_Hresult GetCachedColumnHeaders([FOUT] [FRETVAL] IUIAutomationElementArray**: retVal)
	GetCachedColumnHeaders()
	{
		res:=DllCall(this.__Vt(7), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCachedColumnHeaders in IUIAutomationTablePattern")
		out:= new IUIAutomationElementArray(out)
		return out
	}

	; Property: CachedRowOrColumnMajor; VTable PositonGet: 8; output : RowOrColumnMajor*: retVal
	CachedRowOrColumnMajor[]
	{
		get {
			If !DllCall(this.__Vt(8), "Ptr", this.__Value, "UInt",out)
			{
				return out
			}
		}
	}
	; Property: CurrentRowOrColumnMajor; VTable PositonGet: 5; output : RowOrColumnMajor*: retVal
	CurrentRowOrColumnMajor[]
	{
		get {
			If !DllCall(this.__Vt(5), "Ptr", this.__Value, "UInt",out)
			{
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationTableItemPattern
; GUID: {0B964EB3-EF2E-4464-9C79-61D61737A27E}
; *************************************************************************


class IUIAutomationTableItemPattern
{
	; Generic definitions

	static __IID := "{0B964EB3-EF2E-4464-9C79-61D61737A27E}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationTableItemPattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult GetCurrentRowHeaderItems([FOUT] [FRETVAL] IUIAutomationElementArray**: retVal)
	GetCurrentRowHeaderItems()
	{
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCurrentRowHeaderItems in IUIAutomationTableItemPattern")
		out:= new IUIAutomationElementArray(out)
		return out
	}

	; VTable Positon 4: INVOKE_FUNC Vt_Hresult GetCurrentColumnHeaderItems([FOUT] [FRETVAL] IUIAutomationElementArray**: retVal)
	GetCurrentColumnHeaderItems()
	{
		res:=DllCall(this.__Vt(4), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCurrentColumnHeaderItems in IUIAutomationTableItemPattern")
		out:= new IUIAutomationElementArray(out)
		return out
	}

	; VTable Positon 5: INVOKE_FUNC Vt_Hresult GetCachedRowHeaderItems([FOUT] [FRETVAL] IUIAutomationElementArray**: retVal)
	GetCachedRowHeaderItems()
	{
		res:=DllCall(this.__Vt(5), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCachedRowHeaderItems in IUIAutomationTableItemPattern")
		out:= new IUIAutomationElementArray(out)
		return out
	}

	; VTable Positon 6: INVOKE_FUNC Vt_Hresult GetCachedColumnHeaderItems([FOUT] [FRETVAL] IUIAutomationElementArray**: retVal)
	GetCachedColumnHeaderItems()
	{
		res:=DllCall(this.__Vt(6), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCachedColumnHeaderItems in IUIAutomationTableItemPattern")
		out:= new IUIAutomationElementArray(out)
		return out
	}

}

; *************************************************************************
; IUIAutomationTogglePattern
; GUID: {94CF8058-9B8D-4AB9-8BFD-4CD0A33C8C70}
; *************************************************************************


class IUIAutomationTogglePattern
{
	; Generic definitions

	static __IID := "{94CF8058-9B8D-4AB9-8BFD-4CD0A33C8C70}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationTogglePattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult Toggle()
	Toggle()
	{
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Int")
		return res
	}

	; Property: CachedToggleState; VTable PositonGet: 5; output : ToggleState*: retVal
	CachedToggleState[]
	{
		get {
			If !DllCall(this.__Vt(5), "Ptr", this.__Value, "UInt",out)
			{
				return out
			}
		}
	}
	; Property: CurrentToggleState; VTable PositonGet: 4; output : ToggleState*: retVal
	CurrentToggleState[]
	{
		get {
			If !DllCall(this.__Vt(4), "Ptr", this.__Value, "UInt",out)
			{
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationTransformPattern
; GUID: {A9B55844-A55D-4EF0-926D-569C16FF89BB}
; *************************************************************************


class IUIAutomationTransformPattern
{
	; Generic definitions

	static __IID := "{A9B55844-A55D-4EF0-926D-569C16FF89BB}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationTransformPattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult Move([FIN] R8: x, [FIN] R8: y)
	Move(x, y)
	{
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Double", x, "Double", y, "Int")
		return res
	}

	; VTable Positon 4: INVOKE_FUNC Vt_Hresult Resize([FIN] R8: width, [FIN] R8: height)
	Resize(width, height)
	{
		res:=DllCall(this.__Vt(4), "Ptr", this.__Value, "Double", width, "Double", height, "Int")
		return res
	}

	; VTable Positon 5: INVOKE_FUNC Vt_Hresult Rotate([FIN] R8: degrees)
	Rotate(degrees)
	{
		res:=DllCall(this.__Vt(5), "Ptr", this.__Value, "Double", degrees, "Int")
		return res
	}

	; Property: CachedCanMove; VTable PositonGet: 9; output : Vt_I4*: retVal
	CachedCanMove[]
	{
		get {
			If !DllCall(this.__Vt(9), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedCanResize; VTable PositonGet: 10; output : Vt_I4*: retVal
	CachedCanResize[]
	{
		get {
			If !DllCall(this.__Vt(10), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedCanRotate; VTable PositonGet: 11; output : Vt_I4*: retVal
	CachedCanRotate[]
	{
		get {
			If !DllCall(this.__Vt(11), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentCanMove; VTable PositonGet: 6; output : Vt_I4*: retVal
	CurrentCanMove[]
	{
		get {
			If !DllCall(this.__Vt(6), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentCanResize; VTable PositonGet: 7; output : Vt_I4*: retVal
	CurrentCanResize[]
	{
		get {
			If !DllCall(this.__Vt(7), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentCanRotate; VTable PositonGet: 8; output : Vt_I4*: retVal
	CurrentCanRotate[]
	{
		get {
			If !DllCall(this.__Vt(8), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationValuePattern
; GUID: {A94CD8B1-0844-4CD6-9D2D-640537AB39E9}
; *************************************************************************


class IUIAutomationValuePattern
{
	; Generic definitions

	static __IID := "{A94CD8B1-0844-4CD6-9D2D-640537AB39E9}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationValuePattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult SetValue([FIN] Bstr: val)
	SetValue(val)
	{
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Ptr", val, "Int")
		return res
	}

	; Property: CachedIsReadOnly; VTable PositonGet: 7; output : Vt_I4*: retVal
	CachedIsReadOnly[]
	{
		get {
			If !DllCall(this.__Vt(7), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedValue; VTable PositonGet: 6; output : Vt_Bstr*: retVal
	CachedValue[]
	{
		get {
			If !DllCall(this.__Vt(6), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentIsReadOnly; VTable PositonGet: 5; output : Vt_I4*: retVal
	CurrentIsReadOnly[]
	{
		get {
			If !DllCall(this.__Vt(5), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentValue; VTable PositonGet: 4; output : Vt_Bstr*: retVal
	CurrentValue[]
	{
		get {
			If !DllCall(this.__Vt(4), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationWindowPattern
; GUID: {0FAEF453-9208-43EF-BBB2-3B485177864F}
; *************************************************************************


class IUIAutomationWindowPattern
{
	; Generic definitions

	static __IID := "{0FAEF453-9208-43EF-BBB2-3B485177864F}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationWindowPattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult Close()
	Close()
	{
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Int")
		return res
	}

	; VTable Positon 4: INVOKE_FUNC Vt_Hresult WaitForInputIdle([FIN] Int: milliseconds, [FOUT] [FRETVAL] I4*: success)
	WaitForInputIdle(milliseconds)
	{
		res:=DllCall(this.__Vt(4), "Ptr", this.__Value, "Int", milliseconds, "Int*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from WaitForInputIdle in IUIAutomationWindowPattern")
		return out
	}

	; VTable Positon 5: INVOKE_FUNC Vt_Hresult SetWindowVisualState([FIN] WindowVisualState: state)
	SetWindowVisualState(state)
	{
		res:=DllCall(this.__Vt(5), "Ptr", this.__Value, "UInt", state, "Int")
		return res
	}

	; Property: CachedCanMaximize; VTable PositonGet: 12; output : Vt_I4*: retVal
	CachedCanMaximize[]
	{
		get {
			If !DllCall(this.__Vt(12), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedCanMinimize; VTable PositonGet: 13; output : Vt_I4*: retVal
	CachedCanMinimize[]
	{
		get {
			If !DllCall(this.__Vt(13), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedIsModal; VTable PositonGet: 14; output : Vt_I4*: retVal
	CachedIsModal[]
	{
		get {
			If !DllCall(this.__Vt(14), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedIsTopmost; VTable PositonGet: 15; output : Vt_I4*: retVal
	CachedIsTopmost[]
	{
		get {
			If !DllCall(this.__Vt(15), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedWindowInteractionState; VTable PositonGet: 17; output : WindowInteractionState*: retVal
	CachedWindowInteractionState[]
	{
		get {
			If !DllCall(this.__Vt(17), "Ptr", this.__Value, "UInt",out)
			{
				return out
			}
		}
	}
	; Property: CachedWindowVisualState; VTable PositonGet: 16; output : WindowVisualState*: retVal
	CachedWindowVisualState[]
	{
		get {
			If !DllCall(this.__Vt(16), "Ptr", this.__Value, "UInt",out)
			{
				return out
			}
		}
	}
	; Property: CurrentCanMaximize; VTable PositonGet: 6; output : Vt_I4*: retVal
	CurrentCanMaximize[]
	{
		get {
			If !DllCall(this.__Vt(6), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentCanMinimize; VTable PositonGet: 7; output : Vt_I4*: retVal
	CurrentCanMinimize[]
	{
		get {
			If !DllCall(this.__Vt(7), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentIsModal; VTable PositonGet: 8; output : Vt_I4*: retVal
	CurrentIsModal[]
	{
		get {
			If !DllCall(this.__Vt(8), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentIsTopmost; VTable PositonGet: 9; output : Vt_I4*: retVal
	CurrentIsTopmost[]
	{
		get {
			If !DllCall(this.__Vt(9), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentWindowInteractionState; VTable PositonGet: 11; output : WindowInteractionState*: retVal
	CurrentWindowInteractionState[]
	{
		get {
			If !DllCall(this.__Vt(11), "Ptr", this.__Value, "UInt",out)
			{
				return out
			}
		}
	}
	; Property: CurrentWindowVisualState; VTable PositonGet: 10; output : WindowVisualState*: retVal
	CurrentWindowVisualState[]
	{
		get {
			If !DllCall(this.__Vt(10), "Ptr", this.__Value, "UInt",out)
			{
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationTextRange
; GUID: {A543CC6A-F4AE-494B-8239-C814481187A8}
; *************************************************************************


class IUIAutomationTextRange
{
	; Generic definitions

	static __IID := "{A543CC6A-F4AE-494B-8239-C814481187A8}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationTextRange"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult Clone([FOUT] [FRETVAL] IUIAutomationTextRange**: clonedRange)
	Clone()
	{
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from Clone in IUIAutomationTextRange")
		out:= new IUIAutomationTextRange(out)
		return out
	}

	; VTable Positon 4: INVOKE_FUNC Vt_Hresult Compare([FIN] IUIAutomationTextRange*: range, [FOUT] [FRETVAL] I4*: areSame)
	Compare(range)
	{
		If (IsObject(range) and (ComObjType(range)=""))
			refrange:=range.__Value
		else
			refrange:=range
		res:=DllCall(this.__Vt(4), "Ptr", this.__Value, "Ptr", refrange, "Int*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from Compare in IUIAutomationTextRange")
		return out
	}

	; VTable Positon 5: INVOKE_FUNC Vt_Hresult CompareEndpoints([FIN] TextPatternRangeEndpoint: srcEndPoint, [FIN] IUIAutomationTextRange*: range, [FIN] TextPatternRangeEndpoint: targetEndPoint, [FOUT] [FRETVAL] Int*: compValue)
	CompareEndpoints(srcEndPoint, range, targetEndPoint)
	{
		If (IsObject(range) and (ComObjType(range)=""))
			refrange:=range.__Value
		else
			refrange:=range
		res:=DllCall(this.__Vt(5), "Ptr", this.__Value, "UInt", srcEndPoint, "Ptr", refrange, "UInt", targetEndPoint, "Int*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from CompareEndpoints in IUIAutomationTextRange")
		return out
	}

	; VTable Positon 6: INVOKE_FUNC Vt_Hresult ExpandToEnclosingUnit([FIN] TextUnit: TextUnit)
	ExpandToEnclosingUnit(TextUnit)
	{
		res:=DllCall(this.__Vt(6), "Ptr", this.__Value, "UInt", TextUnit, "Int")
		return res
	}

	; VTable Positon 7: INVOKE_FUNC Vt_Hresult FindAttribute([FIN] Int: attr, [FIN] Variant: val, [FIN] I4: backward, [FOUT] [FRETVAL] IUIAutomationTextRange**: found)
	FindAttribute(attr, val, valVariantType, backward)
	{
		if (valVariantType!=12) ; val is not a variant
		{
			VarSetCapacity(refval,8+2*A_PtrSize)
			variant_ref := ComObject(0x400C, &refval)
			variant_ref[] := val
			NumPut(valVariantType, refval, 0, "short")
		}
		else
			refval:=val
		res:=DllCall(this.__Vt(7), "Ptr", this.__Value, "Int", attr, "Ptr", &refval, "Int", backward, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from FindAttribute in IUIAutomationTextRange")
		out:= new IUIAutomationTextRange(out)
		return out
	}

	; VTable Positon 8: INVOKE_FUNC Vt_Hresult FindText([FIN] Bstr: text, [FIN] I4: backward, [FIN] I4: ignoreCase, [FOUT] [FRETVAL] IUIAutomationTextRange**: found)
	FindText(text, backward, ignoreCase)
	{
		res:=DllCall(this.__Vt(8), "Ptr", this.__Value, "Ptr", text, "Int", backward, "Int", ignoreCase, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from FindText in IUIAutomationTextRange")
		out:= new IUIAutomationTextRange(out)
		return out
	}

	; VTable Positon 9: INVOKE_FUNC Vt_Hresult GetAttributeValue([FIN] Int: attr, [FOUT] [FRETVAL] Variant*: value)
	GetAttributeValue(attr)
	{
		res:=DllCall(this.__Vt(9), "Ptr", this.__Value, "Int", attr, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetAttributeValue in IUIAutomationTextRange")
		out:=ComObject(0x400C, out+0, flag)[]
		return out
	}

	; VTable Positon 10: INVOKE_FUNC Vt_Hresult GetBoundingRectangles([FOUT] [FRETVAL] Safearray*: boundingRects)
	GetBoundingRectangles()
	{
		If (ComObjValue(boundingRects) & 0x2000)
			refboundingRects:=boundingRects
		else
		{
			refboundingRects:=ComObject(0x2003, DllCall("oleaut32\SafeArrayCreateVector", "UInt", 13, "UInt", 0, "UInt", boundingRects.MaxIndex()),1)
			For ind, val in boundingRects
				refboundingRects[A_Index-1]:= val.__Value, ObjAddRef(val.__Value)
		}
		res:=DllCall(this.__Vt(10), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetBoundingRectangles in IUIAutomationTextRange")
		return out
	}

	; VTable Positon 11: INVOKE_FUNC Vt_Hresult GetEnclosingElement([FOUT] [FRETVAL] IUIAutomationElement**: enclosingElement)
	GetEnclosingElement()
	{
		res:=DllCall(this.__Vt(11), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetEnclosingElement in IUIAutomationTextRange")
		out:= new IUIAutomationElement(out)
		return out
	}

	; VTable Positon 12: INVOKE_FUNC Vt_Hresult GetText([FIN] Int: maxLength, [FOUT] [FRETVAL] Bstr*: text)
	GetText(maxLength)
	{
		res:=DllCall(this.__Vt(12), "Ptr", this.__Value, "Int", maxLength, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetText in IUIAutomationTextRange")
		out:= StrGet(out)
		return out
	}

	; VTable Positon 13: INVOKE_FUNC Vt_Hresult Move([FIN] TextUnit: unit, [FIN] Int: count, [FOUT] [FRETVAL] Int*: moved)
	Move(unit, count)
	{
		res:=DllCall(this.__Vt(13), "Ptr", this.__Value, "UInt", unit, "Int", count, "Int*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from Move in IUIAutomationTextRange")
		return out
	}

	; VTable Positon 14: INVOKE_FUNC Vt_Hresult MoveEndpointByUnit([FIN] TextPatternRangeEndpoint: endpoint, [FIN] TextUnit: unit, [FIN] Int: count, [FOUT] [FRETVAL] Int*: moved)
	MoveEndpointByUnit(endpoint, unit, count)
	{
		res:=DllCall(this.__Vt(14), "Ptr", this.__Value, "UInt", endpoint, "UInt", unit, "Int", count, "Int*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from MoveEndpointByUnit in IUIAutomationTextRange")
		return out
	}

	; VTable Positon 15: INVOKE_FUNC Vt_Hresult MoveEndpointByRange([FIN] TextPatternRangeEndpoint: srcEndPoint, [FIN] IUIAutomationTextRange*: range, [FIN] TextPatternRangeEndpoint: targetEndPoint)
	MoveEndpointByRange(srcEndPoint, range, targetEndPoint)
	{
		If (IsObject(range) and (ComObjType(range)=""))
			refrange:=range.__Value
		else
			refrange:=range
		res:=DllCall(this.__Vt(15), "Ptr", this.__Value, "UInt", srcEndPoint, "Ptr", refrange, "UInt", targetEndPoint, "Int")
		return res
	}

	; VTable Positon 16: INVOKE_FUNC Vt_Hresult Select()
	Select()
	{
		res:=DllCall(this.__Vt(16), "Ptr", this.__Value, "Int")
		return res
	}

	; VTable Positon 17: INVOKE_FUNC Vt_Hresult AddToSelection()
	AddToSelection()
	{
		res:=DllCall(this.__Vt(17), "Ptr", this.__Value, "Int")
		return res
	}

	; VTable Positon 18: INVOKE_FUNC Vt_Hresult RemoveFromSelection()
	RemoveFromSelection()
	{
		res:=DllCall(this.__Vt(18), "Ptr", this.__Value, "Int")
		return res
	}

	; VTable Positon 19: INVOKE_FUNC Vt_Hresult ScrollIntoView([FIN] I4: alignToTop)
	ScrollIntoView(alignToTop)
	{
		res:=DllCall(this.__Vt(19), "Ptr", this.__Value, "Int", alignToTop, "Int")
		return res
	}

	; VTable Positon 20: INVOKE_FUNC Vt_Hresult GetChildren([FOUT] [FRETVAL] IUIAutomationElementArray**: children)
	GetChildren()
	{
		res:=DllCall(this.__Vt(20), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetChildren in IUIAutomationTextRange")
		out:= new IUIAutomationElementArray(out)
		return out
	}

}

; *************************************************************************
; IUIAutomationTextRange2
; GUID: {BB9B40E0-5E04-46BD-9BE0-4B601B9AFAD4}
; *************************************************************************


class IUIAutomationTextRange2 extends IUIAutomationTextRange
{
	; Interface functions

	; VTable Positon 21: INVOKE_FUNC Vt_Hresult ShowContextMenu()
	ShowContextMenu()
	{
		res:=DllCall(this.__Vt(21), "Ptr", this.__Value, "Int")
		return res
	}

}

; *************************************************************************
; IUIAutomationTextRange3
; GUID: {6A315D69-5512-4C2E-85F0-53FCE6DD4BC2}
; *************************************************************************


class IUIAutomationTextRange3 extends IUIAutomationTextRange2
{
	; Interface functions

	; VTable Positon 22: INVOKE_FUNC Vt_Hresult GetEnclosingElementBuildCache([FIN] IUIAutomationCacheRequest*: cacheRequest, [FOUT] [FRETVAL] IUIAutomationElement**: enclosingElement)
	GetEnclosingElementBuildCache(cacheRequest)
	{
		If (IsObject(cacheRequest) and (ComObjType(cacheRequest)=""))
			refcacheRequest:=cacheRequest.__Value
		else
			refcacheRequest:=cacheRequest
		res:=DllCall(this.__Vt(22), "Ptr", this.__Value, "Ptr", refcacheRequest, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetEnclosingElementBuildCache in IUIAutomationTextRange3")
		out:= new IUIAutomationElement(out)
		return out
	}

	; VTable Positon 23: INVOKE_FUNC Vt_Hresult GetChildrenBuildCache([FIN] IUIAutomationCacheRequest*: cacheRequest, [FOUT] [FRETVAL] IUIAutomationElementArray**: children)
	GetChildrenBuildCache(cacheRequest)
	{
		If (IsObject(cacheRequest) and (ComObjType(cacheRequest)=""))
			refcacheRequest:=cacheRequest.__Value
		else
			refcacheRequest:=cacheRequest
		res:=DllCall(this.__Vt(23), "Ptr", this.__Value, "Ptr", refcacheRequest, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetChildrenBuildCache in IUIAutomationTextRange3")
		out:= new IUIAutomationElementArray(out)
		return out
	}

	; VTable Positon 24: INVOKE_FUNC Vt_Hresult GetAttributeValues([FIN] Int*: attributeIds, [FIN] Int: attributeIdCount, [FOUT] [FRETVAL] Safearray*: attributeValues)
	GetAttributeValues(attributeIds, attributeIdCount)
	{
		If (ComObjValue(attributeValues) & 0x2000)
			refattributeValues:=attributeValues
		else
		{
			refattributeValues:=ComObject(0x2003, DllCall("oleaut32\SafeArrayCreateVector", "UInt", 13, "UInt", 0, "UInt", attributeValues.MaxIndex()),1)
			For ind, val in attributeValues
				refattributeValues[A_Index-1]:= val.__Value, ObjAddRef(val.__Value)
		}
		res:=DllCall(this.__Vt(24), "Ptr", this.__Value, "Int*", attributeIds, "Int", attributeIdCount, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetAttributeValues in IUIAutomationTextRange3")
		return out
	}

}

; *************************************************************************
; IUIAutomationTextRangeArray
; GUID: {CE4AE76A-E717-4C98-81EA-47371D028EB6}
; *************************************************************************


class IUIAutomationTextRangeArray
{
	; Generic definitions

	static __IID := "{CE4AE76A-E717-4C98-81EA-47371D028EB6}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationTextRangeArray"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 4: INVOKE_FUNC Vt_Hresult GetElement([FIN] Int: index, [FOUT] [FRETVAL] IUIAutomationTextRange**: element)
	GetElement(index)
	{
		res:=DllCall(this.__Vt(4), "Ptr", this.__Value, "Int", index, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetElement in IUIAutomationTextRangeArray")
		out:= new IUIAutomationTextRange(out)
		return out
	}

	; Property: Length; VTable PositonGet: 3; output : Vt_Int*: Length
	Length[]
	{
		get {
			If !DllCall(this.__Vt(3), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationTextPattern
; GUID: {32EBA289-3583-42C9-9C59-3B6D9A1E9B6A}
; *************************************************************************


class IUIAutomationTextPattern
{
	; Generic definitions

	static __IID := "{32EBA289-3583-42C9-9C59-3B6D9A1E9B6A}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationTextPattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult RangeFromPoint([FIN] tagPOINT: pt, [FOUT] [FRETVAL] IUIAutomationTextRange**: range)
	RangeFromPoint(pt)
	{
		If (IsObject(pt) and (ComObjType(pt)=""))
			refpt:=pt.__Value
		else
			refpt:=&pt
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Ptr", refpt, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from RangeFromPoint in IUIAutomationTextPattern")
		out:= new IUIAutomationTextRange(out)
		return out
	}

	; VTable Positon 4: INVOKE_FUNC Vt_Hresult RangeFromChild([FIN] IUIAutomationElement*: child, [FOUT] [FRETVAL] IUIAutomationTextRange**: range)
	RangeFromChild(child)
	{
		If (IsObject(child) and (ComObjType(child)=""))
			refchild:=child.__Value
		else
			refchild:=child
		res:=DllCall(this.__Vt(4), "Ptr", this.__Value, "Ptr", refchild, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from RangeFromChild in IUIAutomationTextPattern")
		out:= new IUIAutomationTextRange(out)
		return out
	}

	; VTable Positon 5: INVOKE_FUNC Vt_Hresult GetSelection([FOUT] [FRETVAL] IUIAutomationTextRangeArray**: ranges)
	GetSelection()
	{
		res:=DllCall(this.__Vt(5), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetSelection in IUIAutomationTextPattern")
		out:= new IUIAutomationTextRangeArray(out)
		return out
	}

	; VTable Positon 6: INVOKE_FUNC Vt_Hresult GetVisibleRanges([FOUT] [FRETVAL] IUIAutomationTextRangeArray**: ranges)
	GetVisibleRanges()
	{
		res:=DllCall(this.__Vt(6), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetVisibleRanges in IUIAutomationTextPattern")
		out:= new IUIAutomationTextRangeArray(out)
		return out
	}

	; Property: DocumentRange; VTable PositonGet: 7; output : IUIAutomationTextRange**: range
	DocumentRange[]
	{
		get {
			If !DllCall(this.__Vt(7), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationTextRange(out)
				return out
			}
		}
	}
	; Property: SupportedTextSelection; VTable PositonGet: 8; output : SupportedTextSelection*: SupportedTextSelection
	SupportedTextSelection[]
	{
		get {
			If !DllCall(this.__Vt(8), "Ptr", this.__Value, "UInt",out)
			{
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationTextPattern2
; GUID: {506A921A-FCC9-409F-B23B-37EB74106872}
; *************************************************************************


class IUIAutomationTextPattern2 extends IUIAutomationTextPattern
{
	; Interface functions

	; VTable Positon 9: INVOKE_FUNC Vt_Hresult RangeFromAnnotation([FIN] IUIAutomationElement*: annotation, [FOUT] [FRETVAL] IUIAutomationTextRange**: range)
	RangeFromAnnotation(annotation)
	{
		If (IsObject(annotation) and (ComObjType(annotation)=""))
			refannotation:=annotation.__Value
		else
			refannotation:=annotation
		res:=DllCall(this.__Vt(9), "Ptr", this.__Value, "Ptr", refannotation, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from RangeFromAnnotation in IUIAutomationTextPattern2")
		out:= new IUIAutomationTextRange(out)
		return out
	}

	; VTable Positon 10: INVOKE_FUNC Vt_Hresult GetCaretRange([FOUT] I4*: isActive, [FOUT] [FRETVAL] IUIAutomationTextRange**: range)
	GetCaretRange(byref isActive)
	{
		res:=DllCall(this.__Vt(10), "Ptr", this.__Value, "Int*", isActive, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCaretRange in IUIAutomationTextPattern2")
		out:= new IUIAutomationTextRange(out)
		return out
	}

}

; *************************************************************************
; IUIAutomationTextEditPattern
; GUID: {17E21576-996C-4870-99D9-BFF323380C06}
; *************************************************************************


class IUIAutomationTextEditPattern extends IUIAutomationTextPattern
{
	; Interface functions

	; VTable Positon 9: INVOKE_FUNC Vt_Hresult GetActiveComposition([FOUT] [FRETVAL] IUIAutomationTextRange**: range)
	GetActiveComposition()
	{
		res:=DllCall(this.__Vt(9), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetActiveComposition in IUIAutomationTextEditPattern")
		out:= new IUIAutomationTextRange(out)
		return out
	}

	; VTable Positon 10: INVOKE_FUNC Vt_Hresult GetConversionTarget([FOUT] [FRETVAL] IUIAutomationTextRange**: range)
	GetConversionTarget()
	{
		res:=DllCall(this.__Vt(10), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetConversionTarget in IUIAutomationTextEditPattern")
		out:= new IUIAutomationTextRange(out)
		return out
	}

}

; *************************************************************************
; IUIAutomationCustomNavigationPattern
; GUID: {01EA217A-1766-47ED-A6CC-ACF492854B1F}
; *************************************************************************


class IUIAutomationCustomNavigationPattern
{
	; Generic definitions

	static __IID := "{01EA217A-1766-47ED-A6CC-ACF492854B1F}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationCustomNavigationPattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult Navigate([FIN] NavigateDirection: direction, [FOUT] [FRETVAL] IUIAutomationElement**: pRetVal)
	Navigate(direction)
	{
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "UInt", direction, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from Navigate in IUIAutomationCustomNavigationPattern")
		out:= new IUIAutomationElement(out)
		return out
	}

}

; *************************************************************************
; IUIAutomationLegacyIAccessiblePattern
; GUID: {828055AD-355B-4435-86D5-3B51C14A9B1B}
; *************************************************************************


class IUIAutomationLegacyIAccessiblePattern
{
	; Generic definitions

	static __IID := "{828055AD-355B-4435-86D5-3B51C14A9B1B}"

	__New(p="", flag=1){
		this.__Type:="IUIAutomationLegacyIAccessiblePattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete(){
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n){
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult Select([NONE] I4: flagsSelect)
	Select(flagsSelect){
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Int", flagsSelect, "Int")
		return res
	}

	; VTable Positon 4: INVOKE_FUNC Vt_Hresult DoDefaultAction()
	DoDefaultAction(){
		res:=DllCall(this.__Vt(4), "Ptr", this.__Value, "Int")
		return res
	}

	; VTable Positon 5: INVOKE_FUNC Vt_Hresult SetValue([NONE] Lpwstr: szValue)
	SetValue(szValue){
		res:=DllCall(this.__Vt(5), "Ptr", this.__Value, "Ptr", szValue, "Int")
		return res
	}

	; VTable Positon 14: INVOKE_FUNC Vt_Hresult GetCurrentSelection([FOUT] [FRETVAL] IUIAutomationElementArray**: pvarSelectedChildren)
	GetCurrentSelection()	{
		res:=DllCall(this.__Vt(14), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCurrentSelection in IUIAutomationLegacyIAccessiblePattern")
		out:= new IUIAutomationElementArray(out)
		return out
	}

	; VTable Positon 24: INVOKE_FUNC Vt_Hresult GetCachedSelection([FOUT] [FRETVAL] IUIAutomationElementArray**: pvarSelectedChildren)
	GetCachedSelection() {
		res:=DllCall(this.__Vt(24), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCachedSelection in IUIAutomationLegacyIAccessiblePattern")
		out:= new IUIAutomationElementArray(out)
		return out
	}

	; VTable Positon 26: INVOKE_FUNC Vt_Hresult GetIAccessible([FOUT] [FRETVAL] IAccessible**: ppAccessible)
	GetIAccessible()	{
		res:=DllCall(this.__Vt(26), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetIAccessible in IUIAutomationLegacyIAccessiblePattern")
		out:= new IAccessible(out)
		return out
	}

	; Property: CachedChildId; VTable PositonGet: 16; output : Vt_Int*: pRetVal
	CachedChildId[]
	{
		get {
			If !DllCall(this.__Vt(16), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedDefaultAction; VTable PositonGet: 25; output : Vt_Bstr*: pszDefaultAction
	CachedDefaultAction[]
	{
		get {
			If !DllCall(this.__Vt(25), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CachedDescription; VTable PositonGet: 19; output : Vt_Bstr*: pszDescription
	CachedDescription[]
	{
		get {
			If !DllCall(this.__Vt(19), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CachedHelp; VTable PositonGet: 22; output : Vt_Bstr*: pszHelp
	CachedHelp[]
	{
		get {
			If !DllCall(this.__Vt(22), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CachedKeyboardShortcut; VTable PositonGet: 23; output : Vt_Bstr*: pszKeyboardShortcut
	CachedKeyboardShortcut[]
	{
		get {
			If !DllCall(this.__Vt(23), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CachedName; VTable PositonGet: 17; output : Vt_Bstr*: pszName
	CachedName[]
	{
		get {
			If !DllCall(this.__Vt(17), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CachedRole; VTable PositonGet: 20; output : Vt_Ui4*: pdwRole
	CachedRole[]
	{
		get {
			If !DllCall(this.__Vt(20), "Ptr", this.__Value, "UInt*",out)
			{
				return out
			}
		}
	}
	; Property: CachedState; VTable PositonGet: 21; output : Vt_Ui4*: pdwState
	CachedState[]
	{
		get {
			If !DllCall(this.__Vt(21), "Ptr", this.__Value, "UInt*",out)
			{
				return out
			}
		}
	}
	; Property: CachedValue; VTable PositonGet: 18; output : Vt_Bstr*: pszValue
	CachedValue[]
	{
		get {
			If !DllCall(this.__Vt(18), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentChildId; VTable PositonGet: 6; output : Vt_Int*: pRetVal
	CurrentChildId[]
	{
		get {
			If !DllCall(this.__Vt(6), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentDefaultAction; VTable PositonGet: 15; output : Vt_Bstr*: pszDefaultAction
	CurrentDefaultAction[]
	{
		get {
			If !DllCall(this.__Vt(15), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentDescription; VTable PositonGet: 9; output : Vt_Bstr*: pszDescription
	CurrentDescription[]
	{
		get {
			If !DllCall(this.__Vt(9), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentHelp; VTable PositonGet: 12; output : Vt_Bstr*: pszHelp
	CurrentHelp[]
	{
		get {
			If !DllCall(this.__Vt(12), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentKeyboardShortcut; VTable PositonGet: 13; output : Vt_Bstr*: pszKeyboardShortcut
	CurrentKeyboardShortcut[]
	{
		get {
			If !DllCall(this.__Vt(13), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentName; VTable PositonGet: 7; output : Vt_Bstr*: pszName
	CurrentName[]
	{
		get {
			If !DllCall(this.__Vt(7), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentRole; VTable PositonGet: 10; output : Vt_Ui4*: pdwRole
	CurrentRole[]
	{
		get {
			If !DllCall(this.__Vt(10), "Ptr", this.__Value, "UInt*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentState; VTable PositonGet: 11; output : Vt_Ui4*: pdwState
	CurrentState[]
	{
		get {
			If !DllCall(this.__Vt(11), "Ptr", this.__Value, "UInt*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentValue; VTable PositonGet: 8; output : Vt_Bstr*: pszValue
	CurrentValue[] {
		get {
			If !DllCall(this.__Vt(8), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationItemContainerPattern
; GUID: {C690FDB2-27A8-423C-812D-429773C9084E}
; *************************************************************************


class IUIAutomationItemContainerPattern
{
	; Generic definitions

	static __IID := "{C690FDB2-27A8-423C-812D-429773C9084E}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationItemContainerPattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult FindItemByProperty([FIN] IUIAutomationElement*: pStartAfter, [FIN] Int: propertyId, [FIN] Variant: value, [FOUT] [FRETVAL] IUIAutomationElement**: pFound)
	FindItemByProperty(pStartAfter, propertyId, value, valueVariantType)
	{
		if (valueVariantType!=12) ; value is not a variant
		{
			VarSetCapacity(refvalue,8+2*A_PtrSize)
			variant_ref := ComObject(0x400C, &refvalue)
			variant_ref[] := value
			NumPut(valueVariantType, refvalue, 0, "short")
		}
		else
			refvalue:=value
		If (IsObject(pStartAfter) and (ComObjType(pStartAfter)=""))
			refpStartAfter:=pStartAfter.__Value
		else
			refpStartAfter:=pStartAfter
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Ptr", refpStartAfter, "Int", propertyId, "Ptr", &refvalue, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from FindItemByProperty in IUIAutomationItemContainerPattern")
		out:= new IUIAutomationElement(out)
		return out
	}

}

; *************************************************************************
; IUIAutomationVirtualizedItemPattern
; GUID: {6BA3D7A6-04CF-4F11-8793-A8D1CDE9969F}
; *************************************************************************


class IUIAutomationVirtualizedItemPattern
{
	; Generic definitions

	static __IID := "{6BA3D7A6-04CF-4F11-8793-A8D1CDE9969F}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationVirtualizedItemPattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult Realize()
	Realize()
	{
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Int")
		return res
	}

}

; *************************************************************************
; IUIAutomationAnnotationPattern
; GUID: {9A175B21-339E-41B1-8E8B-623F6B681098}
; *************************************************************************


class IUIAutomationAnnotationPattern
{
	; Generic definitions

	static __IID := "{9A175B21-339E-41B1-8E8B-623F6B681098}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationAnnotationPattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; Property: CachedAnnotationTypeId; VTable PositonGet: 8; output : Vt_Int*: retVal
	CachedAnnotationTypeId[]
	{
		get {
			If !DllCall(this.__Vt(8), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedAnnotationTypeName; VTable PositonGet: 9; output : Vt_Bstr*: retVal
	CachedAnnotationTypeName[]
	{
		get {
			If !DllCall(this.__Vt(9), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CachedAuthor; VTable PositonGet: 10; output : Vt_Bstr*: retVal
	CachedAuthor[]
	{
		get {
			If !DllCall(this.__Vt(10), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CachedDateTime; VTable PositonGet: 11; output : Vt_Bstr*: retVal
	CachedDateTime[]
	{
		get {
			If !DllCall(this.__Vt(11), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CachedTarget; VTable PositonGet: 12; output : IUIAutomationElement**: retVal
	CachedTarget[]
	{
		get {
			If !DllCall(this.__Vt(12), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationElement(out)
				return out
			}
		}
	}
	; Property: CurrentAnnotationTypeId; VTable PositonGet: 3; output : Vt_Int*: retVal
	CurrentAnnotationTypeId[]
	{
		get {
			If !DllCall(this.__Vt(3), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentAnnotationTypeName; VTable PositonGet: 4; output : Vt_Bstr*: retVal
	CurrentAnnotationTypeName[]
	{
		get {
			If !DllCall(this.__Vt(4), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentAuthor; VTable PositonGet: 5; output : Vt_Bstr*: retVal
	CurrentAuthor[]
	{
		get {
			If !DllCall(this.__Vt(5), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentDateTime; VTable PositonGet: 6; output : Vt_Bstr*: retVal
	CurrentDateTime[]
	{
		get {
			If !DllCall(this.__Vt(6), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentTarget; VTable PositonGet: 7; output : IUIAutomationElement**: retVal
	CurrentTarget[]
	{
		get {
			If !DllCall(this.__Vt(7), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationElement(out)
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationStylesPattern
; GUID: {85B5F0A2-BD79-484A-AD2B-388C9838D5FB}
; *************************************************************************


class IUIAutomationStylesPattern
{
	; Generic definitions

	static __IID := "{85B5F0A2-BD79-484A-AD2B-388C9838D5FB}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationStylesPattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 10: INVOKE_FUNC Vt_Hresult GetCurrentExtendedPropertiesAsArray([FOUT] ExtendedProperty**: propertyArray, [FOUT] Int*: propertyCount)
	GetCurrentExtendedPropertiesAsArray(byref propertyArray, byref propertyCount)
	{
		res:=DllCall(this.__Vt(10), "Ptr", this.__Value, "Ptr*", propertyArray, "Int*", propertyCount, "Int")
		return res
	}

	; VTable Positon 18: INVOKE_FUNC Vt_Hresult GetCachedExtendedPropertiesAsArray([FOUT] ExtendedProperty**: propertyArray, [FOUT] Int*: propertyCount)
	GetCachedExtendedPropertiesAsArray(byref propertyArray, byref propertyCount)
	{
		res:=DllCall(this.__Vt(18), "Ptr", this.__Value, "Ptr*", propertyArray, "Int*", propertyCount, "Int")
		return res
	}

	; Property: CachedExtendedProperties; VTable PositonGet: 17; output : Vt_Bstr*: retVal
	CachedExtendedProperties[]
	{
		get {
			If !DllCall(this.__Vt(17), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CachedFillColor; VTable PositonGet: 13; output : Vt_Int*: retVal
	CachedFillColor[]
	{
		get {
			If !DllCall(this.__Vt(13), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedFillPatternColor; VTable PositonGet: 16; output : Vt_Int*: retVal
	CachedFillPatternColor[]
	{
		get {
			If !DllCall(this.__Vt(16), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedFillPatternStyle; VTable PositonGet: 14; output : Vt_Bstr*: retVal
	CachedFillPatternStyle[]
	{
		get {
			If !DllCall(this.__Vt(14), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CachedShape; VTable PositonGet: 15; output : Vt_Bstr*: retVal
	CachedShape[]
	{
		get {
			If !DllCall(this.__Vt(15), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CachedStyleId; VTable PositonGet: 11; output : Vt_Int*: retVal
	CachedStyleId[]
	{
		get {
			If !DllCall(this.__Vt(11), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedStyleName; VTable PositonGet: 12; output : Vt_Bstr*: retVal
	CachedStyleName[]
	{
		get {
			If !DllCall(this.__Vt(12), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentExtendedProperties; VTable PositonGet: 9; output : Vt_Bstr*: retVal
	CurrentExtendedProperties[]
	{
		get {
			If !DllCall(this.__Vt(9), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentFillColor; VTable PositonGet: 5; output : Vt_Int*: retVal
	CurrentFillColor[]
	{
		get {
			If !DllCall(this.__Vt(5), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentFillPatternColor; VTable PositonGet: 8; output : Vt_Int*: retVal
	CurrentFillPatternColor[]
	{
		get {
			If !DllCall(this.__Vt(8), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentFillPatternStyle; VTable PositonGet: 6; output : Vt_Bstr*: retVal
	CurrentFillPatternStyle[]
	{
		get {
			If !DllCall(this.__Vt(6), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentShape; VTable PositonGet: 7; output : Vt_Bstr*: retVal
	CurrentShape[]
	{
		get {
			If !DllCall(this.__Vt(7), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentStyleId; VTable PositonGet: 3; output : Vt_Int*: retVal
	CurrentStyleId[]
	{
		get {
			If !DllCall(this.__Vt(3), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentStyleName; VTable PositonGet: 4; output : Vt_Bstr*: retVal
	CurrentStyleName[]
	{
		get {
			If !DllCall(this.__Vt(4), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationSpreadsheetPattern
; GUID: {7517A7C8-FAAE-4DE9-9F08-29B91E8595C1}
; *************************************************************************


class IUIAutomationSpreadsheetPattern
{
	; Generic definitions

	static __IID := "{7517A7C8-FAAE-4DE9-9F08-29B91E8595C1}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationSpreadsheetPattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult GetItemByName([FIN] Bstr: name, [FOUT] [FRETVAL] IUIAutomationElement**: element)
	GetItemByName(name)
	{
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Ptr", name, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetItemByName in IUIAutomationSpreadsheetPattern")
		out:= new IUIAutomationElement(out)
		return out
	}

}

; *************************************************************************
; IUIAutomationSpreadsheetItemPattern
; GUID: {7D4FB86C-8D34-40E1-8E83-62C15204E335}
; *************************************************************************


class IUIAutomationSpreadsheetItemPattern
{
	; Generic definitions

	static __IID := "{7D4FB86C-8D34-40E1-8E83-62C15204E335}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationSpreadsheetItemPattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 4: INVOKE_FUNC Vt_Hresult GetCurrentAnnotationObjects([FOUT] [FRETVAL] IUIAutomationElementArray**: retVal)
	GetCurrentAnnotationObjects()
	{
		res:=DllCall(this.__Vt(4), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCurrentAnnotationObjects in IUIAutomationSpreadsheetItemPattern")
		out:= new IUIAutomationElementArray(out)
		return out
	}

	; VTable Positon 5: INVOKE_FUNC Vt_Hresult GetCurrentAnnotationTypes([FOUT] [FRETVAL] Safearray*: retVal)
	GetCurrentAnnotationTypes()
	{
		If (ComObjValue(retVal) & 0x2000)
			refretVal:=retVal
		else
		{
			refretVal:=ComObject(0x2003, DllCall("oleaut32\SafeArrayCreateVector", "UInt", 13, "UInt", 0, "UInt", retVal.MaxIndex()),1)
			For ind, val in retVal
				refretVal[A_Index-1]:= val.__Value, ObjAddRef(val.__Value)
		}
		res:=DllCall(this.__Vt(5), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCurrentAnnotationTypes in IUIAutomationSpreadsheetItemPattern")
		return out
	}

	; VTable Positon 7: INVOKE_FUNC Vt_Hresult GetCachedAnnotationObjects([FOUT] [FRETVAL] IUIAutomationElementArray**: retVal)
	GetCachedAnnotationObjects()
	{
		res:=DllCall(this.__Vt(7), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCachedAnnotationObjects in IUIAutomationSpreadsheetItemPattern")
		out:= new IUIAutomationElementArray(out)
		return out
	}

	; VTable Positon 8: INVOKE_FUNC Vt_Hresult GetCachedAnnotationTypes([FOUT] [FRETVAL] Safearray*: retVal)
	GetCachedAnnotationTypes()
	{
		If (ComObjValue(retVal) & 0x2000)
			refretVal:=retVal
		else
		{
			refretVal:=ComObject(0x2003, DllCall("oleaut32\SafeArrayCreateVector", "UInt", 13, "UInt", 0, "UInt", retVal.MaxIndex()),1)
			For ind, val in retVal
				refretVal[A_Index-1]:= val.__Value, ObjAddRef(val.__Value)
		}
		res:=DllCall(this.__Vt(8), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCachedAnnotationTypes in IUIAutomationSpreadsheetItemPattern")
		return out
	}

	; Property: CachedFormula; VTable PositonGet: 6; output : Vt_Bstr*: retVal
	CachedFormula[]
	{
		get {
			If !DllCall(this.__Vt(6), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentFormula; VTable PositonGet: 3; output : Vt_Bstr*: retVal
	CurrentFormula[]
	{
		get {
			If !DllCall(this.__Vt(3), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationTransformPattern2
; GUID: {6D74D017-6ECB-4381-B38B-3C17A48FF1C2}
; *************************************************************************


class IUIAutomationTransformPattern2 extends IUIAutomationTransformPattern
{
	; Interface functions

	; VTable Positon 12: INVOKE_FUNC Vt_Hresult Zoom([FIN] R8: zoomValue)
	Zoom(zoomValue)
	{
		res:=DllCall(this.__Vt(12), "Ptr", this.__Value, "Double", zoomValue, "Int")
		return res
	}

	; VTable Positon 13: INVOKE_FUNC Vt_Hresult ZoomByUnit([FIN] ZoomUnit: ZoomUnit)
	ZoomByUnit(ZoomUnit)
	{
		res:=DllCall(this.__Vt(13), "Ptr", this.__Value, "UInt", ZoomUnit, "Int")
		return res
	}

	; Property: CachedCanZoom; VTable PositonGet: 15; output : Vt_I4*: retVal
	CachedCanZoom[]
	{
		get {
			If !DllCall(this.__Vt(15), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedZoomLevel; VTable PositonGet: 17; output : Vt_R8*: retVal
	CachedZoomLevel[]
	{
		get {
			If !DllCall(this.__Vt(17), "Ptr", this.__Value, "Double*",out)
			{
				return out
			}
		}
	}
	; Property: CachedZoomMaximum; VTable PositonGet: 21; output : Vt_R8*: retVal
	CachedZoomMaximum[]
	{
		get {
			If !DllCall(this.__Vt(21), "Ptr", this.__Value, "Double*",out)
			{
				return out
			}
		}
	}
	; Property: CachedZoomMinimum; VTable PositonGet: 19; output : Vt_R8*: retVal
	CachedZoomMinimum[]
	{
		get {
			If !DllCall(this.__Vt(19), "Ptr", this.__Value, "Double*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentCanZoom; VTable PositonGet: 14; output : Vt_I4*: retVal
	CurrentCanZoom[]
	{
		get {
			If !DllCall(this.__Vt(14), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentZoomLevel; VTable PositonGet: 16; output : Vt_R8*: retVal
	CurrentZoomLevel[]
	{
		get {
			If !DllCall(this.__Vt(16), "Ptr", this.__Value, "Double*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentZoomMaximum; VTable PositonGet: 20; output : Vt_R8*: retVal
	CurrentZoomMaximum[]
	{
		get {
			If !DllCall(this.__Vt(20), "Ptr", this.__Value, "Double*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentZoomMinimum; VTable PositonGet: 18; output : Vt_R8*: retVal
	CurrentZoomMinimum[]
	{
		get {
			If !DllCall(this.__Vt(18), "Ptr", this.__Value, "Double*",out)
			{
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationTextChildPattern
; GUID: {6552B038-AE05-40C8-ABFD-AA08352AAB86}
; *************************************************************************


class IUIAutomationTextChildPattern
{
	; Generic definitions

	static __IID := "{6552B038-AE05-40C8-ABFD-AA08352AAB86}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationTextChildPattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; Property: TextContainer; VTable PositonGet: 3; output : IUIAutomationElement**: container
	TextContainer[]
	{
		get {
			If !DllCall(this.__Vt(3), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationElement(out)
				return out
			}
		}
	}
	; Property: TextRange; VTable PositonGet: 4; output : IUIAutomationTextRange**: range
	TextRange[]
	{
		get {
			If !DllCall(this.__Vt(4), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationTextRange(out)
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationDragPattern
; GUID: {1DC7B570-1F54-4BAD-BCDA-D36A722FB7BD}
; *************************************************************************


class IUIAutomationDragPattern
{
	; Generic definitions

	static __IID := "{1DC7B570-1F54-4BAD-BCDA-D36A722FB7BD}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationDragPattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 9: INVOKE_FUNC Vt_Hresult GetCurrentGrabbedItems([FOUT] [FRETVAL] IUIAutomationElementArray**: retVal)
	GetCurrentGrabbedItems()
	{
		res:=DllCall(this.__Vt(9), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCurrentGrabbedItems in IUIAutomationDragPattern")
		out:= new IUIAutomationElementArray(out)
		return out
	}

	; VTable Positon 10: INVOKE_FUNC Vt_Hresult GetCachedGrabbedItems([FOUT] [FRETVAL] IUIAutomationElementArray**: retVal)
	GetCachedGrabbedItems()
	{
		res:=DllCall(this.__Vt(10), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCachedGrabbedItems in IUIAutomationDragPattern")
		out:= new IUIAutomationElementArray(out)
		return out
	}

	; Property: CachedDropEffect; VTable PositonGet: 6; output : Vt_Bstr*: retVal
	CachedDropEffect[]
	{
		get {
			If !DllCall(this.__Vt(6), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CachedDropEffects; VTable PositonGet: 8; output : Vt_Safearray*: retVal
	CachedDropEffects[]
	{
		get {
			If !DllCall(this.__Vt(8), "Ptr", this.__Value, "Ptr*",out)
			{
				return out
			}
		}
	}
	; Property: CachedIsGrabbed; VTable PositonGet: 4; output : Vt_I4*: retVal
	CachedIsGrabbed[]
	{
		get {
			If !DllCall(this.__Vt(4), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentDropEffect; VTable PositonGet: 5; output : Vt_Bstr*: retVal
	CurrentDropEffect[]
	{
		get {
			If !DllCall(this.__Vt(5), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentDropEffects; VTable PositonGet: 7; output : Vt_Safearray*: retVal
	CurrentDropEffects[]
	{
		get {
			If !DllCall(this.__Vt(7), "Ptr", this.__Value, "Ptr*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentIsGrabbed; VTable PositonGet: 3; output : Vt_I4*: retVal
	CurrentIsGrabbed[]
	{
		get {
			If !DllCall(this.__Vt(3), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationDropTargetPattern
; GUID: {69A095F7-EEE4-430E-A46B-FB73B1AE39A5}
; *************************************************************************


class IUIAutomationDropTargetPattern
{
	; Generic definitions

	static __IID := "{69A095F7-EEE4-430E-A46B-FB73B1AE39A5}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationDropTargetPattern"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; Property: CachedDropTargetEffect; VTable PositonGet: 4; output : Vt_Bstr*: retVal
	CachedDropTargetEffect[]
	{
		get {
			If !DllCall(this.__Vt(4), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CachedDropTargetEffects; VTable PositonGet: 6; output : Vt_Safearray*: retVal
	CachedDropTargetEffects[]
	{
		get {
			If !DllCall(this.__Vt(6), "Ptr", this.__Value, "Ptr*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentDropTargetEffect; VTable PositonGet: 3; output : Vt_Bstr*: retVal
	CurrentDropTargetEffect[]
	{
		get {
			If !DllCall(this.__Vt(3), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentDropTargetEffects; VTable PositonGet: 5; output : Vt_Safearray*: retVal
	CurrentDropTargetEffects[]
	{
		get {
			If !DllCall(this.__Vt(5), "Ptr", this.__Value, "Ptr*",out)
			{
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationElement2
; GUID: {6749C683-F70D-4487-A698-5F79D55290D6}
; *************************************************************************


class IUIAutomationElement2 extends IUIAutomationElement
{
	; Interface functions

	; Property: CachedFlowsFrom; VTable PositonGet: 90; output : IUIAutomationElementArray**: retVal
	CachedFlowsFrom[]
	{
		get {
			If !DllCall(this.__Vt(90), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationElementArray(out)
				return out
			}
		}
	}
	; Property: CachedLiveSetting; VTable PositonGet: 88; output : LiveSetting*: retVal
	CachedLiveSetting[]
	{
		get {
			If !DllCall(this.__Vt(88), "Ptr", this.__Value, "UInt",out)
			{
				return out
			}
		}
	}
	; Property: CachedOptimizeForVisualContent; VTable PositonGet: 86; output : Vt_I4*: retVal
	CachedOptimizeForVisualContent[]
	{
		get {
			If !DllCall(this.__Vt(86), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentFlowsFrom; VTable PositonGet: 89; output : IUIAutomationElementArray**: retVal
	CurrentFlowsFrom[]
	{
		get {
			If !DllCall(this.__Vt(89), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationElementArray(out)
				return out
			}
		}
	}
	; Property: CurrentLiveSetting; VTable PositonGet: 87; output : LiveSetting*: retVal
	CurrentLiveSetting[]
	{
		get {
			If !DllCall(this.__Vt(87), "Ptr", this.__Value, "UInt",out)
			{
				return out
			}
		}
	}
	; Property: CurrentOptimizeForVisualContent; VTable PositonGet: 85; output : Vt_I4*: retVal
	CurrentOptimizeForVisualContent[]
	{
		get {
			If !DllCall(this.__Vt(85), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationElement3
; GUID: {8471DF34-AEE0-4A01-A7DE-7DB9AF12C296}
; *************************************************************************


class IUIAutomationElement3 extends IUIAutomationElement2
{
	; Interface functions

	; VTable Positon 91: INVOKE_FUNC Vt_Hresult ShowContextMenu()
	ShowContextMenu()
	{
		res:=DllCall(this.__Vt(91), "Ptr", this.__Value, "Int")
		return res
	}

	; Property: CachedIsPeripheral; VTable PositonGet: 93; output : Vt_I4*: retVal
	CachedIsPeripheral[]
	{
		get {
			If !DllCall(this.__Vt(93), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentIsPeripheral; VTable PositonGet: 92; output : Vt_I4*: retVal
	CurrentIsPeripheral[]
	{
		get {
			If !DllCall(this.__Vt(92), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationElement4
; GUID: {3B6E233C-52FB-4063-A4C9-77C075C2A06B}
; *************************************************************************


class IUIAutomationElement4 extends IUIAutomationElement3
{
	; Interface functions

	; Property: CachedAnnotationObjects; VTable PositonGet: 103; output : IUIAutomationElementArray**: retVal
	CachedAnnotationObjects[]
	{
		get {
			If !DllCall(this.__Vt(103), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationElementArray(out)
				return out
			}
		}
	}
	; Property: CachedAnnotationTypes; VTable PositonGet: 102; output : Vt_Safearray*: retVal
	CachedAnnotationTypes[]
	{
		get {
			If !DllCall(this.__Vt(102), "Ptr", this.__Value, "Ptr*",out)
			{
				return out
			}
		}
	}
	; Property: CachedLevel; VTable PositonGet: 101; output : Vt_Int*: retVal
	CachedLevel[]
	{
		get {
			If !DllCall(this.__Vt(101), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedPositionInSet; VTable PositonGet: 99; output : Vt_Int*: retVal
	CachedPositionInSet[]
	{
		get {
			If !DllCall(this.__Vt(99), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedSizeOfSet; VTable PositonGet: 100; output : Vt_Int*: retVal
	CachedSizeOfSet[]
	{
		get {
			If !DllCall(this.__Vt(100), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentAnnotationObjects; VTable PositonGet: 98; output : IUIAutomationElementArray**: retVal
	CurrentAnnotationObjects[]
	{
		get {
			If !DllCall(this.__Vt(98), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationElementArray(out)
				return out
			}
		}
	}
	; Property: CurrentAnnotationTypes; VTable PositonGet: 97; output : Vt_Safearray*: retVal
	CurrentAnnotationTypes[]
	{
		get {
			If !DllCall(this.__Vt(97), "Ptr", this.__Value, "Ptr*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentLevel; VTable PositonGet: 96; output : Vt_Int*: retVal
	CurrentLevel[]
	{
		get {
			If !DllCall(this.__Vt(96), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentPositionInSet; VTable PositonGet: 94; output : Vt_Int*: retVal
	CurrentPositionInSet[]
	{
		get {
			If !DllCall(this.__Vt(94), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentSizeOfSet; VTable PositonGet: 95; output : Vt_Int*: retVal
	CurrentSizeOfSet[]
	{
		get {
			If !DllCall(this.__Vt(95), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationElement5
; GUID: {98141C1D-0D0E-4175-BBE2-6BFF455842A7}
; *************************************************************************


class IUIAutomationElement5 extends IUIAutomationElement4
{
	; Interface functions

	; Property: CachedLandmarkType; VTable PositonGet: 106; output : Vt_Int*: retVal
	CachedLandmarkType[]
	{
		get {
			If !DllCall(this.__Vt(106), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CachedLocalizedLandmarkType; VTable PositonGet: 107; output : Vt_Bstr*: retVal
	CachedLocalizedLandmarkType[]
	{
		get {
			If !DllCall(this.__Vt(107), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentLandmarkType; VTable PositonGet: 104; output : Vt_Int*: retVal
	CurrentLandmarkType[]
	{
		get {
			If !DllCall(this.__Vt(104), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
	}
	; Property: CurrentLocalizedLandmarkType; VTable PositonGet: 105; output : Vt_Bstr*: retVal
	CurrentLocalizedLandmarkType[]
	{
		get {
			If !DllCall(this.__Vt(105), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationElement6
; GUID: {4780D450-8BCA-4977-AFA5-A4A517F555E3}
; *************************************************************************


class IUIAutomationElement6 extends IUIAutomationElement5
{
	; Interface functions

	; Property: CachedFullDescription; VTable PositonGet: 109; output : Vt_Bstr*: retVal
	CachedFullDescription[]
	{
		get {
			If !DllCall(this.__Vt(109), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
	; Property: CurrentFullDescription; VTable PositonGet: 108; output : Vt_Bstr*: retVal
	CurrentFullDescription[]
	{
		get {
			If !DllCall(this.__Vt(108), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationElement7
; GUID: {204E8572-CFC3-4C11-B0C8-7DA7420750B7}
; *************************************************************************


class IUIAutomationElement7 extends IUIAutomationElement6
{
	; Interface functions

	; VTable Positon 110: INVOKE_FUNC Vt_Hresult FindFirstWithOptions([FIN] TreeScope: scope, [FIN] IUIAutomationCondition*: condition, [FIN] TreeTraversalOptions: traversalOptions, [FIN] IUIAutomationElement*: root, [FOUT] [FRETVAL] IUIAutomationElement**: found)
	FindFirstWithOptions(scope, condition, traversalOptions, root)
	{
		If (IsObject(condition) and (ComObjType(condition)=""))
			refcondition:=condition.__Value
		else
			refcondition:=condition
		If (IsObject(root) and (ComObjType(root)=""))
			refroot:=root.__Value
		else
			refroot:=root
		res:=DllCall(this.__Vt(110), "Ptr", this.__Value, "UInt", scope, "Ptr", refcondition, "UInt", traversalOptions, "Ptr", refroot, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from FindFirstWithOptions in IUIAutomationElement7")
		out:= new IUIAutomationElement(out)
		return out
	}

	; VTable Positon 111: INVOKE_FUNC Vt_Hresult FindAllWithOptions([FIN] TreeScope: scope, [FIN] IUIAutomationCondition*: condition, [FIN] TreeTraversalOptions: traversalOptions, [FIN] IUIAutomationElement*: root, [FOUT] [FRETVAL] IUIAutomationElementArray**: found)
	FindAllWithOptions(scope, condition, traversalOptions, root)
	{
		If (IsObject(condition) and (ComObjType(condition)=""))
			refcondition:=condition.__Value
		else
			refcondition:=condition
		If (IsObject(root) and (ComObjType(root)=""))
			refroot:=root.__Value
		else
			refroot:=root
		res:=DllCall(this.__Vt(111), "Ptr", this.__Value, "UInt", scope, "Ptr", refcondition, "UInt", traversalOptions, "Ptr", refroot, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from FindAllWithOptions in IUIAutomationElement7")
		out:= new IUIAutomationElementArray(out)
		return out
	}

	; VTable Positon 112: INVOKE_FUNC Vt_Hresult FindFirstWithOptionsBuildCache([FIN] TreeScope: scope, [FIN] IUIAutomationCondition*: condition, [FIN] IUIAutomationCacheRequest*: cacheRequest, [FIN] TreeTraversalOptions: traversalOptions, [FIN] IUIAutomationElement*: root, [FOUT] [FRETVAL] IUIAutomationElement**: found)
	FindFirstWithOptionsBuildCache(scope, condition, cacheRequest, traversalOptions, root)
	{
		If (IsObject(condition) and (ComObjType(condition)=""))
			refcondition:=condition.__Value
		else
			refcondition:=condition
		If (IsObject(cacheRequest) and (ComObjType(cacheRequest)=""))
			refcacheRequest:=cacheRequest.__Value
		else
			refcacheRequest:=cacheRequest
		If (IsObject(root) and (ComObjType(root)=""))
			refroot:=root.__Value
		else
			refroot:=root
		res:=DllCall(this.__Vt(112), "Ptr", this.__Value, "UInt", scope, "Ptr", refcondition, "Ptr", refcacheRequest, "UInt", traversalOptions, "Ptr", refroot, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from FindFirstWithOptionsBuildCache in IUIAutomationElement7")
		out:= new IUIAutomationElement(out)
		return out
	}

	; VTable Positon 113: INVOKE_FUNC Vt_Hresult FindAllWithOptionsBuildCache([FIN] TreeScope: scope, [FIN] IUIAutomationCondition*: condition, [FIN] IUIAutomationCacheRequest*: cacheRequest, [FIN] TreeTraversalOptions: traversalOptions, [FIN] IUIAutomationElement*: root, [FOUT] [FRETVAL] IUIAutomationElementArray**: found)
	FindAllWithOptionsBuildCache(scope, condition, cacheRequest, traversalOptions, root)
	{
		If (IsObject(condition) and (ComObjType(condition)=""))
			refcondition:=condition.__Value
		else
			refcondition:=condition
		If (IsObject(cacheRequest) and (ComObjType(cacheRequest)=""))
			refcacheRequest:=cacheRequest.__Value
		else
			refcacheRequest:=cacheRequest
		If (IsObject(root) and (ComObjType(root)=""))
			refroot:=root.__Value
		else
			refroot:=root
		res:=DllCall(this.__Vt(113), "Ptr", this.__Value, "UInt", scope, "Ptr", refcondition, "Ptr", refcacheRequest, "UInt", traversalOptions, "Ptr", refroot, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from FindAllWithOptionsBuildCache in IUIAutomationElement7")
		out:= new IUIAutomationElementArray(out)
		return out
	}

	; VTable Positon 114: INVOKE_FUNC Vt_Hresult GetCurrentMetadataValue([FIN] Int: targetId, [FIN] Int: metadataId, [FOUT] [FRETVAL] Variant*: returnVal)
	GetCurrentMetadataValue(targetId, metadataId)
	{
		res:=DllCall(this.__Vt(114), "Ptr", this.__Value, "Int", targetId, "Int", metadataId, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetCurrentMetadataValue in IUIAutomationElement7")
		out:=ComObject(0x400C, out+0, flag)[]
		return out
	}

}

; *************************************************************************
; IUIAutomationProxyFactory
; GUID: {85B94ECD-849D-42B6-B94D-D6DB23FDF5A4}
; *************************************************************************


class IUIAutomationProxyFactory
{
	; Generic definitions

	static __IID := "{85B94ECD-849D-42B6-B94D-D6DB23FDF5A4}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationProxyFactory"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult CreateProvider([FIN] Void*: hwnd, [FIN] I4: idObject, [FIN] I4: idChild, [FOUT] [FRETVAL] IRawElementProviderSimple**: provider)
	CreateProvider(hwnd, idObject, idChild)
	{
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Ptr", hwnd, "Int", idObject, "Int", idChild, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from CreateProvider in IUIAutomationProxyFactory")
		out:= new IRawElementProviderSimple(out)
		return out
	}

	; Property: ProxyFactoryId; VTable PositonGet: 4; output : Vt_Bstr*: factoryId
	ProxyFactoryId[]
	{
		get {
			If !DllCall(this.__Vt(4), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
	}
}

; *************************************************************************
; IRawElementProviderSimpleImpl

; This class provides a basic implementation wrapper for IRawElementProviderSimple.
; WARNING: This currently only works in 64bit!
; To use you need to provide an implementation for the exported functions in your script.
; Example:
;~ #Include ComImplementationBase.ahk
;~ class YourClassName extends IRawElementProviderSimpleImpl
;~ {
;~	ProviderOptions_PropertyGet(pInterface)
;~	{
;~		; your code
;~	}

;~	GetPatternProvider(pInterface, patternId, pRetVal)
;~	{
;~		; your code
;~	}

;~	GetPropertyValue(pInterface, propertyId, pRetVal)
;~	{
;~		; your code
;~	}

;~	HostRawElementProvider_PropertyGet(pInterface)
;~	{
;~		; your code
;~	}
;~ }
;~
; GUID: {D6DD68D1-86FD-4332-8666-9ABEDEA2D24C}
; *************************************************************************


class IRawElementProviderSimpleImpl extends IUnknownImpl
{	ComFunctions := ["QueryInterface", "AddRef", "Release", "ProviderOptions_PropertyGet", "GetPatternProvider", "GetPropertyValue", "HostRawElementProvider_PropertyGet"]

	__New()
	{
		; Add the GUID of the interface this class is implementing
		this.ImplementsInterfaces.InsertAt(1, "{D6DD68D1-86FD-4332-8666-9ABEDEA2D24C}")
		base.__New()
	}

	_ProviderOptions_PropertyGet(pInterface)	; Type: IRawElementProviderSimple** ObjType:
	{
		if (!IsObject(this))
			return ComObjImpl.ObjMap[this]._ProviderOptions_PropertyGet(this, pInterface)
		return this.ProviderOptions_PropertyGet(pInterface)
	}


	; VTable Positon 4: INVOKE_FUNC Vt_Hresult GetPatternProvider([FIN] Int: patternId, [FOUT] [FRETVAL] Unknown*: pRetVal)
	_GetPatternProvider(pInterface, patternId, pRetVal)
	{
		if (!IsObject(this))
			return ComObjImpl.ObjMap[this]._GetPatternProvider(this, pInterface, patternId)

		this.GetPatternProvider(pInterface, patternId, pRetVal)
	}

	; VTable Positon 5: INVOKE_FUNC Vt_Hresult GetPropertyValue([FIN] Int: propertyId, [FOUT] [FRETVAL] Variant*: pRetVal)
	_GetPropertyValue(pInterface, propertyId, pRetVal)
	{
		if (!IsObject(this))
			return ComObjImpl.ObjMap[this]._GetPropertyValue(this, pInterface, propertyId)

		this.GetPropertyValue(pInterface, propertyId, pRetVal)
	}

	_HostRawElementProvider_PropertyGet(pInterface)	; Type: IRawElementProviderSimple** ObjType:
	{
		if (!IsObject(this))
			return ComObjImpl.ObjMap[this]._HostRawElementProvider_PropertyGet(this, pInterface)
		return this.HostRawElementProvider_PropertyGet(pInterface)
	}

}

; *************************************************************************
; IRawElementProviderSimple
; GUID: {D6DD68D1-86FD-4332-8666-9ABEDEA2D24C}
; *************************************************************************


class IRawElementProviderSimple
{
	; Generic definitions

	static __IID := "{D6DD68D1-86FD-4332-8666-9ABEDEA2D24C}"

	__New(p="", flag=1)
	{
		this.__Type:="IRawElementProviderSimple"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 4: INVOKE_FUNC Vt_Hresult GetPatternProvider([FIN] Int: patternId, [FOUT] [FRETVAL] Unknown*: pRetVal)
	GetPatternProvider(patternId)
	{
		res:=DllCall(this.__Vt(4), "Ptr", this.__Value, "Int", patternId, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetPatternProvider in IRawElementProviderSimple")
		return out
	}

	; VTable Positon 5: INVOKE_FUNC Vt_Hresult GetPropertyValue([FIN] Int: propertyId, [FOUT] [FRETVAL] Variant*: pRetVal)
	GetPropertyValue(propertyId)
	{
		res:=DllCall(this.__Vt(5), "Ptr", this.__Value, "Int", propertyId, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetPropertyValue in IRawElementProviderSimple")
		out:=ComObject(0x400C, out+0, flag)[]
		return out
	}

	; Property: HostRawElementProvider; VTable PositonGet: 6; output : IRawElementProviderSimple**: pRetVal
	HostRawElementProvider[]
	{
		get {
			If !DllCall(this.__Vt(6), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IRawElementProviderSimple(out)
				return out
			}
		}
	}
	; Property: ProviderOptions; VTable PositonGet: 3; output : ProviderOptions*: pRetVal
	ProviderOptions[]
	{
		get {
			If !DllCall(this.__Vt(3), "Ptr", this.__Value, "UInt",out)
			{
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationProxyFactoryEntry
; GUID: {D50E472E-B64B-490C-BCA1-D30696F9F289}
; *************************************************************************


class IUIAutomationProxyFactoryEntry
{
	; Generic definitions

	static __IID := "{D50E472E-B64B-490C-BCA1-D30696F9F289}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationProxyFactoryEntry"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 14: INVOKE_FUNC Vt_Hresult SetWinEventsForAutomationEvent([FIN] Int: eventId, [FIN] Int: propertyId, [FIN] Safearray: winEvents)
	SetWinEventsForAutomationEvent(eventId, propertyId, winEvents)
	{
		If (ComObjValue(winEvents) & 0x2000)
			refwinEvents:=winEvents
		else
		{
			refwinEvents:=ComObject(0x2003, DllCall("oleaut32\SafeArrayCreateVector", "UInt", 13, "UInt", 0, "UInt", winEvents.MaxIndex()),1)
			For ind, val in winEvents
				refwinEvents[A_Index-1]:= val.__Value, ObjAddRef(val.__Value)
		}
		res:=DllCall(this.__Vt(14), "Ptr", this.__Value, "Int", eventId, "Int", propertyId, "Ptr", ComObjValue(refwinEvents), "Int")
		return res
	}

	; VTable Positon 15: INVOKE_FUNC Vt_Hresult GetWinEventsForAutomationEvent([FIN] Int: eventId, [FIN] Int: propertyId, [FOUT] [FRETVAL] Safearray*: winEvents)
	GetWinEventsForAutomationEvent(eventId, propertyId)
	{
		If (ComObjValue(winEvents) & 0x2000)
			refwinEvents:=winEvents
		else
		{
			refwinEvents:=ComObject(0x2003, DllCall("oleaut32\SafeArrayCreateVector", "UInt", 13, "UInt", 0, "UInt", winEvents.MaxIndex()),1)
			For ind, val in winEvents
				refwinEvents[A_Index-1]:= val.__Value, ObjAddRef(val.__Value)
		}
		res:=DllCall(this.__Vt(15), "Ptr", this.__Value, "Int", eventId, "Int", propertyId, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetWinEventsForAutomationEvent in IUIAutomationProxyFactoryEntry")
		return out
	}

	; Property: AllowSubstringMatch; VTable PositonGet: 6; output : Vt_I4*: AllowSubstringMatch; VTable PositonPut: 11; input : Vt_I4: AllowSubstringMatch
	AllowSubstringMatch[]
	{
		get {
			If !DllCall(this.__Vt(6), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
		set {
			If !DllCall(this.__Vt(11), "Ptr", this.__Value, "Int", value)
				return value
		}
	}
	; Property: CanCheckBaseClass; VTable PositonGet: 7; output : Vt_I4*: CanCheckBaseClass; VTable PositonPut: 12; input : Vt_I4: CanCheckBaseClass
	CanCheckBaseClass[]
	{
		get {
			If !DllCall(this.__Vt(7), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
		set {
			If !DllCall(this.__Vt(12), "Ptr", this.__Value, "Int", value)
				return value
		}
	}
	; Property: ClassName; VTable PositonGet: 4; output : Vt_Bstr*: ClassName; VTable PositonPut: 9; input : Vt_Lpwstr: ClassName
	ClassName[]
	{
		get {
			If !DllCall(this.__Vt(4), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
		set {
			If !DllCall(this.__Vt(9), "Ptr", this.__Value, "Ptr", value)
				return value
		}
	}
	; Property: ImageName; VTable PositonGet: 5; output : Vt_Bstr*: ImageName; VTable PositonPut: 10; input : Vt_Lpwstr: ImageName
	ImageName[]
	{
		get {
			If !DllCall(this.__Vt(5), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= StrGet(out)
				return out
			}
		}
		set {
			If !DllCall(this.__Vt(10), "Ptr", this.__Value, "Ptr", value)
				return value
		}
	}
	; Property: NeedsAdviseEvents; VTable PositonGet: 8; output : Vt_I4*: adviseEvents; VTable PositonPut: 13; input : Vt_I4: adviseEvents
	NeedsAdviseEvents[]
	{
		get {
			If !DllCall(this.__Vt(8), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
		set {
			If !DllCall(this.__Vt(13), "Ptr", this.__Value, "Int", value)
				return value
		}
	}
	; Property: ProxyFactory; VTable PositonGet: 3; output : IUIAutomationProxyFactory**: factory
	ProxyFactory[]
	{
		get {
			If !DllCall(this.__Vt(3), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationProxyFactory(out)
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomationProxyFactoryMapping
; GUID: {09E31E18-872D-4873-93D1-1E541EC133FD}
; *************************************************************************


class IUIAutomationProxyFactoryMapping
{
	; Generic definitions

	static __IID := "{09E31E18-872D-4873-93D1-1E541EC133FD}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationProxyFactoryMapping"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 4: INVOKE_FUNC Vt_Hresult GetTable([FOUT] [FRETVAL] Safearray*: table)
	GetTable()
	{
		If (ComObjValue(table) & 0x2000)
			reftable:=table
		else
		{
			reftable:=ComObject(0x2003, DllCall("oleaut32\SafeArrayCreateVector", "UInt", 13, "UInt", 0, "UInt", table.MaxIndex()),1)
			For ind, val in table
				reftable[A_Index-1]:= val.__Value, ObjAddRef(val.__Value)
		}
		res:=DllCall(this.__Vt(4), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetTable in IUIAutomationProxyFactoryMapping")
		return out
	}

	; VTable Positon 5: INVOKE_FUNC Vt_Hresult GetEntry([FIN] Uint: index, [FOUT] [FRETVAL] IUIAutomationProxyFactoryEntry**: entry)
	GetEntry(index)
	{
		res:=DllCall(this.__Vt(5), "Ptr", this.__Value, "Uint", index, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetEntry in IUIAutomationProxyFactoryMapping")
		out:= new IUIAutomationProxyFactoryEntry(out)
		return out
	}

	; VTable Positon 6: INVOKE_FUNC Vt_Hresult SetTable([FIN] Safearray: factoryList)
	SetTable(factoryList)
	{
		If (ComObjValue(factoryList) & 0x2000)
			reffactoryList:=factoryList
		else
		{
			reffactoryList:=ComObject(0x2003, DllCall("oleaut32\SafeArrayCreateVector", "UInt", 13, "UInt", 0, "UInt", factoryList.MaxIndex()),1)
			For ind, val in factoryList
				reffactoryList[A_Index-1]:= val.__Value, ObjAddRef(val.__Value)
		}
		res:=DllCall(this.__Vt(6), "Ptr", this.__Value, "Ptr", ComObjValue(reffactoryList), "Int")
		return res
	}

	; VTable Positon 7: INVOKE_FUNC Vt_Hresult InsertEntries([FIN] Uint: before, [FIN] Safearray: factoryList)
	InsertEntries(before, factoryList)
	{
		If (ComObjValue(factoryList) & 0x2000)
			reffactoryList:=factoryList
		else
		{
			reffactoryList:=ComObject(0x2003, DllCall("oleaut32\SafeArrayCreateVector", "UInt", 13, "UInt", 0, "UInt", factoryList.MaxIndex()),1)
			For ind, val in factoryList
				reffactoryList[A_Index-1]:= val.__Value, ObjAddRef(val.__Value)
		}
		res:=DllCall(this.__Vt(7), "Ptr", this.__Value, "Uint", before, "Ptr", ComObjValue(reffactoryList), "Int")
		return res
	}

	; VTable Positon 8: INVOKE_FUNC Vt_Hresult InsertEntry([FIN] Uint: before, [FIN] IUIAutomationProxyFactoryEntry*: factory)
	InsertEntry(before, factory)
	{
		If (IsObject(factory) and (ComObjType(factory)=""))
			reffactory:=factory.__Value
		else
			reffactory:=factory
		res:=DllCall(this.__Vt(8), "Ptr", this.__Value, "Uint", before, "Ptr", reffactory, "Int")
		return res
	}

	; VTable Positon 9: INVOKE_FUNC Vt_Hresult RemoveEntry([FIN] Uint: index)
	RemoveEntry(index)
	{
		res:=DllCall(this.__Vt(9), "Ptr", this.__Value, "Uint", index, "Int")
		return res
	}

	; VTable Positon 10: INVOKE_FUNC Vt_Hresult ClearTable()
	ClearTable()
	{
		res:=DllCall(this.__Vt(10), "Ptr", this.__Value, "Int")
		return res
	}

	; VTable Positon 11: INVOKE_FUNC Vt_Hresult RestoreDefaultTable()
	RestoreDefaultTable()
	{
		res:=DllCall(this.__Vt(11), "Ptr", this.__Value, "Int")
		return res
	}

	; Property: count; VTable PositonGet: 3; output : Vt_Uint*: count
	count[]
	{
		get {
			If !DllCall(this.__Vt(3), "Ptr", this.__Value, "Uint*",out)
			{
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomation
; GUID: {30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}
; *************************************************************************


class IUIAutomation
{
	; Generic definitions

	static __IID := "{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomation"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult CompareElements([FIN] IUIAutomationElement*: el1, [FIN] IUIAutomationElement*: el2, [FOUT] [FRETVAL] I4*: areSame)
	CompareElements(el1, el2) {
		If (IsObject(el1) and (ComObjType(el1)=""))
			refel1:=el1.__Value
		else
			refel1:=el1
		If (IsObject(el2) and (ComObjType(el2)=""))
			refel2:=el2.__Value
		else
			refel2:=el2
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Ptr", refel1, "Ptr", refel2, "Int*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from CompareElements in IUIAutomation")
		return out
	}

	; VTable Positon 4: INVOKE_FUNC Vt_Hresult CompareRuntimeIds([FIN] Safearray: runtimeId1, [FIN] Safearray: runtimeId2, [FOUT] [FRETVAL] I4*: areSame)
	CompareRuntimeIds(runtimeId1, runtimeId2) {
		If (ComObjValue(runtimeId1) & 0x2000)
			refruntimeId1:=runtimeId1
		else
		{
			refruntimeId1:=ComObject(0x2003, DllCall("oleaut32\SafeArrayCreateVector", "UInt", 13, "UInt", 0, "UInt", runtimeId1.MaxIndex()),1)
			For ind, val in runtimeId1
				refruntimeId1[A_Index-1]:= val.__Value, ObjAddRef(val.__Value)
		}
		If (ComObjValue(runtimeId2) & 0x2000)
			refruntimeId2:=runtimeId2
		else
		{
			refruntimeId2:=ComObject(0x2003, DllCall("oleaut32\SafeArrayCreateVector", "UInt", 13, "UInt", 0, "UInt", runtimeId2.MaxIndex()),1)
			For ind, val in runtimeId2
				refruntimeId2[A_Index-1]:= val.__Value, ObjAddRef(val.__Value)
		}
		res:=DllCall(this.__Vt(4), "Ptr", this.__Value, "Ptr", ComObjValue(refruntimeId1), "Ptr", ComObjValue(refruntimeId2), "Int*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from CompareRuntimeIds in IUIAutomation")
		return out
	}

	; VTable Positon 5: INVOKE_FUNC Vt_Hresult GetRootElement([FOUT] [FRETVAL] IUIAutomationElement**: root)
	GetRootElement() {
		res:=DllCall(this.__Vt(5), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetRootElement in IUIAutomation")
		out:= new IUIAutomationElement(out)
		return out
	}

	; VTable Positon 6: INVOKE_FUNC Vt_Hresult ElementFromHandle([FIN] Void*: hwnd, [FOUT] [FRETVAL] IUIAutomationElement**: element)
	ElementFromHandle(hwnd) {
		res:=DllCall(this.__Vt(6), "Ptr", this.__Value, "Ptr", hwnd, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from ElementFromHandle in IUIAutomation")
		out:= new IUIAutomationElement(out)
		return out
	}

	; VTable Positon 7: INVOKE_FUNC Vt_Hresult ElementFromPoint([FIN] tagPOINT: pt, [FOUT] [FRETVAL] IUIAutomationElement**: element)
	ElementFromPoint(pt) {
		If (IsObject(pt) and (ComObjType(pt)=""))
			refpt:=pt.__Value
		else
			refpt:=&pt
		res:=DllCall(this.__Vt(7), "Ptr", this.__Value, "Ptr", refpt, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from ElementFromPoint in IUIAutomation")
		out:= new IUIAutomationElement(out)
		return out
	}

	; VTable Positon 8: INVOKE_FUNC Vt_Hresult GetFocusedElement([FOUT] [FRETVAL] IUIAutomationElement**: element)
	GetFocusedElement() {
		res:=DllCall(this.__Vt(8), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetFocusedElement in IUIAutomation")
		out:= new IUIAutomationElement(out)
		return out
	}

	; VTable Positon 9: INVOKE_FUNC Vt_Hresult GetRootElementBuildCache([FIN] IUIAutomationCacheRequest*: cacheRequest, [FOUT] [FRETVAL] IUIAutomationElement**: root)
	GetRootElementBuildCache(cacheRequest) 	{
		If (IsObject(cacheRequest) and (ComObjType(cacheRequest)=""))
			refcacheRequest:=cacheRequest.__Value
		else
			refcacheRequest:=cacheRequest
		res:=DllCall(this.__Vt(9), "Ptr", this.__Value, "Ptr", refcacheRequest, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetRootElementBuildCache in IUIAutomation")
		out:= new IUIAutomationElement(out)
		return out
	}

	; VTable Positon 10: INVOKE_FUNC Vt_Hresult ElementFromHandleBuildCache([FIN] Void*: hwnd, [FIN] IUIAutomationCacheRequest*: cacheRequest, [FOUT] [FRETVAL] IUIAutomationElement**: element)
	ElementFromHandleBuildCache(hwnd, cacheRequest) {
		If (IsObject(cacheRequest) and (ComObjType(cacheRequest)=""))
			refcacheRequest:=cacheRequest.__Value
		else
			refcacheRequest:=cacheRequest
		res:=DllCall(this.__Vt(10), "Ptr", this.__Value, "Ptr", hwnd, "Ptr", refcacheRequest, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from ElementFromHandleBuildCache in IUIAutomation")
		out:= new IUIAutomationElement(out)
		return out
	}

	; VTable Positon 11: INVOKE_FUNC Vt_Hresult ElementFromPointBuildCache([FIN] tagPOINT: pt, [FIN] IUIAutomationCacheRequest*: cacheRequest, [FOUT] [FRETVAL] IUIAutomationElement**: element)
	ElementFromPointBuildCache(pt, cacheRequest) {
		If (IsObject(pt) and (ComObjType(pt)=""))
			refpt:=pt.__Value
		else
			refpt:=&pt
		If (IsObject(cacheRequest) and (ComObjType(cacheRequest)=""))
			refcacheRequest:=cacheRequest.__Value
		else
			refcacheRequest:=cacheRequest
		res:=DllCall(this.__Vt(11), "Ptr", this.__Value, "Ptr", refpt, "Ptr", refcacheRequest, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from ElementFromPointBuildCache in IUIAutomation")
		out:= new IUIAutomationElement(out)
		return out
	}

	; VTable Positon 12: INVOKE_FUNC Vt_Hresult GetFocusedElementBuildCache([FIN] IUIAutomationCacheRequest*: cacheRequest, [FOUT] [FRETVAL] IUIAutomationElement**: element)
	GetFocusedElementBuildCache(cacheRequest) {
		If (IsObject(cacheRequest) and (ComObjType(cacheRequest)=""))
			refcacheRequest:=cacheRequest.__Value
		else
			refcacheRequest:=cacheRequest
		res:=DllCall(this.__Vt(12), "Ptr", this.__Value, "Ptr", refcacheRequest, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetFocusedElementBuildCache in IUIAutomation")
		out:= new IUIAutomationElement(out)
		return out
	}

	; VTable Positon 13: INVOKE_FUNC Vt_Hresult CreateTreeWalker([FIN] IUIAutomationCondition*: pCondition, [FOUT] [FRETVAL] IUIAutomationTreeWalker**: walker)
	CreateTreeWalker(pCondition) {
		If (IsObject(pCondition) and (ComObjType(pCondition)=""))
			refpCondition:=pCondition.__Value
		else
			refpCondition:=pCondition
		res:=DllCall(this.__Vt(13), "Ptr", this.__Value, "Ptr", refpCondition, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from CreateTreeWalker in IUIAutomation")
		out:= new IUIAutomationTreeWalker(out)
		return out
	}

	; VTable Positon 20: INVOKE_FUNC Vt_Hresult CreateCacheRequest([FOUT] [FRETVAL] IUIAutomationCacheRequest**: cacheRequest)
	CreateCacheRequest() {
		res:=DllCall(this.__Vt(20), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from CreateCacheRequest in IUIAutomation")
		out:= new IUIAutomationCacheRequest(out)
		return out
	}

	; VTable Positon 21: INVOKE_FUNC Vt_Hresult CreateTrueCondition([FOUT] [FRETVAL] IUIAutomationCondition**: newCondition)
	CreateTrueCondition() {
		res:=DllCall(this.__Vt(21), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from CreateTrueCondition in IUIAutomation")
		out:= new IUIAutomationCondition(out)
		return out
	}

	; VTable Positon 22: INVOKE_FUNC Vt_Hresult CreateFalseCondition([FOUT] [FRETVAL] IUIAutomationCondition**: newCondition)
	CreateFalseCondition() {
		res:=DllCall(this.__Vt(22), "Ptr", this.__Value, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from CreateFalseCondition in IUIAutomation")
		out:= new IUIAutomationCondition(out)
		return out
	}

	; VTable Positon 23: INVOKE_FUNC Vt_Hresult CreatePropertyCondition([FIN] Int: propertyId, [FIN] Variant: value, [FOUT] [FRETVAL] IUIAutomationCondition**: newCondition)
	CreatePropertyCondition(propertyId, value, valueVariantType) {
		if (valueVariantType!=12) ; value is not a variant
		{
			VarSetCapacity(refvalue,8+2*A_PtrSize)
			variant_ref := ComObject(0x400C, &refvalue)
			variant_ref[] := value
			NumPut(valueVariantType, refvalue, 0, "short")
		}
		else
			refvalue:=value
		res:=DllCall(this.__Vt(23), "Ptr", this.__Value, "Int", propertyId, "Ptr", &refvalue, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from CreatePropertyCondition in IUIAutomation")
		out:= new IUIAutomationCondition(out)
		return out
	}

	; VTable Positon 24: INVOKE_FUNC Vt_Hresult CreatePropertyConditionEx([FIN] Int: propertyId, [FIN] Variant: value, [FIN] PropertyConditionFlags: flags, [FOUT] [FRETVAL] IUIAutomationCondition**: newCondition)
	CreatePropertyConditionEx(propertyId, value, valueVariantType, flags)	{
		if (valueVariantType!=12) ; value is not a variant
		{
			VarSetCapacity(refvalue,8+2*A_PtrSize)
			variant_ref := ComObject(0x400C, &refvalue)
			variant_ref[] := value
			NumPut(valueVariantType, refvalue, 0, "short")
		}
		else
			refvalue:=value
		res:=DllCall(this.__Vt(24), "Ptr", this.__Value, "Int", propertyId, "Ptr", &refvalue, "UInt", flags, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from CreatePropertyConditionEx in IUIAutomation")
		out:= new IUIAutomationCondition(out)
		return out
	}

	; VTable Positon 25: INVOKE_FUNC Vt_Hresult CreateAndCondition([FIN] IUIAutomationCondition*: condition1, [FIN] IUIAutomationCondition*: condition2, [FOUT] [FRETVAL] IUIAutomationCondition**: newCondition)
	CreateAndCondition(condition1, condition2) {
		If (IsObject(condition1) and (ComObjType(condition1)=""))
			refcondition1:=condition1.__Value
		else
			refcondition1:=condition1
		If (IsObject(condition2) and (ComObjType(condition2)=""))
			refcondition2:=condition2.__Value
		else
			refcondition2:=condition2
		res:=DllCall(this.__Vt(25), "Ptr", this.__Value, "Ptr", refcondition1, "Ptr", refcondition2, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from CreateAndCondition in IUIAutomation")
		out:= new IUIAutomationCondition(out)
		return out
	}

	; VTable Positon 26: INVOKE_FUNC Vt_Hresult CreateAndConditionFromArray([FIN] Safearray: conditions, [FOUT] [FRETVAL] IUIAutomationCondition**: newCondition)
	CreateAndConditionFromArray(conditions) {
		If (ComObjValue(conditions) & 0x2000)
			refconditions:=conditions
		else
		{
			refconditions:=ComObject(0x2003, DllCall("oleaut32\SafeArrayCreateVector", "UInt", 13, "UInt", 0, "UInt", conditions.MaxIndex()),1)
			For ind, val in conditions
				refconditions[A_Index-1]:= val.__Value, ObjAddRef(val.__Value)
		}
		res:=DllCall(this.__Vt(26), "Ptr", this.__Value, "Ptr", ComObjValue(refconditions), "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from CreateAndConditionFromArray in IUIAutomation")
		out:= new IUIAutomationCondition(out)
		return out
	}

	; VTable Positon 27: INVOKE_FUNC Vt_Hresult CreateAndConditionFromNativeArray([FIN] IUIAutomationCondition**: conditions, [FIN] Int: conditionCount, [FOUT] [FRETVAL] IUIAutomationCondition**: newCondition)
	CreateAndConditionFromNativeArray(conditions, conditionCount) {
		res:=DllCall(this.__Vt(27), "Ptr", this.__Value, "Ptr*", conditions, "Int", conditionCount, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from CreateAndConditionFromNativeArray in IUIAutomation")
		out:= new IUIAutomationCondition(out)
		return out
	}

	; VTable Positon 28: INVOKE_FUNC Vt_Hresult CreateOrCondition([FIN] IUIAutomationCondition*: condition1, [FIN] IUIAutomationCondition*: condition2, [FOUT] [FRETVAL] IUIAutomationCondition**: newCondition)
	CreateOrCondition(condition1, condition2) {
		If (IsObject(condition1) and (ComObjType(condition1)=""))
			refcondition1:=condition1.__Value
		else
			refcondition1:=condition1
		If (IsObject(condition2) and (ComObjType(condition2)=""))
			refcondition2:=condition2.__Value
		else
			refcondition2:=condition2
		res:=DllCall(this.__Vt(28), "Ptr", this.__Value, "Ptr", refcondition1, "Ptr", refcondition2, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from CreateOrCondition in IUIAutomation")
		out:= new IUIAutomationCondition(out)
		return out
	}

	; VTable Positon 29: INVOKE_FUNC Vt_Hresult CreateOrConditionFromArray([FIN] Safearray: conditions, [FOUT] [FRETVAL] IUIAutomationCondition**: newCondition)
	CreateOrConditionFromArray(conditions) {
		If (ComObjValue(conditions) & 0x2000)
			refconditions:=conditions
		else
		{
			refconditions:=ComObject(0x2003, DllCall("oleaut32\SafeArrayCreateVector", "UInt", 13, "UInt", 0, "UInt", conditions.MaxIndex()),1)
			For ind, val in conditions
				refconditions[A_Index-1]:= val.__Value, ObjAddRef(val.__Value)
		}
		res:=DllCall(this.__Vt(29), "Ptr", this.__Value, "Ptr", ComObjValue(refconditions), "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from CreateOrConditionFromArray in IUIAutomation")
		out:= new IUIAutomationCondition(out)
		return out
	}

	; VTable Positon 30: INVOKE_FUNC Vt_Hresult CreateOrConditionFromNativeArray([FIN] IUIAutomationCondition**: conditions, [FIN] Int: conditionCount, [FOUT] [FRETVAL] IUIAutomationCondition**: newCondition)
	CreateOrConditionFromNativeArray(conditions, conditionCount) {
		res:=DllCall(this.__Vt(30), "Ptr", this.__Value, "Ptr*", conditions, "Int", conditionCount, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from CreateOrConditionFromNativeArray in IUIAutomation")
		out:= new IUIAutomationCondition(out)
		return out
	}

	; VTable Positon 31: INVOKE_FUNC Vt_Hresult CreateNotCondition([FIN] IUIAutomationCondition*: condition, [FOUT] [FRETVAL] IUIAutomationCondition**: newCondition)
	CreateNotCondition(condition) {
		If (IsObject(condition) and (ComObjType(condition)=""))
			refcondition:=condition.__Value
		else
			refcondition:=condition
		res:=DllCall(this.__Vt(31), "Ptr", this.__Value, "Ptr", refcondition, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from CreateNotCondition in IUIAutomation")
		out:= new IUIAutomationCondition(out)
		return out
	}

	; VTable Positon 32: INVOKE_FUNC Vt_Hresult AddAutomationEventHandler([FIN] Int: eventId, [FIN] IUIAutomationElement*: element, [FIN] TreeScope: scope, [FIN] IUIAutomationCacheRequest*: cacheRequest, [FIN] IUIAutomationEventHandler*: handler)
	AddAutomationEventHandler(eventId, element, scope, cacheRequest, handler) {
		If (IsObject(element) and (ComObjType(element)=""))
			refelement:=element.__Value
		else
			refelement:=element
		If (IsObject(cacheRequest) and (ComObjType(cacheRequest)=""))
			refcacheRequest:=cacheRequest.__Value
		else
			refcacheRequest:=cacheRequest
		If (IsObject(handler) and (ComObjType(handler)=""))
			refhandler:=handler.__Value
		else
			refhandler:=handler
		res:=DllCall(this.__Vt(32), "Ptr", this.__Value, "Int", eventId, "Ptr", refelement, "UInt", scope, "Ptr", refcacheRequest, "Ptr", refhandler, "Int")
		return res
	}

	; VTable Positon 33: INVOKE_FUNC Vt_Hresult RemoveAutomationEventHandler([FIN] Int: eventId, [FIN] IUIAutomationElement*: element, [FIN] IUIAutomationEventHandler*: handler)
	RemoveAutomationEventHandler(eventId, element, handler) {
		If (IsObject(element) and (ComObjType(element)=""))
			refelement:=element.__Value
		else
			refelement:=element
		If (IsObject(handler) and (ComObjType(handler)=""))
			refhandler:=handler.__Value
		else
			refhandler:=handler
		res:=DllCall(this.__Vt(33), "Ptr", this.__Value, "Int", eventId, "Ptr", refelement, "Ptr", refhandler, "Int")
		return res
	}

	; VTable Positon 34: INVOKE_FUNC Vt_Hresult AddPropertyChangedEventHandlerNativeArray([FIN] IUIAutomationElement*: element, [FIN] TreeScope: scope, [FIN] IUIAutomationCacheRequest*: cacheRequest, [FIN] IUIAutomationPropertyChangedEventHandler*: handler, [FIN] Int*: propertyArray, [FIN] Int: propertyCount)
	AddPropertyChangedEventHandlerNativeArray(element, scope, cacheRequest, handler, propertyArray, propertyCount) {
		If (IsObject(element) and (ComObjType(element)=""))
			refelement:=element.__Value
		else
			refelement:=element
		If (IsObject(cacheRequest) and (ComObjType(cacheRequest)=""))
			refcacheRequest:=cacheRequest.__Value
		else
			refcacheRequest:=cacheRequest
		If (IsObject(handler) and (ComObjType(handler)=""))
			refhandler:=handler.__Value
		else
			refhandler:=handler
		res:=DllCall(this.__Vt(34), "Ptr", this.__Value, "Ptr", refelement, "UInt", scope, "Ptr", refcacheRequest, "Ptr", refhandler, "Int*", propertyArray, "Int", propertyCount, "Int")
		return res
	}

	; VTable Positon 35: INVOKE_FUNC Vt_Hresult AddPropertyChangedEventHandler([FIN] IUIAutomationElement*: element, [FIN] TreeScope: scope, [FIN] IUIAutomationCacheRequest*: cacheRequest, [FIN] IUIAutomationPropertyChangedEventHandler*: handler, [FIN] Safearray: propertyArray)
	AddPropertyChangedEventHandler(element, scope, cacheRequest, handler, propertyArray) {
		If (IsObject(element) and (ComObjType(element)=""))
			refelement:=element.__Value
		else
			refelement:=element
		If (IsObject(cacheRequest) and (ComObjType(cacheRequest)=""))
			refcacheRequest:=cacheRequest.__Value
		else
			refcacheRequest:=cacheRequest
		If (IsObject(handler) and (ComObjType(handler)=""))
			refhandler:=handler.__Value
		else
			refhandler:=handler
		If (ComObjValue(propertyArray) & 0x2000)
			refpropertyArray:=propertyArray
		else
		{
			refpropertyArray:=ComObject(0x2003, DllCall("oleaut32\SafeArrayCreateVector", "UInt", 13, "UInt", 0, "UInt", propertyArray.MaxIndex()),1)
			For ind, val in propertyArray
				refpropertyArray[A_Index-1]:= val.__Value, ObjAddRef(val.__Value)
		}
		res:=DllCall(this.__Vt(35), "Ptr", this.__Value, "Ptr", refelement, "UInt", scope, "Ptr", refcacheRequest, "Ptr", refhandler, "Ptr", ComObjValue(refpropertyArray), "Int")
		return res
	}

	; VTable Positon 36: INVOKE_FUNC Vt_Hresult RemovePropertyChangedEventHandler([FIN] IUIAutomationElement*: element, [FIN] IUIAutomationPropertyChangedEventHandler*: handler)
	RemovePropertyChangedEventHandler(element, handler) {
		If (IsObject(element) and (ComObjType(element)=""))
			refelement:=element.__Value
		else
			refelement:=element
		If (IsObject(handler) and (ComObjType(handler)=""))
			refhandler:=handler.__Value
		else
			refhandler:=handler
		res:=DllCall(this.__Vt(36), "Ptr", this.__Value, "Ptr", refelement, "Ptr", refhandler, "Int")
		return res
	}

	; VTable Positon 37: INVOKE_FUNC Vt_Hresult AddStructureChangedEventHandler([FIN] IUIAutomationElement*: element, [FIN] TreeScope: scope, [FIN] IUIAutomationCacheRequest*: cacheRequest, [FIN] IUIAutomationStructureChangedEventHandler*: handler)
	AddStructureChangedEventHandler(element, scope, cacheRequest, handler) {
		If (IsObject(element) and (ComObjType(element)=""))
			refelement:=element.__Value
		else
			refelement:=element
		If (IsObject(cacheRequest) and (ComObjType(cacheRequest)=""))
			refcacheRequest:=cacheRequest.__Value
		else
			refcacheRequest:=cacheRequest
		If (IsObject(handler) and (ComObjType(handler)=""))
			refhandler:=handler.__Value
		else
			refhandler:=handler
		res:=DllCall(this.__Vt(37), "Ptr", this.__Value, "Ptr", refelement, "UInt", scope, "Ptr", refcacheRequest, "Ptr", refhandler, "Int")
		return res
	}

	; VTable Positon 38: INVOKE_FUNC Vt_Hresult RemoveStructureChangedEventHandler([FIN] IUIAutomationElement*: element, [FIN] IUIAutomationStructureChangedEventHandler*: handler)
	RemoveStructureChangedEventHandler(element, handler) {
		If (IsObject(element) and (ComObjType(element)=""))
			refelement:=element.__Value
		else
			refelement:=element
		If (IsObject(handler) and (ComObjType(handler)=""))
			refhandler:=handler.__Value
		else
			refhandler:=handler
		res:=DllCall(this.__Vt(38), "Ptr", this.__Value, "Ptr", refelement, "Ptr", refhandler, "Int")
		return res
	}

	; VTable Positon 39: INVOKE_FUNC Vt_Hresult AddFocusChangedEventHandler([FIN] IUIAutomationCacheRequest*: cacheRequest, [FIN] IUIAutomationFocusChangedEventHandler*: handler)
	AddFocusChangedEventHandler(cacheRequest, handler) {
		If (IsObject(cacheRequest) and (ComObjType(cacheRequest)=""))
			refcacheRequest:=cacheRequest.__Value
		else
			refcacheRequest:=cacheRequest
		If (IsObject(handler) and (ComObjType(handler)=""))
			refhandler:=handler.__Value
		else
			refhandler:=handler
		res:=DllCall(this.__Vt(39), "Ptr", this.__Value, "Ptr", refcacheRequest, "Ptr", refhandler, "Int")
		return res
	}

	; VTable Positon 40: INVOKE_FUNC Vt_Hresult RemoveFocusChangedEventHandler([FIN] IUIAutomationFocusChangedEventHandler*: handler)
	RemoveFocusChangedEventHandler(handler) {
		If (IsObject(handler) and (ComObjType(handler)=""))
			refhandler:=handler.__Value
		else
			refhandler:=handler
		res:=DllCall(this.__Vt(40), "Ptr", this.__Value, "Ptr", refhandler, "Int")
		return res
	}

	; VTable Positon 41: INVOKE_FUNC Vt_Hresult RemoveAllEventHandlers()
	RemoveAllEventHandlers() 	{
		res:=DllCall(this.__Vt(41), "Ptr", this.__Value, "Int")
		return res
	}

	; VTable Positon 42: INVOKE_FUNC Vt_Hresult IntNativeArrayToSafeArray([FIN] Int*: array, [FIN] Int: arrayCount, [FOUT] [FRETVAL] Safearray*: safeArray)
	IntNativeArrayToSafeArray(array, arrayCount) {
		If (ComObjValue(safeArray) & 0x2000)
			refsafeArray:=safeArray
		else
		{
			refsafeArray:=ComObject(0x2003, DllCall("oleaut32\SafeArrayCreateVector", "UInt", 13, "UInt", 0, "UInt", safeArray.MaxIndex()),1)
			For ind, val in safeArray
				refsafeArray[A_Index-1]:= val.__Value, ObjAddRef(val.__Value)
		}
		res:=DllCall(this.__Vt(42), "Ptr", this.__Value, "Int*", array, "Int", arrayCount, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from IntNativeArrayToSafeArray in IUIAutomation")
		return out
	}

	; VTable Positon 43: INVOKE_FUNC Vt_Hresult IntSafeArrayToNativeArray([FIN] Safearray: intArray, [FOUT] Int**: array, [FOUT] [FRETVAL] Int*: arrayCount)
	IntSafeArrayToNativeArray(intArray, byref array) {
		If (ComObjValue(intArray) & 0x2000)
			refintArray:=intArray
		else
		{
			refintArray:=ComObject(0x2003, DllCall("oleaut32\SafeArrayCreateVector", "UInt", 13, "UInt", 0, "UInt", intArray.MaxIndex()),1)
			For ind, val in intArray
				refintArray[A_Index-1]:= val.__Value, ObjAddRef(val.__Value)
		}
		res:=DllCall(this.__Vt(43), "Ptr", this.__Value, "Ptr", ComObjValue(refintArray), "Ptr*", array, "Int*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from IntSafeArrayToNativeArray in IUIAutomation")
		return out
	}

	; VTable Positon 44: INVOKE_FUNC Vt_Hresult RectToVariant([FIN] tagRECT: rc, [FOUT] [FRETVAL] Variant*: var)
	RectToVariant(rc) {
		If (IsObject(rc) and (ComObjType(rc)=""))
			refrc:=rc.__Value
		else
			refrc:=&rc
		res:=DllCall(this.__Vt(44), "Ptr", this.__Value, "Ptr", refrc, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from RectToVariant in IUIAutomation")
		out:=ComObject(0x400C, out+0, flag)[]
		return out
	}

	; VTable Positon 45: INVOKE_FUNC Vt_Hresult VariantToRect([FIN] Variant: var, [FOUT] [FRETVAL] tagRECT*: rc)
	VariantToRect(var, varVariantType) {
		if (varVariantType!=12) ; var is not a variant
		{
			VarSetCapacity(refvar,8+2*A_PtrSize)
			variant_ref := ComObject(0x400C, &refvar)
			variant_ref[] := var
			NumPut(varVariantType, refvar, 0, "short")
		}
		else
			refvar:=var
		If (IsObject(rc) and (ComObjType(rc)=""))
			refrc:=rc.__Value
		else
			refrc:=&rc
		res:=DllCall(this.__Vt(45), "Ptr", this.__Value, "Ptr", &refvar, "Ptr", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from VariantToRect in IUIAutomation")
		return out
	}

	; VTable Positon 46: INVOKE_FUNC Vt_Hresult SafeArrayToRectNativeArray([FIN] Safearray: rects, [FOUT] tagRECT**: rectArray, [FOUT] [FRETVAL] Int*: rectArrayCount)
	SafeArrayToRectNativeArray(rects, byref rectArray) {
		If (ComObjValue(rects) & 0x2000)
			refrects:=rects
		else
		{
			refrects:=ComObject(0x2003, DllCall("oleaut32\SafeArrayCreateVector", "UInt", 13, "UInt", 0, "UInt", rects.MaxIndex()),1)
			For ind, val in rects
				refrects[A_Index-1]:= val.__Value, ObjAddRef(val.__Value)
		}
		res:=DllCall(this.__Vt(46), "Ptr", this.__Value, "Ptr", ComObjValue(refrects), "Ptr*", rectArray, "Int*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from SafeArrayToRectNativeArray in IUIAutomation")
		return out
	}

	; VTable Positon 47: INVOKE_FUNC Vt_Hresult CreateProxyFactoryEntry([FIN] IUIAutomationProxyFactory*: factory, [FOUT] [FRETVAL] IUIAutomationProxyFactoryEntry**: factoryEntry)
	CreateProxyFactoryEntry(factory) {
		If (IsObject(factory) and (ComObjType(factory)=""))
			reffactory:=factory.__Value
		else
			reffactory:=factory
		res:=DllCall(this.__Vt(47), "Ptr", this.__Value, "Ptr", reffactory, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from CreateProxyFactoryEntry in IUIAutomation")
		out:= new IUIAutomationProxyFactoryEntry(out)
		return out
	}

	; VTable Positon 49: INVOKE_FUNC Vt_Hresult GetPropertyProgrammaticName([FIN] Int: property, [FOUT] [FRETVAL] Bstr*: name)
	GetPropertyProgrammaticName(property) {
		res:=DllCall(this.__Vt(49), "Ptr", this.__Value, "Int", property, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetPropertyProgrammaticName in IUIAutomation")
		out:= StrGet(out)
		return out
	}

	; VTable Positon 50: INVOKE_FUNC Vt_Hresult GetPatternProgrammaticName([FIN] Int: pattern, [FOUT] [FRETVAL] Bstr*: name)
	GetPatternProgrammaticName(pattern) {
		res:=DllCall(this.__Vt(50), "Ptr", this.__Value, "Int", pattern, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from GetPatternProgrammaticName in IUIAutomation")
		out:= StrGet(out)
		return out
	}

	; VTable Positon 51: INVOKE_FUNC Vt_Hresult PollForPotentialSupportedPatterns([FIN] IUIAutomationElement*: pElement, [FOUT] Safearray*: patternIds, [FOUT] Safearray*: patternNames)
	PollForPotentialSupportedPatterns(pElement, byref patternIds, byref patternNames) {
		If (IsObject(pElement) and (ComObjType(pElement)=""))
			refpElement:=pElement.__Value
		else
			refpElement:=pElement
		If (ComObjValue(patternIds) & 0x2000)
			refpatternIds:=patternIds
		else
		{
			refpatternIds:=ComObject(0x2003, DllCall("oleaut32\SafeArrayCreateVector", "UInt", 13, "UInt", 0, "UInt", patternIds.MaxIndex()),1)
			For ind, val in patternIds
				refpatternIds[A_Index-1]:= val.__Value, ObjAddRef(val.__Value)
		}
		If (ComObjValue(patternNames) & 0x2000)
			refpatternNames:=patternNames
		else
		{
			refpatternNames:=ComObject(0x2003, DllCall("oleaut32\SafeArrayCreateVector", "UInt", 13, "UInt", 0, "UInt", patternNames.MaxIndex()),1)
			For ind, val in patternNames
				refpatternNames[A_Index-1]:= val.__Value, ObjAddRef(val.__Value)
		}
		res:=DllCall(this.__Vt(51), "Ptr", this.__Value, "Ptr", refpElement, "Ptr*", ComObjValue(refpatternIds), "Ptr*", ComObjValue(refpatternNames), "Int")
		return res
	}

	; VTable Positon 52: INVOKE_FUNC Vt_Hresult PollForPotentialSupportedProperties([FIN] IUIAutomationElement*: pElement, [FOUT] Safearray*: propertyIds, [FOUT] Safearray*: propertyNames)
	PollForPotentialSupportedProperties(pElement, byref propertyIds, byref propertyNames) {
		If (IsObject(pElement) and (ComObjType(pElement)=""))
			refpElement:=pElement.__Value
		else
			refpElement:=pElement
		If (ComObjValue(propertyIds) & 0x2000)
			refpropertyIds:=propertyIds
		else
		{
			refpropertyIds:=ComObject(0x2003, DllCall("oleaut32\SafeArrayCreateVector", "UInt", 13, "UInt", 0, "UInt", propertyIds.MaxIndex()),1)
			For ind, val in propertyIds
				refpropertyIds[A_Index-1]:= val.__Value, ObjAddRef(val.__Value)
		}
		If (ComObjValue(propertyNames) & 0x2000)
			refpropertyNames:=propertyNames
		else
		{
			refpropertyNames:=ComObject(0x2003, DllCall("oleaut32\SafeArrayCreateVector", "UInt", 13, "UInt", 0, "UInt", propertyNames.MaxIndex()),1)
			For ind, val in propertyNames
				refpropertyNames[A_Index-1]:= val.__Value, ObjAddRef(val.__Value)
		}
		res:=DllCall(this.__Vt(52), "Ptr", this.__Value, "Ptr", refpElement, "Ptr*", ComObjValue(refpropertyIds), "Ptr*", ComObjValue(refpropertyNames), "Int")
		return res
	}

	; VTable Positon 53: INVOKE_FUNC Vt_Hresult CheckNotSupported([FIN] Variant: value, [FOUT] [FRETVAL] I4*: isNotSupported)
	CheckNotSupported(value, valueVariantType) {
		if (valueVariantType!=12) ; value is not a variant
		{
			VarSetCapacity(refvalue,8+2*A_PtrSize)
			variant_ref := ComObject(0x400C, &refvalue)
			variant_ref[] := value
			NumPut(valueVariantType, refvalue, 0, "short")
		}
		else
			refvalue:=value
		res:=DllCall(this.__Vt(53), "Ptr", this.__Value, "Ptr", &refvalue, "Int*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from CheckNotSupported in IUIAutomation")
		return out
	}

	; VTable Positon 56: INVOKE_FUNC Vt_Hresult ElementFromIAccessible([FIN] IAccessible*: accessible, [FIN] Int: childId, [FOUT] [FRETVAL] IUIAutomationElement**: element)
	ElementFromIAccessible(accessible, childId) {
		If (IsObject(accessible) and (ComObjType(accessible)=""))
			refaccessible:=accessible.__Value
		else
			refaccessible:=accessible
		res:=DllCall(this.__Vt(56), "Ptr", this.__Value, "Ptr", refaccessible, "Int", childId, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from ElementFromIAccessible in IUIAutomation")
		out:= new IUIAutomationElement(out)
		return out
	}

	; VTable Positon 57: INVOKE_FUNC Vt_Hresult ElementFromIAccessibleBuildCache([FIN] IAccessible*: accessible, [FIN] Int: childId, [FIN] IUIAutomationCacheRequest*: cacheRequest, [FOUT] [FRETVAL] IUIAutomationElement**: element)
	ElementFromIAccessibleBuildCache(accessible, childId, cacheRequest) {
		If (IsObject(accessible) and (ComObjType(accessible)=""))
			refaccessible:=accessible.__Value
		else
			refaccessible:=accessible
		If (IsObject(cacheRequest) and (ComObjType(cacheRequest)=""))
			refcacheRequest:=cacheRequest.__Value
		else
			refcacheRequest:=cacheRequest
		res:=DllCall(this.__Vt(57), "Ptr", this.__Value, "Ptr", refaccessible, "Int", childId, "Ptr", refcacheRequest, "Ptr*", out, "Int")
		If (res<0 and res<>"")
			Throw Exception("COM HResult: 0x" Format("{:x}", res & 0xFFFFFFFF) " from ElementFromIAccessibleBuildCache in IUIAutomation")
		out:= new IUIAutomationElement(out)
		return out
	}

	; Property: ContentViewCondition; VTable PositonGet: 19; output : IUIAutomationCondition**: condition
	ContentViewCondition[]
	{
		get {
			If !DllCall(this.__Vt(19), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationCondition(out)
				return out
			}
		}
	}
	; Property: ContentViewWalker; VTable PositonGet: 15; output : IUIAutomationTreeWalker**: walker
	ContentViewWalker[]
	{
		get {
			If !DllCall(this.__Vt(15), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationTreeWalker(out)
				return out
			}
		}
	}
	; Property: ControlViewCondition; VTable PositonGet: 18; output : IUIAutomationCondition**: condition
	ControlViewCondition[]
	{
		get {
			If !DllCall(this.__Vt(18), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationCondition(out)
				return out
			}
		}
	}
	; Property: ControlViewWalker; VTable PositonGet: 14; output : IUIAutomationTreeWalker**: walker
	ControlViewWalker[]
	{
		get {
			If !DllCall(this.__Vt(14), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationTreeWalker(out)
				return out
			}
		}
	}
	; Property: ProxyFactoryMapping; VTable PositonGet: 48; output : IUIAutomationProxyFactoryMapping**: factoryMapping
	ProxyFactoryMapping[]
	{
		get {
			If !DllCall(this.__Vt(48), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationProxyFactoryMapping(out)
				return out
			}
		}
	}
	; Property: RawViewCondition; VTable PositonGet: 17; output : IUIAutomationCondition**: condition
	RawViewCondition[]
	{
		get {
			If !DllCall(this.__Vt(17), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationCondition(out)
				return out
			}
		}
	}
	; Property: RawViewWalker; VTable PositonGet: 16; output : IUIAutomationTreeWalker**: walker
	RawViewWalker[]
	{
		get {
			If !DllCall(this.__Vt(16), "Ptr", this.__Value, "Ptr*",out)
			{
				out:= new IUIAutomationTreeWalker(out)
				return out
			}
		}
	}
	; Property: ReservedMixedAttributeValue; VTable PositonGet: 55; output : Vt_Unknown*: mixedAttributeValue
	ReservedMixedAttributeValue[]
	{
		get {
			If !DllCall(this.__Vt(55), "Ptr", this.__Value, "Ptr*",out)
			{
				return out
			}
		}
	}
	; Property: ReservedNotSupportedValue; VTable PositonGet: 54; output : Vt_Unknown*: notSupportedValue
	ReservedNotSupportedValue[]
	{
		get {
			If !DllCall(this.__Vt(54), "Ptr", this.__Value, "Ptr*",out)
			{
				return out
			}
		}
	}
}

; *************************************************************************
; IUIAutomation2
; GUID: {34723AFF-0C9D-49D0-9896-7AB52DF8CD8A}
; *************************************************************************


class IUIAutomation2 extends IUIAutomation
{
	; Interface functions

	; Property: AutoSetFocus; VTable PositonGet: 58; output : Vt_I4*: AutoSetFocus; VTable PositonPut: 59; input : Vt_I4: AutoSetFocus
	AutoSetFocus[]
	{
		get {
			If !DllCall(this.__Vt(58), "Ptr", this.__Value, "Int*",out)
			{
				return out
			}
		}
		set {
			If !DllCall(this.__Vt(59), "Ptr", this.__Value, "Int", value)
				return value
		}
	}
	; Property: ConnectionTimeout; VTable PositonGet: 60; output : Vt_Ui4*: timeout; VTable PositonPut: 61; input : Vt_Ui4: timeout
	ConnectionTimeout[]
	{
		get {
			If !DllCall(this.__Vt(60), "Ptr", this.__Value, "UInt*",out)
			{
				return out
			}
		}
		set {
			If !DllCall(this.__Vt(61), "Ptr", this.__Value, "UInt", value)
				return value
		}
	}
	; Property: TransactionTimeout; VTable PositonGet: 62; output : Vt_Ui4*: timeout; VTable PositonPut: 63; input : Vt_Ui4: timeout
	TransactionTimeout[]
	{
		get {
			If !DllCall(this.__Vt(62), "Ptr", this.__Value, "UInt*",out)
			{
				return out
			}
		}
		set {
			If !DllCall(this.__Vt(63), "Ptr", this.__Value, "UInt", value)
				return value
		}
	}
}

; *************************************************************************
; IUIAutomation3
; GUID: {73D768DA-9B51-4B89-936E-C209290973E7}
; *************************************************************************


class IUIAutomation3 extends IUIAutomation2
{
	; Interface functions

	; VTable Positon 64: INVOKE_FUNC Vt_Hresult AddTextEditTextChangedEventHandler([FIN] IUIAutomationElement*: element, [FIN] TreeScope: scope, [FIN] TextEditChangeType: TextEditChangeType, [FIN] IUIAutomationCacheRequest*: cacheRequest, [FIN] IUIAutomationTextEditTextChangedEventHandler*: handler)
	AddTextEditTextChangedEventHandler(element, scope, TextEditChangeType, cacheRequest, handler)
	{
		If (IsObject(element) and (ComObjType(element)=""))
			refelement:=element.__Value
		else
			refelement:=element
		If (IsObject(cacheRequest) and (ComObjType(cacheRequest)=""))
			refcacheRequest:=cacheRequest.__Value
		else
			refcacheRequest:=cacheRequest
		If (IsObject(handler) and (ComObjType(handler)=""))
			refhandler:=handler.__Value
		else
			refhandler:=handler
		res:=DllCall(this.__Vt(64), "Ptr", this.__Value, "Ptr", refelement, "UInt", scope, "UInt", TextEditChangeType, "Ptr", refcacheRequest, "Ptr", refhandler, "Int")
		return res
	}

	; VTable Positon 65: INVOKE_FUNC Vt_Hresult RemoveTextEditTextChangedEventHandler([FIN] IUIAutomationElement*: element, [FIN] IUIAutomationTextEditTextChangedEventHandler*: handler)
	RemoveTextEditTextChangedEventHandler(element, handler)
	{
		If (IsObject(element) and (ComObjType(element)=""))
			refelement:=element.__Value
		else
			refelement:=element
		If (IsObject(handler) and (ComObjType(handler)=""))
			refhandler:=handler.__Value
		else
			refhandler:=handler
		res:=DllCall(this.__Vt(65), "Ptr", this.__Value, "Ptr", refelement, "Ptr", refhandler, "Int")
		return res
	}

}

; *************************************************************************
; IUIAutomation4
; GUID: {1189C02A-05F8-4319-8E21-E817E3DB2860}
; *************************************************************************


class IUIAutomation4 extends IUIAutomation3
{
	; Interface functions

	; VTable Positon 66: INVOKE_FUNC Vt_Hresult AddChangesEventHandler([FIN] IUIAutomationElement*: element, [FIN] TreeScope: scope, [FIN] Int*: changeTypes, [FIN] Int: changesCount, [FIN] IUIAutomationCacheRequest*: pCacheRequest, [FIN] IUIAutomationChangesEventHandler*: handler)
	AddChangesEventHandler(element, scope, changeTypes, changesCount, pCacheRequest, handler)
	{
		If (IsObject(element) and (ComObjType(element)=""))
			refelement:=element.__Value
		else
			refelement:=element
		If (IsObject(pCacheRequest) and (ComObjType(pCacheRequest)=""))
			refpCacheRequest:=pCacheRequest.__Value
		else
			refpCacheRequest:=pCacheRequest
		If (IsObject(handler) and (ComObjType(handler)=""))
			refhandler:=handler.__Value
		else
			refhandler:=handler
		res:=DllCall(this.__Vt(66), "Ptr", this.__Value, "Ptr", refelement, "UInt", scope, "Int*", changeTypes, "Int", changesCount, "Ptr", refpCacheRequest, "Ptr", refhandler, "Int")
		return res
	}

	; VTable Positon 67: INVOKE_FUNC Vt_Hresult RemoveChangesEventHandler([FIN] IUIAutomationElement*: element, [FIN] IUIAutomationChangesEventHandler*: handler)
	RemoveChangesEventHandler(element, handler)
	{
		If (IsObject(element) and (ComObjType(element)=""))
			refelement:=element.__Value
		else
			refelement:=element
		If (IsObject(handler) and (ComObjType(handler)=""))
			refhandler:=handler.__Value
		else
			refhandler:=handler
		res:=DllCall(this.__Vt(67), "Ptr", this.__Value, "Ptr", refelement, "Ptr", refhandler, "Int")
		return res
	}

}

; *************************************************************************
; *************************************************************************
; DISPATCH
; *************************************************************************
; *************************************************************************

; *************************************************************************
; IAccessible
; *************************************************************************

/*
GUID: {618736E0-3C3D-11CF-810C-00AA00389B71}

VTable Positon: 7:
INVOKE_PROPERTYGET Dispatch accParent()

VTable Positon: 8:
INVOKE_PROPERTYGET I4 accChildCount()

VTable Positon: 9:
INVOKE_PROPERTYGET Dispatch accChild([FIN] Variant: varChild)

VTable Positon: 10:
INVOKE_PROPERTYGET Bstr accName([FIN] [FOPT] Variant: varChild)

VTable Positon: 11:
INVOKE_PROPERTYGET Bstr accValue([FIN] [FOPT] Variant: varChild)

VTable Positon: 12:
INVOKE_PROPERTYGET Bstr accDescription([FIN] [FOPT] Variant: varChild)

VTable Positon: 13:
INVOKE_PROPERTYGET Variant accRole([FIN] [FOPT] Variant: varChild)

VTable Positon: 14:
INVOKE_PROPERTYGET Variant accState([FIN] [FOPT] Variant: varChild)

VTable Positon: 15:
INVOKE_PROPERTYGET Bstr accHelp([FIN] [FOPT] Variant: varChild)

VTable Positon: 16:
INVOKE_PROPERTYGET I4 accHelpTopic([FOUT] Bstr*: pszHelpFile, [FIN] [FOPT] Variant: varChild)

VTable Positon: 17:
INVOKE_PROPERTYGET Bstr accKeyboardShortcut([FIN] [FOPT] Variant: varChild)

VTable Positon: 18:
INVOKE_PROPERTYGET Variant accFocus()

VTable Positon: 19:
INVOKE_PROPERTYGET Variant accSelection()

VTable Positon: 20:
INVOKE_PROPERTYGET Bstr accDefaultAction([FIN] [FOPT] Variant: varChild)

VTable Positon: 21:
INVOKE_FUNC Void accSelect([FIN] I4: flagsSelect, [FIN] [FOPT] Variant: varChild)

VTable Positon: 22:
INVOKE_FUNC Void accLocation([FOUT] I4*: pxLeft, [FOUT] I4*: pyTop, [FOUT] I4*: pcxWidth, [FOUT] I4*: pcyHeight, [FIN] [FOPT] Variant: varChild)

VTable Positon: 23:
INVOKE_FUNC Variant accNavigate([FIN] I4: navDir, [FIN] [FOPT] Variant: varStart)

VTable Positon: 24:
INVOKE_FUNC Variant accHitTest([FIN] I4: xLeft, [FIN] I4: yTop)

VTable Positon: 25:
INVOKE_FUNC Void accDoDefaultAction([FIN] [FOPT] Variant: varChild)

VTable Positon: 26:
INVOKE_PROPERTYPUT Void accName([FIN] [FOPT] Variant: varChild, [FIN] Bstr: )

VTable Positon: 27:
INVOKE_PROPERTYPUT Void accValue([FIN] [FOPT] Variant: varChild, [FIN] Bstr: )

Implements: IDispatch
Flags:
*/


class Heap {
	ProcessHeap {
		get {
			static heap := DllCall("GetProcessHeap", "Ptr")
			return heap
		}
	}
	Allocate(bytes) {
		static HEAP_GENERATE_EXCEPTIONS := 0x00000004, HEAP_ZERO_MEMORY := 0x00000008
		return DllCall("HeapAlloc", "Ptr", Heap.ProcessHeap, "UInt", HEAP_GENERATE_EXCEPTIONS|HEAP_ZERO_MEMORY, "UInt", bytes, "UPtr")
	}
	GetSize(buffer) {
		return DllCall("HeapSize", "Ptr", Heap.ProcessHeap, "UInt", 0, "Ptr", buffer, "Ptr" )
	}
	Release(buffer) {

		return DllCall("HeapFree", "Ptr", Heap.ProcessHeap, "UInt", 0, "Ptr", buffer, "Int")
	}
}

StringFromCLSID(riid) {
	res := DllCall("ole32\StringFromCLSID", "Ptr", riid, "PtrP", pStrCLSID := 0)
	sCLSID := StrGet(pStrCLSID, "UTF-16")
	DllCall("ole32\CoTaskMemFree", "Ptr", pStrCLSID)
	return sCLSID
}

global 	VT 		:= 0
	   ,REFS 	:= 1

/**
 *	Base implementation for all Com Objects
 *		- Handles creation of static vTable
 *		- Registers new class instance with vtoMap for efficient memory management of vTable use
 *		- Creates global pObject pointer for use with COM
 *
 *	 NOTE - Tested that:
 *		- this.vTable and this.vtoMap accesses the static declaration in the top level class declaration
 */
class ComObjImpl {

	; Pointers to vTables by this.IID
	static vTables := { }
	; Map of Interface Pointers to Object by this.IID
	static ObjMap := { }

	; Array of string GUID Com Interfaces that this object implements
	ImplementsInterfaces := []

	; Array of Com Functions that are implemented in the class hierarchy
	ComFunctions := []

	__New() {
		; Using the last Interface in the implementation array, this *should* be the highest IID in the chain
		this.IID := this.ImplementsInterfaces[this.ImplementsInterfaces.Length()]

		this.PopulateVirtualMethodTable()

		this.pInterface := Heap.Allocate(A_PtrSize + 4)
		ComObjImpl.ObjMap[this.pInterface] := this
		ObjRelease(&this)	; Release the reference just created, this reference will be free'd when __Delete is actually called

		NumPut(ComObjImpl.vTables[this.IID][VT], this.pInterface, 0, "Ptr")
		ComObjImpl.vTables[this.IID][REFS] += 1

		Refs := this._AddRef(this.pInterface)	; Adding our own reference, on delete should be 0
	}

	/**
	 *	Populates the static this.vTable with the callback points
	 *		NOTE: vTable is being passed in ByRef because it would seem using this.vTable with
	 *		VarSetCapacity/NumPut does not function correctly, using them on a ByRef of it works
	 *		just fine.
	 */
	PopulateVirtualMethodTable() {
		if (!ComObjImpl.vTables[this.IID]) {
			; Allocate a Ptr record for each method in ComFunctions
			ComObjImpl.vTables[this.IID, VT] := Heap.Allocate(this.ComFunctions.Length() * A_PtrSize)
			ComObjImpl.vTables[this.IID, REFS] := 0

			for i, func in this.ComFunctions {
				callback := RegisterCallback(this["_" func].Name)

				NumPut(callback, ComObjImpl.vTables[this.IID][VT], (i-1) * A_PtrSize)
			}
		}
	}

	__Delete() {
		ComObjImpl.ObjMap[this.pInterface] :=
		ComObjImpl.vTables[this.IID][REFS] -= 1

		Heap.Release(this.pInterface)

		if (ComObjImpl.vTables[this.IID][REFS] == 0) {
			Heap.Release(ComObjImpl.vTables[this.IID][VT])
			ComObjImpl.vTables[this.IID] :=
		}
	}
}

class IUnknownImpl extends ComObjImpl {
	; Declare the functions our class is implementing (expected to be over-ridden by sub-classes)
	; This array should be complete for the interface and in the correct vTable order per the Type Library
	ComFunctions := ["QueryInterface", "AddRef", "Release"]

	__New() {
		; Add the GUID of the interface this class is implementing
		this.ImplementsInterfaces.InsertAt(1, "{00000000-0000-0000-C000-000000000046}")		; IUnknown
		base.__New()
	}
	/**
	 *	Implementation of IUnknown::QueryInterface
	 *		Each class level that implements some part of the final vTable should have its interface GUID
	 *		declared in this.ImplementsInterface array
	 */
	_QueryInterface(pInterface, riid, ppvObject) {
		if (!IsObject(this))
			return ComObjImpl.ObjMap[this]._QueryInterface(this, pInterface, riid)

		sCLSID := StringFromCLSID(riid)

		for i, sIID in this.ImplementsInterfaces {
			if (sCLSID == sIID) {
				NumPut(pInterface, ppvObject+0, "Ptr")

				this._AddRef(pInterface)
				return 0 ; S_OK
			}
		}

		NumPut(pInterface, ppvObject+0, "Ptr")
		return -2147467262 ; 0x80004002 0xFFFFFFFF80004002 E_NOINTERFACE
	}

	; Implementation of IUnknown::AddRef
	_AddRef(pInterface) {
		if (!IsObject(this))
			return ComObjImpl.ObjMap[this]._AddRef(this)

		NumPut((RefCount := NumGet(pInterface+0, A_PtrSize, "UInt") + 1), pInterface+0, A_PtrSize, "UInt")

		return RefCount
	}

	; Implementation of IUnknown::Release
	_Release(pInterface) {
		if (!IsObject(this))
			return ComObjImpl.ObjMap[this]._Release(this)

		if ((RefCount := this.GetRefs()) > 0) {
			RefCount -= 1
			NumPut(RefCount, pInterface+0, A_PtrSize, "UInt")
		}

		return RefCount
	}

	GetRefs() {
		return NumGet(this.pInterface+0, A_PtrSize, "UInt")
	}

	__Delete() {
		if ( (RefCount := this.GetRefs()) != 1)
			OutputDebug % Format("WARNING: RefCount={} in {}, should be 1 (our own reference)", RefCount, A_ThisFunc "()")
		base.__Delete()
	}
}

