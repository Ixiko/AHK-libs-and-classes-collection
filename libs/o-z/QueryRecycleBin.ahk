/*
    Recupera el tamaño de la papelera de reciclaje y el número de elementos en ella para una unidad especificada.
    Parámetros:
        RootPath: La ruta de la unidad raíz en la que se encuentra la papelera de reciclaje. Si este parámetro es una cadena vacía o 0 se recupera para todas las unidades.
    Return:
        Si tuvo éxito devuelve un objeto con las siguientes claves:
            Size  = El tamaño de todos los archivos en la papelera de reciclaje, en bytes.
            Items = El número de elementos en la papelera de reciclaje.
        Caso contrario devuelve 0.
*/
QueryRecycleBin(RootPath := '')
{
    Local SHQUERYRBINFO, R, Size

    RootPath := RootPath ? SubStr(RootPath, 1, 1) . ':' : 0
    Size     := VarSetCapacity(SHQUERYRBINFO, 16 + A_PtrSize, 0)

    NumPut(Size, &SHQUERYRBINFO, 'UInt') ;SHQUERYRBINFO.cbSize

    R := DllCall('Shell32.dll\SHQueryRecycleBinW', 'UPtr', &RootPath      ;pszRootPath
                                                 , 'UPtr', &SHQUERYRBINFO ;pSHQueryRBInfo
                                                 , 'UInt')                ;ReturnType
    
    Return (R ? FALSE 
              : { Size : NumGet(&SHQUERYRBINFO + A_PtrSize                 , 'Int64')    ;SHQUERYRBINFO.i64Size
                , Items: NumGet(&SHQUERYRBINFO + (A_PtrSize == 4 ? 12 : 16), 'Int64') }) ;SHQUERYRBINFO.i64NumItems
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/bb762241(v=vs.85).aspx




/*
    https://msdn.microsoft.com/en-us/library/windows/desktop/bb759803(v=vs.85).aspx

    typedef struct {
      DWORD   cbSize;
      __int64 i64Size;
      __int64 i64NumItems;
    } SHQUERYRBINFO, *LPSHQUERYRBINFO;

    ----------------------------------------------------------------------------------------------------------------------------------------
    Notas generales:
        Cada corchete equivale a 1 Byte (8 bits) y el número que encierra representa el offset (desplazamiento de bytes)
        Cada fila o línea de conjunto de corchetes equivale a una palabra, que representa 4 u 8 Bytes dependiendo de si el SO es de 32 o 64-Bits respectivamente.

    32-Bits (word size = 32 bits = 4 bytes):
        DWORD   (4 Bytes): [0]  | [1]  | [2]  | [3]  --> (cbSize. offset 0~3)        --> OFFSET = 0
        __int64 (8 Bytes): [4]  | [5]  | [6]  | [7]  --> (i64Size. offset 4~11)      --> OFFSET = 4 (A_PtrSize)
                           [8]  | [9]  | [10] | [11]
        __int64 (8 Bytes): [12] | [13] | [14] | [15] --> (i64NumItems. offset 12~19) --> OFFSET = 12
                           [16] | [17] | [18] | [19]
    Total: 20 Bytes.
    Nota: Los bytes de 8 a 11 forman parte de i64Size; y los bytes de 16 a 19 forman parte de i64NumItems (en un SO de 32-Bits, cada palabra equivale a
        4 Byes; por lo que para almacenar un valor de 8 Bytes hacemos uso de 2 palabras)

    64-Bits (word size = 64 bits = 8 bytes):
        DWORD   (4 Bytes): [0]  | [1]  | [2]  | [3]  | [4]  | [5]  | [6]  | [7]  --> (cbSize. offset 0~3)        --> OFFSET = 0                | padding. 4~7
        __int64 (8 Bytes): [8]  | [9]  | [10] | [11] | [12] | [13] | [14] | [15] --> (i64Size. offset 8~15)      --> OFFSET = 8  (A_PtrSize)
        __int64 (8 Bytes): [16] | [17] | [18] | [19] | [20] | [21] | [22] | [23] --> (i64NumItems. offset 16~23) --> OFFSET = 16 (2*A_PtrSize)
    Total: 24 Bytes.
    Nota: Los bytes de 4 a 7 (4 bytes) no se utilizan ya que no alcanza para almacenar un __int64 (8 bytes), entonces actua como un relleno (padding)
        y se utiliza la siguiente palabra (en un SO de 64-Bits, cada palabra equivale a 8 Bytes)
    ----------------------------------------------------------------------------------------------------------------------------------------

    Info sobre los tipos de datos:
        Windows Data Types: https://msdn.microsoft.com/en-us/library/windows/desktop/aa383751(v=vs.85).aspx
        Data Type Ranges  : https://msdn.microsoft.com/en-us/library/s3f49ktz.aspx
*/
