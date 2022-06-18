# scintilla_ahk2
Scintilla class wrapper for AHK v2

## Scintilla.dll
Go to the Scintilla site to get the DLL.  [Here is the download page for SciTE.](https://www.scintilla.org/SciTEDownload.html)

Direct Links:

* [SciTE 64-bit](https://www.scintilla.org/wscite502.zip)
* [SciTE 32-bit](https://www.scintilla.org/wscite32_502.zip)

Pick your desired 32-bit or 64-bit version for download.  Unzip and copy over the `Scintilla.dll` from the unzipped folder into the same folder as the script.  You can of course place the DLL anywhere, but make sure you modify the class lib in `Static __New()` to point to the proper DLL location.

## Status

On to the next phase:

I've started to dabble in C.  I wrote a DLL to handle the styling routine (source is of course included - CustomLexer.c).  This includes 3 functions.

* Init() - This just records the ctl hwnd for use with the DLL.
* ChunkColoring() - This does `"string"`, `'string'`, `; line comment`, `/* block comment */`, numbers, hex numbers, punctuation (operators / separators), braces.
* DeleteRoutine() - This colors all braces (and matching braces) within the delete zone red.  The result is matching outside the delete zone are colored red so the user can see where the mismatched braces are.

The main method that uses these is: `wm_messages(wParam, lParam, msg, hwnd)`.

There are method wrappers of the same function names that employ these DLL functions.

I've used the following file as a test (thanks to marius - aka robodesign).  This script is 2.16 MB in size and loads with syntax highlighting in currently just over a second (1.078 - 1.218 secs on my machine).

Test document link (this doc is included as `test-script.ahk`):

https://github.com/marius-sucan/Quick-Picto-Viewer/blob/master/quick-picto-viewer.ahk

NOTE:  If you use LayoutCaching, you may get occasional slower load times (up to 14 seconds on `test-script.ahk` according to my tests).  It's a bit random, but this never seems to happen with LayoutCache disabled.  LayoutCache is mostly only useful if you need smoother performance when resizing the window (ie. not maximized).  You will still get smooth scrolling with LayoutCache disabled.

# Documentation

Making the documentation will be a lengthy work in progress...

For now all I can give is a general outline and some guidelines:

* All numerical IDs are zero-based.  So position numbers, line numbers, column numbers, margin numbers, style numbers, selection numbers, etc., start at zero.

* I tried to keep all like categories of methods and properties together as they are listed on the Scintilla Documentation site, but this is not always the case.  Generally I'm just trying to keep concepts in logical categories (sub classes).  This is a bit of a process as I discover other functions, some of which serve a better purpose in a different category than originally listed in the Scintilla Docs.

* Not all Scintilla functions will make it into this library.  Basically, functions that appear to duplicate another function's result with little or no benefit won't be added, unless there is a good reason, in which case it may get a different name to more appropriately describe what it is best used for.

* I will always append a comment for a property or method that makes use of a particular `SCI_...` message name so it should be easy to see what my script is doing while refrencing the Scintilla documentation.

Below I will outline major features or major parts of the script class structure.

-----

### WM_NOTIFY callback

```
g := Gui()
ctl := g.AddScintilla(...)
ctl.callabck := my_func

my_func(ctl, scn) {
    ...
}
```

`ctl` is the Gui Control object, the Scintilla control.
`scn` is the SCNotification struct as a sub-class.

`scn` Members:

hwnd\
id\
wmmsg\
wmmsg_txt <-- added text name of wm_notify msg\
pos\
ch\
mod\
modType\
text\
textPtr\
length\
linesAdded
message\
wParam\
lParam\
line\
foldLevelNow\
foldLevelPrev\
margin\
listType\
x\
y\
annotationLinesAdded\
updated\
listCompletionMethod\
characterSource

-----

### Changing font/background colors and styles.

`ctl.cust.{category}.{property}`

Properties are as follows unless indicated otherwise:
* props: Back, Fore, Font, Size, Bold, Italic, Underline

```
ctl.cust.number    - 1234 and 0x1234ABCD
ctl.cust.comment1  - ; line comments
ctl.cust.comment2  - /* block comments */
ctl.cust.string1   - "string" 
ctl.cust.string2   - 'string'
ctl.cust.punct
ctl.cust.braceH    - brace highlight on cursor event (not yet implemented)
ctl.cust.braceHBad - mismatched brace style, this changes as you edit the doc
ctl.cust.brace     - matched brace style, this changes as you edit the doc
ctl.cust.selection (props: all props of Selection object)
ctl.cust.Caret     (props: all props of Caret object)
ctl.cust.margin    - this is the number margin
ctl.cust.editor    - default text color/style/background color
```

NOTE: When changing editor properties, you need to call `ctl.Style.ClearAll()` to apply those settings.

Set property values as if you were using the Style subclass:

```
the old way:

ctl.Style.ID    := 32       ; specify the ID before making changes
ctl.Style.Color := 0x00FF00 ; set a property

the new way:

ctl.cust.number.Color := 0x00FF00


NOTE:  The "old way" is still necessary when changing other user-defined styles,
and when applying style settings to other margins that are NOT the typical number
margin (which is usually margin 0).  Margin 0 can still be redefined to something
else, and if you choose to do so, you will want to use the "old way" for maximum
flexibility and access to all capabilities provided by the Scintilla library. 
```

### Margins, Styles, EOL Annotations, and Markers

For margins, styles, EOL Annotations, and Markers, set the "active ID" like so:

```
obj.Style.ID := 34 ; make future calls to obj.Style.* apply to style #34

obj.Margin.ID := 2 ; make future calls to obj.Margin.* apply to margin #2

obj.EOLAnn.Line := 3 ; make future calls to obj.EOLAnn.* apply to line #3

obj.Marker.num := 4 ; make future calls to obj.Marker.* apply to marker #4
                    ; NOTE: All methods in the Marker subclass also take a markerNum parameter.
                    ; If you don't specify a markerNum, then the specified num is used.
```

### Keyword Lists

```
ctl.SetKeywords(list1, list2, ..., list8)
    
    words should be separated by a space

ctl.cust.kw1.Fore := 0xAABBCC

    kw1 - kw8 are available to set.  You can set more than just color:
        properties: Back, Fore, Font, Size, Bold, Italic, Underline
```

Once you set the "active ID", future calls to these sub-classes will apply to the most recently set "ID" or "Line", or "marker number" respectively.

# Current Changes

2021/08/29

new features
* added word highlighting (currently only 8 lists)
* updated `ctl.DefaultTheme()` method to setup 3 keyword list colors
* added `ctl.SetKeywords()` method
* added `ctl.CaseSense` proerty
* added keyword lists for AHK (functions, built-in vars, flow control words) - not checked for completeness (just testing)
* updated DLL code to take a keyword list and CaseSense value
* currently loading test-script.ahk in about 1.55 secs

2021/08/27

bug fixes/new features
* fixed exception thrown 0x00000005 when deleting all text
* pressing ENTER inside `/* block comment */` now extends the block comment and styles text accordingly
* removed some old lines of code

2021/08/26

minor changes
* disabled LayoutCache in the example for more consistent fast loading
* added a mechanism to disable unnecessary document parsing when loading
* reworked README and consolidated some docs

2021/08/25

* added C code source and DLL to handle styling
* much improved performance on large documents
* added AHK funcs to do the same operations as the DLL\
search for: "benchmarking for C code equivalent in AHK" - not completely equivelant currently
* added Italic, Bold, Underline properties to "custom" styles\
This was technically already possible, but is now more accessible when using the "cust" class.  See docs.
* Updated docs (not much - but the new info is good to know).
* Added a beefy test script (thanks to robodesign)
* experimentation is on-going!

Features:
* Brace coloring is done as you edit the doc.  Mismatched braces are persistently red.
* Deleting a brace, or commenting it out, colors it's matching brace red.
* All elements in the new "cust" subclass are colored according to user settings.
* Be sure to check the DefaultOpt() method for what settings are currently set for the script demo.\
NOTE: Some settings are also set at the top of the script.

2021/08/06

* updated to Scintilla 5.1.1
* Custom syntax highlighting basic framework is now complete:
  - see StylingRoutine() and DeleteRoutine() methods
  - currently numbers, strings, comments, braces, and punctuation are colored
  - not much customization available yet, unless you edit the class directly
  - I plant to implement a framework that will make defining specific colors for specific groups/types of characters
* cleaned up code
* implemented SCI_GETDIRECTSTATUSFUNCTION in place of SCI_GETDIRECTFUNCTION
* ctl.Status property now pulls the status from what was returned using the new DirectStatusFunction (should be faster when checking status)
* removed old AutoBraceMatching()
* removed Events class, I'm just putting these events in as methods of the class
* performance is quite decent, but needs to be broken up to prioritize user viewed lines first
--------------------
* refined pasting large chunks of text (getting ≈6s load time on ≈2MB of text)
* initial coloring is strings, comments, and braces only (in that order) on the first go
* other syntax elements are colord per-screen when scrolling, or per-line when typing

2021/05/17

* added ctl.Target.\* subclass, aka Searching category (forgot to add this from a week ago)
* added ctl.Target.Text for getting the matched text
* added ctl.Target.Prev(), .Next(), .Flags, .Tag(), .Anchor()
* added ctl.CharIndex for implementing UTF-16 / UTF-32
* added ctl.EscapeChar, .StringChar, .CommentLine, .CommentBlock, properties
* fixed ctl.GetTextRange() to properly handle UTF-8 with wide characters
* fixed ctl.LineText() to make fewer calls to the control to get line text
* improved ctl.GetChar() to handle wide characters
* added ctl.NextCharPos(), .NextChar(), .PrevCharPos(), .PrevChar()
* removed ctl.Margin.DefaultMinWidth / .WidthOffset\
Now calculation of number margin is more dynamic based on font size
* `ctl.Event.MarginWidth()`, with only first two params, can be used to autosize the number margin on-demand
* moved ctl.Style.TextWidth() to ctl.TextWidth()
* added "DefaultOpt" and "DefaultTheme" options for Gui.AddScintilla(), see example
* added ctl.AutoBraceMatch (false by default), uses style 40 and 41 by default (DefaultTheme)
* added ctl.Event.BraceMatch() ... must be used in callback, don't use when `ctl.AutoBraceMatch := true`

2021/05/11

* moved example back to top, now initiating class with "(Scintilla)" for the example (see comments)
* fixed some instances of blank optional parameters not functioning as intended
* added Doc category (Multiple Views)
* officially crossed off "Other Settings" category (it was done a while ago)
* reorded several properties and methods on the main Scintilla class prepping for documentation
* added ctl.AutoSizeNumberMargin (defaults to false)
* added ctl.Events category for packaged functions/methods, intended to assist with common tasks
* added ctl.Events.MarginWidth(margin, size) - for on-demand or usage within user callback (don't use this method directly in callback when `ctl.AutoSizeNumberMargin := true`)
* added ctl.Margin.MinWidth / .DefaultMinWidth / .WidthOffset (mostly used in ctl.Events.MarginWidth())

2021/05/05

* added .wm_messages() callback per control created (attached to the Gui control obj)
* added SCNotification struct as a sub-class
* added callback property to Gui control object ... `callback(ctl, scn)`
* added several static objs for listing constants
* updated and tested offsets for SCNotification struct (13/22 offsets verified for x86 and x64)
* added a few more SCI_\* funcs
* moved some Scintilla control customizations out of main class into a func in the example
* Added .Lookup() and .GetFlags() static methods for easier interal workings

## To-Do List

I plan to still add the following categories / subclasses listed below.  A crossed out item indicates that category of functions has been added.

* Annotations
* AutoComplete and "Element Colors"
* CallTips
* Character Representations
* ~~Direct Access~~
* ~~EOL Annotations~~
* Folding + SCI_SETVISIBLEPOLICY
* IME and UTF-16
* Indicators (underline and such)
* KeyBindings
* Keyboard Commands
* Macro Recording (technically done, but not tested, and might need index of SCI_\* constants)
* ~~Markers~~
* ~~Multiple views~~
* OSX Find Indicator
* ~~Other Settings (finish up)~~
* Printing
* User Lists
