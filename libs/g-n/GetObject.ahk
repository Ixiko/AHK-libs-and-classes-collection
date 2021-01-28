/*
    Recupera información para el objeto gráfico especificado.
    Parámetros:
        hObject: Un identificador para el objeto gráfico de interés. Esto puede ser un identificador para uno de los siguientes: un mapa de bits lógico, un pincel, una fuente, una paleta, un lápiz o un mapa de bits independiente de dispositivo creado por llamar a la función CreateDIBSection.
        Size   : El número de bytes de información que se escribirá en el búfer.
        pInfo  : Un puntero a un búfer que recibe la información sobre el objeto de gráficos especificado.
    Return:
        Si la función tiene éxito y 'pInfo' es un puntero válido, el valor devuelto es el número de bytes almacenados en el búfer.
        Si la función tiene éxito y 'pInfo' es 0, el valor devuelto es el número de bytes necesarios para mantener la información que la función almacenaría en el búfer.
        Si la función falla, el valor devuelto es 0.
*/
GetObject(hObject, Size := 0, pInfo := 0)
{
    Return (DllCall('Gdi32.dll\GetObjectW', 'Ptr', hObject, 'Int', Size, 'UPtr', pInfo, 'UInt'))
} ;https://msdn.microsoft.com/en-us/library/dd144904(v=vs.85).aspx
