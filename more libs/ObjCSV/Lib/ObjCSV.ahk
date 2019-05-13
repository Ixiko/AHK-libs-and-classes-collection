/*!
	Library: ObjCSV Library
		AutoHotkey_L (AHK) functions to load from CSV files, sort, display and save collections of records using the
		Object data type.  
		  
		* Read and save files in any delimited format (CSV, semi-colon, tab delimited, single-line or multi-line, etc.).
		* Display, edit and read Collections in GUI ListView objects.
		* Export Collection to fixed-width, HTML or XML files.
		  
		For more info on CSV files, see
		[http://en.wikipedia.org/wiki/Comma-separated_values](http://en.wikipedia.org/wiki/Comma-separated_values).  
		  
		Written by Jean Lalonde ([JnLlnd](http://www.autohotkey.com/board/user/4880-jnllnd/) on AHK forum) using
		AutoHotkey_L v1.1.09.03+ ([http://l.autohotkey.net/](http://l.autohotkey.net/))  
		  
		### ONLINE MATERIAL
		* [Home of this library is on GitHub](https://github.com/JnLlnd/ObjCSV)
		* [The most up-to-date version of this AHK file on GitHub](https://raw.github.com/JnLlnd/ObjCSV/master/Lib/ObjCSV.ahk)
		* [Online ObjCSV Library Help](http://code.jeanlalonde.ca/ahk/ObjCSV/ObjCSV-doc/)
		* [Topic about this library on AutoHotkey forum](http://www.autohotkey.com/board/topic/96618-lib-objcsv-library-v01-library-to-load-and-save-csv-files-tofrom-objects-and-listview/)
		  
		### INSTRUCTIONS
			Copy this script in a file named ObjCSV.ahk and save this file in one of these \Lib folders:
				* %A_ScriptDir%\Lib\
				* %A_MyDocuments%\AutoHotkey\Lib\
				* \[path to the currently running AutoHotkey_L.exe]\Lib\
			  
			You can use the functions in this library by calling ObjCSV_FunctionName (no #Include required)
		  
		### VERSIONS HISTORY
			0.5.9  2017-07-20 In ObjCSV_CSV2Collection, reverse change in v0.4.1 to import non-standard CSV files created by XL causing issue (stripping "=") in encapsulated fields with containing "...=""..."  
			0.5.8  2016-12-22 In ObjCSV_CSV2Collection, fix bug when creating "C" names header if blnHeader is false (0) and strFieldNames is empty.  
			0.5.7  2016-12-20  In ObjCSV_CSV2Collection, if blnHeader is false (0) and strFieldNames is empty, strFieldNames returns the "C" field names created by the function.  
			0.5.6  2016-10-20  Stop trimming data value read from CSV file. Addition of blnTrim parameter to ObjCSV_ReturnDSVObjectArray
			(true by default for backward compatibility).  
			0.5.5  2016-08-28  Optional parameter strEol to ObjCSV_Collection2CSV and ObjCSV_Collection2Fixed now empty by default.
			If not provided, end-of-lines character(s) are detected in value to replace. The first end-of-lines character(s) found is used
			for remaining fields and records.  
			0.5.4  2016-08-23  Add optional parameter strEol to ObjCSV_Collection2CSV and ObjCSV_Collection2Fixed to set end-of-line
			character(s) in fields when line-breaks are replaced.  
			0.5.3  2016-08-21  Fix bug with blnAlwaysEncapsulate in ObjCSV_Collection2CSV.  
			0.5.2  2016-07-24  Add an option to ObjCSV_Collection2CSV and blnAlwaysEncapsulate functions to force encapsulation of all values.  
			0.5.1  2016-06-06  In ObjCSV_CSV2Collection if the ByRef parameter is empty, the file encoding is returned only for UTF-8 or
			UTF-16 encoded files (no BOM) because other types (ANSI or UTF-n-RAW) files cannot be differentiated by the AHK engine.  
			0.5.0  2016-05-23  Addition of file encoding optional parameter to ObjCSV_CSV2Collection, ObjCSV_Collection2CSV,
			ObjCSV_Collection2Fixed, ObjCSV_Collection2HTML and ObjCSV_Collection2XML. In ObjCSV_CSV2Collection if the ByRef parameter is
			empty, it is returned with the detected file encoding.  
			0.4.1  2014-03-05  Import files with equal sign before opening field encasulator to indicate text data or formula not to be
			interpreted as numeric when imported by XL (eg. ...;="12345";...). This is an XL-only CSV feature, not a standard CSV feature.  
			0.4.0  2013-12-29  Improved file system error handling (upgrade recommended). Compatibility breaker: review ErrorLevel codes only.  
			0.3.2  2013-11-27  Check presence of ROWS delimiters in HTML export template  
			0.3.1  2013-10-10  Fix ProgressStop missing bug, fix numeric column names bug  
			0.3.0  2013-10-07  Removed strRecordDelimiter, strOmitChars and strEndOfLine parameters. Replaced by ``r``n (CR-LF). 
			Compatibility breaker. Review functions calls for ObjCSV_CSV2Collection, ObjCSV_Collection2CSV, ObjCSV_Collection2Fixed,
			ObjCSV_Collection2HTML, ObjCSV_Collection2XML, ObjCSV_Format4CSV and ObjCSV_ReturnDSVObjectArray  
			0.2.8  2013-10-06  Fix bug in progress start and stop  
			0.2.7  2013-10-06  Memory management optimization and introduction of ErrorLevel results  
			0.2.6  2013-09-29  Display progress using Progress bar or Status bar, customize progress messages, doc converted to GenDocs 3.0  
			0.2.5  2013-09-26  Optimize large variables management in save functions (2CSV, 2Fixed, 2HTML and 2XML),
			optimize progress bars refresh rates  
			0.2.4  2013-09-25  Fix a bug adding progress bar in ObjCSV_ListView2Collection  
			0.2.3  2013-09-20  Fix a bug when importing files with duplicate field names, reformating long lines of
			code  
			0.2.2  2013-09-15  Export to fixed-width (ObjCSV_Collection2Fixed), HTML (ObjCSV_Collection2HTML) and XML
			(ObjCSV_Collection2XML)  
			0.1.3  2013-09-08  Multi-line replacement character at load time in ObjCSV_CSV2Collection  
			0.1.2  2013-09-05  Standardize boolean parameters to 0/1 (not True/False) and without double-quotes  
			0.1.1  2013-08-26  First release  

	Author: By Jean Lalonde
	Version: v0.5.9 (2017-07-20)
*/


