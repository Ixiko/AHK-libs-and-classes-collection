; Title:   	SHELLSTATE() : Get / Check / Set global SHELL settings (Explorer)
; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

SHELLSTATE(C:=0,  P*)             ;   SHELLSTATE v0.91 for ah2 by SKAN on D495/D495 @ tiny.cc/shellstate
{
    Local K,V,M,N, X := Buffer(32, 0)
    Local Get := (not C and not P.Length)
    Local Set := (not C and P.Length)
    Local Chk := (C and not P.Length)

    If ( Set )
    {
        M := SHELLSTATE(False)

        For K,V in P
        {
            N := StrSplit(V, "=", A_Space, 2)
            K := N[1]
            V := Format("{:d}", N[2])
            M := K = "+" ? ( M | V  )
              :  K = "-" ? ( M & ~V )
              :  K = "^" ? ( M ^ V  )
              :  K = ":" ?   V
                       : ( M | V  )
        }

        NumPut("uint", M >> 20,     X, 28)
      , NumPut("uint", M & 0xfffff, X,  0)
    }

    DllCall("shell32.dll\SHGetSetSettings", "ptr",x, "int",-1, "int",Set)
    N := Set ?  DllCall("shell32.dll\SHChangeNotify", "uint",0x08000000, "uint",0, "ptr",0, "ptr",0) * 0
             :  NumGet(X, "int") | ( NumGet(X, 28, "int") * 0x100000 )

    Return Set ? SHELLSTATE() : Format("0x{1:X}", Chk ? ( N & C=C ? C : 0 ) : N)
}