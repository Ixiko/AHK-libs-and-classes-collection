Edit()
{
    Edit
}

FileAppend(Text:="", Filename:="", Encoding:="")
{
    FileAppend %Text%, %Filename%, %Encoding%
    return !ErrorLevel
}

PostMessage(Msg, wParam:="", lParam:="", Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    PostMessage %Msg%, %wParam%, %lParam%, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    if (ErrorLevel = "FAIL")
        ErrorLevel := "ERROR"
}

RegDeleteKey(RootKeySubKey)
{
    RegDelete %RootKeySubKey%
    return !ErrorLevel
}

SendMessage(Msg, wParam:="", lParam:="", Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="", Timeout:="")
{
    SendMessage %Msg%, %wParam%, %lParam%, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%, %Timeout%
    if (ErrorLevel = "FAIL")
        ErrorLevel := "ERROR"
}
