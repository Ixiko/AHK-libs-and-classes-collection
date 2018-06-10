;############################################################################################################
; Barcode Generator Library v1.02 by Giordanno Sperotto. 
; Updated: 27 December 2014.
; General Notes for this library (Refer to functions GENERATE_QR_CODE(), GENERATE_CODE_39(), GENERATE_CODE_ITF() and GENERATE_CODE_128B()
; for specific operating instructions).
; 
; Barcode Generator Library v1.01 by Giordanno Sperotto is an AutoHotkey (AHK) library designed to help generate Barcodes for
; AHK applications.
;
; Barcodes are usually used as a mean to store logistical data in the physical bodys of products and packages, so as to better allow 
; managing of lot numbers, expiring dates and other specific aspects of these products. QR Codes, a type of Two-Dimensional (2D)
; Barcodes, have also been used a marketing tool to quickly guide customers to website stores and ease up the sales of their products. 
; The use of barcodes, however, is not restricited to such cases and careful thought over how to use a quick and cheap way of 
; printing and reading data from physical objects should definitely sparkle some new interesting ideas for a programmer.
;
; Best wishes.
;
; List of Main functions:
; GENERATE_QR_CODE() -> Call this function to retrieve a table object (2D) that represents the dark and light pixels of a QR Code
; Matrix by their respective addresses.
; GENERATE_CODE_39() -> Call this functions to retrieve an object that represents the dark and light pixels of a CODE39
; row by their respective addresses (Note: Even tough the code is 1D, the image to be printed is actually 2D, so stack as many copies 
; of the single line over each other for the height of the image you wish to create).
; GENERATE_CODE_ITF() -> Call this function to retrieve an object that represents the monochrome dark and light pixels of an Interleaved 
; Code 2 of 5 row. (Note: Even tough the code is 1D, the image to be printed is actually 2D, so stack as many copies 
; of the single line over each other for the height of the image you wish to create).
; GENERATE_CODE_128B() -> Call this functions to retrieve an object that represents the dark and light pixels of a CODE128B
; row by their respective addresses (Note: Even tough the code is 1D, the image to be printed is actually 2D, so stack as many copies 
; of the single line over each other for the height of the image you wish to create).
;##############################################################################################################


