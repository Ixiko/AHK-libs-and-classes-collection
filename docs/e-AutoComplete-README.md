# *eAutocomplete*
###### AutoHotkey v1.29.00+
***

#### Download the [latest release](https://github.com/A-AhkUser/eAutocomplete/releases)
> notes:
> - This readme provides an overview of the development version and, as such, may not necessarily reflect your current version. Consider checking out the html file (``eAutocomplete.html``) bundled in the release for an overview of the programmable interface.
> - Unlike the latest release, the master branch is NOT considered as fully tested on each commit.

The class provides a programmable interface allowing to easily integrate a custom word autocomplete function in a given script or project. Any Edit/RICHEDIT50W control should be able to be wrapped into an eAutocomplete object. Practically, it enables users to quickly find, get info tips and select from a dynamic pre-populated list of data (*e.g.* complete strings, replacement strings) as he types, leveraging typing, definition lookups, searching, translation, filtering *etc.*

### Thanks to:

- **AlphaBravo**, **jeeswg** and **just me**
- **brutus_skywalker** for his valuable suggestions on how to make more ergonomic and user-friendly the common features provided by the script via the use of keyboard shortcuts.
- **G33kDude (GeekDude)** and **ManiacDC** whose respective works - respectively [CQT.AutoComplete.ahk](https://github.com/G33kDude/CodeQuickTester/blob/master/lib/CQT.AutoComplete.ahk) and [TypingAid](https://github.com/ManiacDC/TypingAid/) - served as models for this one.
- **and to everyone I might have forgotten**

## Table of Contents

<ul>
  <li><a href="#description-commands">Description, commands</a></li>
  <li>How to use
    <ul>
    <li><a href="#how-to">Through scripting</a></li>
    <li><a href="#sample-example">Sample example</a></li>
    </ul>
  </li>
</ul>
<ul>
  <li><a href="#create-base-method">Create base method</a></li>
  <li><a href="#attach-base-method">Attach base method</a></li>
  <li><a href="#options">Options</a></li>
  <li><a href="#custom-databases">Custom databases</a></li>
  <li><a href="#available-methods">Available methods</a></li>
  <li><a href="#dispose-method">Dispose method</a></li>
  <li><a href="#event-handling">Event handling</a></li>
</ul>

## Description, commands

***

<table align="center">
	<tr>
		<td><img src="https://raw.githubusercontent.com/A-AhkUser/AHK-forums/master/eAutocomplete/eAutocomplete_cb.png" /></td>
		<td><img src="https://raw.githubusercontent.com/A-AhkUser/AHK-forums/master/eAutocomplete/eAutocomplete2.gif" /></td>
	</tr>
</table>

***

Enables users, as typing in an Edit/RICHEDIT50W control, to quickly find and select from a dynamic pre-populated list of suggestions and, by this means, to expand/replace partially entered strings into/by complete strings. When a user starts to type in the edit control and a brief rest (225ms) occured since the last keystroke, the script starts searching for entries that match and should display complete strings to choose from, based both on earlier typed letters and the content of a [custom list](#custom-databases). If the host edit control is a single-line edit control, the list of choices is displayed beneath the control, in the manner of a combobox list (and, in this case, items can be clicked).

* Press the `Tab` key to complete a pending word with the selected suggestion (the top most suggestion is selected by default).
* Use both the `Down` and `Up` arrow keys to select from the list all other available suggestions. Hitting `Up` while the first item is selected will bring you to the last one while hitting `Down` on the last item will bring you to the first one.
* Long press `Tab`/`Shift+Tab` to replace the current partial string by respectively the first/second of the selected [suggestion's own replacement strings](#custom-databases) (or, alternatively, by a [dynamic string](#onreplacement-callback)).
* The `Enter` key is functionally equivalent to the `Tab` one (including in the combination `Shift+Tab`) except that it also moves the caret to the next line at the same time.
* The drop-down list can be closed by pressing the `Esc` key.
* Press and hold the `Right`/`Shift+Right` hotkeys to look up respectively the first/second of the selected [suggestion's associated data](#custom-databases) (or, alternatively, [dynamic data](#onsuggestionlookup-callback)). When applicable, data appear in a tooltip, near the selected suggestion.
* If `autoSuggest` is disabled, `Down` displays the drop-down list, assuming one or more suggestions are available (see also: [options](https://github.com/A-AhkUser/eAutocomplete/blob/master/README.md#options)).


By default, an occurrence of the `regExSymbol` - by default: the asterisk - in the middle of a string will be interpreted not literally but as a pattern, matching zero or more occurrences of any non-delimiter characters (*e.g.* ``a*h`` matches ``autohotkey``).
An instance can optionally learn words at their first onset (or simply collect them for use in a single session) by setting the value of both the `learnWords` and `collectWords` options.
Specify `.` (that is, a dot) as one of the customizable `endkeys` and disable the `expandWithSpace` option to allow subsequence completion (*e.g.* method names, url and email adress components *etc.*).

## How to
***

#### Through scripting

*An instance of `eAutocomplete` will be from now on referred to as `eA`.*

- Download the [latest release](https://github.com/A-AhkUser/eAutocomplete/releases) and extract the content of the zip file to a location of your choice, for example into your project's folder hierarchy.
- Load the library (`\eAutocomplete.ahk`) by means of the [#Include directive](https://www.autohotkey.com/docs/commands/_Include.htm).
- You can either [create](https://github.com/A-AhkUser/eAutocomplete/blob/master/README.md#create-method) an `eAutocomplete` control (that is, add a custom edit control and its wrapper to an existing ahk GUI window) or endow with word completion feature an existing edit control (*e.g* *Notepad*'s one) or an existing rich edit control (*e.g* *Wordpad*'s one) by means of the [attach method](https://github.com/A-AhkUser/eAutocomplete/blob/master/README.md#attach-method) - both methods returning a new instance of `eAutocomplete`.

#### Sample example

```Autohotkey
#NoEnv
#Warn

#Include %A_ScriptDir%\eAutocomplete.ahk

list =
(
voiture	car	автомобиль
jour	day	день
)
/* 
Autocompletion data are assumed to be described in a linefeed-separated list of a TSV-formatted lines.
A line can describe up to three items, in a tabular structure:
- the first tab-separated item represents the string value which is intended to be displayed in the drop-down list, as an actual suggestion.
- the other two items represent potential replacement strings - aside from being able to be displayed as info tips.
*/
eAutocomplete.setSourceFromVar("mySource", list)
; Creates a new autocomplete dictionary from an input string, storing it directly in the base object.

GUI, +hwndGUIID ; +hwndGUIID stores the window handle (HWND) of the GUI in 'GUIID'
A := eAutocomplete.create(GUIID, "w300 h200 +Resize", {source: "mySource"})
GUI, Show, w500 h500, eAutocomplete sample example
OnExit, handleExit
return

handleExit:
	A.dispose()
	; A script should call the `dispose` method, at the latest at the time the script exits.
ExitApp
```

## Create base method
***

```Python
eA := eAutocomplete.create(_GUIID, _editOptions:="", _options:="")
```
***
*The `create` method throws an exception upon failure (such as if the host window does not exist).*

| parameter | description |
|:-|:-|
| ``_GUIID`` [HWND] | The host [window's HWND](https://www.autohotkey.com/docs/misc/WinTitle.htm#ahk_id). |
| ``_editOptions`` *OPTIONAL* [STRING] | The [edit control's options](https://www.autohotkey.com/docs/commands/GuiControls.htm#Edit_Options). The `+Resize` option may be listed in ``options`` to allow the user to resize both the height and width of the edit control. |
| ``_options`` *OPTIONAL* [OBJECT] | An [object](https://www.autohotkey.com/docs/Objects.htm#Usage_Associative_Arrays). If applicable, the [following keys](https://github.com/A-AhkUser/eAutocomplete/blob/master/README.md#options) are processed. |

## Attach base method
***

```Python
eA := eAutocomplete.attach(_hHostControl, _options:="")
```
***
*The `attach` method throws an exception upon failure (such as if the host control is not a representative of the class `Edit/RICHEDIT50W`).*

| parameter | description |
|:-|:-|
| ``_hHostControl`` [HWND] | The host [control's HWND](https://www.autohotkey.com/docs/commands/ControlGet.htm#Hwnd). |
| ``_options`` *OPTIONAL* [OBJECT] | An [object](https://www.autohotkey.com/docs/Objects.htm#Usage_Associative_Arrays). If applicable, the [following keys](https://github.com/A-AhkUser/eAutocomplete/blob/master/README.md#options) are processed. |


### Options
***

###### All keys may at any time be modified after [the instance is created](#create-base-method) by setting the value of the respective [property](https://www.autohotkey.com/docs/Objects.htm#Usage_Objects). On a side note, the runtime readonly properties `eA.HWND`/`eA.AHKID` and `eA.listbox.HWND/eA.listbox.AHKID` contain respectively the host control and the drop-down list control's HWND/AHKID.

| key (property) | description | default value |
| :---: | :- | :---: |
| ``autoSuggest`` | If set to `true` the autocompletion automatically displays a drop-down list beneath the current partial string as soon as suggestions are available. Otherwise, if set to `false`, the `Down` key can display the drop-down list, assuming one or more suggestions are available. | `true` |
| ``collectAt`` | Specify how many times a 'word' absent from the database should be typed before being actually collected by the instance. Instance's concept of 'word' is affected by both the `endKeys` and the `minWordLength` options. Once collected, words are valid during a single session (see also: `learnWords`). | `4` |
| ``collectWords`` | Specify whether or not an instance should collect 'words' at their `collectAt`-nth onset. Once collected, words are valid during a single session (see also: `learnWords`). | `true` |
| ``disabled`` | Determine whether or not the word completion feature should start off in an initially-disabled state. | `false` |
| ``endKeys`` | A list of zero or more characters, considered as not being part of a 'word', that is, all characters which terminate a word and start a new word at the same time. Its value affects the behaviour of the `minWordLength`, the `suggestAt` and the `collectWords` options. In particular, any trailing end keys is removed from a string before being collected and, as the case may be, learned. Space characters - space, tab, and newlines - are always considered as end keys. | ` \/\|?!,;.:(){}[]'""<>@= ` |
| ``expandWithSpace`` | If set to `true`, the script automatically expands the complete string with a space upon text expansion/replacement. | `true` |
| ``learnWords`` | If the value evaluates to `true`, collected words will be stored into the instance's current database (note: **if the [source](#custom-databases) is a file, its content will be overwritten, either at the time the source is replaced by a new one by setting the eponymous property or at the time the `dispose` method is called**). | `false` |
| ``matchModeRegEx`` | If set to `true`, an occurrence of the `regExSymbol` (see below) character in the middle of a string will be interpreted not literally but as part of a regular expression. | `true` |
| ``minWordLength`` | Set the minimum number of characters a word must contain to be actually seen as a 'word'. Its value affects the `collectWords` option. | `4` |
| ``regExSymbol`` | The character which is intended to be interpreted - assuming `matchModeRegEx` is set to `true` - as a pattern, matching zero or more occurrences of any non-delimiter character (*e.g.* **a**\***h** matches **a**uto**h**otkey). The value can be any non-space character not listed in the `endKeys` option. | `*` |
| ``source`` | Specifies the [autocomplete list](#custom-databases) to use. The value must be the name of a source that was previously defined using either the [``setSourceFromVar`` or the ``setSourceFromFile`` base method](#available-methods). Specify an empty string and enable the `learnWords` option to start building a new wordlist from the scratch. | `""` |
| ``suggestAt`` | Set the minimum number of characters a user must type before a search is performed. Zero is useful for local data with just a few items, but a higher value should be used when a single character search could match a few thousand items. | `2` |
|  |  |  |
| ``onCompletion`` | Associate a function with the `completion` event. This can be used, for example, to an launch a search engine when the user has selected an item. See also: [Event handling](https://github.com/A-AhkUser/eAutocomplete/blob/master/README.md#event-handling). | `""` |
| ``onReplacement`` | Associate a function with the `replacement` event. This can be used to allow dynamic replacements, such as when replacement strings come from a translation API, as an example. See also: [Event handling](https://github.com/A-AhkUser/eAutocomplete/blob/master/README.md#event-handling). | `""` |
| ``onResize`` | Associate a function with the little UI handle which allows resizing by the user and with which is endowed an edit control when it has been created using the `create` method and have `+Resize` listed in `editOptions`. It is launched automatically whenever the user resizes the edit control by its means. See also: [Event handling](https://github.com/A-AhkUser/eAutocomplete/blob/master/README.md#event-handling). | `""` |
| ``onSuggestionLookUp`` | Associate a function with the `suggestionLookUp` event. This can be used to allow dynamic description lookups such as when description strings come from a dictionary API, as an example. See also: [Event handling](https://github.com/A-AhkUser/eAutocomplete/blob/master/README.md#event-handling). | `""` |
|  |  |  |
| ``listbox.bkColor`` | Sets the background color of the drop-down list by specifying one of the 16 primary [HTML color names](https://www.autohotkey.com/docs/commands/Progress.htm#colors) or a 6-digit RGB color value. | `FFFFFF` |
| ``listbox.fontColor`` | Sets the font color for the drop-down list by specifying one of the 16 primary [HTML color names](https://www.autohotkey.com/docs/commands/Progress.htm#colors) or a 6-digit RGB color value. | `000000` |
| ``listbox.fontName`` | Sets the font typeface for the drop-down list. | `Segoe UI` |
| ``listbox.fontSize`` | Sets the font size for the drop-down list. | `13` |
| ``listbox.maxSuggestions`` | The maximum number of suggestions to display in the drop-down list, without having to scrolling, if necesary. | `7` |
| ``listbox.tabStops`` | [**combobox only**] Specify an integer, multiple of eight, to set tab stops. Tab stops can be used in a list box to align columns of information. Tab stops are expressed as dialog units. On the average, each character is about four horizontal dialog units in width. `eAutocomplete` uses by deafult a value of 512 (*sic*) to hide replacement/description strings used for the application's internal processing. Actually, it is possible to hide columns of text from the user by specifying tab stops beyond the right side of the list box. You can however decide to make replacement/description strings visually available to user and formatted into columns. | `512` |
| ``listbox.transparency`` | Specify a number between 0 and 255 to indicate the drop-down list's degree of transparency. | `235` |
|  |  |  |
| ``useRTL`` | The language is intended to be displayed in right-to-left (RTL) mode as with Arabic or Hebrew. **(not yet implemented)** | `false` |

### Custom databases
***

#### Autocompletion data are assumed to be described in a linefeed-separated list of a TSV-formatted lines. A line can describe up to three items, in a tabular structure:
```
лето		summer		прекрасное лето - great summer`r`nпроводить лето - to summer
		this is a comment
 this is a comment
```
#### In particular, in this case:
- the first tab-separated item represents the string value which is intended to be displayed in the drop-down list, as an actual suggestion.
- the other two items represent potential replacement strings - aside from being able to be displayed as info tips.

Both the second and the third items may be omitted (that is, a line may consist in a single field, whether it is a word or a group of word) - while specifying an empty string in between two tab-separated values (that is, two consecutive tab characters) allows to omit the second item while being able to use the third one as third. Description/replacement strings can be multiline text strings - however, in this case, both the newline (linefeed/LF) and the carriage return (CR) characters must be [escaped](https://www.autohotkey.com/docs/commands/_EscapeChar.htm). Also, each line may be commented out by prefixing it by one or more space (or tab) characters.
</br>

*note: A linefeed-separated list of a TSV-formatted lines can be built in particular from your google drive or you office suite - from a spreadsheet by saving it as... `.csv` (and specifying, if need be, a tabulation as field separator)*.

## Available methods
***

* **setSourceFromVar**
* **setSourceFromFile**
* **setOptions**

*All methods throw an exception upon failure*

***
```Python
eAutocomplete.setSourceFromVar(_sourceName, _list:="")
```
***

###### Creates a new autocomplete dictionary from an input string, storing it directly in the base object.

| parameter | description |
|:-|:-|
| ``_source`` | The name of the source, which may consist of alphanumeric characters, underscore and non-ASCII characters. |
| ``_list`` [OPTIONAL] | The list as string of characters. |

***
```Python
eAutocomplete.setSourceFromFile(_sourceName, _fileFullPath)
```
***

###### Creates a new autocomplete dictionary from a file's content, storing it directly in the base object.

| parameter | description |
|:-|:-|
| ``_source`` | The name of the source, which may consist of alphanumeric characters, underscore and non-ASCII characters. |
| ``_fileFullPath`` | The absolute path of the file to read (note: **its content will be overwritten and replaced by a sorted list of suggestion items, either at the time the source is replaced by a new one by setting the eponymous property or at the time the `dispose` method is called**). |

***
```Python
eA.setOptions(_options)
eA.listbox.setOptions(_options)
```
***

###### Sets one or more options of a given eAutocomplete instance.

| parameter | description |
|:-|:-|
| ``_options`` [OBJECT] | An [object](https://www.autohotkey.com/docs/Objects.htm#Usage_Associative_Arrays). If applicable, the [following keys](https://github.com/A-AhkUser/eAutocomplete/blob/master/README.md#options) are processed. |

## Dispose method
***

```AutoHotkey
eA.dispose()
```
***

Releases all circular references by unregistering instance's own hotkeys and event handlers. It also removes instance's own event hook functions (the class hook a few events instead of querying windows objects when needed). A script should call the `dispose` method, at the latest at the time the script exits. Moreover, calling `dispose` ensures that collected words, if any, are stored into the appropriate database, as the case may be. Once the method has been called, any further call has no effect.

## Event handling
***

The script is able to call a user-defined callback for the following events:

- `onCompletion`
- `onSuggestionLookUp`
- `onReplacement`
- `onSize`

The value can be either the name of a function, a [function reference](https://www.autohotkey.com/docs/commands/Func.htm) or a [boundFunc object](https://www.autohotkey.com/docs/objects/Functor.htm#BoundFunc). In the latter case, stucked bound references, if any, are freed at the time the `dispose` instance's own method is called.


###### onCompletion callback

***
```Python
eA.onCompletion := Func("mycompletionEventMonitor")
```
***

Executes a custom function whenever the user has performed a completion or a replacement by pressing/long pressing either the `Tab` or the `Enter` key.

- The function can optionally accept the following parameters:
``mycompletionEventMonitor(this, _completeString, _isReplacement)``

| parameter | description |
| :---: | :---: |
| ``_completeString`` | Contains the text of the complete string. |
| ``_isReplacement`` | A boolean value which determines whether or not a remplacement has been performed beforehand. |

###### onSuggestionLookup callback

***
```Python
eA.onSuggestionLookup := Func("mySuggestionLookupEventMonitor")
```
***

Associate a function with the `suggestionLookUp` event. This would cause the function to be launched automatically whenever the user attempts to query an info tip from the selected suggestion by pressing and holding either the `Right` key (querying the first suggestion's associated *datum*) or the `Shift+Right` hotkey (querying the second suggestion's associated *datum*). The return value of the callback will be used as the actual text displayed in the tooltip. This can be used to allow dynamic description lookups such as when description strings come from a dictionary API, as an example.

- The function can optionally accept the following parameters:
``infoTipText := mySuggestionLookupEventMonitor(_suggestionText, _tabIndex)``

| parameter | description |
| :---: | :---: |
| ``_suggestionText`` | The text of the selected suggestion, as visible in the drop-down list. |
| ``_tabIndex`` | If a variable is specified, it is assigned a number indicating the index of the suggestion's associated *datum*. |

###### onReplacement callback

***
```Python
eA.onReplacement := Func("myReplacementEventMonitor")
```
***

Associate a function with the `replacement` event. This would cause the function to be launched automatically whenever the user is about to perform a replacement by long pressing either the `Tab`/`Enter` key (first suggestion's associated replacement string) or the `Shift+Tab`/`Shift+Enter` hotkey (second suggestion's associated replacement string). The event fires before the replacement string has been actually sent to the host control - the return value of the function being actually used as the actual replacement string. This can be used to allow dynamic replacements, such as when replacement strings come from a translation API, as an example.

- The function can optionally accept the following parameters:
``replacementText := myReplacementEventMonitor(_suggestionText, _tabIndex)``

| parameter | description |
| :---: | :---: |
| ``_suggestionText`` | The text of the selected suggestion, as visible in the drop-down list. |
| ``_tabIndex`` | If a variable is specified, it is assigned a number indicating the index of the suggestion's associated replacement string. |

###### onSize callback

***
```Python
eA.onSize := Func("mySizeEventMonitor")
```
***

Associate a function with the little UI handle which allows resizing by the user and with which is endowed an edit control when it has been created using the `create` method and had `+Resize` listed in `editOptions`. The function is executed automatically whenever the user resizes the edit control by its means. The function can prevent resizing by returning a non-zero integer.

- The function can optionally accept the following parameters:
``preventResizing := mySizeEventMonitor(_parent, this, _w, _h, _mousex, _mousey)``

| parameter | description |
| :---: | :---: |
| ``_parent`` | The name, number or HWND of the GUI itself. |
| ``_w`` | The current edit control's width. |
| ``_h`` | The current edit control's height. |
| ``_mousex`` | The current position (abscissa) of the mouse cursor (coordinate is relative to the active window's client area). |
| ``_mousey`` | The current position (ordinate) of the mouse cursor (coordinate is relative to the active window's client area). |

### Licence

[Unlicence](LICENSE)
