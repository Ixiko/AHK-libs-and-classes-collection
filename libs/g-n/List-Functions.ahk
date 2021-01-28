; General Purpose List functions by Roland






; *******************************************************************************
; -------------------------------------------------------------------------------
; List Functions
; -------------------------------------------------------------------------------
; *******************************************************************************

; is var in the list of comma seperated items in matchlist
isIn(var, matchlist) {
if var in % matchlist
  return 1
return 0
}

; does var contain any of the items in matchlist
;    if var contains 1,3  ; Note that it compares the values as strings, not numbers.
;    MsgBox Var contains the digit 1 or 3 (Var could be 1, 3, 10, 21, 23, etc.)
contains(var, matchlist) {
If var contains % matchlist
  return 1
return 0
}


; returns # of items
ListLength(list, del=",") {
ifEqual, list,, return 0
StringReplace, var, list, % del,, useErrorLevel
return errorLevel+1
}


; add item to the end of list
ListAddItem(byRef list, item, del="," ) {
list:=( list!="" ? ( list . del . item ) : item )
return list
}

; Add item to the list at pos, < 0 counted from the end
; ErrorLevel = 1 if pos was truncated, = 0 otherwise
; enclose in commas for search
; pos = -1,-2... counted from right
ListAddItemAtPos(byRef list, item, pos, del="," ) { ; by Laszlo
_list_=%del%%list%%del%
ifLess pos, 0, {
  _pos:=-pos
  StringGetPos chpos, _list_, %del%, R%_pos%
} else ifGreater pos, 1, {    ; pos = 2,3... counted from left
  StringGetPos, chpos, _list_, %del%, L%pos%
  ifEqual, chpos, -1, StringLen chpos, _list_
} StringLeft, lst1, list, chpos - 1
StringTrimLeft, lst2, list, chpos
ifNotEqual, lst2,, SetEnv item, %item%%del%
ifNotEqual, lst1,, SetEnv item, %del%%item%
ifEqual, pos, 0, SetEnv ErrorLevel, 1
list:=lst1 item lst2
return list
}

