/*
;=======================================================================================================================
; Function:         Wrapper functions for the SQLite.dll to work with SQLite DBs.
; AHK version:      L 1.1.00.00 (U 32)
; Language:         English
; Tested on:        Win XPSP3, Win VistaSP2 (32 Bit)
; Version:          1.0.00.00/2011-05-01/ich_L
; Remarks:          Encoding of SQLite DBs is assumed to be UTF-8
;=======================================================================================================================
; Many of these functions are transcripted from the AutoIt3-UDF SQLite.au3
; THX piccaso (Fida Florian)
;=======================================================================================================================
; This software is provided 'as-is', without any express or
; implied warranty.  In no event will the authors be held liable for any
; damages arising from the use of this software.
;=======================================================================================================================
; List of Functions:
;=======================================================================================================================
; - Load SQLite3.dll
;   SQLite_Startup()
; - Unload SQLite3.dll
;   SQLite_Shutdown()
; - Open DB connection
;   SQLite_OpenDB(DBFile)
; - Close DB connection
;   SQLite_CloseDB(DB)
; - Get full result for SQL query (SELECT)
;   SQLite_GetTable(DB, SQL, ByRef Rows, ByRef Cols, ByRef Names, ByRef Result, MaxResult = -1)
; - Execute non query SQL statements
;   SQLite_Exec(DB, SQL)
; - Prepare SQL query
;   SQlite_Query(DB, SQL)
; - Get column names from prepared query
;   SQLite_FetchNames(Query, ByRef Names)
; - Get next row of data from prepared query
;   SQLite_FetchData(Query, ByRef Row)
; - Free prepared query
;   SQLite_QueryFinalize(Query)
; - Reset prepared query for reuse
;   SQLite_QueryReset(Query)
; - Execute SQLite3.exe with given commands
;   SQLite_SQLiteExe(DBFile, Commands, ByRef Output)
; - Get SQLite3.dll version number
;   SQLite_LibVersion()
; - Get the ROWID of the last inserted row
;   SQLite_LastInsertRowID(DB, ByRef RowID)
; - Get number of changes caused by last SQL statement
;   SQLite_Changes(DB, ByRef Rows)
; - Get number of changes since connecting to database
;   SQLite_TotalChanges(DB, ByRef Rows)
; - Get the SQLite error message caused by last SQL statement
;   SQLite_ErrMsg(DB, ByRef Msg)
; - Get the SQLite error code caused by last SQL statement
;   SQLite_ErrCode(DB, ByRef Code)
; - Set SQLite's busy timer's timeout
;   SQLite_SetTimeout(DB, Timeout = 1000)
; - Get description for last error
;   SQLite_LastError(Error = "")
; - Set/get path for SQLite3.dll
;   SQLite_DLLPath(Path = "")
; - Set/get path for SQLite.exe
;   SQLite_EXEPath(Path = "")
; * Internal functions *****************************************************************************
;   _SQLite_StrToUTF8(Str, UTF8)
;   _SQLite_UTF8ToStr(UTF8, Str)
;   _SQLite_ModuleHandle(Handle = "")
;   _SQLite_CurrentDB(DB = "")
;   _SQLite_CheckDB(hDB, Action = "")
;   _SQLite_CurrentQuery(Query = "")
;   _SQLite_CheckQuery(Query, DB = "")
;   _SQLite_ReturnCode(RC)
;=======================================================================================================================
; SQLite Returncodes
;=======================================================================================================================
; see _SQLite_ReturnCode()
;=======================================================================================================================
; Function Name:    SQLite_StartUP()
; Description:      Loads SQLite3.dll
; Requirements:     Valid path to SQLite3.dll stored in SQLite_DLLPath().
;                   Default: A_ScriptDir . "\SQLite3.dll"
; Parameter(s):     None
; Return Value(s):  On Success - True
;                   On Failure - False
;=======================================================================================================================
*/
#Include <Base>
#Include <MemoryBuffer>

class SQLiteDataType
{
   static SQLITE_INTEGER := 1
   static SQLITE_FLOAT  :=  2
   static SQLITE_BLOB :=  4
   static SQLITE_NULL :=  5
   static SQLITE_TEXT := 3
}


