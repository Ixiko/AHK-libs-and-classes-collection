/*
  WarnLegacy(filename := A_ScriptFullPath)

  Prints a warning to stdout for each detected use of the following:
    var = value  ; legacy assignment
    if var = value  ; legacy IF with any of these operators: = < > <= >= <> !=
  excluding:
    if var = n  ; where n is any literal number, and = is any of the above operators.

  Also handles #Include or #IncludeAgain if passed a directory or filename, but does
  not handle <LibName> or variables except for %A_LineFile%.  Relative paths may be
  resolved incorrectly if A_WorkingDir does not have the appropriate value.
*/
WarnLegacy(filename := "") {
    if (filename = "")
        filename := A_ScriptFullPath
    Loop Files, % filename
        filename := A_LoopFileLongPath
    code := FileOpen(filename, "r`r").Read()
    static regex := "
    (LTrim Join
        mi)(*ANYCRLF)(*BSR_ANYCRLF)(?(DEFINE)
            (?<lcom>(?<![^ `t`r`n]);.*)
            (?<bcom>^[ `t]*/\*(?:.*\R?)+?(?:[ `t]*\*/|.*\Z))
            (?<hkkey>\w+|[^ `t`r`n])
            (?<hklbl>(?>[<>*~$!^+#]*(?&hkkey)|~?(?&hkkey) & ~?(?&hkkey))(?i:[ `t]+up)?::)
            (?<hslbl>:[[:alnum:]\?\*\- ]*:.*(?<!``)::)
            (?<hslblr>(?(?=:[^\:`r`n]*[xX])(?&hslbl)|(?&hslbl).*))
            (?<name>[\w[:^ascii:]#@$]++)
            (?<var>(?&name)|%(?&name)%)
            (?<tosol>(?>[ `t]*(?&lcom)?\R|(?&bcom))++)
            (?<contsec>
                [ `t]*\((?i:Join[^ `t`r`n]*+|(?&lcom)|[^ `t`r`n)]++|[ `t]++)*+\R
                (?:[ `t]*+(?!\)).*\R)*+
                [ `t]*\)
            `)
            (?<solcont>[ `t]*(?:,(?!::| +& )|[<>=/|^,?:\.+\-*&!~](?![^""]*?(?:"".*?::(?!.*?"")|::))))
            (?<blank>(?&bcom)|[ `t]*(?&lcom)?\R)
            (?<vline>.*(?>\R(?&blank)*+(?:(?&solcont).*|(?&contsec).*))*+)
            (?<num>[-+]?(?>(?>\d+|(?=\.\d))(?>\.\d*(?:e[-+]?\d+)?)?|0x[[:xdigit:]]+))
            (?<numv>[ `t]*(?&num)[ `t]*$)
        `)
        (?&bcom)(*SKIP)(?!)|
        ^[ `t{}]*
        (?:(?&lcom)|(?&bcom)|(?&hklbl)|(?&hslblr)|(?:else|try|finally)[ `t{}]*)?
        \K(?:
            (?&var)[ `t]*=(?&vline)(*:LegacyAss)|
            if[ `t]+(?&var)[ `t]*(?>!?=|[<>]=?|<>)(?!(?&numv))(?&vline)(*:LegacyIf)|
            #Include(?:Again)?(?>,|[ `t]+,?)[ `t]*+(?:\*i )?(?<IncludePath>.*?(?=[ `t]*(?&lcom)?$))(*:Include)|
            (?:(?&vline))(*SKIP)(?!)
        `)
    )"
    owd := A_WorkingDir, sp := 1, line := 1
    try while fp := RegExMatch(code, "O" regex, m, sp) {
        ; Calculate line number based on number of line since previous match.
        StrReplace(SubStr(code, sp, fp-sp), "`n", "`n", nlc), line += nlc
        ; Calculate next starting point.
        sp := fp + m.Len()
        ; Handle #Include.
        if (m.mark = "Include") {
            ; TODO: Implement more variable support as needed.
            path := StrReplace(m.IncludePath, "%A_LineFile%", filename)
            attrib := InStr(path, "%") ? "" : FileExist(path)
            if InStr(attrib, "D")
                SetWorkingDir % path
            else if attrib
                WarnLegacy(m.IncludePath)
            else if SubStr(filename, 1, 1) != "<"
                FileAppend % filename " (" line ") : ==> Debug: Unable to resolve #Include."
                    . "`n    Specifically: " m.0 "`n", *
            continue
        }
        ; Handle legacy syntax.
        FileAppend % filename " (" line ") : ==> Warning: Use of deprecated syntax."
            . "`n     Specifically: " m.0 "`n", *
    }
    finally
        SetWorkingDir % owd
}
