#include Crypto.ahk
#include WSDataFrame.ahk
#Include Buffer.ahk
#Include EventEmitter.ahk
#Include HTTPClient.ahk


createHandshakeKey()
{
    VarSetCapacity(CSPHandle, 8, 0)
    VarSetCapacity(RandomBuffer, 16, 0)
    DllCall("advapi32.dll\CryptAcquireContextA", "Ptr", &CSPHandle, "UInt", 0, "UInt", 0, "UInt", PROV_RSA_AES := 0x00000018,"UInt", CRYPT_VERIFYCONTEXT := 0xF0000000)
    DllCall("advapi32.dll\CryptGenRandom", "Ptr", NumGet(&CSPHandle, 0, "UInt64"), "UInt", 16, "Ptr", &RandomBuffer)
    DllCall("advapi32.dll\CryptReleaseContext", "Ptr", NumGet(&CSPHandle, 0, "UInt64"), "UInt", 0)
    
    return Base64_encode(&RandomBuffer, 16)
}

sec_websocket_accept(key)
{
    key := key . "258EAFA5-E914-47DA-95CA-C5AB0DC85B11" ; Chosen by fair dice roll. Guaranteed to be random.
    sha1 := sha1_encode(key)
    pbHash := sha1[1]
    cbHash := sha1[2]
    b64 := Base64_encode(&pbHash, cbHash)
    return b64
}


class WSClient extends SocketTCP
{
    OnRecv()
    {   
        DataSize := this.MsgSize()
        VarSetCapacity(Data, DataSize)

        this.Recv(Data, DataSize)

        this.OnRequest.Call(new WSRequest(&Data, DataSize))

        return
    }

    SendFrame(Opcode, pMessageBuffer := 0, MessageSize := 0) {
        Response := new WSResponse(Opcode, pMessageBuffer, MessageSize)
        ResponseBuffer := Response.Encode()

        this.Send(ResponseBuffer.GetPointer(), ResponseBuffer.Length)
    }

    SendText(Message) {
        MessageSize := StrPut(Message, "UTF-8") - 1
        VarSetCapacity(MessageBuffer, MessageSize)
        StrPut(Message, &MessageBuffer, MessageSize, "UTF-8")

        this.SendFrame(WSOpcodes.Text, &MessageBuffer, MessageSize)
    }
}
