;******************************************************
;PolyRoots(A)
;Finds all real and complex roots of all polynomials
;------------------------------------------------------
;
;@A      Comma-deliminated coefficients starting with highest power
;
;Out     Comma-deliminated roots of the polynomials
;******************************************************

PolyRoots(A) {
	Loop Parse, A, `,
		n := A_Index-1

	of := false
	if Mod(n,2)=1 ; odd power, make even to avoid divergence
	{
		A .= ",0"
		n += 1
		of := true
	}
   
	Loop Parse, A, `,
	{
		i := A_Index-1
		If i = 0
			an := A_loopfield
		re%i% := im%i% := b%i% := d%i% := 0.0
		a%A_Index% := A_loopfield / an
	}
	a0 := 0.0,  b1 := d1 := 1.0,  b2 := a2 ; for degree 1 poly

	order := n,  n1 := n+1,  n2 := n+2

	tol := 1.e-10, LIMIT := 500
	q1 := q2 := r1 := r2 := r3 := 0.0
	i := j := k := cnt := 0         ; cnt = root counter

	While n > 1 {                   ; The main Lin-Bairstow loop
		p1 := q1 := -0.7            ; p(x) = x^2 + p1*x + q1
	Try:
		Loop %LIMIT% {
		i := 2, j := 1, k := 0
		Loop %n%  {
			b%i% := a%i% - p1 * b%j% - q1 * b%k%
			d%i% := b%i% - p1 * d%j% - q1 * d%k%
			i++, j++, k++
		}
		j  := n-1,  k := n-2
		r1 := d%j%**2 - (d%n% - b%n%) * d%k%
		If abs(r1) < 1.e-99
			break
		p2 := (b%n% * d%j% - b%n1% * d%k%) / r1
		q2 := (b%n1% * d%j% - (d%n% - b%n%) * b%n%) / r1
		p1 := p1 + p2
		q1 := q1 + q2

		If (Abs(p2) < tol && Abs(q2) < tol)
			GoTo Cont              ; Converged!
	}
	Random p1, -0.8, -0.6
	Random q1, -0.8, -0.6
	GoTo Try                    ; If not converged, random re-try

	Cont:
	r1 := p1*p1 - 4*q1           ; Continue with recording the found roots
	t := cnt + 1

	If (r1 < 0) {                ; imaginary roots
		re%t% := re%cnt% :=-p1/2
		im%t% :=-im%cnt% := sqrt(Abs(r1))/2
	}
	Else {                       ; real roots
		r2 := sqrt(r1)
		re%cnt% := (r2 - p1) / 2
		re%t%  := -(r2 + p1) / 2
		im%t% :=im%cnt% := 0
	}

	cnt += 2                     ; update root counter
	n -= 2, n1 -= 2, n2 -= 2     ; reduce polynomial order

	If (n > 1)
		Loop %n2%                 ; coefficients of the new polynomial
			a%A_Index% := b%A_Index%
	}

	if (n = 1)                      ; obtain last single real root
		re%cnt% := -b2, im%cnt% := 0

	Loop %order%                    ; assemble result
	{
		i := A_index-1, r := round(re%i%,9), j := round(im%i%,9)
		if (of && r < tol && j < tol)
			of := false
		else
			x .= r (j<0 ? "" : "+") j "i" (A_Index < order ? "," : "")
			
	}

   Return x
}