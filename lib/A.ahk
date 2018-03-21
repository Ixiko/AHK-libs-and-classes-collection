; Binary AHK Array RC2
; (w) by DerRaphael
;
; Released under the Terms of European Public License (EUPL 1.0)
;    see http://ec.europa.eu/idabc/en/document/7330
;    for translations in your language.

A_Put(ByRef Array, ByRef Data, Index=-1, dSize=-1){
    If !(A_Array(Array)) ; No Array ? Do an ArrayInit to get a proper Structure
        A_Init(Array)

    if ((Index=-1) || (A_Count(Array)+1=Index)) {
        Gosub, GetArrayStats
    
        nSize := aSize+dSize+8                         ; calculate new size
        VarSetCapacity(tmpArray, nSize, 32)            ; create tmpArray for our new data
        A_ArrayMM(&tmpArray, &Array, aSize)            ; Copy entire array to TMP
    
        NumPut(nSize,       tmpArray, 12)              ; Update size of array in total
        NumPut(tSize+8,     tmpArray, 16)              ; Update tableLenght
        NumPut(oSize+dSize, tmpArray, 20)              ; Update length of new ArrayStructure
        NumPut(ElmCount+1,  tmpArray, 24)              ; Update elementcount
    
        A_ArrayMM( &tmpArray + tSize + 8               ; Shift ArrayData for 8 bytes
                    , &Array + tSize, oSize )
        A_ArrayMM(&tmpArray+aSize+8,&Data,dSize)       ; copy data to tmpArray
    
        Offset := 28                                   ; move offsets for array contents
        Loop, % ElmCount+1
            NumPut( NumGet(tmpArray
                    ,(Offset+(A_index-1)*8))+8         ; get last known value and 
                    ,tmpArray,(Offset+(A_index-1)*8))  ; increment it by 8

        NumPut(aSize+8, tmpArray, tSize)               ; Set offsetpointer to new data
        NumPut(dSize, tmpArray, tSize+4)               ; Set size of new element

        VarSetCapacity(Array,nSize,32)                 ; Resize the array
        A_ArrayMM(&Array, &tmpArray, nSize)            ; copy tmpArray back to array

        Return ElmCount+1
    } else if ((A_Count(Array)>=Index) && (Index!=0)) {
        Gosub, GetArrayStats
        
        ElmPtr  := NumGet(Array,28+(Index-1)*8)
        ElmSize := NumGet(Array,32+(Index-1)*8)
        
        if ((dSize>ElmSize) || (dSize<ElmSize)) {      ; Fix table offsets to new size
    
            OffSet  := 28+Index*8                      ; GetStarting offset in table
            ptrDiff := dSize-ElmSize                   ; Get difference

            nSize := aSize+ptrDiff                     ; calculate new size
            VarSetCapacity(tmpArray, nSize, 32)        ; create tmpArray for our new data
            A_ArrayMM(&tmpArray, &Array                ; Copy entire array to TMP
                , ((aSize>nSize) ? nSize : aSize))     ; with a correct calculated length
            NumPut(nSize, tmpArray, 12)                ; Update size of array in total
            NumPut(oSize+ptrDiff, tmpArray, 20)        ; Update length of new ArrayStructure
            NumPut(dSize, tmpArray, Offset-4)          ; Set size of new element

            Loop,% ElmCount-Index                      ; loop remaining elements
                NumPut( NumGet(tmpArray
                    ,(Offset+(A_index-1)*8))+ptrDiff   ; get last known value and 
                    ,tmpArray,(Offset+(A_index-1)*8))  ; add the difference

            Offset := NumGet(tmpArray,Offset-8)
            A_ArrayMM(&tmpArray+Offset, &Data, dSize)  ; Copy new data into tmpArray
            A_ArrayMM(&tmpArray+Offset+dSize           ; remaining ArrayData to new offset
                    , &Array+Offset+ElmSize, aSize-(OffSet+ElmSize))

            VarSetCapacity(Array,nSize,32)             ; Resize the array
            A_ArrayMM(&Array, &tmpArray, nSize)        ; copy tmpArray back to array

        } else if (dSize=ElmSize) {                    ; No need to fix tableoffsets
            A_ArrayMM(&Array+ElmPtr,&Data,dSize)       ; speeeed!
        } else {                                       ; THIS SHOULD NEVER HAPPEN
            ErrorLevel := "Internal Binary Array Structure Error / Invalid Binary Array Object"
            return -1
        }
        Return ElmCount
    } else {
        ErrorLevel := "Binary Array Index Mismatch"
        Return -1
    }

    GetArrayStats:
        ElmCount := A_Count(Array)       ; update ElementCount
        aSize    := A_Size(Array)        ; current ByteSize of entire Array
        oSize    := A_Length(Array)      ; current ByteSize of contained data in Array
        tSize    := NumGet(Array,16)     ; table size
        If (dSize<=-1)                   ; No size given - assume it's a string and fix it!
            RegExReplace(Data,".","",dSize)
    return
}

