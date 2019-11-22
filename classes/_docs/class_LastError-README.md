# Class_LastError
Adds human readable conversions of [A_LastError](https://www.autohotkey.com/docs/commands/DllCall.htm#LastError) codes.

*Note:* v1 / v2 agnostic

## Usage

### Include
Include `LastError.ahk` in your script by...

- supplying a full path: `#Include C:\LastError.ahk`
- supplying a relative path: `#Include LastError.ahk`
- placing it in the AutoHotkey [LIB](https://www.autohotkey.com/docs/Functions.htm#lib) folder: `#Include <LastError>`

### Access
Access one of `LastError`'s properties:

- `LastError.id`: Identical to `A_LastError`. Returns an `Int`, eg. `126`
- `LastError.hex`: Converts the error code to uppercase hexadecimal. Returns a `Str`, eg. `"0x7E"`. Can be used in numerical, case-insensitive or case-sensitive(uppercase) comparisons
- `LastError.enum`: The name of the error code's constant. Returns a `Str`, eg. `"ERROR_MOD_NOT_FOUND"`
- `LastError.msg`: The error code's description. Returns a `Str`, eg. `"The specified module could not be found."`
- `LastError.info`: All of the above, formatted in the same way as it appears on [MSDN](https://docs.microsoft.com/en-us/windows/desktop/debug/system-error-codes--0-499-). Returns a `Str`, eg. below:

```
ERROR_MOD_NOT_FOUND

126 (0x7E)
The specified module could not be found.
```

## Use-case

Just print the info:
```
DllCall("LoadLibrary", "Str", "file_that_doesnt_exist", "Ptr")
MsgBox % LastError.info
```

Monitor only specific errors:
```
DllCall("LoadLibrary", "Str", "file_that_doesnt_exist", "Ptr")
if (LastError.enum == "ERROR_MOD_NOT_FOUND") ; case-sensitive comparison
{
	; handle ERROR_MOD_NOT_FOUND
}
```
