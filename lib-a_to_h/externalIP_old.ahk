externalIP_old(){
    ipInfo:={}
    tag:=["<!-- do not script -->",":</th><td style=""font-size:14px;"">"]
    ipInfoList:=["city","region","country","isp"]
    ipPage:=urlDownloadToVar("http://whatismyipaddress.com/")
    regExMatch(ipPage,">\K[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+",ipStart)
    ipInfo.insert("ip",ipStart)
    for i,a in ipInfoList
        ipInfo.insert(a,subStr(ipPage,tp:=inStr(ipPage,a tag[2])+strlen(a tag[2]),inStr(ipPage,"<",,tp)-tp))
    return ipInfo
}