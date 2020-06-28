; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

; Originally created by Spawnova.
; https://www.autohotkey.com/boards/viewtopic.php?f=76&t=77304
; Edited for use as a library function by x32.
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=77307

RemapRange(x,in_min,in_max,out_min,out_max) 
	{
	remapped := (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
	return, %remapped%
	}