/*
class: TBPFLAG
an enumeration class containing flags that control the current state of the progress button.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/TBPFLAG)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/dd391697)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 7 / Windows Server 20008 R2
*/
class TBPFLAG
{
	/*
	Field: NOPROGRESS
	Stops displaying progress and returns the button to its normal state. Use this flag to dismiss the progress bar when the operation is complete or canceled.
	*/
	static NOPROGRESS := 0x00000000

	/*
	Field: INDETERMINATE
	The progress indicator does not grow in size, but cycles repeatedly along the length of the taskbar button. This indicates activity without specifying what proportion of the progress is complete. Progress is taking place, but there is no prediction as to how long the operation will take.
	*/
	static INDETERMINATE := 0x00000001

	/*
	Field: NORMAL
	The progress indicator grows in size from left to right in proportion to the estimated amount of the operation completed. This is a determinate progress indicator; a prediction is being made as to the duration of the operation.
	*/
	static NORMAL := 0x00000002

	/*
	Field: ERROR
	The progress indicator turns red to show that an error has occurred in one of the windows that is broadcasting progress. This is a determinate state. If the progress indicator is in the indeterminate state, it switches to a red determinate display of a generic percentage not indicative of actual progress.
	*/
	static ERROR := 0x00000004

	/*
	Field: PAUSED
	The progress indicator turns yellow to show that progress is currently stopped in one of the windows but can be resumed by the user. No error condition exists and nothing is preventing the progress from continuing. This is a determinate state. If the progress indicator is in the indeterminate state, it switches to a yellow determinate display of a generic percentage not indicative of actual progress.
	*/
	static PAUSED := 0x00000008	
}