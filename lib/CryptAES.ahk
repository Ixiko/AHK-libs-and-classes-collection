CryptAES(ByRef lp,sz,pw,e:=1,SID:=256){
	static AES_128:=0x660E,AES_192:=1+AES_128,AES_256:=1+AES_192,SHA1:=1+0x8003 ; MD5
	If !DllCall("Advapi32\CryptAcquireContext","Ptr*",hP,"Uint",0,"Uint",0,"Uint",24,"UInt",0xF0000000) ;PROV_RSA_AES, CRYPT_VERIFYCONTEXT
	|| !DllCall("Advapi32\CryptCreateHash","Ptr",hP,"Uint",SHA1,"Uint",0,"Uint",0,"Ptr*",H )
	|| !CryptHashData(H,&pw,StrLen(pw)*2,0)
	|| !CryptDeriveKey(hP,AES_%SID%,H,SID<<16,getvar(hK:=0))
	|| !CryptDestroyHash(H)
		return 0
	if e
		CryptEncrypt(hK,0,1,0,&lp,getvar(sz),sz+16)
	else
		CryptDecrypt(hK,0,1,0,&lp,sz)
	CryptDestroyKey(hK),CryptReleaseContext(hP,0)
	return sz
}
;~ CryptAES(ByRef lp,sz,pw,e:=1,SID:=256){
	;~ static f:="advapi32\Crypt",t:="UPtr",t_:="UPtr*",AES_128:=0x660E,AES_192:=1+AES_128,AES_256:=1+AES_192,SHA1:=1+0x8003 ; MD5
	;~ return e?VarSetCapacity(lp,sz+16):0,DllCall(f "AcquireContext",t_,hP,t,0,t,0,t,24,t,0xF0000000) ;PROV_RSA_AES, CRYPT_VERIFYCONTEXT
  ;~ ,DllCall(f "CreateHash",t,hP,t,SHA1,t,0,t,0,t_,H),DllCall(f "HashData",t,H,str,pw,t,StrLen(pw)*2,t,0)
  ;~ ,DllCall(f "DeriveKey",t,hP,t,AES_%SID%,t,H,t,SID<<16,t_,hK),DllCall(f "DestroyHash",t,H)
  ;~ ,e?DllCall(f "Encrypt",t,hK,t,0,t,1,t,0,t,&lp,t_,sz,t,sz+16):DllCall(f "Decrypt",t,hK,t,0,t,1,t,0,t,&lp,t_,sz)
  ;~ ,DllCall(f "DestroyKey",t,hK),DllCall(f "ReleaseContext",t,hP,t,0)
  ;~ ,sz
;~ }