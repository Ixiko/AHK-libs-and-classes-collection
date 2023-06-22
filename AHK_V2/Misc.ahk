/*
	Name: Misc.ahk
	Version 0.2 (15.10.22)
	Created: 26.08.22
	Author: Descolada (https://www.autohotkey.com/boards/viewtopic.php?f=83&t=107759)
    Credit: Coco

	Range(stop)						=> Returns an iterable to count from 1..stop
	Range(start, stop [, step])		=> Returns an iterable to count from start to stop with step
	Swap(&a, &b)					=> Swaps the values of a and b
	Print(value?, func?, newline?) 	=> Prints the formatted value of a variable (number, string, array, map, object)
	RegExMatchAll(haystack, needleRegEx [, startingPosition := 1])
	    Returns all RegExMatch results (RegExMatchInfo objects) for needleRegEx in haystack 
		in an array: [RegExMatchInfo1, RegExMatchInfo2, ...]
	Highlight(x?, y?, w?, h?, showTime:=0, color:="Red", d:=2)
		Highlights an area with a colorful border.
	MouseTip(x?, y?, color1:="red", color2:="blue", d:=4)
		Flashes a colorful highlight at a point for 2 seconds.
	WindowFromPoint(X, Y) 			=> Returns the window ID at screen coordinates X and Y.
	ConvertWinPos(X, Y, &outX, &outY, relativeFrom:=A_CoordModeMouse, relativeTo:="screen", winTitle?, winText?, excludeTitle?, excludeText?)
		Converts coordinates between screen, window and client.
*/

/**
 * Returns a sequence of numbers, starting from 1 by default, 
 * and increments by step 1 (by default), 
 * and stops at a specified end number.
 * Can be converted to an array with the method ToArray()
 * @param start The number to start with, or if 'end' is omitted then the number to end with
 * @param end The number to end with
 * @param step Optional: a number specifying the incrementation. Default is 1.
 * @returns {Iterable}
 * @example 
 * for v in Range(5)
 *     Print(v) ; Outputs "1 2 3 4 5"
 */
class Range {
	__New(start, end?, step:=1) {
		if !step
			throw TypeError("Invalid 'step' parameter")
		if !IsSet(end)
			end := start, start := 1
		if (end < start) && (step > 0)
			step := -step
		this.start := start, this.end := end, this.step := step
	}
	__Enum(varCount) {
		start := this.start - this.step, end := this.end, step := this.step, counter := 0
		EnumElements(&element) {
			start := start + step
			if ((step > 0) && (start > end)) || ((step < 0) && (start < end))
				return false
			element := start
			return true
		}
		EnumIndexAndElements(&index, &element) {
			start := start + step
			if ((step > 0) && (start > end)) || ((step < 0) && (start < end))
				return false
			index := ++counter
			element := start
			return true
		}
		return (varCount = 1) ? EnumElements : EnumIndexAndElements
	}
	/**
	 * Converts the iterable into an array.
	 * @returns {Array}
	 * @example
	 * Range(3).ToArray() ; returns [1,2,3]
	 */
	ToArray() {
		r := []
		for v in this
			r.Push(v)
		return r
	}
}

/**
 * Swaps the values of two variables
 * @param a First variable
 * @param b Second variable
 */
Swap(&a, &b) {
	temp := a
	a := b
	b := temp
}

/**
 * Prints the formatted value of a variable (number, string, object).
 * Leaving all parameters empty will return the current function and newline in an Array: [func, newline]
 * @param value Optional: the variable to print. 
 *     If omitted then new settings (output function and newline) will be set.
 *     If value is an object/class that has a ToString() method, then the result of that will be printed.
 * @param func Optional: the print function to use. Default is OutputDebug.
 *     Not providing a function will cause the Print output to simply be returned as a string.
 * @param newline Optional: the newline character to use (applied to the end of the value). 
 *     Default is newline (`n).
 */
Print(value?, func?, newline?) {
	static p := OutputDebug, nl := "`n"
	if IsSet(func)
		p := func
	if IsSet(newline)
		nl := newline
	if IsSet(value) {
		val := IsObject(value) ? ToString(value) nl : value nl
		return HasMethod(p) ? p(val) : val
	}
	return [p, nl]
}

