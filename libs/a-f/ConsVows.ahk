#Include C:\Program Files (x86)\AutoHotKey\Lib\pythahk.ahk 

SetBatchLines -1 

parm0 = %0% ; Contains the number of parameters passed
parm1 = %1% ; Text searching for


help := 
(
"Input will only accepts C for Consonants and V for Vowels to generate a new word.
Example: Cvccv 
Output: Topxa
Usage from Cmd: C:\ScriptName.ahk Parameter
Commands/Parameters:
help - Displays this help Context
exit - Exits the application
CVcv - Generates a random word based on C Consonants and V for Vowels`n"
)

Process, Exist, cmd.exe
pid := ErrorLevel
msgbox % pid
pid ? DllCall("AttachConsole", "int", -1) : DllCall("AllocConsole")
stdout := FileOpen("*", "w `n")
stdin  := FileOpen("*", "r `n")

if (pid && parm0) {
    generateWord(parm1)
    exit()
} 
else if (pid && parm0 == 0) {
    display("You must include one parameter when running from console ie: file.ahk cvCvCv")
    exit()
}

Loop {
    query := ""
    stdout.Write("Generate a New Word: ")
    stdout.Read(0) ; Flush the write buffer.
    query := RTrim(stdin.ReadLine(), "`n")
    query ~= "i)exit" ? exit()
      : query ~= "i)help" ? display(help)  
      : generateWord(query)   
}

exit() {
    DllCall("FreeConsole")
    exitapp
}

generateWord(values) {
    
    For Each, Char in split(values) {
        if (inStr("c", Char)) {
            newChar := split("".ascii_novowels)[random(0, 19)]
            if (str(Char).isupper())
                newChar := Format("{1:U}", newChar)
            results .= newChar
            }
        else if (InStr("v", Char)) {
            newChar := split("".ascii_vowels)[random(0, 5)]
            if (str(Char).isupper())
                newChar := Format("{1:U}", newChar)
            results .= newChar
        }
        else {
           return display("Input will only accepts C for Consonants and V for Vowels to generate a new word.")
        }
    } 
    display(results)
    return 
}

display(value) {
    global 
    stdout.Write(value "`n") ; Write to Console
    stdout.Read(0) ; Flush the write buffer.\
    return
}

random(x:=0, y:=9) {
    random, o, x, y
    return o
}