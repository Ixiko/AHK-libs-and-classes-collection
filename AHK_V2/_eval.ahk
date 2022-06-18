; ======================================================================================
; === Examples =========================================================================
; ======================================================================================

; msgbox Format("0x{:X}",(0xFF | 0x1))

; msgbox eval("0 != 0") "`n"
          ; . (0 != 0)

; msgbox Eval("(((15) & 65535) | ((1 != 0) ? 65536 : 0) | ((1 != 0) ? 131072 : 0) | ((0 != 0) ? 262144 : 0))") "`n"
           ; . (((15) & 65535) | ((1 != 0) ? 65536 : 0) | ((1 != 0) ? 131072 : 0) | ((0 != 0) ? 262144 : 0))

; msgbox eval("(1048576 | 1 | 1048576 | 16)") "`r`n" ; This illustrates proper parsing.  Matching "1048576 | 1"
           ; . (1048576 | 1 | 1048576 | 16)          ; will not be confused with matching "1048576 | 16".

; msgbox eval("!(1-(2+3*-4**5)<<6>>7&8^9|10+~11) - -0x12") "`r`n" ; This illustrates complex order of operations with nested parenthesis.
           ; . !(1-(2+3*-4**5)<<6>>7&8^9|10+~11) - -0x12

; msgbox eval("!1-2+3*-4**5<<6>>7&8^9|10+~11 - -0x12") "`r`n" ; This illustrates complex order of operations without nested parenthesis.
           ; . !1-2+3*-4**5<<6>>7&8^9|10+~11 - -0x12

; msgbox eval("!1-2+3*-4**5<<6>>7&8^9|10+~11 - -~-0x12") "`r`n" ; Trying to make it as silly-complex as possible.
           ; . !1-2+3*-4**5<<6>>7&8^9|10+~11 - -~-0x12

; msgbox eval("-~!-3") "`r`n" ; crazy but possible valid expression
           ; . -~!-3

; msgbox eval("2 ** -3 ** -~-3") "`r`n" ; another crazy valid expression that's difficult to parse.
           ; . 2 ** -3 ** -~-3

; msgbox eval("2 + -3 ** 3") "`r`n" ; simple but tricky
           ; . 2 + -3 ** 3

; msgbox eval("2 ** -3 * 4 + 5 * 6 // 7 - 8") "`r`n" ; Still simple, but slightly more tricky.
           ; . 2 ** -3 * 4 + 5 * 6 // 7 - 8

; msgbox "testing if math expr: " eval("x86",true) ; first char MUST be a digit / ~ / ! / - or opening parenthesis "("

; msgbox eval("0 = 5 > 6") "`n"
          ; . (0 = 5 > 6)

; msgbox eval("~( ( (0 || 1) ? 44 : 55 ) * 7 )") "`n"
           ; . ~( ( (0 || 1) ? 44 : 55 ) * 7 )

; msgbox eval("(100 == 4 || 100 == 5)",true)
; msgbox eval(" (2560 <= 0x0603) ",true) " / " eval("(2560 <= 0x0603)")

; msgbox Float("1.0000000000000001e+300")

; msgbox eval("1.0000000000000001e+300 * 1.0000000000000001e+300")

; ======================================================================================
; ======================================================================================

