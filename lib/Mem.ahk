Mem_Allocate(bytes)
{
	static HEAP_GENERATE_EXCEPTIONS := 0x00000004, HEAP_ZERO_MEMORY := 0x00000008
	return DllCall("HeapAlloc", "Ptr", Mem_GetHeap(), "UInt", HEAP_GENERATE_EXCEPTIONS|HEAP_ZERO_MEMORY, "UInt", bytes, "Ptr")
}
Mem_GetHeap()
{
	static heap := DllCall("GetProcessHeap", "Ptr")
	return heap
}
Mem_Release(buffer)
{
	return DllCall("HeapFree", "Ptr", Mem_GetHeap(), "UInt", 0, "Ptr", buffer, "Int")
}
Mem_Copy(src, dest, bytes)
{
	DllCall("RtlMoveMemory", "Ptr", dest, "Ptr", src, "UInt", bytes)
}