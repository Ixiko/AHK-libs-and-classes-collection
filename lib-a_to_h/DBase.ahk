; #FUNCTION# ====================================================================================================================
; Name ..........	: dBaseDll 1.0
; Description ...	: create, read, write dBaseIII & dBaseIV dbf files
;                     	: create, read, write DBaseIII & dBaseIV dbt files
; Author ........	: Jpam
; Modified ......	: Modified by just me for AHK
; Email .........	: ouderaa@zeelandnet.nl
; Lastupdate ....	: 31-12-2015
; ====================================================================================================================
; #include-once

; OnAutoItExitRegister("Close_DLL")

; #Globals# =====================================================================================================================
; Version const
; ====================================================================================================================
Global DBASEIII          	:= 0x03 ; dBaseIII w/o memo
Global DBASEIII_MEMO:= 0x83 ; dBaseIII memo
Global DBASEIV           	:= 0x04 ; dBaseIV  w/o memo
Global DBASEIV_MEMO:= 0x8B ; dBaseIV  memo

dbasedll:= "\include\dbasedll.dll"

DBase_CreateDBF(pFileName, bVersion) {                                                                               	;-- creates new database file
/*
; #FUNCTION# ====================================================================================================================
; Name ..........: CreateDBF
; Description ...: creates new database file
; Syntax ........: CreateDBF(pFileName, bVersion)
; Parameters ....: pFileName          - filename for dbf
;                  bVersion           - version info $DBASEIII_MEMO / $DBASEIV_MEMO
; Return values .: handle to database
; Author ........: Jpam
; Modified ......:
; Remarks .......: CreateDBF creates automatic the dbt file if $DBASEIII_MEMO / $DBASEIV_MEMO is detected
; Related .......:
; Link ..........:
; Example .......: $hBase = CreateDBF("Sample.dbf", $DBASEIII_MEMO)
; ====================================================================================================================
*/
   Return DllCall("dbasedll.dll\CreateDBF", "Str", pFileName, "UChar", bVersion, "UPtr")

}

DBase_OpenDBF(pFileName) {
/*
; #FUNCTION# ====================================================================================================================
; Name ..........: OpenDBF
; Description ...:
; Syntax ........: OpenDBF(pFileName)
; Parameters ....: pFileName          - filename dbf file
; Return values .: Handle dbf file
; Author ........: Jpam
; Modified ......:
; Remarks .......: OpenDBF opens automatic the related dbt file if the file exist
; Related .......:
; Link ..........:
; Example .......: $hBase = OpenDBF("sample.dbf")
; ====================================================================================================================
*/
   Return DllCall(dbasedll . "\OpenDBF", "Str", pFileName, "UPtr")

}

