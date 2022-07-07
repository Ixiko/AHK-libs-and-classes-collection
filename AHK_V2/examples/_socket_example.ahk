#Include _socket.ahk


g := Gui()
g.OnEvent("close",gui_close)
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
F4::{
    client_data := ""
    msgbox "cleared client data"
}
F5::test_error()

test_error() {
    sock := winsock("client-err",cb,"IPV4")
    
    ; sock.Connect("www.google.com",80) ; 127.0.0.1",27015 ; www.google.com",80
    result := sock.Connect("localhost",5678) ; error is returned in callback
}

test_google() {
    sock := winsock("client",cb,"IPV4")
    
    ; sock.Connect("www.google.com",80) ; 127.0.0.1",27015 ; www.google.com",80
    sock.Connect("www.autohotkey.com",80) ; www.autohotkey.com/download/2.0/
    
    ; dbg(sock.name ": err: " sock.err " / LO: " sock.LastOp)
    print_gui("Client connecting...`r`n`r`n")
}

test_server() { ; server
    sock := winsock("server",cb,"IPV4")
    sock.Bind("0.0.0.0",27015) ; "0.0.0.0",27015
    
    dbg(sock.name ": err: " sock.err " / LO: " sock.LastOp)
    
    sock.Listen()
    dbg(sock.name ": err: " sock.err " / LO: " sock.LastOp)
    
    print_gui("Server listening...`r`n`r`n")
}

test_client() { ; client
    sock := winsock("client",cb,"IPV4")
    
    sock.Connect("127.0.0.1",27015) ; 127.0.0.1",27015 ; www.google.com",80
    
    ; dbg(sock.name ": err: " sock.err " / LO: " sock.LastOp)
    print_gui("Client connecting...`r`n`r`n")
}

cb(sock, event, err) {
    global client_data
    
    if (sock.name = "client") {
    
        if (event = "close") {
            msgbox client_data
            A_Clipboard := client_data
            client_data := ""
            sock.close()
            
        } else if (event = "connect") { ; connection complete
            ; nothing for now
            
        } else if (event = "write") { ; client ready to send/write
            get_req := "GET / HTTP/1.1`r`n"
                     . "Host: www.google.com`r`n`r`n"
            
            strbuf := Buffer(StrPut(get_req,"UTF-8"),0)
            StrPut(get_req,strbuf,"UTF-8")
            
            sock.Send(strbuf)
            
            print_gui("Client sends to server:`r`n`r`n"
                    . "======================`r`n`r`n"
                    . get_req
                    . "======================`r`n`r`n")

        } else if (event = "read") { ; there is data to be read
            buf := sock.Recv()
            client_data .= StrGet(buf,"UTF-8")
        }
        
        
        
    } else if (sock.name = "server") || instr(sock.name,"serving-") {
    
        if (event = "accept") {
            sock.Accept(&addr) ; pass &addr param to extract addr of connected machine
               
            print_gui("Server processes client connection:`r`n`r`n"
                    . "address: " sock.AddrToStr(addr) 
                    . "`r`n`r`n======================`r`n`r`n" )
            
        } else if (event = "close") {
            
            
        } else if (event = "read") {
            buf := sock.Recv()
            print_gui("Server recieved from client:`r`n`r`n"
                    . "======================`r`n`r`n"
                    . strget(buf,"UTF-8")
                    . "======================`r`n`r`n")
        }
        
    } else if (sock.name = "client-err") {
        
        if (event = "connect")
            msgbox sock.name ": " event ": err: " err 
        
    }
    
    
    dbg(sock.name ": " event ": err: " err) ; to make it easier to see all the events
    
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