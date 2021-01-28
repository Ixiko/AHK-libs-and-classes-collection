/*
Name: String Things - Common String & Array Functions
Version 2.6 (Fri May 30, 2014)
Created: Sat March 02, 2013
Author: tidbit
Credit:
   AfterLemon  --- st_insert(), st_overwrite() bug fix. st_strip(), and more.
   Bon         --- word(), leftOf(), rightOf(), between() - These have been replaced
   faqbot      --- jumble()
   Lexikos     --- flip()
   MasterFocus --- Optimizing LineWrap and WordWrap.
   rbrtryn     --- group()
   Rseding91   --- Optimizing LineWrap and WordWrap.
   Verdlin     --- st_concat(), A couple nifty forum-only functions.
   
Description:
   A compilation of commonly needed function for strings and arrays.

No functions rely on eachother. You may simply copy/paste the ones you want or need.
.-==================================================================-.
|Function                                                            |
|====================================================================|
| st_count(string [, searchFor])                                     |
| st_insert(insert, into [, pos])                                    |
| st_delete(string [, start, length])                                |
| st_overwrite(overwrite, into [, pos])                              |
| st_format(string, param1, param2, param3, ...)                     |
| st_word(string [, wordNu, Delim, temp])                            |
| st_subString(string, searchFor [, direction, instance, searchFor2])|
| st_jumble(Text[, Weight, Delim , Omit])                            |
| st_concat(delim, as*)                                              |
|                                                                    |
| st_lineWrap(string [, column, indent])                             |
| st_wordWrap(string [, column, indent])                             |
| st_readLine(string, line [, delim, exclude])                       |
| st_deleteLine(string, line [, delim, exclude])                     |
| st_insertLine(insert, into, line [, delim, exclude])               |
|                                                                    |
| st_flip(string)                                                    |
| st_setCase(string [, case])                                        |
| st_contains(mixed [, lookFor*])                                    |
| st_removeDuplicates(string [, delim])                              |
| st_pad(string [, left, right, LCount, RCount])                     |
|                                                                    |
| st_group(string, size, separator [, perLine, startFromFront])      |
| st_columnize(data [, delim, justify, pad, colsep])                 |
| st_center(text [, fill, symFIll, delim, exclude])                  |
| st_right(text [, fill, delim, exclude])                            |
|----------------------------------------------------------------    |
|array stuff:                                                        |
|   st_split(string [, delim, exclude])                              |
|   st_glue(array [, delim])                                         |
|   st_printArr(array [, depth])                                     |
|   st_countArr(array [, depth])                                     |
|   st_randomArr(array [, min, max, timeout])                        |
'-==================================================================-'
*/
; test

/*
Insert
   Insert text into another string at the specified position.
   All text after the inserted text is shifted over.

   insert = Text to insert.
   into   = The text to insert into.
   pos    = The position where to begin inserting. 0 May be used to insert
            at the very end, -1 will offset 1 from the end, and so on.
            *---------------------------------*
            ! | is where it starts inserting. !
            ! positive: [|1|2|3|4|5|6|7]      !
            ! string:   [|a|b|c|d|e|f|g]      !
            !                                 !
            ! negative: [|7|6|5|4|3|2|1|0]    !
            ! string:   [|a|b|c|d|e|f|g| ]    !
            *---------------------------------*

example: st_insert("aaa", "cccbbb", 1)
output:  aaabbbccc
*/
ST_Insert(insert,input,pos=1)
{
	Length := StrLen(input)
	((pos > 0) ? (pos2 := pos - 1) : (((pos = 0) ? (pos2 := StrLen(input),Length := 0) : (pos2 := pos))))
	output := SubStr(input, 1, pos2) . insert . SubStr(input, pos, Length)
	If (StrLen(output) > StrLen(input) + StrLen(insert))
		((Abs(pos) <= StrLen(input)/2) ? (output := SubStr(output, 1, pos2 - 1) . SubStr(output, pos + 1, StrLen(input))) : (output := SubStr(output, 1, pos2 - StrLen(insert) - 2) . SubStr(output, pos - StrLen(insert), StrLen(input))))
	return, output
}


