RestoreCursors(){
	SPI_SETCURSORS := 0x57
	DllCall( "SystemParametersInfo", "UInt",SPI_SETCURSORS, "UInt",0, "UInt",0, "UInt",0 )
}