/*
class: PROGDLG
an enumeration class containing the possible flags for IOperationsProgressDialog::StartProgressDialog() and IProgressDialog::StartProgressDialog().

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/PROGDLG)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb775380) (part I)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb775262) (part II)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 2000 Professional / Windows XP / Windows 2000 Server; Windows Vista / Windows Server 2008 or higher (see msdn)
*/
class PROGDLG
{
	/*
	Field: NORMAL
	Default, normal progress dialog behavior.
	*/
	static NORMAL := 0x00000000

	/*
	Field: MODAL
	The dialog is modal to its hwndOwner. The default setting is modeless.
	*/
	static MODAL := 0x00000001

	/*
	Field: AUTOTIME
	Update "Line3" text with the time remaining. This flag does not need to be implicitly set because progress dialogs started by IOperationsProgressDialog::StartProgressDialog automatically display the time remaining.
	*/
	static AUTOTIME := 0x00000002

	/*
	Field: NOTIME
	Do not show the time remaining. We do not recommend setting this flag through IOperationsProgressDialog because it goes against the purpose of the dialog.
	*/
	static NOTIME := 0x00000004

	/*
	Field: NOMINIMIZE
	Do not display the minimize button.
	*/
	static NOMINIMIZE := 0x00000008

	/*
	Field: NOPROGRESSBAR
	Do not display the progress bar.
	*/
	static NOPROGRESSBAR := 0x00000010

	/*
	Field: MARQUEEPROGRESS
	This flag is invalid with StartProgressDialog. To set the progress bar to marquee mode, use the flags in IOperationsProgressDialog::SetMode.
	*/
	static MARQUEEPROGRESS := 0x00000020

	/*
	Field: NOCANCEL
	Do not display a cancel button because the operation cannot be canceled. Use this value only when absolutely necessary.
	*/
	static NOCANCEL := 0x00000040

	/*
	Field: DEFAULT
	*Windows 7 and later.* Indicates default, normal operation progress dialog behavior. Same as <NORMAL>.
	*/
	static DEFAULT := 0x00000000

	/*
	Field: ENABLEPAUSE
	Display a pause button. Use this only in situations where the operation can be paused.
	*/
	static ENABLEPAUSE := 0x00000080

	/*
	Field: ALLOWUNDO
	The operation can be undone through the dialog. The Stop button becomes Undo. If pressed, the Undo button then reverts to Stop.
	*/
	static ALLOWUNDO := 0x000000100

	/*
	Field: DONTDISPLAYSOURCEPATH
	Do not display the path of source file in the progress dialog.
	*/
	static DONTDISPLAYSOURCEPATH := 0x00000200

	/*
	Field: DONTDISPLAYDESTPATH
	Do not display the path of the destination file in the progress dialog.
	*/
	static DONTDISPLAYDESTPATH := 0x00000400

	/*
	Field: NOMULTIDAYESTIMATES
	*Windows 7 and later.* If the estimated time to completion is greater than one day, do not display the time.
	*/
	static NOMULTIDAYESTIMATES := 0x00000800

	/*
	Field: DONTDISPLAYLOCATIONS
	*Windows 7 and later.* Do not display the location line in the progress dialog.
	*/
	static DONTDISPLAYLOCATIONS := 0x00001000
}