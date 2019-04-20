#include <AHK_CNG_hashObj>
;#include <AHK_CNG_cryptObj>
#include <crypt>

class pinAuth {
    
    setPath:=a_appData . "\..\Local\PIN\strs.pin"
    
    
    __new(filePath:=""){
        if(filePath)
            this.setPath:=filePath
        splitPath,% this.setPath,,sDir
        if(!fileExist(sDir))
            fileCreateDir,% sDir
        this.file:=fileOpen(this.setPath,"rw -rwd","UTF-8")
        return this
    }
    
    __delete(){
        this.file.close()
    }
    
    setPin(pin){
        if(!pin)
            this.key:="",this.kkey:=""
        else
            this._genTempKey(bcrypt.pbkdf2(pin,bcrypt.hash(pin,"MD5"),"SHA512",this._getIterations(pin),500))
    }
    
    setStr(key,str){
        this.b64e(nStr,clipboard:=this._encryptStr(str))
        this._write(key,nStr)
    }
    
    getStr(key){
        str:=this._get(key)
        if(!str){
            errorlevel:="String not found."
            return
        }
        this.b64d(nStr,str)
        return this._decryptStr(nStr)
    }
    
    listKeys(){
        keyList:=[]
        this.file.seek(3,0)
        while(!this.file.atEOF){
            this.file.seek(dataLen,1)
            varSetCapacity(keyStr,4,0)
            offset:=this.file.pos
            keyLen:=this.file.readUInt() ; read key len
            dataLen:=this.file.readUInt() ; read data len
            this.file.rawRead(keyStr,keyLen) ; read key\
            varSetCapacity(keyStr,-1)
            if(keyStr)
                keyList.push(keyStr)
        }
        return keyList
    }
    
    removeStr(key){
        tFile:=fileOpen(tFilePath:=a_temp . "\" . a_tickCount,"w -rwd","UTF-8")
        this.file.seek(3,0)
        tFile.seek(3,0)
        
        while(!this.file.atEOF){
            varSetCapacity(keyStr,4,0)
            varSetCapacity(dataLen,4,0)

            keyLen:=this.file.readUInt()
            dataLen:=this.file.readUInt()
            this.file.rawRead(keyStr,keyLen)
            varSetCapacity(keyStr,-1)
            varSetCapacity(dataLen,-1)

            if(key=keyStr){
                this.file.seek(dataLen,1)
                continue
            }
            this.file.rawRead(dataStr,dataLen)
            ;tfile.rawWrite(keyLen . dataLen . keyStr . dataStr,keyLen + dataLen + 8)
            tFile.writeUInt(keyLen)
            tFile.writeUInt(dataLen)
            tFile.rawWrite(keyStr,keyLen)
            tFile.rawWrite(dataStr,dataLen)
        }
        tFile.seek(0)
        tFile.close()
        this.file.close()
        fileMove,% tFilePath,% this.setPath,1
        this.file:=fileOpen(this.setPath,"rw -rwd","UTF-8")
    }

    _write(key,str){
        this.file.seek(0,2)
        this.file.writeUInt(strLen(key)*2) ; key len
        this.file.writeUInt(strLen(str)*2) ; data len
        this.file.rawWrite(key,strLen(key)*2) ; key
        this.file.rawWrite(str,strLen(str)*2) ; data
    }

    _get(key){
        varSetCapacity(dataStr,4,0)
        offset:=this._findKey(file,key)
        if(offset=-1)
            return
        this.file.seek(offset,0)
        keyLen:=this.file.readUInt()
        dataLen:=this.file.readUInt()
        this.file.seek(keyLen,1)
        this.file.rawRead(dataStr,dataLen)
        return dataStr
    }
    
    _findKey(byRef file,key){
        this.file.seek(3,0)
        
        while(!this.file.atEOF && key!=keyStr){
            this.file.seek(dataLen,1)
            varSetCapacity(keyStr,4,0)
            offset:=this.file.pos
            keyLen:=this.file.readUInt() ; read key len
            dataLen:=this.file.readUInt() ; read data len
            this.file.rawRead(keyStr,keyLen) ; read key
            varSetCapacity(keyStr,-1)
        }
        return key=keyStr?offset:-1
    }    
    
    _encryptStr(str){
        ; BCrypt
        ;return bcrypt.encrypt(str,a_tickCount,this.key) . "_" . a_tickCount

        ; Crypt
        return crypt.Encrypt.StrEncrypt(str,this._decryptTempKey(),7,6)
    }
    
    _decryptStr(str){
        ; BCrypt
        ;str:=subStr(str,1,regexMatch(str,"_.*",iv))
        ;return bcrypt.decrypt(str,iv,this.key)
        
        ; Crypt
        return crypt.Encrypt.StrDecrypt(str,this._decryptTempKey(),7,6)
    }
    
    _getIterations(str){
        nStr:=0
        loop,parse,str
            nStr+=ord(a_loopField)
        return nStr
    }
    
    _genTempKey(str){
        this.key:=crypt.Encrypt.StrEncrypt(str,this.kkey:=bcrypt.hash(a_tickCount*a_now,"MD5"),7,6)
    }
    
    _decryptTempKey(){
        this._genTempKey(t:=crypt.Encrypt.StrDecrypt(this.key,this.kkey,7,6))
        return t
    }
    
    ; b64e, b64d by SKAN + modified by lifeweaver; strPutVar by lifeweaver; https://autohotkey.com/boards/viewtopic.php?p=49863#p49863
    b64e(byRef outData,byRef inData ){
      inDataLen:=this.strPutVar(inData,inData,"UTF-8") - 1
      dllCall("Crypt32.dll\CryptBinaryToStringW","UInt",&inData,"UInt",inDataLen,"UInt",1,"UInt",0,"UIntP",tChars,"CDECL Int")
      varSetCapacity(outData,req:=tChars * (a_isUnicode?2:1),0)
      dllCall("Crypt32.dll\CryptBinaryToStringW","UInt",&inData,"UInt",inDataLen,"UInt",1,"Str",outData,"UIntP",req,"CDECL Int")
      return tChars
    }
    b64d(byRef outData,byRef inData){
      dllCall("Crypt32.dll\CryptStringToBinaryW","UInt",&inData,"UInt",strLen(inData),"UInt",1,"UInt",0,"UIntP",bytes,"Int",0,"Int",0,"CDECL Int")
      varSetCapacity(outData,req:=bytes * (a_isUnicode?2:1),0)
      dllCall("Crypt32.dll\CryptStringToBinaryW","UInt",&inData,"UInt",strLen(inData),"UInt",1,"Str",outData,"UIntP",req,"Int",0,"Int",0,"CDECL Int")
      outData:=strGet(&outData,"cp0")
      return bytes
    }
    strPutVar(string,byRef var,encoding){
        varSetCapacity(var,strPut(string,encoding)
            * ((encoding="utf-16"||encoding="cp1200")?2:1))
        return strPut(string,&var,encoding)
    }
}