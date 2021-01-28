;===============================================================================
;
; Script Function:  Functions that assist Access to a SQLite Database.
; AHK Version:      1.0.45.03
; Language:         English
; Platform:         WinXP
; Author:           nick (denick)
; Version:          1.00.00/2006-09-23/nick
;                   1.00.01/15.11.2006/nick
;
;===============================================================================
; This include is a AHK translation of the AutoIt3 script SQLite.au3.
; Without it I'd never been able to do it, it was hard enough this way.
; Let's thank picasso (Fida Florian) for sharing it at
; www.autoitscript.com/forum/index.php?showtopic=17099
;===============================================================================
; This software is provided 'as-is', without any express or
; implied warranty.  In no event will the authors be held liable for any
; damages arising from the use of this software.
;===============================================================================
; Changelog:
;===============================================================================
;===============================================================================
; Function list
;===============================================================================
; _SQLite_Startup          ; Load SQLite3.dll
; _SQLite_Shutdown         ; Unload SQLite3.dll
; _SQLite_OpenDB           ; Open connection to a database
; _SQLite_CloseDB          ; Close connection
; _SQLite_GetTable         ; Get full result of a SQL query (SELECT)
; _SQLite_Exec             ; Execute non query SQL statements
; _SQLite_Query            ; Prepare SQL query
; _SQLite_FetchNames       ; Get columns names
; _SQLite_FetchData        ; Get one row of data
; _SQLite_QueryFinalize    ; Free prepared query
; _SQLite_QueryReset       ; Reset prepared query for reuse
; _SQLite_SQLiteExe        ; Execute SQLite3.exe with given commands
; _SQLite_LibVersion       ; Get SQLite3.dll version
; _SQLite_LastInsertRowID  ; Get the ROWID of the last inserted row
; _SQLite_Changes          ; Get the amount of changes caused by last SQL statement
; _SQLite_TotalChanges     ; Get the amount of changes since database connection
; _SQLite_ErrCode          ; Get the SQLite errorcode caused by last SQL statement
; _SQLite_ErrMsg           ; Get the SQLite errormessage caused by last SQL statement
; _SQLite_SetTimeout       ; Set SQLite's busy timer
;===============================================================================
; User Calltips:
;===============================================================================
/*
_SQLite_Startup() Loads SQLite3.dll
_SQLite_Shutdown() Unloads SQLite3.dll
_SQLite_OpenDB($sDBFile) Opens Database, Sets Standard Handle, Returns Handle
_SQLite_CloseDB($hDB | -1) Closes Database
_SQLite_GetTable($hDB | -1 , $sSQL , ByRef $sResult , ByRef $iRows , ByRef $iCols , [$iMaxResult = -1], [$iCharSize = 64]) Executes $sSQL Query to $sResult, Returns Error Code
_SQLite_Exec($hDB | -1 , $sSQL) Executes $sSQL (No Result), Returns Error Code
_SQLite_Query($hDB | -1 , $sSQL , ByRef $hQuery) Prepares $sSql, Returns Error Code
_SQLite_FetchNames($hQuery | -1 , ByRef $sNames) Read out the Tablenames of a _SQLite_Query() based query
_SQLite_FetchData($hQuery | -1 , ByRef $sRow) Fetches Results From First/Next Row of $hQuery Query into $sRow, Returns Error Code
_SQLite_QueryFinalize($hQuery | -1) Finalizes a Query
_SQLite_QueryReset($hQuery | -1) Resets a Query
_SQLite_SQLiteExe($sDBFile , $sInput , ByRef $sOutput) Executes commands in SQLite.exe
_SQLite_LibVersion() Returns Dll's Version No.
_SQLite_LastInsertRowID($hDB | -1) Returns Last INSERT ROWID
_SQLite_Changes($hDB | -1) Returns Number of Changes (Excluding Triggers) of The last Transaction
_SQLite_TotalChanges($hDB | -1) Returns Number of All Changes (Including Triggers) of all Transactions
_SQLite_ErrCode($hDB | -1 , ByRef $sErr) Returns Last Error Code (Numeric)
_SQLite_ErrMsg($hDB | -1 , ByRef $sErr) Returns Last Error Message
_SQLite_SetTimeout($hDB | -1 , [$iTimeout = 1000]) Sets Timeout for busy handler
*/
;===============================================================================
; SQLite Returncodes
;===============================================================================
$SQLITE_OK := 0            ; Successful result
$SQLITE_ERROR := 1         ; SQL error or missing database
$SQLITE_INTERNAL := 2      ; An internal logic error in SQLite
$SQLITE_PERM := 3          ; Access permission denied
$SQLITE_ABORT := 4         ; Callback routine requested an abort
$SQLITE_BUSY := 5          ; The database file is locked
$SQLITE_LOCKED := 6        ; A table in the database is locked
$SQLITE_NOMEM := 7         ; A malloc() failed
$SQLITE_READONLY := 8      ; Attempt to write a readonly database
$SQLITE_INTERRUPT := 9     ; Operation terminated by sqlite_interrupt()
$SQLITE_IOERR := 10        ; Some kind of disk I/O error occurred
$SQLITE_CORRUPT := 11      ; The database disk image is malformed
$SQLITE_NOTFOUND := 12     ; (Internal Only) Table or record not found
$SQLITE_FULL := 13         ; Insertion failed because database is full
$SQLITE_CANTOPEN := 14     ; Unable to open the database file
$SQLITE_PROTOCOL := 15     ; Database lock protocol error
$SQLITE_EMPTY := 16        ; (Internal Only) Database table is empty
$SQLITE_SCHEMA := 17       ; The database schema changed
$SQLITE_TOOBIG := 18       ; Too much data for one row of a table
$SQLITE_CONSTRAINT := 19   ; Abort due to constraint violation
$SQLITE_MISMATCH := 20     ; Data type mismatch
$SQLITE_MISUSE := 21       ; Library used incorrectly
$SQLITE_NOLFS := 22        ; Uses OS features not supported on host
$SQLITE_AUTH := 23         ; Authorization denied
$SQLITE_ROW := 100         ; sqlite_step() has another row ready
$SQLITE_DONE := 101        ; sqlite_step() has finished executing
;===============================================================================
; SQLite Globals
;===============================================================================
; Tested SQLite3.dll version
$SQLITE_s_VERSION := "3.3.7"
; Default path of SQLite3.dll (A_WorkingDir)
; Required in _SQLite_Startup()
$SQLITE_s_DLL := "SQLITE3.DLL"
; Default path of SQLite3.exe (A_WorkingDir)
; Required in _SQLite_SQLiteExe
$SQLITE_s_EXE := "SQLITE3.EXE"
; Default path of SQLite database, not really needed
$SQLITE_s_DB := "Test.db"
; SQLite3.dll handle
; Returned from _SQLite_Startup()
; Required in _SQLite_Shutdown()
$SQLITE_h_DLL := 0
; Handle of last opened Database;
; Returned from _SQLite_OpenDB()
$SQLITE_h_DB := 0
; Handle of last prepared Query
; Returned from _SQLite_Query()
$SQLITE_h_QUERY := 0
; Functions errormessages
$SQLITE_s_ERROR := ""
;===============================================================================
; Function Name:    _SQLite_StartUP()
; Description:      Load SQLite3.dll
; Requirement(s):   Valid Path to SQlite3.dll in $SQLITE_s_DLL
; Parameter(s):     None
; Return Value(s):  On Success - $SQLITE_OK
;                   On Failure - ErrorLevel
; Author(s):        nick
;===============================================================================
_SQLite_Startup()
{
   Global
   $SQLITE_h_DLL := DllCall("LoadLibrary"
                          , "str", $SQLITE_s_DLL)
   If (ErrorLevel <> 0)
   {
      Return ErrorLevel
   }
   Return $SQLITE_OK
}
;===============================================================================
; Function Name:    _SQLite_Shutdown()
; Description:      Unloads SQLite3.dll
; Requirement(s):   Valid Path to SQlite3.dll in $SQLITE_s_DLL
; Parameter(s):     None
; Return Value(s):  On Success - $SQLITE_OK
;                   On Failure - ErrorLevel
; Author(s):        nick
;===============================================================================
_SQLite_Shutdown()
{
   Global
   DllCall("FreeLibrary"
         , "UInt", $SQLITE_h_DLL)
   If (ErrorLevel <> 0)
   {
      Return ErrorLevel
   }
   $SQLITE_h_DLL := 0
   Return $SQLITE_OK
}
;===============================================================================
; Function Name:    _SQLite_OpenDB()
; Description:      Opens a Database
;                   DB handle is stored in $SQLITE_h_DB
; Parameter(s):     $sDBFile   - Database Filename
; Return Value(s):  On Success - $SQLITE_OK
;                   On Failure - ErrorLevel/SQLite_RC
;                                Errormessage is stored in $SQLITE_s_ERROR 
; Author(s):        nick
;===============================================================================
_SQLite_OpenDB($sDBFile)
{
   Local $i_RC, $h_DB
   $i_RC := 0
   $h_DB := 0
   $SQLITE_s_ERROR := ""
   If $sDBFile =
   {
      $sDBFile := ":memory:"
   }
   $i_RC := DllCall("sqlite3\sqlite3_open"
                   , "str", $sDBFile
                   , "Uint *", $h_DB
                   , "Cdecl int")
   If (ErrorLevel <> 0)
   {
      $SQLITE_s_ERROR = ERROR: DLLCall failed
      Return Errorlevel
   }
   If ($i_RC <> $SQLITE_OK)
   {
      $SQLITE_s_ERROR := DllCall("sqlite3\sqlite3_errmsg"
                               , "Uint", $hDB
                               , "Cdecl str")
      Return $i_RC
   }
   $SQLITE_h_DB := $h_DB
   $SQLITE_a_DB%$h_DB% := $h_DB
   Return $i_RC
}
;===============================================================================
; Function Name:    _SQLite_CloseDB()
; Description:      Closes an open Database
;                   Waits until SQLite <> $SQLITE_BUSY until 'Timeout' has elapsed
; Parameter(s):     $hDB       - Database Handle, use -1 for $SQLITE_h_DB
; Return Value(s):  On Success - Returns $SQLITE_OK
;                   On Failure - ErrorLevel/SQLite_RC
;                                Errormessage is stored in $SQLITE_s_ERROR 
; Author(s):        nick
;===============================================================================
_SQLite_CloseDB($hDB)
{
   Local $i_RC
   $i_RC := 0
   $SQLITE_s_ERROR := ""
   If ($hDB = -1)
   {
      $hDB := $SQLITE_h_DB
   }
   If ($hDB = 0 Or $SQLITE_a_DB%$hDB% = 0)
   {
      $hDB := 0
      Return $SQLITE_OK
   }
   $i_RC := DllCall("sqlite3\sqlite3_close"
                  , "Uint", $hDB
                  , "Cdecl int")
   If (ErrorLevel <> 0)
   {
      $SQLITE_s_ERROR = ERROR: DLLCall failed
      Return Errorlevel
   }
   If ($i_RC <> $SQLITE_OK)
   {
      $SQLITE_s_ERROR := DllCall("sqlite3\sqlite3_errmsg"
                               , "Uint", $hDB
                               , "Cdecl str")
   }
   If ($hDB = $SQLITE_h_DB)
   {
      $SQLITE_h_DB := 0
   }
   $SQLITE_a_DB%$hDB% := 0
   Return $i_RC
}
;===============================================================================
; Function Name:    _SQLite_GetTable()
; Description:      Passes out a String containing Column Names and Data of a
;                   given Query. Columns are seperated by "|", Rows by "`n"
; Parameter(s):     $hDB           - Database Handle, use -1 for $SQLITE_h_DB
;                   $sSQL          - SQL Statement to be executed
;                   ByRef $sResult - Passes out the Resultstring
;                   ByRef $iRows   - Passes out the Amount of 'data' Rows
;                   ByRef $iCols   - Passes out the Amount of Columns
;                   $iMaxResult    - Optional: Amount of Rows to be returned
;                                    Default = -1 : All Rows
;                                    Specify 0 to get only $iRows and $iCols
;                                    Specify 1 to get Column Names also 
;                   $iCharSize     - Optional: Maximal Size of a Data Field
; Return Value(s):  On Success     - Returns $SQLITE_OK
;                   On Failure     - ErrorLevel/SQLite_RC
;                                    Errormessage is stored in $SQLITE_s_ERROR 
; Author(s):        nick
;===============================================================================
_SQLite_GetTable($hDB, $sSQL, ByRef $sResult, ByRef $iRows, ByRef $iCols
                 , $iMaxResult = -1, $iCharSize = 64)
{
   Local $i_RC, $i_Err, $i_Off, $i_GetRows, $p_Result, $s_Col, $s_Row
   $i_RC := 0
   $i_Err := 0
   $i_GetRows := 0
   $p_Result := 0
   $iCols := 0
   $iRows := 0
   $SQLITE_s_ERROR := ""
   $sResult := ""
   If ($hDB = -1)
   {
      $hDB := $SQLITE_h_DB
   }
   If Not _#SQLite_CheckDB($hDB)
   {
      $SQLITE_s_ERROR = ERROR: DB Handle %$hDB% not valid
      Return $SQLITE_ERROR
   }
   If $iMaxResult Is Not Integer
   {
      $iMaxResult := -1
   }
   If ($iMaxResult < -1)
   {
      $iMaxresult := -1
   }
   If $iCharSize Is Not Integer
   {
      $iCharSize := 64
   }
   If ($iCharSize < 1)
   {
      $iCharSize := 64
   }
   $i_RC := DllCall("sqlite3\sqlite3_get_table"
                  , "Uint", $hDB
                  , "str", $sSQL
                  , "Uint *", $p_Result
                  , "Uint *", $iRows
                  , "Uint *", $iCols
                  , "Uint *", $i_Err
                  , "Cdecl int")
   If (ErrorLevel <> 0)
   {
      $SQLITE_s_ERROR = ERROR: DLLCall failed
      Return Errorlevel
   }
   If ($i_RC <> $SQLITE_OK)
   {
      $SQLITE_s_ERROR := DllCall("sqlite3\sqlite3_errmsg"
                               , "Uint", $hDB
                               , "Cdecl str")
      Return $i_RC
   }
   If ($iMaxResult = -1)
   {
      $i_GetRows := $iRows + 1
   }
   Else If ($iMaxResult = 0)
   {
		DllCall("SQLite3\sqlite3_free_table", "Uint", $p_Result, "Cdecl")   
      If (ErrorLevel <> 0)
      {
         $SQLITE_s_ERROR = ERROR: DLLCall SQLITE3_FREE_TABLE failed
         Return Errorlevel
      }
      Return $i_RC
   }
   Else If ($iMaxResult < $iRows)
   {
      $i_GetRows := $iMaxResult
   }
   Else
   {
      $i_GetRows := $iRows + 1
   }
   VarSetCapacity($sResult, $i_GetRows * $iCols * $iCharSize)
   VarSetCapacity($s_Col, $iCharSize * 4, 0)
   $i_Off := 0
   Loop %$i_GetRows%
   {
      $s_Row =
      Loop %$iCols%
      {
         $s_Col =
         DllCall("lstrcpyA"
               , "Str", $s_Col
               , "Uint", _#SQLite_ExtractInt($p_Result, $i_Off))
         $s_Row = %$s_Row%%$s_Col%|   
         $i_Off += 4
      }
      StringTrimRight $s_Row, $s_Row, 1
      $sResult = %$sResult%%$s_Row%`n
   }
   VarSetCapacity($sResult, -1)
   StringTrimRight $sResult, $sResult, 1
   ; Free Results Memory
   DllCall("SQLite3\sqlite3_free_table"
         , "Uint", $p_Result
         , "Cdecl")   
   If (ErrorLevel <> 0)
   {
      $SQLITE_s_ERROR = ERROR: DLLCall SQLITE3_FREE_TABLE failed
      Return Errorlevel
   }
   Return $i_RC
}
;===============================================================================
; Function Name:    _SQLite_Exec()
; Description:      Executes a non Query SQLite Statement,
;                   Does not handle Results
; Parameter(s):     $hDB       - Open database handle, use -1 for $SQLITE_h_DB
;                   $sSQL      - SQL Statement to be executed
; Return Value(s):  On Success - Returns $SQLITE_OK
;                   On Failure - ErrorLevel/SQLite_RC
;                                Errormessage is stored in $SQLITE_s_ERROR 
; Author(s):        nick
;===============================================================================
_SQLite_Exec($hDB, $sSQL)
{
   Local $i_RC, $iErr
   $i_RC := 0
   $SQLITE_s_ERROR := ""
   If ($hDB = -1)
   {
      $hDB := $SQLITE_h_DB
   }
   If Not _#SQlite_CheckDB($hDB)
   {
      $SQLITE_s_ERROR = ERROR: DB Handle %$hDB% not valid
      Return $SQLITE_ERROR
   }
   $i_RC := DllCall("sqlite3\sqlite3_exec"
                  , "Uint", $hDB
                  , "str", $sSQL
                  , "Uint", 0
                  , "Uint", 0
                  , "Uint *", $iErr
                  , "Cdecl int")
   If (ErrorLevel <> 0)
   {
      $SQLITE_s_ERROR = ERROR: DLLCall failed
      Return Errorlevel
   }
   If ($i_RC <> $SQLITE_OK Then)
   {
      $SQLITE_s_ERROR := DllCall("sqlite3\sqlite3_errmsg"
                               , "Uint", $hDB
                               , "Cdecl str")
   }
   Return $i_RC
}
;===============================================================================
; Function Name:    _SQlite_Query()
; Description:      Prepares a single Statement SQLite Query,
;                   Query Handle is stored in $SQLITE_h_QUERY
; Parameter(s):     $hDB       - Database Handle, use -1 for $SQLITE_h_DB
;                   $sSQL      - SQL Statement to be executed
; Return Value(s):  On Success - Returns $SQLITE_OK
;                   On Failure - ErrorLevel/SQLite_RC
;                                Errormessage is stored in $SQLITE_s_ERROR 
; Author(s):        nick
;===============================================================================
_SQlite_Query($hDB, $sSQL)
{
   Local $i_RC, $h_Query, $p_SQL
   $i_RC := 0
   $h_Query := 0
   $p_SQL := 0
   $SQLITE_s_ERROR := ""
   If ($hDB = -1)
   {
      $hDB := $SQLITE_h_DB
   }
   If Not _#SQlite_CheckDB($hDB)
   {
      $SQLITE_s_ERROR = ERROR: DB Handle %$hDB% not valid
      Return $SQLITE_ERROR
   }
   $i_RC := DllCall("sqlite3\sqlite3_prepare"
                  , "Uint", $hDB
                  , "str", $sSQL
                  , "int", StrLen($sSQL)
                  , "Uint *", $h_Query
                  , "Uint *", $p_SQL
                  , "Cdecl int")
   If (ErrorLevel <> 0)
   {
      $SQLITE_s_ERROR = ERROR: DLLCall failed
      Return Errorlevel
   }
   If ($i_RC <> $SQLITE_OK)
   {
      $SQLITE_s_ERROR := DllCall("sqlite3\sqlite3_errmsg"
                               , "Uint", $hDB
                               , "Cdecl str")
   }
   $SQLITE_h_QUERY := $h_QUERY
   $SQLITE_a_QUERY%$h_QUERY% := $h_QUERY
   Return $i_RC
}
;===============================================================================
; Function Name:    _SQLite_FetchNames()
; Description:      Read out the Column Names of a _SQLite_Query() based Query
; Parameter(s):     $hQuery     - Query Handle, use -1 for $SQLITE_h_QUERY
;                   ByRef $sNames - Passes out Column Names
; Return Value(s):  On Success    - $SQLITE_OK
;                   On Failure    - ErrorLevel/SQLite_RC
;                                   Errormessage is stored in $SQLITE_s_ERROR 
; Author(s):        nick
;===============================================================================
_SQLite_FetchNames($hQuery, ByRef $sNames)
{
   Local $i_RC, $i_Col, $s_Col
   $i_RC := 0
   $i_Col := 0
   $s_Col := ""
   $sNames := ""
   $SQLITE_s_ERROR := ""
   If ($hQuery = -1)
   {
      $hQuery := $SQLITE_h_QUERY
   }
   If Not _#SQlite_CheckQuery($hQuery)
   {
      $SQLITE_s_ERROR = ERROR: Query Handle %$hQuery% not valid
      Return $SQLITE_ERROR
   }
   $i_RC := DllCall("sqlite3\sqlite3_column_count"
                  , "Uint", $hQuery
                  , "Cdecl int")
   If (ErrorLevel <> 0)
   {
      $SQLITE_s_ERROR = ERROR: DLLCall sqlite3_column_count failed
      Return Errorlevel
   }
   If ($i_RC < 1)
   {
      $SQLITE_s_ERROR = ERROR: Query result is empty
      Return $SQLITE_EMPTY
   }
   Loop %$i_RC%
   {
      $s_Col := DllCall("sqlite3\sqlite3_column_name"
                      , "Uint", $hQuery
                      , "int", $i_Col
                      , "Cdecl str")
      If (ErrorLevel <> 0)
      {
         $SQLITE_s_ERROR = ERROR: DLLCall sqlite3_column_name failed
         Return Errorlevel
      }
      $sNames = %$sNames%%$s_Col%|
      $i_Col += 1
   }
   If ($sNames <> "")
   {
      StringTrimRight $sNames, $sNames, 1
   }
   Return $SQLITE_OK
}
;===============================================================================
; Function Name:    _SQLite_FetchData()
; Description:      Fetches 1 Row of Data from a _SQLite_Query() based Query
; Parameter(s):     $hQuery     - Query Handle, use -1 for $SQLITE_h_QUERY
;                   ByRef $sRow - Passes out a Row of Data
; Return Value(s):  On Success  - $SQLITE_OK
;                   On Failure  - ErrorLevel/SQLite_RC
;                                 Errormessage is stored in $SQLITE_s_ERROR 
; Author(s):        nick
;===============================================================================
_SQLite_FetchData($hQuery, ByRef $sRow)
{
   Local $i_RC, $i_Col, $i_Type, $s_Col, $b_Done
   Local $SQLITE_NULL
   $SQLITE_NULL = 5
   $i_RC := 0
   $i_Col := 0
   $b_Done := False
   $sRow := ""
   $SQLITE_s_ERROR := ""
   If ($hQuery = -1)
   {
      $hQuery := $SQLITE_h_QUERY
   }
   If Not _#SQlite_CheckQuery($hQuery)
   {
      $SQLITE_s_ERROR = ERROR: Query Handle %$hQuery% not valid
      Return $SQLITE_ERROR
   }
   $i_RC := DllCall("sqlite3\sqlite3_step"
                  , "Uint", $hQuery
                  , "Cdecl int")
   If (ErrorLevel <> 0)
   {
      $SQLITE_s_ERROR = ERROR: DLLCall sqlite3_step failed
      Return Errorlevel
   }
   If ($i_RC <> $SQLITE_ROW)
   {
      If ($i_RC <> $SQLITE_DONE)
      {
         $SQLITE_s_ERROR := DllCall("sqlite3\sqlite3_errmsg"
                                  , "Uint", $hDB
                                  , "Cdecl str")
      }
      _SQLite_QueryFinalize($hQuery)
      Return $i_RC
   }
   $i_RC := DllCall("sqlite3\sqlite3_data_count"
                  , "Uint", $hQuery
                  , "Cdecl int")
   If (ErrorLevel <> 0)
   {
      $SQLITE_s_ERROR = ERROR: DLLCall sqlite3_data_count failed
      Return Errorlevel
   }
   If ($i_RC < 1)
   {
      $SQLITE_s_ERROR = ERROR: Query result is empty
      Return $SQLITE_EMPTY
   }
   Loop %$i_RC%
   {
      $i_Type := DllCall("sqlite3\sqlite3_column_type"
                       , "Uint", $hQuery
                       , "int", $i_Col
                       , "Cdecl int")
      If (ErrorLevel <> 0)
      {
         $SQLITE_s_ERROR = ERROR: DLLCall sqlite3_column_type failed
         Return Errorlevel
      }
      If ($i_Type = $SQLITE_NULL)
      {
         $s_Col := ""
      }
      Else
      {
      $s_Col := DllCall("sqlite3\sqlite3_column_text"
                      , "Uint", $hQuery
                      , "int", $i_Col
                      , "Cdecl str")
         If (ErrorLevel <> 0)
         {
            $SQLITE_s_ERROR = ERROR: DLLCall sqlite3_column_text failed
            Return Errorlevel
         }
      }
      $sRow = %$sRow%%$s_Col%|
      $i_Col += 1
   }
   If ($sRow <> "")
   {
      StringTrimRight $sRow, $sRow, 1
   }
   Return $SQLITE_OK
}
;===============================================================================
; Function Name:    _SQLite_QueryFinalize()
; Description:      Finalizes _SQLite_Query() based Query,
;                   Query Handle is not valid any more
; Parameter(s):     $hQuery    - Query Handle, use -1 for $SQLITE_h_QUERY
; Return Value(s):  On Success - $SQLITE_OK
;                   On Failure - ErrorLevel/$SQLITE_ERROR
;                                Errormessage is stored in $SQLITE_s_ERROR 
; Author(s):        nick
;==============================================================================
_SQLite_QueryFinalize($hQuery)
{
   Local $i_RC
   $i_RC := 0
   $SQLITE_s_ERROR := ""
   If ($hQuery = -1)
   {
      $hQuery := $SQLITE_h_QUERY
   }
   If Not _#SQlite_CheckQuery($hQuery)
   {
      $SQLITE_s_ERROR = ERROR: Query Handle %$hQuery% not valid
      Return $SQLITE_ERROR
   }
   $i_RC := DllCall("sqlite3\sqlite3_finalize"
                  , "Uint", $hQuery
                  , "Cdecl int")
   If (ErrorLevel <> 0)
   {
      $SQLITE_s_ERROR = ERROR: DLLCall sqlite3_finalize failed
      Return Errorlevel
   }
   $SQLITE_a_Query%$hQuery% := 0
   If ($hQuery = $SQLITE_h_QUERY)
   {
      $SQLITE_h_QUERY := 0
   }
   If ($i_RC <> $SQLITE_OK)
   {
      $SQLITE_s_ERROR := DllCall("sqlite3\sqlite3_errmsg"
                               , "Uint", $hDB
                               , "Cdecl str")
   }
   Return $i_RC
}
;===============================================================================
; Function Name:    _SQLite_QueryReset()
; Description:      Resets _SQLite_Query() based Query for reuse
; Parameter(s):     $hQuery    - Query Handle, use -1 for $SQLITE_h_QUERY
; Return Value(s):  On Success - $SQLITE_OK
;                   On Failure - ErrorLevel/$SQLITE_ERROR
;                                Errormessage is stored in $SQLITE_s_ERROR 
; Author(s):        nick
;==============================================================================
_SQLite_QueryReset($hQuery)
{
   Local $i_RC
   $i_RC := 0
   $SQLITE_s_ERROR := ""
   If ($hQuery = -1)
   {
      $hQuery := $SQLITE_h_QUERY
   }
   If Not _#SQlite_CheckQuery($hQuery)
   {
      $SQLITE_s_ERROR = ERROR: Query Handle %$hQuery% not valid
      Return $SQLITE_ERROR
   }
   $i_RC := DllCall("sqlite3\sqlite3_reset"
                  , "Uint", $hQuery
                  , "Cdecl int")
   If (ErrorLevel <> 0)
   {
      $SQLITE_s_ERROR = ERROR: DLLCall sqlite3_finalize failed
      Return Errorlevel
   }
   If ($i_RC <> $SQLITE_OK)
   {
      $SQLITE_s_ERROR := DllCall("sqlite3\sqlite3_errmsg"
                               , "Uint", $hDB
                               , "Cdecl str")
   }
   Return $i_RC
}
;===============================================================================
; Function Name:    _SQLite_SQLiteExe()
; Description:      Executes Commands in SQLite.exe
; Requirement(s):   Valid Path to SQLite3.exe in $SQLITE_s_EXE
; Parameter(s):     $sDBFile       - Database Filename
;                   $sInput        - Commands for SQLite.exe
;                   ByRef $sOutput - Raw Output from SQLite.exe
; Return Value(s):  On Success     - $SQLITE_OK
;                   On Failure     - $SQLITE_ERROR
;                                    Errormessage is stored in $SQLITE_s_ERROR 
; Author(s):        nick
;===============================================================================
_SQLite_SQLiteExe($sDBFile, $sInput, ByRef $sOutput)
{
   Local $sCmd, $sInputFile, $sOutputFile
   $SQLITE_s_ERROR := ""
   $sInputFile := "~SQLINP.TXT"
   $sOutputFile := "~SQLOUT.TXT"
   $sOutput := ""
   IfNotExist %$SQLITE_s_EXE%
   {
      $SQLITE_s_ERROR = ERROR: Unable to find %$SQLITE_s_EXE%
      Return $SQLITE_ERROR
   }
   IfNotExist %$sDBFile%
   {
      FileAppend, , %$sDBFile%
      If (ErrorLevel <> 0)
      {
         $SQLITE_s_ERROR = ERROR: Unable to create %$sDBFile%
         Return $SQLITE_ERROR
      }
   }
   IfExist %$sInputFile%
   {
      FileDelete %$sInputFile%
      If (ErrorLevel <> 0)
      {
         $SQLITE_s_ERROR = ERROR: Unable to delete %$sInputFile%
         Return $SQLITE_ERROR
      }
   }
   IfExist %$sOutputFile%
   {
      FileDelete %$sOutputFile%
      If (ErrorLevel <> 0)
      {
         $SQLITE_s_ERROR = ERROR: Unable to delete %$sOutputFile%
         Return $SQLITE_ERROR
      }
   }
   $sInput = .output stdout`n%$sInput%
   FileAppend %$sInput%, %$sInputFile%
   If (ErrorLevel <> 0)
   {
      $SQLITE_s_ERROR = ERROR: Unable to create %$sInputFile%
      Return $SQLITE_ERROR
   }
   $sCmd = ""%$SQLITE_s_EXE%" "%$sDBFile%" < "%$sInputFile%" > "%$sOutputFile%""
   RunWait %comspec% /c %$sCmd%, , Hide UseErrorLevel
   If (Errorlevel <> 0)
   {
      $SQLITE_s_ERROR = ERROR: Error occured running %$sSQLiteExe%
      Return $SQLITE_ERROR
   }
   FileRead $sOutput, %$sOutputFile%
   If (ErrorLevel > 1)
   {
      $SQLITE_s_ERROR = ERROR: Unable to read %$sOutputFile%
      Return $SQLITE_ERROR
   }
   If (InStr($sOutput, "SQL error:") Or InStr($sOutput, "Incomplete SQL:"))
   {
      $SQLITE_s_ERROR = ERROR: SQLite3.exe reported an Error
      Return $SQLITE_ERROR
   }
   Return $SQLITE_OK
}
;===============================================================================
; Function Name:    _SQLite_LibVersion()
; Description:      Returns the Version Number of the Library
; Parameter(s):     None
; Return Value(s):  On Success - Version Number
;                   On Failure - $SQLITE_ERROR
; Author(s):        nick
;===============================================================================
_SQLite_LibVersion()
{
   Local $s_RC
   $s_RC := DllCall("sqlite3\sqlite3_libversion"
                  , "Cdecl str")
   If (ErrorLevel <> 0)
   {
      Return $SQLITE_ERROR
   }
   Return $s_RC
}
;===============================================================================
; Function Name:    _SQLite_LastInsertRowID()
; Description:      Returns the ROWID of the most recent Insert in the Database
; Parameter(s):     $hDB        - Database Handle, use -1 for $SQLITE_h_DB
;                   ByRef $iRow - passes out ROWID
; Return Value(s):  On Success  - $SQLITE_OK
;                   On Failure  - ErrorLevel/$SQLITE_ERROR
;                                 Errormessage is stored in $SQLITE_s_ERROR 
; Author(s):        nick
;===============================================================================
_SQLite_LastInsertRowID($hDB, ByRef $iRow)
{
   Local $i_RC
   $i_RC := 0
   $i_ROW := 0
   $SQLITE_s_ERROR := ""
   If ($hDB = -1)
   {
      $hDB := $SQLITE_h_DB
   }
   If Not _#SQlite_CheckDB($hDB)
   {
      $SQLITE_s_ERROR = ERROR: DB Handle %$hDB% not valid
      Return $SQLITE_ERROR
   }
   $i_RC := DllCall("SQLite3\sqlite3_last_insert_rowid"
                  , "Uint", $hDB
                  , "Cdecl Uint")
   If (ErrorLevel <> 0)
   {
      $SQLITE_s_ERROR = ERROR: DLLCall failed
      Return Errorlevel
   }
   $iRow := $i_RC
   Return $SQLITE_OK
}
;===============================================================================
; Function Name:    _SQLite_Changes()
; Description:      Returns the Number of Database Rows that were changed
;                   by the most recently completed Query
; Parameter(s):     $hDB         - Database Handle, use -1 for $SQLITE_h_DB
;                   ByRef $iRows - Passes out Number of Changes
; Return Value(s):  On Success   - $SQLITE_OK
;                   On Failure   - Errorlevel/$SQLITE_ERROR
;                                  Errormessage is stored in $SQLITE_s_ERROR 
; Author(s):        nick
;===============================================================================
_SQLite_Changes($hDB, ByRef $iRows)
{
   Local $i_RC
   $i_RC := 0
   $i_ROW := 0
   $SQLITE_s_ERROR := ""
   If ($hDB = -1)
   {
      $hDB := $SQLITE_h_DB
   }
   If Not _#SQlite_CheckDB($hDB)
   {
      $SQLITE_s_ERROR = ERROR: DB Handle %$hDB% not valid
      Return $SQLITE_ERROR
   }
   $i_RC := DllCall("SQLite3\sqlite3_changes"
                  , "Uint", $hDB
                  , "Cdecl Uint")
   If (ErrorLevel <> 0)
   {
      $SQLITE_s_ERROR = ERROR: DLLCall failed
      Return Errorlevel
   }
   $iRows := $i_RC
   Return $SQLITE_OK
}
;===============================================================================
; Function Name:    _SQLite_TotalChanges()
; Description:      Returns the total Number of Database Rows that have be
;                   modified, inserted, or deleted since the Database Connection
;                   was created.
; Parameter(s):     $hDB         - Database Handle, use -1 for $SQLITE_h_DB
;                   ByRef $iRows - Passes out Number of Changes
; Return Value(s):  On Success   - $SQLITE_OK
;                   On Failure   - Errorlevel/$SQLITE_ERROR
;                                  Errormessage is stored in $SQLITE_s_ERROR 
; Author(s):        nick
;===============================================================================
_SQLite_TotalChanges($hDB, ByRef $iRows)
{
   Local $i_RC
   $i_RC := 0
   $i_ROW := 0
   $SQLITE_s_ERROR := ""
   If ($hDB = -1)
   {
      $hDB := $SQLITE_h_DB
   }
   If Not _#SQlite_CheckDB($hDB)
   {
      $SQLITE_s_ERROR = ERROR: DB Handle %$hDB% not valid
      Return $SQLITE_ERROR
   }
   $i_RC := DllCall("SQLite3\sqlite3_total_changes"
                  , "Uint", $hDB
                  , "Cdecl Uint")
   If (ErrorLevel <> 0)
   {
      $SQLITE_s_ERROR = ERROR: DLLCall failed
      Return Errorlevel
   }
   $iRows := $i_RC
   Return $SQLITE_OK
}
;===============================================================================
; Function Name:    _SQLite_ErrMsg()
; Description:      Returns the Errormessage for the most recent
;                   sqlite3_* API call as String
; Parameter(s):     $hDB        - Database Handle, use -1 for $SQLITE_h_DB
;                   ByRef $sErr - Passes out Errormessage
; Return Value(s):  On Success  - $SQLITE_OK
;                   On Failure  - Errorlevel/$SQLITE_ERROR
;                                 Errormessage is stored in $SQLITE_s_ERROR 
; Author(s):        nick
;===============================================================================
_SQLite_ErrMsg($hDB, ByRef $sErr)
{
   Local $s_RC
   $s_RC := 0
   $sErr := ""
   $SQLITE_s_ERROR := ""
   If ($hDB = -1)
   {
      $hDB := $SQLITE_h_DB
   }
   If Not _#SQlite_CheckDB($hDB)
   {
      $SQLITE_s_ERROR = ERROR: DB Handle %$hDB% not valid
      Return $SQLITE_ERROR
   }
   $s_RC := DllCall("SQLite3\sqlite3_errmsg"
                  , "Uint", $hDB
                  , "Cdecl Str")
   If (ErrorLevel <> 0)
   {
      $SQLITE_s_ERROR = ERROR: DLLCall failed
      Return Errorlevel
   }
   $sErr := $s_RC
   Return $SQLITE_OK
}
;===============================================================================
; Function Name:   _SQLite_ErrCode()
; Description:      Returns the Errorcode for the most recent
;                   sqlite3_* API Call as String
; Parameter(s):     $hDB        - Database Handle, use -1 for $SQLITE_h_DB
;                   ByRef $sErr - Passes out Errorcode
; Return Value(s):  On Success  - $SQLITE_OK
;                   On Failure  - Errorlevel/$SQLITE_ERROR
;                                 Errormessage is stored in $SQLITE_s_ERROR 
; Author(s):        nick
;===============================================================================
_SQLite_ErrCode($hDB, ByRef $sErr)
{
   Local $i_RC
   $i_RC := 0
   $sErr := ""
   $SQLITE_s_ERROR := ""
   If ($hDB = -1)
   {
      $hDB := $SQLITE_h_DB
   }
   If Not _#SQlite_CheckDB($hDB)
   {
      $SQLITE_s_ERROR = ERROR: DB Handle %$hDB% not valid
      Return $SQLITE_ERROR
   }
   $i_RC := DllCall("SQLite3\sqlite3_errcode"
                  , "Uint", $hDB
                  , "Cdecl Uint")
   If (ErrorLevel <> 0)
   {
      $SQLITE_s_ERROR = ERROR: DLLCall failed
      Return Errorlevel
   }
   $sErr := $i_RC
   Return $SQLITE_OK
}
;===============================================================================
; Function Name:    _SQLite_SetTimeout()
; Description:      Sets Timeout for Busy Handler
; Parameter(s):     $hDB       - Database Handle, use -1 for $SQLITE_h_DB
;                   $iTimeout  - Optional: Timeout [msec]
; Return Value(s):  On Success - $SQLITE_OK
;                   On Failure - Errorlevel/$SQLITE_ERROR
;                                Errormessage is stored in $SQLITE_s_ERROR 
; Author(s):        nick
;===============================================================================
_SQLite_SetTimeout($hDB, $iTimeout = 1000)
{
   Local $i_RC
   $i_RC := 0
   $SQLITE_s_ERROR := ""
   If ($hDB = -1)
   {
      $hDB := $SQLITE_h_DB
   }
   If Not _#SQlite_CheckDB($hDB)
   {
      $SQLITE_s_ERROR = ERROR: DB Handle %$hDB% not valid
      Return $SQLITE_ERROR
   }
   If $iTimeout Is Not Integer
   {
      $iTimeout := 1000
   }
   $i_RC := DllCall("SQLite3\sqlite3_busy_timeout"
                  , "Uint", $hDB
                  , "Cdecl int")
   If (ErrorLevel <> 0)
   {
      $SQLITE_s_ERROR = ERROR: DLLCall failed
      Return Errorlevel
   }
   If ($i_RC <> $SQLITE_OK Then)
   {
      $SQLITE_s_ERROR := DllCall("sqlite3\sqlite3_errmsg"
                               , "Uint", $hDB
                               , "Cdecl str")
   }
   Return $i_RC
}
;===============================================================================
; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; Following functions for internal use only !!!
; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;===============================================================================
;===============================================================================
; Function Name:    _#SQLite_ExtractInt()
; Description:      Extracts an Integer Value from the Address, $pResult points to
; Parameter(s):     $pResult   - Pointer
;                   $pOffset   - Offset for Pointer
;                   $pIsSigned - Optional: Signed or Unsigned Integer (Default = False)
;                   $pSize     - Optional: Size of Returnvalue (Default = 4)
; Return Value(s):  Returns Integer Value of specified Length
; Author(s):        Chris Mallett & nick
;===============================================================================
_#SQLite_ExtractInt(ByRef $pResult, $pOffset = 0, $pIsSigned = false, $pSize = 4)
{
   Local $i_RC
   $i_RC := 0
   ; Build the integer by adding up its bytes
   Loop %$pSize%
   {
      $i_RC += *($pResult + $pOffset + A_Index-1) << 8*(A_Index-1)
   }
   If (!$pIsSigned OR $pSize > 4 OR result < 0x80000000)
   {   ; Signed vs. unsigned doesn't matter in these cases
      Return $i_RC
   }
   Else
   {   ; Otherwise, convert the value (now known to be 32-bit) to its signed counterpart
      Return -(0xFFFFFFFF - $i_RC + 1)
   }
}
;===============================================================================
; Function Name:    _#SQLite_CheckDB()
; Description:      Validates the given Database Handle
; Parameter(s):     $hDB       - Database Handle
; Return Value(s):  On Success - Returns True
;                   On Failure - Returns False
; Author(s):        nick
;===============================================================================
_#SQLite_CheckDB($hDB)
{
   Global
   If $hDB Is Not Integer
   {
      Return False
   }
   If ($hDB = 0)
   {
      Return False
   }
   If ($SQLITE_a_DB%$hDB% <> $hDB)
   {
      Return False
   }
   Return True
}
;===============================================================================
; Function Name:    _#SQLite_CheckQuery()
; Description:      Validates the given Query Handle
; Parameter(s):     $hQuery    - Query Handle
; Return Value(s):  On Success - Returns True
;                   On Failure - Returns False
; Author(s):        nick
;===============================================================================
_#SQLite_CheckQuery($hQuery)
{
   Global
   If $hQuery Is Not Integer
   {
      Return False
   }
   If ($hQuery = 0)
   {
      Return False
   }
   If ($SQLITE_a_Query%$hQuery% <> $hQuery)
   {
      Return False
   }
   Return True
}
