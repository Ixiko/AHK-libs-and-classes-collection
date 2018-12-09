; Codegen
; http://www.autohotkey.com/forum/topic26300.html

; codegen structure:
;      0  ArgStruct*  current_arg
;     
;      4  Line*       last_line
;      8  Label*      last_label
;     12  Func*       last_func
;     
;     16  Line*       first_line
;     20  Label*      first_label
;     24  Func*       first_func
;     
;     28  uint        deref_count     Number of valid DerefTypes in deref_buf.
;     32  uint        deref_buf_size
;     36  DerefType*  deref_buf       Array of [deref_buf_size] DerefTypes.
;     
;     40  uint        text_length     Length of arg text written so far.
;     44  uint        text_buf_size
;     48  str         text_buf
;     
;     52  uint        arg_count       Number of valid ArgStructs in arg_buf.
;     56  uint        arg_buf_size
;     60  ArgStruct*  arg_buf         Array of [arg_buf_size] ArgStructs.
;     
;     64  uint        param_count
;     68  uint        param_buf_size
;     72  FuncParam*  param_buf
;     
;     76  int         flags           {next_line_is_function_body=1, needs_resolve=2}
;     80
; 
; codehandle structure:
;      0  Line*       first_line
;      4  Line*       last_line
;      8  uint        flags
;     12  uint        label_count
;     16  Label**     label_list
;     20  uint        func_count
;     24  Func**      func_list
;     28

code_gen() {
    LowLevel_init()
    return DllCall("GlobalAlloc","uint",0x40,"uint",80)
}

code_gen_reset(cg, delete_code=true)
{
    ; Delete all args/params in the buffers, but not the buffers themselves.
    if arg_buf := NumGet(cg+60)
        code_internal_delete_args(arg_buf, NumGet(cg+52))
    if param_buf := NumGet(cg+72)
        code_internal_delete_params(param_buf, NumGet(cg+64))
    NumPut(0,cg+28), NumPut(0,cg+40), NumPut(0,cg+52), NumPut(0,cg+64)
    ; Also clear current_arg, which should be a location in the arg buffer.
    , NumPut(0,cg+0)
    
    if delete_code
    {   ; Since code_finalize() disassociates the code on success, assume
        ; the caller wants to delete any code remaining in the codegen.
        code_internal_delete_lines(NumGet(cg+16))
        code_internal_delete_labels(NumGet(cg+20))
        code_internal_delete_funcs(NumGet(cg+24))
    }
    ; Reset last_line/label/func and first_line/label/func.
    NumPut(0,NumPut(0,NumPut(0,NumPut(0,NumPut(0,NumPut(0,cg+4))))))
    ; Reset flags.
    , NumPut(0,cg+76)
    
    return cg
}

code_gen_delete(cg, delete_code=true)
{
    ; Delete any buffered args/params and (if delete_code) remaining code.
    code_gen_reset(cg, delete_code)

    if buf := NumGet(cg+36) ; deref_buf
        DllCall("GlobalFree","uint",buf)
    if buf := NumGet(cg+48) ; text_buf
        DllCall("GlobalFree","uint",buf)
    if buf := NumGet(cg+60) ; arg_buf
        DllCall("GlobalFree","uint",buf)
    if buf := NumGet(cg+72) ; param_buf
        DllCall("GlobalFree","uint",buf)
    
    DllCall("GlobalFree","uint",cg)
}

;   Buffer      Initial Size    Growth    Maximum Size
;     deref_buf     64            *2          512
;     text_buf    1024            *2        16385
;     arg_buf       20            N/A          20
;     param_buf     16            *2          255
code_expect_derefs(cg, expected, growth_factor=0) {
    return code_ensure_buf_capacity(cg+28, expected, 64, 512, 12, growth_factor)
}
code_expect_text(cg, expected, growth_factor=0) {
    return code_ensure_buf_capacity(cg+40, expected, 1024, 16385, 1, growth_factor)
}
code_expect_args(cg, expected, growth_factor=0) {
    return code_ensure_buf_capacity(cg+52, expected, 20, 20, 16, growth_factor)
}
code_expect_params(cg, expected, growth_factor=0) {
    return code_ensure_buf_capacity(cg+64, expected, 16, 255, 16, growth_factor)
}


