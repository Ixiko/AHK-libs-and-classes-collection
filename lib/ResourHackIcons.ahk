ResourHackIcons(dotIcoFile)
{
	if !A_IsCompiled
		return
	msgbox This will attempt to change the included icons inside the binary file.`n`nThis may not work!`n`nOnly .ico files are compatible.`n`nThe program will close and attempt the operation. This will take around 10 seconds.
	FileCreateDir, %A_Temp%\Resource Hacker
	FileInstall, Included Files\Resource Hacker\Dialogs.def, %A_Temp%\Resource Hacker\Dialogs.def, 1 
	FileInstall, Included Files\Resource Hacker\ResHacker.cnt, %A_Temp%\Resource Hacker\ResHacker.cnt, 1 
	FileInstall, Included Files\Resource Hacker\ResHacker.exe, %A_Temp%\Resource Hacker\ResHacker.exe, 1 
	FileInstall, Included Files\Resource Hacker\ResHacker.hlp, %A_Temp%\Resource Hacker\ResHacker.hlp, 1 
	FileInstall, Included Files\Resource Hacker\ResHacker.ini, %A_Temp%\Resource Hacker\ResHacker.ini, 1 

	Rscript := "[FILENAMES]"
			.	"`nExe= " A_ScriptFullPath
			. "`nSaveAs= " A_ScriptFullPath
			. "`n[COMMANDS]"
		;	. "`n-addoverwrite " dotIcoFile ", ICONGROUP,MAINICON,0"
			. "`n-addoverwrite " dotIcoFile ", icon, 159,"
			. "`n-addoverwrite " dotIcoFile ", icon, 160,"
			. "`n-addoverwrite " dotIcoFile ", icon, 206,"
			. "`n-addoverwrite " dotIcoFile ", icon, 207,"
			. "`n-addoverwrite " dotIcoFile ", icon, 208,"
			. "`n-addoverwrite " dotIcoFile ", icon, 228,"
			. "`n-addoverwrite " dotIcoFile ", icon, 229,"
			. "`n-addoverwrite " dotIcoFile ", icon, 230,"

	FileDelete, %A_Temp%\Resource Hacker\Rscript.txt
	FileAppend, %Rscript%, %A_Temp%\Resource Hacker\Rscript.txt

	AhkScript := "#NoEnv"
		. "`n#SingleInstance force"
		. "`nSetWorkingDir %A_ScriptDir%"
		. "`nsleep 4000" ;give time for macro trainer to close so can open in reshackers
		. "`nRun,  %A_Temp%\Resource Hacker\ResHacker.exe -script Rscript.txt"
		. "`nRun,  ResHacker.exe -script Rscript.txt, %A_Temp%\Resource Hacker\"
		. "`nmsgbox I just tried to change the included icon files``nDon't know if it worked.``n``nPress ok to re-launch the macro-trainer to find out"
		. "`nrun, " A_ScriptFullPath ;attempt to launch the original program
		. "`nExitapp"

		DynaRun(AhkScript, "ChangeIcon.AHK", A_Temp "\AHK.exe") 
		ExitApp
}


