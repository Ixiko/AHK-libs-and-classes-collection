; Title:
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=86465
; Author:
; Date:
; for:     	AHK_L

/* RegExByte() - Convert unicode string to regex byte escape sequences.


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