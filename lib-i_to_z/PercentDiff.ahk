/*
    Determina la diferencia porcentual entre dos números.
    La diferencia porcentual se calcula generalmente cuando se desea conocer la diferencia en el porcentaje entre dos números.
*/
PercentDiff(Number1, Number2)
{
    Local SN1 := InStr(Number1, '-')
        , SN2 := InStr(Number2, '-')

    If (SN1 && !SN2)
    {
        Number1 := Abs(Number1)
        Number2 += Number1
    }

    If (!SN1 && SN2)
    {
        Number2 := Abs(Number2)
        Number1 += Number2
    }
    
    Return (Abs(Number1 - Number2) * 100.0 / ((Number1 + Number2) / 2.0))
} ;http://www.calculatorsoup.com/calculators/algebra/percent-difference-calculator.php
