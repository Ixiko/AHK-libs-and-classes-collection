/**
 * @file
 * @copyright Dedicated to Public Domain. See UNLICENSE.txt for details
 */
/**
 * Collects text input
 *
 * Collected text accessible through Text property of the class.
 *
 * @note All `[:cntrl:]` characters (except new line) are ignored
 *
 * @code{.ahk}
   #include <TextInputCollector> ; Assuming TextInputCollector.ahk is in your Lib folder

   ;Create new input collector and start it
   inputCollector := new TextInputCollector()
   inputCollector.start()

   ;Win+Shift+i - display collected text input
   #+i::MsgBox % inputCollector.Text
 * @endcode
*/
class TextInputCollector {
	__New() {
		;L0 - Disable hook's internal text buffer (we'll collect useful text in OnChar callback)
		;I - set MinSendLevel to 1, i.e. ignores artificial input produced by AutoHotkey (which defaults to 0 SendLevel)
		this.m_textInputHook := InputHook("L0 I")

		this.m_textInputHook.VisibleText := true ;Allow text characters to be propagated to consumers (do not block them)
		this.m_textInputHook.OnChar := ObjBindMethod(this.base, "OnCharacterTyped", &this)
	}

	Text[]
	{
		get {
			return this.m_textInputBuffer
		}
		set {
		}
	}

	start() {
		this.m_textInputHook.Start()
	}

	stop() {
		this.m_textInputHook.Stop()
	}

	__Delete() {
		this.stop()
	}

;private:
	OnCharacterTyped(instanceAddress, hook, char) {
		this := object(instanceAddress)
		; OutputDebug % "char typed: ``" char . "`` (code: " asc(char) ")"
		if (asc(char) = 10) { ; {Enter} key
			this.m_textInputBuffer .= "`r`n"
		} else if (char ~= "[^[:cntrl:]]") { ;All characters except control chars (see "POSIX character class" for more info)
			this.m_textInputBuffer .= char
		}
	}

	m_textInputHook := ""
	m_textInputBuffer := ""
}