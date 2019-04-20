/*
    Enumera todos los discos y sus particiones.
    Return:
        Devuelve un objeto, la clave es el número que identifica al disco, y el valor es un array con la letra de la partición.
    Ejemplo:
        For Disk, Partitions in EnumDiskDrives()
        {
            Str .= Disk . '`n'
            For Each, Partition in Partitions
                Str .= '`t' . Partition . '`n'
            Str .= '`n'
        }
        MsgBox(Str)
*/
EnumDiskDrives()
{
    Local n, Disk
        , List := {}

    For Obj in ComObjGet('winmgmts:\\.\root\CIMV2').ExecQuery('SELECT * FROM Win32_LogicalDiskToPartition')
    {
        Disk := SubStr(Obj.Antecedent, n:=InStr(Obj.Antecedent, 'Disk #')+6, InStr(Obj.Antecedent, ',')-n)
        If (!List.HasKey(Disk))
            List[Disk] := []
        List[Disk][StrReplace(SubStr(Obj.Antecedent, n:=InStr(Obj.Antecedent, 'Partition #')+11, 3), '"')] := SubStr(Obj.Dependent, n:=InStr(Obj.Dependent, '="')+2, InStr(Obj.Dependent, ':"')-n)
    }

    Return (List)
} ;https://autohotkey.com/board/topic/89345-physical-hard-drive-information/
