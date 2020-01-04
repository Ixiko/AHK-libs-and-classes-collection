; ================================================================================================================================
; Function:			API_GetWindowInfo() 
;						 Get an object containing the values of the WINDOWINFO structure from DllCall("GetWindowInfo")
; AHK version:		L 1.1.00.00 (U 32)
; Language:			English
; Tested on:		  Win XPSP3, Win VistaSP2 (32 Bit)
; Version:			 0.0.00.01/2011-07-17/just me
; Parameters:		 HWND		  - HWND of a window or control
; Return values:	 On success  - Object containing structure's values (see Remarks)
;						 On failure  - False,
;											ErrorLevel = 1 -> Invalid HWND
;											ErrorLevel = 2 -> DllCall("GetWindowInfo") caused an error
; Remarks:			 The returned object contains all keys defined in WINDOWINFO exept "Size".
;						 The keys "Window" and "Client" contain objects with keynames defined in [5].
;						 For more details see http://msdn.microsoft.com/en-us/library/ms633516%28VS.85%29.aspx and
;						 http://msdn.microsoft.com/en-us/library/ms632610%28VS.85%29.aspx
; ================================================================================================================================
API_GetWindowInfo(HWND) {
	; [1] = Offset, [2] = Length, [3] = Occurrences, [4] = Type, [5] = Key array
	Static WINDOWINFO := { Size: [0, 4, 1, "UInt", ""]
								, Window: [4, 4, 4, "Int", ["Left", "Top", "Right", "Bottom"]]
								, Client: [20, 4, 4, "Int", ["Left", "Top", "Right", "Bottom"]]
								, Styles: [36, 4, 1, "UInt", ""]
								, ExStyles: [40, 4, 1, "UInt", ""]
								, Status: [44, 4, 1, "UInt", ""]
								, XBorders: [48, 4, 1, "UInt", ""]
								, YBorders: [52, 4, 1, "UInt", ""]
								, Type: [56, 2, 1, "UShort", ""]
								, Version: [58, 2, 1, "UShort", ""] }
	Static WI_Size := 0
	If (WI_Size = 0) {
		For Key, Value In WINDOWINFO
			WI_Size += (Value[2] * Value[3])
	}
	If !DllCall("User32.dll\IsWindow", "Ptr", HWND) {
		ErrorLevel := 1
		Return False
	}
	struct_WI := ""
	NumPut(VarSetCapacity(struct_WI, WI_Size, 0), struct_WI, 0, "UInt")
	If !(DllCall("User32.dll\GetWindowInfo", "Ptr", HWND, "Ptr", &struct_WI)) {
		ErrorLevel := 2
		Return False
	}
	obj_WI := {}
	For Key, Value In WINDOWINFO {
		If (Key = "Size")
			Continue
		Offset := Value[1]
		If (Value[3] > 1) { ; more than one occurrence
			If IsObject(Value[5]) { ; use keys defined in Value[5] to store the values in
				obj_ := {}
				Loop, % Value[3] {
					obj_.Insert(Value[5][A_Index], NumGet(struct_WI, Offset, Value[4]))
					Offset += Value[2]
				}
				obj_WI[Key] := obj_
			} Else { ; use simple array to store the values in
				arr_ := []
				Loop, % Value[3] {
					arr_[A_Index] := NumGet(struct_WI, Offset, Value[4])
					Offset += Value[2]
				}
				obj_WI[Key] := arr_
			}
		} Else { ; just one item
			obj_WI[Key] := NumGet(struct_WI, Offset, Value[4])
		}
	}
	Return obj_WI
}