#Include ..\MCode.ahk

/*
    Invierte los bytes en el búfer especificado.
    Parámetros:
        pBuffer: La dirección de memoria del búfer a invertir.
        Size   : La longitud de pBuffer, en bytes.
        Bytes  : Reservado (sin uso). Indica si se debe limitar cada ciertos bytes.
    Ejemplo:
        VarSetCapacity(Buffer, 4)
        NumPut(0x12345678, &Buffer, 0, 'Int')
        MsgBox(Format('{:X}', NumGet(&Buffer, 0, 'Int'))) ;12345678
        ReverseBytes(&Buffer, 4)
        MsgBox(Format('{:X}', NumGet(&Buffer, 0, 'Int'))) ;78563412
*/
ReverseBytes(pBuffer, Size, Bytes := 0)
{
    Static Ptr

    If (Ptr == '')
        Ptr := MCode('2,x64:idJIjUQR/0g5wXMgDx9AAA+2EUiD6AFIg8EBRA+2QAFIOcFEiEH/iFABcuTDkJCQ,x86:U4tEJAiLVCQMjVQQ/znQcxYPtggPthqDwAGD6gE50IhY/4hKAXLqW8OQkJCQkJCQ')

    DllCall(Ptr, 'UPtr', pBuffer, 'UInt', Size, 'Cdecl')
}




; DllCall('Kernel32.dll\LCMapStringEx', 'Ptr', 0, 'UInt', 0x800, 'UPtr', &Binary, 'Int', 4, 'UPtr', &Dest, 'Int', 4, 'Ptr', 0, 'Ptr', 0, 'Ptr', 0)
; https://msdn.microsoft.com/en-us/library/windows/desktop/dd318702(v=vs.85).aspx