DBase_AddField(hBase, fldName, fldType, fldLen, fldDecimal, fldWorkAreaId, fldFlag) {            	;-- add new field to dbf file
/*
; #FUNCTION# ====================================================================================================================
; Name ..........: AddField
; Description ...: add new field to dbf file
; Syntax ........: AddField(hBase, fldName, fldType, fldLen, fldDecimal, fldWorkAreaId, fldFlag)
; Parameters ....: hBase              - handle returned from CreateDBF
;                  fldName            - name for new field
;                  fldType            - Field type in ASCII (C, D, L, M, or N) (dBaseIII)
;                                     - Field type in ASCII (C, D, F, L, M, or N) (dBaseIV)
;                                     - Field type in ASCII (B, C, D, F, G, L, M, or N) (dBaseV for dos)
;                                     - Field type in ASCII (B, C, D, F, G, L, M, or N) (dBaseV for windows)
;                  fldLen             - field lenght in bytes
;                  fldDecimal         - decimal point location
;                  fldWorkAreaId      - mostly not used
;                  fldFlag            - mostly not used
; Return values .: None
; Author ........: Jpam
; Modified ......:
; Remarks .......: warning ! don't use AddField() if your dbf file allready has records, your database become corupted !
; Related .......:
; Link ..........:
; Example .......: AddField($hBase, "city", "C", 25, 0, 0, 0)
; ====================================================================================================================
*/
   DllCall("dbasedll.dll\AddField", "Ptr",    hBase
								  , "Str",    fldName
								  , "UChar",  Asc(fldType) ; (StringToBinary(fldType),
								  , "UChar",  fldLen
								  , "UChar",  fldDecimal
								  , "UChar",  fldWorkAreaId
								  , "UChar",  fldFlag)

}

DBase_GetFieldName(hBase, fldNr) {                                                                                      	;--  get the fieldname from fieldnumber
/*
; #FUNCTION# =======================================================================================================
; Name ..........: GetFieldName
; Description ...: get the fieldname from fieldnumber
; Syntax ........: GetFieldName(hBase, fldNr)
; Parameters ....: hBase              - handle returned from OpenDBF
;                  fldNr              - field number
; Return values .: pointer to buffer containing fieldname
; Author ........: Jpam
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: $fldName = GetFieldName($hBase, 5)
; ================================================================================================================
*/
   pFldname := DllCall("dbasedll.dll\GetFieldName", "Ptr", hBase, "UInt", fldNr, "Str")
   Return pFldname

}

DBase_GetFieldType(hBase, fldNr) {                                                                                       	;-- get the fieldtype from fieldnumber
/*
; #FUNCTION# ====================================================================================================================
; Name ..........: GetFieldType
; Description ...: get the fieldtype from fieldnumber
; Syntax ........: GetFieldType(hBase, fldNr)
; Parameters ....: hBase              - handle returned from OpenDBF
;                  fldNr              - field number
; Return values .: pointer to buffer containg the fieldtype
; Author ........: Jpam
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: $fldType = GetFieldType($hBase, 3)
; ===================================================================================================================
*/
   pFldType := DllCall("dbasedll.dll\GetFieldType", "Ptr", hBase, "UInt", fldNr, "Str")
   Return pFldType

}

DBase_GetFieldLenght(hBase, fldNr) {                                                                                    	;-- GetFieldLenght returns byte lenght from field
/*
; #FUNCTION# ====================================================================================================================
; Name ..........: GetFieldLenght
; Description ...: GetFieldLenght returns byte lenght from field
; Syntax ........: GetFieldLenght(hBase, fldNr)
; Parameters ....: hBase              - handle returned from OpenDBF
;                  fldNr              - field number
; Return values .: dword containing fieldlenght
; Author ........: Jpam
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: $fldLen = GetFieldLenght($hBase, 1)
; =================================================================================================================
*/
   pFldLen := DllCall("dbasedll.dll\GetFieldLenght", "Ptr",  hBase, "UInt", fldNr, "UInt")
   Return pFldLen

}

DBase_GetFieldDecimal(hBase, fldNr) {                                                                                 	;-- get decimal point location
/*
; #FUNCTION# ====================================================================================================================
; Name ..........: GetFieldDecimal
; Description ...: get decimal point location
; Syntax ........: GetFieldDecimal(hBase, fldNr)
; Parameters ....: hBase              - handle returned from OpenDBF
;                  fldNr              - field number
; Return values .: dword containing decimal point number
; Author ........: Jpam
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: $fldDec = GetFieldDecimal($hBase, 3)
; =====================================================================================================================
*/
   pFldDec := DllCall("dbasedll.dll\GetFieldDecimal", "Ptr", hBase, "UInt", fldNr, "UInt")
   Return pFldDec

}

DBase_GetRecordCount(hBase) {                                                                                             	;-- get the number of records in dbf file
/*
; #FUNCTION# ====================================================================================================================
; Name ..........: GetRecordCount
; Description ...: get the number of records in dbf file
; Syntax ........: GetRecordCount(hBase)
; Parameters ....: hBase              - handle returned from OpenDBF
; Return values .: dword containing number of records in dbf file
; Author ........: Jpam
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: $recCnt = GetRecordCount($hBase)
; ================================================================================================================
*/
   pRecCnt := DllCall("dbasedll.dll\GetRecordCount", "Ptr", hBase, "UInt")
   Return pRecCnt

}

DBase_GetFieldCount(hBase) {                                                                                                 	;-- get number of fields in dbf file
/*
; #FUNCTION# ====================================================================================================================
; Name ..........: GetFieldCount
; Description ...: get number of fields in dbf file
; Syntax ........: GetFieldCount(hBase)
; Parameters ....: hBase              - handle returned from OpenDBF
; Return values .: dword containing number of fields in dbf file
; Author ........: Jpam
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: #fldCnt = GetFieldCount($hBase)
; ==================================================================================================================
*/
   pFldCnt := DllCall("dbasedll.dll\GetFieldCount", "Ptr", hBase, "UInt")
   Return pFldCnt

}

DBase_AddRecord(hBase) {                                                                                                     	;-- write new blank record to dbf file
/*
; #FUNCTION# ====================================================================================================================
; Name ..........: AddRecord
; Description ...: write new blank record to dbf file
; Syntax ........: AddRecord(hBase)
; Parameters ....: hBase              - handle returned from CreateDBF or OpenDBF
; Return values .: None
; Author ........: Jpam
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: AddRecord($hBase)
; ====================================================================================================================
*/
   DllCall("dbasedll.dll\AddRecord", "Ptr", hBase)

}

DBase_GetSubRecord(hBase, recNr, fldNr) {                                                                          	;-- get record data
/*
; #FUNCTION# ====================================================================================================================
; Name ..........: GetSubRecord
; Description ...: get record data
; Syntax ........: GetSubRecord(hBase, recNr, fldNr)
; Parameters ....: hBase              - handle returned from OpenDBF
;                  recNr              - record number
;                  fldNr              - fieldnumber
; Return values .: pointer buffer containing record data (failure returns -1)
; Author ........: Jpam
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: $rec = GetSubRecord($hBase, 0, 2)
; ==========================================================================================================
*/
   pRec := DllCall("dbasedll.dll\GetSubRecord", "Ptr", hBase, "UInt", recNr, "UInt", fldNr, "Str")
   Return pRec

}

DBase_PutSubRecord(hBase, pValue, recNr, fldNr) {                                                               	;-- write sub record to database
/*
; #FUNCTION# ====================================================================================================================
; Name ..........: PutSubRecord
; Description ...: write sub record to database
; Syntax ........: PutSubRecord(hBase, pValue, recNr, fldNr)
; Parameters ....: hBase              - handle returned from CreateDBF or OpenDBF
;                  pValue             - value to write
;                  recNr              - record number
;                  fldNr              - fieldnumber
; Return values .: None
; Author ........: Jpam
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: PutSubRecord($hBase, "Amsterdam", 1, 2)
; =================================================================================================
*/
   DllCall("dbasedll.dll\PutSubRecord", "Ptr", hBase, "Str", pValue, "UInt", recNr, "UInt", fldNr)

}

DBase_DeleteRecord(hBase, recNr) {                                                                                      	;-- mark record as deleted
/*
; #FUNCTION# ====================================================================================================================
; Name ..........: DeleteRecord
; Description ...: mark record as deleted
; Syntax ........: DeleteRecord(hBase, recNr)
; Parameters ....: hBase              - handle returned from OpenDBF
;                  recNr              - record number
; Return values .: None
; Author ........: Jpam
; Modified ......:
; Remarks .......: use func Pack() to cleanup all deleted records
; Related .......:
; Link ..........:
; Example .......: DeleteRecord($hBase, 15)
; =====================================================================================================================
*/
   DllCall("dbasedll.dll\DeleteRecord", "Ptr", hBase, "UInt", recNr)

}

DBase_UnDeleteRecord(hBase, recNr) {                                                                                 	;-- unMark the marked record
/*
; #FUNCTION# ====================================================================================================================
; Name ..........: UnDeleteRecord
; Description ...: unMark the marked record
; Syntax ........: UnDeleteRecord(hBase, recNr)
; Parameters ....: hBase              - handle returned from OpenDBF
;                  recNr              - record number
; Return values .: None
; Author ........: Jpam
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: UnDeleteRecord($hBase, 15)
; ===========================================================================================================
*/
   DllCall("dbasedll.dll\UnDeleteRecord", "Ptr", hBase, "UInt", recNr)

}

DBase_Search(hBase, pStr, fld, pBuf, len) {                                                                             	;--  searches the database for an specified value
/*
; #FUNCTION# ====================================================================================================================
; Name ..........: Search
; Description ...: searches the database for an specified value
; Syntax ........: Search(hBase, pStr, fld, pBuf, len)
; Parameters ....: hBase              - handle returned from OpenDBF
;                  pStr               - pointer zero terminated string
;                  fld                - field number or -1
;                  pBuf               - pointer buffer created with DllStructCreate("DWORD[100]")
;                  len                - buffer length in bytes
; Return values .: number of records found in database
; Author ........: Jpam
; Modified ......:
; Remarks .......: pStr - can be number or alpha case-insensitive
;                  the dll supports wildcards * between chars or at the end of the string
;                  fld - need a field number to search specific field records or -1 to search the entire database
;                  fld - is protected in the dll for a valid field number , Search() will fail with error -1
;                  len - determine the amount of records you get returned from the dll
; Related .......:
; Link ..........:
; Example .......: $Array = DllStructCreate("DWORD[100]") *this buffer gives you a max of 100 results*
;                  $recCnt = Search($hDbf, "New York*", -1, DllStructGetPtr($Array), DllStructGetSize($Array))
;
;                  $Array = DllStructCreate("DWORD[400]") *the len para is set to 40, only 10 results are returned*
;                  $recCnt = Search($hDbf, "New York*", -1, DllStructGetPtr($Array), 40)
; ===============================================================================================================================
*/
   pRecArray := DllCall("dbasedll.dll\Search", "Ptr",  hBase
											 , "Str",  pStr
											 , "UInt", fld
											 , "Ptr",  pBuf
											 , "UInt", len
											 , "Ptr")
   Return pRecArray

}

DBase_Pack(hBase) {                                                                                                             	;-- deletes all marked records
/*
; #FUNCTION# ====================================================================================================================
; Name ..........: Pack
; Description ...: deletes all marked records
; Syntax ........: Pack(hBase)
; Parameters ....: hBase              - handle returned from OpenDBF
; Return values .: None
; Author ........: Jpam
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Pack($hBase)
; ===============================================================================================================================
*/
   DllCall("dbasedll.dll\Pack", "Ptr", hBase)

}

DBase_Zap(hBase) {                                                                                                              	;-- cleanup database, deletes all records
/*
; #FUNCTION# ====================================================================================================================
; Name ..........: Zap
; Description ...: cleanup database, deletes all records
; Syntax ........: Zap(hBase)
; Parameters ....: hBase              - handle returned from OpenDBF
; Return values .: None
; Author ........: Jpam
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:  Zap($hBase)
; ===============================================================================================================================
*/
   DllCall("dbasedll.dll\Zap", "Ptr", hBase)

}

DBase_LoadMemo(hBase, recNr, fldNr) {                                                                               	;--  load memo from dbt or fpt file
/*
; #FUNCTION# ====================================================================================================================
; Name ..........: LoadMemo
; Description ...: load memo from dbt or fpt file
; Syntax ........: LoadMemo(hBase, recNr, fldNr)
; Parameters ....: hBase              - handle returned from OpenDBF
;                  recNr              - record number
;                  fldNr              - field number
; Return values .: pointer buffer containing memo data
; Author ........: Jpam
; Modified ......:
; Remarks .......: internal code figures out by looking at the first byte of the dbf header if it's dealing with dbt or fpt memo files
; Related .......:
; Link ..........:
; Example .......: $memo = LoadMemo($hBase, $rec, $fld)
; ===============================================================================================================================
*/
   pBuf = DllCall("dbasedll.dll\LoadMemo", "Ptr", hBase, "UInt", recNr, "UInt", fldNr, "Str")
   Return pBuf

}

DBase_WriteMemo(hBase, pMemo, recNr, fldNr) {                                                                 	;-- write memo to dbt file and updates the dbf memo record with blockNumber
/*
; #FUNCTION# ====================================================================================================================
; Name ..........: WriteMemo
; Description ...: write memo to dbt file and updates the dbf memo record with blockNumber
; Syntax ........: WriteMemo(hBase, pMemo, recNr, fldNr)
; Parameters ....: hBase              - handle returned from OpenDBF
;                  pMemo              - data to write
;                  recNr              - record number
;                  fldNr              - field number
; Return values .: None
; Author ........: Jpam
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: WriteMemo($hBase, $Memo, 5, 3)
; ===============================================================================================================================
*/
   DllCall("dbasedll.dll\WriteMemo", "Ptr", hBase, "Str", pMemo, "UInt", recNr, "UInt", fldNr)

}

DBase_CloseDBF(hBase) {                                                                                                     	;-- closes the database
   /*
; #FUNCTION# ====================================================================================================================
; Name ..........: CloseDBF
; Description ...: closes the database
; Syntax ........: CloseDBF(hBase)
; Parameters ....: hBase              - handle returned from OpenDBF
; Return values .: None
; Author ........: Jpam
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: CloseDBF($hBase)
; ===============================================================================================================================
*/
   DllCall("dbasedll.dll\CloseDBF", "Ptr", hBase)
}

DBase_LoadDLL(P*) {                                                                                                            	;-- Loads the database.dll on start-up and unloads it automatically when the script exits.
/*
; DBase_Close_DLL() {
;
;    DllClose("dbasedll.dll\")
;
; }
; ===============================================================================================================================
; Name ..........: LoadDLL
; Description ...: Loads the database.dll on start-up and unloads it automatically when the script exits.
; Syntax ........: Do not call!!
; Parameters ....: None
; Return values .: None
; Author ........: just me
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: None
; ===============================================================================================================================
*/
   Static DBaseMod := 0
   Static Load := DBase_LoadDLL()
   If (DBaseMod = 0) {
	  If !(DBaseMod := DllCall("LoadLibrary", "Str", "dbasedll.dll", "UPtr")) {
		 MsgBox, 262160, %A_ThisFunc%, The dbasedll.dll could not be loaded!`n`nThe program will exit!
		 ExitApp
	  }
	  OnExit("DBase_LoadDLL")
   }
   Else
	  DllCall("FreeLibrary", "Ptr", DBaseMod)
}



