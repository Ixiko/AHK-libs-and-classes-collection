; ===========================================================================================================================================================================
; Gets network adapter information for the local computer.
; Tested with AutoHotkey v2.0-a133
; ===========================================================================================================================================================================

GetAdaptersInfo()
{
	static ERROR_SUCCESS                  := 0
	static ERROR_BUFFER_OVERFLOW          := 111
	static MAX_ADAPTER_NAME_LENGTH        := 256
	static MAX_ADAPTER_DESCRIPTION_LENGTH := 128
	static MAX_ADAPTER_ADDRESS_LENGTH     := 8
	static IF_TYPE := Map(1, "OTHER", 6, "ETHERNET", 9, "TOKENRING", 23, "PPP", 24, "LOOPBACK", 28, "SLIP", 71, "IEEE80211")

	if (DllCall("iphlpapi\GetAdaptersInfo", "ptr", 0, "uint*", &Size := 0) = ERROR_BUFFER_OVERFLOW)
	{
		Buf := Buffer(Size, 0)
		if (DllCall("iphlpapi\GetAdaptersInfo", "ptr", Buf, "uint*", Size) = ERROR_SUCCESS)
		{
			ADAPTER_INFO := Map()
			Addr := Buf.Ptr
			while (Addr)
			{
				Offset := A_PtrSize, Address := ""

				ADAPTER := Map()
				ADAPTER["ComboIndex"]          := NumGet(Addr + Offset, "uint"),                                    Offset += 4
				ADAPTER["AdapterName"]         := StrGet(Addr + Offset, MAX_ADAPTER_NAME_LENGTH + 4, "cp0"),        Offset += MAX_ADAPTER_NAME_LENGTH + 4
				ADAPTER["Description"]         := StrGet(Addr + Offset, MAX_ADAPTER_DESCRIPTION_LENGTH + 4, "cp0"), Offset += MAX_ADAPTER_DESCRIPTION_LENGTH + 4
				AddressLength                  := NumGet(Addr + Offset, "uint"),                                    Offset += 4
				loop AddressLength
					Address .= Format("{:02x}",   NumGet(Addr + Offset + A_Index - 1, "uchar")) ":"
				ADAPTER["Address"]             := SubStr(Address, 1, -1),                                           Offset += MAX_ADAPTER_ADDRESS_LENGTH
				ADAPTER["Index"]               := NumGet(Addr + Offset, "uint"),                                    Offset += 4
				ADAPTER["Type"]                := IF_TYPE[NumGet(Addr + Offset, "uint")],                           Offset += 4
				ADAPTER["DhcpEnabled"]         := NumGet(Addr + Offset, "uint"),                                    Offset += A_PtrSize
				CurrentIpAddress               := NumGet(Addr + Offset + A_PtrSize, "ptr"),                         Offset += A_PtrSize
				ADAPTER["IpAddressList"]       := StrGet(Addr + Offset + A_PtrSize, "cp0")
				ADAPTER["IpMaskList"]          := StrGet(Addr + Offset + A_PtrSize + 16, "cp0"),                    Offset += A_PtrSize + 32 + A_PtrSize
				ADAPTER["GatewayList"]         := StrGet(Addr + Offset + A_PtrSize, "cp0"),                         Offset += A_PtrSize + 32 + A_PtrSize
				ADAPTER["DhcpServer"]          := StrGet(Addr + Offset + A_PtrSize, "cp0"),                         Offset += A_PtrSize + 32 + A_PtrSize
				ADAPTER["HaveWins"]            := NumGet(Addr + Offset, "int"),                                     Offset += A_PtrSize
				ADAPTER["PrimaryWinsServer"]   := StrGet(Addr + Offset + A_PtrSize, "cp0"),                         Offset += A_PtrSize + 32 + A_PtrSize
				ADAPTER["SecondaryWinsServer"] := StrGet(Addr + Offset + A_PtrSize, "cp0"),                         Offset += A_PtrSize + 32 + A_PtrSize
				ADAPTER["LeaseObtained"]       := ConvertUnixTime(NumGet(Addr + Offset, "int")),                    Offset += A_PtrSize
				ADAPTER["LeaseExpires"]        := ConvertUnixTime(NumGet(Addr + Offset, "int"))
				ADAPTER_INFO[A_Index] := ADAPTER

				Addr := NumGet(Addr, "ptr")
			}
			return ADAPTER_INFO
		}
	}
	return ""
}


ConvertUnixTime(value)
{
	unix := 19700101
	unix := DateAdd(unix, value, "seconds")
	return FormatTime(unix, "yyyy-MM-dd HH:mm:ss")
}

; ===========================================================================================================================================================================

Adapters := GetAdaptersInfo()
for i, v in Adapters {
	output := ""
	for k, v in Adapters[i]
		output .= k ": " v "`n"
	MsgBox(output)
}
