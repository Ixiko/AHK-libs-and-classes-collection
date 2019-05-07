/*
    Enumerar todos los dispositivos de impresora y fax.
    Return:
              0 = Ha ocurrido un error al recuperar la información.
        [array] = Si tuvo éxito devuelve un Array de objetos. Cada objeto tiene las siguientes claves:
            Flags       = Especifica información sobre los datos devueltos.
            Description = Descripción del dispositivo.
            Name        = Nombre del dispositivo.
            Comment     = Comentario del dispositivo.
    Ejemplo:
        For Each, Printer in EnumPrinters()
            List .= Printer.Description . '`n'
        MsgBox(List)
*/
EnumPrinters()
{
    Local Size, PRINTER_INFO_1, Count
        , List   := []
        , Offset := 0

    DllCall('Winspool.drv\EnumPrintersW', 'UInt', 0x02000002, 'Ptr', 0, 'UInt', 1, 'Ptr', 0, 'UInt', 0, 'UIntP', Size, 'UIntP', 0)
    If (!VarSetCapacity(PRINTER_INFO_1, Size, 0))
        Return (FALSE)

    If (!DllCall('Winspool.drv\EnumPrintersW', 'UInt', 0x02000002, 'Ptr', 0, 'UInt', 1, 'UPtr', &PRINTER_INFO_1, 'UInt', Size, 'UIntP', 0, 'UIntP', Count))
        Return (FALSE)
    
    Loop (Count)
    {
        List[A_Index] := { Flags      : NumGet(&PRINTER_INFO_1 + Offset, 'UInt')
                         , Description: StrGet(NumGet(&PRINTER_INFO_1 + Offset + A_PtrSize), 'UTF-16')
                         , Name       : StrGet(NumGet(&PRINTER_INFO_1 + Offset + A_PtrSize), 'UTF-16')
                         , Comment    : StrGet(NumGet(&PRINTER_INFO_1 + Offset + A_PtrSize), 'UTF-16') }
        Offset        += A_PtrSize == 4 ? 16 : 32
    }

    Return (List)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/dd162692(v=vs.85).aspx




/*
    Recupera el nombre de impresora de la impresora predeterminada para el usuario actual en el equipo local.
*/
GetDefaultPrinter()
{
    Local Size, Buffer

    DllCall('Winspool.drv\GetDefaultPrinterW', 'Ptr', 0, 'UIntP', Size)
    If (!VarSetCapacity(Buffer, Size * 2, 0))
        Return ('')

    If (!DllCall('Winspool.drv\GetDefaultPrinterW', 'UPtr', &Buffer, 'UIntP', Size))
        Return ('')

    Return (StrGet(&Buffer, 'UTF-16'))
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/dd144876(v=vs.85).aspx




/*
    Establece el nombre de impresora de la impresora predeterminada para el usuario actual en el equipo local.
*/
SetDefaultPrinter(PrinterName)
{
    Return (DllCall('Winspool.drv\SetDefaultPrinterW', 'UPtr', &PrinterName))
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/dd162971(v=vs.85).aspx
