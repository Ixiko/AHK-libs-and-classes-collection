#ifndef MCLIB_HEADER
#define MCLIB_HEADER

#define MCLIB_EXPORT(Name) \
int __MCLIB_e_ ## Name () __attribute__((alias(#Name)));

#define MCLIB_EXPORT_INLINE(ReturnType, Name, Parameters) \
int __MCLIB_e_ ## Name () __attribute__((alias(#Name))); \
ReturnType Name Parameters

#define MCLIB_QUOTE(X) #X

#define MCLIB_IMPORT(ReturnType, DllName, Name, ParameterTypes) \
ReturnType (* __MCLIB_i_ ## DllName ## _ ## Name)ParameterTypes = (ReturnType(*)ParameterTypes)0; \
static ReturnType __attribute__((alias(MCLIB_QUOTE(__MCLIB_i_ ## DllName ## _ ## Name)))) (*Name) ParameterTypes;

#define main __main

#ifdef MCLIB_LIBRARY
void __main() {};
#endif

#endif // MCLIB_HEADER