;============== Function ======================================================;

;* CreateCursorInfo()
;* Description:
	;* Contains global cursor information.
CreateCursorInfo(flags := 0, cursor := 0, screenPos := 0) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-cursorinfo
	if (!screenPos) {
		screenPos := CreatePoint(0, 0, "UInt")
	}

	(s := new Structure(16 + A_PtrSize)).NumPut(0, "UInt", 16 + A_PtrSize, "UInt", flags, "Ptr", cursor, "Struct", screenPos)

    return (s)
}  ;? CURSORINFO, *PCURSORINFO, *LPCURSORINFO;

;* CreateSecurityDescriptor()
;* Description:
	;* The SECURITY_DESCRIPTOR structure contains the security information associated with an object. Applications use this structure to set and query an object's security status.
CreateSecurityDescriptor() {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-security_descriptor
	s := new Structure(8 + A_PtrSize*4 - 4*(A_PtrSize == 4))

    return (s)
}  ;? SECURITY_DESCRIPTOR, *PISECURITY_DESCRIPTOR;

;* CreateGDIplusStartupInput()
;* Description:
	;* The GdiplusStartupInput structure holds a block of arguments that are required by the GdiplusStartup function.
CreateGDIplusStartupInput() {  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusinit/ns-gdiplusinit-gdiplusstartupinput
	(s := new Structure(8 + A_PtrSize*2)).NumPut(0, "UInt", 0x1)

    return (s)
}

;* CreateConsoleReadConsoleControl(initialChars, ctrlWakeupMask, controlKeyState)
;* Description:
	;* Contains information for a console read operation.
;* Parameters:
	;* ctrlWakeupMask
		;* *: https://www.asciitable.com/
CreateConsoleReadConsoleControl(initialChars := 0, ctrlWakeupMask := 0x0A, controlKeyState := 0) {  ;: https://docs.microsoft.com/en-us/windows/console/console-readconsole-control
	(s := new Structure(16)).NumPut(0, "UInt", 16, "UInt", initialChars, "UInt", ctrlWakeupMask, "UInt", controlKeyState)

    return (s)
}  ;? CONSOLE_READCONSOLE_CONTROL, *PCONSOLE_READCONSOLE_CONTROL;

;* CreateSmallRect((x), (y), (width), (height))
;* Description:
	;* Defines the coordinates of the upper left and lower right corners of a rectangle.
CreateSmallRect(x := 0, y := 0, width := 0, height := 0) {  ;: https://docs.microsoft.com/en-us/windows/console/small-rect-str
	(s := new Structure(8)).NumPut(0, "Short", x, "Short", y, "Short", x + width - 1, "Short", y + height - 1)

    return (s)
}  ;? SMALL_RECT;

;* CreateCoord((x), (y))
;* Description:
	;* Defines the coordinates of a character cell in a console screen buffer. The origin of the coordinate system (0,0) is at the top, left cell of the buffer.
CreateCoord(x := 0, y := 0) {  ;: https://docs.microsoft.com/en-us/windows/console/coord-str
	(s := new Structure(4)).NumPut(0, "Short", x, "Short", y)

    return (s)
}  ;? COORD, *PCOORD;

;* CreatePoint((x), (y), (type))
;* Description:
	;* The POINT structure defines the x- and y-coordinates of a point.
CreatePoint(x := 0, y := 0, type := "UInt") {  ;: https://docs.microsoft.com/en-us/windows/win32/api/windef/ns-windef-point
	b := Structure.ValidateType(type)
		, (s := new Structure(b*2)).NumPut(0, type, x, type, y)

    return (s)
}  ;? POINT, *PPOINT, *NPPOINT, *LPPOINT;

;* CreateRect((x), (y), (width), (height), (type))
;* Description:
	;* The RECT structure defines a rectangle by the coordinates of its upper-left and lower-right corners.
CreateRect(x := 0, y := 0, width := 0, height := 0, type := "UInt") {  ;: https://docs.microsoft.com/en-us/windows/win32/api/windef/ns-windef-rect
	b := Structure.ValidateType(type)
		, (s := new Structure(b*4)).NumPut(0, type, x, type, y, type, width, type, height)

	return (s)
}  ;? RECT, *PRECT, *NPRECT, *LPRECT;

;* CreateBitmapData((width), (height), (stride), (pixelFormat), (scan0))
;* Description:
	;* The BitmapData class stores attributes of a bitmap.
CreateBitmapData(width := 0, height := 0, stride := 0, pixelFormat := 0x26200A, scan0 := 0) {  ;: https://docs.microsoft.com/en-us/previous-versions/ms534421(v=vs.85)
	(s := new Structure(16 + A_PtrSize*2)).NumPut(0, "UInt", width, "UInt", height, "Int", stride, "Int", pixelFormat, "Ptr", scan0)

	return (s)
}  ;? BITMAPDATA;

;* CreateBitmapInfo([BITMAPINFOHEADER] bmiHeader, [RGBQUAD] bmiColors)
;* Description:
	;* The BITMAPINFO structure defines the dimensions and color information for a DIB.
