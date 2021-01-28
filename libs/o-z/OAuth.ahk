/*
	###############################################################################################################
	##                                   OAuth Function Library. Version 1.03                                    ##
	###############################################################################################################

	Copyright � 2011-2012 [VxE]. All rights reserved.

	Redistribution and use in source and binary forms, with or without modification, are permitted provided that
	the following conditions are met:

	1. Redistributions of source code must retain the above copyright notice, this list of conditions and the
	following disclaimer.

	2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
	following disclaimer in the documentation and/or other materials provided with the distribution.

	3. The name "[VxE]" may not be used to endorse or promote products derived from this software without specific
	prior written permission.

	THIS SOFTWARE IS PROVIDED BY [VxE] "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
	TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
	SHALL [VxE] BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
	BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
	TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
	THE POSSIBILITY OF SUCH DAMAGE.

	---------------------------------------------------------------------------------------------------------------

	Source is freely available at: http://www.autohotkey.com/forum/viewtopic.php?t=74308
	MUFL-Info: http://dl.dropbox.com/u/13873642/mufl_oauth.txt

	This is the INcompatible successor of my previous OAuth library. This library focuses on the Authorization
	header ( http://oauth.net/core/1.0/ ) and generating the signature for it. Some of the changes are:

	- Credentials are NOT kept in pseudo-variable functions. The user must assemble their credentials ( token,
	consumer key, secret key, etc... ) in a structured string, which is then passed to the main function.

	- This library does NOT handle the actual HTTP transactions OR the responses. It is up to the user to
	submit HTTP requests WITH the header returned by OAuth_Authorization() AND parse the response.

	Fontend Functions:

	OAuth_Authorization - Calculates the signature and generates the 'Authorization' header for the request.

	OAuth_LastSignature - Stores the most recent signature base string and signature for debugging purposes.

	OAuth_Timestamp     - Returns an OAuth 1.0a compliant timestamp.

	Backend Funtions:

	OAuth__URIEncode    - Percent encodes unreserved characters in a string, optionally converting to UTF-8.

	OAuth__Lookup       - Retrieves values from a list of key/value pairs.

	OAuth__HexToB64     - Converts a hexadecimal string to base 64.

	Bonus Functions:

	SHA1                - Calculates the SHA1 hash of a byte stream

	HMAC                - Calculates the HMAC for a key and message.

	Notes:

	The value passed to the first parameter of 'OAuth_Authorization', called 'Credentials', should be a lookup
	list containing the following keys: 'oauth_consumer_key' and 'oauth_consumer_secret', and may contain
	other OAuth related key/value pairs, such as 'oauth_callback', 'oauth_token', 'oauth_token_secret' or
	'oauth_verifier', depending on the type of API call (please familiarize yourself with the OAuth token
	exchange flow). A lookup list is a collection of key/value pairs, separated by newlines, where each key
	is separated from its associated value by an equals sign ('=', asc 61). Here's an example:
	Credentials := "oauth_consumer_key=GDdmIQH6jhtmLUypg82g`noauth_callback=oob"

*/

