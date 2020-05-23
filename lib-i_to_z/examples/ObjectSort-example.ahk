#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.

#include %A_ScriptDir%\..\Object sort.ahk
#include %A_ScriptDir%\..\string-object-file.ahk

MyArray:=["Dog", "Cat", "Mouse", "Snake", "Bird"]
MySortedArray:=ObjectSort(MyArray)

MsgBox % "List of animals: `n`n" strobj(MyArray) "`n`nAlphabetically sorted:`n`n" strobj(MySortedArray)

;Source of car list: https://www.globalcarsbrands.com/top-10-fastest-cars-in-the-world/
MyCarList:={}
MyCarList.push({name: "ZENVO ST 1", speedMPH: "233"})
MyCarList.push({name: "HENNESSEY VENOM GT", speedMPH: "270"})
MyCarList.push({name: "KOENIGSEGG AGERA R", speedMPH: "273"})
MyCarList.push({name: "ASTON MARTIN ONE-77", speedMPH: "220"})
MyCarList.push({name: "PAGANI HUAYRA", speedMPH: "230"})
MyCarList.push({name: "MCLAREN F1", speedMPH: "241"})
MyCarList.push({name: "BUGATTI VEYRON SUPER SPORT", speedMPH: "268"})
MyCarList.push({name: "KOENIGSEGG CCR", speedMPH: "242"})
MyCarList.push({name: "SSC ULTIMATE AERO", speedMPH: "256"})
MyCarList.push({name: "9FF GT9-R", speedMPH: "257"})

MySortedCarList:=ObjectSort(MyCarList, "speedMPH",,true)

MsgBox % "Fastest cars: `n`n" strobj(MyCarList) "`n`nSorted by speed:`n`n" strobj(MySortedCarList)

myImmovables:={}
myImmovables.push({town: "New York", size: "60", price: 400000, balcony: 1})
myImmovables.push({town: "Berlin", size: "45", price: 230000, balcony: 1})
myImmovables.push({town: "Moscow", size: "80", price: 350000, balcony: 0})
myImmovables.push({town: "Tokyo", size: "90", price: 600000, balcony: 2})
myImmovables.push({town: "Palma de Mallorca", size: "250", price: 1100000, balcony: 3})

MySortedImmovablesBySize:=ObjectSort(myImmovables, "size")
MySortedImmovablesByBalconyCount:=ObjectSort(myImmovables, "balcony",,true)
MySortedImmovablesPricePerSqM:=ObjectSort(myImmovables, ,"calcPricePerSqM")

calcPricePerSqM(Immovable)
{
	return Immovable.price / Immovable.size
}

MsgBox % "My immovables: `n`n" strobj(myImmovables)
MsgBox % "My immovables sorted by size: `n`n" strobj(MySortedImmovablesBySize)
MsgBox % "My immovables sorted by balcony count: `n`n" strobj(MySortedImmovablesByBalconyCount)
MsgBox % "My immovables sorted by price per square meter: `n`n" strobj(MySortedImmovablesPricePerSqM)