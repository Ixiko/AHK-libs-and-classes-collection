; Link:   	https://github.com/lingchuanbo/WorkFlow/blob/31859006d8a50ae67bbcf634060c00d16efc52b3/User/CustomFunction_auto-byte-format.ahk
; Author:
; Date:
; for:     	AHK_L

/*


*/

; converts Size (in bytes) to byte(s)/KB/MB/GB/TB (uses best option)
; decimalPlaces is the number of decimal places to round
autoByteFormat(size, decimalPlaces = 2)
{
	static size1 = "KB", size2 = "MB", size3 = "GB", size4 = "TB"
	sizeIndex := 0

	while (size >= 1024)
	{
		sizeIndex++
		size /= 1024.0

		if (sizeIndex = 4)
			break
	}

	return (sizeIndex = 0) ? size " byte" . (size != 1 ? "s" : "") : round(size, decimalPlaces) . size%sizeIndex%
}