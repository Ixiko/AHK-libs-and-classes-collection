; Include the ConvexHull Library
#include ConvexHull.ahk

; Create a C# PointsList object to allow us to pass the data to C#
pl := ConvexHull.CreatePointsList()

; Add some points to the C# PointsList object
pl.Add(9, 1)
pl.Add(4, 3)
pl.Add(4, 5)
pl.Add(3, 2)
pl.Add(14, 2)
pl.Add(4, 12)
pl.Add(4, 10)
pl.Add(5, 6)
pl.Add(10, 2)
pl.Add(1, 2)
pl.Add(1, 10)
pl.Add(5, 2)
pl.Add(11, 2)
pl.Add(4, 11)
pl.Add(12, 4)
pl.Add(3, 1)
pl.Add(2, 6)
pl.Add(2, 4)
pl.Add(7, 8)
pl.Add(5, 5)

; Create a string for outputting the returned data
str := ""

; ================= Graham Scan Demo =======================
; Create C# class to do the computation for us
GrahamScanner := ConvexHull.CreateGrahamScanner()

; Get the result from the C# code
result := GrahamScanner.ConvexHull(pl.Points)

; .NET List<Point> is not easy to use from AHK, so wrap it in a helper class to make it behave like a normal AHK array
result := ConvexHull.CreateListWrapper(result)

; Append returned data to string
str .= "Graham Scan results:`n"
; Iterate through each returned point, and add it to the string
for k, v in result {
	str .= v.X ", " v.Y "`n"
}

str .= "`n`n==============================`n`n"

; ================= Jarvis March Demo =======================

; Create C# class to do the computation for us
JarvisMarcher := ConvexHull.CreateJarvisMarcher()

; Get the result from the C# code
result := JarvisMarcher.ConvexHull(pl.Points)

; .NET List<Point> is not easy to use from AHK, so wrap it in a helper class to make it behave like a normal AHK array
result := ConvexHull.CreateListWrapper(result)

; Append returned data to string
str .= "Jarvis March results:`n"
; Iterate through each returned point, and add it to the string
for k, v in result {
	str .= v.X ", " v.Y "`n"
}

; Show the result
msgbox % str
