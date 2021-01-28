;**********************************************************
;AHK OPERATORS FUNCTIONS - By DigiDon
;No License : Feel free to use it anyhow you want
;WARNING : THIS IS A BETA : UNTESTED FULLY SO MIGHT BE ERRORS OR IMPROVEMENTS TO DO, NO WARRANTIES AT ALL ;)
;**********************************************************
; Added _F at the end of function names to make sure no conflict e.g. obfuscation BUT YOU CAN DELETE IT if no need, might be easier to use
; ex : msgbox % ADD_F(MULT_F(1,2,3),DIV_F(2,3,4))
;**********************************************************
;Missing (because not really sure of understanding it) :
; Bitwisenot, Address, Dereference, Bitwise-and (&), bitwise-exclusive-or (^), and bitwise-or (|)
;**********************************************************
;LIST OF FUNCTIONS
;**********************************************************
; ---- format (var1,varlist*)
; LESS_F(var1,varlist*)
; LESSorEQ_F(var1,varlist*)
; GREATER_F(var1,varlist*)
; GREATERorEQ_F(var1,varlist*)
; ---- format (varlist*)
; AND_F(varlist*)
; OR_F(varlist*)
; NOT_F(varlist*)
; IS_F(varlist*)
; CONCAT_F(varlist*)
; EQUAL_F(varlist*)
; CASEEQUAL_F(varlist*)
; ADD_F(varlist*)
; MINUS_F(varlist*)
; MULT_F(varlist*)
; POWER_F(varlist*)
; DIV_F(varlist*)
; ---- format (var1)
; INCREM_FU(var1)
; DECREM_FU(var1)
; ---- format (var1,var2)
; FLOORDIV_FU(var,divisor)
; BITLEFT_FU(var1,var2)
; BITRIGHT_FU(var1,var2)
;**********************************************************
; EXAMPLE : UNCOMMENT BELOW TO TEST
; YOU CAN UNCOMMENT DEBUG MSGBOX IN EQUAL_F() and AND_F()
; TO CHECK BETTER THE EXAMPLE RESULTS
;**********************************************************
; #SingleInstance Force
; testvar:="test"
; testvar2:="test"
; ;below example was splitted in several lines for easier understanding
; IF AND_F(EQUAL_F(9
; ;these line below have 9 fct that should all be equals to 9
; ,NOT_F(nonvar)*9,ADD_F(4,3,2),MINUS_F(14,3,2),MULT_F(3,3,1),DIV_F(27,3,1),POWER_F(3,2),FLOORDIV_FU(29,3),INCREM_FU(8),DECREM_FU(10))
; ;all below should be true
; ,OR_F(IS_F(testvar,testvar2),IS_F(testvar,nonvar)) ,LESS_F(1,2,3,4,5,6) ,LESSorEQ_F(1,1,2,3,4,5) ,GREATER_F(6,5,4,3,2,1) ,GREATERorEQ_F(6,6,5,4,3,2) ,CASEEQUAL_F(testvar,CONCAT_F(testvar,nonvar)))
; msgbox OK
; else
; msgbox one statement was false
; exitapp

;**********************************************************
;                 AHK OPERATORS FUNCTIONS
;**********************************************************
LESS_F(var1,varlist*) {
	if (varlist.MaxIndex()<1) {
		msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : var list should contain at least 2 items
		exit
		}
	if var1 is not number 
		{
		msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : %value% is not a number
		exit
		}
	for index,value in varlist
		if value is not number 
			{
			msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : %value% is not a number
			exit
			}
		else if (var1 >= value)
			return false
	return true
}

LESSorEQ_F(var1,varlist*) {
	if (varlist.MaxIndex()<1) {
		msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : var list should contain at least 2 items
		exit
		}
	if var1 is not number 
		{
		msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : %value% is not a number
		exit
		}
	for index,value in varlist
		if value is not number 
			{
			msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : %value% is not a number
			exit
			}
		else if (var1 > value)
			return false
	return true
}

GREATER_F(var1,varlist*) {
	if (varlist.MaxIndex()<1) {
		msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : var list should contain at least 2 items
		exit
		}
	if var1 is not number 
		{
		msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : %value% is not a number
		exit
		}
	for index,value in varlist
		if value is not number 
			{
			msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : %value% is not a number
			exit
			}
		else if (var1 <= value) {
			return false
			}
	return true
}

GREATERorEQ_F(var1,varlist*) {
	if (varlist.MaxIndex()<1) {
		msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : var list should contain at least 2 items
		exit
		}
	if var1 is not number 
			{
			msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : %value% is not a number
			exit
			}
	for index,value in varlist
		if value is not number 
			{
			msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : %value% is not a number
			exit
			}
		else if (var1 < value)
			return false
	return true
}

