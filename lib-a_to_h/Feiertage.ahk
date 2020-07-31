; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;Als test alle Feiertage in Deutschland mit Benennung
msgbox, % feiertage("2019","dl","longdate")

;Immer-Sonntage sind nicht dabei
msgbox, % feiertage("2019","ni","yyyyMMdd")

return


feiertage(jahr,land,timestrg){
;https://autohotkey.com/board/topic/97400-feiertage-berechnen-osterformel-nach-heiner-lichtenberg/
;https://www.excel-coach.com/excel-und-die-feiertage/
;https://www.dagmar-mueller.de/wdz/html/feiertagsberechnung.html
;https://www.ferienwiki.de/feiertage/2019/de
; ==============    
;timestrg:="yyyyMMdd"
;timestrg:="longdate"

; Ostersonntag
ttos:="`nOstersonntag:                 "
    X := jahr                                              ; Jahreszahl, für die Ostern berechnet werden soll
    K  := Floor(X/100)                                      ; Säkularzahl
    M  := 15+Floor((3*K+3)/4)-Floor((8*K+13)/25)            ; säkulare Mondschaltung
    S  := 2-Floor((3*K+3)/4)                                ; säkulare Sonnenschaltung
    A  := Mod(X,19)                                         ; Mondparameter
    D  := Mod(19*A+M,30)                                    ; Keim für den ersten Vollmond im Frühling
    R  := Floor(D/29)+(Floor(D/28)-Floor(D/29))*Floor(A/11) ; kalendarische Korrekturgröße (beseitigt die Gaußschen Ausnahmeregeln)
    OG := 21+D-R                                            ; Ostergrenze (Märzdatum des Ostervollmonds)
    SZ := 7-Mod(X+Floor(X/4)+S,7)                           ; Erster Sonntag im März
    OE := 7-Mod(OG-SZ,7)                                    ; Entfernung des Ostersonntag von der Ostergrenze in Tagen
    OS := OG+OE                                             ; Märzdatum (ggf. in den April verlängert) des Ostersonntag, (32. März = 1. April usw.)
    Os:= x . (OS > 31 ? "04" SubStr("0"OS-31,-1) : "03" OS)
    FormatTime, oss,% os, % timestrg
 ; ==============       
 ;Buß- und Bettag                                           ;Mittwoch vor dem 23. November
  tbbt:="`nBuß- und Bettag:             "
  md := OG+OE              
  tOs:= md > 31 ? SubStr("0"md-31,-1) :  md                   ;tag des Ostersonntags für die Berechnung des Buß und Bettags https://www.dagmar-mueller.de/wdz/html/feiertagsberechnung.html     
  tz:= md > 31 ?  Mod((30 - tos), 7)  :  Mod((33 - tos), 7)
  bbt:="20191122"
  bbt += -tz, days
  FormatTime, bbt,% bbt, % timestrg
 ; ==============   
 ; NeuJahr
  tnj:="`nNeuJahr:                           "
  nj:=  jahr . "0101"
  FormatTime, nj,% nj, % timestrg
 ; ==============   
 ; Heilige Drei Könige
   thdk:="`nHeilige Drei Könige:        "
   hdk:=  jahr . "0106"
   FormatTime, hdk,% hdk, % timestrg
 ; ==============   
 ; Internationaler Frauentag (nur Berlin)
   tift:="`nInternationaler Frauentag:         "
   ift:= jahr . "0308"
   FormatTime, ift,% ift, % timestrg
 ; ============== 
  ; Tag der Arbeit  
   ttda:="`nTag der Arbeit:                "
   tda:=  jahr . "0501"
   FormatTime, tda,% tda, % timestrg
 ; ==============   
 ;  Augsburger Friedensfest
    taff:="`nAugsburger Friedensfest:   "
    aff:=  jahr . "0808"
    FormatTime, aff,% aff, % timestrg
 ; ==============   
 ; Mariä Himmelfahrt
   tmhf:="`nMariä Himmelfahrt:            "
   mhf:=  jahr . "0815"
   FormatTime, mhf,% mhf, % timestrg
 ; ==============   
 ; Tag der Deutschen Einheit  
   ttdde:="`nTag der Deutschen Einheit:   "
   tdde:=  jahr . "1003" 
   FormatTime, tdde,% tdde, % timestrg
 ; ==============   
 ; Reformationstag
   trt:="`nReformationstag:           "
   rt:=  jahr . "1031"
   FormatTime, rt,% rt, % timestrg
 ; ==============   
 ; Allerheiligen
   tah:="`nAllerheiligen:                "
   ah:=  jahr . "1101"
   FormatTime, ah,% ah, % timestrg
 ; ==============   
 ; 1. Weihnachtsfeiertag  
   tw1:="`n1. Weihnachtsfeiertag:        "
   w1:=  jahr . "1225" 
   FormatTime, w1,% w1, % timestrg
 ; ==============   
 ; 1. Weihnachtsfeiertag  
   tw2:="`n1. Weihnachtsfeiertag:        "
   w2:=  jahr . "1226"
   FormatTime, w2,% w2, % timestrg
 ; ==============   
; Karfreitag                      Freitag vor Ostersonntag                           = OS – 2
tkfr:="`nKarfreitag:                        " 
  kfr:=os
  kfr += -2, days
  FormatTime, kfr,% kfr, % timestrg
 ; ==============   
;Ostermontag                    Montag nach Ostersonntag                        = OS + 1
  tosm:="`nOstermontag:                  " 
  osm:=os
  osm += 1, days
  FormatTime, osm,% osm, % timestrg
 ; ==============   
;Christi Himmelfahrt          39 Tage nach Ostersonntag                       = OS + 39
  tchf:="`nChristi Himmelfahrt:       " 
  chf:=os
  chf += 39, days
  FormatTime, chf,% chf, % timestrg
 ; ==============   
;Pfingstsonntag                49 Tage nach Ostersonntag                        = OS + 49
  tpfs:="`nPfingstsonntag:             " 
  pfs:=os
  pfs += 49, days
  FormatTime, pfs,% pfs, % timestrg
 ; ==============   
;Pfingstmontag                 50 Tage nach Ostersonntag                        = OS + 50
  tpfm:="`nPfingstmontag:              " 
  pfm:=os
  pfm += 50, days
  FormatTime, pfm,% pfm, % timestrg
 ; ==============   
;Fronleichnam                   60 Tage nach Ostersonntag                       = OS + 60
  tfl:="`nFronleichnam:               " 
  fl:=os
  fl += 60, days
  FormatTime, fl,% fl, % timestrg
 ; ==============   
 
 ; alle (dl)
  ;ft:= nj "," hdk "," ift "," kfr "," os  "," osm "," tda "," chf "," pfs  "," pfm "," fl "," aff "," mhf "," tdde "," rt "," ah "," bbt ","  w1 "," w2 
   ;ft:= tnj nj "," thdk hdk "," tift ift "," tkfr kfr "," ttos oss  "," tosm osm "," ttda tda "," tchf chf "," tpfs pfs  "," tpfm pfm "," tfl fl "," taff aff "," tmhf mhf "," ttdde tdde "," trt rt "," tah ah "," tbbt bbt ","  tw1 w1 "," tw2 w2    
   ;return ft

if (land = "dl") ;test alle
  ft:= tnj nj "," thdk hdk "," tift ift "," tkfr kfr "," ttos oss  "," tosm osm "," ttda tda "," tchf chf "," tpfs pfs  "," tpfm pfm "," tfl fl "," taff aff "," tmhf mhf "," ttdde tdde "," trt rt "," tah ah "," tbbt bbt ","  tw1 w1 "," tw2 w2  
else if (land = "bw") ;Feiertage Baden-Württemberg
  ft:= nj "," hdk "," kfr "," osm "," tda "," chf "," pfm "," fl  "," tdde  "," ah  ","  w1 "," w2   
else if  (land = "by") ;Feiertage Bayern alle
  ft:= nj "," hdk "," kfr "," osm "," tda "," chf "," pfm "," fl "," aff "," mhf "," tdde "," rt "," ah "," bbt ","  w1 "," w2 
else if  (land = "bya") ;Feiertage Bayern alle
  ft:= nj "," hdk "," kfr "," osm "," tda "," chf "," pfm "," fl "," aff "," mhf "," tdde "," rt "," ah "," bbt ","  w1 "," w2 
else if  (land = "byk") ;Feiertage Bayern kath.
  ft:= nj "," hdk "," kfr "," osm "," tda "," chf "," pfm "," fl "," mhf "," tdde "," rt "," ah "," bbt ","  w1 "," w2
else if  (land = "byp") ;Feiertage Bayern prot.
  ft:= nj "," hdk "," kfr "," osm "," tda "," chf "," pfm "," fl  "," tdde "," rt "," ah "," bbt ","  w1 "," w2
else if  (land = "be") ;Feiertage Berlin
  ft:= nj "," ift "," kfr "," osm "," tda "," chf "," pfm "," tdde ","  w1 "," w2 
else if  (land = "bb") ;Feiertage Brandenburg
  ft:= nj "," kfr "," osm "," tda "," chf "," pfm "," tdde "," rt ","  w1 "," w2
else if  (land = "hb") ;Feiertage Bremen
  ft:= nj "," kfr "," osm "," tda "," chf "," pfm "," tdde "," rt ","  w1 "," w2 
else if  (land = "hh") ;Feiertage Hamburg
  ft:= nj "," kfr "," osm "," tda "," chf "," pfm "," tdde "," rt ","  w1 "," w2 
else if  (land = "he") ;Feiertage Hessen
  ft:= nj "," kfr "," osm "," tda "," chf "," pfm "," fl "," tdde ","  w1 "," w2 
else if  (land = "mv") ;Feiertage Mecklenburg-Vorpommern
  ft:= nj "," kfr "," osm "," tda "," chf "," pfm "," tdde "," rt ","  w1 "," w2 
else if  (land = "ni") ;Feiertage Niedersachsen
  ft:= nj "," kfr "," osm "," tda "," chf "," pfm "," tdde "," rt ","  w1 "," w2 
else if  (land = "nw") ;Feiertage Nordrhein-Westfalen
   ft:= nj "," kfr "," osm "," tda "," chf "," pfm "," fl "," tdde "," ah ","  w1 "," w2
else if  (land = "rp") ;Feiertage Rheinland-Pfalz
  ft:= nj "," kfr "," osm "," tda "," chf "," pfm "," fl "," tdde "," ah ","  w1 "," w2 
else if  (land = "sl") ;Feiertage Saarland
  ft:= nj "," kfr "," osm "," tda "," chf "," pfm "," fl "," mhf "," tdde "," ah ","  w1 "," w2 
else if  (land = "sn") ;Feiertage Sachsen
  ft:= nj "," hdk "," kfr "," osm "," tda "," chf "," pfm "," tdde "," rt ","  w1 "," w2 
else if  (land = "st") ;Feiertage Sachsen-Anhalt
  ft:= nj "," hdk "," kfr "," osm "," tda "," chf "," pfm "," tdde "," rt ","  w1 "," w2
else if  (land = "sh") ;Feiertage Schleswig-Holstein
  ft:= nj "," kfr "," osm "," tda "," chf "," pfm "," tdde "," rt ","  w1 "," w2 
else if  (land = "th") ;Feiertage Thüringen
  ft:= nj "," kfr "," osm "," tda "," chf "," pfm "," tdde "," rt ","  w1 "," w2

 return ft
}
