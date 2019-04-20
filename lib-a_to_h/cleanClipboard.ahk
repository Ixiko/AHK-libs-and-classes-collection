cleanClipboard(){
  StringReplace, quote, quote, `r, %A_Space%, All 
  StringReplace, quote, quote, `r`r, %A_Space%, All 
  StringReplace, quote, quote, `r`n, %A_Space%, All 
  StringReplace, quote, quote, `n,  %A_Space%, All 
  StringReplace, quote, quote, `n`n,  %A_Space%, All 
  StringReplace, quote, quote, `n`r,  %A_Space%, All 
  StringReplace, quote, quote, `t,  %A_Space%, All 
  StringReplace, quote, quote, %A_Space%%A_Space%, %A_Space%, All 
  StringReplace, quote, quote, %A_Space%%A_Space%, %A_Space%, All 
}