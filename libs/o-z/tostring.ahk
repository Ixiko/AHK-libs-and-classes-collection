/*
Author: IsNull
http://www.autohotkey.com/forum/topic59244.html
license: not specified 
default license for forum where initially posted:GPL v2
*/

ToString(this){
   if(!IsObject(this))
      return, this
   str := ""
   fields := this._NewEnum()
   while fields[k, v]
   {
      if(!IsObject(v)){
         str .= !IsFunc(v) ? "[" k "] := "  v "`n" : k "() calls "  v "`n"
      }else{
         subobje := ToString(v)
         str .= "[" k "]<ob>`n" _multab(subobje)
      }
   }
   return, str
}

_multab(str){
   Loop, parse, str, `n, `r
      newstr .= A_Tab A_LoopField "`n"
   return, newstr
}