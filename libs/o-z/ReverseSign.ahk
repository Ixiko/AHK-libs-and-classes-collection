ReverseSign(value)
{
    If (value = 0)
    {
        Return, value
    }

    If (value > 0)
    {
        result := value - value * 2
    }
    Else
    {
        result := Abs(value)
    }

    Return, result
}