class strex{
	concat(sep, str, more*){
		s := str
		for k, v in more
			s .= sep v
		return s
		}
	rep(str, times){
		loop times
			newStr .= str
		return newStr
		}
	obj(obj, key := ''){
		if not isObject(obj)
			if key
				return obj ~= '\s' ? "'" obj "'" : obj
			else
				return type(obj) = 'string' ? "'" obj "'" : obj
		printType := 'arr'
		for k, v in obj
			if type(k) != 'integer'{
				printType := 'obj'
				break
				}
		if printType = 'arr'{
			printStr := '['
			if obj.length() > 0{
				for k, v in obj
					printStr .= strex.obj(v) ', '
				printStr := subStr(printStr, 1, -2)
				}
			return printStr ']'
		}else{
			printStr := '{'
			for k, v in obj
				printStr .= strex.obj(k, 1) ': ' strex.obj(v) ', '
			printStr := subStr(printStr, 1, -2)
			return printStr '}'
			}
		}
	}