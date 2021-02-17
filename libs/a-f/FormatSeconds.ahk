; Title:
; Link:   	https://github.com/boulmers/DigiHotkey/blob/df1c4ce586f267267f1a83f61c7ad78f46dc64a2/src/Tools.ahk
; Author:
; Date:
; for:     	AHK_L

/*


*/

FormatSeconds( s_ ) {
    sec  := 1,    min  := 60*sec,  hour := 60*min

    h := s_ // hour		, s_ := Mod( s_, hour )
    m := s_ // min	    , s_ := Mod( s_, min  )
    s := Round( s_, 0)

    time :=  Format("{:02} : {:02} : {:02}", h, m, s)

    return time
}