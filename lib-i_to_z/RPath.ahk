; RelativePath & AbsolutePath by toralf and Titan
; http://www.autohotkey.com/forum/topic19489.html

; Original: RelativePath
RPath_Relative(MasterPath, SlavePath, s="\"){
    len := InStr(MasterPath, s, "", InStr(MasterPath, s . s) + 2) ;get server or drive string length
    If SubStr(MasterPath, 1, len ) <> SubStr(SlavePath, 1, len )  ;different server or drive
        Return SlavePath                                              ;return absolut path
    MasterPath := SubStr(MasterPath, len + 1 )                    ;remove server or drive from MasterPath
    SlavePath := SubStr(SlavePath, len + 1 )                      ;remove server or drive from SlavePath
    If InStr(MasterPath, s, "", 0) = StrLen(MasterPath)           ;remove last \ from MasterPath if any
        StringTrimRight, MasterPath, MasterPath, 1
    If InStr(SlavePath, s, "", 0) = StrLen(SlavePath)             ;remove last \ from SlavePath if any
        StringTrimRight, SlavePath, SlavePath, 1
    Loop{
        If !MasterPath                                            ;when there is nothing didentical
            Return s SlavePath                                         ;return SlavePath in root
        If InStr(SlavePath s, MasterPath s){                      ;when parts of paths match
            If !r                                                      ;no relative part yet
                r = .%s%                                                   ;SlavePath is in the MasterPath
            Return r . SubStr(SlavePath,StrLen(MasterPath) + 2)        ;return relative path
        }Else{                                                    ;otherwise
            r .= ".." s                                                ;add relative part
            MasterPath := SubStr(MasterPath, 1, InStr(MasterPath, s, "", 0) - 1)   ;remove one folder from MasterPath
          }
      }
  }

; Original: AbsolutePath
RPath_Absolute(AbsolutPath, RelativePath, s="\") {
    len := InStr(AbsolutPath, s, "", InStr(AbsolutPath, s . s) + 2) - 1   ;get server or drive string length
    pr := SubStr(AbsolutPath, 1, len)                                     ;get server or drive name
    AbsolutPath := SubStr(AbsolutPath, len + 1)                           ;remove server or drive from AbsolutPath
    If InStr(AbsolutPath, s, "", 0) = StrLen(AbsolutPath)                 ;remove last \ from AbsolutPath if any
        StringTrimRight, AbsolutPath, AbsolutPath, 1
    If InStr(RelativePath, s, "", 0) = StrLen(RelativePath)               ;remove last \ from RelativePath if any
        StringTrimRight, RelativePath, RelativePath, 1
    If InStr(RelativePath, s) = 1                                         ;when first char is \ go to AbsolutPath of server or drive
        AbsolutPath := "", RelativePath := SubStr(RelativePath, 2)            ;set AbsolutPath to nothing and remove one char from RelativePath
    Else If InStr(RelativePath,"." s) = 1                                 ;when first two chars are .\ add to current AbsolutPath directory
        RelativePath := SubStr(RelativePath, 3)                               ;remove two chars from RelativePath
    Else {                                                                ;otherwise
        StringReplace, RelativePath, RelativePath, ..%s%, , UseErrorLevel     ;remove all ..\ from RelativePath
        Loop, %ErrorLevel%                                                    ;for all ..\
            AbsolutPath := SubStr(AbsolutPath, 1, InStr(AbsolutPath, s, "", 0) - 1)  ;remove one folder from AbsolutPath
      }
    Return, pr . AbsolutPath . s . RelativePath                             ;concatenate server + AbsolutPath + separator + RelativePath
  }