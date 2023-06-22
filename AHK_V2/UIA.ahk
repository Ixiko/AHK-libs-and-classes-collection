/*
    Introduction & credits
    This library implements Microsoft's UI Automation framework.
    Microsoft's official documentation:: https://docs.microsoft.com/en-us/windows/win32/winauto/entry-uiauto-win32
    Author: Descolada
    Credits: thqby, neptercn (v1), jethrow (AHK v1 UIA library)

    A lot of modifications have been added to the original UIA framework, such as custom methods for elements (eg element.Click())

    Usage:
    All main UIA methods and properties can be accessed through the UIA variable.
        Eg UIA.GetRootElement()
    Additionally some extra variables are initialized:
        UIA.IUIAutomationVersion contains the version number of IUIAutomation interface
        UIA.TrueCondition contains a TrueCondition
        UIA.TreeWalkerTrue contains a TreeWalker with the TrueCondition
    UIA is initialized only once, on the first use of UIA.
        The initalized IUIAutomation version depends on the system, but the most recent version is automatically used.
        If the version needs to be limited, then set the IUIAutomationMaxVersion global variable before the first use of UIA.
        On initialization, SPI_SETSCREENREADER is also called to notify the system of UIA use. This is needed for some programs (such as VSCode).

    UIAutomation constants and enumerations are also available in the UIA variable. Eg. UIA.Property.Name contains the UIA_NamePropertyId value.
    Microsoft documentation for constants and enumerations:
        UI Automation Constants: https://docs.microsoft.com/en-us/windows/win32/winauto/uiauto-entry-constants
        UI Automation Enumerations: https://docs.microsoft.com/en-us/windows/win32/winauto/uiauto-entry-enumerations
*/
/*
    Questions:
    - if method returns a SafeArray, should we return a Wrapped SafeArray, Raw SafeArray, or AHK Array. Currently we return wrapped AHK arrays for SafeArrays. Although SafeArrays are more convenient to loop over, this causes more confusion in users who are not familiar with SafeArrays (questions such as why are they 0-indexed not 1-indexed, why doesnt for k, v in SafeArray work properly etc).
    - on UIA Interface conversion methods, how should the data be returned? wrapped/extracted or raw? should raw data be a ByRef param?
    - Cached Members?
    - UIA Element existance - dependent on window being visible (non minimized), and also sometimes Elements are lazily generated (eg Microsoft Teams, when a meeting is started then the toolbar buttons (eg Mute, react) aren't visible to UIA, but hovering over them with the cursor or calling ElementFromPoint causes Teams to generate and make them visible to UIA.
    - better way of supporting differing versions of IUIAutomation (version 2, 3, 4)
    - Get methods vs property getter: currently we use properties when the item stores data, fetching the data is "cheap" and when it doesn't have side-effects, and in computationally expensive cases use Get...().
    - should ElementFromHandle etc methods have activateChromiumAccessibility set to True or False? Currently is True, because Chromium apps are very common, and checking whether its on should be relatively fast.

    Design choices:
    - ElementArrays are converted to AHK arrays automatically. This is because speed-testing has shown
      that they are either equal, or AHK array comes on top by far. The situation where it loses to the
      native one is when we need to get exactly one element from the array and won't use it more. This
      is optimized by using the native ElementArray in cases of Element[integer].

    To-do:
    - Better error handling
*/
global IUIAutomationMaxVersion := 7

if !A_IsCompiled && A_LineFile = A_ScriptFullPath
    UIA.Viewer()

class UIA {
/**
 * First use of UIA variable initiates UIA, UIA.IUIAutomationVersion, UIA.TrueCondition and
 * UIA.TreeWalkerTrue. Also enables screen reader with SPI_SETSCREENREADER.
 * Initialized IUIAutomation version can be altered with changing the global IUIAutomationMaxVersion
 * variable, which by default is set to the latest available UIA version.
 */
static __New() {
    static __IID := {
        IUIAutomation:"{30cbe57d-d9d0-452a-ab13-7ac5ac4825ee}",
        IUIAutomation2:"{34723aff-0c9d-49d0-9896-7ab52df8cd8a}",
        IUIAutomation3:"{73d768da-9b51-4b89-936e-c209290973e7}",
        IUIAutomation4:"{1189c02a-05f8-4319-8e21-e817e3db2860}",
        IUIAutomation5:"{25f700c8-d816-4057-a9dc-3cbdee77e256}",
        IUIAutomation6:"{aae072da-29e3-413d-87a7-192dbf81ed10}",
        IUIAutomation7:"{29de312e-83c6-4309-8808-e8dfcb46c3c2}"
    }
    global IUIAutomationMaxVersion
    A_PtrSize = 4 ? DllCall("user32.dll\SystemParametersInfo", "uint", 0x0046, "uint", 0, "uint", 0, "ptr*", &screenreader:=0) : DllCall("user32.dll\SystemParametersInfo", "uint", 0x0046, "uint", 0, "ptr*", &screenreader:=0) ; SPI_GETSCREENREADER
    if !screenreader
        A_PtrSize = 4 ? DllCall("user32.dll\SystemParametersInfo", "uint", 0x0046, "uint", 0, "uint", 0, "ptr*", &screenreader:=0) : DllCall("user32.dll\SystemParametersInfo", "uint", 0x0047, "uint", 1, "int", 0, "uint", 2) ; SPI_SETSCREENREADER
    this.IUIAutomationVersion := IUIAutomationMaxVersion+1, this.ptr := 0
    while (--this.IUIAutomationVersion > 1) {
        if !__IID.HasOwnProp("IUIAutomation" this.IUIAutomationVersion)
            continue
        try {
            this.ptr := ComObjValue(this.__ := ComObject("{e22ad333-b25f-460c-83d0-0581107395c9}", __IID.IUIAutomation%(this.IUIAutomationVersion)%))
            break
        }
    }
    ; If all else fails, try the first IUIAutomation version
    if !this.HasOwnProp("ptr") || (this.HasOwnProp("ptr") && !this.ptr)
        this.ptr := ComObjValue(this.__ := ComObject("{ff48dba4-60ef-4201-aa87-54103eef594e}", "{30cbe57d-d9d0-452a-ab13-7ac5ac4825ee}"))
    UIA.TrueCondition := UIA.CreateTrueCondition(), UIA.TreeWalkerTrue := UIA.CreateTreeWalker(UIA.TrueCondition)
    ; Define some properties that shouldn't be included in the value->name Map
    UIA.Property[30000], UIA.Property.T := 30003, UIA.Property.ControlType := 30003, UIA.Property.N := 30005, UIA.Property.CN := 30012, UIA.Property.A := 30011
}
static __Delete() {
    try UIA.RemoveAllEventHandlers()
}

; ---------- IUIAutomation constants and enumerations. ----------

class Enumeration {
    ; This is enables getting property names from values using the array style
    __Item[param] {
        get {
            local k, v
            if !this.HasOwnProp("__CachedValues") {
                this.__CachedValues := Map()
                for k, v in this.OwnProps()
                    this.__CachedValues[v] := k
            }
            if this.__CachedValues.Has(param)
                return this.__CachedValues[param]
            throw UnsetItemError("Property item `"" param "`" not found!", -2)
        }
    }
    HasValue(val) {
        if !this.HasOwnProp("__CachedValues")
            try this[0]
        if this.__CachedValues.Has(val)
            return this.__CachedValues[val]
        return 0
    }
}

; Access properties with UIA.property.subproperty (UIA.Type.Button)
; To get the property name from value, use the array style: UIA.property[value] (UIA.Type[50000] == "Button")

; enum MatchMode Contains string comparison options used in various methods involving element comparison with condition. 
static MatchMode := {StartsWith:1, Substring:2, Exact:3, RegEx:"RegEx", base:UIA.Enumeration.Prototype}
; enum CaseSense Contains CaseSense options used in various methods involving element comparison with condition.
static CaseSense := {Off:0, On:1, Default:1, base:UIA.Enumeration.Prototype}
; enum Type (alias ControlType) Contains UI element types, which are used to identify the capabilities of a control and to determine how to interact with it.
static Type := {Button:50000,Calendar:50001,CheckBox:50002,ComboBox:50003,Edit:50004,Link:50005, Hyperlink:50005,Image:50006,ListItem:50007,List:50008,Menu:50009,MenuBar:50010,MenuItem:50011,ProgressBar:50012,RadioButton:50013,ScrollBar:50014,Slider:50015,Spinner:50016,StatusBar:50017,Tab:50018,TabItem:50019,Text:50020,ToolBar:50021,ToolTip:50022,Tree:50023,TreeItem:50024,Custom:50025,Group:50026,Thumb:50027,DataGrid:50028,DataItem:50029,Document:50030,SplitButton:50031,Window:50032,Pane:50033,Header:50034,HeaderItem:50035,Table:50036,TitleBar:50037,Separator:50038,SemanticZoom:50039,AppBar:50040, base:UIA.Enumeration.Prototype}
static ControlType := UIA.Type ; Alias definition
; enum Pattern Contains interface names used to control a particular aspect of a control's functionality. These can be used to retrieve information about a particular capability of the control, or to manipulate a particular aspect of the control's behavior.
static Pattern := {Invoke: 10000, Selection: 10001, Value: 10002, RangeValue: 10003, Scroll: 10004, ExpandCollapse: 10005, Grid: 10006, GridItem: 10007, MultipleView: 10008, Window: 10009, SelectionItem: 10010, Dock: 10011, Table: 10012, TableItem: 10013, Text: 10014, Toggle: 10015, Transform: 10016, ScrollItem: 10017, LegacyIAccessible: 10018, ItemContainer: 10019, VirtualizedItem: 10020, SynchronizedInput: 10021, ObjectModel: 10022, Annotation: 10023, Text2:10024, Styles: 10025, Spreadsheet: 10026, SpreadsheetItem: 10027, Transform2: 10028, TextChild: 10029, Drag: 10030, DropTarget: 10031, TextEdit: 10032, CustomNavigation: 10033, Selection2: 10034, base:UIA.Enumeration.Prototype}
; enum Event Contains event types evoked by changes in the user interface. Listeners to these can be registered with CreateEventHandler.
static Event := {ToolTipOpened:20000,ToolTipClosed:20001,StructureChanged:20002,MenuOpened:20003,AutomationPropertyChanged:20004,AutomationFocusChanged:20005,AsyncContentLoaded:20006,MenuClosed:20007,LayoutInvalidated:20008,Invoke_Invoked:20009,SelectionItem_ElementAddedToSelection:20010,SelectionItem_ElementRemovedFromSelection:20011,SelectionItem_ElementSelected:20012,Selection_Invalidated:20013,Text_TextSelectionChanged:20014,Text_TextChanged:20015,Window_WindowOpened:20016,Window_WindowClosed:20017,MenuModeStart:20018,MenuModeEnd:20019,InputReachedTarget:20020,InputReachedOtherElement:20021,InputDiscarded:20022,SystemAlert:20023,LiveRegionChanged:20024,HostedFragmentRootsInvalidated:20025,Drag_DragStart:20026,Drag_DragCancel:20027,Drag_DragComplete:20028,DropTarget_DragEnter:20029,DropTarget_DragLeave:20030,DropTarget_Dropped:20031,TextEdit_TextChanged:20032,TextEdit_ConversionTargetChanged:20033,Changes:20034,Notification:20035,ActiveTextPositionChanged:20036, base:UIA.Enumeration.Prototype}
; enum Property Contains property names and ids that expose properties on UI Automation elements
static Property := {RuntimeId:30000,BoundingRectangle:30001,ProcessId:30002,ControlType:30003,Type:30003,LocalizedControlType:30004, LocalizedType:30004,Name:30005,AcceleratorKey:30006,AccessKey:30007,HasKeyboardFocus:30008,IsKeyboardFocusable:30009,IsEnabled:30010,AutomationId:30011,ClassName:30012,HelpText:30013,ClickablePoint:30014,Culture:30015,IsControlElement:30016,IsContentElement:30017,LabeledBy:30018,IsPassword:30019,NativeWindowHandle:30020,ItemType:30021,IsOffscreen:30022,Orientation:30023,FrameworkId:30024,IsRequiredForForm:30025,ItemStatus:30026,IsDockPatternAvailable:30027,IsExpandCollapsePatternAvailable:30028,IsGridItemPatternAvailable:30029,IsGridPatternAvailable:30030,IsInvokePatternAvailable:30031,IsMultipleViewPatternAvailable:30032,IsRangeValuePatternAvailable:30033,IsScrollPatternAvailable:30034,IsScrollItemPatternAvailable:30035,IsSelectionItemPatternAvailable:30036,IsSelectionPatternAvailable:30037,IsTablePatternAvailable:30038,IsTableItemPatternAvailable:30039,IsTextPatternAvailable:30040,IsTogglePatternAvailable:30041,IsTransformPatternAvailable:30042,IsValuePatternAvailable:30043,IsWindowPatternAvailable:30044,ValueValue:30045,Value:30045,ValueIsReadOnly:30046,RangeValueValue:30047,RangeValueIsReadOnly:30048,RangeValueMinimum:30049,RangeValueMaximum:30050,RangeValueLargeChange:30051,RangeValueSmallChange:30052,ScrollHorizontalScrollPercent:30053,ScrollHorizontalViewSize:30054,ScrollVerticalScrollPercent:30055,ScrollVerticalViewSize:30056,ScrollHorizontallyScrollable:30057,ScrollVerticallyScrollable:30058,SelectionSelection:30059,SelectionCanSelectMultiple:30060,SelectionIsSelectionRequired:30061,GridRowCount:30062,GridColumnCount:30063,GridItemRow:30064,GridItemColumn:30065,GridItemRowSpan:30066,GridItemColumnSpan:30067,GridItemContainingGrid:30068,DockDockPosition:30069,ExpandCollapseExpandCollapseState:30070,MultipleViewCurrentView:30071,MultipleViewSupportedViews:30072,WindowCanMaximize:30073,WindowCanMinimize:30074,WindowWindowVisualState:30075,WindowWindowInteractionState:30076,WindowIsModal:30077,WindowIsTopmost:30078,SelectionItemIsSelected:30079,SelectionItemSelectionContainer:30080,TableRowHeaders:30081,TableColumnHeaders:30082,TableRowOrColumnMajor:30083,TableItemRowHeaderItems:30084,TableItemColumnHeaderItems:30085,ToggleToggleState:30086,TransformCanMove:30087,TransformCanResize:30088,TransformCanRotate:30089,IsLegacyIAccessiblePatternAvailable:30090,LegacyIAccessibleChildId:30091,LegacyIAccessibleName:30092,LegacyIAccessibleValue:30093,LegacyIAccessibleDescription:30094,LegacyIAccessibleRole:30095,LegacyIAccessibleState:30096,LegacyIAccessibleHelp:30097,LegacyIAccessibleKeyboardShortcut:30098,LegacyIAccessibleSelection:30099,LegacyIAccessibleDefaultAction:30100,AriaRole:30101,AriaProperties:30102,IsDataValidForForm:30103,ControllerFor:30104,DescribedBy:30105,FlowsTo:30106,ProviderDescription:30107,IsItemContainerPatternAvailable:30108,IsVirtualizedItemPatternAvailable:30109,IsSynchronizedInputPatternAvailable:30110,OptimizeForVisualContent:30111,IsObjectModelPatternAvailable:30112,AnnotationAnnotationTypeId:30113,AnnotationAnnotationTypeName:30114,AnnotationAuthor:30115,AnnotationDateTime:30116,AnnotationTarget:30117,IsAnnotationPatternAvailable:30118,IsTextPattern2Available:30119,StylesStyleId:30120,StylesStyleName:30121,StylesFillColor:30122,StylesFillPatternStyle:30123,StylesShape:30124,StylesFillPatternColor:30125,StylesExtendedProperties:30126,IsStylesPatternAvailable:30127,IsSpreadsheetPatternAvailable:30128,SpreadsheetItemFormula:30129,SpreadsheetItemAnnotationObjects:30130,SpreadsheetItemAnnotationTypes:30131,IsSpreadsheetItemPatternAvailable:30132,Transform2CanZoom:30133,IsTransformPattern2Available:30134,LiveSetting:30135,IsTextChildPatternAvailable:30136,IsDragPatternAvailable:30137,DragIsGrabbed:30138,DragDropEffect:30139,DragDropEffects:30140,IsDropTargetPatternAvailable:30141,DropTargetDropTargetEffect:30142,DropTargetDropTargetEffects:30143,DragGrabbedItems:30144,Transform2ZoomLevel:30145,Transform2ZoomMinimum:30146,Transform2ZoomMaximum:30147,FlowsFrom:30148,IsTextEditPatternAvailable:30149,IsPeripheral:30150,IsCustomNavigationPatternAvailable:30151,PositionInSet:30152,SizeOfSet:30153,Level:30154,AnnotationTypes:30155,AnnotationObjects:30156,LandmarkType:30157,LocalizedLandmarkType:30158,FullDescription:30159,FillColor:30160,OutlineColor:30161,FillType:30162,VisualEffects:30163,OutlineThickness:30164,CenterPoint:30165,Rotation:30166,Size:30167,IsSelectionPattern2Available:30168,Selection2FirstSelectedItem:30169,Selection2LastSelectedItem:30170,Selection2CurrentSelectedItem:30171,Selection2ItemCount:30173,IsDialog:30174, base:UIA.Enumeration.Prototype}
; enum PropertyVariantType Internally used enum, mapping property ids to variant types
static PropertyVariantType := Map(30000,0x2003,30001,0x2005,30002,3,30003,3,30004,8,30005,8,30006,8,30007,8,30008,0xB,30009,0xB,30010,0xB,30011,8,30012,8,30013,8,30014,0x2005,30015,3,30016,0xB,30017,0xB,30018,0xD,30019,0xB,30020,3,30021,8,30022,0xB,30023,3,30024,8,30025,0xB,30026,8,30027,0xB,30028,0xB,30029,0xB,30030,0xB,30031,0xB,30032,0xB,30033,0xB,30034,0xB,30035,0xB,30036,0xB,30037,0xB,30038,0xB,30039,0xB,30040,0xB,30041,0xB,30042,0xB,30043,0xB,30044,0xB,30045,8,30046,0xB,30047,5,30048,0xB,30049,5,30050,5,30051,5,30052,5,30053,5,30054,5,30055,5,30056,5,30057,0xB,30058,0xB,30059,0x200D,30060,0xB,30061,0xB,30062,3,30063,3,30064,3,30065,3,30066,3,30067,3,30068,0xD,30069,3,30070,3,30071,3,30072,0x2003,30073,0xB,30074,0xB,30075,3,30076,3,30077,0xB,30078,0xB,30079,0xB,30080,0xD,30081,0x200D,30082,0x200D,30083,0x2003,30084,0x200D,30085,0x200D,30086,3,30087,0xB,30088,0xB,30089,0xB,30090,0xB,30091,3,30092,8,30093,8,30094,8,30095,3,30096,3,30097,8,30098,8,30099,0x200D,30100,8,30101,8,30102,8,30103,0xB,30104,0xD,30105,0xD,30106,0xD,30107,8,30108,0xB,30109,0xB,30110,0xB,30111,0xB,30112,0xB,30113,3,30114,8,30115,8,30116,8,30117,0xD,30118,0xB,30119,0xB,30120,3,30121,8,30122,3,30123,8,30124,8,30125,3,30126,8,30127,0xB,30128,0xB,30129,8,30130,0x200D,30131,0x2003,30132,0xB,30133,0xB,30134,0xB,30135,3,30136,0xB,30137,0xB,30138,0xB,30139,8,30140,0x2008,30141,0xB,30142,8,30143,0x2008,30144,0x200D,30145,5,30146,5,30147,5,30148,0x200D,30149,0xB,30150,0xB,30151,0xB,30152,3,30153,3,30154,3,30155,0x2003,30156,0x2003,30157,3,30158,8,30159,8,30160,3,30161,0x2003,30162,3,30163,3,30164,0x2005,30165,0x2005,30166,5,30167,0x2005,30168,0xB)
static PropertyVariantTypeBSTR := Map(30004,8,30005,8,30006,8,30007,8,30011,8,30012,8,30013,8,30021,8,30024,8,30026,8,30045,8,30092,8,30093,8,30094,8,30097,8,30098,8,30100,8,30101,8,30102,8,30107,8,30114,8,30115,8,30116,8,30121,8,30123,8,30124,8,30126,8,30129,8,30139,8,30142,8,30158,8,30159,8)
; enum TextAttribute Contains format and style properties (text attributes) of textual content
static TextAttribute := {AnimationStyle:40000,BackgroundColor:40001,BulletStyle:40002,CapStyle:40003,Culture:40004,FontName:40005,FontSize:40006,FontWeight:40007,ForegroundColor:40008,HorizontalTextAlignment:40009,IndentationFirstLine:40010,IndentationLeading:40011,IndentationTrailing:40012,IsHidden:40013,IsItalic:40014,IsReadOnly:40015,IsSubscript:40016,IsSuperscript:40017,MarginBottom:40018,MarginLeading:40019,MarginTop:40020,MarginTrailing:40021,OutlineStyles:40022,OverlineColor:40023,OverlineStyle:40024,StrikethroughColor:40025,StrikethroughStyle:40026,Tabs:40027,TextFlowDirections:40028,UnderlineColor:40029,UnderlineStyle:40030,AnnotationTypes:40031,AnnotationObjects:40032,StyleName:40033,StyleId:40034,Link:40035,IsActive:40036,SelectionActiveEnd:40037,CaretPosition:40038,CaretBidiMode:40039,LineSpacing:40040,BeforeParagraphSpacing:40041,AfterParagraphSpacing:40042,SayAsInterpretAs:40043, base:UIA.Enumeration.Prototype}
; enum AttributeVariantType Internally used enum, mapping TextAttribute ids to variant types
static AttributeVariantType := {40000:3,40001:3,40002:3,40003:3,40004:3,40005:8,40006:5,40007:3,40008:3,40009:3,40010:5,40011:5,40012:5,40013:0xB,40014:0xB,40015:0xB,40016:0xB,40017:0xB,40018:5,40019:5,40020:5,40021:5,40022:3,40023:3,40024:3,40025:3,40026:3,40027:0x2005,40028:3,40029:3,40030:3,40031:0x2003,40032:0x200D,40033:8,40034:3,40035:0xD,40036:0xB,40037:3,40038:3,40039:3,40040:8,40041:5,40042:5,40043:8}
; enum AnnotationType Contains values that are used to identify types of annotations in a document.
static AnnotationType := {Unknown:60000,SpellingError:60001,GrammarError:60002,Comment:60003,FormulaError:60004,TrackChanges:60005,Header:60006,Footer:60007,Highlighted:60008,Endnote:60009,Footnote:60010,InsertionChange:60011,DeletionChange:60012,MoveChange:60013,FormatChange:60014,UnsyncedChange:60015,EditingLockedChange:60016,ExternalChange:60017,ConflictingChange:60018,Author:60019,AdvancedProofingIssue:60020,DataValidationError:60021,CircularReferenceError:60022,Mathematics:60023, base:UIA.Enumeration.Prototype}
; enum Style Contains values used to identify the visual style of text in a document.
static Style := {Custom:70000,Heading1:70001,Heading2:70002,Heading3:70003,Heading4:70004,Heading5:70005,Heading6:70006,Heading7:70007,Heading8:70008,Heading9:70009,Title:70010,Subtitle:70011,Normal:70012,Emphasis:70013,Quote:70014,BulletedList:70015,NumberedList:70016, base:UIA.Enumeration.Prototype}
; enum LandmarkType Contains values used to identify landmark types.
static LandmarkType := {Custom:80000,Form:80001,Main:80002,Navigation:80003,Search:80004, base:UIA.Enumeration.Prototype}
; enum HeadingLevel Contains values to indicate the heading level of a UIA element
static HeadingLevel := {None:80050, 1:80051, 2:80052, 3:80053, 4:80054, 5:80055, 6:80056, 7:80057, 8:80058, 9:80059, base:UIA.Enumeration.Prototype}
; enum Change Contains values used to identify UIA change information.
static Change := {Summary:90000, base:UIA.Enumeration.Prototype}
; enum Metadata Contains values used to identify metadata types in a document.
static Metadata := {SayAsInterpretAs:100000, base:UIA.Enumeration.Prototype}
; enum AsyncContentLoadedState Contains values that describe the progress of asynchronous loading of content.
static AsyncContentLoadedState := {Beginning:0, Progress:1, Completed:2, base:UIA.Enumeration.Prototype}
; enum AutomationIdentifierType Deprecated: Contains values used in the UiaLookupId function.
static AutomationIdentifierType := {Property:0,Pattern:1,Event:2,Type:3,ControlType:3,TextAttribute:4,LandmarkType:5,Annotation:6,Changes:7,Style:7, base:UIA.Enumeration.Prototype}
; enum ConditionType Contains values that specify a type of UIA condition.
static ConditionType := {True:0,False:1,Property:2,And:3,Or:4,Not:5, base:UIA.Enumeration.Prototype}
; enum EventArgsType Contains values that specify the event type described by a UiaEventArgs structure.
static EventArgsType := {Simple:0,PropertyChanged:1,StructureChanged:2,AsyncContentLoaded:3,WindowClosed:4,TextEditTextChanged:5,Changes:6,Notification:7,ActiveTextPositionChanged:8,StructuredMarkup:9, base:UIA.Enumeration.Prototype}
; enum AutomationElementMode Contains values that specify the type of reference to use when returning UIA elements. This is used in CreateCacheRequest.
static AutomationElementMode := {None:0, Full:1, base:UIA.Enumeration.Prototype}
; enum CoalesceEventsOptions Contains possible values for the CoalesceEvents property, which indicates whether to receive all events, or a subset where duplicate events are detected and filtered.
static CoalesceEventsOptions := {Disabled:0, Enabled:1, base:UIA.Enumeration.Prototype}
; enum ConnectionRecoveryBehaviorOptions Contains possible values for the ConnectionRecoveryBehavior property, which indicates whether an accessible technology client adjusts provider request timeouts when the provider is non-responsive.
static ConnectionRecoveryBehaviorOptions := {Disabled:0, Enabled:1, base:UIA.Enumeration.Prototype}
; enum PropertyConditionFlags Contains values used in creating property conditions with CreatePropertyConditionEx. In condition objects, these can be used with the "flags" key.
static PropertyConditionFlags := {None:0, IgnoreCase:1, MatchSubstring:2, IgnoreCaseMatchSubstring:3, base:UIA.Enumeration.Prototype}
; enum TreeScope Contains values that specify the scope of various operations in the UIA tree.
static TreeScope := {None: 0, Element: 1, Children: 2, Family:3, Descendants: 4, Subtree: 7, Parent: 8, Ancestors: 16, base:UIA.Enumeration.Prototype}
; enum TreeTraversalOptions Contains values that can be used to customize tree navigation order.
static TreeTraversalOptions := {Default:0, PostOrder:1, LastToFirstOrder:2, LastToFirstPostOrder:3, base:UIA.Enumeration.Prototype}
; enum TreeTraversalDirection Not currently used.
static TreeTraversalDirection := {Up:0, Down:1, Left:2, Right:3, Next:3, Previous:2, FirstChild:1, LastChild:4, Parent:0, Normalize:5}


; enum ActiveEnd Contains possible values for the SelectionActiveEnd text attribute, which indicates the location of the caret relative to a text range that represents the currently selected text.
static ActiveEnd := {None:0,Start:1,End:2, base:UIA.Enumeration.Prototype}
; enum AnimationStyle Contains values for the AnimationStyle text attribute.
static AnimationStyle := {None:0,LasVegasLights:1,BlinkingBackground:2,SparkleText:3,MarchingBlackAnts:4,MarchingRedAnts:5,Shimmer:6,Other:-1, base:UIA.Enumeration.Prototype}
; enum BulletStyle Contains values for the BulletStyle text attribute.
static BulletStyle := {None:0,HollowRoundBullet:1,FilledRoundBullet:2,HollowSquareBullet:3,FilledSquareBullet:4,DashBullet:5,Other:-1, base:UIA.Enumeration.Prototype}
; enum CapStyle Contains values that specify the value of the CapStyle text attribute.
static CapStyle := {None:0,SmallCap:1,AllCap:2,AllPetiteCaps:3,PetiteCaps:4,Unicase:5,Titling:6,Other:-1, base:UIA.Enumeration.Prototype}
; enum CaretBidiMode Contains possible values for the CaretBidiMode text attribute, which indicates whether the caret is in text that flows from left to right, or from right to left.
static CaretBidiMode := {LTR:0,RTL:1, base:UIA.Enumeration.Prototype}
; enum CaretPosition Contains possible values for the CaretPosition text attribute, which indicates the location of the caret relative to a line of text in a text range.
static CaretPosition := {Unknown:0,EndOfLine:1,BeginningOfLine:2, base:UIA.Enumeration.Prototype}
; enum DockPosition Contains values that specify the location of a docking window represented by the Dock control pattern.
static DockPosition := {Top:0,Left:1,Bottom:2,Right:3,Fill:4,None:5, base:UIA.Enumeration.Prototype}
; enum ExpandCollapseState Contains values that specify the state of a UI element that can be expanded and collapsed.
static ExpandCollapseState := {Collapsed:0,Expanded:1,PartiallyExpanded:2,LeafNode:3, base:UIA.Enumeration.Prototype}
; enum FillType Contains values for the FillType attribute.
static FillType := {None:0,Color:1,Gradient:2,Picture:3,Pattern:4, base:UIA.Enumeration.Prototype}
; enum FlowDirection Contains values for the TextFlowDirections text attribute.
static FlowDirection := {Default:0,RightToLeft:1,BottomToTop:2,Vertical:4, base:UIA.Enumeration.Prototype}
; enum LiveSetting Contains possible values for the LiveSetting property. This property is implemented by provider elements that are part of a live region.
static LiveSetting := {Off:0,Polite:1,Assertive:2, base:UIA.Enumeration.Prototype}
; enum NavigateDirection Contains values used to specify the direction of navigation within the Microsoft UI Automation tree.
static NavigateDirection := {Parent:0,NextSibling:1,PreviousSibling:2,FirstChild:3,LastChild:4, base:UIA.Enumeration.Prototype}
; enum NotificationKind Defines values that indicate the type of a notification event, and a hint to the listener about the processing of the event.
static NotificationKind := {ItemAdded:0,ItemRemoved:1,ActionCompleted:2,ActionAborted:3,Other:4, base:UIA.Enumeration.Prototype}
; enum NotificationProcessing Defines values that indicate how a notification should be processed.
static NotificationProcessing := {ImportantAll:0,ImportantMostRecent:1,All:2,MostRecent:3,CurrentThenMostRecent:4, base:UIA.Enumeration.Prototype}
; enum OrientationType Contains values that specify the orientation of a control.
static OrientationType := {None:0,Horizontal:1,Vertical:2, base:UIA.Enumeration.Prototype}
; enum OutlineStyles Contains values for the OutlineStyle text attribute.
static OutlineStyles := {None:0,Outline:1,Shadow:2,Engraved:4,Embossed:8, base:UIA.Enumeration.Prototype}
; enum ProviderOptions
static ProviderOptions := {ClientSideProvider:1,ServerSideProvider:2,NonClientAreaProvider:4,OverrideProvider:8,ProviderOwnsSetFocus:10,UseComThreading:20,RefuseNonClientSupport:40,HasNativeIAccessible:80,UseClientCoordinates:100, base:UIA.Enumeration.Prototype}
; enum RowOrColumnMajor Contains values that specify whether data in a table should be read primarily by row or by column.
static RowOrColumnMajor := {RowMajor:0,ColumnMajor:1,Indeterminate:2, base:UIA.Enumeration.Prototype}
; enum SayAsInterpretAs Defines the values that indicate how a text-to-speech engine should interpret specific data.
static SayAsInterpretAs := {None:0,Spell:1,Cardinal:2,Ordinal:3,Number:4,Date:5,Time:6,Telephone:7,Currency:8,Net:9,Url:10,Address:11,Name:13,Media:14,Date_MonthDayYear:15,Date_DayMonthYear:16,Date_YearMonthDay:17,Date_YearMonth:18,Date_MonthYear:19,Date_DayMonth:20,Date_MonthDay:21,Date_Year:22,Time_HoursMinutesSeconds12:23,Time_HoursMinutes12:24,Time_HoursMinutesSeconds24:25,Time_HoursMinutes24:26, base:UIA.Enumeration.Prototype}
; enum ScrollAmount Contains values that specify the direction and distance to scroll.
static ScrollAmount := {NoScroll:-1,LargeDecrement:0,SmallDecrement:1,NoAmount:2,LargeIncrement:3,SmallIncrement:4, base:UIA.Enumeration.Prototype}
; enum StructureChangeType Contains values that specify the type of change in the Microsoft UI Automation tree structure.
static StructureChangeType := {ChildAdded:0,ChildRemoved:1,ChildrenInvalidated:2,ChildrenBulkAdded:3,ChildrenBulkRemoved:4,ChildrenReordered:5, base:UIA.Enumeration.Prototype}
; enum SupportedTextSelection Contains values that specify the supported text selection attribute.
static SupportedTextSelection := {None:0,Single:1,Multiple:2, base:UIA.Enumeration.Prototype}
; enum SynchronizedInputType Contains values that specify the type of synchronized input.
static SynchronizedInputType := {KeyUp:1,KeyDown:2,LeftMouseUp:4,LeftMouseDown:8,RightMouseUp:10,RightMouseDown:20, base:UIA.Enumeration.Prototype}
; enum TextDecorationLineStyle Contains values that specify the OverlineStyle, StrikethroughStyle, and UnderlineStyle text attributes.
static TextDecorationLineStyle := {None:0, Single:1, WordsOnly:2, Double:3, Dot:4, Dash:5, DashDot:6, DashDotDot:7, Wavy:8, ThickSingle:9, DoubleWavy:11, ThickWavy:12, LongDash:13, ThickDash:14, ThickDashDot:15, ThickDashDotDot:16, ThickDot:17, ThickLongDash:18, Other:-1, base:UIA.Enumeration.Prototype}
; enum TextEditChangeType Describes the text editing change being performed by controls when text-edit events are raised or handled.
static TextEditChangeType := {None:0,AutoCorrect:1,Composition:2,CompositionFinalized:3,AutoComplete:4, base:UIA.Enumeration.Prototype}
; enum TextPatternRangeEndpoint Contains values that specify the endpoints of a text range.
static TextPatternRangeEndpoint := {Start:0,End:1, base:UIA.Enumeration.Prototype}
; enum TextUnit Contains values that specify units of text for the purposes of navigation.
static TextUnit := {Character:0,Format:1,Word:2,Line:3,Paragraph:4,Page:5,Document:6, base:UIA.Enumeration.Prototype}
; enum ToggleState Contains values that specify the toggle state of a Microsoft UI Automation element that implements the Toggle control pattern.
static ToggleState := {Off:0,On:1,Indeterminate:2, base:UIA.Enumeration.Prototype}
; enum ZoomUnit Contains possible values for the IUIAutomationTransformPattern2::ZoomByUnit method, which zooms the viewport of a control by the specified unit.
static ZoomUnit := {NoAmount:0,LargeDecrement:1,SmallDecrement:2,LargeIncrement:3,SmallIncrement:4, base:UIA.Enumeration.Prototype}
; enum WindowVisualState Contains values that specify the visual state of a window.
static WindowVisualState := {Normal:0,Maximized:1,Minimized:2, base:UIA.Enumeration.Prototype}
; enum WindowInteractionState Contains values that specify the current state of the window for purposes of user interaction.
static WindowInteractionState := {Running:0,Closing:1,ReadyForUserInteraction:2,BlockedByModalWindow:3,NotResponding:4, base:UIA.Enumeration.Prototype}

; MSAA/Acc enums
class LegacyIAccessible extends UIA.Enumeration {
    static SelectionFlag := {None:0x0, TakeFocus:0x1, TakeSelection:0x2, ExtendSelection:0x4, AddSelection:0x8, RemoveSelection:0x10, Valid:0x1f}
    static Role := {TitleBar:0x1,MenuBar:0x2, ScrollBar:0x3, Grip:0x4, Sound:0x5, Cursor:0x6, Caret:0x7, Alert:0x8, Window:0x9, Client:0xa, MenuPopup:0xb, MenuItem:0xc, ToolTip:0xd, Application:0xe, Document:0xf, Pane:0x10, Chart:0x11, Dialog:0x12, Border:0x13, Grouping:0x14, Separator:0x15, Toolbar:0x16, StatusBar:0x17, Table:0x18, ColumnHeader:0x19, RowHeader:0x1a, Column:0x1b, Row:0x1c, Cell:0x1d, Link:0x1e, HelpBalloon:0x1f, Character:0x20, List:0x21, ListItem:0x22, Outline:0x23, OutlineItem:0x24, PageTab:0x25, PropertyPage:0x26, Indicator:0x27, Graphic:0x28, StaticText:0x29, Text:0x2a, PushButton:0x2b, CheckButton:0x2c, RadioButton:0x2d, ComboBox:0x2e, Droplist:0x2f, Progressbar:0x30, Dial:0x31, HotkeyField:0x32, Slider:0x33, SpinButton:0x34, Diagram:0x35, Animation:0x36, Equation:0x37, ButtonDropdown:0x38, ButtonMenu:0x39, ButtonDropdownGrid:0x3a, Whitespace:0x3b, PageTabList:0x3c, Clock:0x3d, SplitButton:0x3e, IPAddress:0x3f, OutlineButton:0x40}
    static State := {Normal:0, Unavailable:0x1, Selected:0x2, Focused:0x4, Pressed:0x8, Checked:0x10, Mixed:0x20, Indeterminate:0x20, ReadOnly:0x40, HotTracked:0x80, Default:0x100, Expanded:0x200, Collapsed:0x400, Busy:0x800, Floating:0x1000, Marqueed:0x2000, Animated:0x4000, Invisible:0x8000, Offscreen:0x10000, Sizeable:0x20000, Moveable:0x40000, SelfVoicing:0x80000, Focusable:0x100000, Selectable:0x200000, Linked:0x400000, Traversed:0x800000, MultiSelectable:0x1000000, ExtSelectable:0x2000000, Alert_Low:0x4000000, Alert_Medium:0x8000000, Alert_High:0x10000000, Protected:0x20000000, Valid:0x7fffffff}
}

; ---------- UIA Properties ----------

; Check whether a certain version of UIAutomation is available
static IsIUIAutomation2Available := VerCompare(A_OSVersion, ">=6.2.9200")
static IsIUIAutomation3Available := VerCompare(A_OSVersion, ">=6.3.9600")
static IsIUIAutomation4Available := VerCompare(A_OSVersion, ">=10.0.14393")
static IsIUIAutomation5Available := VerCompare(A_OSVersion, ">=10.0.14393")
static IsIUIAutomation6Available := VerCompare(A_OSVersion, ">=10.0.17763")

; Check whether a certain version of UIAutomation Element is available
static IsIUIAutomationElement2Available := VerCompare(A_OSVersion, ">=6.2.9200")
static IsIUIAutomationElement3Available := VerCompare(A_OSVersion, ">=6.3.9600")
static IsIUIAutomationElement4Available := VerCompare(A_OSVersion, ">=10")
static IsIUIAutomationElement5Available := VerCompare(A_OSVersion, ">=10.0.15063")
static IsIUIAutomationElement6Available := VerCompare(A_OSVersion, ">=10.0.15063")
static IsIUIAutomationElement7Available := VerCompare(A_OSVersion, ">=10.0.15063")
static IsIUIAutomationElement8Available := VerCompare(A_OSVersion, ">=10.0.17134")
static IsIUIAutomationElement9Available := VerCompare(A_OSVersion, ">=10.0.17763")

; Retrieves a predefined TreeWalker made with the TrueCondition
static TreeWalkerTrue := ""

; Retrieves a predefined condition that selects all elements.
static TrueCondition := ""

; Retrieves a static token object representing a property or text attribute that is not supported. This property is read-only.
; This object can be used for comparison with the results from UIA.IUIAutomationElement,,GetPropertyValue or IUIAutomationTextRange,,GetAttributeValue.
static ReservedNotSupportedValue {
    get {
        local notSupportedValue
        return (ComCall(54, this, "ptr*", &notSupportedValue := 0), ComValue(0xd, notSupportedValue))
    }
}

; Retrieves a static token object representing a text attribute that is a mixed attribute. This property is read-only.
; The object retrieved by IUIAutomation,,ReservedMixedAttributeValue can be used for comparison with the results from IUIAutomationTextRange,,GetAttributeValue to determine if a text range contains more than one value for a particular text attribute.
static ReservedMixedAttributeValue {
    get {
        local mixedAttributeValue
        return (ComCall(55, this, "ptr*", &mixedAttributeValue := 0), ComValue(0xd, mixedAttributeValue))
    }
}
; Retrieves an IUIAutomationTreeWalker interface used to discover control elements.
static ControlViewWalker {
    get {
        static walker := (ComCall(14, this, "ptr*", &walker := 0), walker?UIA.IUIAutomationTreeWalker(walker):"")
        return walker
    }
}

; Retrieves an IUIAutomationTreeWalker interface used to discover content elements.
static ContentViewWalker {
    get {
        static walker := (ComCall(15, this, "ptr*", &walker := 0), walker?UIA.IUIAutomationTreeWalker(walker):"")
        return walker
    }
}

; Retrieves a tree walker object used to traverse an unfiltered view of the UI Automation tree.
static RawViewWalker {
    get {
        static walker := (ComCall(16, this, "ptr*", &walker := 0), walker?UIA.IUIAutomationTreeWalker(walker):"")
        return walker
    }
}

; Retrieves a predefined IUIAutomationCondition interface that selects all UI elements in an unfiltered view.
static RawViewCondition {
    get {
        static condition := (ComCall(17, this, "ptr*", &condition := 0), condition?UIA.IUIAutomationCondition(condition):"")
        return condition
    }
}

; Retrieves a predefined IUIAutomationCondition interface that selects control elements.
static ControlViewCondition {
    get {
        static condition := (ComCall(18, this, "ptr*", &condition := 0), condition?UIA.IUIAutomationCondition(condition):"")
        return condition
    }
}

; Retrieves a predefined IUIAutomationCondition interface that selects content elements.
static ContentViewCondition {
    get {
        static condition := (ComCall(19, this, "ptr*", &condition := 0), condition?UIA.IUIAutomationCondition(condition):"")
        return condition
    }
}

; ---------- IUIAutomation2 properties ----------

; Specifies whether calls to UI Automation control pattern methods automatically set focus to the target element. Default is True.
static AutoSetFocus {
    get {
        local out
        return (ComCall(58, this,  "int*", &out:=0), out)
    }
    set => ComCall(59, this,  "int", Value)
}
; Specifies the length of time that UI Automation will wait for a provider to respond to a client request for an automation element. Default is 20000ms (20 seconds), minimum seems to be 50ms.
static ConnectionTimeout {
    get {
        local out
        return (ComCall(60, this,  "int*", &out:=0), out)
    }
    set => ComCall(61, this,  "int", Value) ; Minimum seems to be 50 (ms?)
}
; Specifies the length of time that UI Automation will wait for a provider to respond to a client request for information about an automation element. Default is 2000ms (2 seconds), minimum seems to be 50ms.
static TransactionTimeout {
    get {
        local out
        return (ComCall(62, this,  "int*", &out:=0), out)
    }
    set => ComCall(63, this,  "int", Value)
}

; ---------- IUIAutomation6 properties ----------

; Indicates whether an accessible technology client adjusts provider request timeouts when the provider is non-responsive.
ConnectionRecoveryBehavior {
    get {
        local out
        return (ComCall(73, this,  "int*", &out), out)
    }
    set => ComCall(74, this,  "int", value)
}
; Gets or sets whether an accessible technology client receives all events, or a subset where duplicate events are detected and filtered.
CoalesceEvents {
    get {
        local out
        return (ComCall(75, this,  "int*", &out:=0), out)
    }
    set => ComCall(76, this,  "int", value)
}

; ---------- IUIAutomation methods ----------

/**
 * Encodes an array of conditions consisting of only Type and index properties to an UIA path,
 * which is a string of characters/numbers/symbols in base64 encoding.
 * @param path The array of conditions
 * @returns {String}
 */
static EncodePath(path) {
    /*
        FYI, this is probably the most disgusting algorithm I have ever created.

        It goes like this:
        The input (path variable) is an array of conditions, which can only have the Type property and an index.
        This gets encoded into a string of characters. This is a base64 character set of A-Z, a-z,
            0-9, and /?<>= with the exception of letters "p" and "P". This is to maintain backwards
            compatability with the WalkTree paths, where "p" signifies "parent".
        Now, since there are 45 different Types, I've allocated the first 50 encoding characters
            (hopefully no more that 5 will be added in the future to UIA) to the Types.
        If the condition contains an index as well, then the start of an index is signaled by an
            encoding character 50 to 59. 50 means index 2, because index 1 doesn't have to be encoded (it's the default value).
            Then the next symbols will be added in base15 to calculate the final number.
            Negative indices are 60 to 64, and also the next symbols will be subtracted in base15
            to calculate the final index.
        Why only 10 symbols for indices 2-11, yet 5 for negative ones? No particular reason other
            than it seems pragmatic to include more positive integers than negative to be encoded
            with only 1 character. Currently UIAViewer doesn't even use negative indices, users
            may create them themselves.
        Note that this encoding doesn't allow any other properties (eg AutomationId, Name etc),
            although this support might be added in later versions.

        Example: "VE0q" => [{Type:"Document"}, {Type:"ScrollBar"}, {Type:"Button", index:2}]
            "V" corresponds in Base64IntToChar to 31 which is Type Document, "E" is ScrollBar,
            "0" is Button, "q" is 50 which is the first index number, and positive indices start with 2.
    */
    local out, i
    static Base64IntToChar := Map(0,'0',1,'1',2,'2',3,'3',4,'4',5,'5',6,'6',7,'7',8,'8',9,'9',10,'A',11,'B',12,'C',13,'D',14,'E',15,'F',16,'G',17,'H',18,'I',19,'J',20,'K',21,'L',22,'M',23,'N',24,'O',25,'Q',26,'R',27,'S',28,'T',29,'U',30,'V',31,'W',32,'X',33,'Y',34,'Z',35,'a',36,'b',37,'c',38,'d',39,'e',40,'f',41,'g',42,'h',43,'i',44,'j',45,'k',46,'l',47,'m',48,'n',49,'o',50,'q',51,'r',52,'s',53,'t',54,'u',55,'v',56,'w',57,'x',58,'y',59,'z',60,'/',61,'?',62,'<',63,'>',64,'=')
    if !(path is Array)
        path := [path]
    out := ""
    for cond in path {
        t := cond.HasOwnProp("T") ? cond.t : cond.HasOwnProp("Type") ? cond.Type : cond.HasOwnProp("ControlType") ? cond.ControlType : -1
        if t = -1
            throw ValueError("Encodable path requires a Type", -1)
        if !(IsInteger(t) && t < 50)
            t := UIA.TypeValidation.Type(t) - 50000
        out .= Base64IntToChar[t]
        i := cond.HasOwnProp("i") ? cond.i : cond.HasOwnProp("index") ? cond.index : 1
        if i != 0 && i != 1 {
            ; 50 = index 2
            ; 60 = index -1
            ; 61 = index -2
            ; 62 = index -3
            ; 63 = index -4
            ; 64 = index -5
            if i > 1 {
                i -= 2, factor := 10
                Loop {
                    if A_index = 1 {
                        out .= Base64IntToChar[50 + (module := Mod(i, factor))]
                    } else {
                        out .= Base64IntToChar[50 + (module := Mod(i, factor*15))//factor]
                        factor := factor * 15
                    }
                    i -= module
                } Until i = 0
            } else {
                i := -i - 1
                out .= Base64IntToChar[60 + (module := Mod(i, 5))]
                i -= module, factor := 5
                Loop {
                    if A_index > 1 {
                        out .= Base64IntToChar[50 + (module := Mod(i, factor*15))//factor]
                        i -= module, factor := factor*15
                    }
                } Until i = 0
            }
        }
    }
    return out
}

/**
 * Decodes an UIA path to an array of conditions (consisting of only Type and index properties).
 * @param path A string UIA path
 * @returns {Array}
 */
static DecodePath(path) {
    static Base64CharToInt := Map('0',0,'1',1,'2',2,'3',3,'4',4,'5',5,'6',6,'7',7,'8',8,'9',9,'A',10,'B',11,'C',12,'D',13,'E',14,'F',15,'G',16,'H',17,'I',18,'J',19,'K',20,'L',21,'M',22,'N',23,'O',24,'Q',25,'R',26,'S',27,'T',28,'U',29,'V',30,'W',31,'X',32,'Y',33,'Z',34,'a',35,'b',36,'c',37,'d',38,'e',39,'f',40,'g',41,'h',42,'i',43,'j',44,'k',45,'l',46,'m',47,'n',48,'o',49,'q',50,'r',51,'s',52,'t',53,'u',54,'v',55,'w',56,'x',57,'y',58,'z',59,'/',60,'?',61,'<',62,'>',63,'=',64)
    local out := [], calculatingIndex := 0, cond := ""
    loop parse path {
        num := Base64CharToInt[A_LoopField]
        if calculatingIndex != 0 && num < 50
            calculatingIndex := 0
        if num > 49 && calculatingIndex = 0 {
            cond.DefineProp("i", {value:num < 60 ? num-48 : 59-num}) ; 50 => index 2 (index 1 would not exist) ; 60 => index -1
            calculatingIndex := num < 60 ? 1 : -1
            continue
        }
        if calculatingIndex {
            if calculatingIndex > 0 {
                cond.i += (num-50)*10*15**(calculatingIndex-1)
                calculatingIndex++
            } else {
                cond.i -= (num-50)*5*15**(-calculatingIndex-1)
                calculatingIndex--
            }
        } else {
            if cond
                out.Push(cond)
            cond := {Type:50000+num}
        }
    }
    if cond
        out.Push(cond)
    return out
}

static RuntimeIdToString(runtimeId) {
    local str := "", v
    for v in runtimeId
        str .= "." Format("{:X}", v)
    return LTrim(str, ".")
}

static RuntimeIdFromString(str) {
    local t := StrSplit(str, "."), v, arr := ComObjArray(3, t.Length)
    for v in t
        arr[A_Index - 1] := Integer("0x" v)
    return arr
}

/**
 * Filters elements from an element array if "function" evaluates to True
 * @param elementArray Array of elements
 * @param function A function that accepts one parameter (an element) and validates it against some condition.
 * @returns {Array}
 */
static Filter(elementArray, function) {
    if !InStr(Type(elementArray), "Array")
        throw TypeError("elementArray must be an Array or IUIAutomationElementArray", -1)
    ret := []
    for el in elementArray
        if function(el)
            ret.Push(el)
    return ret
}

/**
 * Finds the first element matching a condition from an AHK array
 * @param elementArray The array to search
 * @param condition The condition the element must match
 * @param index Looks for the n-th element matching the condition. Negative index starts the search from the end.
 * @param startingElement Optional: The element to start the search with
 * @param cacheRequest Optional: A cache request to cache the found element with
 * @param cached Whether the condition match uses cached properties or not
 * @returns {UIA.IUIAutomationElement}
 */
static FindElementFromArray(elementArray, condition, index:=1, startingElement:=0, cacheRequest:=0, cached:=False) {
    local out, scope := 0, order := 0
    condition := UIA.IUIAutomationElement.__ExtractConditionNamedParameters(condition, &scope, &order, &startingElement, , &index)
    condition := UIA.TypeValidation.Condition(condition), index := UIA.TypeValidation.Integer(index, "Index"), startingElement := UIA.TypeValidation.Element(startingElement)
    if index = 0
        throw ValueError("Condition index cannot be 0", -1)
    if startingElement
        startingElement := UIA.RuntimeIdToString(startingElement.GetRuntimeId())
    if index > 0 {
        for element in elementArray {
            if (startingElement ? (startingElement = UIA.RuntimeIdToString(element.GetRuntimeId()) ? !(startingElement := "") : 0) : 1) && element.ValidateCondition(condition, cached) && --index = 0
                return cacheRequest ? element.BuildUpdatedCache(cacheRequest) : element
        }
    } else {
        index := -index, len := elementArray.Length + 1
        Loop len-1 {
            element := elementArray[len-A_index]
            if (startingElement ? (startingElement = UIA.RuntimeIdToString(element.GetRuntimeId()) ? !(startingElement := "") : 0) : 1) && element.ValidateCondition(condition, cached) && --index = 0
                return cacheRequest ? element.BuildUpdatedCache(cacheRequest) : element
        }
    }
    throw TargetError("An element matching the condition was not found", -1)
}
static FindCachedElementFromArray(elementArray, condition, index:=1, startingElement:=0) => UIA.FindElementFromArray(elementArray, condition, index, startingElement,, 1)

/**
 * Clears all highlights created by Element.Highlight
 */
static ClearAllHighlights() => UIA.IUIAutomationElement.Prototype.Highlight("clearall")

/**
 * Create a property condition from an AHK object
 * @param condition Object or Array that contains property conditions.  
 * * A single property condition consists of an object where the key is the property name, and value is the property value:  
 *     `{Name:"Test"}` => Creates a condition where the Name property must match "Test" exactly  
 * * Everything inside {} is an "and" condition  
 *     `{Type:"Button", Name:"Something"}` => Name must match "Something" AND Type must be Button  
 * * Everything inside [] is an "or" condition  
 *     `[{Name:"Test"}, {Name:"Something"}]` Name must match "Test" OR Name must match "Something"  
 * * Object key "not" creates a not condition  
 *
 * * matchmode key (short form: mm) can be one of UIA.MatchMode values (except StartsWith and RegEx) and defines the MatchMode:  
 *     2=can contain anywhere in string; 3=exact match  
 * * casesense key (short form: cs) defines case sensitivity (default: case-sensitive/True): True=case sensitive; False=case insensitive
 *
 * @param value If this is set then UIA.CreatePropertyCondition will be called instead, with "condition" being the Property name.
 * @param flags If `value` was set then this will be passed to UIA.CreatePropertyConditionEx
 *
 * #### Examples:
 * * `CreateCondition({Name:"Test"})` => Name must match "Test" exactly, case-sensitive
 * * `CreateCondition({Type:"Button", or:[Name:"Something", Name:"Else"]})` => Name must match "Something" OR "Else", AND Type must be Button
 * * `CreateCondition({Name:"Test", cs:0, mm:2})` => Name must contain "Test" and is case-insensitive
 * * `CreateCondition("Type", "Button")` => Type must be Button
 *
 * @returns {UIA.IUIAutomationCondition}
 */
static CreateCondition(condition, value?, flags?) {
    local propertyId, match
    if IsSet(value) {
        propertyId := UIA.TypeValidation.Property(condition)
        if propertyId = 30003 && !IsNumber(value) {
            if UIA.Type.HasOwnProp(value)
                value := UIA.Type.%value%
            else if value is String && RegExMatch(value, "\d{5}", &match:="") && Integer(match[]) >= 50000
                value := Integer(match[])
            else
                throw ValueError("Type '" value '" in a non-existant type!', -1)
        }
        if IsSet(flags) && (UIA.TypeValidation.PropertyConditionFlags(flags)) && UIA.PropertyVariantTypeBSTR.Has(propertyId)
            return UIA.CreatePropertyConditionEx(propertyId, UIA.TypeValidation.String(value, "Value"), flags)
        return UIA.CreatePropertyCondition(propertyId, value)
    }
    return UIA.__ConditionBuilder(UIA.TypeValidation.Condition(condition))
}

static __CreateRawCondition(condition) {
    local i, nonUIAEncountered
    for i in ["index", "i", "scope", "order", "startingElement"]
        if condition.HasOwnProp(i)
            throw ValueError("This method doesn't support indexes nor named arguments", -2, '"' i '" can be used with FindElement(s) instead')
    condition := UIA.__ConditionBuilder(UIA.TypeValidation.Condition(condition), &nonUIAEncountered:=0)
    if nonUIAEncountered = 1
        throw ValueError("This method doesn't support conditions with Cached properties", -2, "Instead use FindElement(s) or FindCachedElement(s)")
    else if nonUIAEncountered = 2
        throw ValueError("This method doesn't support conditions with MatchMode RegEx nor StartsWith", -2, "Only MatchModes Exact and SubString are allowed. Use FindElement(s) instead, which supports all MatchModes.")
    return condition
}

static __ConditionBuilder(obj, &nonUIAEncountered?) {
    local sanitizeMM, operator, cs, mm, flags, count, k, v, t, i, j, val, match
    sanitizeMM := False
    switch Type(obj) {
        case "Object":
            obj := obj.Clone() ; Speed-testing showed that not cloning (getting props with HasOwnProp and then ignoring them in the loop) is as fast as cloning.
            obj.DeleteProp("index"), obj.DeleteProp("i")
            operator := obj.DeleteProp("operator") || obj.DeleteProp("op") || "and"
            cs := obj.HasOwnProp("casesense") ? obj.casesense : obj.HasOwnProp("cs") ? obj.cs : 1
            obj.DeleteProp("casesense"), obj.DeleteProp("cs")
            mm := obj.DeleteProp("matchmode") || obj.DeleteProp("mm") || 3
            if !IsInteger(mm)
                mm := UIA.MatchMode.%mm%
            if !IsInteger(cs)
                cs := UIA.CaseSense.%cs%
            if IsSet(nonUIAEncountered) {
                if (mm = "RegEx" || mm = 1)
                    nonUIAEncountered := True, sanitizeMM := True
            } else { ; If creating a "pure" UIA condition, allow only Exact and Substring matchmodes
                if !((mm = 3) || (mm = 2))
                    throw TypeError("MatchMode can only be Exact or Substring (3 or 2) when creating UIA conditions.", -1, "MatchMode 1 and RegEx are allowed with FindElement, FindElements, and ElementFromPath methods.")
            }
            flags := ((mm = 3 ? 0 : 2) | (!cs)) || obj.DeleteProp("flags") || 0
            count := ObjOwnPropCount(obj), obj := obj.OwnProps()
        case "Array":
            operator := "or", flags := 0, count := obj.Length
        default:
            throw TypeError("Invalid parameter type", -3)
    }
    if count = 0
        return UIA.TrueCondition
    arr := ComObjArray(0xd, count), i := 0
    for k, v in obj {
        try k := IsNumber(k) ? Integer(k) : UIA.Property.%k%
        if IsInteger(k) && k >= 30000 {
            switch Type(v), 0 {
                case "Array":
                    if (UIA.PropertyVariantType[k] & 0x2000)
                        v := UIA.AHKArrayToSafeArray(v, UIA.PropertyVariantType[k] & ~0x2000)
                    else if !(sanitizeMM && UIA.PropertyVariantTypeBSTR.Has(k)) || mm = 1 {
                        ; Creating an "or" condition with same matchmode and casesense
                        if !v.Length
                            throw ValueError("Invalid condition: `"or`" condition cannot be empty", -2)
                        orArr := ComObjArray(0xd, v.Length)
                        for j, val in v
                            orArr[j-1] := (mm = 1 ? UIA.CreateCondition(k, val, !cs | 2) : UIA.CreateCondition(k, val, flags))[]
                        t := UIA.CreateOrConditionFromArray(orArr)
                        arr[i++] := t[]
                        continue
                    }
                case "String":
                    if k = 30000
                        v := UIA.RuntimeIdFromString(v)
                    else if k = 30003 {
                        if UIA.Type.HasOwnProp(v)
                            v := UIA.Type.%v%
                        else if RegExMatch(v, "\d{5}", &match:="") && match[] >= 50000
                            v := Integer(match[])
                        else
                            throw ValueError("Type '" v '" in a non-existant type!', -1)
                    }
                case "Integer":
                    if k = 30003 && v < 50000
                        v += 50000
            }
            if sanitizeMM && UIA.PropertyVariantTypeBSTR.Has(k) {
                t := mm = 1 ? UIA.CreateCondition(k, v, !cs | 2) : UIA.CreateNotCondition(UIA.CreatePropertyCondition(k, ""))
                arr[i++] := t[]
            } else if (k >= 30000) {
                t := UIA.CreateCondition(k, v, flags)
                arr[i++] := t[]
            }
        } else if IsObject(v) && !(SubStr(Type(v), 1, 6) = "ComObj") && !v.HasOwnProp("ptr") {
            t := UIA.__ConditionBuilder(v, &nonUIAEncountered?)
            if k = "not" || operator = "not"
                t := UIA.CreateNotCondition(t)
            arr[i++] := t[]
            continue
        } else
            throw ValueError("Invalid condition encountered: " k, -2)
    }
    if count = 1
        return operator = "not" ? UIA.CreateNotCondition(t) : t
    switch operator, false {
        case "and":
            return UIA.CreateAndConditionFromArray(arr)
        case "or":
            return UIA.CreateOrConditionFromArray(arr)
        case "not":
            return UIA.CreateNotCondition(UIA.CreateAndConditionFromArray(arr))
        default:
            return UIA.CreateFalseCondition()
    }
}

/**
 * If the element from ElementFromHandle doesn't contain the content of the window, and the window in
 * question is a Chromium app (Window Spy shows "ahk_class Chrome_WidgetWin_1"), then this can be used
 * to get the element for the content (using Chrome_RenderWidgetHostHWND1 control).
 * @param winTitle A window title or other criteria identifying the target window. See AHK WinTitle.
 * @param activateChromiumAccessibility Whether to check if the window is a Chromium application
 * and if it is then try to activate accessibility. Default: True
 * @param timeOut How long to wait for confirmation that accessibility is enabled in the app after
 * trying to enable accessibility. Default: 500ms
 * @param cacheRequest Optional: a cache request object.
 * @returns {UIA.IUIAutomationElement}
 */
static ElementFromChromium(winTitle:="", activateChromiumAccessibility:=True, timeOut:=500, cacheRequest?) {
    if activateChromiumAccessibility
        return UIA.ActivateChromiumAccessibility(winTitle, 1, timeOut, cacheRequest?)
    try cHwnd := ControlGetHwnd("Chrome_RenderWidgetHostHWND1", winTitle)
    if !IsSet(cHwnd) || !cHwnd
        return
    return UIA.ElementFromHandle(cHwnd, cacheRequest?, False)
}
/**
 * In some setups Chromium-based renderers don't react to UIA calls by enabling accessibility,
 * so we need to send the WM_GETOBJECT message to the renderer control to enable accessibility.
 * ActivateChromiumAccessibility does that (only once per window) and then returns the content element.
 * Explanation why this works: https://www.chromium.org/developers/design-documents/accessibility/#TOC-How-Chrome-detects-the-presence-of-Assistive-Technology
 * @param winTitle A window title or other criteria identifying the target window. See AHK WinTitle.
 * @param forceActivation By default a window is activated only once per run. If this is set to True
 *     then the window is activated unconditionally.
 * @param timeOut How long to wait for confirmation that accessibility is enabled in the app after
 * trying to enable accessibility. Default: 500ms
 * @param cacheRequest Optional: a cache request object.
 * @returns {UIA.IUIAutomationElement}
 * @credit malcev, rommmcek
 */
static ActivateChromiumAccessibility(winTitle:="", forceActivation:=False, timeOut:=500, cacheRequest?) {
    static activatedHwnds := Map(), WM_GETOBJECT := 0x003D
    local _
    hwnd := IsInteger(winTitle) ? winTitle : WinExist(winTitle)
    if activatedHwnds.Has(hwnd) && !ForceActivation
        return 1
    activatedHwnds[hWnd] := 1, cHwnd := 0
    try cHwnd := ControlGetHwnd("Chrome_RenderWidgetHostHWND1", winTitle)
    if !IsSet(cHwnd) || !cHwnd
        return
    SendMessage(WM_GETOBJECT := 0x003D, 0, 1,, cHwnd)
    if (cEl := UIA.ElementFromHandle(cHwnd, cacheRequest?, False)) {
        try _ := cEl.Name ; it doesn't work without calling CurrentName (at least in Skype)
        try {
            if (cEl.Type == 50030) {
                waitTime := A_TickCount + timeOut
                while (!cEl.Value && (A_TickCount < waitTime))
                    Sleep 20
            }
        }
    }
    return cEl
}

; Compares two UI Automation elements to determine whether they represent the same underlying UI element.
static CompareElements(el1, el2) {
    local areSame
    return (ComCall(3, this, "ptr", el1, "ptr", el2, "int*", &areSame := 0), areSame)
}

; Compares two integer arrays containing run-time identifiers (IDs) to determine whether their content is the same and they belong to the same UI element.
static CompareRuntimeIds(runtimeId1, runtimeId2) {
    local areSame
    return (ComCall(4, this, "ptr", runtimeId1, "ptr", runtimeId2, "int*", &areSame := 0), areSame)
}

/**
 * Retrieves the UI Automation element that represents the desktop.
 * @param cacheRequest Optional: a cache request object.
 * @returns {UIA.IUIAutomationElement}
 */
static GetRootElement(cacheRequest?) {
    if IsSet(cacheRequest)
        return UIA.GetRootElementBuildCache(cacheRequest)
    if (ComCall(5, this, "ptr*", &root := 0), root)
        return UIA.IUIAutomationElement(root)
    throw UnsetError("No element returned by " A_ThisFunc, -1)
}

/**
 * Retrieves a UI Automation element for the specified window.
 * @param hwnd WinTitle, window handle, or control handle
 * @param cacheRequest Optional: a cache request object.
 * @param activateChromiumAccessibility Whether to check if the window is a Chromium application
 * and if it is then try to activate accessibility. Default: True.
 * If a VarRef is passed, then that variable will be set to the Chromium Document element (only
 * if the activation was done).
 * @returns {UIA.IUIAutomationElement}
 */
static ElementFromHandle(hwnd:="", cacheRequest?, activateChromiumAccessibility:=True) {
    if !IsInteger(hwnd)
        hwnd := WinExist(hwnd)
    if !hwnd
        throw TargetError("No matching window found", -1)
    if (activateChromiumAccessibility && activateChromiumAccessibility is VarRef && IsObject(retEl := UIA.ActivateChromiumAccessibility(hwnd, cacheRequest?)))
        %activateChromiumAccessibility% := retEl
    if IsSet(cacheRequest)
        return UIA.ElementFromHandleBuildCache(cacheRequest, hwnd)

    if (ComCall(6, this, "ptr", hwnd, "ptr*", &element := 0), element)
        return UIA.IUIAutomationElement(element)
    throw UnsetError("No element returned by " A_ThisFunc, -1)
}
static ElementFromWindow(WinTitle:="", cacheRequest?, activateChromiumAccessibility:=True) => UIA.ElementFromHandle(WinTitle, cacheRequest?, activateChromiumAccessibility)
/**
 * Retrieves the UI Automation element at the specified point on the desktop.
 * @param x x coordinate for the screen point.
 * Omit both x and y to get the element from the current mouse position.
 * @param y y coordinate for the screen point.
 * @param cacheRequest Optional: a cache request object.
 * @param activateChromiumAccessibility Whether to check if the window is a Chromium application
 * and if it is then try to activate accessibility. 
 * If a VarRef is passed, then that variable will be set to the Chromium Document element (only
 * if the activation was done).
 * @returns {UIA.IUIAutomationElement}
 */
static ElementFromPoint(x?, y?, cacheRequest?, activateChromiumAccessibility:=True) {
    if !(IsSet(x) && IsSet(y))
        DllCall("user32.dll\GetCursorPos", "int64P", &pt64:=0)
    else
        pt64 := y << 32 | (x & 0xFFFFFFFF)
    if (activateChromiumAccessibility && activateChromiumAccessibility is VarRef && (hwnd := DllCall("GetAncestor", "UInt", DllCall("user32.dll\WindowFromPoint", "int64",  pt64), "UInt", 2))) { ; hwnd from point by SKAN
        %activateChromiumAccessibility% := UIA.ActivateChromiumAccessibility(hwnd)
    }
    if IsSet(cacheRequest)
        return UIA.ElementFromPointBuildCache(cacheRequest, pt64)
    if (ComCall(7, this, "int64", pt64, "ptr*", &element := 0), element)
        return UIA.IUIAutomationElement(element)
    throw UnsetError("No element returned by " A_ThisFunc, -1)
}
/**
 * Retrieves the smallest UI Automation element at the specified point on the desktop.
 * Regular ElementFromPoint doesn't always return the deepest/smallest element.
 * @param x x coordinate for the screen point.
 * Omit both x and y to get the element from the current mouse position.
 * @param y y coordinate for the screen point.
 * @param element Optional: optionally provide an element for which the search is performed for
 * @param cacheRequest Optional: a cache request object.
 * @returns {UIA.IUIAutomationElement}
 */
static SmallestElementFromPoint(x?, y?, element?, cacheRequest?) {
    if !IsSet(cacheRequest) {
        cacheRequest := UIA.CreateCacheRequest()
        cacheRequest.TreeScope := 5
    }
    cacheRequest.AddProperty("BoundingRectangle")
    if !(IsSet(x) && IsSet(y))
        DllCall("user32.dll\GetCursorPos", "int64P", &pt64:=0), x := 0xFFFFFFFF & pt64, y := pt64 >> 32
    if !IsSet(element)
        element := UIA.ElementFromPoint(x, y, cacheRequest)
    else
        element := element.BuildUpdatedCache(cacheRequest)
    lastArr := [element]
    Loop {
        nextArr := []
        for el in lastArr {
            inEl := UIA.Filter(el.CachedChildren, (fEl) => (rect := fEl.CachedBoundingRectangle, rect.l<=x && rect.r >=x && rect.t <= y && rect.b >= y))
            for e in inEl
                nextArr.Push(e)
        }
        if nextArr.Length = 0
            return lastArr[1]
        lastArr := nextArr
    }
}

/**
 * Retrieves the UI Automation element that has the input focus.
 * @param cacheRequest Optional: a cache request object.
 * @returns {UIA.IUIAutomationElement}
 */
static GetFocusedElement(cacheRequest?) {
    if IsSet(cacheRequest)
        return UIA.GetFocusedElementBuildCache(cacheRequest) 
    if (ComCall(8, this, "ptr*", &element := 0), element)
        return UIA.IUIAutomationElement(element)
    throw UnsetError("No element returned by " A_ThisFunc, -1)
}

; Retrieves the UI Automation element that has the input focus, prefetches the requested properties and control patterns, and stores the prefetched items in the cache.
; This is a raw wrapper, instead use GetRootElement and specify cacheRequest.
static GetRootElementBuildCache(cacheRequest) {
    local root
    if (ComCall(9, this, "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr*", &root := 0), root)
        return UIA.IUIAutomationElement(root)
    throw UnsetError("No element returned by " A_ThisFunc, -1)
}

; Retrieves a UI Automation element for the specified window, prefetches the requested properties and control patterns, and stores the prefetched items in the cache.
; This is a raw wrapper, instead use ElementFromHandle and specify cacheRequest.
static ElementFromHandleBuildCache(cacheRequest, hwnd) {
    local element
    if (ComCall(10, this, "ptr", hwnd, "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr*", &element := 0), element)
        return UIA.IUIAutomationElement(element)
    throw UnsetError("No element returned by " A_ThisFunc, -1)
}

; Retrieves the UI Automation element at the specified point on the desktop, prefetches the requested properties and control patterns, and stores the prefetched items in the cache.
; This is a raw wrapper, instead use ElementFromPoint and specify cacheRequest.
static ElementFromPointBuildCache(cacheRequest, pt) {
    local element
    if (ComCall(11, this, "int64", pt, "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr*", &element := 0), element)
        return UIA.IUIAutomationElement(element)
    throw UnsetError("No element returned by " A_ThisFunc, -1)
}

; Retrieves the UI Automation element that has the input focus, prefetches the requested properties and control patterns, and stores the prefetched items in the cache.
; This is a raw wrapper, instead use GetFocusedElement and specify cacheRequest.
static GetFocusedElementBuildCache(cacheRequest) {
    local element
    if (ComCall(12, this, "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr*", &element := 0), element)
        return UIA.IUIAutomationElement(element)
    throw UnsetError("No element returned by " A_ThisFunc, -1)
}

; Retrieves a tree walker object that can be used to traverse the Microsoft UI Automation tree.
static CreateTreeWalker(pCondition) {
    local walker
    if (ComCall(13, this, "ptr", InStr(Type(pCondition), "Condition") ? pCondition : UIA.__CreateRawCondition(pCondition), "ptr*", &walker := 0), walker)
        return UIA.IUIAutomationTreeWalker(walker)
    throw UnsetError("No TreeWalker returned by " A_ThisFunc, -1)
}

/**
 * Creates a cache request. After obtaining the IUIAutomationCacheRequest interface, use its methods to specify properties and control patterns to be cached when a UI Automation element is obtained.
 * @param properties Optional: an array containing properties that will be added to the CacheRequest
 * @param patterns Optional: an array containing patterns that will be added to the CacheRequest
 * @param scope Optional: set the TreeScope for the CacheRequest (one of UIA.TreeScope values). Default is UIA.TreeScope.Descendants
 * @param mode Optional: set the AutomationElementMode for the CacheRequest (one of UIA.AutomationElementMode values). Default is Full.
 * @param filter Optional: a condition for caching elements. Default is ControlView.
 */
static CreateCacheRequest(properties?, patterns?, scope?, mode?, filter?) {
    local cacheRequest, v
    if cacheRequest := (ComCall(20, this, "ptr*", &cacheRequest := 0), cacheRequest?UIA.IUIAutomationCacheRequest(cacheRequest):"") {
        if IsSet(properties) {
            if Type(properties) = "Object" {
                if properties.HasOwnProp("filter")
                    filter := properties.DeleteProp("filter")
                if properties.HasOwnProp("mode")
                    mode := properties.DeleteProp("mode")
                if properties.HasOwnProp("scope")
                    scope := properties.DeleteProp("scope")
                if properties.HasOwnProp("patterns")
                    patterns := properties.DeleteProp("patterns")
                if properties.HasOwnProp("properties")
                    properties := properties.DeleteProp("properties")
            }
            if properties is Array && properties[1] is String {
                for v in properties
                    cacheRequest.AddProperty(v)
            } else if IsObject(properties) {
                cacheRequest.AddPropertiesFromCondition(properties)
            } else
                throw TypeError("Expected properties argument of type Array or Object, but got " Type(properties), -1)
        }
        if IsSet(patterns) {
            if not patterns is Array
                throw TypeError("Expected patterns argument of type Array, but got " Type(properties), -1)
            for v in patterns
                cacheRequest.AddPattern(v)
        }
        if IsSet(scope)
            cacheRequest.TreeScope := scope
        if IsSet(mode)
            cacheRequest.AutomationElementMode := mode
        if IsSet(filter)
            cacheRequest.TreeFilter := InStr(Type(filter), "Condition") ? filter : UIA.__CreateRawCondition(filter)
    }
    return cacheRequest
}

static CreateTrueCondition() {
    local newCondition
    if (ComCall(21, this, "ptr*", &newCondition := 0), newCondition)
        return UIA.IUIAutomationBoolCondition(newCondition)
    throw UnsetError("No condition returned by " A_ThisFunc, -1)
}

; Creates a condition that is always false.
; This method exists only for symmetry with IUIAutomation.CreateTrueCondition(). A false condition will never enable a match with UI Automation elements, and it cannot usefully be combined with any other condition.
static CreateFalseCondition() {
    local newCondition
    if (ComCall(22, this, "ptr*", &newCondition := 0), newCondition)
        return UIA.IUIAutomationBoolCondition(newCondition)
    throw UnsetError("No condition returned by " A_ThisFunc, -1)
}

; Creates a condition that selects elements that have a property with the specified value.
static CreatePropertyCondition(propertyId, value) {
    local v, newCondition
    if A_PtrSize = 4
        v := UIA.ComVar(value, UIA.PropertyVariantType[propertyId], true), ComCall(23, this, "int", propertyId, "int64", NumGet(v, 'int64'), "int64", NumGet(v, 8, "int64"), "ptr*", &newCondition := 0)
    else
        ComCall(23, this, "int", propertyId, "ptr", UIA.ComVar(value, UIA.PropertyVariantType[propertyId], true), "ptr*", &newCondition := 0)
    if newCondition
        return UIA.IUIAutomationPropertyCondition(newCondition)
    throw Error("Creating property condition failed", -1)
}

; Creates a condition that selects elements that have a property with the specified value, using optional flags.
; This is a raw wrapper, instead use CreateCondition and specify flags.
static CreatePropertyConditionEx(propertyId, value, flags := 0) {
    local v, newCondition
    if A_PtrSize = 4
        v := UIA.ComVar(value, UIA.PropertyVariantType[propertyId], true), ComCall(24, this, "int", propertyId, "int64", NumGet(v, 'int64'), "int64", NumGet(v, 8, "int64"), "int", flags, "ptr*", &newCondition := 0)
    else
        ComCall(24, this, "int", propertyId, "ptr", UIA.ComVar(value, UIA.PropertyVariantType[propertyId], true), "int", flags, "ptr*", &newCondition := 0)
    if newCondition
        return UIA.IUIAutomationPropertyCondition(newCondition)
    throw Error("Creating property condition failed", -1)
}

; The Create**Condition** method calls AddRef on each pointers. This means you can call Release on those pointers after the call to Create**Condition** returns without invalidating the pointer returned from Create**Condition**.
; When you call Release on the pointer returned from Create**Condition**, UI Automation calls Release on those pointers.

; Creates a condition that selects elements that match both of two conditions.
static CreateAndCondition(condition1, condition2) {
    local newCondition
    if (ComCall(25, this, "ptr", condition1, "ptr", condition2, "ptr*", &newCondition := 0), newCondition)
        return UIA.IUIAutomationAndCondition(newCondition)
    throw UnsetError("No condition returned by " A_ThisFunc, -1)
}

; Creates a condition that selects elements based on multiple conditions, all of which must be true.
static CreateAndConditionFromArray(conditions) {
    local newCondition
    if (ComCall(26, this, "ptr", conditions is Array ? UIA.Variant(conditions, 0xd) : conditions, "ptr*", &newCondition := 0), newCondition)
        return UIA.IUIAutomationAndCondition(newCondition)
    throw UnsetError("No condition returned by " A_ThisFunc, -1)
}

; Creates a condition that selects elements based on multiple conditions, all of which must be true.
static CreateAndConditionFromNativeArray(conditions, conditionCount) {
    local newCondition
    if (ComCall(27, this, "ptr", conditions, "int", conditionCount, "ptr*", &newCondition := 0), newCondition)
        return UIA.IUIAutomationAndCondition(newCondition)
    throw UnsetError("No condition returned by " A_ThisFunc, -1)
}

; Creates a combination of two conditions where a match exists if either of the conditions is true.
static CreateOrCondition(condition1, condition2) {
    local newCondition
    if (ComCall(28, this, "ptr", condition1, "ptr", condition2, "ptr*", &newCondition := 0), newCondition)
        return UIA.IUIAutomationOrCondition(newCondition)
    throw UnsetError("No condition returned by " A_ThisFunc, -1)
}

; Creates a combination of two or more conditions where a match exists if any of the conditions is true.
static CreateOrConditionFromArray(conditions) {
    local newCondition
    if (ComCall(29, this, "ptr", conditions is Array ? UIA.Variant(conditions, 0xd) : conditions, "ptr*", &newCondition := 0), newCondition)
        return UIA.IUIAutomationOrCondition(newCondition)
    throw UnsetError("No condition returned by " A_ThisFunc, -1)
}

; Creates a combination of two or more conditions where a match exists if any one of the conditions is true.
static CreateOrConditionFromNativeArray(conditions, conditionCount) {
    local newCondition
    if (ComCall(30, this, "ptr", conditions, "ptr", conditionCount, "ptr*", &newCondition := 0), newCondition)
        return UIA.IUIAutomationOrCondition(newCondition)
    throw UnsetError("No condition returned by " A_ThisFunc, -1)
}

; Creates a condition that is the negative of a specified condition.
static CreateNotCondition(condition) {
    local newCondition
    if (ComCall(31, this, "ptr", condition, "ptr*", &newCondition := 0), newCondition)
        return UIA.IUIAutomationNotCondition(newCondition)
    throw UnsetError("No condition returned by " A_ThisFunc, -1)
}

; Note,  Before implementing an event handler, you should be familiar with the threading issues described in Understanding Threading Issues. http,//msdn.microsoft.com/en-us/library/ee671692(v=vs.85).aspx
; A UI Automation client should not use multiple threads to add or remove event handlers. Unexpected behavior can result if one event handler is being added or removed while another is being added or removed in the same client process.
; It is possible for an event to be delivered to an event handler after the handler has been unsubscribed, if the event is received simultaneously with the request to unsubscribe the event. The best practice is to follow the Component Object Model (COM) standard and avoid destroying the event handler object until its reference count has reached zero. Destroying an event handler immediately after unsubscribing for events may result in an access violation if an event is delivered late.

/**
 * Registers a method that handles Microsoft UI Automation events.
 * @param handler Handler object from UIA.CreateEventHandler()
 * @param element UIA element
 * @param eventId One of UIA.Event values
 * @param scope Optional TreeScope value: Element, Children, Family (Element+Children), Descendants, Subtree (=Element+Descendants). Default is Descendants.
 * @param cacheRequest Optional: cache request object
 */
static AddAutomationEventHandler(handler, element, eventId, scope:=0x4, cacheRequest:=0) => ComCall(32, this, "int", UIA.TypeValidation.Event(eventId), "ptr", UIA.TypeValidation.Element(element), "int", UIA.TypeValidation.TreeScope(scope), "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr", handler)

/**
 * Removes the specified UI Automation event handler.
 * @param handler Handler object from UIA.CreateEventHandler()
 * @param element UIA element
 * @param eventId One of UIA.Event values
 */
static RemoveAutomationEventHandler(handler, element, eventId) => ComCall(33, this, "int", UIA.TypeValidation.Event(eventId), "ptr", UIA.TypeValidation.Element(element), "ptr", handler)

; Registers a method that handles property-changed events.
; The UI item specified by element might not support the properties specified by the propertyArray parameter.
; This method serves the same purpose as UIA.AddPropertyChangedEventHandler, but takes a native array of property identifiers instead of a SAFEARRAY.
; Not needed in this library, use UIA.AddPropertyChangedEventHandler instead.
static AddPropertyChangedEventHandlerNativeArray(handler, element, propertyArray, propertyCount, scope:=0x4, cacheRequest:=0) => ComCall(34, this, "ptr", UIA.TypeValidation.Element(element), "int", UIA.TypeValidation.TreeScope(scope), "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr", handler, "ptr", propertyArray, "int", propertyCount)

/**
 * Registers a method that handles property-changed events.
 * The UI item specified by element might not support the properties specified by the propertyArray parameter.
 * @param handler Handler object from UIA.CreateEventHandler()
 * @param element UIA element
 * @param propertyArray An array of UIA.Property values
 * @param scope Optional TreeScope value: Element, Children, Family (Element+Children), Descendants, Subtree (=Element+Descendants). Default is Descendants.
 * @param cacheRequest Optional: cache request object
 */
static AddPropertyChangedEventHandler(handler, element, propertyArray, scope:=0x4, cacheRequest:=0) {
    local i, SafeArray
    if !IsObject(propertyArray)
        propertyArray := [propertyArray]
    SafeArray:=ComObjArray(0x3,propertyArray.Length)
    for i, propertyId in propertyArray
        SafeArray[i-1]:=propertyId
    ComCall(35, this, "ptr", UIA.TypeValidation.Element(element), "int", UIA.TypeValidation.TreeScope(scope), "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr", handler, "ptr", SafeArray)
}

; Removes a property-changed event handler.
static RemovePropertyChangedEventHandler(handler, element) => ComCall(36, this, "ptr", UIA.TypeValidation.Element(element), "ptr", handler)

/**
 * Registers a method that handles structure-changed events.
 * @param handler Handler object from UIA.CreateEventHandler()
 * @param element UIA element
 * @param scope Optional TreeScope value: Element, Children, Family (Element+Children), Descendants, Subtree (=Element+Descendants). Default is Descendants.
 * @param cacheRequest Optional: cache request object
 */
static AddStructureChangedEventHandler(handler, element, scope:=0x4, cacheRequest:=0) => ComCall(37, this, "ptr", UIA.TypeValidation.Element(element), "int", UIA.TypeValidation.TreeScope(scope), "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr", handler)

; Removes a structure-changed event handler.
static RemoveStructureChangedEventHandler(handler, element) => ComCall(38, this, "ptr", UIA.TypeValidation.Element(element), "ptr", handler)

/**
 * Registers a method that handles focus-changed events.
 * Focus-changed events are system-wide; you cannot set a narrower scope.
 * @param handler Handler object from UIA.CreateEventHandler()
 * @param cacheRequest Optional: cache request object
 */
static AddFocusChangedEventHandler(handler, cacheRequest:=0) => ComCall(39, this, "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr", handler)

; Removes a focus-changed event handler.
static RemoveFocusChangedEventHandler(handler) => ComCall(40, this, "ptr", handler)

; Removes all registered Microsoft UI Automation event handlers.
static RemoveAllEventHandlers() => ComCall(41, this)

; Converts an array of integers to a SAFEARRAY.
static IntNativeArrayToSafeArray(array, arrayCount) {
    local safeArray
    return (ComCall(42, this, "ptr", array, "int", arrayCount, "ptr*", &safeArray := 0), ComValue(0x2003, safeArray))
}

; Converts a SAFEARRAY of integers to an array.
static IntSafeArrayToNativeArray(intArray) {
    local array
    return (ComCall(43, this, "ptr", intArray, "ptr*", &array := 0, "int*", &arrayCount := 0), UIA.NativeArray(array, arrayCount, "int"))
}
; Creates a VARIANT that contains the coordinates of a rectangle.
; The returned VARIANT has a data type of VT_ARRAY | VT_R8.
static RectToVariant(rc) {
    local var
    return (ComCall(44, this, "ptr", rc, "ptr", var := UIA.ComVar()), var)
}

; Converts a VARIANT containing rectangle coordinates to a RECT.
static VariantToRect(var) {
    if A_PtrSize = 4
        ComCall(45, this, "int64", NumGet(var, "int64"), "int64", NumGet(var, 8, "int64"), "ptr", rc := UIA.NativeArray(0, 4, "Int"))
    else
        ComCall(45, this, "ptr", var, "ptr", rc := UIA.NativeArray(0, 4, "Int"))
    return rc
}

; Converts a SAFEARRAY containing rectangle coordinates to an array of type RECT.
static SafeArrayToRectNativeArray(rects) {
    local rectArrayCount
    return (ComCall(46, this, "ptr", rects, "ptr*", &rectArray := 0, "int*", &rectArrayCount := 0), UIA.NativeArray(rectArray, rectArrayCount, "int"))
}

; Creates a instance of a proxy factory object.
; Use the IUIAutomationProxyFactoryMapping interface to enter the proxy factory into the table of available proxies.
static CreateProxyFactoryEntry(factory) {
    local factoryEntry
    if (ComCall(47, this, "ptr", factory, "ptr*", &factoryEntry := 0), factoryEntry)
        return UIA.IUIAutomationProxyFactoryEntry(factoryEntry)
    throw UnsetError("No ProxyFactoryEntry returned by " A_ThisFunc, -1)
}

; Retrieves an object that represents the mapping of Window classnames and associated data to individual proxy factories. This property is read-only.
static ProxyFactoryMapping() {
    local factoryMapping
    if (ComCall(48, this, "ptr*", &factoryMapping := 0), factoryMapping)
        return UIA.IUIAutomationProxyFactoryMapping(factoryMapping)
    throw UnsetError("No ProxyFactoryMapping returned by " A_ThisFunc, -1)
}

; The programmatic name is intended for debugging and diagnostic purposes only. The string is not localized.
; This property should not be used in string comparisons. To determine whether two properties are the same, compare the property identifiers directly.

; Retrieves the registered programmatic name of a property.
static GetPropertyProgrammaticName(property) {
    local name
    return (ComCall(49, this, "int", property, "ptr*", &name := 0), UIA.BSTR(name))
}

; Retrieves the registered programmatic name of a control pattern.
static GetPatternProgrammaticName(pattern) {
    local name
    return (ComCall(50, this, "int", UIA.TypeValidation.Pattern(pattern), "ptr*", &name := 0), UIA.BSTR(name))
}

; This method is intended only for use by Microsoft UI Automation tools that need to scan for properties. It is not intended to be used by UI Automation clients.
; There is no guarantee that the element will support any particular control pattern when asked for it later.

; Retrieves the control patterns that might be supported on a UI Automation element.
static PollForPotentialSupportedPatterns(pElement, &patternIds, &patternNames) {
    ComCall(51, this, "ptr", UIA.TypeValidation.Element(pElement), "ptr*", &patternIds := 0, "ptr*", &patternNames := 0)
    patternIds := UIA.SafeArrayToAHKArray(patternIds, 3), patternNames := UIA.SafeArrayToAHKArray(patternNames, 8)
}

; Retrieves the properties that might be supported on a UI Automation element.
static PollForPotentialSupportedProperties(pElement, &propertyIds, &propertyNames) {
    ComCall(52, this, "ptr", UIA.TypeValidation.Element(pElement), "ptr*", &propertyIds := 0, "ptr*", &propertyNames := 0)
    propertyIds := UIA.SafeArrayToAHKArray(propertyIds, 3), propertyNames := UIA.SafeArrayToAHKArray(propertyNames, 8)
}

; Checks a provided VARIANT to see if it contains the Not Supported identifier.
; After retrieving a property for a UI Automation element, call this method to determine whether the element supports the retrieved property. CheckNotSupported is typically called after calling a property retrieving method such as GetPropertyValue.
static CheckNotSupported(value) {
    if A_PtrSize = 4
        value := UIA.ComVar(value, , true), ComCall(53, this, "int64", NumGet(value, "int64"), "int64", NumGet(value, 8, "int64"), "int*", &isNotSupported := 0)
    else
        ComCall(53, this, "ptr", UIA.ComVar(value, , true), "int*", &isNotSupported := 0)
    return isNotSupported
}


; This method enables UI Automation clients to get UIA.IUIAutomationElement interfaces for accessible objects implemented by a Microsoft Active Accessiblity server.
; This method may fail if the server implements UI Automation provider interfaces alongside Microsoft Active Accessibility support.
; The method returns E_INVALIDARG if the underlying implementation of the Microsoft UI Automation element is not a native Microsoft Active Accessibility server; that is, if a client attempts to retrieve the IAccessible interface for an element originally supported by a proxy object from Oleacc.dll, or by the UIA-to-MSAA Bridge.

; Retrieves a UI Automation element for the specified accessible object from a Microsoft Active Accessibility server.
; Currently not working
static ElementFromIAccessible(accessible, childId:=0) => (InStr(Type(accessible), "IAccessible") ? (ComCall(56, this, "ptr", accessible, "int", accessible.childId, "ptr*", &element := 0), UIA.IUIAutomationElement(element)) : (ComCall(56, this, "ptr", ComObjValue(accessible), "int", childId, "ptr*", &element := 0), UIA.IUIAutomationElement(element)))

; Retrieves a UI Automation element for the specified accessible object from a Microsoft Active Accessibility server, prefetches the requested properties and control patterns, and stores the prefetched items in the cache.
static ElementFromIAccessibleBuildCache(cacheRequest, accessible, childId:=0) => (InStr(Type(accessible), "IAccessible") ? (ComCall(57, this, "ptr", accessible.accessible, "int", accessible.childId, "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr*", &element := 0), UIA.IUIAutomationElement(element)) : (ComCall(57, this, "ptr", accessible, "int", childId, "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr*", &element := 0), UIA.IUIAutomationElement(element)))

; ---------- IUIAutomation3 ----------

/**
 * Registers a method that handles programmatic text-edit events.
 * @param handler Handler object from UIA.CreateEventHandler()
 * @param element UIA element
 * @param textEditChangeType The specific change type to listen for, one of UIA.TextEditChangeType values (None, AutoCorrect, Composition, CompositionFinalized, AutoComplete)
 * @param scope Optional TreeScope value: Element, Children, Family (Element+Children), Descendants, Subtree (=Element+Descendants). Default is Descendants.
 * @param cacheRequest Optional: cache request object
 */
static AddTextEditTextChangedEventHandler(handler, element, textEditChangeType, scope:=0x4, cacheRequest:=0) => (ComCall(64, this,  "ptr", UIA.TypeValidation.Element(element), "int", UIA.TypeValidation.TreeScope(scope), "int", UIA.TypeValidation.TextEditChangeType(textEditChangeType), "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr", handler))
static RemoveTextEditTextChangedEventHandler(handler, element) => ComCall(65, this,  "ptr", UIA.TypeValidation.Element(element), "ptr", handler)

; ---------- IUIAutomation4 ----------

/**
 * Registers a method that handles change events.
 * @param handler Handler object from UIA.CreateEventHandler()
 * @param element UIA element
 * @param changeTypes An array of UIA.Changes values that indicate the change types the event represents.
 * @param scope Optional TreeScope value: Element, Children, Family (Element+Children), Descendants, Subtree (=Element+Descendants). Default is Descendants.
 * @param cacheRequest Optional: cache request object
 */
static AddChangesEventHandler(handler, element, changeTypes, scope:=0x4, cacheRequest:=0) {
    local k, v
    if !IsObject(changeTypes)
        changeTypes := [changeTypes]
    nativeArray := UIA.NativeArray(0, changeTypes.Length, "int")
    for k, v in changeTypes
        NumPut("int", v, nativeArray, (k-1)*4)
    ComCall(66, this,  "ptr", UIA.TypeValidation.Element(element), "int", UIA.TypeValidation.TreeScope(scope), "ptr", nativeArray, "int", changeTypes.Length, "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr", handler)
}
static RemoveChangesEventHandler(handler, element) => (ComCall(67, this,  "ptr", UIA.TypeValidation.Element(element), "ptr", handler))

; ---------- IUIAutomation5 ----------

/**
 * Registers a method that handles notification events.
 * @param handler Handler object from UIA.CreateEventHandler()
 * @param element UIA element
 * @param scope Optional TreeScope value: Element, Children, Family (Element+Children), Descendants, Subtree (=Element+Descendants). Default is Descendants.
 * @param cacheRequest Optional: cache request object
 */
static AddNotificationEventHandler(handler, element, scope:=0x4, cacheRequest:=0) => (ComCall(68, this,  "ptr", UIA.TypeValidation.Element(element), "uint", UIA.TypeValidation.TreeScope(scope), "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr", handler))
static RemoveNotificationEventHandler(handler, element) => (ComCall(69, this,  "ptr", UIA.TypeValidation.Element(element), "ptr", handler))

; ---------- IUIAutomation6 ----------

; Registers one or more event listeners in a single method call.
static CreateEventHandlerGroup() {
    local out
    return (ComCall(70, this,  "ptr*", &out:=0), UIA.IUIAutomationEventHandlerGroup(out))
}
; Registers a collection of event handler methods specified with the IUIAutomation6 CreateEventHandlerGroup.
static AddEventHandlerGroup(handlerGroup, element) => (ComCall(71, this,  "ptr", UIA.TypeValidation.Element(element), "ptr", handlerGroup))
static RemoveEventHandlerGroup(handlerGroup, element) => (ComCall(72, this,  "ptr", UIA.TypeValidation.Element(element), "ptr", handlerGroup))
; Registers a method that handles when the active text position changes.
static AddActiveTextPositionChangedEventHandler(handler, element, scope:=0x4, cacheRequest:=0) => (ComCall(77, this,  "ptr", UIA.TypeValidation.Element(element), "int", UIA.TypeValidation.TreeScope(scope), "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr", handler))
static RemoveActiveTextPositionChangedEventHandler(handler, element) => (ComCall(78, this,  "ptr", UIA.TypeValidation.Element(element), "ptr", handler))

; ---------- IUIAutomation7 ----------
; Has no properties/methods


; ---------- Internal methods and properties ----------


; BSTR wrapper, convert BSTR to AHK string and free it
static BSTR(ptr) {
    static _ := DllCall("LoadLibrary", "str", "oleaut32.dll")
    if ptr {
        s := StrGet(ptr), DllCall("oleaut32\SysFreeString", "ptr", ptr)
        return s
    }
}
static SafeArrayToAHKArray(sArr, varType:=3) {
    local _, v, ret := []
    if IsInteger(sArr)
        sArr := ComValue(0x2000 | varType, sArr)
    for _, v in sArr
        ret.Push(v)
    ret.DefineProp("__Value", {value:sArr})
    ret.DefineProp("ptr", {value:sArr.ptr})
    return ret
}
static AHKArrayToSafeArray(arr, varType:=3) {
    local index, value, cArr
    cArr := ComObjArray(varType, arr.Length)
    for index, value in arr
        cArr[index-1] := value
    return cArr
}
; X can be pt64 as well, in which case Y should be omitted
static WindowFromPoint(X, Y?) { ; by SKAN and Linear Spoon
    return DllCall("GetAncestor", "UInt", DllCall("user32.dll\WindowFromPoint", "Int64", IsSet(Y) ? (Y << 32 | (X & 0xFFFFFFFF)) : X), "UInt", 2)
}

/**
 * Checks whether two rectangles intersect and if they do, then returns an object containing the
 * rectangle of the intersection: {l:left, t:top, r:right, b:bottom}  
 * Note 1: Overlapping area must be at least 1 unit.  
 * Note 2: Second rectangle starting at the edge of the first doesn't count as intersecting:  
 *     {l:100, t:100, r:200, b:200} does not intersect {l:200, t:100, 400, 400}
 * @param l1 x-coordinate of the upper-left corner of the first rectangle
 * @param t1 y-coordinate of the upper-left corner of the first rectangle
 * @param r1 x-coordinate of the lower-right corner of the first rectangle
 * @param b1 y-coordinate of the lower-right corner of the first rectangle
 * @param l2 x-coordinate of the upper-left corner of the second rectangle
 * @param t2 y-coordinate of the upper-left corner of the second rectangle
 * @param r2 x-coordinate of the lower-right corner of the second rectangle
 * @param b2 y-coordinate of the lower-right corner of the second rectangle
 * @returns {Object}
 */
static IntersectRect(l1, t1, r1, b1, l2, t2, r2, b2) {
    rect1 := Buffer(16), rect2 := Buffer(16), rectOut := Buffer(16)
    NumPut("int", l1, "int", t1, "int", r1, "int", b1, rect1)
    NumPut("int", l2, "int", t2, "int", r2, "int", b2, rect2)
    if DllCall("user32\IntersectRect", "Ptr", rectOut, "Ptr", rect1, "Ptr", rect2)
        return {l:NumGet(rectOut, 0, "Int"), t:NumGet(rectOut, 4, "Int"), r:NumGet(rectOut, 8, "Int"), b:NumGet(rectOut, 12, "Int")}
}

; Creates a variant to pass into ComCalls
class Variant {
    __New(Value := unset, VarType := 0xC) {
        local v, i
        static SIZEOF_VARIANT := 8 + (2 * A_PtrSize)
        this.var := Buffer(SIZEOF_VARIANT, 0)
        if VarType != 0xC
            NumPut "ushort", VarType, this.var
        this.owner := True
        if IsSet(Value) {
            if (Type(Value) == "ComVar") {
                this.var := Value.var, this.ref := Value.ref, this.obj := Value, this.owner := False
                return
            }
            if (IsObject(Value)) {
                this.ref := ComValue(0x400C, this.var.ptr)
                if Value is Array {
                    if Value.Length {
                        switch Type(Value[1]) {
                            case "Integer": VarType := 3
                            case "String": VarType := 8
                            case "Float": VarType := 5
                            case "ComValue", "ComObject": VarType := ComObjType(Value[1])
                            default: VarType := 0xC
                        }
                    } else
                        VarType := 0xC
                    ComObjFlags(obj := ComObjArray(VarType, Value.Length), -1), i := 0, this.ref[] := obj
                    for v in Value
                        obj[i++] := v
                    return
                }
            }
        }
        this.ref := ComValue(0x4000 | VarType, this.var.Ptr + (VarType = 0xC ? 0 : 8))
        this.ref[] := Value
    }
    __Delete() => (this.owner ? DllCall("oleaut32\VariantClear", "ptr", this.var) : 0)
    __Item {
        get => this.Type=0xB?-this.ref[]:this.ref[]
        set => this.ref[] := this.Type=0xB?(!value?0:-1):value
    }
    Ptr => this.var.Ptr
    Size => this.var.Size
    Type {
        get => NumGet(this.var, "ushort")
        set {
            if (!this.IsVariant)
                throw PropertyError("VarType is not VT_VARIANT, Type is read-only.", -2)
            NumPut("ushort", Value, this.var)
        }
    }
    IsVariant => ComObjType(this.ref) & 0xC
}

; Construction and deconstruction VARIANT struct
class ComVar {
    /**
     * Construction VARIANT struct, `ptr` property points to the address, `__Item` property returns var's Value
     * @param vVal Values that need to be wrapped, supports String, Integer, Double, Array, ComValue, ComObjArray
     * ### Examples
     * `var1 := ComVar('string'), MsgBox(var1[])`
     *
     * `var2 := ComVar([1,2,3,4], , true)`
     *
     * `var3 := ComVar(ComValue(0xb, -1))`
     * @param vType Variant's type, VT_VARIANT (default)
     * @param convert Convert AHK's array to ComObjArray
     */
    __New(vVal := unset, vType := 0xC, convert := false) {
        local v, i
        static size := 8 + 2 * A_PtrSize
        this.var := Buffer(size, 0), this.owner := true
        this.ref := ComValue(0x4000 | vType, this.var.Ptr + (vType = 0xC ? 0 : 8))
        if vType != 0xC
            NumPut "ushort", vType, this.var
        if IsSet(vVal) {
            if (Type(vVal) == "ComVar") {
                this.var := vVal.var, this.ref := vVal.ref, this.obj := vVal, this.owner := false
            } else {
                if (IsObject(vVal)) {
                    if (vType != 0xC)
                        this.ref := ComValue(0x400C, this.var.ptr)
                    if convert && (vVal is Array) {
                        switch Type(vVal[1]) {
                            case "Integer": vType := 3
                            case "String": vType := 8
                            case "Float": vType := 5
                            case "ComValue", "ComObject": vType := ComObjType(vVal[1])
                            default: vType := 0xC
                        }
                        ComObjFlags(obj := ComObjArray(vType, vVal.Length), -1), i := 0, this.ref[] := obj
                        for v in vVal
                            obj[i++] := v
                    } else
                        this.ref[] := vVal
                } else
                    this.ref[] := vVal
            }
        }
    }
    __Delete() => (this.owner ? DllCall("oleaut32\VariantClear", "ptr", this.var) : 0)
    __Item {
        get => this.ref[]
        set => this.ref[] := value
    }
    Ptr => this.var.Ptr
    Size => this.var.Size
    Type {
        get => NumGet(this.var, "ushort")
        set {
            if (!this.IsVariant)
                throw PropertyError("VarType is not VT_VARIANT, Type is read-only.", -2)
            NumPut("ushort", Value, this.var)
        }
    }
    IsVariant => ComObjType(this.ref) & 0xC
}
; NativeArray is C style array, zero-based index, it has `__Item` and `__Enum` property
class NativeArray {
    __New(ptr, count, type := "ptr") {
        static _ := DllCall("LoadLibrary", "str", "ole32.dll")
        static bits := { UInt: 4, UInt64: 8, Int: 4, Int64: 8, Short: 2, UShort: 2, Char: 1, UChar: 1, Double: 8, Float: 4, Ptr: A_PtrSize, UPtr: A_PtrSize }
        this.size := (this.count := count) * (bit := bits.%type%), this.ptr := ptr || DllCall("ole32\CoTaskMemAlloc", "uint", this.size, "ptr")
        this.DefineProp("__Item", { get: (s, i) => NumGet(s, i * bit, type) })
        this.DefineProp("__Enum", { call: (s, i) => (i = 1 ?
                (i := 0, (&v) => i < count ? (v := NumGet(s, i * bit, type), ++i) : false) :
                    (i := 0, (&k, &v) => (i < count ? (k := i, v := NumGet(s, i * bit, type), ++i) : false))
            ) })
    }
    __Delete() => DllCall("ole32\CoTaskMemFree", "ptr", this)
}

class TypeValidation {
    static __Call(method, args) {
        local val
        if UIA.HasProp(method) { ; Handles enumeration type validation: UIA.TypeValidation.TreeScope(scope)
            val := args[1]
            if IsInteger(val) {
                try UIA.%method%[val]
                catch
                    throw ValueError("UIA." method " does not contain constant `"" val "`"", -2)
                return val is Integer ? val : Integer(val)
            }
            if val is String {
                try return UIA.%method%.%val%
                throw ValueError("UIA." method " does not contain value for `"" val "`"", -2)
            }
            throw TypeError(method " requires parameter with type Integer or String, but received " Type(val), -2)
        } else { ; Handles object type validation: UIA.TypeValidation.Condition(condition)
            if !(val := args[1])
                return val
            if (IsObject(val) && (val is UIA.IUIAutomation%method%)) || (val is ComValue) || (val is Integer)
                return val
            throw TypeError(method " requires parameter with type UIA.IUIAutomation" method ", but was provided type " Type(val), -2)
        }
    }
    static Integer(arg, paramName) {
        if IsInteger(arg)
            return arg is Integer ? arg : Integer(arg)
        throw TypeError(paramName " requires type Integer, but received type " Type(arg), -2)
    }
    static String(arg, paramName) {
        if arg is String
            return arg
        if !(arg is Object)
            return String(arg)
        throw TypeError(paramName " requires type String, but received type " Type(arg), -2)
    }
    static Object(arg, paramName) {
        if arg is Object
            return arg
        throw TypeError(paramName " requires type Object, but received type " Type(arg), -2)
    }
    ; Provide pre-optimized methods for commonly used validations
    static Condition(arg) {
        if !arg || (arg is Array || Type(arg) = "Object" || arg is UIA.IUIAutomationCondition || (arg is ComValue) || (arg is Integer))
            return arg
        throw TypeError("Condition argument requires parameter with type Object or UIA.IUIAutomationCondition, but received " Type(arg), -2)
    }
    static CacheRequest(arg) {
        if !arg || (arg is UIA.IUIAutomationCacheRequest) || (arg is ComValue) || (arg is Integer)
            return arg
        throw TypeError("CacheRequest argument requires parameter with type UIA.IUIAutomationCacheRequest, but received " Type(arg), -2)
    }
    static Element(arg) {
        if !arg || (arg is UIA.IUIAutomationElement) || (arg is ComValue) || (arg is Integer)
            return arg
        throw TypeError("Element argument requires parameter with type UIA.IUIAutomationElement, but received " Type(arg), -2)
    }
    static TreeScope(arg) {
        if IsInteger(arg) {
            if arg < 1 || arg > 31
                throw ValueError("UIA.TreeScope does not contain constant `"" arg "`"", -2)
            return arg is Integer ? arg : Integer(arg)
        } else if arg is String {
            try return UIA.TreeScope.%arg%
            throw ValueError("UIA.TreeScope does not contain value for `"" arg "`"", -2)
        }
        throw TypeError("TreeScope requires parameter with type Integer or String, but received " Type(arg), -2)
    }
    static Type(arg) {
        if IsInteger(arg) {
            if arg < 50 && arg >= 0
                return arg + 50000
            if arg < 50000 || arg > 50050
                throw ValueError("UIA.Type does not contain constant `"" arg "`"", -2)
            return arg is Integer ? arg : Integer(arg)
        } else if arg is String {
            try return UIA.Type.%arg%
            try {
                local match
                RegExMatch(arg, "\d{5}", &match:="") && Integer(match[]) >= 50000
                return Integer(match[])
            }
            throw ValueError("UIA.Type does not contain value for `"" arg "`"", -2)
        }
        throw TypeError("UIA.Type requires parameter with type Integer or String, but received " Type(arg), -2)
    }
    static Property(arg) {
        if IsInteger(arg) {
            try UIA.Property[arg]
            catch
                throw ValueError("UIA.Property does not contain constant `"" arg "`"", -2)
            return arg is Integer ? arg : Integer(arg)
        } else if arg is String {
            try return UIA.Property.%RegexReplace(arg, "^(Cached|Current)",,,1)%
            throw ValueError("UIA.Property does not contain value for `"" arg "`"", -2)
        }
        throw TypeError("Property requires parameter with type Integer or String, but received " Type(arg), -2)
    }
    static Pattern(arg) {
        if IsInteger(arg) {
            try UIA.Pattern[arg]
            catch
                throw ValueError("UIA.Pattern does not contain constant `"" arg "`"", -2)
            return arg is Integer ? arg : Integer(arg)
        } else if arg is String {
            try return UIA.Pattern.%StrReplace(arg, "Pattern")%
            throw ValueError("UIA.Pattern does not contain value for `"" arg "`"", -2)
        }
        throw TypeError("Pattern requires parameter with type Integer or String, but received " Type(arg), -2)
    }
    static TreeTraversalOptions(arg) {
        if IsInteger(arg) {
            try UIA.TreeTraversalOptions[arg]
            catch
                throw ValueError("UIA.TreeTraversalOptions does not contain constant `"" arg "`"", -2)
            return arg is Integer ? arg : Integer(arg)
        } else if arg is String {
            try return UIA.TreeTraversalOptions.%arg%
            try return UIA.TreeTraversalOptions.%arg "Order"%
            throw ValueError("UIA.TreeTraversalOptions does not contain value for `"" arg "`"", -2)
        }
        throw TypeError("Invalid type provided for UIA.TreeTraversalOptions", -2, "Allowed types are Integer and String, but was provided type " Type(arg))
    }
}

; The base class for IUIAutomation objects that return releasable pointers
class IUIAutomationBase {
    __New(ptr) {
        if !ptr
            throw ValueError('Invalid IUnknown interface pointer', -2, this.__Class)
        this.DefineProp("ptr", {Value:ptr})
    }
    __Delete() => this.Release()
    __Item => (ObjAddRef(this.ptr), ComValue(0xd, this.ptr))
    AddRef() => ObjAddRef(this.ptr)
    Release() => this.ptr ? ObjRelease(this.ptr) : 0

    __Get(Name, Params) {
        if this.base.HasOwnProp(NewName := StrReplace(Name, "Current"))
            return this.%NewName%
        throw PropertyError("Property " Name " not found in " this.__Class " Class.",-2,Name)
    }

    __Call(Name, Params) {
        if this.base.HasOwnProp(NewName := StrReplace(Name, "Current"))
            return this.%NewName%(Params*)
        throw MethodError("Method " Name " not found in " this.__Class " Class.",-2,Name)
    }
}
/*
    Exposes methods and properties for a UI Automation element, which represents a UI item.
    Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationelement
*/
class IUIAutomationElement extends UIA.IUIAutomationBase {
    /**
     * Enables array-like use of UIA elements to access child elements.
     * If value is an integer then the nth corresponding child will be returned.
     * A negative integer return the nth last child
     *     Eg. Element[2] ==> returns second child of Element
     *         Element[-1] ==> returns the last child of Element
     * If value is a string, then it will be parsed either as an UIA path that was generated by
     *     UIAViewer, or an comma-separated path of integers/Types
     * If value is an object, then it will be used in a FindElement call with scope set to Children.
     *     Eg. Element[{Type:"Button"}] will return the first child with Type Button.
     * @returns {UIA.IUIAutomationElement}
     */
    __Item[params*] {
        get {
            local el, _, param, i
            el := this
            for _, param in params {
                if IsObject(param) {
                    try el := el.FindElement(param, 2)
                    catch TargetError {
                        el := ""
                    } catch {
                        try el := el.FindCachedElement(param, 2)
                        catch
                            el := ""
                    }
                } else if IsInteger(param) {
                    try {
                        ComCall(6, el, "int", 2, "ptr", UIA.TrueCondition, "ptr*", &found := 0)
                        if found {
                            arr := UIA.IUIAutomationElementArray(found)
                            if (i := param < 0 ? arr.Length+param : param-1) <= arr.Length
                                el := arr.GetElement(i)
                            else
                                el := ""
                        }
                    } catch {
                        try {
                            arr := el.CachedChildren
                            el := arr[param < 0 ? arr.Length+param+1 : param]
                        } catch
                            el := ""
                    }
                } else if param is String {
                    maybeEl := ""
                    for path in StrSplit(param, "|") {
                        try {
                            if InStr(path, ".") || InStr(path, ",")
                                maybeEl := el[StrSplit(StrReplace(path, ".", ","), ",")*]
                            else if RegexMatch(path, "i)([a-zA-Z]+) *(\d+)?", &m:="") && UIA.Type.HasOwnProp(m[1]) {
                                try maybeEl := el.FindElement({Type:m[1], i:(m.Count > 1 ? m[2] : 1)}, 2)
                                catch TargetError
                                    maybeEl := ""
                                catch
                                    try maybeEl := el.FindCachedElement({Type:m[1], i:m[2]}, 2)
                            } else if !(path ~= ",\.+-")
                                maybeEl := el[UIA.DecodePath(path)*]
                            else
                                continue
                            break ; no errors encountered means that match was found
                        }
                    }
                    el := maybeEl
                } else
                    throw TypeError("Invalid item type at index " _, -1)
                if !el
                    throw IndexError("Invalid index/condition at index " _, -1)
            }
            return el
        }
    }
    /**
     * Enables enumeration of UIA elements, usually in a for loop.
     * Usage:
     * for [index, ] child in Element
     */
    __Enum(varCount) {
        local maxLen := this.Length, i := 0, children := this.GetChildren()
        EnumElements(&element) {
            if ++i > maxLen
                return false
            element := children[i]
            return true
        }
        EnumIndexAndElements(&index, &element) {
            if ++i > maxLen
                return false
            index := i
            element := children[i]
            return true
        }
        return (varCount = 1) ? EnumElements : EnumIndexAndElements
    }
    /**
     * Getter for element properties and element supported pattern properties.
     * This allows for syntax such as:
     *     Element.Name == Element.CurrentName
     *     Element.ValuePattern == Element.GetPattern("Value")
     */
    __Get(Name, Params) {
        local pName, pVal, NewName := StrReplace(Name, "Current",,,,1)
        if (SubStr(Name, 1, 6) = "Cached") {
            if UIA.Property.HasOwnProp(PropName := SubStr(Name, 7))
                return this.GetCachedPropertyValue(UIA.Property.%PropName%)
        } else if this.base.HasOwnProp(NewName)
            return this.%NewName%
        else if UIA.Property.HasOwnProp(NewName)
            return this.GetPropertyValue(UIA.Property.%NewName%)
        else {
            for pName, pVal in UIA.Pattern.OwnProps()
                if IsInteger(pVal) && IsAlnum(pName) && UIA.HasProp("IUIAutomation" pName "Pattern") && (pName != "LegacyIAccessible") { ; Skip LegacyIAccessible to avoid name collisions (eg Select)
                    if tryName := UIA.IUIAutomation%pName%Pattern.Prototype.HasProp(NewName) ? NewName : UIA.IUIAutomation%pName%Pattern.Prototype.HasProp(Name) ? Name : "" {
                        try return this.%pName%Pattern.%tryName%
                        catch Any as err {
                            if this.Is%pName%PatternAvailable
                                throw %Type(err)%(err.Message, -1, err.Extra)
                        }
                    }
                }
            ; Since LegacyIAccessible was skipped, then try LegacyIAccessible also
            if (tryName := UIA.IUIAutomationLegacyIAccessiblePattern.Prototype.HasProp(NewName) ? NewName : UIA.IUIAutomationLegacyIAccessiblePattern.Prototype.HasProp(Name) ? Name : "") && this.IsLegacyIAccessiblePatternAvailable
                return this.LegacyIAccessiblePattern.%tryName%
            throw PropertyError("Property " Name " not found in " this.__Class " Class.",-1,Name)
        }
    }
    ; Setter for UIA element and pattern properties.
    __Set(Name, Params, Value) {
        local pVal, pName, NewName := StrReplace(Name, "Current",,,,1)
        if this.base.HasOwnProp(NewName)
            return this.%NewName% := Value
        for pName, pVal in UIA.Pattern.OwnProps()
            if IsInteger(pVal) && IsAlnum(pName) && UIA.HasProp("IUIAutomation" pName "Pattern") && pName != "LegacyIAccessible" {
                if tryName := UIA.IUIAutomation%pName%Pattern.Prototype.HasProp(NewName) ? NewName : UIA.IUIAutomation%pName%Pattern.Prototype.HasProp(Name) ? Name : "" {
                    try return this.%pName%Pattern.%tryName% := Value
                    catch Any as err {
                        if this.Is%pName%PatternAvailable
                            throw %Type(err)%(err.Message, -1, err.Extra)
                    }
                }
            }
            ; Since LegacyIAccessible was skipped, then try LegacyIAccessible also
        if (tryName := UIA.IUIAutomationLegacyIAccessiblePattern.Prototype.HasProp(NewName) ? NewName : UIA.IUIAutomationLegacyIAccessiblePattern.Prototype.HasProp(Name) ? Name : "") && this.IsLegacyIAccessiblePatternAvailable
            return this.LegacyIAccessiblePattern.%tryName% := Value
        throw PropertyError("This class does not support adding properties")
    }
    /**
     * Meta-function for calling methods from supperted patterns.
     * This allows for syntax such as:
     *     Element.Invoke() == Element.GetPattern("Value").Invoke()
     */
    __Call(Name, Params) {
        local NewName, pName, pVal
        if this.base.HasOwnProp(NewName := StrReplace(Name, "Current",,,,1))
            return this.%NewName%(Params*)
        for pName, pVal in UIA.Pattern.OwnProps()
            if IsInteger(pVal) && IsAlpha(pName) && UIA.HasProp("IUIAutomation" pName "Pattern") && (pName != "LegacyIAccessible") {
                if (tryName := UIA.IUIAutomation%pName%Pattern.Prototype.HasMethod(Name) ? Name : UIA.IUIAutomation%pName%Pattern.Prototype.HasMethod(NewName) ? NewName : "") {
                    try return this.%pName%Pattern.%tryName%(Params*)
                    catch Any as err {
                        if this.Is%pName%PatternAvailable
                            throw %Type(err)%(err.Message, -1, err.Extra)
                    }
                }
            }
            if (tryName := UIA.IUIAutomationLegacyIAccessiblePattern.Prototype.HasMethod(Name) ? Name : UIA.IUIAutomationLegacyIAccessiblePattern.Prototype.HasMethod(NewName) ? NewName : "") && this.IsLegacyIAccessiblePatternAvailable
                return this.LegacyIAccessiblePattern.%tryName%(Params*)
        throw MethodError("Method " Name " not found in " this.__Class " Class.",-1,Name)
    }
    ; Returns all direct children of the element
    Children => this.GetChildren()
    ; Retrieves the cached child elements of this UI Automation element.
    ; The view of the returned collection is determined by the TreeFilter property of the IUIAutomationCacheRequest that was active when this element was obtained.
    ; Children are cached only if the scope of the cache request included TreeScope_Subtree, TreeScope_Children, or TreeScope_Descendants.
    ; If the cache request specified that children were to be cached at this level, but there are no children, the value of this property is 0. However, if no request was made to cache children at this level, an attempt to retrieve the property returns an error.
    CachedChildren {
        get {
            local children
            return (ComCall(19, this, "ptr*", &children := 0), children?UIA.IUIAutomationElementArray(children).ToArray():[])
        }
    }
    GetCachedChildren(scope:=2) {
        local children
        if scope&4 {
            children := []
            AppendChildren(this)
        } else if scope&2 {
            children := this.CachedChildren
        }
        if scope&1
            children.Push(this)
        return children
        AppendChildren(el) {
            subchildren := el.CachedChildren
            for child in subchildren {
                children.Push(child)
                AppendChildren(child)
            }
        }
    }
    ; Returns the parent of the element
    Parent => UIA.TreeWalkerTrue.GetParentElement(this)
    ; Retrieves from the cache the parent of this UI Automation element.
    CachedParent {
        get {
            local parent
            if (ComCall(18, this, "ptr*", &parent := 0), parent)
                return UIA.IUIAutomationElement(parent)
            throw UnsetError("No element returned by " A_ThisFunc, -1)
        }
    }
    ; Returns the number of children of the element
    Length => this.GetChildren().Length
    /**
     * Returns an object containing the location of the element
     * @returns {Object} {x: screen x-coordinate, y: screen y-coordinate, w: width, h: height}
     */
    Location => (br := this.BoundingRectangle, {x: br.l, y: br.t, w: br.r-br.l, h: br.b-br.t})
    /**
     * Returns an object containing the last cached location of the element
     * @returns {Object} {x: screen x-coordinate, y: screen y-coordinate, w: width, h: height}
     */
    CachedLocation => (br := this.CachedBoundingRectangle, {x: br.l, y: br.t, w: br.r-br.l, h: br.b-br.t})

    ; Gets or sets the current value of the element, if the ValuePattern is supported.
    Value {
        get {
            try return this.GetPropertyValue(UIA.Property.ValueValue)
        }
        set {
            try return this.GetPattern(UIA.Pattern.Value).SetValue(value)
            try return this.GetPattern(UIA.Pattern.LegacyIAccessible).SetValue(value)
            Throw Error("Setting the value failed! Is ValuePattern or LegacyIAccessiblePattern supported?",,-1)
        }
    }
    CachedValue => this.GetCachedPropertyValue(UIA.Property.ValueValue)
    ; Checks whether this object still exists
    Exists {
        get {
            try return (((br := this.BoundingRectangle) && br.t ? 1 : this.IsOffscreen ? "" : 1)) != ""
            return 1
        }
    }

    ; Aliases for UIA.GetPattern(UIA.Pattern.PatternName)
    InvokePattern => (this.DefineProp("InvokePattern", {value:this.GetPattern(UIA.Pattern.Invoke)}), this.InvokePattern)
    SelectionPattern {
        get {
            try return (this.DefineProp("SelectionPattern", {value:this.GetPattern(UIA.Pattern.Selection2)}), this.SelectionPattern)
            return (this.DefineProp("SelectionPattern", {value:this.GetPattern(UIA.Pattern.Selection)}), this.SelectionPattern)
        }
    }
    ValuePattern => (this.DefineProp("ValuePattern", {value:this.GetPattern(UIA.Pattern.Value)}), this.ValuePattern)
    RangeValuePattern => (this.DefineProp("RangeValuePattern", {value:this.GetPattern(UIA.Pattern.RangeValue)}), this.RangeValuePattern)
    ScrollPattern => (this.DefineProp("ScrollPattern", {value:this.GetPattern(UIA.Pattern.Scroll)}), this.ScrollPattern)
    ExpandCollapsePattern => (this.DefineProp("ExpandCollapsePattern", {value:this.GetPattern(UIA.Pattern.ExpandCollapse)}), this.ExpandCollapsePattern)
    GridPattern => (this.DefineProp("GridPattern", {value:this.GetPattern(UIA.Pattern.Grid)}), this.GridPattern)
    GridItemPattern => (this.DefineProp("GridItemPattern", {value:this.GetPattern(UIA.Pattern.GridItem)}), this.GridItemPattern)
    MultipleViewPattern => (this.DefineProp("MultipleViewPattern", {value:this.GetPattern(UIA.Pattern.MultipleView)}), this.MultipleViewPattern)
    WindowPattern => (this.DefineProp("WindowPattern", {value:this.GetPattern(UIA.Pattern.Window)}), this.WindowPattern)
    SelectionItemPattern => (this.DefineProp("SelectionItemPattern", {value:this.GetPattern(UIA.Pattern.SelectionItem)}), this.SelectionItemPattern)
    DockPattern => (this.DefineProp("DockPattern", {value:this.GetPattern(UIA.Pattern.Dock)}), this.DockPattern)
    TablePattern => (this.DefineProp("TablePattern", {value:this.GetPattern(UIA.Pattern.Table)}), this.TablePattern)
    TableItemPattern => (this.DefineProp("TableItemPattern", {value:this.GetPattern(UIA.Pattern.TableItem)}), this.TableItemPattern)
    TextPattern {
        get {
            try return (this.DefineProp("TextPattern", {value:this.GetPattern(UIA.Pattern.Text2)}), this.TextPattern)
            return (this.DefineProp("TextPattern", {value:this.GetPattern(UIA.Pattern.Text)}), this.TextPattern)
        }
    }
    TogglePattern => (this.DefineProp("TogglePattern", {value:this.GetPattern(UIA.Pattern.Toggle)}), this.TogglePattern)
    TransformPattern {
        get {
            try return (this.DefineProp("TransformPattern", {value:this.GetPattern(UIA.Pattern.Transform2)}), this.TransformPattern)
            return (this.DefineProp("TransformPattern", {value:this.GetPattern(UIA.Pattern.Transform)}), this.TransformPattern)
        }
    }
    ScrollItemPattern => (this.DefineProp("ScrollItemPattern", {value:this.GetPattern(UIA.Pattern.ScrollItem)}), this.ScrollItemPattern)
    LegacyIAccessiblePattern => (this.DefineProp("LegacyIAccessiblePattern", {value:this.GetPattern(UIA.Pattern.LegacyIAccessible)}), this.LegacyIAccessiblePattern)
    ItemContainerPattern => (this.DefineProp("ItemContainerPattern", {value:this.GetPattern(UIA.Pattern.ItemContainer)}), this.ItemContainerPattern)
    VirtualizedItemPattern => (this.DefineProp("VirtualizedItemPattern", {value:this.GetPattern(UIA.Pattern.VirtualizedItem)}), this.VirtualizedItemPattern)
    SynchronizedInputPattern => (this.DefineProp("SynchronizedInputPattern", {value:this.GetPattern(UIA.Pattern.SynchronizedInput)}), this.SynchronizedInputPattern)
    ObjectModelPattern => (this.DefineProp("ObjectModelPattern", {value:this.GetPattern(UIA.Pattern.ObjectModel)}), this.ObjectModelPattern)
    AnnotationPattern => (this.DefineProp("AnnotationPattern", {value:this.GetPattern(UIA.Pattern.Annotation)}), this.AnnotationPattern)
    StylesPattern => (this.DefineProp("StylesPattern", {value:this.GetPattern(UIA.Pattern.Styles)}), this.StylesPattern)
    SpreadsheetPattern => (this.DefineProp("SpreadsheetPattern", {value:this.GetPattern(UIA.Pattern.Spreadsheet)}), this.SpreadsheetPattern)
    SpreadsheetItemPattern => (this.DefineProp("SpreadsheetItemPattern", {value:this.GetPattern(UIA.Pattern.SpreadsheetItem)}), this.SpreadsheetItemPattern)
    TextChildPattern => (this.DefineProp("TextChildPattern", {value:this.GetPattern(UIA.Pattern.TextChild)}), this.TextChildPattern)
    DragPattern => (this.DefineProp("DragPattern", {value:this.GetPattern(UIA.Pattern.Drag)}), this.DragPattern)
    DropTargetPattern => (this.DefineProp("DropTargetPattern", {value:this.GetPattern(UIA.Pattern.DropTarget)}), this.DropTargetPattern)
    TextEditPattern => (this.DefineProp("TextEditPattern", {value:this.GetPattern(UIA.Pattern.TextEdit)}), this.TextEditPattern)
    CustomNavigationPattern => (this.DefineProp("CustomNavigationPattern", {value:this.GetPattern(UIA.Pattern.CustomNavigation)}), this.CustomNavigationPattern)
    ; Aliases for UIA.GetCachedPattern(UIA.Pattern.PatternName)
    CachedInvokePattern => (this.DefineProp("CachedInvokePattern", {value:this.GetCachedPattern(UIA.Pattern.Invoke)}), this.CachedInvokePattern)
    CachedSelectionPattern {
        get {
            try return (this.DefineProp("CachedSelectionPattern", {value:this.GetCachedPattern(UIA.Pattern.Selection2)}), this.CachedSelectionPattern)
            return (this.DefineProp("CachedSelectionPattern", {value:this.GetCachedPattern(UIA.Pattern.Selection)}), this.CachedSelectionPattern)
        }
    }
    CachedValuePattern => (this.DefineProp("CachedValuePattern", {value:this.GetCachedPattern(UIA.Pattern.Value)}), this.CachedValuePattern)
    CachedRangeValuePattern => (this.DefineProp("CachedRangeValuePattern", {value:this.GetCachedPattern(UIA.Pattern.RangeValue)}), this.CachedRangeValuePattern)
    CachedScrollPattern => (this.DefineProp("CachedScrollPattern", {value:this.GetCachedPattern(UIA.Pattern.Scroll)}), this.CachedScrollPattern)
    CachedExpandCollapsePattern => (this.DefineProp("CachedExpandCollapsePattern", {value:this.GetCachedPattern(UIA.Pattern.ExpandCollapse)}), this.CachedExpandCollapsePattern)
    CachedGridPattern => (this.DefineProp("CachedGridPattern", {value:this.GetCachedPattern(UIA.Pattern.Grid)}), this.CachedGridPattern)
    CachedGridItemPattern => (this.DefineProp("CachedGridItemPattern", {value:this.GetCachedPattern(UIA.Pattern.GridItem)}), this.CachedGridItemPattern)
    CachedMultipleViewPattern => (this.DefineProp("CachedMultipleViewPattern", {value:this.GetCachedPattern(UIA.Pattern.MultipleView)}), this.CachedMultipleViewPattern)
    CachedWindowPattern => (this.DefineProp("CachedWindowPattern", {value:this.GetCachedPattern(UIA.Pattern.Window)}), this.CachedWindowPattern)
    CachedSelectionItemPattern => (this.DefineProp("CachedSelectionItemPattern", {value:this.GetCachedPattern(UIA.Pattern.SelectionItem)}), this.CachedSelectionItemPattern)
    CachedDockPattern => (this.DefineProp("CachedDockPattern", {value:this.GetCachedPattern(UIA.Pattern.Dock)}), this.CachedDockPattern)
    CachedTablePattern => (this.DefineProp("CachedTablePattern", {value:this.GetCachedPattern(UIA.Pattern.Table)}), this.CachedTablePattern)
    CachedTableItemPattern => (this.DefineProp("CachedTableItemPattern", {value:this.GetCachedPattern(UIA.Pattern.TableItem)}), this.CachedTableItemPattern)
    CachedTextPattern {
        get {
            try return (this.DefineProp("CachedTextPattern", {value:this.GetCachedPattern(UIA.Pattern.Text2)}), this.CachedTextPattern)
            return (this.DefineProp("CachedTextPattern", {value:this.GetCachedPattern(UIA.Pattern.Text)}), this.CachedTextPattern)
        }
    }
    CachedTogglePattern => (this.DefineProp("CachedTogglePattern", {value:this.GetCachedPattern(UIA.Pattern.Toggle)}), this.CachedTogglePattern)
    CachedTransformPattern {
        get {
            try return (this.DefineProp("CachedTransformPattern", {value:this.GetCachedPattern(UIA.Pattern.Transform2)}), this.CachedTransformPattern)
            return (this.DefineProp("CachedTransformPattern", {value:this.GetCachedPattern(UIA.Pattern.Transform)}), this.CachedTransformPattern)
        }
    }
    CachedScrollItemPattern => (this.DefineProp("CachedScrollItemPattern", {value:this.GetCachedPattern(UIA.Pattern.ScrollItem)}), this.CachedScrollItemPattern)
    CachedLegacyIAccessiblePattern => (this.DefineProp("CachedLegacyIAccessiblePattern", {value:this.GetCachedPattern(UIA.Pattern.LegacyIAccessible)}), this.CachedLegacyIAccessiblePattern)
    CachedItemContainerPattern => (this.DefineProp("CachedItemContainerPattern", {value:this.GetCachedPattern(UIA.Pattern.ItemContainer)}), this.CachedItemContainerPattern)
    CachedVirtualizedItemPattern => (this.DefineProp("CachedVirtualizedItemPattern", {value:this.GetCachedPattern(UIA.Pattern.VirtualizedItem)}), this.CachedVirtualizedItemPattern)
    CachedSynchronizedInputPattern => (this.DefineProp("CachedSynchronizedInputPattern", {value:this.GetCachedPattern(UIA.Pattern.SynchronizedInput)}), this.CachedSynchronizedInputPattern)
    CachedObjectModelPattern => (this.DefineProp("CachedObjectModelPattern", {value:this.GetCachedPattern(UIA.Pattern.ObjectModel)}), this.CachedObjectModelPattern)
    CachedAnnotationPattern => (this.DefineProp("CachedAnnotationPattern", {value:this.GetCachedPattern(UIA.Pattern.Annotation)}), this.CachedAnnotationPattern)
    CachedStylesPattern => (this.DefineProp("CachedStylesPattern", {value:this.GetCachedPattern(UIA.Pattern.Styles)}), this.CachedStylesPattern)
    CachedSpreadsheetPattern => (this.DefineProp("CachedSpreadsheetPattern", {value:this.GetCachedPattern(UIA.Pattern.Spreadsheet)}), this.CachedSpreadsheetPattern)
    CachedSpreadsheetItemPattern => (this.DefineProp("CachedSpreadsheetItemPattern", {value:this.GetCachedPattern(UIA.Pattern.SpreadsheetItem)}), this.CachedSpreadsheetItemPattern)
    CachedTextChildPattern => (this.DefineProp("CachedTextChildPattern", {value:this.GetCachedPattern(UIA.Pattern.TextChild)}), this.CachedTextChildPattern)
    CachedDragPattern => (this.DefineProp("CachedDragPattern", {value:this.GetCachedPattern(UIA.Pattern.Drag)}), this.CachedDragPattern)
    CachedDropTargetPattern => (this.DefineProp("CachedDropTargetPattern", {value:this.GetCachedPattern(UIA.Pattern.DropTarget)}), this.CachedDropTargetPattern)
    CachedTextEditPattern => (this.DefineProp("CachedTextEditPattern", {value:this.GetCachedPattern(UIA.Pattern.TextEdit)}), this.CachedTextEditPattern)
    CachedCustomNavigationPattern => (this.DefineProp("CachedCustomNavigationPattern", {value:this.GetCachedPattern(UIA.Pattern.CustomNavigation)}), this.CachedCustomNavigationPattern)

    /**
     * Returns the children of this element, optionally filtering by a condition
     * @param c Optional UIA condition object. Default is TrueCondition.
     * @param scope Optional TreeScope value: Element, Children, Family (Element+Children), Descendants, Subtree (=Element+Descendants). Default is Children.
     * @returns {Array}
     */
    GetChildren(c?, scope:=0x2) => this.FindAll(c ?? UIA.TrueCondition, scope)

    ; Get all child elements using TreeWalker. This is only for debugging purposes.
    TWGetChildren() {
        arr := []
        if !IsObject(nextChild := UIA.TreeWalkerTrue.GetFirstChildElement(this))
            return ""
        arr.Push(nextChild)
        while IsObject(nextChild := UIA.TreeWalkerTrue.GetNextSiblingElement(nextChild))
            arr.Push(nextChild)
        return arr
    }
    /**
     * Returns info about the element: Type, Name, Value, LocalizedType, AutomationId, AcceleratorKey.
     * @param scope Optional TreeScope value: Element, Children, Family (Element+Children), Descendants, Subtree (=Element+Descendants). Default is Descendants.
     * @param delimiter Optional delimiter to separate the returned properties. Default is space.
     * @param maxDepth Optional maximal depth of tree levels traversal. Default is unlimited.
     * @returns {String}
     */
    Dump(scope:=1, delimiter:=" ", maxDepth:=-1) {
        local out := "", n, oChild
        if !IsInteger(scope)
            try scope := UIA.TreeScope.%scope%
        ; Create cache request, add all the necessary properties that Dump uses: Type, LocalizedType, AutomationId, Name, Value, ClassName, AcceleratorKey
        ; Don't even get the live element, because we don't need it. Gives a significant speed improvement.
        static cacheRequest := UIA.CreateCacheRequest(["Type", "LocalizedType", "AutomationId", "Name", "Value", "ClassName", "AcceleratorKey"],,5,0)
        ; Speed-testing has shown that DumpAll with Current properties is about 1,5 to 4x slower than with Cached properties.
        ; Cached Dump with TreeScope.Element or TreeScope.Children is a bit slower than Current Dump.
        ; This means that we use Current properties if TreeScope is less than Descendants,
        ; and Cached properties if dumping Descendants. This gives the maximum performance.
        if scope < 4 {
            if scope&1 {
                out := this.CurrentDump(delimiter) "`n"
            }
            if scope&2 {
                for n, oChild in this.GetChildren()
                    out .= n ": " oChild.CurrentDump(delimiter) "`n"
            }
        } else {
            ; Build the cache for the set scope
            try el := this.CachedChildren.Length
            el := IsSet(el) && el ? this : this.FindFirstBuildCache(cacheRequest, UIA.RawViewCondition, scope)
            if scope&1
                out := el.CachedDump(delimiter) "`n"
            if scope&2 {
                for n, oChild in el.CachedChildren
                    out .= n ": " oChild.CachedDump(delimiter) "`n"
            }
            if scope&4
                return RTrim(RecurseTree(el, out), "`n")
        }
        return RTrim(out, "`n")

        RecurseTree(element, tree, path:="") {
            local i, child, count
            if maxDepth > 0 {
                StrReplace(path, "," , , , &count)
                if count >= (maxDepth-1)
                    return tree
            }
            For i, child in element.CachedChildren {
                tree .= path (path?",":"") i ":" delimiter child.CachedDump(delimiter) "`n"
                tree := RecurseTree(child, tree, path (path?",":"") i)
            }
            return tree
        }
    }
    ; Dumps with only "Current" properties
    CurrentDump(delimiter:=" ") {
        local ctrlType, name, val, lct, aid, cm, ak
        return "Type: " (ctrlType := this.Type) " (" UIA.Type[ctrlType] ")" ((name := this.Name) == "" ? "" : delimiter "Name: `"" name "`"") ((val := this.Value) == "" ? "" : delimiter "Value: `"" val "`"") ((lct := this.LocalizedType) == "" ? "" : delimiter "LocalizedType: `"" lct "`"") ((aid := this.AutomationId) == "" ? "" : delimiter "AutomationId: `"" aid "`"") ((cm := this.ClassName) == "" ? "" : delimiter "ClassName: `"" cm "`"") ((ak := this.AcceleratorKey) == "" ? "" : delimiter "AcceleratorKey: `"" ak "`"")
    }
    ; Dumps with only "Cached" properties
    CachedDump(delimiter:=" ") {
        local ctrlType, name, val, lct, aid, cm, ak
        return "Type: " (ctrlType := this.CachedType) " (" UIA.Type[ctrlType] ")" ((name := this.CachedName) == "" ? "" : delimiter "Name: `"" name "`"") ((val := this.CachedValue) == "" ? "" : delimiter "Value: `"" val "`"") ((lct := this.CachedLocalizedType) == "" ? "" : delimiter "LocalizedType: `"" lct "`"") ((aid := this.CachedAutomationId) == "" ? "" : delimiter "AutomationId: `"" aid "`"") ((cm := this.CachedClassName) == "" ? "" : delimiter "ClassName: `"" cm "`"") ((ak := this.CachedAcceleratorKey) == "" ? "" : delimiter "AcceleratorKey: `"" ak "`"")
    }
    ToString() {
        try return this.Dump()
        return this.CachedDump()
    }
    /**
     * Returns info about the element and its descendants: Type, Name, Value, LocalizedType, AutomationId, AcceleratorKey.
     * @param maxDepth Optional maximal depth of tree levels traversal. Default is unlimited.
     * @returns {String}
     */
    DumpAll(delimiter:=" ", maxDepth:=-1) => this.Dump(5, delimiter, maxDepth)

    /**
     * Returns an UIA path leading to the target element.  
     * This path consists of Type and index information.
     * @param targetEl The element the path will lead to from this element
     * @param cached Whether this element contains a cached tree that should be used for the search.
     * Since UIA path requires Type information, the Type should be cached in the tree.
     * @returns {String}
     */
    GetUIAPath(targetEl, cached := False) => UIA.EncodePath(this.GetConditionPath(targetEl, cached))
    /**
     * Returns an array of conditions consisting of Type and index information, defining the path leading to the target element.
     * @param targetEl The element the path will lead to from this element
     * @param cached Whether this element contains a cached tree that should be used for the search.
     * Since the condition path requires Type information, the Type should be cached in the tree.
     * @returns {Array}
     */
    GetConditionPath(targetEl, cached := False) {
        local i, child, cachedThis, numPath, conditionPath, children, targetType, targetIndex, sameTypeCount, targetTypeIndex
        cachedThis := cached ? this : this.BuildUpdatedCache(UIA.CreateCacheRequest(["Type"],,5))
        numPath := cachedThis.GetNumericPath(targetEl, true)
        conditionPath := []
        Loop numPath.Length {
            children := cachedThis.CachedChildren, targetIndex := numPath[A_index], sameTypeCount := 0, targetTypeIndex := 0
            targetType := children[targetIndex].CachedType
            for i, child in children {
                if child.CachedType == targetType
                    sameTypeCount++
                if i == targetIndex
                    targetTypeIndex := sameTypeCount
            }
            if targetTypeIndex = 1
                conditionPath.Push({Type:targetType})
            else if targetTypeIndex = sameTypeCount
                conditionPath.Push({Type:targetType, i:-1})
            else
                conditionPath.Push({Type:targetType, i:targetTypeIndex})
            cachedThis := children[targetIndex]
        }
        return conditionPath
    }
    /**
     * Returns an array of integers defining the numeric path leading to the target element.
     * @param targetEl The element the path will lead to from this element
     * @param cached Whether this element contains a cached tree that should be used for the search
     * @returns {Array}
     */
    GetNumericPath(targetEl, cached := False) {
        cachedThis := cached ? this : this.BuildUpdatedCache(cacheRequest := UIA.CreateCacheRequest(["Type"],,5))
        if found := FindTarget(cachedThis)
            return found
        throw TargetError("No matching target element found", -1)

        FindTarget(el, path:=[]) {
            local i, child
            for i, child in el.CachedChildren {
                path.Push(i)
                if UIA.CompareElements(child, targetEl)
                    return path
                if found := FindTarget(child, path)
                    return found
                path.Pop()
            }
        }
    }

    /**
     * @param relativeTo CoordMode to be used: client, window or screen. Default is A_CoordModeMouse
     * @returns {x:x coordinate, y:y coordinate, w:width, h:height}
     */
    GetPos(relativeTo:="") {
        local br := this.BoundingRectangle, pt
        relativeTo := (relativeTo == "") ? A_CoordModeMouse : relativeTo
        if (relativeTo = "screen")
            return {x:br.l, y:br.t, w:(br.r-br.l), h:(br.b-br.t)}
        else if (relativeTo = "window") {
            DllCall("user32\GetWindowRect", "Int", this.GetWinId(), "Ptr", RECT := Buffer(16))
            return {x:(br.l-NumGet(RECT, 0, "Int")), y:(br.t-NumGet(RECT, 4, "Int")), w:br.r-br.l, h:br.b-br.t}
        } else if (relativeTo = "client") {
            pt := Buffer(8), NumPut("int",br.l,pt), NumPut("int", br.t,pt,4)
            DllCall("ScreenToClient", "Int", this.GetWinId(), "Ptr", pt)
            return {x:NumGet(pt,0,"int"), y:NumGet(pt,4,"int"), w:br.r-br.l, h:br.b-br.t}
        } else
            throw Error(relativeTo "is not a valid CoordMode",-1)
    }

    ; Get the parent window hwnd from the element
    GetWinId() {
        static TW := UIA.CreateTreeWalker(UIA.CreateNotCondition(UIA.CreatePropertyCondition(UIA.Property.NativeWindowHandle, 0)))
        try return DllCall("GetAncestor", "UInt", TW.NormalizeElement(this).GetPropertyValue(UIA.Property.NativeWindowHandle), "UInt", 2) ; hwnd from point by SKAN
    }
    ; Get the control hwnd (that the element belongs to) from the element
    GetControlId() {
        static TW := UIA.CreateTreeWalker(UIA.CreateNotCondition(UIA.CreatePropertyCondition(UIA.Property.NativeWindowHandle, 0)))
        try return TW.NormalizeElement(this).GetPropertyValue(UIA.Property.NativeWindowHandle)
    }

    /**
     * Tries to click the element. The method depends on WhichButton variable: by default it is attempted
     * to use any "click"-like methods, such as InvokePattern Invoke(), TogglePattern Toggle(), SelectionItemPattern Select().
     * @param WhichButton 
     * * If WhichButton is left empty (default), then any "click"-like pattern methods
     * will be used (Invoke(), Toggle(), Select() etc.  
     * * If WhichButton is a number, then Sleep will be called afterwards with that number of milliseconds.  
     *     Eg. Element.Click(200) will sleep 200ms after "clicking".  
     * * If WhichButton is "left" or "right", then the native Click() will be used to move the cursor to
     * the center of the element and perform a click.  
     * @param ClickCount Is used if WhichButton isn't a number or left empty, that is if AHK Click()
     * will be used. In this case if ClickCount is a number <10, then that number of clicks will be performed.  
     * If ClickCount is >=10, then Sleep will be called with that number of ms. Both ClickCount and sleep time
     * can be combined by separating with a space.  
     * Eg. Element.Click("left", 1000) will sleep 1000ms after clicking.  
     *     Element.Click("left", 2) will double-click the element  
     *     Element.Click("left" "2 1000") will double-click the element and then sleep for 1000ms  
     * @param DownOrUp If AHK Click is used, then this will either press the mouse down, or release it.
     * @param Relative If Relative is "Rel" or "Relative" then X and Y coordinates are treated as offsets from the current mouse position.  
     * Otherwise it expects offset values for both X and Y (eg "-5 10" would offset X by -5 and Y by +10 from the center of the element).
     * @param NoActivate If AHK Click is used, then this will determine whether the window is activated
     * before clicking if the clickable point isn't visible on the screen. Default is no activating.
     */
    Click(WhichButton:="", ClickCount:=1, DownOrUp:="", Relative:="", NoActivate:=False) {
        local SleepTime, togglePattern, expandState, selectionPattern, rel, pos, cCount
        if WhichButton = "" or IsInteger(WhichButton) {
            SleepTime := WhichButton ? WhichButton : -1
            if (this.GetPropertyValue(UIA.Property.IsInvokePatternAvailable)) {
                this.InvokePattern.Invoke()
                Sleep SleepTime
                return 1
            }
            if (this.GetPropertyValue(UIA.Property.IsTogglePatternAvailable)) {
                togglePattern := this.GetCurrentPatternAs("Toggle"), toggleState := togglePattern.CurrentToggleState
                togglePattern.Toggle()
                if (togglePattern.CurrentToggleState != toggleState) {
                    Sleep sleepTime
                    return 1
                }
            }
            if (this.GetPropertyValue(UIA.Property.IsExpandCollapsePatternAvailable)) {
                if ((expandState := (pattern := this.ExpandCollapsePattern).ExpandCollapseState) == 0) {
                    try pattern.Expand() ; Sometimes throws UIA_E_INVALIDOPERATION 0x80131509
                } else {
                    try pattern.Collapse()
                }
                if (pattern.ExpandCollapseState != expandState) {
                    Sleep sleepTime
                    return 1
                }
            }
            if (this.GetPropertyValue(UIA.Property.IsSelectionItemPatternAvailable)) {
                selectionPattern := this.SelectionItemPattern, selectionState := selectionPattern.IsSelected
                selectionPattern.Select()
                if (selectionPattern.IsSelected != selectionState) {
                    Sleep sleepTime
                    return 1
                }
            }
            if (this.GetPropertyValue(UIA.Property.IsLegacyIAccessiblePatternAvailable)) {
                this.LegacyIAccessiblePattern.DoDefaultAction()
                Sleep sleepTime
                return 1
            }
            return 0
        }
        rel := [0,0], pos := this.Location, cCount := 1, SleepTime := -1
        if (Relative && !InStr(Relative, "rel"))
            rel := StrSplit(Relative, " "), Relative := ""
        if IsInteger(WhichButton)
            SleepTime := WhichButton, WhichButton := "left"
        if !IsInteger(ClickCount) && InStr(ClickCount, " ") {
            sCount := StrSplit(ClickCount, " ")
            cCount := sCount[1], SleepTime := sCount[2]
        } else if ClickCount > 9 {
            SleepTime := cCount, cCount := 1
        }
        if (!NoActivate && (UIA.WindowFromPoint(pos.x+pos.w//2+rel[1], pos.y+pos.h//2+rel[2]) != (wId := this.GetWinId()))) {
            WinActivate(wId)
            WinWaitActive(wId)
        }
        saveCoordMode := A_CoordModeMouse
        CoordMode("Mouse", "Screen")
        Click(pos.x+pos.w//2+rel[1] " " pos.y+pos.h//2+rel[2] " " WhichButton (ClickCount ? " " ClickCount : "") (DownOrUp ? " " DownOrUp : "") (Relative ? " " Relative : ""))
        CoordMode("Mouse", saveCoordMode)
        Sleep(SleepTime)
    }

    /**
     * Uses ControlClick to click the element.
     * @param WhichButton determines which button to use to click (left, right, middle).  
     * If WhichButton is a number, then a Sleep will be called afterwards.  
     * Eg. ControlClick(200) will sleep 200ms after clicking.
     * @param ClickCount How many times to click. Default is 1.
     * @param Options Additional ControlClick Options (see AHK documentations).
     */
    ControlClick(WhichButton:="left", ClickCount:=1, Options:="") {
        pos := this.GetPos("client")
        ControlClick("X" pos.x+pos.w//2 " Y" pos.y+pos.h//2, this.GetWinId(),, IsInteger(WhichButton) ? "left" : WhichButton, ClickCount, Options)
        if IsInteger(WhichButton)
            Sleep(WhichButton)
    }
    /**
     * Highlights the element for a chosen period of time.
     * @param showTime Can be one of the following:  
     * * Unset - if highlighting exists then removes the highlighting, otherwise highlights for 2 seconds. This is the default value.
     * * 0 - Indefinite highlighting
     * * Positive integer (eg 2000) - will highlight and pause for the specified amount of time in ms
     * * Negative integer - will highlight for the specified amount of time in ms, but script execution will continue
     * * "clear" - removes the highlighting unconditionally
     * @param color The color of the highlighting. Default is red.
     * @param d The border thickness of the highlighting in pixels. Default is 2.
     * @returns {UIA.IUIAutomationElement}
     */
    Highlight(showTime:=unset, color:="Red", d:=2) {
        local _, r, i, loc, x1, y1, w1, h1
        static Guis := Map()
        if IsSet(showTime) && showTime = "clearall" {
            for key, prop in Guis {
                for r in prop
                    r.Destroy()
            }
            Guis := Map()
            return this
        }
        if !Guis.Has(this.ptr)
            Guis[this.ptr] := []
        if (!IsSet(showTime) && Guis[this.ptr].Length) || (IsSet(showTime) && showTime = "clear") {
                for r in Guis[this.ptr]
                    r.Destroy()
                Guis.Delete(this.ptr)
                return this
        } else if !IsSet(showTime)
            showTime := 2000
        try loc := this.BoundingRectangle
        if !IsSet(loc) || !IsObject(loc)
            try loc := this.CachedBoundingRectangle
            if !IsSet(loc) || !IsObject(loc)
                return this
        Loop 4 {
            Guis[this.ptr].Push(Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000"))
        }
        Loop 4 {
            i:=A_Index
            , x1:=(i=2 ? loc.r : loc.l-d)
            , y1:=(i=3 ? loc.b : loc.t-d)
            , w1:=(i=1 or i=3 ? (loc.r-loc.l)+2*d : d)
            , h1:=(i=2 or i=4 ? (loc.b-loc.t)+2*d : d)
            Guis[this.ptr][i].BackColor := color
            Guis[this.ptr][i].Show("NA x" . x1 . " y" . y1 . " w" . w1 . " h" . h1)
        }
        if showTime > 0 {
            Sleep(showTime)
            this.Highlight()
        } else if showTime < 0
            SetTimer(ObjBindMethod(this, "Highlight", "clear"), -Abs(showTime))
        return this
    }
    ClearHighlight() => this.Highlight("clear")

    /**
     * Waits for this element to not exist
     * @param timeout Waiting time for element to disappear. Default: indefinite wait
     * @returns {Integer}
     */
    WaitNotExist(timeOut:=-1) {
        endtime := A_TickCount + timeout
        while ((exists := this.Exists) && ((timeout == -1) || (A_Tickcount < endtime)))
            Sleep 20
        return !exists
    }

    static __ExtractConditionNamedParameters(condition, &scope, &order, &startingElement, &cacheRequest?, &index?) {
        if Type(condition) != "Object"
            return condition
        pureCondition := condition.Clone()
        if IsSet(index) {
            index := pureCondition.DeleteProp("index") || pureCondition.DeleteProp("i") || index
            if IsInteger(index) && !(index is Integer)
                index := Integer(index)
        }
        scope := pureCondition.DeleteProp("scope") || scope
        order := pureCondition.DeleteProp("order") || order
        startingElement := pureCondition.DeleteProp("startingElement") || startingElement
        if IsSet(cacheRequest)
            cacheRequest := pureCondition.DeleteProp("cacheRequest") || cacheRequest
        pureCondition.DeleteProp("timeOut")
        return pureCondition
    }

    /**
     * Checks whether an element that matches the specified condition exists within the provided TreeScope.
     * If no element is found, then 0 is returned.
     * @param condition The condition to filter with.  
     * The condition object additionally supports named parameters.  
     * See a more detailed explanation under FindElement condition argument.  
     * Default MatchMode is "Exact", and CaseSense "On".  
     * Note: MatchMode "StartsWith" and "RegEx" will have the performance of FindElements (slower).
     * @param scope Optional TreeScope value: Element, Children, Family (Element+Children), Descendants, Subtree (=Element+Descendants). Default is Descendants.
     * @param index Looks for the n-th element matching the condition
     * @param order Optional: custom tree navigation order, one of UIA.TreeTraversalOptions values (LastToFirstOrder, PostOrder, LastToFirstPostOrder). Default is FirstToLast and PreOrder. [requires Windows 10 version 1703+]
     * @param startingElement Optional: search will start from this element instead, which must be a child/descendant of the starting element [requires Windows 10 version 1703+]  
     *     If startingElement is supplied then part of the tree will not be searched (depending on TreeTraversalOrder, either everything before this element, or everything after it will be ignored)
     * @param cacheRequest Optional: cache request object
     * @returns {UIA.IUIAutomationElement}
     */
    ElementExist(condition, scope:=4, index:=1, order:=0, startingElement:=0, cacheRequest:=0) {
        try return this.FindElement(condition, scope, index, order, startingElement, cacheRequest)
        catch TargetError
            return 0
        return 0
    }

    /**
     * Retrieves the first child or descendant element that matches the specified condition.
     * If no element is found, then TargetError is thrown.
     * @param condition The condition to filter with.
     *
     * * A single property condition consists of an object where the key is the property name, and value is the property value: `{Name:"Test"}` => Name property must match "Test" exactly
     * * Everything inside {} is an "and" condition: `{Type:"Button", Name:"Something"}` => Name must match "Something" AND Type must be Button
     * * Everything inside [] is an "or" condition: `[{Name:"Test"}, {Name:"Something"}]` => Name must match "Test" OR Name must match "Something"
     * * Object key "not" creates a not condition: `{not:{Type:"Button"}}` => everything except Type Button
     *
     * * MatchMode key (short form: mm) can be one of UIA.MatchMode values: "StartsWith", "SubString", "Exact", "RegEx". Default MatchMode is "Exact".
     * MatchMode applies to all string-type conditions (except Type), multiple different MatchModes are allowed if used in separate sub-conditions.
     * Note: MatchMode "StartsWith" and "RegEx" will have the performance of FindElements (slower).
     * * CaseSense key (short form: cs) defines case-sense: "On"/True or "Off"/False. Default is "On".
     *
     * * The condition object additionally supports named parameters: {Type:"Button", index:-1} => last element with Type Button
     * @param scope Optional TreeScope value: Element, Children, Family (Element+Children), Descendants, Subtree (=Element+Descendants). Default is Descendants.
     * @param index Looks for the n-th element matching the condition
     * @param order Optional: custom tree navigation order, one of UIA.TreeTraversalOptions values (LastToFirstOrder, PostOrder, LastToFirstPostOrder). Default is FirstToLast and PreOrder. [requires Windows 10 version 1703+]
     * @param startingElement Optional: search will start from this element instead, which must be a child/descendant of the starting element [requires Windows 10 version 1703+]
     *     If startingElement is supplied then part of the tree will not be searched (depending on TreeTraversalOrder, either everything before this element, or everything after it will be ignored)
     * @param cacheRequest Optional: cache request object
     * @returns {UIA.IUIAutomationElement}
     */
    FindElement(condition, scope:=4, index:=1, order:=0, startingElement:=0, cacheRequest:=0) {
        local withOptions := 0
        condition := UIA.IUIAutomationElement.__ExtractConditionNamedParameters(condition, &scope, &order, &startingElement, &cacheRequest, &index)
        condition := UIA.TypeValidation.Condition(condition), scope := UIA.TypeValidation.TreeScope(scope), index := UIA.TypeValidation.Integer(index, "Index"), order := UIA.TypeValidation.TreeTraversalOptions(order), startingElement := UIA.TypeValidation.Element(startingElement), cacheRequest := UIA.TypeValidation.CacheRequest(cacheRequest)
        if index < 0 ; Convert negative index to LastToFirst order
            index := -index, order := order | 2
        withOptions := order || startingElement
        if withOptions && !UIA.IsIUIAutomationElement7Available && InStr(Type(condition), "Condition")
            throw ValueError("If using order or startingElement arguments in Windows <10.0.15063, then condition cannot be IUIAutomationCondition", -1)
        if !InStr(Type(condition), "Condition") {
            /*
                If MatchMode is 1:
                    Use MatchMode 2, but then return all the results and filter using the condition
                If MatchMode is RegEx:
                    Find all !"" elements, then filter using the condition
                If either of these is encountered, nonUIAEncountered is set to 1.
                If a CachedProperty is encountered, nonUIAEncountered is set to 2 and a cached search is used instead.
            */
            IUIAcondition := UIA.__ConditionBuilder(condition, &nonUIAEncountered:=0), counter := 0
            if nonUIAEncountered = 1 { ; Some conditions need validating: MatchMode 1 or RegEx was used
                ; If no cacheRequest was specified, then speed-optimize the search by caching
                ; the required properties, and searching through cached elements.
                ; And although it looks like if adding an exception for a set startingElement
                ; and using FindAllWithOptions from startingElement should give a speed improvement,
                ; it actually doesn't  affect the search speed significantly, probably because
                ; the cache search is just so much faster.
                ; It would be useful to use TreeFilter=IUIAcondition, but unfortunately it seems
                ; that TreeFilter is applied before TreeScope. This leads to the unwanted behavior
                ; of the tree being flattened, so this can't be used with scope=Children
                cache := this.BuildUpdatedCache(UIA.CreateCacheRequest(condition,,scope,, scope>3 ? IUIAcondition : unset))
                found := cache.FindCachedElement(condition, scope, index, order, startingElement)
                return cacheRequest ? found.BuildUpdatedCache(cacheRequest) : found
            } else if nonUIAEncountered = 2 ; A cached name was encountered, use FindCachedElement instead
                return this.FindCachedElement(condition, scope, index, order, startingElement)

            ; If the user is running an older Windows, but is trying to use FindFirstWithOptions arguments
            ; then either use cached elements, or in the case of index 1 and PreOrder, use TreeWalker
            if withOptions && (!UIA.IsIUIAutomationElement7Available || (scope < 4 && startingElement)) {
                if index = 1 && order = 2 && !startingElement { ; Special case for index -1, PreOrder, and older Windows version
                    if scope & 1 
                        try return cacheRequest ? this.FindFirstBuildCache(cacheRequest, IUIAcondition, 1) : this.FindFirst(IUIAcondition, 1)
                    if scope > 1
                        return cacheRequest ? UIA.CreateTreeWalker(IUIAcondition).GetLastChildElementBuildCache(cacheRequest, this) : UIA.CreateTreeWalker(IUIAcondition).GetLastChildElement(this)
                    else
                        throw TargetError("An element matching the condition was not found", -1)
                }
                found := this.BuildUpdatedCache(UIA.CreateCacheRequest(condition,,scope,,scope>3 ? IUIAcondition : unset)).FindCachedElement(condition, scope, index, order, startingElement)
                return cacheRequest ? found.BuildUpdatedCache(cacheRequest) : found
            }
            condition := IUIAcondition
        }
        if !startingElement ; If FindFirstWithOptions is used but startingElement isn't set, start from this element.
            startingElement := this
        ; Use FindAll instead if index > 1
        if index != 1 {
            try {
                unfilteredEls := (cacheRequest ? (withOptions ? startingElement.FindAllWithOptionsBuildCache(cacheRequest, condition, order, this, scope)
                    : this.FindAllBuildCache(cacheRequest, condition, scope))
                    : (withOptions ? startingElement.FindAllWithOptions(condition, order, this, scope)
                    : this.FindAll(condition, scope)))
                return unfilteredEls[order&2 && !withOptions ? unfilteredEls.Length + 1 - index : index]
            } catch IndexError
                throw TargetError("An element matching the condition was not found", -1, "FindAll index " index " was invalid")
        }
        if cacheRequest {
            if withOptions
                ComCall(112, startingElement, "int", scope, "ptr", condition, "ptr", cacheRequest, "int", order, "ptr", this, "ptr*", &found := 0) ; FindFirstWithOptionsBuildCache
            else
                ComCall(7, this, "int", scope, "ptr", condition, "ptr", cacheRequest, "ptr*", &found := 0) ; FindFirstBuildCache
        } else {
            if withOptions {
                ComCall(110, startingElement, "int", scope, "ptr", condition, "int", order, "ptr", this, "ptr*", &found := 0) ; FindFirstWithOptions
            } else {
                ComCall(5, this, "int", scope, "ptr", condition, "ptr*", &found := 0) ; FindFirst
            }
        }
        if found
            return UIA.IUIAutomationElement(found)
        throw TargetError("An element matching the condition was not found", -1)
    }

    /**
     * CachedElementExist can be used to find an element inside a cached tree, using only cached properties.
     * This is not a UIA native method: make sure the cached tree is reasonably small, otherwise the performance will suffer.
     * If no element is found, then 0 is returned.
     * @param condition The condition to filter with.  
     * The condition object additionally supports named parameters.  
     * Default MatchMode is "Exact", and CaseSense "On".  
     * See a more detailed explanation under FindElement condition argument.  
     * @param scope Optional TreeScope value: Element, Children, Family (Element+Children), Descendants, Subtree (=Element+Descendants). Default is Descendants.
     * @param index Looks for the n-th element matching the condition
     * @param order Optional: custom tree navigation order, one of UIA.TreeTraversalOptions values (LastToFirstOrder, PostOrder, LastToFirstPostOrder). Default is FirstToLast and PreOrder.
     * @param startingElement Optional: search will start from this element instead, which must be a child/descendant of the starting element
     *     If startingElement is supplied then part of the tree will not be searched (depending on TreeTraversalOrder, either everything before this element, or everything after it will be ignored)
     *     Unlike FindElement, using this will most likely not have a beneficial effect on performance.
     * @returns {UIA.IUIAutomationElement}
     */
    CachedElementExist(condition, scope:=4, index:=1, order:=0, startingElement:=0) {
        try return this.FindCachedElement(condition, scope, index, order, startingElement)
        catch TargetError
            return 0
        return 0
    }

    /**
     * FindCachedElement can be used to find an element inside a cached tree, using only cached properties.
     * This is not a UIA native method: make sure the cached tree is reasonably small, otherwise the performance will suffer.
     * If no element is found, then a TargetError is thrown.
     * @param condition The condition to filter with.  
     * The condition object additionally supports named parameters.  
     * Default MatchMode is "Exact", and CaseSense "On".  
     * See a more detailed explanation under FindElement condition argument.
     * @param scope Optional TreeScope value: Element, Children, Family (Element+Children), Descendants, Subtree (=Element+Descendants). Default is Descendants.
     * @param index Looks for the n-th element matching the condition
     * @param order Optional: custom tree navigation order, one of UIA.TreeTraversalOptions values (LastToFirstOrder, PostOrder, LastToFirstPostOrder). Default is FirstToLast and PreOrder.
     * @param startingElement Optional: search will start from this element instead, which must be a child/descendant of the starting element
     *     If startingElement is supplied then part of the tree will not be searched (depending on TreeTraversalOrder, either everything before this element, or everything after it will be ignored)
     *     Unlike FindElement, using this will most likely not have a beneficial effect on performance.
     * @returns {UIA.IUIAutomationElement}
     */
    FindCachedElement(condition, scope:=4, index:=1, order:=0, startingElement:=0) {
        local out
        condition := UIA.IUIAutomationElement.__ExtractConditionNamedParameters(condition, &scope, &order, &startingElement, , &index)
        condition := UIA.TypeValidation.Condition(condition), scope := UIA.TypeValidation.TreeScope(scope), index := UIA.TypeValidation.Integer(index, "Index"), order := UIA.TypeValidation.TreeTraversalOptions(order), startingElement := UIA.TypeValidation.Element(startingElement)
        if index < 0
            order |= 2, index := -index
        else if index = 0
            throw ValueError("Condition index cannot be 0", -1)
        if startingElement
            startingElement := UIA.RuntimeIdToString(startingElement.GetRuntimeId())
        ; First handle PostOrder
        if order&1 {
            if out := order&2 ? PostOrderLastToFirstRecursiveFind(this) : PostOrderFirstToLastRecursiveFind(this)
                return out
            throw TargetError("An element matching the condition was not found", -1)
        }
        ; PreOrder
        if scope&1 && this.ValidateCondition(condition, true) && --index = 0
            return this
        if scope > 1 {
            if out := order&2 ? PreOrderLastToFirstRecursiveFind(this) : PreOrderFirstToLastRecursiveFind(this)
                return out
            throw TargetError("An element matching the condition was not found", -1)
        }
        PreOrderFirstToLastRecursiveFind(el) {
            for child in el.CachedChildren {
                if (startingElement ? (startingElement = UIA.RuntimeIdToString(child.GetRuntimeId()) ? !(startingElement := "") : 0) : 1) && child.ValidateCondition(condition, true) && --index = 0
                    return child
                else if scope&4 && (found := PreOrderFirstToLastRecursiveFind(child))
                    return found
            }
        }
        PreOrderLastToFirstRecursiveFind(el) {
            children := el.CachedChildren, len := children.Length + 1
            Loop len-1 {
                child := children[len-A_index]
                if (startingElement ? (startingElement = UIA.RuntimeIdToString(child.GetRuntimeId()) ? !(startingElement := "") : 0) : 1) && child.ValidateCondition(condition, true) && --index = 0
                    return child
                else if scope&4 && found := PreOrderLastToFirstRecursiveFind(child)
                    return found
            }
        }
        PostOrderFirstToLastRecursiveFind(el) {
            if scope > 1 {
                if scope < 4 ; Limit the scope so the next recursion doesn't go deeper
                    scope := 1
                for child in el.CachedChildren {
                    if (found := PostOrderFirstToLastRecursiveFind(child))
                        return found
                }
            }
            if (startingElement ? (startingElement = UIA.RuntimeIdToString(el.GetRuntimeId()) ? !(startingElement := "") : 0) : 1) && el.ValidateCondition(condition, true) && --index = 0
                return el
        }
        PostOrderLastToFirstRecursiveFind(el) {
            if scope > 1 {
                if scope < 4 ; Limit the scope so the next recursion doesn't go deeper
                    scope := 1
                children := el.CachedChildren, len := children.Length + 1
                Loop len-1 {
                    if found := PostOrderLastToFirstRecursiveFind(children[len-A_index])
                        return found
                }
            }
            if (startingElement ? (startingElement = UIA.RuntimeIdToString(el.GetRuntimeId()) ? !(startingElement := "") : 0) : 1) && el.ValidateCondition(condition, true) && --index = 0
                return el
        }
    }

    /**
     * Returns all UI Automation elements that satisfy the specified condition.
     * @param condition The condition to filter with.  
     * The condition object additionally supports named parameters.  
     * Default MatchMode is "Exact", and CaseSense "On".  
     * See a more detailed explanation under FindElement condition argument.  
     * @param scope Optional TreeScope value: Element, Children, Family (Element+Children), Descendants, Subtree (=Element+Descendants). Default is Descendants.
     * @param order Optional: custom tree navigation order, one of UIA.TreeTraversalOptions values (LastToFirstOrder, PostOrder, LastToFirstPostOrder). Default is FirstToLast and PreOrder. [requires Windows 10 version 1703+]
     * @param startingElement Optional: element with which to begin the search [requires Windows 10 version 1703+]
     * @param cacheRequest Optional: cache request object
     * @returns {[UIA.IUIAutomationElement]}
     */
    FindElements(condition, scope := 4, order:=0, startingElement:=0, cacheRequest:=0) {
        local withOptions
        condition := UIA.IUIAutomationElement.__ExtractConditionNamedParameters(condition, &scope, &order, &startingElement, &cacheRequest)
        condition := UIA.TypeValidation.Condition(condition), scope := UIA.TypeValidation.TreeScope(scope), order := UIA.TypeValidation.TreeTraversalOptions(order), startingElement := UIA.TypeValidation.Element(startingElement), cacheRequest := UIA.TypeValidation.CacheRequest(cacheRequest)
        withOptions := order || startingElement
        if withOptions && !UIA.IsIUIAutomationElement7Available && InStr(Type(condition), "Condition")
            throw ValueError("If using order or startingElement arguments in Windows <10.0.15063, then condition cannot be IUIAutomationCondition", -1)
        if !InStr(Type(condition), "Condition") {
            IUIAcondition := UIA.__ConditionBuilder(condition, &nonUIAEncountered:=False), unfilteredEls := [], filteredEls := []
            if nonUIAEncountered = 2 ; A cached name was encountered, use FindCachedElements instead
                return this.FindCachedElements(condition, scope, order, startingElement)
            else if nonUIAEncountered = 1 || (withOptions && (!UIA.IsIUIAutomationElement7Available || (scope < 4 && startingElement))) {
                cache := this.BuildUpdatedCache(UIA.CreateCacheRequest(condition,,scope,,scope>3 ? IUIAcondition : unset))
                found := cache.FindCachedElements(condition, scope, order, startingElement)
                if cacheRequest {
                    Loop found.Length
                        found[A_Index] := found[A_Index].BuildUpdatedCache(cacheRequest)
                }
                return found
            }
            unfilteredCondition := condition, condition := IUIAcondition
        }
        if !startingElement ; If FindFirstWithOptions is used but startingElement isn't set, start from this element.
            startingElement := this
        if cacheRequest {
            if withOptions
                ComCall(113, startingElement, "int", scope, "ptr", condition, "ptr", cacheRequest, "int", order, "ptr", this, "ptr*", &found := 0) ; FindAllWithOptionsBuildCache
            else
                ComCall(8, this, "int", scope, "ptr", condition, "ptr", cacheRequest, "ptr*", &found := 0) ; FindAllBuildCache
        } else {
            if withOptions
                ComCall(111, startingElement, "int", scope, "ptr", condition, "int", order, "ptr", this, "ptr*", &found := 0) ; FindAllWithOptions
            else
                ComCall(6, this, "int", scope, "ptr", condition, "ptr*", &found := 0) ; FindAll
        }
        return found ? UIA.IUIAutomationElementArray(found).ToArray() : []
    }

    /**
     * Returns all UI Automation elements that satisfy the specified condition inside a cached tree, checking only cached properties.
     * This is not a UIA native method: make sure the cached tree is reasonably small, otherwise the performance will suffer.
     * @param condition The condition to filter with.  
     * The condition object additionally supports named parameters.  
     * Default MatchMode is "Exact", and CaseSense "On".  
     * See a more detailed explanation under FindElement condition argument.
     * @param scope Optional TreeScope value: Element, Children, Family (Element+Children), Descendants, Subtree (=Element+Descendants). Default is Descendants.
     * @param order Optional: custom tree navigation order, one of UIA.TreeTraversalOptions values (LastToFirstOrder, PostOrder, LastToFirstPostOrder). Default is FirstToLast and PreOrder.
     * @param startingElement Optional: element with which to begin the search
     *     Unlike FindElements, using this will not give a performance benefit.
     * @returns {[UIA.IUIAutomationElement]}
     */
    FindCachedElements(condition, scope:=4, order:=0, startingElement:=0) {
        condition := UIA.IUIAutomationElement.__ExtractConditionNamedParameters(condition, &scope, &order, &startingElement)
        condition := UIA.TypeValidation.Condition(condition), scope := UIA.TypeValidation.TreeScope(scope), order := UIA.TypeValidation.TreeTraversalOptions(order), startingElement := UIA.TypeValidation.Element(startingElement)
        if startingElement
            startingElement := UIA.RuntimeIdToString(startingElement.GetRuntimeId())
        foundElements := []
        ; First handle PostOrder
        if order&1
            return (order&2 ? PostOrderLastToFirstRecursiveFind(this) : PostOrderFirstToLastRecursiveFind(this), foundElements)
        ; PreOrder
        if scope&1 && this.ValidateCondition(condition, true)
            foundElements.Push(this)
        if scope > 1
            return (order&2 ? PreOrderLastToFirstRecursiveFind(this) : PreOrderFirstToLastRecursiveFind(this), foundElements)
        PreOrderFirstToLastRecursiveFind(el) {
            for child in el.CachedChildren {
                if (startingElement ? (startingElement = UIA.RuntimeIdToString(child.GetRuntimeId()) ? !(startingElement := "") : 0) : 1) && child.ValidateCondition(condition, true)
                    foundElements.Push(child)
                if scope&4
                    PreOrderFirstToLastRecursiveFind(child)
            }
        }
        PreOrderLastToFirstRecursiveFind(el) {
            children := el.CachedChildren, len := children.Length + 1
            Loop len-1 {
                child := children[len-A_index]
                if (startingElement ? (startingElement = UIA.RuntimeIdToString(child.GetRuntimeId()) ? !(startingElement := "") : 0) : 1) && child.ValidateCondition(condition, true)
                    foundElements.Push(child)
                if scope&4
                    PreOrderLastToFirstRecursiveFind(child)
            }
        }
        PostOrderFirstToLastRecursiveFind(el) {
            if scope > 1 {
                if scope < 4 ; Limit the scope so the next recursion doesn't go deeper
                    scope := 1
                for child in el.CachedChildren
                    PostOrderFirstToLastRecursiveFind(child)
            }
            if (startingElement ? (startingElement = UIA.RuntimeIdToString(el.GetRuntimeId()) ? !(startingElement := "") : 0) : 1) && el.ValidateCondition(condition, true)
                foundElements.Push(el)
        }
        PostOrderLastToFirstRecursiveFind(el) {
            if scope > 1 {
                if scope < 4 ; Limit the scope so the next recursion doesn't go deeper
                    scope := 1
                children := el.CachedChildren, len := children.Length + 1
                Loop len-1
                    PostOrderLastToFirstRecursiveFind(children[len-A_index])
            }
            if (startingElement ? (startingElement = UIA.RuntimeIdToString(el.GetRuntimeId()) ? !(startingElement := "") : 0) : 1) && el.ValidateCondition(condition, true)
                foundElements.Push(el)
        }
    }

    /**
     * Wait element to exist.
     * @param condition The condition to filter with.  
     * The condition object additionally supports named parameters.  
     * See a more detailed explanation under FindElement condition argument.
     * @param timeOut Waiting time for element to appear in ms. Default: indefinite wait
     * @param scope Optional TreeScope value: Element, Children, Family (Element+Children), Descendants, Subtree (=Element+Descendants). Default is Descendants.
     * @param index Looks for the n-th element matching the condition
     * @param order Optional: custom tree navigation order, one of UIA.TreeTraversalOptions values (LastToFirstOrder, PostOrder, LastToFirstPostOrder) [requires Windows 10 version 1703+]
     * @param startingElement Optional: element with which to begin the search [requires Windows 10 version 1703+]
     * @param cacheRequest Optional: cache request object
     * @returns {UIA.IUIAutomationElement} Found element if successful, 0 if timeout happens
     */
    WaitElement(condition, timeOut := -1, scope := 4, index := 1, order := 0, startingElement := 0, cacheRequest := 0) {
        timeOut := condition.HasOwnProp("timeOut") ? condition.timeOut : timeOut
        timeOut := UIA.TypeValidation.Integer(timeOut, "TimeOut")
        endtime := A_TickCount + timeOut
        While ((timeOut == -1) || (A_Tickcount < endtime)) {
            try return this.FindElement(condition, scope, index, order, startingElement, cacheRequest)
            Sleep 20
        }
        return 0
    }

    /**
     * Wait element to not exist (disappear).
     * @param condition The condition to filter with.  
     * The condition object additionally supports named parameters.  
     * See a more detailed explanation under FindElement condition argument.
     * @param timeout Waiting time for element to disappear. Default: indefinite wait
     * @param scope Optional TreeScope value: Element, Children, Family (Element+Children), Descendants, Subtree (=Element+Descendants). Default is Descendants.
     * @param order Optional: custom tree navigation order, one of UIA.TreeTraversalOptions values (LastToFirstOrder, PostOrder, LastToFirstPostOrder) [requires Windows 10 version 1703+]
     * @param startingElement Optional: element with which to begin the search [requires Windows 10 version 1703+]
     * @param cacheRequest Optional: cache request object
     * @returns 1 if element disappeared, 0 otherwise
     */
    WaitElementNotExist(condition, timeout := -1, scope := 4, index := 1, order := 0, startingElement := 0, cacheRequest := 0) {
        timeOut := condition.HasOwnProp("timeOut") ? condition.timeOut : timeOut
        endtime := A_TickCount + timeout
        While (timeout == -1) || (A_Tickcount < endtime) {
            try this.FindElement(condition, scope, index, order, startingElement, cacheRequest)
            catch
                return 1
        }
        return 0
    }

    /**
     * Tries to get an element from a path. If no element is found, an IndexError is thrown.  
     * `ElementFromPath(path1[, path2, ...])`  
     * 
     * Paths can be:
     * 1. Comma-separated numeric path that defines which path to travel down the tree. In addition
     *     to integer values, or TypeN which selects the nth occurrence of Type.  
     *     Eg. `Element.ElementFromPath("3,2")` => selects Elements third childs second child  
     *         `Element.ElementFromPath("Button3,2")` => selects Elements third child of type Button, then its second child
     *
     * 2. UIA path copied from UIAViewer.  
     *     Eg. `Element.ElementFromPath("bAx3")`
     *
     * 3. A condition or conditions. In this case the provided conditions define the route of tree-traversal, by default with Scope Children.  
     *        Eg. `Element.ElementFromPath({Type:"Button"}, {Type:"List"})` => finds the first Button type child of Element, then the first List type child of that element
     *
     * @returns {UIA.IUIAutomationElement}
     */
    ElementFromPath(paths*) {
        try return this[paths*]
        catch IndexError as err
            throw IndexError(StrReplace(err.Message, "at index", "at argument"), -1, err.Extra)
    }

    /**
     * Tries to get a cached element from a path. If no element is found, an IndexError is thrown.  
     * This method uses only cached elements and cached properties to perform the search.  
     * `CachedElementFromPath(path1[, path2, ...])`  
     * 
     * Paths can be:
     * 1. Comma-separated numeric path that defines which path to travel down the tree. In addition
     *     to integer values, or TypeN which selects the nth occurrence of Type.  
     *     Eg. `Element.ElementFromPath("3,2")` => selects Elements third childs second child  
     *         `Element.ElementFromPath("Button3,2")` => selects Elements third child of type Button, then its second child
     *
     * 2. UIA path copied from UIAViewer.  
     *     Eg. `Element.ElementFromPath("bAx3")`
     *
     * 3. A condition or conditions. In this case the provided conditions define the route of tree-traversal, by default with Scope Children.  
     *        Eg. `Element.ElementFromPath({Type:"Button"}, {Type:"List"})` => finds the first Button type child of Element, then the first List type child of that element
     *
     * @returns {UIA.IUIAutomationElement}
     */
    CachedElementFromPath(paths*) {
        local el := this, _, path, subpath
        for _, path in paths {
            if IsObject(path) {
                try el := el.FindCachedElement(path, 2)
                catch
                    el := ""
            } else if IsInteger(path) {
                try {
                    arr := el.CachedChildren
                    el := arr[path < 0 ? arr.Length+path+1 : path]
                } catch
                    el := ""
            } else if path is String {
                maybeEl := ""
                for subpath in StrSplit(path, "|") {
                    try {
                        if InStr(subpath, ".") || InStr(subpath, ",")
                            maybeEl := el.CachedElementFromPath(StrSplit(StrReplace(subpath, ".", ","), ",")*)
                        else if RegexMatch(subpath, "i)([a-zA-Z]+) *(\d+)?", &m:="") && UIA.Type.HasOwnProp(m[1]) {
                            try maybeEl := el.FindCachedElement({Type:m[1], i:m[2]}, 2)
                        } else if !(subpath ~= ",\.+-")
                            maybeEl := el.CachedElementFromPath(UIA.DecodePath(subpath)*)
                        else
                            continue
                        break ; no errors encountered means that match was found
                    }
                }
                el := maybeEl
            } else
                throw TypeError("Invalid item type at index " _, -1)
            if !el
                throw IndexError("Invalid index/condition at index " _, -1)
        }
        return el
    }

    /**
     * Checks whether an element exists at a path and returns the element if one is found.
     * If no element is found, 0 is returned.
     * `ElementFromPathExist(path1[, path2, ...])`
     *
     * Paths can be:
     * 1. Comma-separated numeric path that defines which path to travel down the tree. In addition
     *     to integer values, or TypeN which selects the nth occurrence of Type.  
     *     Eg. `Element.ElementFromPath("3,2")` => selects Elements third childs second child  
     *         `Element.ElementFromPath("Button3,2")` => selects Elements third child of type Button, then its second child
     *
     * 2. UIA path copied from UIAViewer.  
     *     Eg. `Element.ElementFromPath("bAx3")`
     *
     * 3. A condition or conditions. In this case the provided conditions define the route of tree-traversal, by default with Scope Children.  
     *        Eg. `Element.ElementFromPath({Type:"Button"}, {Type:"List"})` => finds the first Button type child of Element, then the first List type child of that element
     *
     * @returns {UIA.IUIAutomationElement}
     */
    ElementFromPathExist(paths*) {
        try return this[paths*]
        catch IndexError
            return 0
        return 0
    }

    /**
     * Checks whether a cached element exists at a path and returns the cached element if one is found.  
     * This method uses only cached elements and cached properties to perform the search.  
     * If no element is found, 0 is returned.
     * 
     * @param paths Either an UIA path, numeric path, or condition path.  
     * See longer explanation under CachedElementFromPath
     * 
     * @returns {UIA.IUIAutomationElement}
     */
    CachedElementFromPathExist(paths*) {
        try return this.CachedElementFromPath(paths*)
        catch IndexError
            return 0
        return 0
    }

    /**
     * Wait element to appear at a path.  
     * `WaitElementFromPath(path1[, path2, ...])`
     *
     * Paths can be:
     * 1. Comma-separated numeric path that defines which path to travel down the tree. In addition
     *     to integer values, or TypeN which selects the nth occurrence of Type.  
     *     Eg. `Element.ElementFromPath("3,2")` => selects Elements third childs second child  
     *         `Element.ElementFromPath("Button3,2")` => selects Elements third child of type Button, then its second child
     *
     * 2. UIA path copied from UIAViewer.  
     *     Eg. `Element.ElementFromPath("bAx3")`
     *
     * 3. A condition or conditions. In this case the provided conditions define the route of tree-traversal, by default with Scope Children.  
     *        Eg. `Element.ElementFromPath({Type:"Button"}, {Type:"List"})` => finds the first Button type child of Element, then the first List type child of that element
     *
     * @returns {UIA.IUIAutomationElement}
     */
    WaitElementFromPath(paths*) {
        local timeOut := -1
        if paths.Length > 1 && paths[paths.Length] is Integer
            paths := paths.Clone(), timeOut := paths.Pop()
        endtime := A_TickCount + timeOut
        While ((timeOut == -1) || (A_Tickcount < endtime)) {
            try return this[paths*]
            Sleep 20
        }
    }

    /**
     * Traverses the tree purely using a TreeWalker that is created with an optional filter-condition (default is TrueCondition)
     * @param searchPath This is a comma-separated path that defines the route of tree traversal:
     * * n: gets the nth child (using GetFirstChildElement and GetNextSiblingElement)
     * * +n: gets the nth next sibling
     * * -n: gets the nth previous sibling
     * * pn: gets the nth parent
     * * "n": normalizes the element (returns the first parent or the element itself matching the filterCondition)
     * @param filterCondition Optional: a condition for tree traversal that selects only elements that match the condition.
     * @example Element.ElementFromPath("p,+2,1") ; gets the parent of Element, then the second sibling of the parent, then that siblings first child.
     * @returns {UIA.IUIAutomationElement}
     */
    WalkTree(searchPath, filterCondition?) {
        PathTW := IsSet(filterCondition) ? UIA.CreateTreeWalker(filterCondition) : UIA.TreeWalkerTrue
        el := this, searchPath := StrReplace(StrReplace(String(searchPath), " "), ".", ",")
        Loop Parse searchPath, "," {
            try {
                if IsDigit(A_LoopField) {
                    loopFunc := "GetFirstChildElement", el := PathTW.GetFirstChildElement(el)
                    if A_LoopField > 1
                        el := el.WalkTree("+" A_LoopField-1)
                } else if A_LoopField = "n" {
                    loopFunc := "NormalizeElement", el := PathTW.NormalizeElement(el)
                } else if RegexMatch(A_LoopField, "i)([p+-]+) *(\d+)?", &m:="") {
                    if (loopFunc := (m[1] = "p") ? "GetParentElement" : (m[1] = "+") ? "GetNextSiblingElement" : (m[1] = "-") ? "GetPreviousSiblingElement" : "") {
                        Loop m[2] || 1 {
                            el := PathTW.%loopFunc%(el)
                        }
                    } else
                        throw ValueError()
                } else
                    throw ValueError()
            } catch TargetError, IndexError {
                throw IndexError("Step " A_index " with value " A_LoopField " was out of bounds (" loopFunc " failed)", -1)
            } catch ValueError {
                throw ValueError("Invalid path value " A_LoopField " at step " A_index, -1)
            } catch OSError as err {
                throw ValueError("Step " A_index " with value " A_LoopField " caused COM error: " err.Message, -1, "Make sure the element is valid and not cached (use WalkCachedTree for cached elements).")
            } catch Any as err
                throw
        }
        return el
    }

    /**
     * Traverses the cached tree, optionally filtering by filterCondition
     * @param searchPath This is a comma-separated path that defines the route of tree traversal:
     * * n: gets the nth child (using GetFirstChildElement and GetNextSiblingElement)
     * * +n: gets the nth next sibling
     * * -n: gets the nth previous sibling
     * * pn: gets the nth parent
     * * "n": normalizes the element (returns the first parent or the element itself matching the filterCondition)
     * @param filterCondition Optional: a condition for tree traversal that selects only elements that match the condition.
     * @example Element.ElementFromPath("p,+2,1") ; gets the parent of Element, then the second sibling of the parent, then that siblings first child.
     * @returns {UIA.IUIAutomationElement}
     */
    WalkCachedTree(searchPath, filterCondition?) {
        el := this, searchPath := StrReplace(StrReplace(String(searchPath), " "), ".", ",")
        Loop Parse searchPath, "," {
            try {
                if IsDigit(A_LoopField) {
                    el := el.CachedChildren[A_LoopField]
                } else if A_LoopField = "n" {
                    if !IsSet(filterCondition)
                        throw Error("Normalizing an element requires a filterCondition", -1)
                    if !this.ValidateCondition(filterCondition, true) {
                        if !(parent := el.CachedParent)
                            throw TargetError()
                        el := parent.WalkCachedTree("n", filterCondition)
                    }
                } else if RegexMatch(A_LoopField, "i)([p+-]+) *(\d+)?", &m:="") {
                    if (m[1] = "p") {
                        counter := 0, steps := m[2] || 1
                        Loop {
                            if !(el := el.CachedParent)
                                throw TargetError()
                            if IsSet(filterCondition) && !el.ValidateCondition(filterCondition, true)
                                continue
                            if ++counter = steps
                                break
                        }
                    } else if (m[1] = "+") || (m[1] = "-") {
                        parent := el.CachedParent, children := parent.CachedChildren
                        if !parent
                            throw TargetError()
                        if IsSet(filterCondition) {
                            startingIndex := GetIndex(parent), counter := 0, steps := Integer(m[2] || 1)
                            Loop (m[1] = "+") ? children.Length - startingIndex : startingIndex - 1 {
                                child := children[startingIndex + ((m[1] = "+") ? A_index : -A_index)]
                                if child.ValidateCondition(filterCondition, true) && ++counter = steps {
                                    el := child
                                    break
                                }
                                RecurseTree(child)
                                if counter = steps
                                    break
                            }
                            if counter != steps
                                el := ""
                        } else
                            el := parent[GetIndex(parent) + ((m[1] = "+") ? (m[2] || 1) : -(m[2] || 1))]
                    } else
                        throw ValueError()
                }
            } catch TargetError, IndexError {
                throw IndexError("Step " A_index " with value " A_LoopField " was out of bounds", -1)
            } catch ValueError {
                throw ValueError("Invalid path value " A_LoopField " at step " A_index, -1)
            } catch OSError as err {
                throw ValueError("Step " A_index " with value " A_LoopField " caused COM error: " err.Message, -1, "Either CachedParent or CachedChildren failed: make sure the target and the targets parent are cached.")
            } catch Any as err
                throw
            if !el
                throw IndexError("No element found after step " A_index " with value " A_LoopField, -1)
        }
        return el
        GetIndex(parent) {
            local elId, i, child
            elId := UIA.RuntimeIdToString(el.GetRuntimeId())
            for i, child in parent.CachedChildren {
                if UIA.RuntimeIdToString(child.GetRuntimeId()) = elId
                    return i
            }
        }
        RecurseTree(parent) {
            local children := parent.CachedChildren, child
            if (m[1] = "+") {
                for child in children {
                    if child.ValidateCondition(filterCondition, true) && ++counter = steps
                        return el := child
                    if RecurseTree(child)
                        return
                }
            } else {
                Loop children.Length {
                    child := children[children.Length-A_Index+1]
                    if child.ValidateCondition(filterCondition, true) && ++counter = steps
                        return el := child
                    if RecurseTree(child)
                        return
                }
            }
        }
    }

    ; Gets all property values of this element and returns an object where Object.PropertyName = PropertyValue
    ; Use only for debugging purposes, since this will be quite slow.
    GetAllPropertyValues() {
        local infos := {}, k, v, arr, t
        for k, v in UIA.Property.OwnProps() {
            v := this.GetPropertyValue(v)
            if (v is ComObjArray) {
                arr := []
                for t in v
                    arr.Push(t)
                v := arr
            }
            infos.%k% := v
        }
        return infos
    }

    ; Internal method: checks whether this element matches the condition
    ValidateCondition(cond, cached:=False) {
        local mm := 3, cs := 1, notCond := 0, k, v, result, i, val
        switch Type(cond) {
            case "Object":
                mm := cond.HasOwnProp("matchmode") ? cond.matchmode : cond.HasOwnProp("mm") ? cond.mm : 3
                cs := cond.HasOwnProp("casesense") ? cond.casesense : cond.HasOwnProp("cs") ? cond.cs : 1
                if !IsInteger(mm)
                    mm := UIA.MatchMode.%mm%
                if !IsInteger(cs)
                    cs := UIA.CaseSense.%cs%
                notCond := cond.HasOwnProp("operator") ? cond.operator = "not" : cond.HasOwnProp("op") ? cond.op = "not" : 0
                cond := cond.OwnProps()
            case "Array":
                for k, v in cond {
                    if IsObject(v) && this.ValidateCondition(v, cached)
                        return true
                }
                return false
            default:
                throw ValueError("Condition of type " Type(cond) " is an invalid ValidateCondition condition", -1, "The condition can be an Object or Array")
        }
        for k, v in cond {
            try k := UIA.TypeValidation.Property(k)
            if !(IsInteger(k) && k >= 10000) {
                if IsObject(v) {
                    if (k = "not" ? this.ValidateCondition(v, cached) : !this.ValidateCondition(v, cached))
                        return False
                }
                continue
            }
            if k = 30003 
                v := UIA.TypeValidation.Type(v)
            try currentValue := this.Get%cached ? "Cached" : ""%PropertyValue(k)
            catch { ; If caching is used, should this throw an error to notify the user of a missing cache property?
                result := 0
            } else {
                switch UIA.PropertyVariantType[k] {
                    case 8:
                        if v is Array {
                            for val in v {
                                if (result := CompareStrings(currentValue, val, mm, cs))
                                    break
                            }
                        } else 
                            result := CompareStrings(currentValue, v, mm, cs)
                    case 3,5,11:
                        if v is Array {
                            for val in v {
                                if k = 30003
                                    val := UIA.TypeValidation.Type(val)
                                if (result := currentValue == val)
                                    break
                            }
                        } else 
                        result := currentValue == v
                    default:
                        if Type(v) = "Object"
                            v := v.OwnProps(), currentValue := currentValue is Array ? currentValue : currentValue.OwnProps()
                        if not v is Array
                            throw ValueError("Invalid PropertyId " k, -1)
                        result := 1
                        for i, val in v {
                            try {
                                if currentValue[i] == val
                                    continue
                            } catch {
                                result := 0
                                break
                            }
                        }
                }
            }
            if notCond ? result : !result
                return False
        }
        return True

        CompareStrings(str1, str2, matchmode, casesense) {
            if not str1 is String
                str1 := String(str1)
            if not str2 is String
                str2 := String(str2)
            if matchmode = "RegEx"
                return RegExMatch(str1, str2)
            else if matchmode = 1
                return ((casesense && SubStr(str1, 1, StrLen(str2)) == str2) || (!casesense && SubStr(str1, 1, StrLen(str2)) = str2))
            else if matchmode = 2
                return InStr(str1, str2, casesense)
            else
                return (casesense ? str1 == str2 : str1 = str2)
        }
    }

    ; Sets the keyboard focus to this UI Automation element.
    SetFocus() => ComCall(3, this)

    ; Retrieves the unique identifier assigned to the UI element.
    ; The identifier is only guaranteed to be unique to the UI of the desktop on which it was generated. Identifiers can be reused over time.
    ; The format of run-time identifiers might change in the future. The returned identifier should be treated as an opaque value and used only for comparison; for example, to determine whether a Microsoft UI Automation element is in the cache.
    GetRuntimeId() {
        local runtimeId
        return (ComCall(4, this, "ptr*", &runtimeId := 0), UIA.SafeArrayToAHKArray(runtimeId))
    }

    /**
     * Retrieves the first child or descendant element that matches the specified condition.
     * The scope of the search is relative to the element on which the method is called. Elements are returned in the order in which they are encountered in the tree.
     * This function cannot search for ancestor elements in the UIA tree; that is, UIA.TreeScope.Ancestors is not a valid value for the scope parameter.
     * When searching for top-level windows on the desktop, be sure to specify UIA.TreeScope.Children in the scope parameter, not UIA.TreeScope.Descendants. A search through the entire subtree of the desktop could iterate through thousands of items and lead to a stack overflow.
     * @param condition The condition to filter with. MatchModes StartsWith, RegEx, and using indexes are not supported with FindFirst, use FindElement for that.
     * @param scope Optional TreeScope value: Element, Children, Family (Element+Children), Descendants, Subtree (=Element+Descendants). Default is Descendants.
     * @returns {UIA.IUIAutomationElement}
     */
    FindFirst(condition?, scope:=4) {
        condition := UIA.TypeValidation.Condition(condition), scope := UIA.TypeValidation.TreeScope(scope)
        if !(condition is UIA.IUIAutomationCondition)
            condition := UIA.__CreateRawCondition(condition)
        if (ComCall(5, this, "int", scope, "ptr", condition ?? UIA.TrueCondition, "ptr*", &found := 0), found)
            return UIA.IUIAutomationElement(found)
        throw TargetError("An element matching the condition was not found", -1)
    }

    /**
     * Returns all UI Automation elements that satisfy the specified condition.
     * The scope of the search is relative to the element on which the method is called. Elements are returned in the order in which they are encountered in the tree.
     * This function cannot search for ancestor elements in the UIA tree; that is, UIA.TreeScope.Ancestors is not a valid value for the scope parameter.
     * When searching for top-level windows on the desktop, be sure to specify UIA.TreeScope.Children in the scope parameter, not UIA.TreeScope.Descendants. A search through the entire subtree of the desktop could iterate through thousands of items and lead to a stack overflow.
     * @param condition The condition to filter with.
     * @param scope Optional TreeScope value: Element, Children, Family (Element+Children), Descendants, Subtree (=Element+Descendants). Default is Descendants.
     * @returns {[UIA.IUIAutomationElement]}
     */
    FindAll(condition?, scope := 4) {
        if !IsObject(condition)
            throw TypeError("Condition must be an condition object or array", -1)
        if !InStr(Type(condition), "Condition")
            condition := UIA.__CreateRawCondition(condition)
        return (ComCall(6, this, "int", UIA.TypeValidation.TreeScope(scope), "ptr", condition ?? UIA.TrueCondition, "ptr*", &found := 0), found) ? UIA.IUIAutomationElementArray(found).ToArray() : []
    }

    ; Retrieves the first child or descendant element that matches the specified condition, prefetches the requested properties and control patterns, and stores the prefetched items in the cache.
    FindFirstBuildCache(cacheRequest, condition?, scope := 4) {
        if !InStr(Type(condition), "Condition")
            condition := UIA.__CreateRawCondition(condition)
        if (ComCall(7, this, "int", UIA.TypeValidation.TreeScope(scope), "ptr", condition ?? UIA.TrueCondition, "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr*", &found := 0), found)
            return UIA.IUIAutomationElement(found)
        throw TargetError("An element matching the condition was not found", -1)
    }

    ; Returns all UI Automation elements that satisfy the specified condition, prefetches the requested properties and control patterns, and stores the prefetched items in the cache.
    FindAllBuildCache(cacheRequest, condition?, scope := 4) {
        if !InStr(Type(condition), "Condition")
            condition := UIA.__CreateRawCondition(condition)
        return (ComCall(8, this, "int", UIA.TypeValidation.TreeScope(scope), "ptr", condition ?? UIA.TrueCondition, "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr*", &found := 0), found) ? UIA.IUIAutomationElementArray(found).ToArray() : []
    }

    ; Retrieves a  UI Automation element with an updated cache.
    ; The original UI Automation element is unchanged. The  UIA.IUIAutomationElement interface refers to the same element and has the same runtime identifier.
    BuildUpdatedCache(cacheRequest) {
        local updatedElement
        return (ComCall(9, this, "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr*", &updatedElement := 0), UIA.IUIAutomationElement(updatedElement))
    }

    ; Microsoft UI Automation properties of the double type support Not a Number (NaN) values. When retrieving a property of the double type, a client can use the _isnan function to determine whether the property is a NaN value.

    ; Retrieves the current value of a property for this UI Automation element.
    ; This gets called when Element.Property is used
    GetPropertyValue(propertyId) {
        local val
        if !IsNumber(propertyId)
            try propertyId := UIA.Property.%propertyId%
        ComCall(10, this, "int", propertyId, "ptr", val := UIA.ComVar())
        return val[] is ComObjArray ? UIA.SafeArrayToAHKArray(val[]) : val[]
    }

    ; Retrieves a property value for this UI Automation element, optionally ignoring any default value.
    ; Passing FALSE in the ignoreDefaultValue parameter is equivalent to calling UIA.IUIAutomationElement.GetPropertyValue.
    ; If the Microsoft UI Automation provider for the element itself supports the property, the value of the property is returned. Otherwise, if ignoreDefaultValue is FALSE, a default value specified by UI Automation is returned.
    ; This method returns a failure code if the requested property was not previously cached.
    GetPropertyValueEx(propertyId, ignoreDefaultValue) {
        local val
        ComCall(11, this, "int", UIA.TypeValidation.Property(propertyId), "int", ignoreDefaultValue, "ptr", val := UIA.ComVar())
        return val[] is ComObjArray ? UIA.SafeArrayToAHKArray(val[]) : val[]
    }

    ; Retrieves a property value from the cache for this UI Automation element.
    ; This is called when Element.CachedProperty is used (eg Element.CachedName)
    GetCachedPropertyValue(propertyId) {
        local val
        ComCall(12, this, "int", UIA.TypeValidation.Property(propertyId), "ptr", val := UIA.ComVar())
        return val[] is ComObjArray ? UIA.SafeArrayToAHKArray(val[]) : val[]
    }

    ; Retrieves a property value from the cache for this UI Automation element, optionally ignoring any default value.
    GetCachedPropertyValueEx(propertyId, ignoreDefaultValue, retVal) {
        local val
        ComCall(13, this, "int", UIA.TypeValidation.Property(propertyId), "int", ignoreDefaultValue, "ptr", val := UIA.ComVar())
        return val[] is ComObjArray ? UIA.SafeArrayToAHKArray(val[]) : val[]
    }

    ; Retrieves the control pattern interface of the specified pattern on this UI Automation element.
    ; For riid specify a GUID string, that is the IID for the desired pattern
    ; GetPatternAs doesn't have a use in this library, use GetPattern instead
    GetPatternAs(patternId, riid) {
        try {
            if IsInteger(patternId)
                name := UIA.Pattern[patternId]
            else
                patternId := UIA.Pattern.%(name := patternId)%
        } catch
            Throw ValueError("Failed to find pattern `"" name "`" among UIA.Pattern properties/values", -1)
        DllCall("ole32\CLSIDFromString", "wstr", riid, "ptr", GUID:=Buffer(16))
        ComCall(14, this, "int", patternId, "ptr", GUID, "ptr*", &patternObject := 0)
        return UIA.IUIAutomation%name%Pattern(patternObject)
    }

    ; Retrieves the control pattern interface of the specified pattern from the cache of this UI Automation element.
    ; GetCachedPatternAs doesn't have a use in this library, use GetCachedPattern instead
    GetCachedPatternAs(patternId, riid) {	; not completed
        try {
            if IsInteger(patternId)
                name := UIA.Pattern[patternId]
            else
                patternId := UIA.Pattern.%(name := patternId)%
        } catch
            Throw ValueError("Failed to find pattern `"" name "`" among UIA.Pattern properties/values", -1)
        DllCall("ole32\CLSIDFromString", "wstr", riid, "ptr", GUID:=Buffer(16))
        ComCall(15, this, "int", patternId, "ptr", GUID, "ptr*", &patternObject := 0)
        return UIA.IUIAutomation%name%Pattern(patternObject)
    }

    ; Retrieves the IUnknown interface of the specified control pattern on this UI Automation element.
    ; This method gets the specified control pattern based on its availability at the time of the call.
    ; For some forms of UI, this method will incur cross-process performance overhead. Applications can reduce overhead by caching control patterns and then retrieving them by using UIA.IUIAutomationElement,,GetCachedPattern.
    GetPattern(patternId) {
        try {
            if IsInteger(patternId)
                name := UIA.Pattern[patternId]
            else
                patternId := UIA.Pattern.%(name := StrReplace(patternId, "Pattern"))%
        } catch
            Throw ValueError("Failed to find pattern `"" name "`" among UIA.Pattern properties/values", -1)
        ComCall(16, this, "int", patternId, "ptr*", &patternObject := 0)
        return UIA.IUIAutomation%RegExReplace(name, "\d+$")%Pattern(patternObject)
    }

    ; Retrieves from the cache the IUnknown interface of the specified control pattern of this UI Automation element.
    GetCachedPattern(patternId) {
        try {
            if IsInteger(patternId)
                name := UIA.Pattern[patternId]
            else
               patternId := UIA.Pattern.%(name := StrReplace(patternId, "Pattern"))%
        } catch
            Throw ValueError("Failed to find pattern `"" name "`" among UIA.Pattern properties/values", -1)
        ComCall(17, this, "int", patternId, "ptr*", &patternObject := 0)
        return UIA.IUIAutomation%RegExReplace(name, "\d+$")%Pattern(patternObject)
    }

    ; Retrieves the identifier of the process that hosts the element.
    ProcessId {
        get {
            local retVal
            return (ComCall(20, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the control type of the element.
    ; Control types describe a known interaction model for UI Automation elements without relying on a localized control type or combination of complex logic rules. This property cannot change at run time unless the control supports the IUIAutomationMultipleViewPattern interface. An example is the Win32 ListView control, which can change from a data grid to a list, depending on the current view.
    Type {
        get {
            local retVal
            return (ComCall(21, this, "int*", &retVal := 0), retVal)
        }
    }
    ControlType => this.Type

    ; Retrieves a localized description of the control type of the element.
    LocalizedType {
        get {
            local retVal
            return (ComCall(22, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }
    LocalizedControlType => this.LocalizedType

    ; Retrieves the name of the element.
    Name {
        get {
            local retVal
            return (ComCall(23, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }

    ; Retrieves the accelerator key for the element.
    AcceleratorKey {
        get {
            local retVal
            return (ComCall(24, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }

    ; Retrieves the access key character for the element.
    ; An access key is a character in the text of a menu, menu item, or label of a control such as a button that activates the attached menu function. For example, the letter "O" is often used to invoke the Open file common dialog box from a File menu. Microsoft UI Automation elements that have the access key property set always implement the Invoke control pattern.
    AccessKey {
        get {
            local retVal
            return (ComCall(25, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }

    ; Indicates whether the element has keyboard focus.
    HasKeyboardFocus {
        get {
            local retVal
            return (ComCall(26, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Indicates whether the element can accept keyboard focus.
    IsKeyboardFocusable {
        get {
            local retVal
            return (ComCall(27, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves a cached value that indicates whether the element is enabled.
    IsEnabled {
        get {
            local retVal
            return (ComCall(28, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the Microsoft UI Automation identifier of the element.
    ; The identifier is unique among sibling elements in a container, and is the same in all instances of the application.
    AutomationId {
        get {
            local retVal
            return (ComCall(29, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }

    ; Retrieves the class name of the element.
    ; The value of this property is implementation-defined. The property is useful in testing environments.
    ClassName {
        get {
            local retVal
            return (ComCall(30, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }

    ; Retrieves the help text for the element. This information is typically obtained from tooltips.
    ; Caution  Do not retrieve the CachedHelpText property from a control that is based on the SysListview32 class. Doing so could cause the system to become unstable and data to be lost. A client application can discover whether a control is based on SysListview32 by retrieving the CachedClassName or ClassName property from the control.
    HelpText {
        get {
            local retVal
            return (ComCall(31, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }

    ; Retrieves the culture identifier for the element.
    Culture {
        get {
            local retVal
            return (ComCall(32, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Indicates whether the element is a control element.
    IsControlElement {
        get {
            local retVal
            return (ComCall(33, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Indicates whether the element is a content element.
    ; A content element contains data that is presented to the user. Examples of content elements are the items in a list box or a button in a dialog box. Non-content elements, also called peripheral elements, are typically used to manipulate the content in a composite control; for example, the button on a drop-down control.
    IsContentElement {
        get {
            local retVal
            return (ComCall(34, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Indicates whether the element contains a disguised password.
    ; This property enables applications such as screen-readers to determine whether the text content of a control should be read aloud.
    IsPassword {
        get {
            local retVal
            return (ComCall(35, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the window handle of the element.
    NativeWindowHandle {
        get {
            local retVal
            return (ComCall(36, this, "ptr*", &retVal := 0), retVal)
        }
    }

    ; Retrieves a description of the type of UI item represented by the element.
    ; This property is used to obtain information about items in a list, tree view, or data grid. For example, an item in a file directory view might be a "Document File" or a "Folder".
    ItemType {
        get {
            local retVal
            return (ComCall(37, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }

    ; Indicates whether the element is off-screen.
    IsOffscreen {
        get {
            local retVal
            return (ComCall(38, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves a value that indicates the orientation of the element.
    ; This property is supported by controls such as scroll bars and sliders that can have either a vertical or a horizontal orientation.
    Orientation {
        get {
            local retVal
            return (ComCall(39, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the name of the underlying UI framework. The name of the UI framework, such as "Win32", "WinForm", or "DirectUI".
    FrameworkId {
        get {
            local retVal
            return (ComCall(40, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }

    ; Indicates whether the element is required to be filled out on a form.
    IsRequiredForForm {
        get {
            local retVal
            return (ComCall(41, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the description of the status of an item in an element.
    ; This property enables a client to ascertain whether an element is conveying status about an item. For example, an item associated with a contact in a messaging application might be "Busy" or "Connected".
    ItemStatus {
        get {
            local retVal
            return (ComCall(42, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }

    ; Retrieves the coordinates of the rectangle that completely encloses the element, in screen coordinates.
    BoundingRectangle => (ComCall(43, this, "ptr", retVal := UIA.NativeArray(0, 4, "int")), { l: retVal[0], t: retVal[1], r: retVal[2], b: retVal[3] })

    ; This property maps to the Accessible Rich Internet Applications (ARIA) property.

    ; Retrieves the element that contains the text label for this element.
    ; This property could be used to retrieve, for example, the static text label for a combo box.
    LabeledBy {
        get {
            local retVal
            return (ComCall(44, this, "ptr*", &retVal := 0), UIA.IUIAutomationElement(retVal))
        }
    }

    ; Retrieves the Accessible Rich Internet Applications (ARIA) role of the element.
    AriaRole {
        get {
            local retVal
            return (ComCall(45, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }

    ; Retrieves the ARIA properties of the element.
    AriaProperties {
        get {
            local retVal
            return (ComCall(46, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }

    ; Indicates whether the element contains valid data for a form.
    IsDataValidForForm {
        get {
            local retVal
            return (ComCall(47, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves an array of elements for which this element serves as the controller.
    ControllerFor {
        get {
            local retVal
            return (ComCall(48, this, "ptr*", &retVal := 0), retVal?UIA.IUIAutomationElementArray(retVal).ToArray():[])
        }
    }

    ; Retrieves an array of elements that describe this element.
    DescribedBy {
        get {
            local retVal
            return (ComCall(49, this, "ptr*", &retVal := 0), retVal?UIA.IUIAutomationElementArray(retVal).ToArray():[])
        }
    }

    ; Retrieves an array of elements that indicates the reading order after the current element.
    FlowsTo {
        get {
            local retVal
            return (ComCall(50, this, "ptr*", &retVal := 0), retVal?UIA.IUIAutomationElementArray(retVal).ToArray():[])
        }
    }

    ; Retrieves a description of the provider for this element.
    ProviderDescription {
        get {
            local retVal
            return (ComCall(51, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }

    ; Retrieves the cached ID of the process that hosts the element.
    CachedProcessId {
        get {
            local retVal
            return (ComCall(52, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves a cached value that indicates the control type of the element.
    CachedType {
        get {
            local retVal
            return (ComCall(53, this, "int*", &retVal := 0), retVal)
        }
    }
    CachedControlType => this.CachedType

    ; Retrieves the cached localized description of the control type of the element.
    CachedLocalizedType {
        get {
            local retVal
            return (ComCall(54, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }
    CachedLocalizedControlType => this.CachedLocalizedType

    ; Retrieves the cached name of the element.
    CachedName {
        get {
            local retVal
            return (ComCall(55, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }

    ; Retrieves the cached accelerator key for the element.
    CachedAcceleratorKey {
        get {
            local retVal
            return (ComCall(56, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }

    ; Retrieves the cached access key character for the element.
    CachedAccessKey {
        get {
            local retVal
            return (ComCall(57, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }

    ; A cached value that indicates whether the element has keyboard focus.
    CachedHasKeyboardFocus {
        get {
            local retVal
            return (ComCall(58, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves a cached value that indicates whether the element can accept keyboard focus.
    CachedIsKeyboardFocusable {
        get {
            local retVal
            return (ComCall(59, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves a cached value that indicates whether the element is enabled.
    CachedIsEnabled {
        get {
            local retVal
            return (ComCall(60, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the cached UI Automation identifier of the element.
    CachedAutomationId {
        get {
            local retVal
            return (ComCall(61, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }

    ; Retrieves the cached class name of the element.
    CachedClassName {
        get {
            local retVal
            return (ComCall(62, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }

    ;
    CachedHelpText {
        get {
            local retVal
            return (ComCall(63, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }

    ; Retrieves the cached help text for the element.
    CachedCulture {
        get {
            local retVal
            return (ComCall(64, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves a cached value that indicates whether the element is a control element.
    CachedIsControlElement {
        get {
            local retVal
            return (ComCall(65, this, "int*", &retVal := 0), retVal)
        }
    }

    ; A cached value that indicates whether the element is a content element.
    CachedIsContentElement {
        get {
            local retVal
            return (ComCall(66, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves a cached value that indicates whether the element contains a disguised password.
    CachedIsPassword {
        get {
            local retVal
            return (ComCall(67, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the cached window handle of the element.
    CachedNativeWindowHandle {
        get {
            local retVal
            return (ComCall(68, this, "ptr*", &retVal := 0), retVal)
        }
    }

    ; Retrieves a cached string that describes the type of item represented by the element.
    CachedItemType {
        get {
            local retVal
            return (ComCall(69, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }

    ; Retrieves a cached value that indicates whether the element is off-screen.
    CachedIsOffscreen {
        get {
            local retVal
            return (ComCall(70, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves a cached value that indicates the orientation of the element.
    CachedOrientation {
        get {
            local retVal
            return (ComCall(71, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the cached name of the underlying UI framework associated with the element.
    CachedFrameworkId {
        get {
            local retVal
            return (ComCall(72, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }

    ; Retrieves a cached value that indicates whether the element is required to be filled out on a form.
    CachedIsRequiredForForm {
        get {
            local retVal
            return (ComCall(73, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves a cached description of the status of an item within an element.
    CachedItemStatus {
        get {
            local retVal
            return (ComCall(74, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }

    ; Retrieves the cached coordinates of the rectangle that completely encloses the element.
    CachedBoundingRectangle => (ComCall(75, this, "ptr", retVal := UIA.NativeArray(0, 4, "int")), { l: retVal[0], t: retVal[1], r: retVal[2], b: retVal[3] })

    ; Retrieves the cached element that contains the text label for this element.
    CachedLabeledBy {
        get {
            local retVal
            return (ComCall(76, this, "ptr*", &retVal := 0), UIA.IUIAutomationElement(retVal))
        }
    }

    ; Retrieves the cached ARIA role of the element.
    CachedAriaRole {
        get {
            local retVal
            return (ComCall(77, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }

    ; Retrieves the cached ARIA properties of the element.
    CachedAriaProperties {
        get {
            local retVal
            return (ComCall(78, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }

    ; Retrieves a cached value that indicates whether the element contains valid data for the form.
    CachedIsDataValidForForm {
        get {
            local retVal
            return (ComCall(79, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves a cached array of UI Automation elements for which this element serves as the controller.
    CachedControllerFor {
        get {
            local retVal
            return (ComCall(80, this, "ptr*", &retVal := 0), retVal?UIA.IUIAutomationElementArray(retVal).ToArray():[])
        }
    }

    ; Retrieves a cached array of elements that describe this element.
    CachedDescribedBy {
        get {
            local retVal
            return (ComCall(81, this, "ptr*", &retVal := 0), retVal?UIA.IUIAutomationElementArray(retVal).ToArray():[])
        }
    }

    ; Retrieves a cached array of elements that indicate the reading order after the current element.
    CachedFlowsTo {
        get {
            local retVal
            return (ComCall(82, this, "ptr*", &retVal := 0), retVal?UIA.IUIAutomationElementArray(retVal).ToArray():[])
        }
    }

    ; Retrieves a cached description of the provider for this element.
    CachedProviderDescription {
        get {
            local retVal
            return (ComCall(83, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }

    ; Retrieves a point on the element that can be clicked.
    ; A client application can use this method to simulate clicking the left or right mouse button. For example, to simulate clicking the right mouse button to display the context menu for a control,
    ; • Call the GetClickablePoint method to find a clickable point on the control.
    ; • Call the SendInput function to send a right-mouse-down, right-mouse-up sequence.
    GetClickablePoint() {
        if (ComCall(84, this, "int64*", &clickable := 0, "int*", &gotClickable := 0), gotClickable)
            return { x: clickable & 0xffff, y: clickable >> 32 }
        throw TargetError('The element has no clickable point')
    }

    ;; UIA.IUIAutomationElement2
    OptimizeForVisualContent {
        get {
            local retVal
            return (ComCall(85, this, "int*", &retVal := 0), retVal)
        }
    }
    CachedOptimizeForVisualContent {
        get {
            local retVal
            return (ComCall(86, this, "int*", &retVal := 0), retVal)
        }
    }
    LiveSetting {
        get {
            local retVal
            return (ComCall(87, this, "int*", &retVal := 0), retVal)
        }
    }
    CachedLiveSetting {
        get {
            local retVal
            return (ComCall(88, this, "int*", &retVal := 0), retVal)
        }
    }
    FlowsFrom {
        get {
            local retVal
            return (ComCall(89, this, "ptr*", &retVal := 0), retVal?UIA.IUIAutomationElementArray(retVal).ToArray():[])
        }
    }
    CachedFlowsFrom {
        get {
            local retVal
            return (ComCall(90, this, "ptr*", &retVal := 0), retVal?UIA.IUIAutomationElementArray(retVal).ToArray():[])
        }
    }

    ;; UIA.IUIAutomationElement3
    ShowContextMenu() => ComCall(91, this)
    IsPeripheral {
        get {
            local retVal
            return (ComCall(92, this, "int*", &retVal := 0), retVal)
        }
    }
    CachedIsPeripheral {
        get {
            local retVal
            return (ComCall(93, this, "int*", &retVal := 0), retVal)
        }
    }

    ;; UIA.IUIAutomationElement4
    PositionInSet {
        get {
            local retVal
            return (ComCall(94, this, "int*", &retVal := 0), retVal)
        }
    }
    SizeOfSet {
        get {
            local retVal
            return (ComCall(95, this, "int*", &retVal := 0), retVal)
        }
    }
    Level {
        get {
            local retVal
            return (ComCall(96, this, "int*", &retVal := 0), retVal)
        }
    }
    AnnotationTypes {
        get {
            local retVal
            return (ComCall(97, this, "ptr*", &retVal := 0), ComValue(0x2003, retVal))
        }
    }
    AnnotationObjects {
        get {
            local retVal
            return (ComCall(98, this, "ptr*", &retVal := 0), retVal?UIA.IUIAutomationElementArray(retVal).ToArray():[])
        }
    }
    CachedPositionInSet {
        get {
            local retVal
            return (ComCall(99, this, "int*", &retVal := 0), retVal)
        }
    }
    CachedSizeOfSet {
        get {
            local retVal
            return (ComCall(100, this, "int*", &retVal := 0), retVal)
        }
    }
    CachedLevel {
        get {
            local retVal
            return (ComCall(101, this, "int*", &retVal := 0), retVal)
        }
    }
    CachedAnnotationTypes {
        get {
            local retVal
            return (ComCall(102, this, "ptr*", &retVal := 0), ComValue(0x2003, retVal))
        }
    }
    CachedAnnotationObjects {
        get {
            local retVal
            return (ComCall(103, this, "ptr*", &retVal := 0), retVal?UIA.IUIAutomationElementArray(retVal).ToArray():[])
        }
    }

    ;; UIA.IUIAutomationElement5
    LandmarkType {
        get {
            local retVal
            return (ComCall(104, this, "int*", &retVal := 0), retVal)
        }
    }
    LocalizedLandmarkType {
        get {
            local retVal
            return (ComCall(105, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }
    CachedLandmarkType {
        get {
            local retVal
            return (ComCall(106, this, "int*", &retVal := 0), retVal)
        }
    }
    CachedLocalizedLandmarkType {
        get {
            local retVal
            return (ComCall(107, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }

    ;; UIA.IUIAutomationElement6
    FullDescription {
        get {
            local retVal
            return (ComCall(108, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }
    CachedFullDescription {
        get {
            local retVal
            return (ComCall(109, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }

    ;; UIA.IUIAutomationElement7
    ; FindFirst with additional parameters
    ; This gets called when FindFirst or FindElement is used with traversalOptions or startingElement arguments
    FindFirstWithOptions(condition, traversalOptions:=0, root:=0, scope:=4) {
        if (ComCall(110, this, "int", UIA.TypeValidation.TreeScope(scope), "ptr", InStr(Type(condition), "Condition") ? condition : UIA.__CreateRawCondition(condition), "int", traversalOptions, "ptr", root, "ptr*", &found := 0), found)
            return UIA.IUIAutomationElement(found)
        throw TargetError("An element matching the condition was not found", -1)
    }
    ; FindAll with additional parameters
    ; This gets called when FindAll or FindElements is used with traversalOptions or startingElement arguments
    FindAllWithOptions(condition,  traversalOptions:=0, root:=0, scope:=4) {
        if (ComCall(111, this, "int", UIA.TypeValidation.TreeScope(scope), "ptr", InStr(Type(condition), "Condition") ? condition : UIA.__CreateRawCondition(condition), "int", traversalOptions, "ptr", root, "ptr*", &found := 0), found)
            return UIA.IUIAutomationElementArray(found).ToArray()
        return []
    }

    ; TreeScope, IUIAutomationCondition, IUIAutomationCacheRequest, TreeTraversalOptions, UIA.IUIAutomationElement
    FindFirstWithOptionsBuildCache(cacheRequest, condition, traversalOptions:=0, root:=0, scope := 4) {
        condition := UIA.TypeValidation.Condition(condition)
        if (ComCall(112, this, "int", UIA.TypeValidation.TreeScope(scope), "ptr", InStr(Type(condition), "Condition") ? condition : UIA.__CreateRawCondition(condition), "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "int", traversalOptions, "ptr", root, "ptr*", &found := 0), found)
            return UIA.IUIAutomationElement(found)
        throw TargetError("An element matching the condition was not found", -1)
    }
    FindAllWithOptionsBuildCache(cacheRequest, condition, traversalOptions:=0, root:=0, scope := 4) {
        if (ComCall(113, this, "int", UIA.TypeValidation.TreeScope(scope), "ptr", InStr(Type(condition), "Condition") ? condition : UIA.__CreateRawCondition(condition), "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "int", traversalOptions, "ptr", root, "ptr*", &found := 0), found)
            return UIA.IUIAutomationElementArray(found).ToArray()
        return []
    }
    GetMetadataValue(targetId, metadataId) {
        local returnVal
        return (ComCall(114, this, "int", targetId, "int", metadataId, "ptr", returnVal := UIA.ComVar()), returnVal[])
    }

    ;; UIA.IUIAutomationElement8
    HeadingLevel {
        get {
            local retVal
            return (ComCall(115, this, "int*", &retVal := 0), retVal)
        }
    }
    CachedHeadingLevel {
        get {
            local retVal
            return (ComCall(116, this, "int*", &retVal := 0), retVal)
        }
    }

    ;; UIA.IUIAutomationElement9
    IsDialog {
        get {
            local retVal
            return (ComCall(117, this, "int*", &retVal := 0), retVal)
        }
    }
    CachedIsDialog {
        get {
            local retVal
            return (ComCall(118, this, "int*", &retVal := 0), retVal)
        }
    }

    ;; Some aliases for properties from GetPropertyValue
    /*
    ClickablePoint => this.GetPropertyValue(UIA.Property.ClickablePoint)
    IsDockPatternAvailable => this.GetPropertyValue(UIA.Property.IsDockPatternAvailable)
    IsExpandCollapsePatternAvailable => this.GetPropertyValue(UIA.Property.IsExpandCollapsePatternAvailable)
    IsGridItemPatternAvailable => this.GetPropertyValue(UIA.Property.IsGridItemPatternAvailable)
    IsGridPatternAvailable => this.GetPropertyValue(UIA.Property.IsGridPatternAvailable)
    IsInvokePatternAvailable => this.GetPropertyValue(UIA.Property.IsInvokePatternAvailable)
    IsMultipleViewPatternAvailable => this.GetPropertyValue(UIA.Property.IsMultipleViewPatternAvailable)
    IsRangeValuePatternAvailable => this.GetPropertyValue(UIA.Property.IsRangeValuePatternAvailable)
    IsScrollPatternAvailable => this.GetPropertyValue(UIA.Property.IsScrollPatternAvailable)
    IsScrollItemPatternAvailable => this.GetPropertyValue(UIA.Property.IsScrollItemPatternAvailable)
    IsSelectionItemPatternAvailable => this.GetPropertyValue(UIA.Property.IsSelectionItemPatternAvailable)
    IsSelectionPatternAvailable => this.GetPropertyValue(UIA.Property.IsSelectionPatternAvailable)
    IsTablePatternAvailable => this.GetPropertyValue(UIA.Property.IsTablePatternAvailable)
    IsTableItemPatternAvailable => this.GetPropertyValue(UIA.Property.IsTableItemPatternAvailable)
    IsTextPatternAvailable => this.GetPropertyValue(UIA.Property.IsTextPatternAvailable)
    IsTogglePatternAvailable => this.GetPropertyValue(UIA.Property.IsTogglePatternAvailable)
    IsTransformPatternAvailable => this.GetPropertyValue(UIA.Property.IsTransformPatternAvailable)
    IsValuePatternAvailable => this.GetPropertyValue(UIA.Property.IsValuePatternAvailable)
    IsWindowPatternAvailable => this.GetPropertyValue(UIA.Property.IsWindowPatternAvailable)
    ValueIsReadOnly => this.GetPropertyValue(UIA.Property.ValueIsReadOnly)
    RangeValueValue => this.GetPropertyValue(UIA.Property.RangeValueValue)
    RangeValueIsReadOnly => this.GetPropertyValue(UIA.Property.RangeValueIsReadOnly)
    RangeValueMinimum => this.GetPropertyValue(UIA.Property.RangeValueMinimum)
    RangeValueMaximum => this.GetPropertyValue(UIA.Property.RangeValueMaximum)
    RangeValueLargeChange => this.GetPropertyValue(UIA.Property.RangeValueLargeChange)
    RangeValueSmallChange => this.GetPropertyValue(UIA.Property.RangeValueSmallChange)
    ScrollHorizontalScrollPercent => this.GetPropertyValue(UIA.Property.ScrollHorizontalScrollPercent)
    ScrollHorizontalViewSize => this.GetPropertyValue(UIA.Property.ScrollHorizontalViewSize)
    ScrollVerticalScrollPercent => this.GetPropertyValue(UIA.Property.ScrollVerticalScrollPercent)
    ScrollVerticalViewSize => this.GetPropertyValue(UIA.Property.ScrollVerticalViewSize)
    ScrollHorizontallyScrollable => this.GetPropertyValue(UIA.Property.ScrollHorizontallyScrollable)
    ScrollVerticallyScrollable => this.GetPropertyValue(UIA.Property.ScrollVerticallyScrollable)
    SelectionSelection => this.GetPropertyValue(UIA.Property.SelectionSelection)
    SelectionCanSelectMultiple => this.GetPropertyValue(UIA.Property.SelectionCanSelectMultiple)
    SelectionIsSelectionRequired => this.GetPropertyValue(UIA.Property.SelectionIsSelectionRequired)
    GridRowCount => this.GetPropertyValue(UIA.Property.GridRowCount)
    GridColumnCount => this.GetPropertyValue(UIA.Property.GridColumnCount)
    GridItemRow => this.GetPropertyValue(UIA.Property.GridItemRow)
    GridItemColumn => this.GetPropertyValue(UIA.Property.GridItemColumn)
    GridItemRowSpan => this.GetPropertyValue(UIA.Property.GridItemRowSpan)
    GridItemColumnSpan => this.GetPropertyValue(UIA.Property.GridItemColumnSpan)
    GridItemContainingGrid => this.GetPropertyValue(UIA.Property.GridItemContainingGrid)
    DockDockPosition => this.GetPropertyValue(UIA.Property.DockDockPosition)
    ExpandCollapseExpandCollapseState => this.GetPropertyValue(UIA.Property.ExpandCollapseExpandCollapseState)
    MultipleViewCurrentView => this.GetPropertyValue(UIA.Property.MultipleViewCurrentView)
    MultipleViewSupportedViews => this.GetPropertyValue(UIA.Property.MultipleViewSupportedViews)
    WindowCanMaximize => this.GetPropertyValue(UIA.Property.WindowCanMaximize)
    WindowCanMinimize => this.GetPropertyValue(UIA.Property.WindowCanMinimize)
    WindowWindowVisualState => this.GetPropertyValue(UIA.Property.WindowWindowVisualState)
    WindowWindowInteractionState => this.GetPropertyValue(UIA.Property.WindowWindowInteractionState)
    WindowIsModal => this.GetPropertyValue(UIA.Property.WindowIsModal)
    WindowIsTopmost => this.GetPropertyValue(UIA.Property.WindowIsTopmost)
    SelectionItemIsSelected => this.GetPropertyValue(UIA.Property.SelectionItemIsSelected)
    SelectionItemSelectionContainer => this.GetPropertyValue(UIA.Property.SelectionItemSelectionContainer)
    TableRowHeaders => this.GetPropertyValue(UIA.Property.TableRowHeaders)
    TableColumnHeaders => this.GetPropertyValue(UIA.Property.TableColumnHeaders)
    TableRowOrColumnMajor => this.GetPropertyValue(UIA.Property.TableRowOrColumnMajor)
    TableItemRowHeaderItems => this.GetPropertyValue(UIA.Property.TableItemRowHeaderItems)
    TableItemColumnHeaderItems => this.GetPropertyValue(UIA.Property.TableItemColumnHeaderItems)
    ToggleToggleState => this.GetPropertyValue(UIA.Property.ToggleToggleState)
    TransformCanMove => this.GetPropertyValue(UIA.Property.TransformCanMove)
    TransformCanResize => this.GetPropertyValue(UIA.Property.TransformCanResize)
    TransformCanRotate => this.GetPropertyValue(UIA.Property.TransformCanRotate)
    IsLegacyIAccessiblePatternAvailable => this.GetPropertyValue(UIA.Property.IsLegacyIAccessiblePatternAvailable)
    LegacyIAccessibleChildId => this.GetPropertyValue(UIA.Property.LegacyIAccessibleChildId)
    LegacyIAccessibleName => this.GetPropertyValue(UIA.Property.LegacyIAccessibleName)
    LegacyIAccessibleValue => this.GetPropertyValue(UIA.Property.LegacyIAccessibleValue)
    LegacyIAccessibleDescription => this.GetPropertyValue(UIA.Property.LegacyIAccessibleDescription)
    LegacyIAccessibleRole => this.GetPropertyValue(UIA.Property.LegacyIAccessibleRole)
    LegacyIAccessibleState => this.GetPropertyValue(UIA.Property.LegacyIAccessibleState)
    LegacyIAccessibleHelp => this.GetPropertyValue(UIA.Property.LegacyIAccessibleHelp)
    LegacyIAccessibleKeyboardShortcut => this.GetPropertyValue(UIA.Property.LegacyIAccessibleKeyboardShortcut)
    LegacyIAccessibleSelection => this.GetPropertyValue(UIA.Property.LegacyIAccessibleSelection)
    LegacyIAccessibleDefaultAction => this.GetPropertyValue(UIA.Property.LegacyIAccessibleDefaultAction)
    IsItemContainerPatternAvailable => this.GetPropertyValue(UIA.Property.IsItemContainerPatternAvailable)
    IsVirtualizedItemPatternAvailable => this.GetPropertyValue(UIA.Property.IsVirtualizedItemPatternAvailable)
    IsSynchronizedInputPatternAvailable => this.GetPropertyValue(UIA.Property.IsSynchronizedInputPatternAvailable)
    IsObjectModelPatternAvailable => this.GetPropertyValue(UIA.Property.IsObjectModelPatternAvailable)
    AnnotationAnnotationTypeId => this.GetPropertyValue(UIA.Property.AnnotationAnnotationTypeId)
    AnnotationAnnotationTypeName => this.GetPropertyValue(UIA.Property.AnnotationAnnotationTypeName)
    AnnotationAuthor => this.GetPropertyValue(UIA.Property.AnnotationAuthor)
    AnnotationDateTime => this.GetPropertyValue(UIA.Property.AnnotationDateTime)
    AnnotationTarget => this.GetPropertyValue(UIA.Property.AnnotationTarget)
    IsAnnotationPatternAvailable => this.GetPropertyValue(UIA.Property.IsAnnotationPatternAvailable)
    IsTextPattern2Available => this.GetPropertyValue(UIA.Property.IsTextPattern2Available)
    StylesStyleId => this.GetPropertyValue(UIA.Property.StylesStyleId)
    StylesStyleName => this.GetPropertyValue(UIA.Property.StylesStyleName)
    StylesFillColor => this.GetPropertyValue(UIA.Property.StylesFillColor)
    StylesFillPatternStyle => this.GetPropertyValue(UIA.Property.StylesFillPatternStyle)
    StylesShape => this.GetPropertyValue(UIA.Property.StylesShape)
    StylesFillPatternColor => this.GetPropertyValue(UIA.Property.StylesFillPatternColor)
    StylesExtendedProperties => this.GetPropertyValue(UIA.Property.StylesExtendedProperties)
    IsStylesPatternAvailable => this.GetPropertyValue(UIA.Property.IsStylesPatternAvailable)
    IsSpreadsheetPatternAvailable => this.GetPropertyValue(UIA.Property.IsSpreadsheetPatternAvailable)
    SpreadsheetItemFormula => this.GetPropertyValue(UIA.Property.SpreadsheetItemFormula)
    SpreadsheetItemAnnotationObjects => this.GetPropertyValue(UIA.Property.SpreadsheetItemAnnotationObjects)
    SpreadsheetItemAnnotationTypes => this.GetPropertyValue(UIA.Property.SpreadsheetItemAnnotationTypes)
    IsSpreadsheetItemPatternAvailable => this.GetPropertyValue(UIA.Property.IsSpreadsheetItemPatternAvailable)
    Transform2CanZoom => this.GetPropertyValue(UIA.Property.Transform2CanZoom)
    IsTransformPattern2Available => this.GetPropertyValue(UIA.Property.IsTransformPattern2Available)
    IsTextChildPatternAvailable => this.GetPropertyValue(UIA.Property.IsTextChildPatternAvailable)
    IsDragPatternAvailable => this.GetPropertyValue(UIA.Property.IsDragPatternAvailable)
    DragIsGrabbed => this.GetPropertyValue(UIA.Property.DragIsGrabbed)
    DragDropEffect => this.GetPropertyValue(UIA.Property.DragDropEffect)
    DragDropEffects => this.GetPropertyValue(UIA.Property.DragDropEffects)
    IsDropTargetPatternAvailable => this.GetPropertyValue(UIA.Property.IsDropTargetPatternAvailable)
    DropTargetDropTargetEffect => this.GetPropertyValue(UIA.Property.DropTargetDropTargetEffect)
    DropTargetDropTargetEffects => this.GetPropertyValue(UIA.Property.DropTargetDropTargetEffects)
    DragGrabbedItems => this.GetPropertyValue(UIA.Property.DragGrabbedItems)
    Transform2ZoomLevel => this.GetPropertyValue(UIA.Property.Transform2ZoomLevel)
    Transform2ZoomMinimum => this.GetPropertyValue(UIA.Property.Transform2ZoomMinimum)
    Transform2ZoomMaximum => this.GetPropertyValue(UIA.Property.Transform2ZoomMaximum)
    IsTextEditPatternAvailable => this.GetPropertyValue(UIA.Property.IsTextEditPatternAvailable)
    IsCustomNavigationPatternAvailable => this.GetPropertyValue(UIA.Property.IsCustomNavigationPatternAvailable)
    FillColor => this.GetPropertyValue(UIA.Property.FillColor)
    OutlineColor => this.GetPropertyValue(UIA.Property.OutlineColor)
    FillType => this.GetPropertyValue(UIA.Property.FillType)
    VisualEffects => this.GetPropertyValue(UIA.Property.VisualEffects)
    OutlineThickness => this.GetPropertyValue(UIA.Property.OutlineThickness)
    CenterPoint => this.GetPropertyValue(UIA.Property.CenterPoint)
    Rotation => this.GetPropertyValue(UIA.Property.Rotation)
    Size => this.GetPropertyValue(UIA.Property.Size)
    IsSelectionPattern2Available => this.GetPropertyValue(UIA.Property.IsSelectionPattern2Available)
    Selection2FirstSelectedItem => this.GetPropertyValue(UIA.Property.Selection2FirstSelectedItem)
    Selection2LastSelectedItem => this.GetPropertyValue(UIA.Property.Selection2LastSelectedItem)
    Selection2CurrentSelectedItem => this.GetPropertyValue(UIA.Property.Selection2CurrentSelectedItem)
    Selection2ItemCount => this.GetPropertyValue(UIA.Property.Selection2ItemCount)
    */
}

class IUIAutomationArray extends UIA.IUIAutomationBase {
    /**
     * Element[i] returns the i-th element.
     * Element[-i] returns the i-th last element: Element[-1] will return the last element.
     */
    __Item[index] {
        get {
            try {
                if index>0
                    return this.GetElement(index-1)
                else
                    return this.GetElement(this.Length+index)
            } catch
                throw IndexError("Index " index " out of bounds", -2)
        }
    }
    __Enum(varCount) {
        local maxLen := this.Length-1, i := 0
        EnumElements(&element) {
            if i > maxLen
                return false
            element := this.GetElement(i++)
            return true
        }
        EnumIndexAndElements(&index, &element) {
            if i > maxLen
                return false
            element := this.GetElement(i++)
            index := i
            return true
        }
        return (varCount = 1) ? EnumElements : EnumIndexAndElements
    }
    ; Converts an IUIAutomationArray into AHK array
    ToArray() {
        local ret := []
        Loop this.Length
            ret.Push(this.GetElement(A_index-1))
        return ret
    }
}

class IUIAutomationElementArray extends UIA.IUIAutomationArray {
    ; Retrieves the number of elements in the collection.
    Length {
        get {
            local length
            return (ComCall(3, this, "int*", &length := 0), length)
        }
    }

    ; Retrieves a Microsoft UI Automation element from the collection.
    ; Index is 0-based
    GetElement(index) {
        local element
        return (ComCall(4, this, "int", index, "ptr*", &element := 0), UIA.IUIAutomationElement(element))
    }
}

/*
    Exposes properties and methods that UI Automation client applications use to view and navigate the UI Automation elements on the desktop.
    Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationtreewalker
*/
class IUIAutomationTreeWalker extends UIA.IUIAutomationBase {
    ; The structure of the Microsoft UI Automation tree changes as the visible UI elements on the desktop change.
    ; An element can have additional child elements that do not match the current view condition and thus are not returned when navigating the element tree.

    ; Retrieves the parent element of the specified UI Automation element.
    GetParentElement(element) {
        local out
        if (ComCall(3, this, "ptr", UIA.TypeValidation.Element(element), "ptr*", &out := 0), out)
            return UIA.IUIAutomationElement(out)
        throw UnsetError("No element found with GetParentElement", -1)
    }

    ; Retrieves the first child element of the specified UI Automation element.
    GetFirstChildElement(element) {
        local out
        if (ComCall(4, this, "ptr", UIA.TypeValidation.Element(element), "ptr*", &out := 0), out)
            return UIA.IUIAutomationElement(out)
        throw UnsetError("No element found with GetFirstChildElement", -1)
    }

    ; Retrieves the last child element of the specified UI Automation element.
    GetLastChildElement(element) {
        local out
        if (ComCall(5, this, "ptr", UIA.TypeValidation.Element(element), "ptr*", &out := 0), out)
            return UIA.IUIAutomationElement(out)
        throw UnsetError("No element found with GetLastChildElement", -1)
    }

    ; Retrieves the next sibling element of the specified UI Automation element, and caches properties and control patterns.
    GetNextSiblingElement(element) {
        local out
        if (ComCall(6, this, "ptr", UIA.TypeValidation.Element(element), "ptr*", &out := 0), out)
            return UIA.IUIAutomationElement(out)
        throw UnsetError("No element found with GetNextSiblingElement", -1)
    }

    ; Retrieves the previous sibling element of the specified UI Automation element, and caches properties and control patterns.
    GetPreviousSiblingElement(element) {
        local out
        if (ComCall(7, this, "ptr", UIA.TypeValidation.Element(element), "ptr*", &out := 0), out)
            return UIA.IUIAutomationElement(out)
        throw UnsetError("No element found with GetPreviousSiblingElement", -1)
    }

    ; Retrieves the ancestor element nearest to the specified Microsoft UI Automation element in the tree view.
    ; The element is normalized by navigating up the ancestor chain in the tree until an element that satisfies the view condition (specified by a previous call to IUIAutomationTreeWalker,,Condition) is reached. If the root element is reached, the root element is returned, even if it does not satisfy the view condition.
    ; This method is useful for applications that obtain references to UI Automation elements by hit-testing. The application might want to work only with specific types of elements, and can use IUIAutomationTreeWalker,,Normalize to make sure that no matter what element is initially retrieved (for example, when a scroll bar gets the input focus), only the element of interest (such as a content element) is ultimately retrieved.
    NormalizeElement(element) {
        local out
        if (ComCall(8, this, "ptr", UIA.TypeValidation.Element(element), "ptr*", &out := 0), out)
            return UIA.IUIAutomationElement(out)
        throw UnsetError("No element found with NormalizeElement", -1)
    }

    ; Retrieves the parent element of the specified UI Automation element, and caches properties and control patterns.
    GetParentElementBuildCache(cacheRequest, element) {
        local out
        if (ComCall(9, this, "ptr", UIA.TypeValidation.Element(element), "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr*", &out := 0), out)
            return UIA.IUIAutomationElement(out)
        throw UnsetError("No element found with GetParentElementBuildCache", -1)
    }

    ; Retrieves the first child element of the specified UI Automation element, and caches properties and control patterns.
    GetFirstChildElementBuildCache(cacheRequest, element) {
        local out
        if (ComCall(10, this, "ptr", UIA.TypeValidation.Element(element), "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr*", &out := 0), out)
            return UIA.IUIAutomationElement(out)
        throw UnsetError("No element found with GetFirstChildElementBuildCache", -1)
    }

    ; Retrieves the last child element of the specified UI Automation element, and caches properties and control patterns.
    GetLastChildElementBuildCache(cacheRequest, element) {
        local out
        if (ComCall(11, this, "ptr", UIA.TypeValidation.Element(element), "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr*", &out := 0), out)
            return UIA.IUIAutomationElement(out)
        throw UnsetError("No element found with GetLastChildElementBuildCache", -1)
    }

    ; Retrieves the next sibling element of the specified UI Automation element, and caches properties and control patterns.
    GetNextSiblingElementBuildCache(cacheRequest, element) {
        local out
        if (ComCall(12, this, "ptr", UIA.TypeValidation.Element(element), "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr*", &out := 0), out)
            return UIA.IUIAutomationElement(out)
        throw UnsetError("No element found with GetNextSiblingElementBuildCache", -1)
    }

    ; Retrieves the previous sibling element of the specified UI Automation element, and caches properties and control patterns.
    GetPreviousSiblingElementBuildCache(cacheRequest, element) {
        local out
        if (ComCall(13, this, "ptr", UIA.TypeValidation.Element(element), "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr*", &out := 0), out)
            return UIA.IUIAutomationElement(out)
        throw UnsetError("No element found with GetPreviousSiblingElementBuildCache", -1)
    }

    ; Retrieves the ancestor element nearest to the specified Microsoft UI Automation element in the tree view, prefetches the requested properties and control patterns, and stores the prefetched items in the cache.
    NormalizeElementBuildCache(cacheRequest, element) {
        local out
        if (ComCall(14, this, "ptr", UIA.TypeValidation.Element(element), "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr*", &out := 0), out)
            return UIA.IUIAutomationElement(out)
        throw UnsetError("No element found with NormalizeElementBuildCache", -1)
    }

    ; Retrieves the condition that defines the view of the UI Automation tree. This property is read-only.
    ; The condition that defines the view. This is the interface that was passed to CreateTreeWalker.
    Condition {
        get {
            local condition
            return (ComCall(15, this, "ptr*", &condition := 0), UIA.IUIAutomationCondition(condition))
        }
    }
}

/*
    Represents a condition based on a property value that is used to find UI Automation elements.
    Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationpropertycondition
*/
class IUIAutomationPropertyCondition extends UIA.IUIAutomationCondition {
    static __IID := "{99ebf2cb-5578-4267-9ad4-afd6ea77e94b}"
    PropertyId {
        get {
            local propertyId
            return (ComCall(3, this, "int*", &propertyId := 0), propertyId)
        }
    }
    PropertyValue {
        get {
            local propertyValue
            return (ComCall(4, this, "ptr", propertyValue := UIA.ComVar()), propertyValue[])
        }
    }
    PropertyConditionFlags {
        get {
            local flags
            return (ComCall(5, this, "int*", &flags := 0), flags)
        }
    }
}

/*
    Exposes properties and methods that Microsoft UI Automation client applications can use to retrieve information about an AND-based property condition.
    Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationandcondition
*/
class IUIAutomationAndCondition extends UIA.IUIAutomationCondition {
    static __IID := "{a7d0af36-b912-45fe-9855-091ddc174aec}"
    ChildCount {
        get {
            local childCount
            return (ComCall(3, this, "int*", &childCount := 0), childCount)
        }
    }
    GetChildrenAsNativeArray() {
        local childArrayCount
        return (ComCall(4, this, "ptr*", &childArray := 0, "int*", &childArrayCount := 0), UIA.NativeArray(childArray, childArrayCount))
    }
    GetChildren() {
        local childArray
        return (ComCall(5, this, "ptr*", &childArray := 0), UIA.IUIAutomationCondition.__SafeArrayToConditionArray(childArray))
    }
}

/*
    Represents a condition made up of multiple conditions, at least one of which must be true.
    Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationorcondition
*/
class IUIAutomationOrCondition extends UIA.IUIAutomationAndCondition {
    static __IID := "{8753f032-3db1-47b5-a1fc-6e34a266c712}"
    ChildCount {
        get {
            local childCount
            return (ComCall(3, this, "int*", &childCount := 0), childCount)
        }
    }
    GetChildrenAsNativeArray() {
        local childArrayCount
        return (ComCall(4, this, "ptr*", &childArray := 0, "int*", &childArrayCount := 0), UIA.NativeArray(childArray, childArrayCount))
    }
    GetChildren() {
        local childArray
        return (ComCall(5, this, "ptr*", &childArray := 0), UIA.IUIAutomationCondition.__SafeArrayToConditionArray(childArray))
    }
}

/*
    Represents a condition that can be either TRUE=1 (selects all elements) or FALSE=0(selects no elements).
    Microsoft documentation:
*/
class IUIAutomationBoolCondition extends UIA.IUIAutomationCondition {
    static __IID := "{1B4E1F2E-75EB-4D0B-8952-5A69988E2307}"
    Value {
        get {
            local boolVal
            return (ComCall(3, this, "int*", &boolVal := 0), boolVal)
        }
    }
}

/*
    Represents a condition that is the negative of another condition.
    Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationnotcondition
*/
class IUIAutomationNotCondition extends UIA.IUIAutomationCondition {
    static __IID := "{f528b657-847b-498c-8896-d52b565407a1}"
    GetChild() {
        local condition
        return (ComCall(3, this, "ptr*", &condition := 0), UIA.IUIAutomationCondition.__QueryCondition(condition))
    }
}

class IUIAutomationCondition extends UIA.IUIAutomationBase {
    static __QueryCondition(pCond) {
        for n in ["Property", "Bool", "And", "Or", "Not"] {
            try {
                if ComObjQuery(pCond, UIA.IUIAutomation%n%Condition.__IID)
                    return UIA.IUIAutomation%n%Condition(pCond)
            }
        }
    }
    static __SafeArrayToConditionArray(pSafeArr) {
        local safeArray := ComValue(0x2003,pSafeArr), out := [], k, cond
        for k in safeArray {
            if cond := UIA.IUIAutomationCondition.__QueryCondition(k)
                out.Push(cond)
        }
        return out
    }
}

/*
    Exposes properties and methods of a cache request. Client applications use this interface to specify the properties and control patterns to be cached when a Microsoft UI Automation element is obtained.
    Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationcacherequest
*/
class IUIAutomationCacheRequest extends UIA.IUIAutomationBase {
    ; Adds a property to the cache request.
    AddProperty(propertyId) => ComCall(3, this, "int", UIA.TypeValidation.Property(propertyId))

    ; Adds a control pattern to the cache request. Adding a control pattern that is already in the cache request has no effect.
    AddPattern(patternId) => ComCall(4, this, "int", UIA.TypeValidation.Pattern(patternId))

    ; Creates a copy of the cache request.
    Clone() {
        local clonedRequest
        if (ComCall(5, this, "ptr*", &clonedRequest := 0), clonedRequest)
            return UIA.IUIAutomationCacheRequest(clonedRequest)
        throw Error("Cloning the CacheRequest failed", -1)
    }

    TreeScope {
        get {
            local scope
            return (ComCall(6, this, "int*", &scope := 0), scope)
        }
        set => ComCall(7, this, "int", UIA.TypeValidation.TreeScope(value))
    }

    TreeFilter {
        get {
            local filter
            if (ComCall(8, this, "ptr*", &filter := 0), filter)
                return UIA.IUIAutomationCondition(filter)
            throw UnsetError("No condition returned by " A_ThisFunc, -1)
        }
        set => ComCall(9, this, "ptr", UIA.TypeValidation.Condition(Value))
    }

    AutomationElementMode {
        get {
            local mode
            return (ComCall(10, this, "int*", &mode := 0), mode)
        }
        set => ComCall(11, this, "int", UIA.TypeValidation.AutomationElementMode(Value))
    }

    ; Extracts all properties from an object condition and adds them to the CacheRequest
    AddPropertiesFromCondition(condition) {
        local value, prop
        if Type(condition) = "Object"
            condition := condition.OwnProps()
        for prop, value in condition {
            try prop := UIA.TypeValidation.Property(prop)
            if !(IsInteger(prop) && prop > 10000) {
                if IsObject(value)
                    this.AddPropertiesFromCondition(value)
            } else
                this.AddProperty(prop)
        }
    }
}

/**
 * Creates a new event handler, that when registered will call the supplied function on the registered event.
 * @param funcObj The callback function that will get called on events.
 *      The function needs to accept a certain number of parameters that depends on which event will be registered.
 * 		HandleAutomationEvent(sender, eventId)
 *		HandleFocusChangedEvent(sender)
 *		HandlePropertyChangedEvent(sender, propertyId, newValue)
 *		HandleStructureChangedEvent(sender, changeType, runtimeId)
 *		HandleTextEditTextChangedEvent(sender, changeType, eventStrings)
 *		HandleChangesEvent(sender, uiaChanges, changesCount)
 *		HandleNotificationEvent(sender, notificationKind, notificationProcessing, displayString, activityId)
 * @param handlerType This needs to be provided if the handler is going to be used with something other than UIA.AddAutomationEventHandler()
 *      For UIA.AddAutomationEventHandler leave this empty (default value).
 *      For UIA.Add...EventHandler, specify the ... part: FocusChanged, StructureChanged, TextEditTextChanged, Changes, Notification.
 *      Eg. For UIA.AddFocusChangedEventHandler, set this value to "FocusChanged": CreateEventHandler(Func, "FocusChanged")
 */
static CreateEventHandler(funcObj, handlerType:="") {
    if funcObj is String
        try funcObj := %funcObj%
    if !HasMethod(funcObj, "Call")
        throw TypeError("Invalid function provided", -2)

    buf := Buffer(A_PtrSize * 5)
    handler := UIA.IUIAutomation%handlerType%EventHandler()
    handler.Buffer := buf, handler.Ptr := buf.ptr
    handlerFunc := handler.Handle%(handlerType ? handlerType : "Automation")%Event
    NumPut("ptr", buf.Ptr + A_PtrSize, "ptr", cQI:=CallbackCreate(QueryInterface, "F", 3), "ptr", cAF:=CallbackCreate(AddRef, "F", 1), "ptr", cR:=CallbackCreate(Release, "F", 1), "ptr", cF:=CallbackCreate(handlerFunc.Bind(handler), "F", handlerFunc.MaxParams-1), buf)
    handler.DefineProp("__Delete", { call: (*) => (CallbackFree(cQI), CallbackFree(cAF), CallbackFree(cR), CallbackFree(cF)) })
    handler.EventHandler := funcObj

    return handler

    QueryInterface(pSelf, pRIID, pObj){ ; Credit: https://github.com/neptercn/UIAutomation/blob/master/UIA.ahk
        DllCall("ole32\StringFromIID","ptr",pRIID,"wstr*",&str)
        return (str="{00000000-0000-0000-C000-000000000046}")||(str="{146c3c17-f12e-4e22-8c27-f894b9b79c69}")||(str="{40cd37d4-c756-4b0c-8c6f-bddfeeb13b50}")||(str="{e81d1b4e-11c5-42f8-9754-e7036c79f054}")||(str="{c270f6b5-5c69-4290-9745-7a7f97169468}")||(str="{92FAA680-E704-4156-931A-E32D5BB38F3F}")||(str="{58EDCA55-2C3E-4980-B1B9-56C17F27A2A0}")||(str="{C7CB2637-E6C2-4D0C-85DE-4948C02175C7}")?NumPut("ptr",pSelf,pObj)*0:0x80004002 ; E_NOINTERFACE
    }
    AddRef(pSelf) {
    }
    Release(pSelf) {
    }
}
static CreateAutomationEventHandler(funcObj) => UIA.CreateEventHandler(funcObj)
static CreateFocusChangedEventHandler(funcObj) => UIA.CreateEventHandler(funcObj, "FocusChanged")
static CreatePropertyChangedEventHandler(funcObj) => UIA.CreateEventHandler(funcObj, "PropertyChanged")
static CreateStructureChangedEventHandler(funcObj) => UIA.CreateEventHandler(funcObj, "StructureChanged")
static CreateTextEditTextChangedEventHandler(funcObj) => UIA.CreateEventHandler(funcObj, "TextEditTextChanged")
static CreateChangesEventHandler(funcObj) => UIA.CreateEventHandler(funcObj, "Changes")
static CreateNotificationEventHandler(funcObj) => UIA.CreateEventHandler(funcObj, "Notification")

class IUIAutomationEventHandler {
    static __IID := "{146c3c17-f12e-4e22-8c27-f894b9b79c69}"

    HandleAutomationEvent(pSelf, sender, eventId) {
        this.EventHandler.Call(UIA.IUIAutomationElement(sender), eventId)
    }
}
class IUIAutomationFocusChangedEventHandler {
    static __IID := "{c270f6b5-5c69-4290-9745-7a7f97169468}"

    HandleFocusChangedEvent(pSelf, sender) {
        this.EventHandler.Call(UIA.IUIAutomationElement(sender))
    }
}

/*
    Exposes a method to handle Microsoft UI Automation events that occur when a property is changed.
    Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationpropertychangedeventhandler
*/
class IUIAutomationPropertyChangedEventHandler { ; UNTESTED
    ;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696119(v=vs.85).aspx
    static __IID := "{40cd37d4-c756-4b0c-8c6f-bddfeeb13b50}"

    HandlePropertyChangedEvent(pSelf, sender, propertyId, newValue) {
        local val := ComValue(0x400C, newValue)[]
        DllCall("oleaut32\VariantClear", "ptr", newValue)
        this.EventHandler.Call(UIA.IUIAutomationElement(sender), propertyId, val)
    }
}
/*
    Exposes a method to handle events that occur when the Microsoft UI Automation tree structure is changed.
    Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationstructurechangedeventhandler
*/
class IUIAutomationStructureChangedEventHandler {
    ;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696197(v=vs.85).aspx
    static __IID := "{e81d1b4e-11c5-42f8-9754-e7036c79f054}"

    HandleStructureChangedEvent(pSelf, sender, changeType, runtimeId) {
        this.EventHandler.Call(UIA.IUIAutomationElement(sender), changeType, UIA.SafeArrayToAHKArray(runtimeId))
        DllCall("oleaut32\VariantClear", "ptr", runtimeId)
    }
}
/*
    Exposes a method to handle events that occur when Microsoft UI Automation reports a text-changed event from text edit controls
    Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationtextedittextchangedeventhandler
*/
class IUIAutomationTextEditTextChangedEventHandler { ; UNTESTED
    ;~ http://msdn.microsoft.com/en-us/library/windows/desktop/dn302202(v=vs.85).aspx
    static __IID := "{92FAA680-E704-4156-931A-E32D5BB38F3F}"

    HandleTextEditTextChangedEvent(pSelf, sender, changeType, eventStrings) {
        local val := ComValue(0x400C, eventStrings)[]
        DllCall("oleaut32\VariantClear", "ptr", eventStrings)
        this.EventHandler.Call(UIA.IUIAutomationElement(sender), changeType, val)
    }
}

/*
    Exposes a method to handle one or more Microsoft UI Automation change events
    Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationchangeseventhandler
*/
class IUIAutomationChangesEventHandler { ; UNTESTED
    static __IID := "{58EDCA55-2C3E-4980-B1B9-56C17F27A2A0}"

    HandleChangesEvent(pSelf, sender, uiaChanges, changesCount) {
        local changes, pExtraInfo
        changes := {id:NumGet(uiaChanges,"Int"), payload:ComValue(0x400C, pPayload := NumGet(uiaChanges,8,"uint64"))[], extraInfo:ComValue(0x400C, pExtraInfo := NumGet(uiaChanges,16+2*A_PtrSize,"uint64")[])}
        DllCall("oleaut32\VariantClear", "ptr", pPayload), DllCall("oleaut32\VariantClear", "ptr", pExtraInfo)
        this.EventHandler.Call(UIA.IUIAutomationElement(sender), changes, changesCount)
    }
}
/*
    Exposes a method to handle Microsoft UI Automation notification events
    Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationnotificationeventhandler
*/
class IUIAutomationNotificationEventHandler {
    static __IID := "{C7CB2637-E6C2-4D0C-85DE-4948C02175C7}"

    HandleNotificationEvent(pSelf, sender, notificationKind, notificationProcessing, displayString, activityId) {
        this.EventHandler.Call(UIA.IUIAutomationElement(sender), notificationKind, notificationProcessing, UIA.BSTR(displayString), UIA.BSTR(activityId))
    }
}

class IUIAutomationEventHandlerGroup extends UIA.IUIAutomationBase {
    static __IID := "{C9EE12F2-C13B-4408-997C-639914377F4E}"

    AddActiveTextPositionChangedEventHandler(handler, scope:=0x4, cacheRequest:=0) => ComCall(3, this, "int", UIA.TypeValidation.TreeScope(scope), "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr", handler)
    AddAutomationEventHandler(handler, eventId, scope:=0x4, cacheRequest:=0) => ComCall(4, this, "uint", eventId, "int", UIA.TypeValidation.TreeScope(scope), "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr", handler)
    AddChangesEventHandler(handler, changeTypes, scope:=0x4, cacheRequest:=0) {
        local k, v
        if !IsObject(changeTypes)
            changeTypes := [changeTypes]
        nativeArray := UIA.NativeArray(0, changeTypes.Length, "int")
        for k, v in changeTypes
            NumPut("int", v, nativeArray, (k-1)*4)
        return ComCall(5, this, "int", UIA.TypeValidation.TreeScope(scope), "ptr", nativeArray, "int", changeTypes.Length, "int", cacheRequest, "ptr", handler)
    }
    AddNotificationEventHandler(handler, scope:=0x4, cacheRequest:=0) => ComCall(6, this, "int", UIA.TypeValidation.TreeScope(scope), "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr", handler)
    AddPropertyChangedEventHandler(handler, propertyArray, scope:=0x1,cacheRequest:=0) {
        local i, propertyId, SafeArray
        if !IsObject(propertyArray)
            propertyArray := [propertyArray]
        SafeArray:=ComObjArray(0x3,propertyArray.Length)
        for i,propertyId in propertyArray
            SafeArray[i-1]:=propertyId
        return ComCall(7, this, "int", UIA.TypeValidation.TreeScope(scope), "ptr", UIA.TypeValidation.CacheRequest(cacheRequest),"ptr", handler,"ptr", SafeArray)
    }
    AddStructureChangedEventHandler(handler, scope:=0x4, cacheRequest:=0) => ComCall(8, this "int", UIA.TypeValidation.TreeScope(scope), "ptr",cacheRequest, "ptr", handler)
    AddTextEditTextChangedEventHandler(handler, textEditChangeType, scope:=0x4, cacheRequest:=0) => ComCall(9, this, "int", UIA.TypeValidation.TreeScope(scope), "int", UIA.TypeValidation.TextEditChangeType(textEditChangeType), "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr", handler)
}

/*
    Provides access to the properties of an annotation in a document.
    Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationannotationpattern
*/
class IUIAutomationAnnotationPattern extends UIA.IUIAutomationBase {
    AnnotationTypeId {
        get {
            local retVal
            return (ComCall(3, this, "int*", &retVal := 0), retVal)
        }
    }
    AnnotationTypeName {
        get {
            local retVal
            return (ComCall(4, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }
    Author {
        get {
            local retVal
            return (ComCall(5, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }
    DateTime {
        get {
            local retVal
            return (ComCall(6, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }
    Target {
        get {
            local retVal
            if (ComCall(7, this, "ptr*", &retVal := 0), retVal)
                return UIA.IUIAutomationElement(retVal)
            throw UnsetError("No element returned by " A_ThisFunc, -1)
        }
    }
    CachedAnnotationTypeId {
        get {
            local retVal
            return (ComCall(8, this, "int*", &retVal := 0), retVal)
        }
    }
    CachedAnnotationTypeName {
        get {
            local retVal
            return (ComCall(9, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }
    CachedAuthor {
        get {
            local retVal
            return (ComCall(10, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }
    CachedDateTime {
        get {
            local retVal
            return (ComCall(11, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }
    CachedTarget {
        get {
            local retVal
            if (ComCall(11, this, "ptr*", &retVal := 0), retVal)
                return UIA.IUIAutomationElement(retVal)
            throw UnsetError("No element returned by " A_ThisFunc, -1)
        }
    }
}

/*
    Exposes a method to support access by a Microsoft UI Automation client to controls that support a custom navigation order.
    Microsoft documentation: https://learn.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationcustomnavigationpattern
*/
class IUIAutomationCustomNavigationPattern extends UIA.IUIAutomationBase {
    ; Gets the next element in the specified direction within the logical UI tree.
    ; direction can be one of UIA.NavigateDirection values: Parent, NextSibling, PreviousSibling, FirstChild, LastChild
    Navigate(direction) {
        local pRetVal
        if (ComCall(3, this, "int", UIA.TypeValidation.NavigateDirection(direction), "ptr*", &pRetVal := 0), pRetVal)
            return UIA.IUIAutomationElement(pRetVal)
        throw UnsetError("No element returned by " A_ThisFunc, -1)
    }
}

/*
    Provides access to a control that enables child elements to be arranged horizontally and vertically, relative to each other.
    Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationdockpattern
*/
class IUIAutomationDockPattern extends UIA.IUIAutomationBase {
    static	__IID := "{fde5ef97-1464-48f6-90bf-43d0948e86ec}"

    ; ---------- DockPattern properties ----------

    ; Retrieves the `dock position` of this element within its docking container.
    DockPosition {
        get {
            local retVal
            return (ComCall(4, this, "int*", &retVal := 0), retVal)
        }
    }
    ; Retrieves the `cached dock` position of this element within its docking container.
    CachedDockPosition {
        get {
            local retVal
            return (ComCall(5, this, "int*", &retVal := 0), retVal)
        }
    }

    ; ---------- DockPattern methods ----------

    /**
     * Sets the dock position of this element.
     * @param dockPos One of UIA.DockPosition values: Top, Left, Bottom, Right, Fill, None
     */
    SetDockPosition(dockPos) => ComCall(3, this, "int", UIA.TypeValidation.DockPosition(dockPos))
}

/*
    Provides access to information exposed by a UI Automation provider for an element that can be dragged as part of a drag-and-drop operation.
    Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationdragpattern
*/
class IUIAutomationDragPattern extends UIA.IUIAutomationBase {
    static __IID := "{1DC7B570-1F54-4BAD-BCDA-D36A722FB7BD}"

    ; ---------- DragPattern properties ----------
    IsGrabbed {
        get {
            local retVal
            return (ComCall(3, this, "int*", &retVal := 0), retVal)
        }
    }
    CachedIsGrabbed {
        get {
            local retVal
            return (ComCall(4, this, "int*", &retVal := 0), retVal)
        }
    }
    DropEffect {
        get {
            local retVal
            return (ComCall(5, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }
    CachedDropEffect {
        get {
            local retVal
            return (ComCall(6, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }
    DropEffects {
        get {
            local retVal
            return (ComCall(7, this, "ptr*", &retVal := 0), ComValue(0x2008, retVal))
        }
    }
    CachedDropEffects {
        get {
            local retVal
            return (ComCall(8, this, "ptr*", &retVal := 0), ComValue(0x2008, retVal))
        }
    }

    ; ---------- DragPattern methods ----------
    /**
     * Retrieves a collection of elements that represent the full set of items that the user is dragging as part of a drag operation.
     * @returns {IUIAutomationElementArray}
     */
    GetGrabbedItems() {
        local retVal
        return (ComCall(9, this, "ptr*", &retVal := 0), retVal?UIA.IUIAutomationElementArray(retVal).ToArray():[])
    }
    GetCachedGrabbedItems() {
        local retVal
        return (ComCall(10, this, "ptr*", &retVal := 0), retVal?UIA.IUIAutomationElementArray(retVal).ToArray():[])
    }
}

/*
    Provides access to drag-and-drop information exposed by a Microsoft UI Automation provider for an element that can be the drop target of a drag-and-drop operation.
    Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationdroptargetpattern
*/
class IUIAutomationDropTargetPattern extends UIA.IUIAutomationBase {
    static __IID := "{69A095F7-EEE4-430E-A46B-FB73B1AE39A5}"

    ; ---------- DropTargetPattern properties ----------
    DropTargetEffect {
        get {
            local retVal
            return (ComCall(3, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }
    CachedDropTargetEffect {
        get {
            local retVal
            return (ComCall(4, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }
    DropTargetEffects {
        get {
            local retVal
            return (ComCall(5, this, "ptr*", &retVal := 0), ComValue(0x2008, retVal))
        }
    }
    CachedDropTargetEffects {
        get {
            local retVal
            return (ComCall(6, this, "ptr*", &retVal := 0), ComValue(0x2008, retVal))
        }
    }
}

class IUIAutomationExpandCollapsePattern extends UIA.IUIAutomationBase {
    ; This is a blocking method that returns after the element has been collapsed.
    ; There are cases when a element that is marked as a leaf node might not know whether it has children until either the IUIAutomationExpandCollapsePattern,,Collapse or the IUIAutomationExpandCollapsePattern,,Expand method is called. This behavior is possible with a tree view control that does delayed loading of its child items. For example, Microsoft Windows Explorer might display the expand icon for a node even though there are currently no child items; when the icon is clicked, the control polls for child items, finds none, and removes the expand icon. In these cases clients should listen for a property-changed event on the IUIAutomationExpandCollapsePattern,,ExpandCollapseState property.

    ; Displays all child nodes, controls, or content of the element.
    Expand() => ComCall(3, this)

    ; Hides all child nodes, controls, or content of the element.
    Collapse() => ComCall(4, this)

    ; Retrieves a value that indicates the state, expanded or collapsed, of the element.
    ; Retrieve the name of the state via UIA.ExpandCollapseState[value]
    ExpandCollapseState {
        get {
            local retVal
            return (ComCall(5, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves a cached value that indicates the state, expanded or collapsed, of the element.
    CachedExpandCollapseState {
        get {
            local retVal
            return (ComCall(6, this, "int*", &retVal := 0), retVal)
        }
    }
}

class IUIAutomationGridItemPattern extends UIA.IUIAutomationBase {
    ; Retrieves the element that contains the grid item.
    ContainingGrid {
        get {
            local retVal
            if (ComCall(3, this, "ptr*", &retVal := 0), retVal)
                return UIA.IUIAutomationElement(retVal)
            throw UnsetError("No element returned by " A_ThisFunc, -1)
        }
    }

    ; Retrieves the zero-based index of the row that contains the grid item.
    Row {
        get {
            local retVal
            return (ComCall(4, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the zero-based index of the column that contains the item.
    Column {
        get {
            local retVal
            return (ComCall(5, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the number of rows spanned by the grid item.
    RowSpan {
        get {
            local retVal
            return (ComCall(6, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the number of columns spanned by the grid item.
    ColumnSpan {
        get {
            local retVal
            return (ComCall(7, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the cached element that contains the grid item.
    CachedContainingGrid {
        get {
            local retVal
            if (ComCall(8, this, "ptr*", &retVal := 0), retVal)
                return UIA.IUIAutomationElement(retVal)
            throw UnsetError("No element returned by " A_ThisFunc, -1)
        }
    }

    ; Retrieves the cached zero-based index of the row that contains the item.
    CachedRow {
        get {
            local retVal
            return (ComCall(9, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the cached zero-based index of the column that contains the grid item.
    CachedColumn {
        get {
            local retVal
            return (ComCall(10, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the cached number of rows spanned by a grid item.
    CachedRowSpan {
        get {
            local retVal
            return (ComCall(11, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the cached number of columns spanned by the grid item.
    CachedColumnSpan {
        get {
            local retVal
            return (ComCall(12, this, "int*", &retVal := 0), retVal)
        }
    }
}

class IUIAutomationGridPattern extends UIA.IUIAutomationBase {
    ; Retrieves a UI Automation element representing an item in the grid.
    GetItem(row, column) {
        local element
        if (ComCall(3, this, "int", row, "int", column, "ptr*", &element := 0), element)
            return UIA.IUIAutomationElement(element)
        throw UnsetError("No element returned by " A_ThisFunc, -1)
    }

    ; Hidden rows and columns, depending on the provider implementation, may be loaded in the Microsoft UI Automation tree and will therefore be reflected in the row count and column count properties. If the hidden rows and columns have not yet been loaded they are not counted.

    ; Retrieves the number of rows in the grid.
    RowCount {
        get {
            local retVal
            return (ComCall(4, this, "int*", &retVal := 0), retVal)
        }
    }

    ; The number of columns in the grid.
    ColumnCount {
        get {
            local retVal
            return (ComCall(5, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the cached number of rows in the grid.
    CachedRowCount {
        get {
            local retVal
            return (ComCall(6, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the cached number of columns in the grid.
    CachedColumnCount {
        get {
            local retVal
            return (ComCall(7, this, "int*", &retVal := 0), retVal)
        }
    }
}

class IUIAutomationInvokePattern extends UIA.IUIAutomationBase {
    ; Invokes the action of a control, such as a button click.
    ; Calls to this method should return immediately without blocking. However, this behavior depends on the implementation.
    Invoke() => ComCall(3, this)
}

class IUIAutomationItemContainerPattern extends UIA.IUIAutomationBase {
    ; IUIAutomationItemContainerPattern

    ; Retrieves an element within a containing element, based on a specified property value.
    ; The provider may return an actual UIA.IUIAutomationElement interface or a placeholder if the matching element is virtualized.
    ; This method returns E_INVALIDARG if the property requested is not one that the container supports searching over. It is expected that most containers will support Name property, and if appropriate for the container, AutomationId and IsSelected.
    ; This method can be slow, because it may need to traverse multiple objects to find a matching one. When used in a loop to return multiple items, no specific order is defined so long as each item is returned only once (that is, the loop should terminate). This method is also item-centric, not UI-centric, so items with multiple UI representations need to be hit only once.
    ; When the propertyId parameter is specified as 0 (zero), the provider is expected to return the next item after pStartAfter. If pStartAfter is specified as NULL with a propertyId of 0, the provider should return the first item in the container. When propertyId is specified as 0, the value parameter should be VT_EMPTY.
    FindItemByProperty(pStartAfter, propertyId, value) {
        if A_PtrSize = 4
            value := UIA.ComVar(value, , true), ComCall(3, this, "ptr", pStartAfter, "int", propertyId, "int64", NumGet(value, "int64"), "int64", NumGet(value, 8, "int64"), "ptr*", &pFound := 0)
        else
            ComCall(3, this, "ptr", pStartAfter, "int", propertyId, "ptr", UIA.ComVar(value, , true), "ptr*", &pFound := 0)
        if (pFound)
            return UIA.IUIAutomationElement(pFound)
    }
}

class IUIAutomationLegacyIAccessiblePattern extends UIA.IUIAutomationBase {

    ; IUIAutomationLegacyIAccessiblePattern

    ; Performs a Microsoft Active Accessibility selection.
    Select(flagsSelect:=3) => ComCall(3, this, "int", flagsSelect)

    ; Performs the Microsoft Active Accessibility default action for the element.
    DoDefaultAction() => ComCall(4, this)

    ; Sets the Microsoft Active Accessibility value property for the element. This method is supported only for some elements (usually edit controls).
    SetValue(szValue) => ComCall(5, this, "wstr", szValue)

    ; Retrieves the Microsoft Active Accessibility child identifier for the element. If the element is not a child element, CHILDID_SELF (0) is returned.
    ChildId {
        get {
            local pRetVal
            return (ComCall(6, this, "int*", &pRetVal := 0), pRetVal)
        }
    }

    ; Retrieves the Microsoft Active Accessibility name property of the element. The name of an element can be used to find the element in the element tree when the automation ID property is not supported on the element.
    Name {
        get {
            local pszName
            return (ComCall(7, this, "ptr*", &pszName := 0), UIA.BSTR(pszName))
        }
    }

    ; Retrieves the Microsoft Active Accessibility value property.
    Value {
        get {
            local pszValue
            return (ComCall(8, this, "ptr*", &pszValue := 0), UIA.BSTR(pszValue))
        }
    }

    ; Retrieves the Microsoft Active Accessibility description of the element.
    Description {
        get {
            local pszDescription
            return (ComCall(9, this, "ptr*", &pszDescription := 0), UIA.BSTR(pszDescription))
        }
    }

    ; Retrieves the Microsoft Active Accessibility role identifier of the element.
    Role {
        get {
            local pdwRole
            return (ComCall(10, this, "uint*", &pdwRole := 0), pdwRole)
        }
    }

    ; Retrieves the Microsoft Active Accessibility state identifier for the element.
    State {
        get {
            local pdwState
            return (ComCall(11, this, "uint*", &pdwState := 0), pdwState)
        }
    }

    ; Retrieves the Microsoft Active Accessibility help string for the element.
    Help {
        get {
            local pszHelp
            return (ComCall(12, this, "ptr*", &pszHelp := 0), UIA.BSTR(pszHelp))
        }
    }

    ; Retrieves the Microsoft Active Accessibility keyboard shortcut property for the element.
    KeyboardShortcut {
        get {
            local pszKeyboardShortcut
            return (ComCall(13, this, "ptr*", &pszKeyboardShortcut := 0), UIA.BSTR(pszKeyboardShortcut))
        }
    }

    ; Retrieves the Microsoft Active Accessibility property that identifies the selected children of this element.
    GetSelection() {
        local pvarSelectedChildren
        return (ComCall(14, this, "ptr*", &pvarSelectedChildren := 0), pvarSelectedChildren?UIA.IUIAutomationElementArray(pvarSelectedChildren).ToArray():[])
    }

    ; Retrieves the Microsoft Active Accessibility default action for the element.
    DefaultAction {
        get {
            local pszDefaultAction
            return (ComCall(15, this, "ptr*", &pszDefaultAction := 0), UIA.BSTR(pszDefaultAction))
        }
    }

    ; Retrieves the cached Microsoft Active Accessibility child identifier for the element.
    CachedChildId {
        get {
            local pRetVal
            return (ComCall(16, this, "int*", &pRetVal := 0), pRetVal)
        }
    }

    ; Retrieves the cached Microsoft Active Accessibility name property of the element.
    CachedName {
        get {
            local pszName
            return (ComCall(17, this, "ptr*", &pszName := 0), UIA.BSTR(pszName))
        }
    }

    ; Retrieves the cached Microsoft Active Accessibility value property.
    CachedValue {
        get {
            local pszValue
            return (ComCall(18, this, "ptr*", &pszValue := 0), UIA.BSTR(pszValue))
        }
    }

    ; Retrieves the cached Microsoft Active Accessibility description of the element.
    CachedDescription {
        get {
            local pszDescription
            return (ComCall(19, this, "ptr*", &pszDescription := 0), UIA.BSTR(pszDescription))
        }
    }

    ; Retrieves the cached Microsoft Active Accessibility role of the element.
    CachedRole {
        get {
            local pdwRole
            return (ComCall(20, this, "uint*", &pdwRole := 0), pdwRole)
        }
    }

    ; Retrieves the cached Microsoft Active Accessibility state identifier for the element.
    CachedState {
        get {
            local pdwState
            return (ComCall(21, this, "uint*", &pdwState := 0), pdwState)
        }
    }

    ; Retrieves the cached Microsoft Active Accessibility help string for the element.
    CachedHelp {
        get {
            local pszHelp
            return (ComCall(22, this, "ptr*", &pszHelp := 0), UIA.BSTR(pszHelp))
        }
    }

    ; Retrieves the cached Microsoft Active Accessibility keyboard shortcut property for the element.
    CachedKeyboardShortcut {
        get {
            local pszKeyboardShortcut
            return (ComCall(23, this, "ptr*", &pszKeyboardShortcut := 0), UIA.BSTR(pszKeyboardShortcut))
        }
    }

    ; Retrieves the cached Microsoft Active Accessibility property that identifies the selected children of this element.
    GetCachedSelection() {
        local pvarSelectedChildren
        return (ComCall(24, this, "ptr*", &pvarSelectedChildren := 0), pvarSelectedChildren?UIA.IUIAutomationElementArray(pvarSelectedChildren).ToArray():[])
    }

    ; Retrieves the Microsoft Active Accessibility default action for the element.
    CachedDefaultAction {
        get {
            local pszDefaultAction
            return (ComCall(25, this, "ptr*", &pszDefaultAction := 0), UIA.BSTR(pszDefaultAction))
        }
    }

    ; Retrieves an IAccessible object that corresponds to the Microsoft UI Automation element.
    ; This method returns NULL if the underlying implementation of the UI Automation element is not a native Microsoft Active Accessibility server; that is, if a client attempts to retrieve the IAccessible interface for an element originally supported by a proxy object from OLEACC.dll, or by the UIA-to-MSAA Bridge.
    GetIAccessible() {
        local ppAccessible
        return (ComCall(26, this, "ptr*", &ppAccessible := 0), ComValue(9, ppAccessible))
    }
}

class IUIAutomationMultipleViewPattern extends UIA.IUIAutomationBase {
    static	__IID := "{8d253c91-1dc5-4bb5-b18f-ade16fa495e8}"

    ; ---------- MultipleViewPattern properties ----------

    ; Retrieves the name of a control-specific view.
    GetViewName(view) {
        local name
        return (ComCall(3, this, "int", view, "ptr*", &name := 0), UIA.BSTR(name))
    }

    ; Sets the view of the control.
    SetView(view) => ComCall(4, this, "int", view)

    ; Retrieves the control-specific identifier of the current view of the control.
    View => this.CurrentView
    CurrentView {
        get {
            local retVal
            return (ComCall(5, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves a collection of control-specific view identifiers.
    GetSupportedViews() {
        local retVal
        return (ComCall(6, this, "ptr*", &retVal := 0), UIA.SafeArrayToAHKArray(retVal))
    }

    ; Retrieves the cached control-specific identifier of the current view of the control.
    CachedView => this.CachedCurrentView
    CachedCurrentView {
        get {
            local retVal
            return (ComCall(7, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves a collection of control-specific view identifiers from the cache.
    GetCachedSupportedViews() {
        local retVal
        return (ComCall(8, this, "ptr*", &retVal := 0), UIA.SafeArrayToAHKArray(retVal))
    }
}

/*
    Provides access to the underlying object model implemented by a control or application.
    Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationobjectmodelpattern
*/
class IUIAutomationObjectModelPattern extends UIA.IUIAutomationBase {
    static	__IID := "{71c284b3-c14d-4d14-981e-19751b0d756d}"
    ; Retrieves an interface used to access the underlying object model of the provider.
    GetUnderlyingObjectModel() {
        local retVal
        return (ComCall(3, this, "ptr*", &retVal := 0), ComValue(0xd, retVal))
    }
}

class IUIAutomationProxyFactory extends UIA.IUIAutomationBase {
    CreateProvider(hwnd, idObject, idChild) {
        local provider
        return (ComCall(3, this, "ptr", hwnd, "int", idObject, "int", idChild, "ptr*", &provider := 0), ComValue(0xd, provider))
    }
    ProxyFactoryId {
        get {
            local factoryId
            return (ComCall(4, this, "ptr*", &factoryId := 0), UIA.BSTR(factoryId))
        }
    }
}

class IUIAutomationProxyFactoryEntry extends UIA.IUIAutomationBase {
    ProxyFactory() {
        local factory
        if (ComCall(3, this, "ptr*", &factory := 0), factory)
            return UIA.IUIAutomationProxyFactory(factory)
        throw UnsetError("No ProxyFactory returned by " A_ThisFunc, -1)
    }
    ClassName {
        get {
            local classname
            return (ComCall(4, this, "ptr*", &classname := 0), UIA.BSTR(classname))
        }
        set => (ComCall(9, this, "wstr", Value))
    }
    ImageName {
        get {
            local imageName
            return (ComCall(5, this, "ptr*", &imageName := 0), UIA.BSTR(imageName))
        }
        set => (ComCall(10, this, "wstr", Value))
    }
    AllowSubstringMatch {
        get {
            local allowSubstringMatch
            return (ComCall(6, this, "int*", &allowSubstringMatch := 0), allowSubstringMatch)
        }
        set => (ComCall(11, this, "int", Value))
    }
    CanCheckBaseClass {
        get {
            local canCheckBaseClass
            return (ComCall(7, this, "int*", &canCheckBaseClass := 0), canCheckBaseClass)
        }
        set => (ComCall(12, this, "int", Value))
    }
    NeedsAdviseEvents {
        get {
            local adviseEvents
            return (ComCall(8, this, "int*", &adviseEvents := 0), adviseEvents)
        }
        set => (ComCall(13, this, "int", Value))
    }
    SetWinEventsForAutomationEvent(eventId, propertyId, winEvents) => ComCall(14, this, "int", eventId, "Int", propertyId, "ptr", winEvents)
    GetWinEventsForAutomationEvent(eventId, propertyId) {
        local winEvents
        return (ComCall(15, this, "int", eventId, "Int", propertyId, "ptr*", &winEvents := 0), ComValue(0x200d, winEvents))
    }
}

class IUIAutomationProxyFactoryMapping extends UIA.IUIAutomationBase {
    Count {
        get {
            local count
            return (ComCall(3, this, "uint*", &count := 0), count)
        }
    }
    GetTable() {
        local table
        return (ComCall(4, this, "ptr*", &table := 0), ComValue(0x200d, table))
    }
    GetEntry(index) {
        local entry
        if (ComCall(5, this, "int", index, "ptr*", &entry := 0), entry)
            return UIA.IUIAutomationProxyFactoryEntry(entry)
        throw UnsetError("No ProxyFactoryEntry returned by " A_ThisFunc, -1)
    }
    SetTable(factoryList) => ComCall(6, this, "ptr", factoryList)
    InsertEntries(before, factoryList) => ComCall(7, this, "uint", before, "ptr", factoryList)
    InsertEntry(before, factory) => ComCall(8, this, "uint", before, "ptr", factory)
    RemoveEntry(index) => ComCall(9, this, "uint", index)
    ClearTable() => ComCall(10, this)
    RestoreDefaultTable() => ComCall(11, this)
}

class IUIAutomationRangeValuePattern extends UIA.IUIAutomationBase {
    ; Sets the value of the control.
    SetValue(val) => ComCall(3, this, "double", val)

    ; Retrieves the value of the control.
    Value {
        get {
            local retVal
            return (ComCall(4, this, "double*", &retVal := 0), retVal)
        }
        set => ComCall(3, this, "double", value)
    }

    ; Indicates whether the value of the element can be changed.
    IsReadOnly {
        get {
            local retVal
            return (ComCall(5, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the maximum value of the control.
    Maximum {
        get {
            local retVal
            return (ComCall(6, this, "double*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the minimum value of the control.
    Minimum {
        get {
            local retVal
            return (ComCall(7, this, "double*", &retVal := 0), retVal)
        }
    }

    ; The LargeChange and SmallChange property can support a Not a Number (NaN) value. When retrieving this property, a client can use the _isnan function to determine whether the property is a NaN value.

    ; Retrieves the value that is added to or subtracted from the value of the control when a large change is made, such as when the PAGE DOWN key is pressed.
    LargeChange {
        get {
            local retVal
            return (ComCall(8, this, "double*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the value that is added to or subtracted from the value of the control when a small change is made, such as when an arrow key is pressed.
    SmallChange {
        get {
            local retVal
            return (ComCall(9, this, "double*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the cached value of the control.
    CachedValue {
        get {
            local retVal
            return (ComCall(10, this, "double*", &retVal := 0), retVal)
        }
    }

    ; Retrieves a cached value that indicates whether the value of the element can be changed.
    CachedIsReadOnly {
        get {
            local retVal
            return (ComCall(11, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the cached maximum value of the control.
    CachedMaximum {
        get {
            local retVal
            return (ComCall(12, this, "double*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the cached minimum value of the control.
    CachedMinimum {
        get {
            local retVal
            return (ComCall(13, this, "double*", &retVal := 0), retVal)
        }
    }

    ; Retrieves, from the cache, the value that is added to or subtracted from the value of the control when a large change is made, such as when the PAGE DOWN key is pressed.
    CachedLargeChange {
        get {
            local retVal
            return (ComCall(14, this, "double*", &retVal := 0), retVal)
        }
    }

    ; Retrieves, from the cache, the value that is added to or subtracted from the value of the control when a small change is made, such as when an arrow key is pressed.
    CachedSmallChange {
        get {
            local retVal
            return (ComCall(15, this, "double*", &retVal := 0), retVal)
        }
    }
}

class IUIAutomationScrollItemPattern extends UIA.IUIAutomationBase {
    ; Scrolls the content area of a container object to display the UI Automation element within the visible region (viewport) of the container.
    ; This method does not provide the ability to specify the position of the element within the viewport.
    ScrollIntoView() => ComCall(3, this)
}

class IUIAutomationScrollPattern extends UIA.IUIAutomationBase {
    ; Scrolls the visible region of the content area horizontally and vertically.
    ; Default values for horizontalAmount and horizontalAmount is UIA.ScrollAmount.NoAmount
    Scroll(verticalAmount:=-1, horizontalAmount:=-1) => ComCall(3, this, "int", UIA.TypeValidation.ScrollAmount(horizontalAmount), "int", UIA.TypeValidation.ScrollAmount(verticalAmount))

    ; Sets the horizontal and vertical scroll positions as a percentage of the total content area within the UI Automation element.
    ; This method is useful only when the content area of the control is larger than the visible region.
    ; Default values for horizontalPercent and verticalPercent is UIA.ScrollAmount.NoAmount
    SetScrollPercent(verticalPercent:=-1, horizontalPercent:=-1) => ComCall(4, this, "double", horizontalPercent, "double", verticalPercent)

    ; Retrieves the horizontal scroll position.
    HorizontalScrollPercent {
        get {
            local retVal
            return (ComCall(5, this, "double*", &retVal := 0), retVal)
        }
        set => this.SetScrollPercent(,value)
    }

    ; Retrieves the vertical scroll position.
    VerticalScrollPercent {
        get {
            local retVal
            return (ComCall(6, this, "double*", &retVal := 0), retVal)
        }
        set => this.SetScrollPercent(value)
    }

    ; Retrieves the horizontal size of the viewable region of a scrollable element.
    HorizontalViewSize {
        get {
            local retVal
            return (ComCall(7, this, "double*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the vertical size of the viewable region of a scrollable element.
    VerticalViewSize {
        get {
            local retVal
            return (ComCall(8, this, "double*", &retVal := 0), retVal)
        }
    }

    ; Indicates whether the element can scroll horizontally.
    ; This property can be dynamic. For example, the content area of the element might not be larger than the current viewable area, meaning that the property is FALSE. However, resizing the element or adding child items can increase the bounds of the content area beyond the viewable area, making the property TRUE.
    HorizontallyScrollable {
        get {
            local retVal
            return (ComCall(9, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Indicates whether the element can scroll vertically.
    VerticallyScrollable {
        get {
            local retVal
            return (ComCall(10, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the cached horizontal scroll position.
    CachedHorizontalScrollPercent {
        get {
            local retVal
            return (ComCall(11, this, "double*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the cached vertical scroll position.
    CachedVerticalScrollPercent {
        get {
            local retVal
            return (ComCall(12, this, "double*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the cached horizontal size of the viewable region of a scrollable element.
    CachedHorizontalViewSize {
        get {
            local retVal
            return (ComCall(13, this, "double*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the cached vertical size of the viewable region of a scrollable element.
    CachedVerticalViewSize {
        get {
            local retVal
            return (ComCall(14, this, "double*", &retVal := 0), retVal)
        }
    }

    ; Retrieves a cached value that indicates whether the element can scroll horizontally.
    CachedHorizontallyScrollable {
        get {
            local retVal
            return (ComCall(15, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves a cached value that indicates whether the element can scroll vertically.
    CachedVerticallyScrollable {
        get {
            local retVal
            return (ComCall(16, this, "int*", &retVal := 0), retVal)
        }
    }
}

class IUIAutomationSelectionItemPattern extends UIA.IUIAutomationBase {
    ; Clears any selected items and then selects the current element.
    Select() => ComCall(3, this)

    ; Adds the current element to the collection of selected items.
    AddToSelection() => ComCall(4, this)

    ; Removes this element from the selection.
    ; An error code is returned if this element is the only one in the selection and the selection container requires at least one element to be selected.
    RemoveFromSelection() => ComCall(5, this)

    ; Indicates whether this item is selected.
    IsSelected {
        get {
            local retVal
            return (ComCall(6, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the element that supports IUIAutomationSelectionPattern and acts as the container for this item.
    SelectionContainer {
        get {
            local retVal
            if (ComCall(7, this, "ptr*", &retVal := 0), retVal)
                return UIA.IUIAutomationElement(retVal)
            throw UnsetError("No element returned by " A_ThisFunc, -1)
        }
    }

    ; A cached value that indicates whether this item is selected.
    CachedIsSelected {
        get {
            local retVal
            return (ComCall(8, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the cached element that supports IUIAutomationSelectionPattern and acts as the container for this item.
    CachedSelectionContainer {
        get {
            local retVal
            if (ComCall(9, this, "ptr*", &retVal := 0), retVal)
                return UIA.IUIAutomationElement(retVal)
            throw UnsetError("No element returned by " A_ThisFunc, -1)
        }
    }
}

class IUIAutomationSelectionPattern extends UIA.IUIAutomationBase {
    ; Retrieves the selected elements in the container.
    GetSelection() {
        local retVal
        return (ComCall(3, this, "ptr*", &retVal := 0), retVal?UIA.IUIAutomationElementArray(retVal).ToArray():[])
    }

    ; Indicates whether more than one item in the container can be selected at one time.
    CanSelectMultiple {
        get {
            local retVal
            return (ComCall(4, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Indicates whether at least one item must be selected at all times.
    IsSelectionRequired {
        get {
            local retVal
            return (ComCall(5, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the cached selected elements in the container.
    GetCachedSelection() {
        local retVal
        return (ComCall(6, this, "ptr*", &retVal := 0), retVal?UIA.IUIAutomationElementArray(retVal).ToArray():[])
    }

    ; Retrieves a cached value that indicates whether more than one item in the container can be selected at one time.
    CachedCanSelectMultiple {
        get {
            local retVal
            return (ComCall(7, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves a cached value that indicates whether at least one item must be selected at all times.
    CachedIsSelectionRequired {
        get {
            local retVal
            return (ComCall(8, this, "int*", &retVal := 0), retVal)
        }
    }

    ; --------------- SelectionPattern2 ---------------

    ; Gets an IUIAutomationElement object representing the first item in a group of selected items.
    FirstSelectedItem {
        get {
            local retVal
            return (ComCall(9, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Gets an IUIAutomationElement object representing the last item in a group of selected items.
    LastSelectedItem {
        get {
            local retVal
            return (ComCall(10, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Gets an IUIAutomationElement object representing the currently selected item.
    SelectedItem {
        get {
            local retVal
            return (ComCall(11, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Gets an integer value indicating the number of selected items.
    ItemCount {
        get {
            local retVal
            return (ComCall(12, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Gets a cached IUIAutomationElement object representing the first item in a group of selected items.
    CachedFirstSelectedItem {
        get {
            local retVal
            return (ComCall(13, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Gets a cached IUIAutomationElement object representing the last item in a group of selected items.
    CachedLastSelectedItem {
        get {
            local retVal
            return (ComCall(14, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Gets a cached IUIAutomationElement object representing the currently selected item.
    CachedSelectedItem {
        get {
            local retVal
            return (ComCall(15, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Gets a cached integer value indicating the number of selected items.
    CachedItemCount {
        get {
            local retVal
            return (ComCall(16, this, "int*", &retVal := 0), retVal)
        }
    }
}

class IUIAutomationSpreadsheetPattern extends UIA.IUIAutomationBase {
    GetItemByName(name) {
        local element
        if (ComCall(3, this, "wstr", name, "ptr*", &element := 0), element)
            return UIA.IUIAutomationElement(element)
        throw UnsetError("No element returned by " A_ThisFunc, -1)
    }
}

class IUIAutomationSpreadsheetItemPattern extends UIA.IUIAutomationBase {
    Formula {
        get {
            local retVal
            return (ComCall(3, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }
    GetAnnotationObjects() {
        local retVal
        return (ComCall(4, this, "ptr*", &retVal := 0), retVal?UIA.IUIAutomationElementArray(retVal).ToArray():[])
    }
    GetAnnotationTypes() {
        local retVal
        return (ComCall(5, this, "ptr*", &retVal := 0), ComValue(0x2003, retVal))
    }
    CachedFormul {
        get {
            local retVal
            return (ComCall(6, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }
    GetCachedAnnotationObjects() {
        local retVal
        return (ComCall(7, this, "ptr*", &retVal := 0), retVal?UIA.IUIAutomationElementArray(retVal).ToArray():[])
    }
    GetCachedAnnotationTypes() {
        local retVal
        return (ComCall(8, this, "ptr*", &retVal := 0), ComValue(0x2003, retVal))
    }
}

class IUIAutomationStylesPattern extends UIA.IUIAutomationBase {
    StyleId {
        get {
            local retVal
            return (ComCall(3, this, "int*", &retVal := 0), retVal)
        }
    }
    StyleName {
        get {
            local retVal
            return (ComCall(4, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }
    FillColor {
        get {
            local retVal
            return (ComCall(5, this, "int*", &retVal := 0), retVal)
        }
    }
    FillPatternStyle {
        get {
            local retVal
            return (ComCall(6, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }
    Shape {
        get {
            local retVal
            return (ComCall(7, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }
    FillPatternColor {
        get {
            local retVal
            return (ComCall(8, this, "int*", &retVal := 0), retVal)
        }
    }
    ExtendedProperties {
        get {
            local retVal
            return (ComCall(9, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }
    GetExtendedPropertiesAsArray() {
        ComCall(10, this, "ptr*", &propertyArray := 0, "int*", &propertyCount := 0), arr := []
        for p in UIA.NativeArray(propertyArray, propertyCount)
            arr.Push({ PropertyName: UIA.BSTR(NumGet(p, "ptr")), PropertyValue: UIA.BSTR(NumGet(p, A_PtrSize, "ptr")) })
        return arr
    }
    CachedStyleId {
        get {
            local retVal
            return (ComCall(11, this, "int*", &retVal := 0), retVal)
        }
    }
    CachedStyleName {
        get {
            local retVal
            return (ComCall(12, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }
    CachedFillColor {
        get {
            local retVal
            return (ComCall(13, this, "int*", &retVal := 0), retVal)
        }
    }
    CachedFillPatternStyle {
        get {
            local retVal
            return (ComCall(14, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }
    CachedShape {
        get {
            local retVal
            return (ComCall(15, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }
    CachedFillPatternColor {
        get {
            local retVal
            return (ComCall(16, this, "int*", &retVal := 0), retVal)
        }
    }
    CachedExtendedProperties {
        get {
            local retVal
            return (ComCall(17, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }
    GetCachedExtendedPropertiesAsArray() {
        ComCall(18, this, "ptr*", &propertyArray := 0, "int*", &propertyCount := 0), arr := []
        for p in UIA.NativeArray(propertyArray, propertyCount)
            arr.Push({ PropertyName: UIA.BSTR(NumGet(p, "ptr")), PropertyValue: UIA.BSTR(NumGet(p, A_PtrSize, "ptr")) })
        return arr
    }
}

class IUIAutomationSynchronizedInputPattern extends UIA.IUIAutomationBase {
    ; Causes the Microsoft UI Automation provider to start listening for mouse or keyboard input.
    ; When matching input is found, the provider checks whether the target element matches the current element. If they match, the provider raises the UIA_InputReachedTargetEventId event; otherwise it raises the UIA_InputReachedOtherElementEventId or UIA_InputDiscardedEventId event.
    ; After receiving input of the specified type, the provider stops checking for input and continues as normal.
    ; If the provider is already listening for input, this method returns E_INVALIDOPERATION.
    StartListening(inputType) => ComCall(3, this, "int", inputType)

    ; Causes the Microsoft UI Automation provider to stop listening for mouse or keyboard input.
    Cancel() => ComCall(4, this)
}

class IUIAutomationTableItemPattern extends UIA.IUIAutomationBase {
    ; Retrieves the row headers associated with a table item or cell.
    GetRowHeaderItems() {
        local retVal
        return (ComCall(3, this, "ptr*", &retVal := 0), retVal?UIA.IUIAutomationElementArray(retVal).ToArray():[])
    }

    ; Retrieves the column headers associated with a table item or cell.
    GetColumnHeaderItems() {
        local retVal
        return (ComCall(4, this, "ptr*", &retVal := 0), retVal?UIA.IUIAutomationElementArray(retVal).ToArray():[])
    }

    ; Retrieves the cached row headers associated with a table item or cell.
    GetCachedRowHeaderItems() {
        local retVal
        return (ComCall(5, this, "ptr*", &retVal := 0), retVal?UIA.IUIAutomationElementArray(retVal).ToArray():[])
    }

    ; Retrieves the cached column headers associated with a table item or cell.
    GetCachedColumnHeaderItems() {
        local retVal
        return (ComCall(6, this, "ptr*", &retVal := 0), retVal?UIA.IUIAutomationElementArray(retVal).ToArray():[])
    }
}

class IUIAutomationTablePattern extends UIA.IUIAutomationBase {
    ; Retrieves a collection of UI Automation elements representing all the row headers in a table.
    GetRowHeaders() {
        local retVal
        return (ComCall(3, this, "ptr*", &retVal := 0), retVal?UIA.IUIAutomationElementArray(retVal).ToArray():[])
    }

    ; Retrieves a collection of UI Automation elements representing all the column headers in a table.
    GetColumnHeaders() {
        local retVal
        return (ComCall(4, this, "ptr*", &retVal := 0), retVal?UIA.IUIAutomationElementArray(retVal).ToArray():[])
    }

    ; Retrieves the primary direction of traversal for the table.
    RowOrColumnMajor {
        get {
            local retVal
            return (ComCall(5, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves a cached collection of UI Automation elements representing all the row headers in a table.
    GetCachedRowHeaders() {
        local retVal
        return (ComCall(6, this, "ptr*", &retVal := 0), retVal?UIA.IUIAutomationElementArray(retVal).ToArray():[])
    }

    ; Retrieves a cached collection of UI Automation elements representing all the column headers in a table.
    GetCachedColumnHeaders() {
        local retVal
        return (ComCall(7, this, "ptr*", &retVal := 0), retVal?UIA.IUIAutomationElementArray(retVal).ToArray():[])
    }

    ; Retrieves the cached primary direction of traversal for the table.
    CachedRowOrColumnMajor {
        get {
            local retVal
            return (ComCall(8, this, "int*", &retVal := 0), retVal)
        }
    }
}

class IUIAutomationTextChildPattern extends UIA.IUIAutomationBase {
    TextContainer {
        get {
            local container
            if (ComCall(3, this, "ptr*", &container := 0), container)
                return UIA.IUIAutomationElement(container)
            throw UnsetError("No element returned by " A_ThisFunc, -1)
        }
    }
    TextRange {
        get {
            local range
            if (ComCall(4, this, "ptr*", &range := 0), range)
                return UIA.IUIAutomationTextRange(range)
            throw UnsetError("No TextRange returned by " A_ThisFunc, -1)
        }
    }
}

class IUIAutomationTextEditPattern extends UIA.IUIAutomationBase {
    GetActiveComposition() {
        local range
        if (ComCall(3, this, "ptr*", &range := 0), range)
            return UIA.IUIAutomationTextRange(range)
        throw UnsetError("No TextRange returned by " A_ThisFunc, -1)
    }
    GetConversionTarget() {
        local range
        if (ComCall(4, this, "ptr*", &range := 0), range)
            return UIA.IUIAutomationTextRange(range)
        throw UnsetError("No TextRange returned by " A_ThisFunc, -1)
    }
}

class IUIAutomationTextPattern extends UIA.IUIAutomationBase {
    /*
    * Retrieves the degenerate (empty) text range nearest to the specified screen coordinates.
    * A text range that wraps a child object is returned if the screen coordinates are within the coordinates of an image, hyperlink, Microsoft Excel spreadsheet, or other embedded object.
    * Because hidden text is not ignored, this method retrieves a degenerate range from the visible text closest to the specified coordinates.
    */
    RangeFromPoint(x, y?) {
        local range
        if (ComCall(3, this, "int64", IsSet(y) ? y << 32 | (x & 0xFFFFFFFF) : x, "ptr*", &range := 0), range)
            return UIA.IUIAutomationTextRange(range)
        throw UnsetError("No TextRange returned by " A_ThisFunc, -1)
    }

    ; Retrieves a text range enclosing a child element such as an image, hyperlink, Microsoft Excel spreadsheet, or other embedded object.
    ; If there is no text in the range that encloses the child element, a degenerate (empty) range is returned.
    ; The child parameter is either a child of the element associated with a IUIAutomationTextPattern or from the array of children of a IUIAutomationTextRange.
    RangeFromChild(child) {
        local range
        if (ComCall(4, this, "ptr", child, "ptr*", &range := 0), range)
            return UIA.IUIAutomationTextRange(range)
        throw UnsetError("No TextRange returned by " A_ThisFunc, -1)
    }

    ; Retrieves a collection of text ranges that represents the currently selected text in a text-based control.
    ; If the control supports the selection of multiple, non-contiguous spans of text, the ranges collection receives one text range for each selected span.
    ; If the control contains only a single span of selected text, the ranges collection receives a single text range.
    ; If the control contains a text insertion point but no text is selected, the ranges collection receives a degenerate (empty) text range at the position of the text insertion point.
    ; If the control does not contain a text insertion point or does not support text selection, ranges is set to NULL.
    ; Use the IUIAutomationTextPattern.SupportedTextSelection property to test whether a control supports text selection.
    GetSelection() {
        local ranges
        return (ComCall(5, this, "ptr*", &ranges := 0), ranges?UIA.IUIAutomationTextRangeArray(ranges).ToArray():[])
    }

    ; Retrieves an array of disjoint text ranges from a text-based control where each text range represents a contiguous span of visible text.
    ; If the visible text consists of one contiguous span of text, the ranges array will contain a single text range that represents all of the visible text.
    ; If the visible text consists of multiple, disjoint spans of text, the ranges array will contain one text range for each visible span, beginning with the first visible span, and ending with the last visible span. Disjoint spans of visible text can occur when the content of a text-based control is partially obscured by an overlapping window or other object, or when a text-based control with multiple pages or columns has content that is partially scrolled out of view.
    ; IUIAutomationTextPattern,,GetVisibleRanges retrieves a degenerate (empty) text range if no text is visible, if all text is scrolled out of view, or if the text-based control contains no text.
    GetVisibleRanges() {
        local ranges
        return (ComCall(6, this, "ptr*", &ranges := 0), ranges?UIA.IUIAutomationTextRangeArray(ranges).ToArray():[])
    }

    ; Retrieves a text range that encloses the main text of a document.
    ; Some auxiliary text such as headers, footnotes, or annotations might not be included.
    DocumentRange {
        get {
            local range
            if (ComCall(7, this, "ptr*", &range := 0), range)
                return UIA.IUIAutomationTextRange(range)
            throw UnsetError("No TextRange returned by " A_ThisFunc, -1)
        }
    }

    ; Retrieves a value that specifies the type of text selection that is supported by the control.
    SupportedTextSelection {
        get {
            local supportedTextSelection
            return (ComCall(8, this, "int*", &supportedTextSelection := 0), supportedTextSelection)
        }
    }

    ; ------------- TextPattern2 ------------

    RangeFromAnnotation(annotation) {
        local out
        if (ComCall(9, this, "ptr", annotation, "ptr*", &out:=0), out)
            return UIA.IUIAutomationTextRange(out)
        throw UnsetError("No TextRange returned by " A_ThisFunc, -1)
    }
    GetCaretRange(&isActive:=0) {
        local out
        if (ComCall(10, this, "ptr*", &isActive:=0, "ptr*", &out:=0), out)
            return UIA.IUIAutomationTextRange(out)
        throw UnsetError("No TextRange returned by " A_ThisFunc, -1)
    }
}

/*
    Provides access to a span of continuous text in a container that supports the TextPattern interface. TextRange can be used to select, compare, and retrieve embedded objects from the text span. The interface uses two endpoints to delimit where the text span starts and ends. Disjoint spans of text are represented by a TextRangeArray, which is an array of TextRange interfaces.
    Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationtextrange
*/
class IUIAutomationTextRange extends UIA.IUIAutomationBase {
    static __IID := "{A543CC6A-F4AE-494B-8239-C814481187A8}"
    ; Retrieves a IUIAutomationTextRange identical to the original and inheriting all properties of the original.
    ; The range can be manipulated independently of the original.
    Clone() {
        local clonedRange
        if (ComCall(3, this, "ptr*", &clonedRange := 0), clonedRange)
            return UIA.IUIAutomationTextRange(clonedRange)
        throw UnsetError("No TextRange returned by " A_ThisFunc, -1)
    }

    ; Retrieves a value that specifies whether this text range has the same endpoints as another text range.
    ; This method compares the endpoints of the two text ranges, not the text in the ranges. The ranges are identical if they share the same endpoints. If two text ranges have different endpoints, they are not identical even if the text in both ranges is exactly the same.
    Compare(range) {
        local areSame
        return (ComCall(4, this, "ptr", range, "int*", &areSame := 0), areSame)
    }

    ; Retrieves a value that specifies whether the start or end endpoint of this text range is the same as the start or end endpoint of another text range.
    ; EndPoint must be one of UIA.TextPatternRangeEndpoint values: Start, End
    CompareEndpoints(srcEndPoint, range, targetEndPoint) {
        local compValue
        return (ComCall(5, this, "int", UIA.TypeValidation.TextPatternRangeEndpoint(srcEndPoint), "ptr", range, "int", UIA.TypeValidation.TextPatternRangeEndpoint(targetEndPoint), "int*", &compValue := 0), compValue)
    }

    ; Normalizes the text range by the specified text unit. The range is expanded if it is smaller than the specified unit, or shortened if it is longer than the specified unit.
    ; Client applications such as screen readers use this method to retrieve the full word, sentence, or paragraph that exists at the insertion point or caret position.
    ; Despite its name, the ExpandToEnclosingUnit method does not necessarily expand a text range. Instead, it "normalizes" a text range by moving the endpoints so that the range encompasses the specified text unit. The range is expanded if it is smaller than the specified unit, or shortened if it is longer than the specified unit. If the range is already an exact quantity of the specified units, it remains unchanged. The following diagram shows how ExpandToEnclosingUnit normalizes a text range by moving the endpoints of the range.
    ; ExpandToEnclosingUnit defaults to the next largest text unit supported if the specified text unit is not supported by the control. The order, from smallest unit to largest, is as follows, Character Format Word Line Paragraph Page Document
    ; ExpandToEnclosingUnit respects both visible and hidden text.
    ; TextUnit must be one of UIA.TextUnit values: Character, Format, Word, Line, Paragraph, Page, Document. Default is Document.
    ExpandToEnclosingUnit(textUnit:=6) => ComCall(6, this, "int", textUnit)

    ; Retrieves a text range subset that has the specified text attribute value.
    ; The FindAttribute method retrieves matching text regardless of whether the text is hidden or visible. Use UIA_IsHiddenAttributeId to check text visibility.
    FindAttribute(attr, val, backward:=False) {
        if A_PtrSize = 4
            val := UIA.ComVar(val, , true), ComCall(7, this, "int", attr, "int64", NumGet(val, "int64"), "int64", NumGet(val, 8, "int64"), "int", backward, "ptr*", &found := 0)
        else
            ComCall(7, this, "int", attr, "ptr", UIA.ComVar(val, , true), "int", backward, "ptr*", &found := 0)
        return found?UIA.IUIAutomationTextRange(found):""
    }

    ; Retrieves a text range subset that contains the specified text. There is no differentiation between hidden and visible text.
    FindText(text, backward:=False, ignoreCase:=False) {
        local found
        if (ComCall(8, this, "wstr", text, "int", backward, "int", ignoreCase, "ptr*", &found := 0), found)
            return UIA.IUIAutomationTextRange(found)
        throw UnsetError("No TextRange returned by " A_ThisFunc, -1)
    }

    ; Retrieves the value of the specified text attribute across the entire text range.
    ; The type of value retrieved by this method depends on the attr parameter. For example, calling GetAttributeValue with the attr parameter set to UIA_FontNameAttributeId returns a string that represents the font name of the text range, while calling GetAttributeValue with attr set to UIA_IsItalicAttributeId would return a boolean.
    ; If the attribute specified by attr is not supported, the value parameter receives a value that is equivalent to the IUIAutomation,,ReservedNotSupportedValue property.
    ; A text range can include more than one value for a particular attribute. For example, if a text range includes more than one font, the FontName attribute will have multiple values. An attribute with more than one value is called a mixed attribute. You can determine if a particular attribute is a mixed attribute by comparing the value retrieved from GetAttributeValue with the UIAutomation,,ReservedMixedAttributeValue property.
    ; The GetAttributeValue method retrieves the attribute value regardless of whether the text is hidden or visible. Use UIA_ IsHiddenAttributeId to check text visibility.
    GetAttributeValue(attr) {
        local val
        return (ComCall(9, this, "int", attr, "ptr", val := UIA.ComVar()), val[])
    }

    ; Retrieves a collection of bounding rectangles for each fully or partially visible line of text in a text range.
    GetBoundingRectangles() {
        ComCall(10, this, "ptr*", &boundingRects := 0)
        DllCall("oleaut32\SafeArrayGetVartype", "ptr", boundingRects, "ushort*", &baseType:=0)
        retArr := [], sa := ComValue(0x2000 | baseType, boundingRects)
        Loop sa.MaxIndex() / 4 + 1
            retArr.Push({x:Floor(sa[4*(A_Index-1)]),y:Floor(sa[4*(A_Index-1)+1]),w:Floor(sa[4*(A_Index-1)+2]),h:Floor(sa[4*(A_Index-1)+3])})
        return retArr
    }

    ; Returns the innermost UI Automation element that encloses the text range.
    GetEnclosingElement() {
        local enclosingElement
        if (ComCall(11, this, "ptr*", &enclosingElement := 0), enclosingElement)
            return UIA.IUIAutomationElement(enclosingElement)
        throw UnsetError("No element returned by " A_ThisFunc, -1)
    }

    ; Returns the plain text of the text range.
    GetText(maxLength := -1) {
        local text
        return (ComCall(12, this, "int", maxLength, "ptr*", &text := 0), UIA.BSTR(text))
    }

    ; Moves the text range forward or backward by the specified number of text units.
    ; unit must be one of UIA.TextUnit values: Character, Format, Word, Line, Paragraph, Page, Document.
    Move(unit, count) {
        local moved
        return (ComCall(13, this, "int", UIA.TypeValidation.TextUnit(unit), "int", count, "int*", &moved := 0), moved)
    }

    ; Moves one endpoint of the text range the specified number of text units within the document range.
    ; unit must be one of UIA.TextUnit values: Character, Format, Word, Line, Paragraph, Page, Document. Default is Document.
    ; EndPoint must be one of UIA.TextPatternRangeEndpoint values: Start, End
    MoveEndpointByUnit(endpoint, unit, count) {
        local moved
        return (ComCall(14, this, "int", UIA.TypeValidation.TextPatternRangeEndpoint(endpoint), "int", UIA.TypeValidation.TextUnit(unit), "int", count, "int*", &moved := 0), moved)
    }

    ; Moves one endpoint of the current text range to the specified endpoint of a second text range.
    ; If the endpoint being moved crosses the other endpoint of the same text range, that other endpoint is moved also, resulting in a degenerate (empty) range and ensuring the correct ordering of the endpoints (that is, the start is always less than or equal to the end).
    ; EndPoint must be one of UIA.TextPatternRangeEndpoint values: Start, End
    MoveEndpointByRange(srcEndPoint, range, targetEndPoint) {	; TextPatternRangeEndpoint , IUIAutomationTextRange , TextPatternRangeEndpoint
        ComCall(15, this, "int", UIA.TypeValidation.TextPatternRangeEndpoint(srcEndPoint), "ptr", range, "int", UIA.TypeValidation.TextPatternRangeEndpoint(targetEndPoint))
    }

    ; Selects the span of text that corresponds to this text range, and removes any previous selection.
    ; If the Select method is called on a text range object that represents a degenerate (empty) text range, the text insertion point moves to the starting endpoint of the text range.
    Select() => ComCall(16, this)

    ; Adds the text range to the collection of selected text ranges in a control that supports multiple, disjoint spans of selected text.
    ; The text insertion point moves to the newly selected text. If AddToSelection is called on a text range object that represents a degenerate (empty) text range, the text insertion point moves to the starting endpoint of the text range.
    AddToSelection() => ComCall(17, this)

    ; Removes the text range from an existing collection of selected text in a text container that supports multiple, disjoint selections.
    ; The text insertion point moves to the area of the removed highlight. Providing a degenerate text range also moves the insertion point.
    RemoveFromSelection() => ComCall(18, this)

    ; Causes the text control to scroll until the text range is visible in the viewport.
    ; The method respects both hidden and visible text. If the text range is hidden, the text control will scroll only if the hidden text has an anchor in the viewport.
    ; A Microsoft UI Automation client can check text visibility by calling IUIAutomationTextRange,,GetAttributeValue with the attr parameter set to UIA_IsHiddenAttributeId.
    ScrollIntoView(alignToTop) => ComCall(19, this, "int", alignToTop)

    ; Retrieves a collection of all embedded objects that fall within the text range.
    GetChildren() {
        local children
        return (ComCall(20, this, "ptr*", &children := 0), children?UIA.IUIAutomationElementArray(children).ToArray():"")
    }
    ; ---------- TextRange2 ----------

    ShowContextMenu() => ComCall(21, this)

    ; ---------- TextRange3 ----------

    GetEnclosingElementBuildCache(cacheRequest) {
        local out
        if (ComCall(22, this, "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr*", &out:=0), out)
            return UIA.IUIAutomationElement(out)
        throw UnsetError("No element returned by " A_ThisFunc, -1)
    }
    GetChildrenBuildCache(cacheRequest) {
        local out
        return (ComCall(23, this, "ptr", UIA.TypeValidation.CacheRequest(cacheRequest), "ptr*", &out:=0), out?UIA.IUIAutomationElementArray(out).ToArray():[])
    }
    GetAttributeValues(attributeIds, attributeIdCount) {
        local out
        ComCall(24, this, "ptr", ComObjValue(ComObjArray(8, attributeIds*)), "int", attributeIdCount, "ptr*", &out:=UIA.ComVar())
        return out[]
    }
}

class IUIAutomationTextRangeArray extends UIA.IUIAutomationArray {
    ; Retrieves the number of text ranges in the collection.
    Length {
        get {
            local length
            return (ComCall(3, this, "int*", &length := 0), length)
        }
    }

    ; Retrieves a text range from the collection.
    GetElement(index) {
        local element
        if (ComCall(4, this, "int", index, "ptr*", &element := 0), element)
            return UIA.IUIAutomationTextRange(element)
        throw UnsetError("No TextRange returned by " A_ThisFunc, -1)
    }
}

class IUIAutomationTogglePattern extends UIA.IUIAutomationBase {
    ; Cycles through the toggle states of the control.
    ; A control cycles through its states in this order, ToggleState_On, ToggleState_Off and, if supported, ToggleState_Indeterminate.
    Toggle() => ComCall(3, this)

    ; Retrieves the state of the control.
    ToggleState {
        get {
            local retVal
            return (ComCall(4, this, "int*", &retVal := 0), retVal)
        }
        set {
            if (this.ToggleState != value)
                this.Toggle()
        }
    }

    ; Retrieves the cached state of the control.
    CachedToggleState {
        get {
            local retVal
            return (ComCall(5, this, "int*", &retVal := 0), retVal)
        }
    }
}

/*
    Provides access to a control that can be moved, resized, or rotated.
    Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationtransformpattern
*/
class IUIAutomationTransformPattern extends UIA.IUIAutomationBase {
    ; An element cannot be moved, resized or rotated such that its resulting screen location would be completely outside the coordinates of its container and inaccessible to the keyboard or mouse. For example, when a top-level window is moved completely off-screen or a child object is moved outside the boundaries of the container's viewport, the object is placed as close to the requested screen coordinates as possible with the top or left coordinates overridden to be within the container boundaries.

    ; Moves the UI Automation element.
    Move(x, y) => ComCall(3, this, "double", x, "double", y)

    ; Resizes the UI Automation element.
    ; When called on a control that supports split panes, this method can have the side effect of resizing other contiguous panes.
    Resize(width, height) => ComCall(4, this, "double", width, "double", height)

    ; Rotates the UI Automation element.
    Rotate(degrees) => ComCall(5, this, "double", degrees)

    ; Indicates whether the element can be moved.
    CanMove {
        get {
            local retVal
            return (ComCall(6, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Indicates whether the element can be resized.
    CanResize {
        get {
            local retVal
            return (ComCall(7, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Indicates whether the element can be rotated.
    CanRotate {
        get {
            local retVal
            return (ComCall(8, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves a cached value that indicates whether the element can be moved.
    CachedCanMove {
        get {
            local retVal
            return (ComCall(9, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves a cached value that indicates whether the element can be resized.
    CachedCanResize {
        get {
            local retVal
            return (ComCall(10, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves a cached value that indicates whether the element can be rotated.
    CachedCanRotate {
        get {
            local retVal
            return (ComCall(11, this, "int*", &retVal := 0), retVal)
        }
    }

    ; --------------- TransformPattern2 ---------------

    CanZoom {
        get {
            local retVal
            return (ComCall(14, this, "int*", &retVal := 0), retVal)
        }
    }
    CachedCanZoom {
        get {
            local retVal
            return (ComCall(15, this, "int*", &retVal := 0), retVal)
        }
    }
    ZoomLevel {
        get {
            local retVal
            return (ComCall(16, this, "double*", &retVal := 0), retVal)
        }
    }
    CachedZoomLevel {
        get {
            local retVal
            return (ComCall(17, this, "double*", &retVal := 0), retVal)
        }
    }
    ZoomMinimum {
        get {
            local retVal
            return (ComCall(18, this, "double*", &retVal := 0), retVal)
        }
    }
    CachedZoomMinimum {
        get {
            local retVal
            return (ComCall(19, this, "double*", &retVal := 0), retVal)
        }
    }
    ZoomMaximum {
        get {
            local retVal
            return (ComCall(20, this, "double*", &retVal := 0), retVal)
        }
    }
    CachedZoomMaximum {
        get {
            local retVal
            return (ComCall(21, this, "double*", &retVal := 0), retVal)
        }
    }
    Zoom(zoomValue) => ComCall(12, this, "double", zoomValue)
    ZoomByUnit(ZoomUnit) => ComCall(13, this, "uint", ZoomUnit)
}

class IUIAutomationValuePattern extends UIA.IUIAutomationBase {
    ; Sets the value of the element.
    ; The IsEnabled property must be TRUE, and the IUIAutomationValuePattern,,IsReadOnly property must be FALSE.
    SetValue(val) => ComCall(3, this, "wstr", val)

    ; Retrieves the value of the element.
    ; Single-line edit controls support programmatic access to their contents through IUIAutomationValuePattern. However, multiline edit controls do not support this control pattern, and their contents must be retrieved by using IUIAutomationTextPattern.
    ; This property does not support the retrieval of formatting information or substring values. IUIAutomationTextPattern must be used in these scenarios as well.
    Value {
        get {
            local retVal
            return (ComCall(4, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }

    ; Indicates whether the value of the element is read-only.
    IsReadOnly {
        get {
            local retVal
            return (ComCall(5, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the cached value of the element.
    CachedValue {
        get {
            local retVal
            return (ComCall(6, this, "ptr*", &retVal := 0), UIA.BSTR(retVal))
        }
    }

    ; Retrieves a cached value that indicates whether the value of the element is read-only.
    ; This property must be TRUE for IUIAutomationValuePattern,,SetValue to succeed.
    CachedIsReadOnly {
        get {
            local retVal
            return (ComCall(7, this, "int*", &retVal := 0), retVal)
        }
    }
}

/*
    Represents a virtualized item, which is an item that is represented by a placeholder automation element in the Microsoft UI Automation tree.
    Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationvirtualizeditempattern
*/
class IUIAutomationVirtualizedItemPattern extends UIA.IUIAutomationBase {
    ; Creates a full UI Automation element for a virtualized item.
    ; A virtualized item is represented by a placeholder automation element in the UI Automation tree. The Realize method causes the provider to make full information available for the item so that a full UI Automation element can be created for the item.
    Realize() => ComCall(3, this)
}

/*
    Provides access to the fundamental functionality of a window.
    Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationwindowpattern
*/
class IUIAutomationWindowPattern extends UIA.IUIAutomationBase {
    ; Closes the window.
    ; When called on a split pane control, this method closes the pane and removes the associated split. This method may also close all other panes, depending on implementation.
    Close() => ComCall(3, this)

    ; Causes the calling code to block for the specified time or until the associated process enters an idle state, whichever completes first.
    WaitForInputIdle(milliseconds) {
        local success
        return (ComCall(4, this, "int", milliseconds, "int*", &success := 0), success)
    }

    ; Minimizes, maximizes, or restores the window.
    SetWindowVisualState(state) => ComCall(5, this, "int", state)

    ; Indicates whether the window can be maximized.
    CanMaximize {
        get {
            local retVal
            return (ComCall(6, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Indicates whether the window can be minimized.
    CanMinimize {
        get {
            local retVal
            return (ComCall(7, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Indicates whether the window is modal.
    IsModal {
        get {
            local retVal
            return (ComCall(8, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Indicates whether the window is the topmost element in the z-order.
    IsTopmost {
        get {
            local retVal
            return (ComCall(9, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the visual state of the window; that is, whether it is in the normal, maximized, or minimized state.
    WindowVisualState {
        get {
            local retVal
            return (ComCall(10, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves the current state of the window for the purposes of user interaction.
    WindowInteractionState {
        get {
            local retVal
            return (ComCall(11, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves a cached value that indicates whether the window can be maximized.
    CachedCanMaximize {
        get {
            local retVal
            return (ComCall(12, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves a cached value that indicates whether the window can be minimized.
    CachedCanMinimize {
        get {
            local retVal
            return (ComCall(13, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves a cached value that indicates whether the window is modal.
    CachedIsModal {
        get {
            local retVal
            return (ComCall(14, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves a cached value that indicates whether the window is the topmost element in the z-order.
    CachedIsTopmost {
        get {
            local retVal
            return (ComCall(15, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves a cached value that indicates the visual state of the window; that is, whether it is in the normal, maximized, or minimized state.
    CachedWindowVisualState {
        get {
            local retVal
            return (ComCall(16, this, "int*", &retVal := 0), retVal)
        }
    }

    ; Retrieves a cached value that indicates the current state of the window for the purposes of user interaction.
    CachedWindowInteractionState {
        get {
            local retVal
            return (ComCall(17, this, "int*", &retVal := 0), retVal)
        }
    }
}

; Internal class: UIAViewer code
class Viewer {
    static SettingsFolderPath := A_AppData "\UIAViewer"
    static SettingsFilePath := A_AppData "\UIAViewer\settings.ini"
    __New() {
        local v, pattern, value
        OnError this.ErrorHandler.Bind(this)
        CoordMode "Mouse", "Screen"
        DetectHiddenWindows "On"
        this.Stored := {mwId:0, FilteredTreeView:Map(), TreeView:Map(), HighlightedElement:0}
        this.Capturing := False, this.MacroSidebarVisible := False, this.MacroSidebarWidth := 350, this.Focused := 1
        this.LoadSettings()
        this.cacheRequest := UIA.CreateCacheRequest()
        ; Don't even get the live element, because we don't need it. Gives a significant speed improvement.
        this.cacheRequest.AutomationElementMode := UIA.AutomationElementMode.None
        ; Set TreeScope to include the starting element and all descendants as well
        this.cacheRequest.TreeScope := 5

        this.gViewer := Gui((this.AlwaysOnTop ? "AlwaysOnTop " : "") "Resize +MinSize520x400", "UIAViewer")
        this.gViewer.OnEvent("Close", (*) => ExitApp())
        this.gViewer.OnEvent("Size", this.gViewer_Size.Bind(this))
        this.gViewer.Add("Text", "w100", "Window Info").SetFont("bold")
        this.LVWin := this.gViewer.Add("ListView", "h135 w250", ["Property", "Value"])
        this.LVWin.OnEvent("ContextMenu", LV_CopyTextMethod := this.LV_CopyText.Bind(this))
        this.LVWin.ModifyCol(1,60)
        this.LVWin.ModifyCol(2,180)
        for v in ["Title", "Text", "Id", "Location", "Class(NN)", "Process", "PID"]
            this.LVWin.Add(,v,"")
        this.gViewer.Add("Text", "w100", "Properties").SetFont("bold")
        this.LVProps := this.gViewer.Add("ListView", "h200 w250", ["Property", "Value"])
        this.LVProps.OnEvent("ContextMenu", LV_CopyTextMethod)
        this.LVProps.ModifyCol(1,100)
        this.LVProps.ModifyCol(2,140)
        this.DisplayedProps := ["Type", "LocalizedType", "Name", "Value", "AutomationId", "BoundingRectangle", "ClassName", "FullDescription", "HelpText", "AccessKey", "AcceleratorKey", "HasKeyboardFocus", "IsKeyboardFocusable", "ItemType", "ProcessId", "IsEnabled", "IsPassword", "IsOffscreen", "FrameworkId", "IsRequiredForForm", "ItemStatus", "RuntimeId"]
        for v in this.DisplayedProps {
            this.LVProps.Add(,v,"")
            this.cacheRequest.AddProperty(v)
        }
        for pattern, value in UIA.Property.OwnProps() {
            if pattern ~= "Is([\w]+Pattern.?)Available"
                this.cacheRequest.AddProperty(value)
        }

        (this.TextTVPatterns := this.gViewer.Add("Text", "w100", "Patterns")).SetFont("bold")
        this.TVPatterns := this.gViewer.Add("TreeView", "h85 w250")
        this.TVPatterns.OnEvent("DoubleClick", this.TVPatterns_DoubleClick.Bind(this))

        this.ButCapture := this.gViewer.Add("Button", "xp+60 y+10 w130", "Start capturing (F1)")
        this.ButCapture.OnEvent("Click", this.CaptureHotkeyFunc := this.ButCapture_Click.Bind(this))
        HotKey("~F1", this.CaptureHotkeyFunc)
        this.SBMain := this.gViewer.Add("StatusBar",, "  Start capturing, then hold cursor still to construct tree")
        this.SBMain.OnEvent("Click", this.SBMain_Click.Bind(this))
        this.SBMain.OnEvent("ContextMenu", this.SBMain_ContextMenu.Bind(this))
        this.gViewer.Add("Text", "x278 y10 w100", "UIA Tree").SetFont("bold")
        this.TVUIA := this.gViewer.Add("TreeView", "x275 y25 w300 h465")
        this.TVUIA.OnEvent("Click", this.TVUIA_Click.Bind(this))
        this.TVUIA.OnEvent("ContextMenu", this.TVUIA_ContextMenu.Bind(this))
        this.TVUIA.Add("Start capturing to show tree")
        this.TextFilterTVUIA := this.gViewer.Add("Text", "x275 y503", "Filter:")
        this.EditFilterTVUIA := this.gViewer.Add("Edit", "x305 y500 w100")
        this.EditFilterTVUIA.OnEvent("Change", this.EditFilterTVUIA_Change.Bind(this))
        this.GroupBoxMacro := this.gViewer.Add("GroupBox", "x900 y20 w" (this.MacroSidebarWidth-20), "Macro creator")
        (this.TextMacroAction := this.gViewer.Add("Text", "x900 y40 w40", "Action:")).SetFont("bold")
        this.DDLMacroAction := this.gViewer.Add("DDL", "Choose1 x900 y38 w120", ["No element selected"])
        (this.ButMacroAddElement := this.gViewer.Add("Button","x900 y37 w90 h20", "Add element")).SetFont("bold")
        this.ButMacroAddElement.OnEvent("Click", this.ButMacroAddElement_Click.Bind(this))
        (this.EditMacroScript := this.gViewer.Add("Edit", "-Wrap HScroll x900 y65 h410 w" (this.MacroSidebarWidth-40), "#include UIA.ahk`n`n")).SetFont("s10") ; Setting a font here disables UTF-8-BOM
        (this.ButMacroScriptRun := this.gViewer.Add("Button", "x900 y120 w70", "Test script")).SetFont("bold")
        this.ButMacroScriptRun.OnEvent("Click", this.ButMacroScriptRun_Click.Bind(this))
        this.ButToggleMacroSidebar := this.gViewer.Add("Button", "x490 y500 w120", "Show macro sidebar =>")
        this.ButToggleMacroSidebar.OnEvent("Click", this.ButToggleMacroSidebar_Click.Bind(this))
        this.gViewer.Show("w600 h550")
        this.gViewer_Size(this.gViewer,0,600,550)
        this.FocusHook := DllCall("SetWinEventHook", "UInt", 0x8005, "UInt", 0x8005, "Ptr",0,"Ptr", CallbackCreate(this.HandleFocusChangedEvent.Bind(this), "F", 7),"UInt", 0, "UInt",0, "UInt",0)
    }
    __Delete() {
        DllCall("UnhookWinEvent", "Ptr", this.FocusHook)
    }
    HandleFocusChangedEvent(hWinEventHook, Event, hWnd, idObject, idChild, dwEventThread, dwmsEventTime) {
        winHwnd := DllCall("GetAncestor", "UInt", hWnd, "UInt", 2)
        if winHwnd = this.gViewer.Hwnd {
            if !this.Focused {
                this.Focused := 1
                if IsObject(this.Stored.HighlightedElement)
                    this.Stored.HighlightedElement.Highlight(0, "Blue", 4)
            }
        } else {
            if this.Focused {
                this.Focused := 0
                if IsObject(this.Stored.HighlightedElement)
                    this.Stored.HighlightedElement.Highlight("clear")
            }
        }
        return 0
    }
    SaveSettings() {
        if !FileExist(A_AppData "\UIAViewer")
            DirCreate(A_AppData "\UIAViewer")
        IniWrite(this.PathIgnoreNames, UIA.Viewer.SettingsFilePath, "Path", "IgnoreNames")
        IniWrite(this.PathType, UIA.Viewer.SettingsFilePath, "Path", "Type")
        IniWrite(this.AlwaysOnTop, UIA.Viewer.SettingsFilePath, "General", "AlwaysOnTop")
    }
    LoadSettings() {
        this.PathIgnoreNames := IniRead(UIA.Viewer.SettingsFilePath, "Path", "IgnoreNames", 1)
        this.PathType := IniRead(UIA.Viewer.SettingsFilePath, "Path", "Type", "")
        this.AlwaysOnTop := IniRead(UIA.Viewer.SettingsFilePath, "General", "AlwaysOnTop", 1)
    }
    ErrorHandler(Exception, Mode) => (OutputDebug(Format("{1} ({2}) : ({3}) {4}`n", Exception.File, Exception.Line, Exception.What, Exception.Message) (HasProp(Exception, "Extra") ? "    Specifically: " Exception.Extra "`n" : "") "Stack:`n" Exception.Stack "`n`n"), 1)
    ; Resizes window controls when window is resized
    gViewer_Size(GuiObj, MinMax, Width, Height) {
        static RedrawFunc := WinRedraw.Bind(GuiObj.Hwnd)
        this.TVUIA.GetPos(&TV_Pos_X, &TV_Pos_Y, &TV_Pos_W, &TV_Pos_H)
        this.MoveControls(this.MacroSidebarVisible ? {Control:this.TVUIA,w:(TV_Pos_W:=Width-this.MacroSidebarWidth-TV_Pos_X-10),h:(TV_Pos_H:=Height-TV_Pos_Y-60)} : {Control:this.TVUIA,w:(TV_Pos_W:=Width-TV_Pos_X-10),h:(TV_Pos_H:=Height-TV_Pos_Y-60)})
        TV_Pos_R := TV_Pos_X+TV_Pos_W
        this.LVProps.GetPos(&LVPropsX, &LVPropsY, &LVPropsWidth, &LVPropsHeight)
        this.ButToggleMacroSidebar.GetPos(,,&ButToggleMacroSidebarW)
        this.MoveControls({Control:this.TextFilterTVUIA, x:TV_Pos_X, y:Height-47}, {Control:this.ButToggleMacroSidebar, x:TV_Pos_X+TV_Pos_W-ButToggleMacroSidebarW, y:Height-50}, {Control:this.EditFilterTVUIA, x:TV_Pos_X+30, y:Height-50}
            , {Control:this.LVProps,h:Height-LVPropsY-170}, {Control:this.TextTVPatterns,y:Height-165}, {Control:this.TVPatterns,y:Height-145}, {Control:this.ButCapture,y:Height-50}
            , {Control:this.GroupBoxMacro,x:TV_Pos_R+15, h:TV_Pos_H+35}, {Control:this.TextMacroAction,x:TV_Pos_R+25}, {Control:this.DDLMacroAction,x:TV_Pos_R+70}, {Control:this.ButMacroAddElement,x:TV_Pos_R+245}, {Control:this.EditMacroScript,x:TV_Pos_R+25,h:TV_Pos_H-50}, {Control:this.ButMacroScriptRun,x:TV_Pos_R+140,y:TV_Pos_Y+TV_Pos_H-2})
        RedrawFunc()
    }
    MoveControls(ctrls*) {
        for ctrl in ctrls
            ctrl.Control.Move(ctrl.HasOwnProp("x") ? ctrl.x : unset, ctrl.HasOwnProp("y") ? ctrl.y : unset, ctrl.HasOwnProp("w") ? ctrl.w : unset, ctrl.HasOwnProp("h") ? ctrl.h : unset)
    }
    ; Show/hide macros sidebar
    ButToggleMacroSidebar_Click(GuiCtrlObj?, Info?) {
        local w
        this.MacroSidebarVisible := !this.MacroSidebarVisible
        GuiCtrlObj.Text := this.MacroSidebarVisible ? "Hide macro sidebar <=" : "Show macro sidebar =>"
        this.gViewer.Opt("+MinSize" (520 + (this.MacroSidebarVisible ? this.MacroSidebarWidth : 0)) "x400")
        this.gViewer.GetPos(,, &w)
        this.gViewer.Move(,,w+(this.MacroSidebarVisible ? this.MacroSidebarWidth : -this.MacroSidebarWidth))
    }
    ; Handles adding elements with actions to the macro Edit
    ButMacroAddElement_Click(GuiCtrlObj?, Info?) {
        local match
        if !this.Stored.HasOwnProp("CapturedElement")
            return
        processName := WinGetProcessName(this.Stored.mwId)
        winElVariable := RegExMatch(processName, "^[^ .\d]+", &match:="") ? match[] "El" : "winEl"
        winElText := winElVariable " := UIA.ElementFromHandle(`"" WinGetTitle(this.Stored.mwId) " ahk_exe " processName "`")"
        if !InStr(this.EditMacroScript.Text, winElText) || RegExMatch(this.EditMacroScript.Text, "\Q" winElText "\E(?=[\w\W]*\QwinEl := UIA.ElementFromHandle(`"ahk_exe\E)")
            this.EditMacroScript.Text := RTrim(this.EditMacroScript.Text, "`r`n`t ") "`r`n`r`n" winElText
        else
            this.EditMacroScript.Text := RTrim(this.EditMacroScript.Text, "`r`n`t ")
        winElVariable := winElVariable (SubStr(this.SBMain.Text, 9) ? ".ElementFromPath(" SubStr(this.SBMain.Text, 9) ")" : "") (this.DDLMacroAction.Text ? "." this.DDLMacroAction.Text : "")
        if InStr(this.DDLMacroAction.Text, "Dump")
            winElVariable := "MsgBox(" winElVariable ")"
        this.EditMacroScript.Text := this.EditMacroScript.Text "`r`n" RegExReplace(winElVariable, "(?<!``)`"", "`"") "`r`n"
    }
    ; Tries to run the code in the macro Edit
    ButMacroScriptRun_Click(GuiCtrlObj?, Info?) {
        static tempFileName := "~UIAViewerMacro.tmp"
        if IsObject(this.Stored.HighlightedElement)
            this.Stored.HighlightedElement.Highlight("clear"), this.Stored.HighlightedElement := 0
        DetectHiddenWindows 1
        WinHide(this.gViewer)
        try FileDelete(tempFileName)
        try {
            FileAppend(StrReplace(this.EditMacroScript.Text, "`r"), tempFileName, "UTF-8") 
            Run(A_AhkPath " /force /cp65001 `"" A_ScriptDir "\" tempFileName "`"",,,&pid)
            if WinWait("ahk_pid " pid,, 3)
                WinWaitClose(, , 30)
        }
        if IsSet(pid) && WinExist("ahk_pid " pid)
            WinKill
        try FileDelete(tempFileName)
        WinShow(this.gViewer)
        DetectHiddenWindows 0
    }
    ; Starts showing the element under the cursor with 200ms intervals with CaptureCallback
    ButCapture_Click(GuiCtrlObj?, Info?) {
        if this.Capturing {
            this.StopCapture()
            return
        }
        this.Capturing := True
        HotKey("~F1", this.CaptureHotkeyFunc, "Off")
        HotKey("~Esc", this.CaptureHotkeyFunc, "On")
        this.TVUIA_Click("","") ; Clear highlighting from before
        this.TVUIA.Delete()
        this.TVUIA.Add("Hold cursor still to construct tree")
        this.ButCapture.Text := "Stop capturing (Esc)"
        this.CaptureCallback := this.CaptureCycle.Bind(this)
        SetTimer(this.CaptureCallback, 200)
    }
    ; Handles right-clicking a listview (copies to clipboard)
    LV_CopyText(GuiCtrlObj, Info, *) {
        local LVData, out := "", Property
        LVData := Info > GuiCtrlObj.GetCount()
            ? ListViewGetContent("", GuiCtrlObj)
            : ListViewGetContent("Selected", GuiCtrlObj)
        for LVData in StrSplit(LVData, "`n") {
            LVData := StrSplit(LVData, "`t",,2)
            switch LVData[1], 0 {
                case "Type":
                    LVData[2] := "`"" RTrim(SubStr(LVData[2],8), ")") "`""
                case "Location":
                    LVData[2] := "{" RegExReplace(LVData[2], "(\w:) (\d+)(?= )", "$1$2,") "}"
            }
            Property := -1
            try Property := UIA.Property.%LVData[1]%
            out .= ", " LVData[1] ":" (UIA.PropertyVariantTypeBSTR.Has(Property) ? "`"" StrReplace(StrReplace(LVData[2], "``", "````"), "`"", "```"") "`"" : LVData[2])
        }
        ToolTip("Copied: " (A_Clipboard := SubStr(out, 3)))
        SetTimer(ToolTip, -3000)
    }
    ; Handles running pattern methods, first trying to find the live element by RuntimeId
    TVPatterns_DoubleClick(GuiCtrlObj, Info) {
        if !Info
            return
        Item := GuiCtrlObj.GetText(Info)
        if !InStr(Item, "()")
            return
        Item := SubStr(Item, 1, -2)
        if !(CurrentEl := UIA.ElementFromHandle(this.Stored.mwId).FindElement({RuntimeId:this.Stored.CapturedElement.CachedRuntimeId}))
            return MsgBox("Live element not found!",,"4096")
        if Item ~= "Value|Scroll(?!Into)" {
            this.gViewer.Opt("-AlwaysOnTop")
            Ret := InputBox("Insert value", Item, "W200 H120")
            this.gViewer.Opt("+AlwaysOnTop")
            if Ret.Result != "OK"
                return
        }
        try CurrentEl.%GuiCtrlObj.GetText(GuiCtrlObj.GetParent(Info)) "Pattern"%.%Item%(IsSet(Ret) ? Ret.Value : unset)
    }
    ; Copies the UIA path to clipboard when statusbar is clicked
    SBMain_Click(GuiCtrlObj, Info, *) {
        if InStr(this.SBMain.Text, "Path:") {
            ToolTip("Copied: " (A_Clipboard := SubStr(this.SBMain.Text, 9)))
            SetTimer(ToolTip, -3000)
        }
    }
    ; StatusBar context menu creation
    SBMain_ContextMenu(GuiCtrlObj, Item, IsRightClick, X, Y) {
        SBMain_Menu := Menu()
        if InStr(this.SBMain.Text, "Path:") {
            SBMain_Menu.Add("Copy UIA path", (*) => (ToolTip("Copied: " (A_Clipboard := this.Stored.CapturedElement.Path)), SetTimer(ToolTip, -3000)))
            SBMain_Menu.Add("Copy condition path", (*) => (ToolTip("Copied: " (A_Clipboard := this.Stored.CapturedElement.ConditionPath)), SetTimer(ToolTip, -3000)))
            SBMain_Menu.Add("Copy numeric path", (*) => (ToolTip("Copied: " (A_Clipboard := this.Stored.CapturedElement.NumericPath)), SetTimer(ToolTip, -3000)))
            SBMain_Menu.Add()
        }
        SBMain_Menu.Add("Display UIA path (relatively reliable, shortest)", (*) => (this.PathType := this.PathType = "" ? "" : "", this.Stored.HasOwnProp("CapturedElement") ? this.SBMain.SetText("  Path: " (this.PathType = "Numeric" ? this.Stored.CapturedElement.NumericPath : this.Stored.CapturedElement.Path)) : 1))
        SBMain_Menu.Add("Display numeric path (least reliable, short)", (*) => (this.PathType := this.PathType = "Numeric" ? "" : "Numeric", this.Stored.HasOwnProp("CapturedElement") ? this.SBMain.SetText("  Path: " (this.PathType = "Numeric" ? this.Stored.CapturedElement.NumericPath : this.Stored.CapturedElement.Path)) : 1))
        SBMain_Menu.Add("Display condition path (most reliable, longest)", (*) => (this.PathType := this.PathType = "Condition" ? "" : "Condition", this.Stored.HasOwnProp("CapturedElement") ? this.SBMain.SetText("  Path: " (this.PathType = "Condition" ? this.Stored.CapturedElement.ConditionPath : this.Stored.CapturedElement.Path)) : 1))
        SBMain_Menu.Add("Ignore Name properties in condition path", (*) => (this.PathIgnoreNames := !this.PathIgnoreNames))
        if this.PathIgnoreNames
            SBMain_Menu.Check("Ignore Name properties in condition path")
        if this.PathType = ""
            SBMain_Menu.Check("Display UIA path (relatively reliable, shortest)")
        if this.PathType = "Numeric"
            SBMain_Menu.Check("Display numeric path (least reliable, short)")
        if this.PathType = "Condition"
            SBMain_Menu.Check("Display condition path (most reliable, longest)")
        SBMain_Menu.Add()
        SBMain_Menu.Add("UIAViewer always on top", (*) => (this.AlwaysOnTop := !this.AlwaysOnTop, this.gViewer.Opt((this.AlwaysOnTop ? "+" : "-") "AlwaysOnTop")))
        if this.AlwaysOnTop
            SBMain_Menu.Check("UIAViewer always on top")
        SBMain_Menu.Add("Save settings", (*) => (this.SaveSettings(), ToolTip("Settings saved!"), SetTimer(ToolTip, -2000)))
        SBMain_Menu.Show()
    }
    ; Stops capturing elements under mouse, unhooks CaptureCallback
    StopCapture(GuiCtrlObj:=0, Info:=0) {
        if this.Capturing {
            this.Capturing := False
            this.ButCapture.Text := "Start capturing (F1)"
            HotKey("~Esc", this.CaptureHotkeyFunc, "Off")
            HotKey("~F1", this.CaptureHotkeyFunc, "On")
            SetTimer(this.CaptureCallback, 0)
            this.Stored.HighlightedElement.Highlight("clear")
            return
        }
    }
    ; Gets UIA element under mouse, updates the GUI.
    ; If the mouse is not moved for 1 second then constructs the UIA tree.
    CaptureCycle() {
        CoordMode "Mouse", "Screen" 
        MouseGetPos(&mX, &mY, &mwId)
        try CapturedElement := UIA.SmallestElementFromPoint(mX,mY,,this.cacheRequest)
        if !IsSet(CapturedElement)
            return
        if this.Stored.HasOwnProp("CapturedElement") && IsObject(CapturedElement) {
            try same := UIA.CompareElements(CapturedElement, this.Stored.CapturedElement) ; Cached element RuntimeIds sometimes cause an error here
            catch {
                try same := CapturedElement.CachedDump() == this.Stored.CapturedElement.CachedDump()
            }
            if same ?? 0 {
                if this.FoundTime != 0 && ((A_TickCount - this.FoundTime) > 1000) {
                    if (mX == this.Stored.mX) && (mY == this.Stored.mY) {
                        SetTimer(this.CaptureCallback, 0), this.ConstructTreeView(), this.FoundTime := 0
                        if this.Capturing
                            SetTimer(this.CaptureCallback, 200)
                    } else
                        this.FoundTime := A_TickCount
                }
                this.Stored.mX := mX, this.Stored.mY := mY
                return
            }
        }
        this.LVWin.Delete()
        try WinGetPos(&mwX, &mwY, &mwW, &mwH, mwId)
        catch
            return
        this.Stored.mwId := mwId, this.Stored.CapturedElement := CapturedElement, this.Stored.mX := mX, this.Stored.mY := mY, this.FoundTime := A_TickCount
        propsOrder := ["Title", "Text", "Id", "Location", "Class(NN)", "Process", "PID"]
        props := Map("Title", WinGetTitle(mwId), "Text", WinGetText(mwId), "Id", mwId, "Location", "x: " mwX " y: " mwY " w: " mwW " h: " mwH, "Class(NN)", WinGetClass(mwId), "Process", WinGetProcessName(mwId), "PID", WinGetPID(mwId))
        for propName in propsOrder
            this.LVWin.Add(,propName,props[propName])
        this.PopulatePropsPatterns(CapturedElement)
    }
    ; Populates the listview with UIA element properties
    PopulatePropsPatterns(Element) {
        local v, value, pattern, parent, proto, match, X, Y, W, H
        if IsObject(this.Stored.HighlightedElement)
            this.Stored.HighlightedElement.Highlight("clear")
        this.Stored.HighlightedElement := Element
        try { ; Show the Highlight only if the window is visible and
            WinGetPos(&X, &Y, &W, &H, this.Stored.mwId)
            if IsObject(this.Stored.HighlightedElement) && (elBR := this.Stored.HighlightedElement.CachedBoundingRectangle) && UIA.IntersectRect(X, Y, X+W, Y+H, elBR.l, elBR.t, elBR.r, elBR.b)
                Element.Highlight(0, "Blue", 4) ; Indefinite show
        }
        this.LVProps.Delete()
        this.TVPatterns.Delete()
        for v in this.DisplayedProps {
            try prop := Element.Cached%v%
            switch v, 0 {
                case "Type":
                    try name := UIA.Type[prop]
                    catch
                        name := "Unknown"
                    try this.LVProps.Add(, v, prop " (" name ")")
                case "BoundingRectangle":
                    prop := prop ? prop : {l:0,t:0,r:0,b:0}
                    try this.LVProps.Add(, "Location", "x: " prop.l " y: " prop.t " w: " (prop.r - prop.l) " h: " (prop.b - prop.t))
                case "RuntimeId":
                    continue ; Don't display this for now, since it might confuse users into using it as a search property.
                    ; try this.LVProps.Add(, v, UIA.RuntimeIdToString(prop)) ; Uncomment for debugging purposes
                default:
                    try this.LVProps.Add(, v, prop)
            }
            prop := ""
        }
        this.DDLMacroAction.Delete()
        this.DDLMacroAction.Add(['Click()','Click("left")','ControlClick()', 'SetFocus()', 'ShowContextMenu()', 'Highlight()', 'Dump()','DumpAll()'])
        this.DDLMacroAction.Choose(6)
        for pattern, value in UIA.Property.OwnProps() {
            if RegExMatch(pattern, "Is([\w]+)Pattern(\d?)Available", &match:=0) && Element.GetCachedPropertyValue(value) {
                parent := this.TVPatterns.Add(match[1] (match.Count > 1 ? match[2] : ""))
                if !IsObject(UIA.IUIAutomation%match[1]%Pattern)
                    continue
                proto := UIA.IUIAutomation%match[1]%Pattern.Prototype
                switch match[1], 0 {
                    case "Invoke":
                        this.DDLMacroAction.Add(['Invoke()'])
                    case "ExpandCollapse":
                        this.DDLMacroAction.Add(['Expand()', 'Collapse()'])
                    case "Value":
                        this.DDLMacroAction.Add(['Value := "value"'])
                    case "Toggle":
                        this.DDLMacroAction.Add(['Toggle()'])
                    case "SelectionItem":
                        this.DDLMacroAction.Add(['Select()', 'AddToSelection()', 'RemoveFromSelection()'])
                    case "ScrollItem":
                        this.DDLMacroAction.Add(['ScrollIntoView()'])
                }
                for name in proto.OwnProps() {
                    if name ~= "i)^(_|Cached)"
                        continue
                    this.TVPatterns.Add(name (proto.GetOwnPropDesc(name).HasOwnProp("call") ? "()" : ""), parent)
                }
            }
        }
    }
    ; Handles selecting elements in the UIA tree, highlights the selected element
    TVUIA_Click(GuiCtrlObj, Info) {
        if this.Capturing
            return
        try Element := this.EditFilterTVUIA.Value ? this.Stored.FilteredTreeView[Info] : this.Stored.TreeView[Info]
        if IsSet(Element) && Element {
            if IsObject(this.Stored.HighlightedElement) {
                if this.SafeCompareElements(Element, this.Stored.HighlightedElement)
                    return (this.Stored.HighlightedElement.Highlight("clear"), this.Stored.HighlightedElement := 0)
            }
            this.Stored.CapturedElement := Element
            try this.SBMain.SetText("  Path: " (this.PathType = "Numeric" ? Element.NumericPath : this.PathType = "Condition" ? Element.ConditionPath : Element.Path))
            this.PopulatePropsPatterns(Element)
        }
    }
    ; Permits copying the Dump of UIA element(s) to clipboard
    TVUIA_ContextMenu(GuiCtrlObj, Item, IsRightClick, X, Y) {
        TVUIA_Menu := Menu()
        try Element := this.EditFilterTVUIA.Value ? this.Stored.FilteredTreeView[Item] : this.Stored.TreeView[Item]
        if IsSet(Element)
            TVUIA_Menu.Add("Copy to Clipboard", (*) => (ToolTip("Copied Dump() output to Clipboard!"), A_Clipboard := Element.CachedDump(), SetTimer((*) => ToolTip(), -3000)))
        TVUIA_Menu.Add("Copy Tree to Clipboard", (*) => (ToolTip("Copied DumpAll() output to Clipboard!"), A_Clipboard := UIA.ElementFromHandle(this.Stored.mwId, this.cacheRequest).DumpAll(), SetTimer((*) => ToolTip(), -3000)))
        TVUIA_Menu.Show()
    }
    ; Handles filtering the UIA elements inside the TreeView when the text hasn't been changed in 500ms.
    ; Sorts the results by UIA properties.
    EditFilterTVUIA_Change(GuiCtrlObj, Info, *) {
        static TimeoutFunc := "", ChangeActive := False
        if !this.Stored.TreeView.Count
            return
        if (Info != "DoAction") || ChangeActive {
            if !TimeoutFunc
                TimeoutFunc := this.EditFilterTVUIA_Change.Bind(this, GuiCtrlObj, "DoAction")
            SetTimer(TimeoutFunc, -500)
            return
        }
        ChangeActive := True
        this.Stored.FilteredTreeView := Map(), parents := Map()
        if !(searchPhrase := this.EditFilterTVUIA.Value) {
            this.ConstructTreeView()
            ChangeActive := False
            return
        }
        this.TVUIA.Delete()
        temp := this.TVUIA.Add("Searching...")
        Sleep -1
        this.TVUIA.Opt("-Redraw")
        this.TVUIA.Delete()
        for index, Element in this.Stored.TreeView {
            for prop in this.DisplayedProps {
                try {
                    if InStr(Element.Cached%Prop%, searchPhrase) {
                        if !parents.Has(prop)
                            parents[prop] := this.TVUIA.Add(prop,, "Expand")
                        this.Stored.FilteredTreeView[this.TVUIA.Add(this.GetShortDescription(Element), parents[prop], "Expand")] := Element
                    }
                }
            }
        }
        if !this.Stored.FilteredTreeView.Count
            this.TVUIA.Add("No results found matching `"" searchPhrase "`"")
        this.TVUIA.Opt("+Redraw")
        TimeoutFunc := "", ChangeActive := False
    }
    ; Populates the TreeView with the UIA tree when capturing and the mouse is held still
    ConstructTreeView() {
        local k, v, same
        this.TVUIA.Delete()
        this.TVUIA.Add("Constructing Tree, please wait...")
        Sleep -1
        this.TVUIA.Opt("-Redraw")
        this.TVUIA.Delete()
        this.Stored.TreeView := Map()
        try this.RecurseTreeView(UIA.ElementFromHandle(this.Stored.mwId, this.cacheRequest))
        catch {
            this.Stored.TreeView := []
            this.TVUIA.Add("Error: window not found")
        }
        
        this.TVUIA.Opt("+Redraw")
        this.SBMain.SetText("  Path: ")
        if !this.Stored.CapturedElement.HasOwnProp("Path") {
            this.Stored.CapturedElement.DefineProp("Path", {Value:""})
            this.Stored.CapturedElement.DefineProp("NumericPath", {Value:""})
            this.Stored.CapturedElement.DefineProp("ConditionPath", {Value:""})
        }
        for k, v in this.Stored.TreeView {
            if this.SafeCompareElements(this.Stored.CapturedElement, v) {
                this.TVUIA.Modify(k, "Vis Select"), this.SBMain.SetText("  Path: " (this.PathType = "Numeric" ? v.NumericPath : this.PathType = "Condition" ? v.ConditionPath : v.Path))
                , this.Stored.CapturedElement.Path := v.Path
                , this.Stored.CapturedElement.NumericPath := v.NumericPath
                , this.Stored.CapturedElement.ConditionPath := v.ConditionPath
            }
        }
    }
    ; Stores the UIA tree with corresponding path values for each element
    RecurseTreeView(Element, parent:=0, path:="", conditionpath := "", numpath:="") {
        local info, child, type, name, k, v, paths := Map(), childInfo := [], children := Element.CachedChildren
        Element.DefineProp("Path", {value:"`"" path "`""})
        Element.DefineProp("ConditionPath", {value:conditionpath})
        Element.DefineProp("NumericPath", {value:numpath})
        this.Stored.TreeView[TWEl := this.TVUIA.Add(this.GetShortDescription(Element), parent, "Expand")] := Element
        ; First count up all multiple-condition-index conditions and type-index conditions
        ; This is to know whether the condition is the last of the matching ones, so we can use index -1
        ; This gives an important speed difference over regular indexing
        for child in children {
            compactCondition := this.GetCompactCondition(child, &paths, &typeCondition := "", &type:="")
            childInfo.Push([compactCondition, paths[compactCondition], typeCondition, paths[typeCondition], type])
        }
        ; Now create the final conditions and recurse the tree
        for k, child in children {
            info := childInfo[k], compactCondition := info[1], conditionIndex := info[2]
            if conditionIndex > 1 && conditionIndex = paths[compactCondition]
                conditionIndex := -1
            compactCondition .= conditionIndex = 1 ? "}" : ", i:" conditionIndex "}"
            typeIndex := info[4]
            if typeIndex > 1 && typeIndex = paths[info[3]]
                typeIndex := -1
            this.RecurseTreeView(child, TWEl, path UIA.EncodePath([typeIndex = 1 ? {Type:info[5]} : {Type:info[5], i:typeIndex}]), conditionpath (conditionpath?", ":"") compactCondition, numpath (numpath?",":"") k)
        }
    }
    ; CompareElements sometimes fails to match elements, so this compares some properties instead
    SafeCompareElements(e1, e2) {
        if e1.CachedDump() == e2.CachedDump() {
            br_e1 := e1.CachedBoundingRectangle, br_e2 := e2.CachedBoundingRectangle
            return br_e1.l = br_e2.l && br_e1.t = br_e2.t && br_e1.r = br_e2.r && br_e1.b = br_e2.b
        }
        return 0
    }
    ; Creates a short description string for the UIA tree elements
    GetShortDescription(Element) {
        local elDesc := " `"`""
        try elDesc := " `"" Element.CachedName "`""
        try elDesc := Element.CachedLocalizedType elDesc
        catch
            elDesc := "`"`"" elDesc
        return elDesc
    }
    GetCompactCondition(Element, &pathsMap, &t := "", &type := "", &automationId := "", &className := "", &name := "") {
        local n := "", c := "", a := ""
        type := Element.CachedType
        t := "{T:" (type-50000)
        if !pathsMap.Has(t) {
            pathsMap[t] := 1
            return t
        }
        pathsMap[t] := pathsMap[t] + 1
        try a := StrReplace(automationId := Element.CachedAutomationId, "`"", "```"")
        if a != "" && !IsInteger(a) { ; Ignore Integer AutomationIds, since they seem to be auto-generated in Chromium apps
            a := t ",A:`"" a "`""
            pathsMap[a] := pathsMap.Has(a) ? pathsMap[a] + 1 : 1 ; This actually shouldn't be needed, if AutomationId's are unique
        }
        try c := StrReplace(className := Element.CachedClassName, "`"", "```"")
        if c != "" {
            c := t ",CN:`"" c "`""
            pathsMap[c] := pathsMap.Has(c) ? pathsMap[c] + 1 : 1
        }
        try n := StrReplace(name := Element.CachedName, "`"", "```"")
        if !this.PathIgnoreNames && n != "" { ; Consider Name last, because it can change (eg. window title)
            n := t ",N:`"" n "`""
            pathsMap[n] := pathsMap.Has(n) ? pathsMap[n] + 1 : 1
        }
        if a != "" && !IsInteger(a) {
            return c != "" ? (pathsMap[a] <= pathsMap[c] ? a : c) : a
        } else if c != ""
            return c
        else if !this.PathIgnoreNames && n != "" && (pathsMap[n] < pathsMap[t])
            return n
        return t
    }
}

}