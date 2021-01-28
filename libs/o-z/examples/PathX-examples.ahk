#include %A_ScriptDir%\..\PathX.ahk

; Try the following example to see the key value pairs of the array returned:
	Px := PathX(A_AhkPath)
	Msgbox,,  Key and values, % ""
		   . "Drive`t:`t"  . Px.Drive  "`n"
		   . "Dir`t:`t"    . Px.Dir    "`n"
		   . "Fname`t:`t"  . Px.fname  "`n"
		   . "Ext`t:`t"    . Px.Ext    "`n"
		   . "Folder`t:`t" . Px.Folder "`n"
		   . "File`t:`t"   . Px.File   "`n"
		   . "Full`t:`t"   . Px.Full

; The first 4 keys Drive, Dir, Fname and Ext can be overwritten with custom values:
	MsgBox,, Change name,         % PathX(A_ScriptName, "FName:Hello World").Full
	MsgBox,, Change drive,        % PathX(A_ScriptName, "Drive:Z:").Full
	MsgBox,, Change path to root, % PathX(A_ScriptName, "Dir:\").Full
	MsgBox,, Change extension,    % PathX(A_ScriptName, "Ext:.txt").Full

; PathX() will resolve relative path to fullpath unconditionally:
	MsgBox,, One level up,        % PathX("\..\" . A_ScriptName).Full
	MsgBox,, Two levels down, % PathX("Sub_folder\Sub_folder\" A_ScriptName).Full

; One may pass multiple parameters as well as shorten the key names to two chars:
; The following example shows how to substitute Drive and Fname in one go.
; Note:Make sure there are no spaces between Key:Value unless it was intended.
	MsgBox,, New path, % PathX(A_ScriptName, "Dr:X:", "Fn:MyScript").Full

; Keys Fprefix and Fsuffix can be used to add prefix/suffix to Fname
	MsgBox,, Prefix Fname,  % PathX(A_ScriptName, "fp:Copy of ").Full
	MsgBox,, Suffix Fname,  % PathX(A_ScriptName, "fs:_001").Full
	MsgBox,, Prefix/Suffix, % PathX(A_ScriptName, "fp:Backup_", "fs:" . "_" . A_Now).Full

; File extension can be kind of prefixed indirectly by suffixing Fname:
	MsgBox,, Prefix extension,  % PathX(A_AhkPath, "fs:.old").Full

; Keys Dprefix and Dsuffix may be used to add prefix/suffix to Dir
	MsgBox,, Prefix/Suffix Dir,  % PathX(A_ScriptName, "Dr:N:", "Dp:\Backup", "Ds:001\").Full

; Within Loop, Files, A_LoopFileName is available but no built-in var for base file name (file name without extension).
; PathX() can be used as follows:
	Loop Files, %A_AhkPath%\..\*.exe
		MsgBox % PathX(A_LoopFileLongPath).FName