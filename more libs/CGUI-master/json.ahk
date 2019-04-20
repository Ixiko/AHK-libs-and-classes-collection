#Escapechar \ 
#CommentFlag // 


// Static initialization for stdlib, by fincs at autohotkey.com forums      // 
__json_init() 
{ 
   global 
   static _ := __json_init() 
   $$ := Object() 
   JSON_init() 
} 


// Simple access to global variable $$                                      // 
$(path, val = "") { 

    global $$ 
    tempobj := $$ 

    last := (instr(path, ".") 
        ? substr(path, 1+instr(path, ".", false, -1)) 
        : path) 

    Loop, Parse, path, \. 
    { 
        if (val != "") { 
            if (last = A_loopfield){ 
                tempObj[A_loopfield] := val 
                continue 
            } else if (!tempObj[A_Loopfield]) 
                tempObj[A_loopfield] := Object() 
        } else if (!tempObj) 
            break 
        tempObj := tempObj[A_loopfield] 
    } 

    if (! tempObj) 
        JSON_error("Cannot find or set entry " . path ) 
    else 
        return (val = "" ?  tempObj : 0 ) 
} 

//  Save JSON string to file                                              // 
JSON_save(obj, filename, spacing=35, block="    ", level=1) { 

    file         := FileOpen(filename, "w") 
    jsonString   := JSON_to(obj, spacing, block, level) "\n" 
    bytesWritten := file.write(jsonString) 
    file.close() 

    if (bytesWritten <= 0) 
        JSON_error("Cannot write file " . filename) 
    else 
        return bytesWritten 
} 

//  Load JSON string from file                                            // 
JSON_load(filename) { 
    file := FileOpen(filename, "r") 
    jsonString := file.read() 
    file.close() 
    if (jsonString == "") 
        JSON_error("No file found, or blank file.") 
    return JSON_from(jsonString) 
} 

//  Error handling                                                        // 
JSON_error(s){ 
    Msgbox, % "[" . A_now . "] " . s 
    Exit 
} 

//  Escape / unescape json keys and values                                // 
JSON_escape(s){ 
    StringReplace, s, s, \\, \\\\, All 
    StringReplace, s, s, ', \\',   All 
    StringReplace, s, s, ", \\",   All 
    return s 
} 
JSON_unescape(s){ 
    StringReplace, s, s, \\\\, \\, All 
    StringReplace, s, s, \\', ',   All 
    StringReplace, s, s, \\", ",   All 
    return s 
} 

// Turns an object to a JSON string                                      // 
JSON_to(obj, spacing = 50, block = "    ", level = "1" ) { 

    s := "" 
    for k, v in obj 
    { 
        // New line                        // 
        if (s != "") 
            s .= "," 
        s .= "\n" 

        // Indent key                      // 
        Loop, %level% 
            s .= block 

        // Escape key and value            // 
        k := JSON_escape(k) 
        v := JSON_escape(v) 

        // Write key                       // 
        s .= """" k """: " 

        // If object, do recursion         // 
        if (isobject(v)) { 
            s .= JSON_to(v, spacing, block, level + 1 ) 
        } else { 
  
            // LeftAlign the second column      // 
            totalKeyLength := level * strlen(block) + strlen(k) + 2 
            if (spacing >= totalKeyLength ) { 
                valueIndent := spacing - totalKeyLength 
                loop, %valueIndent% 
                    s .= " " 
            } 
            // Quote non-number values          // 
            if v is not number 
                v := """" v """" 

            // New line                         // 
            s .= v 
        } 
    } 

    // Return                          // 
    if ( (s == "") && !isobject(obj) ) { 
        s := Object() 
    } else if ( (s == "") && isobject(obj) ) { 
        s := "{}" 
    } else { 
        s := "{" s "\n" 
        level -= 1 
        Loop, %level% 
            s .= block 
        s .= "}" 
    } 
    return s 

} 

