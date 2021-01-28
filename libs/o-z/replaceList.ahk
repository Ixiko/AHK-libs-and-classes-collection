; Parts unnecessary for this script have been removed from the lib

replaceList(def, opt) {
    x:=def.clone()
    if isObject(opt)
        for i,val in opt
            x[i]:=val
    return x
}