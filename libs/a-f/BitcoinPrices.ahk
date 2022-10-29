endpoint := "http://api.bitcoincharts.com/v1/trades.csv"
market := "bitfinex"
currency := "USD"

Url := endpoint . "?symbol=" . market . currency
req := ComObjCreate("Msxml2.XMLHTTP")
; Open a request with async enabled.
req.open("GET", Url, true)
; Set our callback function (v1.1.17+).
req.onreadystatechange := Func("Ready")
; Send the request.  Ready() will be called when it's complete.
req.send()
#Persistent

Ready() {
    global req
    if (req.readyState != 4)  ; Not done yet.
        return
    if (req.status == 200 || req.status == 304) { ; OK.
        values := req.responseText
        For Each, Value in StrSplit(values, ",") {
            if (A_index = 2) {
                MsgBox % "Current Bitcoin price in USD: " Round(value, 2)
                ExitApp
            }
        }
    }
    else
        MsgBox 16,, % "Status " req.status
    
    ExitApp
} 

GetUnixTime() {
UnixTime := A_NowUTC
EnvSub, UnixTime, 1970, seconds
Return UnixTime
}