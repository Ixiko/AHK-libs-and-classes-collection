
/* Example
str =
(
example

example text more example text example text more example text example text more example text example text more example text
example text more example text example text more example text example text and more example text example text more example text
example text more example text example text more example text example text more example text example text more example text
example text more example text example text more example text example text more example text example and text more example text
example text more example text example text more example text example text and even more example text example text more example
text.

text example text more example text example text more example text example text more example text example text more example text
example text more example text example text more example text example text more example text example text and even more example
text example text more example text example text more example text example text more example text example text more example text
and even more text.
)

MsgBox, 64, Result, % WrapWords(str, 112)
*/


WrapWords(text, wrapCol) {


   For lIndex, line in StrSplit(text, "`n", "´r")
      For each, word in StrSplit(line := Trim(RegExReplace(line, "\h+", " ")), " ")
         (StrLen(newLine) + StrLen(word) < wrapCol) ? (newLine .= (newLine > "" ? " " : "") word)
         : (out .= (out > "" ? "`n" : "") newLine, newLine := word)
         (!line) && (out .= (out > "" ? "`n" : "") newLine "`n", newLine := "")

return  out (out > "" ? "`n" : "") newLine
}
