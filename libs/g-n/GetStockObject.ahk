/*
    Retrieves an identifier to one of the pens, brushes, fonts or palettes.
    Parameters:
        StockObjectType: The type of stock object.
*/
GetStockObject(StockObjectType){
    Return (DllCall('Gdi32.dll\GetStockObject', 'Int', StockObjectType, 'Ptr'))
} ;https://msdn.microsoft.com/en-us/library/dd144925(v=vs.85).aspx
