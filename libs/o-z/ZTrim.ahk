ZTrim( N := "" ) { ; SKAN /  CD:01-Jul-2017 | LM:03-Jul-2017 | Topic: goo.gl/TgWDb5
Local    V  := StrSplit( N, ".", A_Space ) 
Local    V0 := SubStr( V.1,1,1 ),   V1 := Abs( V.1 ),      V2 :=  RTrim( V.2, "0" )
Return ( V0 = "-" ? "-" : ""   )  ( V1 = "" ? 0 : V1 )   ( V2 <> "" ? "." V2 : "" )
}