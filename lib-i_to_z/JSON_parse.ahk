  /*
  derived from Getfree's parseJson function
  http://www.autohotkey.com/board/topic/93300-what-format-to-store-settings-in/#entry588268
  https://www.autohotkey.com/boards/viewtopic.php?t=41192
  credits to Getfree
  */
  JSON_parse(jsonStr) {
    SC := ComObjCreate("ScriptControl")
    SC.Language := "JScript"
    ;ComObjError(false)
    jsCode =
    (
    function arrangeForAhkTraversing(obj) {
      if(obj instanceof Array) {
        for(var i=0 ; i<obj.length ; ++i)
          obj[i] = arrangeForAhkTraversing(obj[i]) ;
        return ['array',obj] ;
      } else if(obj instanceof Object) {
        var keys = [], values = [] ;
        for(var key in obj) {
          keys.push(key) ;
          values.push(arrangeForAhkTraversing(obj[key])) ;
        }
        return ['object',[keys,values]] ;
      } else
        return [typeof obj,obj] ;
    }
    )
    SC.ExecuteStatement(jsCode "; obj=" jsonStr)
    return convertJScriptObj2AHK(SC.Eval("arrangeForAhkTraversing(obj)"))
  }

  convertJScriptObj2AHK(jsObj) {
    if (jsObj[0]="object") {
      obj := {}, keys := jsObj[1][0], values := jsObj[1][1]
      loop % keys.length
        obj[keys[A_Index-1]] := convertJScriptObj2AHK(values[A_Index-1])
      return obj
    } else if (jsObj[0]="array") {
      array := []
      loop % jsObj[1].length
        array.Insert(convertJScriptObj2AHK(jsObj[1][A_Index-1]))
      return array
    } else return jsObj[1]
  }