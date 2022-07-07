#include Socket.ahk
#Include Buffer.ahk
#Include EventEmitter.ahk
#Include URI.ahk

class HTTPClient extends SocketTCP
{
    __New(IP, Port, OnResponse) {
        SocketTCP.__New.Call(this)

        this.OnResponse := OnResponse

        this.Connect([IP, Port])
    }

    SendRequest(Request) {
        this.SendText(Request.Generate())
    }

    PendingResponse := false

    OnRecv() {
        ResponseSize := this.MsgSize()
        ResponseText := this.RecvText()

        if (IsObject(this.PendingResponse) && !this.PendingResponse.Done) {
            ; Get data and append it to the existing response body

            Response := this.PendingResponse

            Response.BytesLeft -= ResponseSize
            Response.Body .= ResponseText
        } 
        else {
            ; Parse new response

            Response := new HTTPResponse(ResponseText)

            TotalSize := Response.Headers["Content-Length"] + 0
            Response.BytesLeft := TotalSize
            
            if (Response.Body) {
                Response.BytesLeft -= StrPut(Response.Body, "UTF-8") ; Response.BytesLeft -= SizeOf(Response.Body.Encode('UTF-8'))
            }
        }

        if (Response.BytesLeft <= 0) {
            Response.Done := true
            this.OnResponse(Response)
        }
        else {
            this.PendingResponse := Response
        }
    }
}

class HTTPRequest
{
    __new(method := "GET", url := "/", headers := "")
    {
        if(headers == "")
        {
            headers := {}
        }
        this.method := method
        this.headers := headers
        this.url := url
        this.protocol := "HTTP/1.1"
    }
    
    Generate()
    {
        body := this.method . " " . this.url . " " . this.protocol . "`r`n"
        
        for key, value in this.headers {
            StringReplace,value,value,`n,,A
            StringReplace,value,value,`r,,A
            body .= key . ": " . value . "`r`n"
        }
        body .= "`r`n"
        
        return body
    }
}

class HTTPResponse
{
    __new(data)
    {
        if (data)
        this.Parse(data)
    }
    
    GetPathInfo(top)
    {
        results := []
        while (pos := InStr(top, " ")) {
            results.Insert(SubStr(top, 1, pos - 1))
            top := SubStr(top, pos + 1)
        }
        this.method := results[1]
        this.statuscode := Uri.Decode(results[2])
        this.protocol := top
    }
    
    Parse(data) {
        this.raw := data
        data := StrSplit(data, "`n`r")
        headers := StrSplit(data[1], "`n")
        this.body := LTrim(data[2], "`n")
        this.GetPathInfo(headers.Remove(1))
        this.headers := {}
        
        for i, line in headers {
            pos := InStr(line, ":")
            key := SubStr(line, 1, pos - 1)
            val := Trim(SubStr(line, pos + 1), "`n`r ")
            
            this.headers[key] := val
        }
    }
}