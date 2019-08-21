LoWord(byref dword){
	return, dword & 0xFFFF
}
HiWord(ByRef dword){
	return, dword >> 16
}
UIntToShort(ByRef num){
	numPut(num,num,"UInt")
	return  numGet(num, "Short")
}

GET_X_LPARAM(lp){
	return, UIntToShort(LoWord(lp))
}
GET_Y_LPARAM(lp){
	return, UIntToShort(HiWord(lp))
}