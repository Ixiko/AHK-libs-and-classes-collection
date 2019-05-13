#NoEnv
#SingleInstance force
objCollection := ObjCSV_CSV2Collection(A_ScriptDir . "\TheBeatles-Lyrics.txt", strFileHeader, 1, 1)
ObjCSV_Collection2CSV(objCollection, A_ScriptDir . "\TheBeatles-Lyrics-SingleLine.txt", 1, strFileHeader, , 1, , , "¶")
run, %A_ScriptDir%\TheBeatles-Lyrics-SingleLine.txt
return