AND_F(varlist*) {
	if (varlist.MaxIndex()<2) {
		msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : var list should contain at least 2 items
		exit
		}
	for index,value in varlist {
	;debug
	; msgbox % "AND index " index " value " value
		if !value
			return false
	}
	return true
}

OR_F(varlist*) {
	if (varlist.MaxIndex()<2) {
		msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : var list should contain at least 2 items
		exit
		}
	for index,value in varlist
		if value
			return true
	return false
}

NOT_F(varlist*) {
	for index,value in varlist
		if value
			return false
	return true
}

IS_F(varlist*) {
	for index,value in varlist
		if !value
			return false
	return true
}

CONCAT_F(varlist*) {
	if (varlist.MaxIndex()<2) {
		msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : var list should contain at least 2 items
		exit
		}
	for index,value in varlist
		result .= value
	return result
}

EQUAL_F(varlist*) {
	if (varlist.MaxIndex()<2) {
		msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : var list should contain at least 2 items
		exit
		}
	loop % varlist.MaxIndex()
		{
		;debug
		msgbox % "EQUAL index " A_Index " value " varlist[A_Index]
		if (varlist[1] != varlist[A_Index])
			return false
		}
	return true
}

CASEEQUAL_F(varlist*) {
	if (varlist.MaxIndex()<2) {
		msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : var list should contain at least 2 items
		exit
		}
	for index,value in varlist {
		if index=1
			loop varlist.MaxIndex()
				if !(value == A_LoopField)
					return false
	}
	return true
}

ADD_F(varlist*) {
	if (varlist.MaxIndex()<2) {
		msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : var list should contain at least 2 items
		exit
		}
	for index,value in varlist {
		if value is not number 
			{
			msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : %value% is not a number
			exit
			}
		else
			result+=value
	}
	return result
}

MINUS_F(var1,varlist*) {
	if (varlist.MaxIndex()<1) {
		msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : var list should contain at least 2 items
		exit
		}
	for index,value in varlist {
		if value is not number 
			{
			msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : %value% is not a number
			exit
			}
		else
			var1-=value
	}
	return var1
}

MULT_F(varlist*) {
	if (varlist.MaxIndex()<2) {
		msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : var list should contain at least 2 items
		exit
		}
	for index,value in varlist {
		if value is not number 
			{
			msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : %value% is not a number
			exit
			}
		else if A_Index=1
			result:=value
		else
			result *= value
	}
	return result
}

POWER_F(varlist*) {
	if (varlist.MaxIndex()<2) {
		msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : var list should contain at least 2 items
		exit
		}
	for index,value in varlist {
		if value is not number 
			{
			msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : %value% is not a number
			exit
			}
		else if A_Index=1
			result:=value
		else
			result := result ** value
	}
	return result
}

DIV_F(varlist*) {
	if (varlist.MaxIndex()<2) {
		msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : var list should contain at least 2 items
		exit
		}
	for index,value in varlist {
		if value is not number 
			{
			msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : %value% is not a number
			exit
			}
		else if !value {
			msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : %value% cannot be empty
			exit
		}
		else if A_Index=1
			result:=value
		else
			result /= value
	}
	return result
}

INCREM_FU(ByRef var1) {
		if var1 is not number 
			{
			msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : %var1% is not a number
			exit
			}
		else
			return ++var1
}

DECREM_FU(ByRef var1) {
		if var1 is not number 
			{
			msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : %var1% is not a number
			exit
			}
		else
			return --var1
}

FLOORDIV_FU(var,divisor) {
;DigiDon: not sure if variadic fct would make sense?
	if !divisor
		{
		msgbox MATH FCT %A_ThisFunc% ERROR : absent divisor
		exit
		}
	if var is not number 
		{
		msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : %var% is not a number
		exit
		}
	if divisor is not number 
		{
		msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : %divisor% is not a number
		exit
		}
	return var // divisor
}

BITLEFT_FU(var1,var2) {
;Digidon : unsure of this one. Variadic or not? Error checking?
	if var1 is not number 
		{
		msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : %var1% is not a number
		exit
		}
	if var2 is not number 
		{
		msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : %var2% is not a number
		exit
		}
	return var1 << var2
}

BITRIGHT_FU(var1,var2) {
;Digidon : unsure of this one. Variadic or not? Error checking?
	if var1 is not number 
		{
		msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : %var1% is not a number
		exit
		}
	if var2 is not number 
		{
		msgbox MATH FCT VARIADIC %A_ThisFunc% ERROR : %var2% is not a number
		exit
		}
	return var1 >> var2
}