# GuiCtlExt_ahk2
GuiControl extensions for AHK v2 controls

```
Contributions:

AHK_user
iPhilip
just me
teadrinker

See comments in GuiCtlExt.ahk for details.

```

<br>

## Latest Updates

+ added props/methods to Edit: SelText, SelStart, SelEnd, SetSel(), SetCueText()
+ added props/methods to Combo: SelText, SelStart, SelEnd, SetSel() check_match()
+ added prop to Combo: AutoComplete (true/false)
+ added an extension for Gui to facilitate AutoComplete for combo, and other fututre expansions
+ fixed credits & comments (if I miss one please let me know)
+ renamed a few internal properties/methods for these changes
+ changed behavior of .SetSel() for Edit and ComboBox
+ updated README

<br>

## Picture Button

### Gui.AddPicButton(sOptions := "", sPicFile := "", sPicFileOpt := "", Text := "")

`sOptions` are the normal options you would specify for any `Gui` control when invoking `Gui.Add()`.

The sPicFile and sPicFileOpt parameters are the same as the first 2 parameters of LoadPicture().  For more info, see `ctl.SetImg()` below, or the AHK help files for LoadPicture().

Text is optional.

### ctl.SetImg(sFile, sOptions := "")
Sets or changes the image for a button.  Specify no text if you want an image button only.  Otherwise you will get the image and text.

sOptions is the same as `LoadPicture()`.

Example:  `Icon5 w32 h-1`

NOTE:  Specify `*w32 *h-1` to use filtering when scaling an image.

The type of image loaded is always auto-detected.

If you change a Button Pic image, then the previous image handle is automatically destroyed.

This method does not return a value.

### ctl.Type
Returns `"PicButton"`.

<br> 

## SplitButton

### Gui.AddSplitButton(sOptions := "", sText := "", callback := "")

`sOptions` are the normal options you would specify for any `Gui` control when invoking `Gui.Add()`.

Callback format:

```
callback(ctl, coords) {
    msgbox ctl.name "`r`n" coords.x " / " coords.y
}
```

The `coords` parameter is an `{object}` with properties X and Y.  The X/Y is the client coords needed to properly position a menu for the split button.

### ctl.SetImg(sFile, sOptions:="")
Same as PicButton above.

### ctl.Type
Returns `"SplitButton"`.

<br>

## ToggleButton

### Gui.AddToggleButton(sOptions := "", sText := "")
`sOptions` are the normal options you would specify for any `Gui` control when invoking `Gui.Add()`.

`sText` is the button text, if any.  You can also use .SetImg() to make this toggle button a pic button as well.

### ctl.SetImg(sFile, sOptions := "")

<br>

## ListBox

### ctl.GetCount()
Returns number of items in Listbox or ComboBox drop window.

### ctl.GetText(row)
Gets the text of the specified row.

### ctl.GetItems()
Gets a linear array of all the items in the ListBox or ComboBox drop window.

<br>

## ComboBox

### ctl.GetCount()
Returns number of items in Listbox or ComboBox drop window.

### ctl.GetText(row)
Gets the text of the specified row.

### ctl.GetItems()
Gets a linear array of all the items in the ListBox or ComboBox drop window.

### ctl.CueText
Sets/Gets cue text for the ComboBox control.

### ctl.SelEnd
Gets the end pos of the current selection.  This property may act as the "cursor position" when there is no selection.

### ctl.SelStart
Gets the start pos of the current selection.  This property may act as the "cursor position" when there is no selection.

### ctl.SelText
Gets the selected text.

### ctl.SetSel(start := "", end := "")
Sets the cursor position or selection, depending on usage.

Note that both start and end are zero based.

End can be larger than Start.

|Value(s)|Result|
|:--------:|------|
|`0` |Sets cursor to beginning of text.|
|`-1`|Sets cursor to end of text.|
|`0, -1`|Select all text.|
|`start, end`|Sets selection according to given values.|
|*blank*|Removes selection, cursor is moved to selection start.|

<br>

## ListView

### ctl.Checked(row)
Returns true if checked, false if not, for specified row.

### ctl.IconIndex(row)
Returns the icon index for the row.  Note that the default index for all rows, even without an icon is 1.

### ctl.GetColWidth(col)
Returns the width of the specified column.

<br>

## Edit

### ctl.Append(text, top := false)
Appends text to the bottom of the edit control, unless `top := true`, then text is prepended.

### ctl.SetCueText(txt, Option := false)
Sets cue text and option.

|Value|Result|
|-----|------|
|Option = true|Cue text will persist on control focus.|
|Option = false|Cue text will disappear on control focus (default).|

### ctl.CueText
Sets/Gets the cue text for the edit control.  You can also set the `Option` described in `ctl.SetCueText()` above.
```
ctl.CueText := "new cue text"

; This will set the cue text and set the Option to true.  The option can also be set to false.
ctl.CueText[true] := "new cue text"
```
Keep in mind that you must specify either only the text, or the text and the option.  You can't only set the option.

### ctl.SelEnd
Gets the end pos of the current selection.  This property may act as the "cursor position" when there is no selection.

### ctl.SelStart
Gets the start pos of the current selection.  This property may act as the "cursor position" when there is no selection.

### ctl.SelText
Gets the selected text.

### ctl.SetSel(start := "", end := "")
Sets the cursor position or selection, depending on usage.

Note that both start and end are zero based.

End can be larger than Start.

|:Value(s):|Result|
|:--------:|------|
|`0` |Sets cursor to beginning of text.|
|`-1`|Sets cursor to end of text.|
|`0, -1`|Select all text.|
|`start, end`|Sets selection according to given values.|
|*blank*|Removes selection, cursor is moved to selection start.|