A_Get(ByRef Array, Index) {
    If !(A_Array(Array)) {
        ErrorLevel := "No valid binary Array"
        return -1
    } else if ((Index>A_Count(Array)) || (Index<=0)) {
        ErrorLevel := "Binary Array Index mismatch - no such Index"
        return -1
    } else {
        Offset  := 28+(Index-1)*8                      ; Get starting offset in table
        ElmPtr  := NumGet(Array,Offset)
        ElmSize := NumGet(Array,Offset+4)

        VarSetCapacity(ArrayElement,ElmSize,32)        ; Initialise the returnbuffer
        A_ArrayMM(&ArrayElement,&Array+ElmPtr,ElmSize) ; Copy the binary data
        
        ErrorLevel := ElmSize
        Return ArrayElement
    }
}

; Returns a joined string of given Array and glue parameter
; Length is returned as ErrorLevel
A_Implode(ByRef Array, glue=" ") {
    If !(A_Array(Array)) {
        ErrorLevel := "No valid binary Array"
        return -1
    } else {
        lGlue      := glue
        glueLength := StrLen(lGlue)
        aSize      := A_Length(Array)                  ; current DataSize of array
        elmCount   := A_Count(Array)                   ; get ElementCount of Array
        ErrorLevel := (elmCount-1)*glueLength + aSize  ; count new Size of returnString
        Offset     := 0                                ; set Offset for A_ArrayMM Loop

        VarSetCapacity(String,ErrorLevel,32)           ; Allocate space for new return

        Loop,% elmCount
        {
            elmLength  := NumGet(Array,32+(A_Index-1)*8)  ; current element's length
            elmPos     := NumGet(Array,28+(A_Index-1)*8)  ; current element's position in Array
            A_ArrayMM(&String+Offset, &Array+elmPos, elmLength)  ; Move it to ReturnData
            Offset     += elmLength                       ; calculate Offset
            if (A_Index!=elmCount)
                A_ArrayMM(&String+Offset, &lGlue, glueLength) ; Move Glue to ReturnData
            Offset     += glueLength                      ; calculate Offset again
        }
        return String
    }
}

; Returns an array of strings, each of which is a substring of string formed 
; by splitting it on boundaries formed by the string delimiter. 
; unlike Stringsplit, multiple chars are allowed in dString
A_Explode(ByRef Array, dString, sString, Limit=0, trimChars="", trimCharsIsRegEx=False, dStringIsRegEx=False) {
    if !(A_Array(Array))
        A_Init(Array)

    oIF := A_FormatInteger            ; Store current Integerformat
    SetFormat,Integer,H

    If !(trimCharsIsRegEx) {          ; Build RegExNeedle for trimming if non given
        Loop,Parse,TrimChars          ; parse each char and build hexescaped needle
            escTrimChars .=  "|^\" SubStr(asc(A_LoopField),2) "|\" SubStr(asc(A_LoopField),2) "$"
        trimChars := "(" SubStr(escTrimChars,2) ")"
    }

    gLen := StrLen(dString)           ; get length of delimiterString
    sLen := StrLen(sString)           ; get length of string
                                      ; since this is not a byref parameter,
                                      ; binary values need to be assigned direct in call such as 
                                      ; A_Explode(Array,"\x0",FileGetContent("myfile.dat"),"",0,1)

    If !(dStringIsRegEx) {            ; Build RegExNeedle for matching if non given
        Loop,Parse,dString            ; parse each char and build hexescaped needle
            escdString .=  "|\" SubStr(asc(A_LoopField),2)
        dString := "(" SubStr(escdString,2) ")"
    }
    SetFormat,Integer,% oIF

    Loop,
        if (nPos := RegExMatch(sString,dString)) {
            sLen -= nPos                                         ; calculate new length
            data := RegExReplace(sString,"(.{" sLen+gLen "}$)")  ; generate data to store in Array
            _tmp := RegExReplace(data,".","",dLen)               ; fix length for data
            sString := RegExReplace(sString,"(^.{" nPos "})")    ; generate new sourceString
            _tmp := RegExReplace(sString,".","",sLen)            ; fix length for binary Arrays
            A_Put(Array,Data,-1,dLen)                            ; store to Array
        } else {
            A_Put(Array,sString,-1,sLen)
            Break
        }
    return A_Count(Array)
}

