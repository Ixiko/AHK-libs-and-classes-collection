/* 32bit
SetTimerF( Function, Period=0, ParmObject=0, Priority=0 ) { 
 Static current,tmrs:=Object() ;current will hold timer that is currently running
 If IsFunc( Function ) {
    if IsObject(tmr:=tmrs[Function]) ;destroy timer before creating a new one
       ret := DllCall( "KillTimer", UInt,0, UInt, tmr.tmr)
       , DllCall("GlobalFree", UInt, tmr.CBA)
       , tmrs.Remove(Function) 
    if (Period = 0 || Period ? "off")
       return ret ;Return as we want to turn off timer
	 ; create object that will hold information for timer, it will be passed trough A_EventInfo when Timer is launched
    tmr:=tmrs[Function]:=Object("func",Function,"Period",Period="on" ? 250 : Period,"Priority",Priority
								,"OneTime",(Period<0),"params",IsObject(ParmObject)?ParmObject:Object()
								,"Tick",A_TickCount)
    tmr.CBA := RegisterCallback(A_ThisFunc,"F",4,&tmr)
    return !!(tmr.tmr  := DllCall("SetTimer", UInt,0, UInt,0, UInt
								, (Period && Period!="On") ? Abs(Period) : (Period := 250)
								, UInt,tmr.CBA)) ;Create Timer and return true if a timer was created
				, tmr.Tick:=A_TickCount
 }
 tmr := Object(A_EventInfo) ;A_Event holds object which contains timer information
 if IsObject(tmr) {
	 DllCall("KillTimer", UInt,0, UInt,tmr.tmr) ;deactivate timer so it does not run again while we are processing the function
	 If (!tmr.active && tmr.Priority<(current.priority ? current.priority : 0)) ;Timer with higher priority is already current so return
		 Return (tmr.tmr:=DllCall("SetTimer", UInt,0, UInt,0, UInt, 100, UInt,tmr.CBA)) ;call timer again asap
	 current:=tmr
	 tmr.tick:=ErrorLevel :=Priority ;update tick to launch function on time
	 tmr.func(tmr.params*) ;call function
	 current= ;reset timer
    if (tmr.OneTime) ;One time timer, deactivate and delete it
       return DllCall("GlobalFree", UInt,tmr.CBA)
				 ,tmrs.Remove(tmr.func)
	 tmr.tmr:= DllCall("SetTimer", UInt,0, UInt,0, UInt ;reset timer
				,((A_TickCount-tmr.Tick) > tmr.Period) ? 0 : (tmr.Period-(A_TickCount-tmr.Tick)), UInt,tmr.CBA)
 }
}
*/


SetTimerF( Function, Period=0, ParmObject=0, Priority=0 ) { 
	
	 Static current,tmrs:=[]                                                                                                             	;current will hold timer that is currently running
	 
	 If IsFunc( Function ) {
		
		if IsObject(tmr:=tmrs[Function])                                                                                             	;destroy timer before creating a new one
		   ret := DllCall( "KillTimer", UInt,0, PTR, tmr.tmr)
		   , DllCall("GlobalFree", PTR, tmr.CBA)
		   , tmrs.Remove(Function) 
		   
		if (Period = 0 || Period = "off")
		   return ret                                                                                                                           	;-- Return as we want to turn off timer
																																						;-- create object that will hold information for timer, it will be passed trough A_EventInfo when Timer is launched
		tmr:=tmrs[Function]:={func:Function,Period:Period="on" ? 250 : Period,Priority:Priority
									,OneTime:Period<0,params:IsObject(ParmObject)?ParmObject:Object()
									,Tick:A_TickCount}
		tmr.CBA := RegisterCallback(A_ThisFunc,"F",4,&tmr)
		return !!(tmr.tmr  := DllCall("SetTimer", PTR,0, PTR,0, UInt
									, (Period && Period!="On") ? Abs(Period) : (Period := 250)
									, PTR,tmr.CBA,"PTR"))                                                                                	;-- Create Timer and return true if a timer was created
					, tmr.Tick:=A_TickCount
	 }
	 
	 tmr := Object(A_EventInfo)                                                                                                       	;-- A_Event holds object which contains timer information
	 
	 if IsObject(tmr) {
		 DllCall("KillTimer", PTR,0, PTR,tmr.tmr)                                                                               	;-- deactivate timer so it does not run again while we are processing the function
		 If (current && tmr.Priority<current.priority)                                                                        	;-- Timer with higher priority is already current so return
			 Return (tmr.tmr:=DllCall("SetTimer", PTR,0, PTR,0, UInt, 100, PTR,tmr.CBA,"PTR"))        	;-- call timer again asap
		 current:=tmr
		 ,tmr.tick:=ErrorLevel :=Priority                                                                                              	;-- update tick to launch function on time
		 ,tmr.func(tmr.params*)                                                                                                        	;-- call function
		if (tmr.OneTime)                                                                                                                   	;-- One time timer, deactivate and delete it
		   return DllCall("GlobalFree", PTR,tmr.CBA)
					 ,tmrs.Remove(tmr.func)
		 tmr.tmr:= DllCall("SetTimer", PTR,0, PTR,0, UInt                                                                  	;--reset timer
					,((A_TickCount-tmr.Tick) > tmr.Period) ? 0 : (tmr.Period-(A_TickCount-tmr.Tick)), PTR,tmr.CBA,"PTR")
		 current=                                                                                                                              	;-- reset timer
	 }
}

