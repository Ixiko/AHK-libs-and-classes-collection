;**********************
;*                    *
;*    Elapsed Time    *
;*                    *
;**********************
;
;   Decription:
;   ===========
;   This functions keeps tracks of the amount of time that has elapsed (in
;   milliseconds) between calls to the function.  Up to 9 timers can be used.
;
;
;    
;   Parameters
;   ==========
;
;       Name                Decryption
;       ----                ----------
;       p_Timer             Timer #.  Valid values are 1 through 9.  [Optional]
;                           Default is 1.
;
;       p_Start             Set to true to start timer.  [Optional]  Default is
;                           false.  
;
;
;   Notes
;   =====
;   To reduce processing time to a minimum, this function includes no error
;   or integrity checking.  Invalid results will occur if a timer is not
;   initialized (p_Start=true) or if an invalid (undefined) timer is used.
;
;   To create more meaningful timer names, create a static variable (prefixed by
;   "timer_") for every timer name that you wish to use.  For example, creating
;   the static variable (sans quotes) "timer_CheckFiles" will allow for function
;   to be called as follows:
;   
;       ElapsedTime("CheckFiles",true)
;       ;--- Code to check files goes here
;       msgbox "It took " . ElapsedTime("CheckFiles") . " ms to check files."
;       return
;
;
;
;   Examples Of Use
;   ===============
;   The following are examples (not recommendations) of use.
;   
;   ;-- Test 1
;   ^#!Numpad1::
;   msgbox Click the OK button to start Test 1...
;   ElapsedTime(1,true)
;   sleep 2500
;   msgbox % "End of Test 1.  Elapsed Time=" . ElapsedTime() . " ms."
;   return
;
;   ;-- Test 2
;   ^#!Numpad2::
;   msgbox Click the OK button to start Test 2...
;   ElapsedTime(1,true)
;   sleep 1234
;   et1:=ElapsedTime(1)
;   ElapsedTime(2,true)
;   sleep 592
;   et2:=ElapsedTime(2)
;   msgbox End of Test 2.  1st sleep=%et1% ms.  2nd sleep=%et2% ms.
;   return
;
;   ;-- Test 3
;   ^#!Numpad3::
;   msgbox Click the OK button to start Test 3...
;   ElapsedTime(1,true)
;   sleep 888
;   t1:=ElapsedTime(1)
;   ElapsedTime(2,true)
;   sleep 777
;   t2:=ElapsedTime(2)
;   t1_l2:=ElapsedTime(1)
;   ElapsedTime(3,true)
;   sleep 444
;   t3:=ElapsedTime(3)
;   t1_l3:=ElapsedTime(1)
;   message=
;    (ltrim
;     End of Test 3.
;     Time for 1st sleep=%t1% ms.
;     Time for 2nd sleep=%t2% ms.  Lap time after 2nd sleep=%t1_l2% ms.
;     Time for 3rd sleep=%t3% ms.  Lap time after 3rd sleep=%t1_l3% ms.
;    )
;   msgbox %message%
;   return
;
;-------------------------------------------------------------------------------
ElapsedTime(p_Timer=1,p_Start=false)
    {
    static timer_1,timer_2,timer_3,timer_4,timer_5,timer_6,timer_7,timer_8,timer_9
    static timer_CheckFiles  ;-- Example of meaningful timer name

    if p_Start
        {
        timer_%p_Timer%:=A_TickCount
        l_ElapsedTime=0
        }
       else
        l_ElapsedTime:=A_TickCount-timer_%p_Timer%

    return l_ElapsedTime
   }