SQLite_Startup() {
   Static MinVersion := "35"
   
   sqliteDllPath := SQLite_DLLPath()
   
   if(FileExist(sqliteDllPath))
   {
      DLL := DllCall("LoadLibrary", "Str", sqliteDllPath)
      if(!DLL)
         throw Exception("Can't load " . sqliteDllPath . "!", -1)
      
      ver := SQLite_LibVersion()
      
      if(SubStr(RegExReplace(ver, "\."), 1, 2) < MinVersion)
         throw Exception("SQLite ERROR: Version " . ver .  " of SQLite3.dll is not supported!", -1)
      
      _SQLite_ModuleHandle(DLL)
   } else
      throw Exception("SQLite Dll not found:`n" . sqliteDllPath, -1)
  
   Return true
}
;=======================================================================================================================
; Function Name:    SQLite_Shutdown()
; Description:      Unloads SQLite3.dll
; Parameter(s):     None
; Return Value(s):  On Success - True
;                   On Failure - False, check ErrorLevel for details
;=======================================================================================================================
SQLite_Shutdown() {
   DllCall("FreeLibrary", "UInt", _SQLite_ModuleHandle())
   Return (ErrorLevel ? false : true)
}
;=======================================================================================================================
; Function Name:    SQLite_OpenDB()
; Description:      Opens a database.
; Parameter(s):     DBFile - Filepath of the DB
; Return Value(s):  On Success - DB handle
;                   On Failure - False, check ErrorLevel for details
;                                For additional error message call SQLite_LastError()
;=======================================================================================================================
SQLite_OpenDB(DBFile) {
   Static SQLITE_OPEN_READONLY  := 0x01 ; Database opened as read-only
   Static SQLITE_OPEN_READWRITE := 0x02 ; Database opened as read-write
   Static SQLITE_OPEN_CREATE    := 0x04 ; Database will be created if not exists
   
   flags := SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE
   SQLite_LastError(" ")

   if (_SQLite_ModuleHandle() = "") {
      if !(SQLite_Startup())
         throw Exception("ERROR: Could not find the SQLite3.dll!",-1)
   }
   
   if (DBFile = "")
     DBFile := ":memory:"
   else if (!SQLite_IsFilePathValid(DBFile))
     throw Exception("Filepath to the SQLite DB seems to be invalid.",-1,DBFile)
    
   _SQLite_StrToUTF8(DBFile, UTF8)
   DB := 0
   RC := DllCall("SQlite3\sqlite3_open_v2", "Ptr", &UTF8, "Ptr*", DB, "UInt", flags, "Ptr", 0, "Cdecl Int")

   if (ErrorLevel) {
     throw Exception("ERROR: DLLCall sqlite3_open_v2 failed!",-1)
   }
   if (RC) {
      if SQLite_ErrMsg(DB, Msg)
         SQLite_LastError(Msg)
      ErrorLevel := RC
      Return False
   }
   _SQLite_CheckDB(DB, "Store")
   _SQLite_CurrentDB(DB)
   Return DB
}

SQLite_IsFilePathValid(path) {
   if FileExist(path) 
      return true
   if IsObject(FileOpen(path, "a"))
   {
      FileDelete, %path%
      return true
   }
   return false
}

