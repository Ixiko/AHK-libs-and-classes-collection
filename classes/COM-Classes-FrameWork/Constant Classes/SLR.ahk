/*
class: SLR
an enumeration class containing flags that specify how to find the target of a shell link.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/SLR)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb774952)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows XP / Windows 2000 Server or higher
*/
class SLR
{
	/*
	Field: NO_UI
	Do not display a dialog box if the link cannot be resolved. When <NO_UI> is set, the high-order word of fFlags (in IShellLink::Resolve) can be set to a time-out value that specifies the maximum amount of time to be spent resolving the link. The function returns if the link cannot be resolved within the time-out duration. If the high-order word is set to zero, the time-out duration will be set to the default value of 3,000 milliseconds (3 seconds). To specify a value, set the high word of fFlags to the desired time-out duration, in milliseconds.
	*/
	static NO_UI := 0x0001

	/*
	Field: ANY_MATCH
	Not used.
	*/
	static ANY_MATCH := 0x0002

	/*
	Field: UPDATE
	If the link object has changed, update its path and list of identifiers. If <UPDATE> is set, you do not need to call IPersistFile::IsDirty to determine whether the link object has changed.
	*/
	static UPDATE := 0x0004

	/*
	Field: NOUPDATE
	Do not update the link information.
	*/
	static NOUPDATE := 0x0008

	/*
	Field: NOSEARCH
	Do not execute the search heuristics.
	*/
	static NOSEARCH := 0x0010

	/*
	Field: NOTRACK
	Do not use distributed link tracking.
	*/
	static NOTRACK := 0x0020

	/*
	Field: NOLINKINFO
	Disable distributed link tracking. By default, distributed link tracking tracks removable media across multiple devices based on the volume name. It also uses the UNC path to track remote file systems whose drive letter has changed. Setting <NOLINKINFO> disables both types of tracking.
	*/
	static NOLINKINFO := 0x0040

	/*
	Field: INVOKE_MSI
	Call the Windows Installer.
	*/
	static INVOKE_MSI := 0x0080

	/*
	Field: NO_UI_WITH_MSG_PUMP
	*Windows XP and later.*
	*/
	static NO_UI_WITH_MSG_PUMP := 0x0101

	/*
	Field: OFFER_DELETE_WITHOUT_FILE
	*Windows 7 and later.* Offer the option to delete the shortcut when this method is unable to resolve it, even if the shortcut is not a shortcut to a file.
	*/
	static OFFER_DELETE_WITHOUT_FILE := 0x0200

	/*
	Field: KNOWNFOLDER
	*Windows 7 and later.* Report as dirty if the target is a known folder and the known folder was redirected. This only works if the original target path was a file system path or ID list and not an aliased known folder ID list.
	*/
	static KNOWNFOLDER := 0x0400

	/*
	Field: MACHINE_IN_LOCAL_TARGET
	*Windows 7 and later.* Resolve the computer name in UNC targets that point to a local computer.
	*/
	static MACHINE_IN_LOCAL_TARGET := 0x0800

	/*
	Field: UPDATE_MACHINE_AND_SID
	*Windows 7 and later.* Update the computer GUID and user SID if necessary.
	*/
	static UPDATE_MACHINE_AND_SID := 0x1000
}