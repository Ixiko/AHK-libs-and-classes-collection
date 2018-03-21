/* If you want to check performance difference.
uncomment below benchmark routine. written by derRaphael
;-------------------------------------------------------
SetBatchLines, -1
res := ""
t1 := 0, t2 := 0
_t1 := 0, _t2 := 0
iterations := 25
outerLoops := 20

loop, %outerLoops%
{
   tooltip, currently @ test: %A_index%
   t1 := 0, t2 := 0
   Loop, %iterations%
   {
      VarSetCapacity(Test, 25*1024*1024, 97)

         DllCall("QueryPerformanceFrequency", "Int64 *", Freq)
         DllCall("QueryPerformanceCounter", "Int64 *", Start)
         Loop, 10000
            a := chr(NumGet(Test,A_Index,"UChar"))
         DllCall("QueryPerformanceCounter", "Int64 *", End)
      wo%A_Index% := (End - Start)/Freq
         
         EmptyMem()

         DllCall("QueryPerformanceFrequency", "Int64 *", Freq)
         DllCall("QueryPerformanceCounter", "Int64 *", Start)
         Loop, 10000
            a := chr(NumGet(Test,A_Index,"UChar"))
         DllCall("QueryPerformanceCounter", "Int64 *", End)
      w%A_Index% := (End - Start)/Freq
      
      t1 += wo%A_Index%
      t2 += w%A_Index%
   }
   _t1 += t1/iterations
   _t2 += t2/iterations
   res .= "Run" a_index ":`tnormal - " t1/iterations "sec`temty() - " t2/iterations "sec`n"
   tooltip, currently @ test: A_index
}
   res .= "`nAverage normal " _t1/outerLoops " seconds"
       . "`nAverage emtpy() " _t2/outerLoops " seconds"
MsgBox,0,Results,%res%
return
;-------------------------------------------------------
*/

EmptyMem(PID="AHK Rocks"){
    pid:=(pid="AHK Rocks") ? DllCall("GetCurrentProcessId") : pid
    h:=DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
    DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
    DllCall("CloseHandle", "Int", h)
}