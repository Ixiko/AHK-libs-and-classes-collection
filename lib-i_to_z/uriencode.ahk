uriEncode(str)
{ ; v 0.3 / (w) 24.06.2008 by derRaphael / zLib-Style release
   b_Format := A_FormatInteger
   data := ""
   SetFormat,Integer,H
   Loop,Parse,str
      if ((Asc(A_LoopField)>0x7f) || (Asc(A_LoopField)<0x30) || (asc(A_LoopField)=0x3d))
         data .= "%" . ((StrLen(c:=SubStr(ASC(A_LoopField),3))<2) ? "0" . c : c)
      Else
         data .= A_LoopField
   SetFormat,Integer,%b_format%
   return data
}