;=======================================================================================================================
; Function Name:    SQLite_CloseDB()
; Description:      Closes an open database.
;                   Waits until SQLite <> _SQLITE_BUSY until 'Timeout' has elapsed
; Parameter(s):     DB - DB handle, -1 for last opened DB
; Return Value(s):  On Success - True
;                   On Failure - False, check ErrorLevel for details
;                                For additional error message call SQLite_LastError()
;=======================================================================================================================
SQLite_CloseDB(DB) {
   SQLite_LastError(" ")
   if (DB = -1)
      DB := _SQLite_CurrentDB()
   if !_SQLite_CheckDB(DB)
      Return True
   RC := DllCall("SQlite3\sqlite3_close", "Ptr", DB, "Cdecl Int")
   if (ErrorLevel) {
      SQLite_LastError("ERROR: DLLCall sqlite3_close failed!")
      Return False
   }
   if (RC) {
      if SQLite_ErrMsg(DB, Msg)
         SQLite_LastError(Msg)
      ErrorLevel := RC
      Return False
   }
   _SQLite_CheckDB(DB, "Free")
   Return True
}
;=======================================================================================================================
; Function Name:    SQLite_GetTable()
; Description:      Provides the number of rows, the number of columns, the
;                   column names and the column values for a given query.
;                   Names are returned as an array. Result is an array of arrays
;                   containing the column values for each row.
; Parameter(s):     DB  - DB handle, -1 for last opened DB
;                   SQL - SQL statement to be executed
;                   ByRef Rows   - Passes out the number of 'Data' rows
;                   ByRef Cols   - Passes out the number of columns
;                   ByRef Names  - Passes out an array containing the column names
;                   ByRef Result - Passes out an array of arrays containing the column values.
;                   Optional MaxResult - Number of rows to be returned
;                                        Default = -1 : All rows
;                                        Specify 0 to get only the number of rows and columns
;                                        Specify 1 to get column names also
; Return Value(s):  On Success - True
;                   On Failure - False, check ErrorLevel for details
;                                For additional error message call SQLite_LastError()
;=======================================================================================================================
SQLite_GetTable(DB, SQL, ByRef Rows, ByRef Cols, ByRef Names, ByRef Result, MaxResult = -1) {
   Table := "", Err := 0, RC := 0, GetRows := 0
   I := 0
   SQLite_LastError(" ")
   Result := ""
   Rows := Cols := 0
   Names := ""
   if (DB = -1)
      DB := _SQLite_CurrentDB()
   if !_SQLite_CheckDB(DB) {
      SQLite_LastError("ERROR: Invalid database handle " . DB)
      ErrorLevel := _SQLite_ReturnCode("SQLITE_ERROR")
      Return False
   }
   if MaxResult Is Not Integer
      MaxResult := -1
   if (MaxResult < -1)
      MaxResult := -1
   if (MaxResult < -1)
      MaxResult := -1
   Table := ""
   Err := 0
   _SQLite_StrToUTF8(SQL, UTF8)
   RC := DllCall("SQlite3\sqlite3_get_table", "Ptr", DB, "Ptr", &UTF8, "Ptr*", Table
               , "Ptr*", Rows, "Ptr*", Cols, "Ptr*", Err, "Cdecl Int")
   if (ErrorLevel) {
      SQLite_LastError("ERROR: DLLCall sqlite3_get_table failed!")
      Return False
   }
   if (RC) {
      SQLite_LastError(StrGet(Err, "UTF-8"))
      DllCall("SQLite3\sqlite3_free", "Ptr", Err, "cdecl")
      ErrorLevel := RC
      Return False
   }
   Result := Array()
   if (MaxResult = 0) {
      DllCall("SQLite3\sqlite3_free_table", "Ptr", Table, "Cdecl")   
      if (ErrorLevel) {
         SQLite_LastError("ERROR: DLLCall sqlite3_close failed!")
         Return False
      }
      Return True
   }
   if (MaxResult = 1)
      GetRows := 0
   Else if (MaxResult > 1) && (MaxResult < Rows)
      GetRows := MaxResult
   Else
      GetRows := Rows
   Offset := 0
   Names := Array()
   Loop, %Cols% {
      Names[A_Index] := StrGet(NumGet(Table+0, Offset), "UTF-8")
      Offset += A_PtrSize
   }
   Loop, %GetRows% {
      I := A_Index
      Result[I] := Array()
      Loop, %Cols% {
         Result[I][A_Index] := StrGet(NumGet(Table+0, Offset), "UTF-8")
         Offset += A_PtrSize
      }
   }
   ; Free Results Memory
   DllCall("SQLite3\sqlite3_free_table", "Ptr", Table, "Cdecl")   
   if (ErrorLevel) {
      SQLite_LastError("ERROR: DLLCall sqlite3_close failed!")
      Return False
   }
   Return True
}

SQLite_Bind(query, idx, val, type = "auto") {
   if(type = "" || type = "auto")
   {
      if val is integer
         type := "int"
      else if val is float
         type := "double"
      else if (val == DBA.Database.NULL)
         type := "null"
      else if (is(val, MemoryBuffer))
         type := "blob"
      else if (IsObject(val)){
         ; Probably support here any kind of serialisation support
         ; e.g. serialize the object with yaml/json
         ; for now, just try to turn it into a default string
         val := val.ToString()
         type := "text"
      }
      else
         type := "text"
   }
   
   ArchLogger.Log(A_ThisFunc ": Binding value as: " type)
   

   if (type = "int" || type = "Integer")
      return SQLite_bind_int(query, idx, val)
   if (type = "double")
      return SQLite_bind_double(query, idx, val)
   if (type = "text")
      return SQLite_bind_text(query, idx, val)
   if (type = "blob"){
      if(is(val, MemoryBuffer)){
         ;MsgBox % "binding blob, adr: "  val.GetPtr() " size: " val.Size
         return SQLite_Bind_blob(query, idx, val.GetPtr(), val.Size) ; val is a MemoryBuffer
      }else
         throw Exception("You can only store MemorBuffers as BLOB.")
   }
   if (type = "null")
      return SQLite_bind_null(query, idx)
   
    return -1
}

SQLite_Bind_blob(query, idx, addr, bytes) {
    return DllCall("SQLite3\sqlite3_bind_blob", Ptr, Query, "int", idx, Ptr, addr, int, bytes, Ptr, -1, "CDecl int") ; SQLITE_TRANSIENT = -1
}

SQLite_Bind_text(query, idx, text) {
    static fn := "SQLite3\sqlite3_bind_text" (A_IsUnicode ? "16" : "")
    return DllCall(fn, "ptr", Query, "int", idx, "ptr", &text, "int", StrLen(text) * (A_IsUnicode+1), "ptr", -1, "CDecl int") ; SQLITE_TRANSIENT = -1
}

SQLite_bind_double(query, idx, double) {
    return DllCall("SQLite3\sqlite3_bind_double", "ptr", query, "int", idx, "double", double, "CDecl int")
}

