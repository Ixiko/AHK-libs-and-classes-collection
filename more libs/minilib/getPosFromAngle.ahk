getPosFromAngle(ByRef x2,ByRef y2,x1,y1,len,ang){
    ang:= (ang-90) * 0.0174532925
    x2:= x1 + len * cos(ang)
    y2:= y1 + len * sin(ang)
}