; UIA Constants, credit to LarsJ from https://www.autoitscript.com/forum/topic/201683-ui-automation-udfs/
; Variant types for Property Ids: https://docs.microsoft.com/en-us/windows/win32/winauto/uiauto-automation-element-propids

global sCLSID_UIAutomationClient := "{944DE083-8FB8-45CF-BCB7-C477ACB2F897}"

;CoClasses
 , sCLSID_CUIAutomation := "{FF48DBA4-60EF-4201-AA87-54103EEF594E}"
;module UIA_PatternIds
global UIA_InvokePatternId := 10000
 , UIA_SelectionPatternId := 10001
 , UIA_ValuePatternId := 10002
 , UIA_RangeValuePatternId := 10003
 , UIA_ScrollPatternId := 10004
 , UIA_ExpandCollapsePatternId := 10005
 , UIA_GridPatternId := 10006
 , UIA_GridItemPatternId := 10007
 , UIA_MultipleViewPatternId := 10008
 , UIA_WindowPatternId := 10009
 , UIA_SelectionItemPatternId := 10010
 , UIA_DockPatternId := 10011
 , UIA_TablePatternId := 10012
 , UIA_TableItemPatternId := 10013
 , UIA_TextPatternId := 10014
 , UIA_TogglePatternId := 10015
 , UIA_TransformPatternId := 10016
 , UIA_ScrollItemPatternId := 10017
 , UIA_LegacyIAccessiblePatternId := 10018
 , UIA_ItemContainerPatternId := 10019
 , UIA_VirtualizedItemPatternId := 10020
 , UIA_SynchronizedInputPatternId := 10021
 , UIA_ObjectModelPatternId := 10022
 , UIA_AnnotationPatternId := 10023
 , UIA_TextPattern2Id := 10024
 , UIA_StylesPatternId := 10025
 , UIA_SpreadsheetPatternId := 10026
 , UIA_SpreadsheetItemPatternId := 10027
 , UIA_TransformPattern2Id := 10028
 , UIA_TextChildPatternId := 10029
 , UIA_DragPatternId := 10030
 , UIA_DropTargetPatternId := 10031
 , UIA_TextEditPatternId := 10032
 , UIA_CustomNavigationPatternId := 10033
 , UIA_SelectionPattern2Id := 10034 

;module UIA_EventIds
global UIA_ToolTipOpenedEventId := 20000
 , UIA_ToolTipClosedEventId := 20001
 , UIA_StructureChangedEventId := 20002
 , UIA_MenuOpenedEventId := 20003
 , UIA_AutomationPropertyChangedEventId := 20004
 , UIA_AutomationFocusChangedEventId := 20005
 , UIA_AsyncContentLoadedEventId := 20006
 , UIA_MenuClosedEventId := 20007
 , UIA_LayoutInvalidatedEventId := 20008
 , UIA_Invoke_InvokedEventId := 20009
 , UIA_SelectionItem_ElementAddedToSelectionEventId := 20010
 , UIA_SelectionItem_ElementRemovedFromSelectionEventId := 20011
 , UIA_SelectionItem_ElementSelectedEventId := 20012
 , UIA_Selection_InvalidatedEventId := 20013
 , UIA_Text_TextSelectionChangedEventId := 20014
 , UIA_Text_TextChangedEventId := 20015
 , UIA_Window_WindowOpenedEventId := 20016
 , UIA_Window_WindowClosedEventId := 20017
 , UIA_MenuModeStartEventId := 20018
 , UIA_MenuModeEndEventId := 20019
 , UIA_InputReachedTargetEventId := 20020
 , UIA_InputReachedOtherElementEventId := 20021
 , UIA_InputDiscardedEventId := 20022
 , UIA_SystemAlertEventId := 20023
 , UIA_LiveRegionChangedEventId := 20024
 , UIA_HostedFragmentRootsInvalidatedEventId := 20025
 , UIA_Drag_DragStartEventId := 20026
 , UIA_Drag_DragCancelEventId := 20027
 , UIA_Drag_DragCompleteEventId := 20028
 , UIA_DropTarget_DragEnterEventId := 20029
 , UIA_DropTarget_DragLeaveEventId := 20030
 , UIA_DropTarget_DroppedEventId := 20031
 , UIA_TextEdit_TextChangedEventId := 20032
 , UIA_TextEdit_ConversionTargetChangedEventId := 20033
 , UIA_ChangesEventId := 20034
 , UIA_NotificationEventId := 20035
 , UIA_ActiveTextPositionChangedEventId := 20036

