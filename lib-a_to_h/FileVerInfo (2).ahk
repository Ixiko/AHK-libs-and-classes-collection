
; ----------------------------------------------------------------------------------------------------------------------
; Function .....: FileVerInfo
; Description ..: Return Version Information for the selected file
; Parameters ...: sFile   - Path to the file.
; ..............: sVerStr - Pipe-separated list of the properties to retrieve. If empty, it gets all properties.
; Return .......: 0 on error or associative bidimensional array on success. Array is structured as the following:
; ..............: objVersions[objFileVer1, objFileVer2, ..., objFileVerN]
; ..............: objFileVer properties = Language, Codepage and all version properties requested to the function.
; AHK Version ..: AHK_L x32/64 Unicode
; Author .......: Cyruz - http://ciroprincipe.info
; License ......: WTFPL - http://www.wtfpl.net/txt/copying/
; Changelog ....: Nov. 17, 2012 - v0.1 - First revision.
; ..............: Jan. 07, 2014 - v0.2 - Unicode and x64 version. Return an object, not anymore a string.
; ----------------------------------------------------------------------------------------------------------------------
FileVerInfo(sFile, sVerStr:="") {
    Static LANGUAGES := "0401:Arabic|0415:Polish|0402:Bulgarian|0416:Portuguese (Brazil)|0403:Catalan|"
                     .  "0417:Rhaeto-Romanic|0404:Traditional Chinese|0418:Romanian|0405:Czech|0419:Russian|"
                     .  "0406:Danish|041A:Croato-Serbian (Latin)|0407:German|041B:Slovak|0408:Greek|041C:Albanian|"
                     .  "0409:U.S. English|041D:Swedish|040A:Castilian Spanish|041E:Thai|040B:Finnish|041F:Turkish|"
                     .  "040C:French|0420:Urdu|040D:Hebrew|0421:Bahasa|040E:Hungarian|0804:Simplified Chinese|"
                     .  "040F:Icelandic|0807:Swiss German|0410:Italian|0809:U.K. English|0411:Japanese|"
                     .  "080A:Spanish (Mexico)|0412:Korean|080C:Belgian French|0413:Dutch|0C0C:Canadian French|"
                     .  "0414:Norwegian ? Bokmal|100C:Swiss French|0810:Swiss Italian|0816:Portuguese (Portugal)|"
                     .  "0813:Belgian Dutch|081A:Serbo-Croatian (Cyrillic)|0814:Norwegian ? Nynorsk"
         , CODEPAGES := "0000:7-bit ASCII|03A4:Japan (Shift ? JIS X-0208)|03B5:Korea (Shift ? KSC 5601)|"
                     .  "03B6:Taiwan (Big5)|04B0:Unicode|04E2:Latin-2 (Eastern European)|04E3:Cyrillic|"
                     .  "04E4:Multilingual|04E5:Greek|04E6:Turkish|04E7:Hebrew|04E8:Arabic"
                        
    (sVerStr == "") ? sVerStr := "Comments|CompanyName|FileDescription|FileVersion|InternalName|LegalCopyright"
                    .  "|LegalTrademarks|OriginalFilename|ProductName|ProductVersion|PrivateBuild|SpecialBuild"

    If ( !szBuf := DllCall( "Version.dll\GetFileVersionInfoSize", Str,sFile, Ptr,0 ) )
        Return 0

    VarSetCapacity(cBuf, szBuf, 0)
    If ( !DllCall( "Version.dll\GetFileVersionInfo", Str,sFile, UInt,0, UInt,szBuf, Ptr,&cBuf ) )
        Return 0

    If ( !DllCall( "Version.dll\VerQueryValue", Ptr,&cBuf, Str,"\\VarFileInfo\\Translation", PtrP,addrVerBuf
                                              , PtrP,szVerBuf ) )
        Return 0
        
    VarSetCapacity(sLangCp, 18)
    DllCall( "msvcrt\swprintf", Str,sLangCp, Str,"%04X%04X", UShort,NumGet(addrVerBuf+0,"UShort")
                              , UShort,NumGet(addrVerBuf+2,"UShort") )

    objVersions := Object()
    Loop % szVerBuf/4 ; LANGUAGE + CODEPAGE = 4 byte 
    {
        RegExMatch(LANGUAGES, "S)" SubStr(sLangCp, 1, 4) ":([^\|]*)", OutLang)
        RegExMatch(CODEPAGES, "S)" SubStr(sLangCp, 5, 4) ":([^\|]*)", OutCode)
        objFileVer := { "Language": OutLang1, "Codepage": OutCode1 }
        Loop, PARSE, sVerStr, |
            If ( A_LoopField )
                DllCall( "Version.dll\VerQueryValue", Ptr,&cBuf, Str,"\\StringFileInfo\\" sLangCp "\\" A_LoopField
                                                    , PtrP,addrVerBuf, PtrP,szVerBuf )
              , objFileVer[A_LoopField] := StrGet(addrVerBuf, szVerBuf, "UTF-16")
        objVersions[A_Index] := objFileVer, objFileVer := ""
    }
    Return objVersions
}

/* EXAMPLE CODE:
objVerCalc := FileVerInfo("C:\Windows\System32\calc.exe")
Loop % objVerCalc.MaxIndex()
    MsgBox, % "Language: "           objVerCalc[A_Index].Language
            . "`nCodepage: "         objVerCalc[A_Index].Codepage
            . "`nComments: "         objVerCalc[A_Index].Comments
            . "`nCompanyName: "      objVerCalc[A_Index].CompanyName
            . "`nFileDescription: "  objVerCalc[A_Index].FileDescription
            . "`nFileVersion: "      objVerCalc[A_Index].FileVersion
            . "`nInternalName: "     objVerCalc[A_Index].InternalName
            . "`nLegalCopyright: "   objVerCalc[A_Index].LegalCopyright
            . "`nLegalTrademarks: "  objVerCalc[A_Index].LegalTrademarks
            . "`nOriginalFilename: " objVerCalc[A_Index].OriginalFilename
            . "`nProductName: "      objVerCalc[A_Index].ProductName
            . "`nProductVersion: "   objVerCalc[A_Index].ProductVersion
            . "`nPrivateBuild: "     objVerCalc[A_Index].PrivateBuild
            . "`nSpecialBuild: "     objVerCalc[A_Index].SpecialBuild
*/
