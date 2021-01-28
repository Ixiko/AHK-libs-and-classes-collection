/*
    Recupera el texto en la línea espesificada de un archivo.
    Parámetros:
        FileName: La ruta al archivo.
        Line    : El número de la línea.
        Encoding: La codificación a utilizar.
    Return:
        Si tuvo éxito devuelve el texto en la línea especificada, caso contrario devuelve una cadena vacía.
    ErrorLevel:
        0 = El texto se ha recuperado con éxito.
        1 = Ha ocurrido un error al intentar abrir el archivo para lectura.
        2 = La línea especificada es inválida.
    Ejemplo:
        MsgBox(ReadFileLine(A_ScriptFullPath, 15) . '`nErrorLevel: ' . ErrorLevel)
*/
ReadFileLine(FileName, Line, Encoding := '')
{
    Local File

    If (!(File := FileOpen(FileName, 'r', Encoding)))
    {
        ErrorLevel := 1
        Return ('')
    }
    
    Loop (Line - 1)
    {
        File.ReadLine()

        If (File.AtEOF)
        {
            ErrorLevel := 2
            Return ('')
        }
    }

    ErrorLevel := 0

    Return (File.ReadLine())
}
