; Benchmark script for hashTable.ahk
; Results vary sligthly due to using random strings.
; This test takes about 10-20 seconds to run at N:=100000. Do not add a zero, it takes very long time

; Note: to abort, use esc::exitapp()

#include %A_ScriptDir%\..\class_hashTable.ahk
randomSeed(3737)
N:=100000				; Number of key value pairs. Default test case is 100000. Benefits for hashTable can start at around 5000 pairs.
result:=""
makestr(keyvals,N)	; Makes N random words, "`n" - delimited.

p:=3 ; round to p, for display purposes.

;
;	Adding to empty array / table
;

ht := new hashTable()
t1:=QPC()
loop parse, keyvals, "`n"
	ht[A_LoopField] := A_LoopField
t2:=QPC()
result.= "Adding " ht.count() " key/value pairs to empty array / table:`n`n" 
result.= "Hash table`t`t" round(t2-t1,p) "ms.`n"

ahk_array := []
ahk_array.setCapacity(N)
t1:=QPC()
loop parse, keyvals, "`n"
	ahk_array[A_LoopField] := A_LoopField
t2:=QPC()
result.= "Ahk array`t`t`t" round(t2-t1,p) "ms.`n"

keyvals:=sort(keyvals)

ahk_array := []
ahk_array.setCapacity(N)
t1:=QPC()
loop parse, keyvals, "`n"
	ahk_array[A_LoopField] := A_LoopField
t2:=QPC()
result.= "Ahk array sorted`t`t" round(t2-t1,p) "ms.`n"

ht := new hashTable()
t1:=QPC()
ht.splitAdd(&keyvals,&keyvals,"`n",,isByref:=true)
t2:=QPC()
result.= "Hash table splitAdd`t`t" round(t2-t1,p) "ms.`n"

;
;	Adding to already large array / table
;

N:=10000
result.= "`nAdding: " N " more values:`n`n" 
addInLoop:=true
makestr(moreKeyVals, N)
t1:=QPC()
if addInLoop
	loop parse, moreKeyVals, "`n"
		ht[A_LoopField] := A_LoopField
else
	ht.splitAdd(&moreKeyVals, &moreKeyVals, "`n",,true)
t2:=QPC()
result.= "Hash table" (addInLoop?"":" (splitAdd)") "`t`t" round(t2-t1,p) "ms.`n"
moreKeyVals:=sort(moreKeyVals)	; Great benefit
t1:=QPC()
loop parse, moreKeyVals, "`n"
	ahk_array[A_LoopField] := A_LoopField
t2:=QPC()
result.= "Ahk array`t`t`t" round(t2-t1,p) "ms.`n"

;
;	Removing values
;

result.= "`nRemoving the " N " values:`n`n" 

t1:=QPC()
loop parse, moreKeyVals, "`n"
	ht.delete(A_LoopField)
t2:=QPC()
result.= "Hash table`t`t" round(t2-t1,p) "ms.`n"
moreKeyVals:=sort(moreKeyVals) ; Marginal benefit
t1:=QPC()
loop parse, moreKeyVals, "`n"
	ahk_array.delete(A_LoopField)
t2:=QPC()
result.= "Ahk array`t`t`t" round(t2-t1,p) "ms.`n"

;
;	looping
;

result.= "`nLoop self-times:`n`n"

t1:=QPC()
for k, v in ht
	continue
t2:=QPC()
result.= "Hash table self time:`t`t" round(t2-t1,p) "ms.`n"

t1:=QPC()
for k, v in ahk_array
	continue
t2:=QPC()
result.= "Ahk array self time:`t`t" round(t2-t1,p) "ms.`n"

t1:=QPC()
ht.forEach(callbackcreate("forLoop","cdecl fast"))
t2:=QPC()
result.= "Hash table forEach:`t`t" round(t2-t1,p) "ms.`n"
result.= "`nhasVal()`n`n"

;
;	hasVal() - (searches for a value which doesn't exist.)
;
t1:=QPC()
r:=ht.hasVal(1)
t2:=QPC()
result.= "hash table: ( " r " )`t`t" round(t2-t1,p) "ms.`n"

t1:=QPC()
r:=arrHasVal(ahk_array,1)
t2:=QPC()
result.= "Ahk array:  ( " r " )`t`t" round(t2-t1,p) "ms."

;
;	toString()
;
result.= "`n`ntoString()`n`n"
t1:=QPC()
str1:=ht.toString()
t2:=QPC()
result.= "hash table: ( " strlen(str1) " )`t" round(t2-t1,p) "ms.`n"

t1:=QPC()
r:=arrToString(ahk_array, "`t=`t", "`n")
t2:=QPC()
result.= "Ahk array:  ( " strlen(r) " )`t" round(t2-t1,p) "ms."

msgbox(result,"Hash table benchmark",0x40)
exitapp()

esc::exitapp()

; Help functions
forLoop(key,val,i){
	key:=strget(key), val:=strget(val)
	return 1
}
arrHasVal(arr,val){
	for k, v in arr
		if v==val
			return true
	return false
}
arrToString(arr,del1,del2){
	local str
	for k, v in arr
		str.=k . del1 . v . del2
	return rtrim(str,del2)
}

makestr(byref str, N){
	loop N
		str.=rndstr(random(5,25),97,97+25) "`n" 
	rtrim(str,"`n")
}
rndstr(n,min:=1,max:=65535){
	varsetcapacity(str,(n+1)*2), p:=&str, numput(0,&str+(n*1)*2,"ushort")
	loop n
		p:=numput(random(min,max),p,"ushort")
	return strget(&str)
}
;-------------------------------------------------------------------------------
QPC() { ; microseconds precision ; borrowed from wolf_II 
;-------------------------------------------------------------------------------
    static Freq, init := DllCall("QueryPerformanceFrequency", "Int64P", Freq)
	local Count
    DllCall("QueryPerformanceCounter", "Int64P", Count)
    Return (Count / Freq)*1000
}