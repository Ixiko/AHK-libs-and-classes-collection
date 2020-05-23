/* Modes

 - Append numbers to combine
1=lowercase
2=uppercase
3=digits
4=symbols

example: randStr(1,5,124)

test:
rr:=[1,2,3,4,12,13,14,23,24,34,123,124,134,1234]
for i,a in rr
    msgbox % a "`n" randStr(10,20,a)
*/
randStr(lowerBound,upperBound,mode=1){
    if(!isDigit(lowerBound)||!isDigit(upperBound)||!isDigit(mode))
        return -1
    loop % rand(lowerBound,upperBound){
        t:=""
        if(strLen(mode)=1)
            t:=mode
        else{
            while(!ifContains(mode,t))
                t:=rand(1,4)
        }
        if(t=1)
            str.=chr(rand(97,122))
        else if(t=2)
            str.=chr(rand(65,90))
        else if(t=3)
            str.=rand(0,9)
        else if(t=4){
            i:=rand(1,4)
            str.=i=1?chr(rand(33,47)):i=2?chr(rand(58,64)):i=3?chr(rand(91,96)):chr(rand(123,126))
        }
    }
    return str
}
