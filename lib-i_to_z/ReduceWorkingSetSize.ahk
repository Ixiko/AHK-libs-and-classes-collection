/*
    Reduce el consumo de memoria del proceso de llamada.
*/
ReduceWorkingSetSize()
{
    DllCall('Kernel32.dll\SetProcessWorkingSetSize', 'Ptr', DllCall('Kernel32.dll\GetCurrentProcess', 'Ptr'), 'Ptr', -1, 'Ptr', -1)
}
