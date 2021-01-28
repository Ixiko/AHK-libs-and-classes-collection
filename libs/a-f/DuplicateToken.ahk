/*
    Crea un nuevo Token de acceso que duplica un Token existente. Esta función puede crear un Token primario o un Token de suplantación.
    Parámetros:
        hToken            : Un identificador a un Token de acceso abierto con el acceso TOKEN_DUPLICATE.
        DesiredAccess     : Especifica los derechos de acceso solicitados para el nuevo Token. Para solicitar los mismos derechos de acceso que el Token existente, especifique cero.
        TokenAttributes   : Especifica un descriptor de seguridad para el nuevo Token y determina si los procesos secundarios pueden heredar el Token.
        ImpersonationLevel: Especifica un valor de la enumeración SECURITY_IMPERSONATION_LEVEL que indica el nivel de suplantación del nuevo token.
            0 = SecurityAnonymous      --> El proceso de servidor no puede obtener información de identificación sobre el cliente y no puede suplantar al cliente.
            1 = SecurityIdentification --> El proceso del servidor puede obtener información sobre el cliente, como identificadores de seguridad y privilegios, pero no puede suplantar al cliente. Esto es útil para servidores que exportan sus propios objetos, por ejemplo, productos de base de datos que exportan tablas y vistas. Utilizando la información de seguridad del cliente recuperada, el servidor puede tomar decisiones de validación de acceso sin poder utilizar otros servicios que utilizan el contexto de seguridad del cliente.
            2 = SecurityImpersonation  --> El proceso del servidor puede suplantar el contexto de seguridad del cliente en su sistema local. El servidor no puede suplantar al cliente en sistemas remotos.
            3 = SecurityDelegation     --> El proceso del servidor puede suplantar el contexto de seguridad del cliente en sistemas remotos.
        TokenType         : Especifica uno de los siguientes valores de la enumeración TOKEN_TYPE.
            1 = TokenPrimary       --> Indica un token primario.
            2 = TokenImpersonation --> Indica un token de suplantación.
    Observaciones:
        La suplantación es la capacidad de un proceso para tomar los atributos de seguridad de otro proceso.
*/
DuplicateToken(hToken, DesiredAccess := 0, TokenAttributes := 0, ImpersonationLevel := 1, TokenType := 1)
{
    Local hNewToken

    DllCall('Advapi32.dll\DuplicateTokenEx', 'Ptr' , hToken
                                           , 'UInt', DesiredAccess      ;https://msdn.microsoft.com/en-us/library/windows/desktop/aa374905(v=vs.85).aspx
                                           , 'Ptr' , TokenAttributes    ;SECURITY_ATTRIBUTES (https://msdn.microsoft.com/en-us/library/windows/desktop/aa379560(v=vs.85).aspx).
                                           , 'Int' , ImpersonationLevel ;SECURITY_IMPERSONATION_LEVEL (https://msdn.microsoft.com/en-us/library/windows/desktop/aa379572(v=vs.85).aspx).
                                           , 'UInt', TokenType          ;TOKEN_TYPE (https://msdn.microsoft.com/en-us/library/windows/desktop/aa379633(v=vs.85).aspx).
                                           , 'PtrP', hNewToken)
  
    Return (hNewToken)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/aa446617(v=vs.85).aspx
