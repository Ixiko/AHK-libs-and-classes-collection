;#include FcnLib.ahk

;FcnLib-Rewrites.ahk by camerb

;This library contains those functions that reproduce functionality in AHK_basic, but which have significant differences in usage and/or side effects. The differences in functionality in these functions were found to be preferable over the functionality of the commands as they are in plain AHK (that's just my opinion, though)

;{{{ File Manipulation Functions
FileAppend(text, file)
{
   EnsureDirExists(file)
   FileAppend, %text%, %file%
   ;TODO should we ensure that the file exists?
}

FileAppendLine(text, file)
{
   text.="`r`n"
   return FileAppend(text, file)
}

FileCopy(source, dest, options="")
{
   if InStr(options, "overwrite")
      overwrite=1
   if NOT FileExist(source)
      fatalErrord("file doesn't exist", source, A_ThisFunc, A_LineNumber)
   EnsureDirExists(dest)

   FileCopy, %source%, %dest%, %overwrite%
}

FileDelete(file)
{
   ;nothing is wrong if the file is already gone
   if NOT FileExist(file)
      return

   FileDelete, %file%
}

FileMove(source, dest, options="")
{
   if InStr(options, "overwrite")
      overwrite=1
   if NOT FileExist(source)
      fatalErrord("file doesn't exist", source, A_ThisFunc, A_LineNumber)
   EnsureDirExists(dest)

   FileMove, %source%, %dest%, %overwrite%
}

FileCreate(text, file)
{
   ;if rewriting the file wouldn't change anything on the hard drive, don't do it
   if FileExist(file)
   {
      currentText := FileRead(file)
      if (currentText == text)
         return
   }

   ;Create the sucker
   FileDelete(file)
   FileAppend(text, file)
}

;A simple little function, probably isn't performed as quickly as it could be, but what's the harm?
FileLineCount(file)
{
   Loop, read, %file%
      returned:=A_Index
   return returned
}
;}}}

;{{{Folder Manipulation Functions

;TESTME
FileCopyDir(source, dest, options="")
{
   if InStr(options, "overwrite")
      overwrite=1

   if NOT DirExist(source)
      return false
   EnsureDirExists(dest)

   FileCopyDir, %source%, %dest%, %overwrite%
}

;TODO consider a rename to FileDeleteDirForceful (or forceful option)
;Delete folder very forcefully
FileDeleteDirForceful(dir)
{
   ;this will delete as much as possible from the target folder
   ;depending upon file locks, some items may not get deleted

   if NOT DirExist(dir)
      return

   dir:=EnsureEndsWith(dir, "\")
   dir:=EnsureEndsWith(dir, "*")

   ;delete as many files as we possibly can (typically difficult in windows)
   Loop, %dir%, , 1
   {
      FileDelete, %A_LoopFileFullPath%
   }

   ;delete all the folders that we can
   Loop, %dir%, 2, 1
   {
      FileRemoveDir, %A_LoopFileFullPath%, 1
   }
}

;Returns if the directory exists
;FIXME hmm, perhaps I should have named this starting with the word "file"
;TODO rename all instances of DirExist to FileDirExist
FileDirExist(dirPath)
{
   return InStr(FileExist(dirPath), "D") ? 1 : 0
}
DirExist(dirPath)
{
   return FileDirExist(dirPath)
}

;Creates the parent dir if necessary
;TODO if path is a directory, this ensures that that dir exists
;simply: this ensures that the entire specified dir structure exists
EnsureDirExists(path)
{
   ;if path is a file, this ensures that the parent dir exists
   dir:=ParentDir(path)

   ;figure out if it is a file or dir
   ;split off filename if applicable
   FileCreateDir, %dir%
}

;TESTME
;Gets the parent directory of the specified directory
ParentDir(fileOrFolder)
{
   fileOrFolder := RegExReplace(fileOrFolder, "(\\|/)", "\")
   if (StringRight(fileOrFolder, 1) == "\")
      fileOrFolder:= StringTrimRight(fileOrFolder, 1)
   RegexMatch(fileOrFolder, "^.*\\", returned)
   return returned
}
;}}}

;{{{ INI Functions

;TESTME
IniWrite(file, section, key, value)
{
   ;sanitize key and value (replace with NAK to indicate an error)
   key := RegExReplace(key, "(\r|\n)", "?")
   value := RegExReplace(value, "(\r|\n)", "?")
   EnsureDirExists(file)

   ;TODO put this in the read write and delete fcns
   if (file == "")
      fatalErrord(A_ThisFunc, A_ThisLine, A_ScriptName, "no filename was provided for writing the ini to")
   if (key == "")
      fatalErrord(A_ThisFunc, A_ThisLine, A_ScriptName, "no key was provided for writing the ini value to")
   if (section == "")
      section:="default"

   IniWrite, %value%, %file%, %section%, %key%
   ;TODO test if the file is there
   if NOT FileExist(file)
   {
      errord("silent", "wrote to ini file, but it doesn't exist", file)
      Sleep, 500
      return "ERROR"
   }
}

IniDelete(file, section, key="")
{
   ;sanitize key and value (replace with NAK to indicate an error)
   key := RegExReplace(key, "(\r|\n)", "?")
   ;EnsureDirExists(file)

   if (file == "")
      fatalErrord(A_ThisFunc, A_ThisLine, A_ScriptName, "no filename was provided for deleting the ini value from")
   ;if (key == "")
      ;fatalErrord(A_ThisFunc, A_ThisLine, A_ScriptName, "no key was provided for deleting the ini value from")
   if (section == "")
      section:="default"

   if (key == "")
      IniDelete, %file%, %section%
   else
      IniDelete, %file%, %section%, %key%

   ;TODO perhaps we should return what the old value was?
   ;or maybe that would be stupid
}

IniRead(file, section, key, Default = "ERROR")
{
   ;sanitize key and value (replace with NAK to indicate an error)
   ;TODO get a better value!!! NAK was bad, but ? would probably be used...
   key := RegExReplace(key, "(\r|\n)", "?")
   ;EnsureDirExists(file)

   if (file == "")
      fatalErrord(A_ThisFunc, A_ThisLine, A_ScriptName, "no filename was provided for reading the ini value from")
   if (key == "")
      fatalErrord(A_ThisFunc, A_ThisLine, A_ScriptName, "no key was provided for reading the ini value from")
   if (section == "")
      section:="default"
   IniRead, value, %file%, %section%, %key%, %Default%
   Return, value
}

;ok, these two aren't actually rewrites of things that are core
; but these functions probably should have been core
#include thirdParty/ini.ahk
IniListAllSections(file)
{
   content := FileRead(file)
   return ini_getAllSectionNames(content)
}

IniListAllKeys(file, section="") ;defaults to all sections
{
   content := FileRead(file)
   return ini_getAllKeyNames(content, section)
}
;}}}

;{{{ Process Manipulation
GetPID(exeName)
{
   Process, Exist, %exeName%
   return ERRORLEVEL
}

ProcessExist(exeName)
{
   Process, Exist, %exeName%
   return !!ERRORLEVEL
}

ProcessClose(exeName)
{
   Process, Close, %exeName%
}

ProcessCloseAll(exeName)
{
   cmd=taskkill /im %exeName% /f
   CmdRet_RunReturn(cmd)

   ;FIXME
   ;this waits for all processes to get closed...
   ;something like "taskkill /f /im perl.exe" would be best, but that would require external libs
   ;another solution is to just get a list of all processes with that name and ProcessClose() each one
   ;   that would not wait for each one to close
   while ProcessExist(exeName)
   {
      ProcessClose(exeName)
      Sleep, 100
   }
}

;sometimes ProcessCloseAll will fail miserably and just hang. If you use this, it will try to close everything many times, but won't hang
ProcessCloseFifty(exeName)
{
   Loop, 50
      ProcessClose(exeName)

   cmd=taskkill /im %exeName% /f
   CmdRet_RunReturn(cmd)
}
;}}}

;{{{ String Manipulation
StringReplace(ByRef InputVar, SearchText, ReplaceText = "", All = "A") {
	StringReplace, v, InputVar, %SearchText%, %ReplaceText%, %All%
	Return, v
}
;}}}

;{{{ Misc
Reload()
{
   Reload
   Sleep, 60000 ;noticed that reload doesn't reload instantly
}
;}}}

;iniF below this point ========
;TODO this does not belong in the rewrites lib... this needs to be in a lib by itself, and posted on the AHK site
;{{{ viewable iniFolder in one INI
ViewableIniFolder(iniFolder, viewableIniDestination)
{
   ;TODO, make this read all into memory, then output the sucker, rather than making tons of R/Ws on the HD

   ;FileRead, ini, %ConfigFilePath%
   ;value := ini_getValue(ini, "Config", "Started")
   ;ini_replaceValue(ini, "Config", "Started", value)
   ;updateConfigFile(ConfigFilePath, ini)

   ;fix up the incoming params
   if NOT FileDirExist(iniFolder)
      fatalErrord("", "you did not specify an iniFolder that exists already", iniFolder)
   iniFolder := EnsureEndsWith(iniFolder, "\")
   destIni := viewableIniDestination

   ;TESTME if we don't need to recreate the INI, then don't bother doing the regen
   ;note that if some of the IniF files are removed, the ViewableIni will not be regenerated
   if NOT FileExist(destIni)
      needToRegen := true
   lastTimeGenerated := FileGetTime(destIni)
   Loop, %iniFolder%*.ini
   {
      thisIniFile := A_LoopFileFullPath

      if ( FileGetTime(thisIniFile) > lastTimeGenerated)
         needToRegen := true
   }
   if NOT needToRegen
      return

   FileDelete(destIni)
   sections:=IniFolderListAllSections(iniFolder)
   Loop, parse, sections, CSV
   {
      thisSection := A_LoopField
      keys:=IniFolderListAllKeys(iniFolder, thisSection)
      Loop, parse, keys, CSV
      {
         thisKey := A_LoopField

         if NOT thisKey
         {
            ;FIXME what the heck!? the key should never be null... make this less ghetto
            ;not exactly sure why this is null so often
            ;errord("notimeout", iniFolder, thisSection, thisKey)
            continue
         }
         value := IniFolderRead(iniFolder, thisSection, thisKey)
         IniWrite(destIni, thisSection, thisKey, value)
      }
   }
   ;addtotrace("finished making viewable inif")
}
;}}}

;{{{ iniFolder Library
IniFolderRead(iniFolder, section, key)
{
   iniFolder := EnsureEndsWith(iniFolder, "\")
   timestamp := CurrentTime("hyphenated")
   datestamp := CurrentTime("hyphendate")
   keyValue=%key%-value
   keyDate=%key%-timestamp

   ;search through all applicable files to get the most recently inserted value
   maxValue=ERROR
   maxDate=0
   Loop, %iniFolder%*.ini
   {
      thisIniFile := A_LoopFileFullPath
      thisValue := IniRead(thisIniFile, section, keyValue)
      thisTimestamp := IniRead(thisIniFile, section, keyDate)

      thisTimestamp := DeFormatTime(thisTimestamp)
      if (thisTimestamp > maxDate)
      {
         maxValue := thisValue
         maxDate := thisTimestamp
      }
   }

   return maxValue
}

IniFolderWrite(iniFolder, section, key, value)
{
   iniFolder := EnsureEndsWith(iniFolder, "\")
   timestamp := CurrentTime("hyphenated")
   datestamp := CurrentTime("hyphendate")
   modMinute := "ModMin" . Mod(A_Min, 5)
   ;myIniFile=%iniFolder%%datestamp%-%A_ComputerName%.ini
   myIniFile=%iniFolder%%datestamp%-%modMinute%-%A_ComputerName%.ini
   keyValue=%key%-value
   keyDate=%key%-timestamp

   IniWrite(myIniFile, section, keyValue, value)
   IniWrite(myIniFile, section, keyDate, timestamp)
}

IniFolderListAllSections(iniFolder)
{
   iniFolder := EnsureEndsWith(iniFolder, "\")

   Loop, %iniFolder%*.ini
   {
      thisIniFile := A_LoopFileFullPath

      if (strlen(returned) != 0)
         returned .= ","
      returned .= IniListAllSections(thisIniFile)
   }

   ;dedup
   Sort MyVar, N U D,  ; Sort numerically, dedup, use comma as delimiter.

   return returned
}

;TESTME
IniFolderListAllKeys(iniFolder, section="") ;defaults to all sections
{
   ;deleting keys or sections is not allowed, because that will be a lot of work (you'd have to mark as inactive instead)
   iniFolder := EnsureEndsWith(iniFolder, "\")

   Loop, %iniFolder%*.ini
   {
      thisIniFile := A_LoopFileFullPath

      if (strlen(returned) != 0)
         returned .= ","
      returned .= IniListAllKeys(thisIniFile, section)
   }

   ;np=[^()]
   ;haystack=\((%notParen%+)\)\-\(%notParen%+\)
   ;returned := RegExReplace(returned, haystack, "$1")
   ;returned := RegExReplace(returned, "\-(value|timestamp)$")

   ;FIXME make this a little less ghetto, so that I can use "-value" and "-timestamp" in my keys
   returned := RegExReplace(returned, "\-(value|timestamp)")

   ;dedup
   Sort MyVar, N U D,  ; Sort numerically, dedup, use comma as delimiter.

   return returned
}
;}}}

;{{{ archive iniFolder old parts
ArchiveOldInifParts(IniFolder)
{
   ;THIS PART IS AN OLD HOLDOVER FROM THE FIREFLY DAYS
   ; back when we needed to make sure that all old fees were added before we archived
   ;if NOT IsBot()
      ;fatalErrord("This function is only designed for the Bot", A_LineNumber, A_ScriptName, A_ThisFunc, A_ThisLabel)
   ;fatalIfNotThisPC("BAUSTIANVM")

   datestamp := CurrentTime("hyphendate")
   needle=^%datestamp%
   iniFolder := EnsureEndsWith(iniFolder, "\")

   Loop, %IniFolder%*
   {
      deout .= "`n"
      shouldArchive := true
      destination=%IniFolder%archive\%A_LoopFileName%

      if RegExMatch(A_LoopFileName, needle)
         shouldArchive := false

      if shouldArchive
      {
         deout .= "ARCHIVE  "
         FileMove(A_LoopFileFullPath, destination)
         archivedFile := true
      }

      deout .= A_LoopFileFullPath
      deout .= " moved to "
      deout .= destination
   }
   ;debug("errord nolog", deout)

   if archivedFile
   {
      AddToTrace("yellow line - archived old fees files")
      QuickFileOutput("archived files:`n" . deout)
   }
}
;}}}

;{{{ former Firefly Check-Ins (monitoring the bot)
ScriptCheckin(CurrentStatus)
{
   iniFolder:=GetPath("FireflyCheckinIniFolder")

   ;doing the checkin with fewer arguments
   whoIsCheckingIn :=  A_ComputerName . "_" . A_ScriptName
   iniPP("FireflyCheckin, yellow line - " . whoIsCheckingIn)
   iniFolderWrite(iniFolder, "ReadableCheckin", whoIsCheckingIn, CurrentTime("hyphenated"))
   iniFolderWrite(iniFolder, "TickCheckin", whoIsCheckingIn, A_TickCount)
   iniFolderWrite(iniFolder, "Status", whoIsCheckingIn, CurrentStatus)
}
;}}}
