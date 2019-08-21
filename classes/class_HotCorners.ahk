/**                             ;SAMPLE
#include reloadAsAdmin.ahk
reloadAsAdmin()
global A_ScriptPID := ProcessExist()
#include Timer.ahk
A_CoordModeMouse:= "Screen"

HotCorners.register( "R",Func("send").bind("#^{Right}"  ),10    )
HotCorners.register( "L",Func("send").bind("#^{Left}"   ),10    )
HotCorners.register("TL",Func("send").bind("#{Tab}"     )        )
HotCorners.register("BL",Func("send").bind("#x"         )        )
HotCorners.register("BR",Func("send").bind("#a"         )        )

Timer.set(objbindMethod(HotCorners,"run"),100)
/**/

class HotCorners {
    static f
    register(position, f, delay_count:=0){ ;Position: T,B,L,R,TL,TR,BL,BR
    ; The registered function can take position of mouse as parameters
    ; If delay_count<=0, the function is triggered only once. Else, it is triggered everytime the timer runs "delay_count" times
    ; The same edge/corner can have a function registered with delay_count<=0 and another with delay_count>0
        if !this.f {
            this.f:={}
            for _,p in ["L","R","T","B","TL","TR","BL","BR"]
                this.f[p]:={0:{}, 1:{}} ;0=False, 1=True
        }
        ; Alternative to if !(position in ["L","R","T","B","TL","TR","BL","BR"])
        if !{"L":0,"R":0,"T":0,"B":0,"TL":0,"TR":0,"BL":0,"BR":0}.haskey(position)
            return False
        return this.f[position][!(delay_count>0)]:={f:f,t:delay_count}
    }

    run(){
        static margin:=2, counter:=0, trigger:=False, lastpos:=""
        MouseGetPos(mx, my)
       ,position:=(my<margin?"T":(my+margin>=A_ScreenHeight?"B":"")) (mx<margin?"L":(mx+margin>=A_ScreenWidth?"R":""))
        if !position {
            counter:=0, lastpos:=""
            return trigger:=False
        }

        buttonsPressed:= GetKeyState("LButton") OR GetKeyState("RButton"), counter++
        if !buttonsPressed {
            if (!trigger OR !lastpos OR lastpos=position) AND counter>=this.f[position][False].t
                try {
                    f:=this.f[position][False].f
                   ,%f%(mx, my)
                   ,counter:=0, lastpos:=position
                }
            if !trigger
                try {
                    f:=this.f[position][True].f
                    ,%f%(mx, my)
                    ,lastpos:=position
                 }
        }
        return trigger:=True
    }
}