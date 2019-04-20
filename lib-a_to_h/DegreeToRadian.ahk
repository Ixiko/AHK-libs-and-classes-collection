/*
    Convertir grado sexagesimal/centesimal a radian.
*/
DegreeToRadian(Degrees, Centesimal := FALSE)
{
    If (Centesimal)
        Return (Degrees*0.01570796326)  ;pi/200 | 3.14159265359/200 = 0.01570796326

    Return (Degrees*0.01745329251)      ;pi/180 | 3.14159265359/180 = 0.01745329251
}
