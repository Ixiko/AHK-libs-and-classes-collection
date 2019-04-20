/*
    Actualiza el escritorio.
*/
UpdateDesktop()
{
    Local hProgman := DllCall('User32.dll\FindWindowW', 'Str', 'Progman', 'Ptr', 0, 'Ptr')
    Return (hProgman ? DllCall('User32.dll\PostMessageW', 'Ptr', hProgman, 'UInt', 0x111, 'Ptr', 0xA220, 'Ptr', 0) : 0) ;WIN_XP=0x7103
}
