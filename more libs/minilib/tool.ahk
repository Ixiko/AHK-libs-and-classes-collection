tool(content,wait=2500,x="",y=""){
    tooltip,% content,% x,% y
    setTimer,tOff,% "-" wait
    return
    tOff:
    tooltip
    return
}