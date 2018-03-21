; Add Thousands Separator by infogulch
; http://www.autohotkey.com/forum/topic54149.html
ThousandsSep(x, s=",") {
   return RegExReplace(x, "(?(?<=\.)(*COMMIT)(*FAIL))\d(?=(\d{3})+(\D|$))", "$0" s)
}
; old version: RegExReplace(x, "(?(?<=\.)(*COMMIT)(*FAIL))(?<=\d)(\d{3})(?=(?:\d{3})*+(?:$|\.))", ",$1")