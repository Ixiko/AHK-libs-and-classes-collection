/*
 *    "JSON_Beautify.ahk" by Joe DF (joedf@users.sourceforge.net)
 *    ______________________________________________________________________
 *    "Transform Objects & JSON strings into nice or ugly JSON strings."
 *    Uses VxE's JSON_FromObj()
 *    
 *    Released under The MIT License (MIT)
 *    ______________________________________________________________________
 *    
*/

JSON_Uglify(JSON) {
	if IsObject(JSON) {
		return JSON_FromObj(JSON)
	} else {
		if JSON is space
			return ""
		StringReplace,JSON,JSON, `n,,A
		StringReplace,JSON,JSON, `r,,A
		StringReplace,JSON,JSON, % A_Tab,,A
		StringReplace,JSON,JSON, % Chr(08),,A
		StringReplace,JSON,JSON, % Chr(12),,A
		StringReplace,JSON,JSON, \\, % Chr(1),A  ;watchout for escape sequence '\\', convert to '\1'
		_JSON:="", in_str:=0, l_char:=""
		Loop, Parse, JSON
		{
			if ( (!in_str) && (asc(A_LoopField)==0x20) )
				continue
			if( (asc(A_LoopField)==0x22) && (asc(l_char)!=0x5C) )
				in_str := !in_str
			_JSON .= (l_char:=A_LoopField)
		}
		StringReplace,_JSON,_JSON, % Chr(1),\\,A  ;convert '\1' back to '\\'
		return _JSON
	}
}

JSON_Beautify(JSON, gap:="`t") {
	;fork of http://pastebin.com/xB0fG9py
	JSON:=JSON_Uglify(JSON)
	StringReplace,JSON,JSON, \\, % Chr(1),A  ;watchout for escape sequence '\\', convert to '\1'
	
	indent:=""
	
	if gap is number
	{
		i :=0
		while (i < gap) {
			indent .= " "
			i+=1
		}
	} else {
		indent := gap
	}
	
	_JSON:="", in_str:=0, k:=0, l_char:=""
	
	Loop, Parse, JSON
	{
		if (!in_str) {
			if ( (A_LoopField=="{") || (A_LoopField=="[") ) {
				_s:=""
				Loop % ++k
					_s.=indent
				_JSON .= A_LoopField "`n" _s
				continue
			}
			else if ( (A_LoopField=="}") || (A_LoopField=="]") ) {
				_s:=""
				Loop % --k
					_s.=indent
				_JSON .= "`n" _s A_LoopField
				continue
			}
			else if ( (A_LoopField==",") ) {
				_s:=""
				Loop % k
					_s.=indent
				_JSON .= A_LoopField "`n" _s
				continue
			}
		}
		if( (asc(A_LoopField)==0x22) && (asc(l_char)!=0x5C) )
			in_str := !in_str
		_JSON .= (l_char:=A_LoopField)
	}
	StringReplace,_JSON,_JSON, % Chr(1),\\,A  ;convert '\1' back to '\\'
	return _JSON
}