;#NoTrayIcon
#SingleInstance force
/** Return decimal color of anay type of $color
 * 
 *  $dec := Color_ToDecimal( "128,128,128" )
 *  $dec := Color_ToDecimal( "rgb(128,128,128)" )
 *  $dec := Color_ToDecimal( "#808080" )
 * 
*/
Color_ToDecimal($color){
	;dump($color, 50)
	$type := Color_getColorType($color)
	if ( $type == "RGB" )
		return % Color_rgbTodecimal($color)
	if ( $type == "HEX" )
		return % Color_HexToDecimal($color)
}


/** Return color type
 * 
 *  Color_getColorType( "rgb(0, 0, 0)" ) 	RETURN "RGB"
 *  Color_getColorType( "#606060" ) 	RETURN "HEX"
 *  Color_getColorType( 8421504 ) 	RETURN "DEC"
 * 
*/
Color_getColorType($color){

	$RGB_match_count := RegExMatch( $color, "rgb", $RGB_match )
		if ( $RGB_match_count > 0 )
			return "RGB"

	$HEX_match_count := RegExMatch( $color, "#", $HEX_match )
		if ( $HEX_match_count > 0 )
			return "HEX"
	$DEC_match_count := RegExMatch( $color, "\d+", $DEC_match )
		if ( $DEC_match_count > 0 )
			return "DEC"
}


/** DECIMAL TO RGB
 * 
 *  $rgb := Color_decimnalTOrgb(8421504)	; RETURN "rgb(128,128,128)"
 * 
*/
Color_decimnalTOrgb($decimal){
	return % Color_hexTOrgb(Color_decimalTOhex( $decimal ))
}

/** RGB TO DECIMAL
 * 
 *  $decimal := Color_rgbTOdecimal("rgb(128,128,128)")	; RETURN #808080
 *  $decimal := Color_rgbTOdecimal(("128,128,128")		; RETURN #808080
 * 
*/
Color_rgbTodecimal($rgb){
	return % Color_HexToDecimal(Color_rgbTOhex( $rgb ))
}
/** RGB TO HEX
 * 
 *  $hex := Color_rgbTOhex("128,128,128")		; RETURN #808080
 *  $hex := Color_rgbTOhex("rgb (128,128,128)")		; RETURN #808080
 *  dump($hex, 50)
*/
Color_rgbTOhex($rgb){
	$needle = rgb
	IfInString, $rgb, %$needle%
		RegExMatch( $rgb, "\s*rgb\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)\s*", $rgb )
	else
		StringSplit, $rgb, $rgb, "`,"


   SetFormat, Integer, % (f := A_FormatInteger) = "D" ? "H" : f
   $hex := $rgb1 + 0 . $rgb2 + 0 . $rgb3 + 0
   SetFormat, Integer, %f%
   Return, "#" . RegExReplace(RegExReplace($hex, "0x(.)(?=$|0x)", "0$1"), "0x")

}

/** DECIMAL TO HEX		https://autohotkey.com/board/topic/85571-dec-hex-without-setformat-command/#entry545172
 * 
 *  $hex := Color_decimalTOhex( 8421504 ) ; RETURN #808080
*/
Color_decimalTOhex( $int, $pad=0 ) {

; "Pad" may be the minimum number of digits that should appear on the right of the "0x".
	Static $hx := "0123456789ABCDEF"
	If !( 0 < $int |= 0 )
		Return !$int ? "0x0" : "-" Color_decimalTOhex( -$int, $pad )

	$s := 1 + Floor( Ln( $int ) / Ln( 16 ) )
	$h := SubStr( "0x0000000000000000", 1, $pad := $pad < $s ? $s + 2 : $pad < 16 ? $pad + 2 : 18 )
	$u := A_IsUnicode = 1

	Loop % $s
		NumPut( *( &$hx + ( ( $int & 15 ) << $u ) ), $h, $pad - A_Index << $u, "UChar" ), $int >>= 4

	Return $h
}
/** HEX Color TO RGB	https://autohotkey.com/boards/viewtopic.php?t=3925#post_content21139
 * 
 *  $rgb := Color_hexTOrgb("0x77c8d2")        ; "rgb(119,200,210)
 *  $rgb := Color_hexTOrgb("#77c8d2")         ; "rgb(119,200,210)
 *  $rgb := Color_hexTOrgb("77c8d2")          ; "rgb(119,200,210)
*/
Color_hexTOrgb($hex){
    $hex := InStr($hex, "0x") ? $hex : (InStr($hex, "#") ? "0x" SubStr($hex, 2) : "0x" $hex)
    return "rgb(" ($hex & 0xFF0000) >> 16 "," ($hex & 0xFF00) >> 8 "," ($hex & 0xFF) ")"
}
/** Decimal numbrer TO HEX number
 * 
 *  $decimal := Color_HexToDecimal("#808080") ; RETURN 8421504
*/
Color_HexToDecimal($hex){

    static _0:=0,_1:=1,_2:=2,_3:=3,_4:=4,_5:=5,_6:=6,_7:=7,_8:=8,_9:=9,_a:=10,_b:=11,_c:=12,_d:=13,_e:=14,_f:=15
    $hex:=ltrim($hex,"0x `t`n`r"),   len := StrLen($hex),  $decimal:=0
    Loop,Parse,$hex
        $decimal += _%A_LoopField%*(16**(len-A_Index))
    return $decimal

}
/** RGBdiff() https://autohotkey.com/board/topic/150110-pixelsearch-multiple-color-checks/#post_id_735228
 * 
 *  ; RETURN difference between two colors
*/
Color_diff(color1, color2=0){
	r1 := (color1 & 0xFF0000) >> 16
	g1 := (color1 & 0xFF00) >> 8
	b1 := (color1 & 0xFF)
	r2 := (color2 & 0xFF0000) >> 16
	g2 := (color2 & 0xFF00) >> 8
	b2 := (color2 & 0xFF)
	dr := Abs(r1-r2)
	dg := Abs(g1-g2)
	db := Abs(b1-b2)
	return (dr > dg) && (dr > db) ? (dr) : ((dg > db) ? (dg) : (db))
}
