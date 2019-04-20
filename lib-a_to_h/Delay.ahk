Delay( D=0.001 ) {  ; High Resolution Delay ( High CPU Usage )  by SKAN  | CD: 13/Jun/2009
 Static F           ; www.autohotkey.com/forum/viewtopic.php?t=52083     | LM: 13/Jun/2009
 Critical
 F ? F : DllCall( "QueryPerformanceFrequency", Int64P,F )
 DllCall( "QueryPerformanceCounter", Int64P,pTick ), cTick := pTick
 While( ( (Tick:=(pTick-cTick)/F)) <D ) {
   DllCall( "QueryPerformanceCounter", Int64P,pTick )
   Sleep -1
 }
Return Round( Tick,3 )
}