;##############################################################################################################
; QR Code Functions v1.02
; General Notes from the author (refer to the function "GENERATE_QR_CODE()" for an explanation on how to create a QR Code Matrix):
;
; QR Codes (a type of 2D barcode) are a great tool to print to and recover data from physical objects. An advancement compared
; to regular 1D barcodes, they can contain more data (Up to 7,089 numeric characters for v40), encode bigger sets of characters, are  
; more reliable than the previous and can be read quite quick with current market level hardware/software. Most 2D readers currently available 
; will ship bundled with reader software and will simply autotype the decoded message to the selected field of your application. Also, there is 
; probably an application to read QR Codes available for use with your very own cell phone as of today.
;
; For logistical purposes, you can simply print a QR Code on a label and stick it to an object you wish to track, and you (or another person) will
; be able to recover the data stored inside the image at a later time. This ensures a whole new world of possibilities for industrial and commercial
; processes.
;
; If you are seeking out how QR Codes work, the full form of implementing them is described in the document for ISO 18004. The code for this 
; implementation has also been commented whenever i felt like something needed an explanation, but this is NOT a tutorial.Thonky has an 
; online tutorial for generating QR Codes, which has greatly helped this implementation. You can check it out on http://www.thonky.com/qr-code-tutorial/
;
; Thanks to tic (Tariq Porter) for his GDI+ Library (http://www.autohotkey.com/forum/viewtopic.php?t=32238), which has been used through the
; development of this library to display the images of the QR Matrixes.
;
; Thanks to Infogulch for the functions Bin() and Dec() (http://www.autohotkey.com/board/topic/49990-binary-and-decimal-conversion/).
;
; Thanks to AlphaBravo for the functions GENERATE_CODE_ITF(), Add_Check_Sum() and GENERATE_CODE_128B()
; (http://ahkscript.org/boards/viewtopic.php?f=6&t=5538&p=32299#p32299)
; (https://autohotkey.com/boards/viewtopic.php?p=93223#p93223)
;
; "QR Code" is a registered trademark of DENSO-WAVE (http://www.qrcode.com/en/faq.html) and the specifications of the standard are
; publicly available. You are free to use QR Codes on commercial applications and no contracts/fees are required, but you may have to
; credit Denso-Wave if you explicitly refer to the name "QR Code".
;
; Best wishes.

;CHANGELOG:
;11 December 2014: First version is up. Supports CODE39 and QR Code barcode generation. Examples added to the post.
;23 December 2014: Added Interleaved 2 of 5 Functions by AlphaBravo. Changed the lib and function names to allow MyLib_MyFunc syntax compatibility.
;25 December 2014: Fixed a typo in the code generating incorrect version 11-M matrixes.
;27 December 2014: Ran a test on each of the 40 QR Code versions, using each of the 4 ECLs for every version. All 160 matrixes generated were found to be readable. Changed Version to 1.01 to avoid confusion with non-working version 11 scripts.
; 23 June 2016: Added Code128B generating functions designed by AlphaBravo.
;##############################################################################################################



;##################################################################################################################################################################
; GENERATE_QR_CODE() v1.01 by Giordanno Sperotto. 
; How to generate QR Codes using this library:
; This function takes four parameters. 
;
; The First parameter is the message to encode. Please make sure that the message contains only ASCII characters (for this 
; version of the library).
;
; The Second parameter is the Code Mode to be applied, which can be 0 (Automatic choosing - Default and recommended), 1 (Numeric, can only encode sequences of
; numeric characters, with no commas, dots or any other symbols), 2 (AlphaNumeric, can only encode sequences of numeric characters, UPPERCASE letters A-Z and symbols 
; $, %, *, +, -, ., /, :, and \.), and finally 3 (Byte, which can encode any type of ASCII character, but usually requires a higher version QR Code for the same length of the string compared to the other two.
; The function will abort execution and display a message if you try to Force the encoding of a message in a Code Mode that cannot contain all the characters entered.
;
; The Third parameter is the CHOOSEN_ERROR_CORRECTION_LEVEL. QR Code matrixes are able to output the correct message even if they are damaged (to some extent and excluding some critical 
; areas). As the choosen Error Correction Level increases, this power improves, but the output matrix becomes bigger, requiring a bigger version to encode the same ammount of data. Available Error 
; Correction Levels are 1 (Level L, can recover the full data if only up to 7% of the codewords are damaged but will create the smallest matrix outputs, 2 (Level M, the default level, can recover the full data 
; if up to 15% of the codewords are damaged), 3 (Level Q, can recover the full data if up to 25% of the codewords are damaged) and 4 (Level H, can recover the full data if up to 30% of the codewords are 
; damaged - This level has the lowest available space for message codewords in each version).
;
; The Fourth parameter is the CHOOSEN_VERSION. It defaults to 0 (Automatic, Best) which will use the smallest version that can hold the entire message. Although it is possible to use a bigger version
; to encode a small message, this is not a good idea, as it will increase the resources required to generate and decode the matrix, aswell as increase the possibility of a false reading (The latter should 
; only be of real concern if the reader hardware/software is scanning the message for other types of 2D barcodes aswell, as QR Codes have a very low false positive possibility (lower than 1D barcodes AFAIK), 
; but don't really check for the existence of a submatrix that conforms to the other available standards (in example: they may contain a valid small Data Matrix.)). Either way, the lowest version that can encode
; the entire message is the recomended version here, and the default value for this parameter (0) will find that version for you. The function will abort execution and display a message if you try to Force the 
; encoding of a message in a QR Code Version that cannot contain all the characters entered.
;
; HOW TO INTERPRET THE RESULTS:
; If the call is succesfull, the function returns a 2D object, which should be interpreted as MATRIX_TO_PRINT[ROW ADDRESS, COLUMN ADDRESS], where each possible values for Row and Column addresses will reffer to a single module
; (black or white square) inside the matrix. You can thus easily access the individual modules of the output matrix one by one with a loop inside a loop, both set to iterate up to the MaxIndex() of the object. 
; After this, you can use any type of image library you like to create the images, save to disk, print or display in a GUI. I recommend you to use GDI+ Library by Tic. 
; (http://www.autohotkey.com/board/topic/29449-gdi-standard-library-145-by-tic). Do not forget to include reasonable sized "quiet zones" (light colored areas) surrouding the output QR Code image for better readability.
; Example:
;
; Loop % Object.MaxIndex()
; {
; 	ROW := A_Index
;	Loop % Object[1].MaxIndex()
;	{
;		COLUMN := A_Index
;		CURRENT_VALUE := Object[ROW, COLUMN]
;		If (CURRENT_VALUE = 1)
;		{
;			msgbox % "The pixel in row " . ROW . " and column " . COLUMN . " is dark.
;		}
;		Else
;			msgbox % "The pixel in row " . ROW . " and column " . COLUMN . " is light.
;	}
;}
;
; Other possible return values (Error values)
; 1 - Input message is blank.
; 2 - Forced Code Mode cannot encode all the characters in the input message.
; 3 - Choosen Code Mode does not correspond to one of the currently indexed code modes (Automatic, numeric, alphanumeric or byte).
; 4 - The choosen forced version cannot encode the entire input message using the choosen ECL Code_Mode. Try forcing a higher version or choosing automated version selection (parameter value 0).
; 5 - The input message is exceeding the QR Code standards maximum length for the choosen ECL and Code Mode.
; 6 - Choosen Error Correction Level does not correspond to one of the standard ECLs (L, M, Q and H).
; 7 - Forced version does not correspond to one of the QR Code standards versions.
;###################################################################################################################################################################
BARCODER_GENERATE_QR_CODE(MESSAGE_TO_ENCODE, CHOOSEN_CODE_MODE := 0, CHOOSEN_ERROR_CORRECTION_LEVEL := 2, CHOOSEN_VERSION := 0)
{
	Global
	MATRIX_TO_PRINT := ""
	CREATE_LOG_AND_ANTILOG_TABLES()
	LIST_NUMBER_OF_GROUPS_AND_BLOCKS() ; Necessary for processing the later step of interleaving of CodeWords (CW) and ErrorCorrectionWords (ECW).
	GENERATE_ALPHANUMERIC_TABLE()
	GENERATE_VERSION_CAPACITY_CUBE()
	
	If (MESSAGE_TO_ENCODE = "")
	{
		Return 1 ; Input message is blank.
	}
	
	; The best Code Mode is the one that succesfully encodes the entire message, but outputs the smaller QR Matrix. Numeric should be used whenever possible, AlphaNumeric is the second best choice and Byte mode should be selected only if the message cannot be encoded using the other two. Numeric can only hold numbers (sequences of the characters 0-9), AlphaNumeric can only hold numbers, uppercase letters A-Z and the symbols $, %, *, +, -, ., /, :, and \. Byte Mode can hold the entire ASCII table and Kanji mode can hold Japanese/Chinese/Korean characters.
	if (CHOOSEN_CODE_MODE = 0)
	{
		if MESSAGE_TO_ENCODE is number
		{
			CHOOSEN_CODE_MODE := 1
		}
		Else If (RegExMatch(MESSAGE_TO_ENCODE, "[^A-Z0-9`$`%`*`+`-`.`/`:`\ ]") = 0)
		{
			CHOOSEN_CODE_MODE := 2
		}
		Else
		{
			CHOOSEN_CODE_MODE := 3
		}
	}

	If !((CHOOSEN_VERSION >= 0) AND (CHOOSEN_VERSION <= 40))
	{
		; Msgbox, 0x10, Error, Forced Version does not correspond to one of the QR Code standards versions. Please choose a version from 1 to 40. You can also specify 0 to let the function choose the best one for you.
		Return 7 ; Forced version does not correspond to one of the QR Code standards versions.
	}

	; The best version to use is the smallest that sucessfully encodes the entire message.
	If (CHOOSEN_VERSION = 0)
	{
		Loop 40
		{
			If (StrLen(MESSAGE_TO_ENCODE) <= CAPACITY_CUBE[A_Index, CHOOSEN_ERROR_CORRECTION_LEVEL, CHOOSEN_CODE_MODE])
			{
				CHOOSEN_VERSION := A_Index
				Break
			}
		}
		CODE_MODE_TO_USE := ""
	}
	
	If (CHOOSEN_VERSION = 0) ; If the conditionals above failed to find a suitable version...
	{
		Return 5 ; The input message is exceeding the QR Code standards maximum length for the choosen ECL and Code Mode.
	}
	
	
		if ((CHOOSEN_CODE_MODE != 1) AND (CHOOSEN_CODE_MODE != 2) AND (CHOOSEN_CODE_MODE != 3) AND (CHOOSEN_CODE_MODE != 0))
	{
		;msgbox, 0x10, Error,  Please select an appropriate code mode for the message.
		Return 3 ; Choosen Code Mode does not correspond to one of the currently indexed code modes (Automatic, numeric, alphanumeric or byte).
	}
	
		if ((CHOOSEN_ERROR_CORRECTION_LEVEL != 1) AND (CHOOSEN_ERROR_CORRECTION_LEVEL != 2) AND (CHOOSEN_ERROR_CORRECTION_LEVEL != 3) AND (CHOOSEN_ERROR_CORRECTION_LEVEL != 4))
	{
		;msgbox, 0x10, Error,  Please select an appropriate code mode for the message.
		Return 6 ; Choosen Error Correction Level does not correspond to one of the standard ECLs (L, M, Q and H).
	}
	
	If !(StrLen(MESSAGE_TO_ENCODE) <= CAPACITY_CUBE[CHOOSEN_VERSION, CHOOSEN_ERROR_CORRECTION_LEVEL, CHOOSEN_CODE_MODE])
	{
		Return 4 ; The choosen forced version cannot encode the entire input message using the choosen ECL Code_Mode.
	}

	if (CHOOSEN_CODE_MODE = 1)
	{
		if MESSAGE_TO_ENCODE is not number
		{
			;msgbox, 0x10, Error, Numeric code mode can only encode the characters 0-9. Please correct the Message to Encode or change the selected Code Mode if you wish to encode other characters.
			Return 2 ; Forced Code Mode cannot encode all the characters in the input message.
		}
		Numeric_Mode := "0001" ; Numeric type
		If (CHOOSEN_VERSION <= 9)
		{
			Char_Count := SubStr("0000000000" . Bin(StrLen(MESSAGE_TO_ENCODE)), -9, 10) ; 10 bits with the size of the string are req for V1-9 Numeric.
		}
		If (CHOOSEN_VERSION >= 10) AND (CHOOSEN_VERSION <= 26)
		{
			Char_Count := SubStr("000000000000" . Bin(StrLen(MESSAGE_TO_ENCODE)), -11, 12) ; 12 bits with the size of the string are req for V10-26 Numeric.
		}
		If (CHOOSEN_VERSION >= 27) AND (CHOOSEN_VERSION <= 40)
		{
			Char_Count := SubStr("00000000000000" . Bin(StrLen(MESSAGE_TO_ENCODE)), -13, 14) ; 14 bits with the size of the string are req for V27-40 Numeric.
		}
		MESSAGE_CODE :=  Numeric_Mode . Char_Count ; We will add the codewords in the function call bellow, so "Message_Code" is not really complete here.
		MESSAGE_STRING := CONVERT_TO_NUMERIC_ENCODING(MESSAGE_TO_ENCODE)
	}

	if (CHOOSEN_CODE_MODE = 2)
	{
		If !(RegExMatch(MESSAGE_TO_ENCODE, "[^A-Z0-9`$`%`*`+`-`.`/`:`\ ]") = 0)
		{
			;msgbox, 0x10, Error, AlphaNumeric Code Mode can only encode numeric characters, letters from A to Z (uppercase only), whitespaces and the symbols `$, `%, `*, `+, `-, `., `/ and `:. Please correct the Message to Encode or change the selected Code Mode if you wish to encode any other characters.
			Return 2 ; Forced Code Mode cannot encode all the characters in the input message.
		}
		ALPHANUMERIC_MODE := "0010"
		If (CHOOSEN_VERSION <= 9)
		{
			Char_Count := SubStr("000000000" . Bin(StrLen(MESSAGE_TO_ENCODE)), -8, 9) ; 9 bits with the size of the string are req for V1-9 AlphaNumeric.
		}
		If (CHOOSEN_VERSION >= 10) AND (CHOOSEN_VERSION <= 26)
		{
			Char_Count := SubStr("00000000000" . Bin(StrLen(MESSAGE_TO_ENCODE)), -10, 11) ; 11 bits with the size of the string are req for V10-26 AlphaNumeric.
		}
		If (CHOOSEN_VERSION >= 27) AND (CHOOSEN_VERSION <= 40)
		{
			Char_Count := SubStr("0000000000000" . Bin(StrLen(MESSAGE_TO_ENCODE)), -12, 13) ; 13 bits with the size of the string are req for V27-40 AlphaNumeric.
		}
		MESSAGE_CODE :=  ALPHANUMERIC_MODE . Char_Count ; We will add the codewords in the function call bellow, so "Message_Code" is not really complete here.
		MESSAGE_STRING := CONVERT_TO_ALPHANUMERIC_ENCODING(MESSAGE_TO_ENCODE)
	}

	if (CHOOSEN_CODE_MODE = 3)
	{
		BYTE_MODE := "0100"
		If (CHOOSEN_VERSION <= 9)
		{
			Char_Count := SubStr("00000000" . Bin(StrLen(MESSAGE_TO_ENCODE)), -7, 8) ; 8 bits with the size of the string are req for V1-9 Byte Mode.
		}
		If (CHOOSEN_VERSION >= 10) AND (CHOOSEN_VERSION <= 40)
		{
			Char_Count := SubStr("0000000000000000" . Bin(StrLen(MESSAGE_TO_ENCODE)), -15, 16) ; 16 bits with the size of the string are req for V10-40 Byte Mode.
		}
		MESSAGE_CODE :=  BYTE_MODE . Char_Count ; We will add the codewords in the function call bellow, so "Message_Code" is not really complete here.
		MESSAGE_STRING := CONVERT_TO_BYTE_ENCODING(MESSAGE_TO_ENCODE)
	}

	;To add the terminator, we have to know how many data codewords the version and ECL require. the V2H, in example, requires 16 data codewords, which equals 128 bits. If the string length up to now is less than that, we have to add the terminator, which is composed of up to 4 zeroed bits. The limit would than be 128, which means that if the string thus far is 127 bits, our terminator would be "0", if it were 126, "00", and so on up to "0000" which is the maximum for the terminator, in case the string were equal to or less than 124 bits. Once again: each version and ECL requires a different number of codewords to fill it's capacity, and we are creating a list for selecting these here.

	TOTAL_CODEWORDS := Object()
	TOTAL_CODEWORDS[1] := [19,34,55,80,108,136,156,194,232,274,324,370,428,461,523,589,647,721,795,861,932,1006,1094,1174,1276,1370,1468,1531,1631,1735,1843,1955,2071,2191,2306,2434,2566,2702,2812,2956] ; ECL L
	TOTAL_CODEWORDS[2] := [16,28,44,64,86,108,124,154,182,216,254,290,334,365,415,453,507,563,627,669,714,782,860,914,1000,1062,1128,1193,1267,1373,1455,1541,1631,1725,1812,1914,1992,2102,2216,2334] ; ECL M
	TOTAL_CODEWORDS[3] := [13,22,34,48,62,76,88,110,132,154,180,206,244,261,295,325,367,397,445,485,512,568,614,664,718,754,808,871,911,985,1033,1115,1171,1231,1286,1354,1426,1502,1582,1666] ; ECL Q
	TOTAL_CODEWORDS[4] := [9,16,26,36,46,60,66,86,100,122,140,158,180,197,223,253,283,313,341,385,406,442,464,514,538,596,628,661,701,745,793,845,901,961,986,1054,1096,1142,1222,1276] ; ECL H


;128 bits are required for a V2H Mode + Char_Count + String + Terminator + Pads. The terminator contains at most 4 zeros (limited also to the max string size of 128 bits). The pads are sequences of  the bytes "11101100" and "00010001" appended in alternating mode right after the terminator.
;125
	If StrLen(MESSAGE_CODE . MESSAGE_STRING) < (TOTAL_CODEWORDS[CHOOSEN_ERROR_CORRECTION_LEVEL, CHOOSEN_VERSION] * 8) - 3
	{
		MESSAGE_UP_TO_TERMINATOR := MESSAGE_CODE . MESSAGE_STRING . "0000"
	}
	Else if StrLen(MESSAGE_CODE . MESSAGE_STRING) < (TOTAL_CODEWORDS[CHOOSEN_ERROR_CORRECTION_LEVEL, CHOOSEN_VERSION] * 8) - 2
	{
		MESSAGE_UP_TO_TERMINATOR := MESSAGE_CODE . MESSAGE_STRING . "000"
	}
	Else if StrLen(MESSAGE_CODE . MESSAGE_STRING) < (TOTAL_CODEWORDS[CHOOSEN_ERROR_CORRECTION_LEVEL, CHOOSEN_VERSION] * 8) - 1
	{
		MESSAGE_UP_TO_TERMINATOR := MESSAGE_CODE . MESSAGE_STRING . "00"
	}
	Else if StrLen(MESSAGE_CODE . MESSAGE_STRING) < (TOTAL_CODEWORDS[CHOOSEN_ERROR_CORRECTION_LEVEL, CHOOSEN_VERSION] * 8)
	{
		MESSAGE_UP_TO_TERMINATOR := MESSAGE_CODE . MESSAGE_STRING . "0"
	}
	Else 
	{
		MESSAGE_UP_TO_TERMINATOR := MESSAGE_CODE . MESSAGE_STRING
	}

	; We now see how many more zeroes we have to add till we get a multiple of 8 in the total bit length and add these after the teminator.
	MESSAGE_PAD_MULTIPLE_8 := MESSAGE_UP_TO_TERMINATOR ; note that MESSAGE_PAD_MULTIPLE_8 is only completed (in its namesake) below.

	If !(Mod(StrLen(MESSAGE_UP_TO_TERMINATOR), 8) = 0) ; If the number of bits in the string we have up till now is not a multiple of 8...
	{
		Loop % 8 - Mod(StrLen(MESSAGE_UP_TO_TERMINATOR), 8) ; We add zeros till the number of bits is a multiple of 8.
		{
			MESSAGE_PAD_MULTIPLE_8 := MESSAGE_PAD_MULTIPLE_8 . "0"
		}
	}
	NUMBER_OF_RIGHT_BYTE_PADS_TO_ADD := ((TOTAL_CODEWORDS[CHOOSEN_ERROR_CORRECTION_LEVEL, CHOOSEN_VERSION] * 8) - StrLen(MESSAGE_PAD_MULTIPLE_8)) / 8

	FINAL_MESSAGE_RAW_DATA_BITS := MESSAGE_PAD_MULTIPLE_8 ; Again, note that FINAL_MESSAGE_RAW_DATA_BITS is only completed (in its namesake) below. We are including the right pad bytes to make the the message equal to the full capacity of the version.

	; Now that we have the message, terminator and zero padded bits, we add the byte padds, which are alternating sequences of the bytes 236 and 17 up to the filled capacity of  cordewords for the version and ECL.
	Loop % NUMBER_OF_RIGHT_BYTE_PADS_TO_ADD
	{
		if (Mod(A_Index, 2) = 1)
			FINAL_MESSAGE_RAW_DATA_BITS := FINAL_MESSAGE_RAW_DATA_BITS . "11101100" ; 236
		else
			FINAL_MESSAGE_RAW_DATA_BITS := FINAL_MESSAGE_RAW_DATA_BITS . "00010001" ; 17
	}

	GROUPS_AND_BLOCKS_INFO := ""
	GROUPS_AND_BLOCKS_INFO := BLOCKS_AND_GROUPS[CHOOSEN_ERROR_CORRECTION_LEVEL, CHOOSEN_VERSION]
	StringSplit, GROUPS_AND_BLOCKS_INFO_, GROUPS_AND_BLOCKS_INFO , |

	MESSAGE_BITS_TO_SPLIT := FINAL_MESSAGE_RAW_DATA_BITS

	; For each block, we will generate an ECW set.

	NUMBER_OF_BITS_PER_BLOCK := ""
	NUMBER_OF_BITS_PER_BLOCK := GROUPS_AND_BLOCKS_INFO_3 * 8
	Loop % GROUPS_AND_BLOCKS_INFO_1 ; Blocks in Group 1
	{
		BLOCK_%A_Index%_OF_GROUP_1 := SubStr(MESSAGE_BITS_TO_SPLIT, 1, NUMBER_OF_BITS_PER_BLOCK)
		StringTrimLeft, MESSAGE_BITS_TO_SPLIT, MESSAGE_BITS_TO_SPLIT, %NUMBER_OF_BITS_PER_BLOCK%
		GENERATE_ERROR_CORRECTION_CODEWORDS(BLOCK_%A_Index%_OF_GROUP_1, CHOOSEN_ERROR_CORRECTION_LEVEL, 1, A_Index, CHOOSEN_VERSION) 
	}

	NUMBER_OF_BITS_PER_BLOCK := ""
	NUMBER_OF_BITS_PER_BLOCK := GROUPS_AND_BLOCKS_INFO_4 * 8
	Loop % GROUPS_AND_BLOCKS_INFO_2 ; Blocks in Group 2
	{
		BLOCK_%A_Index%_OF_GROUP_2 := SubStr(MESSAGE_BITS_TO_SPLIT, 1, NUMBER_OF_BITS_PER_BLOCK)
		StringTrimLeft, MESSAGE_BITS_TO_SPLIT, MESSAGE_BITS_TO_SPLIT, %NUMBER_OF_BITS_PER_BLOCK%
		GENERATE_ERROR_CORRECTION_CODEWORDS(BLOCK_%A_Index%_OF_GROUP_2, CHOOSEN_ERROR_CORRECTION_LEVEL, 2, A_Index, CHOOSEN_VERSION) 
	}

	; So basically, we now have each of the bytes of the final message allocated in their corresponding groups and blocks. To access the first byte of the first group of the first block, we would than use the first byte of BLOCK_1_OF_GROUP_1. To access the first byte of the first ECW string (the first one related to the first block of the first group of CW) we would than use: SubStr("00000000" . Bin(ERROR_CORRECTION_CODEWORDS_1_1[1]), -7, 8). Time to proceed the interleaving.

	; First, we interleave the CW Bytes.
	HIGHEST_NUMBER_OF_BLOCKS_PER_GROUP := ""
	% ((GROUPS_AND_BLOCKS_INFO_3 > GROUPS_AND_BLOCKS_INFO_4) ? (HIGHEST_NUMBER_OF_BLOCKS_PER_GROUP := GROUPS_AND_BLOCKS_INFO_3) : (HIGHEST_NUMBER_OF_BLOCKS_PER_GROUP := GROUPS_AND_BLOCKS_INFO_4))

	Loop % HIGHEST_NUMBER_OF_BLOCKS_PER_GROUP
	{
		CURRENT_COLUMN := A_Index
		Loop % (GROUPS_AND_BLOCKS_INFO_1 + GROUPS_AND_BLOCKS_INFO_2)
		{
			If (A_Index <= GROUPS_AND_BLOCKS_INFO_1)
			{
				INTERLEAVED_MESSAGE_BITS := INTERLEAVED_MESSAGE_BITS . SubStr(BLOCK_%A_Index%_OF_GROUP_1, CURRENT_COLUMN * 8 - 7, 8)
			}
			If (A_Index > GROUPS_AND_BLOCKS_INFO_1)
			{
				CURRENT_BLOCK_NUMBER := A_Index - GROUPS_AND_BLOCKS_INFO_1
				INTERLEAVED_MESSAGE_BITS := INTERLEAVED_MESSAGE_BITS . SubStr(BLOCK_%CURRENT_BLOCK_NUMBER%_OF_GROUP_2, CURRENT_COLUMN * 8 - 7, 8)
			}
		}
	}
	CURRENT_COLUMN := ""


	; And than, we interleave the ECW bytes.
	Loop % NUMBER_OF_ECW
	{
		CURRENT_COLUMN := A_Index
		Loop % (GROUPS_AND_BLOCKS_INFO_1 + GROUPS_AND_BLOCKS_INFO_2)
		{
			If (A_Index <= GROUPS_AND_BLOCKS_INFO_1)
			{
				INTERLEAVED_ECW_BITS := INTERLEAVED_ECW_BITS . SubStr("00000000" . Bin(ERROR_CORRECTION_CODEWORDS_1_%A_Index%[CURRENT_COLUMN]), -7, 8)
			}
			If (A_Index > GROUPS_AND_BLOCKS_INFO_1)
			{
				CURRENT_BLOCK_NUMBER := A_Index - GROUPS_AND_BLOCKS_INFO_1
				INTERLEAVED_ECW_BITS := INTERLEAVED_ECW_BITS . SubStr("00000000" . Bin(ERROR_CORRECTION_CODEWORDS_2_%CURRENT_BLOCK_NUMBER%[CURRENT_COLUMN]), -7, 8)
			}
		}
	}

	CURRENT_COLUMN := ""

	FINAL_MESSAGE := INTERLEAVED_MESSAGE_BITS . INTERLEAVED_ECW_BITS ; This string contains the full unencoded structured message, without any error correction code.

	MATRIX_TO_PRINT := GENERATE_MATRIX(FINAL_MESSAGE, CHOOSEN_VERSION, CHOOSEN_ERROR_CORRECTION_LEVEL)


	; We are finally done. All that is left before printing is to insert the Version and Format information.The first string goes of the Format information goes below.
	MATRIX_TO_PRINT[9, MATRIX_DIMENSIONS] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, 0, 1), MATRIX_TO_PRINT[9, MATRIX_DIMENSIONS - 1] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, -1, 1), MATRIX_TO_PRINT[9, MATRIX_DIMENSIONS - 2] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, -2, 1), MATRIX_TO_PRINT[9, MATRIX_DIMENSIONS - 3] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, -3, 1), MATRIX_TO_PRINT[9, MATRIX_DIMENSIONS - 4] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, -4, 1), MATRIX_TO_PRINT[9, MATRIX_DIMENSIONS - 5] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, -5, 1), MATRIX_TO_PRINT[9, MATRIX_DIMENSIONS - 6] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, -6, 1), MATRIX_TO_PRINT[9, MATRIX_DIMENSIONS - 7] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, -7, 1), MATRIX_TO_PRINT[MATRIX_DIMENSIONS - 6, 9] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, -8, 1), MATRIX_TO_PRINT[MATRIX_DIMENSIONS - 5, 9] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, -9, 1), MATRIX_TO_PRINT[MATRIX_DIMENSIONS - 4, 9] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, -10, 1), MATRIX_TO_PRINT[MATRIX_DIMENSIONS - 3, 9] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, -11, 1), MATRIX_TO_PRINT[MATRIX_DIMENSIONS - 2, 9] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, -12, 1), MATRIX_TO_PRINT[MATRIX_DIMENSIONS - 1, 9] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, -13, 1), MATRIX_TO_PRINT[MATRIX_DIMENSIONS, 9] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, -14, 1)

	; And now the second string with the Format Info.
	MATRIX_TO_PRINT[1, 9] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, 0, 1), MATRIX_TO_PRINT[2, 9] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, -1, 1), MATRIX_TO_PRINT[3, 9] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, -2, 1), MATRIX_TO_PRINT[4, 9] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, -3, 1), MATRIX_TO_PRINT[5, 9] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, -4, 1), MATRIX_TO_PRINT[6, 9] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, -5, 1), MATRIX_TO_PRINT[8, 9] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, -6, 1), MATRIX_TO_PRINT[9, 9] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, -7, 1), MATRIX_TO_PRINT[9, 8] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, -8, 1), MATRIX_TO_PRINT[9, 6] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, -9, 1), MATRIX_TO_PRINT[9, 5] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, -10, 1), MATRIX_TO_PRINT[9, 4] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, -11, 1), MATRIX_TO_PRINT[9, 3] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, -12, 1), MATRIX_TO_PRINT[9, 2] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, -13, 1), MATRIX_TO_PRINT[9, 1] := SubStr(CHOOSEN_MASK_CODE_FOR_V2, -14, 1)

	; Version information strings exist only on QR matrixes versions 7 and above.
	If (CHOOSEN_VERSION >= 7)
	{
		VERSION_INFORMATION_STRING := ""
		%  ((CHOOSEN_VERSION = 7) ? (VERSION_INFORMATION_STRING := "000111110010010100") : ("")), ((CHOOSEN_VERSION = 8) ? (VERSION_INFORMATION_STRING := "001000010110111100") : ("")), ((CHOOSEN_VERSION = 9) ? (VERSION_INFORMATION_STRING := "001001101010011001") : ("")), ((CHOOSEN_VERSION = 10) ? (VERSION_INFORMATION_STRING := "001010010011010011") : ("")), ((CHOOSEN_VERSION = 11) ? (VERSION_INFORMATION_STRING := "001011101111110110") : ("")), ((CHOOSEN_VERSION = 12) ? (VERSION_INFORMATION_STRING := "001100011101100010") : ("")), ((CHOOSEN_VERSION = 13) ? (VERSION_INFORMATION_STRING := "001101100001000111") : ("")), ((CHOOSEN_VERSION = 14) ? (VERSION_INFORMATION_STRING := "001110011000001101") : ("")), ((CHOOSEN_VERSION = 15) ? (VERSION_INFORMATION_STRING := "001111100100101000") : ("")), ((CHOOSEN_VERSION = 16) ? (VERSION_INFORMATION_STRING := "010000101101111000") : ("")), ((CHOOSEN_VERSION = 17) ? (VERSION_INFORMATION_STRING := "010001010001011101") : ("")), ((CHOOSEN_VERSION = 18) ? (VERSION_INFORMATION_STRING := "010010101000010111") : ("")), ((CHOOSEN_VERSION = 19) ? (VERSION_INFORMATION_STRING := "010011010100110010") : ("")), ((CHOOSEN_VERSION = 20) ? (VERSION_INFORMATION_STRING := "010100100110100110") : (""))
		% ((CHOOSEN_VERSION = 21) ? (VERSION_INFORMATION_STRING := "010101011010000011") : ("")), ((CHOOSEN_VERSION = 22) ? (VERSION_INFORMATION_STRING := "010110100011001001") : ("")), ((CHOOSEN_VERSION = 23) ? (VERSION_INFORMATION_STRING := "010111011111101100") : ("")), ((CHOOSEN_VERSION = 24) ? (VERSION_INFORMATION_STRING := "011000111011000100") : ("")), ((CHOOSEN_VERSION = 25) ? (VERSION_INFORMATION_STRING := "011001000111100001") : ("")), ((CHOOSEN_VERSION = 26) ? (VERSION_INFORMATION_STRING := "011010111110101011") : ("")), ((CHOOSEN_VERSION = 27) ? (VERSION_INFORMATION_STRING := "011011000010001110") : ("")), ((CHOOSEN_VERSION = 28) ? (VERSION_INFORMATION_STRING := "011100110000011010") : ("")), ((CHOOSEN_VERSION = 29) ? (VERSION_INFORMATION_STRING := "011101001100111111") : ("")), ((CHOOSEN_VERSION = 30) ? (VERSION_INFORMATION_STRING := "011110110101110101") : ("")), ((CHOOSEN_VERSION = 31) ? (VERSION_INFORMATION_STRING := "011111001001010000") : ("")), ((CHOOSEN_VERSION = 32) ? (VERSION_INFORMATION_STRING := "100000100111010101") : ("")), ((CHOOSEN_VERSION = 33) ? (VERSION_INFORMATION_STRING := "100001011011110000") : ("")), ((CHOOSEN_VERSION = 34) ? (VERSION_INFORMATION_STRING := "100010100010111010") : ("")), ((CHOOSEN_VERSION = 35) ? (VERSION_INFORMATION_STRING := "100011011110011111") : ("")), ((CHOOSEN_VERSION = 36) ? (VERSION_INFORMATION_STRING := "100100101100001011") : ("")), ((CHOOSEN_VERSION = 37) ? (VERSION_INFORMATION_STRING := "100101010000101110") : ("")), ((CHOOSEN_VERSION = 38) ? (VERSION_INFORMATION_STRING := "100110101001100100") : ("")), ((CHOOSEN_VERSION = 39) ? (VERSION_INFORMATION_STRING := "100111010101000001") : ("")), ((CHOOSEN_VERSION = 40) ? (VERSION_INFORMATION_STRING := "101000110001101001") : (""))

		Loop 6
		{
			CURRENT_COLUMN := A_Index
			Loop 3
			{
				CURRENT_ROW := A_Index
				MATRIX_TO_PRINT[MATRIX_DIMENSIONS - (11 - A_Index), CURRENT_COLUMN] := SubStr(VERSION_INFORMATION_STRING, 1 - (A_Index + (CURRENT_COLUMN * 3 - 2) - 1), 1)
				MATRIX_TO_PRINT[CURRENT_COLUMN, MATRIX_DIMENSIONS - (11 - A_Index)] := SubStr(VERSION_INFORMATION_STRING, 1 - (A_Index + (CURRENT_COLUMN * 3 - 2) - 1), 1)
			}
		}
	}

	; Time to get rid of the global trash.

	Loop % GROUPS_AND_BLOCKS_INFO_1
	{
		BLOCK_%A_Index%_OF_GROUP_1 := ""
		ERROR_CORRECTION_CODEWORDS_1_%A_Index% := ""
	}

	Loop % GROUPS_AND_BLOCKS_INFO_2
	{
		BLOCK_%A_Index%_OF_GROUP_2 := ""
		ERROR_CORRECTION_CODEWORDS_2_%A_Index% := ""
	}

	Loop % ALIGNMENT_INDIVIDUAL_COORDINATES_0
	{
		ALIGNMENT_INDIVIDUAL_COORDINATES_%A_Index% := ""
	}

	CHOOSEN_MASK_CODE_FOR_V2 := "", ERROR_CORRECTION_CODEWORDS := "", CURRENT_COLUMN := "",  CURRENT_GROUP := "", CURRENT_REDIMENSION_ROW := "",  ERROR_CORRECTION_CODEWORDS_BITS := "", FINAL_MESSAGE := "", FINAL_MESSAGE_RAW_DATA_BITS := "", G := "", LIST_OF_PENALTY_VALUES := "", Loop_Times := "", MATRIX_MASK_ONE := "", MATRIX_MASK_TWO := "", MATRIX_MASK_THREE := "", MATRIX_MASK_FOUR := "", MATRIX_MASK_FIVE := "", MATRIX_MASK_SIX := "", MATRIX_MASK_SEVEN := "", MATRIX_MASK_EIGHT := "", MATRIX_UNMASKED := "", MESSAGE_PAD_MULTIPLE_8 := "", MESSAGE_STRING := "", MESSAGE_TO_ENCODE := "", MESSAGE_UP_TO_TERMINATOR := "", NUMBER_OF_BITS_TO_USE := "", NUMBER_OF_RIGHT_BYTE_PADS_TO_ADD := "", Numeric_Mode := "", Options := "", pBitmap := "", pBrush := "", PENALTY_VALUES_IN_ORDER0 := "", PENALTY_VALUES_IN_ORDER1 := "", PENALTY_VALUES_IN_ORDER2 := "", PENALTY_VALUES_IN_ORDER3 := "", PENALTY_VALUES_IN_ORDER4 := "", PENALTY_VALUES_IN_ORDER5 := "", PENALTY_VALUES_IN_ORDER6 := "", PENALTY_VALUES_IN_ORDER7 := "", PENALTY_VALUES_IN_ORDER8 := "", pToken := "", TOTAL_PENALTY_FOR_MASKED_MATRIX_1 := "", TOTAL_PENALTY_FOR_MASKED_MATRIX_2 := "", TOTAL_PENALTY_FOR_MASKED_MATRIX_3 := "", TOTAL_PENALTY_FOR_MASKED_MATRIX_4 := "", TOTAL_PENALTY_FOR_MASKED_MATRIX_5 := "", TOTAL_PENALTY_FOR_MASKED_MATRIX_6 := "", TOTAL_PENALTY_FOR_MASKED_MATRIX_7 := "", TOTAL_PENALTY_FOR_MASKED_MATRIX_8 := "", MESSAGE_CODE := "", NUMBER_OF_ECW := "", CHOOSEN_ERROR_CORRECTION_LEVEL := "", CHOOSEN_CODE_MODE := "", CURRENT_ROW := "", CURRENT_ROW_OF_FUNCTION_PATTERN := "", CURRENT_WRITING_DIRECTION := "", FILE_PATH_AND_NAME := "", FUNCTION_ALIGN_PATTERN_CURRENT_ROW := "", FUNCTION_ALIGNMENT_PATTERN := "", FUNCTION_FINDER_PATTERN := "", GROUPS_AND_BLOCKS_INFO := "", GROUPS_AND_BLOCKS_INFO_0 := "", GROUPS_AND_BLOCKS_INFO_1 := "", GROUPS_AND_BLOCKS_INFO_2 := "", GROUPS_AND_BLOCKS_INFO_3 := "", GROUPS_AND_BLOCKS_INFO_4 := "", CURRENT_BLOCK_NUMBER := "", COMPOSITE_VERSION := "", Column_Count := "", CHOOSEN_VERSION := "", Char_Count := "", INTERLEAVED_ECW_BITS := "", INTERLEAVED_MESSAGE_BITS := "", LIST_OF_PENALTY_VALUES := "", MATRIX_DIMENSIONS := "", LOWER_MULTIPLE_OF_5 := "", NEAREST_MULTIPLE_OF_TEN := "", NOT_WRITE := "", NUMBER_OF_BITS_PER_BLOCK := "", NUMBER_OF_DARK_MODULES := "", NUMBER_OF_LIGHT_MODULES := "", PENALTY_SUM := "", PERCENT_OF_MODULES := "", PREVIOUS_BIT := "", RESULT_ONE := "", RESULT_TWO := "", Row_Count := "", SEQUENCE_TO_CHECK := "", START_BIT := "", TOTAL_CODEWORDS := "", TOTAL_MODULES := "", VERSION_INFORMATION_STRING := "", UPPER_MULTIPLE_OF_5 := "", INDIVIDUAL_ALIGNMENT_COORDS_0 := "", INDIVIDUAL_ALIGNMENT_COORDS_1 := "", INDIVIDUAL_ALIGNMENT_COORDS_2 := "", HIGHEST_NUMBER_OF_BLOCKS_PER_GROUP := "", COUNT_CONTINUOUS := "", CURRENT_ENTRY := "", ALIGNMENT_LOCATIONS := "", ALIGNMENT_INDIVIDUAL_COORDINATES_0 := "", COUNTER := "", FILE_NAME_TO_USE := "", BYTE_MODE := "", ALPHANUMERIC_MODE := "", Bits_Of_Last_Group := ""
	
	Return MATRIX_TO_PRINT
}
Return

