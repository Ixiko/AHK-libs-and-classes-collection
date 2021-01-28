/*
Levenshtein Distance
Source Wikipedia.com
https://en.wikipedia.org/wiki/Levenshtein_distance
Originally written in C translated into AutoHotkey
https://autohotkey.com/boards/viewtopic.php?t=39112
*/

LDistance(s, t)
{ 
    ; degenerate cases
    if (StrLen( s ) = 0) 
		return StrLen( t )
	if ( StrLen( t ) = 0) 
		return StrLen( s )
	s := StrSplit( s )
	t := StrSplit( t )
    v0 := []
    Loop % t.Length() + 1
        v0[ A_Index ] := A_Index - 1
	v3 := [v0]
    Loop % s.Length()
    {
        ; calculate v1 (current row distances) from the previous row v0
		i := A_Index
		v1 := [i]
        ; use formula to fill in the rest of the row
        Loop % t.Length()
		{
			cost := !( s[ i ] == t[ A_Index ] )
			v1[ A_Index + 1 ] := _lMin( v1[ A_Index ] + 1
			, v0[ A_Index + 1 ] + 1
			, v0[ A_Index ] + cost )
		}
		v3.Push( v0 )
		v0 := v1
    }

    return v1[ t.Length() +1 ]
}

/*
Damerau-Levenshtein Distance
Source Wikipedia.com
https://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance
Originally written in Python translated into AutoHotkey
Thx to Helgef for correcting it.
*/

DLDistance( a, b )
{
    da := {}
    d := []
	a := StrSplit( a )
	b := StrSplit( b )
    maxdist := a.Length() + b.Length()
    d[-1, -1] := maxdist
    Loop % a.Length() + 1
	{
        i := A_Index - 1
		d[i, -1] := maxdist
        d[i, 0] := i
    }
	Loop % b.Length() + 1
	{
		j := A_Index - 1
		d[-1, j] := maxdist
        d[0, j] := j
	}
    Loop % a.Length()
	{
        db := 0
		i := A_Index
        Loop % b.Length()
		{
            j := A_Index
			k :=  da.HasKey(b[j]) ?  da[b[j]] : da[b[j]] := 0
            l := db
            if !( cost := !(a[i] == b[j]) )
				db := j
            d[i, j] := _lmin( d[i-1, j-1] + cost, d[i,   j-1] + 1, d[i-1, j  ] + 1, d[k-1, l-1] + (i-k-1) + 1 + (j-l-1 ) ) 
		}
        da[a[i]] := i
	}
    return d[a.Length(), b.Length()] ;I cant understand why but it always reports 1 more than it should. Since I'm a fan of easy solutions I just subtract 1 here
}

_lMin( p* )
{
	Ret := p.Pop()
	For each,Val in p
		if ( Val < Ret )
		{
			Ret := Val
		}
	return Ret
}