; ----------------------------------------------------------------------------------------------------------------------
; Name .........: URL & HTML collection
; Description ..: Various functions dealing with URLs and HTML code.
; AHK Version ..: AHK_L 1.1.13.01 x32/64 Ansi/Unicode
; Author .......: Cyruz (http://ciroprincipe.info)
; License ......: WTFPL - http://www.wtfpl.net/txt/copying/
; Changelog ....: Apr. 06, 2014 - v0.1 - First version.
; ----------------------------------------------------------------------------------------------------------------------

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: ColURL_OpenURL
; Description ..: Open an URL and return the server response.
; Parameters ...: sURL - String containing the URL to open.
; Return .......: Server response as a string.
; ----------------------------------------------------------------------------------------------------------------------
ColURL_OpenURL(sURL) {
    hMod  := DllCall( "Kernel32.dll\LoadLibrary",    Str,"Wininet.dll"                                           )
    hInet := DllCall( "Wininet.dll\InternetOpen",    Str,"AutoHotkey", UInt,0, Str,"", Str,"", UInt,0            )
    hURL  := DllCall( "Wininet.dll\InternetOpenUrl", Ptr,hInet, Str,sURL, Str,"", Int,0, UInt,0x80000000, UInt,0 )
    VarSetCapacity(cBuf, 1024, 0), VarSetCapacity(nRead, 4, 0)
    
    Loop
    {
        bFlag := DllCall( "Wininet.dll\InternetReadFile", Ptr,hURL, Ptr,&cBuf, UInt,1024, Ptr,&nRead )
        szBuf := NumGet(nRead)
        If ( (bFlag) && (!szBuf) )
            Break
        sRetStr := sRetStr . StrGet(&cBuf, szBuf, A_FileEncoding)
    }
    
    DllCall( "Wininet.dll\InternetCloseHandle", Ptr,hInet ) 
    DllCall( "Wininet.dll\InternetCloseHandle", Ptr,hURL  ) 
    DllCall( "Kernel32.dll\FreeLibrary",        Ptr,hMod  )
    Return sRetStr
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: ColURL_ComUrl2Mhtml
; Description ..: Creates a MHTML file from the given URL.
; Parameters ...: sURL      - Working URL.
; ..............: sDestPath - Destination file path.
; ..............: nFlags    - MHTML flags, it can be the OR of the followings:
; ..............:             CdoSuppressImages      := 1
; ..............:             CdoSuppressBGSounds    := 2
; ..............:             CdoSuppressFrames      := 4
; ..............:             CdoSuppressObjects     := 8
; ..............:             CdoSuppressStyleSheets := 16
; ..............:             CdoSuppressAll         := 31
; ..............:             (leave it empty to suppress nothing)
; ----------------------------------------------------------------------------------------------------------------------
ColURL_ComUrl2Mhtml(sURL, sDestPath="", nFlags=0) {
	objIMsg := ComObjCreate("{CD000001-8B95-11D1-82DB-00C04FB1625D}")                      ; IMessage Interface
	objIMsg.CreateMHTMLBody(sURL, nFlags)
	objIMsg.GetStream().SaveToFile((sDestPath) ? sDestPath : A_WorkingDir . "\url.mht", 2) ; adSaveCreateOverWrite = 2
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: ColURL_ComUnHtml
; Description ..: Strips the html tags from the given string.
; Parameters ...: sHtml - String containing the html code.
; Return .......: String without html tags.
; ----------------------------------------------------------------------------------------------------------------------
ColURL_ComUnHthml(sHtml) {
	objHtml := ComObjCreate("HtmlFile")
	objHtml.Write(sHtml)
	Return objHtml.documentElement.innerText
}
