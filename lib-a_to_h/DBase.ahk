; #FUNCTION# ====================================================================================================================
; Name ..........: dBaseDll 1.0
; Description ...: create, read, write dBaseIII & dBaseIV dbf files
;                : create, read, write DBaseIII & dBaseIV dbt files
; Author ........: Jpam
; Modified ......: Modified by just me for AHK
; Email .........: ouderaa@zeelandnet.nl
; Lastupdate ....: 31-12-2015
; ===============================================================================================================================



; #Globals# =====================================================================================================================
; Version const
; ===============================================================================================================================
Global DBASEIII      := 0x03 ; dBaseIII w/o memo
Global DBASEIII_MEMO := 0x83 ; dBaseIII memo
Global DBASEIV       := 0x04 ; dBaseIV  w/o memo
Global DBASEIV_MEMO  := 0x8B ; dBaseIV  memo
#include %A_ScriptDir%\GuiAutomation\dbasedll.dll

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
; ===============================================================================================================================
DBase_CreateDBF(pFileName, bVersion) {

   Return DllCall("dbasedll.dll\CreateDBF", "Str", pFileName, "UChar", bVersion, "UPtr")

}

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
; ===============================================================================================================================
DBase_OpenDBF(pFileName) {

   Return DllCall("dbasedll.dll\OpenDBF", "Str", pFileName, "UPtr")

}

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
; ===============================================================================================================================
DBase_AddField(hBase, fldName, fldType, fldLen, fldDecimal, fldWorkAreaId, fldFlag) {

   DllCall("dbasedll.dll\AddField", "Ptr",    hBase
                                  , "Str",    fldName
                                  , "UChar",  Asc(fldType) ; (StringToBinary(fldType),
                                  , "UChar",  fldLen
                                  , "UChar",  fldDecimal
                                  , "UChar",  fldWorkAreaId
                                  , "UChar",  fldFlag)

}

; #FUNCTION# ====================================================================================================================
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
; ===============================================================================================================================
DBase_GetFieldName(hBase, fldNr) {

   pFldname := DllCall("dbasedll.dll\GetFieldName", "Ptr", hBase, "UInt", fldNr, "Str")
   Return pFldname

}

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
; ===============================================================================================================================
DBase_GetFieldType(hBase, fldNr) {

   pFldType := DllCall("dbasedll.dll\GetFieldType", "Ptr", hBase, "UInt", fldNr, "Str")
   Return pFldType

}

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
; ===============================================================================================================================
DBase_GetFieldLenght(hBase, fldNr) {

   pFldLen := DllCall("dbasedll.dll\GetFieldLenght", "Ptr",  hBase, "UInt", fldNr, "UInt")
   Return pFldLen

}

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
; ===============================================================================================================================
DBase_GetFieldDecimal(hBase, fldNr) {

   pFldDec := DllCall("dbasedll.dll\GetFieldDecimal", "Ptr", hBase, "UInt", fldNr, "UInt")
   Return pFldDec

}

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
; ===============================================================================================================================
DBase_GetRecordCount(hBase) {

   pRecCnt := DllCall("dbasedll.dll\GetRecordCount", "Ptr", hBase, "UInt")
   Return pRecCnt

}

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
; ===============================================================================================================================
DBase_GetFieldCount(hBase) {

   pFldCnt := DllCall("dbasedll.dll\GetFieldCount", "Ptr", hBase, "UInt")
   Return pFldCnt

}

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
; ===============================================================================================================================
DBase_AddRecord(hBase) {

   DllCall("dbasedll.dll\AddRecord", "Ptr", hBase)

}

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
; ===============================================================================================================================
DBase_GetSubRecord(hBase, recNr, fldNr) {

   pRec := DllCall("dbasedll.dll\GetSubRecord", "Ptr", hBase, "UInt", recNr, "UInt", fldNr, "Str")
   Return pRec

}

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
; ===============================================================================================================================
DBase_PutSubRecord(hBase, pValue, recNr, fldNr) {

   DllCall("dbasedll.dll\PutSubRecord", "Ptr", hBase, "Str", pValue, "UInt", recNr, "UInt", fldNr)

}

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
; ===============================================================================================================================
DBase_DeleteRecord(hBase, recNr) {

   DllCall("dbasedll.dll\DeleteRecord", "Ptr", hBase, "UInt", recNr)

}

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
; ===============================================================================================================================
DBase_UnDeleteRecord(hBase, recNr) {

   DllCall("dbasedll.dll\UnDeleteRecord", "Ptr", hBase, "UInt", recNr)

}

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
DBase_Search(hBase, pStr, fld, pBuf, len) {

   pRecArray := DllCall("dbasedll.dll\Search", "Ptr",  hBase
                                             , "Str",  pStr
                                             , "UInt", fld
                                             , "Ptr",  pBuf
                                             , "UInt", len
                                             , "Ptr")
   Return pRecArray

}

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
DBase_Pack(hBase) {

   DllCall("dbasedll.dll\Pack", "Ptr", hBase)

}

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
DBase_Zap(hBase) {

   DllCall("dbasedll.dll\Zap", "Ptr", hBase)

}

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
DBase_LoadMemo(hBase, recNr, fldNr) {

   pBuf = DllCall("dbasedll.dll\LoadMemo", "Ptr", hBase, "UInt", recNr, "UInt", fldNr, "Str")
   Return pBuf

}

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
DBase_WriteMemo(hBase, pMemo, recNr, fldNr) {

   DllCall("dbasedll.dll\WriteMemo", "Ptr", hBase, "Str", pMemo, "UInt", recNr, "UInt", fldNr)

}

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
DBase_CloseDBF(hBase) {
   DllCall("dbasedll.dll\CloseDBF", "Ptr", hBase)
}

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
DBase_LoadDLL(P*) {
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