;removes empty items (and trailing delimiters)
ListClean(byref list, del="") {
If del =
 del = `,
; delete double delimiters
Loop {
  StringReplace, list, list, %del%%del%, %del%, UseErrorLevel
  If ! ErrorLevel
   break
 }
; delete a leading delimiter
If InStr(list, del) = 1
 StringTrimLeft, list, list, 1
; delete a trailing delimiter
If InStr(list, del,0,0) = StrLen(list)
 StringTrimRight, list, list, 1

}


; return item at pos, < 0 from the end
; ErrorLevel = 1 if pos is outside of list
; pos = -1,-2... counted from right
ListGetItem(list, pos=1, del=",") { ; by Laszlo
ifEqual, pos, 0, {
  errorLevel:=1
  return
} _list_:=del . list . del
Transform p1, ABS, pos
p2:=p1+1
ifGreater, pos, 0, {         ; pos > 0 counted from left
  StringGetPos ch1, _list_, %del%, L%p1%
  StringGetPos ch2, _list_, %del%, L%p2%
} else {                     ; pos < 0 counted from right
  StringGetPos ch2, _list_, %del%, R%p1%
  StringGetPos ch1, _list_, %del%, R%p2%
} ifGreater, errorLevel, 0, return   ; nothing found
StringMid, item, list, ch1+1, ch2-ch1-1
return %item%
}

; return position of 1st copy of item, 0 if not found
ListGetPos(list, item, del=",") { ; by Laszlo
_list_=%del%%list%%del%
StringGetPos, ch, _list_, %del%%item%%del%
StringLeft list, _list_, ch+1
StringReplace list, list, %del%, %del%, useErrorLevel
return %errorLevel%
}

; remove & return item from list at pos, < 0 from end
ListCutPos( byRef list, pos=1, del="," ) { ; by Laszlo
_list_=%del%%list%%del%
Transform p1, ABS, pos
p2:=p1+1
ifGreater pos,-1, {        ; pos > 0 counted from left, pos = 0: empty
  StringGetPos, ch1, _list_, %del%, L%p1%
  StringGetPos, ch2, _list_, %del%, L%p2%
} else ifLess pos, 0, {       ; pos < 0 counted from right
  StringGetPos, ch2, _list_, %del%, R%p1%
  StringGetPos, ch1, _list_, %del%, R%p2%
} ifGreater, ErrorLevel, 0, Return   ; nothing found
StringMid, item, list, ch1+1, ch2-ch1-1
StringLeft, lst1, list, ch1-1
StringTrimLeft lst2, list, ch2
ifEqual, lst2,, SetEnv list, %lst1%
else ifEqual lst1,, SetEnv list, %lst2%
else SetEnv list, %lst1%,%lst2%
return item
}

; Del item from list at pos, < 0 from end
; ErrorLevel = 1 if not found. No ByRef as in ListCutPos
ListDelPos( byRef list, pos=1, del="," ) { ; by Laszlo
_list_=%del%%list%%del%
Transform p1, ABS, pos
p2:=p1+1
ifGreater pos,-1, {        ; pos > 0 counted from left, pos = 0: empty
  StringGetPos, ch1, _list_, %del%, L%p1%
  StringGetPos, ch2, _list_, %del%, L%p2%
} else ifLess pos, 0, {       ; pos < 0 counted from right
  StringGetPos, ch2, _list_, %del%, R%p1%
  StringGetPos, ch1, _list_, %del%, R%p2%
} ifGreater, ErrorLevel, 0, Return   ; nothing found
StringLeft, lst1, list, ch1-1
StringTrimLeft, lst2, list, ch2
ifEqual, lst2,, SetEnv list, %lst1%
else ifEqual, lst1,, SetEnv list, %lst2%
else SetEnv list, %lst1%,%lst2%
return list
}

;removes said item from said list
ListDelItem( byRef list, item, del=",") {
ifEqual, item,, return list
list:=del . list . del
StringReplace, list, list, %item%%del%
StringTrimLeft, list, list, 1
StringTrimRight, list, list, 1
return list
}

; replace all itm1 with itm2 in list, itm2="": delete
; errorLevel = # items replaced
ListReplaceItems( byRef list, itm1, itm2="", del="," ) { ; by Laszlo
list=%del%%list%%del%  ; enclose in commas for search
_it_=%del%%itm2%%del%
ifEqual itm2,, SetEnv _it_, % del
Loop { ; StringReplace does not delete consecutive items
    StringReplace list, list, %del%%itm1%%del%, %_it_%, useErrorLevel
    ifEqual, errorLevel, 0, break
    cnt+=errorLevel
  } errorLevel:=cnt
StringTrimLeft  list, list, 1
StringTrimRight list, list, 1
return list
}

;replace the nth item from said list with item
ListReplaceItemAtPos(ByRef list,pos,item=1,del="") {
   del := IIf(del="",",",del)

   StringSplit,array,list,%del%

   if ((pos < 1) OR (pos>array0))
      return list

   array%pos% := item

   Loop % array0
   {
      thisItem := array%a_index%
      newList = %newList%%del%%thisItem%
   }
;   If ( InStr(newList, del,0,0) = StrLen(newList) )         ; check if the last char is a delimiter
;       StringTrimRight, newList, newList, 1
   StringTrimLeft, newList, newList, 1                      ; trim off the first delimeter
   list := newlist
   return newList
}

; swap item @pos1 & item @pos2
ListSwapPos( byRef list, pos1, pos2, del="," ) {
item1:=ListCutPos( list, pos1, del )
item2:=ListCutPos( list, pos2-1, del )
ListAddItemAtPos( list, item1, pos2-1, del )
ListAddItemAtPos( list, item2, pos1, del )
return list
}

; swap item1 with item2
ListSwapItems( byRef list, item1, item2, del="," ) {
p1:=listGetPos(list, item1, del)
p2:=listGetPos(list, item2, del)
ListDelPos( list, p1, del )
ListDelPos( list, p2-1, del )
ListAddItemAtPos( list, item1, p2-1, del )
ListAddItemAtPos( list, item2, p1, del )
return list
}



; returns smallest item
; numeric lists only
ListMin(list, del=",") {
Sort, list, N D%del%
StringLeft, min, list, InStr(list, del)-1
return min
}

; returns largest item
; numeric lists only
ListMax(list, del=",") {
Sort, list, N D%del%
StringTrimLeft, max, list, InStr(list, del, 1, 0)
return max
}
