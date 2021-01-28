GetLogText(fnActionText,fnDetailsText := "",fnActionTextWidth := 30)
{
	; returns a text string formatted for log files
	fnActionText := fnActionText ? fnActionText : "Unspecified action"
	Action := SubStr(fnActionText Replicate(" ",fnActionTextWidth),1,fnActionTextWidth)
	LogText := TimeStampSQL(A_Now) "," Action "," fnDetailsText
	Return LogText
}