CreateBitmapInfo(bmiHeader, bmiColors) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfo
	return (new Structure(bmiHeader, bmiColors))
}  ;? BITMAPINFO, *LPBITMAPINFO, *PBITMAPINFO;

;* CreateBitmapInfoHeader(width, height, (bitCount), (compression), (sizeImage), (xPelsPerMeter), (yPelsPerMeter), (clrUsed), (clrImportant))
;* Description:
	;* The BITMAPINFOHEADER structure contains information about the dimensions and color format of a DIB.
CreateBitmapInfoHeader(width, height, bitCount := 32, compression := 0x0000, sizeImage := 0, xPelsPerMeter := 0, yPelsPerMeter := 0, clrUsed := 0, clrImportant := 0) {  ;: https://docs.microsoft.com/en-us/previous-versions/dd183376(v=vs.85)
	s := new Structure("UInt", 40, "Int", width, "Int", height, "UShort", 1, "UShort", bitCount, "UInt", compression, "UInt", sizeImage, "Int", xPelsPerMeter, "Int", yPelsPerMeter, "UInt", clrUsed, "UInt", clrImportant)

	return (s)
}  ;? BITMAPINFOHEADER, *PBITMAPINFOHEADER;

;* CreateBlendFunction((sourceConstantAlpha), (alphaFormat))
;* Description:
	;* The BLENDFUNCTION structure controls blending by specifying the blending functions for source and destination bitmaps.
CreateBlendFunction(sourceConstantAlpha := 255, alphaFormat := 1) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-blendfunction, https://www.teamdev.com/downloads/jniwrapper/winpack/javadoc/constant-values.html#com.jniwrapper.win32.gdi.BlendFunction.AC_SRC_OVER
	(s := new Structure(4)).NumPut(2, "UChar", sourceConstantAlpha, "UChar", alphaFormat)  ;* ** When the AlphaFormat member is AC_SRC_ALPHA, the source bitmap must be 32 bpp. If it is not, the AlphaBlend function will fail. **

	return (s)
}  ;? BLENDFUNCTION, *PBLENDFUNCTION;

;* CreateRGBQuad((rgbBlue), (rgbGreen), (rgbRed))
;* Description:
	;* The RGBQUAD structure describes a color consisting of relative intensities of red, green, and blue.
CreateRGBQuad(blue := 0, green := 0, red := 0) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-rgbquad#members
	(s := new Structure(4)).NumPut(0, "UChar", blue, "UChar", green, "UChar", red)

	return (s)
}  ;? RGBQUAD;

;* CreateSize(width, height)
;* Description:
	;* The SIZE structure specifies the width and height of a rectangle.
CreateSize(width, height) {  ;: https://docs.microsoft.com/en-us/previous-versions//dd145106(v=vs.85)
	(s := new Structure(8)).NumPut(0, "Int", width, "Int", height)

	return (s)
}  ;? SIZE, *PSIZE;

;===============  Class  =======================================================;

