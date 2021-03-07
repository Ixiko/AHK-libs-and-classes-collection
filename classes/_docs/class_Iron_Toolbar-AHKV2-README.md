# IronToolbar for AHK

<img src="images/preview.gif" />

<details>
<summary>Preview #2</summary>
<img src="images/Preview2.gif" />
</details>

Why Iron?  Two reasons:
1) This class script has turned out pretty solid and reliable.
2) It was a struggle getting there, due to the Toolbar API's "iron will" to defy my attempts to make this not only accessible for AHK v2, but hopefully more accessible and usable if converted to AHK v1.

The latter is my attempt at a light-hearted joke, reflecting on my journey to getting this class script ready for a release.

I designed this class around `tb.easyMode := true`.  EasyMode is on by default and allows maximimum flexibility with minimal code.  If you want, after creating a toolbar object, set `tb.easyMode := false` to have more granular control over adding styles.

For a minimalist example of usage, please see the included example.

## Methods

<details>
<summary>...</summary>

### Toolbar.New()
Usage: `tb := Toolbar.New(in_gui, sOptions, Styles, MixedBtns, EasyMode)`

Creates a new toolbar.  Most styles are applied to toolbars automatically.

* in_gui: A GUI object to attach the toolbar to.
* sOptions: A string of options, formatted the same as AHK GUI options.
* Styles: A string of Styles and ExStyles to apply to the toolbar.
* MixedBtns: Boolean, true by default.\
By default, toolbar style "List" and ExStyle "MixedButtons" are automatically set so that the user can easily set a mix of text buttons, icon buttons, and buttons with icon and text.  Set this value to false to omit these styles.  This will allow you to use `tb.ShowText()` and `tb.HideText` to toggle button text, and the button text will be below all the buttons instead of to the right of the icon (which is what "List" style does).
* EasyMode: Boolean, true by default.\
Turning off Easy Mode automatically disables MixedBtns.  All automatic styles are disabled so you can control them manually.

Toolbar Styles:

