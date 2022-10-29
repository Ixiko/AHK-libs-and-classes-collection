/*
    Library: json
    Author: neovis
    https://github.com/neovis22/date
*/

date(datetime="now") {
    return new __Date__(datetime)
}

class __Date__ {
    
    static timezoneOffset := (unixtime(a_now)-unixtime(a_nowUTC))//60 ; minutes
    
    __new(datetime) {
        if (datetime == "now") {
            this.datetime := a_now
        } else {
            ; 생략된 날짜표현을 YYYYMMDDHH24MISS 포맷으로 완성
            ts := datetime
            ts -= p := 1970, s
            if (ts == "")
                throw Exception("invalid datetime format: " datetime)
            p += ts, s
            this.datetime := p
        }
    }
    
    toString(format="") {
        if (format == "") {
            FormatTime date, % this.datetime " L1033", ddd MMM dd yyyy HH:mm:ss
            p := 1970
            p += Abs(this.timezoneOffset), m
            FormatTime offset, % p, HHmm
            return date " GMT" (this.timezoneOffset < 0 ? "-" offset : "+" offset)
        }
        
        FormatTime res, % this.datetime, % format
        return res
    }
    
    toISOString() {
        FormatTime res, % this.utcDatetime, yyyy-MM-ddTHH:mm:ss.
        return res Format("{:03}Z", this.milliseconds)
    }
    
    between(begin, end) {
        return begin < end
        ? this.datetime >= begin && this.datetime <= end
        : this.datetime >= begin || this.datetime <= end
    }
    
    time[] { ; Unixtime
        get {
            value := this.datetime
            value -= 1970, s
            return value
        }
        set {
            p := 1970
            p += value, s
            return value, this.datetime := p
        }
    }
    
    year[] {
        get {
            return SubStr(this.datetime, 1, 4)
        }
        set {
            this.datetime := value SubStr(this.datetime, 5)
            return value
        }
    }
    
    month[] {
        get {
            return SubStr(this.datetime, 5, 2)
        }
        set {
            this.datetime := this.year+(value-1)//12 SubStr("0" Mod(value-1, 12)+1, -1) SubStr(this.datetime, 7)
            return value
        }
    }
    
    date[] {
        get {
            return SubStr(this.datetime, 7, 2)
        }
        set {
            this.time := unixtime(SubStr(this.datetime, 1, 6) "01" SubStr(this.datetime, 9))+(value-1)*86400
            return value
        }
    }
    
    hours[] {
        get {
            return SubStr(this.datetime, 9, 2)
        }
        set {
            this.time := unixtime(SubStr(this.datetime, 1, 8) "00" SubStr(this.datetime, 11))+value*3600
            return value
        }
    }
    
    minutes[] {
        get {
            return SubStr(this.datetime, 11, 2)
        }
        set {
            this.time := unixtime(SubStr(this.datetime, 1, 10) "00" SubStr(this.datetime, 13))+value*60
            return value
        }
    }
    
    seconds[] {
        get {
            return SubStr(this.datetime, 13, 2)
        }
        set {
            this.time := unixtime(SubStr(this.datetime, 1, 12) "00")+value
            return value
        }
    }
    
    day[] {
        get {
            return this.dayOfWeek
        }
        set {
            throw Exception("readonly property: day")
        }
    }
    
    dayOfWeek[] {
        get {
            ; 일요일-토요일: 1-7
            return Mod(this.time//86400+4, 7)+1
        }
        set {
            throw Exception("readonly property: dayOfWeek")
        }
    }
    
    dayOfYear[] {
        get {
            return (this.time-unixtime(this.year))//86400+1
        }
        set {
            this.time := unixtime(this.year "0101" SubStr(this.datetime, 9))+(value-1)*86400
            return value
        }
    }
    
    weekOfMonth[] {
        get {
            return Ceil((Mod(unixtime(SubStr(this.datetime, 1, 6))//86400+4, 7)+this.date)/7)
        }
        set {
            throw Exception("readonly property: weekOfMonth")
        }
    }
    
    weekOfYear[] {
        get {
            return Ceil((Mod(unixtime(this.year)//86400+4, 7)+this.dayOfYear)/7)
        }
        set {
            throw Exception("readonly property: weekOfYear")
        }
    }
    
    /*
        UTC proeprties
    */
    
    utcTime[] {
        get {
            return this.time+this.timezoneOffset*60
        }
        set {
            this.time := value+this.timezoneOffset*60
            return value
        }
    }
    
    utcDatetime[] {
        get {
            return datetime(this.utcTime)
        }
        set {
            this.utcTime := unixtime(value)
            return value
        }
    }
    
    utcYear[] {
        get {
            return SubStr(This.utcDatetime, 1, 4)
        }
        set {
            This.utcDatetime := value SubStr(This.utcDatetime, 5)
            return value
        }
    }
    
    utcMonth[] {
        get {
            return SubStr(This.utcDatetime, 5, 2)
        }
        set {
            this.utcDatetime := this.year+(value-1)//12 SubStr("0" Mod(value-1, 12)+1, -1) SubStr(this.utcDatetime, 7)
            return value
        }
    }
    
    utcDate[] {
        get {
            return SubStr(this.utcDatetime, 7, 2)
        }
        set {
            this.utcTime := unixtime(SubStr(this.utcDatetime, 1, 6) "01" SubStr(this.utcDatetime, 9))+(value-1)*86400
            return value
        }
    }
    
    utcHours[] {
        get {
            return SubStr(this.utcDatetime, 9, 2)
        }
        set {
            this.utcTime := unixtime(SubStr(this.utcDatetime, 1, 8) "00" SubStr(this.utcDatetime, 11))+value*3600
            return value
        }
    }
    
    utcMinutes[] {
        get {
            return SubStr(this.utcDatetime, 11, 2)
        }
        set {
            this.utcTime := unixtime(SubStr(this.utcDatetime, 1, 10) "00" SubStr(this.utcDatetime, 13))+value*60
            return value
        }
    }
    
    utcSeconds[] {
        get {
            return SubStr(this.utcDatetime, 13, 2)
        }
        set {
            this.utcTime := unixtime(SubStr(this.utcDatetime, 1, 12) "00")+value
            return value
        }
    }
}

unixtime(datetime="now", p=1970) {
    if (datetime == "")
        throw Exception("datetime required")
    ts := datetime == "now" ? a_now : datetime
    ts -= p, s
    if (ts == "")
        throw Exception("invalid datetime format: " datetime)
    return ts
}

datetime(unixtime="now", p=1970) {
    if (unixtime == "now")
        return a_now
    if (unixtime == "")
        throw Exception("unixtime required")
    if (unixtime ~= "\D")
        throw Exception("invalid unixtime format: " unixtime)
    p += unixtime, s
    return p
}

now() {
    return a_now
}

nowUTC() {
    return a_nowUTC
}
