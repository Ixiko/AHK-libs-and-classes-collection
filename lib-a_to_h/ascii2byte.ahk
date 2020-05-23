#NoEnv
SetBatchLines -1
ListLines Off
#include <logging>
#include <system>
#include <base64>
#include <ansi>

Main:
    ASCII_BYTE_CP := System.EnvGet("ASCII_BYTE_CP")
    ASCII_TO_BYTE := true

    if (System.vArgs.MaxIndex() >= 1)
    {
        if (System.vArgs[1] = "-r")
        {
            ASCII_TO_BYTE := false
            System.vArgs.RemoveAt(1)
        }
        else if (System.vArgs[1] = "-h"
            || System.vArgs[1] = "--help"
            || System.vArgs[1] = "/?")
        {
            Ansi.WriteLine("usage: ascii2byte [-r] <string> [encoding]")
            Ansi.WriteLine("   or: Command | ascii2byte [-r]")
            Ansi.WriteLine("   or: ascii2byte [-r] (to read from StdIn)")
            Ansi.WriteLine("")
            Ansi.WriteLine("   -r  To revert the operation (byte2ascii)")
            Ansi.WriteLine("`nSet enviromnent variable ASCII_BYTE_CP "
            . "to use a different encoding (Default: cp1252)")
            exitapp
        }
    }

    if (System.vArgs.MaxIndex() < 1)
    {
        stdin := FileOpen("*", "r")
        st := RegExReplace(stdin.Read(), "[\n\r]+?$", "")
        cp := (ASCII_BYTE_CP <> "" ? ASCII_BYTE_CP : "cp1252")
    }
    else
    {
        st := System.vArgs[1]
        cp := (System.vArgs.MaxIndex() > 1 ? System.vArgs[2]
            : (ASCII_BYTE_CP <> "" ? ASCII_BYTE_CP : "cp1252"))
    }
    try
    {
        OutputDebug %A_ScriptName% cp=%cp% st="%st%"
        if (ASCII_TO_BYTE)
        {
            loop % StrLen(st)
            {
                Ansi.Write(Asc(SubStr(st, A_Index, 1)) " 0 ")
            }
            Ansi.WriteLine("0 0")
        }
        else
        {
            loop parse, st, %A_Space%
            {
                if (A_LoopField > 0)
                {
                    Ansi.Write(Chr(A_LoopField))
                }
            }
            Ansi.WriteLine()
        }
    }
    catch err
    {
        Ansi.WriteLine(err.Message "(" err.Extra ")")
        exitapp 0
    }
exitapp 1
