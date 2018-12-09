; * Functions for searching/reading what is displayed by a window.
; *  
; *  License:
; *  	Display v0.1 by Xander, contributions from Dave (CreateWindowCapture, DeleteWindowCapture, GetPixel)
; *  	GNU General Public License 3.0 or higher: http://www.gnu.org/licenses/gpl-3.0.txt
; *
; * Link:
; * 	https://autohotkey.com/board/topic/22675-in-memory-window-capture/page-2
; * 

/*  Usage:
 *  	Creates an offscreen capture of a window. The window cannot be minimized but may be invisible.
 *  Parameters:
 *  	id: The window's id of which to create a capture
 *  	device, context, pixels: Blank variables, see Releasing Memory below.
 *  Releasing Memory:
 *  	After the capture is no longer needed, it's memory must be freed by calling Display_DeleteWindowCapture(device, context, pixels[color=black], id[/color])
 *      where the [color=black]4[/color] parameters are those that was passed to create the window capture.
 */
Display_CreateWindowCapture(ByRef device, ByRef context, ByRef pixels, ByRef id = "") {		
	if !id
		WinGet, id, ID
	device := DllCall("GetDC", UInt, id)
	context := DllCall("gdi32.dll\CreateCompatibleDC", UInt, device)
	WinGetPos, , , w, h, ahk_id %id%
	pixels := DllCall("gdi32.dll\CreateCompatibleBitmap", UInt, device, Int, w, Int, h)
	DllCall("gdi32.dll\SelectObject", UInt, context, UInt, pixels)
	DllCall("PrintWindow", "UInt", id, UInt, context, UInt, 0)
}

Display_DeleteWindowCapture(ByRef device, ByRef context, ByRef pixels[color=black], ByRef id[/color]) {
	DllCall("ReleaseDC", [color=black]UInt, id, [/color]UInt, device)
	DllCall("gdi32.dll\DeleteDC", UInt, context)
	DllCall("gdi32.dll\DeleteObject", UInt, pixels)
}
/*  Usage:
 *  	Gets the pixel from a window capture created from Display_CreateWindowCapture
 *  Parameters:
 *  	context: the device context as given by Display_CreateWindowCapture
 *  	x, y: the coordinate parameters
 *  Return:
 *  	The pixel in BGR format.
 */
Display_GetPixel(ByRef context, x, y) {
	return DllCall("GetPixel", UInt, context, Int, x, Int, y)
}
/*  Usage:
 *  	Searches for the specifed color in the given rectangle of a window capture created from Display_CreateWindowCapture
 *  Parameters:
 *  	x, y, w, h: the rectangle parameters to search
 *  	color: the color in BGR format or one of:
 *  		BlueBackground, BlueForeground, GreenBackground, GreenForeground, RedBackground, RedForeground
 *  		CyanBackground, CyanForeground, YellowBackground, YellowForeground, VioletBackground, VioletForeground
 *  		DarkBackground, DarkForeground, LightBackground, LightForeground
 *  	variation: the allowed variation from the specified color
 *  	id: either a window id or the letter c followed by the device context handle as given by Display_CreateWindowCapture
 *  		if no id is specified, the Last Found Window will be used.
 *  Return:
 *  	Returns true if the specified color/variation is found within the given area, false otherwise.
 */
Display_PixelSearch(x, y, w, h, color, variation, ByRef id = "") {
	Display_GetContext(device, context, pixels, id)
	if color is not integer
		isPixel = Display_%color%
	Loop, %w% {
		j := y
		Loop, %h% {
			bgr := Display_GetPixel(context, x, j++)
			pixel := isPixel ? Display_IsPixel(isPixel, bgr, variation) : Display_CompareColors(bgr, color, variation)
			if pixel {
				if device
					Display_DeleteWindowCapture(device, context, pixels[color=black], id[/color])
				return true
			}
		}
		x++
	}
	if device
		Display_DeleteWindowCapture(device, context, pixels[color=black], id[/color])
	return false
}

