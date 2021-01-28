;================================================================
ScriptIsComplex(pTxt, sz=0, flags=1)	; flags: SIC_COMPLEX=1 SIC_ASCIIDIGIT=2 SIC_NEUTRAL=4
;================================================================
{
Global Ptr
sz := sz > 0 ? sz : DllCall("msvcrt\wcslen", Ptr, pTxt, "CDecl")
return DllCall("usp10\" A_ThisFunc, Ptr, pTxt, "Int", sz, "UInt", flags)
}
;================================================================
ScriptRecordDigitSubstitution(LCID, ByRef SDS)	; usually used with LOCALE_USER_DEFAULT=0x400
;================================================================
{
Global Ptr
VarSetCapacity(SDS, 8, 0)	; SCRIPT_DIGITSUBSTITUTE struct
return DllCall("usp10\" A_ThisFunc, "UInt", LCID, Ptr, &SDS)
}
;================================================================
ScriptStringAnalyse(hdc, pTxt, sz, gSz, cs, flags, rw, sc, ss, dx, st, gcp, ByRef pssa)
;================================================================
{
Global Ptr, PtrP
return DllCall("usp10\" A_ThisFunc
	, Ptr		, hdc	; hdc
	, Ptr		, pTxt	; pString
	, "Int"	, sz		; cString
	, "Int"	, gSz	; cGlyphs
	, "UInt"	, cs		; iCharset
	, "UInt"	, flags	; dwFlags
	, "Int"	, rw		; iReqWidth
	, Ptr		, sc		; psControl
	, Ptr		, ss		; psState
	, Ptr		, dx		; piDx
	, Ptr		, st		; pTabdef
	, Ptr		, gcp	; pbInClass
	, PtrP	, pssa	; pssa
	, "UInt")
}
;================================================================
ScriptStringOut(pssa, ix, iy, opt, rc, min, max, dis)
;================================================================
{
Global Ptr, PtrP
return DllCall("usp10\" A_ThisFunc
	, Ptr		, pssa	; ssa
	, "Int"	, ix		; iX
	, "Int"	, iy		; iY
	, "UInt"	, opt		; uOptions
	, Ptr		, rc		; prc
	, "Int"	, min		; iMinSel
	, "Int"	, max	; iMaxSel
	, "UInt"	, dis		; fDisabled
	, "UInt")
}
;================================================================
ScriptStringFree(ByRef pssa)
;================================================================
{
Global Ptr
return DllCall("usp10\" A_ThisFunc, PtrP, pssa, "UInt")
}
;================================================================
/*
ScriptItemize
ScriptLayout
ScriptShape
ScriptPlace
ScriptTextOut
ScriptFreeCache
*/