code_line(cg, action_type)
{
    ; Finalize last_line, if applicable.
    if (NumGet(cg+0) || NumGet(cg+52)) && !code_line_end(cg)
        return 0
    
    this_line := __lineAlloc()
    NumPut(action_type, this_line+0,0,"uchar")
    
    ; Add line to linked list.
    if last_line := NumGet(cg+4)
        NumPut(this_line, last_line+20), NumPut(last_line, this_line+16)
    else
        NumPut(this_line, cg+16)    ; first_line := this_line
    
    NumPut(this_line, cg+4)
    ; NOTE: All lines must be processed later to set mParentLine & mRelatedLine.
    ;       See code_process_blocks.
    
    ; Set mJumpToLine of last_label/last_func if not already set.
    ; It is caller's responsibility to ensure the line is a valid target.
    if (last_func := NumGet(cg+12)) && ! NumGet(last_func+4)
    {
        if NumGet(cg+76) & 1 ; next_line_is_function_body
            NumPut(this_line, last_func+4), NumPut(NumGet(cg+76) & ~1, cg+76)
        else if action_type = 107 ; ACT_BLOCK_BEGIN
            NumPut(1, this_line+12), NumPut(NumGet(cg+76) | 1, cg+76)
    }
    if (last_label := NumGet(cg+8)) && ! NumGet(last_label+4)
    {
        Loop {
            NumPut(this_line, last_label+4)
            if !(last_label := NumGet(last_label+8)) || NumGet(last_label+4)
                break
        }
    }

    ; If (Goto, Gosub, OnExit, Hotkey, SetTimer or GroupAdd)
    if (action_type >= 95 && action_type <= 99 || action_type = 140)
        NumPut(NumGet(cg+76) | 2, cg+76) ; set needs_resolve flag.
    
    return this_line
}

code_arg(cg, type=0, param="")
{
    static empty
    if ! code_expect_args(cg, 1 + arg_count:=NumGet(cg+52), 2)
        return false, ErrorLevel:="MEM"
    ; Finalize current arg, if any.
    if NumGet(cg+0) && !code_arg_end(cg)
        return false
    ; Update arg_ptr to point to new arg.
    NumPut(arg_ptr := NumGet(cg+60) + arg_count*16, cg+0)
    ; ++arg_count
    , NumPut(arg_count + 1, cg+52)
    ; ZeroMemory(arg_ptr, 16)
    , NumPut(0, NumPut(0, NumPut(0, NumPut(0, arg_ptr+0))))
    ; Set type and is_expression.
    , NumPut(type=0 && param, NumPut(type, arg_ptr+0,0,"char") ,0,"char")
    ; Set Var* if this arg is a non-dynamic input/output var.
    ; Set text="" as an indicator that the arg has a non-dynamic var.
    if (type = 1 || type = 2) && param
        NumPut(param, NumPut(&empty, arg_ptr+4))
    return true
}

code_arg_write(cg, text)
{
    static empty
    arg_ptr := NumGet(cg+0)
    if !arg_ptr
        return false, ErrorLevel:="Invalid usage (no arg)."
    if NumGet(arg_ptr+4) = &empty
        return false, ErrorLevel:="Invalid usage (arg has in/out var)."
    if text =   ; code_arg_deref uses us for error-checking, even if text="".
        return true
    text_length := NumGet(cg+40)
    if ! code_expect_text(cg, text_length + StrLen(text) + 1, 2)
        return false, ErrorLevel:="MEM"
    DllCall("lstrcpy","uint",NumGet(cg+48) + text_length,"str",text)
    NumPut(text_length + StrLen(text), cg+40)
    return true
}

code_arg_deref(cg, text, var_or_func, is_function=false, param_count=255)
{
    ; v1.0.1 / AutoHotkey v1.0.48: Expressions are now tokenized at load-time.
    ; Function derefs in args are no longer useful, so to catch any scripts
    ; that try to create expressions this way, treat function derefs as errors.
    if is_function
        return false, ErrorLevel:="Function derefs are not supported."
    if ! code_expect_derefs(cg, 1 + deref_count:=NumGet(cg+28), 2)
        return false, ErrorLevel:="MEM"
    deref_ptr := NumGet(cg+36) + deref_count*12
    ; Store current text_length so marker can be calculated later.
    NumPut(NumGet(cg+40), deref_ptr+0)
    ; Write deref text to the arg; even if text="", for error-checking.
    if !code_arg_write(cg, text)
        return false ; ErrorLevel already set.
    NumPut(deref_count + 1, cg+28)
    , NumPut(StrLen(text), NumPut(param_count, NumPut(0, NumPut(var_or_func, deref_ptr+4) ,0,"uchar") ,0,"uchar") ,0,"ushort")
    return true
}

