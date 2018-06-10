; LintaList [standalone script]
; Purpose: Update script for Lintalist
; Version: 1.5
; Date:    20150329

; ChangeButtonNames
; http://ahkscript.org/docs/scripts/MsgBoxButtonNames.htm	  

; CopyFilesAndFolders (AHK Docs)
; http://ahkscript.org/docs/commands/FileCopy.htm

; AutoHotkey wrapper for Windows native Zip feature by Coco
; http://ahkscript.org/boards/viewtopic.php?f=6&t=3892
; https://github.com/cocobelgica/AutoHotkey-ZipFile

; VersionCompare by boiler 
; http://ahkscript.org/boards/viewtopic.php?f=6&t=5959


DetectHiddenWindows, On
SetTitleMatchMode, 2

SetWorkingDir, %A_ScriptDir%\..

IniRead, beta, version.ini, settings, beta
if (beta=1)
	{
	 MsgBox, 48, Disabled, This is a beta-release of Lintalist`nChecking for updates has been disabled.
	 ExitApp
	}

TrayTip, Checking ..., Checking for updates

SplitPath, A_ScriptDir, , LintalistFolder
UnpackFolder:=LintalistFolder "\tmpscrpts"

FileDelete, %UnpackFolder%\checkupdate.ini
FileDelete, %UnpackFolder%\update.zip

URLDownloadToFile, https://raw.githubusercontent.com/lintalist/lintalist/master/version.ini, %UnpackFolder%\checkupdate.ini
                   
IniRead, currentversion, %LintalistFolder%\version.ini, settings, version
If (currentversion = "ERROR")
	{
	 MsgBox, 16, Error, Can't read %LintalistFolder%\version.ini file
	 ExitApp
	}
IniRead, checkversion, %UnpackFolder%\checkupdate.ini, settings, version
IniRead, checkauto   , %UnpackFolder%\checkupdate.ini, settings, auto
If (checkversion = "ERROR") or (checkauto = "ERROR")
	{
	 MsgBox, 16, Error, Can't read %UnpackFolder%\checkupdate.ini file
	 ExitApp
	}

If VersionCompare(currentversion, checkversion) < 2
	{
	 MsgBox, 64, No update, No update available...
	 ExitApp
	}

If (checkauto = 0)
	{
	 MsgBox, 16, Error, Automatic update not possible, read the release notes first.
	 Run, https://github.com/lintalist/lintalist/releases
	 ExitApp
	}

SetTimer, ChangeButtonNames, 10
MsgBox, 4150, Update, There is a Lintalist update.`nNew version: v%checkversion%`nDo you wish to download and install update?
IfMsgBox, TryAgain
	{
	 Run, https://github.com/lintalist/lintalist/releases
	 ExitApp
	}
Else IfMsgBox, Continue
	ExitApp

UrlDownloadToFile, https://github.com/lintalist/lintalist/archive/master.zip, %UnpackFolder%\update.zip
If (ErrorLevel = 1 )
	{
	 MsgBox, 16, Error, Downloading the update failed
	 ExitApp
	}

FileRemoveDir, %UnpackFolder%\lintalist-master, 1

BackupZip:=UnpackFolder "\Backup-" A_Now ".zip"
backup := new ZipFile(BackupZip)

backup.pack("bundles")
backup.pack("docs")
backup.pack("Extras")
backup.pack("icons")
backup.pack("include")
backup.pack("local")
backup.pack("plugins")
backup.pack("changelog.md")
backup.pack("Settings.ini")
backup.pack("lintalist.ahk")
backup.pack("version.ini")
backup.pack("readme.md")

zip := new ZipFile(UnpackFolder "\update.zip")
zip.unpack(, UnpackFolder)

WinClose, %LintalistFolder%\lintalist.ahk
Sleep, 1000 

; From the AHK docs:
; The following copies all files and folders inside a folder to a different folder:
ErrorCount := CopyFilesAndFolders( UnpackFolder "\lintalist-master\*.*", LintalistFolder, true)
if ErrorCount <> 0
    MsgBox %ErrorCount% files/folders could not be copied.

WinClose, %LintalistFolder%\lintalist.ahk
Sleep, 1000 

FileRemoveDir, %UnpackFolder%\lintalist-master, 1
FileDelete, %UnpackFolder%\checkupdate.ini
FileDelete, %UnpackFolder%\update.zip

Run, %LintalistFolder%\lintalist.ahk

MsgBox, 64, Updated, Lintalist has been updated.`nA backup is made and can be found in:`n%BackupZip%

ExitApp

; ---------------------------------------------------------------------------

; VersionCompare function by boiler at ahkscript.org - boiler
; Compares versions where simple string comparison can fail, such as 9.1.3.2 and 10.1.3.5
; Both version numbers are in format n1[.n2.n3.n4...] where each n can be any number of digits.
; Fills in zeros for missing sections for purposes of comparison (e.g., comparing 9 to 8.1).
; Not limited to 4 sections.  Can handle 5.3.2.1.6.19.6 (and so on) if needed.
; Returns 1 if version1 is more recent, 2 if version 2 is more recent, 0 if they are the same.
; http://ahkscript.org/boards/viewtopic.php?f=6&t=5959

VersionCompare(version1, version2)
	{
	 StringSplit, verA, version1, .
	 StringSplit, verB, version2, .
	 Loop, % (verA0> verB0 ? verA0 : verB0)
		{
		 if (verA0 < A_Index)
			verA%A_Index% := "0"
		 if (verB0 < A_Index)
			verB%A_Index% := "0"
		 if (verA%A_Index% > verB%A_Index%)
			return 1
		 if (verB%A_Index% > verA%A_Index%)
			return 2
		}
	 return 0
	}

ChangeButtonNames: ; http://ahkscript.org/docs/scripts/MsgBoxButtonNames.htm	  
IfWinNotExist, Update ahk_class #32770
    Return  ; Keep waiting...
SetTimer, ChangeButtonNames, off 
; WinActivate 
ControlSetText, Button1, Update, Update ahk_class #32770
If (checkauto = 1)
	ControlSetText, Button2, Release notes, Update ahk_class #32770
else If (checkauto = 0)	
	ControlSetText, Button2, Release notes!!, Update ahk_class #32770
ControlSetText, Button3, Cancel, Update ahk_class #32770
Return

; CopyFilesAndFolders
; http://ahkscript.org/docs/commands/FileCopy.htm

CopyFilesAndFolders(SourcePattern, DestinationFolder, DoOverwrite = false) 
; Copies all files and folders matching SourcePattern into the folder named DestinationFolder and
; returns the number of files/folders that could not be copied.
{
    ; First copy all the files (but not the folders):
    FileCopy, %SourcePattern%, %DestinationFolder%, %DoOverwrite%
    ErrorCount := ErrorLevel
    ; Now copy all the folders:
    Loop, %SourcePattern%, 2  ; 2 means "retrieve folders only".
    {
        FileCopyDir, %A_LoopFileFullPath%, %DestinationFolder%\%A_LoopFileName%, %DoOverwrite%
        ErrorCount += ErrorLevel
        if ErrorLevel  ; Report each problem folder by name.
            MsgBox Could not copy %A_LoopFileFullPath% into %DestinationFolder%
    }
    return ErrorCount
}

; AutoHotkey wrapper for Windows native Zip feature
; https://github.com/cocobelgica/AutoHotkey-ZipFile
#include %A_ScriptDir%\ZipFile.ahk

