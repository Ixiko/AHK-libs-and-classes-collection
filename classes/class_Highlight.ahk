; Link:        https://www.autohotkey.com/boards/viewtopic.php?f=6&t=28349&hilit=Highlight
; Author:   Iseahound
; Date:     2017-20-02
; for:     	AHK_L

/*

   CapsLock::
      KeyWait, CapsLock                      ; wait for Capslock to be released
      KeyWait, CapsLock, D T0.2              ; and pressed again within 0.2 seconds
      if ErrorLevel
         return
      else if (A_PriorKey = "CapsLock")
         SetCapsLockState, % GetKeyState("CapsLock","T") ? "Off" : "On"
      return
   *CapsLock:: return                        ; This forces capslock into a modifying key.

   #If, GetKeyState("CapsLock", "P") ;Your CapsLock hotkeys go below
   a::         Highlight.style.case(, "lower")
   s::         Highlight.style.case(, "upper")
   d::         Highlight.style.case(, "sentence")
   f::         Highlight.style.case(, "title")
   +a::        Highlight.style.normal()
   +s::        Highlight.style.serif_bold()
   +d::        Highlight.style.serif_italic()
   +f::        Highlight.style.serif_bold_italic()
   ^a::        Highlight.style.sansSerif()
   ^s::        Highlight.style.sansSerif_bold()
   ^d::        Highlight.style.sansSerif_italic()
   ^f::        Highlight.style.sansSerif_bold_italic()
   ^+a::       Highlight.style.normal()
   ^+s::       Highlight.style.normal()
   ^+d::       Highlight.style.script()
   ^+f::       Highlight.style.script_bold()
   #If

*/


class Highlight {

   Copy() {
      AutoTrim Off
      c := ClipboardAll
      Clipboard := ""             ; Must start off blank for detection to work.
      Send, ^c
      ClipWait 0.5
      if ErrorLevel
         return
      t := Clipboard
      Clipboard := c
      VarSetCapacity(c, 0)
      return t
   }

   Paste(t) {
      c := ClipboardAll
      Clipboard := t
      Send, ^v
      Sleep 50                    ; Don't change clipboard while it is pasted! (Sleep > 0)
      Clipboard := c
      VarSetCapacity(c, 0)        ; Free memory
      AutoTrim On
   }

   class Case {

      Lower(data := "") {
         text := (data == "") ? Highlight.copy() : data
         StringLower, lower, text
         return (data == "") ? Highlight.paste(lower) : lower
      }

      Upper(data := "") {
         text := (data == "") ? Highlight.copy() : data
         StringUpper, upper, text
         return (data == "") ? Highlight.paste(upper) : upper
      }

      Title(data := "") {
         text := (data == "") ? Highlight.copy() : data
         StringUpper, title, text, T
         return (data == "") ? Highlight.paste(title) : title
      }

