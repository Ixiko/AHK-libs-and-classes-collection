;~  Huffman-0.5.x testSuite
SetBatchLines, -1
#include %A_ScriptDir%\..\huffmann.ahk
FileSelectFile,testFile
FileRead,test,%testFile%
FileGetSize,size,%testfile%

oCD := ""
SetTimer, ttInfo, 50
newsize := aHC_Compress(test,oCD,size)
SetTimer, ttInfo, OFF
MsgBox % "uncompressed: " size " bytes / compressed: " newsize " bytes`n"
 	   . "Compression Ratio: " (newsize/size*100) "% of original size`n`n"
	   
newData := ""
SetTimer, ttInfo, 50
newsize := aHC_Decompress(oCD,newData)
if (newsize<0) {
	MsgBox ERROR in Data
	ExitApp
}
SetTimer, ttInfo, OFF
ToolTip, % " Errorcheck in Progress " 
md5a := hash(test,size)
md5b := hash(newData,newsize)
tooltip
MsgBox % md5a " (origin md5)`n" md5b " (new decompressed md5)"
Return

ttInfo:
	ToolTip, % "[" aHC_Info "] Huffman " aHC_Current " in Progress "
return

HASH(ByRef sData, nLen, SID = 3) { 
	; Thx Laszlo: http://www.autohotkey.com/forum/viewtopic.php?p=113252#113252
   ; SID = 3: MD5, 4: SHA1
   DllCall("advapi32\CryptAcquireContextA", UIntP,hProv, UInt,0, UInt,0, UInt,1, UInt,0xF0000000)
   DllCall("advapi32\CryptCreateHash", UInt,hProv, UInt,0x8000|0|SID, UInt,0, UInt,0, UIntP, hHash)
   DllCall("advapi32\CryptHashData", UInt,hHash, UInt,&sData, UInt,nLen, UInt,0)
   DllCall("advapi32\CryptGetHashParam", UInt,hHash, UInt,2, UInt,0, UIntP,nSize, UInt,0)
   VarSetCapacity(HashVal, nSize, 0)
   DllCall("advapi32\CryptGetHashParam", UInt,hHash, UInt,2, UInt,&HashVal, UIntP,nSize, UInt,0)
   DllCall("advapi32\CryptDestroyHash", UInt,hHash)
   DllCall("advapi32\CryptReleaseContext", UInt,hProv, UInt,0)
   IFormat := A_FormatInteger
   SetFormat Integer, H
   Loop %nSize%
      sHash .= SubStr(*(&HashVal+A_Index-1)+0x100,-1)
   SetFormat Integer, %IFormat%
   Return sHash
}