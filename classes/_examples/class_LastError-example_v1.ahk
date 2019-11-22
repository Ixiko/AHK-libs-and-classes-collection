#Include C:\LastError.ahk ; full path
; #Include <LastError> ; or include from the ahk LIB folder 

DllCall("LoadLibrary", "Str", "doesntexisthopefully")

MsgBox % "A_LastError`n`n" A_LastError
MsgBox % "LastError.id - Same as calling A_LastError.`n`n" LastError.id
MsgBox % "LastError.hex - The error code converted to hexadecimal, returned as an uppercase string."
	. "Can be used in numerical, case-insensitive or case-sensitive(uppercase) comparisons.`n`n" LastError.hex
MsgBox % "LastError.msg - The error code's description.`n`n" LastError.msg
MsgBox % "LastError.enum - The name of the error code's constant.`n`n" LastError.enum
MsgBox % "LastError.info - Full info as it appears on MSDN.`n`n" LastError.info
MsgBox % "Sample use-case:`n`nif (LastError.enum == ""ERROR_MOD_NOT_FOUND"")`n`thandleModuleNotFound()"
