﻿;*************************
;*                       *
;*                       *
;*        FileMD5        *
;*                       *
;*                       *
;*************************
;
;
;   Description
;   ===========
;   Computes and returns MD5 hash [RFC1321 specification] for the specified,
;   with speeds comparable to Hashes.DLL.
;
;       RFC1321 specification:
;
;           http://www.ietf.org/rfc/rfc1321.txt
;
;       Hashes.DLL
;
;           http://www.autohotkey.com/forum/topic7179.html            
;
;
;
;   Parameters
;   ==========
;
;       Name            Description
;       ----            -----------
;       sFile           Path to the file to be hashed.
;
;       cSz             Buffer size.  Valid values are as follows:
;
;                         0 = 256 KB
;                         1 = 512 KB
;                         2 = 1 MB
;                         3 = 2 MB
;                         4 = 4 MB (Default)
;                         5 = 8 MB
;                         6 = 16 MB
;                         7 = 32 MB
;                         8 = 64 MB 
;
;
;
;   Return Codes
;   ============
;   Returns the MD5 hash for the specified file.  Returns -1 if the file cannot
;   be found or is invalid.
;
;
;
;   Calls To Other Functions
;   ========================
;   (None)
;
;
;
;   Credit
;   ======
;   This code was extracted from the AHK forum.
;
;       Author: SKAN
;       Forum:  www.autohotkey.com/forum/viewtopic.php?p=275910#275910
;       Original script name:   n/a
;       Original function name: FileMD5
;
;
;-------------------------------------------------------------------------------
FileMD5(sFile="",cSz=4)
    {
    cSz:=(cSz<0||cSz>8) ? 2**22 : 2**(18+cSz)
    VarSetCapacity(Buffer,cSz,0)
    hFil:=DllCall("CreateFile","Str",sFile,"UInt",0x80000000,"Int",1,"Int",0,"Int",3,"Int",0,"Int",0)
    if hFil<1
        return hFil

    DllCall("GetFileSizeEx","UInt",hFil,"Str",Buffer)
    fSz:=NumGet(Buffer,0,"Int64")
    VarSetCapacity(MD5_CTX,104,0)
    DllCall("advapi32\MD5Init","Str",MD5_CTX)
    loop % (fSz//cSz+!!Mod(fSz,cSz))
        DllCall("ReadFile","UInt",hFil,"Str",Buffer,"UInt",cSz,"UIntP",bytesRead,"UInt",0)
            ,DllCall("advapi32\MD5Update","Str",MD5_CTX,"Str",Buffer,"UInt",bytesRead)

    DllCall("advapi32\MD5Final","Str",MD5_CTX)
    DllCall("CloseHandle","UInt",hFil)
    loop % StrLen(Hex:="123456789ABCDEF0")
        {
        N:=NumGet(MD5_CTX,87+A_Index,"Char")
        MD5.=SubStr(Hex,N>>4,1) . SubStr(Hex,N&15,1)
        }

    return MD5
    }
