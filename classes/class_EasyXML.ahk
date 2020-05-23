; TODO: This class with use native, AHK, object syntax for XMLS!!
; First pass at design should be through using Coco's XPath library
; I think I should remember to do this project because many people like XML
; This could also lead to further data sets such as, EasyCSV and/or EasyDelim (delim being user defined delimiter, including CSV)

class_EasyXML(sFile="", sLoadFromStr="")
{
	return new EasyXML(sFile, sLoadFromStr)
}

class EasyXML
{
	__New(sFile="", sLoadFromStr="") ; Loads ths file into memory.
	{
		this := this.CreateIniObj("EasyXML_ReservedFor_m_sFile", sFile, "EasyXML_ReservedFor_TopComments", Object()) ; Top comments can be stored in linear array because order will simply be numeric

		if (sFile == A_Blank && sLoadFromStr == A_Blank)
			return this

		sIni := sLoadFromStr
		if (sIni == A_Blank)
			FileRead, sIni, %sFile%
/*
	Current design:
	--------------------------------------------------------------------------------------------------------------------------------------------------
	Comments at the top of the section apply to the file as a whole. They could be keyed off an internal section called
	"Internal_HeaderSection" or something. Comments above section headers apply to the the last key of the previous section
	If a comment appears between two keys, then it will apply to the key above it -- this is consistent with the solution for
	comments above section headers.	Newlines will be stored in similar fashion to comments
	--------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------
	If full-support for comments needs to be added, then the design below should supersede the design above
	--------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------
	Comments at the top of the section apply to the file as a whole. They could be keyed off an internal section called
	"Internal_HeaderSection" or something.
	Comments above section headers apply to the section header. If people dislike this, I may instead chose to make the comments
	apply to the last key of the previous section if there a newline in-between the comment in question and the next section.
	I may come up with some decent solution as I experiment. If a comment appears between two keys, then it will apply to the key below it
	-- this is consistent with the solution for comments above section headers. Newlines will be stored in similar fashion to comments
	--------------------------------------------------------------------------------------------------------------------------------------------------
*/

		Loop, Parse, sIni, `n, `r
		{
			sTrimmedLine := Trim(A_LoopField)

			; Comments or newlines within the ini
			if (SubStr(sTrimmedLine, 1, 1) == ";" || sTrimmedLine == A_Blank) ; A_Blank would be a newline
			{
				; Chr(14) is just the magical char to indicate that this line should only be a newline "`n"
				LoopField := A_LoopField == A_Blank ? Chr(14) : A_LoopField

				if (sCurSec == A_Blank)
					this.EasyXML_ReservedFor_TopComments.Insert(A_Index, LoopField) ; not using sTrimmedLine so as to keep comment formatting
				else
				{
					if (sPrevKeyForThisSec == A_Blank) ; This happens when there is a comment in the section before the first key, if any
						sPrevKeyForThisSec := "SectionComment"

					if (IsObject(this[sCurSec].EasyXML_ReservedFor_Comments))
					{
						if (this[sCurSec].EasyXML_ReservedFor_Comments.HasKey(sPrevKeyForThisSec))
							this[sCurSec].EasyXML_ReservedFor_Comments[sPrevKeyForThisSec] .= "`n" LoopField
						else this[sCurSec].EasyXML_ReservedFor_Comments.Insert(sPrevKeyForThisSec, LoopField)
					}
					else
					{
						if (IsObject(this[sCurSec]))
							this[sCurSec].EasyXML_ReservedFor_Comments := {(sPrevKeyForThisSec):LoopField}
						else this[sCurSec, "EasyXML_ReservedFor_Comments"] := {(sPrevKeyForThisSec):LoopField}
					}
				}
				continue
			}

			; [Section]
			if (SubStr(sTrimmedLine, 1, 1) = "[" && InStr(sTrimmedLine, "]")) ; need to be sure that this isn't just a key starting with "["
			{
				if (sCurSec != A_Blank && !this.HasKey(sCurSec))
					this[sCurSec] := EasyXML_CreateBaseObj()
				sCurSec := SubStr(sTrimmedLine, 2, InStr(sTrimmedLine, "]", false, 0) - 2) ; 0 search right to left. We want to trim the *last* occurence of "]"
				sPrevKeyForThisSec := ""
				continue
			}

			; key=val
			iPosOfEquals := InStr(sTrimmedLine, "=")
			if (iPosOfEquals)
			{
				sPrevKeyForThisSec := SubStr(sTrimmedLine, 1, iPosOfEquals - 1) ; so it's not the previous key yet...but it will be on next iteration :P
				val := SubStr(sTrimmedLine, iPosOfEquals + 1)
				StringReplace, val, val , `%A_ScriptDir`%, %A_ScriptDir%, All
				StringReplace, val, val , `%A_WorkingDir`%, %A_ScriptDir%, All
				this[sCurSec, sPrevKeyForThisSec] := val
			}
			else ; at this point, we know it isn't a comment, or newline, it isn't a section, and it isn't a conventional key-val pair. Treat this line as a key with no val
			{
				sPrevKeyForThisSec := sTrimmedLine
				this[sCurSec, sPrevKeyForThisSec] := ""
			}
		}
		; if there is a section with no keys and it is at the bottom of the file, then we missed it
		if (sCurSec != A_Blank && !this.HasKey(sCurSec))
			this[sCurSec] := EasyXML_CreateBaseObj()

		return this
	}

