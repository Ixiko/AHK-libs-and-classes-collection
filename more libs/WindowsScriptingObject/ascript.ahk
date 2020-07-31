#Include ActiveScript.ahk

FileRead, code, littledoc.js

script := new ActiveScript("Jscript")

script.Exec(code)