; To encode alphanumeric characters, the table below is required.
GENERATE_ALPHANUMERIC_TABLE()
{
	Global
	ALPHA_TABLE := object()
	ALPHA_TABLE[0] := 0, ALPHA_TABLE[1] := 1, ALPHA_TABLE[2] := 2, ALPHA_TABLE[3] := 3, ALPHA_TABLE[4] := 4, ALPHA_TABLE[5] := 5, ALPHA_TABLE[6] := 6, ALPHA_TABLE[7] := 7, ALPHA_TABLE[8] := 8, ALPHA_TABLE[9] := 9, ALPHA_TABLE["A"] := 10,  ALPHA_TABLE["B"] := 11, ALPHA_TABLE["C"] := 12, ALPHA_TABLE["D"] := 13, ALPHA_TABLE["E"] := 14, ALPHA_TABLE["F"] := 15, ALPHA_TABLE["G"] := 16, ALPHA_TABLE["H"] := 17, ALPHA_TABLE["I"] := 18, ALPHA_TABLE["J"] := 19, ALPHA_TABLE["K"] := 20, ALPHA_TABLE["L"] := 21, ALPHA_TABLE["M"] := 22, ALPHA_TABLE["N"] := 23, ALPHA_TABLE["O"] := 24, ALPHA_TABLE["P"] := 25, ALPHA_TABLE["Q"] := 26, ALPHA_TABLE["R"] := 27, ALPHA_TABLE["S"] := 28, ALPHA_TABLE["T"] := 29, ALPHA_TABLE["U"] := 30, ALPHA_TABLE["V"] := 31, ALPHA_TABLE["W"] := 32, ALPHA_TABLE["X"] := 33, ALPHA_TABLE["Y"] := 34, ALPHA_TABLE["Z"] := 35, ALPHA_TABLE[A_Space] := 36, ALPHA_TABLE["`$"] := 37, ALPHA_TABLE["`%"] := 38, ALPHA_TABLE["`*"] := 39, ALPHA_TABLE["`+"] := 40, ALPHA_TABLE["`-"] := 41, ALPHA_TABLE["`."] := 42, ALPHA_TABLE["`/"] := 43, ALPHA_TABLE["`:"] := 44 
}

Return

;The function below generates a 3D object (CAPACITY_CUBE) to hold the capacity of the QR Matrix according to Version, ECL and Code Mode.
GENERATE_VERSION_CAPACITY_CUBE()
{
	global
	CAPACITY_CUBE := object()
	CAPACITY_STRING := "41	25	17	10	34	20	14	8	27	16	11	7	17	10	7	4	77	47	32	20	63	38	26	16	48	29	20	12	34	20	14	8	127	77	53	32	101	61	42	26	77	47	32	20	58	35	24	15	187	114	78	48	149	90	62	38	111	67	46	28	82	50	34	21	255	154	106	65	202	122	84	52	144	87	60	37	106	64	44	27	322	195	134	82	255	154	106	65	178	108	74	45	139	84	58	36	370	224	154	95	293	178	122	75	207	125	86	53	154	93	64	39	461	279	192	118	365	221	152	93	259	157	108	66	202	122	84	52	552	335	230	141	432	262	180	111	312	189	130	80	235	143	98	60	652	395	271	167	513	311	213	131	364	221	151	93	288	174	119	74	772	468	321	198	604	366	251	155	427	259	177	109	331	200	137	85	883	535	367	226	691	419	287	177	489	296	203	125	374	227	155	96	1022	619	425	262	796	483	331	204	580	352	241	149	427	259	177	109	1101	667	458	282	871	528	362	223	621	376	258	159	468	283	194	120	1250	758	520	320	991	600	412	254	703	426	292	180	530	321	220	136	1408	854	586	361	1082	656	450	277	775	470	322	198	602	365	250	154	1548	938	644	397	1212	734	504	310	876	531	364	224	674	408	280	173	1725	1046	718	442	1346	816	560	345	948	574	394	243	746	452	310	191	1903	1153	792	488	1500	909	624	384	1063	644	442	272	813	493	338	208	2061	1249	858	528	1600	970	666	410	1159	702	482	297	919	557	382	235	2232	1352	929	572	1708	1035	711	438	1224	742	509	314	969	587	403	248	2409	1460	1003	618	1872	1134	779	480	1358	823	565	348	1056	640	439	270	2620	1588	1091	672	2059	1248	857	528	1468	890	611	376	1108	672	461	284	2812	1704	1171	721	2188	1326	911	561	1588	963	661	407	1228	744	511	315	3057	1853	1273	784	2395	1451	997	614	1718	1041	715	440	1286	779	535	330	3283	1990	1367	842	2544	1542	1059	652	1804	1094	751	462	1425	864	593	365	3517	2132	1465	902	2701	1637	1125	692	1933	1172	805	496	1501	910	625	385	3669	2223	1528	940	2857	1732	1190	732	2085	1263	868	534	1581	958	658	405	3909	2369	1628	1002	3035	1839	1264	778	2181	1322	908	559	1677	1016	698	430	4158	2520	1732	1066	3289	1994	1370	843	2358	1429	982	604	1782	1080	742	457	4417	2677	1840	1132	3486	2113	1452	894	2473	1499	1030	634	1897	1150	790	486	4686	2840	1952	1201	3693	2238	1538	947	2670	1618	1112	684	2022	1226	842	518	4965	3009	2068	1273	3909	2369	1628	1002	2805	1700	1168	719	2157	1307	898	553	5253	3183	2188	1347	4134	2506	1722	1060	2949	1787	1228	756	2301	1394	958	590	5529	3351	2303	1417	4343	2632	1809	1113	3081	1867	1283	790	2361	1431	983	605	5836	3537	2431	1496	4588	2780	1911	1176	3244	1966	1351	832	2524	1530	1051	647	6153	3729	2563	1577	4775	2894	1989	1224	3417	2071	1423	876	2625	1591	1093	673	6479	3927	2699	1661	5039	3054	2099	1292	3599	2181	1499	923	2735	1658	1139	701	6743	4087	2809	1729	5313	3220	2213	1362	3791	2298	1579	972	2927	1774	1219	750	7089	4296	2953	1817	5596	3391	2331	1435	3993	2420	1663	1024	3057	1852	1273	784"
	StringSplit, CAPACITY_STRING_, CAPACITY_STRING, %A_Tab%
	Loop 40 ; There are 40 different QR Code versions (excluding Micro Qr Codes).
	{
		CURRENT_VERSION := A_Index
		Loop 4 ; There are 4 different Error Correction Levels (L, M, Q, and H, from lowest to highest. Low ECL = higher capacity, but high ECL = more reliable reading if the matrix code is damaged).
		{
			CURRENT_ECL := A_Index
			Loop 4 ; There are 4 different types of encoded data in QR Code. Numeric, AlphaNumeric, Byte and Kanji.
			{
				CURRENT_TYPE := A_Index
				CURRENT_ADDRESS := ((CURRENT_VERSION - 1) * 16) + ((CURRENT_ECL - 1) * 4) + CURRENT_TYPE
				CAPACITY_CUBE[CURRENT_VERSION, CURRENT_ECL, CURRENT_TYPE] := CAPACITY_STRING_%CURRENT_ADDRESS%
				CAPACITY_STRING_%CURRENT_ADDRESS% := ""
			}
		}
	}
	CURRENT_VERSION := "", CURRENT_ECL := "", CURRENT_TYPE := "", CURRENT_ADDRESS := "", CAPACITY_STRING_0 := "", CAPACITY_STRING := ""
}
Return

CONVERT_TO_NUMERIC_ENCODING(MESSAGE_TO_ENCODE)
{
	Global
	MESSAGE_STRING := ""
	Bits_Of_Last_Group := 10
	If (Mod(StrLen(MESSAGE_TO_ENCODE), 3) = 2) ; If the last group is 2 digits long, it will be encoded as a 7 bits long binary number.
	{
		Bits_Of_Last_Group := 7
	}
	If (Mod(StrLen(MESSAGE_TO_ENCODE), 3) = 1) ; If the last group is 1 digit long, it will be encoded as a 4 bits long binary number.
	{
		Bits_Of_Last_Group := 4
	}
	Loop_Times := Ceil(StrLen(MESSAGE_TO_ENCODE) / 3) ; Numeric messages are encoded 3 digits a time.
	Message_Left := MESSAGE_TO_ENCODE ; This will be cut 3 digit a time in the loop bellow (to form the binary string).
	NUMBER_OF_BITS_TO_USE := 10 ; Initially, we will make sure every group has a total of 10 bits (appending as many zeros as necessary).
	Loop % Loop_Times ; This conditional executes once for every 3 digits in the message (rounded up).
	{
		If (A_Index = Loop_Times) ; If this is the last group, check the ammount of bits to pad according to variable Bits_Of_Last_Group.
		{
			NUMBER_OF_BITS_TO_USE := Bits_Of_Last_Group
		}	
		Current_Group := SubStr(Message_Left, 1, 3)

		MESSAGE_STRING := MESSAGE_STRING . SubStr("0000000000" . Bin(Current_Group), 1 - NUMBER_OF_BITS_TO_USE, NUMBER_OF_BITS_TO_USE) ; Explaining this: We are padding as many zeros as the groups max size to the binary string in the line above, and than we are getting the last NUMBER_OF_BITS_TO_USE digits of the concatenated result. This ensures that all and only the required zeros are padded to the string, whichever size .
		Message_Left := SubStr(Message_Left, 4)
	}
	Return MESSAGE_STRING
}
Return

CONVERT_TO_ALPHANUMERIC_ENCODING(MESSAGE_TO_ENCODE) ; Numeric messages are encoded 3 bits at a time in a 10 digit binary number (except for the last group, which may be 10, 7 or 4, depending on its length)
{
	Global
	MESSAGE_STRING := ""
	Bits_Of_Last_Group := 11
	If (Mod(StrLen(MESSAGE_TO_ENCODE), 2) = 1) ; If the string length is an odd number, the last character shall be encoded using 6 bits.
	{
		Bits_Of_Last_Group := 6
	}
	Loop_Times := Ceil(StrLen(MESSAGE_TO_ENCODE) / 2) ; Numeric messages are encoded 3 digits a time.
	Message_Left := MESSAGE_TO_ENCODE ; This will be cut 3 digit a time in the loop bellow (to form the binary string).
	NUMBER_OF_BITS_TO_USE := 11 ; Initially, we will make sure every group has a total of 11 bits (appending as many zeros as necessary).
	Loop % Loop_Times ; This conditional executes once for every 3 digits in the message (rounded up).
	{
		If (A_Index = Loop_Times) ; If this is the last group, check the ammount of bits to pad according to variable Bits_Of_Last_Group.
		{
			NUMBER_OF_BITS_TO_USE := Bits_Of_Last_Group
		}
		Current_Group := SubStr(Message_Left, 1, 2)
		FIRST_CHAR := SubStr(Current_Group, 1, 1)
		SECOND_CHAR := SubStr(Current_Group, 2, 1)
		if ((A_Index != Loop_Times) OR ((Mod(StrLen(MESSAGE_TO_ENCODE), 2) = 0)))
		{
			MESSAGE_STRING := MESSAGE_STRING . SubStr("00000000000" . Bin((ALPHA_TABLE[FIRST_CHAR] * 45) + ALPHA_TABLE[SECOND_CHAR]), 1 - NUMBER_OF_BITS_TO_USE, NUMBER_OF_BITS_TO_USE) ; Explaining this: We are padding as many zeros as the groups max size to the binary string in the line above, and than we are getting the last NUMBER_OF_BITS_TO_USE digits of the concatenated result. This ensures that all and only the required zeros are padded to the string, whichever size .
			Message_Left := SubStr(Message_Left, 3)
		}
		If ((A_Index = Loop_Times) AND (Mod(StrLen(MESSAGE_TO_ENCODE), 2) = 1))
		{
			MESSAGE_STRING := MESSAGE_STRING . SubStr("00000000000" . Bin(ALPHA_TABLE[FIRST_CHAR]), 1 - NUMBER_OF_BITS_TO_USE, NUMBER_OF_BITS_TO_USE) ; Explaining this: We are padding as many zeros as the groups max size to the binary string in the line above, and than we are getting the last NUMBER_OF_BITS_TO_USE digits of the concatenated result. This ensures that all and only the required zeros are padded to the string, whichever size .
			Message_Left := SubStr(Message_Left, 3)
		}
	}
	Return MESSAGE_STRING
}
Return

CONVERT_TO_BYTE_ENCODING(MESSAGE_TO_ENCODE)
{
	Global
	MESSAGE_STRING := ""
	Loop_Times := StrLen(MESSAGE_TO_ENCODE) ; Byte messages are encoded 1 char at a time.
	Message_Left := MESSAGE_TO_ENCODE
	NUMBER_OF_BITS_TO_USE := 8 ; Initially, we will make sure every group has a total of 8 bits (appending as many zeros as necessary).
	Loop % Loop_Times
	{
	Current_Group := SubStr(Message_Left, 1, 1)

		MESSAGE_STRING := MESSAGE_STRING . SubStr("00000000" . Bin(Asc(Current_Group)), 1 - NUMBER_OF_BITS_TO_USE, NUMBER_OF_BITS_TO_USE) ; Explaining this: We are padding as many zeros as the groups max size to the binary string in the line above, and than we are getting the last NUMBER_OF_BITS_TO_USE digits of the concatenated result. This ensures that all and only the required zeros are padded to the string, whichever size .
		Message_Left := SubStr(Message_Left, 2)
	}
	Return MESSAGE_STRING
}
Return

