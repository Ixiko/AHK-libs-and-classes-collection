;
; eval() v1.0 - Dynamic expression evaluation for AutoHotkey_L
;
; Crazily written by fincs - IT MAY CRASH
; The expression parsing code is translated from the AHK sources. If you need
; to know how it works, refer to the original code.
;
; WARNING - THIS LIBRARY ABUSES INTERNAL AHK STRUCTURES - IT IS GUARANTEED
; TO BE BROKEN BY A FUTURE AHK VERSION - Written for AutoHotkey v1.1.08
;
; Search this file for 'TODO' and 'HACK' in order to know what's to be done
;

eval(expr)
{
	; ppTokens = address of Func("dummy")->mJumpToLine->mArg[0].postfix
	static ppTokens := NumGet(NumGet(&Func("___dynexpr") + A_PtrSize*2) + 8) + 3*A_PtrSize
	try
	{
		toks := eval_ParseExpr(expr) ; the returned object needs to be kept
		pNewTokens := eval_ConvertTokens(toks)
		pOldTokens := NumGet(ppTokens+0)
		NumPut(pNewTokens, ppTokens+0)
		retval := ___dynexpr()
		NumPut(pOldTokens, ppTokens+0)
		eval_FreeTokens(pNewTokens)
		return retval
	}catch e
	{
		msg := e.message
		what := e.extra
		t = Error while executing expression - %msg%`n
		if what
			t .= "Specifically: " what "`n"
		t .= "`n" expr
		MsgBox, 16, eval(), % t
		return
	}
}

; Stub function
___dynexpr()
{
	global
	return "" ; force expression
}

/*
struct ExprTokenType
{
	union
	{
		__int64 value_int64;
		double  value_double;
		struct
		{
			union
			{
				IObject* pObj;
				DerefType* pDeref; // SYM_FUNC
				Var* pVar;
				LPTSTR pMarker; // SYM_STRING and SYM_OPERAND
			};
			union // It's used by SYM_FUNC (helps built-in functions), SYM_DYNAMIC, SYM_OPERAND, and perhaps other misc. purposes.
			{
				LPTSTR pBuf;
				size_t marker_length;
			};
		};
	};

	SymbolType symbol;
	ExprTokenType* pCircuitToken;
}
*/

/*
struct DerefType
{
	LPTSTR marker;
	union
	{
		Var *var;
		Func *func;
	};
	BYTE is_function;
#define DEREF_VARIADIC 2
	DerefParamCountType /*UCHAR*/ param_count; // The actual number of parameters present in this function *call*.  Left uninitialized except for functions.
	DerefLengthType /*WORD*/ length; // Listed only after byte-sized fields, due to it being a WORD.
};
*/

; eval_ParseExpr() - it parses an expression and it yields a token array
eval_ParseExpr(expr, stopAt="", ByRef i=1)
{
	expr := eval_Unescape(expr)
	infix := eval_TokenizeInfixExpr(expr, stopAt, i)
	return eval_InfixToPostfix(infix, expr)
}

