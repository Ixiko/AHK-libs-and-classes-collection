# XA - Save/Load AutoHotkey Arrays in XML format

Introduction

XA was written by **trueski** and the original source can be found here http://www.autohotkey.com/board/topic/85461-ahk-l-saveload-arrays/  
(The code posted there is no longer valid due to errors caused by upgrading the forum software.)

XA_CleanInvalidChars() has been added to remove invalid characters in XML.

## Usage

```ahk
    XA_Save("Array", Path) ; put variable name in quotes
    XA_Load(Path)          ; the name of the variable containing the array is returned
```

### AutoHotkey forum discussion

https://autohotkey.com/boards/viewtopic.php?f=6&t=34849