eval(e,test:=false) { ; extend support for parenthesis
    
    ; dbg("eval - in: " e)
    
    e := RegExReplace(e,"(!|~)[ \t]+","$1")
    
    If (test And Trim(e,"`t ") = "")
        return false
    Else If (test) {
        t1 := !RegExMatch(Trim(e),"i)(^[^\d!~\-\x28 ]|! |~ |[g-wyz]+|['\" . '"\$@#%\{\}\[\]\\,;\``_])') ; only return true/false testing "e" as expression
        t2 := ( !InStr(e,"++") && !InStr(e,"--"))
        t3 := !RegExMatch(e,"i)(?<![a-f\dx])[a-f]")
        
        StrReplace(e,"?","?",,&q) ; count question marks
        StrReplace(e,":",":",,&c) ; count colons
        t4 := (q=c)
        
        return (t1 && t2 && t3 && t4)
    }
    
    If RegExMatch(e,"i)(! |~ |[g-wyz]+|['\" . '"\$@#%\{\}\[\]\\,;\``_])',&m) ; check for invalid characters, non-numbers, invalid punctuation, etc.
        throw Error("Syntax error.`r`n     Reason: " Chr(34) m[1] Chr(34) "`r`n`r`nExpression: " e,-1,"Not a math expression.")
    
    If ( InStr(e,"++") || InStr(e,"--") )
        throw Error("Syntax error.`r`n     Reason: -- and ++ are not valid.",-1,"Not a math expression.")
    
    StrReplace(e,"?","?",,&q) ; count question marks
    StrReplace(e,":",":",,&c) ; count colons
    If (q!=c)
        throw Error("Syntax error.`r`n     Reason: ternary statement must be complete with question mark (?) and colon (:).",-1)
    
    StrReplace(e,"(","(",,&LP), StrReplace(e,")",")",,&RP)
    If (LP != RP)
        throw Error("Invalid grouping with parenthesis.  You must ensure the same number of ( and ) exist in the expression.`r`n`r`nExpression:`r`n    " e,-1)
    
    While RegExMatch(e, "i)(\x28[^\x28\x29]+\x29)", &m) {               ; match phrase surrounded by parenthesis, inner-most first
        
        ; dbg("bef e: " e)
        
        ans := _eval(match := m[0])                                     ; match and calculate result
        ans := (SubStr(ans,1,1) = "-") ? " " ans : ans                  ; resolved sub-expr value, add space for legit negative sign, ie. " -3"
        e := RegExReplace(StrReplace(e,match,ans,,,1),"(!|~) +","$1")   ; perform substitution, remove resulting spaces between !/~ and resolved value
        
        ; dbg("aft e: " e)
        ; dbg("============================================")
    }
    
    e := _eval(e)
    If IsInteger(e)
        return Integer(e)
    Else if (e="inf")
        throw Error("Number too large.",-1)
    Else
        return Float(e)
}

_eval(e) { ; support function for pure math expression without parenthesis
    If IsNumber(e)
        return e
    
    ; dbg("important e 1: " e)
    
    If RegExMatch(e,"i)(^[^\d!~\-\x28 ]|! |~ |[g-wyz]+|['\" . '"\$@#%\{\}\[\]\\,;\``_])',&m) ; check for invalid characters, non-numbers, invalid punctuation, etc.
        throw Error("Syntax error.`r`n     Reason: " Chr(34) m[1] Chr(34),-1,"Not a math expression.")
    
    Static _n   := "(?:\d+\.\d+(?:e\+\d+|e\-\d+|e\d+)?|0x[\dA-F]+|\d+)"  ; Regex to identify float/scientific notation, then hex, then base-10 numbers.  Only positive.
    Static _num := "([!~\-]*" _n ")"                                   ; Expand number definition to include - / ~ / !
    Static _ops := "(?:\*\*|\*|//|/|\+|\-|>>>|<<|>>|&&|&|\^|"            ; Define list of operators, in order of prescedence.
                 . "\|\|" . "|" . "\|" . "|" . ">=|<=|>|<|!=|==|=|\?|:)"
    
    new_e := "", p := 1, prev_m := ""
    typ := "number", expr := _num           ; Start looking for a number first.
    
    While RegExMatch(e,"i)" expr,&_m,p) {   ; Separate numbers and operators (except !/~ operators) with spaces.
        mat := _m[0]                        ; Capture match pattern.  Pattern starts with "number" / alternates with "oper".
        If (typ="number") {                 ; Alternate the RegEx search between numbers and operators to improve grouping/spacing of the expression.
            mat := RegExReplace(_m[1],"\-(\d+)","#$1") ; find "negative" values, replace "-" with "#"
            typ   := "oper"
            expr  := _ops
        } Else {
            typ  := "number"
            expr := _num
        }
        
        new_e .= ((new_e!="")?" ":"") mat
        p := _m.Pos(0) + _m.Len(0)
    }
    
    e := RegExReplace(new_e," {2,}"," ")                        ; Replace e with spaced-out/grouped expression, and replace multiple spaces with single space.
    old_e := e
    
    ; dbg("begin e: " e)
    
    Static order := "** !~ */ +- <> &^| >= == && ?:"            ; Order of operations with appropriate grouping.
    Static opers := StrSplit(order," ")
    Static n := "#?" _n                                         ; Basic number defiintion with # in place - for negative numbers.
    
    For i, op in opers {                                        ; Loop through operators in order of prescedence.
    
        ; dbg("oy ve -> e: " e)
        
        Switch op {
            
            Case "**":
                
                val2 := "", i_count := 0 ; just in case...
                sub_e := "", new_sub_e := ""                    ; Initialize temp vars for the building of sub-expressions.
                p := 1                                          ; Position tracking.
                fail_count := 0                                 ; These expressions can be broken up in different sections in the main expression, so track search fails.
                Static rg_ex1 := "([#!~\-]*" _n ")( *\*\* *)"   ; RegEx for number and exponent (**).  For 1st iteration in next WHILE loop.
                Static rg_ex2 := "([#!~\-]*" _n ")( *\*\* *)?"  ; RegEx for number and maybe exponent (**) for 2nd+ iteration in next WHILE loop.
                rg_ex := rg_ex1
                
                While (r := RegExMatch(e,"i)" rg_ex,&z,p)) {    ; Extract expr before resolving, because this needs to be right-to-left.
                    (z[2] = "") ? fail_count++ : ""             ; Increment fail count when "**" not found.  fail_count = 1 means the end of a sub-expr, but there may be more.
                    p := z.Pos(0) + z.Len(0)                    ; Adjust search position.
                    sub_e .= z[0]                               ; Append valid match to sub_e.
                    
                    If (fail_count = 1 And InStr(sub_e,"**")) { ; ****** End of exponenent expression, so evalute and replace. ******
                        new_sub_e := sub_e
                        While RegExMatch(new_sub_e,"i)([#!~]*)?(" _n ") *(\*\*) *([#!~\-]*" _n ")$",&y) { ; Get last 2 operands and operator with any unary - ! or ~.
                            mat := y[0]                          ; Capture full match.
                            o_op := y[1]                         ; Outside operators must be solved last, ie. -2 ** 3 is -(2 ** 3).
                            v1 := y[2]                           ; First operand.
                            v2 := StrReplace(y[4],"#","-")       ; Switch "#" to "-"
                            
                            ; dbg("** before: v1: " v1 " / v2: " v2)
                            
                            v2 := _eval(v2)                      ; Evaluate the exponent (2nd operand), resolve all ! and ~ first.  This behavior is undocumented in AHK v2.
                            
                            ; dbg("** after: v1: " v1 " / v2: " v2)
                            
                            val2 := v1 ** v2                     ; Resolve sub-sub-expression.
                            
                            ; dbg("** answer: " val2)
                            
                            new_sub_e := RegExReplace(new_sub_e,"\Q" mat "\E$",o_op val2) ; Ensure this substitution only happens at the end of the sub-expression.
                        }
                        
                        ; dbg("** new_sub_e: " new_sub_e)
                        ; dbg("** sub_e: " sub_e)
                        
                        RegExMatch(val2,"([\-!~]*)?(" _n ")",&y) ; Check for "-" to convert to "#".
                        If (IsObject(y) And InStr(y[1],"-"))
                            val2 := StrReplace(y[1],"-","#") y[2]
                        e := StrReplace(e,sub_e,new_sub_e,,,1)  ; Replace only the first instance of the match.  Maintain "#" sub for "-".
                        
                        ; dbg("** final e: " e)
                        
                        sub_e := "", new_sub_e := ""            ; Reset temp vars / sub-expressions.  
                        p := 1, fail_count := 0                 ; Reset postion tracking and fail_count.  Continue looping for another exponent sub-expression.
                        
                    } Else If (fail_count > 1)                  ; No more exponent expressions to evaluate, so Break.
                        Break
                    
                    (A_Index = 1) ? rg_ex := rg_ex2 : ""        ; Switch to new search right before 2nd iteration.
                }
                
            Case "!~":
                
                ; dbg("!~ start:  e: " e)
                
                While (r := RegExMatch(e,"i)(!|\~)" n,&z)) {    ; Find "inner most" expression and solve first.
                    _op  := z[1]
                    _mat := z[0]
                    v1 := StrReplace(SubStr(_mat,2),"#","-")    ; Omit regex stored operator (! or ~) and convert "#" to "-".
                    
                    If (_op = "!")
                        val2 := !v1
                    Else If (_op = "~") {
                        If !IsInteger(v1)
                            throw Error("Bitwise NOT (~) operator against non-integer value.`r`n     Invalid operation: ~" v1,-1,"Bitwise operation with non-integer.")
                        v1 := Integer(v1)
                        
                        ; dbg("!~: v1: " v1)
                        
                        val2 := ~v1
                    } Else
                        throw Error("Unexpected error in NOT (! / ~) expression.",-1,"First char is not ! or ~.`r`n`r`n     Sub-Expression: " _mat)
                    
                    ; dbg("!~: val2: " val2)
                    
                    e := StrReplace(e,_mat,StrReplace(val2,"-","#"),,,1) ; Substitute resolved value in main expression.
                    e := RegExReplace(e,"\-(\d+)","#$1")
                    e := RegExReplace(e,"\-#","")                ; The only time a double negative "--" won't throw an error, so "##" will cancel itself out.
                }
                
                ; dbg("!~ end:  e: " e)
                
            Default: ; basic left-to-right operations that need to be grouped together
                    Switch op {
                        Case "*/":  op_reg := "\*|//|/"
                        Case "+-":  op_reg := "\+|\-"
                        Case "<>":  op_reg := ">>>|<<|>>"
                        Case "&^|": op_reg := "\&|\^|\|"
                        Case ">=":  op_reg := ">\=|<\=|>|<"
                        Case "==":  op_reg := "!=|==|="
                        Case "&&":  op_reg := "&&" . "|" . "\|\|" ; && then ||
                        Case "?:":
                            If !(q := InStr(e,"?"))
                                Continue
                            c := InStr(e,":")
                            expr := StrReplace(SubStr(e,1,q-1),"#","-")
                            expr := _eval(expr)
                            res_A := SubStr(e,q+1,c-q-1)
                            res_B := SubStr(e,c+1)
                            ; dbg("res_A: " res_A " ///// res_B: " res_B " ///// c-q: " c-q)
                            e := (expr) ? Trim(res_A) : Trim(res_B)
                            Continue
                    }
                    
                    ; dbg("important e 2: " e)
                    
                    While (r := RegExMatch(e,"i)(" n ") +(" op_reg ") +(" n ")",&z)) {
                        o := z[2]
                        v1 := StrReplace(z[1],"#","-"), v2 := StrReplace(z[3],"#","-")
                        
                        ; dbg("Default: " v1 " " z[2] " " v2 " /// op_reg: " op_reg)
                        
                        ; =========================================================
                        ; capture operator-specific errors
                        ; =========================================================
                        If (o = "<<" Or o = ">>") And (!IsInteger(v1) Or !IsInteger(v2) Or v2<0) ; check for invalid expressions
                            throw Error("Invalid expression.`r`n     Expr: " v1 " " o " " v2,-1,"Bit shift with non-integers.")
                        If (o = "/" Or o = "//") And v2=0
                            throw Error("Invalid expression.`r`n     Expr: " v1 " " o " " v2,-1,"Divide by zero.")
                        If (o = "//") And (!IsInteger(v1) Or !IsInteger(v2))
                            throw Error("Invalid expression.`r`n     Expr: " v1 " " o " " v2,-1,"Floor division with non-integer divisor.")
                        If (o = "&" Or o = "^" Or o = "|") And (!IsInteger(v1) Or !IsInteger(v2))
                            throw Error("Invalid expression.`r`n     Expr: " v1 " " o " " v2,-1,"Bitwise operation with non-integers.")
                        
                        (IsFloat(v1)) ? v1 := Float(v1) : (IsInteger(v1)) ? v1 := Integer(v1) : ""
                        (IsFloat(v2)) ? v2 := Float(v2) : (IsInteger(v2)) ? v2 := Integer(v2) : ""
                        
                        ; dbg("v1: " v1 " / v2: " v2 " / o: " o)
                        
                        Switch o {
                            Case "*":   val2 := v1  *  v2
                            Case "//":  val2 := v1 //  v2
                            Case "/":   val2 := v1  /  v2
                            Case "+":   val2 := v1  +  v2
                            Case "-":   val2 := v1  -  v2
                            Case ">>>": val2 := v1 >>> v2
                            Case "<<":  val2 := v1 <<  v2
                            Case ">>":  val2 := v1 >>  v2
                            Case "&":   val2 := v1  &  v2
                            Case "^":   val2 := v1  ^  v2
                            Case "|":   val2 := v1  |  v2
                            Case ">=":  val2 := v1 >=  v2
                            Case "<=":  val2 := v1 <=  v2
                            Case ">":   val2 := v1  >  v2
                            Case "<":   val2 := v1  <  v2
                            Case "!=":  val2 := v1 !=  v2
                            Case "==":  val2 := v1 ==  v2
                            Case "=":   val2 := v1  =  v2
                            Case "&&":  val2 := v1 &&  v2
                            Case "||":  val2 := v1 ||  v2
                        }
                        
                        ; dbg("Answer: " val2)
                        
                        e := StrReplace(e,z[0],StrReplace(val2,"-","#"),,,1)
                        
                        ; dbg("Answer e: " e)
                    }
                    r := 0 ; disable substitution before next iteration in FOR loop, because these subs were already done
        }
        
        If IsNumber(StrReplace(e,"#","-"))
            Break
    }
    
    ; dbg("pre return: " e)
    
    e := StrReplace(e,"#","-")
    If IsNumber(StrReplace(e,"#","-")) {
        final := StrReplace(e,"#","-")
        If IsInteger(final)
            return Integer(final)
        Else If IsFloat(final)
            return Float(final)
        Else
            throw Error("fix this type: " Type(final),-1) ; this isn't supposed to be here, but just in case there's some weird type conflict, please tell me and post example.
    } Else {
        ; dbg("return: " e)
        return e
    }
}



; dbg(_in) {
    ; Loop Parse _in, "`n", "`r"
        ; OutputDebug "AHK: " A_LoopField
; }