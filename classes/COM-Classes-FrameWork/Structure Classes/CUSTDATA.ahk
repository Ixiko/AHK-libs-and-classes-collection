/*
class: CUSTDATA
a structure class that represents custom data.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/CUSTDATA)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221456)

Requirements:
	AutoHotkey - AHK v2 alpha
	Base classes - _CCF_Error_Handler_, StructBase
	Structure classes - CUSTDATAITEM
	Other classes - CCFramework
*/
class CUSTDATA extends StructBase
{
	/*
	Field: cCustData
	The number of custom data items in the <prgCustData> array.

	Remarks:
		If you set <prgCustData> to an AHK-array, you may also leave this field uncahnged. In this case the count is assumed to be the array length.
	*/
	cCustData := -1

	/*
	Field: prgCustData
	An array of custom data items.

	Remarks:
		You can set this either to an AHK-array of CUSTDATAITEM instances, an AHK-array of pointers to CUSTDATAITEM instances or to a simple pointer to the memory array.
		When the instance was created by a call to <FromStructPtr()>, this is always an AHK-array of CUSTDATAITEM class instances.
	*/
	prgCustData := 0

	/*
	Method: constructor
	creates a new instance of the class

	Parameters:
		[opt] CUSTDATAITEM[] array - the initial value for the <prgCustData> field
		[opt] UINT count - the initial value for the <cCustData> field
	*/
	__New(array := 0, count := -1)
	{
		this.prgCustData := array, this.cCustData := count
	}

	/*
	Method: ToStructPtr
	converts the instance to a script-usable struct and returns its memory adress.

	Parameters:
		[opt] PTR ptr - the fixed memory address to copy the struct to.

	Returns:
		PTR ptr - a pointer to the struct in memory
	*/
	ToStructPtr(ptr := 0)
	{
		local count, array, item, size := CUSTDATAITEM.GetRequiredSize()

		if (!ptr)
		{
			ptr := this.Allocate(this.GetRequiredSize())
		}

		if IsObject(this.prgCustData)
		{
			count := this.cCustData != -1 ? this.cCustData : this.prgCustData.maxIndex(), array := this.Allocate(count * size)
			Loop this.prgCustData.maxIndex()
			{
				IsObject(this.prgCustData[A_Index])
					? this.prgCustData[A_Index].ToStructPtr(array + (A_PtrSize - 1) * size)
					: CCFramework.CopyMemory(this.prgCustData[A_Index],  array + (A_PtrSize - 1) * size, size)
			}
		}
		else
			array := this.prgCustData, count := this.cCustData

		NumPut(count, 1*ptr, 00, "UInt")
		NumPut(array, 1*ptr, 04, "Ptr")

		return ptr
	}

	/*
	Method: FromStructPtr
	(static) method that converts a script-usable struct into a new instance of the class.

	Parameters:
		PTR ptr - a pointer to a CUSTDATA struct in memory
		[opt] BOOL own - false if the instance must no release the pointer (defaults to true)

	Returns:
		CUSTDATA instance - the new CUSTDATA instance
	*/
	FromStructPtr(ptr, own := true)
	{
		local instance, array := [], size := CUSTDATAITEM.GetRequiredSize(), count := NumGet(1*ptr, 00, "UInt"), arr_ptr := NumGet(1*ptr, 04, "Ptr")
		Loop count
			array.Insert(CUSTDATAITEM.FromStructPtr(arr_ptr + (A_Index - 1) * size, false))

		instance := new CUSTDATA(array, count)
		instance.SetOriginalPointer(ptr, own)
		return instance
	}

	/*
	Method: GetRequiredSize
	calculates the size a memory instance of this class requires.

	Parameters:
		[opt] OBJECT data - an optional data object that may contain data for the calculation.

	Returns:
		UINT bytes - the number of bytes required

	Remarks:
		- This may be called as if it was a static method.
		- The data object is ignored by this class.
	*/
	GetRequiredSize(data := "")
	{
		return 4 + A_PtrSize
	}
}