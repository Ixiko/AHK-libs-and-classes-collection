/*
class: PDOPSTATUS
an enumeration class containing the possible return values for IOperationsProgressDialog::GetOperationStatus().

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/PDOPSTATUS)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb762519)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows Vista / Windows Server 2008 or higher
*/
class PDOPSTATUS
{
	/*
	Field: RUNNING
	Operation is running, no user intervention.
	*/
	static RUNNING := 1

	/*
	Field: PAUSED
	Operation has been paused by the user.
	*/
	static PAUSED := 2

	/*
	Field: CANCELLED
	Operation has been canceled by the user - now go undo.
	*/
	static CANCELLED := 3

	/*
	Field: STOPPED
	Operation has been stopped by the user - terminate completely.
	*/
	static STOPPED := 4

	/*
	Field: ERRORS
	Operation has gone as far as it can go without throwing error dialogs.
	*/
	static ERRORS := 5
}