;module UIA_PropertyIds
global UIA_RuntimeIdPropertyId := 30000
 , UIA_BoundingRectanglePropertyId := 30001
 , UIA_ProcessIdPropertyId := 30002
 , UIA_ControlTypePropertyId := 30003
 , UIA_LocalizedControlTypePropertyId := 30004
 , UIA_NamePropertyId := 30005
 , UIA_AcceleratorKeyPropertyId := 30006
 , UIA_AccessKeyPropertyId := 30007
 , UIA_HasKeyboardFocusPropertyId := 30008
 , UIA_IsKeyboardFocusablePropertyId := 30009
 , UIA_IsEnabledPropertyId := 30010
 , UIA_AutomationIdPropertyId := 30011
 , UIA_ClassNamePropertyId := 30012
 , UIA_HelpTextPropertyId := 30013
 , UIA_ClickablePointPropertyId := 30014
 , UIA_CulturePropertyId := 30015
 , UIA_IsControlElementPropertyId := 30016
 , UIA_IsContentElementPropertyId := 30017
 , UIA_LabeledByPropertyId := 30018
 , UIA_IsPasswordPropertyId := 30019
 , UIA_NativeWindowHandlePropertyId := 30020
 , UIA_ItemTypePropertyId := 30021
 , UIA_IsOffscreenPropertyId := 30022
 , UIA_OrientationPropertyId := 30023
 , UIA_FrameworkIdPropertyId := 30024
 , UIA_IsRequiredForFormPropertyId := 30025
 , UIA_ItemStatusPropertyId := 30026
 , UIA_IsDockPatternAvailablePropertyId := 30027
 , UIA_IsExpandCollapsePatternAvailablePropertyId := 30028
 , UIA_IsGridItemPatternAvailablePropertyId := 30029
 , UIA_IsGridPatternAvailablePropertyId := 30030
 , UIA_IsInvokePatternAvailablePropertyId := 30031
 , UIA_IsMultipleViewPatternAvailablePropertyId := 30032
 , UIA_IsRangeValuePatternAvailablePropertyId := 30033
 , UIA_IsScrollPatternAvailablePropertyId := 30034
 , UIA_IsScrollItemPatternAvailablePropertyId := 30035
 , UIA_IsSelectionItemPatternAvailablePropertyId := 30036
 , UIA_IsSelectionPatternAvailablePropertyId := 30037
 , UIA_IsTablePatternAvailablePropertyId := 30038
 , UIA_IsTableItemPatternAvailablePropertyId := 30039
 , UIA_IsTextPatternAvailablePropertyId := 30040
 , UIA_IsTogglePatternAvailablePropertyId := 30041
 , UIA_IsTransformPatternAvailablePropertyId := 30042
 , UIA_IsValuePatternAvailablePropertyId := 30043
 , UIA_IsWindowPatternAvailablePropertyId := 30044
 , UIA_ValueValuePropertyId := 30045
 , UIA_ValueIsReadOnlyPropertyId := 30046
 , UIA_RangeValueValuePropertyId := 30047
 , UIA_RangeValueIsReadOnlyPropertyId := 30048
 , UIA_RangeValueMinimumPropertyId := 30049
 , UIA_RangeValueMaximumPropertyId := 30050
 , UIA_RangeValueLargeChangePropertyId := 30051
 , UIA_RangeValueSmallChangePropertyId := 30052
 , UIA_ScrollHorizontalScrollPercentPropertyId := 30053
 , UIA_ScrollHorizontalViewSizePropertyId := 30054
 , UIA_ScrollVerticalScrollPercentPropertyId := 30055
 , UIA_ScrollVerticalViewSizePropertyId := 30056
 , UIA_ScrollHorizontallyScrollablePropertyId := 30057
 , UIA_ScrollVerticallyScrollablePropertyId := 30058
 , UIA_SelectionSelectionPropertyId := 30059
 , UIA_SelectionCanSelectMultiplePropertyId := 30060
 , UIA_SelectionIsSelectionRequiredPropertyId := 30061
 , UIA_GridRowCountPropertyId := 30062
 , UIA_GridColumnCountPropertyId := 30063
 , UIA_GridItemRowPropertyId := 30064
 , UIA_GridItemColumnPropertyId := 30065
 , UIA_GridItemRowSpanPropertyId := 30066
 , UIA_GridItemColumnSpanPropertyId := 30067
 , UIA_GridItemContainingGridPropertyId := 30068
 , UIA_DockDockPositionPropertyId := 30069
 , UIA_ExpandCollapseExpandCollapseStatePropertyId := 30070
 , UIA_MultipleViewCurrentViewPropertyId := 30071
 , UIA_MultipleViewSupportedViewsPropertyId := 30072
 , UIA_WindowCanMaximizePropertyId := 30073
 , UIA_WindowCanMinimizePropertyId := 30074
 , UIA_WindowWindowVisualStatePropertyId := 30075
 , UIA_WindowWindowInteractionStatePropertyId := 30076
 , UIA_WindowIsModalPropertyId := 30077
 , UIA_WindowIsTopmostPropertyId := 30078
 , UIA_SelectionItemIsSelectedPropertyId := 30079
 , UIA_SelectionItemSelectionContainerPropertyId := 30080
 , UIA_TableRowHeadersPropertyId := 30081
 , UIA_TableColumnHeadersPropertyId := 30082
 , UIA_TableRowOrColumnMajorPropertyId := 30083
 , UIA_TableItemRowHeaderItemsPropertyId := 30084
 , UIA_TableItemColumnHeaderItemsPropertyId := 30085
 , UIA_ToggleToggleStatePropertyId := 30086
 , UIA_TransformCanMovePropertyId := 30087
 , UIA_TransformCanResizePropertyId := 30088
 , UIA_TransformCanRotatePropertyId := 30089
 , UIA_IsLegacyIAccessiblePatternAvailablePropertyId := 30090
 , UIA_LegacyIAccessibleChildIdPropertyId := 30091
 , UIA_LegacyIAccessibleNamePropertyId := 30092
 , UIA_LegacyIAccessibleValuePropertyId := 30093
 , UIA_LegacyIAccessibleDescriptionPropertyId := 30094
 , UIA_LegacyIAccessibleRolePropertyId := 30095
 , UIA_LegacyIAccessibleStatePropertyId := 30096
 , UIA_LegacyIAccessibleHelpPropertyId := 30097
 , UIA_LegacyIAccessibleKeyboardShortcutPropertyId := 30098
 , UIA_LegacyIAccessibleSelectionPropertyId := 30099
 , UIA_LegacyIAccessibleDefaultActionPropertyId := 30100
 , UIA_AriaRolePropertyId := 30101
 , UIA_AriaPropertiesPropertyId := 30102
 , UIA_IsDataValidForFormPropertyId := 30103
 , UIA_ControllerForPropertyId := 30104
 , UIA_DescribedByPropertyId := 30105
 , UIA_FlowsToPropertyId := 30106
 , UIA_ProviderDescriptionPropertyId := 30107
 , UIA_IsItemContainerPatternAvailablePropertyId := 30108
 , UIA_IsVirtualizedItemPatternAvailablePropertyId := 30109
 , UIA_IsSynchronizedInputPatternAvailablePropertyId := 30110
 , UIA_OptimizeForVisualContentPropertyId := 30111
 , UIA_IsObjectModelPatternAvailablePropertyId := 30112
 , UIA_AnnotationAnnotationTypeIdPropertyId := 30113
 , UIA_AnnotationAnnotationTypeNamePropertyId := 30114
 , UIA_AnnotationAuthorPropertyId := 30115
 , UIA_AnnotationDateTimePropertyId := 30116
 , UIA_AnnotationTargetPropertyId := 30117
 , UIA_IsAnnotationPatternAvailablePropertyId := 30118
 , UIA_IsTextPattern2AvailablePropertyId := 30119
 , UIA_StylesStyleIdPropertyId := 30120
 , UIA_StylesStyleNamePropertyId := 30121
 , UIA_StylesFillColorPropertyId := 30122
 , UIA_StylesFillPatternStylePropertyId := 30123
 , UIA_StylesShapePropertyId := 30124
 , UIA_StylesFillPatternColorPropertyId := 30125
 , UIA_StylesExtendedPropertiesPropertyId := 30126
 , UIA_IsStylesPatternAvailablePropertyId := 30127
 , UIA_IsSpreadsheetPatternAvailablePropertyId := 30128
 , UIA_SpreadsheetItemFormulaPropertyId := 30129
 , UIA_SpreadsheetItemAnnotationObjectsPropertyId := 30130
 , UIA_SpreadsheetItemAnnotationTypesPropertyId := 30131
 , UIA_IsSpreadsheetItemPatternAvailablePropertyId := 30132
 , UIA_Transform2CanZoomPropertyId := 30133
 , UIA_IsTransformPattern2AvailablePropertyId := 30134
 , UIA_LiveSettingPropertyId := 30135
 , UIA_IsTextChildPatternAvailablePropertyId := 30136
 , UIA_IsDragPatternAvailablePropertyId := 30137
 , UIA_DragIsGrabbedPropertyId := 30138
 , UIA_DragDropEffectPropertyId := 30139
 , UIA_DragDropEffectsPropertyId := 30140
 , UIA_IsDropTargetPatternAvailablePropertyId := 30141
 , UIA_DropTargetDropTargetEffectPropertyId := 30142
 , UIA_DropTargetDropTargetEffectsPropertyId := 30143
 , UIA_DragGrabbedItemsPropertyId := 30144
 , UIA_Transform2ZoomLevelPropertyId := 30145
 , UIA_Transform2ZoomMinimumPropertyId := 30146
 , UIA_Transform2ZoomMaximumPropertyId := 30147
 , UIA_FlowsFromPropertyId := 30148
 , UIA_IsTextEditPatternAvailablePropertyId := 30149
 , UIA_IsPeripheralPropertyId := 30150
 , UIA_IsCustomNavigationPatternAvailablePropertyId := 30151
 , UIA_PositionInSetPropertyId := 30152
 , UIA_SizeOfSetPropertyId := 30153
 , UIA_LevelPropertyId := 30154
 , UIA_AnnotationTypesPropertyId := 30155
 , UIA_AnnotationObjectsPropertyId := 30156
 , UIA_LandmarkTypePropertyId := 30157
 , UIA_LocalizedLandmarkTypePropertyId := 30158
 , UIA_FullDescriptionPropertyId := 30159
 , UIA_FillColorPropertyId := 30160
 , UIA_OutlineColorPropertyId := 30161
 , UIA_FillTypePropertyId := 30162
 , UIA_VisualEffectsPropertyId := 30163
 , UIA_OutlineThicknessPropertyId := 30164
 , UIA_CenterPointPropertyId := 30165
 , UIA_RotationPropertyId := 30166
 , UIA_SizePropertyId := 30167
 , UIA_IsSelectionPattern2AvailablePropertyId := 30168
 , UIA_Selection2FirstSelectedItemPropertyId := 30169
 , UIA_Selection2LastSelectedItemPropertyId := 30170
 , UIA_Selection2CurrentSelectedItemPropertyId := 30171
 , UIA_Selection2ItemCountPropertyId := 30172
 , UIA_HeadingLevelPropertyId := 30173
 , UIA_IsDialogPropertyId := 30174

