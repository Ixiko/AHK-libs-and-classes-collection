; #Include RPath.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; From Path2 to Path1

Path1 = ahkstdlib\samp\foo\bar
Path2 = ahkstdlib\samp
p = Path1=%Path1%`nPath2=%Path2%`n`n
MsgBox, % p . "> RPath_Relative(Path1, Path2)`n`n" . RPath_Relative(Path1, Path2)

Path1 = \\server.com\user\Files\Docs\Code\AHK\SciTEDirector\includes
Path2 = ..\..\SmartGui\no_commit\icons_dev
p = Path1=%Path1%`nPath2=%Path2%`n`n
MsgBox, % p . "> RPath_Absolute(Path1, Path2)`n`n" . RPath_Absolute(Path1, Path2)
