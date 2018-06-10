;////////////////////////////////////////////////
; SrtSynch function created by GAHKS (2009)
; http://www.autohotkey.com/forum/topic41466.html
; http://www.autohotkey.net/~gahks/
;////////////////////////////////////////////////
SrtSynch(delay_or_framerate, input_subtitle, output_subtitle, delay, is_delay_positive, input_fps, output_fps) {
shifting_ratio := input_fps/output_fps
; LOOK FOR TIMER SETTINGS
Loop, Read, %input_subtitle%, %output_subtitle% ;Looping through the subtitles by rows
{
show_and_hide1 =
show_and_hide2 =
StringReplace, list, A_LoopReadLine, -->, |
StringSplit, show_and_hide, list, |
StringLen, var, show_and_hide1
StringLen, var2, show_and_hide2
If (var <> 13 OR var2 <> 13) ; Is it a timer
{
	FileAppend, %A_LoopReadLine%`n ; If it isn't, copy the line and jump
	Continue
}
Else
{
string = %A_LoopReadLine%
StringReplace, nyil, string, -->, |
StringSplit, show_and_hide, nyil, |
StringSplit, show , show_and_hide1, : ; Split the timer into two parts in the middle
StringSplit, hide, show_and_hide2, :
;///////////////////
; TIMER, FIRST PART
StringReplace, show_ms, show3, `,,
show_hh_in_ms := show1*3600000
show_mm_in_ms := show2*60000
show_time_in_ms := show_hh_in_ms+show_mm_in_ms+show_ms
If delay_or_framerate = 0
{
	If is_delay_positive = 1
		show_time_in_ms_converted := show_time_in_ms+delay
	Else If is_delay_positive = 0
		show_time_in_ms_converted := show_time_in_ms-delay

}
Else If delay_or_framerate = 1
{
	show_time_in_ms_converted := show_time_in_ms*shifting_ratio
}
Transform, st_in_ms_c_rounded, Round, show_time_in_ms_converted
show_firststep := st_in_ms_c_rounded/1000
StringSplit, show_firststep_split, show_firststep, .
StringLeft, show_ms, show_firststep_split2, 3
show_secondstep := show_firststep_split1/60
StringSplit, show_secondstep_split, show_secondstep, .
show_ss_in_mm = 0.%show_secondstep_split2%
show_ss_raw := show_ss_in_mm*60
Transform, show_ss, Round, show_ss_raw
show_mm = %show_secondstep_split1%
show_hh = 00
If show_mm >= 60
{
show_thirdstep := show_mm/60
StringSplit, show_thirdstep_split, show_thirdstep, .
show_mm_in_hh = 0.%show_thirdstep_split2%
show_mm_raw := show_mm_in_hh*60
Transform, show_mm, Round, show_mm_raw
show_hh = %show_thirdstep_split1%
}
StringLen, var, show_hh
If var = 1
	show_hh = 0%show_hh%
StringLen, var, show_mm
If var = 1
	show_mm = 0%show_mm%
StringLen, var, show_ss
If var = 1
	show_ss = 0%show_ss%
StringLen, var, show_ms
If var = 1
	show_ms = 00%show_ms%
Else If var = 2
	show_ms = 0%show_ms%
show_time_full = %show_hh%:%show_mm%:%show_ss%,%show_ms%
;///////////////////
; TIMER, SECOND PART
StringReplace, hide_ms, hide3, `,,
hide_hh_in_ms := hide1*3600000
hide_mm_in_ms := hide2*60000
hide_time_in_ms := hide_hh_in_ms+hide_mm_in_ms+hide_ms
If delay_or_framerate = 0
{
	If is_delay_positive = 1
		hide_time_in_ms_converted := hide_time_in_ms+delay
	Else If is_delay_positive = 0
		hide_time_in_ms_converted := hide_time_in_ms-delay

}
Else If delay_or_framerate = 1
{
	hide_time_in_ms_converted := hide_time_in_ms*shifting_ratio
}
Transform, st_in_ms_c_rounded, Round, hide_time_in_ms_converted
hide_firststep := st_in_ms_c_rounded/1000
StringSplit, hide_firststep_split, hide_firststep, .
StringLeft, hide_ms, hide_firststep_split2, 3
hide_secondstep := hide_firststep_split1/60
StringSplit, hide_secondstep_split, hide_secondstep, .
hide_ss_in_mm = 0.%hide_secondstep_split2%
hide_ss_raw := hide_ss_in_mm*60
Transform, hide_ss, Round, hide_ss_raw
hide_mm = %hide_secondstep_split1%
hide_hh = 00
If hide_mm >= 60
{
hide_thirdstep := hide_mm/60
StringSplit, hide_thirdstep_split, hide_thirdstep, .
hide_mm_in_hh = 0.%hide_thirdstep_split2%
hide_mm_raw := hide_mm_in_hh*60
Transform, hide_mm, Round, hide_mm_raw
hide_hh = %hide_thirdstep_split1%
}
StringLen, var, hide_hh
If var = 1
	hide_hh = 0%hide_hh%
StringLen, var, hide_mm
If var = 1
	hide_mm = 0%hide_mm%
StringLen, var, hide_ss
If var = 1
	hide_ss = 0%hide_ss%
StringLen, var, hide_ms
If var = 1
	hide_ms = 00%hide_ms%
Else If var = 2
	hide_ms = 0%hide_ms%
hide_time_full = %hide_hh%:%hide_mm%:%hide_ss%,%hide_ms%
; Conversion done, change the timer, jumpt to the next row
timer_full = %show_time_full% --> %hide_time_full%
FileAppend, %timer_full%`n
} ;End of Else
} ;End of Loop
} ;End of Function