#Include <struct>

#Include <modules\struct\CONSOLE_SCREEN_BUFFER_INFO>

class Console {

	static STD_INPUT_HANDLE  = -10
	static STD_OUTPUT_HANDLE = -11
	static STD_ERROR_HANDLE  = -12

	static ANSI_SEQ_REGEX := "\x1b\[([0-9a-fA-FxX;]+)*([HfABCDEFGsuJKmn])"

	static hStdOut := Console.__initHandle(Console.STD_OUTPUT_HANDLE)
	static hStdErr := Console.__initHandle(Console.STD_ERROR_HANDLE)
	static hStdIn  := Console.__initHandle(Console.STD_INPUT_HANDLE)

	static BufferInfo := Console.__initBufferInfo()

	static SavedPos := [0, 0]

	static Encoding := "cp850"

	class Color {
		wAttributes := 0
		strText := ""

		static COLOR_REVERSE 	:= 0x10000
		static COLOR_BOLD 		:= 0x20000
		static COLOR_HIGHLIGHT	:= 0x40000
		static COLOR_NORMAL 	:= 0x80000

		class Foreground {
			static BLACK := 0
			static BLUE := CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_BLUE
			static GREEN := CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_GREEN
			static TURQUOISE := CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_GREEN
					| CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_BLUE
			static RED := CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_RED
			static PURPLE := CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_RED
					| CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_BLUE
			static OCHER := CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_RED
					| CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_GREEN
			static LIGHTGREY := CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_RED
					| CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_GREEN
					| CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_BLUE
			static DARKGREY := CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_INTENSITY
			static LIGHTBLUE := CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_INTENSITY
					| CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_BLUE
			static LIME := CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_INTENSITY
					| CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_GREEN
			static AUQA := CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_INTENSITY
					| CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_GREEN
					| CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_BLUE
			static LIGHTRED := CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_INTENSITY
					| CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_RED
			static MAGENTA := CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_INTENSITY
					| CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_RED
					| CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_BLUE
			static YELLOW := CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_INTENSITY
					| CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_RED
					| CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_GREEN
			static WHITE := CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_INTENSITY
					| CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_RED
					| CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_GREEN
					| CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_BLUE
		}

		class Background {
			static BLACK := 0
			static BLUE := CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_BLUE
			static GREEN := CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_GREEN
			static TURQUOISE := CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_GREEN
					| CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_BLUE
			static RED := CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_RED
			static PURPLE := CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_RED
					| CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_BLUE
			static OCHER := CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_RED
					| CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_GREEN
			static LIGHTGREY := CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_RED
					| CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_GREEN
					| CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_BLUE
			static DARKGREY := CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_INTENSITY
			static LIGHTBLUE := CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_INTENSITY
					| CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_BLUE
			static LIME := CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_INTENSITY
					| CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_GREEN
			static AUQA := CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_INTENSITY
					| CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_GREEN
					| CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_BLUE
			static LIGHTRED := CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_INTENSITY
					| CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_RED
			static MAGENTA := CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_INTENSITY
					| CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_RED
					| CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_BLUE
			static YELLOW := CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_INTENSITY
					| CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_RED
					| CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_GREEN
			static WHITE := CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_INTENSITY
					| CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_RED
					| CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_GREEN
					| CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_BLUE
		}

		__new(pwAttributes, pstrText="") {
			this.wAttributes := pwAttributes
			this.strText := pstrText
			return this
		}

		reverse(pwAttributes="") {
			if (pwAttributes = "") {
				pwAttributes := Console.getBufferInfo().wAttributes
			}
			return ((pwAttributes & 0x0f)<<4) | ((pwAttributes & 0xf0)>>4)
		}

		bold(pwAttributes="") {
			if (pwAttributes = "") {
				pwAttributes := Console.getBufferInfo().wAttributes
			}
			return pwAttributes & 0x0f
					| CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_INTENSITY
		}

		highlight() {
			bi := Console.getBufferInfo()
			return bi.wAttributes
					| CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_INTENSITY
		}

		normal() {
			bi := Console.getBufferInfo()
			return (bi.foregroundColor()
					& ~CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_INTENSITY)
					| (bi.backgroundColor()
					& ~CONSOLE_SCREEN_BUFFER_INFO.BACKGROUND_INTENSITY)
		}
	}

