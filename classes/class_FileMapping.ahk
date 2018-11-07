;https://autohotkey.com/board/topic/93305-filemapping-class/?p=588218

Class FileMappingClass {
	; http://msdn.microsoft.com/en-us/library/windows/desktop/aa366556(v=vs.85).aspx
	; http://www.autohotkey.com/board/topic/86771-i-want-to-share-var-between-2-processes-how-to-copy-memory-do-it/#entry552031
	static INVALID_HANDLE_VALUE := -1, PAGE_READWRITE := 0x4, FILE_MAP_ALL_ACCESS := 0xF001F, BUF_SIZE:=10000

	__New(szName="Global\MyFileMappingObject") {	; Opens existing or creates new file mapping object
		hMapFile := DllCall("OpenFileMapping", "Ptr", this.FILE_MAP_ALL_ACCESS, "Int", 0, "Str", szName)
		if ( hMapFile == 0 ) { ; OpenFileMapping Failed - file mapping object doesn't exist - that means we have to create it
			hMapFile := DllCall("CreateFileMapping", "Ptr", this.INVALID_HANDLE_VALUE, "Ptr", 0, "Int", this.PAGE_READWRITE, "Int", 0, "Int", this.BUF_SIZE, "Str", szName)
			if ( hMapFile == 0 ) ; CreateFileMapping Failed
				return
		}
		pBuf := DllCall("MapViewOfFile", "Ptr", hMapFile, "Int", this.FILE_MAP_ALL_ACCESS, "Int", 0, "Int", 0, "Ptr", this.BUF_SIZE)
		if ( pBuf == 0 )	; MapViewOfFile Failed
			return
		this.szName := szName, this.hMapFile := hMapFile, this.pBuf := pBuf
	}
	Write(szMsg) {
		if (this.pBuf != "") {
			StrPut(szMsg, this.pBuf, this.BUF_SIZE)
			/*
				szMsgLen := StrLen(szMsg) * ( A_Isunicode ? 2 : 1 )
				szBufLen := StrLen(StrGet(this.pBuf)) * ( A_Isunicode ? 2 : 1 )
				MsgLen := (szMsgLen > szBufLen) ? szMsgLen : szBufLen
				if (MsgLen <= this.BUF_SIZE)
					DllCall("RtlMoveMemory", "Ptr", this.pBuf, "Ptr", &szMsg, "Ptr", MsgLen)
			*/
		}
	}
	Read() {
		return StrGet(this.pBuf)
	}
	Close() {
		DllCall("UnmapViewOfFile", "Ptr", this.pBuf), DllCall("CloseHandle", "Ptr", this.hMapFile)
		this.szName := "", this.BUF_SIZE := "", this.hMapFile := "", this.pBuf := ""
	}
	__Delete() {
		this.Close()
	}
}