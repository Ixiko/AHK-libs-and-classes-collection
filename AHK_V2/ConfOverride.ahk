; ----------------------------------------------------------------------------------------------------------------------
; Function .....: ConfOverride
; Description ..: Override a configuration object with data read from an ini configuration file.
; ..............: The configuration object needs to contain separate section objects with key:value pairs. Eg:
; ..............: CONF := {}, CONF.SCRIPT := { a:"value", b:"value" }, CONF.SETTINGS := { c:"value" } and so on...
; ..............: Use the pair __LOCKED:1 to avoid a section being overridden.
; Parameters ...: oConf - Configuration object to be passed byref.
; ..............: sFile - Path to the ini file.
; Return .......: 0 - Error.
; ..............: 1 - Object updated.
; ..............: 2 - Object not updated.
; AHK Version ..: AHK v2 x32/64 Unicode
; Author .......: cyruz - http://ciroprincipe.info
; License ......: WTFPL - http://www.wtfpl.net/txt/copying/
; Changelog ....: Oct. 04, 2022 - v0.1.0 - First version.
; ----------------------------------------------------------------------------------------------------------------------

ConfOverride(&oConf, sFile)
{
    If !FileExist(sFile)
        Return 0

    sIniFile := IniRead(sFile)
    Loop Parse, sIniFile, "`n"
    {
        If oConf.HasOwnProp(A_LoopField)
        {
            If oConf.%A_LoopField%.HasOwnProp("__LOCKED")
            && oConf.%A_LoopField%.__LOCKED
                Continue
            sSectionName    := A_LoopField
            sSectionContent := IniRead(sFile, sSectionName)
            Loop Parse, sSectionContent, "`n"
                If RegExMatch(A_LoopField, "S)^\s*(\w+)\s*\=\s*(.*)\s*$", &oMatch)
                    oConf.%sSectionName%.%oMatch.1% := oMatch.2, bUpdated := 1
       }
    }
    Return bUpdated ? 1 : 2
}
