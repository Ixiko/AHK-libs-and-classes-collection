# ColorPicker_ahk2
Win32 Color Picker for AHK v2

Originally posted by maestrith 
https://autohotkey.com/board/topic/94083-ahk-11-font-and-color-dialogs/

## ColorSelect()
```
result := ColorSelect(Color := 0, hwnd := 0, &custColorObj := "",disp:=true)

Color           = Start color (0 = black) - Format = 0xRRGGBB
hwnd            = Parent window
custColorObj    = Array() to load/save custom colors, must be &VarRef
disp            = 1=full / 0=basic ... full displays custom colors panel, basic does not
```

Color format for `Color`, `result`, and all custom colors in the `custColorObj` array is `0xRRGGBB`.

If no parent `hwnd` is specified, the dialog shows at the top left of the screen.

The `custColorObj` must be a &VarRef, even if you don't use it after selecting a color.

Setting `disp` to false will hide the left panel of the window.  The user can expand it by clicking the `Define Custom Colors` button on the dialog.