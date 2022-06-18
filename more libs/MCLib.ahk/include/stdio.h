#ifndef STDIO_HEADER
#define STDIO_HEADER

#include <mclib.h>
#include <stddef.h>

typedef struct {
	char Dummy;
} FILE;

MCLIB_IMPORT(FILE*, msvcrt, fopen, (const char*, const char*));
MCLIB_IMPORT(long int, msvcrt, ftell, (FILE*));
MCLIB_IMPORT(int, msvcrt, fseek, (FILE*, long int, int));
MCLIB_IMPORT(size_t, msvcrt, fwrite, (const void*, size_t, size_t, FILE*));
MCLIB_IMPORT(int, msvcrt, fputs, (char*, FILE*));
MCLIB_IMPORT(size_t, msvcrt, fread, (void*, size_t, size_t, FILE*));
MCLIB_IMPORT(int, msvcrt, fprintf, (FILE*, char*, ...));
MCLIB_IMPORT(int, msvcrt, fclose, (FILE*));

#define SEEK_SET 0
#define SEEK_CUR 1
#define SEEK_END 2

#define stdout 0
#define stderr 0
#define stdin 0

struct stat {
	off_t st_size;
};

#define fileno(f) ((uint64_t)f)

int fstat(uint64_t FileHandle, struct stat* Output) {
	FILE* f = (FILE*)FileHandle;

	int OldPosition = ftell(f);
	fseek(f, 0, SEEK_END);
	int Result = ftell(f);
	fseek(f, OldPosition, SEEK_SET);

	Output->st_size = Result;

	return 0;
}

#endif // STDIO_HEADER