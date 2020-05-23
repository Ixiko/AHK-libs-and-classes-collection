class_EasyCSV(sFile="", sLoadFromStr="", bHasHeader=false)
{
	return new EasyCSV(sFile, sLoadFromStr, bHasHeader)
}

class EasyCSV
{
	__New(sFile="", sLoadFromStr="", bHasHeader=false) ; Loads ths file into memory.
	{
		this := this.CreateCSVObj("EasyCSV_ReservedFor_m_sFile", sFile
			, "EasyCSV_ReservedFor_m_bHasHeader", bHasHeader)

		if (sFile == A_Blank && sLoadFromStr == A_Blank)
			return this

		if (SubStr(sFile, StrLen(sFile)-3, 4) != ".csv")
			this.EasyIni_ReservedFor_m_sFile := sFile := (sFile . ".csv")

		sCSV := sLoadFromStr
		if (sCSV == A_Blank)
			FileRead, sCSV, %sFile%
/*
	Current design:
	--------------------------------------------------------------------------------------------------------------------------------------------------
	Standard AHK CSV parsing pretty much completely determines how fields are read in
	Here's an example of how the data will be mapped and how you can manipulate it
	header1, header2
	Field1    ,  Field2
	Field1    ,  Field2
	; TODO: Store by column, then row.
		This is because there *must* be a row for each column,
		 but there doesn't have to be a column for each row.
	for iRow, aRowData in vCSV
		for iCol, val in aRowData
			Msgbox Row:`t%iRow%`nCol:`t%iCol%`nVal:`t%val%
	; OR
	iRow := 1
	iCol := 1
	vCSV[iRow][iCol] ; = Field1
	vCSV[iRow][iCol] := "NewField" ; Changes from Field1 to NewField
	; OR
	vCSV.1.1 ; = Field1
	vCSV.1.1 := "NewField" ; Changes from Field1 to NewField
	--------------------------------------------------------------------------------------------------------------------------------------------------
*/

		if (this.GetHasHeader())
			this[1, this.GetHeaderRow()] := ; This allows us to

		Loop, Parse, sCSV, `n, `r
		{
			iRow := A_Index
			Loop, Parse, A_LoopField, CSV
			{
				if (iRow == 1 && this.GetHasHeader())
					this[A_Index, this.GetHeaderRow()] := A_LoopField
				else this[A_Index, iRow] := A_LoopField
			}
		}

		return this
	}

