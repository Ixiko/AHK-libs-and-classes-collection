
#include %A_ScriptDir%\..\oh.ahk

f:=[]
f.url:="https://query.yahooapis.com/v1/public/yql?q=select`%20*`%20from`%20html`%20where`%20url`%3D'http`%3A`%2F`%2Fen.wikipedia.org`%2Fwiki`%2FYahoo'`%20and`%20xpath`%3D'`%2F`%2Ftable`%2F*`%5Bcontains(.`%2C`%22Founder`%22)`%5D`%2F`%2Fa'&format=json&env=store`%3A`%2F`%2Fdatatables.org`%2Falltableswithkeys"
f.json:=1
oh(f)
MsgBox % ObjTree(f.json)