#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

Debug.print("`nDebugging standard excluding")
for k, v in new Range(, , 2.5){
    Debug.print(Format("k: {1:d}, v: {2:01.1f}", k, v))
    Sleep, 100
}

Debug.print("`nDebugging standard including")
for k, v in new RangeE(, , 2.5){
    Debug.print(Format("k: {1:d}, v: {2:01.1f}", k, v))
    Sleep, 100
}

Debug.print("`nDebugging standard excluding")
for k, v in new Range(, -10, -1){
    Debug.print(Format("k: {1:d}, v: {2:d}", k, v))
    Sleep, 100
}

Debug.print("`nDebugging standard including")
for k, v in new RangeE(, -10, -1){
    Debug.print(Format("k: {1:d}, v: {2:d}", k, v))
    Sleep, 100
}

Debug.print("`nDebugging standard excluding")
for k, v in new Range(, -10, -1).toArray(){
    Debug.print(Format("k: {1:d}, v: {2:d}", k, v))
    Sleep, 100
}

ExitApp


Class Debug{
    print(message := "no message received"){
        OutputDebug, % message
    }
}


#Include Range.ahk