/**
 * Converts a value (number, array, object) to a string.
 * Leaving all parameters empty will return the current function and newline in an Array: [func, newline]
 * @param value Optional: the value to convert. 
 * @returns {String}
 */
ToString(val?) {
    if !IsSet(val)
        return "unset"
    valType := Type(val)
    switch valType, 0 {
        case "String":
            return "'" val "'"
        case "Integer", "Float":
            return val
        default:
            self := "", iter := "", out := ""
            try self := ToString(val.ToString()) ; if the object has ToString available, print it
            if valType != "Array" { ; enumerate object with key and value pair, except for array
                try {
                    enum := val.__Enum(2) 
                    while (enum.Call(&val1, &val2))
                        iter .= ToString(val1) ":" ToString(val2?) ", "
                }
            }
            if !IsSet(enum) { ; if enumerating with key and value failed, try again with only value
                try {
                    enum := val.__Enum(1)
                    while (enum.Call(&enumVal))
                        iter .= ToString(enumVal?) ", "
                }
            }
            if !IsSet(enum) && (valType = "Object") && !self { ; if everything failed, enumerate Object props
                for k, v in val.OwnProps()
                    iter .= SubStr(ToString(k), 2, -1) ":" ToString(v?) ", "
            }
            iter := SubStr(iter, 1, StrLen(iter)-2)
            if !self && !iter && !((valType = "Array" && val.Length = 0) || (valType = "Map" && val.Count = 0) || (valType = "Object" && ObjOwnPropCount(val) = 0))
                return valType ; if no additional info is available, only print out the type
            else if self && iter
                out .= "value:" self ", iter:[" iter "]"
            else
                out .= self iter
            return (valType = "Object") ? "{" out "}" : (valType = "Array") ? "[" out "]" : valType "(" out ")"
    }
}

/**
 * Returns all RegExMatch results in an array: [RegExMatchInfo1, RegExMatchInfo2, ...]
 * @param haystack The string whose content is searched.
 * @param needleRegEx The RegEx pattern to search for.
 * @param startingPosition If StartingPos is omitted, it defaults to 1 (the beginning of haystack).
 * @returns {Array}
 */
RegExMatchAll(haystack, needleRegEx, startingPosition := 1) {
	out := []
	While startingPosition := RegExMatch(haystack, needleRegEx, &outputVar, startingPosition) {
		out.Push(outputVar), startingPosition += outputVar[0] ? StrLen(outputVar[0]) : 1
	}
	return out
}

/**
 * Highlights an area with a colorful border.
 * @param x Screen X-coordinate of the top left corner of the highlight
 * @param y Screen Y-coordinate of the top left corner of the highlight
 * @param w Width of the highlight
 * @param h Height of the highlight
 * @param showTime Can be one of the following:
 *     0 - removes the highlighting
 *     Positive integer (eg 2000) - will highlight and pause for the specified amount of time in ms
 *     Negative integer - will highlight for the specified amount of time in ms, but script execution will continue
 * @param color The color of the highlighting. Default is red.
 * @param d The border thickness of the highlighting in pixels. Default is 2.
 */