; eval_ConvertTokens() - it converts a token array to the AutoHotkey internal format
eval_ConvertTokens(toks)
{
	static tokenSize := A_PtrSize = 4 ? 16 : 32
	static off_symbol := tokenSize - 2*A_PtrSize
	static derefSize := 2*A_PtrSize + 4
	static emptyString := "" ; must be used for empty strings
	toks.Insert({sym: Syms.Invalid}) ; insert end-of-expr token
	
	nToks := toks._MaxIndex()
	pToks := __mem(nToks*tokenSize)
	
	try
	{
		if !pToks
			eval_Error("CAN'T ALLOCATE TOKENS")
		
		; Zero the structure
		DllCall("msvcrt\memset", "ptr", pToks, "int", 0, "uptr", nToks*tokenSize, "cdecl")

		for i,tok in toks
		{
			pTok := pToks + (i-1)*tokenSize
			sym := tok.sym
			if Syms.Operand = sym
			{
				; HACK: SYM_OPERAND is not supported
				isInt := tok.val_isInt
				if isInt !=
				{
					sym := isInt ? Syms.Integer : Syms.Float
					tok.val := tok.val_pure
					if tok.val = ""
						sym := Syms.String
				}else sym := Syms.String
			}
			NumPut(sym, pTok + off_symbol, "int")
			if Syms.String = sym
				NumPut(tok.val != "" ? tok._GetAddress("val") : &emptyString, pTok + 0)
			else if Syms.Integer = sym
				NumPut(tok.val, pTok + 0, "int64")
			else if Syms.Float = sym
				NumPut(tok.val, pTok + 0, "double")
			else if Syms.Var = sym
			{
				if tok.deref
					eval_Error("Double-derefs not supported yet", tok.val) ; TODO
				pVar := eval_FindGlobalVar(tok.val)
				if !pVar
					eval_Error("Bad variable name", tok.val)
				if pVar = 1
				{
					; Built-in variable - replace it with a string (ugly but simple hack)
					n := tok.val
					tok.val := %n% ; resolve the value
					NumPut(Syms.String, pTok + off_symbol, "int")
					NumPut(tok.val != "" ? tok._GetAddress("val") : &emptyString, pTok + 0)
				}else
					NumPut(pVar, pTok + 0)
			}else if Syms.Func = sym
			{
				if tok.deref
					eval_Error("Double-derefs not supported yet", tok.val) ; TODO
				oFunc := eval_FindFunc(tok.val)
				if !oFunc
					eval_Error("Bad function name", tok.val)
				pFunc := &oFunc
				pDeref := __mem(derefSize)
				if !pDeref
					eval_Error("CAN'T ALLOCATE DEREF")
				NumPut(pFunc, pDeref + A_PtrSize)
				NumPut(tok.variadic ? 2 : 1, pDeref + 2*A_PtrSize, "UChar")
				NumPut(tok.pcount, pDeref + 2*A_PtrSize + 1, "UChar")
				NumPut(0, pDeref + 2*A_PtrSize + 2, "UShort")
				NumPut(pDeref, pTok + 0)
			}
			if tok.circuit
				NumPut(pToks + (tok.circuit - 1)*tokenSize, pTok + off_symbol + A_PtrSize)
			;msgbox % sym
		}
	}catch e
	{
		if pToks
			eval_FreeTokens(pToks, nToks) ; pass # of tokens because it may be unfinished
		throw e
	}
	
	return pToks
}

; eval_FreeTokens() - it frees an array of AutoHotkey-format tokens
eval_FreeTokens(x, nTok = -1)
{
	static tokenSize := A_PtrSize = 4 ? 16 : 32
	static off_symbol := tokenSize - 2*A_PtrSize
	Loop
	{
		i := A_Index
		if (nTok != -1) && (i = nTok)
			break
		pTok := x + (i - 1)*tokenSize
		sym := NumGet(pTok + off_symbol)
		if Syms.Func = sym
			__free(NumGet(pTok+0)) ; free deref
		if Syms.Invalid = sym
			break
	}
	__free(x)
}

; Internal memory allocation

__mem(z)
{
	return DllCall("GlobalAlloc", "uint", 0, "uptr", z, "ptr")
}

__free(p)
{
	if p
		DllCall("GlobalFree", "ptr", p)
}

