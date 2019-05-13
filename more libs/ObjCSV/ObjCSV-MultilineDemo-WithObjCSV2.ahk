#NoEnv
#SingleInstance force
objCollection := ObjCSV_CSV2Collection(A_ScriptDir . "\TheBeatles-Lyrics.txt", strFileHeader, 1, 1)
Loop, % objCollection.MaxIndex()
{
	i := A_Index
	Loop, Parse, strFileHeader, `,
		MsgBox, % A_LoopField . ":`n`n" . objCollection[i][A_LoopField]
}
return