GET_GENERATOR_POLYNOMIAL(CHOOSEN_VERSION, CHOOSEN_ERROR_CORRECTION_LEVEL) ; Here we calculate the generator polynomial required.
{
	Global
	; The Generator polynomial for the Error Correction Words (ECW) is a result of the expression (X - a**0) * (X - a**1) * (X - a**2) ... (X - a**[n-1]) where n is equal do the number of codewords that must be generated.
	; This means that if you were to need a generator for 2 ECW, you would simply get a simplified galois field abiding form of (X - a**0) * (X - a**1), which is actually (a**0 * x**2 + a**25 * x**1 + a**1 * x**0).
	; A generator for 3 Error Correction Words is achieved simply by multiplying the generator for 2 ECW with (X-a**2). And so on for the next generators. More info on http://www.thonky.com/qr-code-tutorial/error-correction-coding/#step-7-understanding-the-generator-polynomial
		
	; Although it is thereby possible to generate a calculator for any generator polynomials based on required ECW, coding such a routine seems to be a waste of processing power since you only got 13 possible generator polynomials anyways. The ISO 18004 also gives the possible generators in an annex table.
	
	COMPOSITE_VERSION := CHOOSEN_VERSION . "-" . CHOOSEN_ERROR_CORRECTION_LEVEL ; This has been assigned on an earlier call to GET_NUMBER_OF_GROUPS_AND_BLOCKS.
	if (COMPOSITE_VERSION = "1-1") ; 1-L. 7 ECW.
	{
		NUMBER_OF_ECW := 7
		Loop, 7
			GENERATOR_X%A_Index% := 8 - A_Index + (StrLen(FINAL_MESSAGE_RAW_DATA_BITS) / 8) - 1
		GENERATOR_A1 := 0, GENERATOR_A2 := 87, GENERATOR_A3 := 229, GENERATOR_A4 := 146, GENERATOR_A5 := 149, GENERATOR_A6 := 238, GENERATOR_A7 := 102, GENERATOR_A8 := 21
		Return
	}
	
	If COMPOSITE_VERSION in 1-2,2-1 ; 1-M , 2-L. 10 ECW. ANY SPACES AND TABS AROUND THE COMMAS ARE SIGNIFICANT FOR IF VAR IN MATCHLIST !!
	{
		NUMBER_OF_ECW := 10
		Loop, 10
			GENERATOR_X%A_Index% := 11 - A_Index + (StrLen(FINAL_MESSAGE_RAW_DATA_BITS) / 8) - 1
		GENERATOR_A1 := 0, GENERATOR_A2 := 251, GENERATOR_A3 := 67, GENERATOR_A4 := 46, GENERATOR_A5 := 61, GENERATOR_A6 := 118, GENERATOR_A7 := 70, GENERATOR_A8 := 64, GENERATOR_A9 := 94, GENERATOR_A10 := 32, GENERATOR_A11 := 45
		Return
	}
	
	If COMPOSITE_VERSION in 1-3 ; 1-Q. 13 ECW
	{
		NUMBER_OF_ECW := 13
		Loop, 13
			GENERATOR_X%A_Index% := 14 - A_Index + (StrLen(FINAL_MESSAGE_RAW_DATA_BITS) / 8) - 1
		GENERATOR_A1 := 0, GENERATOR_A2 := 74, GENERATOR_A3 := 152, GENERATOR_A4 := 176, GENERATOR_A5 := 100, GENERATOR_A6 := 86, GENERATOR_A7 := 100, GENERATOR_A8 := 106, GENERATOR_A9 := 104, GENERATOR_A10 := 130, GENERATOR_A11 := 218, GENERATOR_A12 := 206, GENERATOR_A13 := 140, GENERATOR_A14 := 78
		Return
	}
	
	If COMPOSITE_VERSION in 3-1 ; 3-L. 15 ECW
	{
		NUMBER_OF_ECW := 15
		Loop, 15
			GENERATOR_X%A_Index% := 16 - A_Index + (StrLen(FINAL_MESSAGE_RAW_DATA_BITS) / 8) - 1
		GENERATOR_A1 := 0, GENERATOR_A2 := 8, GENERATOR_A3 := 183, GENERATOR_A4 := 61, GENERATOR_A5 := 91, GENERATOR_A6 := 202, GENERATOR_A7 := 37, GENERATOR_A8 := 51, GENERATOR_A9 := 58, GENERATOR_A10 := 58, GENERATOR_A11 := 237, GENERATOR_A12 := 140, GENERATOR_A13 := 124, GENERATOR_A14 := 5, GENERATOR_A15 := 99, GENERATOR_A16 := 105
		Return
	}
	
	If COMPOSITE_VERSION in 2-2,4-4,6-2 ; 2-M, 4-H, 6-M. 16 ECW
	{
		NUMBER_OF_ECW := 16
		Loop, 16
			GENERATOR_X%A_Index% := 17 - A_Index + (StrLen(FINAL_MESSAGE_RAW_DATA_BITS) / 8) - 1
		GENERATOR_A1 := 0, GENERATOR_A2 := 120, GENERATOR_A3 := 104, GENERATOR_A4 := 107, GENERATOR_A5 := 109, GENERATOR_A6 := 102, GENERATOR_A7 := 161, GENERATOR_A8 := 76, GENERATOR_A9 := 3, GENERATOR_A10 := 91, GENERATOR_A11 := 191, GENERATOR_A12 := 147, GENERATOR_A13 := 169, GENERATOR_A14 := 182, GENERATOR_A15 := 194, GENERATOR_A16 := 225, GENERATOR_A17 := 120
		Return
	}
	
	If COMPOSITE_VERSION in 1-4 ; 1-H. 17 ECW
	{
		NUMBER_OF_ECW := 17
		Loop, 17
			GENERATOR_X%A_Index% := 18 - A_Index + (StrLen(FINAL_MESSAGE_RAW_DATA_BITS) / 8) - 1
		GENERATOR_A1 := 0, GENERATOR_A2 := 43, GENERATOR_A3 := 139, GENERATOR_A4 := 206, GENERATOR_A5 := 78, GENERATOR_A6 := 43, GENERATOR_A7 := 239, GENERATOR_A8 := 123, GENERATOR_A9 := 206, GENERATOR_A10 := 214, GENERATOR_A11 := 147, GENERATOR_A12 := 24, GENERATOR_A13 := 99, GENERATOR_A14 := 150, GENERATOR_A15 := 39, GENERATOR_A16 := 243, GENERATOR_A17 := 163, GENERATOR_A18 := 136
		Return
	}
	
	If COMPOSITE_VERSION in 3-3,4-2,5-3,6-1,7-2,7-3,10-1 ; 3-Q, 4-M, 5-Q, 6-L, 7-M, 7-Q, 10-L. 18 ECW
	{
		NUMBER_OF_ECW := 18
		Loop, 18
			GENERATOR_X%A_Index% := 19 - A_Index + (StrLen(FINAL_MESSAGE_RAW_DATA_BITS) / 8) - 1
		GENERATOR_A1 := 0, GENERATOR_A2 := 215, GENERATOR_A3 := 234, GENERATOR_A4 := 158, GENERATOR_A5 := 94, GENERATOR_A6 := 184, GENERATOR_A7 := 97, GENERATOR_A8 := 118, GENERATOR_A9 := 170, GENERATOR_A10 := 79, GENERATOR_A11 := 187, GENERATOR_A12 :=152, GENERATOR_A13 := 148, GENERATOR_A14 := 252, GENERATOR_A15 := 179, GENERATOR_A16 := 5, GENERATOR_A17 := 98, GENERATOR_A18 := 96, GENERATOR_A19 := 153
		Return
	}
	
	If COMPOSITE_VERSION in 4-1,7-1,9-3,11-1,14-3 ; 4-L, 7-L, 9-Q, 11-L, 14-Q. 20 ECW
	{
		NUMBER_OF_ECW := 20
		Loop, 20
			GENERATOR_X%A_Index% := 21 - A_Index + (StrLen(FINAL_MESSAGE_RAW_DATA_BITS) / 8) - 1
		GENERATOR_A1 := 0, GENERATOR_A2 := 17, GENERATOR_A3 := 60, GENERATOR_A4 := 79, GENERATOR_A5 := 50, GENERATOR_A6 := 61, GENERATOR_A7 := 163, GENERATOR_A8 := 26, GENERATOR_A9 := 187, GENERATOR_A10 := 202, GENERATOR_A11 := 180, GENERATOR_A12 := 221, GENERATOR_A13 := 225, GENERATOR_A14 := 83, GENERATOR_A15 := 239, GENERATOR_A16 := 156, GENERATOR_A17 := 164, GENERATOR_A18 := 212, GENERATOR_A19 := 212, GENERATOR_A20 := 188, GENERATOR_A21 := 190
		Return
	}
	
	If COMPOSITE_VERSION in 2-3,3-4,5-4,8-2,8-3,9-2,12-2,13-2,13-4,15-1 ; 2-Q, 3-H, 5-H, 8-M, 8-Q, 9-M, 12-M, 13-M, 13-H, 15-L. 22 ECW
	{
		NUMBER_OF_ECW := 22
		Loop, 22
			GENERATOR_X%A_Index% := 23 - A_Index + (StrLen(FINAL_MESSAGE_RAW_DATA_BITS) / 8) - 1
		GENERATOR_A1 := 0, GENERATOR_A2 := 210, GENERATOR_A3 := 171, GENERATOR_A4 := 247, GENERATOR_A5 := 242, GENERATOR_A6 := 93, GENERATOR_A7 := 230, GENERATOR_A8 := 14, GENERATOR_A9 := 109, GENERATOR_A10 := 221, GENERATOR_A11 := 53, GENERATOR_A12 := 200, GENERATOR_A13 := 74, GENERATOR_A14 := 8, GENERATOR_A15 := 172, GENERATOR_A16 := 98, GENERATOR_A17 := 80, GENERATOR_A18 := 219, GENERATOR_A19 := 134, GENERATOR_A20 := 160, GENERATOR_A21 := 105, GENERATOR_A22 := 165, GENERATOR_A23 := 231
		Return
	}
	
	If COMPOSITE_VERSION in 5-2,6-3,8-1,9-4,10-3,11-4,12-1,13-3,14-2,14-4,15-2,15-4,16-1,16-3,22-4 ; 5-M, 6-Q, 8-L, 9-H, 10-Q, 11-H, 12-L, 13-Q, 14-M, 14-H, 15-M, 15-H, 16-L, 16-Q, 22-H. 24 ECW
	{
		NUMBER_OF_ECW := 24
		Loop, 24
			GENERATOR_X%A_Index% := 25 - A_Index + (StrLen(FINAL_MESSAGE_RAW_DATA_BITS) / 8) - 1
		GENERATOR_A1 := 0, GENERATOR_A2 := 229, GENERATOR_A3 := 121, GENERATOR_A4 := 135, GENERATOR_A5 := 48, GENERATOR_A6 := 211, GENERATOR_A7 := 117, GENERATOR_A8 := 251, GENERATOR_A9 := 126, GENERATOR_A10 := 159, GENERATOR_A11 := 180, GENERATOR_A12 := 169, GENERATOR_A13 := 152, GENERATOR_A14 := 192, GENERATOR_A15 := 226, GENERATOR_A16 := 228, GENERATOR_A17 := 218, GENERATOR_A18 := 111, GENERATOR_A19 := 0, GENERATOR_A20 := 117, GENERATOR_A21 := 232, GENERATOR_A22 := 87, GENERATOR_A23 := 96, GENERATOR_A24 := 227, GENERATOR_A25 := 21
		Return
	}
	
	If COMPOSITE_VERSION in 3-2,4-3,5-1,7-4,8-4,10-2,12-3,13-1,18-2,19-2,19-3,19-4,20-2,21-2,25-1 ; 3-M, 4-Q, 5-L, 7-H, 8-H, 10-M, 12-Q, 13-L, 18-M, 19-M, 19-Q, 19-H, 20-M, 21-M, 25-L. 26 ECW
	{
		NUMBER_OF_ECW := 26
		Loop, 26
			GENERATOR_X%A_Index% := 27 - A_Index + (StrLen(FINAL_MESSAGE_RAW_DATA_BITS) / 8) - 1
		GENERATOR_A1 := 0, GENERATOR_A2 := 173, GENERATOR_A3 := 125, GENERATOR_A4 := 158, GENERATOR_A5 := 2, GENERATOR_A6 := 103, GENERATOR_A7 := 182, GENERATOR_A8 := 118, GENERATOR_A9 := 17, GENERATOR_A10 := 145, GENERATOR_A11 := 201, GENERATOR_A12 := 111, GENERATOR_A13 := 28, GENERATOR_A14 := 165, GENERATOR_A15 := 53, GENERATOR_A16 := 161, GENERATOR_A17 := 21, GENERATOR_A18 := 245, GENERATOR_A19 := 142, GENERATOR_A20 := 13, GENERATOR_A21 := 102, GENERATOR_A22 := 48, GENERATOR_A23 := 227, GENERATOR_A24 := 153, GENERATOR_A25 := 145, GENERATOR_A26 := 218, GENERATOR_A27 := 70
		Return
	}
	
	If COMPOSITE_VERSION in 2-4,6-4,10-4,11-3,12-4,16-2,17-1,17-2,17-3,17-4,18-3,18-4,19-1,20-1,20-4,21-1,21-3,22-1,22-2,23-2,24-2,25-2,26-1,26-2,26-3,27-2,28-2,29-2,30-2,31-2,32-2,33-2,34-2,35-2,36-2,37-2,38-2,39-2,40-2 ; 2-H, 6-H, 10-H, 11-Q, 12-H, 16-M, 17-L, 17-M, 17-Q, 17-H, 18-Q, 18-H, 19-L, 20-L, 20-H, 21-L, 21-Q, 22-L, 22-M, 23-M, 24-M, 25-M, 26-L, 26-M, 26-Q, 27-2, 28-M, 29-M, 30-M, 31-M, 32-M, 33-2, 34-M, 35-M, 36-M, 37-M, 38-M, 39-M, 40-M 28 ECW
	{
		NUMBER_OF_ECW := 28
		Loop, 28
			GENERATOR_X%A_Index% := 29 - A_Index + (StrLen(FINAL_MESSAGE_RAW_DATA_BITS) / 8) - 1
		GENERATOR_A1 := 0, GENERATOR_A2 := 168, GENERATOR_A3 := 223, GENERATOR_A4 := 200, GENERATOR_A5 := 104, GENERATOR_A6 := 224, GENERATOR_A7 := 234, GENERATOR_A8 := 108, GENERATOR_A9 := 180, GENERATOR_A10 := 110, GENERATOR_A11 := 190, GENERATOR_A12 := 195, GENERATOR_A13 := 147, GENERATOR_A14 := 205, GENERATOR_A15 := 27, GENERATOR_A16 := 232, GENERATOR_A17 := 201, GENERATOR_A18 := 21, GENERATOR_A19 := 43, GENERATOR_A20 := 245, GENERATOR_A21 := 87, GENERATOR_A22 := 42, GENERATOR_A23 := 195, GENERATOR_A24 := 212, GENERATOR_A25 := 119, GENERATOR_A26 := 242, GENERATOR_A27 := 37, GENERATOR_A28 := 9, GENERATOR_A29 := 123
		Return
	}
	
	NUMBER_OF_ECW := 30 ; If the number of ECW is not any one of the above, that means we have 30 ECW  (the maximum).
	Loop, 30
		GENERATOR_X%A_Index% := 31 - A_Index + (StrLen(FINAL_MESSAGE_RAW_DATA_BITS) / 8) - 1
	GENERATOR_A1 := 0, GENERATOR_A2 := 41, GENERATOR_A3 := 173, GENERATOR_A4 := 145, GENERATOR_A5 := 152, GENERATOR_A6 := 216, GENERATOR_A7 := 31, GENERATOR_A8 := 179, GENERATOR_A9 := 182, GENERATOR_A10 := 50, GENERATOR_A11 := 48, GENERATOR_A12 := 110, GENERATOR_A13 := 86, GENERATOR_A14 := 239, GENERATOR_A15 := 96, GENERATOR_A16 := 222, GENERATOR_A17 := 125, GENERATOR_A18 := 42, GENERATOR_A19 := 173, GENERATOR_A20 := 226, GENERATOR_A21 := 193, GENERATOR_A22 := 224, GENERATOR_A23 := 130, GENERATOR_A24 := 156, GENERATOR_A25 := 37, GENERATOR_A26 := 251, GENERATOR_A27 := 216, GENERATOR_A28 := 238, GENERATOR_A29 := 40, GENERATOR_A30 := 192, GENERATOR_A31 := 180
	Return
}
Return


LIST_NUMBER_OF_GROUPS_AND_BLOCKS()
{
	Global
	; We are going to create 4 lines (one for each ECL) with 40 entries on number of: BLOCKS IN GROUP 1|BLOCKS IN GROUP 2, CW IN BLOCKS OF GROUP 1, CW IN BLOCKS OF GROUP 2.
	BLOCKS_AND_GROUPS := ""
	BLOCKS_AND_GROUPS := object()
	BLOCKS_AND_GROUPS[1] := ["1|0|19|0", "1|0|34|0", "1|0|55|0", "1|0|80|0", "1|0|108|0", "2|0|68|0", "2|0|78|0", "2|0|97|0", "2|0|116|0", "2|2|68|69", "4|0|81|0", "2|2|92|93", "4|0|107|0", "3|1|115|116", "5|1|87|88", "5|1|98|99", "1|5|107|108", "5|1|120|121", "3|4|113|114", "3|5|107|108", "4|4|116|117", "2|7|111|112", "4|5|121|122", "6|4|117|118", "8|4|106|107", "10|2|114|115", "8|4|122|123", "3|10|117|118", "7|7|116|117", "5|10|115|116", "13|3|115|116", "17|0|115|0", "17|1|115|116", "13|6|115|116", "12|7|121|122", "6|14|121|122", "17|4|122|123", "4|18|122|123", "20|4|117|118", "19|6|118|119"] ; The 40 values for ECL L.
	BLOCKS_AND_GROUPS[2] := ["1|0|16|0", "1|0|28|0", "1|0|44|0", "2|0|32|0", "2|0|43|0", "4|0|27|0", "4|0|31|0", "2|2|38|39", "3|2|36|37", "4|1|43|44", "1|4|50|51", "6|2|36|37", "8|1|37|38", "4|5|40|41", "5|5|41|42", "7|3|45|46", "10|1|46|47", "9|4|43|44", "3|11|44|45", "3|13|41|42", "17|0|42|0", "17|0|46|0", "4|14|47|48", "6|14|45|46", "8|13|47|48", "19|4|46|47", "22|3|45|46", "3|23|45|46", "21|7|45|46", "19|10|47|48", "2|29|46|47", "10|23|46|47", "14|21|46|47", "14|23|46|47", "12|26|47|48", "6|34|47|48", "29|14|46|47", "13|32|46|47", "40|7|47|48", "18|31|47|48"] ; The 40 values for ECL M.
	BLOCKS_AND_GROUPS[3] := ["1|0|13|0", "1|0|22|0", "2|0|17|0", "2|0|24|0", "2|2|15|16", "4|0|19|0", "2|4|14|15", "4|2|18|19", "4|4|16|17", "6|2|19|20", "4|4|22|23", "4|6|20|21", "8|4|20|21", "11|5|16|17", "5|7|24|25", "15|2|19|20", "1|15|22|23", "17|1|22|23", "17|4|21|22", "15|5|24|25", "17|6|22|23", "7|16|24|25", "11|14|24|25", "11|16|24|25", "7|22|24|25", "28|6|22|23", "8|26|23|24", "4|31|24|25", "1|37|23|24", "15|25|24|25", "42|1|24|25", "10|35|24|25", "29|19|24|25", "44|7|24|25", "39|14|24|25", "46|10|24|25", "49|10|24|25", "48|14|24|25", "43|22|24|25", "34|34|24|25"] ; The 40 values for ECL Q.
	BLOCKS_AND_GROUPS[4] := ["1|0|9|0", "1|0|16|0", "2|0|13|0", "4|0|9|0", "2|2|11|12", "4|0|15|0", "4|1|13|14", "4|2|14|15", "4|4|12|13", "6|2|15|16", "3|8|12|13", "7|4|14|15", "12|4|11|12", "11|5|12|13", "11|7|12|13", "3|13|15|16", "2|17|14|15", "2|19|14|15", "9|16|13|14", "15|10|15|16", "19|6|16|17", "34|0|13|0", "16|14|15|16", "30|2|16|17", "22|13|15|16", "33|4|16|17", "12|28|15|16", "11|31|15|16", "19|26|15|16", "23|25|15|16", "23|28|15|16", "19|35|15|16", "11|46|15|16", "59|1|16|17", "22|41|15|16", "2|64|15|16", "24|46|15|16", "42|32|15|16", "10|67|15|16", "20|61|15|16"] ; The 40 values for ECL H.
}
Return