/*
Overwrite
   add text at a given position, any text that comes into contact is replaced
   with the inserted text.

   overwrite = Text to insert.
   into      = The text to insert into.
   pos       = The position where to begin overwriting. 0 May be used to overwrite
               at the very end, -1 will offset 1 from the end, and so on.
               *-----------------------------------*
               ! | is where it starts overwriting. !
               ! positive: [|1|2|3|4|5|6|7]        !
               ! string:   [|a|b|c|d|e|f|g]        !
               !                                   !
               ! negative: [|7|6|5|4|3|2|1|0]      !
               ! string:   [|a|b|c|d|e|f|g| ]      !
               *-----------------------------------*

example: st_overwrite("zzz", "aaabbbccc", 4)
output:  aaazzzccc
*/
st_overwrite(overwrite, into, pos=1)
{
   If (abs(pos) > StrLen(into))
      return 0
   else If (pos>0)
      return substr(into, 1, pos-1) . overwrite . substr(into, pos+StrLen(overwrite))
   else If (pos<0)
      return SubStr(into, 1, pos) . overwrite . SubStr(into " ",(abs(pos) > StrLen(overwrite) ? pos+StrLen(overwrite) : 0),abs(pos+StrLen(overwrite)))
   else If (pos=0)
      return into . overwrite
}


/*
Delete
   Delete a range of characters in the specified string.

   string = Text to delete from.
   start  = The position where to start deleting.
   length = How many characters to delete.
            *--------------------------------*
            ! | is where it starts deleting. !
            ! positive: [|1|2|3|4|5|6|7]     !
            ! string:   [|a|b|c|d|e|f|g]     !
            !                                !
            ! negative: [|7|6|5|4|3|2|1|0]   !
            ! string:   [|a|b|c|d|e|f|g| ]   !
            *--------------------------------*

example: st_delete("aaabbbccc", 4, 3)
output:  aaaccc
*/
st_delete(string, start=1, length=1)
{
   if (abs(start+length) > StrLen(string))
      return 0
   if (start>0)
      return substr(string, 1, start-1) . substr(string, start + length)
   else if (start<=0)
      return substr(string " ", 1, start-length-1) SubStr(string " ", ((start<0) ? start : 0), -1)
}


/*
Format
   Formats a string by inserting text at the special searchFor charact (&).

   & is where text will be inserted. any consecutive &'s (such as && and &&&)
   are treated as an escape. So, && an &&& are treated as 1 literal &. (I'm trying to fix this).

   For each single & specified, 1 parameter will be consumed. If there are not
   enough parameters fo fill in all the &'s, the remaining &'s will be filled
   with blanks.

   string = The text with the format searchFors (&) (and && for a literal &).
   params* = Any number of parameters (separated by a comma (,). An Array or Object
            may be used aswell.

example: st_format("aaa & bbb && ccc & ddd", 111, 222)
output:  aaa 111 bbb & ccc 222 ddd
*/
st_format(string, params*)
{
   while (pos:=RegExMatch(string, "(.*?)(?<!&)&(?!&)", match, ((pos) ? pos : 1)+StrLen(match)))
   {
      new.=match1 params[a_index]
      ; we need to get any potential text at the end of the 'format'. so we need to backup the Pos variable.
      if (pos!=0)
         pos2:=pos+StrLen(match1)+1
   }
   return RegExReplace(new, "(&)+", "$1") substr(string, pos2)
}


/*
Pad
   Add character(s) to either side of the input string.
   
   string = What text you want to add stuff to either side.
   left   = The text you want to add to the left side.
   right  = The text you want to add to the right side.
   Lcount = How many times do you want to repeat adding to the left side.
   Rcount = How many times do you want to repeat adding to the right side.

example: st_pad("aaa", "+", "-^", 5)
output: +++++aaa-^
*/
st_pad(string, left="0", right="", LCount=1, RCount=1)
{
   if (LCount>0)
   {
      if (LCount>1)
         loop, %LCount%
            Lout.=left
      Else
         Lout:=left
   }
   if (RCount>0)
   {
      if (RCount>1)
         loop, %RCount%
            Rout.=right
      Else
         Rout.=right
   }
   Return Lout string Rout
}


/*
Word (Made by, Bon. Thanks!)
   string   = String to get from
   wordNum  = The Word to get
   Delim    = Delimiter (Can also be a Word, i.e. "END")
   temp     = Default: ¢. Since Loop,parse doesn't allow a string, only a
              single character, we need to replace it with just 1 character.

Returns any "word" in string ("word" being defined as anything between delimiters)
If wordNum is negative, count from back

example: st_Word("c:\abc\def.x", 1, "\")
outputs: c:

example: st_Word("c:\abc\def.x", -1, "\")
outputs: def.x

example: st_Word("c:\abc\def.x", -2, "\")
outputs: abc
*/
st_word(string, wordNum=1, Delim=" ", temp="¢")
{
   ;Make sure delim is only one character
   if (StrLen(delim)>1)
      StringReplace, string, string, %Delim%, %temp%, All
   else
      temp:=Delim
      
   If (wordNum < 0)
      StringReplace, string, string, %temp%, %temp%, UseErrorLevel ;Count # occurences
   MaxInd := ++ErrorLevel

   Loop, Parse, string, %temp%
      If ((A_Index = wordNum) || (A_Index = MaxInd + wordNum + 1))
         Return, A_LoopField
}


