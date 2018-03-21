; GetCommonPath - Get path to standard system folder by majkinetor
; http://www.autohotkey.com/forum/topic10325.html
GetCommonPath( csidl )
{
        static init

        if !init
        {
                CSIDL_APPDATA                 =0x001A     ; Application Data, new for NT4
                CSIDL_COMMON_APPDATA          =0x0023     ; All Users\Application Data
                CSIDL_COMMON_DOCUMENTS        =0x002e     ; All Users\Documents
                CSIDL_DESKTOP                 =0x0010     ; C:\Documents and Settings\username\Desktop
                CSIDL_FONTS                   =0x0014     ; C:\Windows\Fonts
                CSIDL_LOCAL_APPDATA           =0x001C     ; non roaming, user\Local Settings\Application Data
                CSIDL_MYMUSIC                 =0x000d     ; "My Music" folder
                CSIDL_MYPICTURES              =0x0027     ; My Pictures, new for Win2K
                CSIDL_PERSONAL                =0x0005     ; My Documents
                CSIDL_PROGRAM_FILES_COMMON    =0x002b     ; C:\Program Files\Common
                CSIDL_PROGRAM_FILES           =0x0026     ; C:\Program Files
                CSIDL_PROGRAMS                =0x0002     ; C:\Documents and Settings\username\Start Menu\Programs
                CSIDL_RESOURCES               =0x0038     ; %windir%\Resources\, For theme and other windows resources.
                CSIDL_STARTMENU               =0x000b     ; C:\Documents and Settings\username\Start Menu
                CSIDL_STARTUP                 =0x0007     ; C:\Documents and Settings\username\Start Menu\Programs\Startup.
                CSIDL_SYSTEM                  =0x0025     ; GetSystemDirectory()
                CSIDL_WINDOWS                 =0x0024     ; GetWindowsDirectory()
        }

       
        val = % CSIDL_%csidl%
        VarSetCapacity(fpath, 256)
        DllCall( "shell32\SHGetFolderPathA", "uint", 0, "int", val, "uint", 0, "int", 0, "str", fpath)
        return %fpath%
}