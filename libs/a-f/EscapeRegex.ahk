;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

EscapeRegex(ByRef t) {
    ; via https://stackoverflow.com/a/25837411
    Return RegexReplace(t, "[\-\[\]{}()*+?.,\\\^$|#\s]", "\$0")
}
