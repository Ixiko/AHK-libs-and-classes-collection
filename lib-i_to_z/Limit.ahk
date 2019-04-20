/*
    Limita un número a un cierto rango.
*/
Limit(Value, Min := "", Max := "")
{
    Return (!(Min == "" || Max == "") ? (Value < Min ? Min : Value > Max ? Max : Value) : (Min =="") ? (Value > Max ? Max : Value) : (Value < Min ? Min : Value))
}
