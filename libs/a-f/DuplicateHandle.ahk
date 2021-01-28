/*
    Duplicar un identificador de objeto.
    Parámetros:
        hSourceProcessHandle = Un identificador al proceso con el identificador a ser duplicado. Requiere el acceso PROCESS_DUP_HANDLE.
        hSourceHandle        = El identificador a ser duplicado. Este es un identificador de objeto abierto que es válido en el contexto del proceso de origen (hSourceProcessHandle).
        hTargetProcessHandle = Un identificador al proceso que va a recibir el identificador duplicado. Requiere el acceso PROCESS_DUP_HANDLE.
        DesiredAccess        = El acceso solicitado para el nuevo identificador. Este parámetro se ignora si el parámetro Options especifica DUPLICATE_SAME_ACCESS. De lo contrario, los indicadores que se pueden especificar dependen del tipo de objeto cuyo identificador se va a duplicar.
        InheritHandle        = Indica si el identificador es heredable. Si es TRUE, el identificador duplicado puede ser heredado por los nuevos procesos creados por el proceso de destino. Si es falso, el nuevo identificador no se puede heredar.
        Options              = Acciones opcionales. Este parámetro puede ser cero, o cualquier combinación de los siguientes valores.
            0x00000001 = DUPLICATE_CLOSE_SOURCE --> Cierra el identificador de origen (hSourceHandle). Esto ocurre independientemente de cualquier estado de error devuelto.
            0x00000002 = DUPLICATE_SAME_ACCESS  --> Ignora el parámetro DesiredAccess. El identificador duplicado tiene el mismo acceso que el identificador de origen (hSourceHandle).
    Return:
        Si tuvo éxito devuelve el identificador duplicado, caso contrario devuelve 0. Consultar A_LastError para detalles del error.
*/
DuplicateHandle(hSourceProcessHandle, hSourceHandle, hTargetProcessHandle := -1, DesiredAccess := -1, InheritHandle := FALSE, Options := 0)
{
    Local hTargetHandle
    
    If (hTargetProcessHandle == -1)
        hTargetProcessHandle := hSourceProcessHandle

    If (DesiredAccess == -1)
    {
        DesiredAccess := 0
        Options       := 0x00000002
    }

    DllCall('Kernel32.dll\DuplicateHandle', 'Ptr', hSourceProcessHandle, 'Ptr', hSourceHandle, 'Ptr', hTargetProcessHandle, 'PtrP', hTargetHandle, 'UInt', DesiredAccess, 'Int', InheritHandle, 'UInt', Options)
    Return (hTargetHandle)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms724251(v=vs.85).aspx