; Deletes ItemIndex of given Array
A_Del(ByRef Array, Item=-1){
    If !(A_Array(Array)) {
        ErrorLevel := "No valid binary Array"
        return -1
    } else if ((Item+0<=0) || (Item>A_Count(Array))) {
        ErrorLevel := "No valid Index"
        return -1
    } else {
        aSize      := A_Size(Array)                    ; current DataSize of Array
        VarSetCapacity(tmpArray, aSize, 32)
        A_ArrayMM(&tmpArray, &Array, aSize)            ; copy Array

        VarSetCapacity(Array,0)                        ; delete Old Array
        Loop,% A_Count(tmpArray)
        {
            elmData   := A_Get(tmpArray,A_Index)
            if (A_Index!=Item)
                A_Put(Array,elmData,-1,ErrorLevel)
        }

        data  := A_Get(tmpArray,Item)                  ; Get return data
        size  := ErrorLevel                            ; store size for reuse
        VarSetCapacity(out,0)                          ; prepare element
        VarSetCapacity(out,size,32)
        A_ArrayMM(&out, &data, size)                   ; copy data to return var
        ErrorLevel := size                             ; update ErrorLevel
        Return out
    }
}

; Returns the element off the end of array and removes it
; Length is returned as ErrorLevel
A_Pop(ByRef Array){
    If !(A_Array(Array)) {
        ErrorLevel := "No valid binary Array"
        return -1
    } else {
        Item := A_Count(Array)
        data  := A_Del(Array,Item)                     ; Get return data
        size  := ErrorLevel                            ; store size for reuse
        VarSetCapacity(out,0)                          ; prepare element
        VarSetCapacity(out,size,32)
        A_ArrayMM(&out, &data, size)                   ; copy data to return var
        ErrorLevel := size                             ; update ErrorLevel
        Return out
    }
}

; Shift an element off the beginning of array and returns it
; Length is returned as ErrorLevel
A_Shift(ByRef Array){
    If !(A_Array(Array)) {
        ErrorLevel := "No valid binary Array"
        return -1
    } else {
        Item := 1
        data  := A_Del(Array,Item)                     ; Get return data
        size  := ErrorLevel                            ; store size for reuse
        VarSetCapacity(out,0)                          ; prepare element
        VarSetCapacity(out,size,32)
        A_ArrayMM(&out, &data, size)                   ; copy data to return var
        ErrorLevel := size                             ; update ErrorLevel
        Return out
    }
}

; Swaps element IdxA with element IdxB in given Array
A_Swap(ByRef Array, IdxA, IdxB) {
    If !(A_Array(Array)) {
        ErrorLevel := "No valid binary Array"
        return -1
    } else {
        elmA  := A_Get(Array,IdxA), sizeA := ErrorLevel
        elmB  := A_Get(Array,IdxB), sizeB := ErrorLevel
        A_Put(Array,elmB,idxA,sizeB)
        A_Put(Array,elmA,idxB,sizeA)
        return true
    }
}

; sArray's given intersection Elements are appended to Array, which
; will be created at runtime if neccessary
A_Slice(ByRef Array, ByRef sArray, Start, End) {
    If !(A_Array(sArray)) {
        ErrorLevel := "No valid source Array"
        return -1
    } else if ((cnt := A_Count(sArray)) 
                    && (Start>0) && (cnt<Start)
                    && (End>0) && (cnt<End)) {
        ErrorLevel := "Wrong Start or End of sArray"
        return -1
    } else {
        If !(A_Array(Array))
            A_Init(Array)
        startIndex := (Start > End)? End : Start
        endIndex   := (start==startIndex) ? End : Start
        Loop, % endIndex - StartIndex + 1 {
            elm  := A_Get(sArray, StartIndex-1+A_Index), size := ErrorLevel
            cnt := A_Put(Array, elm, -1, size)
        }
        ErrorLevel := cnt
    }
}

; Appends entire sArray to Array
A_Merge(Byref Array, ByRef sArray) {
    If (!(A_Array(sArray)) || (A_Count(sArray)<1)) {
        ErrorLevel := "No valid source Array"
        return -1
    } else {
        If !(A_Array(Array))
            A_Init(Array)
        A_Slice(Array,sArray,1,A_Count(sArray))
    }
}

; Returns TRUE if Array, FALSE otherwise - Thx, Lexikos
A_Array(byRef Array) {
    Return Array="Array()" && VarSetCapacity(Array)>=28 && NumGet(Array,8)=0x1001
}

; Returns current element count of given array or -1 if no valid binary array
A_Count(byRef Array) {
    If !(A_Array(Array)) {
        ErrorLevel := "No valid binary Array"
        return -1
    } else {
        ErrorLevel := 0
        Return NumGet(Array,24,"uInt")
    }
}

