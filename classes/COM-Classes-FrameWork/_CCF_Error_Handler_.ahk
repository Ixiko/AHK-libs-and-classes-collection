/*
class: _CCF_ErrorHandler_
serves as base class for all other classes and implements some error handling. The "Unknown" and "StructBase" classes derive from this.

Requirements:
	AutoHotkey - AHK v2 alpha
*/
class _CCF_Error_Handler_
{
	/*
	Method: __Call
	meta-function that handles calls to non-existent methods
	*/
	__Call(method, params*)
	{
		local param_list, i, p
		local func := Func("Obj" . LTrim(method, "_"))

		if (!IsObject(func) || !func.IsBuiltIn)
		{
			param_list := ""
			For i, p in params
				param_list .= "`t" . i . " = " . (IsObject(p) ? "[Object]" : p) . "`n"
			throw Exception("Non-existent method was called: `"" . method . "`"" . (params.maxIndex() > 0 ? "`nParameters:`n" . param_list : ""), -1)
		}
	}
}