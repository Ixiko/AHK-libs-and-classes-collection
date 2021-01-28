;
; AutoHotkey Version: 1.0.31.04+
; Language:  English
; Platform:  Win2000/XP
; Author:    Laszlo Hars <www.Hars.US>
;
; Script Function:
;   Function library to manipulate comma delimited lists
;   Little error check is performed on the parameters, add your own!
;
; Test cases at the end are activated with adding lines like
;   TestListUniq = 1
;
; Version 1.0: 2005.04.14 Initial creation
; Version 1.1: 2005.04.17
;              Minor cleanups (removed unnecessary %'s, partial results...)
;              Added test code
;              User function Precede is used in ListMerge and ListSort
; Version 1.2: 2005.04.20
;              Change: Removed ByRef in ListAdd and ListReplace to Return list
;              Added ListSwap(pos1,pos2,list) - Swap items at pos1 and pos2
;                    ListMove(pos1,pos2,list) - Move item from pos1 to pos2
;                    ListDel(pos,list)        - Delete item, Return list
;                    ListReloc(pos,ofst,list) - Move item relative to current pos
;                    ListRemove(text,list)    - Remove items containing text
;                    ListKeep(text,list)      - Remove items NOT containing text
; Version 1.3: 2005.04.21
;              Changed ListRemove and ListKeep (text,opt,list), opt<0, =0, >0
;                    to search text at end, anywhere, or in beginning of item
; Version 1.4: 2005.05.09
;              Hexify is renamed String2Hex
;              Added its inverse Hex2String (thanks Skrommel)

ListAdd(item,pos,list)        ; Add item to the list at pos, < 0 counted from the end
{                             ; ErrorLevel = 1 if pos was truncated, = 0 otherwise
   _list_ = ,%list%,          ; enclose in commas for search
   IfLess pos,0, {            ; pos = -1,-2... counted from right
      _pos := -pos
      StringGetPos chpos, _list_, `,, R%_pos%
   }
   Else IfGreater pos,1, {    ; pos = 2,3... counted from left
      StringGetPos chpos, _list_, `,, L%pos%
      IfEqual chpos,-1, StringLen chpos, _list_
   }                          ; pos = 0, 1 and normal cases ...
   StringLeft lst1, list, chpos - 1
   StringTrimLeft lst2, list, chpos
   IfNotEqual lst2,, SetEnv item, %item%`,
   IfNotEqual lst1,, SetEnv item, `,%item%
   IfEqual pos,0, SetEnv ErrorLevel, 1
   Return lst1 item lst2
}

ListCut(pos, ByRef list)      ; Remove & return item from list at pos, < 0 from end
{
   _list_ = ,%list%,          ; enclose in commas for search
   Transform p1, ABS, pos
   p2 := p1 + 1
   IfGreater pos,-1, {        ; pos > 0 counted from left, pos = 0: empty
      StringGetPos ch1, _list_, `,, L%p1%
      StringGetPos ch2, _list_, `,, L%p2%
   }
   Else IfLess pos,0, {       ; pos < 0 counted from right
      StringGetPos ch2, _list_, `,, R%p1%
      StringGetPos ch1, _list_, `,, R%p2%
   }
   IfGreater ErrorLevel,0, Return   ; nothing found

   StringMid      item, list, ch1+1, ch2-ch1-1
   StringLeft     lst1, list, ch1-1
   StringTrimLeft lst2, list, ch2

   IfEqual      lst2,, SetEnv list, %lst1%
   Else IfEqual lst1,, SetEnv list, %lst2%
   Else                SetEnv list, %lst1%,%lst2%

   Return item
}

ListDel(pos,list)             ; Del item from list at pos, < 0 from end
{                             ; ErrorLevel = 1 if not found. No ByRef as in ListCut
   _list_ = ,%list%,          ; enclose in commas for search
   Transform p1, ABS, pos
   p2 := p1 + 1
   IfGreater pos,-1, {        ; pos > 0 counted from left, pos = 0: empty
      StringGetPos ch1, _list_, `,, L%p1%
      StringGetPos ch2, _list_, `,, L%p2%
   }
   Else IfLess pos,0, {       ; pos < 0 counted from right
      StringGetPos ch2, _list_, `,, R%p1%
      StringGetPos ch1, _list_, `,, R%p2%
   }
   IfGreater ErrorLevel,0, Return list ; no change

   StringLeft     lst1, list, ch1-1
   StringTrimLeft lst2, list, ch2

   IfEqual      lst2,, SetEnv list, %lst1%
   Else IfEqual lst1,, SetEnv list, %lst2%
   Else                SetEnv list, %lst1%,%lst2%

   Return list
}

ListItem(pos,list)            ; Return item at pos, < 0 from the end
{                             ; ErrorLevel = 1 if pos is outside of list
   IfEqual pos,0, {
      ErrorLevel = 1
      Return
   }
   _list_ = ,%list%,          ; enclose in commas for search
   Transform p1, ABS, pos
   p2 := p1 + 1
   IfGreater pos,0, {         ; pos > 0 counted from left
      StringGetPos ch1, _list_, `,, L%p1%
      StringGetPos ch2, _list_, `,, L%p2%
   }
   Else {                     ; pos < 0 counted from right
      StringGetPos ch2, _list_, `,, R%p1%
      StringGetPos ch1, _list_, `,, R%p2%
   }
   IfGreater ErrorLevel,0, Return   ; nothing found
   StringMid item, list, ch1+1, ch2-ch1-1
   Return %item%
}

ListLen(list)                 ; how many items constitute the list
{
   IfEqual list,, Return 0
   StringReplace list, list, `,, `,, UseErrorLevel
   Return ErrorLevel + 1
}

ListPart(pos1,pos2,list)      ; Returns list_pos1,...,list_pos2, pos < 0: from end
{
   _list_ = ,%list%,          ; enclose in commas for search
   IfLess pos1,0, {
      p := 1-pos1
      StringGetPos ch1, _list_, `,, R%p%
      IfGreater ErrorLevel,0, SetEnv ch1, 0
   }
   Else {
      StringGetPos ch1, _list_, `,, L%pos1%
      IfGreater ErrorLevel,0, StringLen ch1, _list_
   }
   IfLess pos2,0, {
      p := -pos2
      StringGetPos ch2, _list_, `,, R%p%
      IfGreater ErrorLevel,0, SetEnv ch2, 0
   }
   Else {
      p := 1+pos2
      StringGetPos ch2, _list_, `,, L%p%
      IfGreater ErrorLevel,0, StringLen ch2, _list_
   }
   StringMid list, list, ch1+1, ch2-ch1-1
   Return list
}

ListPos(item,list)            ; Return position of 1st copy of item, 0 if not found
{
   _list_ = ,%list%,          ; enclose in commas for search
   StringGetPos ch, _list_, `,%item%`,
   StringLeft list, _list_, ch+1
   StringReplace list, list, `,, `,, UseErrorLevel
   Return %ErrorLevel%
}

ListReplace(itm1,itm2,list)   ; Replace all itm1 with itm2 in list, itm2="": delete
{                             ; ErrorLevel = # items replaced
   list = ,%list%,            ; enclose in commas for search
   _it_ = ,%itm2%,
   IfEqual itm2,, SetEnv _it_, `,
   Loop
   {                          ; StringReplace does not delete consecutive items
      StringReplace list, list, `,%itm1%`,, %_it_%, UseErrorLevel
      IfEqual ErrorLevel,0, Break
      cnt += ErrorLevel
   }
   ErrorLevel := cnt
   StringTrimLeft  list, list, 1
   StringTrimRight list, list, 1
   Return list
}

ListSplit(pos,list,ByRef lst1,ByRef lst2) ; Split list at pos, < 0 from end
{       ; pos >=0: lst1:=item_1,...,item_pos;   lst2:=item_pos+1,...{end}
        ; pos < 0: lst1:=item_1,...,item_pos-1; lst2:=item_pos,...{end}
   _list_ = ,%list%,          ; enclose in commas for search
   IfLess pos,0, {
      p := 1-pos
      StringGetPos ch, _list_, `,, R%p%
      IfGreater ErrorLevel,0, SetEnv ch, 0
   }
   Else {
      p := 1+pos
      StringGetPos ch, _list_, `,, L%p%
      IfGreater ErrorLevel,0, StringLen ch, _list_
   }
   StringLeft     lst1, list, ch-1
   StringTrimLeft lst2, list, ch
}

ListSwap(pos1,pos2,list)      ; Returns list with items at pos1 & pos2 swapped
{                             ; ErrorLevel = 1 if item1 or item2 does not exist
   _list_ = ,%list%,          ; enclose in commas for search
   IfLess pos1,0, {
      pos1 := 1-pos1
      StringGetPos ch11, _list_, `,, R%pos1%
      IfGreater ErrorLevel,0, Return list
      pos1--                              ; before the beginning
      StringGetPos ch12, _list_, `,, R%pos1%
   }
   Else {
      StringGetPos ch11, _list_, `,, L%pos1%
      IfGreater ErrorLevel,0, Return list ; pos1 = 0
      pos1++
      StringGetPos ch12, _list_, `,, L%pos1%
      IfGreater ErrorLevel,0, Return list ; over the end
   }
   IfLess pos2,0, {
      pos2 := 1-pos2
      StringGetPos ch21, _list_, `,, R%pos2%
      IfGreater ErrorLevel,0, Return list
      pos2--                              ; before the beginning
      StringGetPos ch22, _list_, `,, R%pos2%
   }
   Else {
      StringGetPos ch21, _list_, `,, L%pos2%
      IfGreater ErrorLevel,0, Return list ; pos2 = 0
      pos2++
      StringGetPos ch22, _list_, `,, L%pos2%
      IfGreater ErrorLevel,0, Return list ; over the end
   }
   IfEqual ch11,%ch21%, Return list       ; swap the same
   StringMid I1, list, ch11+1, ch12-ch11-1
   StringMid I2, list, ch21+1, ch22-ch21-1
   IfLess ch11,%ch21%, {
      StringLeft     L1, list, ch11
      StringMid      L2, list, ch12, ch21-ch12+1
      StringTrimLeft L3, list, ch22-1
      Return L1 I2 L2 I1 L3
   }
   Else {
      StringLeft     L1, list, ch21
      StringMid      L2, list, ch22, ch11-ch22+1
      StringTrimLeft L3, list, ch12-1
      Return L1 I1 L2 I2 L3
   }
}

ListMove(pos1,pos2,list)      ; Move item from pos1 to pos2, return new list
{                             ; ErrorLevel = 1 if pos1 wrong or pos2 truncated
   ;item := ListCut(pos1,list) ; Does not work in AHK 1.0.31.05 (ByRef bug)
   item := ListItem(pos1,list) ; Remove if ByRef fixed
   IfEqual item,, Return list
   list := ListDel(pos1,list)  ; Remove if ByRef fixed
   Return ListAdd(item,pos2,list)
}

ListReloc(pos,ofst,list)      ; Move item relative to its current position
{                             ; ErrorLevel = 1 if pos wrong or pos+ofst truncated
   ;item := ListCut(pos,list) ; Does not work in AHK 1.0.31.05 (ByRef bug)
   item := ListItem(pos,list) ; Remove if ByRef fixed
   IfEqual item,, Return list
   list := ListDel(pos,list)  ; Remove if ByRef fixed
   Return ListAdd(item,pos+ofst,list)
}

;----- Contained Text functions -----

ListRemove(text,opt,list)     ; Remove items containing text. ErrorLevel = #removed items
{                             ; Opt<,=,>0 text at end, anywhere, in beginning of item
   _list_ = ,%list%,          ; enclose in commas for search
   IfGreater   opt,0, SetEnv text, `,%text%
   Else IfLess opt,0, SetEnv text, %text%`,
   Loop
   {
      StringGetPos ch, _list_, %text%
      IfEqual ch,-1, Break
      cnt++
      StringLen len, _list_
      IfGreater opt,0, SetEnv ch1,%ch% ; position of ","
      Else StringGetPos ch1, _list_, `,, R, len-ch
      StringGetPos ch2, _list_, `,, L, ch+1
      StringLeft     L1, _list_, ch1
      StringTrimLeft L2, _list_, ch2+1
      _list_ = %L1%,%L2%
   }
   StringTrimLeft  _list_, _list_, 1
   StringTrimRight _list_, _list_, 1
   ErrorLevel = %cnt%
   Return _list_
}

ListKeep(text,opt,list)       ; Keep only items containing text, ErrorLevel = #kept items
{                             ; Opt<,=,>0 text at end, anywhere, in beginning of item
   _list_ = ,%list%,          ; enclose in commas for search
   StringLen len, _list_
   IfGreater   opt,0, SetEnv text, `,%text%
   Else IfLess opt,0, SetEnv text, %text%`,
   Loop
   {
      StringGetPos ch, _list_, %text%, L, ch+1  ; at start ""+1 = ""
      IfEqual ch,-1, Break
      cnt++
      IfGreater opt,0, SetEnv ch1,%ch% ; position of ","
      Else StringGetPos ch1, _list_, `,, R, len-ch
      StringGetPos ch2, _list_, `,, L, ch+1
      StringMid I, list, ch1+1, ch2-ch1-1
      L = %L%,%I%
   }
   StringTrimLeft  L, L, 1
   ErrorLevel = %cnt%
   Return L
}

;----- Sorted list functions -----

Precede(x,y)                  ; =1 if x precedes y (used in In ListMerge, ListSort)
{
   IfGreater x,%y%, Return 1
}

ListMerge(list1,list2)        ; Merge sorted lists
{                             ; If listX = item, insert in the right place
   IfEqual list1,, Return list2
   IfEqual list2,, Return list1
   p1 = 1
   p2 = 1
   i1 := ListItem(1,list1)
   i2 := ListItem(1,list2)
   Loop
   {
;     IfLess i1,%i2%, {       ; Ascending <-- change for other order
      If Precede(i1,i2)       ; User supplied order
      {
         list = %list%,%i1%
         p1++
         i1 := ListItem(p1,list1)
         IfNotEqual i1,, Continue
         list := list "," ListPart(p2,-1,list2)
         break                ; list1 is exhausted
      }
      Else {
         list = %list%,%i2%
         p2++
         i2 := ListItem(p2,list2)
         IfNotEqual i2,, Continue
         list := list "," ListPart(p1,-1,list1)
         break                ; list2 is exhausted
      }
   }
   StringTrimLeft list, list, 1
   Return list
}

ListSort(ByRef list)          ; ByRef wrapper for recursive sort
{                             ; for simple cases "Sort x, D," is faster
   list := _Sort(ListLen(list),list)
}

_Sort(len,lst)                ; Returns Recursive Merge-sorted list
{                             ; No ByRef with recursion in AHK Vers 1.0.31
   IfLess len,2, Return lst   ; list of length 0,1 is sorted
   L1 := len >> 1             ; integer halve
   Return ListMerge(_Sort(L1,ListPart(1,L1,lst)),_Sort(len-L1,ListPart(L1+1,-1,lst)))
}

String2Hex(x)                 ; Convert a string to a huge hex number starting with X
{
   StringLen Len, x
   format = %A_FormatInteger%
   SetFormat Integer, H
   hex = X
   Loop %Len%
   {
      Transform y, ASC, %x%   ; ASCII code of 1st char, 15 < y < 256
      StringTrimLeft y, y, 2  ; Remove leading 0x
      hex = %hex%%y%
      StringTrimLeft x, x, 1  ; Remove 1st char
   }
   SetFormat Integer, %format%
   Return hex
}

Hex2String(x)                 ; Convert a huge hex number starting with X to string
{
   StringTrimLeft x, x, 1     ; discard leading X
   StringLen len, x
   Loop % len/2               ; 2-digit blocks
   {
      StringLeft hex, x, 2
      Transform y, Chr, % "0x"hex
      string = %string%%y%
      StringTrimLeft x, x, 2
   }
   Return string
}

ListUniq(ByRef list)          ; Remove repeated items from list, preserve order
{                             ; faster than _Sort
   list = %list%,             ; "," added for simpler search
   c = 0
   Loop
   {
      StringGetPos d, list, `,,, %c% ; search from c
      IfLess d,0, {           ; No more ","
         StringTrimRight list, list, 1
         Return
      }
      StringMid item, list, % c+1, % d-c
      hex := String2Hex(item) ; Item might not be a valid name
      IfEqual %hex%,, {       ; 1st occurrence
         %hex% = 1            ; Record that hex is found
         c := d + 1           ; Jump over next ","
         Continue
      }                       ; hex already occured ...
      StringLeft      left, list,% c-1
      StringTrimLeft right, list, %d%
      list = %left%%right%
   }
}

