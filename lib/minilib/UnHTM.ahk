; UnHTM by SKAN
; Please do not expect UnHTM() to unformat a whole HTML file. If you have already parsed out a string, and need to unformat it to plain text, then UnHTM() would be handy. 
; Example:
; HTM = <a href="/intl/en/ads/">Advertising&nbsp;Programs</a>
; MsgBox, % UnHTM( HTM )

UnHTM( HTM ) { ; Remove HTML formatting / Convert to ordinary text     by SKAN 19-Nov-2009
 Static HT     ; Forum Topic: www.autohotkey.com/forum/topic51342.html
 IfEqual,HT,,   SetEnv,HT, % "&aacuteá&acircâ&acute´&aeligæ&agraveà&amp&aringå&atildeã&au"
 . "mlä&bdquo„&brvbar¦&bull•&ccedilç&cedil¸&cent¢&circˆ&copy©&curren¤&dagger†&dagger‡&deg"
 . "°&divide÷&eacuteé&ecircê&egraveè&ethð&eumlë&euro€&fnofƒ&frac12½&frac14¼&frac34¾&gt>&h"
 . "ellip…&iacuteí&icircî&iexcl¡&igraveì&iquest¿&iumlï&laquo«&ldquo“&lsaquo‹&lsquo‘&lt<&m"
 . "acr¯&mdash—&microµ&middot·&nbsp &ndash–&not¬&ntildeñ&oacuteó&ocircô&oeligœ&ograveò&or"
 . "dfª&ordmº&oslashø&otildeõ&oumlö&para¶&permil‰&plusmn±&pound£&quot""&raquo»&rdquo”&reg"
 . "®&rsaquo›&rsquo’&sbquo‚&scaronš&sect§&shy­&sup1¹&sup2²&sup3³&szligß&thornþ&tilde˜&tim"
 . "es×&trade™&uacuteú&ucircû&ugraveù&uml¨&uumlü&yacuteý&yen¥&yumlÿ"
 TXT := RegExReplace( HTM,"<[^>]+>" )               ; Remove all tags between  "<" and ">"
 Loop, Parse, TXT, &`;                              ; Create a list of special characters
   L := "&" A_LoopField ";", R .= (!(A_Index&1)) ? ( (!InStr(R,L,1)) ? L:"" ) : ""
 StringTrimRight, R, R, 1
 Loop, Parse, R , `;                                ; Parse Special Characters
  If F := InStr( HT, A_LoopField )                  ; Lookup HT Data
    StringReplace, TXT,TXT, %A_LoopField%`;, % SubStr( HT,F+StrLen(A_LoopField), 1 ), All
  Else If ( SubStr( A_LoopField,2,1)="#" )
    StringReplace, TXT, TXT, %A_LoopField%`;, % Chr(SubStr(A_LoopField,3)), All
Return RegExReplace( TXT, "(^\s*|\s*$)")            ; Remove leading/trailing white spaces
}

/*
; Array of Special Character Entities was created with following code
Loop % 256-33 {
Transform, F, HTML, % Chr( A := A_Index+33 )
If Strlen(F) > 1 && !Instr( F, "#" )
  list .= "&" SubStr(F,2, StrLen(F)-2) Chr(A )
}
StringLower, List, List
Sort, List, D& U
Clipboard := List
MsgBox, 0, % StrLen( List ), % Clipboard
*/