GENERATE_ERROR_CORRECTION_CODEWORDS(FINAL_MESSAGE_RAW_DATA_BITS, CHOOSEN_ERROR_CORRECTION_LEVEL, GROUP, BLOCK, CHOOSEN_VERSION) ; The total number of ECW depends on version and ECL.

; Generator polynomial for 28 error correction code words as an example. Numbers are exponents: x28 + a168x27 + a223x26 + a200x25 + a104x24 + a224x23 + a234x22 + a108x21 + a180x20 + a110x19 + a190x18 + a195x17 + a147x16 + a205x15 + a27x14 + a232x13 + a201x12 + a21x11 + a43x10 + a245x9 + a87x8 + a42x7 + a195x6 + a212x5 + a119x4 + a242x3 + a37x2 + a9x + a123
{
	Global
	GET_GENERATOR_POLYNOMIAL(CHOOSEN_VERSION, CHOOSEN_ERROR_CORRECTION_LEVEL)
	MESSAGE_POLYNOMIAL := "", ERROR_CORRECTION_CODEWORDS := "" ; Free the ECW object list and the message polynomial.

	MESSAGE_POLYNOMIAL := FINAL_MESSAGE_RAW_DATA_BITS
	
	NUMBER_OF_MESSAGE_BYTES := StrLen(FINAL_MESSAGE_RAW_DATA_BITS) / 8

	Loop % NUMBER_OF_MESSAGE_BYTES ; We create an index with the value of the bytes of the message.
	{
		BYTE_%A_Index%_OF_MESSAGE_POLYNOMIAL := Dec(SubStr(MESSAGE_POLYNOMIAL, 1, 8))
		StringTrimLeft, MESSAGE_POLYNOMIAL, MESSAGE_POLYNOMIAL, 8
	}

	GENERATOR_FIRST := NUMBER_OF_ECW + 1 ; To be deducted on every step

	; Looping routine starts here.

	Loop % NUMBER_OF_MESSAGE_BYTES
	{
		GET_GENERATOR_POLYNOMIAL(CHOOSEN_VERSION, CHOOSEN_ERROR_CORRECTION_LEVEL)
	
	
	; 	Step a - Multiply the Generator Polynomial by the Lead Term of the Message Polynomial
		Loop % NUMBER_OF_ECW + NUMBER_OF_MESSAGE_BYTES ; below, we transform the bytes of the message into alpha exponent sums for the generator polynomial alphas. To do that, we transform the byte into it's alpha exponent value according to the table.
		{
			GENERATOR_A%A_Index% := Mod(GENERATOR_A%A_Index% + AntilogTable[BYTE_1_OF_MESSAGE_POLYNOMIAL], 255)
		}
	
	
		Loop % NUMBER_OF_ECW + NUMBER_OF_MESSAGE_BYTES
		{
			GENERATOR_A%A_Index% := LogTable[GENERATOR_A%A_Index%] ; This will revert the alpha notation to the X multiplier. End of step 1a.
		}
	
		; Step b - XOR the result with the message polynomial (XOR with Zero for the lacking generator bytes and vice versa).


		NEW_MESSAGE_LIST := ""
		
		Loop % NUMBER_OF_ECW + NUMBER_OF_MESSAGE_BYTES
		{
			NEXT_ITERATION := A_Index + 1
			BYTE_%A_INDEX%_OF_MESSAGE_POLYNOMIAL := ((GENERATOR_A%NEXT_ITERATION% > 0) ? (GENERATOR_A%NEXT_ITERATION%) : (0)) ^ ((BYTE_%NEXT_ITERATION%_OF_MESSAGE_POLYNOMIAL > 0) ? (BYTE_%NEXT_ITERATION%_OF_MESSAGE_POLYNOMIAL) : (0))
			MESSAGE_X%A_Index% := (NUMBER_OF_ECW + NUMBER_OF_MESSAGE_BYTES) - A_Index + NUMBER_OF_ECW  ; Here we create the exponents of X in the Message Polynomial.
		}

		GENERATOR_FIRST--
		Loop % NUMBER_OF_ECW + NUMBER_OF_MESSAGE_BYTES
		{
			GENERATOR_X%A_Index% := GENERATOR_FIRST - A_Index + 15 
		}
	}

	ERROR_CORRECTION_CODEWORDS_%GROUP%_%BLOCK% := ""
	ERROR_CORRECTION_CODEWORDS_%GROUP%_%BLOCK% := object()
	Loop % NUMBER_OF_ECW + 1 ; Retrieve the Error Correction Codewords to return to the caller.
	{
		ERROR_CORRECTION_CODEWORDS_%GROUP%_%BLOCK%[A_Index] := BYTE_%A_INDEX%_OF_MESSAGE_POLYNOMIAL
	}

	Loop % NUMBER_OF_ECW + NUMBER_OF_MESSAGE_BYTES + 2 ; Free the message polynomial bytes for future use.
	{
		BYTE_%A_Index%_OF_MESSAGE_POLYNOMIAL := "", MESSAGE_X%A_Index% := "", GENERATOR_X%A_Index% := "", GENERATOR_A%A_Index% := ""
	}
	
	NUMBER_OF_MESSAGE_BYTES := "", GENERATOR_FIRST := "", NEXT_ITERATION := ""
}

Return