Display_GetContext(ByRef device, ByRef context, ByRef pixels, ByRef id) {
	if !id
		Display_CreateWindowCapture(device, context, pixels)
	else if (SubStr(id, 1, 1) = "c")
		context := SubStr(id, 2)
	else
		Display_CreateWindowCapture(device, context, pixels, id)
}

Display_CompareColors(ByRef bgr1, ByRef bgr2, ByRef variation) {
	c1 := bgr1 & 0xff
	c2 := bgr2 & 0xff
	if (abs(c1 - c2) > variation)
		return false
	c1 := (bgr1 >> 8) & 0xff
	c2 := (bgr2 >> 8) & 0xff
	if (abs(c1 - c2) > variation)
		return false
	c1 := (bgr1 >> 16) & 0xff
	c2 := (bgr2 >> 16) & 0xff
	if (abs(c1 - c2) > variation)
		return false
	return true
}

Display_CompareRGBToBGR(ByRef rgb, ByRef bgr, ByRef variation) {
	c1 := (rgb >> 16) & 0xff
	c2 := bgr & 0xff
	if (abs(c1 - c2) > variation)
		return false
	c1 := (rgb >> 8) & 0xff
	c2 := (bgr >> 8) & 0xff
	if (abs(c1 - c2) > variation)
		return false
	c1 := rgb & 0xff
	c2 := (bgr >> 16) & 0xff
	if (abs(c1 - c2) > variation)
		return false
	return true
}

Display_IsBlue(ByRef bgr, ByRef variation) {
	r := bgr & 0xff
	g := (bgr >> 8) & 0xff
	b := ((bgr >> 16) & 0xff) - variation
	return b > r && b > g
}

Display_IsGreen(ByRef bgr, ByRef variation) {
	r := bgr & 0xff
	g := ((bgr >> 8) & 0xff) - variation
	b := (bgr >> 16) & 0xff
	return g > r && g > b
}

Display_IsRed(ByRef bgr, ByRef variation) {
	r := (bgr & 0xff) - variation
	g := (bgr >> 8) & 0xff
	b := (bgr >> 16) & 0xff
	return r > b && r > g
}

Display_IsCyan(ByRef bgr, ByRef variation) {
	g := (bgr >> 8) & 0xff
	if (r < 120)
		return false
	b := (bgr >> 16) & 0xff
	if (g < 120)
		return false
	d := abs(g-r)
	if (d > 32 + variation)
		return false
	d += (bgr & 0xff) + 16
	return r > d && g > d
}

Display_IsViolet(ByRef bgr, ByRef variation) {
	r := bgr & 0xff
	if (r < 120)
		return false
	b := (bgr >> 16) & 0xff
	if (g < 120)
		return false
	d := abs(g-r)
	if (d > 32 + variation)
		return false
	d += ((bgr >> 8) & 0xff) + 16
	return r > d && g > d
}

Display_IsYellow(ByRef bgr, ByRef variation) {
	r := bgr & 0xff
	if (r < 120)
		return false
	g := (bgr >> 8) & 0xff
	if (g < 120)
		return false
	d := abs(g-r)
	if (d > 32 + variation)
		return false
	d += ((bgr >> 16) & 0xff) + 16
	return r > d && g > d
}

Display_IsLight(ByRef bgr, ByRef variation) {
	c := (bgr & 0xff) - variation
	if (c < 200)
		return false
	c := ((bgr >> 8) & 0xff) - variation
	if (c < 200)
		return false
	c := ((bgr >> 16) & 0xff) - variation
	return c >= 200
}

Display_IsDark(ByRef bgr, ByRef variation) {
	c := (bgr & 0xff) - variation
	if (c < 100)
		return true
	c := ((bgr >> 8) & 0xff) - variation
	if (c < 100)
		return true
	c := ((bgr >> 16) & 0xff) - variation
	return c < 100
}

