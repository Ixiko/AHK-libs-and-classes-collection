Structure.ahk
===========

A structure management framework for AutoHotkey.

## Usage

Grants access to a class named `Structure` with the following methods: `.CreateFromArray()`, `.CreateFromStruct()`, `.SizeOf()`

and instances of `Structure` with the following methods: `.NumGet()`, `.NumPut()`, `.StrGet()`, `.StrPut()` and `.ZeroMemory()`

```autohotkey
#Include <Structure>

; Create a new structure of 8 bytes in size:
struct := new Structure(8)
struct.NumPut(0, "UInt", 69, "UInt", 96)  ; Insert [UInt] 69 at offset 0 and [UInt] 96 at offset 4 (the first 4 bytes are used by the first entry).

x := struct.NumGet(0, "UInt")
y := struct.NumGet(4, "UInt")
```

## API

### `new Structure(bytes)`
### `new Structure(array[, type])`
### `new Structure(struct, struct, ...)`
### `new Structure(type, value, type, value, ...)`

Create a new instance with zero-filled memory that will be freed when this object is deleted.

##### Arguments
1. bytes: The number of bytes to be allocated.

##### Return
Returns an instance object with a `.Pointer` property that can be passed to `DllCall()`.

##### Example
```autohotkey
; Create a struct of 8 bytes in size and initially filled with zeroes:
struct1 := new Structure(8, 1) 

; Create a new struct that is a copy of `struct1` (the copy points to a new block of memory and as such can have unique values):
struct2 := new Structure(struct1)

struct1 := 0  ; `struct1` is deleted and it's memory is freed with the HeapFree function.
```

### `.Pointer`
Alias: `.Ptr`

##### Return
Returns the pointer to the block of memory contained in this struct.

##### Example
```autohotkey
rect := new Structure(16)

DllCall("User32\GetWindowRect", "Ptr", WinExist(), "Ptr", rect.Pointer, "UInt")  ; Retrieve the bounds of the active window into the `rect` struct.
DllCall("User32\ClipCursor", "Ptr", rect.Pointer)  ; Pass the pointer to the block of memory contained in this struct to the ClipCursor function.
```

### `.Size[ := value]`

Retrieve the size of this struct or assign a new size. Assigning a new size is guaranteed to preserve the content of the memory being reallocated, even if the new memory is allocated at a different location.

##### Return

##### Get

Returns the total size of the block of memory contained in this struct.

##### Set

Returns the assigned value to allow chain assignment.

### `.NumGet(offset, type[, bytes])`

Retrieve a value from this struct at the given offset.

##### Arguments
1. offset: The offset at which to start retrieving the data.
2. type: The data type to retrieve.

##### Return
Returns the data at the specified address.

##### Example
```autohotkey
struct := new Structure(8)
struct.NumPut(0, "UShort", 1, "Float", 2)

MsgBox, % struct.NumGet(2, "Float")  ; Retrieve the Float (4 bytes) at offset 2 (the first byte after the UShort entry).
```

### `.NumPut(offset, type, value, type, value, ...)`

Insert any number of values into this struct but not exceeding the size allocated when it was created.

##### Arguments
1. offset (*): The offset at which the first entry will be inserted.
2. value (*): The value to insert.

##### Return
Returns the next byte in this struct after all values have been added.

##### Example
```autohotkey
struct := new Structure(12 + A_PtrSize)  ; A_PtrSize = 8 on 64-bit and 4 on 32-bit.
struct.NumPut(0, "Int", 1, "Int", 2, "Int", 3)

struct.NumPut(8, "Float", 3.14159, "Ptr", A_ScriptHwnd)  ; Overwrite the value at offset 8 and insert a handle at offset 12.
```
