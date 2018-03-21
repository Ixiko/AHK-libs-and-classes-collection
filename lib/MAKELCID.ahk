MAKELCID(lgid, srtid){
	return ToShort(srtid) << 16 | ToShort(lgid)
}