; eval_TokenizeInfixExpr() - it tokenizes an infix expression and yields an array of tokens
eval_TokenizeInfixExpr(ByRef expr, stopAt="", ByRef i=1)
{
	expr_len := StrLen(expr), toks_i := 0, depth := 0
	toks := []
	isInt := false, isFloat := false
	while i <= expr_len
	{
		c := SubStr(expr, i, 1)
		if c is space
			goto _parse_continue
		
		tok := {}
		
		if !depth && InStr(stopAt, c)
			break
		
		; Check if this character is an operator
		
		c1 := SubStr(expr, i+1, 1)
		
		if c = +
			if c1 = =
				i ++, tok.sym := Syms.AssignAdd
			else if toks_i && Syms.YieldsAnOperand(toks[toks_i].sym)
				if c1 = +
					i ++, tok.sym := Syms.PostIncr
				else tok.sym := Syms.Add
			else if c1 = +
				i ++, tok.sym := Syms.PreIncr
			else goto _parse_continue ; Ignore unary plus
		else if c = -
			if c1 = =
				i ++, tok.sym := Syms.AssignSub
			else if toks_i && Syms.YieldsAnOperand(toks[toks_i].sym)
				if c1 = -
					i ++, tok.sym := Syms.PostDecr
				else tok.sym := Syms.Sub
			else if c1 = -
				i ++, tok.sym := Syms.PreDecr
			else tok.sym := Syms.Neg ; Unary minus; negative numbers will be handled later (unlike AutoHotkey)
		else if c = ,
			tok.sym := Syms.Comma
		else if c = /
			if c1 = =
				i ++, tok.sym := Syms.AssignDiv
			else if c1 = /
				if SubStr(expr, i+2, 1) = "="
					i += 2, tok.sym := Syms.AssignIDiv
				else i ++, tok.sym := Syms.IDiv
			else tok.sym := Syms.Div
		else if c = *
			if c1 = =
				i ++, tok.sym := Syms.AssignMul
			else if c1 = *
				i ++, tok.sym := Syms.Pow
			else tok.sym := (toks_i && Syms.YieldsAnOperand(toks[toks_i].sym)) ? Syms.Mul : Syms.Deref
		else if c = !
			if c1 = =
				i ++, tok.sym := Syms.NotEqual
			else tok.sym := Syms.HighNot
		else if c = (
		{
			if toks_i && Syms.YieldsAnOperand(toks[toks_i].sym) && InStr(" `t)""", SubStr(expr, i-1, 1))
				toks[++toks_i] := { sym: Syms.Cat }
			tok.sym := Syms.OParen, depth ++
		}else if c = )
			tok.sym := Syms.CParen, depth --
		else if c = [
			if toks_i && (peek := toks[toks_i]).sym = Syms.Dot
			  && SubStr(LTrim(SubStr(expr, i+1)), 1, 1) != "]"
				peek.sym := Syms.OBracket, depth ++
			else if toks_i && Syms.YieldsAnOperand(peek.sym)
				tok.sym := Syms.OBracket, tok.val := "%FObjGet", tok.pcount := 1, depth ++
			else tok.sym := Syms.OBracket, tok.val := "Array", tok.pcount := 0, depth ++
		else if c = ]
			tok.sym := Syms.CBracket, tok.pos := i, depth --
		else if c = {
			if toks_i && Syms.YieldsAnOperand(toks[toks_i].sym)
				eval_Error("Unexpected ""{""")
			else tok.sym := Syms.OBrace, tok.val := "Object", tok.pcount := 0, depth ++
		else if c = }
			tok.sym := Syms.CBrace, tok.pos := i, depth --
		else if c = =
			if cp1 = =
				i ++, tok.sym := Syms.EqualCase
			else tok.sym := Syms.Equal
		else if c = >
			if cp1 = =
				i ++, tok.sym := Syms.Gte
			else if cp1 = >
				if SubStr(expr, i+2, 1) = "="
					i += 2, tok.sym := Syms.AssignShr
				else i ++, tok.sym := Syms.Shr
			else tok.sym := Syms.Gt
		else if c = <
			if cp1 = =
				i ++, tok.sym := Syms.Lte
			else if cp1 = <
				if SubStr(expr, i+2, 1) = "="
					i += 2, tok.sym := Syms.AssignShl
				else i ++, tok.sym := Syms.Shl
			else tok.sym := Syms.Lt
		else if c = &
			if c1 = &
				i ++, tok.sym := Syms.LAnd
			else if c1 = =
				i ++, tok.sym := Syms.AssignBAnd
			else tok.sym := (toks_i && Syms.YieldsAnOperand(toks[toks_i].sym)) ? Syms.BAnd : Syms.Addr
		else if c = |
			if c1 = |
				i ++, tok.sym := Syms.LOr
			else if c1 = =
				i ++, tok.sym := Syms.AssignBOr
			else tok.sym := Syms.BOr
		else if c = ^
			if c1 = =
				i ++, tok.sym := Syms.AssignBXor
			else tok.sym := Syms.BXor
		else if c = ~
			if c1 = =
				i ++, tok.sym := Syms.RegExMatch, tok.val := "RegExMatch", tok.pcount := 2
			else tok.sym := Syms.BNot
		else if c = ?
			tok.sym := Syms.IffThen
		else if c = :
			if c1 = =
				i ++, tok.sym := Syms.Assign
			else tok.sym := Syms.IffElse
		else if c = "
		{
			gosub _autoconcat
			tok.sym := Syms.String
			Loop
				if (c := SubStr(expr, ++i, 1)) = """"
					if SubStr(expr, i+1, 1) != """"
						break
					else i ++, tok.val .= c
				else if (c = "")
					eval_Error("Missing close-quote")
				else tok.val .= c
		}else
		{
			if c = .
			{
				if c1 = =
				{
					i ++, tok.sym := Syms.AssignCat
					goto _add_token
				}
				if !LTrim(c1)
					if !toks_i || LTrim(SubStr(expr, i-1, 1)) != ""
						eval_Error("Unsupported use of "".""")
					else
					{
						tok.sym := Syms.Cat
						goto _add_token
					}
				if toks_i && Syms.YieldsAnOperand(toks[toks_i].sym)
				{
					i ++
					
					op_end := i
					while eval_SafeInStr("0123456789abcdefghijklmnopqrstuvwxyz_", d := SubStr(expr, op_end, 1))
						op_end ++
					
					if !eval_SafeInStr(Syms.OpTerminators, d)
						eval_Error("Only alphanumeric characters and underscore are allowed here.", ">" d)
					
					if (op_end = i) && d != "("
						eval_Error("Unsupported use of "".""")
					
					isNewOp := false
					prevPos := toks_i
					while prevPos >= 1
					{
						prevTok := toks[prevPos]
						if prevTok.sym != Syms.Dot
						{
							if Syms.IsOperand(prevTok.sym) && prevPos > 1
								prevPos --
							isNewOp := toks[prevPos].sym = Syms.NewObj
							break
						}
						prevPos -= 2
					}
					
					toks[++toks_i] := { sym: Syms.Operand, val: SubStr(expr, i, op_end - i) }
					
					tok.pcount := 2
					if (d = "(") && !isNewOp
						tok.sym := Syms.Func, tok.val := "%FObjCall"
					else tok.sym := Syms.Dot, tok.val := "%FObjGet"
					
					toks[++toks_i] := tok
					i := op_end
					continue
				}
			}
			
			op_end := i + 1
			while !InStr(Syms.OpTerminators, d := SubStr(expr, op_end, 1))
				op_end ++
			
			; This part differs from AHK source code
			; There are no separate deref structures, so integer/float/deref distinction
			; must be done separately
			
			op := SubStr(expr, i, op_end-i), isInt := false, isHex := false
			if not isDeref := InStr(op, "%")
				if op is integer
					isInt := true, isHex := SubStr(op, 1, 2) = "0x"
			
			if !isDeref && isInt && !isHex && d = "."
			{
				; Skip over the decimal portion
				old_op_end := ++op_end
				while !InStr(Syms.OpTerminators, d := SubStr(expr, op_end, 1))
					op_end ++
				if (op_end != old_op_end)
					op := SubStr(expr, i, op_end-i), isFloat := true, isInt := false
				else op_end -- ; revert the ++op_end above
			}
			
			afterwards := LTrim(SubStr(expr, op_end))
			followedByColon := SubStr(afterwards, 1, 1) = ":" && SubStr(afterwards, 2, 1) != "="
			
			if isInt || isFloat
			{
				gosub _autoconcat
				tok.sym := Syms.Operand, tok.val := op
				; Check for negative numbers
				if toks[toks_i].sym = Syms.Neg
					toks_i --, tok.val := "-" tok.val
				tok.val_pure := tok.val + ((tok.val_isInt := isInt) ? 0 : 0.0)
			}else
			; Var, var deref, func deref or word keyword
			if !followedByColon && op = "and"
				tok.sym := Syms.LAnd
			else if !followedByColon && op = "or"
				tok.sym := Syms.LOr
			else if !followedByColon && op = "not"
				tok.sym := Syms.LowNot
			else if !followedByColon && op = "new"
				tok.sym := Syms.NewObj, tok.val := "%FObjNew", tok.pcount := 1
			else if !followedByColon
			{
				gosub _autoconcat
				
				tok.val := op, tok.deref := isDeref
				
				if SubStr(expr, op_end, 1) != "("
				{
					; It's a variable
					tok.sym := Syms.Var
					if !isDeref
					{
						; Check for built-in vars
						if op = true
							tok.sym := Syms.Integer, tok.val := 1
						else if op = false
							tok.sym := Syms.Integer, tok.val := 0
						else if op = A_IsUnicode
							tok.sym := Syms.Integer, tok.val := 1
						; else if it's a built-in var it should be SYM_DYNAMIC
						; TODO: more built-in vars
					}
				}else
					; It's a function call
					tok.sym := Syms.Func, tok.pcount := 0
			}else if followedByColon
				tok.sym := Syms.Operand, tok.val := op
			
			i := op_end - 1
		}
		
		_add_token:
		toks[++toks_i] := tok
		;toks.Push(tok)
		_parse_continue:
		i ++
	}
	toks[++toks_i] := { sym: Syms.Invalid }
	return toks
	
	_autoconcat:
	if toks_i && Syms.YieldsAnOperand(toks[toks_i].sym)
		toks[++toks_i] := { sym: Syms.Cat } ; Auto-concat kicks in
	return
}

