#NoEnv
#SingleInstance, Force
#Include, ..\BarsBox.ahk



;-------------------------------------------------------------------------------
; Example: visualize 10,000 random integers 1..100
;-------------------------------------------------------------------------------
    Even := {SampleSize: 10000, min: 1, max: 100, Bars: 100, DATA: []}

    Loop % Even.SampleSize {
        Random RandomNum, Even.min, Even.max
        Even.DATA.Push(RandomNum)
    }
    BarsBox("Even", 200, 100)



;-------------------------------------------------------------------------------
; Example: visualize 10,000 random integers 1..6 (dice throws)
;-------------------------------------------------------------------------------
    Dice := {SampleSize: 10000, min: 1, max: 6, Bars: 6, DATA: []}

    Loop % Dice.SampleSize {
        Random RandomNum, Dice.min, Dice.max
        Dice.DATA.Push(RandomNum)
    }
    BarsBox("Dice", 200, 100)



;-------------------------------------------------------------------------------
; Example: visualize 10,000 random integers 0..1 (coin flips)
;-------------------------------------------------------------------------------
    Coins := {SampleSize: 10000, min: 0, max: 1, Bars: 2, DATA: []}

    Loop % Coins.SampleSize {
        Random RandomNum, Coins.min, Coins.max
        Coins.DATA.Push(RandomNum)
    }
    BarsBox("Coins", 200, 100)



;-------------------------------------------------------------------------------
; Example: visualize 10,000 random floats 0..(1.0)
;-------------------------------------------------------------------------------
    Floats := {SampleSize: 10000, min: 0, max: 1.0, Bars: 100, DATA: []}

    Loop % Floats.SampleSize {
        Random RandomNum, Floats.min, Floats.max
        Floats.DATA.Push(RandomNum)
    }
    BarsBox("Floats", 200, 100)



;-------------------------------------------------------------------------------
; Example: visualize 10,000 random floats 0..(1.0)
;-------------------------------------------------------------------------------
    Float2 := {SampleSize: 10000, min: 1.0, max: 3.0, Bars: 100, DATA: []}

    Loop % Float2.SampleSize {
        Random RandomNum, Float2.min, Float2.max
        Float2.DATA.Push(RandomNum)
    }
    BarsBox("Float2", 200, 100)

ExitApp