/*
st_subString (Made by, AfterLemon. Thanks!)
   string     = String to get from
   searchFor  = What to look for
   direction  = Options: L, R or B.
                [L]eft: Get all the text from the left of searchFor.
                [R]ight: Get all the text from the right of searchFor.
                [B]etween: Get everything between searchFor and searchFor2.
   instance   = If more than 1 searchFor exists, which one should the function use?
   searchFor2 = The ending match for direction "B".

Returns:
   A string based on the criteria passed to it.
   
Example: st_subString("111|222|333.444|555|444.777|888|999", "|","L",4)
Outputs:  111|222|333.444|555
*/
st_subString(string,search1,direction:="R",match:=1,search2:="",CaseSensitive:="")
{ ;Credit @ AfterLemon
	s:=string,A=search1,d=direction,m=match,B=Search2,V=CaseSensitive,c=InStr(s,A,V),(d="B"&&B=""?B:=A:"")
	StringCaseSense,% (V?"On":"Off")
	StringReplace,s,s,%A%,%A%,UseErrorLevel
		E:=(ErrorLevel<m?1:0)
	If !E{
	While(--m?c:=InStr(s,A,V,c+1):""){
	}R:=SubStr(s,1,--c),(d="R"?R:=SubStr(s,StrLen(R)+StrLen(A)+1):(d="B"?(InStr(s,B,V,c+1)>0?R:=SubStr(s,c+StrLen(A)+1,InStr(s,B,V,c+StrLen(A)+1)-c-StrLen(A)-StrLen(B)):R:=SubStr(s,StrLen(R)+StrLen(A)+1)):R))
}return (E?"":R)
}


/*
Jumble
   randomly re-order text, either lines (default), words or characters

   Text   = input text
   Weight = Number of "items" of each element (lines, words, characters)
            example: weight = 3 keep three consecutive lines, words, characters together
   Delim  = Delimiter, default it `n (new line) so it works on lines
            If you pass on a space (" " or A_Space) it will jumble words,
            If you keep it empty ("") it will jumble all characters.
   Omit   = Character to omit

example: st_jumble("Jumble made by faqbot and others", 1, " ")
outputs: nd oJumtherot able  by smadefaqb
*/
st_jumble(Text, Weight=1, Delim = "`n", Omit = "`r")
{
   If (StrLen(Text) <= 1) ; added safety check ...
      Return Text
   Text0:=1
   Loop, Parse, Text, %Delim%, %Omit%
   {
      If (Mod(A_Index,Weight) = 1 || Weight=1)
         Text0++
      Text%Text0% .= A_LoopField Delim
   }
   Loop, % Text0
   NewOrder .= A_Index "|"
   NewOrder:=Trim(NewOrder,"|")
   OldOrder:=NewOrder
   Loop
   {
      Sort, NewOrder, Random D|
      If (NewOrder != OldOrder)
         Break
   }
   
   Loop, parse, NewOrder, |
   Output .= Text%A_LoopField%
   Return Trim(Output,Delim)    
}


/*
Concat
	Join a list of words, sentences, whatever together to form a string separated
	by the deleter if choice.

	delim = The character/string that separates all your items.
	as*   = A list of items separated by a comma.

example: st_concat("|", 111, 222, 333, "abc")
outputs: 111|222|333|abc
*/
st_concat(delim, as*)
{
	for k, v in as
		s .= v . delim
	return subStr(s,1,-strLen(delim))
}


/*
insertLine
   Insert a line of text at the specified line number.
   The line you specify is pushed down 1 and your text is inserted at its
   position. A "line" can be determined by the delimiter parameter. Not
   necessarily just a `r or `n. But perhaps you want a | as your "line".

   insert  = Text you want to insert.
   into    = The text you want to insert into.
   line    = What line number to insert at. Use a 0 or negative to start
             inserting from the end.
   delim   = The string which defines a "line".
   exclude = The text you want to ignore when defining a line.

example: st_insertLine("bbb", "aaa|ccc|ddd", 2, "|")
output:  aaa|bbb|ccc|ddd
*/
st_insertLine(insert, into, line, delim="`n", exclude="`r")
{
   StringReplace, into, into, %delim%, %delim%, UseErrorLevel
   count:=errorlevel+1

   ; Create any lines that don't exist yet, if the Line is less than the total line count.
   if (line<0 && abs(line)>count)
   {
      loop, % abs(line)-count
         into:=delim into
      line:=1
   }
   if (line==0)
      line:=Count+1
   if (line<0)
      line:=count+line+1
   ; Create any lines that don't exist yet. Otherwise the Insert doesn't work.
   if (count<line)
      loop, % line-count
         into.=delim

   loop, parse, into, %delim%, %exclude%
      new.=((a_index==line) ? insert . delim . A_LoopField . delim : A_LoopField . delim)

   return rtrim(new, delim)
}


