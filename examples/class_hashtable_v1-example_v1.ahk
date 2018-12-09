; Simplest example. Creating a hashTable and adding a key/value pair. Shows hasKey, hasVal splitAdd and finally toString() to view the result.
#include %A_ScriptDir%\..\class_hashTable_v1.ahk
ht := new hashTable
ht["hello"] := "hash"
msgbox,, % "Hash table example.",  % "hasKey(""hello"")	=	" ht.hasKey("hello") "`nhasVal(""hash"") 	=	" ht.hasVal("hash")
keys:="
(
key1
key2
key3
)"
vals:="
(
val1
val2
val3
)"
ht.splitAdd(keys,vals)	; split by line break (default)
ht.delete("key2")		; Delete key2
msgbox % ht.toString()
exitapp