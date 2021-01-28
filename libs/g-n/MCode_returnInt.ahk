; Link:   	https://www.autohotkey.com/boards/viewtopic.php?t=32242
; Author:
; Date:
; for:     	AHK_L

/*


*/

returnInt(n){
	; Input:
	;	- n, integer in range (-2**31, 2**31-1), i.e., (-2147483648, 2147483647)
	; Return:
	;	- bin, address pointing to binary code for returning the integer, n.
	; Misc:
	;	When making "many" allocations, call VirtualFree(bin) when done with bin.
	; Example:
	;	r:=returnInt(37)
	;	MsgBox, % DllCall(r) ; 37
	;	VirtualFree(r)
	; Url:
	;	- https://msdn.microsoft.com/en-us/library/windows/desktop/aa366887(v=vs.85).aspx 	(VirtualAlloc function)
	;	- https://msdn.microsoft.com/en-us/library/windows/desktop/aa366786(v=vs.85).aspx 	(Memory Protection Constants)
	;	- http://ref.x86asm.net 															(X86 Opcode and Instruction Reference)
	;
	static dwSize:=6, flProtect:=0x40	; PAGE_EXECUTE_READWRITE
	static flAllocationType:=0x1000 	; MEM_COMMIT
	static mov:=0xb8, ret:=0xc3
	bin:=DllCall("Kernel32.dll\VirtualAlloc", "Uptr",0, "Ptr", dwSize, "Uint", flAllocationType, "Uint", flProtect, "Ptr")
	NumPut(mov,bin+0,"Char"),NumPut(n,bin+1,"Int"),NumPut(ret,bin+5,"Char")
	return bin
}
VirtualFree(lpAddress){
	static dwFreeType:=0x8000 ; MEM_RELEASE
	return DllCall("Kernel32.dll\VirtualFree", "Ptr", lpAddress, "Ptr", 0, "Uint", dwFreeType)  ; Non-zero return is ok!
}