getImageSize(imagePath){
;    if(subStr(a_osVersion,2)=10)
;        _attributeWidth:=169,_attributeHeight:=171
;    else
;        _attributeWidth:=162,_attributeHeight:=164
    splitPath,imagePath,fN,fD

    oS:=comObjCreate("Shell.Application")
    oF:=oS.namespace(fD?fD:a_workingDir)
    oFn:=oF.parseName(fD?fN:imagePath)
    size:=strSplit(oFn.extendedProperty("Dimensions"),"x"
        ," ?" . chr(8234) chr(8236))
;    width:=subStr(oF.getDetailsOf(oFn,_attributeWidth),2,-7)
;    height:=subStr(oF.getDetailsOf(oFn,_attributeHeight),2,-7)

    return {width: size[1],height: size[2]}
}