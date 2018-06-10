nicRestart(adapter){
    nicSetState(adapter,0),nicSetState(adapter,1)
    ;runwait,% comspec " /c netsh interface set interface """ adapter """ disable&netsh interface set interface """ adapter """ enable",,hide
}