Display_FindPixelHorizontal(ByRef x, ByRef y, w, h, color, variation, ByRef context) {
	if color is not integer
		isPixel = Display_%color%
	Loop, %h% {
		i := x
		Loop, %w% {
			bgr := Display_GetPixel(context, i++, y)
			pixel := isPixel ? Display_IsPixel(isPixel, bgr, variation) : Display_CompareColors(bgr, color, variation)
			if pixel {
				x := i
				return true
			}
		}
		y++
	}
	y -= h
	return false
}

Display_FindPixelVertical(ByRef x, ByRef y, w, h, color, variation, ByRef context) {
	if color is not integer
		isPixel = Display_%color%
	Loop, %w% {
		i := y
		Loop, %h% {
			bgr := Display_GetPixel(context, x, i++)
			pixel := isPixel ? Display_IsPixel(isPixel, bgr, variation) : Display_CompareColors(bgr, color, variation)
			if pixel {
				y := i
				return true
			}
		}
		x++
	}
	x -= w
	return false
}
/*	Usage:
 *  	Updates the variables y and h based on the vertical position and height of the text found at x,y
 *  Parameters:
 *  	x: x position to start searching for text
 *  	y: y position where text will be found
 *  	w: maximum width to search
 *  	h: blank variable, will be updated with the correct height
 *  	color: a color in BGR format or one of the following:
 *  		BlueBackground - any color that is not a shade of blue will be recognized as text
 */
Display_FindText(ByRef x, ByRef y, ByRef w, ByRef h, color, variation, ByRef context) {
	if color is not integer
		isPixel = Display_%color%
	minX := x + w
	row := y
	GoSub, Display_FTFindTop
	top := row
	row := y+1
	column := x
	GoSub, Display_FTFindBottom
	y := top
	h := row - top + 2
	if (x != minX)
		minX -= 2
	w -= minX - x
	x := minX
	return
	Display_FTFindTop:
		column := x
		Loop, %w% {
			bgr := Display_GetPixel(context, column, row)
			pixel := isPixel ? Display_IsPixel(isPixel, bgr, variation) : Display_CompareColors(bgr, color, variation)
			if pixel {
				if (column < minX)
					minX := column
				row--
				GoTo, Display_FTFindTop
			}
			column++
		}
		return
	Display_FTFindBottom:
		column := x
		Loop, %w% {
			bgr := Display_GetPixel(context, column, row)
			pixel := isPixel ? Display_IsPixel(isPixel, bgr, variation) : Display_CompareColors(bgr, color, variation)
			if pixel {
				if (column < minX)
					minX := column
				row++
				GoTo, Display_FTFindBottom
			}
			column++
		}
		return
}

