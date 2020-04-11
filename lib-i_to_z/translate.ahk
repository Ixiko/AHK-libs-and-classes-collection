GoogleTranslate(str, from := "auto", to := 0) {
    ret := Array(str, "Unknown Error", "")
    static JS := GetJScripObject(), _ := JS.( GetJScript() ) := JS.("delete ActiveXObject; delete GetObject;")
    if(!to){
        to := GetISOLanguageCode()	; Assign the system (OS) language to "to"
    }

    if(from = to) {
        ret.InsertAt(2, "Target language matches source language")
        Return ret
    }

    request := SendRequest(JS, str, from, to, proxy := "")
    response := request[1]
    url := request[2]
    json := response.responsetext
    if(!json) {
        ret.InsertAt(2, response.status . ": " . response.statustext)
        ret.InsertAt(3, url)
        Return ret				; Return the original, untranslated string
    }
    if(InStr(json, "document.getElementById('captcha-form')")){
        ret.InsertAt(2, "Spam detected")
        ret.InsertAt(3, url)
        Return ret
    }
    oJSON := JS.("(" . json . ")")
    trans:=""
    if !IsObject(oJSON[1])  {
      Loop % oJSON[0].length
         trans .= oJSON[0][A_Index - 1][0]
    }
    else  {
      MainTransText := oJSON[0][0][0]
      trans:=""
      Loop % oJSON[1].length  {
         trans .= "`n+"
         obj := oJSON[1][A_Index-1][1]
         Loop % obj.length  {
            txt := obj[A_Index - 1]
            trans .= (MainTransText = txt ? "" : "`n" txt)
         }
      }
    }
    if(!IsObject(oJSON[1])){
      MainTransText := trans := Trim(trans, ",+`n ")
    } else {
      trans := MainTransText . "`n+`n" . Trim(trans, ",+`n ")
    }
    ; from := oJSON[2]
    trans := Trim(trans, ",+`n ")
   
    ret.InsertAt(1, trans)
    ret.InsertAt(2, "Success")
    ret.InsertAt(3, url)
    Return ret
}

SendRequest(JS, str, from_lang, to_lang, proxy) {
    url := "https translate.google.com /translate_a/single?client=webapp"  Broken Link for safety
      . "&sl=" . from_lang . "&tl=" . to_lang . "&hl=" . to_lang . "&tk=" . JS.("tk").(str) . "&q=" . URIEncode(str)
      . "&dt=at&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&dt=gt&ie=UTF-8&oe=UTF-8&otf=1&ssel=0&tsel=0&kc=1"
    ComObjError(false)
    http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    ; http.SetProxy(2, proxy)
    http.open( "GET", url, 1 )
    ; http.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded;charset=utf-8")
    http.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:69.0) Gecko/20100101 Firefox/69.0")
    http.SetRequestHeader("Host", "translate.google.com")
    http.SetRequestHeader("Referer", "https translate.google.com /")  Broken Link for safety
    http.send() ; "q=" . URIEncode(str))
    http.WaitForResponse(-1)
    Return Array(http,url)
}

URIEncode(str, encoding := "UTF-8") {
    VarSetCapacity(var, StrPut(str, encoding))
    StrPut(str, &var, encoding)
    urlstr:=""
    While code := NumGet(Var, A_Index - 1, "UChar")  {
        bool := (code > 0x7F || code < 0x30 || code = 0x3D)
        UrlStr .= bool ? "%" . Format("{:02X}", code) : Chr(code)
    }
    Return UrlStr
}

