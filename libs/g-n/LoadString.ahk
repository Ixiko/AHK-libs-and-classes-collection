/*
    Carga un recurso de cadena del archivo ejecutable asociado con un módulo especificado y copia la cadena.
    Parámetros:
        hInstance: Un identificador para una instancia del módulo cuyo archivo ejecutable contiene el recurso de cadena. Para obtener el identificador a la aplicación en sí, llame a la función GetModuleHandle con 0.
        uID: El identificador de la cadena que se va a cargar.
    Return:
        Si tuvo éxito devuelve la cadena, caso contrario devuelve una cadena vacía.
    ErrorLevel:
        0 = La cadena se ha recuperado con éxito.
        1 = Ha ocurrido un error. Esto puede deberse a que hInstance es inválido o uID no existe.
    Notas:
        Para hInstance puede utilizar: DllCall('Kernel32.dll\LoadLibraryExW', 'Str', FileName, 'UInt', 0, 'UInt', 0x2, 'Ptr').
        Para liberar hInstance debe utilziar: DllCall('Kernel32.dll\FreeLibrary', 'Ptr', hInstance).

	Loads a string resource from the executable file associated with a specified module and copies the string.
	Parameters:
        hInstance: an identifier for an instance of the module whose executable file contains the string resource. To get the identifier to the application itself, call the GetModuleHandle function with 0.
        uID: The identifier of the string to be loaded.
	Return:
        If successful returns the string, otherwise returns an empty string.
	ErrorLevel:
        0 = The string was successfully retrieved.
        1 = An error occurred. This may be because hInstance is invalid or uID does not exist.
	Notes:
        For hInstance you can use: DllCall('Kernel32.dll\LoadLibraryExW', 'Str', FileName, 'UInt', 0, 'UInt', 0x2, 'Ptr').
        To free hInstance you must use: DllCall('Kernel32.dll\FreeLibrary', 'Ptr', hInstance).
	Example:
	Ejemplo:
			hInstance := DllCall('Kernel32.dll\LoadLibraryExW', 'Str', 'mswsock.dll', 'UInt', 0, 'UInt', 0x2, 'Ptr')
			MsgBox('String`t:' . LoadString(hInstance, 60100) . '`nErrorLevel`t:' . ErrorLevel)
			DllCall('Kernel32.dll\FreeLibrary', 'Ptr', hInstance)
		*/
LoadString(hInstance, uID)
{
    Local Size, p, String

    ;Recupera un puntero de sólo lectura para el recurso en sí. Si no existe, LoadStringW devuelve 0
    If (!(Size := DllCall('User32.dll\LoadStringW', 'Ptr', hInstance, 'UInt', Abs(uID), 'UPtrP', p, 'Int', 0)))
    {
        ErrorLevel := TRUE
        Return ('')
    }

    String     := StrGet(p, Size, 'UTF-16')
    ErrorLevel := FALSE

    Return (String)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms647486(v=vs.85).aspx