;module UIA_TextAttributeIds
global UIA_AnimationStyleAttributeId := 40000
 , UIA_BackgroundColorAttributeId := 40001
 , UIA_BulletStyleAttributeId := 40002
 , UIA_CapStyleAttributeId := 40003
 , UIA_CultureAttributeId := 40004
 , UIA_FontNameAttributeId := 40005
 , UIA_FontSizeAttributeId := 40006
 , UIA_FontWeightAttributeId := 40007
 , UIA_ForegroundColorAttributeId := 40008
 , UIA_HorizontalTextAlignmentAttributeId := 40009
 , UIA_IndentationFirstLineAttributeId := 40010
 , UIA_IndentationLeadingAttributeId := 40011
 , UIA_IndentationTrailingAttributeId := 40012
 , UIA_IsHiddenAttributeId := 40013
 , UIA_IsItalicAttributeId := 40014
 , UIA_IsReadOnlyAttributeId := 40015
 , UIA_IsSubscriptAttributeId := 40016
 , UIA_IsSuperscriptAttributeId := 40017
 , UIA_MarginBottomAttributeId := 40018
 , UIA_MarginLeadingAttributeId := 40019
 , UIA_MarginTopAttributeId := 40020
 , UIA_MarginTrailingAttributeId := 40021
 , UIA_OutlineStylesAttributeId := 40022
 , UIA_OverlineColorAttributeId := 40023
 , UIA_OverlineStyleAttributeId := 40024
 , UIA_StrikethroughColorAttributeId := 40025
 , UIA_StrikethroughStyleAttributeId := 40026
 , UIA_TabsAttributeId := 40027
 , UIA_TextFlowDirectionsAttributeId := 40028
 , UIA_UnderlineColorAttributeId := 40029
 , UIA_UnderlineStyleAttributeId := 40030
 , UIA_AnnotationTypesAttributeId := 40031
 , UIA_AnnotationObjectsAttributeId := 40032
 , UIA_StyleNameAttributeId := 40033
 , UIA_StyleIdAttributeId := 40034
 , UIA_LinkAttributeId := 40035
 , UIA_IsActiveAttributeId := 40036
 , UIA_SelectionActiveEndAttributeId := 40037
 , UIA_CaretPositionAttributeId := 40038
 , UIA_CaretBidiModeAttributeId := 40039
 , UIA_LineSpacingAttributeId := 40040
 , UIA_BeforeParagraphSpacingAttributeId := 40041
 , UIA_AfterParagraphSpacingAttributeId := 40042
 , UIA_SayAsInterpretAsAttributeId := 40043

;module UIA_ControlTypeIds
global UIA_ButtonControlTypeId := 50000
 , UIA_CalendarControlTypeId := 50001
 , UIA_CheckBoxControlTypeId := 50002
 , UIA_ComboBoxControlTypeId := 50003
 , UIA_EditControlTypeId := 50004
 , UIA_HyperlinkControlTypeId := 50005
 , UIA_ImageControlTypeId := 50006
 , UIA_ListItemControlTypeId := 50007
 , UIA_ListControlTypeId := 50008
 , UIA_MenuControlTypeId := 50009
 , UIA_MenuBarControlTypeId := 50010
 , UIA_MenuItemControlTypeId := 50011
 , UIA_ProgressBarControlTypeId := 50012
 , UIA_RadioButtonControlTypeId := 50013
 , UIA_ScrollBarControlTypeId := 50014
 , UIA_SliderControlTypeId := 50015
 , UIA_SpinnerControlTypeId := 50016
 , UIA_StatusBarControlTypeId := 50017
 , UIA_TabControlTypeId := 50018
 , UIA_TabItemControlTypeId := 50019
 , UIA_TextControlTypeId := 50020
 , UIA_ToolBarControlTypeId := 50021
 , UIA_ToolTipControlTypeId := 50022
 , UIA_TreeControlTypeId := 50023
 , UIA_TreeItemControlTypeId := 50024
 , UIA_CustomControlTypeId := 50025
 , UIA_GroupControlTypeId := 50026
 , UIA_ThumbControlTypeId := 50027
 , UIA_DataGridControlTypeId := 50028
 , UIA_DataItemControlTypeId := 50029
 , UIA_DocumentControlTypeId := 50030
 , UIA_SplitButtonControlTypeId := 50031
 , UIA_WindowControlTypeId := 50032
 , UIA_PaneControlTypeId := 50033
 , UIA_HeaderControlTypeId := 50034
 , UIA_HeaderItemControlTypeId := 50035
 , UIA_TableControlTypeId := 50036
 , UIA_TitleBarControlTypeId := 50037
 , UIA_SeparatorControlTypeId := 50038
 , UIA_SemanticZoomControlTypeId := 50039
 , UIA_AppBarControlTypeId := 50040

; module AnnotationType
 , UIA_AnnotationType_Unknown := 60000
 , UIA_AnnotationType_SpellingError := 60001
 , UIA_AnnotationType_GrammarError := 60002
 , UIA_AnnotationType_Comment := 60003
 , UIA_AnnotationType_FormulaError := 60004
 , UIA_AnnotationType_TrackChanges := 60005
 , UIA_AnnotationType_Header := 60006
 , UIA_AnnotationType_Footer := 60007
 , UIA_AnnotationType_Highlighted := 60008
 , UIA_AnnotationType_Endnote := 60009
 , UIA_AnnotationType_Footnote := 60010
 , UIA_AnnotationType_InsertionChange := 60011
 , UIA_AnnotationType_DeletionChange := 60012
 , UIA_AnnotationType_MoveChange := 60013
 , UIA_AnnotationType_FormatChange := 60014
 , UIA_AnnotationType_UnsyncedChange := 60015
 , UIA_AnnotationType_EditingLockedChange := 60016
 , UIA_AnnotationType_ExternalChange := 60017
 , UIA_AnnotationType_ConflictingChange := 60018
 , UIA_AnnotationType_Author := 60019
 , UIA_AnnotationType_AdvancedProofingIssue := 60020
 , UIA_AnnotationType_DataValidationError := 60021
 , UIA_AnnotationType_CircularReferenceError := 60022
 , UIA_AnnotationType_Mathematics := 60023

;enum StyleId
 , UIA_StyleId_Custom := 70000
 , UIA_StyleId_Heading1 := 70001
 , UIA_StyleId_Heading2 := 70002
 , UIA_StyleId_Heading3 := 70003
 , UIA_StyleId_Heading4 := 70004
 , UIA_StyleId_Heading5 := 70005
 , UIA_StyleId_Heading6 := 70006
 , UIA_StyleId_Heading7 := 70007
 , UIA_StyleId_Heading8 := 70008
 , UIA_StyleId_Heading9 := 70009
 , UIA_StyleId_Title := 70010
 , UIA_StyleId_Subtitle := 70011
 , UIA_StyleId_Normal := 70012
 , UIA_StyleId_Emphasis := 70013
 , UIA_StyleId_Quote := 70014
 , UIA_StyleId_BulletedList := 70015
 , UIA_StyleId_NumberedList := 70016

;enum LandmarkTypeIds
 , UIA_CustomLandmarkTypeId := 80000
 , UIA_FormLandmarkTypeId := 80001
 , UIA_MainLandmarkTypeId := 80002
 , UIA_NavigationLandmarkTypeId := 80003
 , UIA_SearchLandmarkTypeId := 80004
 
;enum HeadingLevelIds
 , UIA_HeadingLevel_None := 80050
 , UIA_HeadingLevel1 := 80051
 , UIA_HeadingLevel2 := 80052
 , UIA_HeadingLevel3 := 80053
 , UIA_HeadingLevel4 := 80054
 , UIA_HeadingLevel5 := 80055
 , UIA_HeadingLevel6 := 80056
 , UIA_HeadingLevel7 := 80057
 , UIA_HeadingLevel8 := 80058
 , UIA_HeadingLevel9 := 80059

