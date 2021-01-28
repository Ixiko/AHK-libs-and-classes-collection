SystemMessage(p_MessageNbr)
    {
    if p_MessageNbr is not Integer
        return

    VarSetCapacity(l_Message,1024)
    DllCall("FormatMessage"
           ,"uint",0x1000           ;-- 0x1000=FORMAT_MESSAGE_FROM_SYSTEM
           ,"uint",0
           ,"uint",p_MessageNbr
           ,"uint",0
           ,"str",l_Message
           ,"uint",1024
           ,"uint",0)

    return l_Message
    }
