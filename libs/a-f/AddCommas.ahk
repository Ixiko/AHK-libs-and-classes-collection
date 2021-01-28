;********************
;*                  *
;*    Add Commas    *
;*                  *
;********************
;
;
;   Description
;   ===========
;   This function adds the appropriate comma characters "," to a number for
;   display purposes.  For example, "12345" is converted as "12,345".
;
;   Original code by Laszlo, enhanced by PhiLho.  Original forum topic:
;
;       http://www.autohotkey.com/forum/viewtopic.php?t=12754
;
;
;
;   Return Value
;   ============
;   Formatted number (string)
;
;
;
;   Calls To Other Functions
;   ========================
;   (None)
;
;
;-------------------------------------------------------------------------------
AddCommas(p_Number)    {
    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    p_Number=%p_Number%  ;-- AutoTrim
    if SubStr(p_Number,1,1)="-"
        {
        l_Sign:="-"
        StringTrimLeft p_Number,p_Number,1
        }


    ;[========================]
    ;[  Add commas as needed  ]
    ;[========================]
    loop parse,p_Number,.
        {
        if A_Index=1
            {
            l_IntLen:=StrLen(A_LoopField)
            loop parse,A_LoopField
                {
                 if (mod(l_IntLen-A_Index,3)=0 and A_Index<>l_IntLen)
                    l_Number:=l_Number . A_LoopField . ","
                 else
                    l_Number:=l_Number . A_LoopField
                }
            }
         else
            l_Number:=l_Number . "." . A_LoopField
        }


    ;[==========================]
    ;[  Return converted value  ]
    ;[==========================]
    l_Return:=l_Sign . l_Number
    return l_Return
    }
