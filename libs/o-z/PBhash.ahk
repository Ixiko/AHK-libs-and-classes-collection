; ======================================================================
; E N C R Y P T I O N   C L A S S
; ======================================================================
class Crypt
{
  class Encrypt
  {
    static StrEncoding := "UTF-16"
    static PassEncoding := "UTF-16"

    StrDecryptToFile(EncryptedHash,pFileOut,password,CryptAlg = 1, HashAlg = 1)
    {
      if !EncryptedHash
        return ""
      if !len := b64Decode( EncryptedHash, encr_Buf )
        return ""
      temp_file := "crypt.temp"
      f := FileOpen(temp_file,"w","CP0")
      if !IsObject(f)
        return ""
      if !f.RawWrite(encr_Buf,len)
        return ""
      f.close()
      bytes := this._Encrypt( p, pp, password, 0, temp_file, pFileOut, CryptAlg, HashAlg )
      FileDelete,% temp_file
      return bytes
    }

    FileEncryptToStr(pFileIn,password,CryptAlg = 1, HashAlg = 1)
    {
      temp_file := "crypt.temp"
      if !this._Encrypt( p, pp, password, 1, pFileIn, temp_file, CryptAlg, HashAlg )
        return ""
      f := FileOpen(temp_file,"r","CP0")
      if !IsObject(f)
      {
        FileDelete,% temp_file
        return ""
      }
      f.Pos := 0
      fLen := f.Length
      VarSetCapacity(tembBuf,fLen,0)
      if !f.RawRead(tembBuf,fLen)
      {
        Free(tembBuf)
        return ""
      }
      f.Close()
      FileDelete,% temp_file
      return b64Encode( tembBuf, fLen )
    }

    FileEncrypt(pFileIn,pFileOut,password,CryptAlg = 1, HashAlg = 1)
    {
      return this._Encrypt( p, pp, password, 1, pFileIn, pFileOut, CryptAlg, HashAlg )
    }

    FileDecrypt(pFileIn,pFileOut,password,CryptAlg = 1, HashAlg = 1)
    {
      return this._Encrypt( p, pp, password, 0, pFileIn, pFileOut, CryptAlg, HashAlg )
    }

    StrEncrypt(string,password,CryptAlg = 1, HashAlg = 1)
    {
      len := StrPutVar(string, str_buf,100,this.StrEncoding)
      if this._Encrypt(str_buf,len, password, 1,0,0,CryptAlg,HashAlg)
        return b64Encode( str_buf, len )
      else
        return ""
    }

    StrDecrypt(EncryptedHash,password,CryptAlg = 1, HashAlg = 1)
    {
      if !EncryptedHash
        return ""
      if !len := b64Decode( EncryptedHash, encr_Buf )
        return 0
      if sLen := this._Encrypt(encr_Buf,len, password, 0,0,0,CryptAlg,HashAlg)
      {
        if ( this.StrEncoding = "utf-16" || this.StrEncoding = "cp1200" )
          sLen /= 2
        return strget(&encr_Buf,sLen,this.StrEncoding)
      }
      else
        return ""
    }