/*
there comes a help file with reshacker


Command Line Scripting:

All the functionality of the Resource Hacker GUI (apart from viewing resources) can be accessed from the command line without having to open Resource Hacker. Command line scripting can remove the drudgery entailed with repetitive Resource Hacker tasks.

Command line scripts have 2 general forms:

1. Single commands:

ResHacker.exe command command_parameters
2. Multiple commands:
ResHacker.exe -script scriptfile


Single Commands:

command and command_parameters:
-add ExeFile, SaveAsFile, ResourceFile, ResourceMask
-addskip ExeFile, SaveAsFile, ResourceFile, ResourceMask
-addoverwrite ExeFile, SaveAsFile, ResourceFile, ResourceMask
-modify ExeFile, SaveAsFile, ResourceFile, ResourceMask

-extract ExeFile, ResourceFile, ResourceMask
-delete ExeFile, SaveAsFile, ResourceMask

Each command parameter must be separated by a comma, but no comma is expected before the first parameter.

If paths are not included with filenames, then the operating systems current folder is presumed to contain the named file. It is generally good practice, though not required here, to enclose filenames containing spaces within double quotes.

The ResourceMask enables a command to be performed on either single or multiple resource items and takes the form ResType,ResName,ResLang. If ResType is a predefined type, then either its number or identifier can be used e.g. the ResourceMask dialog,128,0 is identical to 5,128,0. Any or all of the ResourceMask items can be omitted e.g. dialog,, indicates that all dialogs are to be applied to the command irrespective of name or language, and ,,1049 indicates that all resources with Russian (1049) as the languageID will be applied to the command. An empty ResourceMask ,, indicates that the command will be applied to every resource irrespective of type, name or language.

When adding or modifying items, the ResourceFile can be a RES file for any item type, a BMP file for BITMAP types, a CUR file for CURSORGROUP types, an ICO file for ICONGROUP types, and any file type for RCDATA and user defined resource types.

When adding and modifying resources from files other than RES files then both ResType and ResName must be specified in the ResourceMask. If ResLang is omitted then the command applies to the first language item with matching type and name, otherwise, if no matching item exists then language neutral (0) is assumed.

When extracting resources, and more than one item is implied by the ResourceMask, then the specified ResourceFile must be either a RES file or an RC file. When binary image resources are extracted to RC files, each image is also created as a separate binary (ICO, CUR, BMP, GIF, BIN) file. See the example below.

ICON and CURSOR resources cannot be manipulated directly but are added, deleted, modified and extracted by using their respective ICONGROUP or CURSORGROUP. ICON and CURSOR can still be used but Resource Hacker will assume ICONGROUP or CURSORGROUP was intended.

Borlands DFM files can also be added irrespective of whether the file is in binary or text format. However, they will always be extracted in text format (To convert text-formatted dfm files to binary format, use Borlands utility Convert.exe).

All actions or errors are logged to ResHacker.log.

NB: If a script does not produce the desired results then check the log!

Examples: (File paths have been omitted for clarity)

To add or update dialog name:maindlg lang:0 in MyProg.exe from UpdDlg.res
ResHacker.exe -addoverwrite MyProg.exe, MyProgNew.exe, UpdDlg.res, dialog,maindlg,0

To add or update bitmap name:128 in MyProg.exe from NewImage.bmp
ResHacker.exe -addoverwrite MyProg.exe, MyProgNew.exe, NewImage.bmp , bitmap,128,

To add or update all bitmaps in MyProg.exe from Images.res
ResHacker.exe -addoverwrite MyProg.exe, MyProgNew.exe, Images.res, bitmap,,

To add a user-defined binary resource (README,1,0) to MyProg.exe from ReadMe.html
ResHacker.exe -addoverwrite MyProg.exe, MyProgNew.exe, ReadMe.html, readme,1,0

To add all items in Images.res to MyProg.exe (but fail if any item already exists)
ResHacker.exe -add MyProg.exe, MyProgNew.exe, Images.res ,,,

To add all items in Images.res to MyProg.exe (skipping any existing items)
ResHacker.exe -addskip MyProg.exe, MyProgNew.exe, Images.res ,,,

To modify all items in MyProg.exe with the items in Images.res (ignoring any items in Images.res which do not exist in MyProg.exe)
ResHacker.exe -modify MyProg.exe, MyProgNew.exe, Images.res , , ,

To extract all icons from MyProg.exe to MyProgIcons.rc (creating MyProgIcons.rc, Icon_1.ico, Icon_2.ico , Icon_3.ico etc...)
ResHacker.exe -extract MyProg.exe, MyProgIcons.rc, icongroup,,

To delete GIF name:128 from MyProg.exe
ResHacker.exe -delete MyProg.exe, MyProgNew.exe, gif,128,

Multiple Commands:

syntax: ResHacker.exe -script ScriptFile
ScriptFile is a text file with the following layout:

//comments are preceded by double slashes
[FILENAMES]
Exe=
SaveAs=
Log=

[COMMANDS]
-add ResourceSrc, ResourceMask
-addskip ResourceSrc, ResourceMask
-addoverwrite ResourceSrc, ResourceMask
-addoverwrite ResourceSrc, ResourceMask
-modify ResourceSrc, ResourceMask

-extract ResourceTgt, ResourceMask
-delete ResourceMask

If Log is omitted then the default log ResHacker.log will be used.
NB: If a script does not produce the desired results then check the log!

Examples:

rh_script_myprog_rus.txt -

//This script deletes all Language Neutral (0)
//string-table, menu and dialog resource items
//in MyProg.exe before replacing them
//with Russian (1049) items...

[FILENAMES]
Exe= MyProg.exe
SaveAs= MyProg_Rus.exe
Log= MyProg_Rus.log

[COMMANDS]
-delete MENU,,0
-delete DIALOG,,0
-delete STRINGTABLE,,0
-add MyProg_Rus.res, MENU,,1049
-add MyProg_Rus.res, DIALOG,,1049
-add MyProg_Rus.res, STRINGTABLE,,1049


rh_script_myprog_upd_images.txt -

//This script updates 2 bitmaps and an
//icon in MyProg.exe ...

[FILENAMES]
Exe= MyProg.exe
SaveAs= MyProg_Updated.exe

[COMMANDS]
-addoverwrite Bitmap128.bmp, BITMAP,128,
-addoverwrite Bitmap129.bmp, BITMAP,129,0
-addoverwrite MainIcon.ico, ICONGROUP,MAINICON,0


rh_script_myprog_upd_all.txt -

//This script replaces all resources
//in MyProg.exe with all the resources
//in MyProgNew.res

[FILENAMES]
Exe= MyProg.exe
SaveAs= MyProg_Updated.exe

[COMMANDS]
-delete ,,, //delete all resources before...
-add MyProgNew.res ,,, //adding all the new resources 

; delete the original ahk script inside the exe
-delete RCdata, ">AHK WITH ICON<", 1033
; insert a new script
-addoverwrite newScript.txt, RCdata, ">AHK WITH ICON<", 1033

Notice how these require quotes even when the ini file doesnt have spaces!
-delete RCdata, "MT_CONFIG.INI", 1033
-addoverwrite new.txt, RCdata, "CONFIG.INI", 1033
Dont have to call delete first 
-addoverwrite new.txt, RCdata, "CONFIG.INI", 1033


*/