;enum ChangeIds
 , UIA_SummaryChangeId := 90000

;enum MetadataIds
 , UIA_SayAsInterpretAsMetadataId := 100000

;enum TreeScope
global UIA_TreeScope_Element := 1
 , UIA_TreeScope_Children := 2
 , UIA_TreeScope_Descendants := 4
 , UIA_TreeScope_Parent := 8
 , UIA_TreeScope_Ancestors := 16
 , UIA_TreeScope_Subtree := 7

;enum AutomationElementMode
 , UIA_AutomationElementMode_None := 0
 , UIA_AutomationElementMode_Full := 1

;enum OrientationType
 , UIA_OrientationType_None := 0
 , UIA_OrientationType_Horizontal := 1
 , UIA_OrientationType_Vertical := 2

;enum PropertyConditionFlags
 , UIA_PropertyConditionFlags_None := 0
 , UIA_PropertyConditionFlags_IgnoreCase := 1

;enum StructureChangeType
 , UIA_StructureChangeType_ChildAdded := 0
 , UIA_StructureChangeType_ChildRemoved := 1
 , UIA_StructureChangeType_ChildrenInvalidated := 2
 , UIA_StructureChangeType_ChildrenBulkAdded := 3
 , UIA_StructureChangeType_ChildrenBulkRemoved := 4
 , UIA_StructureChangeType_ChildrenReordered := 5

;enum TextEditChangeType
 , UIA_TextEditChangeType_None := 0x0
 , UIA_TextEditChangeType_AutoCorrect := 0x1
 , UIA_TextEditChangeType_Composition := 0x2
 , UIA_TextEditChangeType_CompositionFinalized := 0x3
 , UIA_TextEditChangeType_AutoComplete := 0x4

;enum DockPosition
 , UIA_DockPosition_Top := 0
 , UIA_DockPosition_Left := 1
 , UIA_DockPosition_Bottom := 2
 , UIA_DockPosition_Right := 3
 , UIA_DockPosition_Fill := 4
 , UIA_DockPosition_None := 5

;enum ExpandCollapseState
 , UIA_ExpandCollapseState_Collapsed := 0
 , UIA_ExpandCollapseState_Expanded := 1
 , UIA_ExpandCollapseState_PartiallyExpanded := 2
 , UIA_ExpandCollapseState_LeafNode := 3

;enum ScrollAmount
 , UIA_ScrollAmount_LargeDecrement := 0
 , UIA_ScrollAmount_SmallDecrement := 1
 , UIA_ScrollAmount_NoAmount := 2
 , UIA_ScrollAmount_LargeIncrement := 3
 , UIA_ScrollAmount_SmallIncrement := 4

;enum SynchronizedInputType
 , UIA_SynchronizedInputType_KeyUp := 1
 , UIA_SynchronizedInputType_KeyDown := 2
 , UIA_SynchronizedInputType_LeftMouseUp := 4
 , UIA_SynchronizedInputType_LeftMouseDown := 8
 , UIA_SynchronizedInputType_RightMouseUp := 16
 , UIA_SynchronizedInputType_RightMouseDown := 32

;enum RowOrColumnMajor
 , UIA_RowOrColumnMajor_RowMajor := 0
 , UIA_RowOrColumnMajor_ColumnMajor := 1
 , UIA_RowOrColumnMajor_Indeterminate := 2

;enum ToggleState
 , UIA_ToggleState_Off := 0
 , UIA_ToggleState_On := 1
 , UIA_ToggleState_Indeterminate := 2

;enum WindowVisualState
 , UIA_WindowVisualState_Normal := 0
 , UIA_WindowVisualState_Maximized := 1
 , UIA_WindowVisualState_Minimized := 2

;enum WindowInteractionState
 , UIA_WindowInteractionState_Running := 0
 , UIA_WindowInteractionState_Closing := 1
 , UIA_WindowInteractionState_ReadyForUserInteraction := 2
 , UIA_WindowInteractionState_BlockedByModalWindow := 3
 , UIA_WindowInteractionState_NotResponding := 4

;enum TextPatternRangeEndpoint
 , UIA_TextPatternRangeEndpoint_Start := 0
 , UIA_TextPatternRangeEndpoint_End := 1

;enum TextUnit
 , UIA_TextUnit_Character := 0
 , UIA_TextUnit_Format := 1
 , UIA_TextUnit_Word := 2
 , UIA_TextUnit_Line := 3
 , UIA_TextUnit_Paragraph := 4
 , UIA_TextUnit_Page := 5
 , UIA_TextUnit_Document := 6

;enum SupportedTextSelection
 , UIA_SupportedTextSelection_None := 0
 , UIA_SupportedTextSelection_Single := 1
 , UIA_SupportedTextSelection_Multiple := 2

;enum NavigateDirection
 , UIA_NavigateDirection_Parent := 0x0
 , UIA_NavigateDirection_NextSibling := 0x1
 , UIA_NavigateDirection_PreviousSibling := 0x2
 , UIA_NavigateDirection_FirstChild := 0x3
 , UIA_NavigateDirection_LastChild := 0x4

;enum ZoomUnit
 , UIA_ZoomUnit_NoAmount := 0x0
 , UIA_ZoomUnit_LargeDecrement := 0x1
 , UIA_ZoomUnit_SmallDecrement := 0x2
 , UIA_ZoomUnit_LargeIncrement := 0x3
 , UIA_ZoomUnit_SmallIncrement := 0x4

;enum LiveSetting
 , UIA_LiveSetting_Off := 0x0
 , UIA_LiveSetting_Polite := 0x1
 , UIA_LiveSetting_Assertive := 0x2

;enum TreeTraversalOptions
 , UIA_TreeTraversalOptions_Default := 0x0
 , UIA_TreeTraversalOptions_PostOrder := 0x1
 , UIA_TreeTraversalOptions_LastToFirstOrder := 0x2

;enum ProviderOptions
 , UIA_ProviderOptions_ClientSideProvider := 1
 , UIA_ProviderOptions_ServerSideProvider := 2
 , UIA_ProviderOptions_NonClientAreaProvider := 4
 , UIA_ProviderOptions_OverrideProvider := 8
 , UIA_ProviderOptions_ProviderOwnsSetFocus := 16
 , UIA_ProviderOptions_UseComThreading := 32
 , UIA_ProviderOptions_RefuseNonClientSupport := 64
 , UIA_ProviderOptions_HasNativeIAccessible := 128
 , UIA_ProviderOptions_UseClientCoordinates := 256


