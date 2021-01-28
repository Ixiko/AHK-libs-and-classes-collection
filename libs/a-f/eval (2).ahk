eval(e, byref log=0){
  global eval_vars
  static vars := {"(pi|π)":3.14159265, "e":2.71828182, "log2e":1.44269504, "log10e":0.43429448
  , "ln2":0.69314718, "ln10":2.30258509, "sqrt2":1.41421356, "euler":0.57721566, "true":1, "false":0, "null":0
  , "(answer.?to.?|)life,?.?the.?universe.?and.?everything":42, "number.?of.?horns.?on.?a.?unicorn":1}
  static ahk_vars := ["A_WorkingDir", "A_ScriptDir", "A_ScriptName", "A_ScriptFullPath", "A_AhkVersion", "A_AhkPath", "A_IsUnicode"
  , "A_IsCompiled", "A_YYYY", "A_MM", "A_DD", "A_MMMM", "A_MMM", "A_DDDD", "A_DDD", "A_WDay", "A_YDay", "A_YWeek", "A_Hour"
  , "A_Min", "A_Sec", "A_MSec", "A_Now", "A_NowUTC", "A_TickCount", "ComSpec", "A_Temp", "A_OSType", "A_OSVersion"
  , "A_PtrSize", "A_Language", "A_ComputerName", "A_WinDir", "A_ProgramFiles", "A_AppData", "A_AppDataCommon", "A_Desktop"
  , "A_DesktopCommon", "A_StartMenu", "A_StartMenuCommon", "A_Programs", "A_ProgramsCommon", "A_Startup", "A_StartupCommon"
  , "A_MyDocuments", "A_IsAdmin", "A_ScreenWidth", "A_ScreenHeight", "A_IPAddress1", "A_IPAddress2", "A_IPAddress3"
  , "A_IPAddress4", "A_Cursor", "Clipboard", "ClipboardAll"]
  static build_in_funcs := ["hex", "deg2rad", "rad2deg", "min", "max", "clamp"]
  static num := "(__str[0-9]+_|-?0x[0-9a-fA-F]+|-?[0-9]*\.?[0-9]+)"
  static hex := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, "a", "b", "c", "d", "e", "f"]
  static b := hex.minIndex()
  static str := []
  global_vars := (isobject(eval_vars)) ? eval_vars : []
  if (e[b]="clr")
  {
    while (regexmatch(e[b+1], t := "(__str[0-9]+_|[,²²*~/%+\-<>&^|=!&?:]|-?0x[0-9a-fA-F]+|-?[0-9]*\.?[0-9]+)", m))
    {
      x .= m1
      e[b+1] := regexreplace(e[b+1], t "(.*)", "$2")
    }
    return x
  }
  if (e[b]="trim")
    return regexreplace(regexreplace(regexreplace(e[b+1], ",\s*\+\s*", ","), "^\s*\+\s*"), "\s*([+\-])\s*\+\s*", "$1")
  if (e[b]="str")
  {
    while (regexmatch(e[b+1], "__str([0-9]+)_", m))
      e[b+1] := regexreplace(e[b+1], "__str[0-9]+_(.*)", e[b+2] str[m1] e[b+2] "$1")
    return e[b+1]
  }
  if (e[b]="hex")
  {
    Loop, 16
      h := hex[((e[b+1]>>((A_Index-1)*4))&0xf)+b] h
    return (h="") ? "" : "0x" ((regexreplace(h, "^0*")="") ? "0" : regexreplace(h, "^0*"))
  }
  if (e[b]="deg2rad")
    return e[b+1]*0.01745329
  if (e[b]="rad2deg")
    return e[b+1]*57.29578
  if (e[b]="min")
    return (e[b+1]>e[b+2]) ? e[b+2] : e[b+1]
  if (e[b]="max")
    return (e[b+1]>e[b+2]) ? e[b+1] : e[b+2]
  if (e[b]="clamp") ;value, min, max
    return (e[b+1]<e[b+2]) ? e[b+2] : ((e[b+1]>e[b+3]) ? e[b+3] : e[b+1])
  if (e[b]="var")
  {
    if (e[b+1]="")
      return
    if (regexmatch(e[b+1], "^" num "$"))
      return e[b+1]
    str.insert(e[b+1])
    return "__str" str.maxIndex() "_"
  }
  if (regexmatch(e, "^\s*(.*?)\s*$", m))
    e := regexreplace(m1, "\s", " ")
  log := [eval(["str",e,""""])]
  if (regexmatch(e, """([^""]*)"""))
    str := []
  while (regexmatch(e, """(?P<str>(""""|[^""]*)*)""", m))
  {
    str.insert(regexreplace(mstr, """""", """"))
    e := regexreplace(e, """((""""|[^""]*)*)""(?P<end>.*)", "__str" str.maxIndex() "_${end}")
  }
  while (regexmatch(e, "([+\-]\s*[+\-])", m))
  {
    e := regexreplace(e, "-\s*-", "+")
    e := regexreplace(e, "\+\s*-", "-")
    e := regexreplace(e, "([+\-])\s*\+", "$1")
  }
  for k,v in global_vars
  {
    while (regexmatch(e, "iO)(^|[^a-zA-Z0-9_])" k "([^a-zA-Z0-9_]|$)", m))
      e := regexreplace(e, "i)(^|[^a-zA-Z0-9_])" k "(?P<p>[^a-zA-Z0-9_]|$)", "$1" eval(["var", v]) "${p}")
  }
  for k,v in vars
  {
    while (regexmatch(e, "iO)(^|[^a-zA-Z0-9_])" k "([^a-zA-Z0-9_]|$)", m))
      e := regexreplace(e, "i)(^|[^a-zA-Z0-9_])" k "(?P<p>[^a-zA-Z0-9_]|$)", "$1" eval(["var", v]) "${p}")
  }
  for i,k in ahk_vars
  {
    while (regexmatch(e, "i)(^|[^a-zA-Z0-9_])" k "([^a-zA-Z0-9_]|$)", m))
      e := regexreplace(e, "i)(^|[^a-zA-Z0-9_])" k "([^a-zA-Z0-9_]|$)", "$1" eval(["var", %k%]) "$2")
  }
  if (log[log.maxIndex()] != eval(["str",e,""""]))
    log.insert(eval(["str",e,""""]))
  while (regexmatch(e, "(.*)\(([^)]*)\)(.*)", m))
  {
    s := 0, le := eval(m2, l), p := []
    Loop, parse, le, `,, % " "
      p.insert(eval(["str",A_LoopField]))
    if (regexmatch(m1, "([a-zA-Z0-9_]+)$", fn))
    {
      if (isfunc(fn1))
        r := func(fn1).(p*), s := 1
      else
      {
        for k,v in build_in_funcs
        {
          if (v=fn1)
            r := eval([fn1,p*]), s := 1
        }
      }
      e := (s) ? substr(m1, 1, -strlen(fn1)) eval(["var", r]) m3 : m1 le m3
    }
    else
      e := m1 le m3
    for k,v in l
    {
      if (log[log.maxIndex()] != eval(["str", m1 fn1 "(" v ")" m3, """"]))
        log.insert(eval(["str", m1 fn1 "(" v ")" m3, """"]))
    }
    if (log[log.maxIndex()] != eval(["str",e,""""]))
      log.insert(eval(["str",e,""""]))
  }
  e := eval(["clr", e])
  while (regexmatch(e, "(.*?)" num "\s*(²|³)\s*(.*)", m)) ; ² ³
    log.insert(eval(["str",e := eval(["trim",eval(["str",m1]) "+" (m2 ** ((m3="²") ? 2 : 3)) m4]),""""]))
  while (regexmatch(e, "(.*?)" num "\s*\*\*\s*" num "(.*)", m)) ; **
    log.insert(eval(["str",e := eval(["trim",m1 "+" (eval(["str",m2]) ** eval(["str",m3])) m4]),""""]))
  while (regexmatch(e, "(.*?)" num "\s*~\s*" num "(.*)", m)) ; ~
    log.insert(eval(["str",e := eval(["trim",m1 "+" (eval(["str",m2]) ~ eval(["str",m3])) m4]),""""]))
  while (regexmatch(e, "(.*?)" num "\s*(\*|/|//|%)\s*" num "(.*)", m)) ; * / // %
    log.insert(eval(["str",e := eval(["trim",m1 "+" ((m3="*" || m3="/") ? ((m3="*") ? eval(["str",m2]) * eval(["str",m4]) : eval(["str",m2]) / eval(["str",m4])) : ((m3="//") ? eval(["str",m2]) // eval(["str",m4]) : mod(eval(["str",m2]), eval(["str",m4])))) m5]),""""]))
  while (regexmatch(e, "(.*?)" num "\s*(\+|-)\s*" num "(.*)", m)) ; + -
    log.insert(eval(["str",e := eval(["trim",m1 "+" ((m3="+") ? eval(["str",m2]) + eval(["str",m4]) : eval(["str",m2]) - eval(["str",m4])) m5]),""""]))
  while (regexmatch(e, "(.*?)" num "\s*(<<|>>)\s*" num "(.*)", m)) ; << >>
    log.insert(eval(["str",e := eval(["trim",m1 "+" ((m3="<<") ? eval(["str",m2]) << eval(["str",m4]) : eval(["str",m2]) >> eval(["str",m4])) m5]),""""]))
  while (regexmatch(e, "(.*?)" num "\s*(&|^|\|)\s*" num "(.*)", m)) ; & ^ |
    log.insert(eval(["str",e := eval(["trim",m1 "+" ((m3="&") ? eval(["str",m2]) & eval(["str",m4]) : ((m3="^") ? eval(["str",m2]) ^ eval(["str",m4]) : eval(["str",m2]) | eval(["str",m4]))) m5]),""""]))
  while (regexmatch(e, "(.*?)" num "\s*(>|<|>=|<=)\s*" num "(.*)", m)) ; > < >= <=
    log.insert(eval(["str",e := eval(["trim",m1 "+" ((m3=">" || m3=">=") ? ((m3=">") ? (eval(["str",m2])>eval(["str",m4])) : (eval(["str",m2])>=eval(["str",m4]))) : ((m3="<") ? (eval(["str",m2])<eval(["str",m4])) : (eval(["str",m2])<=eval(["str",m4])))) m5]),""""]))
  while (regexmatch(e, "(.*?)" num "\s*(=|==|<>|!=)\s*" num "(.*)", m)) ; = == <> !=
    log.insert(eval(["str",e := eval(["trim",m1 "+" ((m3="=" || m3="==") ? ((m3="=") ? (eval(["str",m2])=eval(["str",m4])) : (eval(["str",m2])==eval(["str",m4]))) : ((m3="<>") ? (eval(["str",m2])<>eval(["str",m4])) : (eval(["str",m2])!=eval(["str",m4])))) m5]),""""]))
  while (regexmatch(e, "i)(.*?)(!|not)\s*(.*)", m)) ; ! not
    log.insert(eval(["str",e := eval(["trim",m1 (!(eval(["str",m3])))]),""""]))
  while (regexmatch(e, "i)(.*?)" num "\s*(&&|and)\s*" num "(.*)", m)) ; && and
    log.insert(eval(["str",e := eval(["trim",m1 "+" (eval(["str",m2]) && eval(["str",m4])) m5]),""""]))
  while (regexmatch(e, "i)(.*?)" num "\s*(\|\||or)\s*" num "(.*)", m)) ; || or
    log.insert(eval(["str",e := eval(["trim",m1 "+" (eval(["str",m2]) || eval(["str",m4])) m5]),""""]))
  while (regexmatch(e, "\s*(.+?)\s*\?\s*(.+?)\s*:\s*(.+)\s*", m)) ; ?:
    log.insert(eval(["str",e := eval(["trim",eval(["str",m1]) ? m2 : m3]),""""]))
  e := eval(["str",eval(["clr", e])])
  if (log[log.maxIndex()] != e)
    log.insert(e "")
  return e ""
}