	__initHandle(piHandle) {
		return DllCall("GetStdHandle", "UInt", piHandle, "Ptr")
	}

	__initBufferInfo() {
		VarSetCapacity(_csbi, sizeof(CONSOLE_SCREEN_BUFFER_INFO), 0)
		_ret := DllCall("GetConsoleScreenBufferInfo", "Ptr", Console.hStdOut
				, "Ptr", &_csbi)
		if (_ret != 0) {
			return new CONSOLE_SCREEN_BUFFER_INFO(_csbi)
		}
		return ""
	}

	__new() {
		throw Exception("Instantiation of class '" this.__Class
				. "' ist not allowed", -1)
	}

	write(pBuffer*) {
		n := 0
		for i, _item in pBuffer {
			if (_item.maxIndex() != "") {
				return n += Console.writeList(_item)
			}
			if (_item.__Class = "Console.Color") {
				if (_item.strText != "") {
					_currentAttributes := Console.bufferInfo.wAttributes
					Console.setTextAttribute(_item.wAttributes)
					if (Console.bufferInfo) {
						FileAppend % _item.strText, CONOUT$, % Console.encoding
					} else {
						FileAppend % _item.strText, *
					}
					Console.setTextAttribute(_currentAttributes)
				} else {
					Console.setTextAttribute(_item.wAttributes)
					if (Console.bufferInfo) {
						FileAppend % _item.strText, CONOUT$, % Console.encoding
					} else {
						FileAppend % _item.strText, *
					}
				}
				n += StrLen(_item.strText)
			} else {
				if (Console.bufferInfo) {
					FileAppend %_item%, CONOUT$, % Console.encoding
				} else {
					FileAppend %_item%, *
				}
				n += StrLen(_item)
			}
		}
		return n
	}

	writeAndTranslateAnsiSequences(string) {
		p := 1
		while (RegExMatch(string, "(.*?)" Console.ANSI_SEQ_REGEX, $, p)) {
			p += StrLen($)
			OutputDebug ::: %A_ThisFunc% ::: p=%p% -- $=%$% / $1=%$1% / $2=%$2% / $3=%$3% ; ahklint-ignore: W002
			n += Console.write($1)
			if ($3 == "H" || $3 == "f" ) {
				values := StrSplit($2, ";")
				if (values.maxIndex() > 2) {
					continue
				}
				Console.setCursorPos(values[2] = "" || values[2] = 0
						? 0 : values[2] - 1
						, values[1] = "" || values[1] = 0
						? 0 : values[1] - 1)
			} else if ($3 == "A") {
				Console.setCursorPos(0, $2 = "" ? -1 : $2 = 0 ? 0 : $2*(-1)
						, true)
			} else if ($3 == "B") {
				Console.setCursorPos(0, $2 = "" ? 1 : $2 = 0 ? 0 : $2
						, true)
			} else if ($3 == "C") {
				Console.setCursorPos($2 = "" ? 1 : $2 = 0 ? 0 : $2, 0
						, true)
			} else if ($3 == "D") {
				Console.setCursorPos($2 = "" ? -1 : $2 = 0 ? 0 : $2*(-1), 0
						, true)
			} else if ($3 == "E") {
				Console.setCursorPos("", $2 = "" ? 1 : $2 = 0 ? 0 : $2
						, true)
				Console.setCursorPos(0)
			} else if ($3 == "F") {
				Console.setCursorPos("", $2 = "" ? -1 : $2 = 0 ? 0 : $2*(-1)
						, true)
				Console.setCursorPos(0)
			} else if ($3 == "G") {
				Console.setCursorPos($2 - 1)
			} else if ($3 == "s") {
				Console.savePosition()
			} else if ($3 == "u") {
				Console.restorePosition()
			} else if ($3 == "J") {
				Console.clearSCR()
			} else if ($3 == "K") {
				Console.clearEOL()
			} else if ($3 = "m") {
				values := StrSplit($2, ";")
				consoleColor
						:= new Console.Color(Console.bufferInfo.wAttributes)
				loop % values.maxIndex() {
					value := values[A_Index]
					OutputDebug ::: value=%value%
					if (value = 0) {
						consoleColor.wAttributes
								:= Console.bufferInfo.wAttributes
					} else if (value = 1) {
						consoleColor.wAttributes := consoleColor.wAttributes
								| CONSOLE_SCREEN_BUFFER_INFO.FOREGROUND_INTENSITY ; ahklint-ignore: W002
					} else if (value = 7) {
						hb := consoleColor.wAttributes & 0xf0
						lb := consoleColor.wAttributes & 0xf
						consoleColor.wAttributes := lb<<4 | hb>>4
					} else if (value >= 30 && value <= 37) {
						consoleColor.wAttributes
								:= consoleColor.wAttributes & 0xf8
								| Ansi.mapColor(value)
					} else if (value >= 40 && value <= 47) {
						consoleColor.wAttributes
								:= consoleColor.wAttributes & 0xf
								| Ansi.mapColor(value)
					}
				}
				OutputDebug ::: consoleColor=%consoleColor%
				Console.write(consoleColor, "")
			} else if ($3 = "n" && $2 = "6") {
				bi := Console.getBufferInfo()
				SendRaw % "^[[" bi.dwCursorPosition.Y+1
						. ";" bi.dwCursorPosition.X+1 "R"
			}
		}
		return n + Console.write(SubStr(string, p))
	}

