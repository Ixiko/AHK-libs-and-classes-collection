; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=77311
; Author:
; Date:
; for:     	AHK_L

; Original concept by ahklerner
; https://autohotkey.com/board/topic/64700-rotary-knob-for-a-gui/#entry408451
; Edited to be used as a library function by x32
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=77311

class RotaryKnob {

	__New(hControl,size,angle) {
		this.size := size
		this.angle := angle
		this.knobSize := size * 1.05
		this.indicatorSize := size / 9
		this.radius := this.knobSize / 3
		this.hdc := DllCall("GetDC", "uint", hControl)
		this.x := 0
		this.y := 0
		this.Draw(this.angle)
	}

	Draw(angle) {
		this.angle := (angle > 360 ? 360 : angle < 0 ? 0 : angle)
		this.UpdatePosition()

		DllCall("Ellipse", "uint", this.hDc, "int", 1, "int", 1, "int", this.knobsize, "int", this.knobsize)
		DllCall("Ellipse", "uint", this.hDc, "int", 3, "int", 3, "int", this.knobsize-2, "int", this.knobsize-2)
		DllCall("Ellipse", "uint", this.hDc, "int", this.x, "int", this.y, "int", this.x + this.indicatorsize, "int", this.y + this.indicatorsize)
	}

	UpdatePosition() {
		this.x := ((this.knobsize/2)-3) - sin(this.angle*4*ATan(1)/180)*this.radius
		this.y := ((this.knobsize/2)-3) + cos(this.angle*4*ATan(1)/180)*this.radius
	}

	UpdateSize(size) {
		this.knobSize := size * 1.05
		this.indicatorSize := size / 9
	}
}