SQLite_bind_int(query, idx, int) {
    return DllCall("SQLite3\sqlite3_bind_int64", "ptr", query, "int", idx, "int64", int, "CDecl int")
}

SQLite_bind_null(query, idx) {
    return DllCall("SQLite3\sqlite3_bind_null", "ptr", query, "int", idx, "CDecl int")
}

SQLite_Step(query) {
    return DllCall("SQLite3\sqlite3_step", "ptr", query, "CDecl int")
}

SQLite_Reset(query) {
    return DllCall("SQLite3\sqlite3_reset", "ptr", query, "CDecl int")
}

;=======================================================================================================================
; Function Name:    SQLite_Exec()
; Description:      Executes a 'non query' SQLite statement, does not handle results.
; Parameter(s):     DB  - DB handle, -1 for last opened DB
;                   SQL - SQL statement to be executed
; Return Value(s):  On Success - True
;                   On Failure - False, check ErrorLevel for details
;                                For additional error message call SQLite_LastError()
;=======================================================================================================================
SQLite_Exec(DB, SQL) {
   
   ret := false
   try
   {
      SQLite_LastError(" ")
      
      if(DB = -1)
         DB := _SQLite_CurrentDB()
      
      if(!_SQLite_CheckDB(DB)){
         throw Exception("ERROR: Invalid database handle " DB "`nReturn Code: " _SQLite_ReturnCode("SQLITE_ERROR"),-1)
      } else {
         _SQLite_StrToUTF8(SQL, UTF8)
         Err := 0
         RC := DllCall("SQlite3\sqlite3_exec", "Ptr", DB, "Ptr", &UTF8, "Ptr", 0, "Ptr", 0, "Ptr*", Err, "Cdecl Int")
         if (ErrorLevel) {
            throw Exception("DLLCall sqlite3_exec failed!",-1)
         } else {
            if (RC) {
               
               SQLite_LastError(StrGet(Err, "UTF-8"))
               
               try
               {
                  DllCall("SQLite3\sqlite3_free", "Ptr", Err, "cdecl")
                  ErrorLevel := RC
               } catch e
               {
                   ;throw Exception("sqlite3_free failed.`n`nErr:" Err "`n`nChild Exception:`n" e.What " `n" e.Message, -1)
                   ; just igonre for now
               }

            } else
               ret := true
         }
      }
   } catch e
     throw Exception("SQLite_Exec failed.`n`n" sql "`n`nChild Exception:`n" e.What " `n" e.Message, -1)

   return ret
}
;=======================================================================================================================
; Function Name:    SQlite_Query()
; Description:      Prepares a single statement SQLite query,
; Parameter(s):     DB  - DB handle, -1 for last opened DB
;                   SQL - SQL statement to be executed
; Return Value(s):  On Success - Query handle
;                   On Failure - False, check ErrorLevel for details
;                                For additional error message call SQLite_LastError()
;=======================================================================================================================
SQlite_Query(DB, SQL) {
   SQLite_LastError(" ")
   if (DB = -1)
      DB := _SQLite_CurrentDB()
   if !_SQLite_CheckDB(DB) {
      SQLite_LastError("ERROR: Invalid database handle " . DB)
      ErrorLevel := _SQLite_ReturnCode("SQLITE_ERROR")
      Return False
   }
   Query := pSQL := 0
   Len := _SQLite_StrToUTF8(SQL, UTF8)
   RC := DllCall("SQlite3\sqlite3_prepare", "Ptr", DB, "Ptr", &UTF8, "Int", Len
               , "Ptr*", Query, "Ptr*", pSQL, "Cdecl Int")
   if (ErrorLeveL) {
      SQLite_LastError("ERROR: DLLCall sqlite3_prepare failed!")
      Return False
   }
   if (RC) {
      if SQLite_ErrMsg(DB, Msg)
         SQLite_LastError(Msg)
      ErrorLevel := RC
      Return False
   }
   _SQLite_CheckQuery(Query, DB)
   _SQLite_CurrentQuery(Query)
   Return Query
}
;=======================================================================================================================
; Function Name:    SQLite_FetchNames()
; Description:      Provides the column names of a SQLite_Query() based query
; Parameter(s):     Query - Query handle, -1 for last prepared query
;                   ByRef Names - Passes out an array containing the column names
; Return Value(s):  On Success - True
;                   On Failure - False, check ErrorLevel for details
;                                For additional error message call SQLite_LastError()
;=======================================================================================================================
SQLite_FetchNames(Query, ByRef Names) {
   SQLite_LastError(" ")
   Names := Array()
   if (Query = -1)
      Query := _SQLite_CurrentQuery()
   if !(DB := _SQLite_CheckQuery(Query)) {
      SQLite_LastError("ERROR: Invalid query handle " . Query)
      ErrorLevel := _SQLite_ReturnCode("SQLITE_ERROR")
      Return False
   }
   RC := DllCall("SQlite3\sqlite3_column_count", "Ptr", Query, "Cdecl Int")
   if (ErrorLevel) {
      SQLite_LastError("ERROR: DLLCall sqlite3_column_count failed!")
      Return False
   }
   if (RC < 1) {
      SQLite_LastError("ERROR: Query result is empty!")
      ErrorLevel := _SQLite_ReturnCode("SQLITE_EMPTY")
      Return False
   }
   Loop, %RC% {
      StrPtr := DllCall("SQlite3\sqlite3_column_name", "Ptr", Query, "Int", A_Index - 1, "Cdecl Ptr")
      if (ErrorLevel) {
         SQLite_LastError("ERROR: DLLCall sqlite3_column_name failed!")
         Return False
      }
      Names[A_Index] := StrGet(StrPtr, "UTF-8")
   }
   Return True
}

