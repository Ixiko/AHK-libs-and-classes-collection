#include ..\buf.ahk
strCount(byref hay, byref ned, overlap:=0){
	return buf_short_count(&hay, &ned, strlen(hay), strlen(ned), overlap)
}