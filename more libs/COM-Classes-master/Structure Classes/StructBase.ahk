/*
class: StructBase
serves as base class for struct classes. Struct classes must derive from it.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/StructBase)

Requirements:
	AutoHotkey - AHK v2 alpha
	Base classes - _CCF_Error_Handler_
	Other classes - CCFramework
*/
class StructBase extends _CCF_Error_Handler_
{
	/*
	group: private
	These methods and fields are for use by this class only.

	Field: buffers
	an array holding the buffers alocated by this struct instance. For internal use only.
	*/
	buffers := []

	/*
	Method: FindBufferKey
	finds a specified buffer in the <buffers> array and returns its index. For internal use only.

	Parameters:
		UPTR buffer - the buffer to find

	Returns:
		UINT key - the array index, or 0 if not found
	*/
	FindBufferKey(buffer)
	{
		local key, val
		for key, val in this.buffers
		{
			if (val == buffer)
			{
				return val
			}
		}
		return 0
	}

	/*
	Method: deconstructor
	called when the instance is released. Frees all allocated memory.

	Remarks:
		You do not call this method from your code. Instead, AutoHotkey calls it when the instance is no longer needed.
	*/
	__Delete()
	{
		this.FreeAllMemory()
		this.ReleaseOriginalPointer()
	}

	/*
	group: protected
	These methods are intended for use by derived classes.

	Method: Allocate
	allocates a specified amount of bytes from the heap and returns a handle to it. The buffer is initalzed with 0.

	Parameters:
		UINT bytes - the number of bytes to allocate

	Returns:
		UPTR buffer - a pointer to the buffer allocated

	Remarks:
		This function should be used to allocate memory when <ToStructPtr()> is called withot a pointer.
	*/
	Allocate(bytes)
	{
		local buffer
		buffer := CCFramework.AllocateMemory(bytes)
		if (buffer)
		{
			this.buffers.Insert(buffer)
		}
		return buffer
	}

	/*
	Method: Free
	frees the memory of a given buffer.

	Parameters:
		UPTR buffer - a pointer to a buffer returned by <Allocate()>.

	Returns:
		BOOL success - true on success, false otherwise

	Remarks:
		Call this method if you're sure the memory is no longer needed. If you want to free all memory, call <FreeAllMemory>.
	*/
	Free(buffer)
	{
		local bool := CCFramework.FreeMemory(buffer)
		if (bool)
		{
			this.buffers.Remove(this.FindBufferKey(buffer))
		}
		return bool
	}

	/*
	Method: FreeAllMemory
	frees the memory on all <buffers>.

	Remarks:
		This method is called automatically by the <deconstructor>.
	*/
	FreeAllMemory()
	{
		local index, buffer
		for index, buffer in this.buffers
		{
			this.Free(buffer)
		}
		this.buffers.SetCapacity(0)
	}

	/*
	group: abstract methods
	These are methods derived classes must implement.

	Method: ToStructPtr
	abstract method that copies the values of an instance to a memory pointer. Derived classes must override this.

	Parameters:
		[opt] UPTR ptr - the fixed memory address to copy the struct to.

	Returns:
		UPTR ptr - a pointer to the struct in memory

	Developer Remarks:
		If no pointer is supplied, call <Allocate()>.
	*/
	ToStructPtr(ptr := 0)
	{
		throw Exception("Abstract method was not overriden.", -1)
	}

	/*
	Method: FromStructPtr
	abstract method that creates an instance of the struct class from a memory pointer. Derived classes must override this.

	Parameters:
		UPTR ptr - a pointer to a struct in memory
		[opt] BOOL own - set this to false if the instance must not release the given pointer

	Returns:
		OBJECT instance - the new instance
	*/
	FromStructPtr(ptr, own := true)
	{
		throw Exception("Abstract method was not overridden.", -1)
	}

	/*
	Method: GetRequiredSize
	abstract method that calculates the size a memory instance of this class requires.

	Parameters:
		[opt] OBJECT data - an optional data object that may contain data for the calculation.

	Returns:
		UINT bytes - the number of bytes required

	Developer Remarks:
		- Implement this method so that it can be called as if it was a static method: do not depend on instance fields.
		- Also do not depend on the data object. Make the method work without any data.
		- Document the fields the data object can have.
	*/
	GetRequiredSize(data := "")
	{
		throw Exception("Abstract method was not overridden.", -1)
	}

	/*
	Method: GetOriginalPointer
	if the current instance was created by a call to <FromStructPtr()>, this returns the pointer it was created from.

	Returns:
		UPTR ptr - the pointer

	Developer Remarks:
		To make this work, any derived class must call <SetOriginalPointer()> from within its <FromStructPtr()> method.
	*/
	GetOriginalPointer()
	{
		return this._internal_orig_ptr_
	}

	/*
	Method: SetOriginalPointer
	sets the original pointer field. *This may only be used by derived classes.*

	Parameters:
		UPTR ptr - the pointer to set
		[opt] BOOL own - the new value for the <OwnsOriginalPointer> field
	*/
	SetOriginalPointer(ptr, own := true)
	{
		this._internal_orig_ptr_ := ptr
		this.OwnsOriginalPointer := own
	}

	; the field holding the original pointer
	_internal_orig_ptr_ := 0

	/*
	Field: OwnsOriginalPointer
	true if the original pointer is allowed to be released by this instance, false if not
	*/
	OwnsOriginalPointer := true

	/*
	Method: ReleaseOriginalPointer
	if the current instance was created by a call to <FromStructPtr()>, and the pointer passed to the method was previoulsy allocated using CCFramework.AllocateMemory(), this releases the pointer the instance was created from.

	Parameters:
		[opt] BOOL force - true if the pointer should be released even if <OwnsOriginalPointer> is set to false

	Returns:
		BOOL success - true on success, false otherwise
	*/
	ReleaseOriginalPointer(force := false)
	{
		return (this.OwnsOriginalPointer || force) ? CCFramework.FreeMemory(this.GetOriginalPointer()) : 0
	}
}