/*
DeleteLine
   Delete a line of text at the specified line number.
   The line you specify is deleted and all lines below it are shifted up.
   A "line" can be determined by the delimiter parameter. Not necessarily
   just a `r or `n. But perhaps you want a | as your "line".

   string  = Text you want to delete the line from.
   line    = What line to delete. You may use 0 for the last line and a negative
             an offset from the last. -1 would be the second to the last.
   delim   = The string which defines a "line".
   exclude = The text you want to ignore when defining a line.

example: st_deleteLine("aaa|bbb|777|ccc", 3, "|")
output:  aaa|bbb|ccc
*/
st_deleteLine(string, line, delim="`n", exclude="`r")
{
   ; checks to see if we are trying to delete a non-existing line.
   StringReplace, string, string, %delim%, %delim%, UseErrorLevel
   count:=ErrorLevel+1
   if (abs(line)>=Count)
      Return 0
   if (line<=0)
      line:=count+line

   loop, parse, string, %delim%, %exclude%
      new.=((a_index==line) ? Continue : A_LoopField . delim)

   return trim(new, delim)
}


/*
ReadLine
   Read the content of the specified line in a string. A "line" can be
   determined by the delimiter parameter. Not necessarily just a `r or `n.
   But perhaps you want a | as your "line".

   string  = The text you want to read from.
   line    = What line to read*.
   delim   = The string which defines a "line".
   exclude = The text you want to ignore when defining a line.

   * For the Line parameter, you may specify the following:
      "L" = The last line.
      "R" = A random line.
      Otherwise specify a number to get that line.
      You may specify a negative number to get the line starting from
      the end. 0 is the same as "L", the last. -1 would be the second to
      the last, and so on.

example: st_readLine("aaa|bbb|ccc|ddd|eee|fff", 4, "|")
output:  ddd
*/
st_readLine(string, line, delim="`n", exclude="`r")
{
   StringReplace, string, string, %delim%, %delim%, UseErrorLevel
   count:=ErrorLevel+1

   if (abs(line)>Count && (line!="L" || line!="R"))
      Return 0
   if (Line="R")
      Random, Rand, 1, %count%
   if (line<=0)
      line:=count+line

   loop, parse, String, %delim%, %exclude%
   {
      out:=(Line="R" && A_Index==Rand)  ? A_LoopField
         : (Line="L" && A_Index==count) ? A_LoopField
         : (A_Index==Line)              ? A_LoopField
         : -1
      if (out!=-1) ; Something was found so stop searching.
         Break
   }
   Return out
}


/*
Count
   Counts the number of times a tolken exists in the specified string.

   string    = The string which contains the content you want to count.
   searchFor = What you want to search for and count.

   note: If you're counting lines, you may need to add 1 to the results.

example: st_count("aaa`nbbb`nccc`nddd", "`n")+1 ; add one to count the last line
output:  4
*/
st_count(string, searchFor="`n")
{
   StringReplace, string, string, %searchFor%, %searchFor%, UseErrorLevel
   return ErrorLevel
}


