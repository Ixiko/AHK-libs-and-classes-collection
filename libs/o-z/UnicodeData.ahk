; Title:
; Link:
; Author:
; Date:
; for:     	AHK_L

/*

!q:: Highlight.UnicodeData()
;#/:: Highlight.UnicodeData("folder\path_to_unicodedata.txt")

*/


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
   MsgBox, Und nun?
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

UnicodeData(s, unicodedata := "UnicodeData.txt") {
   if (s == "")
      return
   if !(database := FileOpen(unicodedata, "r`n", "UTF-8")) {
      ; Backup website          http://www.unicode.org/Public/UNIDATA/UnicodeData.txt
      UrlDownloadToFile https://www.unicode.org/Public/UCD/latest/ucd/UnicodeData.txt, % unicodedata
      if !(database := FileOpen(unicodedata, "r`n", "UTF-8"))
         throw Exception("UnicodeData.txt cannot be downloaded.")
   }

   ; Binary Search.
   i := 0               ; min bound
   k := database.length ; max bound
   Loop {
      n := Floor((i + k) / 2)                               ; Value to test.
      database.Seek(n)                                      ; Move file pointer to middle of file.
      (database.Pos != 0) ? database.ReadLine() : ""        ; Advance file pointer to the end of line.
      save := database.ReadLine()                           ; Read a full line of text.
      codepoint := RegExReplace(save, "^(.*?);.*$", "0x$1") ; Extract and convert the unicode hex to decimal.
      (Ord(s) < codepoint) ? (k := n) : (i := n)            ; Advance min or max bound per binary search.
   } until (Ord(s) = codepoint)                             ; Exit when the test value is the search value.
   database.Close()
   r := StrSplit(save, ";")                                 ; Split row into an array.
   q := (r[2] = "<control>") ? r[11] : r[2]                 ; Retrieve alternate description if control character.
   MsgBox,, % A_Space Chr(Ord(s)), % " <U+" Format("{:X}", Ord(s)) "> " q
   return
}