	CreateCSVObj(parms*)
	{
		; Define prototype object for CSV arrays:
		static base := {__Set: "EasyCSV_Set", _NewEnum: "EasyCSV_NewEnum", Remove: "EasyCSV_Remove"
			, Insert: "EasyCSV_Insert" , InsertBefore: "EasyCSV_InsertBefore"
			; Cols
			, AddCol: "EasyCSV.AddCol", DeleteCol: "EasyCSV.DeleteCol", GetCol: "EasyCSV.GetCol", GetNumCols: "EasyCSV.GetNumCols"
			; Rows
			, AddRow: "EasyCSV.AddRow", DeleteRow: "EasyCSV.DeleteRow", GetRow: "EasyCSV.GetRow", GetNumRows: "EasyCSV.GetNumRows"
			, FindSecs: "EasyCSV.FindSecs", FindKeys: "EasyCSV.FindKeys", GetVals: "EasyCSV.GetVals", FindVals: "EasyCSV.FindVals"
			, HasVal: "EasyCSV.HasVal", Copy: "EasyCSV.Copy", Merge: "EasyCSV.Merge", Save: "EasyCSV.Save"
			, GetFileName: "EasyCSV.GetFileName", GetHasHeader: "EasyCSV.GetHasHeader", GetHeaderRow: "EasyCSV.GetHeaderRow"}

		; Create and return new object:
		return Object("_keys", Object(), "base", base, parms*)
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: AddCol
			Purpose: To add a column
		Parameters
			sHeader="": Should only be non-blank when EasyCSV has been set to have a header.
			rsError
	*/
	AddCol(sHeader="", ByRef rsError="")
	{
		; TODO: Int/Header support (I'm thinking headers are stored at 0, and they may be referenced literally).
		; I think headers should be stored in a separate object, too.

		if (sHeader && !this.GetHasHeader())
		{
			rsError := "Error: trying to set header, """ sHeader """ on a non-header CSV object."
			return false
		}

		this.Insert(EasyCSV_CreateBaseObj())
		iCol := this.MaxIndex()

		if (sHeader)
			this[iCol, this.GetHeaderRow()] := sHeader

		return iCol
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: DeleteCol
			Purpose: To delete a column
		Parameters
			iCol: Column to delete
	*/
	DeleteCol(iCol)
	{
		this.Remove(iCol)
		return
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: GetCol
			Purpose: Gets data for iCol
		Parameters
			iCol
			sDelim=","
	*/
	GetCol(iCol, sDelim=",")
	{
		for iRow, cell in this[iCol]
			sCol .= (A_Index > 1 ? sDelim : "") . cell

		return sCol
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: GetNumCols
			Purpose:
		Parameters
			
	*/
	GetNumCols()
	{
		return this.MaxIndex()
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: AddRow
			Purpose:
		Parameters
			rsError=""
	*/
	AddRow(ByRef rsError)
	{
		;~ for iCol in this
		; Adding one to every col takes a lot of time, and I don't think it is necessary.
		; However, I should verify this -- Verdlin: 5/26/14.
		this.1.Insert("") ; Insert adds new row.

		iRow := this.1.MaxIndex()
		if (iRow == A_Blank)
		{
			rsError := "Error: Thre is no row for column 1.`nThis usually happens when you have not added a column first."
			return
		}
		return iRow
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: DeleteRow
			Purpose: Deletes a iRow from *all* columns, of course.
		Parameters
			iRow
	*/
	DeleteRow(iRow)
	{
		if (!this.1.HasKey(iRow))
			return ; Nothing to delete.

		for iCol, in this
			this[iCol].Remove(iRow)
		return
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: GetRow
			Purpose: Gets data for iRow
		Parameters
			iRow
			sDelim=","
			bForSave=false: When saving, we need to surround each cell with quotations to escape commas and the like
	*/
	GetRow(iRow, sDelim=",", bForSave=false)
	{
		for iCol, aRowData in this
		{
			sRow .= (sRow == A_Blank ? "" : sDelim)
			if (bForSave)
			{
				sRowData := aRowData[iRow]
				StringReplace, sRowData, sRowData, `", `"`", All
				sRow .= """" sRowData """"
			}
			else sRow .= aRowData[iRow]
		}

		return sRow
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: GetNumRows
			Purpose: Returns total number of rows.
		Parameters
			
	*/
	GetNumRows()
	{
		iRows := this.1.MaxIndex()
		if (this.GetHasHeader)
			iRows++
		return iRows
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

	Copy(vSourceCSV, sDestCSVFile="")
	{
		this := vSourceCSV
		this.EasyCSV_ReservedFor_m_sFile := sDestCSVFile
		return this
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;; Merge two EasyCSV objects. Favors existing EasyCSV object, meaning that any key that exists in both objects keeps the original val
	;;;;;;;;;;;;;; UNDER CONSTRUCTION
	Merge(vOtherCSV, bRemoveNonMatching = false)
	{
		; TODO: Perhaps just save one CSV, read it back in, and then perform merging? I think this would help with formatting.
		; [Sections]
		for sec, aKeysAndVals in vOtherCSV
		{
			if (!this.HasKey(sec))
				if (bRemoveNonMatching)
					this.DeleteRow(sec)
				else this.AddSection(sec)

			; key=val
			for key, val in aKeysAndVals
				if (!this[sec].HasKey(key))
					if (bRemoveNonMatching)
						this.DeleteKey(sec, key)
					else this.AddCol(sec, key, val)
		}
		return
	}
	;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: GetFileName
			Purpose: Wrapper to return the extremely long named member var, EasyCSV_ReservedFor_m_sFile
		Parameters
			None
	*/
	GetFileName()
	{
		return this.EasyCSV_ReservedFor_m_sFile
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: GetHasHeader
			Purpose: Wrapper to return the extremely long named member var, EasyCSV_ReservedFor_m_bHasHeader
		Parameters
			
	*/
	GetHasHeader()
	{
		return this.EasyCSV_ReservedFor_m_bHasHeader
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: GetHeaderRow
			Purpose: To keep hard-coding for header row in one place.
		Parameters
			
	*/
	GetHeaderRow()
	{
		return 0
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: IsEmpty
			Purpose: To indicate whether or not this csv has data
		Parameters
			None
	*/
	IsEmpty()
	{
		return (this.GetColumns() == A_Blank) ; No columns.
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: Reload
			Purpose: Reloads object from csv file. This is necessary when other routines may be modifying the same csv file.
		Parameters
			None
	*/
	Reload()
	{
		if (FileExist(this.GetFileName()))
			this := class_EasyCSV(this.GetFileName(), this.GetHasHeader())
		return this ; else nothing to reload.
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; TODO: Option to store load and save times in comment at bottom of CSV?
	Save(sSaveAs="")
	{
		sFile := (sSaveAs == A_Blank ? this.EasyCSV_ReservedFor_m_sFile : sSaveAs)

		if (SubStr(sFile, StrLen(sFile)-3, 4) != ".csv")
			sFile .= ".csv"

		; Formatting is preserved in CSV class object
		FileDelete, %sFile%
		bIsFirstLine := true
		iRows := this.GetNumRows()
		Loop %iRows%
		{
			iRow := (this.GetHasHeader() ? A_Index - 1 : A_Index)
			sRow := this.GetRow(iRow, ",", true)

			if (bIsFirstLine)
				FileAppend, %sRow%, %sFile%
			else FileAppend, `n%sRow%, %sFile%

			bIsFirstLine := false
		}

		return
	}
}

; For all of the EasyCSV_* functions below, much credit is due to Lexikos and Rbrtryn for their work with ordered arrays
; See http://www.autohotkey.com/board/topic/61792-ahk-l-for-loop-in-order-of-key-value-pair-creation/?p=389662 for Lexikos's initial work with ordered arrays
; See http://www.autohotkey.com/board/topic/94043-ordered-array/#entry592333 for Rbrtryn's OrderedArray lib
EasyCSV_CreateBaseObj(parms*)
{
	; Define prototype object for ordered arrays:
	static base := {__Set: "EasyCSV_Set", _NewEnum: "EasyCSV_NewEnum", Remove: "EasyCSV_Remove", Insert: "EasyCSV_Insert", InsertBefore: "EasyCSV_InsertBefore"}
	; Create and return new base object:
	return Object("_keys", Object(), "base", base, parms*)
}

EasyCSV_Set(obj, parms*)
{
	; If this function is called, the key must not already exist.
	; Sub-class array if necessary then add this new key to the key list, if it doesn't begin with "EasyCSV_ReservedFor_"
	if parms.maxindex() > 2
		ObjInsert(obj, parms[1], EasyCSV_CreateBaseObj())

	; Skip over member variables
	if (SubStr(parms[1], 1, 20) <> "EasyCSV_ReservedFor_")
		ObjInsert(obj._keys, parms[1])
	; Since we don't return a value, the default behaviour takes effect.
	; That is, a new key-value pair is created and stored in the object.
}

EasyCSV_NewEnum(obj)
{
	; Define prototype object for custom enumerator:
	static base := Object("Next", "EasyCSV_EnumNext")
	; Return an enumerator wrapping our _keys array's enumerator:
	return Object("obj", obj, "enum", obj._keys._NewEnum(), "base", base)
}

EasyCSV_EnumNext(e, ByRef k, ByRef v="")
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

EasyCSV_Remove(obj, parms*)
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

EasyCSV_Insert(obj, parms*)
{
	r := ObjInsert(obj, parms*)            ; Insert keys into main object
	enum := ObjNewEnum(obj)              ; Can't use for-loop because it would invoke EasyCSV_NewEnum
	while enum[k] {                      ; For each key in main object
		for i, kv in obj._keys           ; Search for key in obj._keys
			if (k = "_keys" || k = kv || SubStr(k, 1, 20) = "EasyCSV_ReservedFor_" || SubStr(kv, 1, 20) = "EasyCSV_ReservedFor_")   ; If found...
				continue 2               ; Get next key in main object
		ObjInsert(obj._keys, k)          ; Else insert key into obj._keys
	}
	return r
}

EasyCSV_InsertBefore(obj, key, parms*)
{
	OldKeys := obj._keys                 ; Save key list
	obj._keys := []                      ; Clear key list
	for idx, k in OldKeys {              ; Put the keys before key
		if (k = key)                     ; back into key list
			break
		obj._keys.Insert(k)
	}

	r := ObjInsert(obj, parms*)            ; Insert keys into main object
	enum := ObjNewEnum(obj)              ; Can't use for-loop because it would invoke EasyCSV_NewEnum
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