	writeList(pList) {
		n := 0
		for i, _item in pList {
			n += Console.write(_item)
		}
		return n
	}

	resetColor() {
		return Console.setTextAttribute(Console.bufferInfo.wAttributes)
	}


	setTextAttribute(psAttributes=0, phHandle="") {
		if (phHandle = "") {
			phHandle := Console.hStdOut
		}

		_rbhn := psAttributes & 0xf0000 ; Reverse, Bold, Highlight, Normal
		if (_rbhn) {
			psAttributes := psAttributes & ~_rbhn
			if (_rbhn & Console.Color.COLOR_BOLD) {
				psAttributes := Console.Color.Bold(psAttributes)
			}
			if (_rbhn & Console.Color.COLOR_HIGHLIGHT) {
				psAttributes := Console.Color.Highlight(psAttributes)
			}
			if (_rbhn & Console.Color.COLOR_REVERSE) {
				psAttributes := Console.Color.Reverse(psAttributes)
			}
			if (_rbhn & Console.Color.COLOR_NORMAL) {
				psAttributes := Console.Color.Normal(psAttributes)
			}
		}
		if (phHandle) {
			return DllCall("SetConsoleTextAttribute", "Ptr", phHandle
					, "UShort", psAttributes, "Int")
		}
	}

	read(ByRef pBuffer, pNumberOfCharsToRead=1, pInputControlObject="") {
		if (!Console.hStdIn) {
			return throw Exception("No Standard Input availalbe", 1)
		}

		if (IsObject(pInputControlObject)) {
			pInputControlObject.get(pInputControl)
		}

		VarSetCapacity(pBuffer, pNumberOfCharsToRead * (A_IsUnicode ? 2 : 1), 0)
		VarSetCapacity(lpNumberOfCharsRead, 4, 0)
		DllCall("FlushConsoleInputBuffer", "Ptr", Console.hStdIn, "Int")
		DllCall("ReadConsole" (A_IsUnicode ? "W" : "A"), "Ptr", Console.hStdIn
				, "Ptr", &pBuffer
				, "UInt", pNumberOfCharsToRead
				, "UInt", &lpNumberOfCharsRead
				, "UInt", &pInputControl
				, "Int")
		return NumGet(lpNumberOfCharsRead, 0, "UInt")
	}

