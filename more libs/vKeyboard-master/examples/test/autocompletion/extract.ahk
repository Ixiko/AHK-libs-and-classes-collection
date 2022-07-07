#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
freqrnc2011 := (f:=FileOpen(A_ScriptDir . "\freqrnc2011.csv", 4+0, "utf-8")).read(), f.close()
freqrnc2011 := RegExReplace(freqrnc2011, "\t.+?\n", "`n")
StringTrimLeft, freqrnc2011, % freqrnc2011, 6
Sort, freqrnc2011, D`n U
FileAppend % freqrnc2011, % A_ScriptDir . "\ru", utf-8
