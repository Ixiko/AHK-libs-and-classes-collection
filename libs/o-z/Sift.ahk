﻿/* Sift
; Fanatic Guru
; 2015 04 30
; Version 1.00
;
; LIBRARY to sift through a string or array and return items that match sift criteria.
;
; ===================================================================================================================================================
;
; Functions:
; 
; ===================================================================================================================================================
; Sift_Regex(Haystack, Needle, Options, Delimiter)
;
;   Parameters:
;   1) {Haystack}	String or array of information to search, ByRef for efficiency but Haystack is not changed by function
;
;   2) {Needle}		String providing search text or criteria, ByRef for efficiency but Needle is not changed by function
;
;	3) {Options}
;			IN		Needle anywhere IN Haystack item (Default = IN)
;			LEFT	Needle is to LEFT or beginning of Haystack item
;			RIGHT	Needle is to RIGHT or end of Haystack item
;			EXACT	Needle is an EXACT match to Haystack item
;			REGEX	Needle is an REGEX expression to check against Haystack item
;			OC		Needle is ORDERED CHARACTERS to be searched for even non-consecutively but in the given order in Haystack item 
;			OW		Needle is ORDERED WORDS to be searched for even non-consecutively but in the given order in Haystack item
;			UC		Needle is UNORDERED CHARACTERS to be search for even non-consecutively and in any order in Haystack item
;			UW		Needle is UNORDERED WORDS to be search for even non-consecutively and in any order in Haystack item
;
;			If an Option is all lower case then the search will be case insensitive
;
;	4)  {Delimiter}	Single character Delimiter of each item in a Haystack string (Default = `n)
;
;	Returns: 
;		If Haystack is string then a string is returned of found Haystack items delimited by the Delimiter
; 		If Haystack is an array then an array is returned of found Haystack items
;
; 	Note:
;		Sift_Regex searchs are all RegExMatch seaches with Needles crafted based on the options chosen
;
; ===================================================================================================================================================
; Sift_Ngram(Haystack, Needle, Delta, Haystack_Matrix, Ngram Size, Format)
;
;	Parameters:
;	1) {Haystack}		String or array of information to search, ByRef for efficiency but Haystack is not changed by function
;
;   2) {Needle}			String providing search text or criteria, ByRef for efficiency but Needle is not changed by function
;
;	3) {Delta}			(Default = .7) Fuzzy match coefficient, 1 is a prefect match, 0 is no match at all, only results above the Delta are returned
;
;	4) {Haystack_Matrix} (Default = false)	
;			An object containing the preprocessing of the Haystack for Ngrams content
;			If a non-object is passed the Haystack is processed for Ngram content and the results are returned by ByRef
;			If an object is passed then that is used as the processed Ngram content of Haystack
;			If multiply calls to the function are made with no change to the Haystack then a previous processing of Haystack for Ngram content 
;				can be passed back to the function to avoid reprocessing the same Haystack again in order to increase efficiency.
;
;	5) {Ngram Size}		(Default = 3) The length of Ngram used.  Generally Ngrams made of 3 letters called a Trigram is good
;
;	6) {Format}			(Default = S`n)
;			S				Return Object with results Sorted
;			U				Return Object with results Unsorted
;			S%%%			Return Sorted string delimited by characters after S
;			U%%%			Return Unsorted string delimited by characters after U
;								Sorted results are by best match first
;
;	Returns:
;		A string or array depending on Format parameter.
;		If string then it is delimited based on Format parameter.
;		If array then an array of object is returned where each element is of the structure: {Object}.Delta and {Object}.Data
;			Example Code to access object returned:
;				for key, element in Sift_Ngram(Data, QueryText, NgramLimit, Data_Ngram_Matrix, NgramSize)
;						Display .= element.delta "`t" element.data "`n"
;
;	Dependencies: Sift_Ngram_Get, Sift_Ngram_Compare, Sift_Ngram_Matrix, Sift_SortResults
;		These are helper functions that are generally not called directly.  Although Sift_Ngram_Matrix could be useful to call directly to preprocess a large static Haystack
;
; 	Note:
;		The string "dog house" would produce these Trigrams: dog|og |g h| ho|hou|ous|use
;		Sift_Ngram breaks the needle and each item of the Haystack up into Ngrams.
;		Then all the Needle Ngrams are looked for in the Haystack items Ngrams resulting in a percentage of Needle Ngrams found
;
; ===================================================================================================================================================
;
*/


