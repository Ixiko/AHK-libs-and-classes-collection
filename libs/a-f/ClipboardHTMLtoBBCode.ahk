; Converts HTML content on the Clipboard to BBCode for ahkscript.org
; Requires AutoHotkey v1.1
; Produces best results when copying from Internet Explorer

if html := GetClipboardHTMLFragment()
    Clipboard := ConvertHTMLFragmentToBBCode(html)

ConvertHTMLFragmentToBBCode(html)
{
    repl := [[
    (Join],[
        "<STRONG>(.*?)</STRONG>"                , "[b]$1[/b]"
        "<CODE.*?>(.*?)</CODE>"                 , "[c]$1[/c]"
        "<EM>(.*?)</EM>"                        , "[i]$1[/i]"
        "<BR.*?>"                               , "`n"
        "<A\s.*?href=""(.*?)"".*?>(.*?)</A>"    , "[url=$1]$2[/url]"
        "<UL.*?>(.*?)</UL>"                     , "[list]$1[/list]`n"
        "<LI.*?>(.*?)</LI>"                     , "`n[*]$1"
        "<SPAN.*?size: (\d+)%;"">(.*?)</SPAN>"  , "[size=$1]$2[/size]"
    )]]
    for i, r in repl
        html := RegExReplace(html, "i)" r[1], r[2])
    
    ; For debugging missed elements, comment out the following line:
    html := RegExReplace(html, "<.*?>")
    
    return html
}

GetClipboardHTMLFragment()
{
    if !DllCall("OpenClipboard", "ptr", 0)
        return
    if hdata := DllCall("GetClipboardData", "uint", DllCall("RegisterClipboardFormat", "str", "HTML Format"), "ptr")
    {
        size := DllCall("GlobalSize", "ptr", hdata)
        if pdata := DllCall("GlobalLock", "ptr", hdata, "ptr")
        {
            data := StrGet(pdata, size, "utf-8")
            if RegExMatch(data, "Os)<!--StartFragment-->\K.*(?=<!--EndFragment-->)", m)
            {
                html := m.Value
            }
            DllCall("GlobalUnlock", "ptr", hdata)
        }
    }
    DllCall("CloseClipboard")
    return html
}