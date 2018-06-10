; A modified bubble search
; This is slow, but very useful.
; If called in the correct sequence, you can completely order 
; a 2 dimensional array by as many keys as you want (and in any order)!
; i.e. some keys can be ascending, while others can be descending 

; to achieve this, simply call the function multiple times
; beginning with the lowest priority key, and ending with the highest priority key 

; Note: Bubble sorts become increasingly slower as the number of items increase 

bubbleSort2DArray(Byref a, key, ascending := True) 
{
    aStorage := []
    unsorted := True 
    While unsorted 		                        
	{           					            
        unsorted := False                      
        For index, in a  		 
		{
            if (lastIndex = index)          ; This speeds it up (almost halves the time)
                break                  
            if (A_Index > 1) &&  (ascending 
                                    ? (a[prevIndex, key] > a[index, key]) 
                                    : (a[prevIndex, key] < a[index, key])) 
			{       
                ; making this a single line expression saves ~20 ms on a 1000 index array
                aStorage := a[index]
                , a[index] := a[prevIndex]
                , a[prevIndex] := aStorage
                , unsorted := True			
            }         
            prevIndex := index
        }  
        lastIndex := prevIndex ; previous maxIndex reached (i.e. position of the last moved highest/lowest number)
        ; on each pass through the current highest number will be moved to 1 spot before 'lastIndex'
        ; i.e. towards the right
        ; As we know these values at the end are already the sorted
        ; we can break, and don't have to worry about comparing them again
    }
}

