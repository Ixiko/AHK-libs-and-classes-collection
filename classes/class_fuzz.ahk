class fuzz
{
    static all_dll_func := {"fuzz.dll" : {"rapid_fuzz_cpp_ratio": 0, "rapid_fuzz_cpp_partial_ratio" : 0 ,"rapid_fuzz_cpp_token_ratio" : 0, "rapid_fuzz_cpp_partial_token_ratio" : 0 ,"rapid_fuzz_cpp_token_sort_ratio" : 0, "rapid_fuzz_cpp_partial_token_sort_ratio" : 0,"rapid_fuzz_cpp_token_set_ratio" : 0, "rapid_fuzz_cpp_partial_token_set_ratio" : 0}}
    static _ := fuzz.load_all_dll_func()
    load_all_dll_func()
    {
        SplitPath,A_LineFile,,dir
        path := ""
        lib_path := dir
        if(A_IsCompiled)
        {
            path := A_PtrSize == 4 ? A_ScriptDir . "\lib\dll_32\" : A_ScriptDir . "\lib\dll_64\"
            lib_path := A_ScriptDir . "\lib"
        }
        else
        {
            path := (A_PtrSize == 4) ? dir . "\dll_32\" : dir . "\dll_64\"
        }
        dllcall("SetDllDirectory", "Str", path)
        for k,v in this.all_dll_func
        {
            for k1, v1 in v 
            {
                this.all_dll_func[k][k1] := DllCall("GetProcAddress", "Ptr", DllCall("LoadLibrary", "Str", k, "Ptr"), "AStr", k1, "Ptr")
            }
        }
        this.is_dll_load := true
        DllCall("SetDllDirectory", "Str", A_ScriptDir)
    }
    __new()
    {
        this.load_all_dll_func()
    }
    partial_token_set_ratio(str1, str2)
    {
        return DllCall(this.all_dll_func["fuzz.dll"]["rapid_fuzz_cpp_partial_token_set_ratio"], "wstr", str1, "wstr", str2, "Cdecl Double")
    }
    match_single(str1, str2)
    {
        if(str1 == " ")
            return 100
        score = fuzz.partial_token_set_ratio(str1, str2)
        return score
    }
    /*
    * param str1 输入字符串 空格分割
    * param str2 待查找字符串
    */
    match(str1, str2)
    {
        arr := StrSplit(str1, [A_Space, A_tab])
        if(arr.MaxIndex() == "")
            return 100
        score := 0
        real_Length = 0
        for k,v in arr
        {
            if(v != "" && v != " ")
                real_Length++
            Else
                Continue
            score += fuzz.partial_token_set_ratio(v, str2)
        }
        if(real_Length > 0)
            return score / real_Length
        Else
            return 0
    }
}