//  Initialize the shift-reduce tables                                       // 
JSON_init(){ 

    #EscapeChar ` 
    global JSON_regexps, JSON_rules 

    //  symbol : regexp          // 
    JSON_regexps := Object( "" 
        . " " , "(\s+)" 
        , "{" , "({)" 
        , "[" , "(\[)" 
        , "]" , "(\])" 
        , "}" , "(})" 
        , "Q" , "'([^'\\]*(\\.[^'\\]*)*)'" 
        , "S" , """([^""\\]*(\\.[^""\\]*)*)""" 
        , "N" , "([+\-]?\d+([.,]\d+)?)" 
        , "D" , "(true|false|null)" 
        , ":" , "(:)" 
        , "," , "(,)" 
    . "" ) 

    //  1) Match "key" in the symbol stack                                   // 
    //  2) Replace with "sub" in the symbol stack                            // 
    //  3) Remove len("key") from the result stack                           // 
    //  4) Append the result of function "func" on the result stack          // 
    JSON_rules    := Object() 
    JSON_rules[0] := Object( "key", "(\s+)",                             "sub", "" , "func", "JSON_reduce_spaces"   ) 
    JSON_rules[1] := Object( "key", "([QS]:[QSNOAD])",                   "sub", "_", "func", "JSON_reduce_keyvalue" ) 
    JSON_rules[2] := Object( "key", "(\[(([QSNOAD](,[QSNOAD])*\])|\]))", "sub", "A", "func", "JSON_reduce_array"    ) 
    JSON_rules[3] := Object( "key", "({}|{_(,_)*})",                     "sub", "O", "func", "JSON_reduce_object"   ) 

    #Escapechar \ 

} 

// Reducing functions                                                       // 
// Space                           // 
JSON_reduce_spaces(c)  { 
    return "" 
} 
// Key-value pair                  // 
JSON_reduce_keyvalue(c){ 
    return Object(c[3], c[1]) 
} 
// Array                           // 
JSON_reduce_array(c){ 
    ret := Object() 

    new_idx := (c.maxindex() - 1) \/\/ 2 
    for old_idx, token in c { 
        if (mod(old_idx,2) == 0) { 
            ret[new_idx] := token 
            new_idx -= 1 
        } 
    } 
    return ret 
} 
// Objects                         // 
JSON_reduce_object(c){ 
    ret := Object() 
    for old_idx, key_val in c { 
        if (mod(old_idx,2) == 0) { 
            for key, val in key_val { 
                ret[key] := val 
            } 
        } 
    } 
    return ret 
} 



// Main parsing method                                                                      // 
JSON_from(s){ 

    ret     := Object() 
    pos     := 1 
    symbols := "" 
    len     := strLen(s) 

    //   Loop over the tokens         // 
    while (pos <= len) { 

        // Shift a token                 // 
        t := JSON_shift(s,pos,symbols,ret) 

        // Reduce                       // 
        symbols := JSON_reduce(t["symbols"],ret), pos := t["pos"] 

    } 

    // If succesfully reduced, return the object/array    // 
    if (symbols == "O" || symbols == "A") 
        return ret[""] 
    else 
        JSON_error("Invalid JSON string, cannot convert to object.") 
} 



//  Read a token and shift in symbol to the stack                                          // 
JSON_shift(s, pos, symbols, ret){ 

    global JSON_regexps 

    for symbol,regexp in JSON_regexps { 

        // match 1 includes quotes, match 2 doesn't       // 
        RegexMatch(s, "PSi)(" . regexp . ")", match_, pos) 
        if (match_pos1 == pos){ 

            // Add current state to the symbol stack          // 
            symbols .= symbol 

            // Update position                                // 
            pos  += match_len1 

            // Insert the value in the value stack            // 
            ret.insert( JSON_unescape(substr(s, match_pos2, match_len2)) ) 

            // Return the updated symbol stack and pos        // 
            return Object("symbols", symbols, "pos", pos) 
        } 
    } 

    // If there is nothing to shift, error  // 
    JSON_error("Error at pos:" pos "\n" substr(s,pos-4)) 
    exit 
} 



//  Reduces groups of symbols into others according to the rule table                       // 
JSON_reduce(symbols, ret){ 

    global JSON_regexps, JSON_rules 

    rule_idx := 0 

    // Loop over rules, to check if it's possible to reduce tokens // 
    while (rule_idx <= JSON_rules.maxIndex()) { 

        children    := Object() 
        rule        := JSON_rules[rule_idx] 
        old_symbols := rule["key"] 
        new_symbol  := rule["sub"] 
        reduce_func := rule["func"] 

        // Find something to reduce // 
        Regexmatch(symbols, "PSi)" . old_symbols . "$", match_) 

        // If you find nothing, continue to the next rule // 
        if ( match_pos1 < 1 ) { 
            rule_idx += 1 
            continue 
        } 

        // If you find something, remove the symbols from the symbols stack  // 
        // and reduce the tokens in the result stack                         // 
        Loop, %match_len1% { 
            if (ryle_idx != 0 ) 
                children.insert( ret[ret.maxindex()] ) 
            ret.remove() 
            stringtrimright, symbols, symbols, 1 
        } 

        // Append the reduced symbol to the symbol stack  // 
        symbols .= new_symbol 
        rule_idx := 0 

        // Reduce the tokens into a new one  // 
        if ((new_token := %reduce_func%(children)) != "") 
            ret[ret.maxindex()+1] := new_token 

    } 

    return symbols 

}