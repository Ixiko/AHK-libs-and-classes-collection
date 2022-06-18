/*
sJson = ["value to delete", null, false, {"key1": 5, "key2": true, "key3": "string"}]

str := ""
for k, v in JSONcom.Enum(sJson)
   str .= "key: " k "`nvalue: " v "`n`n"
MsgBox, % "for k, v in JSON.Enum(sJson)`n`n" str


str := ""
for k, v in JSONcom.Enum(sJson)
   for k, v in JSONcom.Enum(v)
      str .= "key: " k "`nvalue: " v "`n`n"
MsgBox, % "for k, v in JSON.Enum(sJson)`n"
				. "  for k, v in JSON.Enum(v)`n`n" str

MsgBox, % "JSON after JSON.RemoveKey(sJson, ""[0]"") is:`n`n" JSONcom.RemoveKey(sJson, "[0]")

sJson = [null, false, {"key1": 5, "key2": true, "key3": "string"}, {"key1": 0, "key2": false, "key3": "AHK"}]

str := ""
for k, v in JSONcom.Enum(sJson)
   str .= "key: " k "`nvalue: " v "`n`n"
MsgBox, % "for k, v in JSON.Enum(sJson)`n`n" str

str := ""
for k, v in JSONcom.Enum(sJson)
   for k, v in JSONcom.Enum(v)
      str .= "key: " k "`nvalue: " v "`n`n"
MsgBox, % "for k, v in JSON.Enum(sJson)`n"
				. "  for k, v in JSON.Enum(v)`n`n" str
   
str := ""
for k, v in JSONcom.Enum(sJson, "[3]")
	str .= "key: " k "`nvalue: " v "`n`n"
MsgBox, % "for k, v in JSON.Enum(sJson, ""[3]"")`n`n" str

*/

; https://www.autohotkey.com/boards/viewtopic.php?p=282197#p282197

class JSONcom
{
   static JS := JSONcom._GetJScriptObject()
   
   Parse(sJson, js := false)  {
      if jsObj := this.VerifyJson(sJson)
         Return js ? jsObj : this._CreateObject(jsObj)
   }
   
   Stringify(obj, js := false) {
      if js
         Return this.JS.JSON.stringify(obj)
      else {
         sObj := this._ObjToString(obj)
         Return this.JS.eval("JSON.stringify(" . sObj . ")")
      }
   }
   
   GetKey(sJson, key) {
      if !this.VerifyJson(sJson)
         Return
      
      try res := this.JS.eval("JSON.stringify((" . sJson . ")" . (SubStr(key, 1, 1) = "[" ? "" : ".") . key . ")")
      catch {
         MsgBox, Wrong key:`n`n%key%
         Return
      }
      Return res
   }
   
   SetKey(sJson, key, value) {
      if !(this.VerifyJson(sJson) && this.VerifyJson(value))
         Return
      
      res := this.JS.eval( "var obj = (" . sJson . ");"
                         . "obj" . (SubStr(key, 1, 1) = "[" ? "" : ".") . key . "=" . value . ";"
                         . "JSON.stringify(obj)" )
      this.JS.eval("obj = ''")
      Return res
   }
   
   RemoveKey(sJson, key) {
      if !this.VerifyJson(sJson)
         Return
      
      sign := SubStr(key, 1, 1) = "[" ? "" : "."
      if !RegExMatch(key, "(.*)\[(\d+)]$", match)
         res := this.JS.eval("var obj = (" . sJson . "); delete obj" . sign . key . "; JSON.stringify(obj)")
      else
         res := this.JS.eval( "var obj = (" . sJson . ");" 
                            . "obj" . (match1 != "" ? sign . match1 : "") . ".splice(" . match2 . ", 1);"
                            . "JSON.stringify(obj)" )
      this.JS.eval("obj = ''")
      Return res
   }
   
   Enum(sJson, key := "") {
      if !this.VerifyJson(sJson)
         Return
      
      conc := key ? (SubStr(key, 1, 1) = "[" ? "" : ".") . key : ""
      try jsObj := this.JS.eval("(" sJson ")" . conc)
      catch {
         MsgBox, Wrong key:`n`n%key%
         Return
      }
      res := jsObj.IsArray()
      if (res = "")
         Return
      obj := {}
      if (res = -1)  {
         Loop % jsObj.length
            obj[A_Index - 1] := this.JS.eval("JSON.stringify((" sJson ")" . conc . "[" . (A_Index - 1) . "])")
      }
      else if (res = 0) {
         keys := jsObj.GetKeys()
         Loop % keys.length
            k := keys[A_Index - 1], obj[k] := this.JS.eval("JSON.stringify((" sJson ")" . conc . "." . k . ")")
      }
      Return obj
   }
   
   VerifyJson(sJson) {
      try jsObj := this.JS.eval("(" sJson ")")
      catch {
         MsgBox, Wrong JSON string:`n`n%sJson%
         Return
      }
      Return IsObject(jsObj) ? jsObj : true
   }
   
   _ObjToString(obj) {
      if IsObject( obj )  {
         isArray := true
         for key in obj {
            if IsObject(key)
               throw Exception("Invalid key")
            if !( key = A_Index || isArray := false )
               break
         }
         for k, v in obj
            str .= ( A_Index = 1 ? "" : "," ) . ( isArray ? "" : k . ":" ) . this._ObjToString(v)

         Return isArray ? "[" str "]" : "{" str "}"
      }
      else if !(obj*1 = "" || RegExMatch(obj, "\s"))
         Return obj
      else
         Return """" obj """"
   }

   _GetJScriptObject()  {
      static doc
      doc := ComObjCreate("htmlfile")
      doc.write("<meta http-equiv=""X-UA-Compatible"" content=""IE=9"">")
      JS := doc.parentWindow
      JSONcom._AddMethods(JS)
      Return JS
   }

   _AddMethods(ByRef JS)  {
      JScript =
      (
         Object.prototype.GetKeys = function () {
            var keys = []
            for (var k in this)
               if (this.hasOwnProperty(k))
                  keys.push(k)
            return keys
         }
         Object.prototype.IsArray = function () {
            var toStandardString = {}.toString
            return toStandardString.call(this) == '[object Array]'
         }
      )
      JS.eval(JScript)
   }

   _CreateObject(jsObj)  {
      res := jsObj.IsArray()
      if (res = "")
         Return jsObj
      
      else if (res = -1)  {
         obj := []
         Loop % jsObj.length
            obj[A_Index] := this._CreateObject(jsObj[A_Index - 1])
      }
      else if (res = 0)  {
         obj := {}
         keys := jsObj.GetKeys()
         Loop % keys.length
            k := keys[A_Index - 1], obj[k] := this._CreateObject(jsObj[k])
      }
      Return obj
   }
}