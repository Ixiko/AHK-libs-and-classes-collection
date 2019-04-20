#include Map.ahk
#include ..\LSON\LSON.ahk
#include ..\Zip\Zip.ahk
#SingleInstance, Force

; what is the biggest index of all arrays in my array?
    arr := [[1,2],[1,2,3,4],["a","b","c","d","e"],[1,2,3]]
    msgbox % max( Map("ObjMaxIndex", arr) )
    ; returns: 5

; check if your object has these keys
    obj := { test: "123", foo: "lala", 123: "numeric key", four: 4 }
    msgbox % lson( Map_C("ObjHasKey", [obj], ["test", "one", "two", "three", "foo", "bar"]) )
    ;returns: 1,0,0,0,1,0

; initialize a stuct and put 4 integers in it
    VarSetCapacity(st, 16)
    Map_C("NumPut", [123,456,789,10], [&st], [0,4,8,12], ["int"])

; get those 4 integers back out
    msgbox % lson( Map_C("NumGet", [&st], [0,4,8,12], ["int"]), ", ")
    ; returns: 123,456,789,10

; what are the lengths of all the strings in my array?
    arr := ["abc", "foobar", "the quick brown fox", "defg"]
    msgbox % lson(Map("StrLen", arr), ", ")
    ; returns: 3, 6, 19, 4

; what is the biggest length string in my array?
    msgbox % max(Map("StrLen", arr)*)
    ; returns: 19

; get every word out of a known string. (yeah i know there are better ways of doing this, StrSplit perhaps)
    string := "the quick brown fox jumped over the lazy dog"
    indexes := [1,5,11,17,21,28,33,37,42]
    lengths := [3,5,5,3,6,4,3,4,3]
    msgbox % """" join(Map_C("SubStr", [string], indexes, lengths), """, """) """"

join(arr, sep = ",") { 
    ;simple join script until we get one built in. :) only works with arrays
    loop % ObjMaxIndex(arr)
        ret .= sep (IsObject(arr[A_Index]) ? join(arr[A_Index], sep) : arr[A_Index])
    return SubStr(ret, StrLen(sep)+1)
}