    _Encrypt(ByRef encr_Buf,ByRef Buf_Len, password, mode, pFileIn=0, pFileOut=0, CryptAlg = 1,HashAlg = 1) ;mode - 1 encrypt, 0 - decrypt
    {
      c := CryptConst
      ;password hashing algorithms
      CUR_PWD_HASH_ALG := HashAlg == 1 || HashAlg = "MD5" ?c.CALG_MD5
        :HashAlg==2 || HashAlg = "MD2"  ?c.CALG_MD2
        :HashAlg==3 || HashAlg = "SHA"  ?c.CALG_SHA
        :HashAlg==4 || HashAlg = "SHA256" ?c.CALG_SHA_256 ;Vista+ only
        :HashAlg==5 || HashAlg = "SHA384" ?c.CALG_SHA_384 ;Vista+ only
        :HashAlg==6 || HashAlg = "SHA512" ?c.CALG_SHA_512 ;Vista+ only
        :0
      ;encryption algorithms
      CUR_ENC_ALG := CryptAlg==1 || CryptAlg = "RC4"      ? ( c.CALG_RC4, KEY_LENGHT:=0x80 )
        :CryptAlg==2 || CryptAlg = "RC2"    ? ( c.CALG_RC2, KEY_LENGHT:=0x80 )
        :CryptAlg==3 || CryptAlg = "3DES"     ? ( c.CALG_3DES, KEY_LENGHT:=0xC0 )
        :CryptAlg==4 || CryptAlg = "3DES112" ? ( c.CALG_3DES_112, KEY_LENGHT:=0x80 )
        :CryptAlg==5 || CryptAlg = "AES128"   ? ( c.CALG_AES_128, KEY_LENGHT:=0x80 ) ;not supported for win 2000
        :CryptAlg==6 || CryptAlg = "AES192"   ? ( c.CALG_AES_192, KEY_LENGHT:=0xC0 )  ;not supported for win 2000
        :CryptAlg==7 || CryptAlg = "AES256"   ? ( c.CALG_AES_256, KEY_LENGHT:=0x100 ) ;not supported for win 2000
        :0
      KEY_LENGHT <<= 16
      if (CUR_PWD_HASH_ALG = 0 || CUR_ENC_ALG = 0)
        return 0

      if !dllCall("Advapi32\CryptAcquireContextW","Ptr*",hCryptProv,"Uint",0,"Uint",0,"Uint",c.PROV_RSA_AES,"UInt",c.CRYPT_VERIFYCONTEXT)
      {foo := "CryptAcquireContextW", err := GetLastError(), err2 := ErrorLevel
      Goto FINISH
      }
      if !dllCall("Advapi32\CryptCreateHash","Ptr",hCryptProv,"Uint",CUR_PWD_HASH_ALG,"Uint",0,"Uint",0,"Ptr*",hHash )
      {foo := "CryptCreateHash", err := GetLastError(), err2 := ErrorLevel
      Goto FINISH
      }
      ;hashing password
      passLen := StrPutVar(password, passBuf,0,this.PassEncoding)
      if !dllCall("Advapi32\CryptHashData","Ptr",hHash,"Ptr",&passBuf,"Uint",passLen,"Uint",0 )
      {foo := "CryptHashData", err := GetLastError(), err2 := ErrorLevel
      Goto FINISH
      }
      ;getting encryption key from password
      if !dllCall("Advapi32\CryptDeriveKey","Ptr",hCryptProv,"Uint",CUR_ENC_ALG,"Ptr",hHash,"Uint",KEY_LENGHT,"Ptr*",hKey )
      {foo := "CryptDeriveKey", err := GetLastError(), err2 := ErrorLevel
      Goto FINISH
      }
      ;~ SetKeySalt(hKey,hCryptProv)
      if !dllCall("Advapi32\CryptGetKeyParam","Ptr",hKey,"Uint",c.KP_BLOCKLEN,"Uint*",BlockLen,"Uint*",dwCount := 4,"Uint",0)
      {foo := "CryptGetKeyParam", err := GetLastError(), err2 := ErrorLevel
      Goto FINISH
      }
      BlockLen /= 8
      if (mode == 1)              ;Encrypting
      {
        if (pFileIn && pFileOut)      ;encrypting file
        {
          ReadBufSize := 10240 - mod(10240,BlockLen==0?1:BlockLen ) ;10KB
          pfin := FileOpen(pFileIn,"r","CP0")
          pfout := FileOpen(pFileOut,"w","CP0")
          if !IsObject(pfin)
            {foo := "File Opening " . pFileIn
            Goto FINISH
            }
          if !IsObject(pfout)
            {foo := "File Opening " . pFileOut
            Goto FINISH
            }
          pfin.Pos := 0
          VarSetCapacity(ReadBuf,ReadBufSize+BlockLen,0)
          isFinal := 0
          hModule := DllCall("LoadLibrary", "Str", "Advapi32.dll","UPtr")
          CryptEnc := DllCall("GetProcAddress", "Ptr", hModule, "AStr", "CryptEncrypt","UPtr")
          while !pfin.AtEOF
          {
            BytesRead := pfin.RawRead(ReadBuf, ReadBufSize)
            if pfin.AtEOF
              isFinal := 1
            if !dllCall(CryptEnc
              ,"Ptr",hKey ;key
              ,"Ptr",0  ;hash
              ,"Uint",isFinal ;final
              ,"Uint",0 ;dwFlags
              ,"Ptr",&ReadBuf ;pbdata
              ,"Uint*",BytesRead  ;dwsize
              ,"Uint",ReadBufSize+BlockLen )  ;dwbuf
            {foo := "CryptEncrypt", err := GetLastError(), err2 := ErrorLevel
            Goto FINISH
            }
            pfout.RawWrite(ReadBuf,BytesRead)
            Buf_Len += BytesRead
          }
          DllCall("FreeLibrary", "Ptr", hModule)
          pfin.Close()
          pfout.Close()
        }
        else
        {
          if !dllCall("Advapi32\CryptEncrypt"
            ,"Ptr",hKey ;key
            ,"Ptr",0  ;hash
            ,"Uint",1 ;final
            ,"Uint",0 ;dwFlags
            ,"Ptr",&encr_Buf  ;pbdata
            ,"Uint*",Buf_Len  ;dwsize
            ,"Uint",Buf_Len + BlockLen )  ;dwbuf
          {foo := "CryptEncrypt", err := GetLastError(), err2 := ErrorLevel
          Goto FINISH
          }
        }
      }
      else if (mode == 0)               ;decrypting
      {
        if (pFileIn && pFileOut)          ;decrypting file
        {
          ReadBufSize := 10240 - mod(10240,BlockLen==0?1:BlockLen ) ;10KB
          pfin := FileOpen(pFileIn,"r","CP0")
          pfout := FileOpen(pFileOut,"w","CP0")
          if !IsObject(pfin)
            {foo := "File Opening " . pFileIn
            Goto FINISH
            }
          if !IsObject(pfout)
            {foo := "File Opening " . pFileOut
            Goto FINISH
            }
          pfin.Pos := 0
          VarSetCapacity(ReadBuf,ReadBufSize+BlockLen,0)
          isFinal := 0
          hModule := DllCall("LoadLibrary", "Str", "Advapi32.dll","UPtr")
          CryptDec := DllCall("GetProcAddress", "Ptr", hModule, "AStr", "CryptDecrypt","UPtr")
          while !pfin.AtEOF
          {
            BytesRead := pfin.RawRead(ReadBuf, ReadBufSize)
            if pfin.AtEOF
              isFinal := 1
            if !dllCall(CryptDec
              ,"Ptr",hKey ;key
              ,"Ptr",0  ;hash
              ,"Uint",isFinal ;final
              ,"Uint",0 ;dwFlags
              ,"Ptr",&ReadBuf ;pbdata
              ,"Uint*",BytesRead )  ;dwsize
            {foo := "CryptDecrypt", err := GetLastError(), err2 := ErrorLevel
            Goto FINISH
            }
            pfout.RawWrite(ReadBuf,BytesRead)
            Buf_Len += BytesRead
          }
          DllCall("FreeLibrary", "Ptr", hModule)
          pfin.Close()
          pfout.Close()

        }
        else if !dllCall("Advapi32\CryptDecrypt"
            ,"Ptr",hKey ;key
            ,"Ptr",0  ;hash
            ,"Uint",1 ;final
            ,"Uint",0 ;dwFlags
            ,"Ptr",&encr_Buf  ;pbdata
            ,"Uint*",Buf_Len )  ;dwsize
          {foo := "CryptDecrypt", err := GetLastError(), err2 := ErrorLevel
          Goto FINISH
          }
      }
      FINISH:
      dllCall("Advapi32\CryptDestroyKey","Ptr",hKey )
      dllCall("Advapi32\CryptDestroyHash","Ptr",hHash)
      dllCall("Advapi32\CryptReleaseContext","Ptr",hCryptProv,"UInt",0)
      if (A_ThisLabel = "FINISH")
      {
        if (A_IsCompiled = 1)
          return ""
        else
          msgbox % foo " call failed with:`nErrorLevel: " err2 "`nLastError: " err "`n" ErrorFormat(err)
        return ""
      }
      return Buf_Len
    }
  }

