# Wy [![AutoHotkey2](https://img.shields.io/badge/Language-AutoHotkey2-red.svg)](https://autohotkey.com/)
Tools-library to enhance handling of Monitors, and more

This library uses *AutoHotkey Version 2*.

## Usage 

Include precompiled `Wy.ahk`from the `lib` folder into your project using standard AutoHotkey-include methods.

```autohotkey
#include <Wy.ahk>
pt := new Wy.Pointy(10,15)
MsgBox(pt.toJSON())
```

For usage examples have a look at the files in the *examples* folder and the UnitTest-files in *t* subfolder 

## Contents 

### Main

 * Class *Wy/ScreenSavy* - allows modification of screensaver settings
 * Class *Wy.Pointy* - handling of 2-dimensional points with x- and y-coordinates
 * Class *Wy.Recty* - handling rectangle, consisting of two 2-dimensional points (upperLeft und lowerRight)
 * Class *Colory* - handling colors, adapted from [Color class](https://msdn.microsoft.com/en-us/library/gg427627.aspx)
 * Class *Mony* - handling a single monitor
 * Class *MultiMony* - handling multi-monitor environments
 
### Helper

 * Class *GdipC/Gdipc* - AutoHotkey2 implementation of several GDI+ Classes  - see [GdipC on github](https://github.com/AutoHotkey-V2/GdipC)
 * Class *Wy/JSON* - helper class to serialize/deserialize AutoHotkey objects to/from JSON - credits go to [cocobelgica](https://github.com/cocobelgica) (Original see: [AutoHotkey-JSON](https://github.com/cocobelgica/AutoHotkey-JSON) on [github](https://github.com/) - see also [AutoHotkey-Forum](https://autohotkey.com/boards/viewtopic.php?f=6&t=627))

## Development

1. Provide git-submodule `YUnit` 
```bash
git submodule init
git submodule update
```
2. On sourcecode-modification write your own unittests within *t* subfolder and run the existing unittests to be sure everything is ok ...