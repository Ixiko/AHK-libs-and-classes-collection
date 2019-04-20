/*
    Escribe texto en la línea espesificada de un archivo.
    Parámetros:
        Text: El texto a escribir.
        FileName: La ruta al archivo.
        Line: El número de la línea.
        Encoding: La codificación a utilizar.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
    ErrorLevel:
        Si tuvo éxito se establece en el número de bytes escritos, caso contrario el valor establecido no tiene importancia.
    Ejemplo:
        ReturnValue := WriteFileLine(InputBox('Ingrese el texto a escribir'), FileSelect(), InputBox('Ingrese el número de línea'))
        MsgBox(ReturnValue ? 'Bytes escritos: ' . ErrorLevel : 'Ha ocurrido un error!')
*/
WriteFileLine(Text, FileName, Line, Encoding := '')
{
    Local NewText, File
        , Lines := 0

    Loop Parse, FileRead(FileName, Encoding), '`n', '`r'
    {
        NewText .= (A_Index == Line ? Text : A_LoopField) . '`n'
        ++Lines
    }
    
    If (ErrorLevel)
        Return (FALSE)
    
    Loop (Line - Lines)
        NewText .= ((A_Index + Lines) == Line ? Text : '') . '`n'

    if (!(File := FileOpen(FileName, 1 + 4, Encoding)))
        Return (FALSE)

    ErrorLevel := File.Write(SubStr(NewText, 1, -1))

    Return (TRUE)
}