;================================================
ObjCSV_CSV2Collection(strFilePath, ByRef strFieldNames, blnHeader := 1, blnMultiline := 1, intProgressType := 0
	, strFieldDelimiter := ",", strEncapsulator := """", strEolReplacement := "", strProgressText := "", ByRef strFileEncoding := "")
/*!
	Function: ObjCSV_CSV2Collection(strFilePath, ByRef strFieldNames [, blnHeader = 1, blnMultiline = 1, intProgressType = 0, strFieldDelimiter = ",", strEncapsulator = """", strEolReplacement = "", strProgressText := "", ByRef strFileEncoding := ""])
		Transfer the content of a CSV file to a collection of objects. Field names are taken from the first line of
		the file or from the strFieldNameReplacement parameter. If taken from the file, fields names are returned by
		the ByRef variable strFieldNames. Delimiters are configurable.

	Parameters:
		strFilePath - Path of the file to load, which is assumed to be in A_WorkingDir if an absolute path isn't specified.
		strFieldNames - (ByRef) Input: Names for object keys if blnHeader if false. Names must appear in the same order as they appear in the file, separated by the strFieldDelimiter character (see below). If names are not provided and blnHeader is false, "C" + column numbers are used as object keys, starting at 1, and strFieldNames will return the "C" names. Empty by default. Output: See "Returns:" below.
		blnHeader - (Optional) If true (or 1), the objects key names are taken from the header of the CSV file (first line of the file). If blnHeader if false (or 0), the first line is considered as data (see strFieldNames). True (or 1) by default.
		blnMultiline - (Optional) If true (or 1), multi-line fields are supported. Multi-line fields include line breaks (end-of-line characters) which are usualy considered as delimiters for records (lines of data). Multi-line fields must be enclosed by the strEncapsulator character (usualy double-quote, see below). True by default. NOTE-1: If you know that your CSV file does NOT include multi-line fields, turn this option to false (or 0) to allow handling of larger files and improve performance (RegEx experts, help needed! See the function code for details). NOTE-2: If blnMultiline is True, you can use the strEolReplacement parameter to specify a character (or string) that will be converted to line-breaks if found in the CSV file.
		intProgressType - (Optional) If 1, a progress bar is displayed. If -1, -2 or -n, the part "n" of the status bar is updated with the progress in percentage. See also strProgressText below. By default, no progress bar or status (0).
		strFieldDelimiter - (Optional) Field delimiter in the CSV file. One character, usually comma (default value) or tab. According to locale setting of software (e.g. MS Office) or user preferences, delimiter can be semi-colon (;), pipe (|), space, etc. NOTE-1: End-of-line characters (`n or `r) are prohibited as field separator since they are used as record delimiters. NOTE-2: Using the Trim function, %A_Space% and %A_Tab% (when tab is not a delimiter) are removed from the beginning and end of all field names (but not of data since v0.5.6).
		strEncapsulator - (Optional) Character (usualy double-quote) used in the CSV file to embed fields that include at least one of these special characters: line-breaks, field delimiters or the encapsulator character itself. In this last case, the encapsulator character must be doubled in the string. For example: "one ""quoted"" word". All fields and headers in the CSV file can be encapsulated, if desired by the file creator. Double-quote by default.
		strEolReplacement - (Optional) Character (or string) that will be converted to line-breaks if found in the CSV file. Replacements occur only when blnMultiline is True. Empty by default.
		strProgressText - (Optional) Text to display in the progress bar or in the status bar. For status bar progress, the string "##" is replaced with the percentage of progress. See also intProgressType above. Empty by default.
		strFileEncoding - (ByRef, Optional) File encoding: ANSI, UTF-8, UTF-16, UTF-8-RAW, UTF-16-RAW or CPnnnn (nnnn being a code page numeric identifier - see [https://autohotkey.com/docs/commands/FileEncoding.htm](https://autohotkey.com/docs/commands/FileEncoding.htm). Empty by default (using current encoding). If a literal value or a filled variable is passed as parameter, this value is used to set reading encoding. If an empty variable is passed to the ByRef parameter, the detected file encoding is returned in the ByRef variable.

	Returns:
		This functions returns an object that contains an array of objects. This collection of objects can be viewed as a table in a database. Each object in the collection is like a record (or a line) in a table. These records are, in fact, associative arrays which contain a list key-value pairs. Key names are like field names (or column names) in the table. Key names are taken in the header of the CSV file, if it exists. Keys can be strings or integers, while values can be of any type that can be expressed as text. The records can be read using the syntax obj[1], obj[2] (...). Field values can be read using the syntax obj[1].keyname or, when field names contain spaces, obj[1]["key name"]. The "Loop, Parse" and "For key, value in array" commands allow to easily browse the content of these objects.
		
		If blnHeader is true (or 1), the ByRef parameter strFieldNames returns a string containing the field names (object keys) read from the first line of the CSV file, in the format and in the order they appear in the file. If a field name is empty, it is replaced with "Empty_" and its field number.  If a field name is duplicated, the field number is added to the duplicate name.  If blnHeader is false (or 0), the value of strFieldNames is unchanged by the function except if strFieldNames is empty. In this case, strFieldNames will return the "C" field names created by this function.
		
		If an empty variable is passed to the ByRef parameter strFileEncoding, returns the detected file encoding.

		At the end of execution, the function sets ErrorLevel to: 0 No error / 1 Out of memory / 2 Memory limit / 3 No unused character for replacement (returned by sub-function Prepare4Multilines) / 255 Unknown error. If the function produces an "Memory limit reached" error, increase the #MaxMem value (see the help file).
*/
{
	objCollection := Object() ; object that will be returned by the function (a collection or array of objects)
	objHeader := Object() ; holds the keys (fields name) of the objects in the collection
	if !StrLen(strFileEncoding) and IsByRef(strFileEncoding) ; an empty variable was passed to strFileEncoding, detect the encoding
	{
		objFile := FileOpen(strFilePath, "r") ; open the file read-only
		strFileEncoding := (InStr(objFile.Encoding, "UTF-") ? objFile.Encoding : "")
		objFile.Close()
		objFile := ""
	}
	strPreviousFileEncoding := A_FileEncoding
	FileEncoding, % (strFileEncoding = "ANSI" ? "" : strFileEncoding) ; empty string to encode ANSI
	try
		FileRead, strData, %strFilePath% ; FileRead ignores #MaxMem and just reads the whole file into a variable
	catch e
	{
		if InStr(e.message, "Out of memory")
			ErrorLevel := 1 ; Out of memory
		else
			ErrorLevel := 255 ; Unknown error
		if (intProgressType)
			ProgressStop(intProgressType)
		FileEncoding, %strPreviousFileEncoding%
		return
	}
	FileEncoding, %strPreviousFileEncoding%
	if blnMultiline
	{
		chrEolReplacement := Prepare4Multilines(strData, strEncapsulator, intProgressType, strProgressText . " (1/2)")
			; replace `n (but keep the `r) to make sure each record temporarily stands on a single line *** not tested on Unix files
		if (ErrorLevel)
		{
			if (intProgressType)
				ProgressStop(intProgressType)
			return
		}
	}
	strData := Trim(strData, "`r`n")
		; remove empty line (record) at the beginning or end of the string, if present *** not tested on Unix files
	if (intProgressType)
	{
		intMaxProgress := StrLen(strData)
		intProgressBatchSize := ProgressBatchSize(intMaxProgress)
		intProgressIndex := 0
		intProgressThisBatch := 0
		if blnMultiline
			strProgressText := strProgressText . " (2/2)"
		ProgressStart(intProgressType, intMaxProgress, strProgressText)
	}
	Loop, Parse, strData, `n, `r ; read each line (record) of the CSV file
	{
		; StringReplace, strThisLine, A_LoopField, % "=" . strEncapsulator, %strEncapsulator%, All ; reverse edit from v0.4.1 (see git for details)
		intProgressIndex := intProgressIndex + StrLen(A_LoopField) + 2
		intProgressThisBatch := intProgressThisBatch + StrLen(A_LoopField) + 2
			; augment intProgressIndex of len of line + 2 for cr-lf
		if (intProgressType AND (intProgressThisBatch > intProgressBatchSize))
		{
			ProgressUpdate(intProgressType, intProgressIndex, intMaxProgress, strProgressText)
				; update progress bar only every %intProgressBatchSize% records
			intProgressThisBatch := 0
		}
		if (A_Index = 1) and (blnHeader) ; we have an header to read
		{
			objHeader := ObjCSV_ReturnDSVObjectArray(A_LoopField, strFieldDelimiter, strEncapsulator)
				; returns an object array from the first line of the delimited-separated-value file
			strFieldNamesMatchList := strFieldDelimiter
			Loop, % objHeader.MaxIndex() ; check if fields names are empty or duplicated
			{
				if !StrLen(objHeader[A_Index]) ; field name is empty
					objHeader[A_Index] := "Empty_" . A_Index ; use field number as field name
				else
					if InStr(strFieldNamesMatchList, strFieldDelimiter . objHeader[A_Index] . strFieldDelimiter)
						; field name is duplicate
						objHeader[A_Index] := objHeader[A_Index] . "_" . A_Index ; add field number to field name
				strFieldNamesMatchList := strFieldNamesMatchList . objHeader[A_Index] . strFieldDelimiter
			}
			strFieldNames := ""
			for intIndex, strFieldName in objHeader ; returns the updated field names to the ByRef parameter
				strFieldNames := strFieldNames . ObjCSV_Format4CSV(strFieldName, strFieldDelimiter, strEncapsulator)
					. strFieldDelimiter
			StringTrimRight, strFieldNames, strFieldNames, 1 ; remove extra field delimiter
			if !(objHeader.MaxIndex()) ; we don't have an object, something went wrong
			{
				if (intProgressType)
					ProgressStop(intProgressType)
				ErrorLevel := 255 ; Unknown error
				return ; returns no object
			}
		}
		else
		{
			if (A_Index = 1)
			{
				; If we get here, bnHeader is false so there is no header in the CSV file
				if !StrLen(strFieldNames)
					; We must build the header
				{
					for intIndex, strFieldData in ObjCSV_ReturnDSVObjectArray(A_LoopField, strFieldDelimiter, strEncapsulator, false)
						strFieldNames := strFieldNames . (StrLen(strFieldNames) ? strFieldDelimiter : "") . "C" . A_Index
							; build strFieldNames to use as header and to return to caller
					objHeader := ObjCSV_ReturnDSVObjectArray(strFieldNames, strFieldDelimiter, strEncapsulator)
				}
				; We have values in strFieldNames. Get field names from strFieldNames.
				objHeader := ObjCSV_ReturnDSVObjectArray(strFieldNames, strFieldDelimiter, strEncapsulator)
					; returns an object array from the delimited-separated-value strFieldNames string
			}
			objData := Object() ; object of one record in the collection
			for intIndex, strFieldData in ObjCSV_ReturnDSVObjectArray(A_LoopField, strFieldDelimiter, strEncapsulator, false)
				; returns an object array from each line of the delimited-separated-value file
			{
				if blnMultiline
				{
					StringReplace, strFieldData, strFieldData, %chrEolReplacement%, `n, 1
						; put back all original `n in each field, if present
					StringReplace, strFieldData, strFieldData, %strEolReplacement%, `r`n, 1
						; replace all user-supplied replacement character with end-of-line (`r`n), if present *** not tested on Unix files
				}
				objData[objHeader[A_Index]] := strFieldData ; we always have field names in objHeader[A_Index]
			}
			objCollection.Insert(objData) ; add the object (record) to the collection
		}
	}
	if (intProgressType)
		ProgressStop(intProgressType)
	objHeader := ; release object
	ErrorLevel := 0
	return objCollection
}
;================================================



;================================================
ObjCSV_Collection2CSV(objCollection, strFilePath, blnHeader := 0, strFieldOrder := "", intProgressType := 0
	, blnOverwrite := 0, strFieldDelimiter := ",", strEncapsulator := """", strEolReplacement := ""
	, strProgressText := "", strFileEncoding := "", blnAlwaysEncapsulate := 0, strEol := "")
/*!
	Function: ObjCSV_Collection2CSV(objCollection, strFilePath [, blnHeader = 0, strFieldOrder = "", intProgressType = 0, blnOverwrite = 0, strFieldDelimiter = ",", strEncapsulator = """", strEolReplacement = "", strProgressText = "", strFileEncoding := "", blnAlwaysEncapsulate] := 0, strEol := "")
		Transfer the selected fields from a collection of objects to a CSV file. Field names taken from key names are optionally included in the CSV file. Delimiters are configurable.

	Parameters:
		objCollection - Object containing an array of objects (or collection). Objects in the collection are associative arrays which contain a list key-value pairs. See ObjCSV_CSV2Collection returned value for details.
		strFilePath - The name of the CSV file, which is assumed to be in %A_WorkingDir% if an absolute path isn't specified.
		blnHeader - (Optional) If true, the key names in the collection objects are inserted as header of the CSV file. Fields names are delimited by the strFieldDelimiter character.
		strFieldOrder - (Optional) List of field to include in the CSV file and the order of these fields in the file. Fields names must be separated by the strFieldDelimiter character and, if required, encapsulated by the strEncapsulator character. If empty, all fields are included. Empty by default.
		intProgressType - (Optional) If 1, a progress bar is displayed. If -1, -2 or -n, the part "n" of the status bar is updated with the progress in percentage. See also strProgressText below. By default, no progress bar or status (0).
		blnOverwrite - (Optional) If true (or 1), overwrite existing files. If false (or 0), content is appended to the existing file. False (or 0) by default. NOTE: If content is appended to an existing file, fields names and order should be the same as in the existing file.
		strFieldDelimiter - (Optional) Delimiter inserted between fields in the CSV file. Also used as delimiter in the above parameter strFieldOrder. One character, usually comma, tab or semi-colon. You can choose other delimiters like pipe (|), space, etc. Comma by default. NOTE: End-of-line characters (`n or `r) are prohibited as field separator since they are used as record delimiters.
		strEncapsulator - (Optional) One character (usualy double-quote) inserted in the CSV file to embed fields that include at least one of these special characters: line-breaks, field delimiters or the encapsulator character itself. In this last case, the encapsulator character is doubled in the string. For example: "one ""quoted"" word". Double-quote by default.
		strEolReplacement - (Optional) When empty, multi-line fields are saved unchanged. If not empty, end-of-line in multi-line fields are replaced by the character or string strEolReplacement. Empty by default. NOTE: Strings including replaced end-of-line will still be encapsulated with the strEncapsulator character.
		strProgressText - (Optional) Text to display in the progress bar or in the status bar. For status bar progress, the string "##" is replaced with the percentage of progress. See also intProgressType above. Empty by default.
		strFileEncoding - (Optional) File encoding: ANSI, UTF-8, UTF-16, UTF-8-RAW, UTF-16-RAW or CPnnnn (a code page with numeric identifier nnn - see [https://autohotkey.com/docs/commands/FileEncoding.htm](https://autohotkey.com/docs/commands/FileEncoding.htm)). Empty by default (system default ANSI code page).
		blnAlwaysEncapsulate - (Optional) If true (or 1), always encapsulate values with field encapsulator. If false (or 0), fields are encapsulated only if required (see strEncapsulator above). False (or 0) by default.
		strEol - (Optional) If strEolReplacement is used, character(s) that mark end-of-lines in multi-line fields. Use "`r`n" (carriage-return + line-feed, ASCII 13 & 10), "`n" (line-feed, ASCII 10) or "`r" (carriage-return, ASCII 13). If the parameter is empty, the content is searched to detect the first end-of-lines character(s) detected in the string (in the order "`r`n", "`n", "`r"). The first end-of-lines character(s) found is used for remaining fields and records. Empty by default.

	Returns:
		At the end of execution, the function sets ErrorLevel to: 0 No error / 1 File system error. For system errors, check A_LastError and google "windows system error codes".
*/
{
	strData := ""
	intMax := objCollection.MaxIndex()
	if (intProgressType)
	{
		intProgressBatchSize := ProgressBatchSize(intMax)
		ProgressStart(intProgressType, intMax, strProgressText)
	}
	if (blnHeader) ; put the field names (header) in the first line of the CSV file
	{
		if !StrLen(strFieldOrder)
			; we don't have a header, so we take field names from the first record of objCollection,
			; in their natural order 
		{
			for strFieldName, strValue in objCollection[1]
				strFieldOrder := strFieldOrder . ObjCSV_Format4CSV(strFieldName, strFieldDelimiter, strEncapsulator, blnAlwaysEncapsulate)
					. strFieldDelimiter
			StringTrimRight, strFieldOrder, strFieldOrder, 1 ; remove extra field delimiter
		}
		strData := strFieldOrder . "`r`n" ; put this header as first line of the file
	}
	if (blnOverwrite)
		FileDelete, %strFilePath%
	if StrLen(strFieldOrder) ; we put only these fields, in this order
		objHeader := ObjCSV_ReturnDSVObjectArray(strFieldOrder, strFieldDelimiter, strEncapsulator)
			; parse strFieldOrder handling encapsulated field names
	Loop, %intMax% ; for each record in the collection
	{
		strRecord := "" ; line to add to the CSV file
		if !Mod(A_Index, intProgressBatchSize) ; update progress bar and save every %intProgressBatchSize% records
		{
			if (intProgressType)
				ProgressUpdate(intProgressType, A_index, intMax, strProgressText)
			If !SaveBatch(strData, strFilePath, intProgressType, strFileEncoding)
				return
			strData := ""
		}
		if StrLen(strFieldOrder) ; we put only these fields, in this order
		{
			intLineNumber := A_Index
			for intColIndex, strFieldName in objHeader
			{
				strValue := CheckEolReplacement(objCollection[intLineNumber][Trim(strFieldName)], strEolReplacement, strEol)
				strRecord := strRecord . ObjCSV_Format4CSV(strValue, strFieldDelimiter, strEncapsulator, blnAlwaysEncapsulate) . strFieldDelimiter
			}
		}
		else ; we put all fields in the record (I assume the order of fields is the same for each object)
			for strFieldName, strValue in objCollection[A_Index]
			{
				strValue := ObjCSV_Format4CSV(strValue, strFieldDelimiter, strEncapsulator, blnAlwaysEncapsulate)
				strValue := CheckEolReplacement(strValue, strEolReplacement, strEol)
				strRecord := strRecord . ObjCSV_Format4CSV(strValue, strFieldDelimiter, strEncapsulator, blnAlwaysEncapsulate) . strFieldDelimiter
			}
		StringTrimRight, strRecord, strRecord, 1 ; remove extra field delimiter
		strData := strData . strRecord . "`r`n"
	}
	If !SaveBatch(strData, strFilePath, intProgressType, strFileEncoding)
		return
	if (intProgressType)
		ProgressStop(intProgressType)
	return
}
;================================================



;================================================
ObjCSV_Collection2Fixed(objCollection, strFilePath, strWidth, blnHeader := 0, strFieldOrder := "", intProgressType := 0
	, blnOverwrite := 0, strFieldDelimiter := ",", strEncapsulator := """", strEolReplacement := ""
	, strProgressText := "", strFileEncoding := "", strEol := "")
/*!
	Function: ObjCSV_Collection2Fixed(objCollection, strFilePath, strWidth [, blnHeader = 0, strFieldOrder = "", intProgressType = 0, blnOverwrite = 0, strFieldDelimiter = ",", strEncapsulator = """", strEolReplacement = "", strProgressText = "", strFileEncoding := "", strEol := ""])
		Transfer the selected fields from a collection of objects to a fixed-width file. Field names taken from key names are optionnaly included the file. Width are determined by the delimited string strWidth. Field names and data fields shorter than their width are padded with trailing spaces. Field names and data fields longer than their width are truncated at their maximal width.

	Parameters:
		objCollection - Object containing an array of objects (or collection). Objects in the collection are associative arrays which contain a list key-value pairs. See ObjCSV_CSV2Collection returned value for details.
		strFilePath - The name of the fixed-width destination file, which is assumed to be in %A_WorkingDir% if an absolute path isn't specified.
		strWidth - Width for each field. Each numeric values must be in the same order as strFieldOrder and separated by the strFieldDelimiter character.
		blnHeader - (Optional) If true, the field names in the collection objects are inserted as header of the file, padded or truncated according to each field's width. NOTE: If field names are longer than their fixed-width they will be truncated as well.
		strFieldOrder - (Optional) List of field to include in the file and the order of these fields in the file. Fields names must be separated by the strFieldDelimiter character and, if required, encapsulated by the strEncapsulator character. If empty, all fields are included. Empty by default.
		intProgressType - (Optional) If 1, a progress bar is displayed. If -1, -2 or -n, the part "n" of the status bar is updated with the progress in percentage. See also strProgressText below. By default, no progress bar or status (0).
		blnOverwrite - (Optional) If true (or 1), overwrite existing files. If false (or 0), content is appended to the existing file. False (or 0) by default. NOTE: If content is appended to an existing file, fields names and order should be the same as in the existing file.
		strFieldDelimiter - (Optional) Delimiter inserted between fields names in the strFieldOrder parameter and fields width in the strWidth parameter. This delimiter is NOT used in the file data. One character, usually comma, tab or semi-colon. You can choose other delimiters like pipe (|), space, etc. Comma by default. NOTE: End-of-line characters (`n or `r) are prohibited as field separator since they are used as record delimiters.
		strEncapsulator - (Optional) One character (usualy double-quote) inserted in the strFieldOrder parameter to embed field names that include at least one of these special characters: line-breaks, field delimiters or the encapsulator character itself. In this last case, the encapsulator character is doubled in the string. For example: "one ""quoted"" word". Double-quote by default. This delimiter is NOT used in the file data.
		strEolReplacement - (Optional) A fixed-width file should not include end-of-line within data. If it does and if a strEolReplacement is provided, end-of-line in multi-line fields are replaced by the string strEolReplacement and this (or these) characters are included in the fixed-width character count. Empty by default.
		strProgressText - (Optional) Text to display in the progress bar or in the status bar. For status bar progress, the string "##" is replaced with the percentage of progress. See also intProgressType above. Empty by default.
		strFileEncoding - (Optional) File encoding: ANSI, UTF-8, UTF-16, UTF-8-RAW, UTF-16-RAW or CPnnnn (a code page with numeric identifier nnn - see [https://autohotkey.com/docs/commands/FileEncoding.htm](https://autohotkey.com/docs/commands/FileEncoding.htm)). Empty by default (system default ANSI code page).
		strEol - (Optional) If strEolReplacement is used, character(s) that mark end-of-lines in multi-line fields. Use "`r`n" (carriage-return + line-feed, ASCII 13 & 10), "`n" (line-feed, ASCII 10) or "`r" (carriage-return, ASCII 13). If the parameter is empty, the content is searched to detect the first end-of-lines character(s) detected in the string (in the order "`r`n", "`n", "`r"). The first end-of-lines character(s) found is used for remaining fields and records. Empty by default.
	Returns:
		At the end of execution, the function sets ErrorLevel to: 0 No error / 1 File system error. For system errors, check A_LastError and google "windows system error codes".
*/
{
	StringSplit, arrIntWidth, strWidth, %strFieldDelimiter%
		; get width for each field in the pseudo-array arrIntWidth, so %arrIntWidth1% or arrIntWidth%intColIndex%
	strData := "" ; string to save in the fixed-width file
	intMax := objCollection.MaxIndex()
	if (intProgressType)
	{
		intProgressBatchSize := ProgressBatchSize(intMax)
		ProgressStart(intProgressType, intMax, strProgressText)
	}
	if (blnHeader) ; put the field names (header) in the first line of the file
	{
		strHeaderFixed := ""
		if StrLen(strFieldOrder) ; convert DSV string to fixed-width
		{
			for intColIndex, strFieldName in ObjCSV_ReturnDSVObjectArray(strFieldOrder, strFieldDelimiter, strEncapsulator)
				; parse strFieldOrder handling encapsulated field names
				strHeaderFixed := strHeaderFixed . MakeFixedWidth(strFieldName, arrIntWidth%intColIndex%)
					; add fixed-width field name for each column
		}
		else
			; we dont have a header, so we take field names from the first record of objCollection,
			; in their natural order
		{
			intColIndex := 1
			for strFieldName, strValue in objCollection[1]
			{
				strHeaderFixed := strHeaderFixed . MakeFixedWidth(strFieldName, arrIntWidth%intColIndex%)
					; add fixed-width field name for each column
				intColIndex := intColIndex + 1
			}
		}
		strData := strHeaderFixed . "`r`n" ; put this header as first line of the file
	}
	if (blnOverwrite)
		FileDelete, %strFilePath%
	Loop, %intMax% ; for each record in the collection
	{
		strRecord := "" ; line to add to the file
		if !Mod(A_Index, intProgressBatchSize) ; update progress bar and save every %intProgressBatchSize% records
		{
			if (intProgressType)
				ProgressUpdate(intProgressType, A_index, intMax, strProgressText)
			If !SaveBatch(strData, strFilePath, intProgressType, strFileEncoding)
				return
			strData := ""
		}
		if StrLen(strFieldOrder) ; we put only these fields, in this order
		{
			intLineNumber := A_Index
			for intColIndex, strFieldName in ObjCSV_ReturnDSVObjectArray(strFieldOrder, strFieldDelimiter, strEncapsulator)
				; parse strFieldOrder handling encapsulated field names
			{
				strValue := CheckEolReplacement(objCollection[intLineNumber][Trim(strFieldName)], strEolReplacement, strEol)
				strRecord := strRecord . MakeFixedWidth(strValue, arrIntWidth%intColIndex%)
					; add fixed-width data field for each column
			}
		}
		else ; we put all fields in the record (I assume the order of fields is the same for each object)
		{
			intColIndex := 1
			for strFieldName, strValue in objCollection[A_Index]
			{
				strValue := CheckEolReplacement(strValue, strEolReplacement, strEol)
				strRecord := strRecord . MakeFixedWidth(strValue, arrIntWidth%intColIndex%)
					; add fixed-width data field for each column
				intColIndex := intColIndex + 1
			}
		}
		strData := strData . strRecord . "`r`n" ; add record to the file
	}
	If !SaveBatch(strData, strFilePath, intProgressType, strFileEncoding)
		return
	if (intProgressType)
		ProgressStop(intProgressType)
	return
}
;================================================



;================================================
ObjCSV_Collection2HTML(objCollection, strFilePath, strTemplateFile, strTemplateEncapsulator := "~", intProgressType := 0
	, blnOverwrite := 0, strProgressText := "", strFileEncoding := "")
/*!
	Function: ObjCSV_Collection2HTML(objCollection, strFilePath, strTemplateFile [, strTemplateEncapsulator = ~, intProgressType = 0, blnOverwrite = 0, strProgressText = "", strFileEncoding := ""])
		Builds an HTML file based on a template file where variable names are replaced with the content in each record of the collection.

	Parameters:
		objCollection - Object containing an array of objects (or collection). Objects in the collection are associative arrays which contain a list key-value pairs. See ObjCSV_CSV2Collection returned value for details.
		strFilePath - The name of the HTML file, which is assumed to be in %A_WorkingDir% if an absolute path isn't specified. This path and name of the file can be inserted in the HTML template as described below.
		strTemplateFile - The name of the HTML template file used to create the HTML file, which is assumed to be in %A_WorkingDir% if an absolute path isn't specified. In the template, markups and variables are encapsulated by the strTemplateEncapsulator parameter (single charater of your choice). Markups and variables are not case sensitive unless StringCaseSense has been turned on. The template is divided in three sections: the header template (from the start of the file to the start of the row template), the row template (delimited by the markups ROWS and /ROWS) and the footer template (from the end of the row template to the end of the file). The row template is repeated in the output file for each record in the collection. Field names encapsulated by the strTemplateEncapsulator parameter are replaced by the matching data in each record.  Additionally, in the header and footer, the following variables encapsulated by the strTemplateEncapsulator are replaced by parts of the strFilePath parameter: FILENAME (file name without its path, but including its extension), DIR (drive letter or share name, if present, and directory of the file, final backslash excluded), EXTENSION (file's extension, dot excluded), NAMENOEXT (file name without its path, dot and extension) and DRIVE (drive letter or server name, if present). Finally, in the row template, ROWNUMBER is replaced by the current row number. This simple example, where each record has two fields named "Field1" and "Field2" and the strTemplateEncapsulator is ~ (tilde), shows the use of the various markups and variables:
			> <HEAD>
			>   <TITLE>~NAMENOEXT~</TITLE>
			> </HEAD>
			> <BODY>
			>   <H1>~FILENAME~</H1>
			>   <TABLE>
			>     <TR>
			>       <TH>Row #</TH><TH>Field One</TH><TH>Field Two</TH>
			>     </TR>
			> ~ROWS~
			>     <TR>
			>       <TD>~ROWNUMBER~</TD><TD>~Field1~</TD><TD>~Field2~</TD>
			>     </TR>
			> ~/ROWS~
			>   </TABLE>
			>   Source: ~DIR~\~FILENAME~
			> </BODY>
		strTemplateEncapsulator - (Optional) One character used to encapsulate markups and variable names in the template. By default ~ (tilde).
		intProgressType - (Optional) If 1, a progress bar is displayed. If -1, -2 or -n, the part "n" of the status bar is updated with the progress in percentage. See also strProgressText below. By default, no progress bar or status (0).
		blnOverwrite - (Optional) If true (or 1), overwrite existing files. If false (or 0) and the output file exists, the function ends without writing the output file. False (or 0) by default.
		strProgressText - (Optional) Text to display in the progress bar or in the status bar. For status bar progress, the string "##" is replaced with the percentage of progress. See also intProgressType above. Empty by default.
		strFileEncoding - (Optional) File encoding: ANSI, UTF-8, UTF-16, UTF-8-RAW, UTF-16-RAW or CPnnnn (a code page with numeric identifier nnn - see [https://autohotkey.com/docs/commands/FileEncoding.htm](https://autohotkey.com/docs/commands/FileEncoding.htm)). Empty by default (system default ANSI code page).

	Returns:
		At the end of execution, the function sets ErrorLevel to: 0 No error / 1 File system error / 2 No HTML template / 3 Invalid encapsulator / 4 No ~ROWS~ start delimiter / 5 No ~/ROWS~ end delimiter / 6 File exists and should not be overwritten. For system errors, check A_LastError and google "windows system error codes".
*/
{
	if (FileExist(strFilePath) and !blnOverwrite)
		ErrorLevel := 6 ; File exists and should not be overwritten
	if !FileExist(strTemplateFile)
		ErrorLevel := 2 ; No HTML template
	if StrLen(strTemplateEncapsulator) <> 1
		ErrorLevel := 3 ; Invalid encapsulator
	if (ErrorLevel)
		return
	strPreviousFileEncoding := A_FileEncoding
	FileEncoding, % (strFileEncoding = "ANSI" ? "" : strFileEncoding) ; empty string to encode ANSI
	FileRead, strTemplate, %strTemplateFile%
	FileEncoding, %strPreviousFileEncoding%
	intPos := InStr(strTemplate, strTemplateEncapsulator . "ROWS" . strTemplateEncapsulator)
		; start of the row template
	if (intPos = 0)
		ErrorLevel := 4 ; No ~ROWS~ start delimiter
	strTemplateHeader :=  SubStr(strTemplate, 1, intPos - 1) ; extract header
	strTemplate :=  SubStr(strTemplate, intPos + 6) ; remove header template from template string
	intPos := InStr(strTemplate, strTemplateEncapsulator . "/ROWS" . strTemplateEncapsulator)
		; end of the row template
	if (intPos = 0)
		ErrorLevel := 5 ; No ~/ROWS~ end delimiter
	if (ErrorLevel)
		return
	strTemplateRow :=  SubStr(strTemplate, 1, intPos - 1) ; extract row template
	strTemplate :=  SubStr(strTemplate, intPos + 7) ; remove row template from template string
	strTemplateFooter := strTemplate ; remaining of the template string is the footer template
	strData := MakeHTMLHeaderFooter(strTemplateHeader, strFilePath, strTemplateEncapsulator)
		; replace variables in the header template and initialize the HTML data string
	intMax := objCollection.MaxIndex()
	if (intProgressType)
	{
		intProgressBatchSize := ProgressBatchSize(intMax)
		ProgressStart(intProgressType, intMax, strProgressText)
	}
	if (blnOverwrite)
		FileDelete, %strFilePath% ; delete existing file if present, no error if missing
	Loop, %intMax% ; for each record in the collection
	{
		if !Mod(A_Index, intProgressBatchSize) ; update progress bar and save every %intProgressBatchSize% records
		{
			if (intProgressType)
				ProgressUpdate(intProgressType, A_index, intMax, strProgressText)
			If !SaveBatch(strData, strFilePath, intProgressType, strFileEncoding)
				return
			strData := ""
		}
		strData := strData . MakeHTMLRow(strTemplateRow, objCollection[A_Index], A_Index, strTemplateEncapsulator) 
			. "`r`n" ; replace variables in the row template and append to the HTML data string
	}
	strData := strData . MakeHTMLHeaderFooter(strTemplateFooter, strFilePath, strTemplateEncapsulator)
		; replace variables in the footer template and append to the HTML data string
	If !SaveBatch(strData, strFilePath, intProgressType, strFileEncoding)
		return
	if (intProgressType)
		ProgressStop(intProgressType)
	ErrorLevel := 0
	return
}
;================================================



;================================================
ObjCSV_Collection2XML(objCollection, strFilePath, intProgressType := 0, blnOverwrite := 0, strProgressText := "", strFileEncoding := "")
/*!
	Function: ObjCSV_Collection2XML(objCollection, strFilePath [, intProgressType = 0, blnOverwrite = 0, strProgressText = "", strFileEncoding := ""])
		Builds an XML file from the content of the collection. The calling script must ensure that field names and field data comply with the rules of XML syntax. This simple example, where each record has two fields named "Field1" and "Field2", shows the XML output format:
			> <?xml version='1.0'?>
			> <XMLExport>
			>   <Record>
			>     <Field1>Value Row 1 Col 1</Field1>
			>     <Field2>Value Row 1 Col 2</Field1>
			>   </Record>
			>   <Record>
			>     <Field1>Value Row 2 Col 1</Field1>
			>     <Field2>Value Row 2 Col 2</Field1>
			>   </Record>
			> </XMLExport>

	Parameters:
		objCollection - Object containing an array of objects (or collection). Objects in the collection are associative arrays which contain a list key-value pairs. See ObjCSV_CSV2Collection returned value for details.
		strFilePath - The name of the XML file, which is assumed to be in %A_WorkingDir% if an absolute path isn't specified.
		intProgressType - (Optional) If 1, a progress bar is displayed. If -1, -2 or -n, the part "n" of the status bar is updated with the progress in percentage. See also strProgressText below. By default, no progress bar or status (0).
		blnOverwrite - (Optional) If true (or 1), overwrite existing files. If false (or 0) and the output file exists, the function ends without writing the output file. False (or 0) by default.
		strProgressText - (Optional) Text to display in the progress bar or in the status bar. For status bar progress, the string "##" is replaced with the percentage of progress. See also intProgressType above. Empty by default.
		strFileEncoding - (Optional) File encoding: ANSI, UTF-8, UTF-16, UTF-8-RAW, UTF-16-RAW or CPnnnn (a code page with numeric identifier nnn - see [https://autohotkey.com/docs/commands/FileEncoding.htm](https://autohotkey.com/docs/commands/FileEncoding.htm)). Empty by default (system default ANSI code page).

	Returns:
		At the end of execution, the function sets ErrorLevel to: 0 No error / 1 File system error / 2 File exists and should not be overwritten. For system errors, check A_LastError and google "windows system error codes".
*/
{
	if (FileExist(strFilePath) and !blnOverwrite)
	{
		if (intProgressType)
			ProgressStop(intProgressType)
		ErrorLevel := 2 ; File exists and should not be overwritten
		return
	}
	strData := "<?xml version='1.0'?>`r`n<XMLExport>`r`n"
		; initialize the XML data string with XML header
	intMax := objCollection.MaxIndex()
	if (intProgressType)
	{
		intProgressBatchSize := ProgressBatchSize(intMax)
		ProgressStart(intProgressType, intMax, strProgressText)
	}
	if (blnOverwrite)
		FileDelete, %strFilePath% ; delete existing file if present, no error if missing
	Loop, %intMax% ; for each record in the collection
	{
		if !Mod(A_Index, intProgressBatchSize) ; update progress bar and save every %intProgressBatchSize% records
		{
			if (intProgressType)
				ProgressUpdate(intProgressType, A_index, intMax, strProgressText)
			If !SaveBatch(strData, strFilePath, intProgressType, strFileEncoding)
				return
			strData := ""
		}
		strData := strData . MakeXMLRow(objCollection[A_Index])
			; append XML for this row to the XML data string
	}
	strData := strData . "</XMLExport>`r`n" ; append XML footer to the XML data string
	If !SaveBatch(strData, strFilePath, intProgressType, strFileEncoding)
		return
	if (intProgressType)
		ProgressStop(intProgressType)
	ErrorLevel := 0
	return
}
;================================================



;================================================
ObjCSV_Collection2ListView(objCollection, strGuiID := "", strListViewID := "", strFieldOrder := ""
	, strFieldDelimiter := ",", strEncapsulator := """", strSortFields := "", strSortOptions := ""
	, intProgressType := 0, strProgressText := "")
/*!
	Function: ObjCSV_Collection2ListView(objCollection [, strGuiID = "", strListViewID = "", strFieldOrder = "", strFieldDelimiter = ",", strEncapsulator = """", strSortFields = "", strSortOptions = "", intProgressType = 0, strProgressText = ""])
		Transfer the selected fields from a collection of objects to ListView. The collection can be sorted by the function. Field names taken from the objects keys are used as header for the ListView. NOTE-1: Due to an AHK limitation, files with more that 200 fields will not be transfered to a ListView. NOTE-2: Although up to 8191 characters of text can be stored in each cell of a ListView, only the first 260 characters are displayed (no lost data under 8192 characters).

	Parameters:
		objCollection - Object containing an array of objects (or collection). Objects in the collection are associative arrays which contain a list key-value pairs. See ObjCSV_CSV2Collection returned value for details. NOTE: Multi-line fields can be inserted in a ListView and retreived from a ListView. However, take note that end-of-lines will not be visible in cells with current version of AHK_L (v1.1.09.03).
		strGuiID - (Optional) Name of the Gui that contains the ListView where the collection will be displayed. If empty, the last default Gui is used. Empty by default. NOTE: If a Gui name is provided, this Gui will remain the default Gui at the termination of the function.
		strListViewID - (Optional) Name of the target ListView where the collection will be displayed. If empty, the last default ListView is used. The target ListView should be empty or should contain data in the same columns number and order than the data to display. If this is not respected, new columns will be added to the right of existing columns and new rows will be added at the bottom of existing data. Empty by default. NOTE-1: Performance is greatly improved if we provide the ListView ID because we avoid redraw during import. NOTE-2: If a ListView name is provided, this ListView will remain the default at the termination of the function.
		strFieldOrder - (Optional) List of field to include in the ListView and the order of these columns. Fields names must be separated by the strFieldDelimiter character. If empty, all fields are included. Empty by default.
		strFieldDelimiter - (Optional) Delimiter of the fields in the strFieldOrder parameter. One character, usually comma, but can also be tab, semi-colon, pipe (|), space, etc. Comma by default.
		strEncapsulator - (Optional) One character (usualy double-quote) possibly used in the in the strFieldOrder string to embed fields that would include special characters (as described above).
		strSortFields - (Optional) Field(s) value(s) used to sort the collection before its insertion in the ListView. To sort on more than one field, concatenate field names with the + character (e.g. "LastName+FirstName"). Faster sort can be obtained by manualy clicking on columns headers in the ListView after the collection has been inserted. Empty by default.
		strSortOptions - (Optional) Sorting options to apply to the sort command above. A string of zero or more of the option letters (in any order, with optional spaces in between). Most frequently used are R (reverse order) and N (numeric sort). All AHK_L sort options are supported. See [http://l.autohotkey.net/docs/commands/Sort.htm](http://l.autohotkey.net/docs/commands/Sort.htm) for more options. Empty by default.
		intProgressType - (Optional) If 1, a progress bar is displayed. If -1, -2 or -n, the part "n" of the status bar is updated with the progress in percentage. See also strProgressText below. By default, no progress bar or status (0).
		strProgressText - (Optional) Text to display in the progress bar or in the status bar. For status bar progress, the string "##" is replaced with the percentage of progress. See also intProgressType above. Empty by default.

	Returns:
		At the end of execution, the function sets ErrorLevel to: 0 No error / 1 More than 200 columns.
*/
{
	objHeader := Object() ; holds the keys (fields name) of the objects in the collection
	if StrLen(strSortFields)
	{
		objCollection := ObjCSV_SortCollection(objCollection, strSortFields, strSortOptions, intProgressType
			, strProgressText . " (1/2)")
		strProgressText := strProgressText . " (2/2)"
	}
	intMax := objCollection.MaxIndex()
	if (intProgressType)
	{
		intProgressBatchSize := ProgressBatchSize(intMax)
		ProgressStart(intProgressType, intMax, strProgressText)
	}
	if StrLen(strGuiID)
		Gui, %strGuiID%:Default
	if StrLen(strListViewID)
		GuiControl, -Redraw, %strListViewID% ; stop drawing the ListView during import
	if StrLen(strListViewID)
		Gui, ListView, %strListViewID% ; sets the default ListView in the default Gui
	if !StrLen(strFieldOrder)
		; if we dont have fields restriction or order, take all fields in their natural order in the first records
	{
		for strFieldName, strValue in objCollection[1] ; use the first record to get the field names
			strFieldOrder := strFieldOrder . strFieldName . strFieldDelimiter
		StringTrimRight, strFieldOrder, strFieldOrder, 1 ; remove extra field delimiter
	}
	objHeader := ObjCSV_ReturnDSVObjectArray(strFieldOrder, strFieldDelimiter, strEncapsulator)
		; returns an object array from a delimited-separated-value string
	if objHeader.MaxIndex() > 200 ; ListView cannot display more that 200 columns
	{
		if (intProgressType)
			ProgressStop(intProgressType)
		ErrorLevel := 1 ; More than 200 columns
		return ; displays nothing in the ListView
	}
	for intIndex, strFieldName in objHeader
	{
		LV_GetText(strExistingFieldName, 0, intIndex) ; line 0 returns column names
		if (Trim(strFieldName) <> strExistingFieldName)
			LV_InsertCol(intIndex, "", Trim(strFieldName))
	}
	loop, %intMax%
	{
		if (intProgressType) and !Mod(A_index, intProgressBatchSize)
			ProgressUpdate(intProgressType, A_index, intMax, strProgressText)
				; update progress bar only every %intProgressBatchSize% records
		intRowNumber := A_Index
		arrFields := Array() ; will contain the values for each cell of a new row
		for intIndex, strFieldName in objHeader
			arrFields[intIndex] := objCollection[intRowNumber][Trim(strFieldName)]
				; for each field, in the specified order, add the data to the array
		LV_Add("", arrFields*) ; put each item of the array in cells of a new ListView row
		; "arrFields*" is allowed because LV_Add is a variadic function
		; (see http://www.autohotkey.com/board/topic/92531-lv-add-to-add-an-array/)
	}
	Loop, % arrFields.MaxIndex()
		LV_ModifyCol(A_Index, "AutoHdr") ; adjust width of each column according to their content
	if StrLen(strListViewID)
		GuiControl, +Redraw, %strListViewID% ; redraw the ListView
	if (intProgressType)
		ProgressStop(intProgressType)
	Gui, Show
	objHeader := ; release object
	ErrorLevel := 0
}
;================================================



;================================================
ObjCSV_ListView2Collection(strGuiID := "", strListViewID := "", strFieldOrder := "", strFieldDelimiter := ","
	, strEncapsulator := """", intProgressType := 0, strProgressText := "")
/*!
	Function: ObjCSV_ListView2Collection([strGuiID = "", strListViewID = "", strFieldOrder = "", strFieldDelimiter = ",", strEncapsulator = """", intProgressType = 0, strProgressText = ""])
		Transfer the selected lines of the selected columns of a ListView to a collection of objects. Lines are transfered in the order they appear in the ListView. Column headers are used as objects keys.

	Parameters:
		strGuiID - (Optional) Name of the Gui that contains the ListView where is the data to transfer. If empty, the last default Gui is used. Empty by default. NOTE: If a Gui name is provided, this Gui will remain the default Gui at the termination of the function.
		strListViewID - (Optional) Name of the target ListView where is the data to transfer. If empty, the last default ListView is used. If one or more rows in the ListView are selected, only these rows will be inserted in the collection. Empty by default. NOTE: If a ListView name is provided, this ListView will remain the default at the termination of the function.
		strFieldOrder - (Optional) Name of the fields (or ListView columns) to insert in the collection records. Names are separated by the strFieldDelimiter character (see below). If empty, all fields are transfered. Empty by default.
		strFieldDelimiter - (Optional) Delimiter of the fields in the strFieldOrder parameter. One character, usually comma, but can also be tab, semi-colon, pipe (|), space, etc. Comma by default.
		strEncapsulator - (Optional) One character (usualy double-quote) possibly used in the in the strFieldOrder string to embed fields data or field names that would include special characters (as described above).
		intProgressType - (Optional) If 1, a progress bar is displayed. If -1, -2 or -n, the part "n" of the status bar is updated with the progress in percentage. See also strProgressText below. By default, no progress bar or status (0).
		strProgressText - (Optional) Text to display in the progress bar or in the status bar. For status bar progress, the string "##" is replaced with the percentage of progress. See also intProgressType above. Empty by default.

	Returns:
		This functions returns an object that contains a collection (or array of objects). See ObjCSV_CSV2Collection returned value for details.
*/
{
	objCollection := Object() ; object that will be returned by the function (a collection or array of objects)
	if StrLen(strGuiID)
		Gui, %strGuiID%:Default
	if StrLen(strListViewID)
		Gui, ListView, %strListViewID%
	intNbCols := LV_GetCount("Column") ; get the number of columns in the ListView
	intNbRows := LV_GetCount() ; get the number of lines in the ListView
	intNbRowsSelected := LV_GetCount("Selected")
	blnSelected := (intNbRowsSelected > 0) ; we will read only selected rows
	if (intProgressType)
	{
		if (blnSelected)
		{
			intProgressBatchSize := ProgressBatchSize(intNbRowsSelected)
			intNbRowsProgress:= intNbRowsSelected
		}
		else
		{
			intProgressBatchSize := ProgressBatchSize(intNbRows)
			intNbRowsProgress:= intNbRows
		}
		ProgressStart(intProgressType, intNbRowsProgress, strProgressText)
	}
	objHeaderPositions := Object()
		; holds the keys (fields name) of the objects in the collection and their position in the ListView
	; build an object array with field names and their position in the ListView header
	loop, %intNbCols%
	{
		LV_GetText(strFieldHeader, 0, A_Index)
		objHeaderPositions.Insert(strFieldHeader, A_Index)
	}
	if !(StrLen(strFieldOrder)) ; if empty, we build strFieldOrder from the ListView header
	{
		loop, %intNbCols%
		{
			LV_GetText(strFieldHeader, 0, A_Index)
			strFieldOrder := strFieldOrder . ObjCSV_Format4CSV(strFieldHeader, strFieldDelimiter, strEncapsulator)
				. strFieldDelimiter ; handle field named with special characters requiring encapsulation
		}
		StringTrimRight, strFieldOrder, strFieldOrder, 1
	}
	intRowNumber := 0 ; scan each row or selected row of the ListView
	Loop
	{
		if (intProgressType) and !Mod(A_index, intProgressBatchSize)
			ProgressUpdate(intProgressType, A_index, intNbRowsProgress, strProgressText)
				; update progress bar only every %intProgressBatchSize% records
		if (blnSelected)
			intRowNumber := LV_GetNext(intRowNumber) ; get next selected row number
		else
			intRowNumber := intRowNumber + 1 ; get next row number
		if (not intRowNumber) OR (intRowNumber > intNbRows)
			; we passed the last row or the last selected row of the ListView
			break
		objData := Object() ; add row data to a new object in the collection
		for intIndex, strFieldName in ObjCSV_ReturnDSVObjectArray(strFieldOrder, strFieldDelimiter, strEncapsulator)
			; parse strFieldOrder handling encapsulated fields
		{
			LV_GetText(strFieldData, intRowNumber, objHeaderPositions[Trim(strFieldName)])
				; get data from cell at row number/header position ListView
			objData[strFieldName] := strFieldData ; put data in the appropriate field of the new row
		}
		objCollection.Insert(objData)
	}
	if (intProgressType)
		ProgressStop(intProgressType)
	objHeaderPositions := ; release object
	return objCollection
}
;================================================



;================================================
ObjCSV_SortCollection(objCollection, strSortFields, strSortOptions := "", intProgressType := 0, strProgressText := "")
/*!
	Function: ObjCSV_SortCollection(objCollection, strSortFields [, strSortOptions = "", intProgressType = 0, strProgressText = ""])
		Scan a collection of objects, sort the collection on one or more field and return sorted collection. Standard AHK_L sort options are supported.

	Parameters:
		objCollection - Object containing an array of objects (or collection). Objects in the collection are associative arrays which contain a list key-value pairs. See ObjCSV_CSV2Collection returned value for details.
		strSortFields - Name(s) of the field(s) to use as sort criteria. To sort on more than one field, concatenate field names with the + character (e.g. "LastName+FirstName").
		strSortOptions - (Optional) Sorting options to apply to the sort command. A string of zero or more of the option letters (in any order, with optional spaces in between). Most frequently used are R (reverse order) and N (numeric sort). All AHK_L sort options are supported. See [http://l.autohotkey.net/docs/commands/Sort.htm](http://l.autohotkey.net/docs/commands/Sort.htm) for more options. Empty by default.
		intProgressType - (Optional) If 1, a progress bar is displayed. If -1, -2 or -n, the part "n" of the status bar is updated with the progress in percentage. See also strProgressText below. By default, no progress bar or status (0).
		strProgressText - (Optional) Text to display in the progress bar or in the status bar. For status bar progress, the string "##" is replaced with the percentage of progress. See also intProgressType above. Empty by default.

	Returns:
		This functions returns an object that contains the array (or collection) of objects of objCollection sorted on strSortFields. See ObjCSV_CSV2Collection returned value for details.
*/
{
	objCollectionSorted := Object()
		; Array (or collection) of sorted objects returned by this function.
		; See ObjCSV_CSV2Collection returned value for details.
	objCollectionSorted.SetCapacity(objCollection.MaxIndex())
	strIndexDelimiter := "|" ;
	intTotalRecords := objCollection.MaxIndex()
	if (intProgressType)
	{
		intProgressBatchSize := ProgressBatchSize(intTotalRecords)
		ProgressStart(intProgressType, intTotalRecords, strProgressText)
	}
	strIndex := ""
	; The variable strIndex is a multi-line string used as an index to sort the collection.
	; Each line of the index contains the sort values and record numbers separated by the pipe (|) character.
	; For example:
	;   value_one|1
	;   value_two|2
	;   value_three|3
	; This string is sorted using the standard AHK_L Sort command:
	;   value_one|1
	;   value_three|3
	;   value_two|2
	; The sorted string is used as an index to sort the records in objCollectionSorted according to the sorting
	; values. In our example, the objects will be added to the sorted collection in this order: 1, 3, 2.
	;
	; Because strIndex can be quite large, we gain performance by splitting the string in substrings of around 300 kb.
	; See discussion on AHK forum
	; http://www.autohotkey.com/board/topic/92832-tip-large-strings-performance-or-divide-to-conquer/
	intOptimalSizeOfSubstrings := 300000 ; found by trial and error - no impact on results if not the optimal size
	strSubstring := ""
	Loop, %intTotalRecords% ; populate index substrings
	{
		intRecordNumber := A_Index
		if (intProgressType) and !Mod(A_index, intProgressBatchSize)
			ProgressUpdate(intProgressType, A_index, intTotalRecords, strProgressText)
				; update progress bar only every %intProgressBatchSize% records
		if InStr(strSortFields, "+")
		{
			strSortingValue := ""
			Loop, Parse, strSortFields, +
				strSortingValue := strSortingValue . objCollection[intRecordNumber][A_LoopField] . "+"
		}
		else
			strSortingValue := objCollection[intRecordNumber][strSortFields]
		StringReplace, strSortingValue, strSortingValue, %strIndexDelimiter%, , 1
			; suppress all index delimiters inside sorting values
		StringReplace, strSortingValue, strSortingValue, `n, , 1
			; suppress all end-of-lines characters inside sorting values 
		strSubstring := strSubstring . strSortingValue . strIndexDelimiter . intRecordNumber . "`n"
		if StrLen(strSubstring) > intOptimalSizeOfSubstrings
		{
			strIndex := strIndex . strSubstring ; add this substring to the final string
			strSubstring := "" ; start a new substring
		}
	}
	strIndex := strIndex . strSubstring ; add the last substring to the final string
	StringTrimRight, strIndex, strIndex, 1
	Sort, strIndex, %strSortOptions%
	Loop, Parse, strIndex, `n
	{
		StringSplit, arrRecordKey, A_LoopField, %strIndexDelimiter%
			; get the record numbers in the original collection in the order the have to be inserted
			; in the sorted collection
		objCollectionSorted.Insert(objCollection[arrRecordKey2])
	}
	if (intProgressType)
		ProgressStop(intProgressType)
	return objCollectionSorted
}
;================================================



;================================================
ObjCSV_Format4CSV(strF4C, strFieldDelimiter := ",", strEncapsulator := """", blnAlwaysEncapsulate := 0)
/*!
	Function: ObjCSV_Format4CSV(strF4C [, strFieldDelimiter = ",", strEncapsulator = """"])
		Add encapsulator before and after strF4C if the string includes line breaks, field delimiter or field encapsulator. Encapsulated field encapsulators are doubled.
		  
	Parameters:
		strF4C - String to convert to CSV format
		strFieldDelimiter - (Optional) Field delimiter. One character, usually comma (default value) or tab.
		strEncapsulator - (Optional) Character (usualy double-quote) used in the CSV file to embed fields that include at least one of these special characters: line-breaks, field delimiters or the encapsulator character itself. In this last case, the encapsulator character must be doubled in the string. For example: "one ""quoted"" word". Double-quote by default.
		blnAlwaysEncapsulate - (Optional) If true (or 1), always encapsulate values with field encapsulator. If false (or 0), fields are encapsulated only if required (see strEncapsulator above). False (or 0) by default.

	Returns:
		String with required encapsulator.
		
	Remarks:
		Based on Format4CSV by Rhys ([http://www.autohotkey.com/forum/topic27233.html](http://www.autohotkey.com/forum/topic27233.html)).  
		  
		Added the strFieldDelimiter parameter to make it work with separators other than comma.  
		Added the strEncapsulator parameter to make it work with other encapsultors than double-quotes.
*/
{
	Reformat := blnAlwaysEncapsulate ; was False before the new parameter blnAlwaysEncapsulate - assume String is OK unless caller wants to encasulate anyway
	IfInString, strF4C, `n ; Check for linefeeds
		Reformat := True ; String must be bracketed by double-quotes
	IfInString, strF4C, `r ; Check for linefeeds
		Reformat := True
	IfInString, strF4C, %strFieldDelimiter% ; Check for field delimiter
		Reformat := True
	if InStr(strF4C, strEncapsulator) or (blnAlwaysEncapsulate)
	{
		Reformat := True
		StringReplace, strF4C, strF4C, %strEncapsulator%, %strEncapsulator%%strEncapsulator%, All
		; The original encapsulator need to be double encapsulator
	}
   /*
   IfInString, strF4C, %strEncapsulator% ; Check for encapsulator
   {
      Reformat:=True
      StringReplace, strF4C, strF4C, %strEncapsulator%, %strEncapsulator%%strEncapsulator%, All
		; The original encapsulator need to be double encapsulator
   }
   */
	If (Reformat)
		strF4C = %strEncapsulator%%strF4C%%strEncapsulator% ; If needed, bracket the string in encapsulators
	Return, strF4C
}
;================================================



;================================================
ObjCSV_ReturnDSVObjectArray(strCurrentDSVLine, strDelimiter := ",", strEncapsulator := """", blnTrim := true)
/*!
	Function: ObjCSV_ReturnDSVObjectArray(strCurrentDSVLine, strDelimiter = ",", strEncapsulator = """")
		Returns an object array from a delimiter-separated string.
		  
	Parameters:
		strCurrentDSVLine - String to convert to an object array
		strDelimiter - (Optional) Field strDelimiter. One character, usually comma (default value) or tab.
		strEncapsulator - (Optional) Character (usualy double-quote) used in the CSV file to embed fields that include at least one of these special characters: line-breaks, field strDelimiters or the strEncapsulator character itself. In this last case, the strEncapsulator character must be doubled in the string. For example: "one ""quoted"" word". Double-quote by default.
		blnTrim - Remove extra spaces at beginning and end of array item. True by default for backward compatibility.

	Returns:
		Returns an object array from a strDelimiter-separated string.

		At the end of execution, the function sets ErrorLevel to: 0 No error / 1 Invalid strDelimiter or strEncapsulator.
		
	Remarks:
		Based on ReturnDSVArray by DerRaphael (thanks for regex hard work).  
		See strDelimiter Seperated Values by DerRaphael ([http://www.autohotkey.com/forum/post-203280.html#203280](http://www.autohotkey.com/forum/post-203280.html#203280)).
*/
{
	objReturnObject := Object()             ; create a local object array that will be returned by the function
	if ((StrLen(strDelimiter)!=1)||(StrLen(strEncapsulator)!=1))
	{
		ErrorLevel := 1
		return                              ; return empty object indicating an error
	}
	strPreviousFormat := A_FormatInteger    ; save current interger format
	SetFormat,integer,H                     ; needed for escaping the RegExNeedle properly
	d := SubStr(ASC(strDelimiter)+0,2)         ; used as hex notation in the RegExNeedle
	e := SubStr(ASC(strEncapsulator)+0,2)      ; used as hex notation in the RegExNeedle
	SetFormat,integer,%strPreviousFormat%   ; restore previous integer format

	p0 := 1                                 ; Start of search at char p0 in DSV Line
	fieldCount := 0                         ; start off with empty fields.
	strCurrentDSVLine .= strDelimiter             ; Add strDelimiter, otherwise last field
	;                                         won't get recognized
	Loop
	{
		RegExNeedle := "\" d "(?=(?:[^\" e "]*\" e "[^\" e "]*\" e ")*(?![^\" e "]*\" e "))"
		p1 := RegExMatch(strCurrentDSVLine,RegExNeedle,tmp,p0)
		; p1 contains now the position of our current delimitor in a 1-based index
		fieldCount++                        ; add count
		field := SubStr(strCurrentDSVLine,p0,p1-p0)
		; This is the Line you'll have to change if you want different treatment
		; otherwise your resulting fields from the DSV data Line will be stored in an object array
		if (SubStr(field,1,1)=strEncapsulator)
		{
			; This is the exception handling for removing any doubled strEncapsulators and
			; leading/trailing strEncapsulator chars
			field := RegExReplace(field,"^\" e "|\" e "$")
			StringReplace,field,field,% strEncapsulator strEncapsulator,%strEncapsulator%, All
		}
		objReturnObject.Insert(blnTrim ? Trim(field) : field) ; add an item in the object array and assign our value to it
		;                                                       blnTrim and Trim not in the original ReturnDSVArray but added for my script needs
		if (p1=0)
		{                                   ; p1 is 0 when no more delimitor chars have been found
			 objReturnObject.Remove()       ; so remove last item in the object array due to last appended delimitor
			 Break                          ; and exit Loop
		} Else
			p0 := p1 + 1                    ; set the start of our RegEx Search to last result
	}                                       ; added by one
	ErrorLevel := 0
	return objReturnObject                  ; return the object array to the function caller
}



;******************************************************************************************************************** 
; INTERNAL FUNCTIONS
;******************************************************************************************************************** 

Prepare4Multilines(ByRef strCsvData, strFieldEncapsulator := """", intProgressType := 0, strProgressText := "")
/*
	Function: Prepare4Multilines(ByRef strCsvData [, strFieldEncapsulator = """", intProgressType = 0, strProgressText = ""])
		Replace end-of-line characters (`n) in field data in strCsvData with a replacement character in order to make data rows stand on a single-line before they are processed by the "Loop, Parse" command. A safe replacement character (absent from the strCsvData string) is automatically determined by the function.

	Parameters:
		strCsvData - (ByRef) Input: Data string to process. Output: See "Returns:" below. 
		strFieldEncapsulator - (Optional) Character used in the strCsvData data to embed fields that include line-breaks. Double-quote by default.
		intProgressType - (Optional) If 1, a progress bar is displayed. If -1, -2 or -n, the part "n" of the status bar is updated with the progress in percentage. See also strProgressText below. By default, no progress bar or status (0).
		strProgressText - (Optional) Text to display in the progress bar or in the status bar. For status bar progress, the string "##" is replaced with the percentage of progress. See also intProgressType above. Empty by default.

	Returns:
		The function returns the replacement character for end-of-lines. Usualy ¡ (inverted exclamation mark, ASCII 161) or the next available safe character: ¢ (ASCII 162), £ (ASCII 163), ¤ (ASCII 164), etc.  The caller of this function *must* save this value in a variable and *must* do the reverse replacement with `n at the appropriate step inside a "Loop, Parse" command.  
		  
		The ByRef parameter strCsvData returns the data string with all end-of-line characters (`n) replaced with the safe replacement character.

		At the end of execution, the function sets ErrorLevel to: 0 No error / 2 Memory limit / 3 No unused character for replacement (returned by sub-function GetFirstUnusedAsciiCode) / 255 Unknown error. If the function produces an "Memory limit reached" error, increase the #MaxMem value (see the help file).
*/
/*
CALL-FOR-HELP!
	#1 This function uses a very rudimentary algorithm to do the replacements only when the end-of-line charaters are
	enclosed between double-quotes. I'm confident my code is safe. But there is certainly a more efficient way to
	accomplish this: RegEx command or another approach? Any help appreciated here :-)
	#2 Need help to test it / make sure this work with ASCII files produced on Unix or Mac systems
	see http://peterbenjamin.com/seminars/crossplatform/texteol.html)
*/
{
	if (intProgressType)
	{
		intMaxProgress := StrLen(strCsvData)
		intProgressBatchSize := ProgressBatchSize(intMaxProgress)
		if (intProgressBatchSize < 8192)
			intProgressBatchSize := 8192
		ProgressStart(intProgressType, intMaxProgress, strProgressText)
	}
	intEolReplacementAsciiCode := GetFirstUnusedAsciiCode(strCsvData) ; Usualy ¡ (inverted exclamation mark, ASCII 161)
	if (ErrorLevel) ; No unused character for replacement
		return
	try
		strTestMemCapacity := strCsvData ; test if we have enough room inside #MaxMem to create a copy of strCsvData
	catch e
	{
		if InStr(e.message, "Memory limit")
			ErrorLevel := 2 ; File too large (Memory limit reached - see #MaxMem in the help file)
		else
			ErrorLevel := 255 ; Unknown error
		return
	}
	strTestMemCapacity := "" ; release memory used by strTestMemCapacity
	blnInsideEncapsulators := false
	Loop, Parse, strCsvData
		; parsing on a temporary copy of strCsvData -  so we can update the original strCsvData inside the loop
	{
		if (intProgressType AND !Mod(A_Index, intProgressBatchSize))
			ProgressUpdate(intProgressType, A_index, intMaxProgress, strProgressText)
		if (A_Index = 1)
			strCsvData := ""
		if (blnInsideEncapsulators AND A_Loopfield = "`n")
			strCsvData := strCsvData . Chr(intEolReplacementAsciiCode)
		else
			strCsvData := strCsvData . A_Loopfield
		if (A_Loopfield = strFieldEncapsulator)
			blnInsideEncapsulators := !blnInsideEncapsulators ; beginning or end of encapsulated text
	}
	if (intProgressType)
		ProgressStop(intProgressType)
	ErrorLevel := 0
	return Chr(intEolReplacementAsciiCode)
}



GetFirstUnusedAsciiCode(ByRef strData, intAscii := 161)
/*
Summary: Returns the ASCII code of the first character absent from the strData string, starting at ASCII code intAscii.
By default, ¡ (inverted exclamation mark ASCII 161) or the next available character: ¢ (ASCII 162), £ (ASCII 163),
¤ (ASCII 164), etc.

At the end of execution, the function sets ErrorLevel to: 0 No error / 3 No unused character.

NOTE: Despite the use of ByRef for the parameter strData, the string is unchanged by the function. ByRef is used only
to optimize memory usage by this function.
*/
{
	Loop
		if InStr(strData, Chr(intAscii))
			intAscii := intAscii + 1
		else if (intAscii > 255) ; no more candidate to check
		{
			intAscii := 0
			ErrorLevel := 3 ; No unused character
			return
		}
		else
			break
	ErrorLevel := 0
	return intAscii
}



SaveBatch(strData, strFilePath, intProgressType, strFileEncoding)
{
	strPreviousFileEncoding := A_FileEncoding
	FileEncoding, % (strFileEncoding = "ANSI" ? "" : strFileEncoding) ; empty string to encode ANSI
	
	loop
	{
		FileAppend, %strData%, %strFilePath%
		if ErrorLevel
			Sleep, 20
	}
	until !ErrorLevel or (A_Index > 50) ; after 1 second (20ms x 50), we have a problem

	If (ErrorLevel) and (intProgressType)
		ProgressStop(intProgressType)
	FileEncoding, %strPreviousFileEncoding%

	return !ErrorLevel
}



MakeFixedWidth(strFixed, intWidth)
{
	while StrLen(strFixed) < intWidth
		strFixed := strFixed . " " ; pad with space
	return SubStr(strFixed, 1, intWidth) ; or truncate
}



MakeHTMLHeaderFooter(strTemplate, strFilePath, strEncapsulator)
{
	SplitPath, strFilePath, strFileName, strDir, strExtension, strNameNoExt, strDrive
	StringReplace, strOutput, strTemplate, %strEncapsulator%FILENAME%strEncapsulator%, %strFileName%, All
	StringReplace, strOutput, strOutput, %strEncapsulator%DIR%strEncapsulator%, %strDir%, All
	StringReplace, strOutput, strOutput, %strEncapsulator%EXTENSION%strEncapsulator%, %strExtension%, All
	StringReplace, strOutput, strOutput, %strEncapsulator%NAMENOEXT%strEncapsulator%, %strNameNoExt%, All
	StringReplace, strOutput, strOutput, %strEncapsulator%DRIVE%strEncapsulator%, %strDrive%, All
	return %strOutput%
}



MakeHTMLRow(strTemplate, objRow, intRow, strEncapsulator)
{
	StringReplace, strOutput, strTemplate, %strEncapsulator%ROWNUMBER%strEncapsulator%, %intRow%, All
	for strFieldName, strValue in objRow
		StringReplace, strOutput, strOutput, %strEncapsulator%%strFieldName%%strEncapsulator%, %strValue%, All
	return %strOutput%
}



MakeXMLRow(objRow)
{
	strOutput := A_Tab . "<Record>`r`n"
	for strFieldName, strValue in objRow
		strOutput := strOutput . A_Tab . A_Tab . "<" . strFieldName .  ">" . strValue . "</" . strFieldName .  ">`r`n"
	strOutput := strOutput . A_Tab . "</Record>`r`n"
	return %strOutput%
}



ProgressBatchSize(intMax)
{
	intSize := Round(intMax / 100)
	if (intSize < 100)
		intSize := 100
	return intSize
}



ProgressStart(intType, intMax, strText)
{
	Gui, +Disabled
	if (intType = 1)
		Progress, R0-%intMax% FS8 A, %strText%, , , MS Sans Serif
	else
	{
		StringReplace, strText, strText, ##, 0
		SB_SetText(strText, -intType)
	}
}



ProgressUpdate(intType, intActual, intMax, strText)
{
	if (intType = 1)
		Progress, %intActual%
	else
	{
		StringReplace, strText, strText, ##, % Round(intActual*100/intMax)
		SB_SetText(strText, -intType)
	}
}



ProgressStop(intType)
{
	Gui, -Disabled
	if (intType = 1)
		Progress, Off
	else
		SB_SetText("", -intType)
}



CheckEolReplacement(strData, strEolReplacement, ByRef strEol)
{
	if StrLen(strEolReplacement) ; multiline field eol replacement
	{
		if !StrLen(strEol)
			strEol := GetEolCharacters(strData) ; if found, strEol will be re-used for next records
		if StrLen(strEol)
			StringReplace, strData, strData, %strEol%, %strEolReplacement%, All ; handle multiline data fields
	}
	return strData
}



GetEolCharacters(strData)
; search to detect the first end-of-lines character(s) detected in the string (in the order "`r`n", "`n", "`r"). Returns empty if none is found.
{
	strEolCandidates := "`r`n|`n|`r"
	loop, Parse, strEolCandidates, |
		if InStr(strData, A_LoopField)
			return A_LoopField
	return := "" ; return empty if no end-of-line detected
}


/*
IsBOM(ByRef str)
; Based on HotKeyIt (https://autohotkey.com/board/topic/93295-dynarun/#entry592328)
; MsgBox % DownloadedString:=NoBOM(DownloadToString("http://learningone.ahk4.net/Temp/Test3.ahk"))
{
	if (0xBFBBEF = NumGet(&str, "UInt") & 0xFFFFFF)
		return 3
	else if (0xFFFE = NumGet(&str, "UShort") || 0xFEFF = NumGet(&str, "UShort"))
		return 2
	else
		return 0
}



NoBOM(ByRef str)
; Based on HotKeyIt (https://autohotkey.com/board/topic/93295-dynarun/#entry592328)
{
	if (0xBFBBEF = NumGet(&str, "UInt") & 0xFFFFFF)
		return str := StrGet(&str + 3, "UTF-8")
	else if (0xFFFE = NumGet(&str, "UShort") || 0xFEFF = NumGet(&str, "UShort"))
		return str := SubStr(&str + 2, "UTF-16")
	else
		return str
}
*/