GENERATE_MATRIX(FINAL_MESSAGE, CHOOSEN_VERSION, CHOOSEN_ERROR_CORRECTION_LEVEL)
;Brief note:
; Here is the idea. Add all bits of CW + ECW, than apply masks and only than add the function patterns and the reserved areas (so that you can evaluate the mask) the last being all light color modules. 
{
	Global
	MATRIX_UNMASKED := object()
	
	MATRIX_DIMENSIONS := 17 + (CHOOSEN_VERSION * 4) ; First, we set the matrix dimensions. Since matrix dimensions start on 21 x 21 modules for V1 and increase by 4 modules on every subsequent version.
	
	CURRENT_ROW := 1, COUNTER := 0
	While (COUNTER < (MATRIX_DIMENSIONS**2 - MATRIX_DIMENSIONS)) ; We access each of the rows by the formula MATRIX_DIMENSIONS + 1 - CURRENT_ROW. Since the 7th column is entirely skipped before we enter it (because it belongs to a timing pattern that holds the exception regarding the writing algorithm)
	{
		CURRENT_COLUMN++
		If (CURRENT_ROW = MATRIX_DIMENSIONS + 1) ; If this condition is met, we have left the below loop by the means of exceeding the upper limits of the matrix.
		{
			CURRENT_ROW := MATRIX_DIMENSIONS, CURRENT_COLUMN++
		}
		If (CURRENT_ROW = 0) ; If this condition is met, we have left the below loop by the means of exceeding the bottom limits of the matrix.
		{
			CURRENT_ROW := 1, CURRENT_COLUMN++
		}
		If (MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN = 7) ; If this condition is met, we have reached the vertical timing pattern, which holds an exception to the writing algorithm, so we have to skipp writing to that column entirely and move the message writing position as though.
		{
			CURRENT_COLUMN++
		}
		While ((CURRENT_ROW <= MATRIX_DIMENSIONS) AND (CURRENT_ROW > 0) AND (CURRENT_COLUMN <= MATRIX_DIMENSIONS)) ; And than we access each of the individual modules (or the columns of individual rows). We access the columns by the formula MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN
		{
			COUNTER++
			NOT_WRITE := 0
			
			; Now to check if the current module address belongs to a function finder pattern.
			
			; First, we check if the current module address reffers to a module located in the right-uppermost function finder pattern.
			
			If ((MATRIX_DIMENSIONS + 1 - CURRENT_ROW <= 9) AND (MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN <= 9)) ; At least 9 modules from the top and 9 modules from the left limits of the matrixes: all module addresses that satisfy these conditions are in the left-uppermost function finder pattern.
			{
				NOT_WRITE := 1
			}
			
			If ((MATRIX_DIMENSIONS + 1 - CURRENT_ROW <= 9) AND (MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN >= MATRIX_DIMENSIONS - 7)) ; At least 9 modules from the top and 8 from the right limits of the matrixes: all module addresses that satisfy these conditions are in the right-uppermost function finder pattern.
			{
				NOT_WRITE := 1
			}
			
			If ((MATRIX_DIMENSIONS + 1 - CURRENT_ROW >= MATRIX_DIMENSIONS - 7) AND (MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN <= 9)) ; At least 8 modules from the base and 9 modules from the left limits of the matrixes: all module addresses that satisfy these conditions are in the left-bottommost function finder pattern.
			{
				NOT_WRITE := 1
			}
			
			; Now to check if the current module address belongs to a version information area (these exist only on version 7 or greater QR Matrixes)
			If (CHOOSEN_VERSION >= 7)
			{
				If ((MATRIX_DIMENSIONS + 1 - CURRENT_ROW <= 6) AND (MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN >= MATRIX_DIMENSIONS - 10)) ; Between 9 to 11 modules from the right and 1 to 6 modules from the top limits of the matrixes: all module addresses that satisfy these conditions are located in the top-rightmost version information area, which exists only for versions 7 and higher.
				{
					NOT_WRITE := 1
				}
				
				If ((MATRIX_DIMENSIONS + 1 - CURRENT_ROW >= MATRIX_DIMENSIONS - 10) AND (MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN <= 6)) ; Between 9 to the 11 modules from the bottom and 1 to 6 modules from the left limits of the matrixes: all module addresses that satisfy these conditions are located in the bottom-leftmost version information area, which exists only for versions 7 and higher.
				{
					NOT_WRITE := 1
				}
			}
			
			; Now to check if the current module address belongs to a function ALIGNMENT pattern.
			
			; We start off creating a string with the addresses for the upper-left modules of the alignment patterns of the choosen version.
			; Version 1 Matrixes don't have any alignment patterns.
			ALIGNMENT_LOCATIONS := "" ; We start off erasing this variable just to make sure it starts off empty.
			% ((CHOOSEN_VERSION = 2) ? (ALIGNMENT_LOCATIONS := "17x17") : ("")), ((CHOOSEN_VERSION = 3) ? (ALIGNMENT_LOCATIONS := "21x21") : ("")), ((CHOOSEN_VERSION = 4) ? (ALIGNMENT_LOCATIONS := "25x25") : ("")), ((CHOOSEN_VERSION = 5) ? (ALIGNMENT_LOCATIONS := "29x29") : ("")), ((CHOOSEN_VERSION = 6) ? (ALIGNMENT_LOCATIONS := "33x33") : (""))
			% ((CHOOSEN_VERSION = 7) ? (ALIGNMENT_LOCATIONS := "5x21|21x5|21x21|21x37|37x21|37x37") : ("")), ((CHOOSEN_VERSION = 8) ? (ALIGNMENT_LOCATIONS := "5x23|23x5|23x23|23x41|41x23|41x41") : ("")), ((CHOOSEN_VERSION = 9) ? (ALIGNMENT_LOCATIONS := "5x25|25x5|25x25|25x45|45x25|45x45") : ("")), ((CHOOSEN_VERSION = 10) ? (ALIGNMENT_LOCATIONS := "5x27|27x5|27x27|27x49|49x27|49x49") : ("")), ((CHOOSEN_VERSION = 11) ? (ALIGNMENT_LOCATIONS := "5x29|29x5|29x29|29x53|53x29|53x53") : ("")), ((CHOOSEN_VERSION = 12) ? (ALIGNMENT_LOCATIONS := "5x31|31x5|31x31|31x57|57x31|57x57") : ("")), ((CHOOSEN_VERSION = 13) ? (ALIGNMENT_LOCATIONS := "5x33|33x5|33x33|33x61|61x33|61x61") : (""))
			% ((CHOOSEN_VERSION = 14) ? (ALIGNMENT_LOCATIONS := "5x25|5x45|25x5|25x25|25x45|25x65|45x5|45x25|45x45|45x65|65x25|65x45|65x65") : ("")), ((CHOOSEN_VERSION = 15) ? (ALIGNMENT_LOCATIONS := "5x25|5x47|25x5|25x25|25x47|25x69|47x5|47x25|47x47|47x69|69x25|69x47|69x69") : ("")), ((CHOOSEN_VERSION = 16) ? (ALIGNMENT_LOCATIONS := "5x25|5x49|25x5|25x25|25x49|25x73|49x5|49x25|49x49|49x73|73x25|73x49|73x73") : ("")), ((CHOOSEN_VERSION = 17) ? (ALIGNMENT_LOCATIONS := "5x29|5x53|29x5|29x29|29x53|29x77|53x5|53x29|53x53|53x77|77x29|77x53|77x77") : ("")), ((CHOOSEN_VERSION = 18) ? (ALIGNMENT_LOCATIONS := "5x29|5x55|29x5|29x29|29x55|29x81|55x5|55x29|55x55|55x81|81x29|81x55|81x81") : ("")), ((CHOOSEN_VERSION = 19) ? (ALIGNMENT_LOCATIONS := "5x29|5x57|29x5|29x29|29x57|29x85|57x5|57x29|57x57|57x85|85x29|85x57|85x85") : ("")), ((CHOOSEN_VERSION = 20) ? (ALIGNMENT_LOCATIONS := "5x33|5x61|33x5|33x33|33x61|33x89|61x5|61x33|61x61|61x89|89x33|89x61|89x89") : (""))
			% ((CHOOSEN_VERSION = 21) ? (ALIGNMENT_LOCATIONS := "5x27|5x49|5x71|27x5|27x27|27x49|27x71|27x93|49x5|49x27|49x49|49x71|49x93|71x5|71x27|71x49|71x71|71x93|93x27|93x49|93x71|93x93") : ("")), ((CHOOSEN_VERSION = 22) ? (ALIGNMENT_LOCATIONS := "5x25|5x49|5x73|25x5|25x25|25x49|25x73|25x97|49x5|49x25|49x49|49x73|49x97|73x5|73x25|73x49|73x73|73x97|97x25|97x49|97x73|97x97") : ("")), ((CHOOSEN_VERSION = 23) ? (ALIGNMENT_LOCATIONS := "5x29|5x53|5x77|29x5|29x29|29x53|29x77|29x101|53x5|53x29|53x53|53x77|53x101|77x5|77x29|77x53|77x77|77x101|101x29|101x53|101x77|101x101") : ("")), ((CHOOSEN_VERSION = 24) ? (ALIGNMENT_LOCATIONS := "5x27|5x53|5x79|27x5|27x27|27x53|27x79|27x105|53x5|53x27|53x53|53x79|53x105|79x5|79x27|79x53|79x79|79x105|105x27|105x53|105x79|105x105") : ("")), ((CHOOSEN_VERSION = 25) ? (ALIGNMENT_LOCATIONS := "5x31|5x57|5x83|31x5|31x31|31x57|31x83|31x109|57x5|57x31|57x57|57x83|57x109|83x5|83x31|83x57|83x83|83x109|109x31|109x57|109x83|109x109") : ("")), ((CHOOSEN_VERSION = 26) ? (ALIGNMENT_LOCATIONS := "5x29|5x57|5x85|29x5|29x29|29x57|29x85|29x113|57x5|57x29|57x57|57x85|57x113|85x5|85x29|85x57|85x85|85x113|113x29|113x57|113x85|113x113") : ("")), ((CHOOSEN_VERSION = 27) ? (ALIGNMENT_LOCATIONS := "5x33|5x61|5x89|33x5|33x33|33x61|33x89|33x117|61x5|61x33|61x61|61x89|61x117|89x5|89x33|89x61|89x89|89x117|117x33|117x61|117x89|117x117") : (""))
			% ((CHOOSEN_VERSION = 28) ? (ALIGNMENT_LOCATIONS := "5x25|5x49|5x73|5x97|25x5|25x25|25x49|25x73|25x97|25x121|49x5|49x25|49x49|49x73|49x97|49x121|73x5|73x25|73x49|73x73|73x97|73x121|97x5|97x25|97x49|97x73|97x97|97x121|121x25|121x49|121x73|121x97|121x121") : ("")), ((CHOOSEN_VERSION = 29) ? (ALIGNMENT_LOCATIONS := "5x29|5x53|5x77|5x101|29x5|29x29|29x53|29x77|29x101|29x125|53x5|53x29|53x53|53x77|53x101|53x125|77x5|77x29|77x53|77x77|77x101|77x125|101x5|101x29|101x53|101x77|101x101|101x125|125x29|125x53|125x77|125x101|125x125") : ("")), ((CHOOSEN_VERSION = 30) ? (ALIGNMENT_LOCATIONS := "5x25|5x51|5x77|5x103|25x5|25x25|25x51|25x77|25x103|25x129|51x5|51x25|51x51|51x77|51x103|51x129|77x5|77x25|77x51|77x77|77x103|77x129|103x5|103x25|103x51|103x77|103x103|103x129|129x25|129x51|129x77|129x103|129x129") : ("")), ((CHOOSEN_VERSION = 31) ? (ALIGNMENT_LOCATIONS := "5x29|5x55|5x81|5x107|29x5|29x29|29x55|29x81|29x107|29x133|55x5|55x29|55x55|55x81|55x107|55x133|81x5|81x29|81x55|81x81|81x107|81x133|107x5|107x29|107x55|107x81|107x107|107x133|133x29|133x55|133x81|133x107|133x133") : ("")), ((CHOOSEN_VERSION = 32) ? (ALIGNMENT_LOCATIONS := "5x33|5x59|5x85|5x111|33x5|33x33|33x59|33x85|33x111|33x137|59x5|59x33|59x59|59x85|59x111|59x137|85x5|85x33|85x59|85x85|85x111|85x137|111x5|111x33|111x59|111x85|111x111|111x137|137x33|137x59|137x85|137x111|137x137") : ("")), ((CHOOSEN_VERSION = 33) ? (ALIGNMENT_LOCATIONS := "5x29|5x57|5x85|5x113|29x5|29x29|29x57|29x85|29x113|29x141|57x5|57x29|57x57|57x85|57x113|57x141|85x5|85x29|85x57|85x85|85x113|85x141|113x5|113x29|113x57|113x85|113x113|113x141|141x29|141x57|141x85|141x113|141x141") : ("")), ((CHOOSEN_VERSION = 34) ? (ALIGNMENT_LOCATIONS := "5x33|5x61|5x89|5x117|33x5|33x33|33x61|33x89|33x117|33x145|61x5|61x33|61x61|61x89|61x117|61x145|89x5|89x33|89x61|89x89|89x117|89x145|117x5|117x33|117x61|117x89|117x117|117x145|145x33|145x61|145x89|145x117|145x145") : (""))
			% ((CHOOSEN_VERSION = 35) ? (ALIGNMENT_LOCATIONS := "5x29|5x53|5x77|5x101|5x125|29x5|29x29|29x53|29x77|29x101|29x125|29x149|53x5|53x29|53x53|53x77|53x101|53x125|53x149|77x5|77x29|77x53|77x77|77x101|77x125|77x149|101x5|101x29|101x53|101x77|101x101|101x125|101x149|125x5|125x29|125x53|125x77|125x101|125x125|125x149|149x29|149x53|149x77|149x101|149x125|149x149") : ("")), ((CHOOSEN_VERSION = 36) ? (ALIGNMENT_LOCATIONS := "5x23|5x49|5x75|5x101|5x127|23x5|23x23|23x49|23x75|23x101|23x127|23x153|49x5|49x23|49x49|49x75|49x101|49x127|49x153|75x5|75x23|75x49|75x75|75x101|75x127|75x153|101x5|101x23|101x49|101x75|101x101|101x127|101x153|127x5|127x23|127x49|127x75|127x101|127x127|127x153|153x23|153x49|153x75|153x101|153x127|153x153") : ("")), ((CHOOSEN_VERSION = 37) ? (ALIGNMENT_LOCATIONS := "5x27|5x53|5x79|5x105|5x131|27x5|27x27|27x53|27x79|27x105|27x131|27x157|53x5|53x27|53x53|53x79|53x105|53x131|53x157|79x5|79x27|79x53|79x79|79x105|79x131|79x157|105x5|105x27|105x53|105x79|105x105|105x131|105x157|131x5|131x27|131x53|131x79|131x105|131x131|131x157|157x27|157x53|157x79|157x105|157x131|157x157") : ("")), ((CHOOSEN_VERSION = 38) ? (ALIGNMENT_LOCATIONS := "5x31|5x57|5x83|5x109|5x135|31x5|31x31|31x57|31x83|31x109|31x135|31x161|57x5|57x31|57x57|57x83|57x109|57x135|57x161|83x5|83x31|83x57|83x83|83x109|83x135|83x161|109x5|109x31|109x57|109x83|109x109|109x135|109x161|135x5|135x31|135x57|135x83|135x109|135x135|135x161|161x31|161x57|161x83|161x109|161x135|161x161") : ("")), ((CHOOSEN_VERSION = 39) ? (ALIGNMENT_LOCATIONS := "5x25|5x53|5x81|5x109|5x137|25x5|25x25|25x53|25x81|25x109|25x137|25x165|53x5|53x25|53x53|53x81|53x109|53x137|53x165|81x5|81x25|81x53|81x81|81x109|81x137|81x165|109x5|109x25|109x53|109x81|109x109|109x137|109x165|137x5|137x25|137x53|137x81|137x109|137x137|137x165|165x25|165x53|165x81|165x109|165x137|165x165") : ("")), ((CHOOSEN_VERSION = 40) ? (ALIGNMENT_LOCATIONS := "5x29|5x57|5x85|5x113|5x141|29x5|29x29|29x57|29x85|29x113|29x141|29x169|57x5|57x29|57x57|57x85|57x113|57x141|57x169|85x5|85x29|85x57|85x85|85x113|85x141|85x169|113x5|113x29|113x57|113x85|113x113|113x141|113x169|141x5|141x29|141x57|141x85|141x113|141x141|141x169|169x29|169x57|169x85|169x113|169x141|169x169") : (""))
			
			; Now, we separate the strings into the individual addresses
			ALIGNMENT_INDIVIDUAL_COORDINATES_ := ""
			StringSplit, ALIGNMENT_INDIVIDUAL_COORDINATES_, ALIGNMENT_LOCATIONS, "|"
			
			
			Loop % ALIGNMENT_INDIVIDUAL_COORDINATES_0
			{
				INDIVIDUAL_ALIGNMENT_COORDS_ := ""
				StringSplit, INDIVIDUAL_ALIGNMENT_COORDS_, ALIGNMENT_INDIVIDUAL_COORDINATES_%A_Index%, x
				If ((MATRIX_DIMENSIONS + 1 - CURRENT_ROW >= INDIVIDUAL_ALIGNMENT_COORDS_1) AND (MATRIX_DIMENSIONS + 1 - CURRENT_ROW <= INDIVIDUAL_ALIGNMENT_COORDS_1 + 4) AND (MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN >= INDIVIDUAL_ALIGNMENT_COORDS_2) AND (MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN <= INDIVIDUAL_ALIGNMENT_COORDS_2 + 4)) ; If these conditons are met, we are at an alignment patterns area.
				{
					NOT_WRITE := 1 
				}
			}
			
			
			; Now to check if the current module address belongs to a timing pattern.
			; The timing patterns are always located in the 7th row and the 7th column.
			if (MATRIX_DIMENSIONS + 1 - CURRENT_ROW = 7)
			{
				NOT_WRITE := 1
			}
			
			if (MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN = 7)
			{
				NOT_WRITE := 1
			}
			
			; CODE TO MOVE IF WE ARE NOT IN ANY FUNCTION PATTERN OR RESERVED AREA.
			; Now things get a little tricky. QR Code matrixes are always odd numbered dimensioned. This means that the column we start off positiong the EC + ECW is always an even numbered columm. Whenever we are at an odd number column, the next address to visit is located leftwards 1 position. Whenever we are at an even number columns, the next address to visit is located rightwards 1 and uppwards 1, except if we reach the end of the column, where it will be leftwards 1 and modify the direction of the movements to be leftwards 1 at an even numbered columns and rightwards 1 downwards 1 at an odd column. 
			If (NOT_WRITE = 0)
			{
				StringLeft, BIT_TO_WRITE, FINAL_MESSAGE, 1
				StringTrimLeft, FINAL_MESSAGE, FINAL_MESSAGE, 1
				MATRIX_UNMASKED[MATRIX_DIMENSIONS + 1 - CURRENT_ROW, MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN] := BIT_TO_WRITE
			}
			
			If (((Mod(MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN, 4) = 1) OR (Mod(MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN, 4) = 0)) AND (MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN >= 8))
				CURRENT_WRITING_DIRECTION := "UP"
			If (((Mod(MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN, 4) = 3) OR (Mod(MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN, 4) = 2)) AND (MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN >= 8))
				CURRENT_WRITING_DIRECTION := "DOWN"
			If (((Mod(MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN, 4) = 1) OR (Mod(MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN, 4) = 2)) AND (MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN <= 6))
				CURRENT_WRITING_DIRECTION := "DOWN"
			If (((Mod(MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN, 4) = 3) OR (Mod(MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN, 4) = 0)) AND (MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN <= 6))
				CURRENT_WRITING_DIRECTION := "UP"
			 
			 
			If (CURRENT_WRITING_DIRECTION = "UP")
			{
				If (Mod(MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN,2) = 1) AND (MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN >= 8)
				{
					CURRENT_COLUMN++
					Continue
				}
				If (Mod(MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN,2) = 1) AND (MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN <= 6)
				{
					CURRENT_COLUMN--, CURRENT_ROW++
					Continue
				}
				If (Mod(MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN,2) = 0) AND (MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN >= 8)
				{
					CURRENT_COLUMN--, CURRENT_ROW++
					Continue
				}
				If (Mod(MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN,2) = 0) AND (MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN <= 6)
				{
					CURRENT_COLUMN++
					Continue
				}
			}
			
			If (CURRENT_WRITING_DIRECTION = "DOWN")
			{
				If (Mod(MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN,2) = 1) AND (MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN >= 8)
				{
					CURRENT_COLUMN++
					Continue
				}
				If (Mod(MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN,2) = 1) AND (MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN <= 6)
				{
					CURRENT_COLUMN--, CURRENT_ROW--
					Continue
				}
				If (Mod(MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN,2) = 0) AND (MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN >= 8)
				{
					CURRENT_COLUMN --, CURRENT_ROW--
					Continue
				}
				If (Mod(MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN,2) = 0) AND (MATRIX_DIMENSIONS + 1 - CURRENT_COLUMN <= 6)
				{
					CURRENT_COLUMN++
					Continue
				}
			}
		}
	}

	; Once all the CW+ECW bits have been added, we now apply the masks. Each mask goes on one copy of the unmasked matrix.
	
	; First, make a copy of the unmasked version.
	MATRIX_MASK_ONE := Object(), MATRIX_MASK_TWO := Object(), MATRIX_MASK_THREE := Object(), MATRIX_MASK_FOUR := Object(), MATRIX_MASK_FIVE := Object(), MATRIX_MASK_SIX := Object(), MATRIX_MASK_SEVEN	:= Object(), MATRIX_MASK_EIGHT := Object()
	Loop % MATRIX_DIMENSIONS ; One for every row
	{
		CURRENT_ROW := A_Index
		Loop % MATRIX_DIMENSIONS ; One for every column
		{
			MATRIX_MASK_ONE[CURRENT_ROW, A_Index] := MATRIX_UNMASKED[CURRENT_ROW, A_Index]
			MATRIX_MASK_TWO[CURRENT_ROW, A_Index] := MATRIX_UNMASKED[CURRENT_ROW, A_Index]
			MATRIX_MASK_THREE[CURRENT_ROW, A_Index] := MATRIX_UNMASKED[CURRENT_ROW, A_Index]
			MATRIX_MASK_FOUR[CURRENT_ROW, A_Index] := MATRIX_UNMASKED[CURRENT_ROW, A_Index]
			MATRIX_MASK_FIVE[CURRENT_ROW, A_Index] := MATRIX_UNMASKED[CURRENT_ROW, A_Index]
			MATRIX_MASK_SIX[CURRENT_ROW, A_Index] := MATRIX_UNMASKED[CURRENT_ROW, A_Index]
			MATRIX_MASK_SEVEN[CURRENT_ROW, A_Index] := MATRIX_UNMASKED[CURRENT_ROW, A_Index]
			MATRIX_MASK_EIGHT[CURRENT_ROW, A_Index] := MATRIX_UNMASKED[CURRENT_ROW, A_Index]
		}
	}
	
	
	; And now we apply each mask to the copies we created previously.
	; Note: since the specs define start row and column addresses as 0 (rather than at 1), the calculations must subtract 1. The matrix objects start at 1, so they won't be affected.
	Loop % MATRIX_DIMENSIONS ; One for every row
	{
		CURRENT_ROW := A_Index
		Loop % MATRIX_DIMENSIONS ; One for every column
		{
			If (Mod((CURRENT_ROW-1) + (A_Index-1), 2) = 0) ; Mask one: Switch if (row + column) mod 2 == 0	
			{
				MATRIX_MASK_ONE[CURRENT_ROW, A_Index] := !(MATRIX_MASK_ONE[CURRENT_ROW, A_Index])
			}
			If (Mod((CURRENT_ROW-1), 2) = 0) ; Mask two: Switch if (row) mod 2 == 0
			{
				MATRIX_MASK_TWO[CURRENT_ROW, A_Index] := !(MATRIX_MASK_TWO[CURRENT_ROW, A_Index])
			}
			If (Mod((A_Index-1), 3) = 0) ; Mask three: Switch if (column) mod 3 == 0
			{
				MATRIX_MASK_THREE[CURRENT_ROW, A_Index] := !(MATRIX_MASK_THREE[CURRENT_ROW, A_Index])
			}
			If (Mod((CURRENT_ROW-1) + (A_Index-1), 3) = 0) ; Mask Four: Switch if (row + column) mod 3 == 0
			{
				MATRIX_MASK_FOUR[CURRENT_ROW, A_Index] := !(MATRIX_MASK_FOUR[CURRENT_ROW, A_Index])
			}
			If (Mod(Floor((CURRENT_ROW-1) / 2) + Floor((A_Index-1) / 3), 2) = 0)	; Mask Five: Switch if ( floor(row / 2) + floor(column / 3) ) mod 2 == 0
			{
				MATRIX_MASK_FIVE[CURRENT_ROW, A_Index] := !(MATRIX_MASK_FIVE[CURRENT_ROW, A_Index])
			}
			If (Mod((CURRENT_ROW-1) * (A_Index-1), 2) + Mod((CURRENT_ROW-1) * (A_Index-1), 3) = 0) ; Mask Six: Switch if ((row * column) mod 2) + ((row * column) mod 3) == 0
			{
				MATRIX_MASK_SIX[CURRENT_ROW, A_Index] := !(MATRIX_MASK_SIX[CURRENT_ROW, A_Index])
			}
			If (Mod(Mod((CURRENT_ROW-1) * (A_Index-1), 2) + Mod((CURRENT_ROW-1) * (A_Index-1), 3), 2) = 0) ; Mask Seven: Switch if ( ((row * column) mod 2) + ((row * column) mod 3) ) mod 2 == 0
			{
				MATRIX_MASK_SEVEN[CURRENT_ROW, A_Index] := !(MATRIX_MASK_SEVEN[CURRENT_ROW, A_Index])
			}
			If (Mod(Mod((CURRENT_ROW-1) + (A_Index-1), 2) + Mod((CURRENT_ROW-1) * (A_Index-1), 3), 2) = 0) ; Mask Eight: Switch if ( ((row + column) mod 2) + ((row * column) mod 3) ) mod 2 == 0
			{
				MATRIX_MASK_EIGHT[CURRENT_ROW, A_Index] := !(MATRIX_MASK_EIGHT[CURRENT_ROW, A_Index])
			}
		}
	}
	
	
	;Than, we apply the function and reserved (this one all-light) areas to the masked matrixes.
	APPLY_FUNCTIONS_AND_TURN_RESERVED_AREAS_LIGHT(MATRIX_MASK_ONE, CHOOSEN_VERSION) 
	APPLY_FUNCTIONS_AND_TURN_RESERVED_AREAS_LIGHT(MATRIX_MASK_TWO, CHOOSEN_VERSION) 
	APPLY_FUNCTIONS_AND_TURN_RESERVED_AREAS_LIGHT(MATRIX_MASK_THREE, CHOOSEN_VERSION) 
	APPLY_FUNCTIONS_AND_TURN_RESERVED_AREAS_LIGHT(MATRIX_MASK_FOUR, CHOOSEN_VERSION) 
	APPLY_FUNCTIONS_AND_TURN_RESERVED_AREAS_LIGHT(MATRIX_MASK_FIVE, CHOOSEN_VERSION) 
	APPLY_FUNCTIONS_AND_TURN_RESERVED_AREAS_LIGHT(MATRIX_MASK_SIX, CHOOSEN_VERSION) 
	APPLY_FUNCTIONS_AND_TURN_RESERVED_AREAS_LIGHT(MATRIX_MASK_SEVEN, CHOOSEN_VERSION) 
	APPLY_FUNCTIONS_AND_TURN_RESERVED_AREAS_LIGHT(MATRIX_MASK_EIGHT, CHOOSEN_VERSION) 
	
	
	; Now that we have applyed the masks, we have to evaluate each one to choose the best (by readability). To do that, we must calculate the penalty scores for each of the masks, based on 4 specific criteria regarding readability.
	
	;Calculating the penalty scores.
	TOTAL_PENALTY_FOR_MASKED_MATRIX_1 := CALCULATE_PENALTY(MATRIX_MASK_ONE)
	TOTAL_PENALTY_FOR_MASKED_MATRIX_2 := CALCULATE_PENALTY(MATRIX_MASK_TWO)
	TOTAL_PENALTY_FOR_MASKED_MATRIX_3 := CALCULATE_PENALTY(MATRIX_MASK_THREE)
	TOTAL_PENALTY_FOR_MASKED_MATRIX_4 := CALCULATE_PENALTY(MATRIX_MASK_FOUR)
	TOTAL_PENALTY_FOR_MASKED_MATRIX_5 := CALCULATE_PENALTY(MATRIX_MASK_FIVE)
	TOTAL_PENALTY_FOR_MASKED_MATRIX_6 := CALCULATE_PENALTY(MATRIX_MASK_SIX)
	TOTAL_PENALTY_FOR_MASKED_MATRIX_7 := CALCULATE_PENALTY(MATRIX_MASK_SEVEN)
	TOTAL_PENALTY_FOR_MASKED_MATRIX_8 := CALCULATE_PENALTY(MATRIX_MASK_EIGHT)
	
	;Finding the lowest penalty masked matrix
	LIST_OF_PENALTY_VALUES := TOTAL_PENALTY_FOR_MASKED_MATRIX_1 . "|" . TOTAL_PENALTY_FOR_MASKED_MATRIX_2 . "|" . TOTAL_PENALTY_FOR_MASKED_MATRIX_3 . "|" . TOTAL_PENALTY_FOR_MASKED_MATRIX_4 . "|" . TOTAL_PENALTY_FOR_MASKED_MATRIX_5 . "|" . TOTAL_PENALTY_FOR_MASKED_MATRIX_6 . "|" . TOTAL_PENALTY_FOR_MASKED_MATRIX_7 . "|" . TOTAL_PENALTY_FOR_MASKED_MATRIX_8
	Sort, LIST_OF_PENALTY_VALUES, N D|
	StringSplit, PENALTY_VALUES_IN_ORDER, LIST_OF_PENALTY_VALUES, |
	
	% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_1 = PENALTY_VALUES_IN_ORDER1) ? (MATRIX_TO_PRINT := MATRIX_MASK_ONE) : (""))
	% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_2 = PENALTY_VALUES_IN_ORDER1) ? (MATRIX_TO_PRINT := MATRIX_MASK_TWO) : (""))
	% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_3 = PENALTY_VALUES_IN_ORDER1) ? (MATRIX_TO_PRINT := MATRIX_MASK_THREE) : (""))
	% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_4 = PENALTY_VALUES_IN_ORDER1) ? (MATRIX_TO_PRINT := MATRIX_MASK_FOUR) : (""))
	% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_5 = PENALTY_VALUES_IN_ORDER1) ? (MATRIX_TO_PRINT := MATRIX_MASK_FIVE) : (""))
	% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_6 = PENALTY_VALUES_IN_ORDER1) ? (MATRIX_TO_PRINT := MATRIX_MASK_SIX) : (""))
	% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_7 = PENALTY_VALUES_IN_ORDER1) ? (MATRIX_TO_PRINT := MATRIX_MASK_SEVEN) : (""))	
	% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_8 = PENALTY_VALUES_IN_ORDER1) ? (MATRIX_TO_PRINT := MATRIX_MASK_EIGHT) : (""))
	
	If (CHOOSEN_ERROR_CORRECTION_LEVEL = 1)
	{
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_1 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "111011111000100") : (""))
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_2 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "111001011110011") : (""))
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_3 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "111110110101010") : (""))
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_4 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "111100010011101") : (""))
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_5 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "110011000101111") : (""))
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_6 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "110001100011000") : (""))
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_7 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "110110001000001") : (""))
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_8 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "110100101110110") : (""))
	}
	
	If (CHOOSEN_ERROR_CORRECTION_LEVEL = 2)
	{
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_1 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "101010000010010") : (""))
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_2 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "101000100100101") : (""))
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_3 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "101111001111100") : (""))
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_4 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "101101101001011") : (""))
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_5 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "100010111111001") : (""))
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_6 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "100000011001110") : (""))
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_7 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "100111110010111") : (""))
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_8 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "100101010100000") : (""))
	}
	
	If (CHOOSEN_ERROR_CORRECTION_LEVEL = 3)
	{
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_1 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "011010101011111") : (""))
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_2 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "011000001101000") : (""))
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_3 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "011111100110001") : (""))
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_4 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "011101000000110") : (""))
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_5 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "010010010110100") : (""))
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_6 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "010000110000011") : (""))
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_7 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "010111011011010") : (""))
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_8 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "010101111101101") : (""))
	}
	
	If (CHOOSEN_ERROR_CORRECTION_LEVEL = 4)
	{
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_1 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "001011010001001") : (""))
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_2 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "001001110111110") : (""))
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_3 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "001110011100111") : (""))
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_4 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "001100111010000") : (""))
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_5 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "000011101100010") : (""))
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_6 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "000001001010101") : (""))
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_7 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "000110100001100") : (""))
		% ((TOTAL_PENALTY_FOR_MASKED_MATRIX_8 = PENALTY_VALUES_IN_ORDER1) ? (CHOOSEN_MASK_CODE_FOR_V2 := "000100000111011") : (""))
	}
	
	Return MATRIX_TO_PRINT
}
Return

