winInfo(winName="A"){
    winGet,awp,processName,% winName
    winGet,awpid,PID,% winName
    winGetTitle,awn,ahk_pid %awpid%
    winGetPos,awx,awy,aww,awh,ahk_pid %awpid%
    winGetClass,awc,% winName
    winGet,awcl,controlList,% winName
    clipboard:="Window Name: " awn "`nW/H: " aww "x" awh "`nX/Y: " awx "," awy "`nClass: " awc "`nProcess: " awp "`nPID: " awpid "`nControl List:`n" awcl
    tool("Window Info saved to clipboard")
}