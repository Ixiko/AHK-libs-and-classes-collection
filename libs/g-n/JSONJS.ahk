class JSON
{
   static JS := JSON._GetJScripObject()
   
   Parse(JsonString)  {
      try oJSON := this.JS.("(" JsonString ")")
      catch  {
         MsgBox, Wrong JsonString!
         Return
      }
      Return this._CreateObject(oJSON)
   }
   
   Stringify(obj)  {
      if IsObject( obj )  {
         isArray := true
         for key in obj
            if !( key = A_Index || isArray := false )
               break
            
         for k, v in obj
            str .= ( A_Index = 1 ? "" : "," ) . ( isArray ? "" : this.Stringify(k) . ":" ) . this.Stringify(v)

         return isArray ? "[" str "]" : "{" str "}"
      }
      else if !(obj*1 = "" || RegExMatch(obj, "\s"))
         return obj
      
      for k, v in [["\", "\\"], [A_Tab, "\t"], ["""", "\"""], ["/", "\/"], ["`n", "\n"], ["`r", "\r"], [Chr(12), "\f"], [Chr(08), "\b"]]
         obj := StrReplace( obj, v[1], v[2] )
      
      while RegexMatch( obj, "[^\x20-\x7e]", key )  {
         str := Asc( key )
         val := "\u" . Chr( ( ( str >> 12 ) & 15 ) + ( ( ( str >> 12 ) & 15 ) < 10 ? 48 : 55 ) )
               . Chr( ( ( str >> 8 ) & 15 ) + ( ( ( str >> 8 ) & 15 ) < 10 ? 48 : 55 ) )
               . Chr( ( ( str >> 4 ) & 15 ) + ( ( ( str >> 4 ) & 15 ) < 10 ? 48 : 55 ) )
               . Chr( ( str & 15 ) + ( ( str & 15 ) < 10 ? 48 : 55 ) )
         obj := StrReplace(obj, key, val)
      }
      Return """" obj """"
   }
   
   GetFromUrl(url, contentType := "", userAgent := "", body := "")  {
      ; в случае удачи будет возвращена JSON-строка, в случае ошибки — массив с одним элементом-строкой с описанием ошибки
      try  {
         XmlHttp := ComObjCreate("Microsoft.XmlHttp")
         XmlHttp.Open("GET", url, false)
         ( contentType && XmlHttp.SetRequestHeader("Content-Type", contentType) )
         ( userAgent && XmlHttp.SetRequestHeader("User-Agent", userAgent) )
         XmlHttp.Send(body)
      }
      catch e
         Return ["Error!`n" . e.Message]
      status := XmlHttp.Status
      Return status = 200 ? XmlHttp.ResponseText : ["Error! Status: " . status . ", ResponseText: " . XmlHttp.ResponseText]
   }

   _GetJScripObject()  {
      VarSetCapacity(tmpFile, ((MAX_PATH := 260) - 14) << !!A_IsUnicode, 0)
      DllCall("GetTempFileName", Str, A_Temp, Str, "AHK", UInt, 0, Str, tmpFile)
      
      FileAppend,
      (
      <component>
      <public><method name='eval'/></public>
      <script language='JScript'></script>
      </component>
      ), % tmpFile
      
      JS := ObjBindMethod( ComObjGet("script:" . tmpFile), "eval" )
      FileDelete, % tmpFile
      JSON._AddMethods(JS)
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
      JS.("delete ActiveXObject; delete GetObject;")
      JS.(JScript)
   }

   _CreateObject(ObjJS)  {
      res := ObjJS.IsArray()
      if (res = "")
         Return ObjJS
      
      else if (res = -1)  {
         obj := []
         Loop % ObjJS.length
            obj[A_Index] := this._CreateObject(ObjJS[A_Index - 1])
      }
      else if (res = 0)  {
         obj := {}
         keys := ObjJS.GetKeys()
         Loop % keys.length
            k := keys[A_Index - 1], obj[k] := this._CreateObject(ObjJS[k])
      }
      Return obj
   }
}