	CreateIniObj(parms*)
	{
		; Define prototype object for ini arrays:
		static base := {__Set: "EasyXML_Set", _NewEnum: "EasyXML_NewEnum", Remove: "EasyXML_Remove", Insert: "EasyXML_Insert", InsertBefore: "EasyXML_InsertBefore", AddSection: "EasyXML.AddSection", RenameSection: "EasyXML.RenameSection", DeleteSection: "EasyXML.DeleteSection", GetSections: "EasyXML.GetSections", FindSecs: "EasyXML.FindSecs", AddKey: "EasyXML.AddKey", RenameKey: "EasyXML.RenameKey", DeleteKey: "EasyXML.DeleteKey", GetKeys: "EasyXML.GetKeys", FindKeys: "EasyXML.FindKeys", GetVals: "EasyXML.GetVals", FindVals: "EasyXML.FindVals", HasVal: "EasyXML.HasVal", Copy: "EasyXML.Copy", Merge: "EasyXML.Merge", Save: "EasyXML.Save"}
		; Create and return new object:
		return Object("_keys", Object(), "base", base, parms*)
	}

	AddSection(sec, key="", val="", ByRef rsError="")
	{
		if (this.HasKey(sec))
		{
			rsError := "Error! Cannot add new section [" sec "], because it already exists."
			return false
		}

		if (key == A_Blank)
			this[sec] := EasyXML_CreateBaseObj()
		else this[sec, key] := val

		return true
	}

	RenameSection(sOldSec, sNewSec, ByRef rsError="")
	{
		if (!this.HasKey(sOldSec))
		{
			rsError := "Error! Could not rename section [" sOldSec "], because it does not exist."
			return false
		}

		aKeyValsCopy := this[sOldSec]
		this.DeleteSection(sOldSec)
		this[sNewSec] := aKeyValsCopy
		return true
	}

	DeleteSection(sec)
	{
		this.Remove(sec)
		return
	}

	GetSections(sDelim="`n")
	{
		for sec in this
			secs .= (A_Index == 1 ? sec : sDelim sec)
		return secs
	}

	FindSecs(sExp, iMaxSecs="")
	{
		aSecs := []
		for sec in this
		{
			if (RegExMatch(sec, sExp))
			{
				aSecs.Insert(sec)
				if (iMaxSecs&& aSecs.MaxIndex() == iMaxSecs)
					return aSecs
			}
		}
		return aSecs
	}

	AddKey(sec, key, val="", ByRef rsError="")
	{
		if (this.HasKey(sec))
		{
			if (this[sec].HasKey(key))
			{
				rsError := "Error! Could not add key because there is an key in the same section:`n`[" sec "]`n" key
				return false
			}
		}
		else
		{
			rsError := "Error! Could not add key`, " key " because Section " sec " does not exist."
			return false
		}
		this[sec, key] := val
		return true
	}

