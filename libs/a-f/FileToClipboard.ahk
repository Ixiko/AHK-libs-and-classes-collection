; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=38987
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

FileToClipboard(PathToCopy)
{
   MsgBox, % PathToCopy
   hPath := DllCall("GlobalAlloc","uint",0x42,"uint",StrLen(PathToCopy)+22)
   MsgBox, % hPath
   ; Lock the moveable memory, retrieving a pointer to it.
   pPath := DllCall("GlobalLock","uint",hPath)
    
   NumPut(20, pPath+0) ; DROPFILES.pFiles = offset of file list
    
   ; Copy the string into moveable memory.
   DllCall("lstrcpy","uint",pPath+20,"str",PathToCopy)
    
   ; Unlock the moveable memory.
   DllCall("GlobalUnlock","uint",hPath)
    
   DllCall("OpenClipboard","uint",0)
   ; Empty the clipboard, otherwise SetClipboardData may fail.
   DllCall("EmptyClipboard")
   ; Place the data on the clipboard. CF_HDROP=0xF
   DllCall("SetClipboardData","uint",0xF,"uint",hPath)
   DllCall("CloseClipboard")
}