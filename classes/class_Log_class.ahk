Class Log_class
{ ; Class that handles writing to a log file
	; This class makes working with a log file much easier.  Once created, you can write to a log file with a single method call.
	; Each instance of the object supports a single log file (and its inactive older versions).  To use multiple log files (with separate names) create multiple instances.
	; The log files will be tidied up and rotated automatically.
	; The current log will be titled with just the base filename (e.g., MyLogFile.log) with older, inactive log files being named with a trailing index (e.g., MyLogFile_1.log, MyLogFile_2.log).  Newer files having a higher index.  
	; Log files may be limited by size, and when the threshold is reached the file will be moved to an inactive filename and a new log started.  
	;
	; A brief usage example is as follows:
	;	global log := new LogClass(“MyLogFile”)
	;	log.initalizeNewLogFile(false, “Header text to appear at the start of the new file”)
	;	log.addLogEntry(“Your 1st message to put in the log file”)
	;	log.addLogEntry(“Your next message to put in the log file”)
	;	log.finalizeLog(“Footer text to appear at the very end of your log, which you are done with.”)
	;
	; This LogClass is inspired (very much so) by the pre-AHK built-in classes (circa 2009) file Log.ahk
	;
	; The <name>String properties (e.g., preEntryString, HeaderString, etc.) may be set via initalizeNewLogFile() or individually.  
	; They are strings that will be applied automatically when creating/ending a log file, or adding a new log message/entry.  This allows you to apply a common format (or information) to every logfile or log entry.
	; The String properties all accept variables which may be expanded when written.
		; * $time or %A_Now% expands to the time the log entry is written (as formatted according to this.logsTimeFormat).
		; * $printStack expands to a list of the function calls which caused the log entry to be written.
		; * %Var% expands to whatever value variable Var is, but Var must be a global/built-in variable.
	; These String property variables may be used in the log entries too (e.g., by this.addLogEntry(entry))


	__New(aLogBaseFilename, aLogDir="", aLogExten="", aMaxSizeMBLogFile="", aMaxNumbOldLogs="")
	{
		; Input variables
		; 	aLogBaseFilename -> 1/3 of the log's full filename (filename -> aLogDir\aLogBaseFilename.aLogExten)
		; 	                    Note: If aLogBaseFilename is blank (e.g., ""), then the ScriptName without the exten is used (e.g., "MyScript.ahk" results in a base name of "MyScript"), which is probably the easiest.
		; 	                    Note: If aLogBaseFilename is fully pathed (e.g., C:\Logs\MyLogFile.log) aLogDir and aLogExten are ignored.
		; 	aMaxNumbOldLogs -> The maximum number of old log files to keep when rotating/tidying up the log files.  -1 is infinite.  0 (the default) will not create any indexed (e.g., MyLogFile_1.log) files.
		; 	aMaxSizeMBLogFile -> The maximum size (in megabytes) before a log file is automatically closed and rotated to a new file.  0 or less is infinite (the default).  
		; 	aLogDir -> 1/3 of the log's full filename (filename -> aLogDir\aLogBaseFilename.aLogExten).  The default is A_WorkingDir.
		; 	aLogExten -> 1/3 of the log's full filename (filename -> aLogDir\aLogBaseFilename.aLogExten).  The default is "log".
		
		this._classVersion := 0.2.0
		this._classAlterDate := "2018-09-30"
		
		
		; establish any default values
		this.maxNumbOldLogs_Default     := -1 ; -1 is infinite, 0 is only the current file
		this.maxSizeMBLogFile_Default   := 99 ; 0 or less than (-1) is unlimited size
		this.logDir_Default             := A_WorkingDir
		this.logExten_Default           := "log"
		this.logsFileEncoding_Default   := "UTF-8"
		this.logsTimeFormat_Default     := "yyyy-MM-dd hh:mm:ss tt"
		this.preEntryString_Default     := ""
		this.postEntryString_Default    := ""
		this.headerString_Default       := ""
		this.footerString_Default       := ""
		this.useRecycleBin_Default      := false
		this.printStackMaxDepth_Default := 5 ; maximum number of parent function calls to include the PrintStack function
		this.isAutoWriteEntries_Default := true
		this.maxPendingEntries			:= 200 ; maximum number of log entries to store in buffer

		; initialize any properties (not received as inputs)
		this.logsFileEncoding      := this.logsFileEncoding_Default
		this.logsTimeFormat        := this.logsTimeFormat_Default
		this.preEntryString        := this.preEntryString_Default
		this.postEntryString       := this.postEntryString_Default
		this.headerString          := this.headerString_Default
		this.footerString          := this.footerString_Default
		this.useRecycleBin         := this.useRecycleBin_Default
		this.printStackMaxDepth    := this.printStackMaxDepth_Default
		this.isAutoWriteEntries    := this.isAutoWriteEntries_Default
		this.isLogClassTurnedOff   := false
		this._pendingEntries       := []
		this._ignorePendingEntries := false
		this.application		   := ""

		; Error checking done in property get/set
		if (aMaxNumbOldLogs = "") {
			this.maxNumbOldLogs := maxNumbOldLogs_Default
		} else {
			this.maxNumbOldLogs := aMaxNumbOldLogs
		}

		if (aMaxSizeMBLogFile = "") {
			this.maxSizeMBLogFile := maxSizeMBLogFile_Default
		} else {
			this.maxSizeMBLogFile := aMaxSizeMBLogFile
		}

		; now error check the filename input values
		if(aLogDir="")
			aLogDir := this.logDir_Default
		if(aLogExten="")
			aLogExten := this.logExten_Default
		if(aLogBaseFilename="")
		{ ; use the ScriptName without the extension (i.e., *.ahk or *.exe)
			SplitPath, A_ScriptFullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			aLogBaseFilename := OutNameNoExt
		}
		else if(this.isFilenameFullyPathed(aLogBaseFilename))
		{ ; ignore the other given filename inputs
			SplitPath, aLogBaseFilename, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			aLogDir := OutDir ; overwrite any aLogDir we were given as input
			aLogExten := OutExtension  ; overwrite any aLogExten we were given as input
			aLogBaseFilename := OutNameNoExt ; now it looks like the normal aLogDir . "\" . aLogBaseFilename . "." aLogExten triplet
		}

		; put the filename parts together
		this.currentFileName_FullPath := aLogDir . "\" . aLogBaseFilename . "." . aLogExten

		return this
	}
	
	; Properties
	; ---------------------------------------------
	;BeginRegion
	
	classVersion
	{ ; (Read-Only)  Just the revision/version number of this class
		get
		{
			return this._classVersion
		}
	}

	; List
	; -------------------
	; currentFileName_FullPath ; The current log filename, in full path form.  All other filename related properties read/write to this as the master/keeper of the filename 
	; preEntryString           ; A string to prepend (before) to any log entry (made via addLogEntry()).
	; postEntryString          ; A string to append (after) to any log entry (made via addLogEntry()).
	; headerString             ; A string to be placed at the start of every new logfile (made via initalizeNewLogFile()).
	; footerString             ; A string to be placed at the end of every new logfile (made via finalizeLog()).
	; logsFileEncoding         ; The encoding for the logfile (see AHK help page on FileEncoding).  The default is UTF-8
	; logsTimeFormat           ; The format that $time or %A_Now% will be expanded to (see AHK help page on FormatTime).  The default is "yyyy-MM-dd hh:mm:ss tt"
	; maxNumbOldLogs           ; The maximum number of old (i.e., indexed; e.g., MyLogFile_1.log) files to keep when rotating/cleaning the logs
	; maxSizeMBLogFile         ; The maximum size (in megabytes) of the log file before a new file is automatically created.  The size is not super-strict.  If you really try you can break this, especially is headerString creates a file bigger than your size limit.
	; useRecycleBin            ; Should deleted files be deleted or moved to the RecycleBin?  The default is true (to the Recycle Bin).
	; isAutoWriteEntries       ; New log entries can be written immediately (the default), or saved up in the pendingEntries array (to be written later).  Useful if you want to limit the number of times a logfile is edited in a given time period (e.g., if your logfile is in a cloud synched folder).  If changed (to true) while entries are pending, they will all be written on next addLogEntry().
	; isLogClassTurnedOff      ; When true, pretty much every function instantly exits ** with NO error value ** (so no entries may be added/files moved).  (The default is: false).  Useful for turning off logging ability, especially when your addLogEntry() calls are buried deep in some class/function and you don't want to hunt them down and comment them out.
	; printStackMaxDepth       ; When expanding the String property variable $printStack how far back in call chain should be reported?  The default is 5
	; _pendingEntries[]        ; (Internal use only)  The array of unwritten log entries.
	; _ignorePendingEntries    ; (Internal use only)  If when writing the unwritten log entries a new file needs to be created (due to size), this flags initalizeNewLogFile()/finalizeLog() to not reset the pendingEntries[]

	; not yet implemented (and maybe never will be)
	; maxNumbLogEntries ; before a new logfile
	; numberCurrentLogEntries ; (includes pending) read-only
	; maxPendingEntries ; don't let pending entries get out of control
	
	maxNumbOldLogs
	{ ; The maximum number of old (i.e., indexed; e.g., MyLogFile_1.log) files to keep when rotating/cleaning the logs
		get
		{
			return this._maxNumbOldLogs
		}
		set
		{
			; -1 is infinite, 0 is only the current file
			aMaxNumbOldLogs:= value
			if aMaxNumbOldLogs is not integer
			{
				aMaxNumbOldLogs := this.maxNumbOldLogs_Default
			}
			return this._maxNumbOldLogs := aMaxNumbOldLogs 
		}
	}
	
	maxSizeMBLogFile
	{ ; The maximum size (in megabytes) of the log file before a new file is automatically created.  The size is not super-strict.  If you really try you can break this, especially is headerString creates a file bigger than your size limit.
		get
		{
			return this._maxSizeMBLogFile
		}
		set
		{ ; 0 or less than (-1) is unlimited size
			
			aMaxSizeMBLogFile:= value
			if aMaxSizeMBLogFile is not number
			{ 
				aMaxSizeMBLogFile := this.maxSizeMBLogFile_Default
			}
			if (aMaxSizeMBLogFile = 0 ) 
			{ ; a value of 0 can be confusing, set it to -1 which means the same thing (infinite size)
				aMaxSizeMBLogFile := -1
			}
			return this._maxSizeMBLogFile := aMaxSizeMBLogFile 
		}
	}
	
	printStackMaxDepth
	{ ; When expanding the String property variable $printStack how far back in call chain should be reported?  The default is 5
		get
		{
			return this._printStackMaxDepth
		}
		set
		{
			aPrintStackMaxDepth:= value
			if aPrintStackMaxDepth is not digit
			{
				aPrintStackMaxDepth := this.printStackMaxDepth_Default
			}
			return this._printStackMaxDepth := aPrintStackMaxDepth 
		}
	}
	
	;EndRegion

	; Pseudo-Properties (actually functions that look like properties)
	; ---------------------------------------------
	;BeginRegion
	
	baseFileName
	{ ; The current log file's filename w/o extension or trailing index (e.g., MyLogFile_1.log would be "MyLogFile").  set() alters currentFileName_FullPath (and hence all other filename properties)
		get
		{
			aCurrentFileName_FullPath := this.currentFileName_FullPath
			SplitPath, aCurrentFileName_FullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			return OutNameNoExt
		}
		set
		{
			aBaseFileName := value
			aCurrentFileName_FullPath := this.currentFileName_FullPath
			SplitPath, aCurrentFileName_FullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			this.currentFileName_FullPath := OutDir . "\" . aBaseFileName . "." . OutExtension
			SplitPath, aCurrentFileName_FullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			return OutNameNoExt
		}
	}
	
	currentFileName
	{ ; The current log file's filename, w/o path information.  set() alters currentFileName_FullPath (and hence all other filename properties)
		get
		{
			aCurrentFileName_FullPath := this.currentFileName_FullPath
			SplitPath, aCurrentFileName_FullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			return OutFileName
		}
		set
		{
			aCurrentFileName := value
			if(this.isFilenameFullyPathed(aCurrentFileName))
			{
				this.currentFileName_FullPath := aCurrentFileName
			}
			else
			{
				aCurrentFileName_FullPath := this.currentFileName_FullPath
				SplitPath, aCurrentFileName_FullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
				this.currentFileName_FullPath := OutDir . "\" . aCurrentFileName
			}
			SplitPath, aCurrentFileName_FullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			return OutFileName
		}
	}
	
	logDir
	{ ; The current log file's directory.  set() alters currentFileName_FullPath (and hence all other filename properties)
		get
		{
			aCurrentFileName_FullPath := this.currentFileName_FullPath
			SplitPath, aCurrentFileName_FullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			return OutDir
		}
		set
		{
			aLogDir := value
			aCurrentFileName_FullPath := this.currentFileName_FullPath
			SplitPath, aCurrentFileName_FullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			this.currentFileName_FullPath := aLogDir . "\" . OutFileName
			SplitPath, aCurrentFileName_FullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			return OutDir
		}
	}
	
	logExten
	{ ; The current log file's extension (e.g., *.log).  set() alters currentFileName_FullPath (and hence all other filename properties)
		get
		{
			aCurrentFileName_FullPath := this.currentFileName_FullPath
			SplitPath, aCurrentFileName_FullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			return OutExtension
		}
		set
		{
			aLogExten := value
			aCurrentFileName_FullPath := this.currentFileName_FullPath
			SplitPath, aCurrentFileName_FullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			this.currentFileName_FullPath := OutDir . "\" . OutNameNoExt . "." . aLogExten
			SplitPath, aCurrentFileName_FullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			return OutExtension
		}
	}

	set_applicationname(para_input) {
		this.application := para_input
	}
	;EndRegion
	
	
	
	; Methods (of suitable importance)
	; ---------------------------------------------
	;BeginRegion
	
	initalizeNewLogFile(overwriteExistingFile=false, aHeaderString="UNDEF", aPreEntryString="UNDEF", aPostEntryString="UNDEF", aFooterString="UNDEF", aLogsFileEncoding="UNDEF")
	{ ; Start a new log file, and set (if given) any of the predefined string properties. This method will rotate/move any old log files, as needed.  For the Header/Footer isAutoWriteEntries is ignored (always instantly writes)
	; Input variables
	; 	overwriteExistingFile (Boolean) -> should a pre-existing log file be overwritten or moved (index added to the end; e.g., MyLogFile_1.log)?
	; 	aHeaderString     -> If given, sets the corresponding property.  If not given, the corresponding property stays the same (e.g., from your last log file)
	; 	aPreEntryString   -> If given, sets the corresponding property.  If not given, the corresponding property stays the same (e.g., from your last log file)
	; 	aPostEntryString  -> If given, sets the corresponding property.  If not given, the corresponding property stays the same (e.g., from your last log file)
	; 	aFooterString     -> If given, sets the corresponding property.  If not given, the corresponding property stays the same (e.g., from your last log file)
	; 	aLogsFileEncoding -> If given, sets the corresponding property.  If not given, the corresponding property stays the same (e.g., from your last log file)
	; Output variables
	; 	integer - 0 if everything went well, 1+ for each time something went wrong (a sum of ErrorLevel and the various File actions)
	
		if this.isLogClassTurnedOff ; should this method/class be turned off?
			return false ; if so, exit out before doing anything.

		aLogDir := this.logDir
		aCurrentFileName_FullPath := this.currentFileName_FullPath
		errLvl := false
		
		; UNDEF is used so the properties may have a "" value
		if(aHeaderString != "UNDEF")
			this.headerString := aHeaderString
		if(aPreEntryString != "UNDEF")
			this.preEntryString := aPreEntryString
		if(aPostEntryString != "UNDEF")
			this.postEntryString := aPostEntryString
		if(aFooterString != "UNDEF")
			this.footerString := aFooterString
		if(aLogsFileEncoding != "UNDEF")
			this.logsFileEncoding := aLogsFileEncoding
		if(!this._ignorePendingEntries)
			this._pendingEntries := []
		this._ignorePendingEntries := false ; reset IgnoreVal regardless if it was set or not

		if (!InStr(FileExist(aLogDir), "D"))
		{ ; check if Dir exits
			FileCreateDir, %aLogDir%
			errLvl := ErrorLevel
		}
		else if( FileExist(aCurrentFileName_FullPath) )
		{ ; if the Dir exists, check if the file exists and handle accordingly
			if (overwriteExistingFile)
			{
				FileDelete, %aCurrentFileName_FullPath%
				errLvl := ErrorLevel
			}
			else
			{
				errLvl += this.moveLog()
				errLvl += this.tidyLogs()
			}
		}
		
		if(!errLvl)
		{ ; now write the header string
			aLogFileEncoding := this.logsFileEncoding
			aHeaderString := this.headerString
			aHeaderString := this.transformStringVars(aHeaderString) ; expand any variables in the string
			; write automatically regardless of this.isAutoWriteEntries
			errLvl := this.appendFile(aHeaderString, aCurrentFileName_FullPath, aLogFileEncoding)
		}
		return errLvl
	}
	
	finalizeLog(aFooterString="UNDEF")
	{ ; End a  log file, and set (if given) the predefined string property. This method will rotate/move any old log files, as needed.  For the Header/Footer isAutoWriteEntries is ignored (always instantly writes)
		; Note: "End" should not be confused with File.close().  File.close() is done every time an entry is written to the log file.  We're not sitting here with an open File the entire time you're using the LogClass. 
	; Input variables
	; 	aFooterString -> If given, sets the corresponding property.  If not given, the corresponding property stays the same (e.g., from your last log file or initalizeNewLogFile())
	; Output variables
	; 	integer - 0 if everything went well, 1+ for each time something went wrong (a sum of ErrorLevel and the various File actions)
	
		if this.isLogClassTurnedOff ; should this method/class be turned off?
			return false ; if so, exit out before doing anything.

		errLvl := false
		aLogDir := this.logDir
		aCurrentFileName_FullPath := this.currentFileName_FullPath
		aMaxNumbOldLogs := this.maxNumbOldLogs

		; UNDEF is used so the properties may have a "" value
		if(aFooterString != "UNDEF")
			this.footerString := aFooterString
		
		if (!InStr(FileExist(aLogDir), "D"))
		{ ; check if Dir exits
			FileCreateDir, %aLogDir%
			errLvl := ErrorLevel
		}

		if(!errLvl)
		{ ; write any pending entries & footer to the file
			if(!this._ignorePendingEntries)
			{ ; if this got called do to a log exceeding its size limit, we'll saving the pending entries for the next log file
				errLvl := this.savePendingEntriesToLog()
				; if a large enough number of entries are pending multiple log files may be written
			}
			
			aLogFileEncoding := this.logsFileEncoding
			aFooterString := this.footerString
			aFooterString := this.transformStringVars(aFooterString)
			; write automatically regardless of this.isAutoWriteEntries
			errLvl += this.appendFile(aFooterString, aCurrentFileName_FullPath, aLogFileEncoding)
		}

		; clean up the multiple log files
		if(aMaxNumbOldLogs > 0) ; if we only have 1 log file, then leave it alone (otherwise move/tidy deletes it, and you have no log files)
		{
			errLvl += this.moveLog()
			errLvl += this.tidyLogs()
		}
		
		this._ignorePendingEntries := false ; reset IgnoreVal regardless if it was set or not
		return errLvl
	}
	
	addLogEntry(entryString="", addNewLine=true, usePreEntryString=true, usePostEntryString=true)
	{ ; Adds a new entry (string) to the log file (or pending entries array, see aIsAutoWriteEntries).  Creates the entry as preEntryString . entryString . postEntryString
	; The <name>String properties (e.g., preEntryString, HeaderString, etc.) may be set via initalizeNewLogFile() or individually.  
	; They are strings that will be applied automatically when creating/ending a log file or adding a new log message/entry.  This allows you to apply a common format (or information) to every logfile or log entry.
	; The String properties all accept variables which may be expanded when written.
		; * $time or %A_Now% expands to the time the log entry is written (as formatted according to this.logsTimeFormat).
		; * $printStack expands to a list of the function calls which caused the log entry to be written.
		; * %Var% expands to whatever value variable Var is, but Var must be a global/built-in variable.
	; These String property variables may be used in entryString too
	; -----------------
	; Input variables
	; 	entryString          -> The string you wish to write to the log.  Will be pre/post-appended as dictated by the other inputs
	; 	addNewLine (Boolean) -> Should a "`n" be added to the end of entryString or not (useful if use 1-line entries)?  Default is true.
	; 	usePreEntryString (Boolean) -> Should preEntryString by added before entryString?  Default is true.
	; 	usePostEntryString (Boolean) -> Should postEntryString by added after entryString?  Default is true.
	; Output variables
	; 	integer - 0 if everything went well, 1+ for each time something went wrong (a sum of ErrorLevel and the various File actions)

		if this.isLogClassTurnedOff ; should this method/class be turned off?
			return false ; if so, exit out before doing anything.

		aPreEntryString := this.preEntryString
		aPostEntryString := this.postEntryString
		aIsAutoWriteEntries := this.isAutoWriteEntries
		errLvl := false

		; transform (unpack the variables) in each string
		; then concatenate them together, as desired
		entryString := this.transformStringVars(entryString)
		if(usePreEntryString)
		{
			aPreEntryString := this.transformStringVars(aPreEntryString)
			entryString := aPreEntryString . entryString
		}
		if(addNewLine)
		{
			entryString := entryString . "`n"
		}
		if(usePostEntryString)
		{
			aPostEntryString := this.transformStringVars(aPostEntryString)
			entryString := entryString . aPostEntryString
		}
		
		; now add the entry to file/array
		; add everything to the array, then if auto writing, write out the array
		retVal := this._pendingEntries.push(entryString) ; God I love push/pop. I don't know why but I have loved those 2 functions for decades now.
		if(aIsAutoWriteEntries || this.pendingEntries.MaxIndex() >= this.maxPendingEntries) 
		{ ; if auto writing, write out the array
			errLvl := this.savePendingEntriesToLog()
		}
		return errLvl
	}


    add(entryString="", loglevel="INFO")
	{ ; Adds a new stringified json object to the log file (or pending entries array, see aIsAutoWriteEntries).  Creates the entry as preEntryString . entryString . postEntryString

		if (this.isLogClassTurnedOff) { ; should this method/class be turned off?
            return false ; if so, exit out before doing anything.
        }

		aPreEntryString := this.preEntryString
		aPostEntryString := this.postEntryString
		aIsAutoWriteEntries := this.isAutoWriteEntries
		errLvl := false

		; transform (unpack the variables) in each string
		entryString := this.transformStringVars(entryString)
		
        ;; Create the misc data for our log entry
        logobject := {}
		logobject.msg := entryString
        FormatTime, l_time , A_Now, yyyy-MM-dd HH:mm:ss ;2018-06-25 16:14:35
        logobject.time := l_time
        logobject.utc := A_NowUTC
        logobject.machine := A_ComputerName
        logobject.username := A_UserName
        logobject.application := this.application
        logobject.level := loglevel
        logobject.process := A_ScriptHwnd

		; stringify and append `n
        entryString := JSON.stringify(logobject) "`n"


        ; if(addNewLine) {
		; 	entryString := entryString . "`n"
		; }

        ; now add the entry to file/array
		; add everything to the array, then if auto writing, write out the array
		retVal := this._pendingEntries.push(entryString) ; God I love push/pop. I don't know why but I have loved those 2 functions for decades now.
		if(aIsAutoWriteEntries || this.pendingEntries.MaxIndex() >= this.maxPendingEntries) 
		{ ; if auto writing, write out the array
			errLvl := this.savePendingEntriesToLog()
		}
		return errLvl
	}
	
	savePendingEntriesToLog()
	{ ; Writes the pending entries to the log file, creating more log files if needed
	; Output variables
	; 	integer - 0 if everything went well, 1+ for each time something went wrong (a sum of ErrorLevel and the various File actions)
		if this.isLogClassTurnedOff ; should this method/class be turned off?
			return false ; if so, exit out before doing anything.

		aLogDir := this.logDir
		aCurrentFileName_FullPath := this.currentFileName_FullPath
		aLogFileEncoding := this.logsFileEncoding
		aMaxSizeMBLogFile := this.maxSizeMBLogFile
		errLvl := false

		if (!InStr(FileExist(aLogDir), "D"))
		{ ; check if Dir exits
			FileCreateDir, %aLogDir%
			errLvl := ErrorLevel
		}
		
		if(!errLvl)
		{
			arrayLength := this._pendingEntries.length()
			Loop, %arrayLength% ; this should be a contiguous array 
			{ ; start writing out the array
				; is the log file too big to add more to it?
				if(aMaxSizeMBLogFile > 0) ; < or = 0 is unlimited size
				{
					if(FileExist(aCurrentFileName_FullPath)) ; FileGetSize fails if the file doesn't exist
					{ 
						FileGetSize, logSize, %aCurrentFileName_FullPath% ; get in bytes because the K & M options return integers and this annoys me
						if(!ErrorLevel) 
						{
							logSizeMB := this.byteToMB(logSize)
							if(logSizeMB > aMaxSizeMBLogFile)
							{  ; close the file and start a new one
								this._ignorePendingEntries := true ; don't let finalizeLog()/initalizeNewLogFile() clear the array (array := [])
								errLvl += this.finalizeLog()
								this._ignorePendingEntries := true ; this got cleared by finalizeLog()
								errLvl += this.initalizeNewLogFile() ; this does move & tidy too
							}
						}
					}
				}
				
				; write the next entry
				minIndex := this._pendingEntries.MinIndex() ; rename for easier handling
				entryString := this._pendingEntries.RemoveAt(minIndex) ; I want this to be called shift().  If I have push/pop, I want shift/unshift. :(
				try {
					errLvl += this.appendFile(entryString, aCurrentFileName_FullPath, aLogFileEncoding)
				} catch e {
					
					; sometimes the file can be written to too quickly, if you're pounding it with new entries
					; try again after a rest
					; hopefully moving to the File Object (from FileAppend) solves this
					MsgBox, 16,, % "Before we try again...`nUnable to write to log file!" "`n" "`t" "(Possibly written to too fast?)" "`n`n" "Filename: " aCurrentFileName_FullPath "`n" "LogEntry: " entryString "`n" "Exception.message: " e.message "`n" "Exception.Extra: " e.extra "`n`n`n" "------------------" "`n" . this.printStack(10)
					Sleep 500
					try {
						errLvl += this.appendFile(entryString, aCurrentFileName_FullPath, aLogFileEncoding)
					} catch e {
						MsgBox, 16,, % "Unable to write to log file!" "`n" "`t" "(Possibly written to too fast?)" "`n`n" "Filename: " aCurrentFileName_FullPath "`n" "LogEntry: " entryString "`n" "Exception.message: " e.message "`n" "Exception.Extra: " e.extra "`n`n`n" "------------------" "`n" . this.printStack(10)
					}
				}
			}
		}
		return errLvl
	}

	moveLog(aNewLogFilename="", aNewLogDir="", overwriteExistingFile=false)
	{ ; Moves the current log to a new filename.  Will place it at the end of the index chain (e.g., MyLogFile_1.log), or to the name given via input variables.
	; Input variables
	; 	aNewLogFilename -> The filename to move current log to.  If blank, will place it at the end of the index chain (e.g., MyLogFile_1.log).  If a fully pathed filename, aNewLogDir is ignored.
	; 	aNewLogDir      -> The directory to move current log to.  The full filename's path will be aNewLogDir\aNewLogFilename (unless the caveats described above apply)
	; 	overwriteExistingFile (Boolean) -> Should any existing files be overwritten?  
	; Output variables
	; 	integer - 0 if everything went well, 1+ for each time something went wrong (a sum of ErrorLevel and the various File actions)

	if this.isLogClassTurnedOff ; should this method/class be turned off?
			return false ; if so, exit out before doing anything.

		aCurrentFileName_FullPath := this.currentFileName_FullPath ; source file
		errLvl := false

		; check that the source file actually exists
		errLvl := !FileExist(aCurrentFileName_FullPath)
		if(!errLvl)
		{
			; now error check the input values
			if(this.isFilenameFullyPathed(aNewLogFilename))
			{
				SplitPath, aNewLogFilename, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
				aNewLogDir := OutDir ; overwrite any aNewLogDir we were given as input
				aNewLogFilename := OutFileName ; now it looks like the normal aNewLogDir . "\" . aNewLogFilename pair
			}
			else if (aNewLogDir = "")
			{ ; if aNew is fully pathed, this will be skipped
				aNewLogDir := this.logDir
			}

			if (!InStr(FileExist(aNewLogDir), "D"))
			{ ; check if Dir exits
				FileCreateDir, %aNewLogDir%
				errLvl := ErrorLevel
			}
			
			if(!errLvl)
			{
				if(aNewLogFilename = "") ; destination file
				{ ; if "", move log to end of A_Index chain (e.g., MyLogFile_1.log)
					SplitPath, aCurrentFileName_FullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
					
					Loop
					{
						candidateFilename := aNewLogDir . "\" . OutNameNoExt . "_" . A_Index . "." OutExtension
						if (!FileExist(candidateFilename))
							break
					}
					aNewLogFilename_FullPath := candidateFilename ; set to whichever candidate won
				}
				else
				{ ; if != "", move to explicitly given destination file
					aNewLogFilename_FullPath := aNewLogDir . "\" . aNewLogFilename
				}
				
				; Move the file
				FileMove, %aCurrentFileName_FullPath%, %aNewLogFilename_FullPath%, %overwriteExistingFile%
				errLvl := ErrorLevel
			}
		}
		return errLvl
	}
	
	tidyLogs(aMaxNumbOldLogs="")
	{ ; Rotates logs (newest is highest in the index chain (e.g., MyLogFile_1.log)).  Deletes oldest logs (and re-numbers the less-old) until there are less than aMaxNumbOldLogs/maxNumbOldLogs.
	; Input variables
	; 	aMaxNumbOldLogs -> The maximum number of old log files to keep.  If not blank, sets this.maxNumbOldLogs.
	; Output variables
	; 	integer - 0 if everything went well, 1+ for each time something went wrong (a sum of ErrorLevel and the various File actions)

		if this.isLogClassTurnedOff ; should this method/class be turned off?
			return false ; if so, exit out before doing anything.

		aUseRecycleBin := this.useRecycleBin
		aCurrentFileName_FullPath := this.currentFileName_FullPath
		errLvl := 0

		if (aMaxNumbOldLogs = "")
			aMaxNumbOldLogs := this.maxNumbOldLogs
		
		if (aMaxNumbOldLogs >= 0) ; -1 means keep all old logs
		{
			SplitPath, aCurrentFileName_FullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			; count the number of files (yeah, a discontinuity in the numbering system breaks this (e.g., 1, 2, 3, 7, 8 ... will stop at 3)
			Loop
			{
				candidateFilename := OutDir . "\" . OutNameNoExt . "_" . A_Index . "." OutExtension
				doesExist := FileExist(candidateFilename)
				if (!doesExist)
					break
				totalNumbOldLogs := A_Index
			}

			; rotate/delete the files
			new_Index := 0
			if(totalNumbOldLogs > aMaxNumbOldLogs)
			{
				numbLogsToDelete := totalNumbOldLogs - aMaxNumbOldLogs
				Loop, %totalNumbOldLogs%
				{
					oldFilename := OutDir . "\" . OutNameNoExt . "_" . A_Index . "." OutExtension
					if(FileExist(oldFilename))
					{
						if(A_Index <= numbLogsToDelete)
						{ ; delete the older/lower numbered files (makes way for the next step)
							errLvl1 := this.deleteLog(oldFilename, aUseRecycleBin)
							errLvl := errLvl + errLvl1
						}
						else
						{ ; move the newer/higher numbered files to a lower number (they are now older)
							new_Index++
							newFilename := OutDir . "\" . OutNameNoExt . "_" . new_Index . "." OutExtension
							FileMove, %oldFilename%, %newFilename%, 1 ; overwrite if file still exists (will probably fail if that is the case, or else FileDelete would have handled it)
							errLvl := errLvl + ErrorLevel
						}
					}
				}
			}
		}
		return errLvl
	}
	
	deleteAllLogs(putInRecycleBin=true, useWildCard=true)
	{ ; Deletes all log files (using 1 of 2 methods). 
	; Input variables
	; 	putInRecycleBin -> switches between FileDelete and FileRecycle
	; 	useWildCard -> If false, will walk through log files until a numeric break is hit.  If true, will delete everything using a "baseName_*.exten" wildcard string.
	; Output variables
	; 	integer - 0 if everything went well, 1+ for each time something went wrong (a sum of ErrorLevel and the various File actions)
		aCurrentFileName_FullPath := this.currentFileName_FullPath
		errLvl := 0

		; delete the current file
		errLvl += this.deleteLog(aCurrentFileName_FullPath, putInRecycleBin)

		; delete all the old files
		errLvl += this.deleteAllOldLogs(putInRecycleBin, useWildCard)
		return errLvl
	}

	deleteAllOldLogs(putInRecycleBin=true, useWildCard=true)
	{ ; Deletes all OLD log files (using 1 of 2 methods). Will not delete the current log file.
	; Input variables
	; 	putInRecycleBin -> switches between FileDelete and FileRecycle
	; 	useWildCard -> If false, will walk through log files until a numeric break is hit.  If true, will delete everything using a "baseName_*.exten" wildcard string.
	; Output variables
	; 	integer - 0 if everything went well, 1+ for each time something went wrong (a sum of ErrorLevel and the various File actions)
		aCurrentFileName_FullPath := this.currentFileName_FullPath
		errLvl := 0

		; delete all the old files
		SplitPath, aCurrentFileName_FullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
		if(useWildCard)
		{ ; the wildcard technique, which just deletes everything
			candidateFilename := OutDir . "\" . OutNameNoExt . "_" . "*" . "." OutExtension
			errLvl += this.deleteLog(candidateFilename, putInRecycleBin)
		}
		else
		{ ; the original walking technique which stops once you hit a discontinuity (which allows you to hide old files at high numbers)
			Loop
			{
				candidateFilename := OutDir . "\" . OutNameNoExt . "_" . A_Index . "." OutExtension
				doesExist := FileExist(candidateFilename)
				if (!doesExist)
					break
				errLvl += this.deleteLog(candidateFilename, putInRecycleBin)
			}
		}
		return errLvl
	}

	deleteLog(fileToDelete, putInRecycleBin=true)
	{ ; deletes/recycles a log (any file really)
	; Output variables
	; 	integer - 0 if everything went well, 1+ for each time something went wrong (a sum of ErrorLevel and the various File actions)
		errLvl := false
		
		doesExist := FileExist(fileToDelete)
		if (doesExist)
		{
			if(putInRecycleBin)
			{
				FileRecycle, %fileToDelete%
			}
			else
			{
				FileDelete, %fileToDelete%
			}
			errLvl := ErrorLevel
		}
		return errLvl
	}

	;EndRegion


	; Methods (helpers)
	; ---------------------------------------------
	;BeginRegion
	
	appendFile(text, filename, encoding)
	{ ; a wrapper to FileAppend or its File Object equivalent (so much faster)
		errLvl := false
		USE_FILE_OBJECT := true

		if this.isLogClassTurnedOff ; should this method/class be turned off?
			return false ; if so, exit out before doing anything.

		if(text != "")
		{
			if(!USE_FILE_OBJECT)
			{
				FileAppend, %text%, %filename%, %encoding%
				errLvl := ErrorLevel
			}
			else
			{
				file := FileOpen(filename, "a" , encoding)
				if(file) ; no error occurred
				{
					bytesWritten := file.Write(text)
					file.Close()
					file := {} ; free up the object
					
					; error check: see if anything was written.  We already tested that (text != ""), which would write no bytes.
					if(bytesWritten = 0)
					{
						errLvl := true
					}
				}
				else
				{
					errLvl := true
				}
			}
		}
		return errLvl
	}
	
	createDividerString(char="-", length=70)
	{ ; create a string that repeats X times (e.g., "---------------" and can be used as a line or divider)
		outStr := ""
		Loop, %length%
		{
			outStr .= char
		}
		return outStr
	}
	
	byteToMB(bytes, decimalPlaces=2)
	{ ; It converts bytes to megabytes (you expected something else?).  And limits things to X digits after the decimal place.
		kiloBytes := bytes / 1024.0
		megaBytes := kiloBytes / 1024.0
		megaBytes := round(megaBytes, decimalPlaces)

		return megaBytes
	}
	
	isFilenameFullyPathed(filename)
	{ ; determine if a filename has a relative path or starts at the root (i.e., fully pathed)
		SplitPath, filename, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
		if(OutDrive != "")
			return true
		else
			return false
	}
	
	transformStringVars(encodedString)
	{ ; converts a variable (normal %var%, or made up for this class, $printStack) to whatever its value is (when this function is run)
	; The String properties all accept variables which may be expanded when written.
	; * $time or %A_Now% expands to the time the log entry is written (as formatted according to this.logsTimeFormat).
	; * $printStack expands to a list of the function calls which caused the log entry to be written.
	; * %Var% expands to whatever value variable Var is, but Var must be a global/built-in variable.
	; ------------------------
	; Input variables
	; 	encodedString -> A string, possibly with an encoded %var%/$var in it
	; Non-Input variables (that are relied upon in an important enough way that I should tell you about it).
	; 	this.logsTimeFormat -> The format that $time or %A_Now% will be expanded to (see AHK help page on FormatTime).  The default is "yyyy-MM-dd hh:mm:ss tt"
	; Output variables
	; 	plaintextString -> A string with any %var%/$var replaced by those variables values.

		aLogsTimeFormat := this.logsTimeFormat
		plaintextString := ""
		
		if(encodedString != "")
		{
			; Replace $time var
			if ( (InStr(encodedString, "$time")) OR (InStr(encodedString, "`%A_Now`%")) )
			{ ; $time is really a hold over from the (circa 2009) Log.ahk class.  %A_Now% is preferred.
				; Format the current time
				FormatTime, formattedTime, %A_Now%, %aLogsTimeFormat%
				encodedString := RegExReplace(encodedString, "\$time", formattedTime)
				encodedString := RegExReplace(encodedString, "\%A_Now\%", formattedTime)
			}

			; Expand %var%
			if (RegExMatch(encodedString,"%\w+%"))
			{ 
				; variables need to be ** global ** to be DeRef'ed
				Transform, encodedString, DeRef, %encodedString% ; convert any variables to actual values
			}

			; Replace $printStack var
			if (InStr(encodedString, "$printStack"))
			{ 
				depth := this.printStackMaxDepth
				skip := 2 ; skip transformStringVars() and printStack()
				encodedString := StrReplace(encodedString, "$printStack", this.printStack(depth, skip))
			}

			; copy the now-expanded string to the output string
			plaintextString := encodedString
		}
		return plaintextString
	}

	printStack(maxNumbCalls=2, numbCallsToSkipOver=1 )
	{ ; outputs a String detailing the parentage of functions that called this function

		; if numbCallsToSkipOver=1, skip this printStack() since the work is done in generateStack()
		str := "Stack Print, most recent function calls first:`n"
		str .= "`t" . "Skipping over " . numbCallsToSkipOver . " calls and a maximum shown call depth of " . maxNumbCalls . ".`n"

		maxNumbCalls := maxNumbCalls + numbCallsToSkipOver
		stack := this.generateStack()
		for each, entry in stack
		{
			if(A_Index <= numbCallsToSkipOver)
			{ ; do nothing
			}
			else if(A_Index <= maxNumbCalls)
			{
				str .= "Line: " . entry.line . "`tCalled: " . entry.what "`tFile: " entry.file "`n"
			}
			else
			{
				break
			}
		}
		return str
	}

	generateStack( offset := -1 )
	{ ;returns the call stack as an Array of exception objects - the first array is the function most recently called.
		; from nnnik's excellent work at ..
		; https://autohotkey.com/boards/viewtopic.php?f=74&t=48740
		if ( A_IsCompiled )
			Throw exception( "Cannot access stack with the exception function, as the script is compiled." )
		stack := []
		While ( exData := exception("", -(A_Index-offset)) ).what != -(A_Index-offset)
			stack.push( exData )
		return stack
	}
	
	;EndRegion
	
	; Revision History
	; ---------------------------------------------
	;BeginRegion
	; 2018-06-15
	; * Initial fully commented draft of class
	; * TODO: more error checking on the filename properties
	;
	; 2018-06-08
	; * This folly begins
	;EndRegion
}
