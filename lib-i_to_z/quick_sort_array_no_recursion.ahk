;~ MyObj:=Main()
;~ ExitApp

;~ Main(){
	;~ Test:={}
	;~ Test[1]:={}

	;~ Loop, 100000
		;~ {
		;~ Random, Rnd, 0x00, 0xFF
		;~ Test[1,A_Index,"R"]:=Rnd, Test[1,A_Index,"G"]:=Rnd, Test[1,A_Index,"B"]:=Rnd, Test[1,A_Index,"A"]:=Rnd
		;~ }
	;~ q_sort(Test[1],"G")
	;~ Return Test
;~ }

;;;;;	Quick Sort Without Recursion	;;;;;
;;;;;	https://www.codeproject.com/Articles/29467/Quick-Sort-Without-Recursion	;;;;;
;;;;;	(c) The Code Project Open License (CPOL)	;;;;;
;;;;;	https://www.codeproject.com/info/cpol10.aspx	;;;;;
q_sort(ByRef input,Dim){
	stack:={}, stack.SetCapacity(500)
	pivot:=0
	pivotIndex:=1
	leftIndex:=pivotIndex+1
	rightIndex:=input.Length()

	stack.Push(pivotIndex) ;Push always with left and right
	stack.Push(rightIndex)

	leftIndexOfSubSet:=rightIndexOfSubset:=0

	While (stack.Length()>0)
		{
		rightIndexOfSubset:=stack.Pop() ;pop always with right and left
		leftIndexOfSubSet:=stack.Pop()

		leftIndex:=leftIndexOfSubSet+1
		pivotIndex:=leftIndexOfSubSet
		rightIndex:=rightIndexOfSubset

		pivot:=input[pivotIndex,Dim]

		If (leftIndex>rightIndex)
			Continue

		While (leftIndex<rightIndex)
			{
			While ((leftIndex<=rightIndex)&&(input[leftIndex,Dim]<=pivot))
				leftIndex++	;increment right to find the greater element than the pivot

			While ((leftIndex<=rightIndex)&&(input[rightIndex,Dim]>=pivot))
				rightIndex-- ;decrement right to find the smaller element than the pivot

			If (rightIndex>=leftIndex)   ;if right index is greater then only swap
				SwapElement(input,leftIndex,rightIndex)
			}
		If (pivotIndex<=rightIndex)
			If (input[pivotIndex,Dim]>input[rightIndex,Dim])
				SwapElement(input,pivotIndex,rightIndex)
	   
		If (leftIndexOfSubSet<rightIndex)
			{
			stack.Push(leftIndexOfSubSet)
			stack.Push(rightIndex-1)
			}

		If (rightIndexOfSubset>rightIndex)
			{
			stack.Push(rightIndex+1)
			stack.Push(rightIndexOfSubset)
			}
		}
	Return input
}

SwapElement(ByRef arr,left,right){
	temp:=arr[left]
	arr[left]:=arr[right]
	arr[right]:=temp
}