	;{{{ ReadInput
	/*
	BOOL WINAPI ReadConsoleInput(
	  _In_   HANDLE hConsoleInput,
	  _Out_  PINPUT_RECORD lpBuffer,
	  _In_   DWORD nLength,
	  _Out_  LPDWORD lpNumberOfEventsRead
	);
	*/
	readInput(ByRef pBuffer, pnLength=1) {
		if (!Console.hStdIn) {
			return throw Exception("No Standard Input availalbe", 1)
		}

		VarSetCapacity(pBuffer, 2 * pnLength, 0)
		VarSetCapacity(_noer, 4, 0)
		DllCall("ReadConsoleInput" (A_IsUnicode ? "W" : "A")
				, "Ptr", Console.hStdIn
				, "Ptr", &pBuffer
				, "UInt", pnLength
				, "Ptr", &_noer
				, "Int")

		return NumGet(_noer, 0, "UInt")
	}

	setCursorPos(piX="", piY="", pbRelative=false) {
		bi := Console.getBufferInfo()
		if (pbRelative) {
			piX := piX != "" ? bi.dwCursorPosition.X + piX : ""
			piY := piY != "" ? bi.dwCursorPosition.Y + piY : ""
		}
		piX := piX = "" ? bi.dwCursorPosition.X : piX
		piY := piY = "" ? bi.dwCursorPosition.Y : piY

		VarSetCapacity(_cp, 4, 0)
		NumPut(piX, _cp, 0, "UShort")
		NumPut(piY, _cp, 2, "UShort")
		return DllCall("SetConsoleCursorPosition", "Ptr", Console.hStdOut
				, "UInt", NumGet(_cp, 0, "UInt"), "Int")
	}

	savePosition() {
		bi := Console.getBufferInfo()
		Console.savedPos := [bi.dwCursorPosition.X, bi.dwCursorPosition.Y]
	}

	restorePosition() {
		Console.setCursorPos(Console.savedPos[1], Console.savedPos[2])
	}

	clearEOL() {
		bi := Console.getBufferInfo()
		Console.fillWithCharacter(" ", bi.dwSize.X - bi.dwCursorPosition.X
				, bi.dwCursorPosition.X, bi.dwCursorPosition.Y)
		Console.fillWithAttribute(bi.wAttributes
				, bi.dwSize.X - bi.dwCursorPosition.X, bi.dwCursorPosition.X
				, bi.dwCursorPosition.Y)
		Console.setCursorPos(0, bi.dwCursorPosition.Y)
	}

	clearSCR() {
		bi := Console.getBufferInfo()
		Console.fillWithCharacter(" ", bi.dwSize.X * bi.dwSize.Y, 0, 0)
		Console.fillWithAttribute(bi.wAttributes, bi.dwSize.X * bi.dwSize.Y
				, 0, 0)
		Console.setCursorPos(0, 0)
	}

	getBufferInfo() {
		VarSetCapacity(_csbi, sizeof(CONSOLE_SCREEN_BUFFER_INFO), 0)
		DllCall("GetConsoleScreenBufferInfo", "Ptr", Console.hStdOut
				, "Ptr", &_csbi, "Int")
		return new CONSOLE_SCREEN_BUFFER_INFO(_csbi)
	}

	fillWithCharacter(pcChar=" ", pnLength=1, piX=0, piY=0) {
		VarSetCapacity(dwWriteCoord, 4, 0)
		NumPut(piX, dwWriteCoord, 0, "UShort")
		NumPut(piY, dwWriteCoord, 2, "UShort")
		_dwWriteCoord := NumGet(dwWriteCoord, 0, "UInt")
		VarSetCapacity(_nocw, 4, 0)
		if (A_IsUnicode) {
			VarSetCapacity(_c, 2, 0), NumPut(Chr(SubStr(pcChar, 1, 1))
					, _c, 0, "Short")
		} else {
			VarSetCapacity(_c, 1, 0), NumPut(Chr(SubStr(pcChar, 1, 1))
					, _c, 0, "Char")
		}
		DllCall("FillConsoleOutputCharacter" (A_IsUnicode ? "W" : "A")
				, "Ptr", Console.hStdOut
				, (A_IsUnicode ? "Short" : "Char")
				, NumGet(pcChar, 0, (A_IsUnicode ? "Short" : "Char"))
				, "UInt", pnLength
				, "UInt", _dwWriteCoord
				, "UInt", &_nocw
				, "Int")
		return NumGet(_nocw, 0, "UInt")
	}

	fillWithAttribute(pwAttributes=7, pnLength=1, piX=0, piY=0) {
		VarSetCapacity(dwWriteCoord, 4, 0)
		NumPut(piX, dwWriteCoord, 0, "UShort")
		NumPut(piY, dwWriteCoord, 2, "UShort")
		_dwWriteCoord := NumGet(dwWriteCoord, 0, "UInt")
		VarSetCapacity(_noaw, 4, 0)

		DllCall("FillConsoleOutputAttribute", "Ptr", Console.hStdOut
				, "UShort", pwAttributes
				, "UInt", pnLength
				, "UInt", _dwWriteCoord
				, "UInt", &_noaw
				, "Int")

		return NumGet(_noaw, 0, "UInt")
	}

	refreshBufferInfo() {
		Console.bufferInfo := Console.__InitBufferInfo()
	}
}
