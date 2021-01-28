#SingleInstance, force
#Persistent

w := CreateObject("CommonDialog1")
w.InitDir := "C:\Program Files"
w.ShowOpen
ExitApp