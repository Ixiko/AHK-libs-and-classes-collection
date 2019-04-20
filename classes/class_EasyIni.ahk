class_EasyIni(sFile="", sLoadFromStr="")
{
	return new EasyIni(sFile, sLoadFromStr)
}

class EasyIni
{
	__New(sFile="", sLoadFromStr="") ; Loads ths file into memory.
	{
		this := this.CreateIniObj("EasyIni_ReservedFor_m_sFile", sFile
			, "EasyIni_ReservedFor_TopComments", Object()) ; Top comments can be stored in linear array because order will simply be numeric

		if (sFile == A_Blank && sLoadFromStr == A_Blank)
			return this

		; Append ".ini" if it is not already there.
		if (SubStr(sFile, StrLen(sFile)-3, 4) != ".ini")
			this.EasyIni_ReservedFor_m_sFile := sFile := (sFile . ".ini")

		sIni := sLoadFromStr
		if (sIni == A_Blank)
			FileRead, sIni, %sFile%

/*
	Current design (not fully implemented):
	---------------------------------------------------------------------------------------------------------------------------------------------------
	Comments at the top of the section apply to the file as a whole. They are keyed off an internal section called "EasyIni_ReservedFor_TopComments."
	Comments above section headers apply to the the last key of the previous section.
	If a comment appears between two keys, then it will apply to the key above it -- this is consistent with the solution for comments above section headers.
	Newlines will be stored in similar fashion to comments.
	---------------------------------------------------------------------------------------------------------------------------------------------------

	---------------------------------------------------------------------------------------------------------------------------------------------------
	If full-support for comments needs to be added, then the design below should supersede the design above.
	By saying, "Full-support" I mean a way to directly access these comments based upon sections and keys.
	---------------------------------------------------------------------------------------------------------------------------------------------------

	---------------------------------------------------------------------------------------------------------------------------------------------------
	Comments at the top of the section apply to the file as a whole. They are keyed off an internal section called "EasyIni_ReservedFor_TopComments."
	Comments above section headers apply to the section header. If people dislike this, I may instead chose to make the comments apply to the last key of the previous section if there a newline in-between the comment in question and the next section. I may come up with some decent solution as I experiment
	If a comment appears between two keys, then it will apply to the key below it -- this is consistent with the solution for comments above section headers.
	Newlines will be stored in similar fashion to comments.
	---------------------------------------------------------------------------------------------------------------------------------------------------
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
					this.EasyIni_ReservedFor_TopComments.Insert(A_Index, LoopField) ; not using sTrimmedLine so as to keep comment formatting
				else
				{
					if (sPrevKeyForThisSec == A_Blank) ; This happens when there is a comment in the section before the first key, if any
						sPrevKeyForThisSec := "SectionComment"

					if (IsObject(this[sCurSec].EasyIni_ReservedFor_Comments))
					{
						if (this[sCurSec].EasyIni_ReservedFor_Comments.HasKey(sPrevKeyForThisSec))
							this[sCurSec].EasyIni_ReservedFor_Comments[sPrevKeyForThisSec] .= "`n" LoopField
						else this[sCurSec].EasyIni_ReservedFor_Comments.Insert(sPrevKeyForThisSec, LoopField)
					}
					else
					{
						if (IsObject(this[sCurSec]))
							this[sCurSec].EasyIni_ReservedFor_Comments := {(sPrevKeyForThisSec):LoopField}
						else this[sCurSec, "EasyIni_ReservedFor_Comments"] := {(sPrevKeyForThisSec):LoopField}
					}
				}
				continue
			}

			; [Section]
			if (SubStr(sTrimmedLine, 1, 1) = "[" && InStr(sTrimmedLine, "]")) ; need to be sure that this isn't just a key starting with "["
			{
				if (sCurSec != A_Blank && !this.HasKey(sCurSec))
					this[sCurSec] := EasyIni_CreateBaseObj()
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
			this[sCurSec] := EasyIni_CreateBaseObj()

		return this
	}

	CreateIniObj(parms*)
	{
		; Define prototype object for ini arrays:
		static base := {__Set: "EasyIni_Set", _NewEnum: "EasyIni_NewEnum", Delete: "Delete", Remove: "EasyIni_Remove", Insert: "EasyIni_Insert", InsertBefore: "EasyIni_InsertBefore", AddSection: "EasyIni.AddSection", RenameSection: "EasyIni.RenameSection", DeleteSection: "EasyIni.DeleteSection", GetSections: "EasyIni.GetSections", FindSecs: "EasyIni.FindSecs", AddKey: "EasyIni.AddKey", RenameKey: "EasyIni.RenameKey", DeleteKey: "EasyIni.DeleteKey", GetKeys: "EasyIni.GetKeys", FindKeys: "EasyIni.FindKeys", GetVals: "EasyIni.GetVals", FindVals: "EasyIni.FindVals", HasVal: "EasyIni.HasVal", Copy: "EasyIni.Copy", Merge: "EasyIni.Merge", GetFileName: "EasyIni.GetFileName", GetOnlyIniFileName:"EasyIni.GetOnlyIniFileName", IsEmpty:"EasyIni.IsEmpty", Reload: "EasyIni.Reload", GetIsSaved: "EasyIni.GetIsSaved", Save: "EasyIni.Save", ToVar: "EasyIni.ToVar"}
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
			this[sec] := EasyIni_CreateBaseObj()
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

		this[sNewSec] := this[sOldSec]
		this.DeleteSection(sOldSec)

		return true
	}

	DeleteSection(sec)
	{
		this.Remove(sec)
		return
	}

	GetSections(sDelim="`n", sSort="")
	{
		for sec in this
			secs .= (A_Index == 1 ? sec : sDelim sec)

		if (sSort)
			Sort, secs, D%sDelim% %sSort%

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
				rsError := "Error! Could not add key, " key " because there is a key in the same section:`nSection: " sec "`nKey: " key
				return false
			}
		}
		else
		{
			rsError := "Error! Could not add key, " key " because Section, " sec " does not exist."
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
		this[sec].Delete(key)
		return
	}

	GetKeys(sec, sDelim="`n", sSort="")
	{
		for key in this[sec]
			keys .= A_Index == 1 ? key : sDelim key

		if (sSort)
			Sort, keys, D%sDelim% %sSort%

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

	; Non-regex, exact match on key
	; returns key(s) and their assocationed section(s)
	FindExactKeys(key, iMaxKeys="")
	{
		aKeys := {}
		for sec, aData in this
		{
			if (aData.HasKey(key))
			{
				aKeys.Insert(sec, key)
				if (iMaxKeys && aKeys.MaxIndex() == iMaxKeys)
					return aKeys
			}
		}
		return aKeys
	}

	GetVals(sec, sDelim="`n", sSort="")
	{
		for key, val in this[sec]
			vals .= A_Index == 1 ? val : sDelim val

		if (sSort)
			Sort, vals, D%sDelim% %sSort%

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

	; SourceIni: May be EasyIni object or simply a path to an ini file.
	; bCopyFileName = true: Allow copying of data without copying the file name.
	Copy(SourceIni, bCopyFileName = true)
	{
		; Get ini as string.
		if (IsObject(SourceIni))
			sIniString := SourceIni.ToVar()
		else FileRead, sIniString, %SourceIni%

		; Effectively make this function static by allowing calls via EasyIni.Copy.
		if (IsObject(this))
		{
			if (bCopyFileName)
				sOldFileName := this.GetFileName()
			this := A_Blank ; avoid any copy constructor issues.

			; ObjClone doesn't work consistently. It's likely a problem with the meta-function overrides,
			; but this is a nice, quick hack.
			this := class_EasyIni(SourceIni.GetFileName(), sIniString)

			; Restore file name.
			this.EasyIni_ReservedFor_m_sFile := sOldFileName
		}
		else
			return class_EasyIni(bCopyFileName ? SourceIni.GetFileName() : "", sIniString)

		return this
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		STILL UNDER CONSTRUCTION. Need to handle comments, and then this will be complete.
		Function: Merge
			Purpose: Merge two EasyIni objects.
		Parameters
			vOtherIni: Other EasyIni object to merge with this.
			bRemoveNonMatching: If true, removes sections and keys that do not exist in both inis.
			bOverwriteMatching: If true, any key that exists in both objects will use the val from vOtherIni.
			vExceptionsIni: class_Easy ini object full of exceptions keys for secs. Any matching key will remain unchanged.
	*/
	Merge(vOtherIni, bRemoveNonMatching = false, bOverwriteMatching = false, vExceptionsIni = "")
	{
		; TODO: Perhaps just save one ini, read it back in, and then perform merging? I think this would help with formatting.
		; [Sections]
		for sec, aKeysToVals in vOtherIni
		{
			if (!this.HasKey(sec))
				if (bRemoveNonMatching)
					this.DeleteSection(sec)
				else this.AddSection(sec)

			; key=val
			for key, val in aKeysToVals
			{
				bMakeException := vExceptionsIni[sec].HasKey(key)

				if (this[sec].HasKey(key))
				{
					if (bOverwriteMatching && !bMakeException)
						this[sec, key] := val
				}
				else
				{
					if (bRemoveNonMatching && !bMakeException)
						this.DeleteKey(sec, key)
					else if (!bRemoveNonMatching)
						this.AddKey(sec, key, val)
				}
			}
		}
		return
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: GetFileName
			Purpose: Wrapper to return the extremely long named member var, EasyIni_ReservedFor_m_sFile
		Parameters
			None
	*/
	GetFileName()
	{
		return this.EasyIni_ReservedFor_m_sFile
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: GetFileName
			Purpose: Wrapper to return just the .ini name without the path.
		Parameters
			None
	*/
	GetOnlyIniFileName()
	{
		return SubStr(this.EasyIni_ReservedFor_m_sFile, InStr(this.EasyIni_ReservedFor_m_sFile,"\", false, -1)+1)
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: IsEmpty
			Purpose: To indicate whether or not this ini has data
		Parameters
			None
	*/
	IsEmpty()
	{
		return (this.GetSections() == A_Blank ; No sections.
			&& !this.EasyIni_ReservedFor_TopComments.HasKey(1)) ; and no comments.
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: Reload
			Purpose: Reloads object from ini file. This is necessary when other routines may be modifying the same ini file.
		Parameters
			None
	*/
	Reload()
	{
		if (FileExist(this.GetFileName()))
			this := class_EasyIni(this.GetFileName()) ; else nothing to reload.
		return this
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; TODO: Add option to store load and save times in comment at bottom of ini?
	Save(sSaveAs="", bWarnIfExist=false)
	{
		if (sSaveAs == A_Blank)
			sFile := this.GetFileName()
		else
		{
			sFile := sSaveAs

			; Append ".ini" if it is not already there.
			if (SubStr(sFile, StrLen(sFile)-3, 4) != ".ini")
				sFile .= ".ini"

			if (bWarnIfExist && FileExist(sFile))
			{
				MsgBox, 4,, The file "%sFile%" already exists.`n`nAre you sure that you want to overwrite it?
				IfMsgBox, No
					return false
			}
		}

		; Formatting is preserved in ini object.
		FileDelete, %sFile%

		bIsFirstLine := true
		for k, v in this.EasyIni_ReservedFor_TopComments
		{
			FileAppend, % (A_Index == 1 ? "" : "`n") (v == Chr(14) ? "" : v), %sFile%
			bIsFirstLine := false
		}

		for section, aKeysToVals in this
		{
			FileAppend, % (bIsFirstLine ? "[" : "`n[") section "]", %sFile%
			bIsFirstLine := false

			bEmptySection := true
			for key, val in aKeysToVals
			{
				bEmptySection := false
				FileAppend, `n%key%=%val%, %sFile%

				; Add the comment(s) for this key
				sComments := this[section].EasyIni_ReservedFor_Comments[key]
				Loop, Parse, sComments, `n
					FileAppend, % "`n" (A_LoopField == Chr(14) ? "" : A_LoopField), %sFile%
			}
			if (bEmptySection)
			{
				; An empy section may contain comments...
				sComments := this[section].EasyIni_ReservedFor_Comments["SectionComment"]
				Loop, Parse, sComments, `n
					FileAppend, % "`n" (A_LoopField == Chr(14) ? "" : A_LoopField), %sFile%
			}
		}
		return true
	}

	ToVar()
	{
		sTmpFile := "$$$EasyIni_Temp.ini"
		this.Save(sTmpFile, !A_IsCompiled)
		FileRead, sIniAsVar, %sTmpFile%
		FileDelete, %sTmpFile%
		return sIniAsVar
	}
}

; For all of the EasyIni_* functions below, much credit is due to Lexikos and Rbrtryn for their work with ordered arrays
; See http://www.autohotkey.com/board/topic/61792-ahk-l-for-loop-in-order-of-key-value-pair-creation/?p=389662 for Lexikos's initial work with ordered arrays
; See http://www.autohotkey.com/board/topic/94043-ordered-array/#entry592333 for Rbrtryn's OrderedArray lib
EasyIni_CreateBaseObj(parms*)
{
	; Define prototype object for ordered arrays:
	static base := {__Set: "EasyIni_Set", _NewEnum: "EasyIni_NewEnum", Delete: "Delete", Remove: "EasyIni_Remove", Insert: "EasyIni_Insert", InsertBefore: "EasyIni_InsertBefore"}
	; Create and return new base object:
	return Object("_keys", Object(), "base", base, parms*)
}

EasyIni_Set(obj, parms*)
{
	; If this function is called, the key must not already exist.
	; Sub-class array if necessary then add this new key to the key list, if it doesn't begin with "EasyIni_ReservedFor_"
	if parms.maxindex() > 2
		ObjInsert(obj, parms[1], EasyIni_CreateBaseObj())

	; Skip over member variables
	if (SubStr(parms[1], 1, 20) <> "EasyIni_ReservedFor_")
		ObjInsert(obj._keys, parms[1])
	; Since we don't return a value, the default behaviour takes effect.
	; That is, a new key-value pair is created and stored in the object.
}

EasyIni_NewEnum(obj)
{
	; Define prototype object for custom enumerator:
	static base := Object("Next", "EasyIni_EnumNext")
	; Return an enumerator wrapping our _keys array's enumerator:
	return Object("obj", obj, "enum", obj._keys._NewEnum(), "base", base)
}

EasyIni_EnumNext(e, ByRef k, ByRef v="")
{
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

EasyIni_Remove(obj, parms*)
{
	r := ObjRemove(obj, parms*)         ; Remove keys from main object
	Removed := []                     
	for k, v in obj._keys             ; Get each index key pair
		if not ObjHasKey(obj, v)      ; if key is not in main object
			Removed.Insert(k)         ; Store that keys index to be removed later
	for k, v in Removed               ; For each key to be removed
		ObjRemove(obj._keys, v, "")   ; remove that key from key list

	return r
}

EasyIni_Insert(obj, parms*)
{
	r := ObjInsert(obj, parms*)            ; Insert keys into main object
	enum := ObjNewEnum(obj)              ; Can't use for-loop because it would invoke EasyIni_NewEnum
	while enum[k] {                      ; For each key in main object
		for i, kv in obj._keys           ; Search for key in obj._keys
			if (k = "_keys" || k = kv || SubStr(k, 1, 20) = "EasyIni_ReservedFor_" || SubStr(kv, 1, 20) = "EasyIni_ReservedFor_")   ; If found...
				continue 2               ; Get next key in main object
		ObjInsert(obj._keys, k)          ; Else insert key into obj._keys
	}

	return r
}

EasyIni_InsertBefore(obj, key, parms*)
{
	OldKeys := obj._keys                 ; Save key list
	obj._keys := []                      ; Clear key list
	for idx, k in OldKeys {              ; Put the keys before key
		if (k = key)                     ; back into key list
			break
		obj._keys.Insert(k)
	}

	r := ObjInsert(obj, parms*)            ; Insert keys into main object
	enum := ObjNewEnum(obj)              ; Can't use for-loop because it would invoke EasyIni_NewEnum
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