  class Hash
  {
    static StrEncoding := "CP0"
    static PassEncoding := "UTF-16"

    FileHash(pFile,HashAlg = 1,pwd = "",hmac_alg = 1)
    {
      return this._CalcHash(p,pp,pFile,HashAlg,pwd,hmac_alg)
    }

    StrHash(string,HashAlg = 1,pwd = "",hmac_alg = 1)   ;strType 1 for ASC, 0 for UTF
    {
      buf_len := StrPutVar(string, buf,0,this.StrEncoding)
      return this._CalcHash(buf,buf_len,0,HashAlg,pwd,hmac_alg)
    }

    _CalcHash(ByRef bBuffer,BufferLen,pFile,HashAlg = 1,pwd = "",hmac_alg = 1)
    {
      c := CryptConst
      ;password hashing algorithms
      HASH_ALG := HashAlg==1?c.CALG_MD5
        :HashAlg==2?c.CALG_MD2
        :HashAlg==3?c.CALG_SHA
        :HashAlg==4?c.CALG_SHA_256  ;Vista+ only
        :HashAlg==5?c.CALG_SHA_384  ;Vista+ only
        :HashAlg==6?c.CALG_SHA_512  ;Vista+ only
        :0
      ;encryption algorithms
      HMAC_KEY_ALG  := hmac_alg==1?c.CALG_RC4
        :hmac_alg==2?c.CALG_RC2
        :hmac_alg==3?c.CALG_3DES
        :hmac_alg==4?c.CALG_3DES_112
        :hmac_alg==5?c.CALG_AES_128 ;not supported for win 2000
        :hmac_alg==6?c.CALG_AES_192 ;not supported for win 2000
        :hmac_alg==7?c.CALG_AES_256 ;not supported for win 2000
        :0
      KEY_LENGHT := hmac_alg==1?0x80
        :hmac_alg==2?0x80
        :hmac_alg==3?0xC0
        :hmac_alg==4?0x80
        :hmac_alg==5?0x80
        :hmac_alg==6?0xC0
        :hmac_alg==7?0x100
        :0
      KEY_LENGHT <<= 16
      if (!HASH_ALG || !HMAC_KEY_ALG)
        return 0
      if !dllCall("Advapi32\CryptAcquireContextW","Ptr*",hCryptProv,"Uint",0,"Uint",0,"Uint",c.PROV_RSA_AES,"UInt",c.CRYPT_VERIFYCONTEXT )
        {foo := "CryptAcquireContextW", err := GetLastError(), err2 := ErrorLevel
        Goto FINITA_DA_COMEDIA
        }
      if !dllCall("Advapi32\CryptCreateHash","Ptr",hCryptProv,"Uint",HASH_ALG,"Uint",0,"Uint",0,"Ptr*",hHash )
        {foo := "CryptCreateHash1", err := GetLastError(), err2 := ErrorLevel
        Goto FINITA_DA_COMEDIA
        }

      if (pwd != "")      ;going HMAC
      {
        passLen := StrPutVar(pwd, passBuf,0,this.PassEncoding)
        if !dllCall("Advapi32\CryptHashData","Ptr",hHash,"Ptr",&passBuf,"Uint",passLen,"Uint",0 )
          {foo := "CryptHashData Pwd", err := GetLastError(), err2 := ErrorLevel
          Goto FINITA_DA_COMEDIA
          }
        ;getting encryption key from password
        if !dllCall("Advapi32\CryptDeriveKey","Ptr",hCryptProv,"Uint",HMAC_KEY_ALG,"Ptr",hHash,"Uint",KEY_LENGHT,"Ptr*",hKey )
          {foo := "CryptDeriveKey Pwd", err := GetLastError(), err2 := ErrorLevel
          Goto FINITA_DA_COMEDIA
          }
        dllCall("Advapi32\CryptDestroyHash","Ptr",hHash)
        if !dllCall("Advapi32\CryptCreateHash","Ptr",hCryptProv,"Uint",c.CALG_HMAC,"Ptr",hKey,"Uint",0,"Ptr*",hHash )
          {foo := "CryptCreateHash2", err := GetLastError(), err2 := ErrorLevel
          Goto FINITA_DA_COMEDIA
          }
        VarSetCapacity(HmacInfoStruct,4*A_PtrSize + 4,0)
        NumPut(HASH_ALG,HmacInfoStruct,0,"UInt")
        if !dllCall("Advapi32\CryptSetHashParam","Ptr",hHash,"Uint",c.HP_HMAC_INFO,"Ptr",&HmacInfoStruct,"Uint",0)
          {foo := "CryptSetHashParam", err := GetLastError(), err2 := ErrorLevel
          Goto FINITA_DA_COMEDIA
          }
      }

      if pFile
      {
        f := FileOpen(pFile,"r","CP0")
        BUFF_SIZE := 1024 * 1024 ; 1 MB
        if !IsObject(f)
          {foo := "File Opening"
          Goto FINITA_DA_COMEDIA
          }
        if !hModule := DllCall( "GetModuleHandleW", "str", "Advapi32.dll", "UPtr" )
          hModule := DllCall( "LoadLibraryW", "str", "Advapi32.dll", "UPtr" )
        hCryptHashData := DllCall("GetProcAddress", "Ptr", hModule, "AStr", "CryptHashData", "UPtr")
        VarSetCapacity(read_buf,BUFF_SIZE,0)
        f.Pos := 0
        While (cbCount := f.RawRead(read_buf, BUFF_SIZE))
        {
          if (cbCount = 0)
            break
          if !dllCall(hCryptHashData
              ,"Ptr",hHash
              ,"Ptr",&read_buf
              ,"Uint",cbCount
              ,"Uint",0 )
            {foo := "CryptHashData", err := GetLastError(), err2 := ErrorLevel
            Goto FINITA_DA_COMEDIA
            }
        }
        f.Close()
      }
      else
      {
        if !dllCall("Advapi32\CryptHashData"
            ,"Ptr",hHash
            ,"Ptr",&bBuffer
            ,"Uint",BufferLen
            ,"Uint",0 )
          {foo := "CryptHashData", err := GetLastError(), err2 := ErrorLevel
          Goto FINITA_DA_COMEDIA
          }
      }
      if !dllCall("Advapi32\CryptGetHashParam","Ptr",hHash,"Uint",c.HP_HASHSIZE,"Uint*",HashLen,"Uint*",HashLenSize := 4,"UInt",0 )
        {foo := "CryptGetHashParam HP_HASHSIZE", err := GetLastError(), err2 := ErrorLevel
        Goto FINITA_DA_COMEDIA
        }
      VarSetCapacity(pbHash,HashLen,0)
      if !dllCall("Advapi32\CryptGetHashParam","Ptr",hHash,"Uint",c.HP_HASHVAL,"Ptr",&pbHash,"Uint*",HashLen,"UInt",0 )
      {foo := "CryptGetHashParam HP_HASHVAL", err := GetLastError(), err2 := ErrorLevel
      Goto FINITA_DA_COMEDIA
      }
      hashval := b2a_hex( pbHash, HashLen )

      FINITA_DA_COMEDIA:
      DllCall("FreeLibrary", "Ptr", hModule)
      dllCall("Advapi32\CryptDestroyHash","Ptr",hHash)
      dllCall("Advapi32\CryptDestroyKey","Ptr",hKey )
      dllCall("Advapi32\CryptReleaseContext","Ptr",hCryptProv,"UInt",0)
      if (A_ThisLabel = "FINISH")
      {
        if (A_IsCompiled = 1)
          return ""
        else
          msgbox % foo " call failed with:`nErrorLevel: " err2 "`nLastError: " err "`n" ErrorFormat(err)
        return 0
      }
      return hashval
    }
  }
}

