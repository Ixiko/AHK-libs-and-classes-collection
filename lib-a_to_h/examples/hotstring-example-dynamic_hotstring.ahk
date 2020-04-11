;hotstrings("i)Show me\s*=\s*(.*?)\s*\.", "Result: %$1%%A_Space%") ; try: show me = #$&*_+{|<? .
;hotstrings("now#", "%A_Now%") ; try: now#
;hotstrings("(B|b)tw", "%$1%y the way") ; try: Btw or btw
;hotstrings("(\d+)\/(\d+)%", "percent") ; try: 4/50%
;hotstrings("i)omg", "oh my god!") ; try: omg
;hotstrings("i)R\s*\>\s*(\d+)\s*&\s*\<\s*(\d+)\.","[R] > %$1% & R < %$2%") ; try: r>15&<20 .
;hotstrings("\bcolou?r", "rgb(128, 255, 0);") ; try: colour or color
;hotstrings("rkskek", "rkskek123", 3, "ke") ; try: colour or color


;hotstrings("i)myenglish", "myenglish", 3, "ke") ; try: colour or color


;; readFile
Loop, read, .\hotstring\dynamic_hotstring.ini
{
    if (SubStr(Trim(A_LoopReadLine), 1, 1) = "#"){
        Continue
    }

    ; x1:Regex, x2:target, x3:bsCnt, x4:mode
    StringSplit, x, A_LoopReadLine, `,
    regex := Trim(x1)
    trans := Trim(x2)
    bsCnt  := Trim(x3)
    chMode := Trim(x4)
    
    hotstrings(regex, trans, bsCnt, chMode) 
    
    ;MsgBox, %regex%-%trans%-%bsCnt%-%chMode%

    x1 =
    x2 =
    x3 = 
    x4 = 
}

Hotstrings("([A-O])(\d)(\d)([012])\s","expand",3)
Return

Expand:
Send % ($.value(4) = "0" ? "PLOCK_LOW." : "PLOCK.") $.value(1) "." $.value(2) $.value(3) "." $.value(4)
Return

Hotstrings("((\d)p)\s","page",2)
Return

Page:
Send % $.value(1) "." page
Return


