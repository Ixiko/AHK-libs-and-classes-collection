#NoEnv
SetBatchLines, -1

t              	:= "`r`n"
M          	:= 0
FontSize	:= 10
numbers 	:= [6,12,73,105,1153,13678,300022,416738,2416738,612416738,3612416768,23003612416768]
fnumbers	:= numbers.Count()
Loop 28
	numbers.Push(2**A_Index)
maxLen		:= StrLen(Max(numbers*))

For index, number in numbers {
	L 	:= Format("{:" maxLen "}", number) . " : " . spokennumber(number)
	M	:= M < StrLen(L) ? StrLen(L) : M
	t 	.= l "`r`n"
	t 	.= (index = fnumbers) ? " ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ·· ··  `r`n" : ""
}

Gui, Font, % "s" FontSize, Consolas
Gui, Add, Edit, % "xm ym w" (M*(FontSize*0.75)) " r" (index+3) " Readonly hwndhEdit", % t
Controlsend,, {Down}{LControl Down}{End}{LControl Up}, % "ahk_id " hEdit
WinSet, Style 	, 0x50000004, % "ahk_id " hEdit
WinSet, ExStyle	, 0x00000000, % "ahk_id " hEdit
Gui, Show

return

GuiClose:
GuiEscape:
ExitApp

ExitApp

spokennumber(number, uppercase:=true, separator:=" ") { ;-- Darstellung ganzer Zahlen als Zahlwörter (deutsche Sprache)

  ; z.B. zur Verwendung in RegEx-Strings

  ; Zahlen werden in Gruppen zu je 3 Zahlen gesprochen (Tausendertrennung)
  ; 105                           	- Einhundertfünf
  ; 1.153                        	- Eintausend.einhundertdreiundfünfzig
  ; 13.678                      	- Dreizehntausend.sechshundertachtundsiebzig
  ; 416.738                    	- Vierhundertsechzehntausend.siebenhundertachtunddreißig
  ; 2.416.738                 	- Zweimillionen.vierhundertsechzehntausend.siebenhundertachtunddreißig
  ; 12.416.738               	- Zwölfmillionen.vierhundertsechzehntausend.siebenhundertachtunddreißig
  ; 612.416.738               	- Sechshundertzwölfmillionen.vierhundertsechzehntausend.siebenhundertachtunddreißig
  ; 3.612.416.768            	- Dreimilliarden.sechshundertzwölfmillionen.vierhundertsechzehntausend.siebenhundertachtundsechzig
  ; 23.003.612.416.768   	- Dreiundzwanzigbillionen.dreimilliarden.sechshundertzwölfmillionen.vierhundertsechzehntausend.siebenhundertachtundsechzig

  ; zu Fragen bzgl. der Rechtschreibung siehe z.B. hier:
  ; https://www.sekretaria.de/bueroorganisation/rechtschreibung/zahlwoerter/

	static numbers 	:= { twelves 	: ["ein", "zwei", "drei", "vier", "fünf", "sech", "sieb", "acht", "neun", "zehn", "elf", "zwölf"]
	    	        			, 	tens    	: ["zehn", "zwanzig", "dreißig", "vierzig", "fünfzig", "sechzig", "siebzig", "achtzig", "neunzig"]
		             			,	groups 	: ["tausend", "million", "milliarde", "billion", "billiarde", "trillion", "trilliarde", "quadrillion", "quadrilliarde"]}

  ; die Null
	If (number=0)
		return "Null"

  ; Vorarbeit - Tausendergruppen separieren
	GroupsOfThousands := Array()
	zerofillednumber      	:= Format("{:024}", number)
	zfnLen                    	:= StrLen(zerofillednumber)
	IgnoreZeros            	:= true
	Loop % (zfnLen/3) {
		ngroup := SubStr(zerofillednumber, (A_Index-1)*3+1, 3)
		If (IgnoreZeros && ngroup>0) || !IgnoreZeros {
			IgnoreZeros := false
			GroupsOfThousands.InsertAt(1, ngroup)
		}
	}

  ; gruppenweise in Zahlworte umwandeln
	For index, thousands in GroupsOfThousands {

		ngroup := SubStr("000" thousands, -2)
		d1 := SubStr(ngroup, -0)
		d2 := SubStr(ngroup, -1)
		d3 := SubStr(ngroup, 1, 1)

	  ; die Bezeichnung der Zahlengruppe
		spokennumber	:=	(index=1                         	?	""
								:   	 numbers.groups[index-1]
								.		(index>2 && ngroup>1	? (Mod(index, 2)=0 ? "n" : "en") : "")
								.    	((index=2 && ngroup>100) || index>2 ? separator : ""))
								.     	 spokennumber

	  ; Zahlen von 1 bis 99
		spokennumber 	:=	(d2=0                           	?	""
								:     	 d2=1                           	?	numbers.twelves[d2] (index=1 ? "s" : index>2 ? "e" : "")
								:     	 d2=2                           	?	numbers.twelves[d2]
								:     	 d2=6                           	?	numbers.twelves[d2] "s"
								:     	 d2=7                           	?	numbers.twelves[d2] "en"
								:     	 d2>=3  	&& d2<=9      	?	numbers.twelves[d2]
								:     	 d2>=10 && d2<=12 	?	numbers.twelves[d2]
								:    	 d2>=13 && d2<=19 	?	numbers.twelves[d1] numbers.tens[1]
								:    	 d1=0                          	?	numbers.tens[SubStr(d2, 1,1)]
								:     	 numbers.twelves[d1] . (d1=6 ? "s" : d1=7 ? "en" :"")
								.        "und" . numbers.tens[SubStr(d2, 1,1)])
								. 		 spokennumber

	  ; die Hunderterstelle
		spokennumber	:=  	(d3=0                             	?	""
								:     	 d3=6                             	?	numbers.twelves[d3] "s"
								:     	 d3=7                             	?	numbers.twelves[d3] "en"
								:    	 numbers.twelves[d3]) . (d3>0 ? "hundert" : "")
								. 		 spokennumber

	}

  ; erstes Zeichen in Großschreibung
	If uppercase
		spokennumber := Format("{:U}", SubStr(spokennumber, 1, 1)) . SubStr(spokennumber, -1*(StrLen(spokennumber)-2))

return spokennumber
}