OAuth_Authorization( Credentials, URL, Extra_Parameters = "", Method = "GET" ) { ; ----------------------------
; Calculates an OAuth v1.0 compatible signature and returns the 'Authorization' header for the request.
; The first parameter, 'Credentials', must be a lookup list containing your Consumer Key, Consumer Secret,
; Token and Token Secret ( the last two should be omitted if the URL points to a 'request_token' endpoint).
; The second parameter must be the URL you're about to call. The third parameter must be any additional
; parameters of the request that don't appear in the URL (e.g: application/x-www-form-urlencoded POST data).
; Finally, the fourth parameter may be the http verb used to submit the request. By default, the verb is 'GET'.
; The query portion of the url must already be uriencoded, otherwise the signature will be invalid.
Static E := "oauth_", Hardcoded_Defaults := "`noauth_signature_method=HMAC-SHA1`noauth_version=1.0"
, Required_OAuth := "callback,consumer_key,nonce,signature_method,timestamp,token,verifier,version"

; Generate the nonce and append it and the default required parameter values to the credentials list.
oel := ErrorLevel
Random, Vx, -2147483648, 2147483647
Vx := OAuth__URIEncode( OAuth__HexToB64( SHA1( Vx := A_Now A_MSec Vx ) ) )
Credentials .= "`noauth_nonce=" Vx "`noauth_timestamp=" OAuth_Timestamp() Hardcoded_Defaults
VarSetCapacity( Vx, 2048 >> !A_IsUnicode, 0 )
; Split the URL, first separating the query parameters from the uri, and enforce character case rules.
p1 := InStr( URL "/", "/", 0, 3 + InStr( URL, "://" ) )
p2 := InStr( URL "?", "?", 0, p1 )
StringLeft, host, URL, p1 - 1
StringLower, host, host
host .= SubStr( URL, p1, p2 - p1 )
StringTrimLeft, URL, URL, p2
StringUpper, Method, Method

; Parse the parameters, creating a newline-delimited list of tab-separated key/value pairs.
URL .= "&" Extra_Parameters
Loop, Parse, URL, &?
{
	StringReplace, URL, A_LoopField, =, % "`t"
	If !( ErrorLevel )
	Vx .= "`n" URL
}

; Add required parameters if they are available in the credentials list. This is why we put the defualt values
; into the credentials list. If the oauth_token is NOT in the credentials list, just skip it.
Loop, Parse, Required_OAuth, `,
If !InStr( Vx, "`n" E A_LoopField "`t" ) && InStr( "`n" Credentials, "`n" E A_LoopField "=" )
Vx .= "`n" E A_LoopField "`t" OAuth__Lookup( Credentials, E A_LoopField )

; Get the name of the hash function ( SHA1 by default ) used to generate the HMAC. The HMAC function checks
; whether the hash function exists or not, so we won't bother with that here.
n := 29 + InStr( Vx, "`noauth_signature_method`tHMAC-" )
StringMid, hashfunc, Vx, n, InStr( Vx, "`n", 0, n ) - n

; Sort the parameters lexicographically. Here's the reason why tabs are used instead of '=': "Param1=ABC" sorts
; AFTER "Param10=DEF", since '=' (asc 61) is greater than '0' (asc 48). Tab is asc 09, and it sorts before any
; printable character, making "Param1`tABC" correctly sort before "Param10`tDEF".
StringTrimLeft, Vx, Vx, 1
Sort, Vx, C

; Make a copy the sorted parameter list, then convert tabs to '=' and newlines to '&' and generate the HMAC.
URL := Vx
StringReplace, Vx, Vx, % "`t", =, A
StringReplace, Vx, Vx, `n, &, A

global Unencoded_Formed_URL := host . "?" . Vx


Vx := Method "&" OAuth__URIEncode( host ) "&" OAuth__URIEncode( Vx )
Method := OAuth__Lookup( Credentials, E "consumer_secret" ) "&" OAuth__Lookup( Credentials, E "token_secret" )
OAuth_LastSignature( Vx "`n`n" host := OAuth__URIEncode( OAuth__HexToB64( HMAC( hashfunc, Method, Vx ))))

global Unencoded_Signed_URL := host

; Assemble the authorization header with the parameters list and the signature.
Vx := Unencoded_Formed_URL
;Loop, Parse, URL, `n,`n
;If InStr( A_LoopField, E ) = 1
;Loop, Parse, A_LoopField, % "`t",`n
;Vx .= A_Index = 1 ? A_LoopField : "=" A_LoopField "&"

; Return the signed authorization header.
Return Vx "&" E "signature=" host , ErrorLevel := oel
} ; OAuth_Authorization( Credentials, URL, Extra_Parameters = "", Method = "GET" ) ----------------------------

