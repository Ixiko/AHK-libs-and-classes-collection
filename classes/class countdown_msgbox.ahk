; Title:   	countdown_msgbox - dynamic countdown title for msgbox
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=88114
; Author:	william_ahk
; Date:   	15.03.2021
; for:     	AHK_L

/*


*/
countdown := new countdown_msgbox({title: "Title                             Countdown: ${s}", text: "Proceed?", sec: 15, style: 4})
Msgbox, % (countdown.proceed ? "Ecce" : "Vale") " homo qui est faba"

class countdown_msgbox {

    __new(options) {
        this.options := options
        this.options.title := StrReplace(options.title, "${s}", "{1}")
        this.msgbox_hwnd := 0x0
        fn_obj := this["get_msgbox_hwnd"].bind(this)
        SetTimer, % fn_obj, -100
        fn_obj := this["update_msgbox"].bind(this)
        SetTimer, % fn_obj, -1000
        Msgbox, % this.options.style, % Format(this.options.title, this.options.sec), % this.options.text, % this.options.sec
        IfMsgbox, Timeout
            this.proceed := true
        IfMsgbox, Yes
            this.proceed := true
        IfMsgbox, No
            this.proceed := false
    }

    update_msgbox() {
        if (this.options.sec > 0) {
            this.options.sec -= 1
            WinSetTitle, % "ahk_id " this.msgbox_hwnd, , % Format(this.options.title, this.options.sec)
            fn_obj := this["update_msgbox"].bind(this)
            SetTimer, % fn_obj, -1000
        }
    }

    get_msgbox_hwnd() {
        SetTitleMatchMode, 2
        WinGet, msgbox_hwnd, ID, % Format(this.options.title, this.options.sec)
        this.msgbox_hwnd := msgbox_hwnd
    }

}