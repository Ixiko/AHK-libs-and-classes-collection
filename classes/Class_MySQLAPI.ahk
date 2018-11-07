; ======================================================================================================================
; Wrapper class for MySQL C API functions        -> http://dev.mysql.com/doc/refman/5.5/en/c-api-functions.html
; Based on "MySQL Library functions" by panofish -> http://www.autohotkey.com/board/topic/72629-mysql-library-functions
; Namespace:   MySQLAPI
; AHK version: 1.1.10+
; Author:      panofish/just me
; Version:     1.0.01.00/2015-08-20/just me        - libmysql.dll error handling
;              1.0.00.00/2013-06-15/just me
;
; Example usage:
;    #Include <Class_MySQLAPI>                                       ; include Class_MySQLAPI.ahk from lib
;    My_DB := New MySQLAPI                                           ; instantiate an object using this class
;    My_DB.Connect("Server", "User", "Password")                     ; connect to the server
;    My_DB.Select_DB("Database")                                     ; select a database
;    or
;    My_DB.Real_Connect("Server", "User", "Password", "Database")    ; connect to the server and select a database
;    SQL := "SELECT ..."                                             ; create a SQL statement
;    Result := My_DB.Query(SQL)                                      ; execute the SQL statement
;    ...                                                             ; do something
;    ...                                                             ; do another thing
;    My_DB := ""                                                     ; close the connection and free all resources
;
; Remarks:
; The character encoding depends on the character set used by the current connection. That's why the code page for
; all connections is set to UTF-8 within the __New() meta-function. String conversions are done internally
; whenever possible.
; ======================================================================================================================
Class MySQLAPI {
   ; ===================================================================================================================
   ; CLASS VARIABLES
   ; ===================================================================================================================
   ; MYSQL_FIELD type
   Static FIELD_TYPE := {0: "DECIMAL", 1: "TINY", 2: "SHORT", 3: "LONG", 4: "FLOAT", 5: "DOUBLE", 6: "NULL"
                       , 7: "TIMESTAMP", 8: "LONGLONG", 9: "INT24", 10: "DATE", 11: "TIME", 12: "DATETIME"
                       , 13: "YEAR", 14: "NEWDATE", 15: "VARCHAR", 16: "BIT", 256: "NEWDECIMAL", 247: "ENUM"
                       , 248: "SET", 249: "TINY_BLOB", 250: "MEDIUM_BLOB", 251: "LONG_BLOB", 252: "BLOB"
                       , 253: "VAR_STRING", 254: "STRING", 255: "GEOMETRY"}
   ; MYSQL_FIELD bit-flags
   Static FIELD_FLAG := {NOT_NULL: 1, PRI_KEY: 2, UNIQUE_KEY: 4, MULTIPLE_KEY: 8, BLOB: 16, UNSIGNED: 32
                       , ZEROFILL: 64, BINARY: 128, ENUM: 256, AUTO_INCREMENT: 512, TIMESTAMP: 1024, SET: 2048
                       , NO_DEFAULT_VALUE: 4096, NUM:	32768}
   ; MySQL_SUCCESS
   Static MySQL_SUCCESS := 0
   ; ===================================================================================================================
   ; META FUNCTION __New
   ; Load and initialize libmysql.dll which is supposed to be in the sript's folder.
   ; Parameters:    LibPath  - Optional: Absolute path of libmysql.dll
   ; ===================================================================================================================
   __New(LibPath := "") {
      Static LibMySQL := A_ScriptDir . "\libmysql.dll"
      ; Do not instantiate unstances!
      If (This.Base.Base.__Class = "MySQLAPI") {
         MsgBox, 16, MySQL Error!, You must not instantiate instances of MySQLDB!
         Return False
      }
      ; Load libmysql.dll
      If (LibPath)
         LibMySQL := LibPath
      If !(MySQLM := DllCall("Kernel32.dll\LoadLibrary", "Str", LibMySQL, "UPtr")) {
         If (A_LastError = 126) ; The specified module could not be found
            MsgBox, 16, MySQL Error!, Could not find %LibMySQL%!
         Else {
            ErrCode := A_LastError
            VarSetCapacity(ErrMsg, 131072, 0) ; Unicode
            DllCall("FormatMessage", "UInt", 0x1200, "Ptr", 0, "UInt", ErrCode, "UInt", 0, "Str", ErrMsg, "UInt", 65536, "Ptr", 0)
            MsgBox, 16, MySQL Error!, % "Could not load " . LibMySQL . "!`n"
                                      . "Error code: " . ErrCode . "`n"
                                      . ErrMsg
         }
         Return False
      }
      This.Module := MySQLM
      ; Init MySQL
      If !(MYSQL := This.Init()) {
         MsgBox, 16, MySQL Error!, Could not initialize MySQL!
         Return False
      }
      This.MYSQL := MYSQL
      If (This.Options("MYSQL_SET_CHARSET_NAME", "utf8") <> This.MySQL_SUCCESS) {
         MsgBox, 16, MySQL Error!, Set option MYSQL_SET_CHARSET_NAME failed!
         Return False
      }
      If (This.Options("MYSQL_OPT_RECONNECT", True) <> This.MySQL_SUCCESS) {
         MsgBox, 16, MySQL Error!, Set option MYSQL_OPT_RECONNECT failed!
         Return False
      }
      This.Connected := False
   }
   ; ===================================================================================================================
   ; META FUNCTION __Delete
   ; Free ressources and close the connection, if needed.
   ; ===================================================================================================================
   __Delete() {
      If (This.MYSQL)
         This.Close()
      If (This.Module)
         DllCall("Kernel32.dll\FreeLibrary", "Ptr", This.Module)
   }
   ; ===================================================================================================================
   ; ===================================================================================================================
   ; ===================================================================================================================
   ; Additional custom functions to get the data of a MYSQL_RES structure
   ; ===================================================================================================================
   ; ===================================================================================================================
   ; ===================================================================================================================
   ; Converts a MYSQL_FIELD structure and returns an object containing the appropriate keys and values.
   ; Parameters:    MYSQL_FIELD - Pointer to a MYSQL_FIELD structure.
   ; Return values: Field object.
   ; ===================================================================================================================
   GetField(ByRef MYSQL_FIELD) {
      Field := {}
      Offset := 0
      Field.Name      := StrGet(NumGet(MYSQL_FIELD + 0, Offset, "UPtr"), "UTF-8"), Offset += A_PtrSize
      Field.OrgName   := StrGet(NumGet(MYSQL_FIELD + 0, Offset, "UPtr"), "UTF-8"), Offset += A_PtrSize
      Field.Table     := StrGet(NumGet(MYSQL_FIELD + 0, Offset, "UPtr"), "UTF-8"), Offset += A_PtrSize
      Field.OrgTable  := StrGet(NumGet(MYSQL_FIELD + 0, Offset, "UPtr"), "UTF-8"), Offset += A_PtrSize
      Field.DB        := StrGet(NumGet(MYSQL_FIELD + 0, Offset, "UPtr"), "UTF-8"), Offset += A_PtrSize
      Field.Catalog   := StrGet(NumGet(MYSQL_FIELD + 0, Offset, "UPtr"), "UTF-8"), Offset += A_PtrSize
      Field.Default   := StrGet(NumGet(MYSQL_FIELD + 0, Offset, "UPtr"), "UTF-8"), Offset += A_PtrSize
      Field.Length    := NumGet(MYSQL_FIELD + 0, Offset, "UInt"), Offset += 4
      Field.MaxLength := NumGet(MYSQL_FIELD + 0, Offset, "UInt"), Offset += 4 * 8 ; skip string length fields
      Field.Flags     := NumGet(MYSQL_FIELD + 0, Offset, "UInt"), Offset += 4
      Field.Decimals  := NumGet(MYSQL_FIELD + 0, Offset, "UInt"), Offset += 4
      Field.CharSetNr := NumGet(MYSQL_FIELD + 0, Offset, "UInt"), Offset += 4
      Field.Type      := This.FIELD_TYPE[NumGet(MYSQL_FIELD + 0, Offset, "UInt")]
      Return Field
   }
   ; ===================================================================================================================
   ; Returns the values of the next row of the given MYSQL_RES as an array.
   ; Parameters:    MYSQL_RES - Pointer to a MYSQL_RES structure.
   ; Return values: Array of values, False if there is no more row
   ; ===================================================================================================================
   GetNextRow(MYSQL_RES) {
      If (MYSQL_ROW := This.Fetch_Row(MYSQL_RES)) {
         Row := []
         Lengths := This.Fetch_Lengths(MYSQL_RES)
         Loop, % This.Num_Fields(MYSQL_RES) {
            J := A_Index - 1
            If (Len := NumGet(Lengths + 0, 4 * J, "UInt"))
               Row[A_Index] := (StrGet(NumGet(MYSQL_ROW + 0, A_PtrSize * J, "UPtr"), Len, "UTF-8"))
            Else
               Row[A_Index] := ""
         }
         Return Row
      }
      Return False
   }
   ; ===================================================================================================================
   ; Gets the result for the most recent query that successfully produced a result set and returns an object containing
   ; the appropriate keys and values.
   ; Return values: Result object, or False if there is no result.
   ; ===================================================================================================================
   GetResult() {
      If !(MYSQL_RES := This.Store_Result(This.MYSQL))
            Return False
      Result := {}
      Result.Rows := This.Num_Rows(MYSQL_RES)
      Result.Columns := This.Num_Fields(MYSQL_RES)
      Result.Fields := []
      While(MYSQL_FIELD := This.Fetch_Field(MYSQL_RES))
         Result.Fields[A_Index] := This.GetField(MYSQL_FIELD)
      While (Row := This.GetNextRow(MYSQL_RES))
         Result[A_index] := Row
      This.Free_Result(MYSQL_RES)
      Return Result
   }
   ; ===================================================================================================================
   ; Converts the passed string to UTF-8.
   ; Parameters:    Str - String to convert.
   ; Return values: Address of Str.
   ; ===================================================================================================================
   UTF8(ByRef Str) {
      Var := Str, VarSetCapacity(Str, StrPut(Var, "UTF-8"), 0), StrPut(Var, &Str, "UTF-8")
      Return &Str
   }
   ; ===================================================================================================================
   ; ===================================================================================================================
   ; ===================================================================================================================
   ; API functions
   ; ===================================================================================================================
   ; ===================================================================================================================
   ; ===================================================================================================================
   ; May be called immediately after executing a statement with mysql_query() or mysql_real_query(). It returns the
   ; number of rows changed, deleted, or inserted by the last statement if it was an UPDATE, DELETE, or INSERT.
   ; Return values: An integer greater than zero indicates the number of rows affected or retrieved.
   ; ===================================================================================================================
   Affected_Rows() {
      Return DllCall("libmysql.dll\mysql_affected_rows", "Ptr", This.MYSQL, "UInt64")
   }
   ; ===================================================================================================================
   ; Sets autocommit mode on if Mode is 1, off if Mode is 0.
   ; Parameters:    Mode  - 0/1 (False/True)
   ; Return values: Zero if successful. Nonzero if an error occurred.
   ; ===================================================================================================================
   AutoCommit(Mode) {
      Return DllCall("libmysql.dll\mysql_autocommit", "Ptr", This.MYSQL, "Char", Mode, "Char")
   }
   ; ===================================================================================================================
   ; Changes the user and causes the database specified by DB to become the default (current) database on the connection
   ; specified by mysql.
   ; Parameters:    User     - User name
   ;                PassWd   - Password
   ;                DB       - Database name
   ; Return values: Zero if successful. Nonzero if an error occurred.
   ; ===================================================================================================================
   Change_User(User, PassWd, DB) {
      Return DllCall("libmysql.dll\mysql_change_user", "Ptr", This.MYSQL, "Ptr", This.UTF8(User)
                  , "Ptr", This.UTF8(PassWd), "Ptr", This.UTF8(DB), "Char")
   }
   ; ===================================================================================================================
   ; Returns a string containing the default character set name for the current connection.
   ; Return values: String.
   ; ===================================================================================================================
   Character_Set_Name() {
      Return ((P := DllCall("libmysql.dll\mysql_character_set_name", "Ptr", This.MYSQL, "UPtr")) ? StrGet(P, "UTF-8") : "")
   }
   ; ===================================================================================================================
   ; Closes a previously opened connection.
   ; Return values: None
   ; ===================================================================================================================
   Close() {
      DllCall("libmysql.dll\mysql_close", "Ptr", This.MYSQL)
   }
   ; ===================================================================================================================
   ; Commits the current transaction.
   ; Return values: Zero if successful. Nonzero if an error occurred.
   ; ===================================================================================================================
   Commit() {
      Return DllCall("libmysql.dll\mysql_commit", "Ptr", This.MYSQL, "Char")
   }
   ; ===================================================================================================================
   ; This function is deprecated. Use mysql_real_connect() instead.
   ; ===================================================================================================================
   Connect(Host, User, PassWd) {
      Return This.Real_Connect(Host, User, PassWD)
   }
   ; ===================================================================================================================
   ; Creates the database named by the DB parameter.
   ; This function is deprecated. It is preferable to use mysql_query() to issue an SQL CREATE DATABASE statement
   ; instead.
   ; Parameters:    DB    - Database name
   ; Return values: Zero if the database was created successfully. Nonzero if an error occurred.
   ; ===================================================================================================================
   Create_DB(DB) {
      Return DllCall("libmysql.dll\mysql_create_db", "Ptr", This.MYSQL, "Ptr", This.UTF8(DB), "Int")
   }
   ; ===================================================================================================================
   ; Seeks to an arbitrary row in a query result set. The Offset value is a row number.
   ; Parameters:    MYSQL_RES - Pointer to a MYSQL_RES structure
   ;                Offset    - Specify a value in the range from 0 to mysql_num_rows(result)-1.
   ; Return values: None
   ; ===================================================================================================================
   Data_Seek(MYSQL_RES, Offset) {
      DllCall("libmysql.dll\mysql_data_seek", "Ptr", MYSQL_RES, "UInt64", Offset)
   }
   ; ===================================================================================================================
   ; mysql_debug() - not implemented <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   ; ===================================================================================================================
   ; ===================================================================================================================
   ; Drops the database named by the DB parameter.
   ; This function is deprecated. It is preferable to use mysql_query() to issue an SQL DROP DATABASE statement instead.
   ; Parameters:    DB    - Database name
   ; Return values: Zero if the database was dropped  successfully. Nonzero if an error occurred.
   ; ===================================================================================================================
   Drop_DB(DB) {
      Return DllCall("libmysql.dll\mysql_drop_db", "Ptr", This.MYSQL, "Ptr", This.UTF8(DB), "Int")
   }
   ; ===================================================================================================================
   ; mysql_dump_debug_info() - not implemented <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   ; ===================================================================================================================
   ; ===================================================================================================================
   ; Determines whether the last row of a result set has been read.
   ; This function is deprecated. mysql_errno() or mysql_error() may be used instead.
   ; Parameters:    MYSQL_RES - Pointer to a MYSQL_RES structure
   ; Return values: Zero if no error occurred. Nonzero if the end of the result set has been reached.
   ; ===================================================================================================================
   EOF(MYSQL_RES) {
      Return DllCall("libmysql.dll\mysql_eof", "Ptr", MYSQL_RES, "Char")
   }
   ; ===================================================================================================================
   ; Returns the error code for the most recently invoked API function that can succeed or fail.
   ; Return values: An error code value for the last mysql_xxx() call, if it failed. zero means no error occurred.
   ; ===================================================================================================================
   ErrNo() {
      Return DllCall("libmysql.dll\mysql_errno", "Ptr", This.MYSQL, "UInt")
   }
   ; ===================================================================================================================
   ; Returns a null-terminated string containing the error message for the most recently invoked API
   ; function that failed. An empty string indicates no error.
   ; Return values: String.
   ; ===================================================================================================================
   Error() {
      Return ((S := DllCall("libmysql.dll\mysql_error", "Ptr", This.MYSQL, "UPtr")) ? StrGet(S, "UTF-8") : "")
   }
   ; ===================================================================================================================
   ; mysql_escape_string() ->  mysql_real_escape_string()
   ; ===================================================================================================================
   ; ===================================================================================================================
   ; Returns the definition of the next column of a result set as a MYSQL_FIELD structure.
   ; Parameters:    MYSQL_RES - Pointer to a MYSQL_RES structure
   ; Return values: A pointer to the MYSQL_FIELD structure for the current column. NULL if no columns are left.
   ; ===================================================================================================================
   Fetch_Field(MYSQL_RES) {
      Return DllCall("libmysql.dll\mysql_fetch_field", "Ptr", MYSQL_RES, "UPtr")
   }
   ; ===================================================================================================================
   ; Given a field number FieldNr for a column within a result set, returns that column's field definition as
   ; a MYSQL_FIELD structure.
   ; Parameters:    MYSQL_RES - Pointer to a MYSQL_RES structure
   ;                FieldNr   - Field number in the range from 0 to mysql_num_fields(result)-1.
   ; Return values: A Pointer to the MYSQL_FIELD structure for the specified column.
   ; ===================================================================================================================
   Fetch_Field_Direct(MYSQL_RES, FieldNr) {
      Return DllCall("libmysql.dll\mysql_fetch_field_direct", "Ptr", MYSQL_RES, "UInt", FieldNr, "UPtr")
   }
   ; ===================================================================================================================
   ; Returns an array of all MYSQL_FIELD structures for a result set. Each structure provides the field definition for
   ; one column of the result set.
   ; Parameters:    MYSQL_RES - Pointer to a MYSQL_RES structure
   ; Return values: A Pointer to the MYSQL_FIELD structure for the specified column.
   ; ===================================================================================================================
   Fetch_Fields(MYSQL_RES) {
      Return DllCall("libmysql.dll\mysql_fetch_fields", "Ptr", MYSQL_RES, "UPtr")
   }
   ; ===================================================================================================================
   ; Returns the lengths of the columns of the current row within a result set.
   ; Parameters:    MYSQL_RES - Pointer to a MYSQL_RES structure
   ; Return values: A Pointer to an array of unsigned long integers representing the size of each column
   ;                (not including any terminating null characters). NULL if an error occurred.
   ; ===================================================================================================================
   Fetch_Lengths(MYSQL_RES) {
      Return DllCall("libmysql.dll\mysql_fetch_lengths", "Ptr", MYSQL_RES, "UPtr")
   }
   ; ===================================================================================================================
   ; Retrieves the next row of a result set.
   ; Parameters:    MYSQL_RES - Pointer to a MYSQL_RES structure
   ; Return values: A poiner to a MYSQL_ROW structure, NULL when there are no more rows to retrieve or if an error
   ;                occurred.
   ; ===================================================================================================================
   Fetch_Row(MYSQL_RES) {
      Return DllCall("libmysql.dll\mysql_fetch_row", "Ptr", MYSQL_RES, "UPtr")
   }
   ; ===================================================================================================================
   ; Returns the number of columns for the most recent query on the connection.
   ; Return values: An unsigned integer representing the number of columns in a result set.
   ; ===================================================================================================================
   Field_Count() {
      Return DllCall("libmysql.dll\mysql_field_count", "Ptr", This.MYSQL, "UInt")
   }
   ; ===================================================================================================================
   ; Sets the field cursor to the given offset. The next call to mysql_fetch_field() retrieves the field definition
   ; of the column associated with that offset.
   ; Parameters:    MYSQL_RES - Pointer to a MYSQL_RES structure
   ;                Offset    - Specify a value in the range from 0 to mysql_num_fields(result)-1.
   ;                            To seek to the beginning of a row, pass an offset value of zero.
   ; Return values: The previous value of the field cursor.
   ; ===================================================================================================================
   Field_Seek(MYSQL_RES, Offset) {
      Return DllCall("libmysql.dll\mysql_field_seek", "Ptr", MYSQL_RES, "UInt", Offset, "UInt")
   }
   ; ===================================================================================================================
   ; Returns the position of the field cursor used for the last mysql_fetch_field(). This value can be used as
   ; an argument to mysql_field_seek().
   ; Parameters:    MYSQL_RES -  Pointer to a MYSQL_RES structure
   ; Return values: The current offset of the field cursor.
   ; ===================================================================================================================
   Field_Tell(MYSQL_RES) {
      Return DllCall("libmysql.dll\mysql_field_tell", "Ptr", MYSQL_RES, "UInt")
   }
   ; ===================================================================================================================
   ; Frees the memory allocated for a result set by mysql_store_result(), mysql_use_result(), and so forth.
   ; Parameters:    MYSQL_RES -  Pointer to a MYSQL_RES structure
   ; Return values: None.
   ; ===================================================================================================================
   Free_Result(MYSQL_RES) {
      DllCall("libmysql.dll\mysql_free_result", "Ptr", MYSQL_RES)
   }
   ; ===================================================================================================================
   ; mysql_get_character_set_info() - not implemented <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   ; ===================================================================================================================
   ; ===================================================================================================================
   ; Returns a string that represents the client library version.
   ; Parameters:    None
   ; Return values: String.
   ; ===================================================================================================================
   Get_Client_Info() {
      Return ((S := DllCall("libmysql.dll\mysql_get_client_info", "UPtr")) ? StrGet(S, "UTF-8") : "")
   }
   ; ===================================================================================================================
   ; Returns an integer that represents the client library version. The value has the format XYYZZ where X is the major
   ; version, YY is the release level, and ZZ is the version number within the release level. For example, a value of
   ; 40102 represents a client library version of 4.1.2.
   ; Parameters:    None
   ; Return values: An integer that represents the MySQL client library version.
   ; ===================================================================================================================
   Get_Client_Version() {
      Return DllCall("libmysql.dll\mysql_get_client_version", "Int")
   }
   ; ===================================================================================================================
   ; Returns a string describing the type of connection in use, including the server host name.
   ; Return values: String.
   ; ===================================================================================================================
   Get_Host_Info() {
      Return ((P := DllCall("libmysql.dll\mysql_get_host_info", "Ptr", This.MYSQL, "UPtr")) ? StrGet(P, "UTF-8") : "")
   }
   ; ===================================================================================================================
   ; Returns the protocol version used by current connection.
   ; Return values: An unsigned integer representing the protocol version used by the current connection.
   ; ===================================================================================================================
   Get_Proto_Info() {
      Return DllCall("libmysql.dll\mysql_get_proto_info", "Ptr", This.MYSQL, "UInt")
   }
   ; ===================================================================================================================
   ; Returns a string that represents the server version number.
   ; Return values: String.
   ; ===================================================================================================================
   Get_Server_Info() {
      Return ((P := DllCall("libmysql.dll\mysql_get_server_info", "Ptr", This.MYSQL, "UPtr")) ? StrGet(P, "UTF-8") : "")
   }
   ; ===================================================================================================================
   ; Returns the version number of the server as an unsigned integer.
   ; Return values: A number that represents the MySQL server version, for example, 5.1.5 is returned as 50105.
   ; ===================================================================================================================
   Get_Server_Version() {
      Return DllCall("libmysql.dll\mysql_get_server_version", "Ptr", This.MYSQL, "UInt")
   }
   ; ===================================================================================================================
   ; mysql_get_ssl_cipher() - not implemented <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   ; mysql_hex_string()     - not implemented <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   ; ===================================================================================================================
   ; ===================================================================================================================
   ; Retrieves a string providing information about the most recently executed statement.
   ; Return values: String.
   ; ===================================================================================================================
   Info() {
      Return ((S := DllCall("libmysql.dll\mysql_info", "Ptr", This.MYSQL, "UPtr")) ? StrGet(S, "UTF-8") : "")
   }
   ; ===================================================================================================================
   ; Allocates or initializes a MYSQL object suitable for mysql_real_connect().
   ; Parameters:    MYSQL - Pointer to a MYSQL structure, pass NULL to allocate a new object
   ; Return values: An initialized MYSQL* handle. NULL if there was insufficient memory to allocate a new object.
   ; ===================================================================================================================
   Init(MYSQL := 0) {
      Return DllCall("libmysql.dll\mysql_init", "Ptr", MYSQL, "UPtr")
   }
   ; ===================================================================================================================
   ; Returns the value generated for an AUTO_INCREMENT column by the previous INSERT or UPDATE statement.
   ; Return values: Generated ID, if any.
   ; ===================================================================================================================
   Insert_ID() {
      Return DllCall("libmysql.dll\mysql_insert_id", "Ptr", This.MYSQL, "UInt64")
   }
   ; ===================================================================================================================
   ; mysql_kill()           - not implemented <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   ; mysql_library_end()    - not implemented <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   ; mysql_library_init()   - not implemented <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   ; mysql_list_dbs()       - not implemented <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   ; ===================================================================================================================
   ; Returns a result set consisting of field names in the given table that match the expression specified by
   ; the Like parameter.
   ; Parameters:     Table   - Table name
   ;                 Optional: Like - Expression field names have to match
   ;                                  (may contain the wildcard characters '%' or '_')
   ; Return values: A pointer to a MYSQL_RES result set for success. NULL if an error occurred.
   ; ===================================================================================================================
   List_Fields(Table, Like := "") {
      Return DllCall("libmysql.dll\mysql_list_fields", "Ptr", This.MYSQL, "Ptr", This.UTF8(Table)
                   , "Ptr", (Like = "" ? 0 : This.UTF8(Like)), "UPtr")
   }
   ; ===================================================================================================================
   ; mysql_list_processes() - not implemented <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   ; ===================================================================================================================
   ; ===================================================================================================================
   ; Returns a result set consisting of table names in the current database that match the expression specified
   ; by the Like parameter.
   ; Parameters:     Optional: Like - Expression table names have to match
   ;                                  (may contain the wildcard characters '%' or '_')
   ; Return values: A pointer to a MYSQL_RES result set for success. NULL if an error occurred.
   ; ===================================================================================================================
   List_Tables(Like := "") {
      Return DllCall("libmysql.dll\mysql_list_tables", "Ptr", This.MYSQL
                   , "Ptr", (Like = "" ? 0 : This.UTF8(Like)), "UPtr")
   }
   ; ===================================================================================================================
   ; This function is used when you execute multiple statements specified as a single statement string, or when you
   ; execute CALL statements, which can return multiple result sets.
   ; Return values: TRUE (1) if more results exist. FALSE (0) if no more results exist.
   ; ===================================================================================================================
   More_Results() {
      Return DllCall("libmysql.dll\mysql_more_results", "Ptr", This.MYSQL, "Char")
   }
   ; ===================================================================================================================
   ; This function is used when you execute multiple statements specified as a single statement string, or when you use
   ; CALL statements to execute stored procedures, which can return multiple result sets.
   ; Return values:  0 : Successful and there are more results.
   ;                -1 : Successful and there are no more results.
   ;                >0 : An error occurred.
   ; ===================================================================================================================
   Next_Result() {
      Return DllCall("libmysql.dll\mysql_next_result", "Ptr", This.MYSQL, "Int")
   }
   ; ===================================================================================================================
   ; Returns the number of columns in a result set.
   ; Parameters:    MYSQL_RES - Pointer to a MYSQL_RES structure.
   ; Return values: An unsigned integer representing the number of columns in a result set.
   ; ===================================================================================================================
   Num_Fields(MYSQL_RES) {
      Return DllCall("libmysql.dll\mysql_num_fields", "Ptr", MYSQL_RES, "UInt")
   }
   ; ===================================================================================================================
   ; Returns the number of rows in a result set.
   ; Parameters:    MYSQL_RES - Pointer to a MYSQL_RES structure.
   ; Return values: An unsigned 64-bit integer representing the number of rows in a result set.
   ; ===================================================================================================================
   Num_Rows(MYSQL_RES) {
      Return DllCall("libmysql.dll\mysql_num_rows", "Ptr", MYSQL_RES, "UInt64")
   }
   ; ===================================================================================================================
   ; Can be used to set extra connect options and affect behavior for a connection.
   ; This function may be called multiple times to set several options.
   ; Parameters:    Option - The option that you want to set.
   ;                Arg    - The value for the option.
   ; Return values: Zero for success. Nonzero if you specify an unknown option.
   ; ===================================================================================================================
   Options(Option, Arg) {
      Static MySQL_Option := {MYSQL_OPT_CONNECT_TIMEOUT: 0, MYSQL_OPT_COMPRESS: 1, MYSQL_OPT_NAMED_PIPE: 2
                            , MYSQL_INIT_COMMAND: 3, MYSQL_READ_DEFAULT_FILE: 4, MYSQL_READ_DEFAULT_GROUP: 5
                            , MYSQL_SET_CHARSET_DIR: 6, MYSQL_SET_CHARSET_NAME: 7, MYSQL_OPT_LOCAL_INFILE: 8
                            , MYSQL_OPT_PROTOCOL: 9, MYSQL_SHARED_MEMORY_BASE_NAME: 10, MYSQL_OPT_READ_TIMEOUT: 11
                            , MYSQL_OPT_WRITE_TIMEOUT: 12, MYSQL_OPT_USE_RESULT: 13
                            , MYSQL_OPT_USE_REMOTE_CONNECTION: 14, MYSQL_OPT_USE_EMBEDDED_CONNECTION: 15
                            , MYSQL_OPT_GUESS_CONNECTION: 16, MYSQL_SET_CLIENT_IP: 17, MYSQL_SECURE_AUTH: 18
                            , MYSQL_REPORT_DATA_TRUNCATION: 19, MYSQL_OPT_RECONNECT: 20
                            , MYSQL_OPT_SSL_VERIFY_SERVER_CERT: 21, MYSQL_PLUGIN_DIR: 22, MYSQL_DEFAULT_AUTH: 23
                            , MYSQL_ENABLE_CLEARTEXT_PLUGIN: 24}
      If Option Is Not Integer
         Option := MYSQL_Option[Option]
      If Arg Is Integer
         Return DllCall("libmysql.dll\mysql_options", "Ptr", This.MYSQL, "Int", Option, "Int64P", Arg, "Int")
      Return DllCall("libmysql.dll\mysql_options", "Ptr", This.MYSQL, "Int", Option, "Ptr", This.UTF8(Arg), "Int")
   }
   ; ===================================================================================================================
   ; Checks whether the connection to the server is working.
   ; Return values: Zero if the connection to the server is active. Nonzero if an error occurred.
   ; ===================================================================================================================
   Ping() {
      Return DllCall("libmysql.dll\mysql_ping", "Ptr", This.MYSQL, "Int")
   }
   ; ===================================================================================================================
   ; Executes the SQL statement pointed to by the null-terminated string SQL.
   ; Parameters:    SQL   - SQL statement.
   ; Return values: Zero if the statement was successful. Nonzero if an error occurred.
   ; ===================================================================================================================
   Query(SQL) {
      Return DllCall("libmysql.dll\mysql_query", "Ptr", This.MYSQL, "Ptr", This.UTF8(SQL), "Int")
   }
   ; ===================================================================================================================
   ; Attempts to establish a connection to a MySQL database engine running on Host.
   ; Parameters:    Host   - A host name or an IP address.
   ;                User   - The user's MySQL login ID.
   ;                PassWd - The password for user.
   ;             Optional:
   ;                DB     - The database name.
   ;                Port   - The port number for the TCP/IP connection (Default: 3306)
   ;                Socket - A string specifying the socket or named pipe to use.
   ;                Flags  - Flags to enable certain features.
   ; Return values: A MYSQL* connection handle if the connection was successful, NULL if the connection was
   ;                unsuccessful. For a successful connection, the return value is the same as the handle passed to
   ;                mysql_real_connect() in the first parameter.
   ; ===================================================================================================================
   Real_Connect(Host, User, PassWd, DB := "", Port := 3306, Socket := 0, Flags := 0) {
      If (DB = "")
         PtrDB := 0
      Else
         PtrDB := This.UTF8(DB)
      If !(MYSQL := DllCall("libmysql.dll\mysql_real_connect", "Ptr", This.MYSQL, "Ptr", This.UTF8(Host)
                          , "Ptr", This.UTF8(User), "Ptr", This.UTF8(PassWd), "Ptr", PtrDB
                          , "UInt", Port, "Ptr", This.UTF8(Socket), "Uint", Flags, "UPtr"))
         Return False
      Return MYSQL

   }
   ; ===================================================================================================================
   ; This function is used to create a legal SQL string that you can use in an SQL statement.
   ; The string in From is encoded to an escaped SQL string, taking into account the current character set of the
   ; connection.
   ; Parameters:    From   - Source string.
   ; Return values: Escaped string.
   ; ===================================================================================================================
   Real_Escape_String(ByRef From) {
      L := StrPut(From, "UTF-8") - 1
      VarSetCapacity(SI, L, 0)
      StrPut(From, &SI, "UTF-8")
      VarSetCapacity(SO, (L * 2) + 1, 0)
      N := DllCall("libmysql.dll\mysql_real_escape_string", "Ptr", This.MYSQL, "Ptr", &SO, "Ptr", &SI, "UInt", L, "UInt")
      Return StrGet(&SO, N, "UTF-8")
   }
   ; ===================================================================================================================
   ; Executes the SQL statement pointed to by SQL, a string Length bytes long.
   ; mysql_query() cannot be used for statements that contain binary data; you must use mysql_real_query() instead.
   ; All strings within the SQL statement have to be UTF-8.
   ; Parameters:    SQL    - SQL statement.
   ;                Length - Length of the statement in bytes.
   ; Return values: Zero if the statement was successful. Nonzero if an error occurred.
   ; ===================================================================================================================
   Real_Query(ByRef SQL, Length) {
      Return DllCall("libmysql.dll\mysql_real_query", "Ptr", This.MYSQL, "Ptr", &SQL, "UInt", Length, "Int")
   }
   ; ===================================================================================================================
   ; mysql_refresh() - not implemented <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   ; mysql_reload()  - not implemented <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   ; ===================================================================================================================
   ; ===================================================================================================================
   ; Rolls back the current transaction.
   ; Return values: Zero if successful. Nonzero if an error occurred.
   ; ===================================================================================================================
   Rollback() {
      Return DllCall("libmysql.dll\mysql_rollback", "Ptr", This.MYSQL, "Char")
   }
   ; ===================================================================================================================
   ; Sets the row cursor to an arbitrary row in a query result set.
   ; Parameters:    MYSQL_RES - Pointer to a MYSQL_RES structure
   ;                Offset    - The offset value is a row offset, typically a value returned from mysql_row_tell()
   ;                            or from mysql_row_seek(). This value is not a row number.
   ; Return values: The previous value of the row cursor.
   ; ===================================================================================================================
   Row_Seek(MYSQL_RES, Offset) {
      Return DllCall("libmysql.dll\mysql_row_seek", "Ptr", MYSQL_RES, "Ptr", Offset, "UPtr")
   }
   ; ===================================================================================================================
   ; Returns the current position of the row cursor for the last mysql_fetch_row(). This value can be used as an
   ; argument to mysql_row_seek().
   ; Parameters:    MYSQL_RES -  Pointer to a MYSQL_RES structure
   ; Return values: The current offset of the row cursor.
   ; ===================================================================================================================
   Row_Tell(MYSQL_RES) {
      Return DllCall("libmysql.dll\mysql_row_tell", "Ptr", MYSQL_RES, "UPtr")
   }
   ; ===================================================================================================================
   ; Causes the database specified by DB to become the default (current) database on the connection specified by mysql.
   ; In subsequent queries, this database is the default for table references that do not include an explicit database
   ; specifier.
   ; Parameters:    DB     - Database name.
   ; Return values: Zero if successful. Nonzero if an error occurred.
   ; ===================================================================================================================
   Select_DB(DB) {
      Return DllCall("libmysql.dll\mysql_select_db", "Ptr", This.MYSQL, "Ptr", This.UTF8(DB), "Int")
   }
   ; ===================================================================================================================
   ; This function is used to set the default character set for the current connection.
   ; Parameters:    CSName - Character set name.
   ; Return values: Zero if successful. Nonzero if an error occurred.
   ; ===================================================================================================================
   Set_Character_Set(CSName) {
      Return DllCall("libmysql.dll\mysql_set_character_set", "Ptr", This.MYSQL, "Ptr", This.UTF8(CSName), "Int")
   }
   ; ===================================================================================================================
   ; mysql_set_local_infile_default() - not implemented <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   ; mysql_set_local_infile_handler() - not implemented <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   ; ===================================================================================================================
   ; ===================================================================================================================
   ; Enables or disables an option for the connection.
   ; Parameters:    Option - MYSQL_OPTION_MULTI_STATEMENTS_ON  = 0
   ;                         MYSQL_OPTION_MULTI_STATEMENTS_OFF = 1
   ; Return values: Zero if successful. Nonzero if an error occurred.
   ; ===================================================================================================================
   Set_Server_Option(Option) {
      Return DllCall("libmysql.dll\mysql_set_server_option", "Ptr", This.MYSQL, "Int", Option, "Int")
   }
   ; ===================================================================================================================
   ; mysql_shutdown() - not implemented <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   ; ===================================================================================================================
   ; ===================================================================================================================
   ; Returns a null-terminated string containing the SQLSTATE error code for the most recently executed SQL statement.
   ; The error code consists of five characters. '00000' means “no error.”
   ; Return values: A null-terminated character string containing the SQLSTATE error code.
   ; ===================================================================================================================
   SQLState() {
      Return ((P := DllCall("libmysql.dll\mysql_sqlstate", "Ptr", This.MYSQL, "UPtr")) ? StrGet(P, "UTF-8") : "")
   }
   ; ===================================================================================================================
   ; mysql_ssl_set() - not implemented <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   ; ===================================================================================================================
   ; ===================================================================================================================
   ; Returns a character string containing information similar to that provided by the mysqladmin status command.
   ; Return values: A character string describing the server status. NULL if an error occurred.
   ; ===================================================================================================================
   Stat() {
      Return ((P := DllCall("libmysql.dll\mysql_stat", "Ptr", This.MYSQL, "UPtr")) ? StrGet(P, "UTF-8") : "")
   }
   ; ===================================================================================================================
   ; After invoking mysql_query() or mysql_real_query(), you must call mysql_store_result() or mysql_use_result() for
   ; every statement that successfully produces a result set (SELECT, SHOW, DESCRIBE, EXPLAIN, CHECK TABLE, and so
   ; forth).
   ; Return values: A pointer to a MYSQL_RES result structure with the results. NULL (0) if an error occurred.
   ; ===================================================================================================================
   Store_Result() {
      Return DllCall("libmysql.dll\mysql_store_result", "Ptr", This.MYSQL, "UPtr")
   }
   ; ===================================================================================================================
   ; Returns the thread ID of the current connection.
   ; Return values: The thread ID of the current connection.
   ; ===================================================================================================================
   Thread_ID() {
      Return DllCall("libmysql.dll\mysql_thread_id", "Ptr", This.MYSQL, "UInt")
   }
   ; ===================================================================================================================
   ; After invoking mysql_query() or mysql_real_query(), you must call mysql_store_result() or mysql_use_result() for
   ; every statement that successfully produces a result set (SELECT, SHOW, DESCRIBE, EXPLAIN, CHECK TABLE, and so
   ; forth).
   ; Return values: A pointer to a MYSQL_RES result structure with the results. NULL (0) if an error occurred.
   ; ===================================================================================================================
   Use_Result() {
      Return DllCall("libmysql.dll\mysql_use_result", "Ptr", This.MYSQL, "UPtr")
   }
   ; ===================================================================================================================
   ; Returns the number of errors, warnings, and notes generated during execution of the previous SQL statement.
   ; Return values: The warning count.
   ; ===================================================================================================================
   Warning_Count() {
      Return DllCall("libmysql.dll\mysql_warning_count", "Ptr", This.MYSQL, "UInt")
   }
}