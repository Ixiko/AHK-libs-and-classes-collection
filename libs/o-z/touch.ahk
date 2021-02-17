/*

Function : Touch(file = "" [, set = "0", WhichTime = "M", Reference = "0"] )
Language : AutoHotkey 1.1+
Author   : hi5
Purpose  : Function to set, store and restore the datetime stamp
           of a file or folder. Useful when you are modifying
           files and if you want to keep the original datetime stamp.
           The datetime stamp properties are stored in a static object.
History  : Version 0.1 - 29 september 2013

Options  :

 file      = file name to (re)store the datetime stamp of.
             If you want to "delete" all stored settings, simply call
             Touch() to clear the static object.

 Set       = 0 Update the datetime stamp of a file or folder to current datetime
               making it a simple shorthand for the FileSetTime command.
               (this is the default if the parameter is blank or omitted)
 Set       = 1 Store the datetime stamp of a file or folder
 Set       = 2 Restore the datetime stamp of a file or folder
 Set       = 3 Update the datetime stamp of a file or folder which was previously
               stored using Set=1

 WhichTime = Which timestamp to get/set. Value: M, C, or A
             M: Modification time (this is the default if the parameter is blank or omitted)
             C: Creation time
             A: Last access time
             More info here:
             - http://www.autohotkey.com/docs/commands/FileGetTime.htm
             - http://www.autohotkey.com/docs/commands/FileSetTime.htm

 Reference = File, use this file's timestamp instead of current time

 Returns ErrorLevel - see AutoHotkey documentation
             - http://www.autohotkey.com/docs/misc/ErrorLevel.htm

Example  :

MsgBox % Touch("file.txt",1) ; store datetime stap
MsgBox % Touch("file.txt")   ; update to current date & time, a shorthand for FileSetTime
MsgBox % "file.txt should be the newest file in the directory."
MsgBox % Touch("file.txt",2) ; restore old datetime stamp
Touch()                      ; free memory

*/

Touch(file = "" , set = "0", WhichTime = "M", Reference = "0") 	{
     static Files

     ; Clear all stored settings
     If (file = "")
   		{
   	 	 Files:=[] ; clear object
   	 	 Return 0
   		}

	 If (Reference = "0")
	 	usetime:=A_Now
	 else
	 	{
 		 IfExist, %Reference%
 		 	FileGetTime, usetime, %Reference%, %WhichTime%
	 	}

	 Found:=0

	 If !InStr(file,"\")
		file:=A_ScriptDir "\" file

   	 If !IsObject(files)
		{
		 Files:=[]
		}

	 ; set = 0 Update the datetime stamp
	 If (Set = 0)
	 	{
	 	 FileSetTime, %usetime%, %file%, %WhichTime%
	  	 Return ErrorLevel
	 	}

	 ; set = 1 Store datetime stamp of a file or folder
	 ; set = 3 Update the datetime stamp of a file or folder which was previously
	 ;         stored (using 1)

     If ((Set = 1) or (Set = 3))
		{
		 Loop, % Files.MaxIndex()
		 	{
		 	 If (Files[A_Index].FileName = file)
		 	 	{
		 	 	 Index:=A_Index
		 	 	 Found++
		 	 	 Break
		 	 	}
		 	}
		 If ((Found = 0) or (Set = 3)) ; either new or update info
		 	{
		 	 If (Set <> 3) ; it is a new file
		 	 	{
	  	 	 	 Index:=Files.MaxIndex() + 1
	  	 	 	 If (Index = "")
	  	 			Index:=1
	  	 		}
	  	 	 If (Reference = "0")
		 	 	FileGetTime, stamp, %file%, %WhichTime%
	 		 else
	 		 	stamp:=usetime
		 	 Files[Index,"FileName"]:=file
		 	 Files[Index,"FileStamp"]:=stamp
		 	 Files[Index,"WhichTime"]:=WhichTime
		 	}
		 Return ErrorLevel
		}

	 ; set = 2 Restore the datetime stamp of a file or folder
	 If (Set = 2)
		{
		 Loop, % Files.MaxIndex()
		 	{
		 	 If (Files[A_Index].FileName = file)
		 	 	{
		 	 	 stamp:=Files[A_Index].FileStamp
		 	 	 WhichTime:=Files[A_Index].WhichTime
		 	 	 FileSetTime, %stamp%, %file%, %WhichTime%
		 	 	 Break
		 	 	}
		 	}
		 Return ErrorLevel
		}

    }
