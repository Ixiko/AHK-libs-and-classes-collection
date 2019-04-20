objParam := { "btSubmit": "Upload It!"
            , "adult": "no"
            , "mode": "local"
            , "forumurl": "http://postimage.org/"
            , "upload[]": ["2.png", "1.png"]
            , "um": "computer"
            , "MAX_FILE_SIZE": 16777216
            , "optsize": 0 }
CreateFormData(postData, hdr_ContentType, objParam)

whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
whr.Open("POST", "http://postimage.org/", true)
whr.SetRequestHeader("Content-Type", hdr_ContentType)
whr.SetRequestHeader("Referer", "http://postimage.org/")
whr.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko")
whr.Option(6) := False ; No auto redirect
whr.Send(postData)
whr.WaitForResponse()
Run, % whr.GetResponseHeader("Location")
return