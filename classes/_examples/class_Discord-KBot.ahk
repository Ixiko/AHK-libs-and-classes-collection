#Include OSD.ahk
#Include Discord.ahk
Global token:= readIniVal("token"), discord:= new Discord(token)
, guild_id:= readIniVal("guild_id"), txt_channels:=Array()
, voice_channels:=Array(), members:=Array()
, curr_txt_channel, curr_voice_channel, curr_user_id:=
, last_txt_checked, last_voice_checked, last_user_checked
, msg_str:="<@{}>`n <a:bear_uwu:761543382891495435> {} <a:bear_uwu:761543382891495435>"
initChannels()
initMembersList()
initTray()
readDefaults()
Global memebrsEnum:= members._NewEnum()
SetFormat, IntegerFast, d
helloStr:= chr(0x645) . chr(0x631) . chr(0x62d) . chr(0x628) 
loop, 60
    helloStr.= chr(0x627)
discord.SendMessage(curr_txt_channel, Format("@everyone `n <a:bear_uwu:761543382891495435> {} <a:bear_uwu:761543382891495435>", helloStr))
msgId:=discord.CallAPI("GET","/channels/" . curr_txt_channel . "/messages?limit=1")[1].id
OnExit(Func("deleteMsg").Bind(curr_txt_channel,msgId))
;===============================================Discord Hotkeys===============================================
<!F1:: ;cycle through members
cycleMembers()
OSD_spawn(last_user_checked.user.username . "#" . last_user_checked.user.discriminator . " selected")
return

<^<+M:: ;mute/unmute selected member from voice chat
mute_state:= (discord.CallAPI("GET","/guilds/" . guild_id . "/members/" . curr_user_id)).mute
try discord.CallAPI("PATCH","/guilds/" . guild_id . "/members/" . curr_user_id,{mute:!mute_state})
OSD_spawn((!mute_state? "Muted " : "Unmuted ") . getMember(curr_user_id).user.username)
return

<^<+D:: ;move selected member to afk channel then back to selected channel
moveTo(curr_user_id)
Sleep, 500
moveTo(curr_user_id,curr_voice_channel)
discord.SendMessage(curr_txt_channel, Format(msg_str, curr_user_id, getRandomMsg()))
msgId:=discord.CallAPI("GET","/channels/" . curr_txt_channel . "/messages?limit=1")[1].id
clr:= Func("deleteMsg").Bind(curr_txt_channel,msgId)
SetTimer, % clr, -15000
return
;===============================================Discord Functions===============================================
moveTo(userID,chID:=""){
    if(!chID)
        chID:= discord.CallAPI("GET","/guilds/" . guild_id).afk_channel_id
    try discord.CallAPI("PATCH","/guilds/" . guild_id . "/members/" . userID,{channel_id:chID})
}

setTxtChannel(ch){
    curr_txt_channel:= ch.id
    if(last_txt_checked)
        Menu, TextChannels, Uncheck, % last_txt_checked.name
    Menu, TextChannels, check, % ch.name
    last_txt_checked:= ch
    writeIniVal("txt_channel",curr_txt_channel,"defaults")
}

setVoiceChannel(ch){
    curr_voice_channel:= ch.id
    if(last_voice_checked)
        Menu, VoiceChannels, Uncheck, % last_voice_checked.name
    Menu, VoiceChannels, check, % ch.name
    last_voice_checked:= ch
    writeIniVal("voice_channel",curr_voice_channel,"defaults")
}

cycleMembers(){
    mbr:=,key:=
    enumVal:= memebrsEnum.Next(key,mbr)
    if(mbr.user.id = curr_user_id)
        enumVal:= memebrsEnum.Next(key,mbr)
    if(!enumVal){
        memebrsEnum:= members._NewEnum()
        cycleMembers()
        return
    }
    setMember(mbr)    
}

