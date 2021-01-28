#persistent
#include timer.ahk

; Create some timers for the demo
; timer1 with an interval of 1000ms
; timer2 with with the default interval of 250ms
; timer3 with an interval of 2000ms
timers := map("timer1",timer.new("test",1000),"timer2",timer.new("test2"),"timer3",timer.new("test3",2000))

; We cretate timer4 with an undefiend function and default interval
try{
     timers["timer4"] := timer.new("undefiendFunction")
     ; This won't be executed
     timers["timer4"].Start()
} catch e {
    error(e)
}
; We get the name of the function being used by a timer
tooltip "The name of timer is: " timers["timer1"].name
Sleep 2000
tooltip

; Start the timers
timers["timer1"].Start()
timers["timer3"].Start()

; Change the default interval to something huge
timers["timer2"].interval := 90000000
; Now we wait for the timers we previously started to activate
; timer1 will call test() first
return
test(){
    global timers
        ; Monitor the timer and activate on the first run
        if (timers["timer1"].count == 1){
            ; We stop timer3 mid-cycle
            ; - the default timer that will always finish at least once
            ; You can have controlable loops that can be stopped at any time
            timers["timer3"].Stop()
            ; We try to change the interval with something other than an Integer
            try{
                timers["timer2"].interval := "A"
            } catch e {
                error(e)
                ; We change it to something more managable from the huge one we set earlier
                timers["timer2"].interval := 10000
            }
            ; We begin the countdown to the end of the demo   
            timers["timer2"].Start()
        }
        ; Counting the seconds until the end
        tooltip "Time until demo is over: " round(timers["timer2"].interval/1000-timers["timer1"].count+1) "s"
    return
}
error(e){
    msgbox(e,"Exception", 16)
}

test2(){
    global timers
    ; Time for the demo to finish
    ; Stop the countdown
    timers["timer1"].Stop()
    tooltip ""
    ; END
    msgbox "Demo Finished. Exiting."
    ExitApp
}

test3(){
    Msgbox "You shouldn't see this msgbox"
}
