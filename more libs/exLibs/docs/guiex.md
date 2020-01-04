## Class
### `guiex`
## Methods
### `align(changing, reference, xywh[, alignment])`
Aligns `changing` with `reference`.
#### changing
Type: Gui Control Object
#### reference
Type: Gui Control Object
#### xywh
Type: String

One of `'x'`, `'y'`, `'w'`, `'h'`. Determines what to align.
#### alignment
Type: Float

A number between 0 and 1.

For `'x'`/`'y'`, 0 represents the left/topmost side of the controls and 1 represents the right/bottommost side. Any number between 0 and 1 represents the appropriate value between those two sides. `align` takes the two controls and aligns the two aligment values on each control.

For `'w'`/`'h'`, `changing` is resized so it's right/bottom side is moved to the alignment value of `reference`.

If omitted, `alignment := .5`, which will center `changing` with `reference` if using the `'x'` or `'y'` options.
### `backmove(gui[, winTitle, winText, excludeTitle, excludeText])`
Makes the non-interactable client aera of `gui` able to move the window via click and drag.
#### gui
Type: Gui Object
### `hkGroup(gui, text, names[, limits, positioning, hkBoxWidth, xPadding, yPadding])`
Adds a group of hotkey controls, with text to the left explaining what they're for, to `gui`.
#### gui
Type: Gui Control Object
#### text
An array of the strings that will be displayed next to the hotkey controls.
#### names
An array of strings that will be the names associated with the hotkey controls.
#### limits
Either a single value or an array of values. Reperesents the limits for each hotkey control.
#### positioning
Type: String

A standard positioning string.
#### hkBoxWidth
The width of the hotkey controls.
#### xPadding
The distance between the text and the hotkey controls.
#### yPadding
The distance between each hotkey control.
### `setCursor(guiOrCont, cursor[, options])`
#### guiOrCont
A GUI or GUI control object for which the cursor will change. If `guiOrCont` is a GUI object, then the cursor will only change when it's in the client area **and** not over a control.
#### cursor
This is a string that represents one of the built-in Windows cursors. You can read more about them [here](https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-loadcursorw). Use the part directly after `IDC_`. It also includes `hide`, which will hide the cursor.
#### options
Type: `String`
`n`: `cursor` will be applied when the mouse is moved, even when mouse buttons are held down, provided that no other setting overrides this.
`l`, `r`, and `m`: These options all have the following sub-options:
- `g`: `cursor` will be applied when the mouse is moved and the specified button is being held down.
- `d`: `cursor` will be applied when the specified button is clicked down.
- `u`: `cursor` will be applied when the specified button is released.
- `2`: `cursor` will be applied when the specified button is double clicked and held down.
Omitting all sub-options is equivalent to the sub-options `du2`, and omitting `options` is equivalent to `n l r m` (which changes the cursor at all times). Put spaces between the different options, but not between options and theirs sub-options, e.g. `ldg ru m2`.
