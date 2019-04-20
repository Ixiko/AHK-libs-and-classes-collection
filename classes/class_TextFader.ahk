; ------ Function to fade text in text controls, by ih57452 --------------------------------------------->>

class TextFader {
  __New(text_color = 0x000000, background_color = 0xf0f0f0, step = 15) {
    global Color
    this.text_color := new Color(text_color)
    this.background_color := new Color(background_color)
    this.step := step
    this.fade_color := new Color
  }

  to(params*) {
    controls := []
    for k, v in params
    {
      if (Mod(k, 2) != 0)
        controls.Insert(v)
    }
    this.out(controls*)
    this.in(params*)
  }

  out(controls*) {
    percent = 100
    while percent > 0
    {
      percent -= this.step
      for k, v in ["R", "G", "B"]
        this.fade_color[v] := Round(this.background_color[v] + ((this.text_color[v] - this.background_color[v]) * (percent / 100)))
      for k, control in controls
      {
        GuiControl, % "+C" . (percent <= 0 ? this.background_color.hex : this.fade_color.hex), %control%
        GuiControl, MoveDraw, %control%
      }
      Sleep, 1
    }
  }

  in(params*) {
    controls := {}
    for k, v in params
    {
      if (Mod(k, 2) != 0)
        control := v
      else
        controls[control] := v
    }
    percent = 0
    while percent < 100
    {
      percent += this.step
      for k, v in ["R", "G", "B"]
        this.fade_color[v] := Round(this.background_color[v] + ((this.text_color[v] - this.background_color[v]) * (percent / 100)))
      for control, text in controls
      {
        GuiControl, % "+C" . (percent >= 100 ? this.text_color.hex : this.fade_color.hex), %control%
        GuiControl,, %control%, %text%
      }
      Sleep, 1
    }
  }
}

class Color ; ---- Modified color class from the AHK_L help file -------------------!!
{
  __New(aRGB = 0x000000) {
    this.RGB := aRGB
  }

  __Get(aName) {
    if (aName = "R")
      return (this.RGB >> 16) & 255
    if (aName = "G")
      return (this.RGB >> 8) & 255
    if (aName = "B")
      return this.RGB & 255
    if (aName = "hex")
    {
      format_setting := A_FormatInteger
      SetFormat, IntegerFast, h
      hex := SubStr(this.RGB + 0, 3)
      SetFormat, IntegerFast, %format_setting%
      while StrLen(hex) < 6
        hex := "0" . hex
      return, "0x" . hex
    }
  }

  __Set(aName, aValue) {
    if aName in R,G,B
    {
      aValue &= 255
      if      (aName = "R")
        this.RGB := (aValue << 16) | (this.RGB & ~0xff0000)
      else if (aName = "G")
        this.RGB := (aValue << 8)  | (this.RGB & ~0x00ff00)
      else  ; (aName = "B")
        this.RGB :=  aValue        | (this.RGB & ~0x0000ff)
      return aValue
    }
  }
}
