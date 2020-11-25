; Link:   	https://www.autohotkey.com/boards/viewtopic.php?style=1&t=75965&p=337992
; Author:	SKAN
; Date:   	15.05.2020
; for:     	AHK_L

; SHELLSTATE( [Check, Variadic parameters] )
; SHELLSTATE() when called without any parameters will retrieve the global Shell settings.

/*


*/

						; Flags
ShellStates := {	"ShowAllObjects"              	: "0x1"
                  	,	"ShowExtensions"              	: "0x2"      	            	; HideFileExt
                  	,	"NoConfirmRecycle"          	: "0x4"
                  	,	"ShowCompColor"          	: "0x10"      	        	; ShowCompColor
                  	,	"DoubleClickInWebView"      	: "0x20"
                  	,	"DontPrettyPath"              	: "0x100"      	        	; DontPrettyPath
                  	,	"MapNetDrvBtn"              	: "0x400"      	         	; MapNetDrvBtn
                  	,	"ShowInfoTip"                  	: "0x800"        	       	; ShowInfoTip
                  	,	"HideIcons"                      	: "0x1000"      	     	; HideIcons
                  	,	"WebView"                      	: "0x2000"      	      	; WebView
                  	,	"Filter"                              	: "0x4000"      	      	; Filter
                  	,	"ShowSuperHidden"          	: "0x8000"      	      	; ShowSuperHidden
                  	,	"NoNetCrawling"              	: "0x10000"
                  	,	"AutoCheckSelect"          	: "0x800000"      	 	; AutoCheckSelect
			    		; Exflags
                  	,	"SeparateProcess"          	: "0x100000"      	  	; SeparateProcess
                  	,	"StartPanelOn"                  	: "0x200000"
                  	,	"IconsOnly"                      	: "0x1000000"      	 	; IconsOnly
                  	,	"ShowTypeOverlay"          	: "0x2000000"      	 	; ShowTypeOverlay
                  	,	"ShowStatusBar"              	: "0x4000000"}   	 	; ShowStatusBar   (Win 8+)

; The names in comment are keys found in
; HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced

SHELLSTATE(C:=0, P*) {                   ; SHELLSTATE v0.9 by SKAN on D35B/D35D @ tiny.cc/shellstate

The following is (a slightly incomplete) list of available settings that can be used with SHELLSTATE()
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