      Sentence(data := "") {
         text := (data == "") ? Highlight.copy() : data
         X := "I,LOL"
         S := ""
         T := RegExReplace(text, "[\.\!\?]\s+|\R+|\t+", "$0þ")
         Loop Parse, T, þ
         {
            StringLower L, A_LoopField
            I := Chr(Asc(A_LoopField))
            StringUpper I, I
            S .= I SubStr(L,2)
         }
         Loop Parse, X, `,
            S := RegExReplace(S, "i)\b" A_LoopField "\b", A_LoopField)
         return (data == "") ? Highlight.paste(S) : S
      }
   }


   Normalize(data) {
      abstract := Object() ; so long, fiorelsa
      i := 1
      Loop % StrLen(data) {
         character := Ord(SubStr(data, i, 2))
         i += (character > 65535) ? 2 : 1
         ; Serif Normal aka ASCII
         if ((character >= 0x30 && character <= 0x39) || (character >= 0x41 && character <= 0x5A) || (character >= 0x61 && character <= 0x7A)) {
            abstract[1,A_Index] := 0
            abstract[2,A_Index] := 0
            abstract[3,A_Index] := 0
            if (character >= 0x41 && character <= 0x5A)
               sentence .= Chr(character)
            if (character >= 0x61 && character <= 0x7A)
               sentence .= Chr(character)
            if (character >= 0x30 && character <= 0x39)
               sentence .= Chr(character)
         }
         ; Serif Bold
         else if ((character >= 0x1D400 && character <= 0x1D433) ||  (character >= 0x1D7CE && character <= 0x1D7D7)) {
            abstract[1,A_Index] := (0x1D400 - 0x41)
            abstract[2,A_Index] := (0x1D41A - 0x61)
            abstract[3,A_Index] := (0x1D7CE - 0x30)
            if (character >= 0x1D400 && character <= 0x1D419)
               sentence .= Chr(character - abstract[1,A_Index])
            if (character >= 0x1D41A && character <= 0x1D433)
               sentence .= Chr(character - abstract[2,A_Index])
            if (character >= 0x1D7CE && character <= 0x1D7D7)
               sentence .= Chr(character - abstract[3,A_Index])
         }
         ; Serif Italic
         else if (character >= 0x1D434 && character <= 0x1D467) {
            abstract[1,A_Index] := (0x1D434 - 0x41)
            abstract[2,A_Index] := (0x1D44E - 0x61)
            if (character >= 0x1D434 && character <= 0x1D44D)
               sentence .= Chr(character - abstract[1,A_Index])
            if (character >= 0x1D44E && character <= 0x1D467)
               sentence .= Chr(character - abstract[2,A_Index])
         }
         ; Serif Bold & Italic
         else if (character >= 0x1D468 && character <= 0x1D49B) {
            abstract[1,A_Index] := (0x1D468 - 0x41)
            abstract[2,A_Index] := (0x1D482 - 0x61)
            if (character >= 0x1D468 && character <= 0x1D481)
               sentence .= Chr(character - abstract[1,A_Index])
            if (character >= 0x1D482 && character <= 0x1D49B)
               sentence .= Chr(character - abstract[2,A_Index])
         }
         ; Sans Serif Normal
         else if ((character >= 0x1D5A0 && character <= 0x1D5D3) ||  (character >= 0x1D7E2 && character <= 0x1D7EB)) {
            abstract[1,A_Index] := (0x1D5A0 - 0x41)
            abstract[2,A_Index] := (0x1D5BA - 0x61)
            abstract[3,A_Index] := (0x1D7E2 - 0x30)
            if (character >= 0x1D5A0 && character <= 0x1D5B9)
               sentence .= Chr(character - abstract[1,A_Index])
            if (character >= 0x1D5BA && character <= 0x1D5D3)
               sentence .= Chr(character - abstract[2,A_Index])
            if (character >= 0x1D7E2 && character <= 0x1D7EB)
               sentence .= Chr(character - abstract[3,A_Index])
         }
         ; Sans Serif Bold
         else if ((character >= 0x1D5D4 && character <= 0x1D607) ||  (character >= 0x1D7EC && character <= 0x1D7F5)) {
            abstract[1,A_Index] := (0x1D5D4 - 0x41)
            abstract[2,A_Index] := (0x1D5EE - 0x61)
            abstract[3,A_Index] := (0x1D7EC - 0x30)
            if (character >= 0x1D5D4 && character <= 0x1D5ED)
               sentence .= Chr(character - abstract[1,A_Index])
            if (character >= 0x1D5EE && character <= 0x1D607)
               sentence .= Chr(character - abstract[2,A_Index])
            if (character >= 0x1D7EC && character <= 0x1D7F5)
               sentence .= Chr(character - abstract[3,A_Index])
         }
         ; Sans Serif Italic
         else if (character >= 0x1D608 && character <= 0x1D63B) {
            abstract[1,A_Index] := (0x1D608 - 0x41)
            abstract[2,A_Index] := (0x1D622 - 0x61)
            if (character >= 0x1D608 && character <= 0x1D621)
               sentence .= Chr(character - abstract[1,A_Index])
            if (character >= 0x1D622 && character <= 0x1D63B)
               sentence .= Chr(character - abstract[2,A_Index])
         }
         ; Sans Serif Bold & Italic
         else if (character >= 0x1D63C && character <= 0x1D66F) {
            abstract[1,A_Index] := (0x1D63C - 0x41)
            abstract[2,A_Index] := (0x1D656 - 0x61)
            if (character >= 0x1D63C && character <= 0x1D655)
               sentence .= Chr(character - abstract[1,A_Index])
            if (character >= 0x1D656 && character <= 0x1D66F)
               sentence .= Chr(character - abstract[2,A_Index])
         }
         ; Script
         else if (character >= 0x1D49C && character <= 0x1D4CF) {
            abstract[1,A_Index] := (0x1D49C - 0x41)
            abstract[2,A_Index] := (0x1D4B6 - 0x61)
            if (character >= 0x1D49C && character <= 0x1D4B5)
               sentence .= Chr(character - abstract[1,A_Index])
            if (character >= 0x1D4B6 && character <= 0x1D4CF)
               sentence .= Chr(character - abstract[2,A_Index])
         }
         ; Script Bold
         else if (character >= 0x1D4D0 && character <= 0x1D503) {
            abstract[1,A_Index] := (0x1D4D0 - 0x41)
            abstract[2,A_Index] := (0x1D4EA - 0x61)
            if (character >= 0x1D4D0 && character <= 0x1D4E9)
               sentence .= Chr(character - abstract[1,A_Index])
            if (character >= 0x1D4EA && character <= 0x1D503)
               sentence .= Chr(character - abstract[2,A_Index])
         }


         ; Serif Italic - Replacements
         if (character == 0x1D43B || character == 0x210E) { ;h
            abstract[1,A_Index] := (0x1D43B - 0x48)
            abstract[2,A_Index] := (0x210E - 0x68)
            sentence .= (character == 0x210E) ? Chr(character - abstract[2,A_Index]) : ""
         }
         ; Script - Replacements
         else if (character == 0x212C || character == 0x1D4B7) { ;B
            abstract[1,A_Index] := (0x212C - 0x42)
            abstract[2,A_Index] := (0x1D4B7 - 0x62)
            sentence .= (character == 0x212C) ? Chr(character - abstract[1,A_Index]) : ""
         }
         else if (character == 0x2130 || character == 0x212F) { ;E & e
            abstract[1,A_Index] := (0x2130 - 0x45)
            abstract[2,A_Index] := (0x212F - 0x65)
            sentence .= (character == 0x2130) ? Chr(character - abstract[1,A_Index]) : ""
            sentence .= (character == 0x212F) ? Chr(character - abstract[2,A_Index]) : ""
         }
         else if (character == 0x2131 || character == 0x1D4BB) { ;F
            abstract[1,A_Index] := (0x2131 - 0x46)
            abstract[2,A_Index] := (0x1D4BB - 0x66)
            sentence .= (character == 0x2131) ? Chr(character - abstract[1,A_Index]) : ""
         }
         else if (character == 0x210B || character == 0x1D4BD) { ;H
            abstract[1,A_Index] := (0x210B - 0x48)
            abstract[2,A_Index] := (0x1D4BD - 0x68)
            sentence .= (character == 0x210B) ? Chr(character - abstract[1,A_Index]) : ""
         }
         else if (character == 0x2110 || character == 0x1D4BE) { ;I
            abstract[1,A_Index] := (0x2110 - 0x49)
            abstract[2,A_Index] := (0x1D4BE - 0x69)
            sentence .= (character == 0x2110) ? Chr(character - abstract[1,A_Index]) : ""
         }
         else if (character == 0x2112 || character == 0x1D4C1) { ;L
            abstract[1,A_Index] := (0x2112 - 0x4C)
            abstract[2,A_Index] := (0x1D4C1 - 0x6C)
            sentence .= (character == 0x2112) ? Chr(character - abstract[1,A_Index]) : ""
         }
         else if (character == 0x2133 || character == 0x1D4C2) { ;M
            abstract[1,A_Index] := (0x2133 - 0x4D)
            abstract[2,A_Index] := (0x1D4C2 - 0x6D)
            sentence .= (character == 0x2133) ? Chr(character - abstract[1,A_Index]) : ""
         }
         else if (character == 0x211B || character == 0x1D4C7) { ;R
            abstract[1,A_Index] := (0x211B - 0x52)
            abstract[2,A_Index] := (0x1D4C7 - 0x72)
            sentence .= (character == 0x211B) ? Chr(character - abstract[1,A_Index]) : ""
         }
         else if (character == 0x1D4A2 || character == 0x210A) { ;g
            abstract[1,A_Index] := (0x1D4A2 - 0x47)
            abstract[2,A_Index] := (0x210A - 0x67)
            sentence .= (character == 0x210A) ? Chr(character - abstract[2,A_Index]) : ""
         }
         else if (character == 0x1D4AA || character == 0x2134) { ;o
            abstract[1,A_Index] := (0x1D4AA - 0x4F)
            abstract[2,A_Index] := (0x2134 - 0x6F)
            sentence .= (character == 0x2134) ? Chr(character - abstract[2,A_Index]) : ""
         }


         if (abstract[1,A_Index] == "" && abstract[2,A_Index] == "" && abstract[3,A_Index] == "")
            sentence .= Chr(character)
      }
      abstract[0] := sentence
      return abstract
   }

   ReNormalize(abstract) {
      discourse := abstract[0]
      i := 1
      Loop % StrLen(discourse) {
         character := Ord(SubStr(discourse, i, 2))
         i += (character > 65535) ? 2 : 1
         if (character >= 0x30 && character <= 0x39)
            sentence .= Chr(character + abstract[3,A_Index])
         else if (character >= 0x41 && character <= 0x5A)
            sentence .= Chr(character + abstract[1,A_Index])
         else if (character >= 0x61 && character <= 0x7A)
            sentence .= Chr(character + abstract[2,A_Index])
         else
            sentence .= Chr(character)
      }
      return sentence
   }


   class Style {

      Case(data := "", case := "") {
         abstract := Highlight.normalize((data == "") ? Highlight.copy() : data)
         if (case == "upper")
            abstract[0] := Highlight.case.UPPER(abstract[0])
         if (case == "lower")
            abstract[0] := Highlight.case.lower(abstract[0])
         if (case == "title")
            abstract[0] := Highlight.case.Title(abstract[0])
         if (case == "sentence")
            abstract[0] := Highlight.case.sentence(abstract[0])
         publication := Highlight.reNormalize(abstract)
         return (data == "") ? Highlight.paste(publication) : publication
      }

      Normal(data := "") {
         abstract := Highlight.normalize((data == "") ? Highlight.copy() : data)
         return (data == "") ? Highlight.paste(abstract[0]) : abstract[0]
      }

      Serif_Bold(data := "") {
         abstract := Highlight.normalize((data == "") ? Highlight.copy() : data)
         discourse := abstract[0]
         i := 1
         Loop % StrLen(discourse) {
            character := Ord(SubStr(discourse, i, 2))
            i += (character > 65535) ? 2 : 1
            publication .= (character >= 0x30 && character <= 0x39) ? Chr(character + (0x1D7CE - 0x30)) : ""            ;numeric
            publication .= (character >= 0x41 && character <= 0x5A) ? Chr(character + (0x1D400 - 0x41)) : ""            ;UPPERCASE
            publication .= (character >= 0x61 && character <= 0x7A) ? Chr(character + (0x1D41A - 0x61)) : ""            ;lowercase
            publication .= (!(character >= 0x30 && character <= 0x39) && !(character >= 0x41 && character <= 0x5A) && !(character >= 0x61 && character <= 0x7A) ) ? Chr(character) : ""
         }
         return (data == "") ? Highlight.paste(publication) : publication
      }

      Serif_Italic(data := "") {
         abstract := Highlight.normalize((data == "") ? Highlight.copy() : data)
         discourse := abstract[0]
         i := 1
         Loop % StrLen(discourse) {
            character := Ord(SubStr(discourse, i, 2))
            i += (character > 65535) ? 2 : 1
            publication .= (character >= 0x41 && character <= 0x5A) ? Chr(character + (0x1D434 - 0x41)) : ""            ;UPPERCASE
            publication .= (character >= 0x61 && character <= 0x7A) ? Chr(character + (0x1D44E - 0x61)) : ""            ;lowercase
            publication .= (!(character >= 0x41 && character <= 0x5A) && !(character >= 0x61 && character <= 0x7A) ) ? Chr(character) : ""
         }
         publication := StrReplace(publication, Chr(0x1D455), Chr(0x210E))
         return (data == "") ? Highlight.paste(publication) : publication
      }

      Serif_Bold_Italic(data := "") {
         abstract := Highlight.normalize((data == "") ? Highlight.copy() : data)
         discourse := abstract[0]
         i := 1
         Loop % StrLen(discourse) {
            character := Ord(SubStr(discourse, i, 2))
            i += (character > 65535) ? 2 : 1
            publication .= (character >= 0x41 && character <= 0x5A) ? Chr(character + (0x1D468 - 0x41)) : ""            ;UPPERCASE
            publication .= (character >= 0x61 && character <= 0x7A) ? Chr(character + (0x1D482 - 0x61)) : ""            ;lowercase
            publication .= (!(character >= 0x41 && character <= 0x5A) && !(character >= 0x61 && character <= 0x7A) ) ? Chr(character) : ""
         }
         return (data == "") ? Highlight.paste(publication) : publication
      }

      SansSerif(data := "") {
         abstract := Highlight.normalize((data == "") ? Highlight.copy() : data)
         discourse := abstract[0]
         i := 1
         Loop % StrLen(discourse) {
            character := Ord(SubStr(discourse, i, 2))
            i += (character > 65535) ? 2 : 1
            publication .= (character >= 0x30 && character <= 0x39) ? Chr(character + (0x1D7E2 - 0x30)) : ""            ;numeric
            publication .= (character >= 0x41 && character <= 0x5A) ? Chr(character + (0x1D5A0 - 0x41)) : ""            ;UPPERCASE
            publication .= (character >= 0x61 && character <= 0x7A) ? Chr(character + (0x1D5BA - 0x61)) : ""            ;lowercase
            publication .= (!(character >= 0x30 && character <= 0x39) && !(character >= 0x41 && character <= 0x5A) && !(character >= 0x61 && character <= 0x7A) ) ? Chr(character) : ""
         }
         return (data == "") ? Highlight.paste(publication) : publication
      }

      SansSerif_Bold(data := "") {
         abstract := Highlight.normalize((data == "") ? Highlight.copy() : data)
         discourse := abstract[0]
         i := 1
         Loop % StrLen(discourse) {
            character := Ord(SubStr(discourse, i, 2))
            i += (character > 65535) ? 2 : 1
            publication .= (character >= 0x30 && character <= 0x39) ? Chr(character + (0x1D7EC - 0x30)) : ""            ;numeric
            publication .= (character >= 0x41 && character <= 0x5A) ? Chr(character + (0x1D5D4 - 0x41)) : ""            ;UPPERCASE
            publication .= (character >= 0x61 && character <= 0x7A) ? Chr(character + (0x1D5EE - 0x61)) : ""            ;lowercase
            publication .= (!(character >= 0x30 && character <= 0x39) && !(character >= 0x41 && character <= 0x5A) && !(character >= 0x61 && character <= 0x7A) ) ? Chr(character) : ""
         }
         return (data == "") ? Highlight.paste(publication) : publication
      }

      SansSerif_Italic(data := "") {
         abstract := Highlight.normalize((data == "") ? Highlight.copy() : data)
         discourse := abstract[0]
         i := 1
         Loop % StrLen(discourse) {
            character := Ord(SubStr(discourse, i, 2))
            i += (character > 65535) ? 2 : 1
            publication .= (character >= 0x41 && character <= 0x5A) ? Chr(character + (0x1D608 - 0x41)) : ""            ;UPPERCASE
            publication .= (character >= 0x61 && character <= 0x7A) ? Chr(character + (0x1D622 - 0x61)) : ""            ;lowercase
            publication .= (!(character >= 0x41 && character <= 0x5A) && !(character >= 0x61 && character <= 0x7A) ) ? Chr(character) : ""
         }
         return (data == "") ? Highlight.paste(publication) : publication
      }

      SansSerif_Bold_Italic(data := "") {
         abstract := Highlight.normalize((data == "") ? Highlight.copy() : data)
         discourse := abstract[0]
         i := 1
         Loop % StrLen(discourse) {
            character := Ord(SubStr(discourse, i, 2))
            i += (character > 65535) ? 2 : 1
            publication .= (character >= 0x41 && character <= 0x5A) ? Chr(character + (0x1D63C - 0x41)) : ""            ;UPPERCASE
            publication .= (character >= 0x61 && character <= 0x7A) ? Chr(character + (0x1D656 - 0x61)) : ""            ;lowercase
            publication .= (!(character >= 0x41 && character <= 0x5A) && !(character >= 0x61 && character <= 0x7A) ) ? Chr(character) : ""
         }
         return (data == "") ? Highlight.paste(publication) : publication
      }

      Script(data := "") {
         abstract := Highlight.normalize((data == "") ? Highlight.copy() : data)
         discourse := abstract[0]
         i := 1
         Loop % StrLen(discourse) {
            character := Ord(SubStr(discourse, i, 2))
            i += (character > 65535) ? 2 : 1
            publication .= (character >= 0x41 && character <= 0x5A) ? Chr(character + (0x1D49C - 0x41)) : ""            ;UPPERCASE
            publication .= (character >= 0x61 && character <= 0x7A) ? Chr(character + (0x1D4B6 - 0x61)) : ""            ;lowercase
            publication .= (!(character >= 0x41 && character <= 0x5A) && !(character >= 0x61 && character <= 0x7A) ) ? Chr(character) : ""
         }
         publication := StrReplace(publication, Chr(0x1D49D), Chr(0x212C))
         publication := StrReplace(publication, Chr(0x1D4A0), Chr(0x2130))
         publication := StrReplace(publication, Chr(0x1D4A1), Chr(0x2131))
         publication := StrReplace(publication, Chr(0x1D4A3), Chr(0x210B))
         publication := StrReplace(publication, Chr(0x1D4A4), Chr(0x2110))
         publication := StrReplace(publication, Chr(0x1D4A7), Chr(0x2112))
         publication := StrReplace(publication, Chr(0x1D4A8), Chr(0x2133))
         publication := StrReplace(publication, Chr(0x1D4AD), Chr(0x211B))
         publication := StrReplace(publication, Chr(0x1D4BA), Chr(0x212F))
         publication := StrReplace(publication, Chr(0x1D4BC), Chr(0x210A))
         publication := StrReplace(publication, Chr(0x1D4C4), Chr(0x2134))
         return (data == "") ? Highlight.paste(publication) : publication
      }

      Script_Bold(data := "") {
         abstract := Highlight.normalize((data == "") ? Highlight.copy() : data)
         discourse := abstract[0]
         i := 1
         Loop % StrLen(discourse) {
            character := Ord(SubStr(discourse, i, 2))
            i += (character > 65535) ? 2 : 1
            publication .= (character >= 0x41 && character <= 0x5A) ? Chr(character + (0x1D4D0 - 0x41)) : ""            ;UPPERCASE
            publication .= (character >= 0x61 && character <= 0x7A) ? Chr(character + (0x1D4EA - 0x61)) : ""            ;lowercase
            publication .= (!(character >= 0x41 && character <= 0x5A) && !(character >= 0x61 && character <= 0x7A) ) ? Chr(character) : ""
         }
         return (data == "") ? Highlight.paste(publication) : publication
      }
   }
}
