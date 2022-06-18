# FontPicker_ahk2
Font Picker for AHK v2

originally posted by maestrith 
https://autohotkey.com/board/topic/94083-ahk-11-font-and-color-dialogs/

## FontSelect()
```
fontObj := FontSelect(fontObject:="", hwnd:=0, Effects := true)
```

The input `fontObject` is for initializing the dialog with specific values.

The `hwnd` will make the specified window handle the parent.

Setting `Effects` to false will disable the changing of strike, underline, and other styles.

The return `fontObj` is generally meant for future use to re-open the dialog with the settings last used.

## fontObj Properties

```
fontObj.str        = string to use with AutoHotkey to set GUI values - see examples
fontObj.size       = size of font
fontObj.name       = font name
fontObj.bold       = true/false
fontObj.italic     = true/false
fontObj.strike     = true/false
fontObj.underline  = true/false
fontObj.color      = 0xRRGGBB
```