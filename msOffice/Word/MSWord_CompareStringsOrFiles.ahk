; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=63631
; Author:
; Date:
; for:     	AHK_L

/*
	MSWord_CompareStringsOrFiles("String 1", "String 2")								                        		; compares two STRINGS
	MSWord_CompareStringsOrFiles("C:\File1.txt", "C:\Document2.docx", {ReadFiles: "both"})		; compares FILE CONTENT from two files; .txt file and .docx file
	MSWord_CompareStringsOrFiles("C:\File1.txt", "String 2", {ReadFiles: "first"})		            		; reads FILE CONTENT from the first parameter and compares it with STRING in second parameter
	; etc.

*/

MSWord_CompareStringsOrFiles(StringOrFile1, StringOrFile2, options="") { ; Compares strings or files (file contents) using MS Word built-in compare documents functionality. By Learning one. Last update: 2019-09-05
	/*
	Parameters & usage:
		This function can compare strings and file contents from MS Word documents and plain text files like .txt, .ahk, .html, etc.
		First and second parameters can be treated as strings or as full paths of files whose file contents you want to read and compare.
		In third parameter you can optionally specify options as associative array.
		If you specify {ReadFiles: "both"} option, first and second parameters are treated as full paths of files whose file contents you want to read - function will read file contents from both files and compare them
		If you specify {ReadFiles: "first"} option, function will read file contents of file whose full path is specified in first parameter and compare it with second parameter which will be treated as string
		If you specify {ReadFiles: "second"} option, it will have oposite effect compared to {ReadFiles: "first"} option
		If third parameter is not specified or if you specify {ReadFiles: ""}, function will threat first and second parameter as strings (no matter if they are full paths).
		You can use almost all MS Word built-in compare documents functionality options like: Granularity, CompareFormatting, CompareCaseChanges, CompareWhitespace, etc.
		You can combine many sorts of comparisons like: string <--> string, MS Word document <--> TXT document, String <--> MS Word Document, etc.
		Learn from examples below.

	Examples:
		MSWord_CompareStringsOrFiles("String 1", "String 2")												; compares two STRINGS
		MSWord_CompareStringsOrFiles("STRING 1", "string 2", {CompareCaseChanges: 0})						; compares two STRINGS but doesn't compare case changes
		MSWord_CompareStringsOrFiles("STRING 1", "String2", {CompareCaseChanges: 0, CompareWhitespace: 0}) 	; compares two STRINGS but doesn't compare case changes and whitespace changes

		MSWord_CompareStringsOrFiles("C:\File1.txt", "C:\File2.txt")									; compares two STRINGS
		MSWord_CompareStringsOrFiles("C:\File1.txt", "C:\File2.txt", {ReadFiles: "both"})				; compares FILE CONTENT from two files - first and second parameters are treated as full paths of files to read
		MSWord_CompareStringsOrFiles("C:\File1.txt", "C:\File2.txt", {ReadFiles: "first"})				; reads FILE CONTENT from the first parameter and compares it with STRING in second parameter
		MSWord_CompareStringsOrFiles("C:\File1.txt", "C:\File2.txt", {ReadFiles: "second"})				; reads FILE CONTENT from the second parameter and compares it with STRING in first parameter

		MSWord_CompareStringsOrFiles("C:\Document1.docx", "C:\Document2.docx", {ReadFiles: "both"})		; compares FILE CONTENT from two files (MS Word documents)
		MSWord_CompareStringsOrFiles("C:\Document1.docx", "C:\Document2.docx", {ReadFiles: "first"})	; reads FILE CONTENT from the first parameter and compares it with STRING in second parameter

		MSWord_CompareStringsOrFiles("C:\File1.txt", "C:\Document2.docx", {ReadFiles: "both"})			; reads FILE CONTENT from two files; .txt file and .docx file
		MSWord_CompareStringsOrFiles(Clipboard, "C:\File2.txt", {ReadFiles: "second"})					; reads FILE CONTENT from the second parameter and compares it with Clipboard (STRING) in first parameter
		MSWord_CompareStringsOrFiles(A_ScriptFullPath, "C:\File2.txt")									; compares two STRINGS; script's full path and path in second string
		MSWord_CompareStringsOrFiles(A_ScriptFullPath, Clipboard)										; compares two STRINGS; script's full path and Clipboard
		MSWord_CompareStringsOrFiles("C:\web-page-1.html", "C:\web-page-2.html", {ReadFiles: "both"})	; compares FILE CONTENT from two files (HTML documents)
		MSWord_CompareStringsOrFiles("C:\Script1.ahk", "C:\Script2.ahk", {ReadFiles: "both"})			; compares FILE CONTENT from two files (AutoHotkey scripts)

	Forum post:
		https://www.autohotkey.com/boards/viewtopic.php?f=6&t=63631

	Application.CompareDocuments method (Word) documentation:
		https://docs.microsoft.com/en-us/office/vba/api/word.application.comparedocuments
	*/

	;=== Options object, set String1 and String2, close documents switches ===
	if (IsObject(options) != 1)		; if user didn't specify object which contains options
		options := {}				; create options object
	String1 := StringOrFile1, String2 := StringOrFile2
	CloseDocument1 := 1, CloseDocument2 := 1

	;=== Read file(s) and get or create MS Word COM object if needed ===
	if (options.HasKey("ReadFiles") = 1 and options.ReadFiles != "") {	; we have to read file(s)
		FilesToRead := ["",""]	; make two initially empty keys
		if (options.ReadFiles = "first")
			FilesToRead.1 := Trim(StringOrFile1)
		else if (options.ReadFiles = "second")
			FilesToRead.2 := Trim(StringOrFile2)
		else if (options.ReadFiles = "both")
			FilesToRead.1 := Trim(StringOrFile1), FilesToRead.2 := Trim(StringOrFile2)

		For k,FullPath in FilesToRead
		{
			if (FullPath = "")	; continue - in this case we have a string, not file's full path - for example when user specifies {ReadFiles: "first"} or {ReadFiles: "second"}
				continue
			if (FileExist(FullPath) != "") {  ; file exists
				SplitPath, FullPath,,, OutExtension
				if OutExtension in doc,docm,docx,dot,dotm,dotx	 ; MS Word document extensions (note: tested only on .docx)
				{
					;=== Get or create MS Word COM object if it wasn't created before === (note: do not put this part in "if (k = 1)" block)
					if (oWord = "") {
						try
							oWord := ComObjActive("Word.Application")
						catch {
							try
								oWord := ComObjCreate("Word.Application")
							catch
								return	; or: throw Exception("Can't retrieve nor create MS Word COM object", -1)
						}
					}

					;=== Deal with first file (MS Word document) ===
					if (k = 1) {
						Loop, % oWord.Documents.Count							; loop through all documents already opened in Word (if any)
						{
							if (oWord.Documents(A_Index).FullName = FullPath) {	; if this document is already opened in Word
								try {
									oDocument1 := oWord.Documents(A_Index)
									CloseDocument1 := 0							; after comparison we don't want to close this document because it was opened before
								}
								break
							}
						}
						if (oDocument1 = "")	; if that document wasn't opened in Word, open it
							try oDocument1 := oWord.Documents.Open(FullPath)
					}

					;=== Deal with second file (MS Word document) ===
					else {
						Loop, % oWord.Documents.Count							; loop through all documents already opened in Word (if any)
						{
							if (oWord.Documents(A_Index).FullName = FullPath) {	; if this document is already opened in Word
								try {
									oDocument2 := oWord.Documents(A_Index)
									CloseDocument2 := 0							; after comparison we don't want to close this document because it was opened before
								}
								break
							}
						}
						if (oDocument2 = "")	; if that document wasn't opened in Word, open it
							try oDocument2 := oWord.Documents.Open(FullPath)
					}

				}
				else {	; files with "txt", "ahk", "html", etc. extensions are expected - but user should care what file types he wants to read
					if (k = 1)	; deal with first file
						FileRead, String1, % FullPath
					else		; deal with second file
						FileRead, String2, % FullPath
				}
			}
			else {	; file doesn't exist - nothing to read - treat as empty string (or should I signal error?)
				if (k = 1)
					String1 := ""
				else
					String2 := ""
			}
		}
	}

	;=== Get or create MS Word COM object if it wasn't created before ===
	if (oWord = "") {
		try
			oWord := ComObjActive("Word.Application")
		catch {
			try
				oWord := ComObjCreate("Word.Application")
			catch
				return	; or: throw Exception("Can't retrieve nor create MS Word COM object", -1)
		}
	}

	;=== Options - defaults or set by user (except ReadFiles option) ===
	Destination := (options.HasKey("Destination") = 1) ? options.Destination : 2	; 2 = wdCompareDestinationNew - Creates a new file and tracks the diferences between the original and revised document
	Granularity := (options.HasKey("Granularity") = 1) ? options.Granularity : 1	; 1 = wdGranularityWordLevel - Tracks word-level changes. For character-level changes specify 0
	CompareFormatting := (options.HasKey("CompareFormatting") = 1) ? options.CompareFormatting : 1
	CompareCaseChanges := (options.HasKey("CompareCaseChanges") = 1) ? options.CompareCaseChanges : 1
	CompareWhitespace := (options.HasKey("CompareWhitespace") = 1) ? options.CompareWhitespace : 1
	CompareTables := (options.HasKey("CompareTables") = 1) ? options.CompareTables : 1
	CompareHeaders := (options.HasKey("CompareHeaders") = 1) ? options.CompareHeaders : 1
	CompareFootnotes := (options.HasKey("CompareFootnotes") = 1) ? options.CompareFootnotes : 1
	CompareTextboxes := (options.HasKey("CompareTextboxes") = 1) ? options.CompareTextboxes : 1
	CompareFields := (options.HasKey("CompareFields") = 1) ? options.CompareFields : 1
	CompareComments := (options.HasKey("CompareComments") = 1) ? options.CompareComments : 1

	;=== Create document(s) and set text if we did not get reference to existing MS Word document(s) before ===
	if (oDocument1 = "") {
		oDocument1 := oWord.Documents.Add   			; create new document
		oDocument1.Content.Text := String1				; set text to main document story
	}
	if (oDocument2 = "") {
		oDocument2 := oWord.Documents.Add   			; create new document
		oDocument2.Content.Text := String2				; set text to main document story
	}

	;=== Compare & show ===
    oDifferencesDocument := oWord.CompareDocuments(oDocument1, oDocument2, Destination, Granularity, CompareFormatting, CompareCaseChanges, CompareWhitespace, CompareTables, CompareHeaders, CompareFootnotes, CompareTextboxes, CompareFields, CompareComments)

	if (CloseDocument1 = 1)
		oDocument1.Close(0)	; 0 = wdDoNotSaveChanges
	if (CloseDocument2 = 1)
		oDocument2.Close(0)	; 0 = wdDoNotSaveChanges

	oDifferencesDocument.Activate
    oWord.ActiveWindow.ShowSourceDocuments := 3	; 3 = wdShowSourceDocumentsBoth - Shows both original and revised documents.
	oWord.Visible := 1
    oWord.Activate
}