#include %A_ScriptDir%\..\MouseDelta.ahk
#SingleInstance force
 
MacroOn := 0
md := new MouseDelta("MouseEvent")
return
 
F12::
	MacroOn := !MacroOn
	md.SetState(MacroOn)
	return

; Keeps a track of a "Pool" for each direction of movement (u, d, l, r)
; The pools constantly empty every 10ms at the rate dictated by DecayRate
; Moving the mouse in a direction will add the delta value to the pool, to a max of PoolCap
; If one direction's pool crosses the threshold, that direction is considered "Held"
; In this case, the opposite direction's pool is emptied.
MouseEvent(MouseID, x := "", y := ""){
	; User configurables
	static DecayRate := 1		; The rate at which the pools decay
	static PoolCap := 20		; The highest value a pool can hold
	static Threshold := 3		; If a pool crosses this value, it is considered held
	; Output keys
	static KeyMap := {y: {-1: "Up", 1: "Down"}, x: {-1: "Left", 1: "Right"}}	; Arrow Keys
	; End of user configurables
	
	; StopFns are fired while the pool for an exis is not empty
	static StopFns := {x: Func("MouseEvent").Bind(-1,0), y: Func("MouseEvent").Bind(-1,"",0)}
	static VectorPools := {x: {-1: 0, 1: 0}, y: {-1: 0, 1: 0}}
	Static AxisStates := {x: 0, y: 0}
	static Vectors := {-1: "", 1: ""}	; just used for iteration
	static TimerStates := {x: 0, y: 0}
	
	input_data := {x: x, y: y}
	
	; Apply current input to the pools
	for axis, value in input_data {
		if (value == "")
			continue
		; Deplete vector pools
		for v, u in vectors {
			VectorPools[axis, v] -= DecayRate
			if (VectorPools[axis, v] < 0)
				VectorPools[axis, v] := 0
		}
		; Update pool states
		vector := GetVector(value)
		fn := StopFns[axis]
		if (vector){
			; Movement for this axis
			magnitude := abs(value)
			VectorPools[axis, vector] += magnitude
			if (VectorPools[axis, vector] > PoolCap){
				VectorPools[axis, vector] := PoolCap
			}
			is_over_thresh := (VectorPools[axis, vector] > Threshold)
			was_over_thresh := (VectorPools[axis, vector] > Threshold)
			if (!was_over_thresh && is_over_thresh){
				; Crossed threshold, cancel out opposite axis
				; This is used to allow switching of directions relatively quickly.
				; If we cross the threshold on a new vector, zero out the other vector
				VectorPools[axis, vector * -1] := 0
			}
			; If there was movement on this axis and the timer is not running, then start it running
			if (!TimerStates[axis]){
				SetTimer, % fn, 10
			}
		} else {
			; No movement for this axis
			if (VectorPools[axis, -1] + VectorPools[axis, 1] == 0){
				; Pools for this axis are empty, stop timer
				SetTimer, % fn, Off
			}
		}
	}
	
	; Change states of outputs according to pools
	for axis, value in input_data {
		new_vector := (VectorPools[axis, -1] > Threshold ? -1 : (VectorPools[axis, 1] > Threshold ? 1 : 0))
	
		if (new_vector != AxisStates[axis]){
			; This axis changed state
			if (AxisStates[axis] != 0){
				; One of the directions for this axis was previously held, release old key
				Send %  "{" KeyMap[axis, AxisStates[axis]] " up}"
				
			}
			if (new_vector){
				; The new state is non-zero, so press the new key
				Send % "{" KeyMap[axis, new_vector] " down}"
			}
		}
		AxisStates[axis] := new_vector
	}
}

; Returns -1 for negative input, +1 for positive, else 0
GetVector(val){
	if (val == 0)
		return 0
	else if (val < 0)
		return -1
	else
		return 1
}