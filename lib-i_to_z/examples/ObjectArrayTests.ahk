#Include ObjectArrayV2_4a.ahk

; uncomment one of this line to run test
;O_DeleteExtractTest()
;O_SetValSetNestedArrayTest()
;O_InizialisedArrayTest()
;O_CloneArrayTest()
;O_ReplaceNameArrayTest()
;O_directAccessTest()

O_DeleteExtractTest(){
	array := O_newArray("test1")
	A_set(array,"hi1",0,"AAA")
	A_set(array,"hi2",0,"BBB")
	A_set(array,"hi3",0,"CCC")
	A_set(array,"hi4",0,"DDD")
	A_set(array,"hi5",0,"EEE")
	A_set(array,"hi6",0,"FFF")
	O_printArray(array)
	array := A_delete(array,0,"EEE")
	O_printArray(array)
	array := A_delete(array,0,"BBB",true)
	O_printArray(array)
	array := A_Extract(array,0,"BBB")
	O_printArray(array)	
}

O_InizialisedArrayTest(){	
	array := O_newInizializedArray("test1",";",":","AAA:111;BBB:222;CCC:333;DDD:444;EEE:555;FFF:666")
	array2 := O_newInizializedArray("test2",";",":","GGG:1000;HHH:2000;KKK:3000;III:4000;JJJ:5000;LLL:6000")			
	array3 := O_newInizializedArray("test3",";",":","MMM:001;NNN:002;OOO:003;PPP:004;QQQ:005;RRR:006")	
	array2 := A_set(array2,array3,0,"array3")	
	array := A_set(array,array2,0,"array2")	; now array2 lose pointer	
	O_printAllArrayStructured()
}

O_ReplaceNameArrayTest(){	
	array := O_newInizializedArray("test1",";",":","AAA:111;BBB:222;CCC:333;DDD:444;EEE:555;FFF:666")
	array2 := O_newInizializedArray("test2",";",":","GGG:1000;HHH:2000;KKK:3000;III:4000;JJJ:5000;LLL:6000")			
	array3 := O_newInizializedArray("test3",";",":","MMM:001;NNN:002;OOO:003;PPP:004;QQQ:005;RRR:006")	
	array2 := A_set(array2,array3,0,"array3")	
	array := A_set(array,array2,0,"array2")	; now array2 lose pointer	
	O_printArray(O_getArray("test1"))
	array4 := O_replaceName(array,"test5")
	O_printAllArrayStructured()
}

O_CloneArrayTest(){	
	array := O_newInizializedArray("test1",";",":","AAA:111;BBB:222;CCC:333;DDD:444;EEE:555;FFF:666")
	array2 := O_newInizializedArray("test2",";",":","GGG:1000;HHH:2000;KKK:3000;III:4000;JJJ:5000;LLL:6000")			
	array3 := O_newInizializedArray("test3",";",":","MMM:001;NNN:002;OOO:003;PPP:004;QQQ:005;RRR:006")	
	array2 := A_set(array2,array3,0,"array3")	
	array := A_set(array,array2,0,"array2")	; now array2 lose pointer	
	O_printArray(O_getArray("test1"))
	array4 := O_clone(array,"test4")
	OutputDEbug -----------------------------------------
	O_printAllArrayStructured()
}


O_SetValSetNestedArrayTest(){
	array := O_newArray("test1")
	A_set(array,"hi1",0,"AAA")
	A_set(array,"hi2",0,"BBB")
	A_set(array,"hi3",0,"CCC")
	A_set(array,"hi4",0,"DDD")
	A_set(array,"hi5",0,"EEE")
	A_set(array,"hi6",0,"FFF")		
	array := O_getArray("test1")
	array2 := O_newArray("test2")
	A_set(array2,"hi7",0,"1AAA")
	A_set(array2,"hi8",0,"1BBB")
	A_set(array2,"hi9",0,"1CCC")
	A_set(array2,"hi10",0,"1DDD")
	A_set(array2,"hi51",0,"1EEE")
	A_set(array2,"hi61",0,"1FFF")			
	array3 := O_newArray("test3")	
	A_set(array3,"3hi7",0,"1AAA3")
	A_set(array3,"3hi8",0,"1BBB3")
	A_set(array3,"3hi9",0,"1CCC3")
	A_set(array3,"3hi10",0,"1DDD3")
	A_set(array3,"3hi51",0,"1EEE3")
	A_set(array3,"3hi61",0,"1FFF3")		
	array2 := A_set(array2,array3,0,"array3")	
	array := A_set(array,array2,0,"array2")	; now array2 lose pointer	
	O_printArray(O_getArray("test1"))
	O_printAllArrayStructured()
}
	
O_boolean(val){
	if val
		return "true"
	else return "false"
}
	
O_directAccessTest(){
	array := O_newInizializedArray("test1",";",":","AAA:111;BBB:222;CCC:333;DDD:444;EEE:555;FFF:666")
	array2 := O_newInizializedArray("test2",";",":","GGG:1000;HHH:2000;KKK:3000;III:4000;JJJ:5000;LLL:6000")			
	array3 := O_newInizializedArray("test3",";",":","MMM:001;NNN:002;OOO:003;PPP:004;QQQ:005;RRR:006")	
	array2 := A_set(array2,array3,0,"array3")	
	array := A_set(array,array2,0,"array2")	; now array2 lose pointer	
	O_printArray(O_getArray("test1"))
	existArray2Name := O_boolean(O_existDirectArray("test1;array2",";"))
    outputDebug exist array2: %existArray2Name%
	existArray2Pointer := O_boolean(O_existDirectArray("test1;test2",";",true))
	outputDebug exist array2(pointer): %existArray2Pointer%
	existKKKINArray2Name := O_boolean(O_existDirectArrayVal("test1;array2","KKK",";"))
	outputDebug exist KKK in array2: %existKKKINArray2Name%
	existKKKInArray2Pointer := O_boolean(O_existDirectArrayVal("test1;test2","KKK",";",true))
	outputDebug exist KKK in array2(pointer): %existKKKInArray2Pointer%	
	KKKINArray2Name := O_getDirectArrayVal("test1;array2","KKK",false,";")
	outputDebug KKK in array2: %KKKINArray2Name%
	KKKInArray2Pointer := O_getDirectArrayVal("test1;test2","KKK",false,";",true)
	outputDebug KKK in array2(pointer): %KKKInArray2Pointer%		
	O_setDirectArrayVal("test1;array2","KKK","modifiedKKKbyName",false,";")
	O_setDirectArrayVal("test1;test2","III","modifiedIIIByPointer",false,";",true)
	O_addDirectArrayVal("test1;array2","SSS","sssByName",";")
	O_addDirectArrayVal("test1;test2","TTT","tttByPointer",";",true)
	O_printArray(O_getArray("test1"))
	return
}
	