Display_IsPixel(ByRef label, ByRef bgr, ByRef variation) {
	GoSub, %label%
	return isPixel
	Display_BlueForeground:
		isPixel := Display_IsBlue(bgr, variation)
		return
	Display_BlueBackground:
		isPixel := !Display_IsBlue(bgr, variation)
		return
	Display_GreenForeground:
		isPixel := Display_IsGreen(bgr, variation)
		return
	Display_GreenBackground:
		isPixel := !Display_IsGreen(bgr, variation)
		return
	Display_RedForeground:
		isPixel := Display_IsRed(bgr, variation)
		return
	Display_RedBackground:
		isPixel := !Display_IsRed(bgr, variation)
		return
	Display_CyanForeground:
		isPixel := Display_IsCyan(bgr, variation)
		return
	Display_CyanBackground:
		isPixel := !Display_IsCyan(bgr, variation)
		return
	Display_YellowForeground:
		isPixel := Display_IsYellow(bgr, variation)
		return
	Display_YellowBackground:
		isPixel := !Display_IsYellow(bgr, variation)
		return
	Display_VioletForeground:
		isPixel := Display_IsViolet(bgr, variation)
		return
	Display_VioletBackground:
		isPixel := !Display_IsViolet(bgr, variation)
		return
	Display_DarkForeground:
		isPixel := Display_IsDark(bgr, variation)
		return
	Display_DarkBackground:
		isPixel := !Display_IsDark(bgr, variation)
		return
	Display_LightForeground:
		isPixel := Display_IsLight(bgr, variation)
		return
	Display_LightBackground:
		isPixel := !Display_IsLight(bgr, variation)
		return
}
/*  Usage:
 *  	This function has an empty map. That is, it won't read ANYTHING. You must specify the map by providing the necessary signature labels.
 *  Parameters:
 *  	x: The x position to start reading.
 *  	y: The y position to start reading.
 *  	w: The width to read from x.
 *  	h: The height to read from y.
 *  	color: The color to read in BGR format or one of the following:
 *  		BlueBackground, BlueForeground, GreenBackground, GreenForeground, RedBackground, RedForeground
 *  		CyanBackground, CyanForeground, YellowBackground, YellowForeground, VioletBackground, VioletForeground
 *  		DarkBackground, DarkForeground, LightBackground, LightForeground
 *  	variation: The variation allowed from the specified color to be considered part of the text.
 *  	id: The window id to read or alternatively, the letter c followed by the device context handle of an already created window capture.
 *  		If blank, the specified area will be read from the screen. Otherwise the area will be read from an offscreen capture of the window - this method is more reliable and usually faster than the former.
 */
