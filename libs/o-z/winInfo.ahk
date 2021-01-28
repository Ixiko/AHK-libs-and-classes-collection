winInfo(winName:="A"){
    winGet,awp,processName,% winName
    winGet,awpid,PID,% winName
    winGetTitle,awn,ahk_pid %awpid%
    winGetPos,awx,awy,aww,awh,ahk_pid %awpid%
    winGetClass,awc,% winName
    winGet,awhwnd,ID,% winName
    winGet,awcl,controlList,% winName
    return "Window Name: " . awn . "`nW/H: " . aww . "x" . awh . "`nX/Y: " . awx . "," . awy . "`nClass: " . awc . "`nProcess: " . awp . "`nPID: " . awpid . "`nHWND: " . awhwnd . "`nControl List:`n" . awcl
}