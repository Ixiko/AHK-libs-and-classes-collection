#SingleInstance, force

s := "123456789ABCDEF0 This is some very nice binary data"
s := s s s s s s s s s
HexView(&s, 1024)
return

#include HexView.ahk
#include Attach.ahk
#include Dlg.ahk
#include Mem.ahk