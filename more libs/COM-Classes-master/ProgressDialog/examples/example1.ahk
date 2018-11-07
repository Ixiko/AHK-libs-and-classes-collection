/*
Example: Demonstrates the usage of *ProgressDialog.ahk*
	* Showing a system progress dialog
	* Setting custom messages

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 2000 Professional / Windows XP or Windows Server 2003 or higher.
	Classes - _CCF_Error_Handler_, CCFramework, Unknown, ProgressDialog
*/
#SingleInstance
#include ..\..\_CCF_Error_Handler_.ahk
#Include ..\..\CCFramework.ahk
#Include ..\..\Unknown\Unknown.ahk
#Include ..\ProgressDialog.ahk

progress := new ProgressDialog ; create a new instance
progress.SetTitle("This is a demo script") ; set the title
progress.SetLine(1, "This script shows you the power of COM.") ; set line text
progress.SetLine(2, "To do so, it uses the IProgressDialog COM interface.")
progress.SetLine(3, "This is even possible with AHK basic, without native COM support!")
progress.SetCancelMsg("You canceled the dialog. Please wait.")

if (!progress.StartProgressDialog()) ; show the dialog
	ExitApp

Loop 100
{
	progress.SetProgress(A_Index, 100) ; update progress
	sleep 500
	if (progress.HasUserCanceled()) ; if user canceled:
	{
		sleep 2000 ; let him read cancel msg
		break
	}
}

progress.SetLine(2, "The script finished now and will exit in a few seconds...")
progress.SetLine(3, "Bye Bye!")
sleep 3000
progress.StopProgressDialog() ; close the dialog