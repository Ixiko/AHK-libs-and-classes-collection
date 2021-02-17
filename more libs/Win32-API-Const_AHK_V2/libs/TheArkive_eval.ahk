; ======================================================================================
; === Examples =========================================================================
; ======================================================================================
; msgbox eval("(1048576 | 1 | 1048576 | 16)") "`r`n" ; This illustrates proper parsing.  Matching "1048576 | 1" will not be confused with matching "1048576 | 16".
           ; . (1048576 | 1 | 1048576 | 16)

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

; msgbox eval("x86",true) ; first char MUST be a digit / ~ / ! / - or opening parenthesis "("


; ======================================================================================
; ======================================================================================





eval(e,test:=false) { ; extend support for parenthesis
    Static q := Chr(34)
    If (test And e = "")
        return false
    Else If (test)
        return !RegExMatch(Trim(e),"i)(^[^\d!~\-\x28]|! |~ |[g-wyz]+|['\" q "\$@#%\{\}\[\]\\,:;\?``=_])") ; only return true/false testing "e" as expression
    
    If RegExMatch(e,"i)(! |~ |[g-wyz]+|['\" q "\$@#%\{\}\[\]\\,:;\?``=_])",m) ; check for invalid characters, non-numbers, invalid punctuation, etc.
        throw Exception("Syntax error.`r`n     Reason: " Chr(34) m.Value(1) Chr(34) "`r`n`r`nExpression: " e,,"Not a math expression.")
    
    StrReplace(e,"(","(",,LP), StrReplace(e,")",")",,RP)
    If (LP != RP)
        throw Exception("Invalid grouping with parenthesis.  You must ensure the same number of ( and ) exist in the expression.`r`n`r`nExpression:`r`n    " e)
    
    While RegExMatch(e, "i)(\x28[^\x28\x29]+\x29)", m) {                ; match phrase surrounded by parenthesis, inner-most first
        ans := _eval(match := m.value(0))                               ; match and calculate result
        ans := (SubStr(ans,1,1) = "-") ? " " ans : ans                  ; sub resolved value, add space for legit negative sign " -#"
        e := RegExReplace(StrReplace(e,match,ans,,,1),"(!|~) +","$1")   ; perform substitution, remove resulting spaces between !/~ and resolved value
    }
    
    e := _eval(e)
    return e
}

_eval(e) { ; support function for pure math expression without parenthesis
    If IsNumber(e)
        return e
    
    Static q := Chr(34)
    If RegExMatch(e,"i)(^[^\d!~\-\x28]|! |~ |[g-wyz]+|['\" q "\$@#%\{\}\[\]\\,:;\?``=_])",m) ; check for invalid characters, non-numbers, invalid punctuation, etc.
        throw Exception("Syntax error.`r`n     Reason: " Chr(34) m.Value(1) Chr(34),,"Not a math expression.")
    
    Static _n   := "(?:\d+\.\d+(?:e\+\d+|e\-\d+|e\d+)?|0x[\dA-F]+|\d+)"  ; Regex to identify float/scientific notation, then hex, then base-10 numbers.  Only positive.
    Static _num := "([!~\-]*)(" _n ")"                                   ; Expand number definition to include - / ~ / !
    Static _ops := "(?:\*\*|\*|//|/|\+|\-|<<|>>|\&|\^|\|)"               ; Define list of operators, in order of prescedence.
    
    new_e := "", p := 1, prev_m := ""
    typ := "number", expr := _num           ; Start looking for a number first.
    While RegExMatch(e,"i)" expr,_m,p) {    ; Separate numbers and operators (except !/~ operators) with spaces.
        mat := _m.Value(0)                  ; Capture match pattern.  Pattern starts with "number" / alternates with "oper".
        If (typ="number") {                 ; Alternate the RegEx search between numbers and operators to improve grouping/spacing of the expression.
            If InStr(_m.Value(1), "--")     ; Check for improper "--" in prefix.
                throw Exception("Improper usage of double negative, ie. " q "--" q ".",,"Sub-Expression: " mat)
            If InStr(_m.Value(1),"-")
                mat := StrReplace(_m.Value(1), "-", "#") _m.Value(2) ; Replace "-" that ONLY indicates negative (not subtraction) with "#".
            typ   := "oper"
            expr  := _ops
        } Else {
            typ  := "number"
            expr := _num
        }
        
        new_e .= mat " "
        p := _m.Pos(0) + _m.Len(0)
    }
    
    e := Trim(RegExReplace(new_e," {2,}"," "))                  ; Replace e with spaced-out/grouped expression, and replace multiple spaces with single space.
    old_e := e
    
    Static order := "** !~ */ +- <> &^|"                        ; Order of operations with appropriate grouping.
    Static opers := StrSplit(order," ")
    Static n := "#?" _n                                         ; Basic number defiintion with # in place - for negative numbers.
    
    For i, op in opers {                                        ; Loop through operators in order of prescedence.
    
        ; msgbox "old e: " old_e "`r`n`r`ne: " e "`r`n`r`nop: " op
        
        Switch op {
            Case "**":
                val2 := "", i_count := 0 ; just in case...
                sub_e := "", new_sub_e := ""                    ; Initialize temp vars for the building of sub-expressions.
                p := 1                                          ; Position tracking.
                fail_count := 0                                 ; These expressions can be broken up in different sections in the main expression, so track search fails.
                Static rg_ex1 := "([#!~]*" _n ")( *\*\* *)"     ; RegEx for number and exponent (**).  For 1st iteration in next WHILE loop.
                Static rg_ex2 := "([#!~]*" _n ")( *\*\* *)?"    ; RegEx for number and maybe exponent (**) for 2nd+ iteration in next WHILE loop.
                rg_ex := rg_ex1
                
                While (r := RegExMatch(e,"i)" rg_ex,z,p)) {     ; Extract expr before resolving, because this needs to be right-to-left.
                    (z.Value(2) = "") ? fail_count++ : ""       ; Increment fail count when "**" not found.  fail_count = 1 means the end of a sub-expr, but there may be more.
                    p := z.Pos(0) + z.Len(0)                    ; Adjust search position.
                    sub_e .= z.Value(0)                         ; Append valid match to sub_e.
                    
                    ; msgbox "sub_e: " sub_e "`r`npos: " p "`r`ne: " e
                    
                    If (fail_count = 1 And InStr(sub_e,"**")) { ; ****** End of exponenent expression, so evalute and replace. ******
                        new_sub_e := sub_e
                        While RegExMatch(new_sub_e,"i)([#!~]*)?(" _n ") *(\*\*) *([#!~]*" _n ")$",y) { ; Get last 2 operands and operator with any unary - ! or ~.
                            mat := y.Value(0)                   ; Capture full match.
                            o_op := y.Value(1)                  ; Outside operators must be solved last, ie. -2 ** 3 is -(2 ** 3).
                            v1 := y.Value(2)                    ; First operand.
                            v2 := StrReplace(y.Value(4),"#","-") ; Switch "#" to "-"
                            v2 := _eval(v2)                     ; Evaluate the exponent (2nd operand), resolve all ! and ~ first.  This behavior is undocumented in AHK v2.
                            
                            val2 := v1 ** v2                    ; Resolve sub-sub-expression.
                            
                            ; msgbox "new_sub_e: " new_sub_e "`r`n`r`nval2: " val2
                            
                            new_sub_e := RegExReplace(new_sub_e,"\Q" mat "\E$",o_op val2) ; Ensure this substitution only happens at the end of the sub-expression.
                        }
                        
                        ; msgbox "v1: " v1 "`r`nv2: " v2 "`r`nval2: " val2 "`r`n`r`ne: " e "`r`n`r`nsub_e: " sub_e "`r`n`r`nnew_sub_e: " new_sub_e
                        
                        RegExMatch(val2,"([\-!~]*)?(" _n ")",y) ; Check for "-" to convert to "#".
                        If (IsObject(y) And InStr(y.Value(1),"-"))
                            val2 := StrReplace(y.Value(1),"-","#") y.Value(2)
                        e := StrReplace(e,sub_e,new_sub_e,,,1) ; Replace only the first instance of the match.  Maintain "#" sub for "-".
                        
                        sub_e := "", new_sub_e := ""            ; Reset temp vars / sub-expressions.  
                        p := 1, fail_count := 0                 ; Reset postion tracking and fail_count.  Continue looping for another exponent sub-expression.
                    } Else If (fail_count > 1)                  ; No more exponent expressions to evaluate, so Break.
                        Break
                    (A_Index = 1) ? rg_ex := rg_ex2 : ""        ; Switch to new search right before 2nd iteration.
                }
            Case "!~":
                While (r := RegExMatch(e,"i)(!|\~)" n,z)) {     ; Find "inner most" expression and solve first.
                    _op  := z.Value(1)
                    _mat := z.Value(0)
                    v1 := StrReplace(SubStr(_mat,2),"#","-")     ; Omit regex stored operator (! or ~) and convert "#" to "-".
                    
                    If (_op = "!")
                        val2 := !v1
                    Else If (_op = "~") {
                        If !IsInteger(v1)
                            throw Exception("Bitwise NOT (~) operator against non-integer value.`r`n     Invalid operation: ~" v1,,"Bitwise operation with non-integer.")
                        val2 := ~v1
                    } Else
                        throw Exception("Unexpected error in NOT (! / ~) expression.",,"First char is not ! or ~.`r`n`r`n     Sub-Expression: " _mat)
                    
                    e := StrReplace(e,_mat,StrReplace(val2,"-","#"),,,1) ; Substitute resolved value in main expression.
                    e := RegExReplace(e,"##","")                ; The only time a double negative "--" won't throw an error, so "##" will cancel itself out.
                }
            Default: ; basic left-to-right operations that need to be grouped together
                    Switch op {
                        Case "*/":  op_reg := "\*|//|/"
                        Case "+-":  op_reg := "\+|\-"
                        Case "<>":  op_reg := "<<|>>"
                        Case "&^|": op_reg := "\&|\^|\|"
                    }
                    
                    While (r := RegExMatch(e,"i)(" n ") +(" op_reg ") +(" n ")",z)) {
                        o := z.value(2)
                        v1 := StrReplace(z.value(1),"#","-"), v2 := StrReplace(z.value(3),"#","-")
                        
                        If (o = "<<" Or o = ">>") And (!IsInteger(v1) Or !IsInteger(v2) Or v2<0) ; check for invalid expressions
                            throw Exception("Invalid expression.`r`n     Expr: " v1 " " o " " v2,,"Bit shift with non-integers.")
                        If (o = "/" Or o = "//") And v2=0
                            throw Exception("Invalid expression.`r`n     Expr: " v1 " " o " " v2,,"Divide by zero.")
                        If (o = "//") And (!IsInteger(v1) Or !IsInteger(v2))
                            throw Exception("Invalid expression.`r`n     Expr: " v1 " " o " " v2,,"Floor division with non-integer divisor.")
                        If (o = "&" Or o = "^" Or o = "|") And (!IsInteger(v1) Or !IsInteger(v2))
                            throw Exception("Invalid expression.`r`n     Expr: " v1 " " o " " v2,,"Bitwise operation with non-integers.")
                        
                        (IsFloat(v1)) ? v1 := Float(v1) : (IsInteger(v1)) ? v1 := Integer(v1) : ""
                        (IsFloat(v2)) ? v2 := Float(v2) : (IsInteger(v2)) ? v2 := Integer(v2) : ""
                        
                        Switch o {
                            Case "*":  val2 := v1 *  v2
                            Case "//": val2 := v1 // v2
                            Case "/":  val2 := v1 /  v2
                            Case "+":  val2 := v1 +  v2
                            Case "-":  val2 := v1 -  v2
                            Case "<<": val2 := v1 << v2
                            Case ">>": val2 := v1 >> v2
                            Case "&":  val2 := v1 &  v2
                            Case "^":  val2 := v1 ^  v2
                            Case "|":  val2 := v1 |  v2
                        }
                        
                        e := StrReplace(e,z.value(0),StrReplace(val2,"-","#"),,,1)
                    }
                    r := 0 ; disable substitution before next iteration in FOR loop, because these subs were already done
        }
        
        If IsNumber(StrReplace(e,"#","-"))
            Break
    }
    
    If IsNumber(StrReplace(e,"#","-")) {
        final := StrReplace(e,"#","-")
        If IsInteger(final)
            return Integer(final)
        Else If IsFloat(final)
            return final
        Else
            throw Exception("fix this type: " Type(final)) ; this isn't supposed to be here, but just in case there's some weird type conflict, please tell me and post example.
    } Else
        return e
}