/*
    Enumera todas las entradas en la lista de propiedades de una ventana.
    Parámetros:
        hWnd: El identificador de la ventana.
    Return:
              0 = La ventana especificada no existe.
        [array] = Si tuvo éxito devuelve un Array de objetos. Cada objeto tiene las siguientes claves:
            String = El componente de cadena de una entrada de lista de propiedades.
            Data   = El identificador a los datos. Este identificador es el componente de datos de una entrada de lista de propiedades.
    Ejemplo:
        For Each, Prop in EnumWindowProps(hWnd := WinExist('A'))
            List .= Prop.String . ' [' . Prop.Data . ']`n'
        MsgBox('Window ID: ' . hWnd . '`n`n' . List)
*/
EnumWindowProps(hWnd)
{
    If (!DllCall('User32.dll\IsWindow', 'Ptr', hWnd))
        Return (FALSE)

    Local Data      := {}
        , pCallback := RegisterCallback('PropEnumProcEx')

    DllCall('User32.dll\EnumPropsExW', 'Ptr', hWnd, 'UPtr', pCallback, 'UPtr', &Data)
    DllCall('Kernel32.dll\GlobalFree', 'UPtr', pCallback, 'UPtr')

    Return (Data)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633563(v=vs.85).aspx

PropEnumProcEx(hWnd, pString, hData, pData)
{
    Object(pData).Push({String: StrGet(pString, 'UTF-16'), Data: hData})
    Return (TRUE)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633566(v=vs.85).aspx




/*
    Agrega una nueva entrada o cambia una entrada existente en la lista de propiedades de la ventana especificada. La función agrega una nueva entrada a la lista si la cadena de caracteres especificada no existe ya en la lista. La nueva entrada contiene la cadena y el identificador. De lo contrario, la función reemplaza el identificador actual de la cadena con el identificador especificado.
    Parámetros:
        hWnd  : El identificador de la ventana.
        String: Una cadena.
        Data  : Un identificador a los datos que se van a copiar a la lista de propiedades.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
*/
SetWindowProp(hWnd, String, Data := 0)
{
    Return (DllCall('User32.dll\SetPropW', 'Ptr', hWnd, 'Str', String, 'Ptr', Data))
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633568(v=vs.85).aspx




/*
    Recupera un identificador de datos de la lista de propiedades de la ventana especificada.
    Parámetros:
        hWnd  : El identificador de la ventana.
        String: Una cadena.
    Return:
        Si la lista de propiedades contiene la cadena, el valor de retorno es el identificador de datos asociado. De lo contrario, el valor devuelto es 0.
*/
GetWindowProp(hWnd, String)
{
    Return (DllCall('User32.dll\GetPropW', 'Ptr', hWnd, 'Str', String, 'Ptr'))
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633564(v=vs.85).aspx




/*
    Eliminar una entrada de la lista de propiedades de la ventana especificada. La cadena de caracteres especificada identifica la entrada que se va a eliminar.
    Parámetros:
        hWnd  : El identificador de la ventana.
        String: Una cadena.
    Return:
        El valor de retorno identifica los datos especificados. Si los datos no se pueden encontrar en la lista de propiedades especificada, el valor devuelto es 0.
*/
RemoveWindowProp(hWnd, String)
{
    Return (DllCall('User32.dll\RemovePropW', 'Ptr', hWnd, 'Str', String, 'Ptr'))
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633567(v=vs.85).aspx
