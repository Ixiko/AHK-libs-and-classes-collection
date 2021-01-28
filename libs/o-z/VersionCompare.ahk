/*
    Compara dos versiones para determina si es mayor, menor o igual a otra.
    Return:
        0 = version1 = version2.
        1 = version1 > version2.
        2 = version1 < version2.
*/
VersionCompare(version1, version2)
{
    Local vA := StrSplit(version1:=Trim(version1), '.')
        , vB := StrSplit(version2:=Trim(version2), '.')
    
    Loop (vA.MaxIndex() > vB.MaxIndex() ? vA.MaxIndex() : vB.MaxIndex())
    {
        If (vA.MaxIndex() < A_Index)
            vA[A_Index] := 0
        If (vB.MaxIndex() < A_Index)
            vB[A_Index] := 0
        If (vA[A_Index] > vB[A_Index])
            Return (1)
        If (vB[A_Index] > vA[A_Index])
            Return (2)
    }

    Return (0)
}
