;*************************
;*                       *
;*    SecondsToHHMMSS    *
;*                       *
;*************************
;
;
;   Description
;   ===========
;   This function converts the specified number of seconds to hh:mm:ss format.
;
;
;
;   Parameters
;   ==========
;
;       Name                Description
;       ----                -----------
;       p_Seconds           Number of seconds. [Required]
;
;
;       p_MinimumSize       Minimum size.  [Optional]  The default is 4.
;
;                           This is the minimum size in characters (not
;                           significant digits) that you want returned.  Unless
;                           you want a ":" character to show as the leading
;                           character, don't set this value to 3 or 6.
;
;
;
;   Return Value
;   ============
;   Time in hh:mm:ss format with leading zero and ":" characters suppressed
;   unless the length is less than p_MinimumSize.
;
;   Note:  If the number of hours is greater than 99, the size of hour ("hh") 
;   will increase as needed.
;
;
;
;   Calls To Other Functions
;   ========================
;   (None)
;
;
;
;   Credit
;   ======
;   This function is a customized version of an example that was extracted from
;   the AHK documenation.
;
;
;-------------------------------------------------------------------------------
SecondsToHHMMSS(p_Seconds,p_MinimumSize=4)
    {
    ;-- p_Seconds must be a postive integer.  Round if necessary.
    if p_Seconds is not Number
        p_Seconds=0
     else
        {
        p_Seconds:=round(p_Seconds)
        if p_Seconds<0
            p_Seconds=0
        }

        
    ;-- Initialize and format
    l_Time=20121212  ;-- Midnight of an arbitrary date.
    EnvAdd l_Time,p_Seconds,Seconds
    FormatTime l_mmss,%l_Time%,mm:ss
    l_FormattedTime:="0" . p_Seconds//3600 . ":" . l_mmss
        ;-- Allows support for more than 24 hours.


    ;-- Trim insignificant leading characters
    loop
        if StrLen(l_FormattedTime)<=p_MinimumSize
            break
         else
            if SubStr(l_FormattedTime,1,1)="0"
                StringTrimLeft l_FormattedTime,l_FormattedTime,1
             else
                if SubStr(l_FormattedTime,1,1)=":"
                    StringTrimLeft l_FormattedTime,l_FormattedTime,1
                else
                    break


    ;-- Return to sender
    return l_FormattedTime
    }