Display_ReadArea(x, y, w, h, color = 0x000000, variation = 32, ByRef id = "", maxwidth = 0, exclude = "") {
	if !maxwidth
		maxwidth := h
	h2 := h * 2
	text := ""
	width := 0
	column := 1
	spaces := 0
	xi := x
	if exclude {
		prevPixel := true
		i := InStr(exclude, ",")
		if i
			StringSplit, exclude, exclude, `,
		else {
			exclude1 := exclude
			exclude2 := 0
		}
		if exclude1 is not integer
			isNotPixel = Display_%exclude1%
	}
	if color is not integer
		isPixel = Display_%color%
	if id {
		if (SubStr(id, 1, 1) = "c") {
			context := SubStr(id, 2)
		} else {
			Display_CreateWindowCapture(device, context, pixels, id)
		}
		GoSub, Display_SetPixels
		if device
			Display_DeleteWindowCapture(device, context, pixels[color=black], id[/color])
	} else {
		GoSub, Display_SetPixels
	}
	if replaceColon {
		StringGetPos, i, text, `;, R
		if (i == StrLen(text) - 3) {
			text := SubStr(text, 1, i) . "." . SubStr(text, i+2)
		}
		StringReplace, text, text, `;, `,, All
	}
	return text
	Display_SetPixels:
		Loop, %w% {
			yi := y
			Loop, %h% {
				if context
					bgr := DllCall("GetPixel", UInt, context, Int, xi, Int, yi++)
				else
					PixelGetColor, bgr, xi, yi++
				row := A_Index
				pixel := isPixel ? Display_IsPixel(isPixel, bgr, variation) : Display_CompareColors(bgr, color, variation)
				if exclude {
					if (pixel && !prevPixel) {
						pixel := !(isNotPixel ? Display_IsPixel(isNotPixel, bgr, exclude2) : Display_CompareColors(bgr, exclude1, exclude2))
					}
					prevPixel := pixel
				}
				pixels%column%_%row% := pixel
			}
			xi++
			; Check if column has any pixels or if the pixels are not continuous with the previous column
			row = 0
			GoSub, Display_NextSetPixel
			if !row {
				isBreak := 1
			} else if !width {
				isBreak := 0
			} else {
				Loop {
					c := column - 1
					if (pixels%c%_%row%
							|| (--row >= 0 && pixels%c%_%row%)
							|| ((row+=2) < h && pixels%c%_%row%)) {
						isBreak := 0
						break
					}
					GoSub, Display_NextSetPixel
					if !row {
;						width += 1
						isBreak := 2
						break
					}
				}
			}
			if isBreak {
				if width {
					if (isBreak > 1)
						xi--
					GoSub, Display_ReadDigit
					spaces := 0
				} else {
					if (text && ++spaces > h2) {
						return
					}
				}
				width := 0
				column := 1
			} else {
				if (++width >= maxwidth) {
					GoSub, Display_ReadDigit
					spaces := 0
					width := 0
					column := 1
				} else {
					column++
				}
			}
		}
		return
	Display_ReadDigit:
		top := h
		bottom := 0
		Loop, %h% {
			r := A_Index
			Loop, %width% {
				if pixels%A_Index%_%r% {
					top := r
					GoTo, Display_FoundTop
				}
			}
		}
		Display_FoundTop:
		r := h
		Loop, %h% {
			Loop, %width% {
				if pixels%A_Index%_%r% {
					bottom := r
					GoTo, Display_FoundBottom
				}
			}
			r--
		}
		Display_FoundBottom:
		signature = Display_
		ht := Round((bottom - top) / 10)
		wh := Round(width / 10)
		c := 1
		GoSub, Display_SetColumnSequences
		c := width - wh
		GoSub, Display_SetColumnSequences
		r := top
		GoSub, Display_SetRowSequences
		r := bottom - ht
		GoSub, Display_SetRowSequences
		if IsLabel(signature)
			GoSub, %signature%
		else
			text .= " "
; println(signature . " " . xi . " " . width)
		return
	Display_SetColumnSequences:
		sequences := 0
		last := false
		set := 0
		sig = 
		Loop, %h% {
			i := A_Index
			isSet := pixels%c%_%i%
			if (!isSet && wh) {
				c2 := c
				Loop {
					c2++
					isSet := pixels%c2%_%i%
					if (isSet || A_Index >= wh)
						break
				}
			}
			if (isSet != last) {
				last := isSet
				if (isSet) {
					set := i
				} else {
					sequences += 1
					clear := i - 1
					sig .= set == top ? (clear == bottom ? "D" : "A") : clear == bottom ? "C" : "B"
				}
			}
		}
		if (last) {
			sequences += 1
			sig .= set == top ? "D" : "C"
		}
		signature .= sequences . sig
		return
	Display_SetRowSequences:
		sequences := 0
		last := false
		set := 0
		sig = 
		t := width
		Loop, %width% {
			i := A_Index
			isSet := pixels%i%_%r%
			if (!isSet && ht) {
				r2 := r
				Loop {
					r2++
					isSet := pixels%i%_%r2%
					if (isSet || A_Index >= ht)
						break
				}
			}
			if (isSet != last) {
				last := isSet
				if (isSet) {
					set := i
				} else {
					sequences += 1
					clear := i - 1
					sig .= set == 1 ? (clear == t ? "D" : "A") : clear == t ? "C" : "B"
				}
			}
		}
		if (last) {
			sequences += 1
			sig .= set == 1 ? "D" : "C"
		}
		signature .= sequences . sig
		return
	Display_NextSetPixel:
		Loop {
			if (++row > h)
				break
			if pixels%column%_%row%
				return
		}
		row = 0
		return
	Display_NextClearPixel:
		Loop {
			if (++row > h)
				break
			if !pixels%column%_%row%
				return
		}
		row = 0
		return
	Display_NextSetPixelH:
		Loop {
			if (++column > width)
				break
			if pixels%column%_%row%
				return
		}
		column = 0
		return
	Display_NextClearPixelH:
		Loop {
			if (++column > width)
				break
			if !pixels%column%_%row%
				return
		}
		column = 0
		return
	; example map:
	/*
	Display_2BB2BB1B1A:
	Display_2AB2AB1D1B:
		text .= "$"
		return
	*/
}


