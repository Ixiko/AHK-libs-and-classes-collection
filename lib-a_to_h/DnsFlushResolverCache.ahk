/*
    Vacía el cache DNS por completo, igual a 'ipconfig /flushdns' en la consola.
    Return:
        Si tuvo éxito devuelve 1, en caso contrario devuelve 0.
*/
DnsFlushResolverCache()
{
    Return (DllCall('dnsapi.dll\DnsFlushResolverCache'))
} ;https://autohotkey.com/boards/viewtopic.php?f=6&t=3514&start=40#p85877