global sIID_IUIAutomationElement := "{D22108AA-8AC5-49A5-837B-37BBB3D7591E}"
 , dtagIUIAutomationElement := "SetFocus hresult();"
 . "GetRuntimeId hresult(ptr*);"
 . "FindFirst hresult(long;ptr;ptr*);"
 . "FindAll hresult(long;ptr;ptr*);"
 . "FindFirstBuildCache hresult(long;ptr;ptr;ptr*);"
 . "FindAllBuildCache hresult(long;ptr;ptr;ptr*);"
 . "BuildUpdatedCache hresult(ptr;ptr*);"
 . "GetCurrentPropertyValue hresult(int;variant*);"
 . "GetCurrentPropertyValueEx hresult(int;long;variant*);"
 . "GetCachedPropertyValue hresult(int;variant*);"
 . "GetCachedPropertyValueEx hresult(int;long;variant*);"
 . "GetCurrentPatternAs hresult(int;none;none*);"
 . "GetCachedPatternAs hresult(int;none;none*);"
 . "GetCurrentPattern hresult(int;ptr*);"
 . "GetCachedPattern hresult(int;ptr*);"
 . "GetCachedParent hresult(ptr*);"
 . "GetCachedChildren hresult(ptr*);"
 . "CurrentProcessId hresult(int*);"
 . "CurrentControlType hresult(int*);"
 . "CurrentLocalizedControlType hresult(bstr*);"
 . "CurrentName hresult(bstr*);"
 . "CurrentAcceleratorKey hresult(bstr*);"
 . "CurrentAccessKey hresult(bstr*);"
 . "CurrentHasKeyboardFocus hresult(long*);"
 . "CurrentIsKeyboardFocusable hresult(long*);"
 . "CurrentIsEnabled hresult(long*);"
 . "CurrentAutomationId hresult(bstr*);"
 . "CurrentClassName hresult(bstr*);"
 . "CurrentHelpText hresult(bstr*);"
 . "CurrentCulture hresult(int*);"
 . "CurrentIsControlElement hresult(long*);"
 . "CurrentIsContentElement hresult(long*);"
 . "CurrentIsPassword hresult(long*);"
 . "CurrentNativeWindowHandle hresult(hwnd*);"
 . "CurrentItemType hresult(bstr*);"
 . "CurrentIsOffscreen hresult(long*);"
 . "CurrentOrientation hresult(long*);"
 . "CurrentFrameworkId hresult(bstr*);"
 . "CurrentIsRequiredForForm hresult(long*);"
 . "CurrentItemStatus hresult(bstr*);"
 . "CurrentBoundingRectangle hresult(struct*);"
 . "CurrentLabeledBy hresult(ptr*);"
 . "CurrentAriaRole hresult(bstr*);"
 . "CurrentAriaProperties hresult(bstr*);"
 . "CurrentIsDataValidForForm hresult(long*);"
 . "CurrentControllerFor hresult(ptr*);"
 . "CurrentDescribedBy hresult(ptr*);"
 . "CurrentFlowsTo hresult(ptr*);"
 . "CurrentProviderDescription hresult(bstr*);"
 . "CachedProcessId hresult(int*);"
 . "CachedControlType hresult(int*);"
 . "CachedLocalizedControlType hresult(bstr*);"
 . "CachedName hresult(bstr*);"
 . "CachedAcceleratorKey hresult(bstr*);"
 . "CachedAccessKey hresult(bstr*);"
 . "CachedHasKeyboardFocus hresult(long*);"
 . "CachedIsKeyboardFocusable hresult(long*);"
 . "CachedIsEnabled hresult(long*);"
 . "CachedAutomationId hresult(bstr*);"
 . "CachedClassName hresult(bstr*);"
 . "CachedHelpText hresult(bstr*);"
 . "CachedCulture hresult(int*);"
 . "CachedIsControlElement hresult(long*);"
 . "CachedIsContentElement hresult(long*);"
 . "CachedIsPassword hresult(long*);"
 . "CachedNativeWindowHandle hresult(hwnd*);"
 . "CachedItemType hresult(bstr*);"
 . "CachedIsOffscreen hresult(long*);"
 . "CachedOrientation hresult(long*);"
 . "CachedFrameworkId hresult(bstr*);"
 . "CachedIsRequiredForForm hresult(long*);"
 . "CachedItemStatus hresult(bstr*);"
 . "CachedBoundingRectangle hresult(struct*);"
 . "CachedLabeledBy hresult(ptr*);"
 . "CachedAriaRole hresult(bstr*);"
 . "CachedAriaProperties hresult(bstr*);"
 . "CachedIsDataValidForForm hresult(long*);"
 . "CachedControllerFor hresult(ptr*);"
 . "CachedDescribedBy hresult(ptr*);"
 . "CachedFlowsTo hresult(ptr*);"
 . "CachedProviderDescription hresult(bstr*);"
 . "GetClickablePoint hresult(struct*;long*);"

 , sIID_IUIAutomationCondition := "{352FFBA8-0973-437C-A61F-F64CAFD81DF9}"
 , dtagIUIAutomationCondition  :=  ""

 , sIID_IUIAutomationElementArray := "{14314595-B4BC-4055-95F2-58F2E42C9855}"
 , dtagIUIAutomationElementArray  :=  "Length hresult(int*);"
 . "GetElement hresult(int;ptr*);"

 , sIID_IUIAutomationCacheRequest := "{B32A92B5-BC25-4078-9C08-D7EE95C48E03}"
 , dtagIUIAutomationCacheRequest  :=  "AddProperty hresult(int);"
 . "AddPattern hresult(int);"
 . "Clone hresult(ptr*);"
 . "get_TreeScope hresult(long*);"
 . "put_TreeScope hresult(long);"
 . "get_TreeFilter hresult(ptr*);"
 . "put_TreeFilter hresult(ptr);"
 . "get_AutomationElementMode hresult(long*);"
 . "put_AutomationElementMode hresult(long);"

 , sIID_IUIAutomationBoolCondition := "{1B4E1F2E-75EB-4D0B-8952-5A69988E2307}"
 , dtagIUIAutomationBoolCondition  :=  "BooleanValue hresult(long*);"

 , sIID_IUIAutomationPropertyCondition := "{99EBF2CB-5578-4267-9AD4-AFD6EA77E94B}"
 , dtagIUIAutomationPropertyCondition  :=  "propertyId hresult(int*);"
 . "PropertyValue hresult(variant*);"
 . "PropertyConditionFlags hresult(long*);"

 , sIID_IUIAutomationAndCondition := "{A7D0AF36-B912-45FE-9855-091DDC174AEC}"
 , dtagIUIAutomationAndCondition  :=  "ChildCount hresult(int*);"
 . "GetChildrenAsNativeArray hresult(ptr*;int*);"
 . "GetChildren hresult(ptr*);"

 , sIID_IUIAutomationOrCondition := "{8753F032-3DB1-47B5-A1FC-6E34A266C712}"
 , dtagIUIAutomationOrCondition  :=  "ChildCount hresult(int*);"
 . "GetChildrenAsNativeArray hresult(ptr*;int*);"
 . "GetChildren hresult(ptr*);"

 , sIID_IUIAutomationNotCondition := "{F528B657-847B-498C-8896-D52B565407A1}"
 , dtagIUIAutomationNotCondition  :=  "GetChild hresult(ptr*);"

 , sIID_IUIAutomationTreeWalker := "{4042C624-389C-4AFC-A630-9DF854A541FC}"
 , dtagIUIAutomationTreeWalker  :=  "GetParentElement hresult(ptr;ptr*);"
 . "GetFirstChildElement hresult(ptr;ptr*);"
 . "GetLastChildElement hresult(ptr;ptr*);"
 . "GetNextSiblingElement hresult(ptr;ptr*);"
 . "GetPreviousSiblingElement hresult(ptr;ptr*);"
 . "NormalizeElement hresult(ptr;ptr*);"
 . "GetParentElementBuildCache hresult(ptr;ptr;ptr*);"
 . "GetFirstChildElementBuildCache hresult(ptr;ptr;ptr*);"
 . "GetLastChildElementBuildCache hresult(ptr;ptr;ptr*);"
 . "GetNextSiblingElementBuildCache hresult(ptr;ptr;ptr*);"
 . "GetPreviousSiblingElementBuildCache hresult(ptr;ptr;ptr*);"
 . "NormalizeElementBuildCache hresult(ptr;ptr;ptr*);"
 . "condition hresult(ptr*);"

 , sIID_IUIAutomationEventHandler := "{146C3C17-F12E-4E22-8C27-F894B9B79C69}"
 , dtagIUIAutomationEventHandler  :=  "HandleAutomationEvent hresult(ptr;int);"

 , sIID_IUIAutomationPropertyChangedEventHandler := "{40CD37D4-C756-4B0C-8C6F-BDDFEEB13B50}"
 , dtagIUIAutomationPropertyChangedEventHandler  :=  "HandlePropertyChangedEvent hresult(ptr;int;variant);"

 , sIID_IUIAutomationStructureChangedEventHandler := "{E81D1B4E-11C5-42F8-9754-E7036C79F054}"
 , dtagIUIAutomationStructureChangedEventHandler  :=  "HandleStructureChangedEvent hresult(ptr;long;ptr);"

 , sIID_IUIAutomationFocusChangedEventHandler := "{C270F6B5-5C69-4290-9745-7A7F97169468}"
 , dtagIUIAutomationFocusChangedEventHandler  :=  "HandleFocusChangedEvent hresult(ptr);"

 , sIID_IUIAutomationInvokePattern := "{FB377FBE-8EA6-46D5-9C73-6499642D3059}"
 , dtagIUIAutomationInvokePattern  :=  "Invoke hresult();"

 , sIID_IUIAutomationDockPattern := "{FDE5EF97-1464-48F6-90BF-43D0948E86EC}"
 , dtagIUIAutomationDockPattern  :=  "SetDockPosition hresult(long);"
 . "CurrentDockPosition hresult(long*);"
 . "CachedDockPosition hresult(long*);"

 , sIID_IUIAutomationExpandCollapsePattern := "{619BE086-1F4E-4EE4-BAFA-210128738730}"
 , dtagIUIAutomationExpandCollapsePattern  :=  "Expand hresult();"
 . "Collapse hresult();"
 . "CurrentExpandCollapseState hresult(long*);"
 . "CachedExpandCollapseState hresult(long*);"

 , sIID_IUIAutomationGridPattern := "{414C3CDC-856B-4F5B-8538-3131C6302550}"
 , dtagIUIAutomationGridPattern  :=  "GetItem hresult(int;int;ptr*);"
 . "CurrentRowCount hresult(int*);"
 . "CurrentColumnCount hresult(int*);"
 . "CachedRowCount hresult(int*);"
 . "CachedColumnCount hresult(int*);"

 , sIID_IUIAutomationGridItemPattern := "{78F8EF57-66C3-4E09-BD7C-E79B2004894D}"
 , dtagIUIAutomationGridItemPattern  :=  "CurrentContainingGrid hresult(ptr*);"
 . "CurrentRow hresult(int*);"
 . "CurrentColumn hresult(int*);"
 . "CurrentRowSpan hresult(int*);"
 . "CurrentColumnSpan hresult(int*);"
 . "CachedContainingGrid hresult(ptr*);"
 . "CachedRow hresult(int*);"
 . "CachedColumn hresult(int*);"
 . "CachedRowSpan hresult(int*);"
 . "CachedColumnSpan hresult(int*);"

 , sIID_IUIAutomationMultipleViewPattern := "{8D253C91-1DC5-4BB5-B18F-ADE16FA495E8}"
 , dtagIUIAutomationMultipleViewPattern  :=  "GetViewName hresult(int;bstr*);"
 . "SetCurrentView hresult(int);"
 . "CurrentCurrentView hresult(int*);"
 . "GetCurrentSupportedViews hresult(ptr*);"
 . "CachedCurrentView hresult(int*);"
 . "GetCachedSupportedViews hresult(ptr*);"

 , sIID_IUIAutomationRangeValuePattern := "{59213F4F-7346-49E5-B120-80555987A148}"
 , dtagIUIAutomationRangeValuePattern  :=  "SetValue hresult(ushort);"
 . "CurrentValue hresult(ushort*);"
 . "CurrentIsReadOnly hresult(long*);"
 . "CurrentMaximum hresult(ushort*);"
 . "CurrentMinimum hresult(ushort*);"
 . "CurrentLargeChange hresult(ushort*);"
 . "CurrentSmallChange hresult(ushort*);"
 . "CachedValue hresult(ushort*);"
 . "CachedIsReadOnly hresult(long*);"
 . "CachedMaximum hresult(ushort*);"
 . "CachedMinimum hresult(ushort*);"
 . "CachedLargeChange hresult(ushort*);"
 . "CachedSmallChange hresult(ushort*);"

 , sIID_IUIAutomationScrollPattern := "{88F4D42A-E881-459D-A77C-73BBBB7E02DC}"
 , dtagIUIAutomationScrollPattern  :=  "Scroll hresult(long;long);"
 . "SetScrollPercent hresult(ushort;ushort);"
 . "CurrentHorizontalScrollPercent hresult(ushort*);"
 . "CurrentVerticalScrollPercent hresult(ushort*);"
 . "CurrentHorizontalViewSize hresult(ushort*);"
 . "CurrentVerticalViewSize hresult(ushort*);"
 . "CurrentHorizontallyScrollable hresult(long*);"
 . "CurrentVerticallyScrollable hresult(long*);"
 . "CachedHorizontalScrollPercent hresult(ushort*);"
 . "CachedVerticalScrollPercent hresult(ushort*);"
 . "CachedHorizontalViewSize hresult(ushort*);"
 . "CachedVerticalViewSize hresult(ushort*);"
 . "CachedHorizontallyScrollable hresult(long*);"
 . "CachedVerticallyScrollable hresult(long*);"

 , sIID_IUIAutomationScrollItemPattern := "{B488300F-D015-4F19-9C29-BB595E3645EF}"
 , dtagIUIAutomationScrollItemPattern  :=  "ScrollIntoView hresult();"

 , sIID_IUIAutomationSelectionPattern := "{5ED5202E-B2AC-47A6-B638-4B0BF140D78E}"
 , dtagIUIAutomationSelectionPattern  :=  "GetCurrentSelection hresult(ptr*);"
 . "CurrentCanSelectMultiple hresult(long*);"
 . "CurrentIsSelectionRequired hresult(long*);"
 . "GetCachedSelection hresult(ptr*);"
 . "CachedCanSelectMultiple hresult(long*);"
 . "CachedIsSelectionRequired hresult(long*);"

 , sIID_IUIAutomationSelectionItemPattern := "{A8EFA66A-0FDA-421A-9194-38021F3578EA}"
 , dtagIUIAutomationSelectionItemPattern  :=  "Select hresult();"
 . "AddToSelection hresult();"
 . "RemoveFromSelection hresult();"
 . "CurrentIsSelected hresult(long*);"
 . "CurrentSelectionContainer hresult(ptr*);"
 . "CachedIsSelected hresult(long*);"
 . "CachedSelectionContainer hresult(ptr*);"

 , sIID_IUIAutomationSynchronizedInputPattern := "{2233BE0B-AFB7-448B-9FDA-3B378AA5EAE1}"
 , dtagIUIAutomationSynchronizedInputPattern  :=  "StartListening hresult(long);"
 . "Cancel hresult();"

 , sIID_IUIAutomationTablePattern := "{620E691C-EA96-4710-A850-754B24CE2417}"
 , dtagIUIAutomationTablePattern  :=  "GetCurrentRowHeaders hresult(ptr*);"
 . "GetCurrentColumnHeaders hresult(ptr*);"
 . "CurrentRowOrColumnMajor hresult(long*);"
 . "GetCachedRowHeaders hresult(ptr*);"
 . "GetCachedColumnHeaders hresult(ptr*);"
 . "CachedRowOrColumnMajor hresult(long*);"

 , sIID_IUIAutomationTableItemPattern := "{0B964EB3-EF2E-4464-9C79-61D61737A27E}"
 , dtagIUIAutomationTableItemPattern  :=  "GetCurrentRowHeaderItems hresult(ptr*);"
 . "GetCurrentColumnHeaderItems hresult(ptr*);"
 . "GetCachedRowHeaderItems hresult(ptr*);"
 . "GetCachedColumnHeaderItems hresult(ptr*);"

 , sIID_IUIAutomationTogglePattern := "{94CF8058-9B8D-4AB9-8BFD-4CD0A33C8C70}"
 , dtagIUIAutomationTogglePattern  :=  "Toggle hresult();"
 . "CurrentToggleState hresult(long*);"
 . "CachedToggleState hresult(long*);"

 , sIID_IUIAutomationTransformPattern := "{A9B55844-A55D-4EF0-926D-569C16FF89BB}"
 , dtagIUIAutomationTransformPattern  :=  "Move hresult(double;double);" ;~ fixed ushort to be double
 . "Resize hresult(double;double);" ;~ fixed ushort to be double
 . "Rotate hresult(ushort);"
 . "CurrentCanMove hresult(long*);"
 . "CurrentCanResize hresult(long*);"
 . "CurrentCanRotate hresult(long*);"
 . "CachedCanMove hresult(long*);"
 . "CachedCanResize hresult(long*);"
 . "CachedCanRotate hresult(long*);"

 , sIID_IUIAutomationValuePattern := "{A94CD8B1-0844-4CD6-9D2D-640537AB39E9}"
 , dtagIUIAutomationValuePattern  :=  "SetValue hresult(bstr);"
 . "CurrentValue hresult(bstr*);"
 . "CurrentIsReadOnly hresult(long*);"
 . "CachedValue hresult(bstr*);"
 . "CachedIsReadOnly hresult(long*);"

 , sIID_IUIAutomationWindowPattern := "{0FAEF453-9208-43EF-BBB2-3B485177864F}"
 , dtagIUIAutomationWindowPattern  :=  "Close hresult();"
 . "WaitForInputIdle hresult(int;long*);"
 . "SetWindowVisualState hresult(long);"
 . "CurrentCanMaximize hresult(long*);"
 . "CurrentCanMinimize hresult(long*);"
 . "CurrentIsModal hresult(long*);"
 . "CurrentIsTopmost hresult(long*);"
 . "CurrentWindowVisualState hresult(long*);"
 . "CurrentWindowInteractionState hresult(long*);"
 . "CachedCanMaximize hresult(long*);"
 . "CachedCanMinimize hresult(long*);"
 . "CachedIsModal hresult(long*);"
 . "CachedIsTopmost hresult(long*);"
 . "CachedWindowVisualState hresult(long*);"
 . "CachedWindowInteractionState hresult(long*);"

 , sIID_IUIAutomationTextRange := "{A543CC6A-F4AE-494B-8239-C814481187A8}"
 , dtagIUIAutomationTextRange  :=  "Clone hresult(ptr*);"
 . "Compare hresult(ptr;long*);"
 . "CompareEndpoints hresult(long;ptr;long;int*);"
 . "ExpandToEnclosingUnit hresult(long);"
 . "FindAttribute hresult(int;variant;long;ptr*);"
 . "FindText hresult(bstr;long;long;ptr*);"
 . "GetAttributeValue hresult(int;variant*);"
 . "GetBoundingRectangles hresult(ptr*);"
 . "GetEnclosingElement hresult(ptr*);"
 . "GetText hresult(int;bstr*);"
 . "Move hresult(long;int;int*);"
 . "MoveEndpointByUnit hresult(long;long;int;int*);"
 . "MoveEndpointByRange hresult(long;ptr;long);"
 . "Select hresult();"
 . "AddToSelection hresult();"
 . "RemoveFromSelection hresult();"
 . "ScrollIntoView hresult(long);"
 . "GetChildren hresult(ptr*);"

 , sIID_IUIAutomationTextRangeArray := "{CE4AE76A-E717-4C98-81EA-47371D028EB6}"
 , dtagIUIAutomationTextRangeArray  :=  "Length hresult(int*);"
 . "GetElement hresult(int;ptr*);"

 , sIID_IUIAutomationTextPattern := "{32EBA289-3583-42C9-9C59-3B6D9A1E9B6A}"
 , dtagIUIAutomationTextPattern  :=  "RangeFromPoint hresult(struct;ptr*);"
 . "RangeFromChild hresult(ptr;ptr*);"
 . "GetSelection hresult(ptr*);"
 . "GetVisibleRanges hresult(ptr*);"
 . "DocumentRange hresult(ptr*);"
 . "SupportedTextSelection hresult(long*);"

 , sIID_IUIAutomationLegacyIAccessiblePattern := "{828055AD-355B-4435-86D5-3B51C14A9B1B}"
 , dtagIUIAutomationLegacyIAccessiblePattern  :=  "Select hresult(long);"
 . "DoDefaultAction hresult();"
 . "SetValue hresult(wstr);"
 . "CurrentChildId hresult(int*);"
 . "CurrentName hresult(bstr*);"
 . "CurrentValue hresult(bstr*);"
 . "CurrentDescription hresult(bstr*);"
 . "CurrentRole hresult(uint*);"
 . "CurrentState hresult(uint*);"
 . "CurrentHelp hresult(bstr*);"
 . "CurrentKeyboardShortcut hresult(bstr*);"
 . "GetCurrentSelection hresult(ptr*);"
 . "CurrentDefaultAction hresult(bstr*);"
 . "CachedChildId hresult(int*);"
 . "CachedName hresult(bstr*);"
 . "CachedValue hresult(bstr*);"
 . "CachedDescription hresult(bstr*);"
 . "CachedRole hresult(uint*);"
 . "CachedState hresult(uint*);"
 . "CachedHelp hresult(bstr*);"
 . "CachedKeyboardShortcut hresult(bstr*);"
 . "GetCachedSelection hresult(ptr*);"
 . "CachedDefaultAction hresult(bstr*);"
 . "GetIAccessible hresult(idispatch*);"

