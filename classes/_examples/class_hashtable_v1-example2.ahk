; for loop example. 
#include %A_ScriptDir%\..\class_hashTable.ahk
ht := new hashTable
keys:="key1|key2|key3|key4"
vals:="val1|val2|val3|val4"
ht.splitAdd(keys,vals, "|")	; split by pipe
ht.forEach("myFunc")	; Note the order of the pairs
ht.toTree()				; View it.
exitapp()

myFunc(key,val){
	msgbox(key "`t=`t" val)
	if val == "val4"		
		return -1			; Return -1 means delete and continue. The key/value pair is deleted if val == "val4"
	else if key == "key2"   
		return 0			; Return 0 means break. The loop is stopped if key == "val2"
	return 1				; Return 1 means continue
}