/*
LineWrap
   Wrap the specified text so each line is never more than a specified length.
   
   This function does not care if it is in the middle of a word, it will
   split up any word if it exceedes the limit.
   
   string     = What text you want to wrap.
   column     = The column where you want to split. Each line will never be longer than this.
   indentChar = You may optionally indent any lines that get broken up. Specify
                What character or string you would like to define as the indent.
example: st_lineWrap("aaabbbcccdddeeefffggghhhiiijjjkkklllmmmnnnoooppp", 20, "---")
output:
aaabbbcccdddeeefffgg
---ghhhiiijjjkkklllm
---mmnnnoooppp
*/
st_lineWrap(string, column= 56, indentChar= "")
{
    CharLength := StrLen(indentChar)
    , columnSpan := column - CharLength
    , Ptr := A_PtrSize ? "Ptr" : "UInt"
    , NewLineType := A_IsUnicode ? "UShort" : "UChar"
    , UnicodeModifier := A_IsUnicode ? 2 : 1
    , VarSetCapacity(out, (StrLen(string) + (Ceil(StrLen(string) / columnSpan) * (column + CharLength + 1))) * UnicodeModifier, 0)
    , A := &out
     
    loop, parse, string, `n, `r
        If ((FieldLength := StrLen(ALoopField := A_LoopField)) > column)
        {
            DllCall("RtlMoveMemory", Ptr, A, Ptr, &ALoopField, "UInt", column * UnicodeModifier)
            , A += column * UnicodeModifier
            , NumPut(10, A+0, 0, NewLineType)
            , A += UnicodeModifier
            , Pos := column
             
            While (Pos < FieldLength)
            {
                If CharLength
                    DllCall("RtlMoveMemory", Ptr, A, Ptr, &indentChar, "UInt", CharLength * UnicodeModifier)
                    , A += CharLength * UnicodeModifier
                 
                If (Pos + columnSpan > FieldLength)
                    DllCall("RtlMoveMemory", Ptr, A, Ptr, &ALoopField + (Pos * UnicodeModifier), "UInt", (FieldLength - Pos) * UnicodeModifier)
                    , A += (FieldLength - Pos) * UnicodeModifier
                    , Pos += FieldLength - Pos
                Else
                    DllCall("RtlMoveMemory", Ptr, A, Ptr, &ALoopField + (Pos * UnicodeModifier), "UInt", columnSpan * UnicodeModifier)
                    , A += columnSpan * UnicodeModifier
                    , Pos += columnSpan
                 
                NumPut(10, A+0, 0, NewLineType)
                , A += UnicodeModifier
            }
        } Else
            DllCall("RtlMoveMemory", Ptr, A, Ptr, &ALoopField, "UInt", FieldLength * UnicodeModifier)
            , A += FieldLength * UnicodeModifier
            , NumPut(10, A+0, 0, NewLineType)
            , A += UnicodeModifier
     
    VarSetCapacity(out, -1)
    Return SubStr(out,1, -1)
}


/*
WordWrap
   Wrap the specified text so each line is never more than a specified length.
  
   Unlike st_lineWrap(), this function tries to take into account for words (separated by a space).
   
   string     = What text you want to wrap.
   column     = The column where you want to split. Each line will never be longer than this.
   indentChar = You may optionally indent any lines that get broken up. Specify
                What character or string you would like to define as the indent.
                
example: st_wordWrap("Apples are a round fruit, usually red.", 20, "---")
output:
Apples are a round
---fruit, usually
---red.
*/
st_wordWrap(string, column=56, indentChar="")
{
    indentLength := StrLen(indentChar)
     
    Loop, Parse, string, `n, `r
    {
        If (StrLen(A_LoopField) > column)
        {
            pos := 1
            Loop, Parse, A_LoopField, %A_Space%
                If (pos + (loopLength := StrLen(A_LoopField)) <= column)
                    out .= (A_Index = 1 ? "" : " ") A_LoopField
                    , pos += loopLength + 1
                Else
                    pos := loopLength + 1 + indentLength
                    , out .= "`n" indentChar A_LoopField
             
            out .= "`n"
        } Else
            out .= A_LoopField "`n"
    }
     
    Return SubStr(out, 1, -1)
}


/*
SetCase
   Set the case (Such as UPPERCASE or lowercase) for the specified text.

   string = The text you want to modify.
   case   = The case you would like the specified text to be.

   The following types of Case are aloud:
   .-===============================================-.
   |    Use any cell as a name. CaSE-InSEnsitIVe.    |
   |----|-----|---------|------------|---------------|
   | 1  |  U  |   UP    |   UPPER    |   UPPERCASE   |
   |----|-----|---------|------------|---------------|
   | 2  |  l  |   low   |   lower    |   lowercase   |
   |----|-----|---------|------------|---------------|
   | 3  |  T  |  Title  |  TitleCase |               |
   |----|-----|---------|------------|---------------|
   | 4  |  S  |   Sen   |  Sentence  |  Sentencecase |
   |----|-----|---------|------------|---------------|
   | 5  |  i  |   iNV   |   iNVERT   |   iNVERTCASE  |
   |----|-----|---------|------------|---------------|
   | 6  |  r  |  rANd   |   rAnDOm   |   RAndoMcASE  |
   '-===============================================-'

example: st_setCase("ABCDEFGH", "l")
output:  abcdefgh
*/
st_setCase(string, case="s")
{
   if (case=1 || case="u" || case="up" || case="upper" || case="uppercase")
      StringUpper, new, string
   else if (case=2 || case="l" || case="low" || case="lower" || case="lowercase")
      StringLower, new, string
   else if (case=3 || case="t" || case="title" || case="titlecase")
   {
      StringLower, string, string, T
      string:=RegExReplace(string, "i)(with|amid|atop|from|into|onto|over|past|plus|than|till|upon|are|via|and|but|for|nor|off|out|per|the|\b[a-z]{1,2}\b)", "$L1")
      new:=RegExReplace(string, "^(\w)|(\bi\b)|(\w)(\w+)$", "$U1$U2$U3$4")
   }
   else if (case=4 || case="s" || case="sen" || case="sentence" || case="sentencecase")
   {
      StringLower string, string
      new:=RegExReplace(string, "([.?\s!(]\s\w)|^(\b\w)|(\.\s*[(]\w)|(\bi\b)", "$U0")
   }
   else if (case=5 || case="i" || case="inv" || case="invert" || case="invertcase")
   {
      Loop, parse, string
      {
         if A_LoopField is upper
            new.= Chr(Asc(A_LoopField) + 32)
         else if A_LoopField is lower
            new.= Chr(Asc(A_LoopField) - 32)
         else
            new.= A_LoopField
      }
   }
   else if (case=6 || case="r" || case="rand" || case="random" || case="randomcase")
   {
      loop, parse, string
      {
         random, rcase, 0, 1
         if (rcase==0)
            StringUpper, out, A_LoopField
         Else
            StringLower, out, A_LoopField
         new.=out
      }
      return new
   }
   Else
      return -1
   return new
}