	RenameKey(sec, OldKey, NewKey, ByRef rsError="")
	{
		if (!this[sec].HasKey(OldKey))
		{
			rsError := "Error! The specified key " OldKey " could not be modified because it does not exist."
			return false
		}

		ValCopy := this[sec][OldKey]
		this.DeleteKey(sec, OldKey)
		this.AddKey(sec, NewKey)
		this[sec][NewKey] := ValCopy
		return true
	}

	DeleteKey(sec, key)
	{
		this[sec].Remove(key)
		return
	}

	GetKeys(sec, sDelim="`n")
	{
		for key in this[sec]
			keys .= A_Index == 1 ? key : sDelim key
		return keys
	}

	FindKeys(sec, sExp, iMaxKeys="")
	{
		aKeys := []
		for key in this[sec]
		{
			if (RegExMatch(key, sExp))
			{
				aKeys.Insert(key)
				if (iMaxKeys && aKeys.MaxIndex() == iMaxKeys)
					return aKeys
			}
		}
		return aKeys
	}

	GetVals(sec, sDelim="`n")
	{
		for key, val in this[sec]
			vals .= A_Index == 1 ? val : sDelim val
		return vals
	}

	FindVals(sec, sExp, iMaxVals="")
	{
		aVals := []
		for key, val in this[sec]
		{
			if (RegExMatch(val, sExp))
			{
				aVals.Insert(val)
				if (iMaxVals && aVals.MaxIndex() == iMaxVals)
					break
			}
		}
		return aVals
	}

	HasVal(sec, FindVal)
	{
		for k, val in this[sec]
			if (FindVal = val)
				return true
		return false
	}

