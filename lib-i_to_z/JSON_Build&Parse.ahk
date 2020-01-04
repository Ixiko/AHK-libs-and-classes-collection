; Credits: rbrtryn / http://www.autohotkey.com/board/topic/95262-obj-json-obj/
/****************************************************************************************
    Function: BuildJson(obj)
        Builds a JSON string from an AutoHotkey object

    Parameters:
        obj - An AutoHotkey array or object, which can include nested objects.

    Remarks:
        Originally Obj2Str() by Coco,
        http://www.autohotkey.com/board/topic/93300-what-format-to-store-settings-in/page-2#entry588373

        Modified to use double quotes instead of single quotes and to leave numeric values
        unquoted.

    Returns:
        The JSON string
*/
BuildJson(obj) {
    str := "" , array := true
    for k in obj {
        if (k == A_Index)
            continue
        array := false
        break
    }
    for a, b in obj
        str .= (array ? "" : """" a """: ") . (IsObject(b) ? BuildJson(b) : IsNumber(b) ? b : """" b """") . ", "
    str := RTrim(str, " ,")
    return (array ? "[" str "]" : "{" str "}")
}

/****************************************************************************************
    Function: ParseJson(jsonStr)
        Converts a JSON string into an AutoHotkey object

    Parameters:
        jsonstr - the JSON string to convert

    Remarks:
        Originally by Getfree,
        http://www.autohotkey.com/board/topic/93300-what-format-to-store-settings-in/#entry588268

    Returns:
        The AutoHotkey object.
*/
ParseJson(jsonStr) {
    SC := ComObjCreate("ScriptControl")
    SC.Language := "JScript"
    ComObjError(false)
    jsCode =
    (
    function arrangeForAhkTraversing(obj){
        if(obj instanceof Array){
            for(var i=0 ; i<obj.length ; ++i)
                obj[i] = arrangeForAhkTraversing(obj[i]) ;
            return ['array',obj] ;
        }else if(obj instanceof Object){
            var keys = [], values = [] ;
            for(var key in obj){
                keys.push(key) ;
                values.push(arrangeForAhkTraversing(obj[key])) ;
            }
            return ['object',[keys,values]] ;
        }else
            return [typeof obj,obj] ;
    }
    )
    SC.ExecuteStatement(jsCode "; obj=" jsonStr)
    return convertJScriptObjToAhks( SC.Eval("arrangeForAhkTraversing(obj)") )
}

/*!
    Function: convertJScriptObjToAhks(jsObj)
        Used by ParseJson()
*/
convertJScriptObjToAhks(jsObj) {
    if(jsObj[0]="object"){
        obj := {}, keys := jsObj[1][0], values := jsObj[1][1]
        loop % keys.length
            obj[keys[A_INDEX-1]] := convertJScriptObjToAhks( values[A_INDEX-1] )
        return obj
    }else if(jsObj[0]="array"){
        array := []
        loop % jsObj[1].length
            array.insert(convertJScriptObjToAhks( jsObj[1][A_INDEX-1] ))
        return array
    }else
        return jsObj[1]
}

/*!
    Function: IsNumber(Num)
        Checks if Num is a number.

    Returns:
        True if Num is a number, false if not
*/
IsNumber(Num) {
    if Num is number
        return true
    else
        return false
}