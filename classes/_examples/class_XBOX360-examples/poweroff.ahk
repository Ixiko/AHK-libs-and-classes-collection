#NoEnv
#Include ../XBOX360.ahk

x360 := []

manager :=  new Xbox360LibControllerManager()

loop 4 {
    manager.PowerOffController(A_Index -1)
}

return