;----- Hash functions -----

Hash16(x)   ; 16-bit hash related to DJB2 hash(i) = 33*hash(i-1) + x[i]
{
   hash = 5381
   StringLen Len, x
   Loop %Len%
   {
      Transform y, ASC, %x%   ; ASCII code of 1st char
      hash := 33*hash + y                ; *33 = <<5,add
      hash := hash >> 16 ^ hash & 0xFFFF ; Fold over MS & LS word
      StringTrimLeft x, x, 1  ; Remove 1st char from x
   }
   Return hash
}

;----- Test cases for function x: set TESTx = 1 -----

TEST(A,x)   ; Display expression x and its value: TEST(A_LineNumber,3*a+2)
{
   E = %ErrorLevel%
   FileReadLine Line, %A_LineFile%, %A%
   StringTrimLeft  Line, Line, 18
   StringTrimRight Line, Line, 1
   MsgBox %Line% = {%x%}`nErrorLevel = {%E%}
}

TEST1(A,x)  ; Display 1 prior line I =, the expression, its value and the new I
{
   Global I
   E = %ErrorLevel%
   FileReadLine LI,   %A_LineFile%,% A-1
   FileReadLine Line, %A_LineFile%, %A%
   StringTrimLeft  Line, Line, 19
   StringTrimRight Line, Line, 1
   MsgBox %LI%`n%Line% = {%x%}`nI = {%I%}`nErrorLevel = {%E%}
}

