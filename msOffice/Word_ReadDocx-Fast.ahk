;https://www.autohotkey.com/boards/viewtopic.php?f=6&t=29423
myWord := "Testing.docx" 	
startTime  :=  A_TickCount	
tempFolder := RegExReplace( myWord, ".*\K\\.*") "\_Word_UnZip\"		
tempName := RegExReplace( myWord, "\.docx") ".zip"
FileCopy, % myWord , % tempName
FileCreateDir, % tempFolder
tempObject := ComObjCreate("Shell.Application")
tempObject.Namespace(tempFolder).CopyHere( tempObject.Namespace(tempName).items, 4|16)	
FileDelete, % tempName
FileEncoding, UTF-8
FileRead, wordContents, % tempFolder "\" "word\document.xml"	
While @ := RegExMatch( wordContents, "<w:t>(.+?)</w:t>", _, @ ? StrLen(_) + @ : 1 )  	
	myContent .= _1 "`n"
FileRemoveDir, % tempFolder, 1
resultFile := RegExReplace( myWord, "\.docx") "_Extracted.txt"
FileAppend,% myContent, % resultFile
MsgBox % A_TickCount - startTime