;returns positive hex value of last error
GetLastError()
{
  return ToHex(A_LastError < 0 ? A_LastError & 0xFFFFFFFF : A_LastError)
}

;converting decimal to hex value
ToHex(num)
{
  if num is not integer
    return num
  oldFmt := A_FormatInteger
  SetFormat, integer, hex
  num := num + 0
  SetFormat, integer,% oldFmt
  return num
}

;And this function returns error description based on error number passed. ;
;Error number is one returned by GetLastError() or from A_LastError
ErrorFormat(error_id)
{
  VarSetCapacity(msg,1000,0)
  if !len := DllCall("FormatMessageW"
    ,"UInt",FORMAT_MESSAGE_FROM_SYSTEM := 0x00001000 | FORMAT_MESSAGE_IGNORE_INSERTS := 0x00000200    ;dwflags
    ,"Ptr",0    ;lpSource
    ,"UInt",error_id  ;dwMessageId
    ,"UInt",0     ;dwLanguageId
    ,"Ptr",&msg     ;lpBuffer
    ,"UInt",500)      ;nSize
    return
  return  strget(&msg,len)
}

StrPutVar(string, ByRef var, addBufLen = 0,encoding="UTF-16")
{
  ; Ensure capacity.
  ; StrPut returns char count, but VarSetCapacity needs bytes.
  tlen := ((encoding="utf-16"||encoding="cp1200") ? 2 : 1)
  str_len := StrPut(string, encoding) * tlen
    VarSetCapacity( var, str_len + addBufLen,0 )
    ; Copy or convert the string.
  StrPut( string, &var, encoding )
    return str_len - tlen
}

SetKeySalt(hKey,hProv)
{
  KP_SALT_EX := 10
  SALT := "89ABF9C1005EDD40"
  ;~ len := HashToByte(SALT,pb)
  VarSetCapacity(st,2*A_PtrSize,0)
  NumPut(len,st,0,"UInt")
  NumPut(&pb,st,A_PtrSize,"UPtr")
  if !dllCall("Advapi32\CryptSetKeyParam"
    ,"Ptr",hKey
    ,"Uint",KP_SALT_EX
    ,"Ptr",&st
    ,"Uint",0)
  msgbox % ErrorFormat(GetLastError())
}

GetKeySalt(hKey)
{
  KP_IV := 1 ; Initialization vector
  KP_SALT := 2 ; Salt value
  if !dllCall("Advapi32\CryptGetKeyParam"
    ,"Ptr",hKey
    ,"Uint",KP_SALT
    ,"Uint",0
    ,"Uint*",dwCount
    ,"Uint",0)
  msgbox % "Fail to get SALT length."
  msgbox % "SALT length.`n" dwCount
  VarSetCapacity(pb,dwCount,0)
  if !dllCall("Advapi32\CryptGetKeyParam"
    ,"Ptr",hKey
    ,"Uint",KP_SALT
    ,"Ptr",&pb
    ,"Uint*",dwCount
    ,"Uint",0)
  msgbox % "Fail to get SALT"
  ;~ msgbox % ByteToHash(pb,dwCount) "`n" dwCount
}