TEST2(A,x)  ; Display expression x, its value and 2 ByRef values I and J
{
   Global I, J
   E = %ErrorLevel%
   FileReadLine Line, %A_LineFile%, %A%
   StringTrimLeft  Line, Line, 19
   StringTrimRight Line, Line, 1
   MsgBox %Line% = {%x%}`nI = {%I%}`nJ = {%J%}`nErrorLevel = {%E%}
}

IfNotEqual TestListSwap,, {
TEST(A_LineNumber,ListSwap(2,4,"1,2,3,4,5"))
TEST(A_LineNumber,ListSwap(4,2,"1,2,3,4,5"))
TEST(A_LineNumber,ListSwap(1,1,"1,2,3,4,5"))
TEST(A_LineNumber,ListSwap(0,4,"1,2,3,4,5"))
TEST(A_LineNumber,ListSwap(2,6,"1,2,3,4,5"))
TEST(A_LineNumber,ListSwap(1,1,"1"))
}

IfNotEqual TestListAdd,, {
TEST(A_LineNumber,ListAdd(1,0,""))
TEST(A_LineNumber,ListAdd("3",-1,""))
TEST(A_LineNumber,ListAdd(2,2,"1,3"))
TEST(A_LineNumber,ListAdd(5,5,"1,2,3"))
TEST(A_LineNumber,ListAdd(4,-2,"1,2,3,5"))
TEST(A_LineNumber,ListAdd(0,-9,"1,2,3"))
TEST(A_LineNumber,ListAdd(0,-4,"1,2,3"))
TEST(A_LineNumber,ListAdd(4,4,"1,2,3"))
TEST(A_LineNumber,ListAdd(4,5,"1,2,3"))
}

IfNotEqual TestListCut,, {
I =
TEST1(A_LineNumber,ListCut( 1,I))
I = abc
TEST1(A_LineNumber,ListCut( 1,I))
I = abc
TEST1(A_LineNumber,ListCut(-1,I))
I = abc
TEST1(A_LineNumber,ListCut( 2,I))
I = abc
TEST1(A_LineNumber,ListCut( 2,I))
I = abc
TEST1(A_LineNumber,ListCut(-2,I))
I = 1,2,03,4,5
TEST1(A_LineNumber,ListCut( 0,I))
I = 1,2,03,4,5
TEST1(A_LineNumber,ListCut( 1,I))
I = 1,2,03,4,5
TEST1(A_LineNumber,ListCut( 2,I))
I = 1,2,03,4,5
TEST1(A_LineNumber,ListCut( 3,I))
I = 1,2,03,4,5
TEST1(A_LineNumber,ListCut( 4,I))
I = 1,2,03,4,5
TEST1(A_LineNumber,ListCut( 5,I))
I = 1,2,03,4,5
TEST1(A_LineNumber,ListCut( 6,I))
I = 1,2,03,4,5
TEST1(A_LineNumber,ListCut(-1,I))
I = 1,2,03,4,5
TEST1(A_LineNumber,ListCut(-2,I))
I = 1,2,03,4,5
TEST1(A_LineNumber,ListCut(-4,I))
I = 1,2,03,4,5
TEST1(A_LineNumber,ListCut(-5,I))
I = 1,2,03,4,5
TEST1(A_LineNumber,ListCut(-6,I))
}

IfNotEqual TestListItem,, {
TEST(A_LineNumber,ListItem( 1,""))
TEST(A_LineNumber,ListItem( 1,"abc"))
TEST(A_LineNumber,ListItem(-1,"abc"))
TEST(A_LineNumber,ListItem( 2,"abc"))
TEST(A_LineNumber,ListItem(-2,"abc"))
TEST(A_LineNumber,ListItem( 0,"1,2,03,4,5"))
TEST(A_LineNumber,ListItem( 1,"1,2,03,4,5"))
TEST(A_LineNumber,ListItem( 2,"1,2,03,4,5"))
TEST(A_LineNumber,ListItem( 3,"1,2,03,4,5"))
TEST(A_LineNumber,ListItem( 4,"1,2,03,4,5"))
TEST(A_LineNumber,ListItem( 5,"1,2,03,4,5"))
TEST(A_LineNumber,ListItem( 6,"1,2,03,4,5"))
TEST(A_LineNumber,ListItem(-1,"1,2,03,4,5"))
TEST(A_LineNumber,ListItem(-2,"1,2,03,4,5"))
TEST(A_LineNumber,ListItem(-5,"1,2,03,4,5"))
TEST(A_LineNumber,ListItem(-6,"1,2,03,4,5"))
}

IfNotEqual TestListMove,, {
TEST(A_LineNumber,ListMove(1,2,"1,2,3,4,5"))
TEST(A_LineNumber,ListMove(2,1,"1,2,3,4,5"))
TEST(A_LineNumber,ListMove(1,-1,"1,2,3,4,5"))
TEST(A_LineNumber,ListMove(-1,1,"1,2,3,4,5"))
TEST(A_LineNumber,ListMove(4,5,"1,2,3,4,5"))
TEST(A_LineNumber,ListMove(5,4,"1,2,3,4,5"))
TEST(A_LineNumber,ListMove(2,4,"1,2,3,4,5"))
TEST(A_LineNumber,ListMove(4,2,"1,2,3,4,5"))
TEST(A_LineNumber,ListMove(0,1,"1,2,3,4,5"))
TEST(A_LineNumber,ListMove(1,6,"1,2,3,4,5"))
TEST(A_LineNumber,ListMove(1,-6,"1,2,3,4,5"))
TEST(A_LineNumber,ListMove(1,-5,"1,2,3,4,5"))
TEST(A_LineNumber,ListMove(1,-4,"1,2,3,4,5"))
TEST(A_LineNumber,ListMove(-1,5,"1,2,3,4,5"))
TEST(A_LineNumber,ListMove(-4,-5,"1,2,3,4,5"))
}

IfNotEqual TestListReloc,, {
TEST(A_LineNumber,ListReloc(1,0,"1,2,3,4,5"))
TEST(A_LineNumber,ListReloc(1,1,"1,2,3,4,5"))
TEST(A_LineNumber,ListReloc(1,-1,"1,2,3,4,5"))
TEST(A_LineNumber,ListReloc(2,1,"1,2,3,4,5"))
TEST(A_LineNumber,ListReloc(2,-1,"1,2,3,4,5"))
TEST(A_LineNumber,ListReloc(-1,1,"1,2,3,4,5"))
TEST(A_LineNumber,ListReloc(-1,-1,"1,2,3,4,5"))
TEST(A_LineNumber,ListReloc(5,-4,"1,2,3,4,5"))
TEST(A_LineNumber,ListReloc(2,3,"1,2,3,4,5"))
}

IfNotEqual TestListPos,, {
TEST(A_LineNumber,ListPos(1,""))
TEST(A_LineNumber,ListPos("","abc"))
TEST(A_LineNumber,ListPos("a","abc"))
TEST(A_LineNumber,ListPos("ab","ab,ac"))
TEST(A_LineNumber,ListPos("ac","ab,ac"))
TEST(A_LineNumber,ListPos("ab","ab,ab"))
TEST(A_LineNumber,ListPos("abc","abc"))
TEST(A_LineNumber,ListPos( 1,"1,2,12,4,4"))
TEST(A_LineNumber,ListPos( 2,"1,2,12,4,4"))
TEST(A_LineNumber,ListPos(12,"1,2,12,4,4"))
TEST(A_LineNumber,ListPos( 4,"1,2,12,4,4"))
TEST(A_LineNumber,ListPos( 5,"1,2,12,4,4"))
}

IfNotEqual TestListReplace,, {
TEST(A_LineNumber,ListReplace(1,"",""))
TEST(A_LineNumber,ListReplace("","","abc"))
TEST(A_LineNumber,ListReplace("a","","abc"))
TEST(A_LineNumber,ListReplace("ac","","ab,ac"))
TEST(A_LineNumber,ListReplace("abc","","abc"))
TEST(A_LineNumber,ListReplace("ab","","ab,ab"))
TEST(A_LineNumber,ListReplace(2,"03","1,2,12,4,4"))
TEST(A_LineNumber,ListReplace(1,"","1,2,12,4,4"))
TEST(A_LineNumber,ListReplace(1,12,"1,2,12,4,4"))
TEST(A_LineNumber,ListReplace(4,"","1,2,12,4,4"))
TEST(A_LineNumber,ListReplace(4,55,"1,2,12,4,4"))
}

IfNotEqual TestListLen,, {
TEST(A_LineNumber,ListLen(""))
TEST(A_LineNumber,ListLen("abc"))
TEST(A_LineNumber,ListLen("ab,ac"))
TEST(A_LineNumber,ListLen("1,2,123,4,4"))
}

IfNotEqual TestListSplit,, {
TEST2(A_LineNumber,ListSplit(0,1,I,J))
TEST2(A_LineNumber,ListSplit(1,1,I,J))
TEST2(A_LineNumber,ListSplit(0,"1,2",I,J))
TEST2(A_LineNumber,ListSplit(1,"1,2",I,J))
TEST2(A_LineNumber,ListSplit(3,"1,2",I,J))
TEST2(A_LineNumber,ListSplit(1,"1,2,3",I,J))
TEST2(A_LineNumber,ListSplit(2,"1,02,3",I,J))
TEST2(A_LineNumber,ListSplit(3,"01,2,3",I,J))
TEST2(A_LineNumber,ListSplit(-1,"1,2,3",I,J))
TEST2(A_LineNumber,ListSplit(-2,"1,2,03",I,J))
TEST2(A_LineNumber,ListSplit(-4,"1,2,03",I,J))
}

IfNotEqual TestListPart,, {
TEST(A_LineNumber,ListPart(0,0,""))
TEST(A_LineNumber,ListPart(1,1,"1"))
TEST(A_LineNumber,ListPart(1,2,"1"))
TEST(A_LineNumber,ListPart(2,1,"1"))
TEST(A_LineNumber,ListPart(-1,1,"1"))
TEST(A_LineNumber,ListPart(1,-1,"1"))
TEST(A_LineNumber,ListPart(2,-1,"1,2"))
TEST(A_LineNumber,ListPart(1,2,"2,1"))
TEST(A_LineNumber,ListPart(1,3,"2,1,3"))
TEST(A_LineNumber,ListPart(2,6,"2,1,3,6,5,4"))
TEST(A_LineNumber,ListPart(-6,6,"2,1,3,6,5,4"))
TEST(A_LineNumber,ListPart(-6,-1,"2,1,3,6,5,4"))
TEST(A_LineNumber,ListPart(1,3,"2,1,3,6,5,4"))
}

IfNotEqual TestListRemove,, {
TEST(A_LineNumber,ListRemove(2,0,"1,2,3"))
TEST(A_LineNumber,ListRemove(2,0,"2"))
TEST(A_LineNumber,ListRemove(2,0,"2,2,2"))
TEST(A_LineNumber,ListRemove(2,0,"1,3"))
TEST(A_LineNumber,ListRemove(1,0,"1,3"))
TEST(A_LineNumber,ListRemove(3,0,"1,3"))
TEST(A_LineNumber,ListRemove(3,0,"01,30"))
TEST(A_LineNumber,ListRemove(3,1,"01,30"))
TEST(A_LineNumber,ListRemove(3,-1,"01,30"))
TEST(A_LineNumber,ListRemove(0,0,"01,30"))
TEST(A_LineNumber,ListRemove(0,1,"01,30"))
TEST(A_LineNumber,ListRemove(0,-1,"01,30"))
TEST(A_LineNumber,ListRemove(".tmp",-1,"1.exe,2.tmp,3.dat,4.tmp"))
}

IfNotEqual TestListKeep,, {
TEST(A_LineNumber,ListKeep(2,0,"1,2,3"))
TEST(A_LineNumber,ListKeep(2,0,"2"))
TEST(A_LineNumber,ListKeep(2,0,"2,2,2"))
TEST(A_LineNumber,ListKeep(2,0,"1,3"))
TEST(A_LineNumber,ListKeep(1,0,"1,3"))
TEST(A_LineNumber,ListKeep(3,0,"1,3"))
TEST(A_LineNumber,ListKeep(3,1,"1,3"))
TEST(A_LineNumber,ListKeep(3,-1,"1,3"))
TEST(A_LineNumber,ListKeep(3,0,"01,30"))
TEST(A_LineNumber,ListKeep(0,0,"01,30"))
TEST(A_LineNumber,ListKeep(3,1,"01,30"))
TEST(A_LineNumber,ListKeep(3,-1,"01,30"))
TEST(A_LineNumber,ListKeep(0,1,"01,30"))
TEST(A_LineNumber,ListKeep(0,-1,"01,30"))
TEST(A_LineNumber,ListKeep(".tmp",-1,"1.exe,2.tmp,3.dat,4.tmp"))
}

IfNotEqual TestListMerge,, {
TEST(A_LineNumber,ListMerge("",""))
TEST(A_LineNumber,ListMerge("","1"))
TEST(A_LineNumber,ListMerge("1",""))
TEST(A_LineNumber,ListMerge(0,"1,2"))
TEST(A_LineNumber,ListMerge(3,"2,1"))
TEST(A_LineNumber,ListMerge("2,0",1))
TEST(A_LineNumber,ListMerge("2,1",0))
TEST(A_LineNumber,ListMerge("2,1",3))
TEST(A_LineNumber,ListMerge("6,5,4","2,1,0"))
TEST(A_LineNumber,ListMerge("2,1,0","6,5,4"))
TEST(A_LineNumber,ListMerge("2,1,0","3,4,5"))
TEST(A_LineNumber,ListMerge("5,3,1","4,2,0"))
}

IfNotEqual TestListSort,, {
I = 06,5,a,3,2,01
TEST1(A_LineNumber,ListSort(I))
I = 1,02,003,4,5,06
TEST1(A_LineNumber,ListSort(I))
}

IFNotEqual Test_Sort,, {
TEST(A_LineNumber,_Sort(0,""))
TEST(A_LineNumber,_Sort(1,"1"))
TEST(A_LineNumber,_Sort(2,"1,2"))
TEST(A_LineNumber,_Sort(2,"2,1"))
TEST(A_LineNumber,_Sort(3,"2,1,3"))
TEST(A_LineNumber,_Sort(6,"5,1,3,2,6,4"))
TEST(A_LineNumber,_Sort(6,"5,6,3,2,1,4"))
TEST(A_LineNumber,_Sort(6,"1,2,3,4,5,6"))
TEST(A_LineNumber,_Sort(6,"1,2,03,4,5,6"))
TEST(A_LineNumber,_Sort(6,"06,5,4,3,2,01"))
TEST(A_LineNumber,_Sort(6,"0x06,0x5,0xa,3,2,01"))
TEST(A_LineNumber,_Sort(6,"1,2,03,4,5,6"))
}

IfNotEqual TestHash16,, {
TEST(A_LineNumber,Hash16("0"))
TEST(A_LineNumber,Hash16("00"))
TEST(A_LineNumber,Hash16("000"))
TEST(A_LineNumber,Hash16("1"))
TEST(A_LineNumber,Hash16("2"))
TEST(A_LineNumber,Hash16("3"))
}

IfNotEqual TestString2Hex,, {
TEST(A_LineNumber,String2Hex("0"))
TEST(A_LineNumber,String2Hex("00"))
TEST(A_LineNumber,String2Hex("000"))
TEST(A_LineNumber,String2Hex("1"))
TEST(A_LineNumber,String2Hex("2"))
TEST(A_LineNumber,String2Hex("abc"))
}

IfNotEqual TestHex2String,, {
TEST(A_LineNumber,Hex2String("X30"))
TEST(A_LineNumber,Hex2String("X3030"))
TEST(A_LineNumber,Hex2String("X31"))
TEST(A_LineNumber,Hex2String("X32"))
TEST(A_LineNumber,Hex2String("X33"))
TEST(A_LineNumber,Hex2String("X616263"))
}

IfNotEqual TestListUniq,, {
I = 1
TEST1(A_LineNumber,ListUniq(I))
I = 1,2
TEST1(A_LineNumber,ListUniq(I))
I = 1,1
TEST1(A_LineNumber,ListUniq(I))
I = 01,1
TEST1(A_LineNumber,ListUniq(I))
I = 1,2,1,3,2,4
TEST1(A_LineNumber,ListUniq(I))
I = 0,1,2,1,03,02,4
TEST1(A_LineNumber,ListUniq(I))
}