code_arg_end(cg)
{
    arg_ptr := NumGet(cg+0)
    if !arg_ptr
        return false, ErrorLevel:="Invalid usage (no arg)."
    
    if deref_count := NumGet(cg+28)
    {
        deref_ptr := DllCall("GlobalAlloc","uint",0,"uint",deref_count*12+12)
        if !deref_ptr
            return false, ErrorLevel:="GlobalAlloc failed."
        DllCall("RtlMoveMemory","uint",deref_ptr,"uint",NumGet(cg+36),"uint",deref_count*12)
        , NumPut(0, deref_ptr + deref_count*12) ; NULL-marker deref terminates the list.
        , NumPut(0, cg+28) ; deref_count := 0
    }
    else
        deref_ptr := 0
    
    if text_length := NumGet(cg+40)
    {
        text_ptr := DllCall("GlobalAlloc","uint",0,"uint",text_length+1)
        if !text_ptr {
            if deref_ptr
                DllCall("GlobalFree","uint",deref_ptr)
            return false, ErrorLevel:="MEM"
        }
        DllCall("lstrcpyn","uint",text_ptr,"uint",NumGet(cg+48),"int",text_length+1)
        , NumPut(0, cg+40) ; text_length := 0
    }
    else
        text_ptr := &empty
    
    NumPut(text_ptr, NumPut(text_length, arg_ptr+0, 2, "ushort"))
    if deref_count
        NumPut(deref_ptr, arg_ptr+8)
    
    Loop %deref_count%
    {
        ; Convert deref markers from string offsets to string pointers.
        NumPut(text_ptr + NumGet(deref_ptr+0), deref_ptr+0)
        
        ; If this deref is a function call,
        if NumGet(deref_ptr+8,0,"char")
        {   ; calculate param_count.
            if NumGet(deref_ptr+9, 0,"uchar") = 255
            {
                rem_expr := SubStr(__str(NumGet(deref_ptr+0) + NumGet(deref_ptr+10,0,"ushort")), 2)
                param_count = 0
                open_parens = 1
                in_quote := false
                Loop, Parse, rem_expr
                {
                    if param_count = 0
                        if !InStr(") `t", A_LoopField)
                            param_count = 1
                    if A_LoopField = "
                        in_quote := !in_quote
                    if in_quote
                        continue
                    if A_LoopField = ,
                        param_count += (open_parens=1) ; add boolean 1 or 0
                    else if A_LoopField = (
                        open_parens += 1
                    else if A_LoopField = )
                        if --open_parens = 0
                            break
                }
                NumPut(param_count, deref_ptr+9, 0,"uchar")
            }
            ; Set the needs_resolve flag if func == NULL.
            if !NumGet(deref+4)
                NumPut(NumGet(cg+76) | 2, cg+76)
        }

        deref_ptr += 12
    }

    NumPut(0, cg+0)
    return true
}

code_line_end(cg)
{
    if ! this_line := NumGet(cg+4)
        return 0, ErrorLevel:="Invalid usage (no line)."
    if NumGet(this_line+1,0,"uchar")
        return 0, ErrorLevel:="Invalid usage (line already has args)."
    ; Finalize current_arg, if applicable.
    if NumGet(cg+0) && !code_arg_end(cg)
        return 0
    if arg_count := NumGet(cg+52)
    {   ; Move args from the buffer to this_line.
        arg_ptr := DllCall("GlobalAlloc","uint",0,"uint",arg_count*16)
        if !arg_ptr
            return 0, ErrorLevel:="MEM"
        DllCall("RtlMoveMemory","uint",arg_ptr,"uint",NumGet(cg+60),"uint",arg_count*16)
        , NumPut(0, cg+52) ; arg_count := 0
    } else
        arg_ptr := 0
    NumPut(arg_count, this_line+1, "uchar"), NumPut(arg_ptr, this_line+4)
    ; Determine line Attribute.
    attr := 0
    if NumGet(this_line+0,0,"UChar") = 104 ; ACT_LOOP
    {   ; Parsing loops must be marked as such at load-time.
        ; Other types of loops are handled by AutoHotkey at run-time.
        ; Future optimization: detect other types of loops at load-time where possible.
        if arg_count = 0
            attr := 2 ; ATTR_LOOP_NORMAL
        else if arg_count >= 2
        {   arg_str := __str(NumGet(arg_ptr+4))
            if arg_str = Read
                attr := 5 ; ATTR_LOOP_READ_FILE
            else if arg_str = Parse
                attr := 6 ; ATTR_LOOP_PARSE
        }
    }
    NumPut(attr, this_line+12)
    return this_line
}

code_func(cg, name)
{
    this_func := DllCall("GlobalAlloc","uint",0x40,"uint",52+StrLen(name)+1)
    if !this_func
        return 0, ErrorLevel:="MEM"
    NumPut(DllCall("lstrcpy","uint",this_func+52,"str",name), this_func+0)
    , NumPut(1, this_func+48, 0, "uchar") ; mDefaultVarType = VAR_ASSUME_LOCAL
    if last_func := NumGet(cg+12)
        NumPut(this_func, last_func+44) ; cg->last_func->mNextFunc
    else
        NumPut(this_func, cg+24) ; cg->first_func
    NumPut(this_func, cg+12) ; cg->last_func
    return this_func
}

code_func_param(cg, name, is_byref=false, default_type=0, default_value="")
{
    static empty
    if ! code_expect_params(cg, 1 + param_count:=NumGet(cg+64), 2)
        return 0, ErrorLevel:="MEM"
    if ! var := code_var(name)
        return 0
    param_ptr := NumGet(cg+72) + param_count*16
    NumPut(is_byref | default_type<<16, NumPut(var, param_ptr+0))
    if default_type = 1
    {
        if default_value !=
        {
            pstr := DllCall("GlobalAlloc","uint",0,"uint",StrLen(default_value)+1)
            NumPut(pstr, param_ptr+8) ; even if NULL.
            if !pstr
                return false, ErrorLevel:="MEM"
            DllCall("lstrcpy","uint",pstr,"str",default_value)
        }
        else
            NumPut(&empty, param_ptr+8)
    }
    else if default_type = 2
        NumPut(default_value, param_ptr+8, 0, "int64")
    else if default_type = 3
        NumPut(default_value, param_ptr+8, 0, "double")
    NumPut(param_count + 1, cg+64)
    return var
}

