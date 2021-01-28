; MsgBox, % Shuffle("abcdefghijklmnopqrstuvwxyz")
; return

; https://autohotkey.com/board/topic/91195-fisher-yates-shuffle-algorithm/
Shuffle(string) {
	length := StrLen(string)
	Loop, %length% {
		Random, position, 1, (length - A_Index + 1)
		out .= SubStr(string, position, 1)
		string := SubStr(string, 1, position - 1) . SubStr(string, position + 1)
	}
	return out
}