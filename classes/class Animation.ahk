;-------------------------------------------------------------------------------
; class Animation.ahk
; by wolf_II
;-------------------------------------------------------------------------------
; version 1.30



;===============================================================================
class Animation { ; manage animations
;===============================================================================


    static pToken   := ""
    static Count    := 0

    ; configuration
    BkColor             := 0x00FFFFFF   ; transparent white
    Delay               := 10           ; 1..16 <- all the same
    Draw                := "Draw"       ; function name

    ; configure "Quality functions"
    TextRenderingMode   := ANTIALIAS
    InterpolationMode   := HIGHQUALITYBICUBIC
    SmoothingMode       := ANTIALIAS
    CompositingMode     := OVERWRITE


    ;---------------------------------------------------------------------------
    __New(hParent, Config := "") { ; attach to parent
    ;---------------------------------------------------------------------------
        If Config.HasKey("BkColor")
            this.BkColor := Config.BkColor
        If Config.HasKey("Delay")
            this.Delay := Config.Delay
        If Config.HasKey("Draw")
            this.Draw := Config.Draw
        If Config.HasKey("TextRenderingMode")
            this.TextRenderingMode := Config.TextRenderingMode
        If Config.HasKey("InterpolationMode")
            this.InterpolationMode := Config.InterpolationMode
        If Config.HasKey("SmoothingMode")
            this.SmoothingMode := Config.SmoothingMode
        If Config.HasKey("CompositingMode")
            this.CompositingMode := Config.CompositingMode
        If !Animation.pToken
            Animation.pToken := Gdip_Startup()
        Animation.Count++

        GuiControl, +E0x80000, % this.hWnd := hParent ; WS_EX_LAYERED
        this.hBM := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
        this.hDC := CreateCompatibleDC()
        this.oBM := SelectObject(this.hDC, this.hBM)
        this.pGraphics := Gdip_GraphicsFromHDC(this.hDC)

        Gdip_SetTextRenderingHint(this.pGraphics, this.TextRenderingMode)
        Gdip_SetInterpolationMode(this.pGraphics, this.InterpolationMode)
        Gdip_SetSmoothingMode(this.pGraphics, this.SmoothingMode)
        Gdip_SetCompositingMode(this.pGraphics, this.CompositingMode)
    }


    ;---------------------------------------------------------------------------
    __Delete() { ; clean up
    ;---------------------------------------------------------------------------
        this.Clear()
        this.Update()
        SelectObject(this.hDC, this.oBM)
        DeleteObject(this.hBM)
        DeleteDC(this.hDC)
        Gdip_DeleteGraphics(this.pGraphics)

        If (--Animation.Count = 0)
            Gdip_Shutdown(Animation.pToken)
    }


    ;---------------------------------------------------------------------------
    Call() { ; timer controlled
    ;---------------------------------------------------------------------------
        this.Clear()
        Func(this.Draw).Call()
        this.Update()
    }


    ;---------------------------------------------------------------------------
    Clear() { ; stand alone
    ;---------------------------------------------------------------------------
        Gdip_GraphicsClear(this.pGraphics, this.BkColor)
    }


    ;---------------------------------------------------------------------------
    Update() { ; stand alone
    ;---------------------------------------------------------------------------
        UpdateLayeredWindow(this.hWnd, this.hDC)
    }


    ;---------------------------------------------------------------------------
    Start() { ; start timer
    ;---------------------------------------------------------------------------
        SetTimer, %this%, % this.Delay
        this.Call() ; start immediately
    }


    ;---------------------------------------------------------------------------
    Stop() { ; stop timer
    ;---------------------------------------------------------------------------
        SetTimer, %this%, Off
    }
}
