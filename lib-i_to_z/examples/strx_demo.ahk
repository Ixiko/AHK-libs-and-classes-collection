; #Include StrX.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

UrlDownloadToFile, http://www.autohotkey.com/forum/rss.php, ahkrss.xml   ; 01
FileRead, xml, ahkrss.xml                                                ; 02

While Item  := StrX( xml ,  "<item>" ,N,0,  "</item>" ,1,0,  N )         ; 03
      Title := StrX( Item,  "<title>",1,7,  "</title>",1,8     )         ; 04
    , Link  := StrX( Item,  "<link>" ,1,6,  "</link>" ,1,7     )         ; 05
    , List  .= "`n`n" A_Index ")`t" Title "`n`t" Link                    ; 06

MsgBox, 64, Latest Posts on AHK Forum, %List%                            ; 07