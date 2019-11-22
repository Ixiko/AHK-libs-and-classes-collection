#include <ShellRun>

ShellRunEx(cmdLine, workingDir)
{
    cmdLine := EnvVars(cmdLine)
    args := Args(cmdLine)
    
    
    
    ; Extract exe path
    exePath := args[1]
    if (RegExMatch(exePath, "^\\?[^\/:*?""<>|\r\n%]+\\?$") and FileExist(A_ScriptDir "\" exePath))
    {
        exePath := A_ScriptDir "\" exePath
    }
    
    
    ; Extract params
    params =
    i := 2
    while (i <= args[0])
    {
        params .= args[i]
        if (i <> arg[0])
            params .= " "
        i++
    }
    
    
    ; Run command
    ShellRun(exePath, params, workingDir)
}

EnvVars(str)
{
    if sz:=DllCall("ExpandEnvironmentStrings", "uint", &str
                    , "uint", 0, "uint", 0)
    {
        VarSetCapacity(dst, A_IsUnicode ? sz*2:sz)
        if DllCall("ExpandEnvironmentStrings", "uint", &str
                    , "str", dst, "uint", sz)
            return dst
    }
    return src
}

; By SKAN
; http://goo.gl/JfMNpN,  
; CD:23/Aug/2014 | MD:24/Aug/2014
Args( CmdLine := "", Skip := 0 ) 
{
  
  Local pArgs := 0, nArgs := 0, A := []
  
  pArgs := DllCall( "Shell32\CommandLineToArgvW", "WStr",CmdLine, "PtrP",nArgs, "Ptr" ) 

  Loop % ( nArgs ) 
     If ( A_Index > Skip ) 
       A[ A_Index - Skip ] := StrGet( NumGet( ( A_Index - 1 ) * A_PtrSize + pArgs ), "UTF-16" )  

    Return A,   A[0] := nArgs - Skip,   DllCall( "LocalFree", "Ptr",pArgs )
}