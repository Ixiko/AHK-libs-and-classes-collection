; Title:   	
; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

; code by SKAN  simple approach of parsing the results 
Deref_Umlauts( w, n=1 )
{ 
  stringreplace, w, w, \u0171, % chr("0xfc")
  stringreplace, w, w, \u0151, % chr("0xf6")
  While n := instr( w, "\u",1,n ) 
    StringReplace, w, w, % ww := substr( w,n,6 ), % chr( "0x" substr( ww,3 ) ), all 
  Return w 
}