OAuth_LastSignature( string="" ) { ; --------------------------------------------------------------------------
; Caches the last message used to calculate the HMAC signature for use in debugging and/or logs.
Static x := ""
Return string = "" ? x : x := string
} ; OAuth_LastSignature( string="" ) --------------------------------------------------------------------------

OAuth_Timestamp( ServerTime="" ) { ; --------------------------------------------------------------------------
; http://oauth.net/core/1.0/#nonce "Unless otherwise specified by the Service Provider, the
; timestamp is expressed in the number of seconds since January 1, 1970 00:00:00 GMT"
; NOTE: if the computer's clock is too far off from the server's clock, you can give the timestamp
; an offset by passing the server's response timestamp to this function.
Static offset := 0
If ( ServerTime != "" ) && ( "19700101000000" < ( ServerTime := RegexReplace( ServerTime, "\D" )))
{
	offset := ServerTime
	offset -= A_NowUTC, s
}
timestamp := A_NowUTC
timestamp -= 19700101000000, s
Return SubStr( 0.0 + timestamp + offset, 1, 1 + FLOOR( LOG( timestamp + offset ) ) )
} ; OAuth_Timestamp( ServerTime="" ) --------------------------------------------------------------------------

OAuth__URIEncode( String, IsUTF8=0 ) { ; ----------------------------------------------------------------------
; Convert non-alpha, non-digit, non '-._~' characters into percent-encoded form. Characters with a code point
; higher than 127 are encoded as percent-encoded UTF-8 (even if the string is already in UTF-8).
IsUTF8 := ( 1 << 8 - !IsUTF8 ) - 1
StringLen, len, String
Loop, Parse, String
If A_LoopField IN -,.,_,~,0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
String .= A_LoopField
Else
{
	i := 2
	If ( IsUTF8 < n := Asc( A_LoopField ) )
	If ( n < 0x800 )
	i := 4, n := 0xC080 | (( n & 0x7C0 ) << 2 ) | ( n & 63 )
	Else If ( n < 0x10000 )
	i := 6, n := 0xE08080 | (( n & 0xF000 ) << 4 ) | (( n & 0xFC0 ) << 2 ) | ( n & 63 )
	Else If ( n < 0x110000 )
	i := 8, n := 0xF0808080 | (( n & 0x1C0000 ) << 6 ) | (( n & 0x3F000 ) << 4 )
	| (( n & 0xFC0 ) << 2 ) | ( n & 63 )
	Loop % i
	String .= ( A_Index & 1 ? "%" : "" ) Chr((( n >> ( i - A_Index << 2 )) & 15 )
	+ (( n >> ( i - A_Index << 2 )) & 15 < 10 ? 48 : 55 ))
}
Return SubStr( String, len + 1 )
} ; OAuth__URIEncode( String, IsUTF8=0 ) ----------------------------------------------------------------------

OAuth__Lookup( data, key, key_value_delimiter="=", row_delimiter="`n" ) { ; -----------------------------------
; Returns the value associated with the key name.
oel := ErrorLevel, data := row_delimiter data row_delimiter
StringGetPos, st, data, % row_delimiter key key_value_delimiter
If ( ErrorLevel )
Return "", ErrorLevel := oel
StringGetPos, ed, data, % row_delimiter,, st += 1 + StrLen( row_delimiter key key_value_delimiter )
return SubStr( data, st, 1 + ed - st ), ErrorLevel := oel
} ; OAuth__Lookup( data, key, key_value_delimiter="=", row_delimiter="`n" ) -----------------------------------

