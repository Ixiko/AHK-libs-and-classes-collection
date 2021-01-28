; Link:   	https://autohotkey.com/board/topic/23627-machine-code-binary-buffer-searching-regardless-of-null/
; Author:
; Date:
; for:     	AHK_L

/*


*/

InFile( fileName, needleAddr, needleLen, StartOffset=0 ){

	lRet=-1
	IfEqual,needleLen,0, return lRet
	IfEqual,needleAddr,0, return lRet
	hFile:=DllCall("CreateFile", "str", fileName,"uint",0x80000000 ;GENERIC_READ
				,"uint", 1 ;FILE_SHARE_READ
				,"uint", 0, "uint",3 ;OPEN_EXISTING
				,"uint",0x2000000 ;FILE_FLAG_BACKUP_SEMANTICS
				,"uint", 0)
	ifEqual,hFile,-1, return lRet

	VarSetCapacity( lBufLen, 8, 0 )
	NumPut( DllCall("GetFileSize","uint",hFile,"uint",&lBufLen+4), lBufLen )
	DllCall( "RtlMoveMemory", "int64 *",lBufLen64, "uint",&lBufLen, "uint",8 )
	lBufLen64 -= StartOffset
	If( lBufLen64>=0 )
	{	hMap:=DllCall("CreateFileMapping", "uint",hFile, "uint",0, "uint",2 ;PAGE_READONLY
					,"uint",0,"uint",0,"uint",0)
		if( hMap )
		{	lMax32b=0xFFFFFFFF
			lMaxView=0x40000000 ;1GB
			VarSetCapacity( SI, 36, 0 )
			DllCall("GetSystemInfo","uint",&SI)
			memAllocGranularity:=NumGet( SI, 28 )
			loop
			{	FileOffs:=(StartOffset//memAllocGranularity)*memAllocGranularity
				delta:=StartOffset-FileOffs
				lBufLenLo:=(lBufLen64+delta > lMaxView) ? lMaxView : lBufLen64+delta
				hView:=DllCall("MapViewOfFile", "uint",hMap, "uint", 4 ;FILE_MAP_READ
							,"uint",FileOffs>>32,"uint",FileOffs & lMax32b,"uint",lBufLenLo)
				ifEqual,hView,0, break
				lRet:=InBuf( hView, needleAddr, lBufLenLo, needleLen, delta )
				DllCall("UnmapViewOfFile","uint",hView)
				if( lRet!=-1 )
				{	lRet += FileOffs
					break
				}
				StartOffset += lBufLenLo-needleLen
				lBufLen64 -= lBufLenLo-needleLen
				IfLessOrEqual,lBufLen64,0, break
			}
			DllCall("CloseHandle","uint",hMap)
		}
	}
	DllCall("CloseHandle","uint",hFile)
	return lRet
}