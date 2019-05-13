#NoEnv
#SingleInstance force
objCollection := ObjCSV_CSV2Collection(A_ScriptDir . "\TheBeatles-Lyrics.txt", strFileHeader, 1, 1)
loop, % objCollection.MaxIndex()
	for strFieldName, strFieldValue in objCollection[A_Index]
		MsgBox, %strFieldName%:`n`n%strFieldValue%
return
