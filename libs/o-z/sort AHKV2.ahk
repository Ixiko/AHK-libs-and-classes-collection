; Title:   	[v2 Function]Sort function - replace the built in one with something useable
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?p=390679#p390679
; Author:	nnik
; Date:   	28.03.2018
; for:     	AHK_L

/*
		Updates:
		v1.0 available - now it's using Quicksort


		Lexikos recently released an update for AK v2 which good me into the mood to play around with AHK v2 a bit.
		One thing I see a lot in other languages is a sort function that looks and works similar to this:
		Code: Select all - Toggle Line numbers

		Arr.sort( compareFunction := defaultSortFunction )
		Sort( arr, compareFunction := defaultSortFunction )
		The function accepts 2 parameters. First is the array whose data should be sorted. Second is a function that compares 1 of the arrays values to the other and returns that value.
		We do have a sort function in AHK. But we do not talk about this one.
		Anyways with this I have started to replicate this function:

*/

/* written by nnnik
	https://autohotkey.com/boards/viewtopic.php?f=6&t=46260
	v1.0.0
	Changelog:
	v0.1.0 Implemented an example using insertion sort
	v1.0.0 It now uses quick sort
*/


sort( arr, compareFn := "" ) {
	if !compareFn
		compareFn := func( "standardCompare" )
	layer := 0
	quickSort( arr.MinIndex(), arr.MaxIndex() )
	return arr

	quickSort( firstIndex, lastIndex ) {

		if lastIndex-firstIndex < 100
			return insertSort( firstIndex, lastIndex )

		leftIndex  := firstIndex
		rightIndex := lastIndex
		pivotIndex := floor( ( rightIndex - leftIndex ) / 2 ) + leftIndex
		pivotValue := arr[ pivotIndex ]

		if layer > 15
			Msgbox leftIndex "`n" pivotIndex "`n" rightIndex

		Loop {
			While( leftIndex < pivotIndex && cmp := compareFn.Call( arr[ leftIndex ], pivotValue ) <= 0 )
				leftIndex++
			if ( pivotIndex <= leftIndex ) {
				pivotIndex := leftIndex
				break
			}
			While( rightIndex > pivotIndex && compareFn.Call( arr[ rightIndex ], pivotValue ) >= 0 )
				rightIndex--
			if ( pivotIndex >= rightIndex ) {
				pivotIndex := rightIndex
				break
			}
			swap( leftIndex, rightIndex )
			leftIndex++
			rightIndex--
		}

		if ( leftIndex = pivotIndex ) {
			if ( rightIndex > pivotIndex ) {
				while ( rightIndex > pivotIndex ) {
					if ( compareFn.Call( arr[ rightIndex ], pivotValue ) < 0 ) {
						move( rightindex, pivotIndex ), pivotIndex++
					} else
						rightIndex--
				}
			}
		}
		else if ( rightIndex = pivotIndex ) {
			while ( leftIndex < pivotIndex ) {
				if ( compareFn.Call( arr[ leftIndex ], pivotValue ) > 0 ) {
					move( leftIndex, pivotIndex ), pivotIndex--
				} else
					leftIndex++
			}
		}

		quickSort( firstIndex, pivotIndex - 1 )
		quickSort( pivotIndex + 1, lastIndex )
	}

	insertSort( firstIndex, lastIndex ) {
		Loop lastIndex - firstIndex {
			currentIndex := firstIndex + A_Index
			currentValue := arr[ currentIndex ]
			Loop {
				currentCompareIndex := currentIndex - A_Index
			}Until currentCompareIndex < firstIndex || compareFn.Call( currentValue, arr[currentCompareIndex] ) >= 0
			move( currentIndex, currentCompareIndex + 1 )
		}
	}

	standardCompare( compareVal1, compareVal2 ) {
		if ( compareVal1 = compareVal2 )
			return 0
		minStrLen := min( compareLen1 := StrLen( compareVal1 ), StrLen( compareVal2 ) )
		Loop minStrLen {
			compareChr1 := ord( subStr( compareVal1, A_Index, 1 ) )
			compareChr2 := ord( subStr( compareVal2, A_Index, 1 ) )
			if ( compareChr1 != compareChr2 )
				return compareChr1 - compareChr2
		}
		return ( ( compareLen1 = minStrLen ) && -1 )
	}

	swap( index1, index2 ) {
		temp := arr[ index1 ]
		arr[ index1 ] := arr[ index2 ]
		arr[ index2 ] := temp
	}

	move( srcIndex, targetIndex ) {
		if srcIndex != targetIndex
			arr.insertAt( targetIndex, arr.RemoveAt( srcIndex ) )
	}
}