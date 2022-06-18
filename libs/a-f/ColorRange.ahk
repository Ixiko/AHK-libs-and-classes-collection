
ColorRange(c1,c2){ ; Create a list of colors between two https://www.autohotkey.com/boards/viewtopic.php?t=29205
  Color2 := {RGB:c2
  ,R:((c2 >> 16) & 0xFF)
  ,G:((c2 >> 8) & 0xFF)
  ,B:((c2 >> 0) & 0xFF)}

  Color1 := {RGB:c1
  ,R:((c1 >> 16) & 0xFF)
  ,G:((c1 >> 8) & 0xFF)
  ,B:((c1 >> 0) & 0xFF)}
  ColorList := []
  If !IsObject(Color1) || !IsObject(Color2)
    MsgBox % "Color objects are not initialized: One-" IsObject(Color1) " - " c1 " Two-" IsObject(Color2) " - " c2
  ;-----------------------------------
  ; color distance for each color individually
  ; this distance may be positive or negative
  ;-----------------------------------
  Distance_R := Color2.R - Color1.R
  Distance_G := Color2.G - Color1.G
  Distance_B := Color2.B - Color1.B


  ;-----------------------------------
  ; MCD is maximum color distance
  ; MCD deals only with absolute values
  ;-----------------------------------
  MCD := max(Abs(Distance_R), Abs(Distance_G), Abs(Distance_B))

  ;-----------------------------------
  ; list all gradient colors between Color1 and Color2
  ;-----------------------------------
  ColorList.Push(Color1.RGB) ; start at Color1
  Loop, % MCD - 1
      ColorList.Push("0x" . Format("{:02X}", Color1.R + A_Index / MCD * Distance_R) . Format("{:02X}", Color1.G + A_Index / MCD * Distance_G) . Format("{:02X}", Color1.B + A_Index / MCD * Distance_B))
  ColorList.Push(Color2.RGB) ; stop at Color2
  Return ColorList
}