Highlight(x?, y?, w?, h?, showTime:=0, color:="Red", d:=2) {
	static guis := []
	if !IsSet(x) {
        for _, r in guis
            r.Destroy()
        guis := []
		return
    }
    if !guis.Length {
        Loop 4
            guis.Push(Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000"))
    }
	Loop 4 {
		i:=A_Index
		, x1:=(i=2 ? x+w : x-d)
		, y1:=(i=3 ? y+h : y-d)
		, w1:=(i=1 or i=3 ? w+2*d : d)
		, h1:=(i=2 or i=4 ? h+2*d : d)
		guis[i].BackColor := color
		guis[i].Show("NA x" . x1 . " y" . y1 . " w" . w1 . " h" . h1)
	}
	if showTime > 0 {
		Sleep(showTime)
		Highlight()
	} else if showTime < 0
		SetTimer(Highlight, -Abs(showTime))
}

/**
 * Flashes a colorful highlight at a point for 2 seconds.
 * @param x Screen X-coordinate for the highlight
 *     Omit x or y to highlight the current cursor position.
 * @param y Screen Y-coordinate for the highlight
 * @param color1 First color for the highlight. Default is red.
 * @param color2 Second color for the highlight. Default is blue.
 * @param d The border thickness of the highlighting in pixels. Default is 2.
 */
MouseTip(x?, y?, color1:="red", color2:="blue", d:=4) {
	If !(IsSet(x) && IsSet(y))
		MouseGetPos(&x, &y)
	Loop 2 {
		Highlight(x-10, y-10, 20, 20, 500, color1, d)
		Highlight(x-10, y-10, 20, 20, 500, color2, d)
	}
	Highlight()
}

/**
 * Returns the window ID at screen coordinates X and Y. 
 * @param X Screen X-coordinate of the point
 * @param Y Screen Y-coordinate of the point
 */
WindowFromPoint(X, Y) { ; by SKAN and Linear Spoon
	return DllCall("GetAncestor", "UInt", DllCall("user32.dll\WindowFromPoint", "Int64", Y << 32 | X), "UInt", 2)
}

/**
 * Converts coordinates between screen, window and client.
 * @param X X-coordinate to convert
 * @param Y Y-coordinate to convert
 * @param outX Variable where to store the converted X-coordinate
 * @param outY Variable where to store the converted Y-coordinate
 * @param relativeFrom CoordMode where to convert from. Default is A_CoordModeMouse.
 * @param relativeTo CoordMode where to convert to. Default is Screen.
 * @param winTitle A window title or other criteria identifying the target window. 
 * @param winText If present, this parameter must be a substring from a single text element of the target window.
 * @param excludeTitle Windows whose titles include this value will not be considered.
 * @param excludeText Windows whose text include this value will not be considered.
 */
ConvertWinPos(X, Y, &outX, &outY, relativeFrom:="", relativeTo:="screen", winTitle?, winText?, excludeTitle?, excludeText?) {
	relativeFrom := (relativeFrom == "") ? A_CoordModeMouse : relativeFrom
	if relativeFrom = relativeTo {
		outX := X, outY := Y
		return
	}
	hWnd := WinExist(winTitle?, winText?, excludeTitle?, excludeText?)

	switch relativeFrom, 0 {
		case "screen", "s":
			if relativeTo = "window" || relativeTo = "w" {
				DllCall("user32\GetWindowRect", "Int", hWnd, "Ptr", RECT := Buffer(16))
				outX := X-NumGet(RECT, 0, "Int"), outY := Y-NumGet(RECT, 4, "Int")
			} else { 
				; screen to client
				pt := Buffer(8), NumPut("int",X,pt), NumPut("int",Y,pt,4)
				DllCall("ScreenToClient", "Int", hWnd, "Ptr", pt)
				outX := NumGet(pt,0,"int"), outY := NumGet(pt,4,"int")
			}
		case "window", "w":
			; window to screen
			WinGetPos(&outX, &outY,,,hWnd)
			outX += X, outY += Y
			if relativeTo = "client" || relativeTo = "c" {
				; screen to client
				pt := Buffer(8), NumPut("int",outX,pt), NumPut("int",outY,pt,4)
				DllCall("ScreenToClient", "Int", hWnd, "Ptr", pt)
				outX := NumGet(pt,0,"int"), outY := NumGet(pt,4,"int")
			}
		case "client", "c":
			; client to screen
			pt := Buffer(8), NumPut("int",X,pt), NumPut("int",Y,pt,4)
			DllCall("ClientToScreen", "Int", hWnd, "Ptr", pt)
			outX := NumGet(pt,0,"int"), outY := NumGet(pt,4,"int")
			if relativeTo = "window" || relativeTo = "w" { ; screen to window
				DllCall("user32\GetWindowRect", "Int", hWnd, "Ptr", RECT := Buffer(16))
				outX -= NumGet(RECT, 0, "Int"), outY -= NumGet(RECT, 4, "Int")
			}
	}
}

/**
 * Gets the position of the caret with UIA, Acc or CaretGetPos.
 * Credit: plankoe (https://www.reddit.com/r/AutoHotkey/comments/ysuawq/get_the_caret_location_in_any_program/)
 * @param X Value is set to the screen X-coordinate of the caret
 * @param Y Value is set to the screen Y-coordinate of the caret
 * @param W Value is set to the width of the caret
 * @param H Value is set to the height of the caret
 */
GetCaretPos(&X?, &Y?, &W?, &H?) {
    ; UIA2 caret
    static IUIA := ComObject("{e22ad333-b25f-460c-83d0-0581107395c9}", "{34723aff-0c9d-49d0-9896-7ab52df8cd8a}")
    try {
        ComCall(8, IUIA, "ptr*", &FocusedEl:=0) ; GetFocusedElement
        ComCall(16, FocusedEl, "int", 10024, "ptr*", &patternObject:=0), ObjRelease(FocusedEl) ; GetCurrentPattern. TextPatternElement2 = 10024
        if patternObject {
            ComCall(10, patternObject, "int*", &IsActive:=1, "ptr*", &caretRange:=0), ObjRelease(patternObject) ; GetCaretRange
            ComCall(10, caretRange, "ptr*", &boundingRects:=0), ObjRelease(caretRange) ; GetBoundingRectangles
            if (Rect := ComValue(0x2005, boundingRects)).MaxIndex() = 3 { ; VT_ARRAY | VT_R8
                X:=Round(Rect[0]), Y:=Round(Rect[1]), W:=Round(Rect[2]), H:=Round(Rect[3])
                return
            }
        }
    }

    ; Acc caret
    static _ := DllCall("LoadLibrary", "Str","oleacc", "Ptr")
    try {
        idObject := 0xFFFFFFF8 ; OBJID_CARET
        if DllCall("oleacc\AccessibleObjectFromWindow", "ptr", WinExist("A"), "uint",idObject &= 0xFFFFFFFF
            , "ptr",-16 + NumPut("int64", idObject == 0xFFFFFFF0 ? 0x46000000000000C0 : 0x719B3800AA000C81, NumPut("int64", idObject == 0xFFFFFFF0 ? 0x0000000000020400 : 0x11CF3C3D618736E0, IID := Buffer(16)))
            , "ptr*", oAcc := ComValue(9,0)) = 0 {
            x:=Buffer(4), y:=Buffer(4), w:=Buffer(4), h:=Buffer(4)
            oAcc.accLocation(ComValue(0x4003, x.ptr, 1), ComValue(0x4003, y.ptr, 1), ComValue(0x4003, w.ptr, 1), ComValue(0x4003, h.ptr, 1), 0)
            X:=NumGet(x,0,"int"), Y:=NumGet(y,0,"int"), W:=NumGet(w,0,"int"), H:=NumGet(h,0,"int")
            if (X | Y) != 0
                return
        }
    }

    ; Default caret
    savedCaret := A_CoordModeCaret, W := 4, H := 20
    CoordMode "Caret", "Screen"
    CaretGetPos(&X, &Y)
    CoordMode "Caret", savedCaret
}

/**
 * Checks whether two rectangles intersect and if they do, then returns an object containing the
 * rectangle of the intersection: {l:left, t:top, r:right, b:bottom}
 * Note 1: Overlapping area must be at least 1 unit. 
 * Note 2: Second rectangle starting at the edge of the first doesn't count as intersecting:
 *     {l:100, t:100, r:200, b:200} does not intersect {l:200, t:100, 400, 400}
 * @param l1 x-coordinate of the upper-left corner of the first rectangle
 * @param t1 y-coordinate of the upper-left corner of the first rectangle
 * @param r1 x-coordinate of the lower-right corner of the first rectangle
 * @param b1 y-coordinate of the lower-right corner of the first rectangle
 * @param l2 x-coordinate of the upper-left corner of the second rectangle
 * @param t2 y-coordinate of the upper-left corner of the second rectangle
 * @param r2 x-coordinate of the lower-right corner of the second rectangle
 * @param b2 y-coordinate of the lower-right corner of the second rectangle
 * @returns {Object}
 */
IntersectRect(l1, t1, r1, b1, l2, t2, r2, b2) {
	rect1 := Buffer(16), rect2 := Buffer(16), rectOut := Buffer(16)
	NumPut("int", l1, "int", t1, "int", r1, "int", b1, rect1)
	NumPut("int", l2, "int", t2, "int", r2, "int", b2, rect2)
	if DllCall("user32\IntersectRect", "Ptr", rectOut, "Ptr", rect1, "Ptr", rect2)
		return {l:NumGet(rectOut, 0, "Int"), t:NumGet(rectOut, 4, "Int"), r:NumGet(rectOut, 8, "Int"), b:NumGet(rectOut, 12, "Int")}
}