code_func_end(cg)
{
    if ! last_func := NumGet(cg+12)
        return 0, ErrorLevel:="Invalid usage (no func)."
    if NumGet(last_func+8)
        return 0, ErrorLevel:="Invalid usage (func already has params)."
    if param_count := NumGet(cg+64)
    {
        param_ptr := DllCall("GlobalAlloc","uint",0,"uint",param_count*16)
        if !param_ptr
            return 0, ErrorLevel:="MEM"
        DllCall("RtlMoveMemory","uint",param_ptr,"uint",NumGet(cg+72),"uint",param_count*16)
        Loop % param_count
            if ! NumGet(param_ptr+A_Index*16-10,0,"ushort") ; ! default_type
                min_params := A_Index
        NumPut(min_params, NumPut(param_count, NumPut(param_ptr, last_func+8)))
        , NumPut(0, cg+64) ; param_count
    }
    return last_func
}


code_label(cg, name)
{
    this_label := DllCall("GlobalAlloc","uint",0x40,"uint",16 + StrLen(name) + 1)
    if !this_label
        return 0, ErrorLevel:="MEM"
    NumPut(DllCall("lstrcpy","uint",this_label+16,"str",name), this_label+0)
    if last_label := NumGet(cg+8)
        NumPut(last_label, this_label+8), NumPut(this_label, last_label+12)
    else
        NumPut(this_label, cg+20) ; first_label
    NumPut(this_label, cg+8) ; last_label
    return this_label
}

code_var(name)
{
    static empty
    var_ptr := DllCall("GlobalAlloc","uint",0x40,"uint",28 + StrLen(name) + 1)
    if !var_ptr
        return 0, ErrorLevel:="MEM"
    NumPut(DllCall("lstrcpy","uint",var_ptr+28,"str",name), var_ptr+24)
    , NumPut(&empty, var_ptr+8)
    , NumPut(2, var_ptr+20, 0, "uchar")
    , NumPut(1, var_ptr+23, 0, "uchar")
    return var_ptr
}

code_finalize(cg, flags=0, OnResolveFunc="code_resolve_func", OnResolveLabel="code_resolve_label")
{
    ; Finalize last_line, if applicable.
    if (NumGet(cg+0) || NumGet(cg+52)) && !code_line_end(cg)
        return 0
    if ! NumGet(cg+4)
        return 0, ErrorLevel:="No code!"
    
    ; Check for func/label with no target line.
    if (func := NumGet(cg+12)) && ! NumGet(func+4)
        return 0, ErrorLevel:="Func has no target: " __str(NumGet(func+0))
    if (label := NumGet(cg+8)) && ! NumGet(label+4)
        return 0, ErrorLevel:="Label has no target: " __str(NumGet(label+0))
    
    ; Ensure each func/label has a target line. Might help catch errors.
    ; These loops are also required to determine the last func/label if (flags & 1).
    label := NumGet(cg+20)
    label_count := 0
    Loop {
        if !label
            break
        label_count += 1
        label := NumGet(label+12)
    }
    func := NumGet(cg+24)
    func_count := 0
    Loop {
        if !func
            break
        func_count += 1
        func := NumGet(func+44)
    }
    
    if NumGet(cg+76) & 2 ; needs_resolve: label or function references need to be resolved.
    {
        if !code_resolve_funcs_and_labels(cg, OnResolveFunc, OnResolveLabel)
            return 0
        NumPut(NumGet(cg+76) & ~2, cg+76) ; remove flag: needs_resolve.
    }
    code_process_blocks(NumGet(cg+16))
    if ErrorLevel
        return 0
    
    hcode := DllCall("GlobalAlloc","uint",0,"uint", 28 + func_count*4 + label_count*4)
    if !hcode
        return 0, ErrorLevel:="MEM"
    
    ; For maintainability, don't assign something meaningless if count=0.
    func_list := func_count ? hcode + 28 : 0
    label_list := label_count ? hcode + 28 + func_count*4 : 0
    
    ; Copy the labels and functions into an array, in case
    ; the script later alters or breaks the linked list(s).
    label := NumGet(cg+20)
    Loop {
        if !label
            break
        NumPut(label, label_list + A_Index*4-4)
        label := NumGet(label+12)
    }
    func := NumGet(cg+24)
    Loop {
        if !func
            break
        NumPut(func, func_list + A_Index*4-4)
        func := NumGet(func+44)
    }
    
     NumPut(NumGet(cg+16), hcode+0) ; first_line
    ,NumPut(NumGet(cg+4), hcode+4) ; last_line
    ,NumPut(flags, hcode+8)
    ,NumPut(label_list, NumPut(label_count, hcode+12))
    ,NumPut(func_list, NumPut(func_count, hcode+20))
    
    code_gen_reset(cg, false)
    
    if flags & 1 ; Add labels and functions to the main script.
    {
        if func_count
        {
            func_1 := __getFirstFunc()
            func_2 := NumGet(func_1+44)
            NumPut(func_2, NumGet(func_list+func_count*4-4)+44)
            NumPut(NumGet(func_list+0), func_1+44)
        }
        if label_count
        {
            label_1 := __getFirstLabel()
            label_2 := NumGet(label_1+12)
            NumPut(label_2, NumGet(label_list+label_count*4-4)+12)
            NumPut(label_1, NumGet(label_list+0)+8)
            NumPut(NumGet(label_list+label_count*4-4), label_2+8)
            NumPut(NumGet(label_list+0), label_1+12)
        }
    }
    
    return hcode
}