; eval_InfixToPostfix() - it converts an infix token array to a postfix token array
eval_InfixToPostfix(infix, ByRef expr)
{	
	postfix := [], postfix_count := 1, i := 1, in_param_list := ""
	stack := { 0: { sym: Syms.Begin } }, stack_count := 1
	Loop
	{
		infix_symbol := infix[i].sym
		stack_symbol := stack[stack_count-1].sym
		
		if Syms.IsOperand(infix_symbol)
		{
			postfix[postfix_count++] := infix[i++]
			continue
		}
		
		if IsLabel(l := "_s_" infix_symbol)
			goto %l%
		else goto _s_else
		_s_end:
		continue
		
		standard_pop_into_postfix:
		postfix_token := (postfix[postfix_count] := stack[--stack_count])
		postfix_symbol := postfix_token.sym
		; TODO: support obj.field(something) := val
		; TODO: resolve +=, -=, etc etc etc
		if (postfix_symbol = Syms.NewObj || postfix_symbol = Syms.RegExMatch)
			postfix_token.sym := Syms.Func
		postfix_count ++
		continue
		
		_s_11: ; CParen
		_s_12: ; CBracket
		_s_13: ; CBrace
		_s_17: ; Comma
		if (infix_symbol != Syms.Comma) && !Syms.IsOParenMatchingCParen(stack_symbol, infix_symbol)
			if (stack_symbol = Syms.Begin) || Syms.IsOParenLike(stack_symbol)
				eval_Error(infix_symbol = Syms.CParen ? "Missing ""(""" : (infix_symbol = Syms.CBracket ? "Missing ""[""" : "Missing ""{"""))
			else goto standard_pop_into_postfix
		if in_param_list && Syms.IsOParenLike(stack_symbol)
		{
			func := in_param_list.val
			oFunc := eval_FindFunc(func)
			if oFunc && oFunc.MaxParams && in_param_list.pcount >= oFunc.MaxParams
			{
				if !oFunc.IsVariadic
					eval_Error("Too many parameters", func)
				oFunc := ""
			}
			
			if (infix_symbol = Syms.Comma) || (infix[i-1].sym != stack_symbol)
			{
				; TODO: Parameter validation + default parameter placing
				if infix[i-1].sym = Syms.Comma || infix[i-1].sym = stack_symbol
					eval_Error("Blank function parameters not supported yet")
				
				in_param_list.pcount ++
				
				if (stack_symbol = Syms.OBrace) && (in_param_list.pcount & 1)
					eval_Error("Missing ""key:"" in object literal.")
			}
			
			if oFunc && infix_symbol == Syms.CParen && in_param_list.pcount < oFunc.MinParams && !in_param_list.variadic
				eval_Error("Missing parameters", func)
		}
		
		if (infix_symbol = Syms.CParen)
		{
			stack_count --, i ++
			
			in_param_list := stack[stack_count].pos
			if stack[stack_count-1].sym = Syms.Func
				goto standard_pop_into_postfix
		}else if (infix_symbol = Syms.CBracket) || (infix_symbol = Syms.CBrace)
		{
			stack_top := stack[stack_count - 1]
			stack_top.sym := Syms.Func
			
			if SubStr(expr, infix[i].pos+1, 1) = "("
			{
				if (infix_symbol = Syms.CBrace) || in_param_list.val != "%FObjGet" || in_param_list.pcount != 2
					eval_Error("Unsupported method call syntax.")
				stack_top.val := "%FObjCall"
				infix[++i].pos := stack_top.pos
				stack[stack_count++] := infix[i++]
			}else
			{
				i ++
				in_param_list := stack_top.pos
				goto standard_pop_into_postfix
			}
		}else
		{
			if Syms.OpPrec[stack_symbol] < Syms.OpPrec[infix_symbol]
			{
				if !in_param_list
				{
					stack[stack_count++] := infix[i]
					fwd_infix_pos := i + 1
					Loop
					{
						fwd_infix := infix[fwd_infix_pos++], fwd_infix_2 := infix[fwd_infix_pos++]
						if fwd_infix.sym = Syms.Invalid || fwd_infix_2.sym != Syms.Equal
							break
						if fwd_infix.sym = Syms.Var
						{
							fwd_infix_2.sym := Syms.Assign
							continue
						}
					}
				}
				i ++
			}else goto standard_pop_into_postfix
		}
		goto _s_end
		
		_s_61: ; Func
		stack[stack_count++] := infix[i++]
		
		_s_14: ; OParen
		infix[i].pos := in_param_list
		if (infix_symbol = Syms.Func)
			in_param_list := infix[i-1]
		else if (stack_symbol = Syms.NewObj)
			`(in_param_list := stack[stack_count - 1]).sym := Syms.Func
		else in_param_list := ""
		stack[stack_count++] := infix[i++]
		goto _s_end
		
		_s_15: ; OBracket
		_s_16: ; OBrace
		infix[i].pos := in_param_list
		stack[stack_count++] := in_param_list := infix[i++]
		goto _s_end
		
		_s_10: ; Dot
		infix[i].sym := Syms.Func
		stack[stack_count++] := infix[i++]
		goto standard_pop_into_postfix
		
		_s_30: ; IffElse
		if (stack_symbol = Syms.Begin)
			eval_Error("A "":"" is missing its ""?""")
		if in_param_list && stack_symbol = Syms.OBrace
		{
			in_param_list.pcount ++
			i ++
			continue
		}
		if (stack_symbol = Syms.OParen)
			eval_Error("Missing "")"" before "":""")
		if (stack_symbol = Syms.OBracket)
			eval_Error("Missing ""]"" before "":""")
		if (stack_symbol = Syms.OBrace)
			eval_Error("Missing ""}"" before "":""")
		if (stack_symbol = Syms.IffThen)
		{
			postfix[postfix_count] := stack[--stack_count]
			postfix[postfix_count++].circuit := infix[i]
			stack[stack_count++] := infix[i++]
		}else goto standard_pop_into_postfix
		goto _s_end
		
		_s_64: ; Invalid
		if (stack_symbol = Syms.Begin)
		{
			stack_count --
			break
		}else if (stack_symbol = Syms.OParen)
			eval_Error("Missing "")""")
		else if (stack_symbol = Syms.OBracket)
			eval_Error("Missing ""]""")
		else if (stack_symbol = Syms.OBrace)
			eval_Error("Missing ""}""")
		else goto standard_pop_into_postfix
		
		_s_50: ; Multiply
		if in_param_list && (infix[i+1].sym = Syms.CParen || infix[i+1].sym = Syms.CBracket)
		{
			in_param_list.variadic := true
			i ++
			continue
		}
		
		_s_else:
		if Syms.OpPrec[stack_symbol] < (Syms.OpPrec[infix_symbol] + (Syms.OpPrec[infix_symbol]&1))
		  || Syms.IsAssgnExcptPostAndPre(infix_symbol)
		  || stack_symbol = Syms.Power && (infix_symbol >= Syms.Negative && infix_symbol <= Syms.Deref
		  || infix_symbol = Syms.LowNot)
		{
			if (infix_symbol <= Syms.LAnd) && infix_symbol >= Syms.IffThen && postfix_count
				postfix[postfix_count - 1].circuit := infix[i]
			stack[stack_count++] := infix[i++]
		}else goto standard_pop_into_postfix
	}
	; Resolve circuit fields
	for each,tok in postfix
		if tok.circuit
			for k,v in postfix
				if tok.circuit == v
					tok.circuit := k
	return postfix
}

; eval_Error() - error routine
eval_Error(txt, v="")
{
	throw Exception(txt, -1, v)
}

; eval_SafeInStr() - returns false if the needle is an empty string
eval_SafeInStr(ByRef a, ByRef b, p*)
{
	return b != "" ? InStr(a, b, p*) : 0
}

; Token symbols
class Syms
{
	static PURE_NOT_NUMERIC := 0
		, PURE_INTEGER := 1, PURE_FLOAT := 2
		, String := 0, Integer := 1, Float := 2
		, Var := 3, Operand := 4, Object := 5, Dynamic := 6
		, OperandEnd := 7, Begin := 7
		, PostIncr := 8, PostDecr := 9
		, Dot := 10, CParen := 11, CBracket := 12, CBrace := 13, OParen := 14, OBracket := 15, OBrace := 16, Comma := 17
		, Assign := 18, AssignAdd := 19, AssignSub := 20, AssignMul := 21, AssignDiv := 22, AssignIDiv := 23
		, AssignBOr := 24, AssignBXor := 25, AssignBAnd := 26, AssignShl := 27, AssignShr := 28, AssignCat := 29
		, IffElse := 30, IffThen := 31
		, LOr := 32, LAnd := 33
		, LowNot := 34
		, Equal := 35, EqualCase := 36, NotEqual := 37
		, Gt := 38, Lt := 39, Gte := 40, Lte := 41
		, Cat := 42, BOr := 43, BXor := 44, BAnd := 45, Shl := 46, Shr := 47
		, Add := 48, Sub := 49, Mul := 50, Div := 51, IDiv := 52
		, Neg := 53, HighNot := 54, BNot := 55, Addr := 56, Deref := 57
		, Pow := 58, PreIncr := 59, PreDecr := 60
		, Func := 61, NewObj := 62, RegExMatch := 63, Count := 64, Invalid := 64
		
	static OpTerminators := " `t<>=/|^,:*&~!()[]{}+-?."
	
	static OpPrec := [0,0,0,0,0,0,0
		,82,82,86,4,4,4,4,4,4,6,7,7,7,7,7,7,7,7,7,7,7,7
		,11,11,16,20,25,30,30,30,34,34,34,34,38,42,46
		,50,54,54,58,58,62,62,62,67,67,67,67,67,72,77,77,86,86,36]
		, _ := Syms.OpPrec[0] := 0 ; fill first element
		
	IsNumeric(a)
	{
		return a = 1 || a = 2
	}
	IsOperand(a)
	{
		return a < 7
	}
	IsOParenLike(a)
	{
		return a <= 16 && a >= 14
	}
	IsCParenLike(a)
	{
		return a <= 13 && a >= 11
	}
	IsOParenMatchingCParen(a,b)
	{
		return (a-b) = 3
	}
	CParenForOParen(a)
	{
		return a - 3
	}
	OParenForCParen(a)
	{
		return a + 3
	}
	YieldsAnOperand(a)
	{
		return a < 14
	}
	IsAssgnExcptPostAndPre(a)
	{
		return a <= 29 && a >= 18
	}
	IsAssgnOrPostOp(a)
	{
		return (a <= 29 && a >= 18) || a = 8 || a = 9
	}
	IsRelOp(a)
	{
		return a >= 35 && a <= 41
	}
}

; eval_Unescape() - unescape AHK escape sequences
eval_Unescape(ByRef t, escchar="``")
{
	i := 1, l := StrLen(t), t2 := ""
	while i <= l
	{
		c := SubStr(t, i++, 1)
		if (c = escchar)
		{
			c := SubStr(t, i++, 1)
			if (c = escchar)
				t2 .= escchar
			else if c = n
				t2 .= "`n"
			else if c = r
				t2 .= "`r"
			else if c = b
				t2 .= "`b"
			else if c = t
				t2 .= "`t"
			else if c = v
				t2 .= "`v"
			else if c = a
				t2 .= "`a"
			else if c = f
				t2 .= "`f"
			else t2 .= c
		}else t2 .= c
	}
	return t2
}

__GetObjCommon(f, id) ; must be here due to static expr evaluation order issues
{
	static tokenSize := A_PtrSize = 4 ? 16 : 32
	; WOO crazyness!!!!
	return Object(NumGet(NumGet(NumGet(NumGet(NumGet(&Func(f) + A_PtrSize*2) + 8) + 4 + 2*A_PtrSize) + id*tokenSize) + A_PtrSize))
}

; eval_FindFunc() - find a function (including internal ones)
eval_FindFunc(name)
{
	static _extra := { "%FObjGet": __GetObjCommon("__dummyget", 1), "%FObjSet": __GetObjCommon("__dummyset", 2)
		, "%FObjCall": __GetObjCommon("__dummycall", 2), "%FObjNew": __GetObjCommon("__dummynew", 1) }
	oFun := Func(name)
	if not oFun := Func(name)
		oFun := _extra[name]
	return oFun
}

__dummyget()
{
	return o[] ; ACT_RETURN[VAR[o] CALL[ObjGet]]
}

__dummyset()
{
	o[] := "" ; ACT_EXPR[VAR[o] STRING[""] CALL[ObjSet]]
}

__dummycall()
{
	o.() ; ACT_EXPR[VAR[o] STRING[""] CALL[ObjCall]]
}

__dummynew()
{
	return new o ; ACT_RETURN[VAR[o] CALL[ObjNew]]
}

; eval_FindGlobalVar() - get the address of a global var
eval_FindGlobalVar(name)
{
	global
	try return __FindGlobalVar(%name%)
	catch
		return 0
}

__FindGlobalVar(ByRef aliasVar)
{
	; ppAliasFor = address of Func("_FindGlobalVar")->mParam[0].var->mAliasFor
	static ppAliasFor := NumGet(NumGet(&Func("__FindGlobalVar")+3*A_PtrSize)) + 8 + A_PtrSize
	if !IsByRef(aliasVar)
		return 1 ; built-in var
	return NumGet(ppAliasFor+0)
}