APPLY_FUNCTIONS_AND_TURN_RESERVED_AREAS_LIGHT(MATRIX_TO_APPLY, CHOOSEN_VERSION) ; No need for a global indicator.
{
	Global
	; First, we create the model objects for the function alignment patterns and function finder patterns.
	FUNCTION_FINDER_PATTERN := Object(), FUNCTION_ALIGNMENT_PATTERN := Object()
	FUNCTION_FINDER_PATTERN[1] := [1,1,1,1,1,1,1], FUNCTION_FINDER_PATTERN[2] := [1,0,0,0,0,0,1], FUNCTION_FINDER_PATTERN[3] := [1,0,1,1,1,0,1], FUNCTION_FINDER_PATTERN[4] := [1,0,1,1,1,0,1], FUNCTION_FINDER_PATTERN[5] := [1,0,1,1,1,0,1], FUNCTION_FINDER_PATTERN[6] := [1,0,0,0,0,0,1], FUNCTION_FINDER_PATTERN[7] := [1,1,1,1,1,1,1]
	FUNCTION_ALIGNMENT_PATTERN[1] := [1, 1, 1, 1, 1], FUNCTION_ALIGNMENT_PATTERN[2] := [1, 0, 0, 0, 1], FUNCTION_ALIGNMENT_PATTERN[3] := [1, 0, 1, 0, 1], FUNCTION_ALIGNMENT_PATTERN[4] := [1, 0, 0, 0, 1], FUNCTION_ALIGNMENT_PATTERN[5] := [1, 1, 1, 1, 1]
	
	;Next, we print those starting at their corresponding addresses in the matrixes, for all eight masks (This function is called once for every mask).
	;First, we print the Function Finder Patterns.
	Loop 7
	{
		CURRENT_ROW_OF_FUNCTION_PATTERN := A_Index
		Loop 7
		{
			MATRIX_TO_APPLY[CURRENT_ROW_OF_FUNCTION_PATTERN, A_Index] := FUNCTION_FINDER_PATTERN[CURRENT_ROW_OF_FUNCTION_PATTERN, A_Index] ; Left-Uppermost Function Finder Pattern.
			MATRIX_TO_APPLY[CURRENT_ROW_OF_FUNCTION_PATTERN, MATRIX_DIMENSIONS - 7 + A_Index] := FUNCTION_FINDER_PATTERN[CURRENT_ROW_OF_FUNCTION_PATTERN, A_Index] ; Right-Uppermost Function Finder Pattern.
			MATRIX_TO_APPLY[MATRIX_DIMENSIONS - 7 + CURRENT_ROW_OF_FUNCTION_PATTERN, A_Index] := FUNCTION_FINDER_PATTERN[CURRENT_ROW_OF_FUNCTION_PATTERN, A_Index] ; Left-Bottommost Function Finder Pattern.
		}
	}
	
	; Next, we print the Timing Patterns.
	Loop % MATRIX_DIMENSIONS ; MATRIX_DIMENSIONS is a global variable created on a function that is called before this one. It contains the matrix dimensions, both height and width.
	{
		If (A_Index > 8) AND (A_Index < MATRIX_DIMENSIONS - 7) AND (Mod(A_Index,2) = 1)
		{
			MATRIX_TO_APPLY[7, A_Index] := 1 ; The Horizontal Timing Pattern.
			MATRIX_TO_APPLY[A_Index, 7] := 1 ; The Vertical Timing Pattern.
		}
		If (A_Index > 8) AND (A_Index < MATRIX_DIMENSIONS - 7) AND (Mod(A_Index,2) = 0)
		{
			MATRIX_TO_APPLY[7, A_Index] := 0 ; The Horizontal Timing Pattern.
			MATRIX_TO_APPLY[A_Index, 7] := 0 ; The Vertical Timing Pattern.
		}
	}
	
	Loop % ALIGNMENT_INDIVIDUAL_COORDINATES_0 ; ALIGNMENT_INDIVIDUAL_COORDINATES_0 is a global variable created on a function that is called before this one. It contains the number of function alignment patterns for the choosen version.
	{
		INDIVIDUAL_ALIGNMENT_COORDS_ := ""
		StringSplit, INDIVIDUAL_ALIGNMENT_COORDS_, ALIGNMENT_INDIVIDUAL_COORDINATES_%A_Index%, x
		Loop 5 ; Function Finder Patterns are dimensioned 5 x 5 (width and height).
		{
			FUNCTION_ALIGN_PATTERN_CURRENT_ROW := A_Index
			Loop 5
			{
				MATRIX_TO_APPLY[INDIVIDUAL_ALIGNMENT_COORDS_1 + A_Index - 1, INDIVIDUAL_ALIGNMENT_COORDS_2 + FUNCTION_ALIGN_PATTERN_CURRENT_ROW - 1] := FUNCTION_ALIGNMENT_PATTERN[FUNCTION_ALIGN_PATTERN_CURRENT_ROW, A_Index]
			}
		}
	}
	
	;Now, we turn the reserved areas light.
	Loop 8
	{
		; reserved area for the left-uppermost function finder pattern.
		MATRIX_TO_APPLY[A_index, 8] := 0
		MATRIX_TO_APPLY[8, A_Index] := 0
		
		; reserved area for the right-uppermost function finder pattern.
		MATRIX_TO_APPLY[A_Index, MATRIX_DIMENSIONS - 7] := 0
		MATRIX_TO_APPLY[8, MATRIX_DIMENSIONS + A_Index - 8] := 0
		
		; reserved area for the left-bottommost function finder pattern.
		MATRIX_TO_APPLY[MATRIX_DIMENSIONS + A_Index - 8, 8] := 0
		MATRIX_TO_APPLY[MATRIX_DIMENSIONS - 7, A_Index] := 0
	}
	
	MATRIX_TO_APPLY[MATRIX_DIMENSIONS - 7, 9] := 1
	
}
Return

CALCULATE_PENALTY(MATRIX_TO_USE)
{
	Global
	; Rule 1: Add 3 penalty scores for each row/column with 5 consective modules of same color. Add 1 more for each consecutive that exceeds the 5th.
	
	; First check for horizontal sequences.
	PENALTY_SUM := 0 ; This is unnecessary, since the function is not global. Leaving it here just in case i change that (update: changed!).
	Loop % MATRIX_DIMENSIONS
	{
		Row_Count := A_Index
		PREVIOUS_BIT := 2 ; A value to simply make it impossible for 0 or 1 to match.
		COUNT_CONTINUOUS := 0 ; To guarantee we start off with no count for continuous bits.
		Loop % MATRIX_DIMENSIONS
		{
			CURRENT_BIT := MATRIX_TO_USE[Row_Count, A_Index]
			START_BIT := MATRIX_TO_USE[Row_Count, A_Index]
			If ((PREVIOUS_BIT = 2) OR !(PREVIOUS_BIT = CURRENT_BIT))
			{
				If (COUNT_CONTINUOUS > 3)
				{
					PENALTY_SUM += COUNT_CONTINUOUS - 4 + 3
				}
				COUNT_CONTINUOUS := 0
				PREVIOUS_BIT := CURRENT_BIT
				Continue
			}
			COUNT_CONTINUOUS++
			PREVIOUS_BIT := CURRENT_BIT
		}
		if (COUNT_CONTINUOUS > 3)
		{
			PENALTY_SUM += COUNT_CONTINUOUS - 4 + 3
		}
	}
	
	;Next, check for vertical sequences. It is the same code, except we change the row and column adresses.
	Loop % MATRIX_DIMENSIONS
	{
		Column_Count := A_Index
		PREVIOUS_BIT := 2 ; A value to simply make it impossible for 0 or 1 to match.
		COUNT_CONTINUOUS := 0 ; To guarantee we start off with no count for continuous bits.
		Loop % MATRIX_DIMENSIONS
		{
			CURRENT_BIT := MATRIX_TO_USE[A_Index, Column_Count]
			START_BIT := MATRIX_TO_USE[A_Index, Column_Count]
			If ((PREVIOUS_BIT = 2) OR !(PREVIOUS_BIT = CURRENT_BIT))
			{
				If (COUNT_CONTINUOUS > 3)
				{
					PENALTY_SUM += COUNT_CONTINUOUS - 4 + 3
				}
				COUNT_CONTINUOUS := 0
				PREVIOUS_BIT := CURRENT_BIT
				Continue
			}
			COUNT_CONTINUOUS++
			PREVIOUS_BIT := CURRENT_BIT
		}
		if (COUNT_CONTINUOUS > 3)
		{
			PENALTY_SUM += COUNT_CONTINUOUS - 4 + 3
		}
	}
	
	; Rule 2: Add 3 penalty scores for every overlapping 2x2 block of the same color. (i.e., a 3x3 = 2 overlaping 2x2 blocks.)
	
	Loop % MATRIX_DIMENSIONS ; We access each row
	{
		CURRENT_ROW := A_Index
		Loop % MATRIX_DIMENSIONS ; And than we access each block (or column of row).
		{
			If ((MATRIX_TO_USE[CURRENT_ROW, A_Index] = MATRIX_TO_USE[CURRENT_ROW, A_Index + 1]) AND (MATRIX_TO_USE[CURRENT_ROW, A_Index] = MATRIX_TO_USE[CURRENT_ROW + 1, A_Index]) AND (MATRIX_TO_USE[CURRENT_ROW, A_Index] = MATRIX_TO_USE[CURRENT_ROW + 1, A_Index + 1]))
			{
				PENALTY_SUM += 3
			}
		}
	}
	
	; Rule 3: Add 40 (yes, fourty) penalty scores for each of the following patterns in vertical or horizontal position: 10111010000 and 00001011101.
	; Reasoning here is that these patterns are similar to the finder function patterns and may cause trouble to the reader algorithms.
	
	
	; First, we do an horizontal scan for the patterns.
	Loop % MATRIX_DIMENSIONS ; We access each row
	{
		CURRENT_ROW := A_Index
		Loop % MATRIX_DIMENSIONS - 10 ; And than we access each block (or column of row). Since thes sequences are 11 digits long and the matrix is 25 bits long, there is no need to scan the16th bit onwards in the same row.
		{
			SEQUENCE_TO_CHECK := MATRIX_TO_USE[CURRENT_ROW, A_Index] . MATRIX_TO_USE[CURRENT_ROW, A_Index + 1] . MATRIX_TO_USE[CURRENT_ROW, A_Index + 2] . MATRIX_TO_USE[CURRENT_ROW, A_Index + 3] . MATRIX_TO_USE[CURRENT_ROW, A_Index + 4] . MATRIX_TO_USE[CURRENT_ROW, A_Index + 5] . MATRIX_TO_USE[CURRENT_ROW, A_Index + 6] . MATRIX_TO_USE[CURRENT_ROW, A_Index + 7] . MATRIX_TO_USE[CURRENT_ROW, A_Index + 8] . MATRIX_TO_USE[CURRENT_ROW, A_Index + 9] . MATRIX_TO_USE[CURRENT_ROW, A_Index + 10]
			if ((SEQUENCE_TO_CHECK = "10111010000") OR (SEQUENCE_TO_CHECK = "00001011101"))
			{
				PENALTY_SUM += 40
			}
		}
	}
	
	
	; Next, we do a vertical scan for the patterns.
	Loop % MATRIX_DIMENSIONS - 10 ; We access each row. Since the sequences are 11 digits long and the matrix is 25 bits long, there is no need to scan the 16th bit onwards in the same column.
	{
		CURRENT_ROW := A_Index
		Loop % MATRIX_DIMENSIONS ; And than we access each block (or column of row).
		{
			SEQUENCE_TO_CHECK := MATRIX_TO_USE[CURRENT_ROW, A_Index] . MATRIX_TO_USE[CURRENT_ROW + 1, A_Index] . MATRIX_TO_USE[CURRENT_ROW + 2, A_Index] . MATRIX_TO_USE[CURRENT_ROW + 3, A_Index] . MATRIX_TO_USE[CURRENT_ROW + 4, A_Index] . MATRIX_TO_USE[CURRENT_ROW + 5, A_Index] . MATRIX_TO_USE[CURRENT_ROW + 6, A_Index] . MATRIX_TO_USE[CURRENT_ROW + 7, A_Index] . MATRIX_TO_USE[CURRENT_ROW + 8, A_Index] . MATRIX_TO_USE[CURRENT_ROW + 9, A_Index] . MATRIX_TO_USE[CURRENT_ROW + 10, A_Index]
			if ((SEQUENCE_TO_CHECK = "10111010000") OR (SEQUENCE_TO_CHECK = "00001011101"))
			{
				PENALTY_SUM += 40
			}
		}
	}
	
	; Rule 4: This rule is based on the ratio of light modules to dark modules. Basically, what we are trying to do here is to penalize matrixes with too many light or too many dark modules. The most desirable ratio for a good readability is around half for each.
	
	NUMBER_OF_LIGHT_MODULES := ""
	TOTAL_MODULES := MATRIX_DIMENSIONS * MATRIX_DIMENSIONS ; or 25 x 25.
	Loop % MATRIX_DIMENSIONS ; We access each row.
	{
		CURRENT_ROW := A_Index
		Loop % MATRIX_DIMENSIONS
		{
			if (MATRIX_TO_USE[CURRENT_ROW, A_Index] = 0)
			{
				NUMBER_OF_LIGHT_MODULES++
			}
			if (MATRIX_TO_USE[CURRENT_ROW, A_Index] = 1)
			{
				NUMBER_OF_DARK_MODULES++
			}
		}
	}
	PERCENT_OF_MODULES := NUMBER_OF_DARK_MODULES / TOTAL_MODULES
	
	; Below we calculate the nearest multiples of 5 before and after the calculated percent of modules. Example, if PERCENT_OF_MODULES is 343, we should get 345 and 340.
	NEAREST_MULTIPLE_OF_TEN := round(PERCENT_OF_MODULES, -1)
	If (Mod(PERCENT_OF_MODULES,5) = 0)
	{
		UPPER_MULTIPLE_OF_5 := PERCENT_OF_MODULES
		LOWER_MULTIPLE_OF_5 := PERCENT_OF_MODULES
	}
	Else if (NEAREST_MULTIPLE_OF_TEN > PERCENT_OF_MODULES)
	{
		UPPER_MULTIPLE_OF_5 := NEAREST_MULTIPLE_OF_TEN
		LOWER_MULTIPLE_OF_5 := NEAREST_MULTIPLE_OF_TEN - 5
	}
	Else if (NEAREST_MULTIPLE_OF_TEN < PERCENT_OF_MODULES)
	{
		UPPER_MULTIPLE_OF_5 := NEAREST_MULTIPLE_OF_TEN + 5
		LOWER_MULTIPLE_OF_5 := NEAREST_MULTIPLE_OF_TEN
	}
	
	; Now we subtract 50 from each value, take the absolute result and divide it by 5.
	RESULT_ONE := abs(UPPER_MULTIPLE_OF_5 - 50) / 5
	RESULT_TWO := abs(LOWER_MULTIPLE_OF_5 - 50) / 5
	
	;Finaly we take the lowest value and multiply it by 10. This is the final penalty for rule 4.
	if (RESULT_ONE > RESULT_TWO)
	{
		PENALTY_SUM += RESULT_ONE * 10
	}
	Else if ((RESULT_ONE < RESULT_TWO) OR (RESULT_ONE = RESULT_TWO))
	{
		PENALTY_SUM += RESULT_TWO * 10
	}
	
	Return PENALTY_SUM ; PENALTY_SUM should now contain the overal score of the masked matrix provided.We are returning it now for comparison against the other 7. The lowest overal penalty shall decide the masked matrix to use.
}
Return




CREATE_LOG_AND_ANTILOG_TABLES() ; The complete Log and Antilog tables for Galois Field 256 (bitwise mod 2, bytewise mod 285, as specified in the ISO for QR Codes). The steps of this calculum are explained in http://www.thonky.com/qr-code-tutorial/error-correction-coding/#step-5-generate-powers-of-2-using-bytewise-modulo-100011101.
{
	Global
	LogTable := Object(), AntiLogTable := Object()
	LogTable[0] := 1
	Loop 255
	{
		CURRENT_ENTRY := (((LogTable[A_index - 1]  * 2) > 255) ? ((LogTable[A_index - 1]  * 2) ^ 285) : ((LogTable[A_index - 1]  * 2)))
		LogTable[A_Index] := CURRENT_ENTRY
		AntilogTable[CURRENT_ENTRY] := A_Index
	}	
}
Return

GUICLOSE:
ExitApp
Return

;##############################################################################################################
; CODE 39 (or CODE 3 of 9) Functions v1.0 by Giordanno Sperotto.
; General Notes from the author (refer to the function "GENERATE_CODE_39()" for an explanation on how to create a CODE 39 Matrix):
; 
; Barcodes have been in use since at least the 1960s. They are a machine-readable representation of data that can be attached to
; a specific object in order to allow anyone with a scanner to later recall info for that specific object. An invaluable logistical tool, barcodes
; can greatly increase the production of workers inside an organization by dramatically reducing the time required for information to be 
; relayed between two specific users. Code 39 is a form of one-dimensional (1D) barcode symbology developed by David Allais and widely
; used in the market due to it's simplicity of implementation and ease availability of low cost scanners.
; 
; The current standard for CODE39 Barcodes is ANSI/AIM BC1/1995.
;
; Each character in Code39 Barcode is encoded as 5 (five) dark strips separated by 4 (four) light strips with 1 (one) light strip
; added between characters. These strips vary in width. The first character of a valid Code39 barcode is always * (asterisk) and 
; the last is also * (asterisk), both used to mark the beggining and the end of the barcode and both not being translated as output
; data when the code is read. The characters between these two compose the valid data string. Code39 can thereby be implemented
; as simply a text font translating each character to it's according set of strips and a small programmable routine to add the asterisks 
; in the beggining and the end of the string. This library also uses this simple approach. A modulo 43 checksum is optional on the standard, 
; but will not be readily available for this version. 
; Code39 can encode digits (0-9), UPPERCASE letters (A-Z), symbols -, +, $, %, .,/ and whitespaces, for a total of 43 possible
; characters.
; Do not forget to include reasonable sized "quiet zones" (light-colored areas) before the first and after the last bar of the code in the image.
;##############################################################################################################


;#######################################################################################################
;  GENERATE_CODE_39() v1.0 by Giordanno Sperotto.
; How to generate CODE39 lines using this library:
; This function takes a single parameter: The message you wish to encode. This parameter should be a string of characters, 
; composed of any combination of the following characters: Digits (0-9), UPPERCASE letters (A-Z), symbols -, +, $, %, .,/ and whitespaces.
;
; The function will complain and abort execution if you try to encode a message that contains any characters other than these.
;
; Although there is not limit for how many characters you can encode, do notice that the output image gets bigger quite fast as you try
; to encode a bigger message. Since most scanners have a practical scanning area limit, it is wise to limit the message size to no more
; than a few characters whenever possible.
;
; If you absolutely need to encode many characters, consider using QR Code instead.
;#########################################################################################################


