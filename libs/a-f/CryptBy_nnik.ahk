;https://autohotkey.com/boards/viewtopic.php?f=6&t=1108&hilit=password+encryption

encryptStr(str="",pass="") {
        If !(enclen:=(strput(str,"utf-16")*2))
            return "Error: Nothing to Encrypt"
        If !(passlen:=strput(pass,"utf-8")-1)
            return "Error: No Pass"
        enclen:=mod(enclen,4) ? (enclen) : (enclen-2)
        Varsetcapacity(encbin,enclen,0)
        strput(str,&encbin,enclen/2,"utf-16")
        Varsetcapacity(passbin,passlen+=mod((4-mod(passlen,4)),4),0)
        strput(pass,&passbin,strlen(pass),"utf-8")
        _encryptbin(&encbin,enclen,&passbin,passlen)
return _crypttobase64(&encbin,enclen)
}

decryptStr(str="",pass="") {
    If !((strput(str,"utf-16")*2))
        return "Error: Nothing to Decrypt"
    If !((passlen:=strput(pass,"utf-8")-1))
        return "Error: No Pass"
    Varsetcapacity(passbin,passlen+=mod((4-mod(passlen,4)),4),0)
    strput(pass,&passbin,strlen(pass),"utf-8")
    enclen:=_cryptfrombase64(str,encbin)
    _decryptbin(&encbin,enclen,&passbin,passlen)
return strget(&encbin,"utf-16")
}

_MCode(mcode) {
  static e := {1:4, 2:1}, c := (A_PtrSize=8) ? "x64" : "x86"
  if (!regexmatch(mcode, "^([0-9]+),(" c ":|.*?," c ":)([^,]+)", m))
    return
  if (!DllCall("crypt32\CryptStringToBinary", "str", m3, "uint", 0, "uint", e[m1], "ptr", 0, "uint*", s, "ptr", 0, "ptr", 0))
    return
  p := DllCall("GlobalAlloc", "uint", 0, "ptr", s, "ptr")
  if (c="x64")
    DllCall("VirtualProtect", "ptr", p, "ptr", s, "uint", 0x40, "uint*", op)
  if (DllCall("crypt32\CryptStringToBinary", "str", m3, "uint", 0, "uint", e[m1], "ptr", p, "uint*", s, "ptr", 0, "ptr", 0))
    return p
  DllCall("GlobalFree", "ptr", p)
}

_encryptbin(bin1pointer,bin1len,bin2pointer,bin2len) { 
  static encrypt := _MCode("2,x86:U1VWV4t0JBCLTCQUuAAAAAABzoPuBIsWAcKJFinCAdAPr8KD6QR164tsJByLfCQYi3QkEItMJBSLH7gAAAAAixYBwjHaiRYx2inCAdAPr8KDxgSD6QR154PHBIPtBHXQuAAAAABfXl1bww==,x64:U1ZJicpJidNMidZMidlIAc64AAAAAEiD7gSLFgHCiRYpwgHQD6/CSIPpBHXpuAAAAABBixhMidZMidmLFgHCMdqJFjHaKcIB0A+vwkiDxgRIg+kEdeVJg8AESYPpBHXbuAAAAABeW8M=") ;reserved
b:=0
Loop % bin1len/4
{
a:=numget(bin1pointer+0,bin1len-A_Index*4,"uint")
numput(a+b,bin1pointer+0,bin1len-A_Index*4,"uint")
b:=(a+b)*a
}
Loop % bin2len/4
{
c:=numget(bin2pointer+0,(A_Index-1)*4,"uint")
b:=0
Loop % bin1len/4
{
a:=numget(bin1pointer+0,(A_Index-1)*4,"uint")
numput((a+b)^c,bin1pointer+0,(A_Index-1)*4,"uint")
b:=(a+b)*a
}
}
}

_decryptbin(bin1pointer,bin1len,bin2pointer,bin2len) {
  static decrypt := _MCode("2,x86:U1VWV4tsJByLfCQYAe+D7wSLH7gAAAAAi3QkEItMJBSLFjHaKcKJFgHQD6/Cg8YEg+kEdeuD7QR11LgAAAAAi3QkEItMJBQBzoPuBIsWKcKJFgHQD6/Cg+kEde24AAAAAF9eXVvD,x64:U1ZJicpJidNNAchJg+gEuAAAAABBixhMidZMidmLFjHaKcKJFgHQD6/CSIPGBEiD6QR16UmD6QR140yJ1kyJ2UgBzrgAAAAASIPuBIsWKcKJFgHQD6/CSIPpBHXruAAAAABeW8M=") ;reserved

Loop % bin2len/4
{
c:=numget(bin2pointer+0,bin2len-A_Index*4,"uint")
b:=0
Loop % bin1len/4
{
a:=numget(bin1pointer+0,(A_Index-1)*4,"uint")
numput(a:=(a^c)-b,bin1pointer+0,(A_Index-1)*4,"uint")
b:=(a+b)*a
}
}
b:=0
Loop % bin1len/4
{
a:=numget(bin1pointer+0,bin1len-A_Index*4,"uint")
numput(a:=a-b,bin1pointer+0,bin1len-A_Index*4,"uint")
b:=(a+b)*a
}
}

_crypttobase64(binpointer,binlen) {
    s:=0
    DllCall("crypt32\CryptBinaryToStringW","ptr",binpointer,"uint",binlen,"uint",1,"ptr",   0,"uint*",s)
    VarSetCapacity(out,s*2,0)
    DllCall("crypt32\CryptBinaryToStringW","ptr",binpointer,"uint",binlen,"uint",1,"ptr",&out,"uint*",s)
    return strget(&out,"utf-16")
}

_cryptfrombase64(string,byref bin) {
    DllCall("crypt32\CryptStringToBinaryW", "wstr",string,"uint",0,"uint",1,"ptr",0,"uint*",s,"ptr",0,"ptr",0)
    VarSetCapacity(bin,s,0)
    DllCall("crypt32\CryptStringToBinaryW", "wstr",string,"uint",0,"uint",1,"ptr",&bin,"uint*",s,"ptr",0,"ptr",0)
    return s
}