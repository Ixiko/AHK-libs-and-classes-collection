/*
Example: Demonstrates the usage of *ShellItem.ahk*

Authors:
	- hoppfrosch (https://github.com/hoppfrosch)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 7, Windows Server 2008 R2 or higher
	Classes - _CCF_Error_Handler_, CCFramework, Unknown, ShellItem
	Constant Classes - SIGDN, SFGAO
*/
#SingleInstance
#include ..\..\_CCF_Error_Handler_.ahk
#include ..\..\CCFramework.ahk
#Include ..\..\Unknown\Unknown.ahk
#Include ..\ShellItem.ahk
#Include ..\..\Constant Classes\SIGDN.ahk
#Include ..\..\Constant Classes\SFGAO.ahk
#Include ..\..\Constant Classes\KNOWNFOLDERID.ahk


; #############################################
; Explicit filepath
shItem := ShellItem.FromAbsolutePath(A_AhkPath)

; display a few names
MsgBox % "NORMALDISPLAY: <" shItem.GetDisplayName() ">`nFILESYSPATH: <" shItem.GetDisplayName(SIGDN.FILESYSPATH) ">`nDESKTOPABSOLUTEEDITING: <" shItem.GetDisplayName(SIGDN.DESKTOPABSOLUTEEDITING) ">`nPARENTRELATIVEFORADDRESSBAR: <" shItem.GetDisplayName(SIGDN.PARENTRELATIVEFORADDRESSBAR) ">"

; checking some attributes
ret := shItem.GetAttributes((SFGAO.HASPROPSHEET | SFGAO.ENCRYPTED | SFGAO.FOLDER | SFGAO.BROWSABLE), bits)
; to display wheter the flag is set or not, we use Utility function - or some bitwise operations
MsgBox % "HASPROPSHEET: <" CCFramework.HasEnumFlag(bits, SFGAO.HASPROPSHEET) ">`nENCRYPTED: <" CCFramework.HasEnumFlag(bits,SFGAO.ENCRYPTED) ">`nFOLDER: <" ((bits & SFGAO.FOLDER) > 0) ">`nBROWSABLE: <" ((bits & SFGAO.BROWSABLE) > 0) ">" 

; ############################################
; Known Folder
shItem := ShellItem.FromKNOWNFOLDERID(KNOWNFOLDERID.PublicDocuments)
MsgBox % "NORMALDISPLAY: <" shItem.GetDisplayName() ">`nFILESYSPATH: <" shItem.GetDisplayName(SIGDN.FILESYSPATH) ">`nDESKTOPABSOLUTEEDITING: <" shItem.GetDisplayName(SIGDN.DESKTOPABSOLUTEEDITING) ">`nPARENTRELATIVEFORADDRESSBAR: <" shItem.GetDisplayName(SIGDN.PARENTRELATIVEFORADDRESSBAR) ">"

ret := shItem.GetAttributes((SFGAO.HASPROPSHEET | SFGAO.ENCRYPTED | SFGAO.FOLDER | SFGAO.BROWSABLE), bits)
MsgBox % "HASPROPSHEET: <" CCFramework.HasEnumFlag(bits, SFGAO.HASPROPSHEET) ">`nENCRYPTED: <" CCFramework.HasEnumFlag(bits,SFGAO.ENCRYPTED) ">`nFOLDER: <" CCFramework.HasEnumFlag(bits,SFGAO.FOLDER) ">`nBROWSABLE: <" CCFramework.HasEnumFlag(bits,SFGAO.BROWSABLE) ">"  

; #############################################
; Comparing Known Folder Item vs. Explicit filepath item
path := shItem.GetDisplayName(SIGDN.FILESYSPATH)
shItem2 := ShellItem.FromAbsolutePath(path)
MsgBox % "Compare: <" (shItem2.Compare(shItem)=0?"Equal":"Not Equal") ">"

ExitApp