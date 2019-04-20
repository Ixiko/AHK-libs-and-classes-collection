#include <AHK_CNG_hashObj>
;#include <AHK_CNG_cryptObj>
#include <crypt>

class pinAuth {
    setPath:=(setDir:=a_appData . "\..\Local\PIN") . "\strs.ini"
    
    __new(dir:="",iniName:=""){
        if(dir)
            this.setDir:=dir
        if(!fileExist(this.setDir))
            fileCreateDir,% this.setDir

        if(iniName){
            if(subStr(iniName,-3)!=".ini")
                iniName.=".ini"
            this.setPath:=this.setDir . "\" . iniName
        }
        return this
    }
    
    setPin(pin){
        if(!pin)
            this.key:="",this.kkey:=""
        else
            this._genTempKey(bcrypt.pbkdf2(pin,bcrypt.hash(pin,"MD5"),"SHA512",this._getIterations(pin),500))
    }
    
    setStr(str,key,header:="Default"){
        if(!this.key){
            msgbox,,PIN,No PIN has been set.
            return 1
        }
        return this._saveStr(this._encryptStr(str),key,header)
    }
    
    getStr(key,header:="Default"){
        rStr:=this._getStr(key,header)
        if(rStr=="ERROR"){
            msgbox,,PIN,Requested string not found.
            return 1
        }
        return this._decryptStr(rStr)
    }
    
    removeStr(key,header:="Default"){
        if(key)
            iniDelete,% this.setPath,% header,% key
        else
            iniDelete,% this.setPath,% header
        return errorlevel
    }
    
    _getStr(key,header){
        iniRead,str,% this.setPath,% header,% key
        return str
    }
    
    _saveStr(str,key,header){
        iniWrite,% str,% this.setPath,% header,% key
        return errorlevel
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
}