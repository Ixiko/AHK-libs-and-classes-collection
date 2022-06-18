#ifndef STRING_HEADER
#define STRING_HEADER

MCLIB_IMPORT(int, msvcrt, isspace, (int));
MCLIB_IMPORT(int, msvcrt, tolower, (int));
MCLIB_IMPORT(int, msvcrt, toupper, (int));

MCLIB_IMPORT(int, msvcrt, strlen, (const char*));
MCLIB_IMPORT(int, msvcrt, strcmp, (const char*, const char*));
MCLIB_IMPORT(int, msvcrt, strncmp, (const char*, const char*, size_t));
MCLIB_IMPORT(char, msvcrt, strcpy, (char*, const char*));
MCLIB_IMPORT(char*, msvcrt, strchr, (const char*, int));
MCLIB_IMPORT(char*, msvcrt, strrchr, (const char*, int));
MCLIB_IMPORT(char*, msvcrt, strncpy, (char*, const char*, size_t));

MCLIB_IMPORT(char*, msvcrt, strerror, (int));

MCLIB_IMPORT(int, msvcrt, sscanf, (char*, char*, ...));
MCLIB_IMPORT(int, msvcrt, sprintf, (char*, const char*, ...));
MCLIB_IMPORT(int, msvcrt, vsprintf, (char*, const char*, va_list));
MCLIB_IMPORT(int, msvcrt, vsnprintf, (char*, size_t, const char*, va_list));

int strcasecmp(const char* Left, const char* Right) {
	int ca, cb;

	do {
		ca = *(unsigned char *)Left;
		cb = *(unsigned char *)Right;
		ca = tolower(toupper(ca));
		cb = tolower(toupper(cb));
		Left++;
		Right++;
	} while (ca == cb && ca != '\0');

	return ca - cb;
}

#endif // STRING_HEADER