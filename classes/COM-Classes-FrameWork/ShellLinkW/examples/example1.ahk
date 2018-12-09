/*
Example: Demonstrates the usage of *ShellLinkW.ahk*
	* Creating a new shell link (shortcut)
	* Setting its properties
	* Saving it to a file.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows XP / Windows 2000 Server or higher
	Classes - _CCF_Error_Handler_, CCFramework, Unknown, ShellLinkW, Persist, PersistFile
*/
#SingleInstance off
#include ..\..\_CCF_Error_Handler_.ahk
#include ..\..\CCFramework.ahk
#include ..\..\Unknown\Unknown.ahk
#include ..\ShellLinkW.ahk
#include ..\..\Persist\Persist.ahk
#include ..\..\PersistFile\PersistFile.ahk

link := new ShellLinkW() ; create a shell link

link.SetPath(A_Comspec) ; set the target + other properties of the link
link.SetDescription("this is a test file by an AHK script")
link.SetIconLocation(A_WinDir "\system32\imageres.dll", 23)
link.SetWorkingDirectory(A_MyDocuments)
link.SetArguments("/k `"echo Hi! This is a test.`"")

file := new PersistFile(link.QueryInterface(PersistFile.IID)) ; get a PersistFile instance for the link

file.Save(A_Desktop "\comspec.lnk.lnk", true) ; save the link to a file (somehow the '.lnk' is trucated...)
MsgBox Saved the shell link to %A_Desktop%\comspec.lnk ; report to user