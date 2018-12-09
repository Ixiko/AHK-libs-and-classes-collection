ITL_Mem_Allocate(bytes)
{
	static HEAP_GENERATE_EXCEPTIONS := 0x00000004, HEAP_ZERO_MEMORY := 0x00000008
	return DllCall("HeapAlloc", "Ptr", ITL_Mem_GetHeap(), "UInt", HEAP_GENERATE_EXCEPTIONS|HEAP_ZERO_MEMORY, "UInt", bytes, "Ptr")
}
ITL_Mem_GetHeap()
{
	static heap := DllCall("GetProcessHeap", "Ptr")
	return heap
}
ITL_Mem_Release(buffer)
{
	return DllCall("HeapFree", "Ptr", ITL_Mem_GetHeap(), "UInt", 0, "Ptr", buffer, "Int")
}
ITL_Mem_Copy(src, dest, bytes)
{
	DllCall("RtlMoveMemory", "Ptr", dest, "Ptr", src, "UInt", bytes)
}