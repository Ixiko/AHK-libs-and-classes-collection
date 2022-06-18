;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

GetFingerprint(ByRef textfp:=0, ByRef strComputer:=".") {
    local
    static SkipValues := ""
    If (SkipValues == "")
	SkipValues := GetFingerprint_GetForgedValues()
    ;https://autohotkey.com/board/topic/60968-wmi-tasks-com-with-ahk-l/
    objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . strComputer . "\root\cimv2")
    
    fpo := Object()
    
    For dispnameMC,WMIQparm in GetWMIQueryParametersforFingerprint() {
	query := WMIQparm[1]
	valArray := WMIQparm[2]
	fpo[dispnameMC] := Object()
	txtDataMС=

	For o in objWMIService.ExecQuery("Select " . valArray . " from " . query) {
	    objDataMO := Object()
	    txtDataMO=
	    
	    Loop Parse, valArray,`,
	    {
		v := Trim(o[A_LoopField])
		;"System IdentifyingNumber":"System Serial Number"
		If (v && !SkipValues.HasKey(v)) { ; Поля с этими значениями пропускаются (остальные поля остаются)
		    ; виртуальные NIC не нужны в отпечатке, пропускаются целиком
		    If (dispnameMC == "NIC" && GetFingerprint_CheckVirtualNIC(A_LoopField, v)) {
			objDataMO=
			txtDataMO=
			break 
		    }
		    objDataMO[A_LoopField] := v
		    
		    If (textfp!=0)
			txtDataMO .= GetFingerprint_WMIMgmtObjPropToText(A_LoopField, v, txtDataMO)
		}
	    }
	    If (txtDataMO)
		txtDataMС .= dispnameMC . ":" txtDataMO "`n"
	    If (objDataMO)
		fpo[dispnameMC][A_Index] := objDataMO
	}
	If (textfp!=0 && txtDataMС)
	    textfp .= txtDataMС
    }
    
    return fpo
}

GetFingerprint_GetForgedValues() {
    static SkipValues := { "To be filled by O.E.M.": ""
			 , "Base Board Serial Number": ""
			 , "Base Board": ""
			 , "BSN12345678901234567": ""
			 , "System Product Name": ""
			 , "System manufacturer": ""
			 , "System Version": ""
			 , "System Serial Number": ""
			 , "x.x": ""
			 , "Основная плата": ""
			 , "00000000": "" ; RAM: 8502, PartNumber: 1600LL Series, SerialNumber: 00000000
			 , "1": "" ; System: FOXCONN A6GMV 0A, IdentifyingNumber: 1
			 , "CPUSocket": "" ; trello.com/c/iqzGJkcI/307, https://trello.com/c/qXdzEAEQ/249
			 , "Manufacturer0": "" ; RAM: Manufacturer0, PartNumber: PartNum0, SerialNumber: SerNum0
			 , "Manufacturer1": ""
			 , "Manufacturer2": "" ; RAM: Manufacturer2, PartNumber: PartNum2, SerialNumber: SerNum2
			 , "Manufacturer3": ""
			 , "Manufacturer00": "" ; RAM: Manufacturer00, PartNumber: HMT125U6TFR8C-H9, SerialNumber: A516521C
			 , "Manufacturer01": "" ; RAM: Manufacturer01, PartNumber: ModulePartNumber01, SerialNumber: SerNum01 https://trello.com/c/8wHwo4SQ/67
			 , "Manufacturer02": ""
			 , "Manufacturer03": ""
			 , "ModulePartNumber00": "" ; https://trello.com/c/HFcgc6Er/236
			 , "ModulePartNumber01": "" ; RAM: Manufacturer01, PartNumber: ModulePartNumber01, SerialNumber: SerNum01 https://trello.com/c/8wHwo4SQ/67
			 , "ModulePartNumber02": ""
			 , "ModulePartNumber03": ""
			 , "SerNum00": "" ; https://trello.com/c/HFcgc6Er/236
			 , "SerNum01": "" ; RAM: Manufacturer01, PartNumber: ModulePartNumber01, SerialNumber: SerNum01 https://trello.com/c/8wHwo4SQ/67
			 , "SerNum02": ""
			 , "SerNum03": ""
			 , "PartNum0": ""
			 , "PartNum1": ""
			 , "PartNum2": ""
			 , "PartNum3": ""
			 , "SerNum0": ""
			 , "SerNum1": ""
			 , "SerNum2": ""
			 , "SerNum3": ""
			 , "Default string": ""
			 , "N/A": ""
			 , "Unknow": ""
			 , "Unknow Unknow Unknow": "" ; https://trello.com/c/uTCFOTJW/77
			 , "Undefined": ""
			 , "None": "" }
    return SkipValues
}

