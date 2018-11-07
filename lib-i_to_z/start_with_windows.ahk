start_with_windows(seperator="", menu_name="tray") {
    global sww_shortcut, sww_menu

    sww_menu := menu_name
    if (seperator = "1") or (seperator = "3")
        menu, % sww_menu, add,
    menu, % sww_menu, add, Start with Windows, start_with_windows

    splitPath, a_scriptFullPath, , , , script_name
    sww_shortcut := a_startup "\" script_name ".lnk"

    ifExist, % sww_shortcut
        {
        fileGetShortcut, % sww_shortcut, target  ;# update if script has moved
        if (target != a_scriptFullPath)
            fileCreateShortcut, % a_scriptFullPath, % sww_shortcut
        menu, % sww_menu, check, Start with Windows
        }
    else menu, % sww_menu, unCheck, Start with Windows

    if (seperator = "2") or (seperator = "3")
        menu, % sww_menu, add,
}



start_with_windows:     ;# action when tray item is clicked
ifExist, % sww_shortcut
    {
    fileDelete, % sww_shortcut
    menu, % sww_menu, unCheck, Start with Windows
    trayTip, Start With Windows, Shortcut removed , 5
    }
else
    {
    fileCreateShortcut, % a_scriptFullPath, % sww_shortcut
    menu, % sww_menu, check, Start with Windows
    trayTip, Start With Windows, Shortcut created , 5
    }
return


/*
[script info]
version     = 2
description = tray option to start your scripts when windows starts
author      = davebrny
source      = git.io/vMv74
*/