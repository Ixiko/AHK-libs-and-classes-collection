/*
class: CHARRANGE
a structure class that specifies a range of characters in a rich edit control. If the <cpMin> and <cpMax> members are equal, the range is empty. The range includes everything if <cpMin> is 0 and <cpMax> is –1.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/CHARRANGE)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb787885)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 2000 Professional / Windows 2000 Server or higher
	Base classes - StructBase
*/
class CHARRANGE extends StructBase
{
	/*
	Field: cpMin
	Character position index immediately preceding the first character in the range.
	*/
	cpMin := 0

	/*
	Field: cpMax
	Character position immediately following the last character in the range.
	*/
	cpMax := -1

	/*
	Method: Constructor

	Parameters:
		[opt] UINT min - the initial value of the <cpMin> member. By default 0.
		[opt] UINT max - the initial value of the <cpMax> member. By default -1.
	*/
	__New(min := 0, max := -1)
	{
		this.cpMin := min
		this.cpMax := max
	}

	/*
	Method: ToStructPtr
	converts the instance to a script-usable struct and returns its memory adress.

	Parameters:
		[opt] UPTR ptr - the fixed memory address to copy the struct to.

	Returns:
		UPTR ptr - a pointer to the struct in memory
	*/
	ToStructPtr(ptr := 0)
	{
		if (!ptr)
		{
			ptr := this.Allocate(this.GetRequiredSize())
		}

		NumPut(this.cpMin,	1*ptr,	00,	"UInt")
		NumPut(this.cpMax,	1*ptr,	04,	"UInt")

		return ptr
	}

	/*
	Method: FromStructPtr
	(static) method that converts a script-usable struct into a new instance of the class

	Parameters:
		UPTR ptr - a pointer to a CHARRANGE struct in memory
		[opt] BOOL own - false if the instance must no release the pointer (defaults to true)

	Returns:
		CHARRANGE instance - the new CHARRANGE instance
	*/
	FromStructPtr(ptr, own := true)
	{
		local instance := new CHARRANGE(NumGet(1*ptr,	00, "UInt"), NumGet(1*ptr,	04,	"UInt"))
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
		return 8
	}
}