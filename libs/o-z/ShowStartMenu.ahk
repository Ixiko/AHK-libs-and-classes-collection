/*
    Muestra el Menú Inicio.
*/
ShowStartMenu() {
    DllCall('User32.dll\PostMessageW', 'Ptr', DllCall('User32.dll\GetForegroundWindow', 'Ptr'), 'UInt', 0x112, 'Ptr', 0xF130, 'Ptr', 0)
}
