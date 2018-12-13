;basic idea for SIFT3 code by Siderite Zackwehdex
;http://siderite.blogspot.com/2007/04/super-fast-and-accurate-string-distance.html
;took idea to normalize it to longest string from Brad Wood
;http://www.bradwood.com/string_compare/
;Own work:
; - when character only differ in case, LSC is a 0.8 match for this character
; - modified code for speed, might lead to different results compared to original code
; - optimized for speed (30% faster then original SIFT3 and 13.3 times faster than basic Levenshtein distance)
;http://www.autohotkey.com/forum/topic59407.html
Difference(string1, string2, maxOffset=5) {    ;returns a float: between "0.0 = identical" and "1.0 = nothing in common"
  If (string1 = string2)
    Return (string1 == string2 ? 0/1 : 0.2/StrLen(string1))    ;either identical or (assumption:) "only one" char with different case
  If (string1 = "" OR string2 = "")
    Return (string1 = string2 ? 0/1 : 1/1)
  StringSplit, n, string1
  StringSplit, m, string2
  ni := 1, mi := 1, lcs := 0
  While((ni <= n0) AND (mi <= m0)) {
    If (n%ni% == m%mi%)
      EnvAdd, lcs, 1
    Else If (n%ni% = m%mi%)
      EnvAdd, lcs, 0.8
    Else{
      Loop, %maxOffset%  {
        oi := ni + A_Index, pi := mi + A_Index
        If ((n%oi% = m%mi%) AND (oi <= n0)){
            ni := oi, lcs += (n%oi% == m%mi% ? 1 : 0.8)
            Break
        }
        If ((n%ni% = m%pi%) AND (pi <= m0)){
            mi := pi, lcs += (n%ni% == m%pi% ? 1 : 0.8)
            Break
        }
      }
    }
    EnvAdd, ni, 1
    EnvAdd, mi, 1
  }
  Return ((n0 + m0)/2 - lcs) / (n0 > m0 ? n0 : m0)
}