code_resolve_funcs_and_labels(cg, OnResolveFunc, OnResolveLabel)
{
    line := NumGet(cg+16)
    Loop
    {
        arg_count := NumGet(line+1,0,"uchar")
        
        ; Resolve as-yet-unresolved function calls.
        arg := NumGet(line+4)
        Loop %arg_count%
        {
            if NumGet(arg+0,0,"uchar") = 0 && NumGet(arg+1,0,"uchar")
            {   ; This arg is an expression.
                ; AutoHotkey v1.0.48: Expressions are now tokenized at load-time.
                if !NumGet(arg+12)
                    return false, ErrorLevel:="Expression has not been pre-tokenized."
                /*
                deref := NumGet(arg+8)
                Loop
                {
                    if !NumGet(deref+0)
                        break
                    if NumGet(deref+8,0,"uchar") && !NumGet(deref+4)
                    {   ; This deref is a function call with no func.
                        func_name := __str(NumGet(deref+0), NumGet(deref+10,0,"ushort"))
                        
                        func := %OnResolveFunc%(cg, func_name)
                        if func
                            NumPut(func, deref+4)
                        else
                            return false, ErrorLevel:="Unresolved function: " func_name
                    }
                    deref += 12
                }
                */
            }
            arg += 16
        }
        ; Resolve static labels for Goto, Gosub, OnExit, Hotkey, SetTimer and GroupAdd.
        line_action := NumGet(line+0,0,"uchar")
        if (line_action >= 95 && line_action <= 99 || line_action = 140)
            && arg_count >= (line_action=98 ? 2 : line_action=140 ? 4 : 1)
        {
            label_name := ""
            arg := NumGet(line+4)
            deref := NumGet(arg+8)
            
            if line_action = 140 ; GroupAdd
            {
                ; GroupAdd's fourth parameter may be a label.
                deref := NumGet(arg+56)
                if NumGet(arg+48,0,"uchar") = 0 && !(deref && NumGet(deref+0))
                    label_name := __str(NumGet(arg+52))
            }
            else if NumGet(arg+0,0,"uchar") = 0 && !(deref && NumGet(deref+0))
            {   ; arg 1 is ARG_TYPE_NORMAL and has no derefs
            
                if line_action = 98 ; Hotkey
                {
                    deref := NumGet(arg+24)
                    if NumGet(arg+12,0,"uchar") = 0 && !(deref && NumGet(deref+0))
                        ; second arg has no derefs
                        && SubStr(__str(NumGet(arg+4)),1,5) != "IfWin"
                        ; and first arg is not IfWin-something
                    {
                        label_name := __str(NumGet(arg+20))
                    }
                }
                else
                    label_name := __str(NumGet(arg+4))
            }
            
            if label_name
            {
                ; Call %OnResolveLabel%().
                label := %OnResolveLabel%(cg, label_name)
                
                ; Treat this as non-critical, since
                ;   a) the parameter might be a non-label (On, Off, etc.) and
                ;   b) AutoHotkey will attempt to resolve the label at run-time.
                if label is not integer
                    label := 0

                NumPut(label, line + (line_action=95||line_action=96||line_action=140 ? 24 : 12))
            }
        }
        
        if !(line := NumGet(line+20))
            break
    }
    return true
}

code_resolve_func(cg, func_name)
{
    if func := __findFunc(func_name, NumGet(cg+24))
        return func
    if func := __findFunc(func_name)
        return func
}
code_resolve_label(cg, label_name)
{
    if label := __findLabel(label_name, NumGet(cg+20))
        return label
    if label := __findLabel(label_name)
        return label
}