	Copy(vSourceIni, sDestIniFile="")
	{
		this := vSourceIni
		this.EasyXML_ReservedFor_m_sFile := sDestIniFile
		return this
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;; Merge two EasyXML objects. Favors existing EasyXML object, meaning that any key that exists in both objects keeps the original val
	;;;;;;;;;;;;;; UNDER CONSTRUCTION
	Merge(vOtherIni, bRemoveNonMatching = false)
	{
		; TODO: Perhaps just save one ini, read it back in, and then perform merging? I think this would help with formatting.
		; [Sections]
		for sec, aKeysAndVals in vOtherIni
		{
			if (!this.HasKey(sec))
				if (bRemoveNonMatching)
					this.DeleteSection(sec)
				else this.AddSection(sec)

			; key=val
			for key, val in aKeysAndVals
				if (!this[sec].HasKey(key))
					if (bRemoveNonMatching)
						this.DeleteKey(sec, key)
					else this.AddKey(sec, key, val)
		}
		return
	}
	;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	Save()
	{
		; Formatting is preserved in ini object
		FileDelete, % this.EasyXML_ReservedFor_m_sFile

		for k, v in this.EasyXML_ReservedFor_TopComments
			FileAppend, % (A_Index == 1 ? "" : "`n") (v == Chr(14) ? "" : v), % this.EasyXML_ReservedFor_m_sFile

		bIsFirstLine := !FileExist(this.EasyXML_ReservedFor_m_sFile)
		for section, aKeysAndVals in this
		{
			FileAppend, % (bIsFirstLine ? "[" : "`n[") section "]", % this.EasyXML_ReservedFor_m_sFile
			bIsFirstLine := false

			bEmptySection := true
			for key, val in aKeysAndVals
			{
				bEmptySection := false
				FileAppend, `n%key%=%val%, % this.EasyXML_ReservedFor_m_sFile

				; Add the comment(s) for this key
				sComments := this[section].EasyXML_ReservedFor_Comments[key]
				Loop, Parse, sComments, `n
					FileAppend, % "`n" (A_LoopField == Chr(14) ? "" : A_LoopField), % this.EasyXML_ReservedFor_m_sFile
			}
			if (bEmptySection)
			{
				; An empy section may contain comments...
				sComments := this[section].EasyXML_ReservedFor_Comments["SectionComment"]
				Loop, Parse, sComments, `n
					FileAppend, % "`n" (A_LoopField == Chr(14) ? "" : A_LoopField), % this.EasyXML_ReservedFor_m_sFile
			}
		}
		return
	}
}

; For all of the EasyXML_* functions below, much credit is due to Lexikos and Rbrtryn for their work with ordered arrays
; See http://www.autohotkey.com/board/topic/61792-ahk-l-for-loop-in-order-of-key-value-pair-creation/?p=389662 for Lexikos's initial work with ordered arrays
; See http://www.autohotkey.com/board/topic/94043-ordered-array/#entry592333 for Rbrtryn's OrderedArray lib
EasyXML_CreateBaseObj(parms*){
	; Define prototype object for ordered arrays:
	static base := {__Set: "EasyXML_Set", _NewEnum: "EasyXML_NewEnum", Remove: "EasyXML_Remove", Insert: "EasyXML_Insert", InsertBefore: "EasyXML_InsertBefore"}
	; Create and return new base object:
	return Object("_keys", Object(), "base", base, parms*)
}

EasyXML_Set(obj, parms*){
	; If this function is called, the key must not already exist.
	; Sub-class array if necessary then add this new key to the key list, if it doesn't begin with "EasyXML_ReservedFor_"
	if parms.maxindex() > 2
		ObjInsert(obj, parms[1], EasyXML_CreateBaseObj())

	; Skip over member variables
	if (SubStr(parms[1], 1, 20) <> "EasyXML_ReservedFor_")
		ObjInsert(obj._keys, parms[1])
	; Since we don't return a value, the default behaviour takes effect.
	; That is, a new key-value pair is created and stored in the object.
}

EasyXML_NewEnum(obj){
	; Define prototype object for custom enumerator:
	static base := Object("Next", "EasyXML_EnumNext")
	; Return an enumerator wrapping our _keys array's enumerator:
	return Object("obj", obj, "enum", obj._keys._NewEnum(), "base", base)
}

EasyXML_EnumNext(e, ByRef k, ByRef v=""){
	; If Enum.Next() returns a "true" value, it has stored a key and
	; value in the provided variables. In this case, "i" receives the
	; current index in the _keys array and "k" receives the value at
	; that index, which is a key in the original object:
	if r := e.enum.Next(i,k)
		; We want it to appear as though the user is simply enumerating
		; the key-value pairs of the original object, so store the value
		; associated with this key in the second output variable:
		v := e.obj[k]
	return r
}

EasyXML_Remove(obj, parms*){
	r := ObjRemove(obj, parms*)         ; Remove keys from main object
	Removed := []
	for k, v in obj._keys             ; Get each index key pair
		if not ObjHasKey(obj, v)      ; if key is not in main object
			Removed.Insert(k)         ; Store that keys index to be removed later
	for k, v in Removed               ; For each key to be removed
		ObjRemove(obj._keys, v, "")   ; remove that key from key list
	return r
}

EasyXML_Insert(obj, parms*){
	r := ObjInsert(obj, parms*)            ; Insert keys into main object
	enum := ObjNewEnum(obj)              ; Can't use for-loop because it would invoke EasyXML_NewEnum
	while enum[k] {                      ; For each key in main object
		for i, kv in obj._keys           ; Search for key in obj._keys
			if (k = "_keys" || k = kv || SubStr(k, 1, 20) = "EasyXML_ReservedFor_" || SubStr(kv, 1, 20) = "EasyXML_ReservedFor_")   ; If found...
				continue 2               ; Get next key in main object
		ObjInsert(obj._keys, k)          ; Else insert key into obj._keys
	}
	return r
}

EasyXML_InsertBefore(obj, key, parms*){
	OldKeys := obj._keys                 ; Save key list
	obj._keys := []                      ; Clear key list
	for idx, k in OldKeys {              ; Put the keys before key
		if (k = key)                     ; back into key list
			break
		obj._keys.Insert(k)
	}

	r := ObjInsert(obj, parms*)            ; Insert keys into main object
	enum := ObjNewEnum(obj)              ; Can't use for-loop because it would invoke EasyXML_NewEnum
	while enum[k] {                      ; For each key in main object
		for i, kv in OldKeys             ; Search for key in OldKeys
			if (k = "_keys" || k = kv)   ; If found...
				continue 2               ; Get next key in main object
		ObjInsert(obj._keys, k)          ; Else insert key into obj._keys
	}

	for i, k in OldKeys {                ; Put the keys after key
		if (i < idx)                     ; back into key list
			continue
		obj._keys.Insert(k)
	}
	return r
}