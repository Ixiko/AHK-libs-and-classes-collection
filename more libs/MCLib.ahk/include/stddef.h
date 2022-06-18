#ifndef STDDEF_HEADER
#define STDDEF_HEADER

#include <stdint.h>

typedef uint64_t size_t;
typedef int64_t ssize_t;

typedef int64_t ptrdiff_t;
typedef uint64_t off_t;

#ifndef __cplusplus
typedef uint16_t wchar_t;
#endif

#define NULL (void*)0

#define offsetof(Type, Member) (off_t)(&((Type*)0)-> ## Member)

#endif // STDDEF_HEADER