;=======================================================================================================================
; Function Name:    SQLite_QueryFinalize()
; Description:      Finalizes SQLite_Query() based query,
;                   Query handle will be not valid any more
; Parameter(s):     Query - Query handle, -1 for last prepared query
; Return Value(s):  On Success - True
;                   On Failure - False, check ErrorLevel for details
;                                For additional error message call SQLite_LastError()
;=======================================================================================================================
SQLite_QueryFinalize(Query) {
   SQLite_LastError(" ")
   if (Query = -1)
      Query := _SQLite_CurrentQuery()
   if !(DB := _SQLite_CheckQuery(Query)) {
      SQLite_LastError("ERROR: Invalid query handle " . Query)
      ErrorLevel := _SQLite_ReturnCode("SQLITE_ERROR")
      Return False
   }
   RC := DllCall("SQlite3\sqlite3_finalize", "Ptr", Query, "Cdecl Int")
   if (ErrorLevel) {
      SQLite_LastError("ERROR: DLLCall sqlite3_finalize failed!")
      Return False
   }
   if (RC) {
      if SQLite_ErrMsg(DB, Msg)
         SQLite_LastError(Msg)
      ErrorLevel := RC
      Return False
   }
   _SQLite_CheckQuery(Query, 0)
   Return True
}
;=======================================================================================================================
; Function Name:    SQLite_QueryReset()
; Description:      Resets SQLite_Query() based query for reuse
; Parameter(s):     Query - Query handle, -1 for last prepared query
; Return Value(s):  On Success - True
;                   On Failure - False, check ErrorLevel for details
;                                For additional error message call SQLite_LastError()
;=======================================================================================================================
SQLite_QueryReset(Query) {
   SQLite_LastError(" ")
   if (Query = -1)
      Query := _SQLite_CurrentQuery()
   if !(DB := _SQLite_CheckQuery(Query)) {
      SQLite_LastError("ERROR: Invalid query handle " . Query)
      ErrorLevel := _SQLite_ReturnCode("SQLITE_ERROR")
      Return False
   }
   RC := DllCall("SQlite3\sqlite3_reset", "Ptr", Query, "Cdecl Int")
   if (ErrorLevel) {
      SQLite_LastError("ERROR: DLLCall sqlite3_finalize failed!")
      Return False
   }
   if (RC) {
      if SQLite_ErrMsg(DB, Msg)
         SQLite_LastError(Msg)
      ErrorLevel := RC
      Return False
   }
   Return True
}
;=======================================================================================================================
; Function Name:    SQLite_SQLiteExe()
; Description:      Executes commands with SQLite3.exe
; Requirements:     Valid path for SQLite3.exe stored in SQLite_EXEPath().
;                   Default: A_ScriptDir . "\SQLite3.EXE"
; Parameter(s):     DBFile - DB filename
;                   Commands - Commands for SQLite3.exe
;                   ByRef Output - Raw output from SQLite3.exe
; Return Value(s):  On Success - True
;                   On Failure - False, check ErrorLevel for details
;                                For additional error message call SQLite_LastError()
;=======================================================================================================================
SQLite_SQLiteExe(DBFile, Commands, ByRef Output) {
   Static InputFile := "~SQLINP.TXT"
   Static OutputFile := "~SQLOUT.TXT"
   SQLite_LastError(" ")
   Output := ""
   SQLiteExe := SQLite_EXEPath()
   if !FileExist(SQLiteExe) {
      SQLite_LastError("ERROR: Unable to find " . SQLiteExe . "!")
      ErrorLevel := _SQLite_ReturnCode("SQLITE_ERROR")
      Return False
   }
   if FileExist(InputFile) {
      FileDelete, %InputFile%
      if (ErrorLevel) {
         SQLite_LastError("ERROR: Unable to delete " . InputFile . "!")
         Return False
      }
   }
   if FileExist(OutputFile) {
      FileDelete, %OutputFile%
      if (ErrorLevel) {
         SQLite_LastError("ERROR: Unable to delete " . OutputFile . "!")
         Return False
      }
   }
   if !InStr(Commands, ".output stdout")
      Commands := ".output stdout`n" . Commands
   FileAppend, %Commands%, %InputFile%, UTF-8-RAW
   if (ErrorLevel) {
      SQLite_LastError("ERROR: Unable to create " . InputFile . "!")
      Return False
   }
   Cmd = ""%SQLiteExe%" "%DBFile%" < "%InputFile%" > "%OutputFile%"" ;"
      
   RunWait %comspec% /c %Cmd%, , Hide UseErrorLevel
   if (Errorlevel) {
      SQLite_LastError("ERROR: Error occured running " . SQLiteExe . "!")
      Return False
   }
   FileRead, Output, %OutputFile%
   if (ErrorLevel) {
      SQLite_LastError("ERROR: Unable to read " . OutputFile . "!")
      Return False
   }
   if InStr(Output, "SQL error:") || InStr(Output, "Incomplete SQL:") {
      SQLite_LastError("ERROR: " . SQLiteExe . " reported an Error!")
      ErrorLevel := _SQLite_ReturnCode("SQLITE_ERROR")
      Return False
   }
   Return True
}
;=======================================================================================================================
; Function Name:    SQLite_LibVersion()
; Description:      Returns the version number of the SQLite3.dll
; Parameter(s):     None
; Return Value(s):  On Success - Version number
;                   On Failure - False, check ErrorLevel for details
;                                For additional error message call SQLite_LastError()
;=======================================================================================================================
SQLite_LibVersion() {
   SQLite_LastError(" ")
   StrPtr := DllCall("SQlite3\sqlite3_libversion", "Cdecl Ptr")
   if (ErrorLevel) {
      SQLite_LastError("ERROR: DLLCall sqlite3_libversion failed!")
      Return False
   }
   Return StrGet(StrPtr, "UTF-8")
}
;=======================================================================================================================
; Function Name:    SQLite_LastInsertRowID()
; Description:      Returns the ROWID of the most recent INSERT in the DB
; Parameter(s):     DB - DB handle, -1 for last opened DB
;                   ByRef RowID - passes out ROWID
; Return Value(s):  On Success - True
;                   On Failure - False, check ErrorLevel for details
;                                For additional error message call SQLite_LastError()
;=======================================================================================================================
SQLite_LastInsertRowID(DB, ByRef rowId) {
   SQLite_LastError(" ")
   RowID := 0
   if (DB = -1)
      DB := _SQLite_CurrentDB()
   if !_SQLite_CheckDB(DB) {
      SQLite_LastError("ERROR: Invalid DB Handle " . DB . "!")
      Return False
   }
   rowId := DllCall("SQLite3\sqlite3_last_insert_rowid", "Ptr", DB, "Cdecl Int64") ; Each entry in an SQLite table has a unique 64-bit signed integer key called the "rowid".
   if (ErrorLevel) {
      SQLite_LastError("ERROR: DLLCall sqlite3_last_insert_rowid failed!")
      Return False
   }
   Return True
}
;=======================================================================================================================
; Function Name:    SQLite_Changes()
; Description:      Returns the number of DB rows that were changed
;                   by the most recently completed query
; Parameter(s):     DB - DB handle, -1 for last opened DB
;                   ByRef Rows - Passes out number of changes
; Return Value(s):  On Success - True
;                   On Failure - False, check ErrorLevel for details
;                                For additional error message call SQLite_LastError()
;=======================================================================================================================
SQLite_Changes(DB, ByRef Rows) {
   SQLite_LastError(" ")
   Rows := 0
   if (DB = -1)
      DB := _SQLite_CurrentDB()
   if !_SQLite_CheckDB(DB) {
      SQLite_LastError("ERROR: Invalid DB Handle " . DB . "!")
      Return False
   }
   RC := DllCall("SQLite3\sqlite3_changes", "Ptr", DB, "Cdecl Ptr")
   if (ErrorLevel) {
      SQLite_LastError("ERROR: DLLCall sqlite3_changes failed!")
      Return False
   }
   Rows := RC
   Return True
}
;=======================================================================================================================
; Function Name:    SQLite_TotalChanges()
; Description:      Returns the total number of DB rows that have been
;                   modified, inserted, or deleted since the DB connection
;                   was created
; Parameter(s):     DB - DB handle, -1 for last opened DB
;                   ByRef Rows - Passes out the number of changes
; Return Value(s):  On Success - True
;                   On Failure - False, check ErrorLevel for details
;                                For additional error message call SQLite_LastError()
;=======================================================================================================================
SQLite_TotalChanges(DB, ByRef Rows) {
   SQLite_LastError(" ")
   Rows := 0
   if (DB = -1)
      DB := _SQLite_CurrentDB()
   if !_SQLite_CheckDB(DB) {
      SQLite_LastError("ERROR: Invalid DB Handle " . DB . "!")
      Return False
   }
   RC := DllCall("SQLite3\sqlite3_total_changes", "Ptr", DB, "Cdecl Ptr")
   if (ErrorLevel) {
      SQLite_LastError("ERROR: DLLCall sqlite3_total_changes failed!")
      Return False
   }
   Rows := RC
   Return True
}
;=======================================================================================================================
; Function Name:    SQLite_ErrMsg()
; Description:      Returns the error message for the most recent sqlite3_* API call as string
; Parameter(s):     DB - DB handle, -1 for last opened DB
;                   ByRef Msg - Passes out the error message
; Return Value(s):  On Success - True
;                   On Failure - False, check ErrorLevel for details
;                                For additional error message call SQLite_LastError()
;=======================================================================================================================
SQLite_ErrMsg(DB, ByRef Msg) {
   SQLite_LastError(" ")
   Msg := ""
   if (DB = -1)
      DB := _SQLite_CurrentDB()
   if !_SQLite_CheckDB(DB) {
      SQLite_LastError("ERROR: Invalid DB Handle " . DB . "!")
      Return False
   }
   messagePtr := DllCall("SQLite3\sqlite3_errmsg", "Ptr", DB, "Cdecl Ptr")
   if (ErrorLevel) {
      SQLite_LastError("ERROR: DLLCall sqlite3_errmsg failed!")
      Return False
   }
   Msg := StrGet(messagePtr, "UTF-8")
   Return True
}
;=======================================================================================================================
; Function Name:    SQLite_ErrCode()
; Description:      Returns the error code for the most recent sqlite3_* API call as string.
; Parameter(s):     DB - DB handle, -1 for last opened DB
;                   ByRef Code - Passes out the error code
; Return Value(s):  On Success - True
;                   On Failure - False, check ErrorLevel for details
;                                For additional error message call SQLite_LastError()
;=======================================================================================================================
SQLite_ErrCode(DB, ByRef Code)
{
   SQLite_LastError(" ")
   Code := ""
   if (DB = -1)
      DB := _SQLite_CurrentDB()
   if !_SQLite_CheckDB(DB) {
      SQLite_LastError("ERROR: Invalid DB Handle " . DB . "!")
      Return False
   }
   RC := DllCall("SQLite3\sqlite3_errcode", "Ptr", DB, "Cdecl Ptr")
   if (ErrorLevel) {
      SQLite_LastError("ERROR: DLLCall sqlite3_errcode failed!")
      Return False
   }
   Code := RC
   Return True
}
;=======================================================================================================================
; Function Name:    SQLite_SetTimeout()
; Description:      Sets timeout for DB's "busy handler"
; Parameter(s):     hDB - DB handle, -1 for last opened DB
;                   Optional Timeout - Timeout [msec]
; Return Value(s):  On Success - True
;                   On Failure - False, check ErrorLevel for details
;                                For additional error message call SQLite_LastError()
;=======================================================================================================================
SQLite_SetTimeout(DB, Timeout = 1000) {
   SQLite_LastError(" ")
   Msg := ""
   if (DB = -1)
      DB := _SQLite_CurrentDB()
   if !_SQLite_CheckDB(DB) {
      SQLite_LastError("ERROR: Invalid DB Handle " . DB . "!")
      Return False
   }
   if Timeout Is Not Integer
      Timeout := 1000
   RC := DllCall("SQLite3\sqlite3_busy_timeout", "Ptr", DB, "Cdecl Int")
   if (ErrorLevel) {
      SQLite_LastError("ERROR: DLLCall sqlite3_busy_timeout failed!")
      Return False
   }
   if (RC) {
      if SQLite_ErrMsg(DB, Msg)
         SQLite_LastError(Msg)
      ErrorLevel := RC
      Return False
   }
   Return True
}
;=======================================================================================================================
; Function Name:    SQLite_LastError()
; Description:      Provides additional error description for the last error
; Parameter(s):     Optional Error - for internal use only!!!
; Return Value(s):  Error description or ""
;=======================================================================================================================
SQLite_LastError(Error = "") {
   Static LastError := ""
   if (Error != "")
      LastError := Error
   Return LastError
}
;=======================================================================================================================
; Function Name:    SQLite_DLLPath()
; Description:      Stores/provides the path for SQLite3.dll
;                   SQLite DLL is assumed to be in the scripts directory, if not
;                   you have to call the function with the valid path before any
;                   other function calls!
; Parameter(s):     Optional Path - Path for SQLite3.dll
; Return Value:     Path to SQLite DLL
;=======================================================================================================================

