/*
    Recupera el dominio y nombre de usuario propietario y el grupo al que pertenece el archivo especificado.
    Parámetros:
        FileName : La ruta al archivo.
        GroupName: Devuelve el grupo al que pertenece.
    Ejemplo:
        MsgBox('Domain\Username: ' . GetFileOwner(A_ComSpec, GroupName) . '`nGroupName: ' . GroupName)
*/
GetFileOwner(FileName, ByRef GroupName := '') ;WIN_V+
{
    Local ADsSecurityUtility, ADsSecurityDescriptor, Owner

    Try
    {
        ADsSecurityUtility              := ComObjCreate('ADsSecurityUtility')
        ADsSecurityUtility.SecurityMask := 0x1 | 0x2
        ADsSecurityDescriptor           := ADsSecurityUtility.GetSecurityDescriptor(FileName, 1, 1)
        Owner                           := ADsSecurityDescriptor.Owner
        GroupName                       := ADsSecurityDescriptor.Group
    }

    Return (Owner)
}
