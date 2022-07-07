/*
    this is where we hide the ugly code, Yeah it gets uglier...
    acording to the Websocket RFC: http://tools.ietf.org/html/rfc6455
    there's lots of bits that we need to scrub before we can get the message data
    according to ammount of data the message may be split in multiple data frames
    as well as change the format of the data frame
    
    
    Frame format:
    0               1               2               3               4    bytes
    0                   1                   2                   3
    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
    +-+-+-+-+-------+-+-------------+-------------------------------+
    |F|R|R|R| opcode|M| Payload len |    Extended payload length    |
    |I|S|S|S|  (4)  |A|     (7)     |             (16/64)           |
    |N|V|V|V|       |S|             |   (if payload len==126/127)   |
    | |1|2|3|       |K|             |                               |
    +-+-+-+-+-------+-+-------------+ - - - - - - - - - - - - - - - +
    |     Extended payload length continued, if payload len == 127  |
    + - - - - - - - - - - - - - - - +-------------------------------+
    |                               |Masking-key, if MASK set to 1  |
    +-------------------------------+-------------------------------+
    | Masking-key (continued)       |          Payload Data         |
    +-------------------------------- - - - - - - - - - - - - - - - +
    :                     Payload Data continued ...                :
    + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +
    |                     Payload Data continued ...                |
    +---------------------------------------------------------------+
    
    OpCodes: 
    0x8 Close
    0x9 Ping
    0xA Pong
    
    Payload data OpCodes:
    0x0 Continuation
    0x1 Text
    0x2 Binary
    
    
    
    references: 
    http://tools.ietf.org/html/rfc6455
    https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API/Writing_WebSocket_servers
    https://www.iana.org/assignments/websocket/websocket.xhtml
    
    implementation references:
    Lua: https://github.com/lipp/lua-websockets/blob/master/src/websocket/frame.lua
    Python: https://github.com/aaugustin/websockets/blob/main/src/websockets/frames.py
    JS: https://github.com/websockets/ws/blob/master/lib/receiver.js
    JS: https://github.com/websockets/ws/blob/master/lib/sender.js
    
    when reading this code, keep in mind:
    1 - there's no way to read binary in AHK, only bytes at a time (so there's lots of AND masking going on)
    2 - arrays start at 1
*/

OpCodes := {CONTINUATION:0x0,TEXT:0x1,BINARY:0x2,CLOSE:0x8,PING:0x9,PONG:0xA}

class WSOpcodes {
        static CONTINUATION := 0x0
        static TEXT := 0x1
        static BINARY := 0x2
        static CLOSE := 0x8
        static PING := 0x9
        static PONG := 0xA

        ToString(Value) {
            for Name, NameValue in WSOpcodes {
                if (Value = NameValue) {
                    return Name
                }
            }
        }
    }

/*
    MDN says: 
    "
    1. Read bits 9-15 (inclusive) and interpret that as an unsigned integer. If it's 125 or less, then that's the length; you're done. If it's 126, go to step 2. If it's 127, go to step 3.
    2. Read the next 16 bits and interpret those as an unsigned integer. You're done.
    3. Read the next 64 bits and interpret those as an unsigned integer. (The most significant bit must be 0.) You're done.
    "
    So unfortunatelly using NumGet UShort and UInt64 doesn't work...
*/
Uint16(a, b) {
    return a << 8 | b
}
Uint64(a, b, c, d) {
    return a << 24 | b << 16 | c << 8 | d    
}
Uint16ToUChar(c) {
    a := c >> 8
    b := c & 0xFF
    return [a, b]
}

Uint64ToUChar(e) {
    a := e >> 24
    b := e >> 16
    c := e >> 8
    d := c & 0xFF
    return [a, b, c, d]
}

class WSDataFrame{
    encode(message) {
        length := strlen(message)
        if(length < 125) {
            byteArr := [129, length]
            buf := new Buffer(length + 2)
            Loop, Parse, message
            byteArr.push(Asc(A_LoopField))
            VarSetCapacity(result, byteArr.Length())
            For, i, byte in byteArr
            NumPut(byte, result, A_Index - 1, "UInt")
            buf.Write(&result, length + 2)
        }
        return buf
    }
    
}

