; https://autohotkey.com/board/topic/77352-class-binaryheap/
; https://gist.github.com/Uberi/6459092

#NoEnv

/*
Basic example:

    Heap := new BinaryHeap
    For Index, Value In [10,17,20,30,38,30,24,34]
        Heap.Add(Value)
    MsgBox % Heap.Peek()
    Loop, 8
        MsgBox % Heap.Pop()

You can use a custom comparison function to modify the behavior of the heap. For example, the class implements a min-heap by default, but it can become a max-heap by extending the class and overriding Compare():

    Heap := new MaxHeap
    
    class MaxHeap extends Heap
    {
        Compare(Value1,Value2)
        {
            Return, Value1 > Value2
        }
    }

Or work with objects:

    Heap := ObjectHeap
    
    class ObjectHeap extends Heap
    {
        Compare(Value1,Value2)
        {
            Return, Value1.SomeKey < Value2.SomeKey
        }
    }
*/

class BinaryHeap
{
    __New()
    {
        this.Data := []
    }

    Add(Value)
    {
        Index := this.Data.MaxIndex(), Index := Index ? (Index + 1) : 1

        ;append value to heap array
        this.Data[Index] := Value

        ;rearrange the array to satisfy the minimum heap property
        ParentIndex := Index >> 1
        While, Index > 1 && this.Compare(this.Data[Index],this.Data[ParentIndex]) ;child entry is less than its parent
        {
            ;swap the two elements so that the child entry is greater than its parent
            Temp1 := this.Data[ParentIndex]
            this.Data[ParentIndex] := this.Data[Index]
            this.Data[Index] := Temp1

            ;move to the parent entry
            Index := ParentIndex, ParentIndex >>= 1
        }
    }

    Peek()
    {
        If !this.Data.MaxIndex()
            throw Exception("Cannot obtain minimum entry from empty heap.",-1)
        Return, this.Data[1]
    }

    Pop()
    {
        MaxIndex := this.Data.MaxIndex()
        If !MaxIndex ;no entries in the heap
            throw Exception("Cannot pop minimum entry off of empty heap.",-1)

        Minimum := this.Data[1] ;obtain the minimum value in the heap

        ;move the last entry in the heap to the beginning
        this.Data[1] := this.Data[MaxIndex]
        this.Data.Remove(MaxIndex), MaxIndex --

        ;rearrange array to satisfy the heap property
        Index := 1, ChildIndex := 2
        While, ChildIndex <= MaxIndex
        {
            ;obtain the index of the lower of the two child nodes if there are two of them
            If (ChildIndex < MaxIndex && this.Compare(this.Data[ChildIndex + 1],this.Data[ChildIndex]))
                ChildIndex ++

            ;stop updating if the parent is less than or equal to the child
            If this.Compare(this.Data[Index],this.Data[ChildIndex])
                Break

            ;swap the two elements so that the child entry is greater than the parent
            Temp1 := this.Data[Index]
            this.Data[Index] := this.Data[ChildIndex]
            this.Data[ChildIndex] := Temp1

            ;move to the child entry
            Index := ChildIndex, ChildIndex <<= 1
        }

        Return, Minimum
    }

    Count()
    {
        Value := this.Data.MaxIndex()
        Return, Value ? Value : 0
    }

    Compare(Value1,Value2)
    {
        Return, Value1 < Value2
    }
}