; Does necessary processing of if, else, loop, { and }.
code_process_blocks(start_line, parent_line=0, one_line_only=false)
{
    line := start_line
    Loop
    {
        if !line
            break
        
        NumPut(parent_line, line+28) ; mParentLine
        
        line_action := NumGet(line+0,0,"uchar")
        
        ; IF, LOOP or REPEAT;  update: or WHILE
        if (line_action >= 10 && line_action <= 33) || line_action = 104 || line_action = 8 || line_action = 105
        {
            line_temp := NumGet(line+20) ; mNextLine
            
            if !line_temp
                return 0, ErrorLevel:="IF or LOOP with no action."
            
            if (temp_action:=NumGet(line_temp+0,0,"uchar")) = 9 || temp_action = 108 ; ELSE or }
                return 0, ErrorLevel:="Inappropriate line beneath IF or LOOP."
            
            line_temp := code_process_blocks(line_temp, line, true)

            NumPut(line_temp, line+24) ; mRelatedLine
            ; If end of code was reached, don't override the ErrorLevel set
            ; by the recursed instance. In all other cases, ErrorLevel should
            ; be set to a meaningful value (maybe blank) before/at return.
            if !line_temp
                return 0
            
            if NumGet(line_temp+0,0,"uchar") = 9 ; ELSE
            {
                if (line_action = 104 || line_action = 8) ; LOOP or REPEAT
                {
                    if one_line_only
                    {   ; Not our else, so let the caller handle it.
                        ErrorLevel =
                        return line_temp
                    }
                    return 0, ErrorLevel:="ELSE with no matching IF."
                }
                
                if ! line := NumGet(line_temp+20) ; mNextLine
                    return 0, ErrorLevel:="ELSE with no action."
                
                if (line_action:=NumGet(line+0,0,"uchar")) = 9 || line_action = 108 ; ELSE or }
                    return 0, ErrorLevel:="Inappropriate line beneath ELSE."
                
                line := code_process_blocks(line, line_temp, true)
                
                NumPut(line, line_temp+24) ; mRelatedLine
                ; End of code, don't set ErrorLevel. See comment above.
                if !line
                    return 0
            }
            else
                line := line_temp
            
            if one_line_only
            {   ; This if or if/else was the action of an if/else/loop.
                ; Return the line after; i.e. the "related line".
                ErrorLevel =
                return line
            }
            continue
        }
        
        if line_action = 107 ; {
        {
            ; Find the block-end for this block-begin.
            if ! line_temp := code_process_blocks(NumGet(line+20), line, false)
                return 0, ErrorLevel:="Unterminated block."

            NumPut(NumGet(line_temp+20), line+24) ; mRelatedLine = line_temp->mNextLine
            
            line := line_temp
        }
        else if line_action = 108 ; }
        {
            if ! parent_line
                return 0, ErrorLevel:="Unexpected end of block."
            ; Successfully found the end of a block.
            ErrorLevel =
            return line 
        }
        else if line_action = 9 ; ELSE
        {
            return 0, ErrorLevel:="ELSE with no matching IF."
        }
        
        line := NumGet(line+20) ; mNextLine
        if one_line_only
        {   ; Successfully processed the action of an if/else/loop.
            ; Return the line after; i.e. the "related line".
            ErrorLevel =
            return line
        }
    }
    ; Found the end of the code without encountering errors.
    ErrorLevel =
    return 0
}



code_add_func(func_ptr, first_func=0)
{
    if !first_func && !(first_func := __getFirstFunc())
        return false
    second_func := NumGet(first_func+44)
    NumPut(second_func, func_ptr+44)
    NumPut(func_ptr, first_func+44)
    return true
}

code_add_label(label_ptr, first_label=0)
{
    if !first_label && !(first_label := __getFirstLabel())
        return false
    second_label := NumGet(first_label+12)
    NumPut(second_label, label_ptr+12)
    NumPut(first_label, label_ptr+8)
    if second_label
        NumPut(label_ptr, second_label+8)
    NumPut(label_ptr, first_label+12)
    return true
}

code_insert_after(hcode, prefix_line)
{
    return prefix_line
        && code_insert_between(hcode, prefix_line, NumGet(prefix_line+20))
}
code_insert_before(hcode, postfix_line)
{
    return postfix_line
        && code_insert_between(hcode, NumGet(postfix_line+16), postfix_line)
}

code_insert_at(hcode, label)
{
    target := NumGet(label+4)
    NumPut(NumGet(hcode+0), label+4)
    return !target || code_insert_between(hcode, NumGet(target+16), target)
}

