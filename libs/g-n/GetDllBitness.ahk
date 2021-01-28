DllPath := A_ScriptDir "\amf-component-vc-windesktop32.dll"     ; point to full path of dll
DllName := (d:=StrSplit( DllPath,"\"))[d.Length()]              ; for display purposes only

Bitness := GetDllBitness( DllPath )                             ; test call

msgbox % DllName " is " Bitness "Bit"

GetDllBitness( dll, warn:=0 )
{	
	hM := DllCall( "LoadLibrary", "str", "imagehlp.dll", "ptr" ), VarSetCapacity( LIS, 88, 0 )

	if DllCall( "imagehlp\MapAndLoad", AStr, dll, Ptr, 0, Ptr, &LIS, Int, 1, Int, 1 )
		Bitness := (NumGet(NumGet(LIS, A_PtrSize*3, "UPtr")+4, "UShort") = 0x014c ? 32:64)

        DllCall("imagehlp\UnMapAndLoad", Ptr, &Lis ), DllCall( "FreeLibrary", Ptr, hM )

	if ( !Bitness && warn = 1 )
	{
		MsgBox, 0x30, Error!, %Bitness% >> Could not load the specified dll.
		Exit 0
	}
    
    Return ( Bitness ? Bitness : 0 )
}