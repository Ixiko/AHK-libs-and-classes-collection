/*
class: VARENUM
an enumeration class that defines flags that specifies a variant's type.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/VARENUM)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221170)

Requirements:
	AutoHotkey - AHK v2 alpha
*/
class VARENUM
{
	/*
	Field: EMPTY
	Not specified.
	*/
	static EMPTY := 0

	/*
	Field: NULL
	Null.
	*/
	static NULL := 1

	/*
	Field: I2
	A 2-byte integer.
	*/
	static I2 := 2

	/*
	Field: I4
	A 4-byte integer.
	*/
	static I4 := 3

	/*
	Field: R4
	A 4-byte real.
	*/
	static R4 := 4

	/*
	Field: R8
	An 8-byte real.
	*/
	static R8 := 5

	/*
	Field: CY
	Currency.
	*/
	static CY := 6

	/*
	Field: DATE
	A date.
	*/
	static DATE := 7

	/*
	Field: BSTR
	A string.
	*/
	static BSTR := 8

	/*
	Field: DISPATCH
	An IDispatch pointer.
	*/
	static DISPATCH := 9

	/*
	Field: ERROR
	A SCODE value.
	*/
	static ERROR := 10

	/*
	Field: BOOL
	A Boolean value. True is -1 and false is 0.
	*/
	static BOOL := 11

	/*
	Field: VARIANT
	A variant pointer.
	*/
	static VARIANT := 12

	/*
	Field: UNKNOWN
	An IUnknown pointer.
	*/
	static UNKNOWN := 13

	/*
	Field: DECIMAL
	A 16-byte fixed-pointer value.
	*/
	static DECIMAL := 14

	/*
	Field: I1
	A character.
	*/
	static I1 := 16

	/*
	Field: UI1
	An unsigned character.
	*/
	static UI1 := 17

	/*
	Field: UI2
	An unsigned short.
	*/
	static UI2 := 18

	/*
	Field: UI4
	An unsigned long.
	*/
	static UI4 := 19

	/*
	Field: I8
	A 64-bit integer.
	*/
	static I8 := 20

	/*
	Field: UI8
	A 64-bit unsigned integer.
	*/
	static UI8 := 21

	/*
	Field: INT
	An integer.
	*/
	static INT := 22

	/*
	Field: UINT
	An unsigned integer.
	*/
	static UINT := 23

	/*
	Field: VOID
	A C-style void.
	*/
	static VOID := 24

	/*
	Field: HRESULT
	An HRESULT value.
	*/
	static HRESULT := 25

	/*
	Field: PTR
	A pointer type.
	*/
	static PTR := 26

	/*
	Field: SAFEARRAY
	A safe array. Use <ARRAY> in VARIANT.
	*/
	static SAFEARRAY := 27

	/*
	Field: CARRAY
	A C-style array.
	*/
	static CARRAY := 28

	/*
	Field: USERDEFINED
	A user-defined type.
	*/
	static USERDEFINED := 29

	/*
	Field: LPSTR
	A null-terminated string.
	*/
	static LPSTR := 30

	/*
	Field: LPWSTR
	A wide null-terminated string.
	*/
	static LPWSTR := 31

	/*
	Field: RECORD
	A user-defined type.
	*/
	static RECORD := 36

	/*
	Field: INT_PTR
	A signed machine register size width.
	*/
	static INT_PTR := 37

	/*
	Field: UINT_PTR
	An unsigned machine register size width.
	*/
	static UINT_PTR := 38

	/*
	Field: FILETIME
	A FILETIME value.
	*/
	static FILETIME := 64

	/*
	Field: BLOB
	Length-prefixed bytes.
	*/
	static BLOB := 65

	/*
	Field: STREAM
	The name of the stream follows.
	*/
	static STREAM := 66

	/*
	Field: STORAGE
	The name of the storage follows.
	*/
	static STORAGE := 67

	/*
	Field: STREAMED_OBJECT
	The stream contains an object.
	*/
	static STREAMED_OBJECT := 68

	/*
	Field: STORED_OBJECT
	The storage contains an object.
	*/
	static STORED_OBJECT := 69

	/*
	Field: BLOB_OBJECT
	The blob contains an object.
	*/
	static BLOB_OBJECT := 70

	/*
	Field: CF
	A clipboard format.
	*/
	static CF := 71

	/*
	Field: CLSID
	A class ID.
	*/
	static CLSID := 72

	/*
	Field: VERSIONED_STREAM
	A stream with a GUID version.
	*/
	static VERSIONED_STREAM := 73

	/*
	Field: BSTR_BLOB
	Reserved.
	*/
	static BSTR_BLOB := 0xffff

	/*
	Field: VECTOR
	A simple counted array.
	*/
	static VECTOR := 0x1000

	/*
	Field: ARRAY
	A SAFEARRAY pointer.
	*/
	static ARRAY := 0x2000

	/*
	Field: BYREF
	A void pointer for local use.
	*/
	static BYREF := 0x5000
}