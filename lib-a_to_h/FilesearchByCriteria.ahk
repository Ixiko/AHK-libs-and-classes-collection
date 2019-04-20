



;Tail function by Laszlo of the AutoHotkey forums
FileTail(k,file)   ; Return the last k lines of file
{
	Loop Read, %file%
		{
			i := Mod(A_Index,k)
			L%i% = %A_LoopReadLine%
		}
	L := L%i%
	Loop % k-1
		{
			IfLess i,1, SetEnv i,%k%
			i--      ; Mod does not work here
			L := L%i% "`n" L
		}
	Return L
}

; return the full path of a file matching: filename in directory with this suffix
; if suffix isn't given, then use * for suffix
; id directory is not given, then use a_workingDir
; from Roland functions
FileSearch(filename, directory="", suffix="*")
{
   directory := directory!="" ? directory : a_workingDir
   Loop %directory%\*.%suffix%
   { if InStr(a_loopFileName, filename)
      return directory "\" a_loopFileName
   }
}



; search for files in directory containing Criteria1 but not Exclusion
; ALSO find the matching file with the LATEST timemmodified date
FileSearchOneCriteriaLatestDate(Criteria1, Exclusion, directory="", suffix="*")
{

;outputdebug, filesearch2criteria  Criteria1:%Criteria1%  Criteria2:%Criteria2%  Exclusion:%Exclusion%  directory:%directory%  suffix:%suffix%

   directory := directory!="" ? directory : a_workingDir
   
   filetime := 0
   filename := ""
   
   ; loop thru all the files in this directory with this suffix
   Loop %directory%\*.%suffix%
   {
      ; check if our two criteria are in the file name
      if InStr(a_loopFileName, Criteria1)
      {
         ; if the exclusion is included, then make sure that it is not there
         if (Exclusion and instr(a_loopFileName, Exclusion))
            continue
            
         ; see if this filename is LATER than the previous one that we found
         if (A_LoopFileTimeModified > filetime)
         {
            filename := a_loopFileName
            filetime := A_LoopFileTimeModified
         }
      }
   }
   
   if filename
      return directory "\" filename
   
}


; return the full path of a file matching: filename in directory with this suffix
; if suffix isn't given, then use * for suffix
; id directory is not given, then use a_workingDir
; from Roland functions
FileSearchTwoCriteria(Criteria1, Criteria2, Exclusion, directory="", suffix="*")
{

;outputdebug, filesearch2criteria  Criteria1:%Criteria1%  Criteria2:%Criteria2%  Exclusion:%Exclusion%  directory:%directory%  suffix:%suffix%

   directory := directory!="" ? directory : a_workingDir
   ; loop thru all the files in this directory with this suffix
   Loop %directory%\*.%suffix%
   {
      ; check if our two criteria are in the file name
      if (InStr(a_loopFileName, Criteria1) AND InStr(a_loopFileName, Criteria2))
      {
         ; if the exclusion is included, then make sure that it is not there
         if (Exclusion and instr(a_loopFileName, Exclusion))
            continue

         return directory "\" a_loopFileName
      }
   }
}