; for internal use only - initialises bytestructure of array
A_Init(byRef Array) {
    ; ATM 28 Bytes is minimum for AHK binary array structure
    ArraySize := 28 
    VarSetCapacity(Array,ArraySize,32)

    Array = Array()

    NumPut(0x1001,    Array, 8)   ; Array version
    NumPut(ArraySize, Array, 12)  ; ArraySize in bytes
    NumPut(0x1c,      Array, 16)  ; TableLength in bytes
    NumPut(0x0,       Array, 20)  ; ArrayLength in bytes
    NumPut(0x0,       Array, 24)  ; Element count
    Return True
}

; for internal use only - returns ArrayStructuresize
A_Size(ByRef Array){
    If !(A_Array(Array)) {
        ErrorLevel := "No valid binary Array"
        return -1
    } else {
        ErrorLevel := 0
        Return NumGet(Array,12,"uInt")
    }
}

; for internal use only - returns DataLength of Array
A_Length(ByRef Array){
    If !(A_Array(Array)) {
        ErrorLevel := "No valid binary Array"
        return -1
    } else {
        ErrorLevel := 0
        Return NumGet(Array,20,"uInt")
    }
}

A_Dump(ByRef Array) {
    If !(A_Array(Array)) {
        ErrorLevel := "No valid binary Array"
        return -1
    } else {
        out := "Array(" A_Count(Array) ")`n{`n" A_Implode(Array,"`n`t=>`t") "`n}`n"
        Loop,parse,out,`n
            if ((A_Index>=3) && (A_Count(Array)+2>=A_Index))
                out .= "   [" A_Index-2 "]" ((A_index-2=1) ? "`t=>`t" : "") A_LoopField "`n"
            else 
                out := ((A_Index=1) ? A_LoopField : out A_LoopField) "`n"
        Return out
    }
}

; for internal use only - SyntaxSugar for RtlMoveMemory
A_ArrayMM(Target, Source, Length) {
    DllCall("RtlMoveMemory","uInt",Target,"uInt",Source,"uInt",Length)
}

; for debugging purposes only
A___ArrayBin(ByRef Array,offset,length){
    SetFormat,Integer,h
    n := 0
    Loop,% length
    {
        c := NumGet(Array,offset+A_Index-1,"uchar")
        o .= SubStr("0" SubStr(c,3),-1) " " ((n=16) ? "`t" chars "`n" : "" )
        chars := ((n=16) ? "" : chars (RegExMatch(chr(c),"[^\x0-\x1f\x7f-\xa0]") ? chr(c) : "."))
        n:= ((n=16) ? 0 : n+1)
    }
    SetFormat,Integer,D
    if (n) && (n!=16) {
        VarSetCapacity(spc,(16-n)*3,32)
        r := spc "`t" chars
    }
    return o r
}

; for debugging purposes only - to dump an array use A_Dump(Array)
A___ArrayInsideView(Array) {
    A_ArrayMM(&(as1:="-------"), &Array, 7)
    as2 := ((x:=NumGet(Array, 7,"uchar"))=0) ? "\0" : x
    av  := NumGet(Array, 8)   ; Array version
    as  := NumGet(Array, 12)  ; ArraySize in bytes    (Structure)

    tl  := NumGet(Array, 16)  ; TableLength in bytes
    al  := NumGet(Array, 20)  ; ArrayLength in bytes  (Data)
    ec  := NumGet(Array, 24)  ; Element count
    
    offset := 28
    Loop,% (tl-offset) // 8
    {
        elms .= "&" offset+((A_index-1)*8)   " ptr elm " a_index 
                    . "`t->`t" (o:=NumGet(Array,offset+((A_index-1)*8)))   "`n"
              . "&" offset+((A_index-1)*8)+4 " len elm " a_index 
                    . "`t->`t" (l:=NumGet(Array,offset+4+((A_index-1)*8))) "`n"
        data .= "&" o ": " A___ArrayBin(Array,o,l) "`n"
    }
    
    out=
        (LTrim 
            aSignature    &0    %as1%
            Terminator    &7    %as2%
            arrayVersion    &8    %av%
            tArraySize    &12    %as%
            tableLength    &16    %tl%
            arrayLength    &20    %al%
            elementCount    &24    %ec%
                        
            %elms%
            %data%
        )

    return out 
}

/*
a_array - by derRaphael - exmaple internal table layout

  &0    (str)     Array()
  &7    (uchar)    \0
  &8    (uint)    AHK Array Version Major/Minor ::atm dec 4097 or 0x1001::
 &12    (uint)    ArraySize in bytes
 &16    (uint)    TableLength ::subject to change:: will stay reserved
 &20    (uint)    ArrayLength
 &24    (uint)    ElementsCount
 &28    (uint)    Elm1Offset ::In this case &36::
 &32    (uint)    elm1Length
 &36     rawdata
*/