global sIID_IAccessible := "{618736E0-3C3D-11CF-810C-00AA00389B71}"
 , dtagIAccessible  :=  "GetTypeInfoCount hresult(uint*);" ; IDispatch
 . "GetTypeInfo hresult(uint;int;ptr*);"
 . "GetIDsOfNames hresult(struct*;wstr;uint;int;int);"
 . "Invoke hresult(int;struct*;int;word;ptr*;ptr*;ptr*;uint*);"
 . "get_accParent hresult(ptr*);" ; IAccessible
 . "get_accChildCount hresult(long*);"
 . "get_accChild hresult(variant;idispatch*);"
 . "get_accName hresult(variant;bstr*);"
 . "get_accValue hresult(variant;bstr*);"
 . "get_accDescription hresult(variant;bstr*);"
 . "get_accRole hresult(variant;variant*);"
 . "get_accState hresult(variant;variant*);"
 . "get_accHelp hresult(variant;bstr*);"
 . "get_accHelpTopic hresult(bstr*;variant;long*);"
 . "get_accKeyboardShortcut hresult(variant;bstr*);"
 . "get_accFocus hresult(struct*);"
 . "get_accSelection hresult(variant*);"
 . "get_accDefaultAction hresult(variant;bstr*);"
 . "accSelect hresult(long;variant);"
 . "accLocation hresult(long*;long*;long*;long*;variant);"
 . "accNavigate hresult(long;variant;variant*);"
 . "accHitTest hresult(long;long;variant*);"
 . "accDoDefaultAction hresult(variant);"
 . "put_accName hresult(variant;bstr);"
 . "put_accValue hresult(variant;bstr);"

 , sIID_IUIAutomationItemContainerPattern := "{C690FDB2-27A8-423C-812D-429773C9084E}"
 , dtagIUIAutomationItemContainerPattern  :=  "FindItemByProperty hresult(ptr;int;variant;ptr*);"

 , sIID_IUIAutomationVirtualizedItemPattern := "{6BA3D7A6-04CF-4F11-8793-A8D1CDE9969F}"
 , dtagIUIAutomationVirtualizedItemPattern  :=  "Realize hresult();"

 , sIID_IUIAutomationProxyFactory := "{85B94ECD-849D-42B6-B94D-D6DB23FDF5A4}"
 , dtagIUIAutomationProxyFactory  :=  "CreateProvider hresult(hwnd;long;long;ptr*);"
 . "ProxyFactoryId hresult(bstr*);"

 , sIID_IRawElementProviderSimple := "{D6DD68D1-86FD-4332-8666-9ABEDEA2D24C}"
 , dtagIRawElementProviderSimple  :=  "ProviderOptions hresult(long*);"
 . "GetPatternProvider hresult(int;ptr*);"
 . "GetPropertyValue hresult(int;variant*);"
 . "HostRawElementProvider hresult(ptr*);"

 , sIID_IUIAutomationProxyFactoryEntry := "{D50E472E-B64B-490C-BCA1-D30696F9F289}"
 , dtagIUIAutomationProxyFactoryEntry  :=  "ProxyFactory hresult(ptr*);"
 . "ClassName hresult(bstr*);"
 . "ImageName hresult(bstr*);"
 . "AllowSubstringMatch hresult(long*);"
 . "CanCheckBaseClass hresult(long*);"
 . "NeedsAdviseEvents hresult(long*);"
 . "ClassName hresult(wstr);"
 . "ImageName hresult(wstr);"
 . "AllowSubstringMatch hresult(long);"
 . "CanCheckBaseClass hresult(long);"
 . "NeedsAdviseEvents hresult(long);"
 . "SetWinEventsForAutomationEvent hresult(int;int;ptr);"
 . "GetWinEventsForAutomationEvent hresult(int;int;ptr*);"

 , sIID_IUIAutomationProxyFactoryMapping := "{09E31E18-872D-4873-93D1-1E541EC133FD}"
 , dtagIUIAutomationProxyFactoryMapping  :=  "count hresult(uint*);"
 . "GetTable hresult(ptr*);"
 . "GetEntry hresult(uint;ptr*);"
 . "SetTable hresult(ptr);"
 . "InsertEntries hresult(uint;ptr);"
 . "InsertEntry hresult(uint;ptr);"
 . "RemoveEntry hresult(uint);"
 . "ClearTable hresult();"
 . "RestoreDefaultTable hresult();"

 , sIID_IUIAutomation := "{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}"
 , dtagIUIAutomation  :=  "CompareElements hresult(ptr;ptr;long*);"
 . "CompareRuntimeIds hresult(ptr;ptr;long*);"
 . "GetRootElement hresult(ptr*);"
 . "ElementFromHandle hresult(hwnd;ptr*);"
 . "ElementFromPoint hresult(struct;ptr*);"
 . "GetFocusedElement hresult(ptr*);"
 . "GetRootElementBuildCache hresult(ptr;ptr*);"
 . "ElementFromHandleBuildCache hresult(hwnd;ptr;ptr*);"
 . "ElementFromPointBuildCache hresult(struct;ptr;ptr*);"
 . "GetFocusedElementBuildCache hresult(ptr;ptr*);"
 . "CreateTreeWalker hresult(ptr;ptr*);"
 . "ControlViewWalker hresult(ptr*);"
 . "ContentViewWalker hresult(ptr*);"
 . "RawViewWalker hresult(ptr*);"
 . "RawViewCondition hresult(ptr*);"
 . "ControlViewCondition hresult(ptr*);"
 . "ContentViewCondition hresult(ptr*);"
 . "CreateCacheRequest hresult(ptr*);"
 . "CreateTrueCondition hresult(ptr*);"
 . "CreateFalseCondition hresult(ptr*);"
 . "CreatePropertyCondition hresult(int;variant;ptr*);"
 . "CreatePropertyConditionEx hresult(int;variant;long;ptr*);"
 . "CreateAndCondition hresult(ptr;ptr;ptr*);"
 . "CreateAndConditionFromArray hresult(ptr;ptr*);"
 . "CreateAndConditionFromNativeArray hresult(ptr;int;ptr*);"
 . "CreateOrCondition hresult(ptr;ptr;ptr*);"
 . "CreateOrConditionFromArray hresult(ptr;ptr*);"
 . "CreateOrConditionFromNativeArray hresult(ptr;int;ptr*);"
 . "CreateNotCondition hresult(ptr;ptr*);"
 . "AddAutomationEventHandler hresult(int;ptr;long;ptr;ptr);"
 . "RemoveAutomationEventHandler hresult(int;ptr;ptr);"
 . "AddPropertyChangedEventHandlerNativeArray hresult(ptr;long;ptr;ptr;struct*;int);"
 . "AddPropertyChangedEventHandler hresult(ptr;long;ptr;ptr;ptr);"
 . "RemovePropertyChangedEventHandler hresult(ptr;ptr);"
 . "AddStructureChangedEventHandler hresult(ptr;long;ptr;ptr);"
 . "RemoveStructureChangedEventHandler hresult(ptr;ptr);"
 . "AddFocusChangedEventHandler hresult(ptr;ptr);"
 . "RemoveFocusChangedEventHandler hresult(ptr);"
 . "RemoveAllEventHandlers hresult();"
 . "IntNativeArrayToSafeArray hresult(int;int;ptr*);"
 . "IntSafeArrayToNativeArray hresult(ptr;int*;int*);"
 . "RectToVariant hresult(struct;variant*);"
 . "VariantToRect hresult(variant;struct*);"
 . "SafeArrayToRectNativeArray hresult(ptr;struct*;int*);"
 . "CreateProxyFactoryEntry hresult(ptr;ptr*);"
 . "ProxyFactoryMapping hresult(ptr*);"
 . "GetPropertyProgrammaticName hresult(int;bstr*);"
 . "GetPatternProgrammaticName hresult(int;bstr*);"
 . "PollForPotentialSupportedPatterns hresult(ptr;ptr*;ptr*);"
 . "PollForPotentialSupportedProperties hresult(ptr;ptr*;ptr*);"
 . "CheckNotSupported hresult(variant;long*);"
 . "ReservedNotSupportedValue hresult(ptr*);"
 . "ReservedMixedAttributeValue hresult(ptr*);"
 . "ElementFromIAccessible hresult(idispatch;int;ptr*);"
 . "ElementFromIAccessibleBuildCache hresult(iaccessible;int;ptr;ptr*);"
 , UIA_MaxVersion_Interface := 7
 , UIA_MaxVersion_Element := 7
 , UIA_MaxVersion_TextRange := 3
 
 , VT_BSTR_Properties := [UIA_AcceleratorKeyPropertyId, UIA_AccessKeyPropertyId, UIA_AriaPropertiesPropertyId, UIA_AriaRolePropertyId, UIA_AutomationIdPropertyId, UIA_ClassNamePropertyId, UIA_FrameworkIdPropertyId, UIA_FullDescriptionPropertyId, UIA_HelpTextPropertyId, UIA_ItemStatusPropertyId, UIA_ItemTypePropertyId, UIA_LocalizedControlTypePropertyId, UIA_LocalizedLandmarkTypePropertyId, UIA_NamePropertyId, UIA_ProviderDescriptionPropertyId]
 , VT_I4_Properties := [UIA_ControlTypePropertyId, UIA_CulturePropertyId, UIA_FillColorPropertyId, UIA_FillTypePropertyId, UIA_HeadingLevelPropertyId, UIA_LandmarkTypePropertyId, UIA_LevelPropertyId, UIA_LiveSettingPropertyId, UIA_NativeWindowHandlePropertyId, UIA_OrientationPropertyId, UIA_PositionInSetPropertyId, UIA_ProcessIdPropertyId, UIA_SizeOfSetPropertyId, UIA_VisualEffectsPropertyId]

 , VT_EMPTY:=0,VT_NULL:=1,VT_I2:=2,VT_I4:=3,VT_R8:=5,VT_CY:=6,VT_DATE:=7,VT_BSTR:=8,VT_DISPATCH:=9,VT_ERROR:=10,VT_BOOL:=11,VT_VARIANT:=12,VT_UNKNOWN:=13,VT_DECIMAL:=14,VT_I1:=16,VT_UI1=17,VT_UI2:=18,VT_UI4:=19,VT_I8:=20,VT_UI8:=21,VT_INT:=22,VT_UINT:=23,VT_RECORD:=36,VT_BYREF:=4096
