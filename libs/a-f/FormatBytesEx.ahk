FormatBytesEx( Bytes ) { ; By SKAN,    http://ahkscript.org/boards/viewtopic.php?p=18352#p18352
Static B1 := "KB", B2 := "MB", B3 := "GB", B4 := "TB", B5 := "PB", B6 := "EB"
  IfLess, Bytes, 1000, Return Bytes + 0 " bytes"
  AFF := A_FormatFloat
  SetFormat, FloatFast, 0.15

  While ( FL>3 or FL="" ) {
    FBytes := Bytes / ( 1024 ** ( IX := A_Index ) )
    StringSplit, F, FBytes, .
    FL := StrLen( F1 )
  }

  SetFormat, FloatFast, %AFF%
Return F1 ( FL<3 ? "." SubStr( F2, 1, 3-FL ) : "" ) " " B%IX%
}