; Inserts code between two adjacent lines. Does not automatically insert braces
; around an if/else/loop's body, since there would be ambiguities like:
;
;   if value
;       action  <-- insert after this line. should it be part of the if?
;
;   if value1
;      if value2
;         action
;      else
;         action
;       <-- insert here. does it belong to "if value1" or "if value2..else"?
;   else
;      action
code_insert_between(hcode, prefix, postfix)
{
    first := NumGet(hcode+0)
    last := NumGet(hcode+4)
    
    if (prefix && postfix)
    {
        prefix_action := NumGet(prefix+0,0,"uchar")
        postfix_action := NumGet(postfix+0,0,"uchar")
        ; not allowed as prefix: repeat, else, if or loop
        if (prefix_action >= 8 && prefix_action <= 33) || prefix_action = 104
            return false
        ; not allowed as postfix: else
        if (postfix_action = 9)
            return false
    }

     NumPut(prefix, first+16)    ; first->mPrevLine = prefix
    ,NumPut(postfix, last+20)    ; last->mNextLine = postfix
    if prefix
    {
        NumPut(first, prefix+20) ; prefix->mNextLine = first
        prefix_parent := NumGet(prefix+28)
    }
    if postfix
    {
        NumPut(last, postfix+16) ; postfix->mPrevLine = last
        postfix_parent := NumGet(postfix+28)
    }
    
    if prefix
    {
        if NumGet(prefix+0,0,"uchar") = 107 ; {
        {
            start_line := first
            ln := prefix
        }
        else
        {
            ; Find common ancestor of prefix/postfix.
            if ln := prefix_parent {
                Loop
                    if (ln = postfix_parent) || !(ln := NumGet(ln+28))
                        break
                if !ln ; prefix_parent is not derived from postfix_parent.
                    ln := prefix_parent
                ; else:  ln/postfix_parent is the common ancestor.
            }
            if ln   ; start at this line's body (i.e. the next line)
                start_line := NumGet(ln+20)
            else {  ; no parent, find the first line.
                ln := prefix
                Loop
                    if ln := NumGet(ln+16)
                        start_line := ln
                    else
                        break
                ; ln is now 0, since we'd otherwise still be in the loop.
            }
        }
    }
    else
        start_line := first, ln := 0
    
    code_process_blocks(start_line, ln, ln && NumGet(ln+0,0,"uchar") != 107)
    
    return true
}

code_remove(hcode)
{
    first := NumGet(hcode+0)
    last := NumGet(hcode+4)
    prefix := NumGet(first+16)
    postfix := NumGet(last+20)
    if prefix
        NumPut(postfix, prefix+20), NumPut(0, first+16)
    if postfix
        NumPut(prefix, postfix+16), NumPut(0, last+20)
    
    if (parent := NumGet(first+28)) && (start_line := NumGet(parent+20))
        code_process_blocks(start_line, parent, NumGet(parent+0,0,"uchar") != 107)
    
    return postfix
}

code_remove_func(func_ptr, first_func=0)
{
    if !first_func && !(first_func := __getFirstFunc())
        return false
    Loop {
        if !next_func := NumGet(first_func+44)
            return false
        if (next_func = func_ptr) {
            NumPut(NumGet(func_ptr+44), first_func+44)
            NumPut(0, func_ptr+44)
            return true
        }
        first_func := next_func
    }
}

code_remove_label(label_ptr)
{
    prev_label := NumGet(label_ptr+8)
    next_label := NumGet(label_ptr+12)
    if prev_label
        NumPut(next_label, prev_label+12)
    if next_label
        NumPut(prev_label, next_label+8)
    NumPut(0, NumPut(0, label_ptr+8))
    return true
}

code_wrap_body_of(line)
{
    body_first := NumGet(line+20)               ; body_first = line->mNextLine

    if !body_first || NumGet(body_first+0,0,"uchar") = 107 ; {
        return

    if related := NumGet(line+24)               ; related = line->mRelatedLine
        body_last := NumGet(related+16)         ; body_last = related->mPrevLine
    else
        body_last := body_first, related := NumGet(body_last+20)
    
    block_begin := __lineAlloc()
    block_end := __lineAlloc()
    
     NumPut(107, block_begin+0, 0, "uchar")     ; block_begin->mActionType = ACT_BLOCK_BEGIN
    ,NumPut(NumGet(line+8), block_begin+8)      ; block_begin->mLineNumber = line->mLineNumber
    ,NumPut(line, block_begin+28)               ; block_begin->mParentLine = line
    ,NumPut(related, block_begin+24)            ; block_begin->mRelatedLine = related
    
    ,NumPut(108, block_end+0, 0, "uchar")       ; block_end->mActionType = ACT_BLOCK_END
    ,NumPut(NumGet(related+8), block_end+8)     ; block_end->mLineNumber = related->mLineNumber
    ,NumPut(block_begin, block_end+28)          ; block_end->mParentLine = block_begin
    
    ,NumPut(block_begin, line+20)               ; if/else/loop  --> {
    ,NumPut(body_first, block_begin+20)         ;               --> body
    ,NumPut(block_end, body_last+20)            ;               --> }
    ,NumPut(related, block_end+20)              ;               --> related
    
    ,NumPut(block_end, related+16)              ; related       <--
    ,NumPut(body_last, block_end+16)            ; {             <--
    ,NumPut(block_begin, body_first+16)         ; body          <--
    ,NumPut(line, block_begin+16)               ; }             <-- if/else/loop
    
    code_process_blocks(body_first, block_begin, false)
}



code_run(hcode)
{
    static cb, cb_func
    if !hcode
        return
    ; Create a callback and script function to run code in a new thread.
    if !cb
        cb := RegisterCallback(A_ThisFunc, "Cdecl", 1, 0)
        , VarSetCapacity(cb_func, 52, 0), NumPut(&cb_func, cb+28)
        , NumPut(&cb, cb_func, 0), NumPut(2, cb_func, 48, "uchar")
        , NumPut(0, cb+22, 0, "uchar")
    NumPut(NumGet(hcode+0), cb_func, 4), DllCall(cb)
}



code_delete(hcode)
{
    ret := code_remove(hcode)
    remove := NumGet(hcode+8) & 1 ; True if functions/labels were added to main script.

    label_list := NumGet(hcode+16)
    Loop % NumGet(hcode+12)
    {   ; Remove and delete each label.
        label := NumGet(label_list+A_Index*4-4)
        if remove
            code_remove_label(label)
        code_delete_label(label)
    }
    func_list := NumGet(hcode+24)
    Loop % NumGet(hcode+20)
    {   ; Remove and delete each function.
        func := NumGet(func_list+A_Index*4-4)
        if remove
            code_remove_func(func)
        code_delete_func(func)
    }
    code_internal_delete_lines(NumGet(hcode+0))
    DllCall("GlobalFree","uint",hcode)
    return ret
}

code_delete_handle(hcode)
{
    DllCall("GlobalFree","uint",hcode)
}

code_delete_line(line_ptr)
{
    arg_count := NumGet(line_ptr+1,0,"uchar")
    ; Set mArgc=0 before freeing derefs or text, in case the line is visible in ListLines.
    NumPut(0,line_ptr+1,0,"uchar")
    if arg_ptr := NumGet(line_ptr+4) {
        code_internal_delete_args(arg_ptr, arg_count)
        DllCall("GlobalFree","uint",arg_ptr)
    }
    __lineFree(line_ptr)
}

code_delete_func(func_ptr)
{
    if param_ptr := NumGet(func_ptr+8) {
        code_internal_delete_params(param_ptr, NumGet(func_ptr+12))
        DllCall("GlobalFree","uint",NumGet(func_ptr+8))
    }
    DllCall("GlobalFree","uint",func_ptr)
}

code_delete_label(label_ptr)
{
    code_remove_label(label_ptr)
    DllCall("GlobalFree","uint",label_ptr)
}

code_delete_var(var_ptr)
{
    if NumGet(var_ptr+16) ; mCapacity
        __alias(ref, var_ptr+0), VarSetCapacity(ref, 0), __alias(ref, 0)
    DllCall("GlobalFree","uint",var_ptr)
}


;
; INTERNAL FUNCTION(S)
;

code_internal_delete_lines(line)
{
    Loop {
        if !line
            break
        next_line := NumGet(line+20)
        code_delete_line(line)
        line := next_line
    }
}

code_internal_delete_labels(label)
{
    Loop {
        if !label
            break
        next_label := NumGet(label+12)
        code_delete_label(label)
        label := next_label
    }
}

code_internal_delete_funcs(func)
{
    Loop {
        if !func
            break
        next_func := NumGet(func+44)
        code_delete_func(func)
        func := next_func
    }
}

code_internal_delete_args(arg_ptr, arg_count)
{
    static empty
    Loop %arg_count%
    {
        if (deref_ptr := NumGet(arg_ptr+8))
            DllCall("GlobalFree","uint",deref_ptr)
        if (text_ptr := NumGet(arg_ptr+4)) && text_ptr != &empty
            DllCall("GlobalFree","uint",text_ptr)
        arg_ptr += 16
    }
}

code_internal_delete_params(param_ptr, param_count)
{
    static empty
    Loop %param_count%
    {
        code_delete_var(NumGet(param_ptr+0))
        ; Delete param default string, if present.
        if NumGet(param_ptr+6,0,"ushort") = 1 && (pstr := NumGet(param_ptr+8)) && pstr != &empty
            DllCall("GlobalFree","uint",pstr)
        param_ptr += 16
    }
}

code_ensure_buf_capacity(buf_info_ptr, min_buf_size, init_buf_size, max_buf_size, item_size, growth_factor=0)
{
    old_buf_size := NumGet(buf_info_ptr+4)
    old_buf      := NumGet(buf_info_ptr+8)
    ; If the buffer is already large enough, no need to do anything.
    if old_buf && old_buf_size >= min_buf_size
        return true

    ; Allow caller to specify "exponential" growth to reduce the required
    ; number of reallocations (e.g. as items are added one by one.)
    if growth_factor
    {
        grown_buf_size := old_buf_size ? old_buf_size * growth_factor : init_buf_size
        ; max_buf_size applies only to grown buffer size.
        if (grown_buf_size > max_buf_size)
            grown_buf_size := max_buf_size
        if (grown_buf_size > min_buf_size)
            min_buf_size := grown_buf_size
    }
    
    if old_buf
        new_buf := DllCall("GlobalReAlloc","uint",old_buf,"uint",min_buf_size*item_size,"uint",0x2)
    else
        new_buf := DllCall("GlobalAlloc","uint",0x0,"uint",min_buf_size*item_size)
    
    if !new_buf
        return false

    NumPut(new_buf, NumPut(min_buf_size, buf_info_ptr+4))
    return true
}
