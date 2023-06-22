StrBuf(string, encoding := "UTF-8") {
	return (buf := Buffer(StrPut(string, encoding)), StrPut(string, buf, encoding), buf)
}