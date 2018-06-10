;
; Default Base Object Class
;

/*!
	Page: Default Base Module
	Filename: DefaultBase
	Contents: @file:../doc-pages/DefaultBase.md
*/

class CDefaultBase
{
	class __PropImpl
	{
		__Call(ByRef aTarget, aName, aParams*)
		{
			if ObjHasKey(this, aName)
				return this[aName].(aTarget, aParams*)
		}
	}
	
	class __Get extends CDefaultBase.__PropImpl
	{
		static Length := Func("StrLen")
	}
	
	class __Set extends CDefaultBase.__PropImpl
	{
	}
	
	static Split := Func("__CDefaultBase_StrSplit")
	static Replace := Func("__CDefaultBase_StrReplace")
	static Find := Func("InStr")
	static Match := Func("RegExMatch")
	static MatchReplace := Func("RegExReplace")
	static ToLower := Func("__CDefaultBase_StrLower")
	static ToUpper := Func("__CDefaultBase_StrUpper")
	static Trim := Func("Trim")
	static LTrim := Func("LTrim")
	static RTrim := Func("RTrim")
	
	; Register default base objec
	static _ := IsObject("".base.base := CDefaultBase)
}

__CDefaultBase_StrSplit(ByRef t, delim := "", omitC := "")
{
	k := []
	Loop, Parse, t, % delim, % omitC
		k.Insert(A_LoopField)
	return k
}

__CDefaultBase_StrReplace(ByRef t, searchText, replaceText := "", ByRef ovCount := "")
{
	if IsByRef(ovCount)
	{
		StringReplace, q, t, % searchText, % replaceText, UseErrorLevel
		ovCount := ErrorLevel, ErrorLevel := 0
	} else
		StringReplace, q, t, % searchText, % replaceText, % ovCount = "" ? "A" : 1
	return q
}

__CDefaultBase_StrLower(ByRef t, titleCase := false)
{
	StringLower, q, t, % titleCase ? "T" : ""
	return q
}

__CDefaultBase_StrUpper(ByRef t, titleCase := false)
{
	StringUpper, q, t, % titleCase ? "T" : ""
	return q
}
