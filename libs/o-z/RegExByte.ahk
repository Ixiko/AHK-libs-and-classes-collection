; Title:   	Convert unicode to RegEx escape string
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=86465&p=379876&hilit=Regex+Unicode#p379876
; Author:	iseahound
; Date:   	03.02.2021
; for:     	AHK_L

/*
; RegExByte() - Convert unicode string to regex byte escape sequences.
; Code: Select all - Toggle Line numbers
;
; Input: Hey Alexa, my name is "没有人😂".
; Output: \x48\x65\x79\x20\x41\x6c\x65\x78\x61\x2c\x20\x6d\x79\x20\x6e\x61\x6d\x65\x20\x69\x73\x20\x22\x{6ca1}\x{6709}\x{4eba}\x{1f602}\x22\x2e\x20
; RegExUnicode() - Convert unicode string to regex unicode escape sequences.
; Code: Select all - Toggle Line numbers
;
; Input: Hey Alexa, my name is "没有人😂".
; Output: \u0048\u0065\u0079\u0020\u0041\u006C\u0065\u0078\u0061\u002C\u0020\u006D\u0079\u0020\u006E\u0061\u006D\u0065\u0020\u0069\u0073\u0020\u0022\u6CA1\u6709\u4EBA\u{1F602}\u0022\u002E\u0020

; Highlight Text and press Win + u/ Win Shift + u:
#u:: Highlight.RegExByte()
#+u:: Highlight.RegExUnicode()

class Highlight extends Highlight.Delegate {
   class Delegate {
      __Call(function, args*) {
         IsObject(function)
            ? Paste(function.call("", Copy(), args*))
            : Paste(%function%(Copy(), args*))
      }
   }
}

Copy() {
   Clip0 := ClipboardAll
   Clipboard := ""               ; Must start off blank for detection to work
   Send ^c
   ClipWait 0.5
   if !ErrorLevel
      s := Clipboard
   Clipboard := Clip0
   VarSetCapacity(Clip0, 0)      ; Free memory
   return s                      ; Allows the empty string ("") for side-effects
}

Paste(s) {
   if (s == "")
      return
   Clip0 := ClipboardAll
   Clipboard := s
   Send ^v
   Sleep 50                      ; Don't change Clipboard while it is pasted! (Sleep > 0)
   Clipboard := Clip0            ; Restore original Clipboard
   VarSetCapacity(Clip0, 0)      ; Free memory
}

*/

RegExByte(s) {
   if (s == "")
      return
   head := Format("{:02x}", Ord(s))
   head := StrLen(head) > 2 ? "\x{" head "}" : "\x" head
   tail := SubStr(s, (Ord(s) > 65535)?3:2) ; Remove unicode surrogate values
   return head . RegExByte(tail)
}

RegExUnicode(s) {
   if (s == "")
      return
   head := Format("{:04X}", Ord(s))
   head := StrLen(head) > 4 ? "\u{" head "}" : "\u" head
   tail := SubStr(s, (Ord(s) > 65535)?3:2) ; Remove unicode surrogate values
   return head . RegExUnicode(tail)
}