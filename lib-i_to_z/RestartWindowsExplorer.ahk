/*
    Reinicia el Explorador de Archivos de Windows.
*/
RestartWindowsExplorer()
{
    R := WinExist('ahk_exe ' . A_WinDir . '\explorer.exe')
    For Each, hWnd In WinGetList('ahk_exe ' . A_WinDir . '\explorer.exe')
    {
        DllCall('User32.dll\PostMessageW', 'Ptr', hWnd, 'UInt', 0x0016, 'UInt', 0x1, 'Ptr', 0)
        DllCall('User32.dll\PostMessageW', 'Ptr', hWnd, 'UInt', 0x0012, 'Ptr', 0, 'Ptr', 0)
    }

    if (R == '' || R == FALSE)
        Run(A_WinDir . '\explorer.exe', A_WinDir, 'Min')
} ;http://www.replicator.org/journal/200908012325-how-to-shutdown-explorerexe-gracefully-from-c
