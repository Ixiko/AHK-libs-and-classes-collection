class sql {
	__New(db := "", opt := "") {
		static lib := DllCall("LoadLibrary", "str", "sqlite3.dll", "Cdecl UPtr")
		If opt
			if IsObject(opt)
				if IsObject(opt[1])
					for k, v in opt
						this.config(v*)
				else this.config(opt*)
			else this.config(opt)

		DllCall("sqlite3.dll\sqlite3_initialize", "Cdecl int"), db ? This.open(db) : ""
	}

	open(db) {
		if (db != ":memory:") && !FileExist(this.dir := SubStr(db, 1, InStr(db, "\", , -1)))
			DirCreate(this.dir)
		DllCall("sqlite3.dll\sqlite3_open16", "wstr", db, "UPtrP", &hdb := 0, "Cdecl int")
		return this.hdb := hdb
	}

	close(hdb := "") => DllCall("sqlite3.dll\sqlite3_close", "UPtr", hdb or this.hdb, "Cdecl int")
	shutdown() => DllCall("sqlite3.dll\sqlite3_shutdown", "Cdecl int")
	config(opt, li*) => DllCall("sqlite3.dll\sqlite3_config", "int", opt, (li.push("Cdecl int"), li) * )
	err(hdb) => DllCall("sqlite3.dll\sqlite3_errmsg16", "UPtr", hdb, "Cdecl str")
	step(pStmt) => DllCall("sqlite3.dll\sqlite3_step", "UPtr", pStmt, "Cdecl int")
	finalize(pStmt) => DllCall("sqlite3.dll\sqlite3_finalize", "UPtr", pStmt, "Cdecl int")
	exec(sl, hdb) => DllCall("sqlite3.dll\sqlite3_exec", "UPtr", hdb, "astr", sl, "ptr", 0, "ptr", 0, "ptrP", &_ := 0, "Cdecl int")

	list(table, li, hdb := "") {
		this.exec("BEGIN TRANSACTION", hdb ? hdb : hdb := this.hdb)
		for pi in li
		{
			j := k := ""
			for i, n in pi
				if n != ""
					j .= i ",", k .= (IsNumber(n) ? n : "'" this.quote(n) "'") ","
			this.set("INSERT INTO " table " (" trim(j, ",") ") VALUES(" trim(k, ",") ");", hdb)
		}
		this.exec("END TRANSACTION", hdb)
	}

	set(stmt, hdb := "") {
		pzTail := strptr(stmt), end := pzTail + StrLen(stmt) * 2, hdb ? '' : hdb := this.hdb
		While pzTail != end
		{
			if DllCall("sqlite3\sqlite3_prepare16_v2", "ptr", this.hdb, "PTR", pzTail, "int", -1, "ptrP", &pstmt := 0, "PTRP", &pzTail, "cdecl int")
				return ("Error Prepare: " A_Index "`n" this.err(hdb))
			if pStmt = 0
				continue
			else if (err := this.step(pStmt)) != 101 && err != 100
				return (this.finalize(pStmt), "Error Step: " A_Index "`n" err ": " this.err(hdb))
			if this.finalize(pStmt)
				return ("Error Finalize: " A_Index "`n" this.err(hdb))
		}
	}

	get(sl, hdb := "") {
		pzTail := strptr(sl), final := pzTail + StrLen(sl) * 2, res := [], hdb ? '' : hdb := this.hdb
		While pzTail != final
		{
			if DllCall("sqlite3\sqlite3_prepare16_v2", "ptr", hdb, "PTR", pzTail, "int", -1, "ptrP", &pstmt := 0, "PTRP", &pzTail, "cdecl int")
				return (this.err := this.err(hdb), "")

			if pStmt = 0
				continue
			else if (100 = ret := this.step(pStmt)) || ret = 101
			{
				if ret = 101
				{
					if this.finalize(pStmt)
						return (this.err := this.err(hdb), "")
					continue
				}

				Index := []
				Loop ColumnCount := DllCall("sqlite3.dll\sqlite3_column_count", "UPtr", pStmt, "Cdecl int")
					Index.push(DllCall("sqlite3.dll\sqlite3_column_name16", "UPtr", pStmt, "int", A_Index - 1, "Cdecl str"))

				While ret = 100
				{
					res.InsertAt(A_Index, row := map())
					Loop ColumnCount
					{
						n := Index[A_Index]
						Switch DllCall("sqlite3.dll\sqlite3_column_type", "UPtr", pStmt, "int", A_Index - 1, "Cdecl int")
						{
							Case 3: row[n] := DllCall("sqlite3.dll\sqlite3_column_text16", "UPtr", pStmt, "int", A_Index - 1, "Cdecl str")
							Case 1: row[n] := DllCall("sqlite3.dll\sqlite3_column_int64", "UPtr", pStmt, "int", A_Index - 1, "Cdecl int64")
							Case 5:	;row[n] := ''
							Case 2: row[n] := DllCall("sqlite3.dll\sqlite3_column_double", "UPtr", pStmt, "int", A_Index - 1, "Cdecl double")

							Case 4: row[n] := (RtlMoveMemory((buf := Buffer(sz := DllCall("sqlite3.dll\sqlite3_column_bytes", "UPtr", pStmt, "int", A_Index - 1, "Cdecl int"))).ptr
									, DllCall("sqlite3.dll\sqlite3_column_blob", "UPtr", pStmt, "int", A_Index - 1, "Cdecl ptr"), sz), buf)

							default: row[n] := DllCall("sqlite3.dll\sqlite3_column_text16", "UPtr", pStmt, "int", A_Index - 1, "Cdecl str")
						}
					}
					ret := this.step(pStmt)
				}
			} else
				return (this.finalize(pStmt), this.err := this.err(hdb), "")

			if this.finalize(pStmt)
				return (this.err := this.err(hdb), "")
		}
		return res.Length ? res : ""
	}

	quote(st) => StrReplace(st, "'", "''")
	__Delete() {
		this.close(), this.shutdown()
	}
}