/*
; Thanks Lexikos!
Flip
   flip the string so it is in reverse.

   string = The text you want to flip/reverse.

example: st_flip("aaabbbccc")
output:  cccbbbaaa
*/
st_flip(string)
{
   VarSetCapacity(new, n:=StrLen(string))
   Loop %n%
      new .= SubStr(string, n--, 1)
   return new
}


/*
RemoveDuplicates
   Remove any and all consecutive lines. A "line" can be determined by
   the delimiter parameter. Not necessarily just a `r or `n. But perhaps
   you want a | as your "line".

   string = The text or symbols you want to search for and remove.
   delim  = The string which defines a "line".

example: st_removeDuplicates("aaa|bbb|||ccc||ddd", "|")
output:  aaa|bbb|ccc|ddd
*/
st_removeDuplicates(string, delim="`n")
{
   delim:=RegExReplace(delim, "([\\.*?+\[\{|\()^$])", "\$1")
   Return RegExReplace(string, "(" delim ")+", "$1")
}


/*
contains
   Search a string or array to see if it contains a certain value from a given list.

   mixed   = The text or array* you want to search.
   lookFor = The list of stuff to search for, separated by a comma. You
             may use an array as an input aswell.
             
   * When using an array/object in the string parameter, it only search the
   first level of the array. It will not go into sub-levels.
             
   Returns:
      1 on success
      0 on failure

example: st_contains("aaa|bbb|ccc|ddd", "deer", "cat", "bbb", "ball")
output:  1
*/
st_contains(mixed, lookFor*)
{
   if (IsObject(mixed))
   {
      for key1,input in mixed
         for key,search in lookFor
            if (InStr(input, search))
               Return 1
   }
   Else
   {
      for key,search in lookFor
         if (InStr(mixed, search))
            Return 1
   }
   Return 0
}


/*
Group
   Add a separator at a set interval
   
   string         = The text where separators will be inserted
   size           = How big each group should be. The distance between each separator
   separator      = The string/symbol you want to separate each group by
   perLine        = "Start over" on each line (`n)?
   startFromFront = Default is 0 (no). If 1, The group will start from the left side.
                    Starting from the back allows you to group numbers easily. See example.

example: st_group(28753782365, 3, ",")
output: 28,753,782,365
*/
st_group(string, size, separator, perLine=1, startFromFront=0)
{
   if (startFromFront==1)
      needle:=".{" size "}"
   Else
      needle:=".+?(?=(.{" size "})+$)"

   if (perLine=0)
      return RegExReplace(string, needle, "$0" separator)
   Else
   {
      loop, parse, string, `n, `r
         out.= RegExReplace(A_LoopField, needle, "$0" separator) "`n"
      return out
   }
}



