#include TextRender.ahk
#MaxThreads 10
SetBatchLines -1

button1 := TextRender("Width", {y:"42vh", r:5, c:"DeepSkyBlue"})
button2 := TextRender("Height", {x:"42vw", r:5, c:"DarkOrange"})
button3 := TextRender("Exit", {x:"90vw", y:"90vh", r:5, c:"Red"})
button4 := TextRender("Reload", {x:"83vw", y:"90vh", r:5, c:"Gold"})

button1.OnEvent("LeftMouseDown", Func("start_width"))
button2.OnEvent("LeftMouseDown", Func("start_height"))
button3.OnEvent("LeftMouseDown", Func("ExitApp"))
button4.OnEvent("LeftMouseDown", Func("Reload"))

ExitApp() {
   ExitApp
}

Reload() {
   Reload
}

start_width(this) {
   dpi := DllCall("SetThreadDpiAwarenessContext", "ptr", -4, "ptr")
   sx := DllCall("GetSystemMetrics", "int", 76, "int")
   sy := DllCall("GetSystemMetrics", "int", 77, "int")
   sw := DllCall("GetSystemMetrics", "int", 78, "int")
   sh := DllCall("GetSystemMetrics", "int", 79, "int")
   DllCall("SetThreadDpiAwarenessContext", "ptr", dpi, "ptr")

   x := sx
   tr := TextRender()

   DllCall("QueryPerformanceFrequency", "int64*", frequency:=0)
   DllCall("QueryPerformanceCounter", "int64*", start:=0)
   while (x < sx + sw) {
      tr.render(f := A_Index, {a:2, x:x, m:0, y:"Top"}, "s:108")
      x++
   }
   DllCall("QueryPerformanceCounter", "int64*", end:=0)

   fps := (end - start) / frequency
   fps := f / fps

   TextRender(fps " fps", "t:3000 y:25vh c:RoyalBlue")
}

start_height(this) {
   dpi := DllCall("SetThreadDpiAwarenessContext", "ptr", -4, "ptr")
   sx := DllCall("GetSystemMetrics", "int", 76, "int")
   sy := DllCall("GetSystemMetrics", "int", 77, "int")
   sw := DllCall("GetSystemMetrics", "int", 78, "int")
   sh := DllCall("GetSystemMetrics", "int", 79, "int")
   DllCall("SetThreadDpiAwarenessContext", "ptr", dpi, "ptr")

   y := sy
   tr := TextRender()

   DllCall("QueryPerformanceFrequency", "int64*", frequency:=0)
   DllCall("QueryPerformanceCounter", "int64*", start:=0)
   while (y < sy + sh) {
      tr.render(f := A_Index, {a:4, x:"left", m:0, y:y}, "s:108")
      y++
   }
   DllCall("QueryPerformanceCounter", "int64*", end:=0)

   fps := (end - start) / frequency
   fps := f / fps

   TextRender(fps " fps", "t:3000 x:25vw c:RoyalBlue")
}

Esc:: ExitApp
