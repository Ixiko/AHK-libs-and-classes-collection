/*
    Determina la codificación de un archivo de texto.
    Parámetros:
        FileName: La ruta del archivo. Este parámetro también puede ser un objeto FileOpen o un identificador a un archivo con permiso de lectura.
    Return:
        0     = El archivo especificado no existe, no es un archivo o no se ha podido abrir para lectura.
        [str] = Una cadena vacía indica que no se ha podido determinar la codificación. Esto puede deberse a que el archivo sea ANSI.
        [str] = Una cadena que identifica la codificación del archivo. Puede ser una de las siguientes cadenas:
            BOCU-1, SCSU, UTF-EBCDIC, UTF-1, UTF-7, UTF-8, UTF-32LE, UTF-32BE, UTF-16LE, UTF-16BE
    Referencia:
        BOM: https://es.wikipedia.org/wiki/Marca_de_orden_de_bytes
    Observaciones:
        AutoHotkey solo soporta ANSI, UTF-8 y UTF-16LE.
    Ejemplo:
        MsgBox(GetFileEncoding(FileSelect()))
*/
GetFileEncoding(FileName)
{
    Local Length, Pos, Byte
        , File := FileName

    If (!IsObject(FileName))
    {
        If (Type(FileName) == 'Integer')
        {
            If (!(File := FileOpen(FileName, 'h')))
                Return (0)
        }
        Else
        {
            If (!(File := FileOpen(FileName, 'r')))
                Return (0)
        }
    }

    If ((Length := File.Length) < 2)
        Return ('')

    Pos      := File.Pos
    File.Pos := 0
    Byte     := []
    Loop
        Byte.Push(File.ReadUchar())
    Until (A_Index == 4 || A_Index == Length)
    File.Seek(Pos)

    If (Length < 3)
    {
        If (Byte[1] == 0xFE && Byte[2] == 0xFF)
            Return ('UTF-16BE')
        Else If (Byte[1] == 0xFF && Byte[2] == 0xFE)
            Return ('UTF-16LE')
    }
    Else If (Length < 4)
    {
        If (Byte[1] == 0xEF && Byte[2] == 0xBB && Byte[3] == 0xBF)
            Return ('UTF-8')
        Else If (Byte[1] == 0xF7 && Byte[2] == 0x64 && Byte[3] == 0x4C)
            Return ('UTF-1')
        Else If (Byte[1] == 0x0E && Byte[2] == 0xFE && Byte[3] == 0xFF)
            Return ('SCSU')
        Else If (Byte[1] == 0xFB && Byte[2] == 0xEE && Byte[3] == 0x28)
            Return ('BOCU-1')
    }
    Else
    {
        If (Byte[1] == 0x00 && Byte[2] == 0x00 && Byte[3] == 0xFE && Byte[4] == 0xFF)
            Return ('UTF-32BE')
        Else If (Byte[1] == 0xFF && Byte[2] == 0xFE && Byte[3] == 0x00 && Byte[4] == 0x00)
            Return ('UTF-32LE')
        Else If (Byte[1] == 0xDD && Byte[2] == 0x73 && Byte[3] == 0x66 && Byte[4] == 0x73)
            Return ('UTF-EBCDIC')
        Else If (Byte[1] == 0x2B && Byte[2] == 0x2F && Byte[3] == 0x76 && (Byte[4] == 0x38 || Byte[4] == 0x39 || Byte[4] == 0x2B || Byte[4] == 0x2F))
            Return ('UTF-7')
        Else If (Byte[1] == 0xFB && Byte[2] == 0xEE && Byte[3] == 0x28 && Byte[4] == 0xFF)
            Return ('BOCU-1')
        Else If (Byte[1] == 0xEF && Byte[2] == 0xBB && Byte[3] == 0xBF)
            Return ('UTF-8')
        Else If (Byte[1] == 0xF7 && Byte[2] == 0x64 && Byte[3] == 0x4C)
            Return ('UTF-1')
        Else If (Byte[1] == 0x0E && Byte[2] == 0xFE && Byte[3] == 0xFF)
            Return ('SCSU')
        Else If (Byte[1] == 0xFB && Byte[2] == 0xEE && Byte[3] == 0x28)
            Return ('BOCU-1')
        Else If (Byte[1] == 0xFE && Byte[2] == 0xFF)
            Return ('UTF-16BE')
        Else If (Byte[1] == 0xFF && Byte[2] == 0xFE)
            Return ('UTF-16LE')
    }

    Return ('')
}
