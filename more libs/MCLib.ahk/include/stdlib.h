#ifndef STDLIB_HEADER
#define STDLIB_HEADER

#include "mclib.h"
#include <stddef.h>

MCLIB_IMPORT(uint64_t, Kernel32, GetProcessHeap, ());
MCLIB_IMPORT(void*, Kernel32, HeapAlloc, (uint64_t, uint32_t, size_t));
MCLIB_IMPORT(void*, Kernel32, HeapReAlloc, (uint64_t, uint32_t, void*, size_t));
MCLIB_IMPORT(void, Kernel32, HeapFree, (uint64_t, uint32_t, void*));

void* malloc(size_t Size) {
	return HeapAlloc(GetProcessHeap(), 0x8, Size);
}
void* calloc(size_t ElementSize, size_t ElementCount) {
	return malloc(ElementCount * ElementSize);
}
void* realloc(void* Memory, size_t NewSize) {
	if (Memory == NULL) {
		return malloc(NewSize);
	}

	return HeapReAlloc(GetProcessHeap(), 0x8, Memory, NewSize);
}

void free(void* Memory) {
	HeapFree(GetProcessHeap(), 0, Memory);
}

void* memcpy(void* To, const void* From, size_t Count) {
	asm("cld\n\t" \
		"rep movsb" \
		:: "D"(To), "S"(From), "c"(Count)
	);

	return To;
}

void* memset(void* To, int Value, size_t Count) {
	asm("cld\n\t" \
		"rep stosb" \
		:: "D"(To), "c"(Count), "a"(Value)
	);
	
	return To;
}

int memcmp(const void* Left, const void* Right, size_t Count) {
	asm("cld\n\t" \
		"repe cmpsb\n\t" \
        "mov 0, %%eax\n\t" \
        "cmovl -1, %%eax\n\t" \
        "cmovg 1, %%eax\n\t" \
        "ret"
		:: "D"(Left), "S"(Right), "c"(Count)
	);

    return 0;
}

#ifdef __cplusplus
void* operator new(size_t size) {
	return malloc(size);
}
void* operator new[](size_t size) {
	return malloc(size);
}
void operator delete(void* Memory) {
	free(Memory);
}
void operator delete[](void* Memory) {
	free(Memory);
}
#endif // __cplusplus

#endif // STDLIB_HEADER