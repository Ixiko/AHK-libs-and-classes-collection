; Link:   	https://www.autohotkey.com/boards/viewtopic.php?p=21986#p21986
; Author:	Bruttosozialprodukt
; Date:   	2014-07-22
; for:     	AHK_L


HtmlUpload(url,FileNames,AddCDParams:="",AddHeaders:="") {
    static MimeType := {jpg:"image/jpeg",jpeg:"image/jpeg",png:"image/png",bmp:"image/bmp",gif:"image/gif"}
    boundary := RandomString(16)
    Files := Object()
    bodySize := 0
    Loop % FileNames.MaxIndex() {
        filePath := FileNames[A_Index]
        SplitPath, filePath, fileName,, fileExt
        buffer := "--" . boundary . "`r`n"
        buffer .= "Content-Disposition: form-data; name=""file_" . A_Index-1 . """; filename=""" . fileName . """`r`n"
        buffer .= "Content-Type: " . MimeType[fileExt] . "`r`n`r`n"
        buffer .= "`r`n"
        bodySize += StrLen(buffer)
        Files[A_Index] := FileOpen(filePath, "r")
        bodySize += Files[A_Index].Length
    }
    buffer := "--" . boundary

    For cdKey, cdValue in AddCDParams
    {
        buffer .=  "`r`nContent-Disposition: form-data; name=""" . cdKey . """`r`n`r`n"
        buffer .= cdValue . "`r`n"
        buffer .= "--" . boundary
    }
    buffer .= "--"
    bodySize += StrLen(buffer)
    VarSetCapacity(body,bodySize)
    currentPos := 0
    Loop % FileNames.MaxIndex() {
        filePath := FileNames[A_Index]
        SplitPath, filePath, fileName,, fileExt
        VarSetCapacity(buffer,0)
        buffer := "--" . boundary . "`r`n"
        buffer .= "Content-Disposition: form-data; name=""file_" . A_Index-1 . """; filename=""" . fileName . """`r`n"
        buffer .= "Content-Type: " . MimeType[fileExt] . "`r`n`r`n"
        bufferSize := StrLen(buffer)
        StrPut(buffer, &body+currentPos, bufferSize, "CP0")
        currentPos += bufferSize

        bufferSize := VarSetCapacity(buffer,Files[A_Index].Length)
        Files[A_Index].RawRead(&buffer, bufferSize)
        DllCall("RtlMoveMemory", "Ptr", &body+currentPos, "Ptr", &buffer, "UInt", bufferSize)
        currentPos += bufferSize

        VarSetCapacity(buffer,0)
        buffer :=  "`r`n"
        bufferSize := StrLen(buffer)
        StrPut(buffer, &body+currentPos, bufferSize, "CP0")
        currentPos += bufferSize
    }
    buffer := "--" . boundary

    For cdKey, cdValue in AddCDParams
    {
        buffer .=  "`r`nContent-Disposition: form-data; name=""" . cdKey . """`r`n`r`n"
        buffer .= cdValue . "`r`n"
        buffer .= "--" . boundary
    }
    buffer .= "--"
    bufferSize := StrLen(buffer)
    StrPut(buffer, &body+currentPos, bufferSize, "CP0")
    currentPos += bufferSize

    If (!IsObject(headers))
        headers := Object()
    headers["Content-Type"] := "multipart/form-data; boundary=" . boundary
    headers["Content-Length"] := bodySize

    Return HttpRequest(url,"POST",headers,body)
}

RandomString(length,chars:="") {
    If (chars = "")
        chars := "0123456789abcdefghijklmnopqrstuvwxyz"
    charsCount := StrLen(chars)
    Loop %length% {
        Random, num, 1, % StrLen(chars)
        string .= SubStr(chars,num,1)
    }
    Return string
}