Sift_Regex(ByRef Haystack, ByRef Needle, Options := "IN", Delimit := "`n") {
	Sifted := {}
	if (Options = "IN")		
		Needle_Temp := "\Q" Needle "\E"
	else if (Options = "LEFT")
		Needle_Temp := "^\Q" Needle "\E"
	else if (Options = "RIGHT")
		Needle_Temp := "\Q" Needle "\E$"
	else if (Options = "EXACT")		
		Needle_Temp := "^\Q" Needle "\E$"
	else if (Options = "REGEX")
		Needle_Temp := Needle
	else if (Options = "OC")
		Needle_Temp := RegExReplace(Needle,"(.)","\Q$1\E.*")
	else if (Options = "OW")
		Needle_Temp := RegExReplace(Needle,"( )","\Q$1\E.*")
	else if (Options = "UW")
		Loop, Parse, Needle, " "
			Needle_Temp .= "(?=.*\Q" A_LoopField "\E)"
	else if (Options = "UC")
		Loop, Parse, Needle
			Needle_Temp .= "(?=.*\Q" A_LoopField "\E)"

	if Options is lower
		Needle_Temp := "i)" Needle_Temp
	
	if IsObject(Haystack)
	{
		for key, Hay in Haystack
			if RegExMatch(Hay, Needle_Temp)
				Sifted.Insert(Hay)
	}
	else
	{
		Loop, Parse, Haystack, %Delimit%
			if RegExMatch(A_LoopField, Needle_Temp)
				Sifted .= A_LoopField Delimit
		Sifted := SubStr(Sifted,1,-1)
	}
	return Sifted
}

Sift_Ngram(ByRef Haystack, ByRef Needle, Delta := .7, ByRef Haystack_Matrix := false, n := 3, Format := "S`n" ) {
	if !IsObject(Haystack_Matrix)
		Haystack_Matrix := Sift_Ngram_Matrix(Haystack, n)
	Needle_Ngram := Sift_Ngram_Get(Needle, n)
	if IsObject(Haystack)
	{
		Search_Results := {}
		for key, Hay_Ngram in Haystack_Matrix
		{
			Result := Sift_Ngram_Compare(Hay_Ngram, Needle_Ngram)
			if !(Result < Delta)
				Search_Results[key,"Delta"] := Result, Search_Results[key,"Data"] := Haystack[key]
		}
	}
	else
	{
		Search_Results := {}
		Loop, Parse, Haystack, `n, `r
		{
			Result := Sift_Ngram_Compare(Haystack_Matrix[A_Index], Needle_Ngram)
			if !(Result < Delta)
				Search_Results[A_Index,"Delta"] := Result, Search_Results[A_Index,"Data"] := A_LoopField
		}
	}
	if (Format ~= "i)^S")
		Sift_SortResults(Search_Results)
	if RegExMatch(Format, "i)^(S|U)(.+)$", Match)
	{
		for key, element in Search_Results
			String_Results .= element.data Match2
		return SubStr(String_Results,1,-StrLen(Match2))
	}
	else
		return Search_Results
}

Sift_Ngram_Get(ByRef String, n := 3) {
	Pos := 1, Grams := {}
	Loop, % (1 + StrLen(String) - n)
		gram := SubStr(String, A_Index, n), Grams[gram] ? Grams[gram] ++ : Grams[gram] := 1
	return Grams
} 

Sift_Ngram_Compare(ByRef Hay, ByRef Needle) {
	for gram, Needle_Count in Needle
	{
		Needle_Total += Needle_Count
		Match += (Hay[gram] > Needle_Count ? Needle_Count : Hay[gram])
	}
	return Match / Needle_Total
}

Sift_Ngram_Matrix(ByRef Data, n := 3) {
	if IsObject(Data)
	{
		Matrix := {}
		for key, string in Data
			Matrix.Insert(Sift_Ngram_Get(string, n))
	}
	else
	{
		Matrix := {}
		Loop, Parse, Data, `n
			Matrix.Insert(Sift_Ngram_Get(A_LoopField, n))
	}
	return Matrix
}

Sift_SortResults(ByRef Data) {
	Data_Temp := {}
	for key, element in Data
		Data_Temp[element.Delta SubStr("0000000000" key, -9)] := element
	Data := {}
	for key, element in Data_Temp
		Data.InsertAt(1,element)
	return
}
