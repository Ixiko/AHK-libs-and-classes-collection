/*
    Recupera un identificador a uno de los bolígrafos, pinceles, fuentes o paletas.
    Parámetros:
        StockObjectType: El tipo de objeto de inventario.
*/
GetStockObject(StockObjectType)
{
    Return (DllCall('Gdi32.dll\GetStockObject', 'Int', StockObjectType, 'Ptr'))
} ;https://msdn.microsoft.com/en-us/library/dd144925(v=vs.85).aspx
