;Sunday, March 06, 2016
;filey.ahk
;version 1.2
;an autohotkey library for common file functions
;File Class
;Path Class
;make sure core.ahk is loaded since it is required
;#include core.ahk
;---------------FILEY----------------------------------------------------
;exist(whatfile)
;open(whatfile)
;delete(whatfile)
;locked(whatfile)
;deletedir(whatdir, removecontents=0)
;isfolder(whatfile)
;getEncoding(whatfile)
;move(whatfile, whatdestination, overwrite=1)
;copy(whatfile, whatdestination, overwrite=1)
;CopyEverything(SourcePattern, DestinationFolder, DoOverwrite = false)
;size(whatfile)
;fetchautoname(whatfile)
;swap(whatfile1, whatfile2, confirmation=false)
;bak(whatfile, whatbak)
;------------PATH-------------------------------------------------------
;nameonly(whatfile)
;dir(whatfile)
;name(whatfile)
;FullPathFromLocal(whatfile)
;fullpathfromprocess(whatprocess)
;date()
;gettext(whatfile)
;appendtext(whattext, whatfile)
;writetext(whattext, whatfile, makebak="")
;-------------------------------------------------------------------
class filey {

delete(whatfile){
	filedelete, %whatfile%
}

open(whatfile){
	if(FileExist(whatfile) ){
		run, %whatfile%
		return true
	}
}

exist(whatfile){
	global a_doublequote
	whatfile := trim(whatfile, a_doublequote)	;remove existing doublequotes just in case
	if(FileExist(whatfile) ){
		return true	;success
	}else{
		return false ;failure	
	}
}

exists(whatfile){
	return this.exist(whatfile)
}
;returns true if the item is a folder, false if is a file
isfolder(whatfile){
	filegetattrib, theseattributes, %whatfile%
	if(instr(theseattributes, "D") )	;test for the D property, indicating the file is a directory
		return true
}

;return true if locked
locked(whatfile){
	if(!this.exist(whatfile))		;no reason to report it as locked if it doesn't exist, right?
		return false
	returnvalue := false
	if(!thisfile := FileOpen(whatfile, "r-rwd")){
		returnvalue := true
	}
	thisfile.close()
	return returnvalue
}

;overwrite a file by default
;returns name of file if successful
move(whatfile, whatdestination, overwrite=1){
	if(!this.isfolder(whatfile)){
		filemove, %whatfile%, %whatdestination%, %overwrite%
	}else{
		filemove, %whatfile%, %whatdestination%, %overwrite%
	}
	if(errorlevel){
		return false
	}else{
		;for the return name, there are several complications
		;whatdestination includes a custom filename
		;whatdestination is just a directory, and we are copying whatfile using the same filename
		;whatdestination could be a directory and could be the same as whatfile
		if( this.isfolder(whatdestination)  ){		;does the destination include the whatfile folder?
			if(path.name(whatdestination) = path.name(whatfile) ){	;the folder being moved retains it's original name
				return whatdestination
			}else{	;then the destination folder does not contain the file name
				return whatdestination  . "\" . path.name(whatfile)
			}
		}else{		;whatdestination is a file so just return that, whatever it is
			return whatdestination
		}
	}
}


;overwrite a file by default
;returns name of new file if successful
copy(whatfile, whatdestination, overwrite=1){
	if(!this.isfolder(whatfile)){
		isfolder := true
		filecopy, %whatfile%, %whatdestination%, %overwrite%	
	}else{
		isfile := true
		filecopydir, %whatfile%, %whatdestination%, %overwrite%
	}
	if(errorlevel){
		return false
	}else{
		;for the return name, there are several complications
		;whatdestination includes a custom filename
		;whatdestination is just a directory, and we are copying whatfile using the same filename
		;whatdestination could be a directory and could be the same as whatfile
		if( this.isfolder(whatdestination)  ){		;does the destination include the whatfile folder?
			if(path.name(whatdestination) = path.name(whatfile) ){	;the folder being moved retains it's original name
				return whatdestination
			}else{	;then the destination folder does not contain the file name
				return whatdestination  . "\" . path.name(whatfile)
			}
		}else{		;whatdestination is a file so just return that, whatever it is
			return whatdestination
		}
	}
}

;renames a file or folder
;you can use wildcard patterns in whatfile and whatnewname
rename(whatfile, whatnewname, overwrite=1){
	return this.move(whatfile, whatnewname, overwrite)
}

;if recurse is 1, the directory and all its contents will be deleted
;otherwise it will only delete an empty directory
;returns true if successful
deletedir(whatdir, removecontents=0){
	fileremovedir, %whatdir%, %removecontents%
	if(errorlevel)
		return false
	else
		return true	
}

;returns true if successful
createdir(whatdir){
	FileCreateDir, %whatdir%
}

getEncoding(whatfile){
	thisfile := FileOpen(whatfile,"r")
	thisfileencoding := thisfile.encoding
	thisfile.close()
	return thisfileencoding
}

size(whatfile){
	filegetsize, thissize, %whatfile%, K
	return thissize
}

;needs error handling
;needs optimization - that is, the speed could be improved by reserving the smaller file
;preserves the extensions.
;works on files AND folders
swap(whatfile1, whatfile2, confirmation=false){
	if( !this.exist(whatfile1) or !this.exist(whatfile2) ){
		return
	}
	ext1 := "." . path.ext(whatfile1)
	ext2 := "." . path.ext(whatfile2)
	path1 := path.pathname(whatfile1)
	path2 := path.pathname(whatfile2)
	
	isdir1 := this.isfolder(whatfile1)
	isdir2 := this.isfolder(whatfile2)
	
	newfile1 := path1 . ext2
	newfile2 := path2 . ext1
	
	;place file1 in reserve
	tempfile := this.move(whatfile1, whatfile1 . "~temp" . a_now)	
	if(ErrorLevel){
		alert("Sorry, fellow, the operation failed.")
		return
	}
	
	;we use the fetchautoname() to assure that the filenames won't exist after we swap.
	if(isdir1 && isdir2){
		;both items are directories
		this.move(whatfile2, whatfile1)		;move 2 to 1
		this.move(tempfile, whatfile2)		;move 1 to 2
	}else if(isdir1 && !isdir2){
		;file2=file.ext2
		;file1=directory
		this.move(whatfile2, this.fetchautoname(newfile1) )		;move 2 to 1 and keep extension
		this.move(tempfile, this.fetchautoname(path2) )			;move 1 to 2, and lose the extension
	}else if(!isdir1 && isdir2){
		;file2=directory
		;file1=file.ext1
		this.move(whatfile2, this.fetchautoname(path1))		;move 2 to 1 and skip the extension
		this.move(tempfile, this.fetchautoname(newfile2))	;move 1 to 2 and keep extension
	}else{
		;both items are files
		this.move(whatfile2, this.fetchautoname(newfile1))	;move 2 to 1, keeping the original extension
		this.move(tempfile, this.fetchautoname(newfile2))	;move 1 to 2, keeping the original extension
	}
	
	if(confirmation)
		alert("Okay! The filenames were swapped")
}
;create a backup file, autonaming the file if it exists
;returns the name of the bak file
bak(whatfile, whatbak=""){
	if(!this.exist(whatfile) or this.isfolder(whatfile))
		return
	if(!whatbak)
		whatbak := whatfile . ".bak"
	thisfile := this.duplicate(whatfile)
	thisfile := this.autoname(thisfile, whatbak)
	return whatbak
}

;creates an autonamed duplicate of the file (creates a file copy with a new name)
;returns the name of the new file
duplicate(whatfile){
	if(!this.exist(whatfile))
		return
	tempfile := this.copy(whatfile, whatfile . "~temp" . a_now	)
	newname := this.fetchautoname(whatfile)
	this.move(tempfile, newname)
	return newname
}
;This is like copy except that the new filename is autonamed.  Creates a new autonamed file.
;This is different than duplicate because it uses a new name instead of the original file's filename
;to start this, just specify whatfile; newfile is only used by the internal recursive loop
;returns the name of the new file
autoname(whatfile, newfile){
	;if no file is specified, then don't do anything.
	if(!file.exist(whatfile))
		return
	;fetch the new name
	newname := file.fetchautoname(newfile)		
	file.move(whatfile, newname)
	return newname	
}
;return the name of a filename that isn't taken - figure the new name by appending (1) or (2) to the filename
;loop to rename a file until it finds a numbered name that doesn't exist
;returns the new filename
;does not change the files
fetchautoname(whatfile){
	if(!this.exist(whatfile))
		return whatfile
		
	;since newfile exists, calculate a new filename
	;fetch the position of the parentheses and fetch the counter and the parenthesis
	counterstart := instr(whatfile, "(", 0)	
	counterend := instr(whatfile, ")", 0)
	lencounter := counterend - counterstart +1		
	;see if there is already a counter and build a new filename
	if(lencounter < 3){	;it has to be at least 3 to make (1)
		newcounter := 1
		newname := path.pathname(whatfile) . "(" . newcounter . ")." . path.ext(whatfile)
	}else{
		;now remove the parenthesis and increment the counter
		currentcounter := mid(whatfile, counterstart, lencounter)
		currentcounter := left(currentcounter, 1, true)
		currentcounter := right(currentcounter, 1, true)
		newname := left(whatfile, counterstart-1) . "(" . currentcounter+1 . ")." . path.ext(whatfile)	
	}
	;now rename the file to the new name by going into recurse
	return this.fetchautoname(newname)
}
; Copy all files and folders inside a folder to a different folder
; Copies all files and folders matching SourcePattern into the folder named DestinationFolder and
; returns the number of files/folders that could not be copied.
CopyEverything(SourcePattern, DestinationFolder, DoOverwrite = false){
    ; First copy all the files (but not the folders):
    FileCopy, %SourcePattern%, %DestinationFolder%, %DoOverwrite%
    ErrorCount := ErrorLevel
    ; Now copy all the folders:
    Loop, %SourcePattern%, 2  ; 2 means "retrieve folders only".
    {
        FileCopyDir, %A_LoopFileFullPath%, %DestinationFolder%\%A_LoopFileName%, %DoOverwrite%
        ErrorCount += ErrorLevel
        if ErrorLevel  ; Report each problem folder by name.
            MsgBox Could not copy %A_LoopFileFullPath% into %DestinationFolder%.
    }
    return ErrorCount
}
}	;end class file
;--------------PATH------------------------------------------------------------------------------------------------------------------------
;Consider a full path as c:\some path\folder\file.ext
class path {
;swaps the nameonly
swapnameonly(whatfile, whatnameonly){
	newfile := this.dir(whatfile) . whatnameonly . this.ext(whatfile)
	return newfile
}
;returns: file
nameonly(whatfile){
	splitpath, whatfile,,,,thisnameonly
	return thisnameonly
}
;returns:   file.ext
name(whatfile){
	splitpath, whatfile,thisfilename
	return thisfilename
}
;returns .ext
ext(whatfile){
	splitpath, whatfile,,,thisextension
	return thisextension	
}
;returns:  c:\some path\folder
;(no trailing slash)
dir(whatfile){
	splitpath, whatfile,,thisdir
	return thisdir
}
;returns:   c:\some path\folder\file
;if no directory is specified, return blank
pathname(whatfile){
	thisdir := this.dir(whatfile)
	if(thisdir)
		thispath := thisdir . "\" . this.nameonly(whatfile)
	else
		thispath := this.nameonly(whatfile)
	return thispath
}
;return the full path of the file; we assume it is in a_workingdir unless another is specified
FullPathFromLocal(whatfile, whatdefaultpath=""){
	;see if there are any slashes in the path; if not, add the current directory to get the full path
	if(!instr(whatfile, "\")){
		if(whatdefaultpath){
			thispath := whatdefaultpath . "\" . whatfile
		}else{	
			thispath := a_workingdir . "\" . whatfile
		}
	}else{
		thispath := whatfile
	}
	if(!fileexist(whatfile)){
		alert("Dude! " . whatfile . " doesn't seem to exist!", "error")
		return ""
	}else{
		return thispath
	}
}
;return the full path of an executable from its process name (must include file extension)
;if the process isn't running, it will return blank.
fullpathfromprocess(whatprocess){
	winget, thisfullpath, processpath, ahk_exe %whatprocess%
	return thisfullpath
}


;fetches the full path of a file from its environmentally gotten name
;if not an environmental, it returns emtpy
;http://ahkscript.org/boards/viewtopic.php?p=48907&sid=be08c944ec8e4ff820310a35e8bc38d5#p48907
pathfrompath(whatfile) {
	; msdn.microsoft.com/en-us/library/bb773594(v=vs.85).aspx
	VarSetCapacity(Buffer, 520, 0)
	Buffer := whatfile
	If DllCall("Shlwapi.dll\PathFindOnPath", "Str", Buffer, "Ptr", 0)
	Return Buffer
}




;create a precise time format useful for file-creation and easy to read
date(){
	FormatTime, thisdate,,yyyy-MM-dd-hhmmss
	return thisdate
}
time(){
	FormatTime, thisdate,,hhmmss
	return thisdate
}
} ;end class path