GetFingerprint_CheckVirtualNIC(fieldName, v) {
    static SkipDescriptions := { "RAS Async Adapter": "" ; Виртуальный NIC VPN с одним и тем же MAC на разных системах
			       , "WAN Miniport (IP)": ""
			       , "WAN Miniport (IPv6)": ""
			       , "WAN Miniport (Network Monitor)": ""
			       , "Минипорт WAN (PPTP)": ""
			       , "Microsoft Wi-Fi Direct Virtual Adapter": "" }
	 , SkipMACs := { "20:41:53:59:4E:FF": "" ; Виртуальный NIC VPN с одним и тем же MAC на разных системах
		       , "50:50:54:50:30:30": "" ; Минипорт WAN (PPTP)
		       , "33:50:6F:45:30:30": ""} ; https://www.lansweeper.com/forum/yaf_postst6456_Report-Duplicate-MAC-Addresses-lists-same-computer-multiple-times.aspx
			   
    return ( fieldName=="Description" && SkipDescriptions.HasKey(v)
	  || fieldName=="MACAddress" && (   SkipMACs.HasKey(v)
					 || (firstOctet := "0x" SubStr(v, 1, 2)) & 0x2)) ; если второй бит первого октета = 1, это локально-администрируемый MAC адрес, его не может быть у физического адаптера
}

GetFingerprint_Object_To_Text(fpo) {
    t=
    
    paramNames := Object(), paramOrder := Object()
    For dispnameMC,WMIQparm in GetWMIQueryParametersforFingerprint() {
	paramNames[dispnameMC] := Object(), paramOrder[dispnameMC] := Object()
	Loop Parse, % WMIQparm[2],`,
	    paramNames[dispnameMC][A_Index] := A_LoopField, paramOrder[dispnameMC][A_LoopField] := A_Index
    }
    
    ;MsgBox % ObjectToText({paramNames: paramNames, paramOrder: paramOrder})
    
    For dispnameMC, objDataMO in fpo {
	For j, kv in objDataMO {
	    line=
	    If (dispnameMC=="NIC") {
		skipNIC := 0
		For k, v in kv {
		    If (GetFingerprint_CheckVirtualNIC(k, v)) {
			skipNIC := 1
			break
		    }
		}
		If (skipNIC)
		    continue
	    }
	    Loop % paramNames[dispnameMC].Length() ; known
	    {
		k := paramNames[dispnameMC][A_Index]
		v := kv[k]
		If (kv.HasKey(k))
		    line .= GetFingerprint_WMIMgmtObjPropToText(k, v, line)
	    }
	    For k, v in kv
		If (!paramOrder[dispnameMC].HasKey(k)) ; unknown
		    line .= GetFingerprint_WMIMgmtObjPropToText(k, v, line)
	    
	    If (line)
		t .= dispnameMC ":" line "`n"
	}
    }
    return t
}

GetFingerprint_Text_To_Object(t) {
    Throw "Not implemented"
}

GetFingerprint_WMIMgmtObjPropToText(ByRef propName, ByRef propVal, ByRef currLine:="") {
    static SkipValues := ""
    If (SkipValues == "")
	SkipValues := GetFingerprint_GetForgedValues()
    If (propVal=="" || SkipValues.HasKey(propVal))
	return ""
    If propName in Name,Vendor,Version,Manufacturer,Product,Model,Caption,Description
	return " " . propVal
    Else
	return ( currLine ? ", " : " " ) . propName . ": " . propVal
}

GetWMIQueryParametersforFingerprint(ByRef UniqueIDsOnly:=0) {
    ; {group name for management class (prefix for each object) : [query, properties]}
    static qParams :=  { "System" :  [ "Win32_ComputerSystemProduct" ,	"Vendor,Name,Version,IdentifyingNumber,UUID" ]
		       , "MB" :      [ "Win32_BaseBoard" , 	    	"Manufacturer,Product,Name,Model,Version,OtherIdentifyingInfo,PartNumber,SerialNumber" ]
		       , "CPU" :     [ "Win32_Processor" , 	    	"Manufacturer,Name,Caption,ProcessorId,SocketDesignation" ]
		       , "RAM" :     [ "Win32_PhysicalMemory",		"Manufacturer,PartNumber,SerialNumber" ]
		       , "NIC" :     [ "Win32_NetworkAdapter where MACAddress is not null" , "Description,MACAddress" ]
		       , "Storage" : [ "Win32_DiskDrive where InterfaceType<>'USB'" , "Model,InterfaceType,SerialNumber" ] }
    return qParams
}

GetFingerprintTransactWriteout(ByRef text, ByRef fname := "*", encoding := "UTF-8", append := 0) {
    If (SubStr(fname, 1, 1)=="*") {
	append := 1
	If (SubStr(text, 0) != "`n")
	    suffix := "`n"
    }
    If (append) {
	FileAppend %text%%suffix%, %fname%, %encoding%
    } Else {
	tmpfname := fname "#.tmp"
	If (IsObject(of := FileOpen(tmpfname, 1, encoding))) {
	    of.Write(text)
	    of.Close()
	    FileMove %tmpfname%, %fname%, 1
	}
    }
}
