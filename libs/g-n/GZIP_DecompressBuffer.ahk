GZIP_DecompressBuffer( ByRef var, nSz ) { ; 'Microsoft GZIP Compression DLL' SKAN 20-Sep-2010
; Decompress routine for 'no-name single file GZIP', available in process memory.
; Forum post :  www.autohotkey.com/forum/viewtopic.php?p=384875#384875
; Modified by Lexikos 25-Apr-2015 to accept the data size as a parameter.

; Modified version by tmplinshi
static hModule
static GZIP_InitDecompression, GZIP_CreateDecompression, GZIP_Decompress
     , GZIP_DestroyDecompression, GZIP_DeInitDecompression
If !hModule
{
	for i, dir in [".", A_LineFile "\..", A_AhkPath "\..\Lib"]
	{
		if FileExist(dllFile := dir "\gzip.dll")
		{
			hModule := DllCall("LoadLibrary", "Str", dllFile, "Ptr")
			Break
		}
	}
	if !dllFile {
		Gui, +OwnDialogs
		MsgBox, 48, 提示, 缺少文件 gzip.dll！程序将退出。
		ExitApp
	}

	For k, v in ["InitDecompression","CreateDecompression","Decompress","DestroyDecompression","DeInitDecompression"]
		GZIP_%v% := DllCall("GetProcAddress", Ptr, hModule, "AStr", v, "Ptr")

	if !GZIP_Decompress {
		Gui, +OwnDialogs
		MsgBox, 48, 错误, gzip.dll 版本不匹配。`n`n详细信息: 无法从 gzip.dll 找到 Decompress 函数。`n`n程序将退出。
		ExitApp
	}
}

 vSz :=  NumGet( var,nsz-4 ), VarSetCapacity( out,vsz,0 )
 DllCall( GZIP_InitDecompression )
 DllCall( GZIP_CreateDecompression, UIntP,CTX, UInt,1 )
 If ( DllCall( GZIP_Decompress, UInt,CTX, UInt,&var, UInt,nsz, UInt,&Out, UInt,vsz
    , UIntP,input_used, UIntP,output_used ) = 0 && ( Ok := ( output_used = vsz ) ) )
      VarSetCapacity( var,64 ), VarSetCapacity( var,0 ), VarSetCapacity( var,vsz,32 )
    , DllCall( "RtlMoveMemory", UInt,&var, UInt,&out, UInt,vsz )
 DllCall( GZIP_DestroyDecompression, UInt,CTX ),  DllCall( GZIP_DeInitDecompression )
Return Ok ? vsz : 0
}
