# *eAutocomplete*
###### AutoHotkey v1.1.32.00+
***

The script aims to provide a programmable interface, allowing to relatively simply integrate a custom word autocomplete function in a given script or project. Any `Edit`/`RICHEDIT50W` control should be able to be wrapped into an `eAutocomplete` object. Practically, the script enables you, as you type, to quickly find and select from a dynamic set of data (*i.e.* complete strings and replacement strings) and get suggestion-based info tips - leveraging this way typing, definition lookups, searching, translation, filtering *etc.*

This readme provides an overview of the development version and, as such, may not necessarily present your current version. Consider checking out the html file (eAutocomplete.html) bundled in the release for an overview of the programmable interface.

### Download the [latest release](https://github.com/A-AhkUser/eAutocomplete/releases)

***

> Notes:

> - Unlike the latest release, the master branch is not considered as fully tested on each commit.
> - Although I have been careful to ensure that the script is right and efficient, I should underlined that I am not a programmer: this code should only serve as a basis for your own development and it is more reasonable to assume that the script cannot be used in unmodified form in a production environment.

### Thanks to:

- ***AlphaBravo***, ***jeeswg*** and ***just me***.
- ***brutus_skywalker*** for his valuable suggestions on how to make more ergonomic and user-friendly the common features provided by the script via the use of keyboard shortcuts.
- ***G33kDude (GeekDude)*** and ***ManiacDC*** whose respective works - respectively [CQT.AutoComplete.ahk](https://github.com/G33kDude/CodeQuickTester/blob/master/lib/CQT.AutoComplete.ahk) and [TypingAid](https://github.com/ManiacDC/TypingAid/) - served as models for this one.
- ***Uberi*** for its [score fuzzy search algorithm](https://github.com/Uberi/Autocomplete/blob/master/Autocomplete.ahk).
- A special thanks to ***FanaticGuru*** for its [Sift_Regex function](https://www.autohotkey.com/boards/viewtopic.php?t=7302).
- **Thanks to the [AutoHotkey community](https://www.autohotkey.com/boards/).**

# Table of Contents

<ul>
	<li><a href="#description-commands">Description, commands</a></li>
	<li><a href="#deployment">Deployment</a>
	<ul>
		<li><a href="#custom-autocomplete-lists">Custom autocomplete lists</a></li>
		<ul>
			<li><a href="#the-wordlist-object">The WordList object</a></li>
		</ul>
		<li><a href="#sample-example">Sample example</a></li>
	</ul>
		</li>
		<li><a href="#available-properties">Available properties</a></li>
		<li><a href="#available-methods">Available methods</a></li>
	<ul>
		<li><a href="#event-handling">Event handling</a></li>
		<ul>
			<li><a href="#oncomplete">OnComplete</a></li>
			<li><a href="#onsuggestionlookup">OnSuggestionLookUp</a></li>
			<li><a href="#onreplacement">OnReplacement</a></li>
		</ul>
	</ul>
		<li><a href="#object-members">Object members</a></li>
	<ul>
		<li><a href="#available-properties-object-members">Available properties (object members)</a></li>
	</ul>
</ul>

## Description, commands

The script enables, as typing in an `Edit`/`RICHEDIT50W` control, to quickly find and select from a dynamic pre-populated list of suggestions and, by this means, to expand/replace partially entered strings into/by complete strings. When you start to type in the target control and a brief rest occurred since the last keystroke, the script starts searching for entries that match and should automatically - by default at least - display complete strings to choose from, which are based:

- on earlier typed characters (letters, symbols *etc.*);
- on the content and settings of the current [wordlist](#custom-autocomplete-lists);
- on the recentness of use of the matching suggestions.

The script integrates the [Sift_Regex function](https://www.autohotkey.com/boards/viewtopic.php?t=7302): fuzzy searching is available, assuming the given wordlist and its `Query`'s interface have been set up to allow it. By way of examples, and depending on the setting, `ahkey`, `AHKey`, `a.+?key$` or `auto` could match `autohotkey` - and suggest it as an autocomplete string.

> Known limitation: for efficiency reasons, and for want of anything better, the script preprocessed the user-defined wordlist, creating a list alphabetically splitted in subsections; a pending word is check against the subsection of the autocomplete source where all words start with the very first letter by which a given pending word starts so that the length of the input string whose content is searched is reduced. This means, for example, in 'regex mode', that `on$` will suggest `objection` because:

> - 1° the word actually ends with 'on' (that is, actually observes the pattern to search for, represented by the [regular expression](https://www.autohotkey.com/docs/misc/RegEx-QuickRef.htm) used as query);
> - 2° starts with 'o': the search has been conducted on the subsection where all words start with 'o'.

> In other words, and by way of example, `on$` won't be able to suggest `abandon` (in this case one should use `aon$` instead).

Depending on the setting of the [`Menu` member](#object-members)'s own positioning strategy, the list of choices is displayed in the vicinity of the host control's caret or beneath the control instead, in the manner of a combobox menu. Items can be clicked to complete words and the menu is designed in such way that it does not get focused while being able to interact with it. Also, you can display suggestion-based info tips (when applicable, they appear in a tooltip, near the selected suggestion).

The key features provided by the script are accessible using keyboard shortcuts, which are customizable. By default, hotkeys default to the following values:

* Press the <kbd>Tab</kbd> key to complete a pending word with the selected suggestion (the top most suggestion is selected by default either when the menu drops or is updated upon match or when you invoke it).
* Use both the <kbd>Down</kbd> and <kbd>Up</kbd> arrow keys to select from the list all other available suggestions. Hitting <kbd>Up</kbd> while the first item is selected will bring you to the last one while hitting <kbd>Down</kbd> on the last item will bring you to the first one.
* Long press <kbd>Tab</kbd> to replace the current partial string (should call the [onReplacement](#onreplacement) callback, if any).
* The <kbd>Enter</kbd> hotkey is functionally equivalent to the <kbd>Tab</kbd> one except that it also moves the caret to the next line at the same time.
* Press and hold <kbd>⯈</kbd> (that is, the right arrow key) to look up the selected suggestion's associated info tip (should call the [onSuggestionLookUp](#onsuggestionlookup) callback, if any).
* The menu can be hidden by pressing the combination <kbd>Shift</kbd>+<kbd>Esc</kbd>.
* If [`autoSuggest`](#available-properties) is disabled or if you previously hid the menu, <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>Down</kbd> displays the menu, assuming one or more suggestions are available and that the caret is positioned in such a way that completion is practicable.

An instance can optionally learn *hapax legomena* at their first onset (or simply collect them for use in a single session) by setting the respective value of the given [wordlist's `learnWords` and `collectWords` properties](#custom-autocomplete-lists).

On a side note, the graphics of the menu and of both the listbox and the infotip it owns are to some extent customizable via [their respective interface](#available-properties-object-members).

***

<table align="center">
	<tr>
	<td><img src="https://raw.githubusercontent.com/A-AhkUser/resources/master/eAutocomplete_1.gif" /></td>
	<td><img src="https://raw.githubusercontent.com/A-AhkUser/resources/master/eAutocomplete_2.gif" /></td>
	</tr>
</table>

***


## Deployment

- Download the [latest release](https://github.com/A-AhkUser/eAutocomplete/releases) and extract the content of the zip file to a location of your choice, for example into your project's folder hierarchy.
- Load the library (``\eAutocomplete.ahk``) by means of the [#Include directive](https://www.autohotkey.com/docs/commands/_Include.htm).
- `eAutocomplete` is at its root designed as [a super global automatically initialized singleton](https://www.autohotkey.com/boards/viewtopic.php?f=7&p=175700#post_content176521); you don't need to create a new instance of the class (besides, any attempt to create a new instance will throw an exception).
- You must call the [wrap base method](#wrap) to endow with word completion feature an existing edit control (*e.g.* *Notepad*'s one) or an existing rich edit control (*e.g.* [Poor Man's Rich Edit GUI](https://github.com/AHK-just-me/Class_RichEdit/blob/master/Sources/RichEdit_sample.ahk)'s one).

But first it might be necessary to load a wordlist, either from a file or a variable, preparing it beforehand, when appropriate. This is precisely the subject of the next section.

***
### Custom autocomplete lists
***

Autocompletion data are assumed to be described as a simple LF/CRLF-separated set of lines.

A given line may be commented out by prefixing it by one or more space (or tab) characters - while a given part of a line may be excluded from the string which is intended to be displayed in the autocomplete menu, as an actual suggestion, by prefixing it by one or more tab characters:


```
...
summer		this is a comment
sun
sunday this is not a comment
		this is a comment
 this is a comment
...
```



You must first call either the ``WordList.buildFromFile`` or the ``WordList.buildFromVar`` ``eAutocomplete``'s base method to prepare a new list for use as an autocomplete list.

***
### eAutocomplete.WordList.*buildFromFile* / *buildFromVar* / *setFromFile* / *setFromVar* methods
***

```AutoHotkey
wlo := eAutocomplete.WordList.buildFromFile(_sourceName, _fileFullPath, _exportPath:="", _caseSensitive:=false)
wlo := eAutocomplete.WordList.buildFromVar(_sourceName, _list:="", _exportPath:="", _caseSensitive:=false)
wlo := eAutocomplete.WordList.setFromFile(_sourceName, _fileFullPath:="", _exportPath:="", _caseSensitive:=false)
wlo := eAutocomplete.WordList.setFromVar(_sourceName, _list:="", _exportPath:="", _caseSensitive:=false)
```

##### [``buildFrom...``] Load a list of suggestions from a file/a variable and prepare the given list for use as an autocompletion list.
##### [``setFrom...``] Set an already formatted list of suggestion from a file/a variable for use as an autocompletion list.

| parameter | description |
|:-|:-|
| ``_sourceName`` *[STRING]* | The name of the wordlist, which may consist of alphanumeric characters, underscore and non-ASCII characters. |
| ``_fileFullPath`` *[FILE_FULL_PATH]* | [``...FromFile``] The absolute path of the file to read and whose content will be used to build or set the autocomplete list. |
| ``_list`` *[STRING]* | [``...FromVar``] A list, as string of characters, from which to build or set the autocomplete list. You can use [FileRead](https://www.autohotkey.com/docs/commands/FileRead.htm) or a [continuation section](https://www.autohotkey.com/docs/Scripts.htm#continuation) to save a series of lines to a variable. |
| ``_exportPath`` *[FILE_FULL_PATH/INTEGER]* | The absolute path of the file to which export the formatted autocomplete list and any update of its content (see also: [`learnWords`](#the-wordlist-object)). The file is created if need be and **overwritten if it already exists**. [``...FromFile``]: Specify `-1` to use ``_fileFullPath`` as export file. |
| ``_caseSensitive`` *[BOOLEAN]* | A boolean value which determines whether or not items in the autocomplete list which are distinguishable one from the other only by their case should be considered as identical (`false`) or not (`true`). |

##### return value: all four methods return an [new WordList object](#the-wordlist-object) upon success.
> All four methods throw an exception on failure.

***
### The *WordList* object
***

##### Each ``WordList`` instance comes with the following interface:

| Object member | description |
| :- | :---: |
| ``Query.Sift`` | Description soon available. |
| ``Query.Word`` | Description soon available. |

The ``WordList`` object provides an interface that allows you to set for a given wordlist:

- its learning behaviour.
- its own definition of what a 'word' consists in.
- its way of sifting or searching through data for items that match a given pending word.

You can find below all properties available for the ``WordList`` object:

|| property | description | default value
| :---: | :---: | :---: | :---: |
|| ``collectAt``</br>*[UNSIGNED_INTEGER]* | Specify how many times a 'word' absent from the wordlist should be typed before being actually collected by the instance. Instance's concept of 'word' is affected by the setting of the ``query.word`` member. Once collected, words are valid during a single session (see also: `learnWords`). Each time you set this value, all internal instance's counters are reset: a given non-yet collected 'word' must anew be typed `collectAt` time(s) to trigger the collecting mechanism (that is, regardless of how many times it has been typed so far).  | `4` |
|| ``collectWords``</br>*[BOOLEAN]* | Specify whether or not an instance should collect 'words' at their `collectAt`-nth onset. Once collected, words are valid during a single session (see also: `learnWords`). | `true` |
|| ``learnWords``</br>*[BOOLEAN]* | If the value evaluates to `true` at the time the eAutocomplete's current wordlist [is replaced by a new one](#available-properties) or at the time the script exits, collected words **and the ranking of all the entries of the given wordlist, based on their respective recentness** will be stored into the instance's export file. | `false` |
|| ``name``</br>*[STRING] [READ_ONLY]* | The name of the wordlist. | *runtime/user-defined* |
| **query.sift** | | | |
|| ``option``</br>*[SIFT_REGEX_OPTION]* | One of the following `Sift_Regex` options:</br></br>`IN`	*Needle anywhere IN Haystack item*</br>`LEFT`	*Needle is to LEFT or beginning of Haystack item*</br>`RIGHT`	*Needle is to RIGHT or end of Haystack item*</br>`EXACT`	*Needle is an EXACT match to Haystack item*</br>`REGEX`	*Needle is an REGEX expression to check against Haystack item*</br>`OC`	*Needle is ORDERED CHARACTERS to be searched for even non-consecutively but in the given order in Haystack item*</br>`OW`	*Needle is ORDERED WORDS to be searched for even non-consecutively but in the given order in Haystack item*</br>`UC`	*Needle is UNORDERED CHARACTERS to be search for even non-consecutively and in any order in Haystack item*</br>`UW`	*Needle is UNORDERED WORDS to be search for even non-consecutively and in any order in Haystack item*</br>(see also: [Sift_Regex](https://www.autohotkey.com/boards/viewtopic.php?t=7302))| `"LEFT"` |
| **query.word** | | | |
|| ``edgeKeys``</br>*[STRING]* | A list of zero or more characters, considered as not being part of a 'word', that is, all characters that can work as outer edges of a word. Space characters - space, tab, and newlines - are always considered as edge keys. | `"\/\|?!,;.:(){}[]'""<>@="` |
|| ``minLength``</br>*[UNSIGNED_INTEGER]* | Set the minimum number of characters a word must contain to be actually seen as a 'word'. | `2` |


> Note: the collecting/learning mechanism is case (in)sensitive if the wordlist has been created as case (in)sensitive.

> Known limitation: for now, the script is unable to make a distinction between 'edge chars' and [symbols commonly used in the regex syntax](https://www.autohotkey.com/docs/misc/RegEx-QuickRef.htm#Common): if you want to use a regex symbol as such (by setting ``(this).query.sift.option`` to `"REGEX"`), it must not be listed in ``edgeKeys``.

##

***
## Sample example

Once you have created / loaded one or more wordlists, you can wrap one or more controls and use the ``eAutocomplete`` interface to set up the autocomplete feature:

```Autohotkey
#NoEnv
#Warn

#Include %A_ScriptDir%\eAutocomplete.ahk

list =
(Join`r`n
Control	, Cmd [, Value, Control, WinTitle, WinText, ExcludeTitle, ExcludeText]
ControlClick	[, Control-or-Pos, WinTitle, WinText, WhichButton, ClickCount, Options, ExcludeTitle, ExcludeText]
ControlFocus	[, Control, WinTitle, WinText, ExcludeTitle, ExcludeText]
ControlGet	, OutputVar, Cmd [, Value, Control, WinTitle, WinText, ExcludeTitle, ExcludeText]
ControlGetFocus	, OutputVar [, WinTitle, WinText, ExcludeTitle, ExcludeText]
ControlGetPos	[, X, Y, Width, Height, Control, WinTitle, WinText, ExcludeTitle, ExcludeText]
ControlGetText	, OutputVar [, Control, WinTitle, WinText, ExcludeTitle, ExcludeText]
ControlMove	, Control, X, Y, Width, Height [, WinTitle, WinText, ExcludeTitle, ExcludeText]
ControlSend	[, Control, Keys, WinTitle, WinText, ExcludeTitle, ExcludeText]
ControlSetText	[, Control, NewText, WinTitle, WinText, ExcludeTitle, ExcludeText]
)
global params := Object(StrSplit(list, ["`r`n", "`t"])*)
source := eAutocomplete.WordList.buildFromVar("myList", list)
query := source.Query
query.Word.minLength := 1
query.Sift.option := "OC"
GUI, New
GUI, Font, s14, Segoe UI
GUI, Add, Edit, hwndhEdit w200 h200
GUI, Show, AutoSize, eAutocomplete
eAutocomplete.wrap(hEdit)
eAutocomplete.resource := source.name
Menu := eAutocomplete.Menu
Menu.positioningStrategy := "DropDownList"
Menu.InfoTip.font.setCharacteristics("Segoe UI", "s11")
Menu.itemsBox.maxVisibleItems := 5
eAutocomplete.onSuggestionLookUp("eA_onSuggestionLookUp")
eAutocomplete.onComplete("eA_onComplete")
return

eA_onComplete(_suggestion, ByRef _expandModeOverride:="") {
static EXPAND_NO_SPACE := 0
return _suggestion . params[_suggestion], _expandModeOverride:=EXPAND_NO_SPACE
}
eA_onSuggestionLookUp(_selectionText) {
return params[_selectionText]
}

!x::
ExitApp
```

###

***
## Available properties

| property | description | default value
| :---: | :---: | :---: |
| ``eAutocomplete.autoSuggest`` *[BOOLEAN]* | If set to `true` the autocompletion feature automatically displays a menu as soon as suggestions are available. Otherwise, if set to `false`, the <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>Down</kbd> hotkey can display the menu, assuming one or more suggestions are available and that the caret is positioned in such a way that completion is practicable. | `true` |
| ``eAutocomplete.disabled`` *[BOOLEAN]* | Disable (`true`) or enable (`false`), if need be, the autocomplete feature. Use the [unwrap method](#available-methods) instead to deprive a control of its eAutocomplete word completion feature and interface. | `false` |
| ``eAutocomplete.keypressThreshold `` *[UNSIGNED_INTEGER]* | The number of milliseconds that must pass before eAutocomplete starts searching for entries that match in the autocomplete list. Keystroke events separated by a period of less than this value are considered as part of an influx and are discarded as such while a single call is buffered: in other words, when you start to type in the target control and a brief rest of this property's value (in milliseconds) occurred since the last keystroke, eAutocomplete actually starts searching for entries that match in the autocomplete list. Specifying a number less than 65 is the same as specifying 65. | `225` |
| ``eAutocomplete.resource`` *[SOURCE_NAME/WORDLIST_OBJECT]* | [setter] Specifies the [autocomplete list](#custom-autocomplete-lists) to use. The value must be the name of a [Wordlist instance](#the-wordlist-object).</br>[getter] Returns the current Wordlist instance used for autocompletion. | *runtime/user-defined* |

###

***
## Available methods

- **wrap**
- **unwrap**

- **OnComplete**
- **OnReplacement**
- **OnSuggestionLookUp**

### wrap
***

```AutoHotkey
eAutocomplete.wrap(_hHost)
```

###### Endow an existing `Edit`/`RICHEDIT50W` control with the eAutocomplete word completion feature and interface.

| parameter | description |
|:-|:-|
| ``_hHost`` *[HWND]* | The [HWND](https://www.autohotkey.com/docs/commands/WinGet.htm#ID) of the [`Edit`/`RICHEDIT50W` control](https://www.autohotkey.com/docs/commands/WinGetClass.htm) to be endowed with the eAutocomplete word completion feature and interface. |

You can wrap as many controls as you need. Once you have done with a control, you should call the unwrap method.

> The method throws an exception on failure.

### unwrap
***

```AutoHotkey
eAutocomplete.unwrap(_hHost)
```

###### Deprive an existing `Edit`/`RICHEDIT50W` control of its eAutocomplete word completion feature and interface, if applicable.

| parameter | description |
|:-|:-|
| ``_hHost`` *[HWND]* | The [HWND](https://www.autohotkey.com/docs/commands/WinGet.htm#ID) of the [`Edit`/`RICHEDIT50W` control](https://www.autohotkey.com/docs/commands/WinGetClass.htm) whose the eAutocomplete word completion feature and interface should be removed. |

> The method throws an exception on failure.

Other documented methods allows you to specify user-defined callbacks in order to implement a custom event handling. This is the subject of the next section.

***
## Event handling

The script is able to call a user-defined callback for the following events:

- `onComplete`
- `onReplacement`
- `onSuggestionLookUp`

The value can be either the name of a function, a [function reference](https://www.autohotkey.com/docs/commands/Func.htm) or a [boundFunc object](https://www.autohotkey.com/docs/objects/Functor.htm#BoundFunc).

##
### OnComplete
***
```AutoHotkey
eAutocomplete.onComplete("onCompleteEventHandler")
eAutocomplete.onComplete("") ; unregister the function object, if applicable
```
***
##### description:
Associate a function with the `complete` event. This would cause the function to be launched automatically whenever you are about to complete a word by pressing the <kbd>Tab</kbd>/<kbd>Enter</kbd> key (by default). The event fires before the complete string has been actually sent to the host control - the return value of the function being actually used as the actual complete string.</br>
The function can optionally accept the following parameters:</br>
```AutoHotkey
completeString := onCompleteEventHandler(_suggestion, ByRef _expandModeOverride:="")
```

| parameters | description |
|:-|:-|
| ``_suggestion`` | The text of the selected suggestion, as visible in the autocomplete menu. |
| ``_expandModeOverride`` | If you give a value to this `ByRef` parameter, it can be that of an EXPAND_MODE - to locally and punctually override the [eAutocomplete's Completor](#available-properties-object-members) way to expand. The value can be `-1` to complete and move the caret to the next line at the same time. |
##
### OnReplacement
***
```AutoHotkey
eAutocomplete.onReplacement("onReplacementEventHandler")
eAutocomplete.onReplacement("")  ; unregister the function object, if applicable
```
***
##### description:
Associate a function with the `replacement` event. This would cause the function to be launched automatically whenever you are about to replace a word by long pressing the <kbd>Tab</kbd>/<kbd>Enter</kbd> key (by default). The event fires before the replacement string has been actually sent to the host control - the return value of the function being actually used as the actual replacement string. This can be used to allow dynamic replacements, such as when replacement strings come from a translation API, for example.</br>
The function can optionally accept the following parameters:</br>
```AutoHotkey
replacementString := onReplacementEventHandler(_suggestion, ByRef _expandModeOverride:="")
```

| parameters | description |
|:-|:-|
| ``_suggestion`` | The text of the selected suggestion, as visible in the autocomplete menu. |
| ``_expandModeOverride`` | If you give a value to this `ByRef` parameter, it can be that of an EXPAND_MODE - to locally and punctually override the [eAutocomplete's Completor](#available-properties-object-members) way to expand. The value can be `-1` to replace and move the caret to the next line at the same time. |
##
### OnSuggestionLookUp
***
```AutoHotkey
eAutocomplete.onSuggestionLookUp("onSuggestionLookUpEventHandler")
eAutocomplete.onSuggestionLookUp("") ; unregister the function object, if applicable
```
***
##### description:
Associate a function with the `suggestionLookUp` event. This would cause the function to be launched automatically whenever you attempt to query an info tip from the selected suggestion by pressing and holding the <kbd>⯈</kbd> arrow key (by default). The return value of the callback will be used as the actual text displayed in the tooltip. This can be used to allow dynamic description lookups such as when description strings come from a dictionary API.</br>
The function can optionally accept the following parameters:</br>
```AutoHotkey
infotTipText := onSuggestionLookUp(_selectionText)
```

| parameters | description |
|:-|:-|
| ``_selectionText`` | The text of the selected suggestion, as visible in the autocomplete menu. |

###

***
## Object members

<pre id="tree">
eAutocomplete
├── Resource (instance of eAutocomplete.WordList)
├── ├── Query
├── ├── ├── Sift
├── ├── ├── Word
├── Menu
├── ├── ItemsBox
├── ├── ├── Selection
├── ├── ├── Font
├── ├── Positioning
├── ├── InfoTip
├── ├── ├── Positioning
├── ├── ├── Font
├── Completor
</pre>

| Object member | description |
| :- | :---: |
| ``WordList (resource)`` | Description soon available. |
| ``WordList.Query (resource.Query)`` | Description soon available. |
| ``WordList.Query.Sift (resource.Query.Sift)`` | Description soon available. |
| ``WordList.Query.Word (resource.Query.Word)`` | Description soon available. |
| ``Menu`` | Description soon available. |
| ``Menu.ItemsBox`` | Description soon available. |
| ``Menu.ItemsBox.selection`` | Description soon available. |
| ``Menu.ItemsBox.font`` | Description soon available. |
| ``Menu.Positioning`` | Description soon available. |
| ``Menu.InfoTip`` | Description soon available. |
| ``Menu.InfoTip.Positioning`` | Description soon available. |
| ``Menu.InfoTip.font`` | Description soon available. |
| ``Completor`` | Description soon available. |

### Available properties (object members)
***

| member | property | description | default value |
| :- | :---: | :---: | :---: |
| **menu** |  |  |  |
|| ``bkColor``</br>*[COLOR_VALUE/COLOR_NAME]*</br>(**getter not implemented**) | Set the background color of the autocomplete menu by specifying one of the 16 primary [HTML color names](https://www.autohotkey.com/docs/commands/Progress.htm#colors) or a 6-digit RGB color value (in this latter case, the 0x prefix is optional). | `0xF0F0F0` |
|| ``positioningStrategy``</br>*[POS_STRATEGY]* | Set or get the current strategy used to automatically place the autocomplete menu. The two following positioning strategies are available:</br>``Menu``	*the list of choices is displayed in the vicinity of the host control's caret*</br>``DropDownList``	*the menu is displayed beneath the host control, in the manner of a combobox menu* | `"Menu"` |
|| ``transparency``</br>*[UNSIGNED_INTEGER]* | Specify a number between **10** and 255 to indicate the autocomplete menu's degree of transparency. | `255` |
| **menu.itemsBox** | | | |
|| ``maxVisibleItems``</br>*[UNSIGNED_INTEGER]* | The maximum number of suggestions that must be visible in the autocomplete menu without having to scrolling, if necesary. | `5` |
| **menu.itemsBox.selection** |  |  |  |
|| ``index``</br>*[UNSIGNED_INTEGER]* | - | *runtime/user-defined* |
|| ``text``</br>*[STRING]* | - | *runtime/user-defined* |
| **menu.itemsBox.font** | | | |
|| ``color``</br>*[COLOR_VALUE/COLOR_NAME]*</br>(**getter not implemented**) | Set the font color for the autocomplete menu's list box by specifying one of the 16 primary [HTML color names](https://www.autohotkey.com/docs/commands/Progress.htm#colors) or a 6-digit RGB color value. | `"000000"` |
|| ``name``</br>*[FONT_DENOMINATION]* | Set or get the font typeface for the autocomplete menu's list box. | `"Segoe UI"` |
|| ``size``</br>*[UNSIGNED_INTEGER]*</br>(**getter not implemented**) | Set the font size for the autocomplete menu's list box. | `12` |
| **menu.positioning** |  |  |  |
|| ``offsetX``</br>*[INTEGER]* | (**The menu's positioning strategy must be "Menu"**) The offset from the current host control's caret position to which display the autocomplete menu, on the x-axis. The offset value can be negative. | `5` |
|| ``offsetY``</br>*[INTEGER]* | (**The menu's positioning strategy must be "Menu"**) The offset from the current host control's caret position to which display the autocomplete menu, on the y-axis. The offset value can be negative. | `25` |
| **menu.infotip.positioning** | | | |
|| ``offsetX``</br>*[INTEGER]* | The offset from the abscissa of the selected suggestion's upper-left corner to which display the infotip. The offset value can be negative. | `5` |
| **completor** | | | |
|| ``correctCase``</br>*[INTEGER]* | Determine whether the eAutocomplete's completor simply completes the pending word (that is, preserving this latter's case) or actually replaces it by the autocomplete menu's selected suggestion (or more precisely, by the return value of either the [``onComplete`` or the ``onReplacement`` callback](#event-handling), as appropriate). | `false` |
|| ``expandMode``</br>*[BOOLEAN]* | Determine whether or not the eAutocomplete's completor automatically expands or not the complete string with a space upon text expansion/replacement. | `1` |



## Licence

CC BY-SA for the autocompletion list. Otherwise, [Unlicence](LICENSE).