setMember(mbr){
    curr_user_id:= mbr.user.id
    if(last_user_checked)
        Menu, Users, Uncheck, % last_user_checked.user.username . "#" . last_user_checked.user.discriminator
    Menu, Users, check, % mbr.user.username . "#" . mbr.user.discriminator
    last_user_checked:= mbr
    writeIniVal("user_id",curr_user_id,"defaults")
}

getMember(chID){
    return discord.CallAPI("GET","/guilds/" . guild_id . "/members/" . chID)
}

getChannel(chID){
    return discord.CallAPI("GET","/channels/" . chID)
}

deleteMsg(chID,msgID){
    discord.CallAPI("DELETE", "/channels/" . chID . "/messages/" msgID)
}

initChannels(){
    chList:= discord.CallAPI("GET","/guilds/" . guild_id . "/channels")
    for i, channel in chList {
        if(channel.type=2){ ;voice
            voice_channels.Push(channel)
        }else if (channel.type=0){
            txt_channels.Push(channel)
        }
    }
}

initMembersList(){
    mbrList:= discord.CallAPI("GET","/guilds/" . guild_id . "/members?limit=1000")
    for i, member in mbrList {
        members.Push(member)
    }
}

getRandomMsg(){
    str:=""
    Random, num, 0.0, 1.0
    num:= floor(3*num)
    switch num {
        case 0: ;شم
            str.= chr(0x0634)
            loop 19
                str.= chr(0x0645)
        case 1: ; مستوى 25
            loop 25
                str.= " " . chr(0x0645) . chr(0x0633) . chr(0x062a) . chr(0x0648) . chr(0x0649) . " " 
        case 2: ; 
            loop 2
                str.= chr(0x0627) . chr(0x0628) . chr(0x0644) . chr(0x0639) . " "
            str.= chr(0x0634)
            loop 7
                str.= chr(0x0645)
            str.= " " . chr(0x0645) . chr(0x0633) . chr(0x062a) . chr(0x0648) . chr(0x0649) . " " 
        case 3:
            str.= chr(0x0645) . chr(0x0646) . chr(0x0648) . chr(0x0628) . " "
            str.= chr(0x0627) . chr(0x0628) . chr(0x0644) . chr(0x0639) . " "
    }
    return str
}
;===============================================config===============================================
readIniVal(key,section:="settings"){
    IniRead, val, config.ini, %section%, %key%, %A_Space%
    return val
}

writeIniVal(key,value,section:="settings"){
    IniWrite, %value%, config.ini, %section%, %key%
}

editConfig(){
    RunWait, notepad.exe config.ini
}

readDefaults(){
    setTxtChannel(getChannel(readIniVal("txt_channel", "defaults")))
    setVoiceChannel(getChannel(readIniVal("voice_channel", "defaults")))
    setMember(getMember(readIniVal("user_id", "defaults")))
}
;===============================================tray===============================================
initTray(){
    Menu, Tray, NoStandard
    ;init txt channels menu
    for i, ch in txt_channels{
        funcObj:= Func("setTxtChannel").Bind(ch)
        Menu, TextChannels, Add, % ch.name, % funcObj, +Radio
    }
    ;init voice channels menu
    for i, ch in voice_channels{
        funcObj:= Func("setVoiceChannel").Bind(ch)
        Menu, VoiceChannels, Add, % ch.name, % funcObj, +Radio
    }
    ;init users menu
    for i, mbr in members{
        funcObj:= Func("setMember").Bind(mbr)
        Menu, Users, Add, % mbr.user.username . "#" . mbr.user.discriminator, % funcObj, +Radio
    }
    ;add submenus to tray
    Menu, Tray, Add, Text Channel, :TextChannels
    Menu, Tray, Add, Voice Channel, :VoiceChannels
    Menu, Tray, Add, User, :Users
    Menu, Tray, Add, Edit config, editConfig
    Menu, Tray, Add, Close, close
}
close(){
    discord.ws.Close()
    ExitApp
}