; #Include RemoteBuf.ahk
; Example by majkinetor
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;get the handle of the Explorer window
   WinGet, hw, ID, ahk_class ExploreWClass

;open two buffers
   RemoteBuf_Open( hBuf1, hw, 128 )
   RemoteBuf_Open( hBuf2, hw, 16  )

;write something
   str := "1234"
   RemoteBuf_Write( hBuf1, str, strlen(str) )

   str := "_5678"
   RemoteBuf_Write( hBuf1, str, strlen(str), 4)

   str := "_testing"
   RemoteBuf_Write( hBuf2, str, strlen(str))


;read
   RemoteBuf_Read( hBuf1, str, 10 )
   out = %str%
   RemoteBuf_Read( hBuf2, str, 10 )
   out = %out%%str%

   MsgBox %out%

;close
   RemoteBuf_Close( hBuf1 )
   RemoteBuf_Close( hBuf2 )