WTSSendMessage(Text, Title := "", Options := 0, Timeout := 0, Wait := True, Session := -1, Server := 0, ByRef Response := 0) {
    DllCall("winsta.dll\WinStationSendMessage"
        , "Ptr" , Server
        , "UInt", Session
        , "Str" , Title
        , "UInt", StrLen(Title) * 2
        , "Str" , Text
        , "UInt", StrLen(Text) * 2
        , "UInt", Options
        , "UInt", Timeout
        , "Int*", Response
        , "UInt", !Wait)

    Return {1: "OK", 2: "Cancel", 3: "Abort", 4: "Retry", 5: "Ignore", 6: "Yes", 7: "No", 10: "Try Again", 11: "Continue", 32000: "Timeout"}[Response]
}