OAuth__HexToB64( hex ) { ; ------------------------------------------------------------------------------------
oel := ErrorLevel
StringGetPos, pos, hex, 0x
If !( ErrorLevel || pos )
StringTrimLeft, hex, hex, 2
StringLen, len, hex
VarSetCapacity( output, 2 + ( Ceil( len / 6 ) << 3 - !A_IsUnicode ), 0 )
hex .= SubStr( "00000", 1 + Mod( len + 5, 6 ) )
Loop, % len
If !Mod( A_Index - 1, 6 )
{
	StringMid, pos, hex, A_Index, 6
	Loop 4
	{
		n := ( Abs( "0x" pos ) >> 24 - A_Index * 6 ) & 63
		output .= Chr( n < 26 ? n + 65 : n < 52 ? n + 71 : n < 62 ? n - 4 : n = 62 ? 43 : 47 )
	}
}
StringTrimRight, output, output, 2 - Mod( len + 5 >> 1, 3 )
Return output SubStr( "==", 1 + Mod( len + 5 >> 1, 3 ) ), ErrorLevel := oel
} ; OAuth__HexToB64( hex ) ------------------------------------------------------------------------------------

SHA1( byref data, len=-1 ) { ; ---------------------------------------------------------------------
; This implementation of the SHA1 algorithm was written by [VxE] on 09-13-2010.
Static m32 := 0xffffffff
If ( len < 0 )
Stringlen, len, data
_a := 0x67452301, _b := 0xEFCDAB89, _c := 0x98BADCFE, _d := 0x10325476, _e := 0xC3D2E1F0

Loop % blocks := ( len + 8 >> 6 ) + 1
{
	VarSetCapacity( block, 320, 0 )
	a := _a, b := _b, c := _c, d := _d, e := _e

	If ( len - 64 >= o := A_Index - 1 << 6 )
	DllCall("RtlMoveMemory", "UInt", &block, "UInt", &data + o, "Int", 64 )
	Else If ( len - o > 0 )
	DllCall("RtlMoveMemory", "UInt", &block, "UInt", &data + o, "Int", len - o )

	If ( len - o >= 0 && len - o < 64 )
	NumPut( 128, block, len - o, "Char" )
	If ( A_Index = blocks )
	Loop 8
	NumPut( len << 3 >> ( 8 - A_Index << 3 ) & 255, block, 55 + A_Index, "Char" )

	Loop 80
	{
		If ( 64 > o := A_Index - 1 << 2 )
		NumPut( w := NumGet( block, o + 3, "UChar" )
		| NumGet( block, o + 2, "UChar" ) << 8
		| NumGet( block, o + 1, "UChar" ) << 16
		| NumGet( block, o, "UChar" ) << 24, block, o, "UInt" )
		Else
		{
			w := NumGet( block, o - 4 * 3, "UInt" ) ^ NumGet( block, o - 4 * 8, "UInt" )
			^ NumGet( block, o - 4 * 14, "UInt" ) ^ NumGet( block, o - 4 * 16, "UInt" )
			NumPut( w := ( w << 1 | ( w >> 31 )) & m32, block, o, "UInt" )
		}
		If ( o < 80 )
		f := m32 & 0x5A827999 + ( ( b & c ) | ((~b) & d) ) + ( a << 5 | ( a >> 27 )) + e + w
		Else If ( o < 160 )
		f := m32 & 0x6ED9EBA1 + ( b ^ c ^ d ) + ( a << 5 | ( a >> 27 )) + e + w
		Else If ( o < 240 )
		f := m32 & 0x8F1BBCDC + ( ( b & c ) | ( b & d ) | ( c & d ) ) + ( a << 5 | ( a >> 27 )) + e + w
		Else f := m32 & 0xCA62C1D6 + ( b ^ c ^ d ) + ( a << 5 | ( a >> 27 )) + e + w
		e := d, d := c, c := m32 & ( b << 30 | ( b >> 2 )), b := a, a := f
	}
	_a := _a + a & m32, _b := _b + b & m32, _c := _c + c & m32, _d := _d + d & m32, _e := _e + e & m32
}
VarSetCapacity( block, 64, 0 )
Loop 40
j := Chr( 97 + ( A_Index - 1 >> 3 ) )
, j := _%j% >> ( ( 8 - A_Index & 7 ) << 2 ) & 15
, block .= Chr( 48 + j + 39 * ( j > 9 ) )
Return block
} ; SHA1( byref data, len = 0 ) --------------------------------------------------------------------

