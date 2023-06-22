; ======================================================================================================================
; Function:         Class definitions as wrappers for SQLite3.dll to work with SQLite DBs.
; AHK version:      1.1.33.09
; Tested on:        Win 10 Pro (x64), SQLite 3.11.1
; Version:          0.0.01.00/2011-08-10/just me
;                   0.0.02.00/2012-08-10/just me   -  Added basic BLOB support
;                   0.0.03.00/2012-08-11/just me   -  Added more advanced BLOB support
;                   0.0.04.00/2013-06-29/just me   -  Added new methods AttachDB and DetachDB
;                   0.0.05.00/2013-08-03/just me   -  Changed base class assignment
;                   0.0.06.00/2016-01-28/just me   -  Fixed version check, revised parameter initialization.
;                   0.0.07.00/2016-03-28/just me   -  Added support for PRAGMA statements.
;                   0.0.08.00/2019-03-09/just me   -  Added basic support for application-defined functions
;                   0.0.09.00/2019-07-09/just me   -  Added basic support for prepared statements, minor bug fixes
;                   0.0.10.00/2019-12-12/just me   -  Fixed bug in EscapeStr method
;                   0.0.11.00/2021-10-10/just me   -  Removed statement checks in GetTable, Prepare, and Query
;                   0.0.12.00/2022-09-18/just me   -  Fixed bug for Bind - type text
;                   0.0.13.00/2022-10-03/just me   -  Fixed bug in Prepare
;                   0.0.14.00/2022-10-04/just me   -  Changed DllCall parameter type PtrP to UPtrP
; Remarks:          Names of "private" properties / methods are prefixed with an underscore,
;                   they must not be set / called by the script!
;
;                   SQLite3.dll file is assumed to be in the script's folder, otherwise you have to
;                   provide an INI-File SQLiteDB.ini in the script's folder containing the path:
;                   [Main]
;                   DllPath=Path to SQLite3.dll
;
;                   Encoding of SQLite DBs is assumed to be UTF-8
;                   Minimum supported SQLite3.dll version is 3.6
;                   Download the current version of SQLite3.dll (and also SQlite3.exe) from www.sqlite.org
; ======================================================================================================================
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from the
; use of this software.
; ======================================================================================================================
; CLASS SQliteDB - SQLiteDB main class
; ======================================================================================================================
Class SQLiteDB {
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; PRIVATE Properties and Methods ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   Static Version := ""
   Static _SQLiteDLL := A_ScriptDir . "\SQLite3.dll"
   Static _RefCount := 0
   Static _MinVersion := "3.6"
   ; ===================================================================================================================
   ; CLASS _Table
   ; Object returned from method GetTable()
   ; _Table is an independent object and does not need SQLite after creation at all.
   ; ===================================================================================================================
   Class _Table {
      ; ----------------------------------------------------------------------------------------------------------------
      ; CONSTRUCTOR  Create instance variables
      ; ----------------------------------------------------------------------------------------------------------------
      __New() {
          This.ColumnCount := 0          ; Number of columns in the result table         (Integer)
          This.RowCount := 0             ; Number of rows in the result table            (Integer)
          This.ColumnNames := []         ; Names of columns in the result table          (Array)
          This.Rows := []                ; Rows of the result table                      (Array of Arrays)
          This.HasNames := False         ; Does var ColumnNames contain names?           (Bool)
          This.HasRows := False          ; Does var Rows contain rows?                   (Bool)
          This._CurrentRow := 0          ; Row index of last returned row                (Integer)
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; METHOD GetRow      Get row for RowIndex
      ; Parameters:        RowIndex    - Index of the row to retrieve, the index of the first row is 1
      ;                    ByRef Row   - Variable to pass out the row array
      ; Return values:     On failure  - False
      ;                    On success  - True, Row contains a valid array
      ; Remarks:           _CurrentRow is set to RowIndex, so a subsequent call of NextRow() will return the
      ;                    following row.
      ; ----------------------------------------------------------------------------------------------------------------
      GetRow(RowIndex, ByRef Row) {
         Row := ""
         If (RowIndex < 1 || RowIndex > This.RowCount)
            Return False
         If !This.Rows.HasKey(RowIndex)
            Return False
         Row := This.Rows[RowIndex]
         This._CurrentRow := RowIndex
         Return True
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; METHOD Next        Get next row depending on _CurrentRow
      ; Parameters:        ByRef Row   - Variable to pass out the row array
      ; Return values:     On failure  - False, -1 for EOR (end of rows)
      ;                    On success  - True, Row contains a valid array
      ; ----------------------------------------------------------------------------------------------------------------
      Next(ByRef Row) {
         Row := ""
         If (This._CurrentRow >= This.RowCount)
            Return -1
         This._CurrentRow += 1
         If !This.Rows.HasKey(This._CurrentRow)
            Return False
         Row := This.Rows[This._CurrentRow]
         Return True
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; METHOD Reset       Reset _CurrentRow to zero
      ; Parameters:        None
      ; Return value:      True
      ; ----------------------------------------------------------------------------------------------------------------
      Reset() {
         This._CurrentRow := 0
         Return True
      }
   }
   ; ===================================================================================================================
   ; CLASS _RecordSet
   ; Object returned from method Query()
   ; The records (rows) of a recordset can be accessed sequentially per call of Next() starting with the first record.
   ; After a call of Reset() calls of Next() will start with the first record again.
   ; When the recordset isn't needed any more, call Free() to free the resources.
   ; The lifetime of a recordset depends on the lifetime of the related SQLiteDB object.
   ; ===================================================================================================================
   Class _RecordSet {
      ; ----------------------------------------------------------------------------------------------------------------
      ; CONSTRUCTOR  Create instance variables
      ; ----------------------------------------------------------------------------------------------------------------
      __New() {
         This.ColumnCount := 0         ; Number of columns                             (Integer)
         This.ColumnNames := []        ; Names of columns in the result table          (Array)
         This.HasNames := False        ; Does var ColumnNames contain names?           (Bool)
         This.HasRows := False         ; Does _RecordSet contain rows?                 (Bool)
         This.CurrentRow := 0          ; Index of current row                          (Integer)
         This.ErrorMsg := ""           ; Last error message                            (String)
         This.ErrorCode := 0           ; Last SQLite error code / ErrorLevel           (Variant)
         This._Handle := 0             ; Query handle                                  (Pointer)
         This._DB := {}                ; SQLiteDB object                               (Object)
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; DESTRUCTOR   Clear instance variables
      ; ----------------------------------------------------------------------------------------------------------------
      __Delete() {
         If (This._Handle)
            This.Free()
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; METHOD Next        Get next row of query result
      ; Parameters:        ByRef Row   - Variable to store the row array
      ; Return values:     On success  - True, Row contains the row array
      ;                    On failure  - False, ErrorMsg / ErrorCode contain additional information
      ;                                  -1 for EOR (end of records)
      ; ----------------------------------------------------------------------------------------------------------------
      Next(ByRef Row) {
         Static SQLITE_NULL := 5
         Static SQLITE_BLOB := 4
         Static EOR := -1
         Row := ""
         This.ErrorMsg := ""
         This.ErrorCode := 0
         If !(This._Handle) {
            This.ErrorMsg := "Invalid query handle!"
            Return False
         }
         RC := DllCall("SQlite3.dll\sqlite3_step", "Ptr", This._Handle, "Cdecl Int")
         If (ErrorLevel) {
            This.ErrorMsg := "DllCall sqlite3_step failed!"
            This.ErrorCode := ErrorLevel
            Return False
         }
         If (RC <> This._DB._ReturnCode("SQLITE_ROW")) {
            If (RC = This._DB._ReturnCode("SQLITE_DONE")) {
               This.ErrorMsg := "EOR"
               This.ErrorCode := RC
               Return EOR
            }
            This.ErrorMsg := This._DB.ErrMsg()
            This.ErrorCode := RC
            Return False
         }
         RC := DllCall("SQlite3.dll\sqlite3_data_count", "Ptr", This._Handle, "Cdecl Int")
         If (ErrorLevel) {
            This.ErrorMsg := "DllCall sqlite3_data_count failed!"
            This.ErrorCode := ErrorLevel
            Return False
         }
         If (RC < 1) {
            This.ErrorMsg := "Recordset is empty!"
            This.ErrorCode := This._DB._ReturnCode("SQLITE_EMPTY")
            Return False
         }
         Row := []
         Loop, %RC% {
            Column := A_Index - 1
            ColumnType := DllCall("SQlite3.dll\sqlite3_column_type", "Ptr", This._Handle, "Int", Column, "Cdecl Int")
            If (ErrorLevel) {
               This.ErrorMsg := "DllCall sqlite3_column_type failed!"
               This.ErrorCode := ErrorLevel
               Return False
            }
            If (ColumnType = SQLITE_NULL) {
               Row[A_Index] := ""
            } Else If (ColumnType = SQLITE_BLOB) {
               BlobPtr := DllCall("SQlite3.dll\sqlite3_column_blob", "Ptr", This._Handle, "Int", Column, "Cdecl UPtr")
               BlobSize := DllCall("SQlite3.dll\sqlite3_column_bytes", "Ptr", This._Handle, "Int", Column, "Cdecl Int")
               If (BlobPtr = 0) || (BlobSize = 0) {
                  Row[A_Index] := ""
               } Else {
                  Row[A_Index] := {}
                  Row[A_Index].Size := BlobSize
                  Row[A_Index].Blob := ""
                  Row[A_Index].SetCapacity("Blob", BlobSize)
                  Addr := Row[A_Index].GetAddress("Blob")
                  DllCall("Kernel32.dll\RtlMoveMemory", "Ptr", Addr, "Ptr", BlobPtr, "Ptr", BlobSize)
               }
            } Else {
               StrPtr := DllCall("SQlite3.dll\sqlite3_column_text", "Ptr", This._Handle, "Int", Column, "Cdecl UPtr")
               If (ErrorLevel) {
                  This.ErrorMsg := "DllCall sqlite3_column_text failed!"
                  This.ErrorCode := ErrorLevel
                  Return False
               }
               Row[A_Index] := StrGet(StrPtr, "UTF-8")
            }
         }
         This.CurrentRow += 1
         Return True
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; METHOD Reset       Reset the result pointer
      ; Parameters:        None
      ; Return values:     On success  - True
      ;                    On failure  - False, ErrorMsg / ErrorCode contain additional information
      ; Remarks:           After a call of this method you can access the query result via Next() again.
      ; ----------------------------------------------------------------------------------------------------------------
      Reset() {
         This.ErrorMsg := ""
         This.ErrorCode := 0
         If !(This._Handle) {
            This.ErrorMsg := "Invalid query handle!"
            Return False
         }
         RC := DllCall("SQlite3.dll\sqlite3_reset", "Ptr", This._Handle, "Cdecl Int")
         If (ErrorLevel) {
            This.ErrorMsg := "DllCall sqlite3_reset failed!"
            This.ErrorCode := ErrorLevel
            Return False
         }
         If (RC) {
            This.ErrorMsg := This._DB._ErrMsg()
            This.ErrorCode := RC
            Return False
         }
         This.CurrentRow := 0
         Return True
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; METHOD Free        Free query result
      ; Parameters:        None
      ; Return values:     On success  - True
      ;                    On failure  - False, ErrorMsg / ErrorCode contain additional information
      ; Remarks:           After the call of this method further access on the query result is impossible.
      ; ----------------------------------------------------------------------------------------------------------------
      Free() {
         This.ErrorMsg := ""
         This.ErrorCode := 0
         If !(This._Handle)
            Return True
         RC := DllCall("SQlite3.dll\sqlite3_finalize", "Ptr", This._Handle, "Cdecl Int")
         If (ErrorLevel) {
            This.ErrorMsg := "DllCall sqlite3_finalize failed!"
            This.ErrorCode := ErrorLevel
            Return False
         }
         If (RC) {
            This.ErrorMsg := This._DB._ErrMsg()
            This.ErrorCode := RC
            Return False
         }
         This._DB._Queries.Delete(This._Handle)
         This._Handle := 0
         This._DB := 0
         Return True
      }
   }
   ; ===================================================================================================================
   ; CLASS _Statement
   ; Object returned from method Prepare()
   ; The life-cycle of a prepared statement object usually goes like this:
   ; 1. Create the prepared statement object (PST) by calling DB.Prepare().
   ; 2. Bind values to parameters using the PST.Bind_*() methods of the statement object.
   ; 3. Run the SQL by calling PST.Step() one or more times.
   ; 4. Reset the prepared statement using PTS.Reset() then go back to step 2. Do this zero or more times.
   ; 5. Destroy the object using PST.Finalize().
   ; The lifetime of a prepared statement depends on the lifetime of the related SQLiteDB object.
   ; ===================================================================================================================
   Class _Statement {
      ; ----------------------------------------------------------------------------------------------------------------
      ; CONSTRUCTOR  Create instance variables
      ; ----------------------------------------------------------------------------------------------------------------
      __New() {
         This.ErrorMsg := ""           ; Last error message                            (String)
         This.ErrorCode := 0           ; Last SQLite error code / ErrorLevel           (Variant)
         This.ParamCount := 0          ; Number of SQL parameters for this statement   (Integer)
         This._Handle := 0             ; Query handle                                  (Pointer)
         This._DB := {}                ; SQLiteDB object                               (Object)
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; DESTRUCTOR   Clear instance variables
      ; ----------------------------------------------------------------------------------------------------------------
      __Delete() {
         If (This._Handle)
            This.Free()
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; METHOD Bind        Bind values to SQL parameters.
      ; Parameters:        Index       -  1-based index of the SQL parameter
      ;                    Type        -  type of the SQL parameter (currently: Blob/Double/Int/Text)
      ;                    Param3      -  type dependent value
      ;                    Param4      -  type dependent value
      ;                    Param5      -  not used
      ; Return values:     On success  - True
      ;                    On failure  - False, ErrorMsg / ErrorCode contain additional information
      ; ----------------------------------------------------------------------------------------------------------------
      Bind(Index, Type, Param3 := "", Param4 := 0, Param5 := 0) {
         Static SQLITE_STATIC := 0
         Static SQLITE_TRANSIENT := -1
         Static Types := {Blob: 1, Double: 1, Int: 1, Text: 1}
         This.ErrorMsg := ""
         This.ErrorCode := 0
         If !(This._Handle) {
            This.ErrorMsg := "Invalid statement handle!"
            Return False
         }
         If (Index < 1) || (Index > This.ParamCount) {
            This.ErrorMsg := "Invalid parameter index!"
            Return False
         }
         If (Types[Type] = "") {
            This.ErrorMsg := "Invalid parameter type!"
            Return False
         }
         If (Type = "Blob") { ; ----------------------------------------------------------------------------------------
            ; Param3 = BLOB pointer, Param4 = BLOB size in bytes
            If Param3 Is Not Integer
            {
               This.ErrorMsg := "Invalid blob pointer!"
               Return False
            }
            If Param4 Is Not Integer
            {
               This.ErrorMsg := "Invalid blob size!"
               Return False
            }
            ; Let SQLite always create a copy of the BLOB
            RC := DllCall("SQlite3.dll\sqlite3_bind_blob", "Ptr", This._Handle, "Int", Index, "Ptr", Param3
                        , "Int", Param4, "Ptr", -1, "Cdecl Int")
            If (ErrorLeveL) {
               This.ErrorMsg := "DllCall sqlite3_bind_blob failed!"
               This.ErrorCode := ErrorLevel
               Return False
            }
            If (RC) {
               This.ErrorMsg := This._ErrMsg()
               This.ErrorCode := RC
               Return False
            }
         }
         Else If (Type = "Double") { ; ---------------------------------------------------------------------------------
            ; Param3 = double value
            If Param3 Is Not Float
            {
               This.ErrorMsg := "Invalid value for double!"
               Return False
            }
            RC := DllCall("SQlite3.dll\sqlite3_bind_double", "Ptr", This._Handle, "Int", Index, "Double", Param3
                        , "Cdecl Int")
            If (ErrorLeveL) {
               This.ErrorMsg := "DllCall sqlite3_bind_double failed!"
               This.ErrorCode := ErrorLevel
               Return False
            }
            If (RC) {
               This.ErrorMsg := This._ErrMsg()
               This.ErrorCode := RC
               Return False
            }
         }
         Else If (Type = "Int") { ; ------------------------------------------------------------------------------------
            ; Param3 = integer value
            If Param3 Is Not Integer
            {
               This.ErrorMsg := "Invalid value for int!"
               Return False
            }
            RC := DllCall("SQlite3.dll\sqlite3_bind_int", "Ptr", This._Handle, "Int", Index, "Int", Param3
                        , "Cdecl Int")
            If (ErrorLeveL) {
               This.ErrorMsg := "DllCall sqlite3_bind_int failed!"
               This.ErrorCode := ErrorLevel
               Return False
            }
            If (RC) {
               This.ErrorMsg := This._ErrMsg()
               This.ErrorCode := RC
               Return False
            }
         }
         Else If (Type = "Text") { ; -----------------------------------------------------------------------------------
            ; Param3 = zero-terminated string
            This._DB._StrToUTF8(Param3, UTF8)
            ; Let SQLite always create a copy of the text
            RC := DllCall("SQlite3.dll\sqlite3_bind_text", "Ptr", This._Handle, "Int", Index, "Ptr", &UTF8
                        , "Int", -1, "Ptr", -1, "Cdecl Int")
            If (ErrorLeveL) {
               This.ErrorMsg := "DllCall sqlite3_bind_text failed!"
               This.ErrorCode := ErrorLevel
               Return False
            }
            If (RC) {
               This.ErrorMsg := This._ErrMsg()
               This.ErrorCode := RC
               Return False
            }
         }
         Return True
      }

      ; ----------------------------------------------------------------------------------------------------------------
      ; METHOD Step        Evaluate the prepared statement.
      ; Parameters:        None
      ; Return values:     On success  - True
      ;                    On failure  - False, ErrorMsg / ErrorCode contain additional information
      ; Remarks:           You must call ST.Reset() before you can call ST.Step() again.
      ; ----------------------------------------------------------------------------------------------------------------
      Step() {
         This.ErrorMsg := ""
         This.ErrorCode := 0
         If !(This._Handle) {
            This.ErrorMsg := "Invalid statement handle!"
            Return False
         }
         RC := DllCall("SQlite3.dll\sqlite3_step", "Ptr", This._Handle, "Cdecl Int")
         If (ErrorLevel) {
            This.ErrorMsg := "DllCall sqlite3_step failed!"
            This.ErrorCode := ErrorLevel
            Return False
         }
         If (RC <> This._DB._ReturnCode("SQLITE_DONE"))
         && (RC <> This._DB._ReturnCode("SQLITE_ROW")) {
            This.ErrorMsg := This._DB.ErrMsg()
            This.ErrorCode := RC
            Return False
         }
         Return True
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; METHOD Reset       Reset the prepared statement.
      ; Parameters:        ClearBindings  - Clear bound SQL parameter values (True/False)
      ; Return values:     On success     - True
      ;                    On failure     - False, ErrorMsg / ErrorCode contain additional information
      ; Remarks:           After a call of this method you can access the query result via Next() again.
      ; ----------------------------------------------------------------------------------------------------------------
      Reset(ClearBindings := True) {
         This.ErrorMsg := ""
         This.ErrorCode := 0
         If !(This._Handle) {
            This.ErrorMsg := "Invalid statement handle!"
            Return False
         }
         RC := DllCall("SQlite3.dll\sqlite3_reset", "Ptr", This._Handle, "Cdecl Int")
         If (ErrorLevel) {
            This.ErrorMsg := "DllCall sqlite3_reset failed!"
            This.ErrorCode := ErrorLevel
            Return False
         }
         If (RC) {
            This.ErrorMsg := This._DB._ErrMsg()
            This.ErrorCode := RC
            Return False
         }
         If (ClearBindings) {
            RC := DllCall("SQlite3.dll\sqlite3_clear_bindings", "Ptr", This._Handle, "Cdecl Int")
            If (ErrorLevel) {
               This.ErrorMsg := "DllCall sqlite3_clear_bindings failed!"
               This.ErrorCode := ErrorLevel
               Return False
            }
            If (RC) {
               This.ErrorMsg := This._DB._ErrMsg()
               This.ErrorCode := RC
               Return False
            }
         }
         Return True
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; METHOD Free        Free the prepared statement object.
      ; Parameters:        None
      ; Return values:     On success  - True
      ;                    On failure  - False, ErrorMsg / ErrorCode contain additional information
      ; Remarks:           After the call of this method further access on the statement object is impossible.
      ; ----------------------------------------------------------------------------------------------------------------
      Free() {
         This.ErrorMsg := ""
         This.ErrorCode := 0
         If !(This._Handle)
            Return True
         RC := DllCall("SQlite3.dll\sqlite3_finalize", "Ptr", This._Handle, "Cdecl Int")
         If (ErrorLevel) {
            This.ErrorMsg := "DllCall sqlite3_finalize failed!"
            This.ErrorCode := ErrorLevel
            Return False
         }
         If (RC) {
            This.ErrorMsg := This._DB._ErrMsg()
            This.ErrorCode := RC
            Return False
         }
         This._DB._Stmts.Delete(This._Handle)
         This._Handle := 0
         This._DB := 0
         Return True
      }
   }
   ; ===================================================================================================================
   ; CONSTRUCTOR __New
   ; ===================================================================================================================
   __New() {
      This._Path := ""                  ; Database path                                 (String)
      This._Handle := 0                 ; Database handle                               (Pointer)
      This._Queries := {}               ; Valid queries                                 (Object)
      This._Stmts := {}                 ; Valid prepared statements                     (Object)
      If (This.Base._RefCount = 0) {
         SQLiteDLL := This.Base._SQLiteDLL
         If !FileExist(SQLiteDLL)
            If FileExist(A_ScriptDir . "\SQLiteDB.ini") {
               IniRead, SQLiteDLL, %A_ScriptDir%\SQLiteDB.ini, Main, DllPath, %SQLiteDLL%
               This.Base._SQLiteDLL := SQLiteDLL
         }
         If !(DLL := DllCall("LoadLibrary", "Str", This.Base._SQLiteDLL, "UPtr")) {
            MsgBox, 16, SQLiteDB Error, % "DLL " . SQLiteDLL . " does not exist!"
            ExitApp
         }
         This.Base.Version := StrGet(DllCall("SQlite3.dll\sqlite3_libversion", "Cdecl UPtr"), "UTF-8")
         SQLVersion := StrSplit(This.Base.Version, ".")
         MinVersion := StrSplit(This.Base._MinVersion, ".")
         If (SQLVersion[1] < MinVersion[1]) || ((SQLVersion[1] = MinVersion[1]) && (SQLVersion[2] < MinVersion[2])){
            DllCall("FreeLibrary", "Ptr", DLL)
            MsgBox, 16, SQLite ERROR, % "Version " . This.Base.Version .  " of SQLite3.dll is not supported!`n`n"
                                      . "You can download the current version from www.sqlite.org!"
            ExitApp
         }
      }
      This.Base._RefCount += 1
   }
   ; ===================================================================================================================
   ; DESTRUCTOR __Delete
   ; ===================================================================================================================
   __Delete() {
      If (This._Handle)
         This.CloseDB()
      This.Base._RefCount -= 1
      If (This.Base._RefCount = 0) {
         If (DLL := DllCall("GetModuleHandle", "Str", This.Base._SQLiteDLL, "UPtr"))
            DllCall("FreeLibrary", "Ptr", DLL)
      }
   }
   ; ===================================================================================================================
   ; PRIVATE _StrToUTF8
   ; ===================================================================================================================
   _StrToUTF8(Str, ByRef UTF8) {
      VarSetCapacity(UTF8, StrPut(Str, "UTF-8"), 0)
      StrPut(Str, &UTF8, "UTF-8")
      Return &UTF8
   }
   ; ===================================================================================================================
   ; PRIVATE _UTF8ToStr
   ; ===================================================================================================================
   _UTF8ToStr(UTF8) {
      Return StrGet(UTF8, "UTF-8")
   }
   ; ===================================================================================================================
   ; PRIVATE _ErrMsg
   ; ===================================================================================================================
   _ErrMsg() {
      If (RC := DllCall("SQLite3.dll\sqlite3_errmsg", "Ptr", This._Handle, "Cdecl UPtr"))
         Return StrGet(&RC, "UTF-8")
      Return ""
   }
   ; ===================================================================================================================
   ; PRIVATE _ErrCode
   ; ===================================================================================================================
   _ErrCode() {
      Return DllCall("SQLite3.dll\sqlite3_errcode", "Ptr", This._Handle, "Cdecl Int")
   }
   ; ===================================================================================================================
   ; PRIVATE _Changes
   ; ===================================================================================================================
   _Changes() {
      Return DllCall("SQLite3.dll\sqlite3_changes", "Ptr", This._Handle, "Cdecl Int")
   }
   ; ===================================================================================================================
   ; PRIVATE _Returncode
   ; ===================================================================================================================
   _ReturnCode(RC) {
      Static RCODE := {SQLITE_OK: 0          ; Successful result
                     , SQLITE_ERROR: 1       ; SQL error or missing database
                     , SQLITE_INTERNAL: 2    ; NOT USED. Internal logic error in SQLite
                     , SQLITE_PERM: 3        ; Access permission denied
                     , SQLITE_ABORT: 4       ; Callback routine requested an abort
                     , SQLITE_BUSY: 5        ; The database file is locked
                     , SQLITE_LOCKED: 6      ; A table in the database is locked
                     , SQLITE_NOMEM: 7       ; A malloc() failed
                     , SQLITE_READONLY: 8    ; Attempt to write a readonly database
                     , SQLITE_INTERRUPT: 9   ; Operation terminated by sqlite3_interrupt()
                     , SQLITE_IOERR: 10      ; Some kind of disk I/O error occurred
                     , SQLITE_CORRUPT: 11    ; The database disk image is malformed
                     , SQLITE_NOTFOUND: 12   ; NOT USED. Table or record not found
                     , SQLITE_FULL: 13       ; Insertion failed because database is full
                     , SQLITE_CANTOPEN: 14   ; Unable to open the database file
                     , SQLITE_PROTOCOL: 15   ; NOT USED. Database lock protocol error
                     , SQLITE_EMPTY: 16      ; Database is empty
                     , SQLITE_SCHEMA: 17     ; The database schema changed
                     , SQLITE_TOOBIG: 18     ; String or BLOB exceeds size limit
                     , SQLITE_CONSTRAINT: 19 ; Abort due to constraint violation
                     , SQLITE_MISMATCH: 20   ; Data type mismatch
                     , SQLITE_MISUSE: 21     ; Library used incorrectly
                     , SQLITE_NOLFS: 22      ; Uses OS features not supported on host
                     , SQLITE_AUTH: 23       ; Authorization denied
                     , SQLITE_FORMAT: 24     ; Auxiliary database format error
                     , SQLITE_RANGE: 25      ; 2nd parameter to sqlite3_bind out of range
                     , SQLITE_NOTADB: 26     ; File opened that is not a database file
                     , SQLITE_ROW: 100       ; sqlite3_step() has another row ready
                     , SQLITE_DONE: 101}     ; sqlite3_step() has finished executing
      Return RCODE.HasKey(RC) ? RCODE[RC] : ""
   }
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; PUBLIC Interface ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; ===================================================================================================================
   ; Properties
   ; ===================================================================================================================
    ErrorMsg := ""              ; Error message                           (String)
    ErrorCode := 0              ; SQLite error code / ErrorLevel          (Variant)
    Changes := 0                ; Changes made by last call of Exec()     (Integer)
    SQL := ""                   ; Last executed SQL statement             (String)
   ; ===================================================================================================================
   ; METHOD OpenDB         Open a database
   ; Parameters:           DBPath      - Path of the database file
   ;                       Access      - Wanted access: "R"ead / "W"rite
   ;                       Create      - Create new database in write mode, if it doesn't exist
   ; Return values:        On success  - True
   ;                       On failure  - False, ErrorMsg / ErrorCode contain additional information
   ; Remarks:              If DBPath is empty in write mode, a database called ":memory:" is created in memory
   ;                       and deletet on call of CloseDB.
   ; ===================================================================================================================
   OpenDB(DBPath, Access := "W", Create := True) {
      Static SQLITE_OPEN_READONLY  := 0x01 ; Database opened as read-only
      Static SQLITE_OPEN_READWRITE := 0x02 ; Database opened as read-write
      Static SQLITE_OPEN_CREATE    := 0x04 ; Database will be created if not exists
      Static MEMDB := ":memory:"
      This.ErrorMsg := ""
      This.ErrorCode := 0
      HDB := 0
      If (DBPath = "")
         DBPath := MEMDB
      If (DBPath = This._Path) && (This._Handle)
         Return True
      If (This._Handle) {
         This.ErrorMsg := "You must first close DB " . This._Path . "!"
         Return False
      }
      Flags := 0
      Access := SubStr(Access, 1, 1)
      If (Access <> "W") && (Access <> "R")
         Access := "R"
      Flags := SQLITE_OPEN_READONLY
      If (Access = "W") {
         Flags := SQLITE_OPEN_READWRITE
         If (Create)
            Flags |= SQLITE_OPEN_CREATE
      }
      This._Path := DBPath
      This._StrToUTF8(DBPath, UTF8)
      RC := DllCall("SQlite3.dll\sqlite3_open_v2", "Ptr", &UTF8, "UPtrP", HDB, "Int", Flags, "Ptr", 0, "Cdecl Int")
      If (ErrorLevel) {
         This._Path := ""
         This.ErrorMsg := "DLLCall sqlite3_open_v2 failed!"
         This.ErrorCode := ErrorLevel
         Return False
      }
      If (RC) {
         This._Path := ""
         This.ErrorMsg := This._ErrMsg()
         This.ErrorCode := RC
         Return False
      }
      This._Handle := HDB
      Return True
   }
   ; ===================================================================================================================
   ; METHOD CloseDB        Close database
   ; Parameters:           None
   ; Return values:        On success  - True
   ;                       On failure  - False, ErrorMsg / ErrorCode contain additional information
   ; ===================================================================================================================
   CloseDB() {
      This.ErrorMsg := ""
      This.ErrorCode := 0
      This.SQL := ""
      If !(This._Handle)
         Return True
      For Each, Query in This._Queries
         DllCall("SQlite3.dll\sqlite3_finalize", "Ptr", Query, "Cdecl Int")
      RC := DllCall("SQlite3.dll\sqlite3_close", "Ptr", This._Handle, "Cdecl Int")
      If (ErrorLevel) {
         This.ErrorMsg := "DLLCall sqlite3_close failed!"
         This.ErrorCode := ErrorLevel
         Return False
      }
      If (RC) {
         This.ErrorMsg := This._ErrMsg()
         This.ErrorCode := RC
         Return False
      }
      This._Path := ""
      This._Handle := ""
      This._Queries := []
      Return True
   }
   ; ===================================================================================================================
   ; METHOD AttachDB       Add another database file to the current database connection
   ;                       http://www.sqlite.org/lang_attach.html
   ; Parameters:           DBPath      - Path of the database file
   ;                       DBAlias     - Database alias name used internally by SQLite
   ; Return values:        On success  - True
   ;                       On failure  - False, ErrorMsg / ErrorCode contain additional information
   ; ===================================================================================================================
   AttachDB(DBPath, DBAlias) {
      Return This.Exec("ATTACH DATABASE '" . DBPath . "' As " . DBAlias . ";")
   }
   ; ===================================================================================================================
   ; METHOD DetachDB       Detaches an additional database connection previously attached using AttachDB()
   ;                       http://www.sqlite.org/lang_detach.html
   ; Parameters:           DBAlias     - Database alias name used with AttachDB()
   ; Return values:        On success  - True
   ;                       On failure  - False, ErrorMsg / ErrorCode contain additional information
   ; ===================================================================================================================
   DetachDB(DBAlias) {
      Return This.Exec("DETACH DATABASE " . DBAlias . ";")
   }
   ; ===================================================================================================================
   ; METHOD Exec           Execute SQL statement
   ; Parameters:           SQL         - Valid SQL statement
   ;                       Callback    - Name of a callback function to invoke for each result row coming out
   ;                                     of the evaluated SQL statements.
   ;                                     The function must accept 4 parameters:
   ;                                     1: SQLiteDB object
   ;                                     2: Number of columns
   ;                                     3: Pointer to an array of pointers to columns text
   ;                                     4: Pointer to an array of pointers to column names
   ;                                     The address of the current SQL string is passed in A_EventInfo.
   ;                                     If the callback function returns non-zero, DB.Exec() returns SQLITE_ABORT
   ;                                     without invoking the callback again and without running any subsequent
   ;                                     SQL statements.
   ; Return values:        On success  - True, the number of changed rows is given in property Changes
   ;                       On failure  - False, ErrorMsg / ErrorCode contain additional information
   ; ===================================================================================================================
   Exec(SQL, Callback := "") {
      This.ErrorMsg := ""
      This.ErrorCode := 0
      This.SQL := SQL
      If !(This._Handle) {
         This.ErrorMsg := "Invalid database handle!"
         Return False
      }
      CBPtr := 0
      Err := 0
      If (FO := Func(Callback)) && (FO.MinParams = 4)
         CBPtr := RegisterCallback(Callback, "F C", 4, &SQL)
      This._StrToUTF8(SQL, UTF8)
      RC := DllCall("SQlite3.dll\sqlite3_exec", "Ptr", This._Handle, "Ptr", &UTF8, "Int", CBPtr, "Ptr", Object(This)
                  , "UPtrP", Err, "Cdecl Int")
      CallError := ErrorLevel
      If (CBPtr)
         DllCall("Kernel32.dll\GlobalFree", "Ptr", CBPtr)
      If (CallError) {
         This.ErrorMsg := "DLLCall sqlite3_exec failed!"
         This.ErrorCode := CallError
         Return False
      }
      If (RC) {
         This.ErrorMsg := StrGet(Err, "UTF-8")
         This.ErrorCode := RC
         DllCall("SQLite3.dll\sqlite3_free", "Ptr", Err, "Cdecl")
         Return False
      }
      This.Changes := This._Changes()
      Return True
   }
   ; ===================================================================================================================
   ; METHOD GetTable       Get complete result for SELECT query
   ; Parameters:           SQL         - SQL SELECT statement
   ;                       ByRef TB    - Variable to store the result object (TB _Table)
   ;                       MaxResult   - Number of rows to return:
   ;                          0          Complete result (default)
   ;                         -1          Return only RowCount and ColumnCount
   ;                         -2          Return counters and array ColumnNames
   ;                          n          Return counters and ColumnNames and first n rows
   ; Return values:        On success  - True, TB contains the result object
   ;                       On failure  - False, ErrorMsg / ErrorCode contain additional information
   ; ===================================================================================================================
   GetTable(SQL, ByRef TB, MaxResult := 0) {
      TB := ""
      This.ErrorMsg := ""
      This.ErrorCode := 0
      This.SQL := SQL
      If !(This._Handle) {
         This.ErrorMsg := "Invalid database handle!"
         Return False
      }
      Names := ""
      Err := 0, RC := 0, GetRows := 0
      I := 0, Rows := Cols := 0
      Table := 0
      If MaxResult Is Not Integer
         MaxResult := 0
      If (MaxResult < -2)
         MaxResult := 0
      This._StrToUTF8(SQL, UTF8)
      RC := DllCall("SQlite3.dll\sqlite3_get_table", "Ptr", This._Handle, "Ptr", &UTF8, "UPtrP", Table
                  , "IntP", Rows, "IntP", Cols, "UPtrP", Err, "Cdecl Int")
      If (ErrorLevel) {
         This.ErrorMsg := "DLLCall sqlite3_get_table failed!"
         This.ErrorCode := ErrorLevel
         Return False
      }
      If (RC) {
         This.ErrorMsg := StrGet(Err, "UTF-8")
         This.ErrorCode := RC
         DllCall("SQLite3.dll\sqlite3_free", "Ptr", Err, "Cdecl")
         Return False
      }
      TB := new This._Table
      TB.ColumnCount := Cols
      TB.RowCount := Rows
      If (MaxResult = -1) {
         DllCall("SQLite3.dll\sqlite3_free_table", "Ptr", Table, "Cdecl")
         If (ErrorLevel) {
            This.ErrorMsg := "DLLCall sqlite3_free_table failed!"
            This.ErrorCode := ErrorLevel
            Return False
         }
         Return True
      }
      If (MaxResult = -2)
         GetRows := 0
      Else If (MaxResult > 0) && (MaxResult <= Rows)
         GetRows := MaxResult
      Else
         GetRows := Rows
      Offset := 0
      Names := Array()
      Loop, %Cols% {
         Names[A_Index] := StrGet(NumGet(Table+0, Offset, "UPtr"), "UTF-8")
         Offset += A_PtrSize
      }
      TB.ColumnNames := Names
      TB.HasNames := True
      Loop, %GetRows% {
         I := A_Index
         TB.Rows[I] := []
         Loop, %Cols% {
            TB.Rows[I][A_Index] := StrGet(NumGet(Table+0, Offset, "UPtr"), "UTF-8")
            Offset += A_PtrSize
         }
      }
      If (GetRows)
         TB.HasRows := True
      DllCall("SQLite3.dll\sqlite3_free_table", "Ptr", Table, "Cdecl")
      If (ErrorLevel) {
         TB := ""
         This.ErrorMsg := "DLLCall sqlite3_free_table failed!"
         This.ErrorCode := ErrorLevel
         Return False
      }
      Return True
   }
   ; ===================================================================================================================
   ; Prepared statement 10:54 2019.07.05. by Dixtroy
   ;  DB := new SQLiteDB
   ;  DB.OpenDB(DBFileName)
   ;  DB.Prepare 1 or more, just once
   ;  DB.Step 1 or more on prepared one, repeatable
   ;  DB.Finalize at the end
   ; ===================================================================================================================
   ; ===================================================================================================================
   ; METHOD Prepare        Prepare database table for further actions.
   ; Parameters:           SQL         - SQL statement to be compiled
   ;                       ByRef ST    - Variable to store the statement object (Class _Statement)
   ; Return values:        On success  - True, ST contains the statement object
   ;                       On failure  - False, ErrorMsg / ErrorCode contain additional information
   ; Remarks:              You have to pass one ? for each column you want to assign a value later.
   ; ===================================================================================================================
   Prepare(SQL, ByRef ST) {
      This.ErrorMsg := ""
      This.ErrorCode := 0
      This.SQL := SQL
      If !(This._Handle) {
         This.ErrorMsg := "Invalid database handle!"
         Return False
      }
      Stmt := 0
      This._StrToUTF8(SQL, UTF8)
      RC := DllCall("SQlite3.dll\sqlite3_prepare_v2", "Ptr", This._Handle, "Ptr", &UTF8, "Int", -1
                  , "UPtrP", Stmt, "Ptr", 0, "Cdecl Int")
      If (ErrorLeveL) {
         This.ErrorMsg := A_ThisFunc . ": DllCall sqlite3_prepare_v2 failed!"
         This.ErrorCode := ErrorLevel
         Return False
      }
      If (RC) {
         This.ErrorMsg := A_ThisFunc . ": " . This._ErrMsg()
         This.ErrorCode := RC
         Return False
      }
      ST := New This._Statement
      ST.ParamCount := DllCall("SQlite3.dll\sqlite3_bind_parameter_count", "Ptr", Stmt, "Cdecl Int")
      ST._Handle := Stmt
      ST._DB := This
      This._Stmts[Stmt] := Stmt
      Return True
    }
   ; ===================================================================================================================
   ; METHOD Query          Get "recordset" object for prepared SELECT query
   ; Parameters:           SQL         - SQL SELECT statement
   ;                       ByRef RS    - Variable to store the result object (Class _RecordSet)
   ; Return values:        On success  - True, RS contains the result object
   ;                       On failure  - False, ErrorMsg / ErrorCode contain additional information
   ; ===================================================================================================================
   Query(SQL, ByRef RS) {
      RS := ""
      This.ErrorMsg := ""
      This.ErrorCode := 0
      This.SQL := SQL
      ColumnCount := 0
      HasRows := False
      If !(This._Handle) {
         This.ErrorMsg := "Invalid dadabase handle!"
         Return False
      }
      Query := 0
      This._StrToUTF8(SQL, UTF8)
      RC := DllCall("SQlite3.dll\sqlite3_prepare_v2", "Ptr", This._Handle, "Ptr", &UTF8, "Int", -1
                  , "UPtrP", Query, "Ptr", 0, "Cdecl Int")
      If (ErrorLeveL) {
         This.ErrorMsg := "DLLCall sqlite3_prepare_v2 failed!"
         This.ErrorCode := ErrorLevel
         Return False
      }
      If (RC) {
         This.ErrorMsg := This._ErrMsg()
         This.ErrorCode := RC
         Return False
      }
      RC := DllCall("SQlite3.dll\sqlite3_column_count", "Ptr", Query, "Cdecl Int")
      If (ErrorLevel) {
         This.ErrorMsg := "DLLCall sqlite3_column_count failed!"
         This.ErrorCode := ErrorLevel
         Return False
      }
      If (RC < 1) {
         This.ErrorMsg := "Query result is empty!"
         This.ErrorCode := This._ReturnCode("SQLITE_EMPTY")
         Return False
      }
      ColumnCount := RC
      Names := []
      Loop, %RC% {
         StrPtr := DllCall("SQlite3.dll\sqlite3_column_name", "Ptr", Query, "Int", A_Index - 1, "Cdecl UPtr")
         If (ErrorLevel) {
            This.ErrorMsg := "DLLCall sqlite3_column_name failed!"
            This.ErrorCode := ErrorLevel
            Return False
         }
         Names[A_Index] := StrGet(StrPtr, "UTF-8")
      }
      RC := DllCall("SQlite3.dll\sqlite3_step", "Ptr", Query, "Cdecl Int")
      If (ErrorLevel) {
         This.ErrorMsg := "DLLCall sqlite3_step failed!"
         This.ErrorCode := ErrorLevel
         Return False
      }
      If (RC = This._ReturnCode("SQLITE_ROW"))
         HasRows := True
      RC := DllCall("SQlite3.dll\sqlite3_reset", "Ptr", Query, "Cdecl Int")
      If (ErrorLevel) {
         This.ErrorMsg := "DLLCall sqlite3_reset failed!"
         This.ErrorCode := ErrorLevel
         Return False
      }
      RS := new This._RecordSet
      RS.ColumnCount := ColumnCount
      RS.ColumnNames := Names
      RS.HasNames := True
      RS.HasRows := HasRows
      RS._Handle := Query
      RS._DB := This
      This._Queries[Query] := Query
      Return True
   }
   ; ===================================================================================================================
   ; METHOD CreateScalarFunc  Create a scalar application defined function
   ; Parameters:              Name  -  the name of the function
   ;                          Args  -  the number of arguments that the SQL function takes
   ;                          Func  -  a pointer to AHK functions that implement the SQL function
   ;                          Enc   -  specifies what text encoding this SQL function prefers for its parameters
   ;                          Param -  an arbitrary pointer accessible within the funtion with sqlite3_user_data()
   ; Return values:           On success  - True
   ;                          On failure  - False, ErrorMsg / ErrorCode contain additional information
   ; Documentation:           www.sqlite.org/c3ref/create_function.html
   ; ===================================================================================================================
   CreateScalarFunc(Name, Args, Func, Enc := 0x0801, Param := 0) {
      ; SQLITE_DETERMINISTIC = 0x0800 - the function will always return the same result given the same inputs
      ;                                 within a single SQL statement
      ; SQLITE_UTF8 = 0x0001
      This.ErrorMsg := ""
      This.ErrorCode := 0
      If !(This._Handle) {
         This.ErrorMsg := "Invalid database handle!"
         Return False
      }
      RC := DllCall("SQLite3.dll\sqlite3_create_function", "Ptr", This._Handle, "AStr", Name, "Int", Args, "Int", Enc
                                                         , "Ptr", Param, "Ptr", Func, "Ptr", 0, "Ptr", 0, "Cdecl Int")
      If (ErrorLeveL) {
         This.ErrorMsg := "DllCall sqlite3_create_function failed!"
         This.ErrorCode := ErrorLevel
         Return False
      }
      If (RC) {
         This.ErrorMsg := This._ErrMsg()
         This.ErrorCode := RC
         Return False
      }
      Return True
   }
   ; ===================================================================================================================
   ; METHOD LastInsertRowID   Get the ROWID of the last inserted row
   ; Parameters:              ByRef RowID - Variable to store the ROWID
   ; Return values:           On success  - True, RowID contains the ROWID
   ;                          On failure  - False, ErrorMsg / ErrorCode contain additional information
   ; ===================================================================================================================
   LastInsertRowID(ByRef RowID) {
      This.ErrorMsg := ""
      This.ErrorCode := 0
      This.SQL := ""
      If !(This._Handle) {
         This.ErrorMsg := "Invalid database handle!"
         Return False
      }
      RowID := 0
      RC := DllCall("SQLite3.dll\sqlite3_last_insert_rowid", "Ptr", This._Handle, "Cdecl Int64")
      If (ErrorLevel) {
         This.ErrorMsg := "DllCall sqlite3_last_insert_rowid failed!"
         This.ErrorCode := ErrorLevel
         Return False
      }
      RowID := RC
      Return True
   }
   ; ===================================================================================================================
   ; METHOD TotalChanges   Get the number of changed rows since connecting to the database
   ; Parameters:           ByRef Rows  - Variable to store the number of rows
   ; Return values:        On success  - True, Rows contains the number of rows
   ;                       On failure  - False, ErrorMsg / ErrorCode contain additional information
   ; ===================================================================================================================
   TotalChanges(ByRef Rows) {
      This.ErrorMsg := ""
      This.ErrorCode := 0
      This.SQL := ""
      If !(This._Handle) {
         This.ErrorMsg := "Invalid database handle!"
         Return False
      }
      Rows := 0
      RC := DllCall("SQLite3.dll\sqlite3_total_changes", "Ptr", This._Handle, "Cdecl Int")
      If (ErrorLevel) {
         This.ErrorMsg := "DllCall sqlite3_total_changes failed!"
         This.ErrorCode := ErrorLevel
         Return False
      }
      Rows := RC
      Return True
   }
   ; ===================================================================================================================
   ; METHOD SetTimeout     Set the timeout to wait before SQLITE_BUSY or SQLITE_IOERR_BLOCKED is returned,
   ;                       when a table is locked.
   ; Parameters:           TimeOut     - Time to wait in milliseconds
   ; Return values:        On success  - True
   ;                       On failure  - False, ErrorMsg / ErrorCode contain additional information
   ; ===================================================================================================================
   SetTimeout(Timeout := 1000) {
      This.ErrorMsg := ""
      This.ErrorCode := 0
      This.SQL := ""
      If !(This._Handle) {
         This.ErrorMsg := "Invalid database handle!"
         Return False
      }
      If Timeout Is Not Integer
         Timeout := 1000
      RC := DllCall("SQLite3.dll\sqlite3_busy_timeout", "Ptr", This._Handle, "Int", Timeout, "Cdecl Int")
      If (ErrorLevel) {
         This.ErrorMsg := "DllCall sqlite3_busy_timeout failed!"
         This.ErrorCode := ErrorLevel
         Return False
      }
      If (RC) {
         This.ErrorMsg := This._ErrMsg()
         This.ErrorCode := RC
         Return False
      }
      Return True
   }
   ; ===================================================================================================================
   ; METHOD EscapeStr      Escapes special characters in a string to be used as field content
   ; Parameters:           Str         - String to be escaped
   ;                       Quote       - Add single quotes around the outside of the total string (True / False)
   ; Return values:        On success  - True
   ;                       On failure  - False, ErrorMsg / ErrorCode contain additional information
   ; ===================================================================================================================
   EscapeStr(ByRef Str, Quote := True) {
      This.ErrorMsg := ""
      This.ErrorCode := 0
      This.SQL := ""
      If !(This._Handle) {
         This.ErrorMsg := "Invalid database handle!"
         Return False
      }
      If Str Is Number
         Return True
      VarSetCapacity(OP, 16, 0)
      StrPut(Quote ? "%Q" : "%q", &OP, "UTF-8")
      This._StrToUTF8(Str, UTF8)
      Ptr := DllCall("SQLite3.dll\sqlite3_mprintf", "Ptr", &OP, "Ptr", &UTF8, "Cdecl UPtr")
      If (ErrorLevel) {
         This.ErrorMsg := "DllCall sqlite3_mprintf failed!"
         This.ErrorCode := ErrorLevel
         Return False
      }
      Str := This._UTF8ToStr(Ptr)
      DllCall("SQLite3.dll\sqlite3_free", "Ptr", Ptr, "Cdecl")
      Return True
   }
   ; ===================================================================================================================
   ; METHOD StoreBLOB      Use BLOBs as parameters of an INSERT/UPDATE/REPLACE statement.
   ; Parameters:           SQL         - SQL statement to be compiled
   ;                       BlobArray   - Array of objects containing two keys/value pairs:
   ;                                     Addr : Address of the (variable containing the) BLOB.
   ;                                     Size : Size of the BLOB in bytes.
   ; Return values:        On success  - True
   ;                       On failure  - False, ErrorMsg / ErrorCode contain additional information
   ; Remarks:              For each BLOB in the row you have to specify a ? parameter within the statement. The
   ;                       parameters are numbered automatically from left to right starting with 1.
   ;                       For each parameter you have to pass an object within BlobArray containing the address
   ;                       and the size of the BLOB.
   ; ===================================================================================================================
   StoreBLOB(SQL, BlobArray) {
      Static SQLITE_STATIC := 0
      Static SQLITE_TRANSIENT := -1
      This.ErrorMsg := ""
      This.ErrorCode := 0
      If !(This._Handle) {
         This.ErrorMsg := "Invalid database handle!"
         Return False
      }
      If !RegExMatch(SQL, "i)^\s*(INSERT|UPDATE|REPLACE)\s") {
         This.ErrorMsg := A_ThisFunc . " requires an INSERT/UPDATE/REPLACE statement!"
         Return False
      }
      Query := 0
      This._StrToUTF8(SQL, UTF8)
      RC := DllCall("SQlite3.dll\sqlite3_prepare_v2", "Ptr", This._Handle, "Ptr", &UTF8, "Int", -1
                  , "UPtrP", Query, "Ptr", 0, "Cdecl Int")
      If (ErrorLeveL) {
         This.ErrorMsg := A_ThisFunc . ": DllCall sqlite3_prepare_v2 failed!"
         This.ErrorCode := ErrorLevel
         Return False
      }
      If (RC) {
         This.ErrorMsg := A_ThisFunc . ": " . This._ErrMsg()
         This.ErrorCode := RC
         Return False
      }
      For BlobNum, Blob In BlobArray {
         If !(Blob.Addr) || !(Blob.Size) {
            This.ErrorMsg := A_ThisFunc . ": Invalid parameter BlobArray!"
            This.ErrorCode := ErrorLevel
            Return False
         }
         RC := DllCall("SQlite3.dll\sqlite3_bind_blob", "Ptr", Query, "Int", BlobNum, "Ptr", Blob.Addr
                     , "Int", Blob.Size, "Ptr", SQLITE_STATIC, "Cdecl Int")
         If (ErrorLeveL) {
            This.ErrorMsg := A_ThisFunc . ": DllCall sqlite3_bind_blob failed!"
            This.ErrorCode := ErrorLevel
            Return False
         }
         If (RC) {
            This.ErrorMsg := A_ThisFunc . ": " . This._ErrMsg()
            This.ErrorCode := RC
            Return False
         }
      }
      RC := DllCall("SQlite3.dll\sqlite3_step", "Ptr", Query, "Cdecl Int")
      If (ErrorLevel) {
         This.ErrorMsg := A_ThisFunc . ": DllCall sqlite3_step failed!"
         This.ErrorCode := ErrorLevel
         Return False
      }
      If (RC) && (RC <> This._ReturnCode("SQLITE_DONE")) {
         This.ErrorMsg := A_ThisFunc . ": " . This._ErrMsg()
         This.ErrorCode := RC
         Return False
      }
      RC := DllCall("SQlite3.dll\sqlite3_finalize", "Ptr", Query, "Cdecl Int")
      If (ErrorLevel) {
         This.ErrorMsg := A_ThisFunc . ": DllCall sqlite3_finalize failed!"
         This.ErrorCode := ErrorLevel
         Return False
      }
      If (RC) {
         This.ErrorMsg := A_ThisFunc . ": " . This._ErrMsg()
         This.ErrorCode := RC
         Return False
      }
      Return True
   }
}
; ======================================================================================================================
; Exemplary custom callback function regexp()
; Parameters:        Context  -  handle to a sqlite3_context object
;                    ArgC     -  number of elements passed in Values (must be 2 for this function)
;                    Values   -  pointer to an array of pointers which can be passed to sqlite3_value_text():
;                                1. Needle
;                                2. Haystack
; Return values:     Call sqlite3_result_int() passing 1 (True) for a match, otherwise pass 0 (False).
; ======================================================================================================================
SQLiteDB_RegExp(Context, ArgC, Values) {
   Result := 0
   If (ArgC = 2) {
      AddrN := DllCall("SQLite3.dll\sqlite3_value_text", "Ptr", NumGet(Values + 0, "UPtr"), "Cdecl UPtr")
      AddrH := DllCall("SQLite3.dll\sqlite3_value_text", "Ptr", NumGet(Values + A_PtrSize, "UPtr"), "Cdecl UPtr")
      Result := RegExMatch(StrGet(AddrH, "UTF-8"), StrGet(AddrN, "UTF-8"))
   }
   DllCall("SQLite3.dll\sqlite3_result_int", "Ptr", Context, "Int", !!Result, "Cdecl") ; 0 = false, 1 = trus
}