/*
st_columnize
   Take a set of data with a common delimiter (csv, tab, |, "a string", anything) and
   nicely organize it into a column structure, like an EXCEL spreadsheet.

	data    = [String] Your input data to be organized.
	delim   = [Optional] What separates each set of data? It can be a string or it can
	          be the word "csv" to treat it as a CSV document.
	justify = [Optional] Specify 1 to align the data to the left of the column, 2 for
	          aligning to the right or 3 to align centered. You may enter a 
	          string such as "2|1|3" to adjust columns specifically. Columns are 
	          separeted by |.
	pad     = [Optional] The string that should fill in shorter column items to match
	          the longest item.
	colsep  = [Optional] What string should go between every column?

example: 
	data=
	(
	"Date","Pupil","Grade"
	----,-----,-----
	"25 May","Bloggs, Fred","C"
	"25 May","Doe, Jane","B"
	"15 July","Bloggs, Fred","A"
	"15 April","Muniz, Alvin ""Hank""","A"
	)
	output:=Columnize(data, "csv", 2)  

output:
	    Date |               Pupil | Grade
	    ---- |               ----- | -----
	  25 May |        Bloggs, Fred |     C
	  25 May |           Doe, Jane |     B
	 15 July |        Bloggs, Fred |     A
	15 April | Muniz, Alvin "Hank" |     A
*/
st_columnize(data, delim="csv", justify=1, pad=" ", colsep=" | ")
{		
	widths:=[]
	dataArr:=[]
	
	if (instr(justify, "|"))
		colMode:=strsplit(justify, "|")
	else
		colMode:=justify
	; make the arrays and get the total rows and columns
	loop, parse, data, `n, `r
	{
		if (A_LoopField="")
			continue
		row:=a_index
		
		if (delim="csv")
		{
			loop, parse, A_LoopField, csv
			{
				dataArr[row, a_index]:=A_LoopField
				if (dataArr.maxindex()>maxr)
					maxr:=dataArr.maxindex()
				if (dataArr[a_index].maxindex()>maxc)
					maxc:=dataArr[a_index].maxindex()
			}
		}
		else
		{
			dataArr[a_index]:=strsplit(A_LoopField, delim)
			if (dataArr.maxindex()>maxr)
				maxr:=dataArr.maxindex()
			if (dataArr[a_index].maxindex()>maxc)
				maxc:=dataArr[a_index].maxindex()
		}
	}
	; get the longest item in each column and store its length
	loop, %maxc%
	{
		col:=a_index
		loop, %maxr%
			if (strLen(dataArr[a_index, col])>widths[col])
				widths[col]:=strLen(dataArr[a_index, col])
	}
	; the main goodies.
	loop, %maxr%
	{
		row:=a_index
		loop, %maxc%
		{
			col:=a_index
			stuff:=dataArr[row,col]
			len:=strlen(stuff)
			difference:=abs(strlen(stuff)-widths[col])

			; generate a repeating string about the length of the longest item
			; in the column.
			loop, % ceil(widths[col]/((strlen(pad)<1) ? 1 : strlen(pad)))
    			padSymbol.=pad

			if (isObject(colMode))
				justify:=colMode[col]
			; justify everything correctly.
			; 3 = center, 2= right, 1=left.
			if (strlen(stuff)<widths[col])
			{
				if (justify=3)
					stuff:=SubStr(padSymbol, 1, floor(difference/2)) . stuff
					. SubStr(padSymbol, 1, ceil(difference/2))
				else
				{
					if (justify=2)
						stuff:=SubStr(padSymbol, 1, difference) stuff
					else ; left justify by default.
						stuff:= stuff SubStr(padSymbol, 1, difference) 
				}
			}
			out.=stuff ((col!=maxc) ? colsep : "")
		}
		out.="`r`n"
	}
	stringTrimRight, out, out, 2 ; remove the last blank newline
	return out
}


/*
Center
   Centers a block of text to the longest item in the string.

   text    = The text you would like to center.
   fill    = A single character to use as the padding to center text.
   symFIll = 0: Just fill in the left half. 1: Fill in both sides.
   delim   = The string which defines a "line".
   exclude = The text you want to ignore when defining a line.

  
example: st_center("aaa`na`naaaaaaaa")
output:
  aaa
   a
aaaaaaaa
*/
st_center(text, fill=" ", symFIll=0, delim= "`n", exclude="`r")
{
	fill:=SubStr(fill,1,1)
	loop, parse, text, %delim%, %exclude%
		if (StrLen(A_LoopField)>longest)
			longest:=StrLen(A_LoopField)
	loop, parse, text, %delim%, %exclude%
	{
		filled:=""		
		loop, % floor((longest-StrLen(A_LoopField))/2)
			filled.=fill
		new.= filled A_LoopField ((symFIll=1) ? filled : "") "`n"
	}
	return rtrim(new,"`r`n")
}


/*
right
   Align a block of text to the right side.

   text    = The text you would like to right-justify.
   fill    = A single character to use as to push the text to the right.
   delim   = The string which defines a "line".
   exclude = The text you want to ignore when defining a line.

example: st_center("aaa`na`naaaaaaaa")
output:
     aaa
       a
aaaaaaaa
*/
st_right(text, fill=" ", delim= "`n", exclude="`r")
{
	fill:=SubStr(fill,1,1)
	loop, parse, text, %delim%, %exclude%
		if (StrLen(A_LoopField)>longest)
			longest:=StrLen(A_LoopField)
	loop, parse, text, %delim%, %exclude%
	{
		filled:=""
		loop, % abs(longest-StrLen(A_LoopField))
			filled.=fill
		new.= filled A_LoopField "`n"
	}
	return rtrim(new,"`r`n")
}


