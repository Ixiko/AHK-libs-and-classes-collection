/* returned object keys
    ip
    city
    country
    countryCode
    region
    regionCode
    isp
    lat
    long
    asn
    tz (timezone)
    zip (postal code)
    utcOffset
    countryCallCode
    currency
    languages (CSV)
*/

externalIP(ip:=""){
    ipInfoList:={ip:"ip",city:"city",country:"country_name",countryCode:"country",region:"region",regionCode:"region_code",isp:"org",lat:"latitude",long:"longitude",asn:"asn",tz:"timezone",zip:"postal",utcOffset:"utc_offset",countryCallCode:"country_calling_code",currency:"currency",languages:"languages"}
    ipPage:=urlDownloadToVar("https://ipapi.co/" . (ip?ip . "/":"") . "json")
    
    for i,a in ipInfoList{
        regExMatch(ipPage,"Um)""" . a . """: ""?\K[^"",]+(?=""|,)",t)
        ipInfoList[i]:=t
    }
    
    return ipInfoList
}
