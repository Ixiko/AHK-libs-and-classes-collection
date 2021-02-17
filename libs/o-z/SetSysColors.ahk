; Title:   	
; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

SetSysColors()
{
Local s, s1, s2, c
colors=
(
ButtonText=18
ButtonFace=15
ButtonAlternateFace=25
ButtonLight=22
ButtonHilight=20
ButtonShadow=16
ButtonDkShadow=21
ActiveBorder=10
ActiveTitle=2
GradientActiveTitle=27
TitleText=9
Background=1
GrayText=17
Hilight=13
HilightText=14
HotTrackingColor=26
InactiveBorder=11
InactiveTitle=3
GradientInactiveTitle=28
InactiveTitleText=19
InfoWindow=24
InfoText=23
Menu=4
MenuHilight=29
MenuBar=30
MenuText=7
Scrollbar=0
AppWorkSpace=12
Window=5
WindowFrame=6
WindowText=8
)
Loop, Parse, colors, `n
{
	RegExMatch( A_LoopField, "([0-9a-zA-Z]+)=([0-9]+)", s )
	c := s1
	s1 := "Color" . s1
	s1 := %s1%
	if StrLen(s1) {
		DllCall("SetSysColors", "Int", 1, "Int*", s2, "UInt*", s1)
		s := s1 & 0xFF
		s1 := s1 >> 8
		s2 := s1 & 0xFF
		s1 := s1 >> 8
		if ColorRegUpdate
			RegWrite, REG_SZ, HKEY_CURRENT_USER, Control Panel\Colors, %c%, %s% %s2% %s1%
	}
}
colors := 0

}

ReadIni( filename = 0 )
; Read a whole .ini file and creates variables like this:
; %Section%%Key% = %value%
{

Local s, sep, key, line, val, val1, val2


if not filename
   filename := SubStr( A_ScriptName, 1, -3 ) . "ini"

   FileRead, s, %filename%
   sep := chr(129)
   s := RegExReplace( s, "m)^\[([a-zA-Z0-9_]+\])\s*$", sep . "$1" ) . "`n"

   Loop, Parse, s, %sep%
   {
      RegExMatch( A_LoopField, "^([a-zA-Z0-9_]+)", key )
      line :=( RegExReplace( A_LoopField, key . "\]\s*", "" ) )
         Loop, Parse, line, `n
         {
            RegExMatch( A_LoopField, "^\s*([a-zA-Z0-9_]+)\s*=(.+)\s$", val )
            If val1
               %key%%val1% :=val2
         }

   }

}