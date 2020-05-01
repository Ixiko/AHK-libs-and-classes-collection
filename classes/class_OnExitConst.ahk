;==================================================================
; ONEXIT CONSTANTS v1.0.0
; Author: Daniel Shuy
; 
; A library of constants for the OnExit function/command
;==================================================================

class OnExitConst {
;==================================================================
; AddRemove Constants
; see https://autohotkey.com/docs/commands/OnExit.htm
;==================================================================
	; Call the function after any previously registered functions
	static ON_EXIT_ADD_AFTER 	:= 	1
	
	; Call the function before any previously registered functions
	static ON_EXIT_ADD_BEFORE 	:= -1
	
	; Do not call the function
	static ON_EXIT_REMOVE 		:= 	0
;==================================================================
}