HMAC( hashfunc, key, msg ) { ; --------------------------------------------------------------------------------
; Hashed Message Authentication Code. Function by [VxE]. If the script uses wide-char strings (unicode), this
; function converts the message and key to UTF-8 before generating the HMAC. ! IMPORTANT ! 'hashfunc' MUST be
; the name of a hash function available in the script and it MUST accept two parameters, the first as BYREF for
; the data and the second for the number of bytes in the data. Lastly, the hashfunc MUST return a HEX STRING
; representing the message digest.

If ( IsFunc( hashfunc ) >> 1 != 1 )
Return "" ; error: invalid hashfunc. The hash function must require one or two parameters.

; First, left-pad the message with 64 bytes of 0x36.
If ( A_IsUnicode ) ; Transform the key and message for unicode versions of AHK
{
	dummy := msg
	mlen := 63 + DllCall( "WideCharToMultiByte", "UInt", 65001, "UInt", 0
	, "UInt", &dummy, "Int", -1, "UInt", 0, "Int", 0, "UInt", 0, "UInt", 0 )
	VarSetCapacity( msg, mlen + 1, 54 )
	DllCall( "WideCharToMultiByte", "UInt", 65001, "UInt", 0
	, "UInt", &dummy, "Int", -1, "UInt", &msg + 64, "Int", mlen - 63, "UInt", 0, "UInt", 0 )
	dummy := key
	klen := -1 + DllCall( "WideCharToMultiByte", "UInt", 65001, "UInt", 0
	, "UInt", &dummy, "Int", -1, "UInt", 0, "Int", 0, "UInt", 0, "UInt", 0 )
	VarSetCapacity( key, klen + 1 )
	DllCall( "WideCharToMultiByte", "UInt", 65001, "UInt", 0
	, "UInt", &dummy, "Int", -1, "UInt", &key, "Int", klen + 1, "UInt", 0, "UInt", 0 )
}
Else ; ANSI versions of AHK don't need any fancy dllcalls
{
	msg := "6666666666666666666666666666666666666666666666666666666666666666" msg
	StringLen, mlen, msg
	StringLen, klen, key
}

If ( 64 < kLen ) ; long keys must be hashed before use
{
	key := %hashfunc%( key, klen )
	StringLeft, dummy, key, 2
	StringTrimLeft, key, key, ( dummy = "0x" ) << 1
	klen := StrLen( key ) >> 1
	Loop, Parse, key
	If ( A_Index & 1 )
	dummy := Abs( "0x" A_LoopField ) << 4
	Else NumPut( dummy | Abs( "0x" A_LoopField ), key, A_Index - 2 >> 1, "Char" )
}

Loop, % klen ; XOR each byte in the key with 0x36 and insert it into the message padding.
NumPut( NumGet( key, A_Index - 1, "Char" ) ^ 54, msg, A_Index - 1, "Char" )

dummy := %hashfunc%( msg, mlen ) ; hash the message once
StringLeft, msg, dummy, 2
StringTrimLeft, dummy, dummy, ( msg = "0x" ) << 1
VarSetCapacity( msg, mlen := 128 + StrLen( dummy ) >> 1, 92 ) ; pad the message with 64*0x5C

Loop, Parse, dummy ; Insert each byte of the hashed message into the new message buffer
If ( A_Index & 1 )
dummy := Abs( "0x" A_LoopField ) << 4
Else NumPut( dummy | Abs( "0x" A_LoopField ), msg, A_Index + 126 >> 1 , "Char" )

Loop, % klen ; XOR each byte in the key with 0x5C and insert it into the message padding.
NumPut( NumGet( key, A_Index - 1, "Char" ) ^ 92, msg, A_Index - 1, "Char" )

Return %hashfunc%( msg, mlen ) ; hash the message again and return the result
} ; HMAC( hashfunc, key, msg ) --------------------------------------------------------------------------------