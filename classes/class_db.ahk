class db {

    ; meta
    
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
    
    ; public
    
    listKeys(){
        keyList:=[]
        this.file.seek(3,0)
        while(!this.file.atEOF){
            this.file.seek(dataLen,1)
            varSetCapacity(keyStr,4,0)
            varSetCapacity(keyLen,4,0)
            offset:=this.file.pos
            keyLen:=this.file.readUInt() ; read key len
            dataLen:=this.file.readUInt() ; read data len
            this.file.rawRead(keyStr,keyLen) ; read key
            varSetCapacity(keyStr,-1)
            if(keyStr)
                keyList.push(keyStr)
        }
        return keyList
    }
    
    get(key){
        varSetCapacity(keyLen,4,0)
        varSetCapacity(dataLen,4,0)
        offset:=this._findKey(key)
        if(offset=-1)
            return
        this.file.seek(offset,0)
        keyLen:=this.file.readUInt()
        dataLen:=this.file.readUInt()
        varSetCapacity(dataStr,dataLen,0)
        this.file.seek(keyLen,1)
        this.file.rawRead(dataStr,dataLen)
        varSetCapacity(dataStr,-1)
        this.b64d(nStr,dataStr)
        return nStr
    }
    
    put(key,str,overwrite:=0){
        if(this._findKey(key) != "-1"){ ; check for/replace existing entry
            if(overwrite)
                this.remove(key)
            else
                return -1
        }
        varSetCapacity(dataStr,4,0)
        this.b64e(nStr,str)
        this.file.seek(0,2)
        this.file.writeUInt(strLen(key)*2) ; key len
        this.file.writeUInt(strLen(nStr)*2) ; data len
        this.file.rawWrite(key,strLen(key)*2) ; key
        this.file.rawWrite(nStr,strLen(nStr)*2) ; data
    }
    
    remove(key){
        tFile:=fileOpen(tFilePath:=a_temp . "\" . a_tickCount,"w -rwd","UTF-8")
        this.file.seek(3,0)
        tFile.seek(3,0)
        
        while(!this.file.atEOF){
            varSetCapacity(keyStr,strLen(key)*2,0)
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
    
    ; private
    
    _findKey(key){
        this.file.seek(3,0)
        
        while(!this.file.atEOF && key!=keyStr){
            this.file.seek(dataLen,1)
            varSetCapacity(keyStr,strLen(key)*2,0)
            varSetCapacity(keyLen,4,0)
            varSetCapacity(dataLen,4,0)
            offset:=this.file.pos
            keyLen:=this.file.readUInt() ; read key len
            dataLen:=this.file.readUInt() ; read data len
            this.file.rawRead(keyStr,keyLen) ; read key
            varSetCapacity(keyStr,-1)
        }
        return key=keyStr?offset:-1
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
