; 此脚本来自 www.autohotkey.com/forum/topic6107.html

SystemCursor(OnOff=1)   ; 初始化 = "I","Init"; 隐藏 = 0,"Off"; 切换 = -1,"T","Toggle"; 显示 = 其他
{
    static AndMask, XorMask, $, h_cursor
        ,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13 ; 系统指针
        , b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13   ; 空白指针
        , h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11,h12,h13   ; 默认指针的句柄
    if (OnOff = "Init" or OnOff = "I" or $ = "")       ; 在请求或首此调用时进行初始化
    {
        $ = h                                          ; 活动的默认指针
        VarSetCapacity( h_cursor,4444, 1 )
        VarSetCapacity( AndMask, 32*4, 0xFF )
        VarSetCapacity( XorMask, 32*4, 0 )
        system_cursors = 32512,32513,32514,32515,32516,32642,32643,32644,32645,32646,32648,32649,32650
        StringSplit c, system_cursors, `,
        Loop %c0%
        {
            h_cursor   := DllCall( "LoadCursor", "Ptr",0, "Ptr",c%A_Index% )
            h%A_Index% := DllCall( "CopyImage", "Ptr",h_cursor, "UInt",2, "Int",0, "Int",0, "UInt",0 )
            b%A_Index% := DllCall( "CreateCursor", "Ptr",0, "Int",0, "Int",0
                , "Int",32, "Int",32, "Ptr",&AndMask, "Ptr",&XorMask )
        }
    }
    if (OnOff = 0 or OnOff = "Off" or $ = "h" and (OnOff < 0 or OnOff = "Toggle" or OnOff = "T"))
        $ = b  ; 使用空白指针
    else
        $ = h  ; 使用保存的指针

    Loop %c0%
    {
        h_cursor := DllCall( "CopyImage", "Ptr",%$%%A_Index%, "UInt",2, "Int",0, "Int",0, "UInt",0 )
        DllCall( "SetSystemCursor", "Ptr",h_cursor, "UInt",c%A_Index% )
    }
}
