/*
    Recupera una lista de todas las funciones exportadas para el archivo dll especificado.
    Parámetros:
        DllPath: La ruta del archivo DLL.
    Return:
           -2 = El archivo no esta diseñado para ejecutarse en este tipo de procesador.
           -1 = El archivo no se ha podido abrir para leer en él.
            0 = El archivo especificado es inválido.
            1 = No se pudo encontrar una tabla de exportación
        [obj] = Si tuvo éxito devuelve un objeto con las siguientes claves: 
            Module    = El nombre del módulo.
            Total     = El número de funciones.
            Named     = 
            OrdBase   = El valor ordinal base.
            Bitness   = Bits (32 o 64).
            Functions = Un objeto con las siguientes claves:
                Name       = El nombre de la función.
                EntryPoint = El punto de entrada.
                Ordinal    = El valor ordinal.
    Ejemplo:
        ObjInfo := DllExports(A_WinDir . '\System32\User32.dll')
        g       := GuiCreate(, ObjInfo.Module)
        lv      := g.AddListView('x0 y0 h350 w500', 'Name|EntryPoint|Ordinal')
        sb      := g.AddStatusBar(), sb.SetParts(500//5+50, 500//5, 500//5, 500//5)
        Loop Parse, 'Module: ' . ObjInfo.Module '|Total: ' . ObjInfo.Total . '|Name: ' . ObjInfo.Named . '|OrdBase: ' . ObjInfo.OrdBase . '|x' . ObjInfo.Bitness, '|'
            sb.SetText(A_LoopField, A_Index)
        For Each, Obj in ObjInfo.Functions
            lv.Add(, Obj.Name, Obj.EntryPoint, Obj.Ordinal)
        g.Show('w500'), lv.ModifyCol(1, 'AutoHdr'), lv.ModifyCol(2, 'AutoHdr')
        WinWaitClose('ahk_id' . g.hWnd)
        ExitApp
*/
DllExports(DllPath)
{
    Local File, IMAGE_FILE_HEADER, MachineType, IMAGE_OPTIONAL_HEADER, Magic, Offset, NumberOfRvaAndSizes, ExportAddr, ExportSize, NumberOfSections
        , VirtualAddress, SizeOfRawData, PointerToRawData, Buffer, EndOfSection, ModNamePtr, OrdinalBase, FuncCount, NameCount, FuncTblPtr, NameTblPtr
        , Exports, NamePtr, Ordinal, FnAddr, EntryPt

    If (!(File := FileOpen(DllPath, 'r')))
        Return (-1)

    If (File.Pos)
        Return (0)

    If (File.ReadUShort() != 0x5A4D) ;MZ
        Return (0)

    File.Seek(0x3C)
    File.Seek(File.ReadUInt())
    If (File.ReadUInt() != 0x4550) ;PE
        Return (0)

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms680313(v=vs.85).aspx
    File.RawRead(IMAGE_FILE_HEADER, 20)

    MachineType := NumGet(&IMAGE_FILE_HEADER, 'UShort')
    If (MachineType != 0x8664 && MachineType != 0x014C && MachineType != 0x0200) ;IMAGE_FILE_MACHINE_AMD64|IMAGE_FILE_MACHINE_I386|IMAGE_FILE_MACHINE_IA64
        Return (-2)

    If (!(NumGet(IMAGE_FILE_HEADER, 18, 'UShort') & 0x2000)) ;Characteristics --> IMAGE_FILE_DLL
        Return (FALSE)

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms680339(v=vs.85).aspx
    File.RawRead(IMAGE_OPTIONAL_HEADER, NumGet(&IMAGE_FILE_HEADER + 16, 'UShort')) ;SizeOfOptionalHeader

    Magic  := NumGet(&IMAGE_OPTIONAL_HEADER, 'UShort')
    Offset := (Magic = 0x020B) ? 16 : 0

    If ((NumberOfRvaAndSizes := NumGet(&IMAGE_OPTIONAL_HEADER + 92 + Offset    , 'UInt')) < 1
     || (ExportAddr          := NumGet(&IMAGE_OPTIONAL_HEADER + 92 + Offset + 4, 'UInt')) < 1
     || (ExportSize          := NumGet(&IMAGE_OPTIONAL_HEADER + 92 + Offset + 8, 'UInt')) < 1)
        Return (1)
    
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms680341(v=vs.85).aspx
    NumberOfSections := NumGet(&IMAGE_FILE_HEADER + 2, 'UShort')
    File.RawRead(IMAGE_SECTION_HEADER, 40 * NumberOfSections)

    VarSetCapacity(Buffer, NumGet(&IMAGE_OPTIONAL_HEADER + 56, 'UInt'), 0) ;SizeOfImage
    Offset := 0
    Loop (NumberOfSections)
    {
        VirtualAddress   := NumGet(&IMAGE_SECTION_HEADER + Offset + 12, 'UInt')
        SizeOfRawData    := NumGet(&IMAGE_SECTION_HEADER + Offset + 16, 'UInt')
        PointerToRawData := NumGet(&IMAGE_SECTION_HEADER + Offset + 20, 'UInt')
        Offset           += 40

        File.Seek(PointerToRawData)
        File.RawRead(&Buffer + VirtualAddress, SizeOfRawData)
    }

    EndOfSection := ExportAddr + ExportSize
    ModNamePtr   := NumGet(&Buffer + ExportAddr + 0x0C, 'UInt') ; pointer to an ASCII string that contains the name of the DLL
    OrdinalBase  := NumGet(&Buffer + ExportAddr + 0x10, 'UInt') ; starting ordinal number for exports in this image
    FuncCount    := NumGet(&Buffer + ExportAddr + 0x14, 'UInt') ; number of entries in the export address table
    NameCount    := NumGet(&Buffer + ExportAddr + 0x18, 'UInt') ; number of entries in the name pointer table
    FuncTblPtr   := NumGet(&Buffer + ExportAddr + 0x1C, 'uint') ; pointer to the export address table
    NameTblPtr   := NumGet(&Buffer + ExportAddr + 0x20, 'UInt') ; pointer to the export name pointer table
    OrdTblPtr    := NumGet(&Buffer + ExportAddr + 0x24, 'UInt') ; pointer to the ordinal table
    Exports      := {Module    : StrGet(&Buffer + ModNamePtr, 'CP0')
                    , Total    : FuncCount
                    , Named    : NameCount
                    , OrdBase  : OrdinalBase
                    , Bitness  : (Magic == 0x020B) ? 64 : 32
                    , Functions: []}

    Loop (NameCount)
    {
        NamePtr    := NumGet(&Buffer + NameTblPtr, 'UInt')
        Ordinal    := NumGet(&Buffer + OrdTblPtr, 'UShort')
        FnAddr     := NumGet(&Buffer + FuncTblPtr + (Ordinal * 4), 'UInt')
        EntryPt    := (FnAddr > ExportAddr && FnAddr < EndOfSection) ? StrGet(&Buffer + FnAddr, 'CP0') : Format('0x{:08X}', FnAddr)
        NameTblPtr += 4
        OrdTblPtr  += 2

        Exports.Functions.Push({Name      : StrGet(&Buffer + NamePtr, 'CP0')
                              , EntryPoint: EntryPt
                              , Ordinal   : Ordinal + OrdinalBase})
    }

    Return (Exports)
} ;https://autohotkey.com/boards/viewtopic.php?f=6&t=34262
