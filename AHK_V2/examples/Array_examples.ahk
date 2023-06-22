#include ..\Lib\Misc.ahk
#include ..\Lib\Array.ahk

Print([4,3,5,1,2].Sort(), MsgBox)
Print(["a", 2, 1.2, 1.22, 1.20].Sort("C")) ; Default is numeric sort, so specify case-sensitivity if the array contains strings.

myImmovables:=[]
myImmovables.push({town: "New York", size: "60", price: 400000, balcony: 1})
myImmovables.push({town: "Berlin", size: "45", price: 230000, balcony: 1})
myImmovables.push({town: "Moscow", size: "80", price: 350000, balcony: 0})
myImmovables.push({town: "Tokyo", size: "90", price: 600000, balcony: 2})
myImmovables.push({town: "Palma de Mallorca", size: "250", price: 1100000, balcony: 3})
Print(myImmovables.Sort("N R", "size")) ; Sort by the key 'size', treating the values as numbers, and sorting in reverse

Print(["dog", "cat", "mouse"].Map((v) => "a " v))

partial := [1,2,3,4,5].Map((a,b) => a+b)
Print("Array: [1,2,3,4,5]`n`nAdd 3 to first element: " partial[1](3) "`nSubtract 1 from third element: " partial[3](-1))

Print("Filter integer values from [1,'two','three',4,5]: " ([1,'two','three',4,5].Filter(IsInteger).Join()))

Print("Sum of elements in [1,2,3,4,5]: " ([1,2,3,4,5].Reduce((a,b) => (a+b))))

Print("First value in [1,2,3,4,5] that is an even number: " ([1,2,3,4,5].Find((v) => (Mod(v,2) == 0))))