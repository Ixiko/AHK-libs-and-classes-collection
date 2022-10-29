#Persistent
#SingleInstance, force
SetBatchLines, -1

paths := {}
paths["/"] := Func("HelloWorld")
paths["404"] := Func("NotFound")
paths["/logo"] := Func("Logo")

server := new HttpServer()
server.LoadMimes(A_ScriptDir . "/mime.types")
server.SetPaths(paths)
server.Serve(8000)
return

Logo(ByRef req, ByRef res, ByRef server) {
    server.ServeFile(res, A_ScriptDir . "/logo.png")
    res.status := 200
}

NotFound(ByRef req, ByRef res) {
    res.SetBodyText("Page not found")
}

HelloWorld(ByRef req, ByRef res) {
    res.SetBodyText("Hello World")
    res.status := 200
}

#include, %A_ScriptDir%\AHKhttp.ahk
#include <AHKsock>
