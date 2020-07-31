; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

class JSON
{
   static JS := JSON._GetJScriptObject(), true := {}, false := {}, null := {}
   
   Parse(sJson, js := false)  {
      if jsObj := this.VerifyJson(sJson)
         Return js ? jsObj : this._CreateObject(jsObj)
   }
   
   Stringify(obj, js := false, indent := "") {
      if js
         Return this.JS.JSON.stringify(obj, "", indent)
      else {
         sObj := this._ObjToString(obj)
         Return this.JS.eval("JSON.stringify(" . sObj . ",'','" . indent . "')")
      }
   }
   
   GetKey(sJson, key, indent := "") {
      if !this.VerifyJson(sJson)
         Return
      
      try Return this.JS.eval("JSON.stringify((" . sJson . ")" . (SubStr(key, 1, 1) = "[" ? "" : ".") . key . ",'','" . indent . "')")
      catch
         MsgBox, Bad key:`n`n%key%
   }
   
   SetKey(sJson, key, value, indent := "") {
      if !this.VerifyJson(sJson)
         Return
      if !this.VerifyJson(value, true) {
         MsgBox, % "Bad value: " . value                      . "`n"
                 . "Must be a valid JSON string."             . "`n"
                 . "Enclose literal strings in quotes '' or """".`n"
                 . "As an empty string pass '' or """""
         Return
      }
      try {
         res := this.JS.eval( "var obj = (" . sJson . ");"
                            . "obj" . (SubStr(key, 1, 1) = "[" ? "" : ".") . key . "=" . value . ";"
                            . "JSON.stringify(obj,'','" . indent . "')" )
         this.JS.eval("obj = ''")
         Return res
      }
      catch
         MsgBox, Bad key:`n`n%key%
   }
   
   RemoveKey(sJson, key, indent := "") {
      if !this.VerifyJson(sJson)
         Return
      
      sign := SubStr(key, 1, 1) = "[" ? "" : "."
      try {
         if !RegExMatch(key, "(.*)\[(\d+)]$", match)
            res := this.JS.eval("var obj = (" . sJson . "); delete obj" . sign . key . "; JSON.stringify(obj,'','" . indent . "')")
         else
            res := this.JS.eval( "var obj = (" . sJson . ");" 
                               . "obj" . (match1 != "" ? sign . match1 : "") . ".splice(" . match2 . ", 1);"
                               . "JSON.stringify(obj,'','" . indent . "')" )
         this.JS.eval("obj = ''")
         Return res
      }
      catch
         MsgBox, Bad key:`n`n%key%
   }
   
   Enum(sJson, key := "", indent := "") {
      if !this.VerifyJson(sJson)
         Return
      
      conc := key ? (SubStr(key, 1, 1) = "[" ? "" : ".") . key : ""
      try {
         jsObj := this.JS.eval("(" sJson ")" . conc)
         res := jsObj.IsArray()
         if (res = "")
            Return
         obj := {}
         if (res = -1) {
            Loop % jsObj.length
               obj[A_Index - 1] := this.JS.eval("JSON.stringify((" sJson ")" . conc . "[" . (A_Index - 1) . "],'','" . indent . "')")
         }
         else if (res = 0) {
            keys := jsObj.GetKeys()
            Loop % keys.length
               k := keys[A_Index - 1], obj[k] := this.JS.eval("JSON.stringify((" sJson ")" . conc . "['" . k . "'],'','" . indent . "')")
         }
         Return obj
      }
      catch
         MsgBox, Bad key:`n`n%key%
   }
   
   VerifyJson(sJson, silent := false) {
      try jsObj := this.JS.eval("(" sJson ")")
      catch {
         if !silent
            MsgBox, Bad JSON string:`n`n%sJson%
         Return
      }
      Return IsObject(jsObj) ? jsObj : true
   }
   
   _ObjToString(obj) {
      if IsObject( obj ) {
         for k, v in ["true", "false", "null"]
            if (obj = this[v])
               Return v
            
         isArray := true
         for key in obj {
            if IsObject(key)
               throw Exception("Invalid key")
            if !( key = A_Index || isArray := false )
               break
         }
         for k, v in obj
            str .= ( A_Index = 1 ? "" : "," ) . ( isArray ? "" : """" . k . """:" ) . this._ObjToString(v)

         Return isArray ? "[" str "]" : "{" str "}"
      }
      else if !(obj*1 = "" || RegExMatch(obj, "\s"))
         Return obj
      
      for k, v in [["\", "\\"], [A_Tab, "\t"], ["""", "\"""], ["/", "\/"], ["`n", "\n"], ["`r", "\r"], [Chr(12), "\f"], [Chr(08), "\b"]]
         obj := StrReplace( obj, v[1], v[2] )

      Return """" obj """"
   }

   _GetJScriptObject() {
      static doc
      doc := ComObjCreate("htmlfile")
      doc.write("<meta http-equiv=""X-UA-Compatible"" content=""IE=9"">")
      JS := doc.parentWindow
      JSON._AddMethods(JS)
      Return JS
   }

   _AddMethods(ByRef JS) {
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

   _CreateObject(jsObj) {
      res := jsObj.IsArray()
      if (res = "")
         Return jsObj
      
      else if (res = -1) {
         obj := []
         Loop % jsObj.length
            obj[A_Index] := this._CreateObject(jsObj[A_Index - 1])
      }
      else if (res = 0) {
         obj := {}
         keys := jsObj.GetKeys()
         Loop % keys.length
            k := keys[A_Index - 1], obj[k] := this._CreateObject(jsObj[k])
      }
      Return obj
   }
}