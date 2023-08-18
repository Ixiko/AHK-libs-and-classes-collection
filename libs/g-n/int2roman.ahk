/*
  _____       _     ____      __                              
  \_   \_ __ | |_  |___ \    /__\ ___  _ __ ___   __ _ _ __   
   / /\| '_ \| __|   __) |  / \/// _ \| '_ ` _ \ / _` | '_ \  
/\/ /_ | | | | |_   / __/  / _  | (_) | | | | | | (_| | | | | 
\____/ |_| |_|\__| |_____| \/ \_/\___/|_| |_| |_|\__,_|_| |_| 
                                                              
              Coded by errorseven @ 11-19-2018


  - Supports Values up to whenever you Overflow and crash!
  - A Numeral surrounded by Parenthesis denotes x 1000


Breakdown: 300,600,999 == ((CCC))(DC)CMXCIX

  300,000,000 == (((CCC))) == (((C=100)x3)x1000)x1000 
  600,000     == (DC) == ((D=500 + C=100) == 600)x1000
  900         == CM == (C=100 - M=1000) 
  90          == XC == (X=10 - C=100)
  9           == IX == (I=1 - X=10)
 
Compared values to this websites Large Roman Numeral
https://www.mytecbits.com/tools/mathematics/roman-numerals-converter#aSimple  
*/

roman(x) { ; Supports up to Overflow??? 

if x is not Integer 
    return
    
if (x > 3999999999 or x < 1) 
    return 
    
    rn:=[["M", 1000],["CM", 900],["D",500],["CD",400],["C",100],["XC",90]
    ,["L",50],["XL", 40],["X", 10],["IX",9],["V",5],["IV", 4],["I",1]]

    While(x) {
        (x>=4000?(i:=SubStr(x, -2)
        , x:=SubStr(x,1,StrLen(x)-StrLen(i)))
        :x<4000?(i:=x,x:=""))
        ((A_Index>1)?(F.="(",B.=")"):_), g.=F
        
        While(i)              
            for e, v in rn  
                if (i >= v.2) {
                    g .= v.1, i -= v.2
                    Break
                }
        r:= g B r, g:=""
    }
    return r
}