# Introduction
	
This function works as the built-in function `dllcall`, but with the added _value type_ `struct`, used to pass a struct by value and to fetch a struct which is returned by value.
	
# Documentation

### `dllcall_struct(p*)`

Parameters are the same as for the built-in function.

### Pass struct by value

To pass a struct by value, specify `struct` for the _argument type_, and for the _argument value_, you pass a struct object. For details on the struct object, see below. Suffix `*` and `P` are also supported and causes the address of the struct to be passed.

### Return struct by value
	
For a function which returns a struct by value specify, for the last parameter, `[cdecl ] struct: stuct_definition`, where by default, the structure is defined by it size alone, eg,  `cdecl struct:4`,
or to assign the result to an existing struct, you can pass an array: `[cdecl_or_blank, struct_object]` for the last parameter.

Suffix `*` and `P`  not supported for `struct` when used as _return value_, 

### The struct object

The default struct object is on the form `[struct_address, struct_size]`, where `struct_address` is the address to the struct's first member, `struct_size` is the size of the struct.
Struct objects returned by the function stores the data (with address `struct_address`) in the string buffer associated with the key `data`.

To change the default struct object, you need to modify the nested functions `addressof`, `sizeof` and `createStruct`.  `createStruct` takes one parameter which is the string that follows the string `struct:`, which should represent the definition of the struct. `createStruct` should return an object which when passed to `sizeof` returns its size and when passed to `addressof` returns the address of its first member.

### Supported calling conventions

For __AHK 64 bit__, this function supports the _x64 calling convention_ as described here: [MSDN (2019-01-03)](https://docs.microsoft.com/en-us/cpp/build/x64-calling-convention?view=vs-2017). For __AHK 32 bit__ this function supports the _cdecl_ and _stdcall_ calling conventions, when implemented as:

 > Structures of all sizes are passed on the stack, and structs of sizes `1`, `2`, `4` and `8` bytes are returned in `%eax/%edx` registers. All other structs are _returned_ via pointer to memory allocated by the caller, which is pushed last on the stack.

### Known limitiations

* Output values, eg, `int*` can be passed by not returned, use `ptr` instead if you need the output. 
Likewise, `str` works as input, but cannot output, again, use 'ptr' and retrieve with `strget`.
* The built-in optimisation for the first parameter cannot be done for this function, to improve performance consider _looking up the function's address beforehand_ as described in [DllCall - performance](https://lexikos.github.io/v2/docs/commands/DllCall.htm#load).
* Likely more...

### Example

For an example, see `example.ahk`.