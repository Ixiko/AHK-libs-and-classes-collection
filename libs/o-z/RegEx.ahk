; https://autohotkey.com/boards/viewtopic.php?t=1035
;----------------------------------------------------------------------
/*
	RegEx.ahk
	ver 11/30/14
	URL http://ahkscript.org/boards/viewtopic.php?f=6&t=1035&p=7482#p7481
    Examples http://ahkscript.org/boards/viewtopic.php?f=6&t=1035&p=7481#p7482
*/
;----------------------------------------------------------------------
;----------------------------------------------------------------------
/*
Functions List:
					RegEx_Trim			Returns a trimmed string based on RegEx character(s)
(12/31/15)	RegEx_Split			Returns delimited string or an array object based on RegEx delimiter
					RegEx_Sort			Returns sorted string based on RegEx Key
					RegEx_Grep			Returns delimited string or an array object based on RegEx needle
					RegEx_Between	Returns delimited string or an array object between two regex patterns exclusively
(12.17.13)		RegEx_Match		Returns match of regex
					RegEx_Help			Returns syntax help
*/
;----------------------------------------------------------------------
/*
	RegEx_Trim		Returns a trimmed string based on RegEx characters
	Parameters:
		Name		Req/Opt		Data Type	Default 	Description
		Haystack	Required	text					a string or a multi-line text to be trimmed
		Needle		Required	Pattern					regex pattern to match trim character(s)
		End 		Optional	text		""			"R" right trim only | "L" left trim only | omitted for left and right trim (default)
*/
RegEx_Trim(Haystack, Needle, End:=""){
	IfEqual, end , L, return 	RegExReplace(HayStack, "`am)^" Needle)
	IfEqual, end , R, return 	RegExReplace(HayStack, "`am)"  Needle "$")
	return 						RegExReplace(HayStack, "`am)^" Needle "|" Needle "$")
}
;----------------------------------------------------------------------
/*
	RegEx_Split		Returns delimited string or an array object based on RegEx delimiter
	Parameters:
		Name		Req/Opt		Data Type	Default 	Description
		Haystack	Required	text					a string to be split into delimited string or an array object
		Needle		Required	Pattern					regex pattern to match split character(s)
		Delim 		Optional	text		""			text delimiter for string result | omitted for an array object result (default)
*/
RegEx_Split(Haystack, Needle, Delim:=""){
	O:=[], Start:=1
	while Pos := RegExMatch(Haystack, Needle, m, A_Index=1 ?1: Pos+StrLen(m))
		X:=SubStr(Haystack, Start, Pos-Start), R .= (A_Index=1?"":Delim) X, O.Insert(X) , Start := Pos+StrLen(m)
	R .= (R?Delim:"") SubStr(Haystack, Start), O.Insert(SubStr(Haystack, Start))
	return Delim?R:O
}

;----------------------------------------------------------------------
/*
	RegEx_Sort		Returns sorted string based on RegEx Key
	Parameters:
		Name		Req/Opt		Data Type	Default 	Description
		Haystack	Required	text					a string to be sorted
		Needle		Optional	Pattern		".*"		regex pattern to match sort key - default ".*" no sort key
		SubPattern 	Optional	No.			""			optional subpattern number to be used as a sort key - default no subpattern
		Descending	Optional	boolean		""			1 for Sorts in reverse order | omitted sort in ascending order (default)
		Delim 		Optional	text		""			text delimiter for string result | omitted for "`n" delimiter (default)
*/
RegEx_Sort(Haystack, Needle:=".*", SubPattern:="", Descending:=0, Delim:="`n"){
	Obj := [], 	SubPattern := SubPattern ? SubPattern : ""
	loop, parse, Haystack, %Delim%
		RegExMatch(A_LoopField, Needle, Match), Obj[Match%SubPattern%] .= (Obj[Match%SubPattern%]?Delim:"") A_LoopField
	for, k, v in obj {
		Sort, v, % "D" Delim (Descending?" R":"")
		Res := (Descending? v (A_Index>1?Delim:"") Res : Res (A_Index>1?Delim:"") v)
	}
	return Res
}
;----------------------------------------------------------------------
/*
	RegEx_Grep		Returns delimited string or an array object based on RegEx needle
	Parameters:
		Name		Req/Opt		Data Type	Default 	Description
		Haystack	Required	text					a string to be searched
		Needle		Required	Pattern					regex pattern to match required text
		SubPattern 	Optional	No.			""			optional subpattern number to be used as match - default no subpattern
		Delim 		Optional	text		""			text delimiter for string result | omitted for an array object result (default)
*/
RegEx_Grep(Haystack, Needle, SubPattern:="", Delim:=""){
	O:=[]	, SubPattern := SubPattern ? SubPattern : ""
	while Pos:=RegExMatch(HayStack,Needle,Match,Pos?Pos+StrLen(Match):1)
		R.= (A_Index>1?Delim:"") Match%SubPattern%, O.Insert(Match%SubPattern%)
	return Delim?R:O
}
;----------------------------------------------------------------------
/*
	RegEx_Between	Returns delimited string or an array object between two regex patterns exclusively
	Parameters:
		Name		Req/Opt		Data Type	Default 	Description
		Haystack	Required	text					a string to be searched
		NeedleA		Required	Pattern					regex pattern to match Start of Text
		NeedleB 	Required	Pattern					regex pattern to match End of Text
		Delim 		Optional	text		""			text delimiter for string result | omitted for an array object result (default)
*/
RegEx_Between(HayStack, NeedleA, NeedleB, Delim:=""){
	O:=[]
	while Pos:=RegExMatch(HayStack, NeedleA "\K.*?(?=" NeedleB ")", Match, Pos?Pos+StrLen(Match):1)
		R.= (A_Index>1?Delim:"") Match,  O.Insert(Match)
	return , Delim?R:O
}
;----------------------------------------------------------------------
/*
	RegEx_Match		Returns matches of regex
	Parameters:
		Name		Req/Opt		Data Type	Default 	Description
		Haystack	Required	text					a string to be searched
		Needle		Required	Pattern					regex pattern to match
		SubPattern 	Optional	No.			""			optional subpattern number to be used as match - default no subpattern
*/
RegEx_Match(Haystack, Needle, SubPattern:=""){
	SubPattern := SubPattern ? SubPattern : ""
	RegExMatch(Haystack, Needle, Match)
	return Match%SubPattern%
}
;----------------------------------------------------------------------
/*
	RegEx_Help		Returns syntax help
	Parameters:
		Name		Req/Opt		Data Type	Default 	Description
		Function	Required	text					the name of the function
*/
RegEx_Help(Function){
	Help := []
	Help["Trim"]				:=	"RegEx_Trim(Haystack, Needle, End:=[""L|R""])"
	Help["Split"]				:=	"RegEx_Split(Haystack, Needle, Delim:="""")"
	Help["Sort"]				:=	"RegEx_Sort(Haystack, Needle:="".*"", SubPattern:="""", Descending:=0, Delim:=""``n"")"
	Help["Grep"]				:=	"RegEx_Grep(Haystack, Needle, SubPattern:="""", Delim:="""")"
	Help["Between"]			:=	"RegEx_Between(HayStack, NeedleA, NeedleB, Delim:="""")"
	Help["Match"]				:=	"RegEx_Match(Haystack, Needle, SubPattern:="""")"
	return help[function]
}
;----------------------------------------------------------------------