; -------------------
; --- Array stuff ---
; -------------------

/*
Split
   Split a string into an array. "Split" one item into many items.

   string  = The text you want to split into pieces.
   delim   = The character(s) that define where to split.
   exclude = The character(s) you want to ignore when splitting.

example: st_split("aaa|bbb|ccc")
output:  array("aaa", "bbb", "ccc")
*/
st_split(string, delim="`n", exclude="`r")
{
   arr:=[]
   loop, parse, string, %delim%, %exclude%
      arr.insert(A_LoopField)
   return arr
}


/*
Glue
   Take an array and turn it into a string. "Glue" many items into one item.

   array = An array that will be turned into a string.
   delim = This is what separates each item in the newly formed string.

example: st_glue(arr, "|") ; where arr is an array containing: ["aaa", "bbb", "ccc"]
output:  aaa|bbb|ccc
*/
st_glue(array, delim="`n")
{
   for k,v in array
      new.=v delim
   return trim(new, delim)
}


/*
; inspired by Lexikos ExploreObj()
PrintArr
   Prints the layout of an array (in text form) so that you can easily
   see the layout of it.

   array = The input array. Don't add the []'s.
   depth = How deep should we go if there are arrays within arrays?
   * indentLevel should not be touched as it's hard-coded in! DO NOT TOUCH.

example: st_printArr([["aaa","bbb","ccc"],[111,222,333]])
output:
[1]
    [1] ==> aaa
    [2] ==> bbb
    [3] ==> ccc

[2]
    [1] ==> 111
    [2] ==> 222
    [3] ==> 333
*/
st_printArr(array, depth=5, indentLevel="")
{
   for k,v in Array
   {
      list.= indentLevel "[" k "]"
      if (IsObject(v) && depth>1)
         list.="`n" st_printArr(v, depth-1, indentLevel . "    ")
      Else
         list.=" => " v
      list.="`n"
   }
   return rtrim(list)
}

/*
; this version by AfterLemon is shorter and better. It fixes some bugs. 
; It also looks nicer. However, I keep both versions available since it's quite
; hard to read :D
st_printArr(array,depth:=10,indentLevel:="     ")
{	static parent,pArr,depthP=depth
	For k,v in (Array,(!IsObject(pArr)?pArr:=[]:""))
	{	Loop,% ((d2=depth&&dP2=depthP)?0:(depth-depthP+1,d2:=depth))
			parent:=SubStr(a:=SubStr(parent,1,InStr(parent,",",0,0)-1),1,InStr(a,",",0,0)),dP2:=depthP++
		k:=RegExReplace(k,","),list.=(indentLevel "arr[" pArr[depth]:=parent (k&1=""?"""" k """":k) "]"),((IsObject(v)&&depth>1)?(parent.=k ",",list.="`n" st_printArr(v,(depthP:=depth)-1,indentLevel "    ")):list.=" = " v),list.="`n"
	}return RTrim(list,"`n")
}
*/

/*
countArr
   counts all the items in an array, up to the specified depth.

   array = The input array. Don't add the []'s.
   depth = How deep should we go if there are arrays within arrays?
   * count should not be touched as it's hard-coded in! DO NOT TOUCH.

example: st_countArr([["aaa","bbb","ccc"],[111,222,333]])
output: 8
*/
st_countArr(array, depth=5, count=0)
{
   for k,v in Array
   {
      if (IsObject(v) && depth>1)
         count:=st_countArr(v, depth-1, count)
      count+=1
   }
   return count
}


/*
RandomArr
   Returns a random value from an array.
   
   array   = The array object you want to pick something from. Don't include the []'s.
   min     = The optional minimum index value to search in.
   max     = The optional maximum index to search in. If not specified, it'll
             search the entire array (only the current level).
   timeout = This parameter is to prevent an infinite loop. Specify the max time in MS.
example: st_randomArr(["aaa", "bbb", "ccc", "ddd"])
output: ccc
*/
st_randomArr(array, min=0, max=0, timeout=3000)
{
   start:=A_TickCount
   while (!array.HasKey(random))
   {
      if (min<=0)
         min:=1
      if (max<=0)
         max:=array.MaxIndex()
      Random, random, %min%, %max%
      if (A_TickCount-start>timeout)
         return "Timeout" A_TickCount-start
   }
   Return array[random]
}