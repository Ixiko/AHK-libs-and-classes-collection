# vKeyboard interface
###### An AutoHotKey library for creating simple [``XMB™``](http://manuals.playstation.net/document/en/ps3/current/basicoperations/keyboard.html)-like visual keyboards.
###### AutoHotkey v1.1.32.00+ (recommended)

***

<table align="center">
	<tr>
	<td><img src="https://raw.githubusercontent.com/A-AhkUser/resources/master/vKeyboard_1.png" /></td>
	<td><img src="https://raw.githubusercontent.com/A-AhkUser/resources/master/vKeyboard_2.png" /></td>
	</tr>
</table>

***

### Acknowledgements
- the [AutoHotkey community](https://www.autohotkey.com/boards/)
- [``JSON``](https://github.com/cocobelgica/AutoHotkey-JSON)

> special thanks to **brutus_skywalker**, **coco**, **GeekDude**, **fenchai**, **helgef**, **ixiko**, **jeeswg**, **ManiacDC**, **Rohwedder** and **Uberi**

## Table of Contents

<ul>
	<li><a href="#presentation">Presentation</a></li>
		<ul>
			<li><a href="#main-features">Main features</a></li>
		</ul>
	<li><a href="#deployment">Deployment</a></li>
		<ul>
			<li><a href="#sample-example">Sample example</a></li>
		</ul>
	<li><a href="#namespace-reservations">Namespace reservations</a></li>
	<li><a href="#vkeyboard-the-visual-keyboard-object">vKeyboard (the visual keyboard object)</a></li>
	<li><a href="#object-members">Object members</a></li>
	<li><a href="#available-properties">Available properties</a></li>
	<li><a href="#available-methods">Available methods</a></li>
	<li><a href="#event-handling">Event handling</a></li>
	<li><a href="#customization">Customization</a></li>
		<ul>
			<li><a href="#keyboard-and-joystick-shortcuts">Keyboard and joystick shortcuts</a></li>
			<li><a href="#autocomplete-lists">Autocomplete lists</a></li>
			<li><a href="#styling-the-keyboard">Styling the keyboard</a></li>
			<li><a href="#layout-json-representations">Layout JSON representations</a></li>
				<ul>
					<li><a href="#the-structure-of-keymaps">The structure of keymaps</a></li>
					<li><a href="#the-semantics-of-keymaps---key-descriptors">The semantics of keymaps - key descriptors</a></li>
					<li><a href="#the-built-in-default-callback">The built-in default callback</a></li>
					<li><a href="#f-functions">'F-functions'</a></li>
					<li><a href="#built-in-f-functions">Built-in 'f-functions'</a></li>
					<ul>
						<li><a href="#keywithvariantsproc">keyWithVariantsProc</a></li>
						<li><a href="#setaltindexproc">setAltIndexProc</a></li>
						<li><a href="#altentrymodeproc">altEntryModeProc</a></li>
						<li><a href="#setcaretposproc">setCaretPosProc</a></li>
						<li><a href="#tolayerproc">toLayerProc</a></li>
					</ul>
				</ul>
		</ul>
</ul>


***
## Presentation

The library allows to create basic but nevertheless rather customizable visual keyboards, via an AutoHotkey programmable interface. Practically, the script enables you to invoke a visual keyboard whenever text entry is required - and as an alternative to type, enter text.

***
## Main features

- The visual keyboard is endowed with an [``eAutocomplete``](https://github.com/A-AhkUser/eAutocomplete) control, which allows **autocompletion**. This latter enables you, as you are composing text, to rather quickly find, get info tips and select from a dynamic pre-populated list of suggestions and, by this means, to expand/replace partially entered strings into/by complete strings. The ``eAutocomplete`` component allows **fuzzy search**.
- The visual keyboard is designed to be easily handled **using a [12keys-1POV-4axes](https://www.autohotkey.com/docs/scripts/index.htm#JoystickTest) PC game controller**.
- Basic **event handling**.
- **Customizable** keyboard/joystick hotkeys, autocomplete lists, keyboard layouts and UI graphics.

***
## Deployment

*An instance of ``vKeyboard`` (the visual keyboard object) will be from now on referred to as ``vk``.*

- Make sure you have [a recent version of AutoHotkey](https://www.autohotkey.com/) (AutoHotkey v1.1.32.00+, preferably).
- Download [the latest release](https://github.com/A-AhkUser/vKeyboard/releases) and extract the content of the zip file to a location of your choice, for example into your project's folder hierarchy.
- Load the library ([/lib/vKeyboard.ahk](/lib/vKeyboard.ahk)) by means of the [``#Include`` directive](https://www.autohotkey.com/docs/commands/_Include.htm):

#### Sample example ([sample_example.ahk](/examples/sample_example))

```Autohotkey
#NoEnv
#SingleInstance force
SetWorkingDir % A_ScriptDir
SendMode, Input
#Warn
; tested on Windows 10 (19041) 64 bit with Autohotkey v1.1.32.00 32-bit Unicode

#Include %A_ScriptDir%\..\..\lib\vKeyboard.ahk

eAutocomplete.setSourceFromFile("fr", A_ScriptDir . "\autocompletion\fr")

vk := new vKeyboard()
vk.autocomplete.source := "fr"
vKeyboard.defineLayout("français", A_ScriptDir . "\keymaps\français.json")
vk.setLayout("français")
vKeyboard.defineStyle("default", A_ScriptDir . "\styles\default.css")
vk.setStyle("default")
vk.autocomplete.bkColor := vk.backgroundColor
vk.autocomplete.fontColor := "FFFFFF"
vk.autocomplete.fontName := "Segoe UI"
vk.autocomplete.fontSize := 14
vk.autocomplete.listbox.bkColor := vk.backgroundColor
vk.autocomplete.listbox.fontColor := "666666"
vk.autocomplete.listbox.fontName := "Segoe UI"
vk.autocomplete.listbox.fontSize := 11
vk.setHotkeys({}, 1, "Joy5")
vk.showHide()
vk.fitContent(16, 5, true)
vk.onSubmit(Func("vk_onSubmit"))
OnExit, handleExit
return

vk_onSubmit(this, _hLastFoundControl, _input) {
	ToolTip % _hLastFoundControl "," _input
	if (_hLastFoundControl)
		ControlSend,, % "{Text}" . _input, % "ahk_id " . _hLastFoundControl
	else SendInput % "{Text}" . _input
}

handleExit:
	vk.dispose()
ExitApp

!x::ExitApp
```

> you can find this sample script, commented, in the [examples folder](/examples/).
> see also: [Keyboard and joystick shortcuts](#keyboard-and-joystick-shortcuts) to start using the script!

***
## Namespace reservations

The library sets the following class variables:

- [``JSON``](https://github.com/cocobelgica/AutoHotkey-JSON) (by coco)
- ``eAutocomplete``
- ``Hotkey`` [``_HotkeyIt``, ``_Hotkey``, ``__Hotkey__``, ``_Hk``, ``_Context``, ``_JoyButtonKeypressHandler``, ``ObjBindTimedMethod``]
- ``Joystick``
- ``Keypad`` [``_Keypad``, ``_KeypadEvents``, ``_KeypadGraphicsMapping``, ``_KeypadAXObjectWrapper``]
- ``KeypadInterface``
- ``vKeyboard``

> you can find the tree structure of the library in the [lib folder](/lib).

The [``#Warn`` directive](https://www.autohotkey.com/docs/commands/_Warn.htm) can be used to show a warning for each assignment targeting a class variable.

***
## vKeyboard (the visual keyboard object)
Syntax description for creating a new object derived from ``vKeyboard``, using the [``new`` keyword](https://autohotkey.com/docs/Objects.htm#Custom_Objects):
```javascript
vk := new vKeyboard() ; create a new instance of the visual keyboard object and stores it in 'vk'
```

> The constructor throws an exception on failure.

***
## Object members
> note: the following list may not be exhaustive.

| Object member | description |
| :---: | :---: |
| ``vk.AXObject`` | The wrapper of the ActiveX object embedded into the visual keyboard window (for example, the root node of the HTML document can be retrieved using ``vk.AXObject.document``). |
| ``vk.autocomplete`` | The visual keyboard's own specific ``eAutocomplete`` (v1.2.30) interface. It differs from a standard ``eAutocomplete`` interface in that both its ``autoSuggest`` and ``onResize`` properties have been made **read-only** and in that it offers four additional properties (*i.e.* ``bkColor``, ``fontName``, ``fontSize`` and ``fontColor``) - through which one can [style the visual keyboard's text entry field](#styling-the-keyboard). Otherwise, see the [``eAutocomplete``'s readme](https://github.com/A-AhkUser/eAutocomplete#eautocomplete) for an overview of all available properties and methods for this member. |
| ``vk.hostWindow`` | An interface to the window which hosts the visual keyboard. It has the following relevant read-only property: `HWND`, which contains the visual keyboard GUI window's HWND - and besides having three transparent methods: `show()`, `hide()` and `isVisible()`. |

###

***
## Available properties
> note: the following list may not be exhaustive.

| property | description | default value
| :---: | :---: | :---: |
| ``vk.X``</br>[READ-ONLY] | Returns the position, along the x-axis (columns), of the key currently focused. | `1` |
| ``vk.Y``</br>[READ-ONLY] | Returns the position, along the y-axis (rows), of the key currently focused. | `1` |
| ``vk.columns``</br>[READ-ONLY] | Returns the number of columns in the mapping of the visual keyboard current layout. | *runtime/user-defined* |
| ``vk.rows``</br>[READ-ONLY] | Returns the number of rows in the mapping of the visual keyboard current layout. | *runtime/user-defined* |
| ``vk.hideOnSubmit`` | Set or get the boolean value which determine if the visual keyboard should be hidden each time the text entered is submitted. | `true` |
| ``vk.resetOnSubmit`` | Set or get the boolean value which determine if the entire text entry field of the visual keyboard should be cleared upon submission. | `true` |
| ``vk.transparency`` | Set or get the visual keyboard GUI window's degree of transparency. Could be any integer value between **10** and 255. | `255` |
| ``vk.alwaysOnTop`` | Set or get the boolean value which determine if the visual keyboard host window should stay on top of all other windows. | `true` |
| ``vk.style``</br>[READ-ONLY] | Returns the name of the css stylesheet used to graphically render the keyboard layout. Use the [setStyle method](#setstyle) to set the visual keyboard style. | "" |
| ``vk.layout``</br>[READ-ONLY] | Returns the name of the current keyboard layout. Use the [setLayout method](#setlayout) to set the visual keyboard layout. | *runtime/user-defined* |
| ``vk.layer``</br>[READ-ONLY] | Returns the index of the current keyboard layout's layer. Use the [setLayer method](#setlayer) to set the visual keyboard layer. | `1` |
| ``vk.layers``</br>[READ-ONLY] | Returns the total number of layers available for the current keyboard layout. | *runtime/user-defined* |
| ``vk.altIndex``</br>[READ-ONLY] | Returns the current [altIndex](#built-in-f-functions). | `1` |
| ``vk.altMode``</br>[READ-ONLY] | Returns `true` if the visual keyboard is currently in 'alt mode' (that is, displays [key variants](#built-in-f-functions) to select from) and `false` otherwise. | `false` |
| ``vk.fontSize`` | Set or get a positive integer between 8 and 112 defining the size (in px) of the keyboard's font. | `16` |
| ``vk.backgroundColor``</br>[READ-ONLY] | Returns the current background colour of the keypad. | `FFFFFF` |

###

***
## Available methods
> note: the following list may not be exhaustive.

- **defineLayout**
- **defineStyle**
- **setHotkeys**
- **setStyle**
- **setLayout**
- **setLayer**
- **showHide**
- **fitContent**
- **expand**
- **shrink**
- **redraw**
- **dispose**


***
### defineLayout

```AutoHotkey
vKeyboard.defineLayout(_name, _pathOrContent, _defaultObjectWrapper:="", _defaultCallback:="")
```

###### This base method allows to define a 'keymap' (keyboard layout mapping) for future calls of the [``setLayout`` instance method](#setlayout).

| parameter | description |
|:-|:-|
| ``_name`` [STRING] | The name identifying the keymap, which may consist of alphanumeric characters, underscore and non-ASCII characters. |
| ``_pathOrContent`` [STRING - *PATH/JSON-FORMATTED STRING*] | Can be either a [keyboard layout JSON representation](#layout-json-representations) or the full path of a file containing such JSON-formatted string. In the first case, you can use [FileRead](https://www.autohotkey.com/docs/commands/FileRead.htm) or a [continuation section](https://www.autohotkey.com/docs/Scripts.htm#continuation) to save a series of lines to a variable. Alternatively, you can run the [keymapMaker](/examples/keymapMaker/): by means of its GUI, you can the WYSIWYG-way create keyboard layouts, export and save them as Layout JSON representations, compatible with this interface method. |
| ``_defaultObjectWrapper`` [OBJECT] *OPTIONAL* | If specified, a [class](https://www.autohotkey.com/docs/Objects.htm#Custom_Classes) that wraps press handlers, used as target object for all keyboard keys whose [f-function](#f-functions) is not a 'floating' function defined in the script. If omitted, the script's own internal wrapper is used instead, allowing you to use the [built-in f-functions](#built-in-f-functions). |
| ``_defaultCallback`` [STRING] *OPTIONAL* | The **name** of a function that will be executed in place of the [built-in default callback](#the-built-in-default-callback) each time a key on the visual keyboard is pressed/clicked, assuming that a f-function has not been set for this key. If the function does not exist, the script searches for a matching method in [``_defaultObjectWrapper``]. To omit this parameter while specifying a ``_defaultObjectWrapper`` amounts to specify ``call``. |

*The method throws an exception upon failure (for instance, if the keyboard layout JSON representation is badly formatted).*

```AutoHotkey
; usage examples:
; 1
vKeyboard.defineLayout("english", A_ScriptDir . "\myLayouts\english.json")
; 2
vKeyboard.defineLayout("français", A_ScriptDir . "\myLayouts\français.json",, "myFunc")
; somewhere in your script:
myFunc(this, _keyDescriptor, _count) {
	; some stuff
}
; 3
vKeyboard.defineLayout("русский", A_ScriptDir . "\myLayouts\русский.json", myEventHandler, "defaultCb")
; somewhere in your script:
Class myEventHandler {
	defaultCb(_vKeyboardInst, _keyDescriptor, _count) {
		; some stuff
	}
	onStarPress(_vKeyboardInst, _keyDescriptor, _count) {
		; some stuff
	}
}
/* somewhere in your keyboard layout mapping:
	...
	{ ; key descriptor
		"caption": "★",
		"f": "onStarPress"
	}
	...
*/
```

> see also: [Layout JSON representations](#layout-json-representations).

***
### defineStyle

```AutoHotkey
vKeyboard.defineStyle(_name, _pathOrContent)
```

###### This base method allows to define a style for future calls of the [``setStyle`` instance method](#setstyle).

| parameter | description |
|:-|:-|
| ``_name`` [STRING] | The name identifying the style, which may consist of alphanumeric characters, underscore and non-ASCII characters. |
| ``_pathOrContent`` [STRING - *PATH/CSS-FORMATTED STRING*] | A CSS style sheet describing how the visual keyboard's layout should be rendered. Can be either a css style sheet string or the full path of a file containing such stylesheet. In the first case, you can use [FileRead](https://www.autohotkey.com/docs/commands/FileRead.htm) or a [continuation section](https://www.autohotkey.com/docs/Scripts.htm#continuation) to save a series of lines to a variable. |

```AutoHotkey
; usage examples:
vKeyboard.defineStyle("myCustomStyle", A_ScriptDir . "\myStyles\myCustomStyle.css")
cascadingStyleSheet =
(Join`r`n
body {
	background-color: #000000;
}
button.key {
	background-color: #111111;
	font-family: Segoe UI;
	color: #EA72C0;
}
button.key:focus {
	background-color: #333333;
	outline: none;
}
button.key:hover {
	background-color: #222222;
}
)
vKeyboard.defineStyle("myCustomStyle", cascadingStyleSheet)
```

> see also: [Styling the keyboard](#styling-the-keyboard).

***
### setHotkeys

```AutoHotkey
vk.setHotkeys(_obj, _joystickPort:=1, _joyModifier:="Joy5")
```

###### Set up all keyboard/joystick shortcuts for a given ``vKeyboard`` instance. Joystick hotkeys are set taking into account the value of ``_joystickPort``, which defaults to `1`.

| parameter | description |
|:-|:-|
| ``_obj`` [OBJECT] | An [object](https://www.autohotkey.com/docs/Objects.htm#Usage_Associative_Arrays) that observes the [tree structure](#tree) shown below. It will indicate to the script the value of each keyboard/joystick shortcuts which are to be used by the visual keyboard. If a given value is not passed to the caller, its default value is used instead (see [Keyboard and joystick shortcuts](#keyboard-and-joystick-shortcuts) to get an overview of all default values used by the script). Actually, branches, sub-branches and keys are all optional. Also, the keys for a branch or sub-branch may be in any order within that branch or sub-branch, as they are referenced by name. Note that you can find an example of such JSON description in the script directory: [/examples/test/settings.json](/examples/test/settings.json) - you can copy it and merely set the relevant values at your convenience whilst keeping it within the limitations imposed below on acceptable values. |
| ``_joystickPort`` [INTEGER] *OPTIONAL* | If the computer has more than one joystick and you want to use one beyond the first to control the visual keyboard, specify a positive integer between 2 and **8**. Specify ``0`` for ``_joystickPort`` to avoid setting up joystick hotkeys and polling, seeking for events, joystick axes. |
| ``_joyModifier`` [INTEGER] *OPTIONAL* | Any joystick button name **without** the joystick number prefix (*e.g.* `Joy1`, `Joy2`, ... and up to `Joy32` - at least if your joystick controller actually has 32 buttons). It will be used as 'modifier' - so that you would hold down it then press a second joystick button to trigger the joystick hotkey. It must be represented by a ``!`` (that is, an exclamation mark) right before the key name (e.g. !Joy3) in ``_obj``'s values. |

*The method throws an exception upon failure.*

The ``_obj`` parameter must observe the following tree structure:

<pre id="tree">
├── "autocomplete"
│   ├── "keyboard"
│   ├── ├──[AUTOCOMPLETE_HOTKEYS]
│   ├── "joystick"
│   ├── ├──[AUTOCOMPLETE_HOTKEYS]
├── "keypad"
│   ├── "keyboard"
│   ├── ├──[KEYPAD_HOTKEYS]
│   ├── "joystick"
│   ├── ├──[KEYPAD_HOTKEYS]
├── "window"
│   ├── "keyboard"
│   ├── ├──[WINDOW_HOTKEYS]
│   ├── "joystick"
│   ├── ├──[WINDOW_HOTKEYS]
</pre>

- where ``[AUTOCOMPLETE_HOTKEYS]``, ``[KEYPAD_HOTKEYS]`` and ``[WINDOW_HOTKEYS]`` stand respectively for the following objects:

``` AutoHotkey
{"listboxDismiss": [HOTKEY_NAME]
, "listboxSelectUp": [HOTKEY_NAME]
, "listboxSelectDown": [HOTKEY_NAME]
, "dataLookUp1": [HOTKEY_NAME]
, "dataLookUp2": [HOTKEY_NAME]
, "complete1": [HOTKEY_NAME]
, "complete2": [HOTKEY_NAME]} ; [AUTOCOMPLETE_HOTKEYS]
```

``` AutoHotkey
{"pressKey": [SINGLE_KEY_NAME]
, "altReset": [SINGLE_KEY_NAME]
, "sendBackSpace": [HOTKEY_NAME]
, "sendSpace": [HOTKEY_NAME]
, "startNewLine": [HOTKEY_NAME]
, "submit": [HOTKEY_NAME]
, "switchLayer": [HOTKEY_NAME]
, "decreaseFontSize": [HOTKEY_NAME]
, "increaseFontSize": [HOTKEY_NAME]
, "clearContent": [HOTKEY_NAME]} ; [KEYPAD_HOTKEYS]
```

``` AutoHotkey
{"showHide": [AHK_KEY_NAME]} ; [WINDOW_HOTKEYS]
```

- where ``[HOTKEY_NAME]`` can be any hotkey's activation key name supported by the [hotkey command](https://www.autohotkey.com/docs/commands/Hotkey.htm#Parameters) while also allowing, for joystick buttons, a 'modifier' to be specified. In this case, it must be represented by a `!` (that is, an exclamation mark) right before the key name (*e.g.* `!Joy3`) - so that you would hold down ``_joyModifier`` then press the second joystick button (here `Joy3`) to trigger the joystick hotkey.
- where ``[AHK_KEY_NAME]`` can be any hotkey's activation key name supported by the [hotkey command](https://www.autohotkey.com/docs/commands/Hotkey.htm#Parameters).
- where ``[SINGLE_KEY_NAME]`` must consist in a **single** [key](https://www.autohotkey.com/docs/KeyList.htm) - either it is a joystick button name or a non-modifier keyboard key (*e.g.* `a`, `F1`, `NumpadEnter`, `Insert`, `Tab` *etc.*).
- In any case, do **not** specify the joystick number prefix in front of the control name (*e.g.* `1Joy3`): use the second parameter instead to set the joystick number.

``` AutoHotkey
; usage examples:
vk.setHotkeys({}, 0) ; use default values
vk.setHotkeys({autocomplete:{keyboard:{"listboxSelectUp": "!Up", "listboxSelectUp": "!Down"}}}, 1)
vk.setHotkeys({window:{keyboard:{"showHide": "F11"}}}, 1)
obj :=
(LTrim Join C
{
	window: {
		keyboard: {
			"showHide": "F11" ; [AHK_KEY_NAME]
		}
	},
	keypad: {
		joystick: {
			pressKey: "Joy1", ; [SINGLE_KEY_NAME]
			sendBackSpace: "!Joy4" ; [HOTKEY_NAME]
		},
		keyboard: {
			pressKey: "NumpadEnter",
			sendBackSpace: "!Backspace"
		}
	}
}
)
vk.setHotkeys(obj, 2, "Joy2")
```

> see also: [Keyboard and joystick shortcuts](#keyboard-and-joystick-shortcuts).

***
### setStyle

```AutoHotkey
vk.setStyle(_style)
```

###### Set the visual appearance of the keyboard layout.

| parameter | description |
|:-|:-|
| ``_style`` [STRING] | Can be an empty string or the name of a css stylesheet that was previously defined as style using the [defineStyle](#definestyle) base method. If the value is an empty string all keypad's user-defined styles are removed. |

> The method throws an exception on failure.

***
### setLayout

```AutoHotkey
vk.setLayout(_layout, _layer:=1, _center:=false)
```

###### Set the visual keyboard's layout.

| parameter | description |
|:-|:-|
| ``_layout`` [STRING] | The value must be the name of a layout JSON representation that was previously defined using the [defineLayout](#definelayout) base method. |
| ``layer`` [INTEGER] | An integer indicating the index of the new keyboard layout's starting layer. |
| ``_center`` [BOOLEAN] | A boolean value which determines if the script has to center the visual keyboard window immediately after having set the new layout. |

> The method throws an exception on failure.

***
### setLayer

```AutoHotkey
vk.setLayer(_layer)
```

###### Set the visual keyboard layout's layer.

| parameter | description |
|:-|:-|
| ``_layer`` [INTEGER] | The index of the layer to navigate to. |

> return value: the method returns 0 upon failure and the index of the new visual keyboard layout's layer upon success.

***
### showHide

```AutoHotkey
vk.showHide()
```

###### Shows the visual keyboard if it is hidden - and vice versa.

***
### fitContent

```AutoHotkey
vk.fitContent(_size:="", _padding:=2, _center:=true)
```

###### Resize the visual keyboard so that it fits its content.

| parameter | description |
|:-|:-|
| ``_size`` [INTEGER] | The keypad's font size to be taken into account for the resizing operation. If omitted, defaults to [the current keypad's font size](#available-properties). |
| ``_padding`` [INTEGER] | The keypad's keys 'padding' value to be taken into account for the resizing operation. |
| ``_center`` [BOOLEAN] | A boolean value which determines if the script has to center the visual keyboard window after resizing, if it is visible. |

***
### expand

```AutoHotkey
vk.expand()
```

###### This method is a shorthand for `vk.fitcontent(vk.fontSize + 2)`

***
### shrink

```AutoHotkey
vk.shrink()
```

###### This method is a shorthand for  `vk.fitcontent(vk.fontSize - 2)`

***
### redraw

```AutoHotkey
vk.redraw()
```

###### Attempts to update the appearance of the keyboard layout graphics. This method solves painting artefacts that may occur when, for instance, you set the background color of the visual keyboard's text entry field using `vk.autocomplete.bkColor`.

***
### dispose

```AutoHotkey
vk.dispose()
```

###### Destroys the visual keyboard window. Releases all circular references by unregistering instance’s own hotkeys, event handlers and event hook functions (the autocomplete component hooks a few events instead of querying windows objects when needed). A script should call the ``dispose`` method, at the latest at the time the script exits, if it implements one or more ``__Delete`` meta-functions. On a side note, calling ``dispose`` ensures that words collected by the autocomplete component, if any, are stored into the appropriate database. Once the method has been called, the script is assumed not to query, interact with the instance thereafter.

###

***
## Event handling
The script is able to call a user-defined callback for the following events:

- `onKeyPress` (**not yet implemented**)
- `onSubmit`
- `onShowHide`

Note that the autocomplete ``vKeyboard``'s object member has also [its own event handling](https://github.com/A-AhkUser/eAutocomplete#event-handling) you can take advantage of.

##
#### onKeyPress
***
```AutoHotkey
vk.onKeyPress(Func("myKeyPressEventMonitor"))
```
***
##### description:
[**NOT YET IMPLEMENTED**] Executes a custom function each time a keyboard's key is pressed or clicked. It is executed before the key's own [f-function](#layout-json-representations) is actually called. The function can prevent the key's default behaviour by returning a non-zero integer.</br>
The function can optionally accept the following parameters:</br>
``preventDefault := myKeyPressEventMonitor(this, _x, _y, _count, _key)``

| parameters | description |
|:-|:-|
| ``_x`` | Represents the position, along the x-axis (columns), of the key being clicked or pressed. |
| ``_y`` | Represents the position, along the y-axis (rows), of the key being pressed or clicked. |
| ``_count`` | A non-zero integer which represents the number of clicks or presses that generated the event. Up to 3 consecutive presses/clicks are detected as such - while -1 stands for a long click/press. |
| ``_key`` | A reference to the [key descriptor](#the-semantics-of-keymaps---key-descriptors) of the key currently focused/hovered whose press/click triggered the event handler. |
##
#### onShowHide
***
```AutoHotkey
vk.onShowHide(Func("myShowHideEventMonitor"))
```
***
##### description:
Executes a user-defined function each time the keyboard is shown/hidden (*by means of the ``showHide`` method*).</br>
The function can optionally accept the following parameters:</br>
``myShowHideEventMonitor(this, _isVisible)``

| parameters | description |
|:-|:-|
| ``_isVisible`` | Contains `1` (`true`) if the keyboard is now visible or `0` (`false`) otherwise. |

```AutoHotkey
; usage example:
; ...
vk.onShowHide(Func("vk_onShowHide"))
return
; ...
vk_onShowHide(this, _isVisible) {
	ToolTip % _isVisible
}
```
##
#### onSubmit
***
```AutoHotkey
vk.onSubmit(Func("mySubmitEventMonitor"))
```
***
##### description:
Executes a user-defined function each time the text entered so far is submitted.</br>
The function can optionally accept the following parameters:</br>
``mySubmitEventMonitor(this, _hLastFoundControl, _input)``

| parameters | description |
|:-|:-|
| ``_hLastFoundControl`` | If any, the HWND of the control that had focus and whose focus has been stolen by the visual keyboard at the moment this latter was last shown. |
| ``_input`` | The content of the visual keyboard's text entry field upon submission. |

```AutoHotkey
; usage example:
; ...
vk.onSubmit(Func("vk_onSubmit"))
return
; ...
vk_onSubmit(this, _hLastFoundControl, _input) {
	if (_hLastFoundControl)
		ControlSend,, % "{Text}" . _input, % "ahk_id " . _hLastFoundControl
	else SendInput % "{Text}" . _input
}
```

***
## Customization

### Keyboard and joystick shortcuts

Hotkeys default to the following values:

| hotkey | description |
|:---|:---|
| `Left`-`Up`-`Right`-`Down` \ `JoyPOV` | Navigate through keyboard's keys. |
| `JoyX` \ `JoyY` | Move the visual keyboard window. |
| `Enter` \ `Joy3` | Press the keyboard key currently focused. Keys can alternatively be clicked. Long press (respectively long click) to display the [key's own variants](#built-in-f-functions), if any. [Multiple clicks and presses](#f-functions) can also be handled as such. |
| `Escape` \ `Joy1` | Reset both the visual keyboard's [alt mode](#built-in-f-functions) and [index](#built-in-f-functions). |
| `F2` \ `Joy5 & Joy3` | Switch the keyboard layer (from the greater stack order to the lowest one in the z-index axis). |
| `Shift + Enter` \ `Joy10` | Submit the text entered so far in the visual keyboard's text entry field (should call the [onSubmit callback](#event-handling), if any). |
| `F1` \ `Joy12` | Show/hide the visual keyboard (should call the [onShowHide callback](#event-handling), if any). |
| `NumpadSub` \ `Joy9` | Decrease the visual keyboard keys' font size. |
| `NumpadAdd` \ `Joy5 & Joy9` | Increase the visual keyboard keys' font size. |
| ~~`NumpadDown`-`NumpadUp`-`NumpadLeft`-`NumpadRight` \ `JoyZR`~~ | ~~[*text entry field*] Shift the caret/insert position.~~ |
| `Backspace` \ `Joy4` | [*text entry field*] Remove the last character starting from the left-hand side of the caret/insert current position. |
| `Space` \ `Joy4` | [*text entry field*] Insert a space character. |
| `NumpadEnter` \ `Joy5 & Joy4` | [*text entry field*] Insert a line break. |
| `Shift + Delete` \ `Joy5 & Joy1` | [*text entry field*] Clear the entire visual keyboard's text entry field. |
| `Escape` \ `Joy1` | [*autocomplete mode*] Dismiss the list of autocomplete suggestions. |
| `PageUp` \ `Joy7` | [*autocomplete mode*] Select the previous item from the list of available suggestions. |
| `PageDown` \ `Joy8` | [*autocomplete mode*] Select the next item from the list of available suggestions. |
| `Alt + Left` \ `Joy5 & Joy7` | [*autocomplete mode*] Hold the first key and press the second one to look up the selected suggestion’s first associated data, if any. |
| `Alt + Right` \ `Joy5 & Joy8` | [*autocomplete mode*] Hold the first key and press the second one to look up the selected suggestion’s second associated data, if any. |
| `Tab` \ `Joy6` | [*autocomplete mode*] Complete a pending word with the currently selected suggestion. Long press to replace instead the current partial string by the selected suggestion’s first associated data. |
| `Shift + Tab` \ `Joy5 & Joy6` | [*autocomplete mode*] Long press to replace the current partial string by the selected suggestion’s second associated data. |

> The vast majority of these hotkeys are customizable. See also: [setHotkeys](#sethotkeys).

***
### Autocomplete lists

Use [``eAutocomplete.setSourceFromFile`` or ``eAutocomplete.setSourceFromVar``](https://github.com/A-AhkUser/eAutocomplete#available-methods) to create a new autocomplete dictionary, respectively from a file’s content or from an input string. Thus, you can thereafter use at any time the setter/getter ``vk.autocomplete.source`` to set the autocomplete list to use for the visual keyboard.

> see also: [eAutocomplete - Custom autocomplete lists](https://github.com/A-AhkUser/eAutocomplete#custom-autocomplete-lists).

***
### Styling the keyboard

So far, you can use the following setters/getters to style - using 6-digit RGB color values - the autocomplete control:

- ``vk.autocomplete.bkColor``
- ``vk.autocomplete.fontName``
- ``vk.autocomplete.fontSize``
- ``vk.autocomplete.fontColor``
- [``vk.autocomplete.listbox.bkColor``](https://github.com/A-AhkUser/eAutocomplete#options)
- [``vk.autocomplete.listbox.fontName``](https://github.com/A-AhkUser/eAutocomplete#options)
- [``vk.autocomplete.listbox.fontSize``](https://github.com/A-AhkUser/eAutocomplete#options)
- [``vk.autocomplete.listbox.fontColor``](https://github.com/A-AhkUser/eAutocomplete#options)

```AutoHotKey
; usage examples:
vk := new vKeyboard()
; ...
vk.autocomplete.bkColor := "000000" ; black
vk.autocomplete.fontColor := "FFFFFF" ; white
vk.autocomplete.listbox.bkColor := "000000"
vk.autocomplete.listbox.fontColor := "FFFFFF"
```

Besides, the script offers a basic css interface that allows you to indicate how the visual keyboard's keys should be rendered.
You can use both the ``button.key`` and ``button.variant`` [css selectors](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Selectors) in your custom css stylesheet - as an example:

``` css
body {
	background-color: #000000;
}
/* the 'key' class identifies all keys but
the 'variants' ones (see comment below) */
button.key {
	background-color: #111111;
	font-family: Segoe UI;
	color: #EA72C0;
}
button.key:focus {
	background-color: #333333;
	outline: none;
}
button.key:hover {
	background-color: #222222;
}
/* the 'variant' class identifies all keys displayed when
the visual keyboard enters alt mode and suggests key
variants (e.g. letters with diacritics) to select from */
button.variant {
	color: #EA72C0;
}
button.variant:focus {
	background-color: #555555;
	outline: none;
}
button.variant:hover {
	background-color: #444444;
}
```
You must call the [defineStyle](#definestyle) base method to define a style. Thus, you can thereafter use the [``setStyle`` method](#setstyle) to set at any time the style used to render the visual keyboard graphics.

***
### Layout JSON representations

> note: The following provides extensive details on the implementation. You can also run the [keymapMaker](/examples/keymapMaker/) if you don't need to know the ins and outs of this layout stuff: by means of this script, you can the WYSIWYG-way create keyboard layouts, export and save them as Layout JSON representations.

The ``vKeyboard`` interface uses JSON-formatted object descriptions in order to represent keyboard layouts.
These descriptions help the script determine the structure (layers, rows, columns *etc.*) but also the semantic content (key captions, key's associated callback function *etc.*) of the keyboard layout.

#### The structure of keymaps

We can model, map a keyboard layout as a tri-dimensional array. Actually, it can be seen as one or more layers (z-axis), only one of them being visible at a given time - in that way:
- A layer can be described as a two-dimensional array: an array of rows (y-axis).
- A row can be itself described as an array of keys (x-axis).
- A key can be a descriptor; it can be either a string (for simple keys) or an object (for semantically richer keys).

*The following example describes a bare keyboard layout (one layer, one row, one key):*
```AutoHotkey
[
    [
        [
            null
        ]
    ]
]
```

*The following layout object representation describes a keyboard layout with just one layer and one row (consisting itself in three keys: two complex ones and a simple one):*
```AutoHotkey
[ ; keymap
	[ ; first layer (3rd dimension -z)
		[ ; first row (2nd dimension -y)
			{ ; first key (1st dimension -x)
				"caption": "★",
				"f": "myCustomFunc",
				"myCustomKey": "myCustomValue"
			},
			{ ; second key
				"caption": "a",
				"f": "keyWithVariantsProc",
				"params": [
					"å","â","ä","ā","à","ã","æ","à"
				]
			},
			"z" ; third key
		]
	]
]
```

> You can find some basic examples of such keyboard layouts representations in the keymaps directory ([/examples/test/keymaps](/examples/test/keymaps)).

#### The semantics of keymaps - key descriptors

Key descriptors are the constitutive elements of a keyboard layout mapping (see above). By default, if the descriptor is not an object, press or click the key will simply send its caption right on the keyboard's text entry field each time it is pressed or clicked. Otherwise, if a given descriptor is an object, the following properties have a special meaning for the script and are processed accordingly by it:

| property | description |
|:-|:-|
| `caption` | [STRING] specifies the symbol displayed on the visual keyboard's key. |
| `f` | *OPTIONAL* [STRING] specifies a function - the ['**f**-function'](#f-functions) - to execute each time the key is pressed. A reference to the key descriptor itself will be passed to the caller of the key's associated f-function each time it is executed. If a given key descriptor lacks its ``f`` property, the [built-it default callback](#the-built-in-default-callback) will be used as associated f-function for this key. |
| `style` | *OPTIONAL* [STRING] (**not yet implemented**) specifies the CSS class name whose rules describe how the visual keyboard's key should be rendered. Both ``variant`` and ``key`` CSS class names are used internally and, for this very reason, must **not** be used as custom class names. |
| `params` | *OPTIONAL* Reserved by the script. Relevant when used with one of the [built-in f-functions](#built-in-f-functions). |
| `altCaption` | *OPTIONAL* Reserved by the script. Might be implemented and, thus, have special meaning later. |
| `accessKey` | *OPTIONAL* Reserved by the script. Might be implemented and, thus, have special meaning later. |
| `[CUSTOM_NAME]` | *OPTIONAL* [STRING/OBJECT/ARRAY/STRING/NUMBER/true/false/null] You can add custom keys in the key descriptor to take advantage of their respective values from within the key's own f-function callback each time the key is pressed or clicked. The `[CUSTOM_NAME]` key's value can be any of the value supported by the JSON data-interchange format. |

> note: in cases where your key descriptor lacks all its optional keys, you can merely specify the letter which is intended to be displayed on the visual keyboard as a shorthand for the key descriptor object:`{"caption": "a"}` - which does works, but amounts to specify `"a"`.

#### The built-in default callback

If a [key descriptor](#the-semantics-of-keymaps---key-descriptors) is not an object, press or click the key will simply send its caption right on the keyboard's text entry field each time it is pressed or clicked: the built-it default callback and its default procedure will be used as associated f-function for the keyboard's key. You can modify this behaviour by specifying a custom default callback for a specific keymap when calling [defineLayout](#definelayout).

#### F-functions

```AutoHotkey
example:
/*
assuming at least one of the key in your keyboard layout consists in the following descriptor...
{ ; key descriptor
	"caption": "★",
	"f": "myCustomFunc",
	"myCustomKey": "MsgBox!"
}
*/
; somewhere in your script:
myCustomFunc(this, _keyDescriptor, _count) {
	_msgBoxOption := this.alwaysOnTop ? 4096 : 0
	GUI % this.hostWindow.HWND . ":+OwnDialogs"
	MsgBox, % _msgBoxOption
			, % _keyDescriptor.myCustomKey
			, % "You pressed on the " . _keyDescriptor.caption . " key "
				. ((_count = -1) ? "a long time" : _count . "time(s)") . "!"
; return 0
}
```
***
##### description:
The ``f`` key in the [key descriptor](#the-semantics-of-keymaps---key-descriptors) allows you to specify a function to execute each time the keyboard's key is pressed or clicked. In case it is a non-zero integer, the return value of the callback will be used to set the [altIndex](#setaltindexproc) accordingly.</br>
The function can optionally accept the following parameters (where `this` refers to the ``vKeyboard`` instance, not the key descriptor object):</br>
``altIndex := myCustomFunc(this, _keyDescriptor, _count)``

| parameters | description |
|:-|:-|
| ``_keyDescriptor`` | Contains a reference to the descriptor of the key whose click/press triggered the f-function. |
| ``_count`` | A non-zero integer which represents the number of clicks or presses that triggered the callback. Up to 3 consecutive presses/clicks are detected as such - while -1 stands for a long click/press. |

#### Built-in 'f-functions'

Unless you specified a custom default object wrapper when calling [defineLayout](#definelayout), you don't necessary have to define in your script functions in order to handle key presses and clicks on the visual keyboard. Instead, you can specify one of the built-in f-functions and the ``params`` key in your [key descriptor](#the-semantics-of-keymaps---key-descriptors).
> note: the following list may not be exhaustive.

##### keyWithVariantsProc

``` AutoHotkey
{
	"caption": "i",
	"f": "keyWithVariantsProc",
	"params": [
		"ī","î","ï","ì","į","í"
	]
} ; each time the keyboard's key is long pressed/clicked, the visual keyboard
; enters alt mode and all params will be suggested as variants to select from
```

***

<table align="center">
	<tr>
	<td><img src="https://raw.githubusercontent.com/A-AhkUser/resources/master/keyWithVariantsProc.png" /></td>
	</tr>
</table>

***

##### setAltIndexProc

``` AutoHotkey
{
	"caption": "^",
	"f": "setAltIndexProc",
	"params": [
		2
	]
} ; 2 will set alt index to 2 so that if you click this key on the
; keyboard and then click on a key with variants (see above) the second
; variant will be sent
```

##### altEntryModeProc

``` AutoHotkey
{
	"caption": "abc",
	"f": "altEntryModeProc",
	"params": [
		"a",
		"b",
		"c"
	]
} ; the index of the letter that will be sent depends on the amount
; of clicks/presses
```

##### setCaretPosProc

``` AutoHotkey
{
	"caption": "◀",
	"f": "setCaretPosProc",
	"params": [
		-1
	]
} ; -1 shifts from right to left the caret/insert position; conversely, 1
; would shift from left to right the caret/insert position
```

##### toLayerProc

``` AutoHotkey
{
	"caption": "↑",
	"f": "toLayerProc",
	"params": [
		2
	]
} ; 2 is the index of layer to navigate to
```

##### submitProc

##### switchLayerProc

##### sendBackSpaceProc

##### sendSpaceProc

##### startNewLineProc

##### clearContentProc


### Licence

[Unlicence](LICENSE)
