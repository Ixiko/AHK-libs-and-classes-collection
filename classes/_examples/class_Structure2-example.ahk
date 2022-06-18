;============ Auto-execute ====================================================;
;======================================================  Setting  ==============;

#NoEnv
#SingleInstance, Force
#Warn, ClassOverwrite, MsgBox

Process, Priority, , Normal
SetBatchLines, -1
SetTitleMatchMode, 2

;====================================================== Variable ==============;

IniRead, Debug, % A_WorkingDir . "\cfg\Settings.ini", Debug, Debug
Global Debug

;======================================================== Test ================;

Assert.SetLabel("001")
(struct := new Structure(8)).NumPut(0, "Int", 2, "Int", 1)
struct.Size := 12
loop, % (size := struct.Size)//4 {
	contents001 .= NumGet(struct.Ptr + (A_Index - 1)*4, "Int") . ((A_Index < size//4) ? (", ") : (""))
}
Assert.IsEqual(contents001, "2, 1, 0")  ;* Test that the values were copied correctly and extra 4 bytes has a value of `0`.

Assert.SetLabel("002")
struct := Primary(Header(1, 2), Body(3, 4, 5, 6))  ;* Create a struct by combining two other structs.
loop, % (size := struct.Size)//4 {
	contents002 .= NumGet(struct.Ptr + (A_Index - 1)*4, "Int") . ((A_Index < size//4) ? (", ") : (""))
}
Assert.IsEqual(contents002, "1, 2, 3, 4, 5, 6")  ;* Test that all the data from the other structs was copied.

Assert.SetLabel("003")
struct.NumPut(0, "Struct", Body(3, 4, 5, 6))  ;* Insert an entire struct at offset 0.
loop, % (size := struct.Size)//4 {
	contents003 .= NumGet(struct.Ptr + (A_Index - 1)*4, "Int") . ((A_Index < size//4) ? (", ") : (""))
}
Assert.IsEqual(contents003, "3, 4, 5, 6, 5, 6")  ;* Test that all the data from the other struct was inserted.

Assert.SetLabel("004")
struct.NumPut(20, "Int", 1)  ;* Attempt to insert an "Int" (4 bytes) value of 1 at offset 20.
loop, % (size := struct.Size)//4 {
	contents004 .= NumGet(struct.Ptr + (A_Index - 1)*4, "Int") . ((A_Index < size//4) ? (", ") : (""))
}
Assert.IsEqual(contents004, "3, 4, 5, 6, 5, 1")  ;* Test that the value was inserted.

Assert.SetLabel("005")
struct.NumPut(24, "Int", 1)  ;* Attempt to insert an "Int" (4 bytes) value at offset 24 but that points to memory beyond this struct's size.
Assert.IsNotEqual(struct.NumGet(24, "Int"), "1")  ;* Test that the 4	 bytes of memory at offset 24 are unaffected.

Assert.SetLabel("006")
struct.NumPut(12, "Struct", Body(3, 4, 5, 6))  ;* Attempt to insert an entire struct at offset 12 but doing so would affect memory beyond this struct's size.
Assert.IsNotEqual(struct.NumGet(24, "Int"), "6")  ;* Test that the insertion is truncated and the 4 bytes of memory at offset 24 are unaffected.

Assert.SetLabel("007")
struct := struct.NumGet(4, "Struct", 8)  ;* Create a new struct from a slice of another.
loop, % (size := struct.Size)//4 {
	contents007 .= NumGet(struct.Ptr + (A_Index - 1)*4, "Int") . ((A_Index < size//4) ? (", ") : (""))
}
Assert.IsEqual(contents007, "4, 5")

Assert.SetLabel("008")
struct := struct.NumGet(8, "Struct", 4)  ;* Cannot create a slice from memory not part of another structure.
loop, % (size := struct.Size)//4 {
	contents008 .= NumGet(struct.Ptr + (A_Index - 1)*4, "Int") . ((A_Index < size//4) ? (", ") : (""))
}
Assert.IsNull(contents008)  ;* Test that null is returned.

Assert.SetLabel("009")
(struct := new Structure(8)).NumPut(0, "Int", 1, "Int", 1)
struct.ZeroMemory(12)  ;* Give `ZeroMemory()` a length greater than this structure's size (this will cause a critical error without handling).
loop, % (size := struct.Size)//4 {
	contents009 .= NumGet(struct.Ptr + (A_Index - 1)*4, "Int") . ((A_Index < size//4) ? (", ") : (""))
}
Assert.IsEqual(contents009, "0, 0")  ;* Test that zeroes were inserted.
Assert.SetLabel("010")
Assert.IsNotEqual(struct.NumGet(8, "Int"), "0")  ;* Test that the memory at offset 8 is unaffected.

Assert.SetLabel("011")
struct := Structure.CreateFromArray([1, 2, 3, 4, 5])  ;* Create a new struct from an array.
loop, % (size := struct.Size)//4 {
	contents011 .= NumGet(struct.Ptr + (A_Index - 1)*4, "UInt") . ((A_Index < size//4) ? (", ") : (""))  ;* Defaults to `"UInt"` type.
}
Assert.IsEqual(contents011, "1, 2, 3, 4, 5")  ;* Test that the values were inserted correctly.

Assert.SetLabel("012")
struct := new Structure([1, 2, 3, 4, 5], "Int")  ;* Create a new struct from an array.
loop, % (size := struct.Size)//4 {
	contents012 .= NumGet(struct.Ptr + (A_Index - 1)*4, "Int") . ((A_Index < size//4) ? (", ") : (""))
}
Assert.IsEqual(contents012, "1, 2, 3, 4, 5")  ;* Test that the values were inserted correctly.

Assert.SetLabel("013")
struct := new Structure(Header(1, 2), Body(3, 4, 5, 6))  ;* Create a new struct from two other structs.
loop, % (size := struct.Size)//4 {
	contents013 .= NumGet(struct.Ptr + (A_Index - 1)*4, "Int") . ((A_Index < size//4) ? (", ") : (""))
}
Assert.IsEqual(contents013, "1, 2, 3, 4, 5, 6")  ;* Test that the data was coppied correctly.

Assert.Report()

exit

;=============== Hotkey =======================================================;

#If (WinActive(A_ScriptName))

	~*$Esc::
		KeyWait, Esc, T1
		if (ErrorLevel) {
			ExitApp
		}

		return

	$F10::
		ListVars
		return

	~$^s::
		Critical, On

		Sleep, 200
		Reload

		return

#If

;==============  Include  ======================================================;

#Include, %A_ScriptDir%\..\..\Assert\Assert.ahk

;============== Function ======================================================;

Header(number1, number2) {
	(header := new Structure(8)).NumPut(0, "Int", number1, "Int", number2)

	return (header)
}

Body(number1, number2, number3, number4) {
	(body := new Structure(16)).NumPut(0, "Int", number1, "Int", number2, "Int", number3, "Int", number4)

	return (body)
}

Primary(header, body) {
    return (new Structure("Struct", header, "Struct", body))
}