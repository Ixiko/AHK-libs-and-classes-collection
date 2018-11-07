; Description: Create form-data for http request (Only works in ANSI!)
; AHK Version: 1.1.14.03 A32
Class Multipart
{
	Make(ByRef PostData, ByRef PostHeader, Array_FormData*) {
		static CRLF := "`r`n"
		static DW   := "UInt"
		static ptr  := (A_PtrSize = "") ? DW : "Ptr"

		PostData := ""
		Boundary := this.RandomBoundary()

		For Index, FormData in Array_FormData
		{
			If (  pos := InStr(FormData, "=")  )
				FormData_Name    := SubStr(FormData, 1, pos-1)
			  , FormData_Content := SubStr(FormData, pos+1)
			Else
				FormData_Name    := FormData

			If (  SubStr(FormData_Content, 1, 1) = "@"  )  {
				FilePath := SubStr(FormData_Content, 2)

				FileRead, binData, %FilePath%
				FileGetSize, binSize, %FilePath%
				SplitPath, FilePath, FileName

				VarSetCapacity( placeholder, binSize, 32 )
				PostData .= "------------------------------" Boundary CRLF
				            . "Content-Disposition: form-data; name=""" FormData_Name """; filename=""" FileName """" CRLF
                            . "Content-Type: " this.MimeType(binData) CRLF CRLF
                offset   := StrLen( PostData )
                PostData .= placeholder CRLF
			}
			Else
			{
				If (  SubStr(FormData_Content, 1, 1) = "<"  )
					FileRead, FormData_Content, % SubStr(FormData_Content, 2)

				PostData .= "------------------------------" Boundary CRLF
				            . "Content-Disposition: form-data; name=""" FormData_Name """" CRLF CRLF
				            . FormData_Content CRLF
			}
		}

		PostData .= "------------------------------" Boundary "--" CRLF
		If offset
			DllCall( "RtlMoveMemory", Ptr, &PostData + offset, Ptr, &binData, DW, binSize )

		PostHeader := "Content-Type: multipart/form-data; boundary=----------------------------" Boundary

		Return Boundary
	}

	MimeType(ByRef binData) {
		static HeaderList := ["424D"     , "4749463"  , "FFD8FFE"   , "89504E4"  , "4657530"                      , "49492A0"   ]
		static TypeList   := ["image/bmp", "image/gif", "image/jpeg", "image/png", "application/x-shockwave-flash", "image/tiff"]

		this.toHex(binData, hex, 4)

		For Index, Header in HeaderList
			If RegExMatch(hex, "^" Header)
				Return TypeList[ Index ]

		Return "application/octet-stream"
	}

	toHex( ByRef V, ByRef H, dataSz=0 )  { ; http://goo.gl/b2Az0W (by SKAN)
		P := ( &V-1 ), VarSetCapacity( H,(dataSz*2) ), Hex := "123456789ABCDEF0"
		Loop, % dataSz ? dataSz : VarSetCapacity( V )
			H  .=  SubStr(Hex, (*++P >> 4), 1) . SubStr(Hex, (*P & 15), 1)
	}

	RandomBoundary() {
		static CharList := "0|1|2|3|4|5|6|7|8|9|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z"
		Sort, CharList, D| Random
		StringReplace, Boundary, CharList, |,, All
		Return SubStr(Boundary, 1, 12)
	}
}