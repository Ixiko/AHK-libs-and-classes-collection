#include %A_LineFile%\..
#Include Const_WinUser.ahk
#Include GdipC\GdipC.ahk

#include Wy\JSON.ahk

#include Wy\Colory.ahk
#include Wy\ScreenSavy.ahk
#include Wy\Mony.ahk
#include Wy\MultiMony.ahk

/*
Title: Wy 
	
Wy provides a collection of classes, which allow a class based approach of handling windows, monitors, etc.
	
Following classes exist:
	
- <Colory> - Handling colors
- <Mony> - Single Monitor
- <MultiMony> - Multi Monitor Environments
- <ScreenSaver> - Settings of Windows-Screensaver
- <Wy.Pointy> - Points (geometric 2D-points) - this is mostly a helper class being used within this package, but maybe helpful anyway ...
- <Wy.Recty> - Rectangles (consisting of two <Wy.Point>) -  - this is mostly a helper class being used within this package, but maybe helpful anyway ...
		
Authors:
<hoppfrosch at hoppfrosch@gmx.de>: Original

About: License
MIT License

Copyright (c) 2017 Johannes Kilian

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 
to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
class Wy {
	; ******************************************************************************************************************************************
	/*
	Class: Wy
		Class as container for several helper classes

	Authors:
	<hoppfrosch at hoppfrosch@gmx.de>: Original
	*/
	_version := "1.0.1"
	__New()  {
	}
	
	__Delete() {
	}

; #region # Nested classes ############################################################################################	

; #region ### [C] Wy.Pointy ###########################################################################################	
	class Pointy extends GdipC.Point
	; ******************************************************************************************************************************************
	/*
	Class: Wy.Pointy
		2-dimensional point, based on Class <GdipC.Point at https://github.com/AutoHotkey-V2/GdipC>

	Authors:
	<hoppfrosch at hoppfrosch@gmx.de>: Original
	*/
	{
		ToJSON() {
			return "{`"x`":=" this.x ",`"y`":" this.y "}"
		}
	}
; #endregion ### [C] Wy.Pointy ########################################################################################	

; #region ### [C] Wy.Recty ############################################################################################	
	class Recty extends GdipC.Rect
	; ******************************************************************************************************************************************
	/*
	Class: Wy.Recty
		2-dimensional rectangle, based on Class <GdipC.Rectangle at https://github.com/AutoHotkey-V2/GdipC>

	Authors:
	<hoppfrosch at hoppfrosch@gmx.de>: Original
	*/
	
	{
		ToJSON() {
			return "{`"x`":=" this.x ",`"y`":" this.y ",`"width`":" this.width ",`"height`":" this.height "}"
		}
	}
; #endregion ### [C] Wy.Recty #########################################################################################	

; #endregion # Nested classes #########################################################################################	
} ; End of Class Wy