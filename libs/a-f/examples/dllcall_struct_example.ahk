#include %a_Scriptdir%\..\lib-a_to_h\dllcall_struct.ahk

/*
// the function to call:

typedef struct {
	char a;
	char b;
	char c;
} S;

S f(int a, S s1){
	// this function takes a struct S and returns a copy of it where all members are multiplied by a.
	S s2 = s1;
	s2.a *= a;
	s2.b *= a;
	s2.c *= a;
	return s2;
}
*/

size := 3

varsetcapacity struct_in, size		; set up the struct as 'usual'
numput 1, struct_in, 0, 'char'		; struct_in.a = 1;	
numput 2, struct_in, 1, 'char'		; struct_in.b = 2;
numput 3, struct_in, 2, 'char'     	; struct_in.c = 3;

struct_object := [&struct_in, size]	; create a (default) struct object
a := 2 ; the number to multiply the members by.
struct_out := dllcall_struct(p(), 'int', a, 'struct', struct_object, 'cdecl struct:' size)	; calls f, passing it a struct and fetches its return struct.
 
p := struct_out.1	; the address of the returned struct

; read the values of the returned struct, the input struct is not changed
msgbox		numget(p, 0, 'char') . '`n' 
		.	numget(p, 1, 'char') . '`n' 
		.	numget(p, 2, 'char')      

exitapp
p(){
	; returns a pointer to: S f(int a, S s1) as defined above.
	; compiled with gcc -Os ((tdm64-1) 5.1.0)
	static flProtect:=0x40, flAllocationType:=0x1000 ; PAGE_EXECUTE_READWRITE ; MEM_COMMIT	
	static raw32:=[1407551829,2333164938,2936997965,3263695941,252855690,2282505647,3280470353,252724618,2282505647,25690713,1566296201,2425393347]
	static raw64:=[4131508360,2285961568,1104185538,1141006582,1090605448,3498623368,1143010881,2281851272,3364440065,2425393347,2425393296,2425393296]
	static bin
	local
	if !bin {
		bin:=DllCall("Kernel32.dll\VirtualAlloc", "Uptr",0, "Ptr", (raw:=A_PtrSize==4?raw32:raw64).length()*4, "Uint", flAllocationType, "Uint", flProtect, "Ptr")
		for k, i in raw
			NumPut(i,bin+(k-1)*4,"Int")
		raw32:="",raw64:=""
	}
	return bin
}