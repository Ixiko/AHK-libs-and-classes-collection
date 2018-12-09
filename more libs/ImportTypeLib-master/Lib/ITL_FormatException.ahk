ITL_FormatException(msg, detail, error, hr = "", special = false, special_msg = "")
{
	static NL := "`n`t"
	return [  msg
			, -1
			, (detail != ""	? NL . detail										:	"")
			. (ErrorLevel	? NL . "ErrorLevel: " error							:	"")
			. (A_LastError	? NL . "A_LastError: " ITL_FormatError(A_LastError)	:	"")
			. (hr != ""		? NL . "HRESULT: " ITL_FormatError(hr)				:	"")
			. (special		? NL . special_msg									:	"") ]
}