GetJScript() {
    script =
    (
      var TKK = ((function() {
        var a = 561666268;
        var b = 1526272306;
        return 406398 + '.' + (a + b);
      })());
      function b(a, b) {
        for (var d = 0; d < b.length - 2; d += 3) {
            var c = b.charAt(d + 2),
                c = "a" <= c ? c.charCodeAt(0) - 87 : Number(c),
                c = "+" == b.charAt(d + 1) ? a >>> c : a << c;
            a = "+" == b.charAt(d) ? a + c & 4294967295 : a ^ c
        }
        return a
      }
      function tk(a) {
          for (var e = TKK.split("."), h = Number(e[0]) || 0, g = [], d = 0, f = 0; f < a.length; f++) {
              var c = a.charCodeAt(f);
              128 > c ? g[d++] = c : (2048 > c ? g[d++] = c >> 6 | 192 : (55296 == (c & 64512) && f + 1 < a.length && 56320 == (a.charCodeAt(f + 1) & 64512) ?
              (c = 65536 + ((c & 1023) << 10) + (a.charCodeAt(++f) & 1023), g[d++] = c >> 18 | 240,
              g[d++] = c >> 12 & 63 | 128) : g[d++] = c >> 12 | 224, g[d++] = c >> 6 & 63 | 128), g[d++] = c & 63 | 128)
          }
          a = h;
          for (d = 0; d < g.length; d++) a += g[d], a = b(a, "+-a^+6");
          a = b(a, "+-3^+b+-f");
          a ^= Number(e[1]) || 0;
          0 > a && (a = (a & 2147483647) + 2147483648);
          a `%= 1E6;
          return a.toString() + "." + (a ^ h)
      }
    )
    Return script
}

GetJScripObject()  {
    static doc
    doc := ComObjCreate("htmlfile")
    doc.write("<meta http-equiv='X-UA-Compatible' content='IE=9'>")
    Return ObjBindMethod(doc.parentWindow, "eval")
}

GetISOLanguageCode(lang := 0) {
   LanguageCodeArray := { 0436: "af", 041c: "sq", 0401: "ar", 0801: "ar", 0c01: "ar", 1001: "ar", 1401: "ar", 1801: "ar", 1c01: "ar", 2001: "ar", 2401: "ar", 2801: "ar", 2c01: "ar", 3001: "ar", 3401: "ar", 3801: "ar", 3c01: "ar", 042c: "az", 082c: "az", 042d: "eu", 0423: "be", 0402: "bg", 0403: "ca", 0404: "zh-CN", 0804: "zh-CN", 0c04: "zh-CN", 1004: "zh-CN", 1404: "zh-CN", 041a: "hr", 0405: "cs", 0406: "da", 0413: "nl", 0813: "nl", 0409: "en", 0809: "en", 0c09: "en", 1009: "en", 1409: "en", 1809: "en", 1c09: "en", 2009: "en", 2409: "en", 2809: "en", 2c09: "en", 3009: "en", 3409: "en", 0425: "et", 040b: "fi", 040c: "fr", 080c: "fr", 0c0c: "fr", 100c: "fr", 140c: "fr", 180c: "fr", 0437: "ka", 0407: "de", 0807: "de", 0c07: "de", 1007: "de", 1407: "de", 0408: "el", 040d: "iw", 0439: "hi", 040e: "hu", 040f: "is", 0421: "id", 0410: "it", 0810: "it", 0411: "ja", 0412: "ko", 0426: "lv", 0427: "lt", 042f: "mk", 043e: "ms", 083e: "ms", 0414: "no", 0814: "no", 0415: "pl", 0416: "pt", 0816: "pt", 0418: "ro", 0419: "ru", 081a: "sr", 0c1a: "sr", 041b: "sk", 0424: "sl", 040a: "es", 080a: "es", 0c0a: "es", 100a: "es", 140a: "es", 180a: "es", 1c0a: "es", 200a: "es", 240a: "es", 280a: "es", 2c0a: "es", 300a: "es", 340a: "es", 380a: "es", 3c0a: "es", 400a: "es", 440a: "es", 480a: "es", 4c0a: "es", 500a: "es", 0441: "sw", 041d: "sv", 081d: "sv", 0449: "ta", 041e: "th", 041f: "tr", 0422: "uk", 0420: "ur", 042a: "vi" }
   if(lang) {
       return LanguageCodeArray[lang]
   } else {
    return LanguageCodeArray[A_Language]
   }
}