[Toolbar Styles Reference - MS.docs](https://docs.microsoft.com/en-us/windows/win32/controls/toolbar-control-and-button-styles)\
AltDrag, CustomErase, Flat, List, RegisterDrop, ToolTips, Transparent, Wrapable

[Window Styles Reference - also affects the toolbar - MS.docs](https://docs.microsoft.com/en-us/windows/win32/winmsg/window-styles)\
Border, TabStop, ThickFrame, Child (these styles are rarely used directly with toolbars)

[Common Control Styles Reference - MS.docs](https://docs.microsoft.com/en-us/windows/win32/controls/common-control-styles)\
Adjustable, Bottom, Left, Right, Top, NoDivider, NoMoveX, NoMoveY, NoParentAlign, NoResize, Vert

[Toolbar ExStyles Reference - MS.docs](https://docs.microsoft.com/en-us/windows/win32/controls/toolbar-extended-styles)\
DoubleBuffer, DrawDDArrows, HideClippedButtons, MixedButtons\
MultiColumn, Vertical (suggested to NOT use MultiColumn and Vertical)

### tb.Add(btn_array)

Usage: `tb.Add([btn_array])`

Adds buttons and separators to the toolbar.  When adding a separator, you only need to specify `{label:""}`.  Other buttons can be specified with nothing more than specifying `{label:"txt", icon:#}`, unless you want to add the other types of buttons that toolbar supports (ie. DropDown button, Check button, etc).  In this case you would need to specify all necessary `styles` and `states` to get the button and behavior you want.

The format for the btn_array is as follows:

```
btnArray := [ { label:"str", icon:int, styles:"str", states:"str" }
            , { ... }
            , { ... } ]
```

* label: Any string for button text.
* icon: Image List index for which icon to use (not zero-based).\
Specify `icon:-1` to make a text-only button (without an icon).
* styles: A space separated list of styles and exStyles to apply.
* states: A space separated list of states to apply.

[Toolbar Button Styles Reference](https://docs.microsoft.com/en-us/windows/win32/controls/toolbar-control-and-button-styles)\
AutoSize, Button, Check, CheckGroup, DropDown, Group, NoPrefix, Sep, ShowText, WholeDropDown

[Toolbar Button States Reference](https://docs.microsoft.com/en-us/windows/win32/controls/toolbar-button-states)\
Checked, Ellipses, Enabled, Hidden, Marked, Pressed, Wrap, Grayed

### tb.BtnCount()
Usage: `tb.BtnCount()`

Returns the number of elements in the toolbar (including separators).

### tb.ClearButtons()
Usage: `tb.ClearButtons()`

Deletes all buttons on the toolbar.

### tb.CmdToIndex()
Usage: `idx := tb.CmdToIndex(idCmd)`

* idCmd: The button ID specified.  Use `tb.GetButton(idx)` to find a button's idCmd.

This is useful when using `tb.SendMsg()`.  Sometimes wParam or lParam will require the idCmd of a button instead of it's index.

### tb.Customizer()
Usage: `tb.Customizer()`

Invokes the improved Toolbar Customizer.  This customizer does everything the `OldCustomizer()` does, except that it will only hide buttons, not delete them.

### tb.Delete()
Usage: `tb.Delete(idx)`

* idx:  The 1-based index of the button to delete.

### tb.EnableButton()
Usage: `tb.EnableButton(idx, status)`

Sets button enabled / disabled status.

* idx: The 1-based index of the button to affect.
* status: TRUE or FALSE.  TRUE to enable the button, FALSE to disable it.

### tb.Export()
Usage: `map := tb.Export()`

Exports the current layout of the buttons.  States and styles are also preserved.  The output map is meant to be used with an object serializer in order to save it to disk.

Recommended serializer: [JSON](https://www.autohotkey.com/boards/viewtopic.php?f=83&t=74799&sid=3c11c9a47a6500664963402ec9ccb082)

### tb.GetButton()
Usage: `tb.GetButton(idx)`

This function returns a button object with the following properties:\
`index, label, icon, states, styles, idCmd, iString`

* idx: The 1-based index of the button to get.

This method is not usually needed for simple useage, but can be used for advanced scripting.

### tb.GetButtonDims()
Usage: `dims := tb.GetButtonDims()`

This returns the tallest button height and the widest button width, as well as the horizontal and vertical padding used in the toolbar.  The returned object contains the following properties:\
`{w, h, hPad, vPad}`

### tb.GetButtonText()
Usage: `txt := tb.GetButtonText(idx)`

* idx: The 1-based index of the button specifying the text to retrieve.

### tb.HideButton()
Usage: `tb.HideButton(idx, status)`

* idx: The 1-based index of the button to affect.
* status: TRUE or FALSE.  TRUE to hide the button, FALSE to show it.

### tb.IL_Create()
Usage: `tb.IL_Create("IL_name", file_array [, Large_Icons := false])`

Creates an image list and populates it with specified files.  This was created as a means to easily store all the necessary data for an image list in order to duplicate it.  The duplication is necessary when using the alternate toolbar customizer, which is more effective at customizing the toolbar between sessions than the default built-in toolbar customizer.

* IL_name: Any name you want to give to the image list.
* file_array: `["file/icon_index", "file/icon_index", ...].`
* Large_Icons: false by default.

### tb.IL_Destroy()
Usage: `tb.IL_Destroy("IL_name")`

* IL_name: The string name of the specified Image List to destroy.

### tb.Import()
Usage: `tb.Import(map)`

* map: A previously exported map using `map := tb.Export()`.

Imports the specified layout of the buttons.  States and styles are also preserved.  The input map is meant to be loaded with an object serializer.

Recommended serializer: [JSON](https://www.autohotkey.com/boards/viewtopic.php?f=83&t=74799&sid=3c11c9a47a6500664963402ec9ccb082)

### tb.Insert()
Usage: `tb.Insert(btn_obj, index)`

Inserts the specified button at the specified index.  The button at the index, and all buttons with a higher index, will be moved to the left.

* btn_obj: this is the same as [btn_array] with tb.Add(), but you only pass one element.  If you try to pass more than one element you will get an error.\
EX: `[ { label:"str", icon:# } ]`

### tb.MoveButton()
Usage: `tb.MoveButton(idx, pos)`

* idx: The 1-based index of the button to be moved.
* pos: The 1-based index of the position to move the button to.

### tb.OldCustomize()
Usage: `tb.OldCustomize()`

Use this to invoke the default windows Toolbar Customizer.  It is suggested to use `tb.Customizer()` instead.

### tb.Position()
Usage: `tb.Position(pos)`

* pos: One of the following strings:  top, bottom, left, right\
Default value is "top".

### tb.SendMsg()
Usage: `result := tb.SendMsg(msg, wParam, lParam)`

Not intended for causal use, however you can exercise very precise control over the toolbar and buttons by sending your own messages if desired.

### tb.SetImageList()
Usage: `tb.SetImageList(Default [, Hot := "", Pressed := "", Disabled := ""])`

* Default: The main image list for button icons.
* Hot: The image list that is used when the mouse hovers over a button. (Optional)
* Pressed: The image list used when a button is pressed. (Optional)
* Disabled: The image list used when a button is disabled. (Optional)

For most simple implementations, you only need to specify "Default".  All other parameters are optional.  Simply pass the "IL_name" used with .IL_Create() for any of the parameters you wish to use.  See IL_Create() above for more info.  If you want to change button icons, you can specify a different `Default` image list.  This is useful if you want to have small and large icons ready for on-the-fly switching.

### tb.ShowText()
Usage: `tb.ShowText(status)`

* status:  TRUE or FALSE.  TRUE to show text, FALSE to hide text.

</details>

## Properties

<details>
<summary>...</summary>

If you specify `vName` in the options when using `tb.New()` then you can access some of the same properties available to most other AutoHotkey controls.  A few of these properties have been mimicked / duplicated for convenience as described below.

### tb.callback

String.  The default callback function is `tbEvent`.  You can change the name of the callback function by changing the value of this property.

```
Default callback and parameters:

tbEvent(tb, lParam, dataObj) {
    ...
}
```

* tb: Toolbar object resulting from `tb.New()`
* lParam: Only provided for advanced usage.
* dataObj: Contains lots of info regarding the specified event.

dataObj Properties:

```
d props: { event:str, eventInt:int
         , index:int, idCmd:int, label:str, dims:{x:int, y:int, w:int, h:int}
         , hoverFlags:str, hoverFlagsInt:int
         , vKey:int, char:int
         , oldIndex:int, oldIdCmd:int, oldLabel:str }
```

[Toolbar WM_NOTIFY Events Reference - MS.docs](https://docs.microsoft.com/en-us/windows/win32/controls/bumper-toolbar-control-reference-notifications)\
dataObj Events:

```
events: LClick, LDClick, LDown, RClick, RDClick
        Char, KeyDown
        BeginDrag, DragOut, EndDrag
        DropDown
        DeletingButton
        HotItemChange
        
        - These events fire but do not currently populate data in dataObj.
        CustomDraw, DupAccelerator, GetDispInfo, GetObject, GetTipInfo, MapAccelerator
        ReleasedCapture, ToolTipsCreated, WrapAccelerator, WrapHotItem
```

NOTE:  A few events have been renamed for consistency, ie. `LClick` was originally `NM_CLICK`, and `LDClick` was `NM_LDBLCLK`, etc.

### tb.easyMode

Boolean.  This is `true` by default.  If you set this to `false` then all the automatic handling and sizing of the toolbar is disabled.  You will mostly need to use `tb.SendMsg()` in several manual contexts in order to manage the toolbar with easyMode disabled.

### tb.hotItem

Integer.  Contains the current hot-item 1-based index.

### tb.hotItemID

Integer.  Contains the current hot-item idCmd.

### tb.hwnd

Pointer.  Stores the toolbar hwnd.

### tb.name

String.  Stores the `vName` of the control if specified in options when calling `tb.New()`.

### tb.txtSpacing

Integer.  Stores the number of spaces to automatically add to the left of button text (label) when `easyMode` is enabled and when `icon:-1` is specified on button creation with `tb.Add()`.  For most non-fixed width fonts, 2 spaces should suffice.  The default value is 2.  Please see the example.

### tb.type

String.  his is always "Toolbar".

</details>

## To-Do List:

<details>
<summary>...</summary>

* Implement `CreateWindowEx()` to be able to add non-toolbar controls.  This will likely be in a separate class extension.
* Adding a few more properties (maybe).
* Testing for icons larger than 32 x 32.
* More testing with TB_SETBUTTONSIZE.
* Attempt to support automatic toolbar wrapping on window resize (not currently supported with `easyMode` enabled).
* Attempt to support Drop targets and TBN_GETOBJECT for drag-drop onto a toolbar.

</details>

Please let me know if you have any suggestions for different ways of handling things.  And please note that not using `easyMode` has not be thuroughly tested yet.

## Easy Mode
Please read the rest of the docs above and study the included script example for appropriate context, especially if you want to deviate from "easyMode".

By default, `tb.easyMode := true` and will apply the following Styles/ExStyles automatically:
* Flat Style (TBSTYLE_FLAT) - for toolbar\
Makes separators appear as bars.
* List Style (TBSTYLE_LIST) - for toolbar\
Makes text appear to the right of the icon.
* MixedButtons (TBSTYLE_EX_MIXEDBUTTONS) - for toolbar\
Hides all button text, except for buttons that have the TBSTYLE_SHOWTEXT style.
* AutoSize Style (TBSTYLE_AUTOSIZE) - for buttons\
Causes the buttons with this style to automatically resize according to the displayed icon, text, and whether or not button text should be displayed.
* ShowText Style (TBSTYLE_SHOWTEXT) - for buttons if `icon:-1` is specified on button creation\
This is a shorthand in easy mode to create a text button with no icon.
* Enabled State (TBSTATE_ENABED) - for buttons
* Wrap State (TBSTATE_WRAP) for buttons / Vert Style (CSS_VERT) for toolbar if toolbar is oriented with LEFT or RIGHT\
Orienting the toolbar with LEFT or RIGHT can be done by specifying "Left" or "Right" as one of the styles when calling `tb.New()`, or when calling `tb.Position(pos)` where `pos` is a string set to "Left" or "Right".  Conversely TBSTATE_WRAP and CSS_VERT are removed when calling `tb.Position(pos)` where `pos` is set to "Top" or "Bottom".