class CryptConst
{
static ALG_CLASS_ANY := (0)
static ALG_CLASS_SIGNATURE := (1 << 13)
static ALG_CLASS_MSG_ENCRYPT := (2 << 13)
static ALG_CLASS_DATA_ENCRYPT := (3 << 13)
static ALG_CLASS_HASH := (4 << 13)
static ALG_CLASS_KEY_EXCHANGE := (5 << 13)
static ALG_CLASS_ALL := (7 << 13)
static ALG_TYPE_ANY := (0)
static ALG_TYPE_DSS := (1 << 9)
static ALG_TYPE_RSA := (2 << 9)
static ALG_TYPE_BLOCK := (3 << 9)
static ALG_TYPE_STREAM := (4 << 9)
static ALG_TYPE_DH := (5 << 9)
static ALG_TYPE_SECURECHANNEL := (6 << 9)
static ALG_SID_ANY := (0)
static ALG_SID_RSA_ANY := 0
static ALG_SID_RSA_PKCS := 1
static ALG_SID_RSA_MSATWORK := 2
static ALG_SID_RSA_ENTRUST := 3
static ALG_SID_RSA_PGP := 4
static ALG_SID_DSS_ANY := 0
static ALG_SID_DSS_PKCS := 1
static ALG_SID_DSS_DMS := 2
static ALG_SID_ECDSA := 3
static ALG_SID_DES := 1
static ALG_SID_3DES := 3
static ALG_SID_DESX := 4
static ALG_SID_IDEA := 5
static ALG_SID_CAST := 6
static ALG_SID_SAFERSK64 := 7
static ALG_SID_SAFERSK128 := 8
static ALG_SID_3DES_112 := 9
static ALG_SID_CYLINK_MEK := 12
static ALG_SID_RC5 := 13
static ALG_SID_AES_128 := 14
static ALG_SID_AES_192 := 15
static ALG_SID_AES_256 := 16
static ALG_SID_AES := 17
static ALG_SID_SKIPJACK := 10
static ALG_SID_TEK := 11
static CRYPT_MODE_CBCI := 6       ; ANSI CBC Interleaved
static CRYPT_MODE_CFBP := 7       ; ANSI CFB Pipelined
static CRYPT_MODE_OFBP := 8       ; ANSI OFB Pipelined
static CRYPT_MODE_CBCOFM := 9       ; ANSI CBC + OF Masking
static CRYPT_MODE_CBCOFMI := 10      ; ANSI CBC + OFM Interleaved
static ALG_SID_RC2 := 2
static ALG_SID_RC4 := 1
static ALG_SID_SEAL := 2
static ALG_SID_DH_SANDF := 1
static ALG_SID_DH_EPHEM := 2
static ALG_SID_AGREED_KEY_ANY := 3
static ALG_SID_KEA := 4
static ALG_SID_ECDH := 5
static ALG_SID_MD2 := 1
static ALG_SID_MD4 := 2
static ALG_SID_MD5 := 3
static ALG_SID_SHA := 4
static ALG_SID_SHA1 := 4
static ALG_SID_MAC := 5
static ALG_SID_RIPEMD := 6
static ALG_SID_RIPEMD160 := 7
static ALG_SID_SSL3SHAMD5 := 8
static ALG_SID_HMAC := 9
static ALG_SID_TLS1PRF := 10
static ALG_SID_HASH_REPLACE_OWF := 11
static ALG_SID_SHA_256 := 12
static ALG_SID_SHA_384 := 13
static ALG_SID_SHA_512 := 14
static ALG_SID_SSL3_MASTER := 1
static ALG_SID_SCHANNEL_MASTER_HASH := 2
static ALG_SID_SCHANNEL_MAC_KEY := 3
static ALG_SID_PCT1_MASTER := 4
static ALG_SID_SSL2_MASTER := 5
static ALG_SID_TLS1_MASTER := 6
static ALG_SID_SCHANNEL_ENC_KEY := 7
static ALG_SID_ECMQV := 1
static ALG_SID_EXAMPLE := 80
static CALG_MD2 := (CryptConst.ALG_CLASS_HASH | CryptConst.ALG_TYPE_ANY | CryptConst.ALG_SID_MD2)
static CALG_MD4 := (CryptConst.ALG_CLASS_HASH | CryptConst.ALG_TYPE_ANY | CryptConst.ALG_SID_MD4)
static CALG_MD5 := (CryptConst.ALG_CLASS_HASH | CryptConst.ALG_TYPE_ANY | CryptConst.ALG_SID_MD5)
static CALG_SHA := (CryptConst.ALG_CLASS_HASH | CryptConst.ALG_TYPE_ANY | CryptConst.ALG_SID_SHA)
static CALG_SHA1 := (CryptConst.ALG_CLASS_HASH | CryptConst.ALG_TYPE_ANY | CryptConst.ALG_SID_SHA1)
static CALG_MAC := (CryptConst.ALG_CLASS_HASH | CryptConst.ALG_TYPE_ANY | CryptConst.ALG_SID_MAC)
static CALG_RSA_SIGN := (CryptConst.ALG_CLASS_SIGNATURE | CryptConst.ALG_TYPE_RSA | CryptConst.ALG_SID_RSA_ANY)
static CALG_DSS_SIGN := (CryptConst.ALG_CLASS_SIGNATURE | CryptConst.ALG_TYPE_DSS | CryptConst.ALG_SID_DSS_ANY)
static CALG_NO_SIGN := (CryptConst.ALG_CLASS_SIGNATURE | CryptConst.ALG_TYPE_ANY | CryptConst.ALG_SID_ANY)
static CALG_RSA_KEYX := (CryptConst.ALG_CLASS_KEY_EXCHANGE|CryptConst.ALG_TYPE_RSA|CryptConst.ALG_SID_RSA_ANY)
static CALG_DES := (CryptConst.ALG_CLASS_DATA_ENCRYPT|CryptConst.ALG_TYPE_BLOCK|CryptConst.ALG_SID_DES)
static CALG_3DES_112 := (CryptConst.ALG_CLASS_DATA_ENCRYPT|CryptConst.ALG_TYPE_BLOCK|CryptConst.ALG_SID_3DES_112)
static CALG_3DES := (CryptConst.ALG_CLASS_DATA_ENCRYPT|CryptConst.ALG_TYPE_BLOCK|CryptConst.ALG_SID_3DES)
static CALG_DESX := (CryptConst.ALG_CLASS_DATA_ENCRYPT|CryptConst.ALG_TYPE_BLOCK|CryptConst.ALG_SID_DESX)
static CALG_RC2 := (CryptConst.ALG_CLASS_DATA_ENCRYPT|CryptConst.ALG_TYPE_BLOCK|CryptConst.ALG_SID_RC2)
static CALG_RC4 := (CryptConst.ALG_CLASS_DATA_ENCRYPT|CryptConst.ALG_TYPE_STREAM|CryptConst.ALG_SID_RC4)
static CALG_SEAL := (CryptConst.ALG_CLASS_DATA_ENCRYPT|CryptConst.ALG_TYPE_STREAM|CryptConst.ALG_SID_SEA)
static CALG_DH_SF := (CryptConst.ALG_CLASS_KEY_EXCHANGE|CryptConst.ALG_TYPE_DH|CryptConst.ALG_SID_DH_SANDF)
static CALG_DH_EPHEM := (CryptConst.ALG_CLASS_KEY_EXCHANGE|CryptConst.ALG_TYPE_DH|CryptConst.ALG_SID_DH_EPHEM)
static CALG_AGREEDKEY_ANY := (CryptConst.ALG_CLASS_KEY_EXCHANGE|CryptConst.ALG_TYPE_DH|CryptConst.ALG_SID_AGREED_KEY_ANY)
static CALG_KEA_KEYX := (CryptConst.ALG_CLASS_KEY_EXCHANGE|CryptConst.ALG_TYPE_DH|CryptConst.ALG_SID_KEA)
static CALG_HUGHES_MD5 := (CryptConst.ALG_CLASS_KEY_EXCHANGE|CryptConst.ALG_TYPE_ANY|CryptConst.ALG_SID_MD5)
static CALG_SKIPJACK := (CryptConst.ALG_CLASS_DATA_ENCRYPT|CryptConst.ALG_TYPE_BLOCK|CryptConst.ALG_SID_SKIPJACK)
static CALG_TEK := (CryptConst.ALG_CLASS_DATA_ENCRYPT|CryptConst.ALG_TYPE_BLOCK|CryptConst.ALG_SID_TEK)
static CALG_CYLINK_MEK := (CryptConst.ALG_CLASS_DATA_ENCRYPT|CryptConst.ALG_TYPE_BLOCK|CryptConst.ALG_SID_CYLINK_MEK)
static CALG_SSL3_SHAMD5 := (CryptConst.ALG_CLASS_HASH | CryptConst.ALG_TYPE_ANY | CryptConst.ALG_SID_SSL3SHAMD5)
static CALG_SSL3_MASTER := (CryptConst.ALG_CLASS_MSG_ENCRYPT|CryptConst.ALG_TYPE_SECURECHANNEL|CryptConst.ALG_SID_SSL3_MASTER)
static CALG_SCHANNEL_MASTER_HASH := (CryptConst.ALG_CLASS_MSG_ENCRYPT|CryptConst.ALG_TYPE_SECURECHANNEL|CryptConst.ALG_SID_SCHANNEL_MASTER_HASH)
static CALG_SCHANNEL_MAC_KEY := (CryptConst.ALG_CLASS_MSG_ENCRYPT|CryptConst.ALG_TYPE_SECURECHANNEL|CryptConst.ALG_SID_SCHANNEL_MAC_KEY)
static CALG_SCHANNEL_ENC_KEY := (CryptConst.ALG_CLASS_MSG_ENCRYPT|CryptConst.ALG_TYPE_SECURECHANNEL|CryptConst.ALG_SID_SCHANNEL_ENC_KEY)
static CALG_PCT1_MASTER := (CryptConst.ALG_CLASS_MSG_ENCRYPT|CryptConst.ALG_TYPE_SECURECHANNEL|CryptConst.ALG_SID_PCT1_MASTER)
static CALG_SSL2_MASTER := (CryptConst.ALG_CLASS_MSG_ENCRYPT|CryptConst.ALG_TYPE_SECURECHANNEL|CryptConst.ALG_SID_SSL2_MASTER)
static CALG_TLS1_MASTER := (CryptConst.ALG_CLASS_MSG_ENCRYPT|CryptConst.ALG_TYPE_SECURECHANNEL|CryptConst.ALG_SID_TLS1_MASTER)
static CALG_RC5 := (CryptConst.ALG_CLASS_DATA_ENCRYPT|CryptConst.ALG_TYPE_BLOCK|CryptConst.ALG_SID_RC5)
static CALG_HMAC := (CryptConst.ALG_CLASS_HASH | CryptConst.ALG_TYPE_ANY | CryptConst.ALG_SID_HMAC)
static CALG_TLS1PRF := (CryptConst.ALG_CLASS_HASH | CryptConst.ALG_TYPE_ANY | CryptConst.ALG_SID_TLS1PRF)
static CALG_HASH_REPLACE_OWF := (CryptConst.ALG_CLASS_HASH | CryptConst.ALG_TYPE_ANY | CryptConst.ALG_SID_HASH_REPLACE_OWF)
static CALG_AES_128 := (CryptConst.ALG_CLASS_DATA_ENCRYPT|CryptConst.ALG_TYPE_BLOCK|CryptConst.ALG_SID_AES_128)
static CALG_AES_192 := (CryptConst.ALG_CLASS_DATA_ENCRYPT|CryptConst.ALG_TYPE_BLOCK|CryptConst.ALG_SID_AES_192)
static CALG_AES_256 := (CryptConst.ALG_CLASS_DATA_ENCRYPT|CryptConst.ALG_TYPE_BLOCK|CryptConst.ALG_SID_AES_256)
static CALG_AES := (CryptConst.ALG_CLASS_DATA_ENCRYPT|CryptConst.ALG_TYPE_BLOCK|CryptConst.ALG_SID_AES)
static CALG_SHA_256 := (CryptConst.ALG_CLASS_HASH | CryptConst.ALG_TYPE_ANY | CryptConst.ALG_SID_SHA_256)
static CALG_SHA_384 := (CryptConst.ALG_CLASS_HASH | CryptConst.ALG_TYPE_ANY | CryptConst.ALG_SID_SHA_384)
static CALG_SHA_512 := (CryptConst.ALG_CLASS_HASH | CryptConst.ALG_TYPE_ANY | CryptConst.ALG_SID_SHA_512)
static CALG_ECDH := (CryptConst.ALG_CLASS_KEY_EXCHANGE | CryptConst.ALG_TYPE_DH | CryptConst.ALG_SID_ECDH)
static CALG_ECMQV := (CryptConst.ALG_CLASS_KEY_EXCHANGE | CryptConst.ALG_TYPE_ANY | CryptConst.ALG_SID_ECMQV)
static CALG_ECDSA := (CryptConst.ALG_CLASS_SIGNATURE | CryptConst.ALG_TYPE_DSS | CryptConst.ALG_SID_ECDSA)
static CRYPT_VERIFYCONTEXT := 0xF0000000
static CRYPT_NEWKEYSET := 0x00000008
static CRYPT_DELETEKEYSET := 0x00000010
static CRYPT_MACHINE_KEYSET := 0x00000020
static CRYPT_SILENT := 0x00000040
static CRYPT_DEFAULT_CONTAINER_OPTIONAL := 0x00000080
static CRYPT_EXPORTABLE := 0x00000001
static CRYPT_USER_PROTECTED := 0x00000002
static CRYPT_CREATE_SALT := 0x00000004
static CRYPT_UPDATE_KEY := 0x00000008
static CRYPT_NO_SALT := 0x00000010
static CRYPT_PREGEN := 0x00000040
static CRYPT_RECIPIENT := 0x00000010
static CRYPT_INITIATOR := 0x00000040
static CRYPT_ONLINE := 0x00000080
static CRYPT_SF := 0x00000100
static CRYPT_CREATE_IV := 0x00000200
static CRYPT_KEK := 0x00000400
static CRYPT_DATA_KEY := 0x00000800
static CRYPT_VOLATILE := 0x00001000
static CRYPT_SGCKEY := 0x00002000
static CRYPT_ARCHIVABLE := 0x00004000
static CRYPT_FORCE_KEY_PROTECTION_HIGH := 0x00008000
static RSA1024BIT_KEY := 0x04000000
static CRYPT_SERVER := 0x00000400
static KEY_LENGTH_MASK := 0xFFFF0000
static CRYPT_Y_ONLY := 0x00000001
static CRYPT_SSL2_FALLBACK := 0x00000002
static CRYPT_DESTROYKEY := 0x00000004
static CRYPT_OAEP := 0x00000040  ; used with RSA encryptions/decryptions
static CRYPT_BLOB_VER3 := 0x00000080  ; export version 3 of a blob type
static CRYPT_IPSEC_HMAC_KEY := 0x00000100  ; CryptImportKey only
static CRYPT_DECRYPT_RSA_NO_PADDING_CHECK := 0x00000020
static CRYPT_SECRETDIGEST := 0x00000001
static CRYPT_OWF_REPL_LM_HASH := 0x00000001  ; this is only for the OWF replacement CSP
static CRYPT_LITTLE_ENDIAN := 0x00000001
static CRYPT_NOHASHOID := 0x00000001
static CRYPT_TYPE2_FORMAT := 0x00000002
static CRYPT_X931_FORMAT := 0x00000004
static CRYPT_MACHINE_DEFAULT := 0x00000001
static CRYPT_USER_DEFAULT := 0x00000002
static CRYPT_DELETE_DEFAULT := 0x00000004
static SIMPLEBLOB := 0x1
static PUBLICKEYBLOB := 0x6
static PRIVATEKEYBLOB := 0x7
static PLAINTEXTKEYBLOB := 0x8
static OPAQUEKEYBLOB := 0x9
static PUBLICKEYBLOBEX := 0xA
static SYMMETRICWRAPKEYBLOB := 0xB
static KEYSTATEBLOB := 0xC
static AT_KEYEXCHANGE := 1
static AT_SIGNATURE := 2
static CRYPT_USERDATA := 1
static KP_IV := 1       ; Initialization vector
static KP_SALT := 2       ; Salt value
static KP_PADDING := 3       ; Padding values
static KP_MODE := 4       ; Mode of the cipher
static KP_MODE_BITS := 5       ; Number of bits to feedback
static KP_PERMISSIONS := 6       ; Key permissions DWORD
static KP_ALGID := 7       ; Key algorithm
static KP_BLOCKLEN := 8       ; Block size of the cipher
static KP_KEYLEN := 9       ; Length of key in bits
static KP_SALT_EX := 10      ; Length of salt in bytes
static KP_P := 11      ; DSS/Diffie-Hellman P value
static KP_G := 12      ; DSS/Diffie-Hellman G value
static KP_Q := 13      ; DSS Q value
static KP_X := 14      ; Diffie-Hellman X value
static KP_Y := 15      ; Y value
static KP_RA := 16      ; Fortezza RA value
static KP_RB := 17      ; Fortezza RB value
static KP_INFO := 18      ; for putting information into an RSA envelope
static KP_EFFECTIVE_KEYLEN := 19      ; setting and getting RC2 effective key length
static KP_SCHANNEL_ALG := 20      ; for setting the Secure Channel algorithms
static KP_CLIENT_RANDOM := 21      ; for setting the Secure Channel client random data
static KP_SERVER_RANDOM := 22      ; for setting the Secure Channel server random data
static KP_RP := 23
static KP_PRECOMP_MD5 := 24
static KP_PRECOMP_SHA := 25
static KP_CERTIFICATE := 26      ; for setting Secure Channel certificate data (PCT1)
static KP_CLEAR_KEY := 27      ; for setting Secure Channel clear key data (PCT1)
static KP_PUB_EX_LEN := 28
static KP_PUB_EX_VAL := 29
static KP_KEYVAL := 30
static KP_ADMIN_PIN := 31
static KP_KEYEXCHANGE_PIN := 32
static KP_SIGNATURE_PIN := 33
static KP_PREHASH := 34
static KP_ROUNDS := 35
static KP_OAEP_PARAMS := 36      ; for setting OAEP params on RSA keys
static KP_CMS_KEY_INFO := 37
static KP_CMS_DH_KEY_INFO := 38
static KP_PUB_PARAMS := 39      ; for setting public parameters
static KP_VERIFY_PARAMS := 40      ; for verifying DSA and DH parameters
static KP_HIGHEST_VERSION := 41      ; for TLS protocol version setting
static KP_GET_USE_COUNT := 42      ; for use with PP_CRYPT_COUNT_KEY_USE contexts
static KP_PIN_ID := 43
static KP_PIN_INFO := 44
static HP_ALGID := 0x0001  ; Hash algorithm
static HP_HASHVAL := 0x0002  ; Hash value
static HP_HASHSIZE := 0x0004  ; Hash value size
static HP_HMAC_INFO := 0x0005  ; information for creating an HMAC
static HP_TLS1PRF_LABEL := 0x0006  ; label for TLS1 PRF
static HP_TLS1PRF_SEED := 0x0007  ; seed for TLS1 PRF
static PROV_RSA_FULL := 1
static PROV_RSA_SIG := 2
static PROV_DSS := 3
static PROV_FORTEZZA := 4
static PROV_MS_EXCHANGE := 5
static PROV_SSL := 6
static PROV_RSA_SCHANNEL := 12
static PROV_DSS_DH := 13
static PROV_EC_ECDSA_SIG := 14
static PROV_EC_ECNRA_SIG := 15
static PROV_EC_ECDSA_FULL := 16
static PROV_EC_ECNRA_FULL := 17
static PROV_DH_SCHANNEL := 18
static PROV_SPYRUS_LYNKS := 20
static PROV_RNG := 21
static PROV_INTEL_SEC := 22
static PROV_REPLACE_OWF := 23
static PROV_RSA_AES := 24
static PROV_STT_MER := 7
static PROV_STT_ACQ := 8
static PROV_STT_BRND := 9
static PROV_STT_ROOT := 10
static PROV_STT_ISS := 11
}

