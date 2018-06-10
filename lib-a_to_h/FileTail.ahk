; ======================================================================================================================
; Function:       Retrieves the last lines of a text file.
; Tested with:    AHK 1.1.15.00
; Tested on:      Win 8.1 x64
; Change histoty:
;     1.0.00.00/2014-06-25/just me     -  Initial release on ahkscript.org.
; Parameters:
;     FileName -  Name of the file, assumed to be in A_WorkingDir if an absolute path isn't specified.
;     Lines    -  Number of lines to read - default: 10   (like Unix).
;     NewLine  -  New line character(s)   - default: `r`n (Windows).
; Return values:
;     On success: Array containing the last requested lines, if present.
;     On failure: ""
; ======================================================================================================================
FileTail(FileName, Lines := 10, NewLine := "`r`n") {
   Static MaxLineLength := 256 ; seems to be a reasonable value to start with
   If !IsObject(File := FileOpen(FileName, "r"))
      Return ""
   Content := ""
   LinesLength := MaxLineLength * Lines * (InStr(File.Encoding, "UTF-16") ? 2 : 1)
   FileLength := File.Length
   BytesToRead := 0
   FoundLines := 0
   While (BytesToRead < FileLength) && !(FoundLines) {
      BytesToRead += LinesLength
      If (BytesToRead < FileLength)
         File.Pos := FileLength - BytesToRead
      Else
         File.Pos := 0
      Content := RTrim(File.Read(), NewLine)
      If (FoundLines := InStr(Content, NewLine, 0, 0, Lines))
         Content := SubStr(Content, FoundLines + StrLen(NewLine))
   }
   File.Close()
   Return (Content <> "" ? StrSplit(Content, NewLine) : Content)
}