scanColorsDown(x, y, h, cols, colVar := 0, incr := 4, hint := "", debug := False, reverse := False, conditionToContinue := "")
{
    found := False
    maxY := y + h
    Loop, 1080
    {
        found := colorsMatch(x, y, cols, colVar, hint, debug, reverse, conditionToContinue)
        if (found)
            break
        y := y + incr
        if (y >= maxY)
            break
    }
    if (found == False)
        y := ""
    return y
}

scanColorsRight(x, y, w, cols, colVar := 0, incr := 4, hint := "", debug := False, reverse := False, conditionToContinue := "")
{
    found := False
    maxX := x + w
    Loop, 1920
    {
        found := colorsMatch(x, y, cols, colVar, hint, debug, reverse, conditionToContinue)
        if (found)
            break
        x := x + incr
        if (x >= maxX)
            break
    }
    if (found < 1)
        x := ""
    
    return x
}

global colorsMatchDebug := False
global colorsMatchDebugTime := 1000
global lastColorMatchResCol := 
colorsMatch(x, y, cols, colVar := 0, hint := "", debug := False, reverse := False, conditionToContinue := "")
{
    success := False
    debug := colorsMatchDebug or debug

    PixelGetColor, resCol, %x%, %y% , RGB
    for i, col in cols
    {
        success := colorComparison(col, resCol, colVar)
        if (debug)
        {
            MouseGetPos, oriX, oriY
            ;ToolTipColor(resCol)
            col := decimal2hex(col)
            if (success)
                msg := "success"
            else
                msg := "no match"
            resDiff := hexColorVariation(col, resCol)
            txt := "col:   " col "            colVar: " colVar "              (" x ", " y "):     " msg
            txt := txt "`r`nres:   " resCol "            resdiff: " resDiff
            moveMouse(x, y, pixelCoordMode)
            msgTip(txt, colorsMatchDebugTime)
            MouseMove, %oriX%, %oriY%
        }
        if (success)
            break
        if (conditionToContinue != "" and !%conditionToContinue%(resCol))
        {
            success := -1
            break
        }
    }
    colorsMatchDebugTime := 1000
    if (!cols.MaxIndex() and debug)
        msgTip("colorsMatch: no colours received.")

    if (reverse)
        success := !success    
    if (hint)
    {
        toolTipPrevMode := setToolTipCoordMode(pixelCoordMode)
        ToolTip, %hint%, %x%, %y%
        Sleep, 25
        ToolTip
        setToolTipCoordMode(toolTipPrevMode)
    } 
    lastColorMatchResCol := resCol
    return success
}

scanColorsLine(x, y, cols, colVar := 0, debug := False)
{
    success := False
    debug := colorsMatchDebug or debug
    
    for i, col in cols
    {
        success := colorsMatch(x, y, [col], colVar, "", debug)
        if (!success)
            break
        x := x + 1
    }
    if (!cols.MaxIndex() and debug)
        msgTip("colorsMatch: no colours received.")
    return success
}

colorComparison(col1, col2, colVar)
{
    success := False
    if (col1 == col2)
        success := True
    else if (colVar > 0)
    {
        diff := hexColorVariation(decimal2hex(col1), decimal2hex(col2))
        success := diff <= colVar
    }
    return success
}