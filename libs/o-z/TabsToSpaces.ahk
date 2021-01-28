TabsToSpaces(Str, outEOL="`r`n", EOL="`n", Omit="`r"){ ;
       Loop Parse, Str, %EOL%, %Omit%                  ;
       {                                               ;
               index := 0                              ; Used instead of A_Index
               Loop Parse, A_LoopField                 ;  since we can change it
               {                                       ;
                       index++                         ; increment manually
                       If (A_LoopField = A_Tab){       ;
                               Loop % 8-Mod(index, 8)  ;
                                       r .= " "        ;
                               index := -1             ; it's aligned now, 
                       }                               ;  so next tab will be 8
                       else    r .= A_LoopField        ;
               }                                       ;
               r .= outEOL                             ;
       }                                               ;
       StringTrimRight, r, r, % StrLen(outEOL)         ; remove trailing `r`n
       return r                                        ;
}                                                      ;