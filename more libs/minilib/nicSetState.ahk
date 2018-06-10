; state=0 (disable)
; state=1 (enable)

nicSetState(adapter,state){
    runwait,% "netsh interface set interface """ adapter """ " (state?"enable":"disable"),,hide
}