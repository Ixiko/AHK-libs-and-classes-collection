#Include <struct>
#Include <modules\struct\CONSOLE_SCREEN_BUFFER_INFO>

#Include %A_LineFile%\..\modules\pager\
#Include actions.ahk

class Pager {

	requires() {
		return []
	}

	static TEST_CONSOLE_HEIGHT := 24
	static TEST_CONSOLE_WIDTH := 80

	static handleOfCurrentConsoleWindow := WinExist("A")
	static lineCounter := 0
	static enablePager := true
	static scrollOneLine := false
	static runInTestMode := false
	static breakMessage := "<Press space to continue or q to quit>"

	writeHardWrapped(text) {
		wrappedText := Ansi.wrap(text, Pager.getConsoleWidth())
		Pager.lineCounter := Pager.writeText(wrappedText
				, Pager.lineCounter)
		return Pager.lineCounter
	}

	writeWordWrapped(text) {
		wordWrappedText := Ansi.wordWrap(text, Pager.getConsoleWidth())
		Pager.lineCounter := Pager.writeText(wordWrappedText
				, Pager.lineCounter)
		return Pager.lineCounter
	}

	writeText(wrappedText, lineCounter) {
		listOfLines := StrSplit(wrappedText, Ansi.NEWLINE)
		loop % listOfLines.maxIndex() {
			lineCounter := Pager.printLineAndBreak(listOfLines[A_Index]
					, lineCounter)
		}
		return lineCounter
	}

	printLineAndBreak(textToPrint, lineCounter) {
		lineCounter++
		if (Pager.enablePager && (Pager.scrollOneLine
				|| lineCounter = Pager.getConsoleHeight())) {
			Pager.break(Pager.breakMessage)
			lineCounter := 1
		}
		if (Pager.getMaxConsoleWidth()
				&& ((A_IsCompiled
				&& Ansi.plainStrLen(textToPrint) >= Pager.getMaxConsoleWidth())
				|| (Ansi.plainStrLen(textToPrint)
				> Pager.getMaxConsoleWidth()))) {
			Ansi.write(textToPrint)
		} else {
			Ansi.writeLine(textToPrint)
		}
		return lineCounter
	}

	break(breakMessage, resetLineCounter=false) {
		if (resetLineCounter) {
			Pager.lineCounter := 0
		}
		if (Pager.runInTestMode) {
			Ansi.write(Pager.breakMessage)
			Ansi.flush()
			return
		}
		Ansi.write(Ansi.saveCursorPosition() Ansi.cursorHorizontalAbs(1)
				. Ansi.reset() Ansi.eraseLine()
				. Ansi.setGraphic(Ansi.ATTR_REVERSE) breakMessage Ansi.reset()
				. Ansi.eraseLine())
		_handleOfCurrentConsoleWindow := Pager.handleOfCurrentConsoleWindow
		HotKey, IfWinActive, ahk_id %_handleOfCurrentConsoleWindow%
		HotKey, q, pagerActionQuit
		HotKey, c, pagerActionContinue
		HotKey, Space, pagerActionNextPage
		HotKey, Enter, pagerActionNextLine
		Ansi.flush()
		Pause On
	}

	getConsoleHeight() {
		if (Pager.runInTestMode) {
			return Pager.TEST_CONSOLE_HEIGHT
		}
		conHeight := 1 + Console.bufferInfo.srWindow.bottom
				- Console.bufferInfo.srWindow.top
		return conHeight
	}

	getConsoleWidth() {
		if (Pager.runInTestMode) {
			return Pager.TEST_CONSOLE_WIDTH
		}
		conWidth := 1 + Console.bufferInfo.srWindow.right
				- Console.bufferInfo.srWindow.left
		return conWidth
	}

	getMaxConsoleWidth() {
		if (Pager.runInTestMode) {
			return Pager.TEST_CONSOLE_WIDTH
		}
		return Console.bufferInfo.dwMaximumWindowSize.X
	}
}
