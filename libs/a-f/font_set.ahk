font_set(win_id, font_params) {
    ; function from majkinetor
    ; http://www.autohotkey.com/forum/viewtopic.php?p=124450#124450
    ; Example:
    ; font_set(win_id, "s12 bold, Courier New")
    ; font_set(win_id, "s12 bold, Comic Sans MS")
    local height, weight, italic, underline, strikeout , n_char_set, h_font
    static WM_SETFONT := 0x30

    ;parse the font
    italic := InStr(font_params, "italic") ? 1 : 0
    underline := InStr(font_params, "underline") ? 1 : 0
    strikeout := InStr(font_params, "strikeout") ? 1 : 0
    weight := InStr(font_params, "bold") ? 700 : 400

    ; calculate height
    RegExMatch(font_params, "(?<=[S|s])(\d{1,2})(?=[ ,])", height)
    if (height = "")
        height := 10
    RegRead, LogPixels, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontDPI, LogPixels
    height := -DllCall("MulDiv", "int", height, "int", LogPixels, "int", 72)

    ; get the font face
    RegExMatch(font_params, "(?<=,).+", font_face)
    if (font_face != "")
        font_face := Trim(font_face)
    else
        font_face := "MS Sans Serif"

    ; create font
    h_font := DllCall("CreateFont", "int", height, "int", 0, "int", 0, "int", 0
    ,"int", weight, "uint", italic, "uint", underline, "uint", strikeOut
    , "uint", n_char_set, "uint", 0, "uint", 0, "uint", 0, "uint", 0, "str", font_face)

    SendMessage, WM_SETFONT, h_font, TRUE,, ahk_id %win_id%
    return ErrorLevel
}