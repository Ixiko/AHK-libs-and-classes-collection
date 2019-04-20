# Class_PictureButton [![_Ne0n](https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg)](https://github.com/Ne0n-git)

### Last updated: August 31, 2018
### Read this in other languages: [Russian](README.ru.md).
Pages:
```
Versions
Functions
```
------------------------------------------------------------------------------------



# Versions
About versions
## Class_PictureButton_v1.ahk
### Advantage:
- Does not use/require third-party libraries. Written with built-in AHK functions
### Flaw:
- There are flickers when you change the picture(that is, when you hover/when you press / when you disable / enable the button)


## Class_PictureButton_v2.ahk
### Advantage:
- Flicker-free
- When creating - > ability to set the image as Bitmap, and the path to the image
- When deleting - > ability to clear Bitmap, thus free up memory, or not
### Flaw:
- Uses GDI+ (not so scary)

------------------------------------------------------------------------------------


# REMARKS:
```
-> DoubleClick by default ignored, see line:290 or(find: "NOTE:DoubleClick") in Class_PictureButton_v2.ahk
```

------------------------------------------------------------------------------------
# FUNCTION LIST


## _PictureButton.add(hwnd,options)
```
________________________________________
Description: Adding new picture button.
Args:
    hwnd - owner window
    xywh[] - position and size of button
      * {x,y,w,h}
    options[] - options object
        name  - button name (uses on callback funcname(id,NAME,hwnd))
    	AntiAlias - AntiAlias (default:3)
	    * 0 - Default 
            * 1 - HighSpeed
            * 2 - HighQuality
            * 3 - None
            * 4 - AntiAlias
        state - state of the button (default:normal)
            * "normal","hover","pressed","disable"
        on_click - function object (callback, use Func("FunctionName"))
    bitmaps[] - object (values can be a bitmap or path to file or color(ARGB)) example "color": c0xFF001122
	* 1 - "normal"
        * 2 - "hover"
        * 3 - "pressed"
        * 3 - "disable"
    text[] - object
        title - text on the button.
        color - text color ARGB     ;;;in future("color" can be either a variable or array of colors for button states)
        width - text width  *(max size)*
        height- text height *(max size)*
        options - options for text, separate by "|"
	    ; XYWH
	    ; Top|Bottom|vCentre|vCenter
	    ; NoWrap
	    ; R - Rendering
	    ; S - Size
	    ; Regular|Bold|Italic|BoldItalic|Underline|Strikeout - styles
	    ; Near|Left|Centre|Center|Far|Right - Align
________________________________________
REMARKS: if value of "bitmaps[N]" = color, xywh must have each parameters
```




## _PictureButton.del(ID_or_NAME,removeBitmap=1)
```
________________________________________
Description: deleting button.
Args:
    ID_or_NAME - id/name of the button
    removeBitmap - removing a bitmap from resources (default:1)

Returns:
    0 - button not exist
    1 - button succesfully deleted
________________________________________
```




## _PictureButton.show(ID_or_NAME,state=0)
```
________________________________________
Description: showing button/s.
Args:
    ID_or_NAME - id/name of the button, or -1 - all button
    state - the state of the button
        1 - normal
        2 - hover
        3 - pressed
        3 - disable

Returns:
    0 - button not exist
    1 - button succesfully deleted
NOTE: function returns all the time 1, if id=-1
________________________________________
```




## _PictureButton.enable(id)
```
________________________________________

Description: enabling button.
Args:
     ID_or_NAME - id/name of the button

Returns:
    0 - button not exist
    1 - button succesfully enabled
________________________________________
```




## _PictureButton.disable(id)
```
________________________________________

Description: disabling button.
Args:
    ID_or_NAME - id/name of the button

Returns:
    0 - button not exist
    1 - button succesfully enabled
________________________________________
```
