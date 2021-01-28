; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=65248
; Author:	just me
; Date:   	09.06.2019
; for:     	AHK_L

/*

   #NoEnv
   MyBuffer := BufferAlloc(2048)
   MsgBox, 0,  MyBuffer.Ptr - MyBuffer.Size, % MyBuffer.Ptr . " - " . MyBuffer.Size
   MyBuffer.PutNum(42, 1024, "UInt")
   MyBuffer.Size := 4096
   MsgBox, 0,  MyBuffer.Ptr - MyBuffer.Size, % MyBuffer.Ptr . " - " . MyBuffer.Size
   MsgBox, 0, MyBuffer.GetNum(), % MyBuffer.GetNum(1024, "UInt")
   Test := "Hello world!"
   TestLen := StrLen(Test) << !!A_IsUnicode
   MyBuffer.PutBin(Test, 0, TestLen)
   MyBuffer.GetBin(Out, 0, TestLen)
   VarSetCapacity(Out, -1) ; we are expecting a string
   Read := Out
   MsgBox, %Read%
   ExitApp
   ;#Include *i BufferAlloc.ahk

*/



; ================================================================================================================================
; AHK 1.1 replacement for the built-in AHK v2 BufferAlloc() function.
; Returns a new instance of the class BufferAllocClass on success, otherwise zero.
; Parameters:
;     ByteCount   -  The requested size of the buffer in bytes.
; ================================================================================================================================
BufferAlloc(ByteCount) {
   Return New BufferAllocClass(ByteCount)
}
; ================================================================================================================================
; Binary buffer object.
; Public properties:
;     Ptr      -  a pointer to the buffer
;     Size     -  the size of the buffer
; Public methods:
;     GetBin   -  gets binary data from the buffer
;     PutBin   -  stores binary data in the buffer
;     GetNum   -  gets a number from the buffer
;     PutNum   -  stores a number in the buffer
; The instance keys "&" and "#" are used for internal purposes. You must not change them!!!
; Heap functions -> docs.microsoft.com/en-us/windows/desktop/api/HeapApi/
; HEAP_NO_SERIALIZE = 0x01, HEAP_ZERO_MEMORY = 0x08
; ================================================================================================================================
Class BufferAllocClass {
   ; -----------------------------------------------------------------------------------------------------------------------------
   ; Returns a new buffer object instance of the given size, usually called by BufferAlloc()
   ; -----------------------------------------------------------------------------------------------------------------------------
   __New(ByteCount) {
      If !This._IsInt_(ByteCount)
      || (ByteCount < 1)
      || !(Ptr := DllCall("HeapAlloc", "Ptr", This.Heap, "UInt", 0x09, "Ptr", ByteCount, "UPtr"))
      || !(Size := DllCall("HeapSize", "Ptr", This.Heap, "UInt", 0, "Ptr", Ptr, "UPtr"))
         Return 0
      ObjRawSet(This, "&", Ptr)
      ObjRawSet(This, "#", Size)
   }
   ; -----------------------------------------------------------------------------------------------------------------------------
   __Delete() {
      If This["&"]
         DllCall("HeapFree", "Ptr", This.Heap, "UInt", 0x01, "Ptr", This["&"], "UInt")
   }
   ; -----------------------------------------------------------------------------------------------------------------------------
   __Set(Prop, Args*) {
      If !This.Base.HasKey(Prop) && (Prop <> "")
         Return ""
   }
   ; -----------------------------------------------------------------------------------------------------------------------------
   _IsInt_(Value) {
      If Value Is Integer
         Return True
      Return False
   }
   ; -----------------------------------------------------------------------------------------------------------------------------
   Heap[] {
      Get {
         Static Heap := DllCall("GetProcessHeap", "UPtr")
         Return Heap
      }
      Set {
         Return This.Heap
      }
   }
   ; =============================================================================================================================
   ; Public properties
   ; -----------------------------------------------------------------------------------------------------------------------------
   ; Gets / sets the pointer to the buffer.
   ; -----------------------------------------------------------------------------------------------------------------------------
   Ptr[] {
      Get {
         Return This["&"]
      }
      Set {
         Return This.Ptr
      }
   }
   ; -----------------------------------------------------------------------------------------------------------------------------
   ; Gets / sets the size of the buffer.
   ; -----------------------------------------------------------------------------------------------------------------------------
   Size[] {
      Get {
         Return This["#"]
      }
      Set {
         If !This._IsInt_(Value)
         || (Value < 1)
         || !(Ptr := DllCall("HeapReAlloc", "Ptr", This.Heap, "UInt", 0x08, "Ptr", This.Ptr, "Ptr", Value, "UPtr"))
         || !(Size := DllCall("HeapSize", "Ptr", This.Heap, "UInt", 0, "Ptr", Ptr, "UPtr"))
            Return This.Size
         This["&"] := Ptr
         This["#"] := Size
         Return This.Size
      }
   }
   ; =============================================================================================================================
   ; Public methods
   ; -----------------------------------------------------------------------------------------------------------------------------
   ; Gets binary data from the buffer.
   ; Parameters:
   ;     VarOrAddr   -  variable or a pointer to memory to store the data
   ;     Offset      -  offset from the beginning of the buffer
   ;     ByteCount   -  number of bytes
   ; -----------------------------------------------------------------------------------------------------------------------------
   GetBin(ByRef VarOrAddr, Offset, ByteCount) {
      If !This._IsInt_(Offset)
      || (Offset < 0)
      || ((Offset + ByteCount) >= This.Size)
         Return 0
      If IsByRef(VarOrAddr) {
         VarSetCapacity(VarOrAddr, ByteCount, 0)
         Dest := &VarOrAddr
      }
      Else
         Dest := VarOrAddr
      DllCall("RtlMoveMemory", "Ptr", Dest, "Ptr", This.Ptr + Offset, "Ptr", ByteCount)
      Return True
   }
   ; -----------------------------------------------------------------------------------------------------------------------------
   ; Stores binary date in the buffer.
   ; Parameters:
   ;     VarOrAddr   -  variable or a pointer to memory holding the data
   ;     Offset      -  offset from the beginning of the buffer
   ;     ByteCount   -  number of bytes
   ; -----------------------------------------------------------------------------------------------------------------------------
   PutBin(ByRef VarOrAddr, Offset, ByteCount) {
      If !This._IsInt_(Offset)
      || (Offset < 0)
      || ((Offset + ByteCount) >= This.Size)
         Return 0
      Src := IsByRef(VarOrAddr) ? &VarOrAddr : VarOrAddr
      DllCall("RtlMoveMemory", "Ptr", This.Ptr + Offset, "Ptr", Src, "Ptr", ByteCount)
      Return True
   }
   ; -----------------------------------------------------------------------------------------------------------------------------
   ; Gets a number from the buffer
   ; Parameters:
   ;     Offset      -  offset from the beginning of the buffer
   ;     Type        -  one of the types used by NumGet()
   ; -----------------------------------------------------------------------------------------------------------------------------
   GetNum(Offset, Type) {
      Static Types := {Char: 1, Double: 8, Float: 4, Int: 4, Int64: 8, Ptr: A_PtrSize, Short: 2}
      Check := (SubStr(Type, 1, 1) = "U") ? SubStr(Type, 2) : Type
      If !(Len := Types[Check])
      || !This._IsInt_(Offset)
      || (Offset < 0)
      || ((Offset + Len) >= This.Size)
         Return ""
      Return NumGet(This.Ptr + Offset, Type)
   }
   ; -----------------------------------------------------------------------------------------------------------------------------
   ; Stores a number in the buffer, for parameters see NumPut().
   ; Parameters:
   ;     Value       -  number to store
   ;     Offset      -  offset from the beginning of the buffer
   ;     Type        -  one of the types used by NumPut()
   ; -----------------------------------------------------------------------------------------------------------------------------
   PutNum(Value, Offset, Type) {
      Static Types := {Char: 1, Double: 8, Float: 4, Int: 4, Int64: 8, Ptr: A_PtrSize, Short: 2}
      Check := (SubStr(Type, 1, 1) = "U") ? SubStr(Type, 2) : Type
      If !(Len := Types[Check])
      || !This._IsInt_(Offset)
      || (Offset < 0)
      || ((Offset + Len) >= This.Size)
         Return ""
      NumPut(Value, This.Ptr + Offset, Type)
      Return Value
   }
}
; ================================================================================================================================