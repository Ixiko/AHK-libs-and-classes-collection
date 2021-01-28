ImageList_Create(cx,cy,flags,cInitial,cGrow){ 
   return DllCall("comctl32.dll\ImageList_Create", "int", cx, "int", cy, "uint", flags, "int", cInitial, "int", cGrow) 
} 

ImageList_Add(hIml, hbmImage, hbmMask=""){ 
   return DllCall("comctl32.dll\ImageList_Add", "uint", hIml, "uint",hbmImage, "uint", hbmMask) 
} 

ImageList_AddIcon(hIml, hIcon) { 
   return DllCall("comctl32.dll\ImageList_ReplaceIcon", "uint", hIml, "int", -1, "uint", hIcon) 
} 

ImageList_Remove(hIml, Pos=-1){
   return DllCall("comctl32.dll\ImageList_Remove", "uint", hIml, "int", Pos) 
}


API_LoadImage(pPath, uType, cxDesired, cyDesired, fuLoad) { 
   return,  DllCall( "LoadImage", "uint", 0, "str", pPath, "uint", uType, "int", cxDesired, "int", cyDesired, "uint", fuLoad) 
} 

LoadIcon(Filename, IconNumber, IconSize) { 
   DllCall("PrivateExtractIcons" 
          ,"str",Filename,"int",IconNumber-1,"int",IconSize,"int",IconSize 
            ,"uint*",h_icon,"uint*",0,"uint",1,"uint",0,"int") 
   if !ErrorLevel 
         return h_icon 
}