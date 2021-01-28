; Written by TheGood - http://www.autohotkey.com/board/topic/35990-string-matching-using-trigrams/

MatchItemFromList(iPtr, iCount, sItem) {
    
    /*
    ;iPtr is a pointer to the list of string pointers
    ;Here is an example on how to use it
    ;Prepare the list of pointers
    VarSetCapacity(ptr, iCount * 4, 0) ;iCount = the number of items in the list
    ;Add the string pointers to the list
    i := &ptr
    Loop %iCount%
        i := NumPut(&sList%A_Index%, i+0)
    ;Call function
    MatchItemFromList(&ptr, iCount, sItem)
    */
    
    ;Get length
    iLength := StrLen(sItem)
    iTrigrams := iLength - 2
    
    ;Retrieve all the strings
    Loop %iCount%
        sList%A_Index% := DllCall("MulDiv", int, NumGet(iPtr+0, (A_Index - 1) * 4), int, 1, int, 1, str)
    
    ;Check for a clean match first
    Loop %iCount%
        If (sList%A_Index% = sItem)
            Return (100 << 16) + A_Index
    
    ;CREATE ARRAY OF TRIGRAMS FOR sItem
    If (iLength < 3)
        Return 0    ;Invalid item
    Else {    ;Get trigram count
        Loop %iTrigrams% {
            
            ;Check if the trigram we're about to extract is unique
            i := InStr(sItem, SubStr(sItem, A_Index, 3), False, 1)
            If i And (i < A_Index) {
                sItem_%i% += 1 ;Not unique. Add count to original
                sItem_%A_Index% := 0 ;Discard current index
            } Else sItem_%A_Index% := InStrCount(sItem, SubStr(sItem, A_Index, 3))
        }
    }
    
    ;COMPARE TRIGRAMS
    Loop %iCount% {
        i := A_Index
        If (StrLen(sList%i%) < 3)
            Return 0    ;Invalid item
        Else {
            Loop %iTrigrams% ;Get trigram count
                If sItem_%A_Index%
                    sList%i%_Diff += Abs(InStrCount(sList%i%, SubStr(sItem, A_Index, 3)) - sItem_%A_Index%)
        }
    }
    
    iBestI := 0
    iBestD := 0x10000
    Loop %iCount% {
        If (sList%A_Index%_Diff < iBestD) {
            iBestD := sList%A_Index%_Diff
            iBestI := A_Index
        }
    }
    
    ;Put the winning index in the low-word and a number between 0 and 100 representing the "fitness" of the match in the high-word
    Return (Round((iTrigrams - iBestD) * 100 / iTrigrams) << 16) + iBestI
}

;Returns the number of times a trigrams occurs in a string
InStrCount(ByRef Haystack, Trigram) {
    j := 0, i := 1
    Loop {
        i := InStr(Haystack, Trigram, False, i)
        If Not i
            Return j
        j += 1, i += 3
    }
}


/* EXAMPLE:

MyItem = 2008 - The Dark Knight

s1 := "The Dark Knight's Dog"
s2 := "The Dark Knight [2008]"
s3 := "Dark Nights"
s4 := "Dark Nightmares on Elm Street"

VarSetCapacity(ptr, 16)
i := &ptr
Loop 4
    i := NumPut(&s%A_Index%, i+0)

;Call function
i := MatchItemFromList(&ptr, 4, MyItem), l := i & 0xFFFF, h := i >> 16
MsgBox % "Winning index: " l "`nWinning title: " s%l% "`nMatch fitness: " h    "%"
    
Return

*/