; Parts unnecessary for this script have been removed from the lib

class line {
    angle(p1,p2) { ; angle returned as multiple of 360 deg. ie, 180 deg = 0.5 etc
        dx:=p2.x-p1.x
       ,dy:=p2.y-p1.y
       ,add:= dx>0? 0: 0.5
        if dx=0
            return dy=0? 0: 0.25 + add
        else return angle.clip(atan(dy/dx)/angle.tau + add)
    }
    length(p1,p2) {
        return sqrt((p1.x-p2.x)**2 + (p1.y-p2.y)**2)
    }
}

class angle { ; angle is taken in multiples of 360 deg. ie, 180 deg = 0.5 etc
    static tau:=2*ACos(-1)
    clip(a) {
        return a>=0? mod(a,1): 1-mod(-a,1)
    }
    isInRange(a,min,max) {
        a:=angle.clip(a), min:=angle.clip(min), max:=angle.clip(max)
        return (min<=max) ? (a>=min AND a<=max) : (a>=min OR a<=max)
    }
    range(a1,a2){
        d:=mod(abs(a2-a1), 1)
        return d<0.5? d: 1-d
    }
}