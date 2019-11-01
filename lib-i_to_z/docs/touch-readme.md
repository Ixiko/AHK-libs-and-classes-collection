# Touch() - v0.1

Function for AutoHotkey to set, store and restore the datetime stamp of a file or
folder. Useful when you are modifying files and you want to keep the original datetime
stamp. The datetime stamp properties are stored in a static object.

### Touch(file = "" [, set = "0", WhichTime = "M", Reference = "0"] )

**Options:**

* file: file name to (re)store the datetime stamp of. If you want to "delete" all stored settings, simply call Touch() to clear the static object.
* Set:
	* 0: Update the datetime stamp of a file or folder to current datetime making it a simple shorthand for the FileSetTime command. (this is the default if the parameter is blank or omitted)
	* 1: Store the datetime stamp of a file or folder
	* 2: Restore the datetime stamp of a file or folder
	* 3: Update the datetime stamp of a file or folder which was previously stored using Set=1
* WhichTime: Which timestamp to get/set. Value: M, C, or A
	* M: Modification time (this is the default if the parameter is blank or omitted)
	* C: Creation time
	* A: Last access time 
	* More info here:
		- <http://www.autohotkey.com/docs/commands/FileGetTime.htm>
		- <http://www.autohotkey.com/docs/commands/FileSetTime.htm>
* Reference: File, use this file's timestamp instead of current time

Returns: ErrorLevel - see AutoHotkey documentation <http://www.autohotkey.com/docs/misc/ErrorLevel.htm>

