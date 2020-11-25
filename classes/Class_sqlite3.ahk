#SingleInstance, Force



;======================================================================
;======================================================================
;======================================================================

; You must download sqlite3.dll from sqlite.org to use this library

;======================================================================
;======================================================================
;======================================================================




; RegisterCallback does not support ObjBindMethod(), so we need
; a global variable to pass between the SQLiteObj class instance
; and the callback function.  if you are using AHK v2 you can
; change this
global Query := []



; create a test database file 
FileAppend, % "", % A_Desktop "\Sample.db"



; construct SQLiteObj
; param1 = sqlite3.dll file path
; param2 = target database file path
SQL := new SQLiteObj(A_Desktop "\sqlite3.dll", A_Desktop "\Sample.db")
if SQL=0
    return



; queries to populate db with sample data
SQL.Query("CREATE TABLE SampleTable(Items, Stuff);")
SQL.Query("INSERT INTO SampleTable VALUES(1, 'a');")
SQL.Query("INSERT INTO SampleTable VALUES(2, 'b');")
SQL.Query("INSERT INTO SampleTable VALUES(3, 'c');")



; basic SELECT FROM WHERE query
; return value is always a simple array, in this case:
; [item1, stuff1, item2, stuff2, ...]
Values := []
Values := SQL.Query("SELECT Items, Stuff FROM SampleTable WHERE Items > 1;")
MsgBox % Values[1] " | " Values[2] " | " Values[3] " | " Values[4]



; supports dynamic queries
Values := []
Cols := "Items, Stuff"
Table := "SampleTable"
Condition := "Items > 0"
Values := SQL.Query("SELECT " Cols " FROM " Table " WHERE " Condition ";")



; placing values into an associative array
SampleTask := Object()
Loop 3 {
    i := A_Index * 2 - 1
    SampleTask[Values[i]] := Values[i+1]
}

for key, val in SampleTask
    MsgBox % key ":" val

return


class SQLiteObj
{
    __new(Path_SQLDLL, Path_DB) {
        if FileExist(Path_SQLDLL)="" { 
            msgbox sqlite3.dll not found!  Go get sqlite3.dll from sqlite.org.
            return 0
        }
        This.Library := DllCall("LoadLibrary", "Str", Path_SQLDLL, "Ptr")
        This.Callback := RegisterCallback("QueryCallback", "F C", 4)
        This.Open(Path_DB)
    }

    Open(Path_DB) {
        DB := 0
        VarSetCapacity(Address, StrPut(Path_DB, "UTF-8"), 0)
        StrPut(Path_DB, &Address, "UTF-8")
        DllCall("sqlite3.dll\sqlite3_open_v2" ; https://www.sqlite.org/c3ref/open.html
                , "Ptr", &Address
                , "PtrP", DB
                , "Int", 2
                , "Ptr", 0
                , "CDecl Int")
        This.Database := DB
    }

    Query(Q) {
        Query := []
        VarSetCapacity(Address, StrPut(Q, "UTF-8"), 0)
        StrPut(Q, &Address, "UTF-8")        
        DllCall("sqlite3.dll\sqlite3_exec" ; https://www.sqlite.org/c3ref/exec.html
                , "Ptr", This.Database
                , "Ptr", &Address
                , "Ptr", This.Callback)
        return Query
    }
}

QueryCallback(ParamFromCaller, Columns, Values, Names) {
    Loop %Columns%
        Query.Push(StrGet(NumGet(Values+0, (A_Index-1)*8, "uInt"), "UTF-8"))
    return 0
}