; Numeric comparison mini lib.
cmp_self(x){
	; returns true if all elements of x are the same.
	; x, array
	return min(x*) == max(x*)
}
cmp(x, op, y){
	; Compares all elements in x to all elements in y.
	; x, array.
	;
	; op, operator string, can be one of,
	;
	;	'=', '==', returns true if all in x equal to all in y.
	;	'<', returns true if all in x less than all in y.
	;	'<=', returns true if all in x less or equal to all in y.
	;	'>', returns true if all in x greater than all in y.
	;	'>=', returns true if all in x greater or equal to all in y.
	;
	; y, array.
	;
	local
	if op == '=' || op == '=='
		return	(rx := min(x*)) == max(x*) 
				&& (ry := min(y*)) == max(y*) 
				&& rx == ry											; all in x equal to all in y.
	else if op == '<'
		return max(x*) < min(y*)									; all in x less than all in y.
	else if op == '<='
		return max(x*) <= min(y*)									; all in x less or equal to all in y.
	else if op == '>'
		return min(x*) > max(y*)									; all in x greater than all in y.
	else if op == '>='
		return min(x*) >= max(y*)									; all in x greater or equal to all in y.
	
	throw exception('Parameter #2 invalid.',, op)					; Invaild operator.
}
/*
; switch version
cmp(x, op, y) {
	local
	switch op
	{
		case '=', '==':	return 	(rx := min(x*)) == max(x*) 
								&& (ry := min(y*)) == max(y*) 
								&& rx == ry										; all in x equal to all in y.
		case '<': 		return max(x*) < min(y*)								; all in x less than all in y.
		case '<=':		return max(x*) <= min(y*)								; all in x less or equal to all in y.
		case '>':		return min(x*) > max(y*)								; all in x greater than all in y.
		case '>=':		return min(x*) >= max(y*)								; all in x greater or equal to all in y.
	}
	throw exception('Parameter #2 invalid.',, op)								; Invaild operator.
}
*/