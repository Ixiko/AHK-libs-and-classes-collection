getIPInfo(getLoc:=True){

    if getLoc {
        webpage:=Download("https://www.whatismybrowser.com/detect/ip-address-location")
        ; http://www.netikus.net/show_ip.html gives faster result, but no location

        start:=Instr(webpage, "<div class=""value"">")  ;Location
        loc:=substr(webpage,start+19,Instr(webpage, "<",false,start+1)-start-19)

        start:=Instr(webpage, "<p>Your IP Address appears to be: <strong>",start) ;IP
        public_ip:=substr(webpage,start+42,Instr(webpage, "</",false,start+42)-start-42)
    } else
        regexMatch(Download("http://www.netikus.net/show_ip.html"),"^\d{1,3}(\.\d{1,3}){3}$",public_ip)

    adapter_count:=0, ipl:=""
    loop, 4 {
        if (A_IPAddress%A_Index% != "0.0.0.0" and A_IPAddress%A_Index% != "127.0.0.1"){
            ipl.=A_IPAddress%A_Index% " | "
            adapter_count++
        }
    }

    ; tooltip, location:%loc% count:%adapter_count% ip:%public_ip% ip1:%A_IPAddress1% ip2:%A_IPAddress2% ip3:%A_IPAddress3% ip4:%A_IPAddress4% ipl:%ipl%
    return { loc:loc, count:adapter_count, ip:public_ip
           , ip1:A_IPAddress1, ip2:A_IPAddress2, ip3:A_IPAddress3, ip4:A_IPAddress4, ipl:substr(ipl,1,-3)}
}

netStatus(){
    static VPN_prefix:="10.3.", n:=strlen(VPN_prefix), time_start, old_status:=""

    ipInfo:=getIPInfo()
    if ipInfo.count=0
        status:= -1    ; No connection
    else if (!ipInfo.ip)
        status:= 0    ; No internet
    else if ( substr(ipInfo.ip1,1,n)=VPN_prefix OR substr(ipInfo.ip2,1,n)=VPN_prefix OR substr(ipInfo.ip3,1,n)=VPN_prefix OR substr(ipInfo.ip4,1,n)=VPN_prefix )
        status:= 2    ;VPN
    else status:= 1   ;Internet, no VPN

    time_current:=A_TickCount
    if (status!=old_status)
        time_start:=time_current
    old_status:=status

    return {status:status, time:time_current-time_start, ipInfo:ipInfo}
}

netNotify(refresh:=True,show:=True,life:=0) {
    static current:={}, old:={}    ;current=last time checked, old=last time notified

    if !show
        return refresh ? netStatus() : current     ; Static var are not updated when !show even if refresh=true

    msg:=""
    if refresh {
        net:=netStatus()

        if (current.status=""){  ;first run
            current:=net, old:=net
            ; obj:=func("netNotify").bind(false,,1000)
            ; setTimer, % obj, -1
            return
        }

        if (net.time<=0 OR old.status=net.status)
            return current:=net   ; Not enough time to show notification OR no change

        if net.status=0 AND old.status>0
            title:= "Internet disconnected"        , highlight:={1:True}
        else if net.status=-1 AND old.status>=0
            title:="No Network Connection"         , highlight:={0:True}
        else if net.status=0 AND old.status=-1
            title:= "Network Connected"            , highlight:={0:True}
        else if net.status=1 AND old.status<=0
            title:= "Internet Connected"           , highlight:={1:True}
        else if net.status=1 AND old.status=2
            title:= "VPN disconnected"             , highlight:={2:True}
        else if net.status=2 AND old.status<=0
            title:= "Internet Connected (with VPN)", highlight:={1:True, 2:True}
        else if net.status=2 AND old.status=1
            title:= "VPN Connected"                , highlight:={2:True}

        current:=net, old:=net
    }
    if !title
        title:="Internet Status"
    if (current.status="")
        msg:=["No Info"], color:=[False]
    else{
        msg:= [ "Network = "     (current.status=-1 ?"No"               :"Yes" )
              , "Internet = "    (current.status>0  ?"Yes"              :"No"  )
              , "VPN = "         (current.status=2  ?"Yes"              :"No"  )
              , "Public IP = "   (current.ipInfo.ip ?current.ipInfo.ip  :"None")
              , "IP Location = " (current.ipInfo.loc?current.ipInfo.loc :"?"   )
              , "Local IP = "    (current.ipInfo.ipl?current.ipInfo.ipl :"None")       ]

        color:= [ current.status!=-1, current.status>0, current.status==2, current.ipInfo.ip, current.ipInfo.loc, current.ipInfo.ipl]
    }
    netNotifyShow(title,msg,color,highlight,life,refresh)
    return current
}
netNotifyShow(title,msg,col,h,t,s){
    static netNotifyToast
    , active_color:="0xffffff", inactive_color:="0x505050", active_hcolor:="0x107C10", inactive_hcolor:="0xFF1010"
    if !netNotifyToast
        netNotifyToast:=new toast({ life:0, title:{size:14,opt:"bold underline"}, message:{size:12}, margin:{x:20,y:20} })
    c:=[], o:=[]
    for i,ci in col
        c[i]:=ci?(h[i-1]?active_hcolor:active_color):(h[i-1]?inactive_hcolor:inactive_color)
    for i,hi in h
        o[i+1]:=hi?"bold":""

    return netNotifyToast.show({ title:{text:title}, message:{text:msg,color:c,opt:o, life:t}, sound:s })
}