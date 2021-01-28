; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

ExpandNS( NumSeries, RL:="", Uni:=0, D:="," ) {     ;  By SKAN on D28U @ bit.ly/2L81pmP
Local R:= "", N:="", Out:=D, B := IsObject(RL) ? RL : [2**63, 2**63-1]
  Loop, Parse, NumSeries, `,, % " `r`n`t"
    {  
        R := StrSplit(A_LoopField . ".." . A_LoopField, "..", " `r`n`t", 3)
        Loop % ( Abs(R.1-R.2)+1 ) 
          { 
            N   :=  Round(R.1<R.2 ? R.1+A_Index-1 : R.1-A_Index+1)
            Out .=  (Uni && InStr(Out, D . N . D) ? "" : N>=B.1 && N<=B.2 ? N . D : "")
          }
     }  
Return Trim(Out, D)  
}


/*

Basic usage example:

MsgBox % ExpandNS( "1..10, 25..30, 41" ) ;    1,2,3,4,5,6,7,8,9,10,25,26,27,28,29,30,41

Parameters
----------

Number series: Numbers in abbreviated range form
               For eg. 1,2,3,4,5,9,11,12,13,14 in range form would be: 1..5, 9, 11..14
               Non-numerical values are ignored.
               Fractional values would be rounded-off to nearest integer.
               Numbers outside boundary will be omitted from output. (Refer next)
                
Range limit:   2 element array with Low/high boundary. for eg: [1, 26]

Unique:        True/False. True will omit duplicate numbers from output.

Delimiter:     Default output delimiter is comma.  

               Clipboard := ExpandNS( "1..9",,,")`n") . ")"
               would generate following paste content   

               1)
               2)
               3)
               4)
               5)
               6)
               7)
               8)
               9)