class WSRequest{
    __new(pData, DataLength){
        this.payload := []
        this.decode(pData, DataLength)
    }
    decode(pData, DataLength){
        this.parseHeader(pData, DataLength)
        this.getPayload(pData, DataLength, this.length)
    }
    parseHeader(pData, DataLength){
        byte1 := NumGet(pData + 0, "UChar")
        byte2 := NumGet(pData + 1, "UChar")
        
        byte3 := NumGet(pData + 2, "UChar")
        byte4 := NumGet(pData + 3, "UChar")
        byte5 := NumGet(pData + 4, "UChar")
        byte6 := NumGet(pData + 5, "UChar")
        
        this.fin := byte1 & 0x80 ? True : False
        
        this.rsv1 := byte1 & 0x40 ? True : False
        this.rsv2 := byte1 & 0x20 ? True : False
        this.rsv3 := byte1 & 0x10 ? True : False
        
        Opcode := this.opcode := byte1 & 0xF
        
        if (Opcode = 0x01) {
            this.datatype := "text"
        }
        else if (Opcode = 0x02) {
            this.datatype := "binary"
        }
        else if (Opcode = 0x8){
            this.datatype := "close"
        }
        else if (Opcode = 0x9){
            this.datatype := "ping"
        }
        else if (Opcode = 0xA){
            this.datatype := "pong"
        }
        
        this.mask := byte2 & 0x80 ? True : False ; indicates if the content is masked(XOR)
        
        this.length := byte2 & 0x7F

        if (this.length == 0x7E) {
            this.length := Uint16(byte3, byte4)

            if (this.mask) {
                this.key := this.getKey(pData, 4)
            }
        } 
        else if (this.length == 0x7F) {
            this.length := Uint64(byte3, byte4, byte5, byte6)

            if (this.mask) {
                this.key := this.getKey(pData, 6)
            }
        }
        else if (this.mask) {
            this.key := this.getKey(pData)
        }

        ; FIXME: This only works for very short frames

        HeaderSize := 2 + (this.mask * 4)

        this.pPayload := pData + HeaderSize
        this.PayloadSize := this.length
    }
    
    getKey(pData, index := 2){
        key := []
        key[1] := NumGet(pData + (index + 0), "UChar")
        key[2] := NumGet(pData + (index + 1), "UChar")
        key[3] := NumGet(pData + (index + 2), "UChar")
        key[4] := NumGet(pData + (index + 3), "UChar")
        return key
    }
    
    getPayload(pData, DataLength, length) {
        payloadIndex := DataLength - length

        loop %length% {
            byte := NumGet(pData + payloadIndex + A_Index - 1, "UChar")
            this.payload.push(byte)
        }
        
        if(this.mask){
            this.payload := XOR(this.payload, this.key)
        }        
    }
    
    getMessage() {
        if (this.datatype == "text" || this.datatype == "ping") {
            message := ""

            for _, byte in this.payload {
                message .= chr(byte)
            }

            return message
        }

        return this.payload
    }
}
class WSResponse {
    __new(opcode := 0x01, pMessage := "", length := 0, fin := True){
        this.opcode := opcode
        this.fin := fin
        this.pMessage := pMessage
        this.length := length
    }
    
    encode() {
        byte1 := (this.fin? 0x80 : 0x00) | this.opcode
        
        if(this.length < 127) {
            byteArr := [byte1, this.length]
        
        } else if(this.length <= 65535) {
            lengthBytes := Uint16ToUChar(this.length)
            byteArr := [byte1, 0x7E, lengthBytes[1], lengthBytes[2]]
        
        } else if(this.length < 2 ^ 53) {
            lengthBytes := Uint64ToUChar(this.length)
            byteArr := [byte1, 0x7F, lengthBytes[1], lengthBytes[2], lengthBytes[3], lengthBytes[4]]
            
        }
        
        byteArr[2] |= 0x80 ; Set MASK bit

        length := this.length + byteArr.Length() + 4
        buf := new Buffer(length)

        VarSetCapacity(result, byteArr.Length())
        for i, byte in byteArr {
            NumPut(byte, result, A_Index - 1, "UInt")
        }
        buf.Write(&result, byteArr.Length())

        VarSetCapacity(TempMask, 4, 0)
        NumPut(TempMask, 0, "UInt")

        buf.Write(&TempMask, 4)
        buf.Write(this.pMessage, this.length)

        return buf
    }
    
}

#Include Buffer.ahk