/* Library: Base64
 *     Functions for Base64 (en|de)coding
 * Version:
 *     v1.0.00.00
 * Requirements:
 *     AutoHotkey v1.1.20.00+ OR v2.0-a+ (latest preferred)
 *     Windows XP or higher
 * Installation:
 *     Use #Include or copy to a function library folder
 * Remarks:
 *     Based on similar lib(s) found in the forum.
 */


/* Function: Base64_Encode
 *     Encode data to Base64
 * Syntax:
 *     bytes := Base64_Encode( ByRef data, len, ByRef out [ , mode := "A" ] )
 * Parameter(s):
 *     bytes      [retval] - on success, the number of bytes copied to 'out'.
 *     data    [in, ByRef] - data to encode
 *     len            [in] - size in bytes of 'data'. Specify '-1' to automtically
 *                           calculate the size.
 *     out    [out, ByRef] - out variable containing the Base64 encoded data
 *     mode      [in, opt] - Specify 'A'(default) to use the ANSI version of
 *                           'CryptBinaryToString'. Otherwise, 'W' for UNICODE.
 */
Base64_Encode(ByRef data, len:=-1, ByRef out:="", mode:="A")
{
	if !InStr("AW", mode := Format("{:U}", mode), true)
		mode := "A"
	BytesPerChar := mode=="W" ? 2 : 1
	if (Round(len) <= 0)
		len := StrLen(data) * (A_IsUnicode ? 2 : 1)
	
	; CRYPT_STRING_BASE64 := 0x00000001
	if DllCall("Crypt32\CryptBinaryToString" . mode, "Ptr", &data, "UInt", len
	    , "UInt", 0x00000001, "Ptr", 0, "UIntP", size)
	{
		VarSetCapacity(out, size *= BytesPerChar, 0)
		if DllCall("Crypt32\CryptBinaryToString" . mode, "Ptr", &data, "UInt", len
		    , "UInt", 0x00000001, "Ptr", &out, "UIntP", size)
			return size * BytesPerChar
	}
}

/* Function: Base64_Decode
 *     Decode Base64 encoded data
 * Syntax:
 *     bytes := Base64_Decode( ByRef data, ByRef out [ , mode := "A" ] )
 * Parameter(s):
 *     bytes      [retval] - on success, the number of bytes copied to 'out'.
 *     data    [in, ByRef] - data(NULL-terminated) to decode
 *     out    [out, ByRef] - out variable containing the decoded data
 *     mode      [in, opt] - Specify 'A'(default) to use the ANSI version of
 *                           'CryptStringToBinary'. Otherwise, 'W' for UNICODE.
 */
Base64_Decode(ByRef data, ByRef out, mode:="A")
{
	if !InStr("AW", mode := Format("{:U}", mode), true)
		mode := "A"

	; CRYPT_STRING_BASE64 := 0x00000001
	if DllCall("Crypt32\CryptStringToBinary" . mode, "Ptr", &data, "UInt", 0
	    , "UInt", 0x00000001, "Ptr", 0, "UIntP", size, "Ptr", 0, "Ptr", 0)
	{
		VarSetCapacity(out, size, 0)
		if DllCall("Crypt32\CryptStringToBinary" . mode, "Ptr", &data, "UInt", 0
		    , "UInt", 0x00000001, "Ptr", &out, "UIntP", size, "Ptr", 0, "Ptr", 0)
			return size
	}
}