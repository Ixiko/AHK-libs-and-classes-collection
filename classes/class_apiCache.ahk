#Include <SingleRecordSQL>
#Include <functions>
#Include <LibCrypt>
#Include <class_SQLiteDB_modified>
#Include <WinHttpRequest>
#Include <string_things>
class class_ApiCache{ 
	static acDB := ""	;api cache DB
	static acDir := ""	;api cache dir, used only for bulk downloads
	static uncDB := ""
	static acExpiry := 518400	;api cache expiry
							;how many seconds to wait before burning api call for fresh file
							;default = 518400 (6 days)
	static lastResponseHeaders := ""
	static WinHttpRequest_encoding := "Charset: UTF-8"
	static WinHttpRequest_windowsCache := "Cache-Control: no-cache"
	static openTransaction := 0
	static lastServedSource := "nothing"	;holds the string "server" if the class burned api, or "cache" otherwise.
	static bulkRetObj := []
	init(pathToDir,pathToDB){
		this.initDir(pathToDir)
		this.initDB(pathToDB)
	}
	initDir(pathToDir){	;temporary directory for bulk downloads
		FileCreateDir, % pathToDir
		this.acDir := Trim(pathToDir,"\")
	}
	initDB(pathToDB,journal_mode := "wal",synchronous := 0){	
		;this.initDLLs()
		If FileExist(pathToDB){
			this.acDB := new SQLiteDB
			if !this.acDB.openDB(pathToDB)
				msgbox % "error opening database"
		}
		else{
			SplitPath,pathToDB,FileName,FileDir
			FileCreateDir, % FileDir
			this.acDB := new SQLiteDB
			this.acDB.openDB(pathToDB)
			ddlObj := this.initSchema()
			
			for k,v in ddlObj {
				
				if !this.acDB.exec(v)
					msgbox % "error creating table in new database"
			}
		}
		this.acDB.exec("PRAGMA journal_mode=" journal_mode ";")
		this.acDB.exec("PRAGMA synchronous=" synchronous ";")
		
		;this.acDB.getTable("PRAGMA synchronous;",table)
		;msgbox % st_printArr(table)
		;this.acDB.exec("VACUUM;")
	}



	initSchema(){
		retObj := []
		ret = 
		(
		CREATE TABLE simpleCacheTable (
			fingerprint       TEXT PRIMARY KEY UNIQUE,
			url               TEXT,
			headers           TEXT,
			responseHeaders   BLOB,
			responseHeadersSz INTEGER,
			timestamp         INTEGER,
			expiry            INTEGER,
			mode              INTEGER,
			data              BLOB,
			dataSz            INTEGER
		`);
		)
		retObj.push(ret)
		
		ret = 
		(
		CREATE VIEW vRecords AS
			SELECT fingerprint,
				url,
				headers,
				sqlar_uncompress(responseHeaders, responseHeadersSz) AS responseHeaders,
				timestamp,
				expiry,
				sqlar_uncompress(data, dataSz) AS data
			FROM simpleCacheTable;
		)	
		retObj.push(ret)
		
		ret = 
		(
		CREATE VIEW vRecords_complete AS
			SELECT fingerprint,
				url,
				headers,
				sqlar_uncompress(responseHeaders, responseHeadersSz) AS responseHeaders,
				responseHeadersSz,
				mode,
				timestamp,
				expiry,
				sqlar_uncompress(data, dataSz) AS data,
				dataSz
			FROM simpleCacheTable;
		)
		retObj.push(ret)
		
		return retObj		
	}
	initExpiry(expiry){
		this.acExpiry := expiry
	}
	retrieve(url,ByRef post := "",ByRef headers := "", ByRef options := "",expiry := "", forceBurn := 0){
		if (expiry = "")
			expiry := this.acExpiry
		/*
			-check if url+header (fingerprint) exists in db
			-if url doesn't exist -> burn api
				
			-check expiry
			-if url too old -> burn api
				
			-if fingerprint exists AND expiry is good -> return fileblob from db
		*/
		; msgbox % url
		fingerprint := this.generateFingerprint(url,headers)
		,responseHeaders := headers	;WinHttpRequest will overwrite the ByRef Headers var otherwise
			;,SHA512_url := LC_SHA512(url)
			;,SHA512_headers := LC_SHA512(headers)
			;,fingerprint := SHA512_url SHA512_headers
		
		timestamp := expiry_timestamp := A_NowUTC	;makes the timestamp consistent across the method
		EnvAdd,expiry_timestamp, % expiry, Seconds	
		;msgbox % timestamp "`n" expiry_timestamp
		
		If (forceBurn = 0){	;skips useless db call if !0
			SQL := "SELECT sqlar_uncompress(data,dataSz) AS data, sqlar_uncompress(responseHeaders,responseHeadersSz) AS responseHeaders FROM simpleCacheTable WHERE fingerprint = '" fingerprint "' AND expiry > " Min(timestamp,expiry_timestamp) ";"	;uses lower number between current and user-set timestamp
			If !this.acDB.getTable(sql,table)	;finds data only if it hasn't expired
				msgbox % clipboard := "--expiry check failed under optional burn`n" sql
			;msgbox % clipboard := sql
			;msgbox % st_printArr(table)
			If (table.RowCount > 0) {	;RowCount will = 0 if nothing found
				table.NextNamed(chkCache)
				this.lastResponseHeaders := chkCache["responseHeaders"]
				this.lastServedSource := "cache"
				return chkCache["data"]	;returns previously cached data
			}
		}
		;msgbox % fingerprint
		
		
		;TODO - MOVE WinHttpRequest() TO LIBCURL
		WinHttpRequest(url, post, responseHeaders, options this.WinHttpRequest_encoding "`n" WinHttpRequest_windowsCache)
		this.lastResponseHeaders := responseHeaders
		
		quotedResponseHeaders := sqlQuote(responseHeaders)
		quotedPost := sqlQuote(post)	
		;TODO - use proper BLOB insertion
		insObj := {"url":url
			,"headers":headers
			,"responseHeaders":"sqlar_compress(CAST(" quotedResponseHeaders " AS BLOB))"	
			,"responseHeadersSz":"length(CAST(" quotedResponseHeaders " AS BLOB))"
			;,"responseHeadersSz":StrPut(responseHeaders, "UTF-8")
			,"fingerprint":fingerprint
			,"timestamp":timestamp
			,"expiry":expiry_timestamp
			,"mode":"777"
			,"dataSz":"length(CAST(" quotedPost " AS BLOB))"
			;,"dataSz":StrPut(post, "UTF-8")
			,"data":"sqlar_compress(CAST(" quotedPost " AS BLOB))"}	 
		
		;SQL := SingleRecordSQL("simpleCacheTable",insObj,"fingerprint",,"responseHeaders,data")
		SQL := SingleRecordSQL("simpleCacheTable",insObj,"fingerprint",,"responseHeaders,responseHeadersSz,data,dataSz")
		
		;if (this.openTransaction = 0)
			;this.acDB.exec("BEGIN TRANSACTION;")
		;msgbox % clipboard := sql
		if !this.acDB.exec(sql)
			msgbox % clipboard := "--insObj failure`n" sql
		;if (this.openTransaction = 0)				
			;If !this.acDB.exec("COMMIT;")
				;msgbox % "commit failure"
		this.lastServedSource := "server"
		return post
		
		;don't think I need this fetch after the insertion? keeping for now
		SQL := "SELECT sqlar_uncompress(data,size) AS data FROM vRecords WHERE fingerprint = '" fingerprint "';"
		
		this.acDB.getTable(sql,table)
		table.NextNamed(chkCache)
		
		return chkCache["data"]	;returns previously cached data
		
	}
	findFingerprints(urlToMatch := "",  dataToMatch := "", headersToMatch := "", responseHeadersToMatch := "",urlPartialMatch := 0){
		;looking for any fingerprints whose records match the parameters
		;blank parameters will not be considered
		;url is exact unless urlPartialMatch != 0, others will always look for partial matches
		;will return a linear array of fingerprints

		SQL := "SELECT fingerprint from vRecords WHERE "
			.	(urlToMatch!=""?(urlPartialMatch=0?"url = "sqlQuote(urlToMatch):"INSTR(url,"sqlQuote(urlToMatch)")"):"url IS NOT NULL")	;more complicated logic at url to simplify the next three
			.	(dataToMatch!=""?" AND INSTR(data," sqlQuote(dataToMatch) ")":"")
			.	(headersToMatch=""?"":" AND INSTR(data," sqlQuote(headersToMatch) ")")	;probably less likely to search headers so the null string is first match
			.	(responseHeadersToMatch=""?"":" AND INSTR(data," sqlQuote(responseHeadersToMatch) ")")	;same as above
			.	";"

		;msgbox % clipboard := sql
		if !this.acDB.gettable(SQL,table)
			msgbox % clipboard := "--Failure in findFingerprints`n" SQL
		retObj := []
		loop, % table.rowCount {
			;using SQLite.next() instead of SQLite.nextNamed() because there's just 1 column
			;infinitesimal performance boost ftw
			table.next(nextObj)	
			retObj.push(nextObj[1])
		}
		return retObj
	}
	fetchFingerprints(ByRef recordObj){	
		;Accepts a linear array of fingerprints to return any number of rows
		;candidate to explore for optimization: https://use-the-index-luke.com/sql/partial-results/fetch-next-page
		if (recordObj.count()=0)
			Return	[] ;prevents erroneous calls
		retObj := []
		lastTimestamp := 0
		;lastFingerprint := ""
		;sqlString := "SELECT * FROM vRecords WHERE (timestamp, fingerprint) < "
		sqlStart := "SELECT * FROM vRecords WHERE "
		For k,v in recordObj {
			fingerprintStr .= "fingerprint = '" v "'" "  OR "	;will trim the last OR later
			;msgbox % fingerprintStr
			if (!mod(a_index,950) || (a_index = recordObj.count())){	;descends every 950 iterations OR on the final iteration
				;sqlFilter := "(timestamp,fingerprint) < (" lastTimestamp ",'" lastFingerprint "') AND (" RTrim(fingerprintStr," OR ") ") ORDER BY timestamp DESC, fingerprint ASC"
				sqlFilter := "timestamp >= " lastTimestamp " AND (" RTrim(fingerprintStr," OR ") ") ORDER BY timestamp ASC"
				;clipboard := sqlStart sqlFilter ";"
				this.acDB.gettable(sqlStart sqlFilter ";",table)
				loop, % table.rowCount {
					table.nextNamed(nextObj)
					retObj.push(nextObj)
				}
				fingerprintStr := ""	;resets fingerprintStr to respect SQLite's variable limit
				;lastFingerprint := retObj[retObj.count(),"fingerprint"]
				lastTimestamp := retObj[retObj.count(),"timestamp"]
			}  
		}
		return retObj
	}


	generateFingerprint(url,headers := ""){
		;returns a concatonated hash of the outgoing url+headers
		;fingerprint is either 128 or 256 characters, depending on if headers has content
		return LC_SHA512(url) . (headers=""?"":LC_SHA512(headers)) 
	}
	invalidateRecords(ByRef recordObj){
		;accepts a linear array of fingerprints to forcefully stale any number of records
		;this does NOT delete the records, it sets the expiry to 0
		;useful when there's a known list of updated fingerprints but not a readily available bulk download
		
		if (this.openTransaction = 0)	;makes sure the user hasn't manually opened a transaction
			this.begin()
		for k,v in recordObj
			this.invalidateRecord(v)
		if (this.openTransaction = 0)
			this.commit()
	}
	invalidateRecord(ByRef fingerprint){
		;this does NOT delete the records, it sets the expiry to 0
		;msgbox % clipboard := "UPDATE cacheTable SET expiry = 0 WHERE fingerprint = '" fingerprint "';"
		;If !this.acDB.exec("UPDATE cacheTable SET expiry = 0 WHERE fingerprint = '" fingerprint "';")
		If !this.acDB.exec("UPDATE simpleCacheTable SET expiry = 0 WHERE fingerprint = '" fingerprint "';")
			msgbox % "error in invalidateRecord()"
	}
	purgeFingerprints(fingerprintObj){
		;accepts a linear array of fingerprints to delete any number of records from the database
		if (this.openTransaction = 0)	;makes sure the user hasn't manually opened a transaction
			this.begin()
		For k,v in fingerprintObj
			this.purgeFingerprint(v)
		if (this.openTransaction = 0)
			this.commit()
	}
	purgeFingerprint(fingerprint){
		;deletes one record from the database
		this.acDB.exec("DELETE FROM cacheTable WHERE fingerprint = '" fingerprint "';")
	}
	nuke(reallyNuke := 0){	;you didn't really like this db, did you?
		;deletes all entries in the database
		if (reallyNuke != 1)
			return
		this.acDB.exec("DELETE FROM simpleCacheTable;")
	}
	CloseDB(){
		this.acDB.exec("PRAGMA optimize;")
		this.acDb.CloseDB()
	}
	
	begin(){
		if (this.openTransaction = 1)	;can't open a new statement
			return
		;this.acDB.exec("PRAGMA locking_mode = EXCLUSIVE;")
		this.acDB.exec("BEGIN TRANSACTION;")
		this.openTransaction := 1
	}
	commit(){
		if (this.openTransaction = 0)	;nothing to commit
			return
		this.acDB.exec("COMMIT;")
		;this.acDB.exec("PRAGMA locking_mode = NORMAL;")
		this.openTransaction := 0
	}
	sideloadFingerprints(sideloadObj){
		;accepts an array with nested objects containing 2-6 keys corresponding to the parameters in apiCache.sideload()
		;For now, will not delete files. Will examine possible logic to cleanup inserted files later.
		if (this.openTransaction = 0)	;makes sure the user hasn't manually opened a transaction
			this.begin()
		for k,v in sideloadObj
			this.sideload(v["localFile"],v["url"],v["headers"],v["expiry"],v["responseHeadersFile"])
		if (this.openTransaction = 0){
			this.commit()
		}
	}
	sideloadFingerprint(localFile,url,headers := "", expiry := "",responseHeadersFile := "",deleteFile := 0){
		;uses SQLite.readfile() to insert a local file into the DB as if you had burned an api call
		;Useful for APIs that offer periodic bulk zips containing many of their datapoints
		;Will not delete file if apiCache.openTransaction = 1, or if the transaction fails for any reason
		if !FileExist(localFile)
			Return	;nothing to insert
		foundResponseHeadersFile := (FileExist(responseHeadersFile)?1:0)

		if (expiry = "")
			expiry = this.acExpiry
		timestamp := expiry_timestamp := A_NowUTC	;makes the timestamp consistent across the method
		EnvAdd,expiry_timestamp, % expiry, Seconds	

		fingerprint := this.generateFingerprint(url,headers)

		insObj := {"url":url
			,"headers":headers
			,"responseHeaders":(foundResponseHeadersFile=1?"sqlar_compress(readfile('" responseHeadersFile "'))":"")
			,"responseHeadersSz": (foundResponseHeadersFile=1?FileGetSize(responseHeadersFile):0)
			;,"responseHeadersSz":StrPut(responseHeaders, "UTF-8")
			,"fingerprint":fingerprint
			,"timestamp":timestamp
			,"expiry":expiry_timestamp
			,"mode":"777"
			,"dataSz": FileGetSize(localFile)
			;,"dataSz":StrPut(post, "UTF-8")
			,"data":"sqlar_compress(readfile('" localFile "'))"}	 
		
		;SQL := SingleRecordSQL("simpleCacheTable",insObj,"fingerprint",,"responseHeaders,data")
		SQL := SingleRecordSQL("simpleCacheTable",insObj,"fingerprint",,"responseHeaders,responseHeadersSz,data,dataSz")
		
		;if (this.openTransaction = 0)
			;this.acDB.exec("BEGIN TRANSACTION;")
		;msgbox % clipboard := sql
		if !this.acDB.exec(sql)
			msgbox % clipboard := "--sideload failure`n" sql
		else {
			if (this.openTransaction=0) && (deleteFile=1)
				FileDelete, % localFile
				if (foundResponseHeadersFile=1)
					FileDelete, responseHeadersFile
		}
	}
	exportFingerprints(fingerprintObj){
		;accepts an array with objects containing keys corresponding to apiCache.exportFingerprint()'s parameters
		;the outResponseHeaderFile key can be absent
		if (this.openTransaction = 0)	;makes sure the user hasn't manually opened a transaction
			this.begin()
		for k,v in fingerprintObj
			this.exportFingerprint(v["fingerprint"],v["outFile"],v["outResponseHeaderFile"])
		if (this.openTransaction = 0)
			this.commit()
	}
	exportFingerprint(fingerprint,outFile, outResponseHeaderFile := ""){
		;uses SQLite.writefile() to dump a fingerprint's data to disk.
		;can also optionally dump the response headers.
		;SQLite auotmatically overwrites any existing file
		this.acDB.exec("SELECT writefile('" outFile "',data)" (outResponseHeaderFile=""?"":", writefile('" outResponseHeaderFile "',responseHeaders)") " FROM vRecords WHERE fingerprint = '" fingerprint "';")
	}

	exportUncompressedDb(pathToUncompressedDB,overwrite := 0){
		;create a db that can be used by any version of SQLite
		;if FileExist(pathToUncompressedDB){
		;	if (overwrite!=1)
		;		return
		;	else
		;		FileDelete, % pathToUncompressedDB
		;}
		this.uncDB := new SQLiteDB
		If !this.uncDB.openDB(pathToUncompressedDB)
			msgbox % clipboard := "failure opening uncompressed DB in exportUncompressedDb()"
		uncObj := []
		unc = 
		(
		CREATE TABLE simpleCacheTable (
			fingerprint       TEXT PRIMARY KEY UNIQUE,
			url               TEXT,
			headers           TEXT,
			responseHeaders   BLOB,
			responseHeadersSz INTEGER,
			timestamp         INTEGER,
			expiry            INTEGER,
			mode              INTEGER,
			data              BLOB,
			dataSz            INTEGER
		`);
		)
		uncObj.push(unc)
		
		unc = 
		(
		CREATE VIEW vRecords AS
			SELECT fingerprint,
				url,
				headers,
				responseHeaders,
				timestamp,
				expiry,
				data
			FROM simpleCacheTable;
		)	
		uncObj.push(unc)
		
		unc = 
		(
		CREATE VIEW vRecords_complete AS
			SELECT fingerprint,
				url,
				headers,
				responseHeaders,
				responseHeadersSz,
				mode,
				timestamp,
				expiry,
				data,
				dataSz
			FROM simpleCacheTable;
		)
		uncObj.push(unc)
		if (overwrite!=0)
			for k,v in uncObj {
				tableDDL := v
				If !this.uncDB.exec(tableDDL)
					msgbox % "--Error creating table in uncompressed DB`n" tableDDL
			}
		this.uncDB.exec("PRAGMA journal_mode=" journal_mode ";")			
		;this.uncDB.exec("VACUUM;")		
		this.uncDB.CloseDB()
		
		this.acDB.AttachDB(pathToUncompressedDB, "unc")
		SQL := "INSERT OR REPLACE INTO unc.simpleCacheTable SELECT * FROM main.vRecords_Complete;"
		if !this.acDB.exec(SQL)
			msgbox % clipboard := "--failure in exportUncompressedDb()`n" SQL
		this.acDB.DetachDB("unc")
	}
	
	/*	temporarily shelved findRecords() and fetchRecords()
	findRecords(urlToMatch := "",  dataToMatch := "", headersToMatch := "", responseHeadersToMatch := "",urlPartialMatch := 0){
		;looking for any records which match the parameters
		;blank parameters will not be considered
		;url is exact unless urlPartialMatch != 0, others will always look for partial matches
		;will return an object with [fingerprint,url,headers] fields to help prevent memory overflow

		SQL := "SELECT fingerprint,url,headers from vRecords WHERE "
			.	(urlToMatch!=""?(urlPartialMatch=0?"url = "sqlQuote(urlToMatch):"INSTR(url,"sqlQuote(urlToMatch)")"):"url IS NOT NULL")	;more complicated logic at url to simplify the next three
			.	(dataToMatch!=""?" AND INSTR(data," sqlQuote(dataToMatch) ")":"")
			.	(headersToMatch=""?"":" AND INSTR(data," sqlQuote(headersToMatch) ")")	;probably less likely to search headers so the null string is first match
			.	(responseHeadersToMatch=""?"":" AND INSTR(data," sqlQuote(responseHeadersToMatch) ")")	;same as above
			.	";"

		if !this.acDB.gettable(SQL,table)
			msgbox % clipboard := "--Failure in findRecords`n" SQL
		retObj := []
		loop, % table.rowCount {
			table.nextNamed(nextObj)
			retObj.push(nextObj)
		}
		return retObj
	}
	fetchRecords(recordObj){
		;accepts a findRecords()-formatted array to return any number of rows
		
	}
	findAndFetchRecords(){	;find and fetch records in one step
		;TODO
	}
	*/
		/*	bulk insert stuff
			
		
		buildBulkRetrieve(url,headers := "",expiry := "",forceBurn := 0){
		;queues one fingerprint for .bulkRetrieve()
			if (expiry = "")
				expiry := this.acExpiry
			
			fingerprintObj := {"url":url,"forceBurn":forceBurn,"expiry":expiry,"options":{"headers":headers,"gid":format("{1:016X}",this.bulkRetObj.count()+1),"dir":this.acDir,"out":this.generateFingerprint(url,headers)}}
			this.bulkRetObj.push(fingerprintObj)
		}
		bulkRetrieve(maxConcurrentDownloads := 5, urlObj := ""){
			if (urlObj = "")
				urlObj := this.bulkRetObj
		;msgbox % st_printArr(urlObj)
			cuidFingerprintMap := []
			mapIndex := 0
			retFingerprints := []
		;msgbox % this.acDir "\bulk.txt"
			bulk := FileOpen(this.acDir "\bulk.txt","w")
			for k,v in urlObj{
			;check if the fingerprint's cache is expired
			;fingerprint := this.generateFingerprint(v["url"],v["options","headers"])	
				fingerprint := v["options","out"]
				
				timestamp := expiry_timestamp := A_NowUTC	;makes the timestamp consistent across the method
				EnvAdd,expiry_timestamp, % v["expiry"], Seconds	
				
				If (v["forceBurn"] = 0){	;skips unneeded db call if !0
				;not pulling data at this stage so we don't need blobs
					SQL := "SELECT fingerprint FROM simpleCacheTable WHERE fingerprint = '" fingerprint "' AND expiry > " Min(timestamp,expiry_timestamp) ";"	;uses lower number between current and user-set timestamp
					If !this.acDB.getTable(sql,table)	;finds data only if it hasn't expired
						msgbox % clipboard := "--expiry check failed under optional burn`n" sql
				;msgbox % clipboard := sql
				;msgbox % st_printArr(table)
					If (table.RowCount > 0) {	;RowCount will = 0 if nothing found
					;add to the list of fingerprints
						retFingerprints[fingerprint] := {"url":v["url"],"headers":v["options","headers"],"source":"cache"}
						continue	;will use cached data so nothing to do
					}
				}
			;msgbox % "yo"
				bulk.write(this.formatAria2cUrl(v["url"],v["options"]) "`n")
				mapIndex += 1
				cuidFingerprintMap[mapIndex] := {"fingerprint":fingerprint,"url":v["url"],"headers":v["options","headers"]}	;assuming the .count() = aria2c's CUID
			}
			bulk.close()
		;msgbox % "test"
			if !(FileGetSize(this.acDir "\bulk.txt") > 20)	;file is definitely too small
				return retFingerprints	;all files were found in cache
			
		;actually download the bulk items
		;aria2c -i out.txt --http-accept-gzip true --max-concurrent-downloads=30 --console-log-level=notice  --log=log.txt
			FileDelete, % this.acDir "\bulk.log"
			runLine := chr(34) A_ScriptDir "\aria2c.exe"	chr(34) a_space
			.	"-i " chr(34) this.acDir "\bulk.txt" chr(34) a_space
			.	"--http-accept-gzip true" a_space
			.	"--http-no-cache" a_space
			.	"--max-concurrent-downloads=" maxConcurrentDownloads a_space
			.	"--allow-overwrite" a_space
			.	"--log-level=info" a_space
			.	"--disk-cache=250M" a_space
			.	"--deferred-input true" a_space
			.	"--log=" chr(34) this.acDir "\bulk.log" chr(34)
		;msgbox % clipboard := runLine
			RunWait, % runLine
			
		;parse the log for responseHeaders
			static needle := "mUs)\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d+ \[INFO] \[HttpConnection.+] CUID#(\d+) - Response received:\r?\n(.+)\r?\n\r?\n"
			parseLog := RegExMatchGlobal(FileOpen(this.acDir "\bulk.log","r").read(),needle,0)
		;msgbox % st_printArr(parseLog)
			
			for k,v in parseLog {
				cuid := v[1] + 6
				fingerprint := cuidFingerprintMap[cuid,"fingerprint"]
				if (fingerprint = ""){
				;msgbox % st_printArr(v) st_printArr(cuidFingerprintMap)
					
				}
			;msgbox % 
				quotedResponseHeaders := sqlQuote(v[2])
				insObj := {"url":cuidFingerprintMap[cuid,"url"]
				,"headers":cuidFingerprintMap[cuid,"headers"]
				,"responseHeaders":"sqlar_compress(CAST(" quotedResponseHeaders " AS BLOB))"	
				,"responseHeadersSz":"length(CAST(" quotedResponseHeaders " AS BLOB))"
				;,"responseHeadersSz":StrPut(responseHeaders, "UTF-8")
				,"fingerprint":fingerprint
				,"timestamp":timestamp
				,"expiry":expiry_timestamp
				,"mode":"777"
				,"dataSz":FileGetSize(this.acDir "\" fingerprint)
				;,"dataSz":StrPut(post, "UTF-8")
				,"data":"sqlar_compress(READFILE(" sqlQuote(this.acDir "\" fingerprint) "))"}	 
				
			;SQL := SingleRecordSQL("simpleCacheTable",insObj,"fingerprint",,"responseHeaders,data")
				SQL := SingleRecordSQL("simpleCacheTable",insObj,"fingerprint",,"responseHeaders,responseHeadersSz,data,dataSz")
				
				
			;if (this.openTransaction = 0)
				;this.acDB.exec("BEGIN TRANSACTION;")
			;msgbox % clipboard := sql
				if !this.acDB.exec(sql)
					msgbox % clipboard := "--insObj failure`n" sql
				FileDelete, % this.acDir "\" fingerprint
			;if (this.openTransaction = 0)				
				;If !this.acDB.exec("COMMIT;")
					;msgbox % "commit failure"
				this.lastServedSource := "server"
			;msgbox % st_printArr(v)
			}
			
			
		;import into the db
		;return retFingerprints
		}
		formatAria2cUrl(url,options := ""){
			for k,v in options {
				switch k {
					case "headers" :{
						for k,v in StrSplit(options["headers"],"`n","`r"){
							if (v != "")
								opts .= "`n" a_tab "header=" v
						}
					}
					default : {
						if (v != "")
							opts .= "`n" a_tab k "=" v
					}
				}
			}
			return url opts
		}
	*/
		/*	temporarily shelved until I have a better plan in place - maybe forever? idk
		initDLLs(){
		;this will eventually follow the expectations of class_SQLiteDB when checking for SQLite3.dll + unicode dependencies.
		;for now it just dumps to a_scriptdir

		;/*	returns the id of the sqlite dll in use - used to check if our supplied version is present (AKA best case scenario)

			SELECT sqlite_source_id();

			current id: 2022-05-06 15:25:27 78d9c993d404cdfaa7fdd2973fa1052e3da9f66215cff9c5540ebe55c407d9fe
		;*/


		;/*	returns "4" if all functions are present
			SELECT SUM(1) 
			FROM pragma_function_list
			WHERE name = 'sqlar_compress' OR 
				name = 'sqlar_uncompress' OR 
				name = 'compress' OR 
				name = 'uncompress';
		;*/

		if !FileExist(a_scriptdir "\SQLite3.dll"){
			For k,v in ["SQLite3","icudt71","icuin71","icuio71","icutu71","icuuc71"]
				Extract_install_%v%(a_scriptdir "\" v ".dll",1)

		}

	}
	*/
}