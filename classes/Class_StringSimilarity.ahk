Class stringsimilarity {

	__New() {
        this.info_Array
	}


    compareTwoStrings(para_string1,para_string2) {
        ;Sørensen-Dice coefficient
        vCount := 0
        oArray := {}
        oArray := {base:{__Get:Func("Abs").Bind(0)}} ;make default key value 0 instead of a blank string
        Loop, % vCount1 := StrLen(para_string1) - 1
            oArray["z" SubStr(para_string1, A_Index, 2)]++
        Loop, % vCount2 := StrLen(para_string2) - 1
            if (oArray["z" SubStr(para_string2, A_Index, 2)] > 0) {
                oArray["z" SubStr(para_string2, A_Index, 2)]--
                vCount++
            }
        vDSC := Round((2 * vCount) / (vCount1 + vCount2),2)
        if (!vDSC || vDSC < 0.005) { ;round to 0 if less than 0.005
            return 0
        }
        if (vDSC = 1) { 
            return 1
        }
        return % vDSC
    }


    findBestMatch(para_string,para_array) {
        if (!IsObject(para_array)) {
            return false
        }
        this.info_Array := []

        ; Score each option and save into a new array
        loop, % para_array.MaxIndex() {
            this.info_Array[A_Index, "rating"] := this.compareTwoStrings(para_string, para_array[A_Index])
            this.info_Array[A_Index, "target"] := para_array[A_Index]
        }

        ;sort the scored array and return the bestmatch
        l_sortedArray := this.internal_Sort2DArrayFast(this.info_Array,"rating", false) ;false reverses the order so the highest scoring is at the top
        l_Object := {bestMatch:l_sortedArray[1], ratings:l_sortedArray}
        return l_Object
    }


    simpleBestMatch(para_string,para_array) {
        if (!IsObject(para_array)) {
            return false
        }

        l_array := this.findBestMatch(para_string,para_array)
        return l_array.bestMatch.target
    }




    internal_Sort2DArrayFast(byRef a, key, Ascending := True)
    {
        for index, obj in a
            out .= obj[key] "+" index "|" ; "+" allows for sort to work with just the value
        ; out will look like:   value+index|value+index|

        v := a[a.minIndex(), key]
        if v is number 
            type := " N "
        StringTrimRight, out, out, 1 ; remove trailing | 
        Sort, out, % "D| " type  (!Ascending ? " R" : " ")
        l_storage := []
        loop, parse, out, |
            l_storage.insert(a[SubStr(A_LoopField, InStr(A_LoopField, "+") + 1)])
        return l_storage
    }
}
