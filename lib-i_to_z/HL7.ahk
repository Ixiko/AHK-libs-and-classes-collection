; Link:   	https://raw.githubusercontent.com/pedcards/TRRIQ/master/hl7.ahk
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

initHL7() {
	global hl7, preventiceDDE
	hl7 := Object()
	IniRead, s0, hl7.ini																	; s0 = Section headers
	loop, parse, s0, `n, `r																	; parse s0
	{
		i := A_LoopField
		hl7[i] := []																		; create array for each header
		IniRead, s1, hl7.ini, % i															; s1 = individual header
		loop, parse, s1, `n, `r																; parse s1
		{
			j := A_LoopField
			arr := strSplit(j,"=",,2)														; split into arr.1 and arr.2
			hl7[i][arr.1] := arr.2															; set hl7.OBX.2 = "Obs Type"
		}
	}
	
	
	hl7["flds"] := readIni("preventiceDDE")													; map hl7 fields to lw fields
	
	return
}

processHL7(fnam) {
	global fldval
	FileRead, txt, % fnam
	StringReplace, txt, txt, `r`n, `r														; convert `r`n to `r
	StringReplace, txt, txt, `n, `r															; convert `n to `r
	loop, parse, txt, `r, `n																; parse HL7 message, split on `r, ignore `n
	{
		seg := A_LoopField																	; read next Segment line
		if (seg=="") {
			continue
		}
		hl7line(seg)
	}
	return
}

hl7line(seg) {
/*	Interpret an hl7 message "segment" (line)
	segments are comprised of fields separated by "|" char
	field elements can contain subelements separated by "^" char
	field elements stored in res[i] object
	attempt to map each field to recognized structure for that field element
*/
	global hl7, fldVal, path, obxVal
	res := Object()
	fld := StrSplit(seg,"|")															; split on `|` field separator into fld array
	segName := fld.1																	; first array element should be NAME
	if !IsObject(hl7[segName]) {														; no matching hl7 map?
		MsgBox,,% A_Index, % seg "-" segName "`nBAD SEGMENT NAME"
		return error																	; fail if segment name not allowed
	}
	
	isOBX := (segName == "OBX")
	segMap := hl7[segName]
	segPre := (isOBX) ? "" : segName "_"
	
	Loop, % fld.length()																; step through each of the fld[] strings
	{
		i := A_Index
		if (i<=2) {																		; skip first 2 elements in OBX|2|TX
			continue
		}
		str := fld[i]																	; each segment field
		strMap := segMap[i-1]															; get hl7 substring that maps to this 
		val := StrSplit(str,"^")														; array of subelements
		
		if (strMap=="") {																; no mapped fields
			loop, % val.length()														; create strMap "^^^" based on subelements in val
			{
				strMap .= "z" i "_" A_Index "^"
			}
		}
		map := StrSplit(strMap,"^")														; array of substring map
		loop, % map.length()
		{
			j := A_Index
			if (map[j]=="") {															; skip if map value is null
				continue
			}
			x := segPre . map[j]														; res.pre_map
			
			res[x] := val[j]															; add each mapped result as subelement, res.mapped_name
			
			if !(isOBX)  {																; non-OBX results
				fldVal[x] := val[j]														; populate all fldVal.mapped_name
				obxVal[x] := val[j]
			}
		}
	}
	if (isOBX) {																		; need to special process OBX[], test result strings
		if (res.ObsType == "ED") {
			fldVal.Filename := res.Filename											; file follows
			nBytes := Base64Dec( res.resValue, Bin )
			File := FileOpen( path.PrevHL7in . res.Filename, "w")
			File.RawWrite(Bin, nBytes)
			File.Close()
			;~ seg := "OBX|" fld.2 "|ED|PDFReport"
		} else {
			label := res.resCode													; result value
			result := strQ(res.resValue, "###")
			maplab := strQ(hl7.flds[label],"###",label)								; maps label if hl7->lw map exists
					. strQ(res.Filename,"_###")        								; add suffix if multiple units in OBX_Filename
			fldVal[segPre maplab] := result
			obxval[segPre maplab] := result
		}
	}
	fldval.hl7 .= seg "`n"
	
	return res
}

Base64Dec( ByRef B64, ByRef Bin ) {  ; By SKAN / 18-Aug-2017
; from https://autohotkey.com/boards/viewtopic.php?t=35964
Local Rqd := 0, BLen := StrLen(B64)                 ; CRYPT_STRING_BASE64 := 0x1
  DllCall( "Crypt32.dll\CryptStringToBinary", "Str",B64, "UInt",BLen, "UInt",0x1
         , "UInt",0, "UIntP",Rqd, "Int",0, "Int",0 )
  VarSetCapacity( Bin, 128 ), VarSetCapacity( Bin, 0 ),  VarSetCapacity( Bin, Rqd, 0 )
  DllCall( "Crypt32.dll\CryptStringToBinary", "Str",B64, "UInt",BLen, "UInt",0x1
         , "Ptr",&Bin, "UIntP",Rqd, "Int",0, "Int",0 )
Return Rqd
}

buildHL7(seg,params*) {
/*	creates hl7out.msg = "seg|idx|param1|param2|param3|param4|..."
	keeps seg counts in hl7out[seg] = idx
*/
	global hl7out
	
	txt := seg
	
	if (seg!="MSH") {
		seqnum := hl7out[seg]															; get last sequence number for this segment
		seqnum ++
		hl7out[seg] := seqnum
		txt .= "|" seqnum
	}
	
	for index,param in params															; append params
	{
		txt .= "|" param
	}
	
	hl7out.msg .= txt "`n"																; append result to hl7out.msg
	
	return
}