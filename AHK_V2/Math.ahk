; Source: https://autohotkey.com/board/topic/47325-isprime-check-if-number-is-prime/
; thanks to user entropic
IsPrime(n,k=2) { ; testing primality with trial divisors not multiple of 2,3,5, up to sqrt(n) 
   d := k+(k<7 ? 1+(k>2) : SubStr("6-----4---2-4---2-4---6-----2",Mod(k,30),1)) 
   Return n < 3 ? n>1 : Mod(n,k) ? (d*d <= n ? IsPrime(n,d) : 1) : 0 
}

; Source: https://autohotkey.com/board/topic/98131-isprime-optimized-yet/
; Thanks to use LinearSpoon
; ============================================
isPrime2(n)
{
  if n is not integer
    return false
  if n < 2
    return false
  if (n = leastFactor(n))
    return true
  return false
}

leastFactor(n)
{
  if (mod(n,2) = 0)
    return 2
  if (mod(n,3) = 0)
    return 3
  if (mod(n,5) = 0)
    return 5
  max := sqrt(n), i := 7
  while(i <= max)
  {
    if (mod(n,i) = 0)
      return i
    if (mod(n,i+4) = 0)
      return i+4
    if (mod(n,i+6) = 0)
      return i+6
    if (mod(n,i+10) = 0)
      return i+10
    if (mod(n,i+12) = 0)
      return i+12
    if (mod(n,i+16) = 0)
      return i+16
    if (mod(n,i+22) = 0)
      return i+22
    if (mod(n,i+24) = 0)
      return i+24
    i+=30
  }
  return n
}
; ============================================
; IsPrime2() - thanks to user LinearSpoon
; ============================================
