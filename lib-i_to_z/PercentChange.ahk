/*
    Cuantifica el cambio de un número a otro y expresa el cambio como un aumento o disminución.
    Por ejemplo, la diferencia entre 1000 y 500 es -50%, debido a que se redujo en un 50%.
    Parámetros:
        Number1: El primer valor.
        Number2: El segundo valor con el que se va a comparar Number1.
*/
PercentChange(Number1, Number2)
{
    Return (Abs(Number1) < Abs(Number2) ? Abs((((Abs(Number1) - Abs(Number2)) / Abs(Number2)) * 100.0)) : (((Abs(Number2) - Abs(Number1)) / Abs(Number1)) * 100.0) )
} ;http://www.calculatorsoup.com/calculators/algebra/percent-change-calculator.php
