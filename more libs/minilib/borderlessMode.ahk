borderlessMode(winId=""){
    winId:=winId?winId:"A"
    winSet,alwaysOnTop,toggle,% winId
    winSet,style,^0xC40000,% winId
    winGetPos,,,winw,,% winId
    winMove,A,,,,% winw+5
    winMove,A,,,,% winw
}