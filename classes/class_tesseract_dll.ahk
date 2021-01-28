class tesseract {
    
    __new(perfix, lang, tessdll="", leptdll=""){
        this.api := 0
        this.perfix := perfix
        this.lang := lang
        this.tessdll := FileExist(tessdll) ? tessdll : "tesseract50.dll"
        this.leptdll := FileExist(leptdll) ? leptdll : "leptonica1780.dll"
        this.tesshandle := DllCall("LoadLibrary", "Str", this.tessdll, "Ptr")
        this.lepthandle := DllCall("LoadLibrary", "Str", this.leptdll, "Ptr")
    }

    __Delete() {
        dllcall("FreeLibrary", "Ptr", this.tesshandle)
        dllcall("FreeLibrary", "Ptr", this.lepthandle)
    }


    GetTextFromFile(file) {
        return this.GetTextFromPix(this.pixRead(file))
    }

    GetTextFromPix(pix) {
        api := this.APICreate()
        this.APIInit3(api, this.perfix, this.lang)
        this.APISetImage2(api, pix)
        ges := this.APIGetUTF8Text(api)
        this.APIDelete(api)
        return ges
    }

    version() {
        rc := dllcall(this.tessdll "\TessVersion", "Cdecl Ptr")
        return StrGet(rc, "UTF-8")
    }

    APICreate() {
        api := dllcall(this.tessdll "\TessBaseAPICreate", "Cdecl Ptr")
        return api
    }

    APIInit3(api, perfix, lang) {
        this.StrToUTF8(lang, lang_utf8)
        this.StrToUTF8(perfix, perfix_utf8)
        rc := dllcall(this.tessdll "\TessBaseAPIInit3", "Ptr", api, "Ptr", &perfix_utf8, "Ptr", &lang_utf8, "Cdecl Int")
        if (not rc) {
            Exception("api initialization failure")
        }
        return rc
    }

    pixRead(pixfile) {
        this.StrToUTF8(pixfile, pixfile_utf8)
        pix := DllCall(this.leptdll "\pixRead", "Ptr", &pixfile_utf8, "CDecl Ptr")
        return pix
    }

    pixReadMem(buffer, size) {
        pix := DllCall(this.leptdll "\pixReadMem", "Ptr", buffer, "Int", size, "CDecl Ptr")
        return pix
    }

    APISetImage(api, imgfile) {
        width := 16
        height := 16
        file := FileOpen(imgfile, "r")
        length := file.rawRead(pix, 317)
        file.close()

        msgbox % VarSetCapacity(pix, length)

        si := dllcall(this.tessdll "\TessBaseAPISetImage", "Ptr", api, "Ptr", &pix, "Int", width, "Int", height, "Int", 3, "Int", width * 3, "CDecl Ptr")
        msgbox % si "`n" errorlevel
    }

    APISetImage2(api, pix) {
        si := dllcall(this.tessdll "\TessBaseAPISetImage2", "Ptr", api, "Ptr", pix, "CDecl")
        return si
    }

    APIGetUTF8Text(api) {
       ptr := dllcall(this.tessdll "\TessBaseAPIGetUTF8Text", "Ptr", api, "Cdecl Ptr")
       text := StrGet(ptr, "utf-8")
       return text
    }

    APIDelete(api) {
        api_delete := dllcall(this.tessdll "\TessBaseAPIDelete", "Ptr", api)
        return api_delete
    }

    StrToUTF8(Str, ByRef UTF8) {
        VarSetCapacity(UTF8, StrPut(Str, "UTF-8"), 0)
        StrPut(Str, &UTF8, "UTF-8")
        Return &UTF8
    }

    UTF8ToStr(UTF8) {
        Return StrGet(UTF8, "UTF-8")
    }
}