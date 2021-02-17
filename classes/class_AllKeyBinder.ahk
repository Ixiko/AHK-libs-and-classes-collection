; Title:   	https://www.autohotkey.com/boards/viewtopic.php?f=76&t=63274
; Link:
; Author:
; Date:
; for:     	AHK_L

/*

	#SingleInstance force

	kb := new AllKeyBinder(Func("MyFunc"))
	return

	MyFunc(code, name, state){
		Tooltip % "Key Code: " code ", Name: " name ", State: " state
	}

*/


class AllKeyBinder{
    __New(callback, pfx := "~*"){
        static mouseButtons := ["LButton", "RButton", "MButton", "XButton1", "XButton2"]
        keys := {}
        this.Callback := callback
        Loop 512 {
            i := A_Index
            code := Format("{:x}", i)
            n := GetKeyName("sc" code)
            if (!n || keys.HasKey(n))
                continue
            keys[n] := code

            fn := this.KeyEvent.Bind(this, "Key", i, n, 1)
            hotkey, % pfx "SC" code, % fn, On

            fn := this.KeyEvent.Bind(this, "Key", i, n, 0)
            hotkey, % pfx "SC" code " up", % fn, On
        }

        for i, k in mouseButtons {
            fn := this.KeyEvent.Bind(this, "Mouse", i, n, 1)
            hotkey, % pfx k, % fn, On

            fn := this.KeyEvent.Bind(this, "Mouse", i, n, 0)
            hotkey, % pfx k " up", % fn, On
        }
    }

    KeyEvent(type, code, name, state){
        this.Callback.Call(type, code, name, state)
    }
}