BARCODER_GENERATE_CODE_39(MESSAGE_TO_ENCODE)
{
	Global
	If (MESSAGE_TO_ENCODE = "")
	{
		;msgbox, 0x10, Error, Please insert a message to encode.
		Return 1
	}
	
	CREATE_CODE_39_CHARACTER_TABLE()
	MATRIX_TO_PRINT := ""
	If !(RegExMatch(MESSAGE_TO_ENCODE, "[^A-Z0-9`$`%`+`-`.`/ ]") = 0)
	{
		;msgbox, 0x10, Error, The input string contains characters that cannot be encoded in a CODE39 Barcode. Please correct the message or choose another type of barcode. `n`nAvailable characters for encoding in CODE39 Barcodes: Numbers (0-9), UPPERCASE Letters (A-Z), Some symbols ($, `%, +, -, ., /) and whitespaces.
		Return 1
	}
	
	MATRIX_TO_PRINT := object()
	Loop, parse, MESSAGE_TO_ENCODE
	{
		VALUE_TO_SEARCH := A_LoopField
		% (A_LoopField = "+") ? (VALUE_TO_SEARCH := 43) : ("") ; Was getting an awkawd behavior when trying to straight translate CODE_39_TABLE[A_LoopField] when A_LoopField is "+". AHK v1.1.13.00.
		% (A_LoopField = "/") ? (VALUE_TO_SEARCH := 47) : ("") ; Was getting an awkawd behavior when trying to straight translate CODE_39_TABLE[A_LoopField] when A_LoopField is "/". AHK v1.1.13.00.
		LINE_TO_USE := LINE_TO_USE . CODE_39_TABLE[VALUE_TO_SEARCH] . ",0,"
		VALUE_TO_SEARCH := ""
	}
	StringTrimRight, LINE_TO_USE, LINE_TO_USE, 1
	LINE_TO_USE := "1,0,0,1,0,1,1,0,1,1,0,1," . "0," LINE_TO_USE . ",1,0,0,1,0,1,1,0,1,1,0,1" ; Asterisk + Message + Asterisk
	StringSplit, COLUMN_TO_USE_, LINE_TO_USE, `,
	Loop % COLUMN_TO_USE_0
	{
		MATRIX_TO_PRINT[A_Index] := COLUMN_TO_USE_%A_Index%
		COLUMN_TO_USE_%A_Index% := ""
	}
	
	; Getting rid of the global trash.
	COLUMN_TO_USE_0 := "", LINE_TO_USE := ""
	
	Return MATRIX_TO_PRINT
}
Return

CREATE_CODE_39_CHARACTER_TABLE()
{
	Global
	CODE_39_TABLE := Object()
	CODE_39_TABLE[1] := "1,1,0,1,0,0,1,0,1,0,1,1", CODE_39_TABLE[2] := "1,0,1,1,0,0,1,0,1,0,1,1", CODE_39_TABLE[3] := "1,1,0,1,1,0,0,1,0,1,0,1",  CODE_39_TABLE[4] := "1,0,1,0,0,1,1,0,1,0,1,1", CODE_39_TABLE[5] := "1,1,0,1,0,0,1,1,0,1,0,1", CODE_39_TABLE[6] := "1,0,1,1,0,0,1,1,0,1,0,1", CODE_39_TABLE[7] := "1,0,1,0,0,1,0,1,1,0,1,1", CODE_39_TABLE[8] := "1,1,0,1,0,0,1,0,1,1,0,1", CODE_39_TABLE[9] := "1,0,1,1,0,0,1,0,1,1,0,1", CODE_39_TABLE[0] := "1,0,1,0,0,1,1,0,1,1,0,1", CODE_39_TABLE["A"] := "1,1,0,1,0,1,0,0,1,0,1,1", CODE_39_TABLE["B"] := "1,0,1,1,0,1,0,0,1,0,1,1", CODE_39_TABLE["C"] := "1,1,0,1,1,0,1,0,0,1,0,1", CODE_39_TABLE["D"] := "1,0,1,0,1,1,0,0,1,0,1,1", CODE_39_TABLE["E"] := "1,1,0,1,0,1,1,0,0,1,0,1", CODE_39_TABLE["F"] := "1,0,1,1,0,1,1,0,0,1,0,1", CODE_39_TABLE["G"] := "1,0,1,0,1,0,0,1,1,0,1,1", CODE_39_TABLE["H"] := "1,1,0,1,0,1,0,0,1,1,0,1", CODE_39_TABLE["I"] := "1,0,1,1,0,1,0,0,1,1,0,1", CODE_39_TABLE["J"] := "1,0,1,0,1,1,0,0,1,1,0,1", CODE_39_TABLE["K"] := "1,1,0,1,0,1,0,1,0,0,1,1", CODE_39_TABLE["L"] := "1,0,1,1,0,1,0,1,0,0,1,1", CODE_39_TABLE["M"] := "1,1,0,1,1,0,1,0,1,0,0,1", CODE_39_TABLE["N"] := "1,0,1,0,1,1,0,1,0,0,1,1", CODE_39_TABLE["O"] := "1,1,0,1,0,1,1,0,1,0,0,1", CODE_39_TABLE["P"] := "1,0,1,1,0,1,1,0,1,0,0,1", CODE_39_TABLE["Q"] := "1,0,1,0,1,0,1,1,0,0,1,1", CODE_39_TABLE["R"] := "1,1,0,1,0,1,0,1,1,0,0,1", CODE_39_TABLE["S"] := "1,0,1,1,0,1,0,1,1,0,0,1", CODE_39_TABLE["T"] := "1,0,1,0,1,1,0,1,1,0,0,1", CODE_39_TABLE["U"] := "1,1,0,0,1,0,1,0,1,0,1,1", CODE_39_TABLE["V"] := "1,0,0,1,1,0,1,0,1,0,1,1", CODE_39_TABLE["W"] := "1,1,0,0,1,1,0,1,0,1,0,1", CODE_39_TABLE["X"] := "1,0,0,1,0,1,1,0,1,0,1,1", CODE_39_TABLE["Y"] := "1,1,0,0,1,0,1,1,0,1,0,1", CODE_39_TABLE["Z"] := "1,0,0,1,1,0,1,1,0,1,0,1", CODE_39_TABLE[A_Space] := "1,0,0,1,1,0,1,0,1,1,0,1", CODE_39_TABLE["`-"] := "1,0,0,1,0,1,0,1,1,0,1,1", CODE_39_TABLE["`$"] := "1,0,0,1,0,0,1,0,0,1,0,1", CODE_39_TABLE["`%"] := "1,0,1,0,0,1,0,0,1,0,0,1", CODE_39_TABLE["`."] := "1,1,0,0,1,0,1,0,1,1,0,1", CODE_39_TABLE[47] := "1,0,0,1,0,0,1,0,1,0,0,1", CODE_39_TABLE[43] := "1,0,0,1,0,1,0,0,1,0,0,1"
}
Return


;##############################################################################################################
; INTERLEAVED 2 OF 5 (or CODE_ITF) Functions by AlphaBravo (http://ahkscript.org/boards/viewtopic.php?f=6&t=5538&p=32299#p32299)
; INTERLEAVED 2 OF 5 is a 1D Barcode capable of encoding numeric digits (0-9). Although the availability of encodable characters is smaller, 
; the output image is also smaller than some other types of 1D barcode, such as CODE 39. Consider using this type of barcode whenever the 
; upper limits in the dimensions of the output barcode are a critical factor and also whenever numeric digits are all you need to encode. Also, 
; read the note below before choosing this barcode format.
;
; !! NOTE !! 
;
; 1 - An INTERLEAVED 2 OF 5 image can only encode an even number of digits. Odd numebered strings will thus be
; encoded with a leading 0 padded to the left of the string.The code lines to deal with this issue have to be thus scripted by the user accoding
; to each case. 
; 2 - We've had a few problems with some scanners not reading an output ITF barcode whenever it was 4 chars long or shorter 
; than that. The output code was, however, checked to be 100% legit and was succesfully readen by other scanners. It is thereby recommended
; that you test your scanners whenever possible if you expect that encoding such a low number of chars is a possibility for your application.
; 3 - Like any other barcodes, don't forget to add "quiet zones" (light colored areas with reasonable widths) before the first and after the last bar
; of the code.
; 4 - Adding bearer bars to the top and bottom of the output ITF image has been recommended by some fonts to prevent partial readings on 
; long codes.
;##############################################################################################################


;#######################################################################################################
;  GENERATE_CODE_ITF() by AlphaBravo
; How to generate INTERLEAVED CODE 2 OF 5 lines using this library:
; This function takes two parameters: The message you wish to encode and an indicator for whether a checksum should be added 
; to the output code or not. The first parameter should be a string of numeric characters, composed of any combination of the digits 0-9.
; The second parameter is optional and contain a BOOL value (0 or 1) that determines whether to add a checksum to the code or not.
; Although optional in the standard, the checksum has a purpose: it is to make it harder for the scanner to output a misread.
;
; The function defaults to NOT add the checksum.
;
; Although there is no limit to how many characters you can encode using CODE_ITF, do notice that the output image gets bigger quite fast
; as you try to encode a bigger message (not as fast as CODE39, but much faster than a 2D barcode). Since most scanners have a practical
; scanning area limit, it is wise to limit the message size to no more than a few characters whenever possible.
;
; If you absolutely need to encode many characters, consider using a 2D Barcode, such as QR Code instead.
;#########################################################################################################

BARCODER_GENERATE_CODE_ITF(NUMBER_TO_ENCODE, Add_Check_Sum:=0)
{
    if NUMBER_TO_ENCODE is not digit
        return 1
    if Add_Check_Sum
        NUMBER_TO_ENCODE := Add_Check_Sum(NUMBER_TO_ENCODE)
    
    ; http://en.wikipedia.org/wiki/Interleaved_2_of_5
    Codes := "NNWWN,WNNNW,NWNNW,WWNNN,NNWNW,WNWNN,NWWNN,NNNWW,WNNWN,NWNWN"

    ; assign "Narrow/Wide" codes to numbers 0-9
    CODE_ITF_TABLE := [], MATRIX_TO_PRINT := [], BarWidth := []
    for k, v in StrSplit(Codes, ",")
        CODE_ITF_TABLE[A_Index-1] := v

    ; an odd number of digits is encoded by adding a "0" as first digit
    NUMBER_TO_ENCODE := RegExReplace(NUMBER_TO_ENCODE, "^(?=\d(\d\d)*$)", "0")
    
    ; assign bar/space width to number
    for k, v in StrSplit(NUMBER_TO_ENCODE)
    {
        Pair .= v
        if Mod(A_Index,2)
            continue
        Code1 := StrSplit(CODE_ITF_TABLE[SubStr(Pair,1,1)]) ,   Code2 := StrSplit(CODE_ITF_TABLE[SubStr(Pair, 0) ]) , Pair := ""    
        ; interleave bar/space widths, (W/N to bars) and (w/n to spaces)
        loop, 5                                     
            BarWidth.Insert(Code1[A_Index])     ,   BarWidth.Insert(RegExReplace(Code2[A_Index], "(.)", "$L1"))
    }

    for k, v in StrSplit("1010")        ; add prefix
        MATRIX_TO_PRINT.Insert(v)

    ; assign matrix
    for i, v in BarWidth {
        if (v == "W")
            loop, 3
                MATRIX_TO_PRINT.Insert("1")
        else if (v == "N")
            MATRIX_TO_PRINT.Insert("1")
        else if (v == "w")
            loop, 3
                MATRIX_TO_PRINT.Insert("0")
        else if (v == "n")
            MATRIX_TO_PRINT.Insert("0")
    }

    for k, v in StrSplit("11101")       ; add suffix
        MATRIX_TO_PRINT.Insert(v)
    return MATRIX_TO_PRINT
}

Return

Add_Check_Sum(num){ ; http://en.wikipedia.org/wiki/Universal_Product_Code#Check_digits
    for k, v in StrSplit(num)
        if mod(A_Index, 2)
            odd += v
        else
            even += v
    return num . 10-mod(odd*3+even, 10)
}

Return

;##############################################################################################################
; CODE128B Function by AlphaBravo (https://www.autohotkey.com/boards/viewtopic.php?p=93223#p93223)

; CODE128B Barcodes are capable of encoding numeric digits, letters, spaces and many symbols. Although the availability of encodable is limited, it has 
; many more options of characters than CODE39 and CODE_ITF. The output image is also a bit smaller than some other types of 1D barcode, such as CODE 39. 
; Consider using this type of barcode whenever the upper limits in the dimensions of the output barcode are a critical factor and also if your decoder is able to 
; decode this set with reasonable speed and high accuracy. Also, read the note below before choosing this barcode format.
;
; !! NOTE !! 
;
; 1 - Like any other barcodes, don't forget to add "quiet zones" (light colored areas with reasonable widths) before the first and after the last bar
; of the code.
; 2 - Code128B has twice the ammount of possible bar widths than Code39. Higher printing quality may be required with scanned image reading routines!
; Always test the full routine througly.
;##############################################################################################################

;#######################################################################################################
;  BARCODER_GENERATE_CODE_128B() by AlphaBravo
; How to generate CODE128B lines using this library:
; This function takes a single parameters: The message you wish to encode.
; The first parameter should be a string of the characters available for the Code128B set (letters, numbers and some symbols, see https://en.wikipedia.org/wiki/Code_128 
; for a complete table with the available characters - The table is for the B set !!)
; Although there is no limit to how many characters you can encode using CODE_128B, do notice that the output image gets bigger quite fast
; as you try to encode a bigger message (not as fast as CODE39, but much faster than a 2D barcode). Since most scanners have a practical
; scanning area limit, it is wise to limit the message size to no more than a few characters whenever possible or separate it into multiple barcodes.
;#########################################################################################################


BARCODER_GENERATE_CODE_128B(Str){
	data =
	(ltrim
	0	 	11011001100	212222
	1	!	11001101100	222122
	2	"	11001100110	222221
	3	#	10010011000	121223
	4	$	10010001100	121322
	5	`%	10001001100	131222
	6	&	10011001000	122213
	7	'	10011000100	122312
	8	(	10001100100	132212
	9	)	11001001000	221213
	10	*	11001000100	221312
	11	+	11000100100	231212
	12	,	10110011100	112232
	13	-	10011011100	122132
	14	.	10011001110	122231
	15	/	10111001100	113222
	16	0	10011101100	123122
	17	1	10011100110	123221
	18	2	11001110010	223211
	19	3	11001011100	221132
	20	4	11001001110	221231
	21	5	11011100100	213212
	22	6	11001110100	223112
	23	7	11101101110	312131
	24	8	11101001100	311222
	25	9	11100101100	321122
	26	:	11100100110	321221
	27	;	11101100100	312212
	28	<	11100110100	322112
	29	=	11100110010	322211
	30	>	11011011000	212123
	31	?	11011000110	212321
	32	@	11000110110	232121
	33	A	10100011000	111323
	34	B	10001011000	131123
	35	C	10001000110	131321
	36	D	10110001000	112313
	37	E	10001101000	132113
	38	F	10001100010	132311
	39	G	11010001000	211313
	40	H	11000101000	231113
	41	I	11000100010	231311
	42	J	10110111000	112133
	43	K	10110001110	112331
	44	L	10001101110	132131
	45	M	10111011000	113123
	46	N	10111000110	113321
	47	O	10001110110	133121
	48	P	11101110110	313121
	49	Q	11010001110	211331
	50	R	11000101110	231131
	51	S	11011101000	213113
	52	T	11011100010	213311
	53	U	11011101110	213131
	54	V	11101011000	311123
	55	W	11101000110	311321
	56	X	11100010110	331121
	57	Y	11101101000	312113
	58	Z	11101100010	312311
	59	[	11100011010	332111
	60	\	11101111010	314111
	61	]	11001000010	221411
	62	^	11110001010	431111
	63	_	10100110000	111224
	64	``	10100001100	111422
	65	a	10010110000	121124
	66	b	10010000110	121421
	67	c	10000101100	141122
	68	d	10000100110	141221
	69	e	10110010000	112214
	70	f	10110000100	112412
	71	g	10011010000	122114
	72	h	10011000010	122411
	73	i	10000110100	142112
	74	j	10000110010	142211
	75	k	11000010010	241211
	76	l	11001010000	221114
	77	m	11110111010	413111
	78	n	11000010100	241112
	79	o	10001111010	134111
	80	p	10100111100	111242
	81	q	10010111100	121142
	82	r	10010011110	121241
	83	s	10111100100	114212
	84	t	10011110100	124112
	85	u	10011110010	124211
	86	v	11110100100	411212
	87	w	11110010100	421112
	88	x	11110010010	421211
	89	y	11011011110	212141
	90	z	11011110110	214121
	91	{	11110110110	412121
	92	|	10101111000	111143
	93	}	10100011110	111341
	94	~	10001011110	131141
	95	Del	10111101000	114113
	96	FC3	10111100010	114311
	97	FC2	11110101000	411113
	98	Sh	11110100010	411311
	99	CdC	10111011110	113141
	100	CdB	10111101110	114131
	101	CdA	11101011110	311141
	102	FC1	11110101110	411131
	)	
	StartA 	:= "11010000100"	, CheckSumA	:= 103 , CodeA := "11101011110"
	StartB 	:= "11010010000"	, CheckSumB	:= 104 , CodeB := "10111101110"
	StartC 	:= "11010011100"	, CheckSumC	:= 105 , CodeC := "10111011110"
	Stop 	:= "1100011101011"  , Quiet 	:= "000000000000"
	MATRIX_TO_PRINT := [], Pattern := []
	;-------------------------------------------
	loop, parse, data, `n, `r
		f := StrSplit(A_LoopField, "`t")
		, Pattern[f.1] := f.3
	;-------------------------------------------
	if (Str~="[a-z]")								; lower case
		CheckSum := CheckSumB, Start := StartB
	else											; not lower case
		CheckSum := CheckSumA, Start := StartA
	if (Str~="^(\d\d)+$")							; Even number of digits
		CheckSum := CheckSumC, Start := StartC
	;-------------------------------------------	
	STR_TO_PRINT := Quiet . Start
	loop, parse, str
	{		
		STR_TO_PRINT .= Pattern[value := (Start = StartC) ? SubStr(Str, 2*A_Index -1, 2) : Asc(A_LoopField) - 32]
		CheckSum += value * A_Index
	}
	;-------------------------------------------
	CheckCode := mod(CheckSum, 103)	
	STR_TO_PRINT .= Pattern[CheckCode] . Stop . Quiet
	loop, parse, STR_TO_PRINT
		MATRIX_TO_PRINT.Push(A_LoopField)	
	return MATRIX_TO_PRINT
}

Return

;######################################################################################
;THIRD PARTY FUNCTIONS																														   #
;######################################################################################

;#####################################################################################
; Bin() and Dec() by Infogulch - http://www.autohotkey.com/board/topic/49990-binary-and-decimal-conversion/
; Transforms decimal numbers to and from binary format.
;#####################################################################################


Bin(x){
	while x
		r:=1&x r,x>>=1
	return r
}
Return

Dec(x){
	b:=StrLen(x),r:=0
	loop,parse,x
		r|=A_LoopField<<--b
	return r
}
Return