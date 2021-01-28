FormatTickCount(ms)  ;  Formats milliseconds into 00:00:00:000 (last three digits are milliseconds)
{
	StringRight , mil , ms , 3
	StringTrimRight , sec , ms , 3
	min := Floor(sec/60)
	sec := sec-(min*60)
	hrs := Floor(min/60)
	min := min-(hrs*60)
	While StrLen(sec) <> 2
		sec := "0" . sec
	While StrLen(mil) <> 3
		mil := "0" . mil
	While StrLen(min) <> 2
		min := "0" . min
	While StrLen(hrs) <> 2
		hrs := "0" . hrs 
	return , hrs . ":" . min . ":" . sec . ":" . mil
}