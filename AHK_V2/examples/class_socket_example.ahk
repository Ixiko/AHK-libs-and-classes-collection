#Include _socket.ahk

#Requires AutoHotkey v2.0-beta ; 32-bit


g := Gui()
g.OnEvent("close",gui_close)
g.OnEvent("escape",gui_close)
g.Add("Edit","vMyEdit Multi w500 h500 ReadOnly","")
g.Show()


gui_close(*) {
    ExitApp
}

print_gui(str) {
    global g
    AppendText(g["MyEdit"].hwnd,str)
}

client_data := ""

F1::test_google()
F2::test_server()
F3::test_client()
F4::{ ; clear log
    client_data := ""
    g["MyEdit"].Value := ""
}
F5::test_error()

F6::test_send()

F7::test_google_blocking()

test_error() {
    sock := winsock("client-err",cb,"IPV4")
    
    ; sock.Connect("www.google.com",80) ; 127.0.0.1",27015 ; www.google.com",80
    result := sock.Connect("localhost",5678) ; error is returned in callback
}

test_google() {
    sock := winsock("client",cb,"IPV6")
    
    sock.Connect("www.google.com",80) ; 127.0.0.1",27015 ; www.google.com",80
    ; sock.Connect("www.autohotkey.com",80) ; www.autohotkey.com/download/2.0/
    
    print_gui("Client connecting...`r`n`r`n")
}

test_server() { ; server - uses async to accept sockets
    sock := winsock("server",cb,"IPV4")
    sock.Bind("0.0.0.0",27015) ; "0.0.0.0",27015
    
    sock.Listen()
    
    print_gui("Server listening...`r`n`r`n")
}

test_client() { ; client
    sock := winsock("client",cb,"IPV4")
    
    sock.Connect("127.0.0.1",27015) ; 127.0.0.1",27015 ; www.google.com",80
    
    print_gui("Client connecting...`r`n`r`n")
}

test_google_blocking() { ; this uses no async at all
    sock := winsock("client",cb,"IPV6")
    
    domain := "www.autohotkey.com" ; www.google.com / www.autohotkey.com
    port := 443 ; 443 / 80
    
    If !(r1 := sock.Connect(domain,port,true)) { ; www.google.com
        msgbox "Could not connect: " sock.err
        return
    }
    
    get_req := "GET / HTTP/1.1`r`n"
             . "Host: " domain "`r`n`r`n"
    
    strbuf := Buffer(StrPut(get_req,"UTF-8"),0)
    StrPut(get_req,strbuf,"UTF-8")
    
    If !(r2 := sock.Send(strbuf)) {
        Msgbox "Send failed."
        return
    }
    
    While !(buf:=sock.Recv()).size ; wait for data
        Sleep 10
    
    result := ""
    while buf.size {
        result .= StrGet(buf,"UTF-8") ; collect data
        buf:=sock.Recv()
    }
    
    sock.Close()
    
    A_Clipboard := result
    msgbox "Done.  Check clipboard."
}

test_send() { ; the connecting client doesn't use async
    sock := winsock("client", cb, "IPV4")
    If !(r := sock.Connect("127.0.0.1", 27015, true)) { ; connect as blocking, setting param #3 to TRUE
        msgbox "Could not connect."
        return ; handle a failed connect properly
    }
    
    msg := "abc"
    strbuf := Buffer(StrLen(msg) + 1) ; for UTF-8, take strLen() + 1 as the buffer size
    StrPut(msg, strbuf, "UTF-8")
    
    r := sock.Send(strbuf) ; check send result if necessary
    
    sock.Close()
}

cb(sock, event, err) {
    global client_data
    
    dbg("sock.name: " sock.name " / event: " event " / err: " err " ===========================")
    
    if (sock.name = "client") {
    
        if (event = "close") {
            msgbox "Address: " sock.addr "`n" "Port: " sock.port "`n`n" client_data
            A_Clipboard := client_data
            client_data := ""
            sock.close()
            
        } else if (event = "connect") { ; connection complete, if (err = 0) then it is a success
            print_gui("Client...`r`nConnect Addr: " sock.addr "`r`nConnect Port: " sock.port "`r`n`r`n") ; this does not check for failure
            
        } else if (event = "write") { ; client ready to send/write
            get_req := "GET / HTTP/1.1`r`n"
                     . "Host: www.google.com`r`n`r`n"
            
            strbuf := Buffer(StrPut(get_req,"UTF-8"),0)
            StrPut(get_req,strbuf,"UTF-8")
            
            sock.Send(strbuf)
            
            print_gui("Client sends to server:`r`n"
                    . "======================`r`n"
                    . Trim(get_req,"`r`n") "`r`n"
                    . "======================`r`n`r`n")

        } else if (event = "read") { ; there is data to be read
            buf := sock.Recv()
            client_data .= StrGet(buf,"UTF-8")
        }
        
        
        
    } else if (sock.name = "server") || instr(sock.name,"serving-") {
    
        if (event = "accept") {
            sock.Accept(&addr,&newsock) ; pass &addr param to extract addr of connected machine
               
            print_gui("======================`r`n"
                    . "Server processes client connection:`r`n"
                    . "address: " newsock.addr "`r`n"
                    . "======================`r`n`r`n" )
            
        } else if (event = "close") {
            
            
        } else if (event = "read") {
            
            If !(buf := sock.Recv()).size ; get buffer, check size, return on zero-size buffer
                return
            
            dbg("buf size: " buf.size)
            
            print_gui("======================`r`n"
                    . "Server recieved from client:`r`n"
                    . Trim(strget(buf,"UTF-8"),"`r`n") "`r`n"
                    . "======================`r`n`r`n")
        }
        
    } else if (sock.name = "client-err") { ; this is how you catch an error with async / non-blocking
        
        if (event = "connect") && err
            msgbox sock.name ": " event ": err: " err 
        
    }
    
    ; dbg(sock.name ": " event ": err: " err) ; to make it easier to see all the events
}
        


; ==========================================================
; support funcs
; ==========================================================

AppendText(EditHwnd, sInput, loc := "bottom") { ; Posted by TheGood: https://autohotkey.com/board/topic/52441-append-text-to-an-edit-control/#entry328342
    insertPos := (loc="bottom") ? SendMessage(0x000E, 0, 0,, "ahk_id " EditHwnd) : 0    ; WM_GETTEXTLENGTH
    r1 := SendMessage(0x00B1, insertPos, insertPos,, "ahk_id " EditHwnd)                ; EM_SETSEL - place cursor for insert
    r2 := SendMessage(0x00C2, False, StrPtr(sInput),, "ahk_id " EditHwnd)               ; EM_REPLACESEL - insert text at cursor
}

dbg(_in) { ; AHK v2
    Loop Parse _in, "`n", "`r"
        OutputDebug "AHK: " A_LoopField
}