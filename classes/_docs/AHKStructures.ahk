; AHK Structures
_AHKDerefType := "LPTSTR marker,{_AHKVar *var,_AHKFunc *func},BYTE is_function,BYTE param_count,WORD length"
_AHKExprTokenType := "{__int64 value_int64,double value_double,struct{{PTR *object,_AHKDerefType *deref,_AHKVar *var,LPTSTR marker},{LPTSTR buf,size_t marker_length}}},UINT symbol,{_AHKExprTokenType *circuit_token,LPTSTR mem_to_free}"
_AHKArgStruct := "BYTE type,BYTE is_expression,WORD length,LPTSTR text,_AHKDerefType *deref,_AHKExprTokenType *postfix"
_AHKLine := "BYTE ActionType,BYTE Argc,WORD FileIndex,UINT LineNumber,_AHKArgStruct *Arg,PTR *Attribute,*_AHKLine PrevLine,*_AHKLine NextLine,*_AHKLine RelatedLine,*_AHKLine ParentLine"
_AHKLabel := "LPTSTR name,*_AHKLine JumpToLine,*_AHKLabel PrevLabel,*_AHKLabel NextLabel"
_AHKFuncParam := "*_AHKVar var,UShort is_byref,UShort default_type,{default_str,Int64 default_int64,Double default_double}"
If (A_PtrSize = 8)
	_AHKRCCallbackFunc := "UINT64 data1,UINT64 data2,PTR stub,UINT_PTR callfuncptr,BYTE actual_param_count,BYTE create_new_thread,event_info,*_AHKFunc func"
else
	_AHKRCCallbackFunc := "ULONG data1,ULONG data2,ULONG data3,PTR stub,UINT_PTR callfuncptr,ULONG data4,ULONG data5,BYTE actual_param_count,BYTE create_new_thread,event_info,*_AHKFunc func"
_AHKFunc := "PTR vTable,LPTSTR name,{PTR BIF,*_AHKLine JumpToLine},*_AHKFuncParam Param,Int ParamCount,Int MinParams,*_AHKVar var,*_AHKVar LazyVar,Int VarCount,Int VarCountMax,Int LazyVarCount,Int Instances,*_AHKFunc NextFunc,BYTE DefaultVarType,BYTE IsBuiltIn"
_AHKVar := "{Int64 ContentsInt64,Double ContentsDouble,PTR object},{char *mByteContents,LPTSTR CharContents},{UINT_PTR Length,_AHKVar *AliasFor},{UINT_PTR Capacity,UINT_PTR BIV},BYTE HowAllocated,BYTE Attrib,BYTE IsLocal,BYTE Type,LPTSTR Name"