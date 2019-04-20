# RichCode.ahk

A wrapper around a RichEdit control to provide code editing features.

## Using

Create an instance of the `RichCode` class, passing it a Settings array whose
members are as listed below. As a second, optional parameter you can pass
control options to be used in the `Gui, Add` command.

See [Examples/Demo.ahk](Examples/Demo.ahk) for more advanced usage.

```AutoHotkey
class RichCode({"TabSize": 4     ; Width of a tab in characters
	, "Indent": "`t"             ; What text to insert on indent
	, "FGColor": 0xRRGGBB        ; Foreground (text) color
	, "BGColor": 0xRRGGBB        ; Background color
	, "Font"                     ; Font to use
	: {"Typeface": "Courier New" ; Name of the typeface
		, "Size": 12             ; Font size in points
		, "Bold": False}         ; Bold weight (True/False)
	, "WordWrap": False          ; Whether to enable WordWrap
	
	
	; Whether to use the highlighter, or leave it as plain text
	, "UseHighlighter": True
	
	; Delay after typing before the highlighter is run
	, "HighlightDelay": 200
	
	; The highlighter function (FuncObj or name)
	; to generate the highlighted RTF. It will be passed
	; two parameters, the first being this settings array
	; and the second being the code to be highlighted
	, "Highlighter": Func("HighlightAHK")
	
	; The colors to be used by the highlighter function.
	; This is currently used only by the highlighter, not at all by the
	; RichCode class. As such, the RGB ordering is by convention only.
	; You can add as many colors to this array as you want.
	, "Colors"
	: {"Comments": 0xRRGGBB
		, "Functions": 0xRRGGBB
		, "Numbers": 0xRRGGBB,
		, "Strings": 0xRRGGBB}})
```