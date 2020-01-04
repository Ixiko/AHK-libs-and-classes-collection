pagerActionQuit() {
	if (A_IsPaused) {
		Ansi.write(Ansi.restoreCursorPosition() Ansi.reset()
				. Ansi.eraseLine())
		Ansi.flush()
		Ansi.flushInput()
	}
	exitapp
}

pagerActionNextPage() {
	Pause Off
	Ansi.write(Ansi.restoreCursorPosition() Ansi.reset()
			. Ansi.eraseLine())
	Ansi.flush()
	Console.refreshBufferInfo()
	Pager.scrollOneLine := false
	return
}

pagerActionContinue() {
	Pause off
	Ansi.write(Ansi.restoreCursorPosition() Ansi.reset()
			. Ansi.eraseLine())
	Ansi.flush()
	Pager.enablePager := false
	Console.refreshBufferInfo()
	return
}

pagerActionNextLine() {
	Pause off
	Ansi.write(Ansi.restoreCursorPosition() Ansi.reset()
			. Ansi.eraseLine())
	Ansi.flush()
	Pager.scrollOneLine := true
}
