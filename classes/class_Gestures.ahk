#include <geometry>

class gestures {
    __new(opt:="") {
        opt0:={angle_tolerance:0.25, size_tolerance:A_ScreenHeight//12, scaling:True}
       ,this.opt:=replaceList(opt0, opt), this.dTheta:=this.opt.angle_tolerance, this.dr:=this.opt.size_tolerance
       ,this.tracker:=ObjBindMethod(this, "trackMouse")
       ,this.list:=[], this.points:=[]

    }

    add(gesture,f,opt:="") {

        ; Make gesture/options into standard form
        if !isObject(gesture)
            gesture:=[gesture]
        for i,g in gesture {
            if !isObject(g)
                gesture[i]:={angle:[g,g],size:[0,0]}
            else {
                if !isObject(g.angle)
                    gesture[i].angle:=[g.angle,g.angle]
                if !g.hasKey("size")
                    gesture[i].size:=[0,0]
                else if !IsObject(g.size)
                    gesture[i].size:=[g.size,g.size]
            }
        }
        opt:=replaceList(this.opt,opt)

        ; Make the global threshold the minimum of all thresholds
        this.dTheta:=min(opt.angle_tolerance, this.dTheta)
       ,this.dr:=min(opt.size_tolerance, this.dr)

        this.list.push({gesture:gesture,f:f,opt:opt})
        return true
    }

    start(time:=100) {
        ;msgbox this.dTheta "`n" this.dr
        setTimer(this.tracker, time)
        return ;this.tracker.call()
    }
    end() { ; Returns 0 = No Gesture, 1 = Gesture Triggered, -1 = Unidentified Gesture
        setTimer(this.tracker, "Off")
        triggered:= this.points.length()>1? -1: 0
        for _,item in this.list
            if this.checkGesture(item) {
                ;msgbox "Triggered"
                triggered:=True
               ,item.f.Call()
                break
            }
        this.killTracker()
        return triggered
    }
    killTracker(){
        this.trackMouse(True)
       ,this.points:=[]
        return
    }

    trackMouse(kill:=False) {
        static lastPos:="", lastAngle:=""
        if kill
            return lastPos:=lastAngle:=""
        A_CoordModeMouse:="Screen"
       ,MouseGetPos(mx, my), p:={x:mx, y:my}

        if !isObject(lastPos) ; First entry
            return this.points.push(lastPos:=p)
        if line.length(p,lastPos)<this.dr ;Mouse not moved
            return

        currentAngle:=angle.clip(round_near(line.angle(lastPos,p), this.dTheta))
        ;tooltip p.x " " p.y "`n" lastPos.x " " lastPos.y "`n" currentAngle " " lastAngle
        if lastAngle="" OR angle.range(currentAngle,lastAngle)>=this.dTheta {
            ;tooltip p.x " " p.y "`n" lastPos.x " " lastPos.y "`n" currentAngle " " lastAngle " X"
            this.points.push(lastPos:=p)
           ,lastAngle:=currentAngle
        } else this.points[this.points.length()]:=(lastPos:=p)
        return
    }

    checkGesture(obj) {
        p_i:=1, g:=obj.gesture, p_n:=this.points.length(), opt:=obj.opt

        for i in g {
            if p_i=p_n OR !p_i:=this.matchStroke(g,i,p_i,opt) ;Points left after finishing gesture OR Not matching with gesture
                return False
        }
        ;msgbox "p_i=" p_i
        return (p_i=p_n) ; if p_i=p_n+1, gesture is complete
    }
    matchStroke(g,i,p_i,opt) {
        static scale:=[1,1]
        p_j:=p_i, a1:=g[i].angle[1], a2:=g[i].angle[2]
       ,dTheta:=opt.angle_tolerance, dr:=opt.size_tolerance, scaling:=opt.scaling

        while this.points.hasKey(p_j+1)
            AND angle.isInRange( round_near(line.angle(this.points[p_j],this.points[p_j+1]),dTheta)
                               , round_near(a1,dTheta), round_near(a2,dTheta)                       )
            p_j++ ; Angle matched
        if p_j=p_i AND g[i].size[1]>=0 ;No match
            return 0

        if g[i].size[1]>0 OR g[i].size[2]>0 { ; is size specified?
            lMin:=g[i].size[1], lMax := g[i].size[2]
           ,l:=round_near(line.length(this.points[p_i],this.points[p_j]), dr)
            if scaling AND p_i=1
                scale:=[l/lMax,l/lMin]
            else {
                if !scaling
                    scale:=[1,1]
                ;msgbox l " " lMin " " lMax " " scale[2] " " scale[1]
                if l<round_near(lMin*scale[1], dr) OR l>round_near(lMax*scale[2],dr) ; Distance not match
                    return 0
            }
        }
        return p_j ; Last point in this stroke = First point of next stroke
    }
}