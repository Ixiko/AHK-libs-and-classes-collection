/*
    Convertir radian a grado sexagesimal/centesimal.
*/
RadianToDegree(Radians, Centesimal := FALSE)
{
    If (Centesimal)
        Return (Radians*63.6619772368)  ;200/pi | 200/3.14159265359 = 63.6619772368

    Return (Radians*57.2957795131)      ;180/pi | 180/3.14159265359 = 57.2957795131
}
