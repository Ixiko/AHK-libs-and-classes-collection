; Title:   	SHELLSTATE() : Get / Check / Set global SHELL settings (Explorer)
; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

SHELLSTATE(C:=0, P*) {                   ; SHELLSTATE v0.9 by SKAN on D35B/D35D @ tiny.cc/shellstate
Local K,V,M,X,N:=VarSetCapacity(X,32,0), NP:=P.Count(), Get:=(not C and not NP), Set:=(not C and NP) 
  If Set and ( M:=SHELLSTATE() )
   For K,V in P 
       N:=StrSplit(V,"="," ",2), K := N[1], V:=Round(N[2])
     , M:=K="+" ? M|V : K="-" ? M&~V : K="^" ? M^V : K=":" ? V : M|V
  DllCall("Shell32\SHGetSetSettings","Ptr"
     , Set ? NumPut(M & 0xfffff,NumPut(M >> 20,X,28,"UInt")-32, "UInt")-4 : &X, "Int",-1, "Int",Set)
Return Set ? SHELLSTATE() : Format("0x{2:08X}", N:=NumGet(X,"UInt") | (NumGet(X,28,"UInt")*0x100000)
     , Get ? N : (N & C)=C ? N : 0)
}