b64Encode( ByRef buf, bufLen )
{
  DllCall( "crypt32\CryptBinaryToStringA", "ptr", &buf, "UInt", bufLen, "Uint", 1 | 0x40000000, "Ptr", 0, "UInt*", outLen )
  VarSetCapacity( outBuf, outLen, 0 )
  DllCall( "crypt32\CryptBinaryToStringA", "ptr", &buf, "UInt", bufLen, "Uint", 1 | 0x40000000, "Ptr", &outBuf, "UInt*", outLen )
  return strget( &outBuf, outLen, "CP0" )
}

b64Decode( b64str, ByRef outBuf )
{
  static CryptStringToBinary := "crypt32\CryptStringToBinary" (A_IsUnicode ? "W" : "A")

  DllCall( CryptStringToBinary, "ptr", &b64str, "UInt", 0, "Uint", 1, "Ptr", 0, "UInt*", outLen, "ptr", 0, "ptr", 0 )
  VarSetCapacity( outBuf, outLen, 0 )
  DllCall( CryptStringToBinary, "ptr", &b64str, "UInt", 0, "Uint", 1, "Ptr", &outBuf, "UInt*", outLen, "ptr", 0, "ptr", 0 )

  return outLen
}

b2a_hex( ByRef pbData, dwLen )
{
  if (dwLen < 1)
    return 0
  if pbData is integer
    ptr := pbData
  else
    ptr := &pbData
  SetFormat,integer,Hex
  loop,%dwLen%
  {
    num := numget(ptr+0,A_index-1,"UChar")
    hash .= substr((num >> 4),0) . substr((num & 0xf),0)
  }
  SetFormat,integer,D
  StringLower,hash,hash
  return hash
}

a2b_hex( sHash,ByRef ByteBuf )
{
  if (sHash == "" || RegExMatch(sHash,"[^\dABCDEFabcdef]") || mod(StrLen(sHash),2))
    return 0
  BufLen := StrLen(sHash)/2
  VarSetCapacity(ByteBuf,BufLen,0)
  loop,%BufLen%
  {
    num1 := (p := "0x" . SubStr(sHash,(A_Index-1)*2+1,1)) << 4
    num2 := "0x" . SubStr(sHash,(A_Index-1)*2+2,1)
    num := num1 | num2
    NumPut(num,ByteBuf,A_Index-1,"UChar")
  }
  return BufLen
}

Free(byRef var)
{
  VarSetCapacity(var,0)
  return
}