SQLite_DLLPath(forcedPath = "") {
   static DLLPath := ""
   static dllname := "SQLite3.dll"

   if(DLLPath == ""){
      ; search the dll
      prefix := (A_PtrSize == 8) ? "x64\" : ""
      dllpath := prefix . dllname
      
      if (FileExist(A_ScriptDir . "\" . dllpath))
         DLLPath := A_ScriptDir . "\"  . dllpath
      else
         DLLPath := A_ScriptDir . "\Lib\" . dllpath
   }
   
   if (forcedPath != "")
      DLLPath := forcedPath

   return DLLPath
}


;=======================================================================================================================
; Function Name:    SQLite_EXEPath()
; Description:      Stores/provides the path for SQLite3.exe
;                   SQLite EXE is assumed to be in the scripts directory, if not
;                   you have to call the function with the valid path before any
;                   calls on SQLite_SQLite_Exe()!
; Parameter(s):     Optional Path - Path for SQLite3.exe
; Return Value:     Path to SQLite DLL
;=======================================================================================================================
SQLite_EXEPath(forcedPath = "") {
   static EXEPath := ""
   
   if (EXEPath == ""){
      if (FileExist(A_ScriptDir . "\SQLite3.exe"))
         EXEPath := A_ScriptDir . "\SQLite3.exe"
      else if (FileExist(A_ScriptDir . "\Lib\SQLite3.exe"))
         EXEPath := A_ScriptDir . "\Lib\SQLite3.exe"
   }
   if (forcedPath != "")
      EXEPath := forcedPath
   Return EXEPath
}
;=======================================================================================================================
; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; !!! Following functions and classes are for internal use only !!!
; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;=======================================================================================================================
; Function Name:    _SQLite_StrToUTF8()
; Description:      Converts Str to UTF-8
;=======================================================================================================================
_SQLite_StrToUTF8(Str, ByRef UTF8) {
   VarSetCapacity(UTF8, StrPut(Str, "UTF-8"), 0)
   Return StrPut(Str, &UTF8, "UTF-8")
}
;=======================================================================================================================
; Function Name:    _SQLite_UTF8ToStr()
; Description:      Converts UTF-8 to Str
;=======================================================================================================================
_SQLite_UTF8ToStr(UTF8, ByRef Str) {
   Str := StrGet(&UTF8, "UTF-8")
   Return StrLen(Str)
}
;=======================================================================================================================
; Function Name:    _SQLite_ModuleHandle()
; Description:      Stores/provides DLL's module handle
;=======================================================================================================================
_SQLite_ModuleHandle(Handle = "") {
   Static ModuleHandle := ""
   if (Handle != "")
      ModuleHandle := Handle
   Return ModuleHandle
}
;=======================================================================================================================
; Function Name:    _SQLite_CurrentDB()
; Description:      Stores\provides the current (last opened) DB handle
;=======================================================================================================================
_SQLite_CurrentDB(DB = "") {
   Static CurrentDB := 0
   if (DB != "")
      CurrentDB := DB
   Return CurrentDB
}
;=======================================================================================================================
; Function Name:    _SQLite_CheckDB()
; Description:      Stores\frees\validates the given DB handle
;=======================================================================================================================
_SQLite_CheckDB(DB, Action = "") {
   Static ValidHandles := {}
   DB += 0
   if DB Is Not Integer
      Return False
   if (DB = 0)
      Return False
   if (Action = "Store") {
      ValidHandles[DB] := True
      Return True
   }
   if (Action = "Free") {
      if ValidHandles.HasKey(DB)
         ValidHandles.Remove(DB, "")
      Return True
   }
   Return ValidHandles.HasKey(DB)
}
;=======================================================================================================================
; Function Name:    _SQLite_CurrentQuery()
; Description:      Stores\provides the current (last prepared) query handle
;=======================================================================================================================
_SQLite_CurrentQuery(Query = "") {
   Static CurrentQuery := 0
   if (Query != "")
      CurrentQuery := Query
   Return CurrentQuery
}
;=======================================================================================================================
; Function Name:    _SQLite_CheckQuery()
; Description:      Stores\frees\validates the given query handle
;=======================================================================================================================
_SQLite_CheckQuery(Query, DB = "") {
   Static ValidQueries := {}
   Query += 0   
   if Query Is Not Integer
      Return False
   if (Query = 0)
      Return False
   if (DB = 0) {
      if ValidQueries.HasKey(Query)
         ValidQueries.Remove(Query, "")
      Return True
   }
   if (DB != "") {
      ValidQueries[Query] := DB
      Return True
   }
   Return ValidQueries.HasKey(Query) ? ValidQueries[Query] : False
}
;=======================================================================================================================
; Function Name:    _SQLite_ReturnCode(RC)
; Description:      Returns numeric RC for literal RC
;=======================================================================================================================
_SQLite_ReturnCode(RC) {
   Static RCTXT :={ SQLITE_OK: 0          ; Successful result
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
   Return RCTXT.HasKey(RC) ? RCTXT[RC] : ""
}
