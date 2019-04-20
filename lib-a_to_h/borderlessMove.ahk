borderlessMove(winId="",key="LButton"){
    winId:=winId?winId:"A"
    bl:=a_batchLines
    winDel:=a_winDelay
    setBatchLines -1
    setWinDelay -1

    winWaitActive,% winId,,0.2
    if(errorlevel)
        return
    winGet,isBorderless,style,A
    winGetPos,,,ww,wh,A
    if(isBorderless & 0xC40000 || (ww=a_ScreenWidth && wh=a_ScreenHeight))
        return
    mouseGetPos,mx,my
    while(getKeyState(key,"P") && winActive(winId)){
        mouseGetPos,mmx,mmy
        if(mmx!=mx || mmy!=my){
            winGetPos,vlx,vly,,,A
            winMove,A,,% vlx-(mx-mmx),% vly-(my-mmy)
            mx:=mmx
            my:=mmy
            sleep 0
        }else
            sleep 10
    }
    setWinDelay,% winDel
    setBatchLines % bl
}