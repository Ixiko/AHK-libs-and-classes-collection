;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; Sorts a string array.
RA_StringSort(as)
{
	sSorted := st_Split(as)
	Sort, sSorted
	asSorted := st_Glue(sSorted)
	return % asSorted
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;