Class Structure {
	Static Heap := DllCall("Kernel32\GetProcessHeap", "Ptr")  ;! DllCall("Kernel32\HeapCreate", "UInt", 0x00000004, "Ptr", 0, "Ptr", 0, "Ptr")

	;* new Structure(bytes)
	;* new Structure((type, value)*)
	__New(params*) {
		Local

		if (params.Count() <= 1) {  ;* Single `bytes` parameter.
			bytes := params[1]

			if (!(bytes == Round(bytes) && bytes >= 0)) {  ;~ Possible to create a struct of zero bytes.
				throw (Exception("Invalid Assignment", -1, Format("""{}"" is invalid. This value must be a non negative integer.", Print(bytes))))
			}

			return ({"Ptr": DllCall("Kernel32\HeapAlloc", "Ptr", this.Heap, "UInt", 0x00000008, "Ptr", bytes, "Ptr")  ;* ** Heap allocations made by calling the malloc and HeapAlloc functions are non-executable. **

				, "Base": this.__Structure})
		}
		else {
			switch (RegExReplace(params[1].__Class, "S).*?\.(?!.*?\..*?)")) {
				case "__Array": {
					return (this.CreateFromArray(params[1], params[2]))
				}
				case "__Structure": {
					return (this.CreateFromStruct(params*))
				}
				Default: {
					loop, % (params.Length()//2, bytes := 0) {  ;* Calculate the total size for everything to be added.
						index := A_Index*2
							, type := params[index - 1]

						if (type == "Struct") {
							bytes += params[index].Size
						}
						else {
							if (!size := this.ValidateType(type)) {
								throw (Exception("!!!"))
							}

							bytes += size
						}
					}

					(instance := {"Ptr": DllCall("Kernel32\HeapAlloc", "Ptr", this.Heap, "UInt", 0, "Ptr", bytes, "Ptr")

						, "Base": this.__Structure}).NumPut(0, params*)

					return (instance)
				}
			}
		}
	}

	CreateFromArray(array, type := "UInt") {
		Local

		if (!this.ValidateType(type)) {
			throw (Exception("!!!"))
		}

		for index, value in (array, size := this.SizeOf(type), struct := new this(array.Length*size), pointer := struct.Ptr) {
			NumPut(value, pointer + size*index, type)
		}

		return (struct)
	}

	CreateFromStruct(params*) {
		Local

		for i, struct in (params, bytes := 0) {
			if ((size := struct.Size) == "") {
				throw (Exception("!!!"))
			}

			bytes += size
		}

		for i, struct in (params, pointer := (instance := new this(bytes)).Ptr) {
			size := struct.Size

			DllCall("NtDll\RtlCopyMemory", "Ptr", pointer, "Ptr", struct.Ptr, "Ptr", size), pointer += size
		}

		return (instance)
	}

	SizeOf(type) {
		Static sizeLookup := {"Char": 1, "UChar": 1, "Short": 2, "UShort": 2, "Float": 4, "Int": 4, "UInt": 4, "Int64": 8, "UInt64": 8, "Ptr": A_PtrSize, "UPtr": A_PtrSize}

		return (sizeLookup[type])
	}

	ValidateType(type) {
		Local

		if (!size := this.SizeOf(type)) {
			throw (Exception("Critical Failue", -2, "ValidateType failed."))
		}

		return (size)
	}

	Class __Structure {

		__Delete() {
			DllCall("Kernel32\HeapFree", "Ptr", Structure.Heap, "UInt", 0, "Ptr", this.Ptr, "UInt")
		}

		Size[] {
			Get {
				return (DllCall("Kernel32\HeapSize", "Ptr", Structure.Heap, "UInt", 0, "Ptr", this.Ptr, "Ptr"))
			}

			Set {
				if (!(this.Ptr := DllCall("Kernel32\HeapReAlloc", "Ptr", Structure.Heap, "UInt", 0x00000008, "Ptr", this.Ptr, "Ptr", value, "Ptr"))) {  ;* ** If HeapReAlloc fails, the original memory is not freed, and the original handle and pointer are still valid. **
					throw (Exception("Critical Failue", -1, Format("Kernel32\HeapReAlloc failed to allocate memory.")))
				}

				return (value)
			}
		}

		NumGet(offset, type, bytes := 0) {
			if (!(offset == Round(offset) && offset >= 0)) {
				throw (Exception("Invalid Assignment", -1, Format("""{}"" is invalid. This value must be a non negative integer.", offset)))
			}

			if (type == "Struct" && bytes == Round(bytes) && bytes >= 0) {  ;* Create and return a new struct from a slice of another.
				if (offset + bytes < this.Size) {  ;* Ensure that the memory from `offset` to `offset + bytes` is part of this struct.
					struct := new Structure(bytes)
					DllCall("NtDll\RtlCopyMemory", "Ptr", struct.Ptr, "Ptr", this.Ptr + offset, "Ptr", bytes)

					return (struct)
				}

				return  ;~ No error handling.
			}

			return (NumGet(this.Ptr + offset, type))
		}

		NumPut(offset, params*) {
			if (!(offset == Round(offset) && offset >= 0)) {
				throw (Exception("Invalid Assignment", -1, Format("""{}"" is invalid. This value must be a non negative integer.", offset)))
			}

			loop, % (params.Length()//2, pointer := this.Ptr) {
				index := A_Index*2
					, type := params[index - 1], value := params[index]

				if (type == "Struct") {
					size := value.Size, limit := this.Size - offset
						, bytes := (size > limit) ? (limit) : (size)  ;* Ensure that there is capacity left after accounting for the offset. It is entirely possible to insert a type that exceeds 2 bytes in size into the last 2 bytes of this struct's memory however, thereby corrupting the value.

					if (bytes) {
						DllCall("NtDll\RtlCopyMemory", "Ptr", pointer + offset, "Ptr", value.Ptr, "Ptr", bytes), offset += bytes
					}
				}
				else {
					Static sizeLookup := {"Char": 1, "UChar": 1, "Short": 2, "UShort": 2, "Float": 4, "Int": 4, "UInt": 4, "Int64": 8, "UInt64": 8, "Ptr": A_PtrSize, "UPtr": A_PtrSize}

					size := sizeLookup[type], limit := this.Size - offset
						, bytes := (size > limit) ? (limit) : (size)

					if (bytes - size == 0) {
						NumPut(value, pointer + offset, type), offset += bytes
					}
				}
			}

			return (offset)  ;* Similar to `Push()` returning position of the last inserted value.
		}

		StrGet(length := "", encoding := "") {
			if (length) {
				return (StrGet(this.Ptr, length, encoding))
			}

			return (StrGet(this.Ptr))
		}

		ZeroMemory(bytes := 0) {
			Local

			size := this.Size
				, bytes := (bytes) ? ((bytes > size) ? (size) : (bytes)) : (this.Size)

			DllCall("Ntdll\RtlZeroMemory", "Ptr", this.Ptr, "Ptr", bytes)
		}
	}
}