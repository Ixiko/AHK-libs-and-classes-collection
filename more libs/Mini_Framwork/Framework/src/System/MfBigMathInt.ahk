;{ License
/* This file is part of Mini-Framework For AutoHotkey.
 * 
 * Mini-Framework is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 2 of the License.
 * 
 * Mini-Framework is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with Mini-Framework.  If not, see <http://www.gnu.org/licenses/>.
 */
; End:License ;}
/*
********************************************
* Big Integer Library
* Created 2000, last modified 2009
* Leemon Baird
* www.leemon.com
*
*
* This code defines a bigInt library for arbitrary-precision integers.
* A bigInt is an array of integers storing the value in chunks of bpe bits, 
* little endian (buff[0] is the least significant word).
* Negative bigInts are stored two's complement.  Almost all the functions treat
* bigInts as nonnegative.  The few that view them as two's complement say so
* in their comments.  Some functions assume their parameters have at least one 
* leading zero element. Functions with an underscore at the end of the name put
* their answer into one of the arrays passed in, and have unpredictable behavior 
* in case of overflow, so the caller must make sure the arrays are big enough to 
* hold the answer.  But the average user should never have to call any of the 
* underscored functions.  Each important underscored function has a wrapper function 
* of the same name without the underscore that takes care of the details for you.  
* For each underscored function where a parameter is modified, that same variable 
* must not be used as another argument too.  So, you cannot square x by doing 
* multMod_(x,x,n).  You must use squareMod_(x,n) instead, or do y=Dup(x); multMod_(x,y,n).
* Or simply use the MultMod(x,x,n) function without the underscore, where
* such issues never arise, because non-underscored functions never change
* their parameters; they always allocate new memory for the answer that is returned.
*
* These functions are designed to avoid frequent dynamic memory allocation in the inner loop.
* For most functions, if it needs a BigInt as a local variable it will actually use
* a global, and will only allocate to it only when it's not the right size.  This ensures
* that when a function is called repeatedly with same-sized parameters, it only allocates
* memory on the first call.
*
* Note that for cryptographic purposes, the calls to Math.random() must 
* be replaced with calls to a better pseudorandom number generator.
*
* In the following, "bigInt" means a bigInt with at least one leading zero element,
* and "integer" means a nonnegative integer less than radix.  In some cases, integer 
* can be Negative.  Negative bigInts are 2s complement.
* 
* The following functions do not modify their inputs.
* Those returning a bigInt, string, or Array will dynamically allocate memory for that value.
* Those returning a boolean will return the integer 0 (false) or 1 (true).
* Those returning boolean or int will not allocate memory except possibly on the first 
* time they're called with a given parameter size.
* 
* bigInt  Add(x,y)               *return (x+y) for bigInts x and y.  
* bigInt  AddInt(x,n)            *return (x+n) where x is a bigInt and n is an integer.
* string  BigInt2str(x,base)     *return a string form of bigInt x in a given base, with 2 <= base <= 95
* int     BitSize(x)             *return how many bits long the bigInt x is, not counting leading zeros
* bigInt  Dup(x)                 *return a copy of bigInt x
* boolean Equals(x,y)            *is the bigInt x equal to the bigint y?
* boolean EqualsInt(x,y)         *is bigint x equal to integer y?
* bigInt  Expand(x,n)            *return a copy of x with at least n elements, adding leading zeros if needed
* Array   FindPrimes(n)          *return array of all primes less than integer n
* bigInt  GCD(x,y)               *return greatest common divisor of bigInts x and y (each with same number of elements).
* boolean Greater(x,y)           *is x>y?  (x and y are nonnegative bigInts)
* boolean GreaterShift(x,y,shift)*is (x <<(shift*bpe)) > y?
* bigInt  Int2bigInt(t,n,m)      *return a bigInt equal to integer t, with at least n bits and m array elements
* bigInt  InverseMod(x,n)        *return (x**(-1) Mod n) for bigInts x and n.  If no inverse exists, it returns null
* int     InverseModInt(x,n)     *return x**(-1) Mod n, for integers x and n.  Return 0 if there is no inverse
* boolean IsZero(x)              *is the bigInt x equal to zero?
* boolean MillerRabin(x,b)       *does one round of Miller-Rabin base integer b say that bigInt x is possibly prime? (b is bigInt, 1<b<x)
* boolean MillerRabinInt(x,b)    *does one round of Miller-Rabin base integer b say that bigInt x is possibly prime? (b is int,    1<b<x)
* bigInt  Mod(x,n)               *return a new bigInt equal to (x Mod n) for bigInts x and n.
* int     ModInt(x,n)            *return x Mod n for bigInt x and integer n.
* bigInt  Mult(x,y)              *return x*y for bigInts x and y. This is faster when y<x.
* bigInt  MultMod(x,y,n)         *return (x*y Mod n) for bigInts x,y,n.  For Greater speed, let y<x.
* boolean Negative(x)            *is bigInt x Negative?
* bigInt  PowMod(x,y,n)          *return (x**y Mod n) where x,y,n are bigInts and ** is exponentiation.  0**0=1. Faster for odd n.
* bigInt  RandBigInt(n,s)        *return an n-bit random BigInt (n>=1).  If s=1, then the most significant of those n bits is set to 1.
* bigInt  RandTruePrime(k)       *return a new, random, k-bit, true prime bigInt using Maurer's algorithm.
* bigInt  RandProbPrime(k)       *return a new, random, k-bit, probable prime bigInt (probability it's composite less than 2^-80).
* bigInt  Str2bigInt(s,b,n,m)    *return a bigInt for number represented in string s in base b with at least n bits and m array elements
* bigInt  Sub(x,y)               *return (x-y) for bigInts x and y.  Negative answers will be 2s complement
* bigInt  Trim(x,k)              *return a copy of x with exactly k leading zero elements
*
*
* The following functions each have a non-underscored version, which most users should call instead.
* These functions each write to a single parameter, and the caller is responsible for ensuring the array 
* passed in is large enough to hold the result. 
*
* void    addInt_(x,n)          *do x=x+n where x is a bigInt and n is an integer
* void    add_(x,y)             *do x=x+y for bigInts x and y
* void    copy_(x,y)            *do x=y on bigInts x and y
* void    copyInt_(x,n)         *do x=n on bigInt x and integer n
* void    GCD_(x,y)             *set x to the greatest common divisor of bigInts x and y, (y is destroyed).  (This never overflows its array).
* boolean inverseMod_(x,n)      *do x=x**(-1) Mod n, for bigInts x and n. Returns 1 (0) if inverse does (doesn't) exist
* void    mod_(x,n)             *do x=x Mod n for bigInts x and n. (This never overflows its array).
* void    mult_(x,y)            *do x=x*y for bigInts x and y.
* void    multMod_(x,y,n)       *do x=x*y  Mod n for bigInts x,y,n.
* void    powMod_(x,y,n)        *do x=x**y Mod n, where x,y,n are bigInts (n is odd) and ** is exponentiation.  0**0=1.
* void    randBigInt_(b,n,s)    *do b = an n-bit random BigInt. if s=1, then nth bit (most significant bit) is set to 1. n>=1.
* void    randTruePrime_(ans,k) *do ans = a random k-bit true random prime (not just probable prime) with 1 in the msb.
* void    sub_(x,y)             *do x=x-y for bigInts x and y. Negative answers will be 2s complement.
*
* The following functions do NOT have a non-underscored version. 
* They each write a bigInt result to one or more parameters.  The caller is responsible for
* ensuring the arrays passed in are large enough to hold the results. 
*
* void addShift_(x,y,ys)       *do x=x+(y<<(ys*bpe))
* void carry_(x)               *do carries and borrows so each element of the bigInt x fits in bpe bits.
* void divide_(x,y,q,r)        *divide x by y giving quotient q and remainder r
* int  divInt_(x,n)            *do x=floor(x/n) for bigInt x and integer n, and return the remainder. (This never overflows its array).
* int  eGCD_(x,y,d,a,b)        *sets a,b,d to positive bigInts such that d = GCD_(x,y) = a*x-b*y
* void halve_(x)               *do x=floor(|x|/2)*sgn(x) for bigInt x in 2's complement.  (This never overflows its array).
* void leftShift_(x,n)         *left shift bigInt x by n bits.  n<bpe.
* void linComb_(x,y,a,b)       *do x=a*x+b*y for bigInts x and y and integers a and b
* void linCombShift_(x,y,b,ys) *do x=x+b*(y<<(ys*bpe)) for bigInts x and y, and integers b and ys
* void mont_(x,y,n,np)         *Montgomery multiplication (see comments where the function is defined)
* void multInt_(x,n)           *do x=x*n where x is a bigInt and n is an integer.
* void rightShift_(x,n)        *right shift bigInt x by n bits.  0 <= n < bpe. (This never overflows its array).
* void squareMod_(x,n)         *do x=x*x  Mod n for bigInts x,n
* void subShift_(x,y,ys)       *do x=x-(y<<(ys*bpe)). Negative answers will be 2s complement.
*
* The following functions are based on algorithms from the _Handbook of Applied Cryptography_
*    powMod_()           = algorithm 14.94, Montgomery exponentiation
*    eGCD_,inverseMod_() = algorithm 14.61, Binary extended GCD_
*    GCD_()              = algorothm 14.57, Lehmer's algorithm
*    mont_()             = algorithm 14.36, Montgomery multiplication
*    divide_()           = algorithm 14.20  Multiple-precision division
*    squareMod_()        = algorithm 14.16  Multiple-precision squaring
*    randTruePrime_()    = algorithm  4.62, Maurer's algorithm
*    MillerRabin()       = algorithm  4.24, Miller-Rabin algorithm
*
* Profiling shows:
*     randTruePrime_() spends:
*         10% of its time in calls to powMod_()
*         85% of its time in calls to MillerRabin()
*     MillerRabin() spends:
*         99% of its time in calls to powMod_()   (always with a base of 2)
*     powMod_() spends:
*         94% of its time in calls to mont_()  (almost always with x==y)
*
* This suggests there are several ways to speed up this library slightly:
*     - convert powMod_ to use a Montgomery form of k-ary window (or maybe a Montgomery form of sliding window)
*         -- this should especially focus on being fast when raising 2 to a power Mod n
*     - convert randTruePrime_() to use a minimum r of 1/3 instead of 1/2 with the appropriate change to the test
*     - tune the parameters in randTruePrime_(), including c, m, and recLimit
*     - speed up the single loop in mont_() that takes 95% of the runtime, perhaps by reducing checking
*       within the loop when all the parameters are the same Count.
*
* There are several ideas that look like they wouldn't help much at all:
*     - replacing trial division in randTruePrime_() with a sieve (that speeds up something taking almost no time anyway)
*     - increase bpe from 15 to 30 (that would help if we had a 32*32->64 multiplier, but not with JavaScript's 32*32->32)
*     - speeding up mont_(x,y,n,np) when x==y by doing a non-modular, non-Montgomery square
*       followed by a Montgomery reduction.  The intermediate answer will be twice as long as x, so that
*       method would be slower.  This is unfortunate because the code currently spends almost all of its time
*       doing mont_(x,x,...), both for randTruePrime_() and powMod_().  A faster method for Montgomery squaring
*       would have a large impact on the speed of randTruePrime_() and powMod_().  HAC has a couple of poorly-worded
*       sentences that seem to imply it's faster to do a non-modular square followed by a single
*       Montgomery reduction, but that's obviously wrong.
********************************************
*/
class MfBigMathInt extends MfObject
{
;{ Globals
	static bpe := 15 ; bits stored per array element
	static mask := 32767 ; AND this with an array element to chop it down to bpe bits
	static radix := 32768 ; Equals 2^bpe.  A single 1 bit to the left of the last bit of mask.
	;{ digitStr
	static m_digitStr := ""
	static one := ""
	static m_Uint64Max := ""
	static m_Init := MfBigMathInt.StaticInit()
		/*!
			Property: digitStr [get]
				Gets the digitStr value associated with the this instance
			Value:
				Var representing the digitStr property of the instance
			Remarks:
				Readonly Property
		*/
		digitStr[]
		{
			get {
				if (MfBigMathInt.m_digitStr = "")
				{
					MfBigMathInt.m_digitStr := new MfBigMathInt.DigitsChars()
				}
				return MfBigMathInt.m_digitStr
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, "digitStr")
				Throw ex
			}
		}
		Uint64Max[]
		{
			get {
				if (MfBigMathInt.m_Uint64Max = "")
				{
					MfBigMathInt.m_Uint64Max := MfBigMathInt.Str2bigInt("18446744073709551615", 10, 3, 3)
				}
				return MfBigMathInt.m_Uint64Max
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, "Uint64Max")
				Throw ex
			}
		}
		StaticInit() {
			; MfBigMathInt.bpe := 0
			; While ((1 << (MfBigMathInt.bpe + 1)) > (1 << MfBigMathInt.bpe))
			; {
			; 	; bpe=number of bits in the mantissa on this platform
			; 	MfBigMathInt.bpe++ ; bpe=number of bits in one element of the array representing the bigInt
				
			; }
			; MfBigMathInt.bpe >>= 1
			; MfBigMathInt.mask := ( 1 << MfBigMathInt.bpe) - 1 ; AND the mask with an integer to get its bpe least significant bits
			; MfBigMathInt.radix := MfBigMathInt.mask + 1 ; 2^bpe.  a single 1 bit to the left of the first bit of mask

			MfBigMathInt.one := MfBigMathInt.Int2bigInt(1,1,1)
			
			return true
		}
	; End:digitStr ;}
	static t := new MfListVar(0)
	static ss 		:= MfBigMathInt.t 	; used in mult_()
	static s0 		:= MfBigMathInt.t 	; used in multMod_(), squareMod_() 
	static s1 		:= MfBigMathInt.t 	; used in powMod_(), multMod_(), squareMod_() 
	static s2 		:= MfBigMathInt.t 	; used in powMod_(), multMod_()
	static s3 		:= MfBigMathInt.t 	; used in powMod_()
	static s4 		:= MfBigMathInt.t 	; used in mod_()
	static s5 		:= MfBigMathInt.t 	; used in mod_()
	static s6 		:= MfBigMathInt.t 	; used in BigInt2str()
	static s7 		:= MfBigMathInt.t 	; used in powMod_()
	static tt 		:= MfBigMathInt.t 	; used in GCD_()
	static sa 		:= MfBigMathInt.t 	; used in mont_()
	static mr_x1 	:= MfBigMathInt.t 	; used in MillerRabin()
	static mr_r 	:= MfBigMathInt.t 	; used in MillerRabin()
	static mr_a 	:= MfBigMathInt.t 	; used in MillerRabin()
	static eg_v 	:= MfBigMathInt.t 	; used in eGCD_(), inverseMod_()
	static eg_u 	:= MfBigMathInt.t 	; used in eGCD_(), inverseMod_()
	static eg_A 	:= MfBigMathInt.t 	; used in eGCD_(), inverseMod_()
	static eg_B 	:= MfBigMathInt.t 	; used in eGCD_(), inverseMod_()
	static eg_C 	:= MfBigMathInt.t 	; used in eGCD_(), inverseMod_()
	static eg_D 	:= MfBigMathInt.t 	; used in eGCD_(), inverseMod_()
	static md_q1 	:= MfBigMathInt.t	; used in mod_()
	static md_q2 	:= MfBigMathInt.t	; used in mod_()
	static md_q3 	:= MfBigMathInt.t	; used in mod_()
	static md_r 	:= MfBigMathInt.t	; used in mod_()
	static md_r1 	:= MfBigMathInt.t	; used in mod_()
	static md_r2 	:= MfBigMathInt.t	; used in mod_()
	static md_tt 	:= MfBigMathInt.t 	; used in mod_()

	static primes 	:= MfBigMathInt.t
	static pows 	:= MfBigMathInt.t
	static s_i 		:= MfBigMathInt.t
	static s_i2 	:= MfBigMathInt.t
	static s_R 		:= MfBigMathInt.t
	static s_rm 	:= MfBigMathInt.t
	static s_q 		:= MfBigMathInt.t
	static s_n1 	:= MfBigMathInt.t 
	 
	; used in randTruePrime_()
	static s_a 		:= MfBigMathInt.t
	static s_r2 	:= MfBigMathInt.t
	static s_n 		:= MfBigMathInt.t
	static s_b 		:= MfBigMathInt.t
	static s_d 		:= MfBigMathInt.t
	static s_x1 	:= MfBigMathInt.t
	static s_x2 	:= MfBigMathInt.t
	static s_aa 	:= MfBigMathInt.t 
	  
	static rpprb 	:= MfBigMathInt.t 	; used in randProbPrimeRounds() (which also uses "primes")

; End:Globals ;}
;{ Methods
;{ 	FindPrimes
	;return array of all primes less than integer n
	FindPrimes(n) {
		
		lst := new MfListVar(n, 0)
		s := lst.m_InnerList

		i := 0
		p := 0
	
		s[1] := 2
		p := 0 ; first p elements of s are primes, the rest are a sieve
		p++ ; one base index
		while (s[p] < n) ; s.Item[p] is the pth prime
		{
			sp := s[p]
			i := sp * sp
			while (i <= n) 
			{
				; mark multiples of s.Item[p]
				s[i] := 1
				i += s[p]
			}
			p++
			s[p] := s[p - 1] + 1
			sp := s[p]
			while ((sp < n) && (s[sp]))
			{
				; find next prime (where s.Item[p] = 0)
				sp++
			}
			s[p] := sp
		}
		p-- ; zero based index
		ans := []
		i := 1 ; one based index
		while (i <= p)
		{
			ans[i] := s[i]
			i++
		}
		lst._SetInnerList(ans, true)
		return lst
	}
; 	End:FindPrimes ;}
;{ 	MillerRabinInt
	; does a single round of Miller-Rabin base b consider x to be a possible prime?
	; x is a bigInt, and b is an integer, with b<x
	MillerRabinInt(x, b) {
		if (MfBigMathInt.mr_x1.m_Count != x.m_Count)
		{
			MfBigMathInt.mr_x1 := MfBigMathInt.Dup(x)
			MfBigMathInt.mr_r := MfBigMathInt.Dup(x)
			MfBigMathInt.mr_a := MfBigMathInt.Dup(x)
		}

		MfBigMathInt.copyInt_(MfBigMathInt.mr_a, b)
		return MfBigMathInt.MillerRabin(x, MfBigMathInt.mr_a)
	}
; 	End:MillerRabinInt ;}
;{ 	MillerRabin
	; does a single round of Miller-Rabin base b consider x to be a possible prime?
	; x and b are bigInts with b<x
	MillerRabin(x, b) {
		i := 0, j := 0, k := 0 , s := 0

		if (MfBigMathInt.mr_x1.m_Count != x.m_Count)
		{
			MfBigMathInt.mr_x1 := MfBigMathInt.Dup(x)
			MfBigMathInt.mr_r := MfBigMathInt.Dup(x)
			MfBigMathInt.mr_a := MfBigMathInt.Dup(x)
		}

		MfBigMathInt.copy_(MfBigMathInt.mr_a, b)
		MfBigMathInt.copy_(MfBigMathInt.mr_r, x)
		MfBigMathInt.copy_(MfBigMathInt.mr_x1, x)

		MfBigMathInt.addInt_(MfBigMathInt.mr_r, -1)
		MfBigMathInt.addInt_(MfBigMathInt.mr_x1, -1)

		if (MfBigMathInt.IsZero(MfBigMathInt.mr_r))
		{
			return 0
		}

		k := 0
		k++ ; move for one based index
		while (MfBigMathInt.mr_r.m_InnerList[k] = 0)
		{
			k++
		}

		i := 1
		j := 2
		while (Mod(MfBigMathInt.mr_r.m_InnerList[k], j) = 0)
		{
			j *= 2
			i++
		}
		k-- ; return to zero based index
		s := (k * MfBigMathInt.bpe) + i - 1
		if (s != 0)
		{
			MfBigMathInt.rightShift_(MfBigMathInt.mr_r, s)
		}

		MfBigMathInt.powMod_(MfBigMathInt.mr_a, MfBigMathInt.mr_r, x)

		if (!MfBigMathInt.EqualsInt(MfBigMathInt.mr_a, 1) && !MfBigMathInt.Equals(MfBigMathInt.mr_a, MfBigMathInt.mr_x1))
		{
			j := 1
			while ((j <= s) && (!MfBigMathInt.Equals(MfBigMathInt.mr_a, MfBigMathInt.mr_x1)))
			{
				MfBigMathInt.squareMod_(MfBigMathInt.mr_a, x)
				if (MfBigMathInt.EqualsInt(MfBigMathInt.mr_a, 1))
				{
					return 0
				}
				j++
			}
			if (!MfBigMathInt.Equals(MfBigMathInt.mr_a, MfBigMathInt.mr_x1))
			{
				return 0
			}
		}
		return 1
	}
; 	End:MillerRabin ;}
;{ 	BitSize
	; returns how many bits long the bigInt is, not counting leading zeros.
	BitSize(x) {
		j := x.m_Count -1
		if (j = 0)
		{
			return 0
		}
		j++ ; move to one base index
		while ((j > 1) && (x.m_InnerList[j] = 0))
		{
			j--
		}
		z := 0
		w := x.m_InnerList[j]
		j-- ; move to zero base index
		While (w >= 1)
		{
			w >>= 1
			z++
		}
		z += MfBigMathInt.bpe * j
		return z
	}
; 	End:BitSize ;}
;{ 	Expand
	; return a copy of x with at least n elements, adding leading zeros if needed
	Expand(x, n) {
		ans := MfBigMathInt.Int2bigInt(0, (x.m_Count > n ? x.m_Count : n) * MfBigMathInt.bpe, 0)
		MfBigMathInt.copy_(ans, x)
		return ans
	}
; 	End:Expand ;}
;{ 	RandTruePrime
	; return a k-bit true random prime using Maurer's algorithm.
	RandTruePrime(k) {
		ans := MfBigMathInt.Int2bigInt(0, k, 0)
		MfBigMathInt.randTruePrime_(ans,k)
		return MfBigMathInt.Trim(ans, 1)
	}
; 	End:RandTruePrime ;}
;{ 	RandProbPrime
	; return a k-bit random probable prime with probability of error < 2^-80
	RandProbPrime(k) {
		if (k >= 600)
			return MfBigMathInt.randProbPrimeRounds(k, 2) ;numbers from HAC table 4.3
		if (k >= 550)
			return MfBigMathInt.randProbPrimeRounds(k, 4)
		if (k >= 500)
			return MfBigMathInt.randProbPrimeRounds(k, 5)
		if (k >= 400)
			return MfBigMathInt.randProbPrimeRounds(k, 6)
		if (k >= 350)
			return MfBigMathInt.randProbPrimeRounds(k, 7)
		if (k >= 300)
			return MfBigMathInt.randProbPrimeRounds(k, 9)
		if (k >= 250)
			return MfBigMathInt.randProbPrimeRounds(k, 12) ; numbers from HAC table 4.4
		if (k >= 200)
			return MfBigMathInt.randProbPrimeRounds(k, 15)
		if (k >= 150)
			return MfBigMathInt.randProbPrimeRounds(k, 18)
		if (k >= 100)
			return MfBigMathInt.randProbPrimeRounds(k, 27)

		return MfBigMathInt.randProbPrimeRounds(k, 40) ; number from HAC remark 4.26 (only an estimate)
	}
; 	End:RandProbPrime ;}
;{ 	randProbPrimeRounds
	; return a k-bit probable random prime using n rounds of Miller Rabin (after trial division with small primes)	
	RandProbPrimeRounds(k, n) {
		B := 30000 ; B is largest prime to use in trial division
		i := 0
		divisible := 0
		ans := MfBigMathInt.Int2bigInt(0, k, 0)
		ansl := ans.m_InnerList

		; optimization: try larger and smaller B to find the best limit.
		if (MfBigMathInt.primes.m_Count = 0)
		{
			MfBigMathInt.primes := MfBigMathInt.FindPrimes(30000)
		}
		if (MfBigMathInt.rpprb.m_Count != ans.m_Count)
		{
			MfBigMathInt.rpprb := MfBigMathInt.Dup(ans)
		}
		loop
		{
			; keep trying random values for ans until one appears to be prime
			; optimization: pick a random number times L=2*3*5*...*p, plus a 
			; random element of the list of all numbers in [0,L) not divisible by any prime up to p.
			; This can reduce the amount of random number generation.

			MfBigMathInt.randBigInt_(ans, k, 0) ; ans = a random odd number to check
			ansl[1] |= 1
			divisible := 0

			; check ans for divisibility by small primes up to B
			i := 1 ; one based index
			while ((i <= MfBigMathInt.primes.m_Count) && (MfBigMathInt.primes.m_InnerList[i] <= B))
			{
				if (MfBigMathInt.ModInt(ans, MfBigMathInt.primes.m_InnerList[i]) = 0 && !(MfBigMathInt.EqualsInt(ans, MfBigMathInt.primes.m_InnerList[i])))
				{
					divisible := 1
					break
				}
				i++
			}

			; optimization: change MillerRabin so the base can be bigger than the number being checked, then eliminate the while here.
			i :=  ; zero based index
			while ((i < n) && !divisible)
			{
				MfBigMathInt.randBigInt_(MfBigMathInt.rpprb, k, 0)
				while (!MfBigMathInt.Greater(ans, MfBigMathInt.rpprb)) ;pick a random rpprb that's < ans
				{
					MfBigMathInt.randBigInt_(MfBigMathInt.rpprb, k, 0)
				}
				if (!MfBigMathInt.MillerRabin(ans, MfBigMathInt.rpprb))
				{
					divisible := 1
				}
				i++
			}
			if (!divisible)
			{
				return ans
			}
		}
	}
; 	End:randProbPrimeRounds ;}
;{ 	Mod
	;return a new bigInt equal to (x Mod n) for bigInts x and n.
	Mod(x, n) {
		ans := MfBigMathInt.Dup(x)
		MfBigMathInt.mod_(ans, n)
		return MfBigMathInt.Trim(ans, 1)
	}
; 	End:Mod ;}
;{ 	AddInt
	; return (x+n) where x is a bigInt and n is an integer.
	AddInt(x, n) {
		ans := MfBigMathInt.Expand(x, x.m_Count + 1)
		MfBigMathInt.addInt_(ans, n)
		return MfBigMathInt.Trim(ans, 1)
	}
; 	End:AddInt ;}
;{ 	Mult
	; return x*y for bigInts x and y. This is faster when y<x.
	Mult(x, y) {
		ans := MfBigMathInt.Expand(x, x.m_Count + y.m_Count)
		MfBigMathInt.mult_(ans, y)
		return MfBigMathInt.Trim(ans, 1)
	}
; 	End:Mult ;}
;{ 	PowMod
	; return (x**y Mod n) where x,y,n are bigInts and ** is exponentiation.  0**0=1. Faster for odd n.
	PowMod(x, y, n) {
		ans := MfBigMathInt.Expand(x, n.m_Count)

		; this should work without the Trim, but doesn't
		MfBigMathInt.powMod_(ans, MfBigMathInt.Trim(y, 2), MfBigMathInt.Trim(n, 2), 0)
		return MfBigMathInt.Trim(ans, 1)
	}
; 	End:PowMod ;}
;{ 	Sub
	; return (x-y) for bigInts x and y.  Negative answers will be 2s complement
	Sub(x,y) {
		ans := MfBigMathInt.Expand(x, (x.m_Count > y.m_Count ? x.m_Count + 1 : y.m_Count + 1))
		MfBigMathInt.sub_(ans, y)
		return MfBigMathInt.Trim(ans, 1)
	}
; 	End:Sub ;}
;{ 	Add
	; return (x+y) for bigInts x and y.  
	Add(x,y) {
		ans := MfBigMathInt.Expand(x, (x.m_Count > y.m_Count ? x.m_Count + 1 : y.m_Count + 1))
		MfBigMathInt.add_(ans, y)
		return MfBigMathInt.Trim(ans, 1)
	}
; 	End:Add ;}
;{ 	InverseMod
	; return (x**(-1) Mod n) for bigInts x and n.  If no inverse exists, it returns null
	InverseMod(x,n) {
		 ans := MfBigMathInt.Expand(x, n.m_Count)
		 s := MfBigMathInt.inverseMod_(ans, n)
		 return s ? MfBigMathInt.Trim(ans, 1) : null
	}
; 	End:InverseMod ;}
;{ 	MultMod
	; return (x*y Mod n) for bigInts x,y,n.  For Greater speed, let y<x.
	 MultMod(x,y,n) {
	 	ans := MfBigMathInt.Expand(x, n.m_Count)
	 	MfBigMathInt.multMod_(ans,y,n)
	 	return MfBigMathInt.Trim(ans, 1)
	 }
; 	End:MultMod ;}
;{ 	randTruePrime_
	; generate a k-bit true random prime using Maurer's algorithm,
	; and put it into ans.  The bigInt ans must be large enough to hold it.
	RandTruePrime_(byref ans, k) {

		if (MfBigMathInt.primes.m_Count = 0)
		{
			MfBigMathInt.primes := MfBigMathInt.FindPrimes(30000) ; check for divisibility by primes <=30000
		}

		if (MfBigMathInt.pows.m_Count = 0)
		{
			wf := A_FormatFloat
			SetFormat, FloatFast, 0.16
			try
			{
				MfBigMathInt.pows := new MfListVar(512)
				j := 0
				while (j < 512)
				{
					tmp := ((j / 511.0) - 1.0) + 0.0
					tmpPow := 2 ** tmp
					MfBigMathInt.pows.m_InnerList[j + 1] := tmpPow
					j++
				}
			}
			catch e
			{
				throw e
			}
			finally
			{
				SetFormat, FloatFast, %wf%
			}
				
		}
		wf := A_FormatFloat
		try
		{
			SetFormat, FloatFast, 0.16
			;c and m should be tuned for a particular machine and value of k, to maximize speed
			c := 0.1 ; c=0.1 in HAC
			m := 20 ;generate this k-bit number by first recursively generating a number that has between k/2 and k-m bits 
			recLimit := 20 ;stop recursion when k <=recLimit.  Must have recLimit >= 2

			if (MfBigMathInt.s_i2.m_Count != ans.m_Count)
			{
				MfBigMathInt.s_i2 	:= MfBigMathInt.Dup(ans)
				MfBigMathInt.s_R 	:= MfBigMathInt.Dup(ans)
				MfBigMathInt.s_n1 	:= MfBigMathInt.Dup(ans)
				MfBigMathInt.s_r2 	:= MfBigMathInt.Dup(ans)
				MfBigMathInt.s_d 	:= MfBigMathInt.Dup(ans)
				MfBigMathInt.s_x1 	:= MfBigMathInt.Dup(ans)
				MfBigMathInt.s_x2 	:= MfBigMathInt.Dup(ans)
				MfBigMathInt.s_b 	:= MfBigMathInt.Dup(ans)
				MfBigMathInt.s_n 	:= MfBigMathInt.Dup(ans)
				MfBigMathInt.s_i 	:= MfBigMathInt.Dup(ans)
				MfBigMathInt.s_rm 	:= MfBigMathInt.Dup(ans)
				MfBigMathInt.s_q 	:= MfBigMathInt.Dup(ans)
				MfBigMathInt.s_a 	:= MfBigMathInt.Dup(ans)
				MfBigMathInt.s_aa 	:= MfBigMathInt.Dup(ans)
			}
			if (k <= recLimit)
			{
				; generate small random primes by trial division up to its square root
				pm := (1 << ((k + 2) >> 1)) - 1 ; pm is binary number with all ones, just over sqrt(2^k)
				MfBigMathInt.copyInt_(ans, 0)
				dd := 1
				while (dd)
				{
					dd := 0
					; random, k-bit, odd integer, with msb 1
					tmp := floor(MfBigMathInt.Random_() * (1 << k))
					ans.m_InnerList[1] := 1 | (1 << (k - 1)) | tmp
					j := 1
					jOne := j + 1
					while ((j < MfBigMathInt.primes.m_Count) && ((MfBigMathInt.primes.m_InnerList[jOne] & pm) = MfBigMathInt.primes.m_InnerList[jOne]))
					{
						; trial division by all primes 3...sqrt(2^k)
						if (0 = Mod(ans.m_InnerList[1], MfBigMathInt.primes.m_InnerList[jOne]))
						{
							dd := 1
							break
						}
						j++
						jOne++
					}
					MfBigMathInt.carry_(ans)
					return

				}
			}
			B := c * k * k ; try small primes up to B (or all the primes[] array if the largest is less than B).
			if (k > 2 * m) ; generate this k-bit number by first recursively generating a number that has between k/2 and k-m bits
			{
				r := 1
				while ((k - (k * r)) <= m)
				{
					tmp := floor(MfBigMathInt.Random_() * 512) + 1
					r := MfBigMathInt.pows.m_InnerList[tmp]
				}
			}
			else
			{
				r := 0.5
			}

			; simulation suggests the more complex algorithm using r=.333 is only slightly faster.
			recSize := floor(r * k) + 1
			MfBigMathInt.randTruePrime_(MfBigMathInt.s_q, recSize)
			MfBigMathInt.copyInt_(MfBigMathInt.s_i2, 0)
			MfBigMathInt.s_i2.m_InnerList[floor((k - 2) / MfBigMathInt.bpe) + 1] |= (Mod((1 << (k - 2)), MfBigMathInt.bpe)) ; s_i2=2^(k-2)
			MfBigMathInt.divide_(MfBigMathInt.s_i2, MfBigMathInt.s_q, MfBigMathInt.s_i, MfBigMathInt.s_rm) ; s_i=floor((2^(k-1))/(2q))
			z =: MfBigMathInt.BitSize(MfBigMathInt.s_i)
			loop
			{
				loop
				{
					MfBigMathInt.randBigInt_(MfBigMathInt.s_R, z, 0)
					if (MfBigMathInt.Greater(MfBigMathInt.s_i, MfBigMathInt.s_R))
					{
						break
					}
				}
				; now s_R is in the range [0,s_i-1]
				MfBigMathInt.addInt_(MfBigMathInt.s_R, 1) ; now s_R is in the range [1,s_i]
				MfBigMathInt.add_(MfBigMathInt.s_R, MfBigMathInt.s_i) ; now s_R is in the range [s_i+1,2*s_i]

				MfBigMathInt.copy_(MfBigMathInt.s_n, MfBigMathInt.s_q)
				MfBigMathInt.mult_(MfBigMathInt.s_n, MfBigMathInt.s_R)
				MfBigMathInt.multInt_(MfBigMathInt.s_n, 2)
				MfBigMathInt.addInt_(MfBigMathInt.s_n, 1) ; s_n=2*s_R*s_q+1

				MfBigMathInt.copy_(MfBigMathInt.s_r2, MfBigMathInt.s_R)
				MfBigMathInt.multInt_(MfBigMathInt.s_r2, 2) ; s_r2=2*s_R

				; check s_n for divisibility by small primes up to B
				divisible := 0
				j := 1 ; one based index
				while ((j <= MfBigMathInt.primes.m_Count) && (MfBigMathInt.primes.m_InnerList[j] < B))
				{
					if ((MfBigMathInt.ModInt(MfBigMathInt.s_n, MfBigMathInt.primes.m_InnerList[j]) = 0)
						&& (!MfBigMathInt.EqualsInt(MfBigMathInt.s_n, MfBigMathInt.primes.m_InnerList[j])))
					{
						divisible := 1
						break
					}
				}

				if (!divisible) ; if it passes small primes check, then try a single Miller-Rabin base 2
				{
					if (!MfBigMathInt.MillerRabinInt(MfBigMathInt.s_n, 2)) ; this line represents 75% of the total runtime for randTruePrime_ 
					{
						divisible := 1
					}
				}
				if (!divisible)
				{
					MfBigMathInt.addInt_(MfBigMathInt.s_n, -3)
					j := MfBigMathInt.s_n.m_Count - 1
					while ((MfBigMathInt.s_n.m_InnerList[j + 1] = 0) && (j > 0))
					{
						j--
					}
					zz := 0
					w := MfBigMathInt.s_n.m_InnerList[j + 1]
					While (w)
					{
						w >>= 1
						zz++
					}
					zz += MfBigMathInt.bpe * j ; zz=number of bits in s_n, ignoring leading zeros
					loop
					{
						; generate z-bit numbers until one falls in the range [0,s_n-1]
						MfBigMathInt.randBigInt_(MfBigMathInt.s_a, zz, 0)
						if (MfBigMathInt.Greater(MfBigMathInt.s_n, MfBigMathInt.s_a))
						{
							break
						}
					}
					; now s_a is in the range [0,s_n-1]
					MfBigMathInt.addInt_(MfBigMathInt.s_n, 3) ; now s_a is in the range [0,s_n-4]
					MfBigMathInt.addInt_(MfBigMathInt.s_a, 2) ; now s_a is in the range [2,s_n-2]
					MfBigMathInt.copy_(MfBigMathInt.s_b, MfBigMathInt.s_a)
					MfBigMathInt.copy_(MfBigMathInt.s_n1, MfBigMathInt.s_n)
					MfBigMathInt.addInt_(MfBigMathInt.s_n1, -1)
					MfBigMathInt.powMod_(MfBigMathInt.s_b, MfBigMathInt.s_n1, MfBigMathInt.s_n) ; s_b=s_a^(s_n-1) modulo s_n
					MfBigMathInt.addInt_(MfBigMathInt.s_b, -1)
					if (MfBigMathInt.IsZero(MfBigMathInt.s_b))
					{
						MfBigMathInt.copy_(MfBigMathInt.s_b, MfBigMathInt.s_a)
						MfBigMathInt.powMod_(MfBigMathInt.s_b, MfBigMathInt.s_r2, MfBigMathInt.s_n)
						MfBigMathInt.addInt_(MfBigMathInt.s_b, -1)
						MfBigMathInt.copy_(MfBigMathInt.s_aa, MfBigMathInt.s_n)
						MfBigMathInt.copy_(MfBigMathInt.s_d, MfBigMathInt.s_b)
						MfBigMathInt.GCD_(MfBigMathInt.s_d, MfBigMathInt.s_n)
						if (MfBigMathInt.EqualsInt(MfBigMathInt.s_d, 1))
						{
							MfBigMathInt.copy_(ans, MfBigMathInt.s_aa)
							return
						}
					}
				}
			}
		}
		catch e
		{
			throw e
		}
		finally
		{
			SetFormat, FloatFast, %wf%
		}

	}
; 	End:randTruePrime_ ;}
;{ 	randBigInt_
	; Set b to an n-bit random BigInt.  If s=1, then the most significant of those n bits is set to 1.
	; Array b must be big enough to hold the result. Must have n>=1
	randBigInt_(byref b, n, s) {
		
		bl := b.m_InnerList
		i := 1
		while (i <= b.m_Count)
		{
			bl[i] := 0
			i++
		}
		wf := A_FormatFloat
		SetFormat, FloatFast, 0.16
		try
		{
			a := floor((n - 1) / MfBigMathInt.bpe) + 1
			i := 1
			while (i <= a)
			{
				bl[i] := floor(MfBigMathInt.Random_() * (1 << (MfBigMathInt.bpe -1)))
				i++
			}
			bl[a -2] &= (2 << (Mod((n -1), MfBigMathInt.bpe))) - 1
			if (s = 1)
			{
				bl[a - 2] |= (1 << (Mod((n-1), MfBigMathInt.bpe)))
			}
		}
		catch e
		{
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		finally
		{
			SetFormat, FloatFast, %wf%
		}
		b.m_InnerList := bl
			
	}
; 	End:randBigInt_ ;}
;{ 	GCD
	; Return the greatest common divisor of bigInts x and y (each with same number of elements).
	GCD(x, y) {
		xc := MfBigMathInt.Dup(x)
		yc := MfBigMathInt.Dup(y)
		MfBigMathInt.GCD_(xc, yc)
		return xc
	}
; 	End:GCD ;}
;{ 	GCD_
	; set x to the greatest common divisor of bigInts x and y (each with same number of elements).
	; y is destroyed.
	GCD_(byref x, byref y) {
		if(MfBigMathInt.tt.m_Count != x.m_Count)
		{
			MfBigMathInt.tt := MfBigMathInt.Dup(x)
		}
		xl := x.m_InnerList
		yl := y.m_InnerList
		sing := 1
		while (sing)
		{
			; while y has nonzero elements other than y[0]
			sing := 0
			i := 1
			i++ ; Add 1 for one based index
			while (i <= y.m_Count)
			{
				if (yl[i])
				{
					sing := 1
					break
				}
				i++
			}
			if (!sing)
			{
				break ; quit when y all zero elements except possibly y[0]
			}

			i := x.m_Count ; zero based index
			i++ ; one base index
			while ((i >= 1) && (!xl[i]))
			{
				; find most significant element of x
				i--
			}
			xp := xl[i]
			yp := yl[i]
			; i is not used from this point
			A := 1
			B := 0
			c := 0
			D := 1
			while ((yp + C) && (yp + D))
			{
				q := floor((xp + A) / (yp + C))
				qp := floor((xp + B) / (yp + D))
				if (q != qp)
				{
					break
				}
				t := A - q * C
				A := C
				C := t ; do (A,B,xp, C,D,yp) = (C,D,yp, A,B,xp) - q*(0,0,0, C,D,yp)
				t := B - q * D
				B := D
				D := t
				t := xp - q * yp
				xp := yp
				yp := t
			}

			if (B)
			{
				MfBigMathInt.copy_(MfBigMathInt.tt, x)
				MfBigMathInt.linComb_(x, y, A, B) ; x=A*x+B*y
				MfBigMathInt.linComb_(y, MfBigMathInt.tt, D, C) ; y=D*y+C*tt
			}
			else
			{
				MfBigMathInt.mod_(x, y)
				MfBigMathInt.copy_(MfBigMathInt.tt, x)
				MfBigMathInt.copy_(x, y)
				MfBigMathInt.copy_(y, MfBigMathInt.tt)
			}
			if (MfObject.ReferenceEquals(xl, x.m_InnerList) = false)
			{
				xl := x.m_InnerList
			}
			if (MfObject.ReferenceEquals(yl, y.m_InnerList) = false)
			{
				yl := y.m_InnerList
			}
		}
		if (yl[1] = 0)
		{
			return
		}
		t := MfBigMathInt.ModInt(x, yl[1])
		MfBigMathInt.copyInt_(x, yl[1])
		yl[1] := t
		while (yl[1] != 0)
		{
			xl[1] := Mod(xl[1], yl[1])
			t := xl[1]
			xl[1] := yl[1]
			yl[1] := t
		}
	}
; 	End:GCD_ ;}
;{ 	inverseMod_
	; do x=x**(-1) Mod n, for bigInts x and n.
	; If no inverse exists, it sets x to zero and returns 0, else it returns 1.
	; The x array must be at least as large as the n array.
	inverseMod_(byref x, byref n) {
		xl := x.m_InnerList
		nl := n.m_InnerList
		k := 1 + 2 * MfMath.Max(x.m_Count, n.m_Count)

		; if both inputs are even, then inverse doesn't exist
		if (!(xl[1] & 1) && !(nl[10] & 1))
		{
			MfBigMathInt.copyInt_(x, 0)
			return false
		}
		if (MfBigMathInt.eg_u.m_Count != k)
		{
			MfBigMathInt.eg_u := new MfListVar(k)
			MfBigMathInt.eg_v := new MfListVar(k)
			MfBigMathInt.eg_A := new MfListVar(k)
			MfBigMathInt.eg_B := new MfListVar(k)
			MfBigMathInt.eg_C := new MfListVar(k)
			MfBigMathInt.eg_D := new MfListVar(k)
		}

		MfBigMathInt.copy_(MfBigMathInt.eg_u, x)
		MfBigMathInt.copy_(MfBigMathInt.eg_v, n)
		MfBigMathInt.copyInt_(MfBigMathInt.eg_A, 1)
		MfBigMathInt.copyInt_(MfBigMathInt.eg_B, 0)
		MfBigMathInt.copyInt_(MfBigMathInt.eg_C, 0)
		MfBigMathInt.copyInt_(MfBigMathInt.eg_D, 1)

		loop
		{
			while (!(MfBigMathInt.eg_u.m_InnerList[1] & 1))
			{
				MfBigMathInt.halve_(MfBigMathInt.eg_u)
				if (!(MfBigMathInt.eg_A.m_InnerList[1] & 1) && !(MfBigMathInt.eg_B.m_InnerList[1] & 1))
				{
					; if eg_A==eg_B==0 Mod 2
					MfBigMathInt.halve_(MfBigMathInt.eg_A)
					MfBigMathInt.halve_(MfBigMathInt.eg_B)
				}
				else
				{
					MfBigMathInt.add_(MfBigMathInt.eg_A, n)
					MfBigMathInt.halve_(MfBigMathInt.eg_A)
					MfBigMathInt.sub_(MfBigMathInt.eg_B, x)
					MfBigMathInt.halve_(MfBigMathInt.eg_B)
				}
			}

			; while eg_v is even
			while (!(MfBigMathInt.eg_v.m_InnerList[1] & 1))
			{
				MfBigMathInt.halve_(MfBigMathInt.eg_v)
				; if eg_C==eg_D==0 Mod 2
				if (!(MfBigMathInt.eg_C.m_InnerList[1] & 1) && !(MfBigMathInt.eg_D.m_InnerList[1] & 1))
				{
					MfBigMathInt.halve_(MfBigMathInt.eg_C)
					MfBigMathInt.halve_(MfBigMathInt.eg_D)
				}
				else
				{
					MfBigMathInt.add_(MfBigMathInt.eg_C, n)
					MfBigMathInt.halve_(MfBigMathInt.eg_C)
					MfBigMathInt.sub_(MfBigMathInt.eg_D, x)
					MfBigMathInt.halve_(MfBigMathInt.eg_D)
				}
			}

			; eg_v <= eg_u
			if (!MfBigMathInt.Greater(MfBigMathInt.eg_v, MfBigMathInt.eg_u))
			{
				MfBigMathInt.sub_(MfBigMathInt.eg_u, MfBigMathInt.eg_v)
				MfBigMathInt.sub_(MfBigMathInt.eg_A, MfBigMathInt.eg_C)
				MfBigMathInt.sub_(MfBigMathInt.eg_B, MfBigMathInt.eg_D)
			}
			else
			{
				MfBigMathInt.sub_(MfBigMathInt.eg_v, MfBigMathInt.eg_u)
				MfBigMathInt.sub_(MfBigMathInt.eg_C, MfBigMathInt.eg_A)
				MfBigMathInt.sub_(MfBigMathInt.eg_D, MfBigMathInt.eg_B)
			}
			if (MfBigMathInt.EqualsInt(MfBigMathInt.eg_u, 0))
			{
				if (MfBigMathInt.Negative(MfBigMathInt.eg_C))
				{
					; make sure answer is nonnegative
					MfBigMathInt.add_(MfBigMathInt.eg_C, n)
				}
				MfBigMathInt.copy_(x, MfBigMathInt.eg_C)
				if (!MfBigMathInt.EqualsInt(MfBigMathInt.eg_v, 1))
				{
					;if GCD_(x,n)!=1, then there is no inverse
					MfBigMathInt.copyInt_(x, 0)
					return false
				}
				return true
			}
		}
	}
; 	End:inverseMod_ ;}
;{ 	InverseModInt
	InverseModInt(x, n) {
		a := 1
		b := 0
		t := ""
		loop
		{
			if (x = 1)
			{
				return a
			}
			if (x = 0)
			{
				return 0
			}
			b -= a * floor(n / x)
			n := Mod(n, x)

			; to avoid negatives, change this b to n-b, and each -= to +=
			if (n = 1)
			{
				return b
			}
			if (n = 0)
			{
				return 0
			}
			a -= b * floor(z / n)
			x := Mod(x, n)
		}
	}
; 	End:InverseModInt ;}
;{ 	eGCD_
	; Given positive bigInts x and y, change the bigints v, a, and b to positive bigInts such that:
	;      v = GCD_(x,y) = a*x-b*y
	; The bigInts v, a, b, must have exactly as many elements as the larger of x and y.
	eGCD_(x, y, byref v, byref a, byref b) {
		g := 0
		k := MfMath.Max(x.m_Count, y.m_Count)
		if (MfBigMathInt.eg_u.m_Count != k)
		{
			MfBigMathInt.eg_u := new MfListVar(k)
			MfBigMathInt.eg_A := new MfListVar(k)
			MfBigMathInt.eg_B := new MfListVar(k)
			MfBigMathInt.eg_C := new MfListVar(k)
			MfBigMathInt.eg_D := new MfListVar(k)
		}
		xl := x.m_InnerList
		yl := y.m_InnerList
		while (!(xl[1] & 1) && !(yl[1] & 1))
		{ 
			; while x and y both even
			MfBigMathInt.halve_(x)
			MfBigMathInt.halve_(y)
			g++
		}
		MfBigMathInt.copy_(MfBigMathInt.eg_u, x)
		MfBigMathInt.copy_(v, y)
		MfBigMathInt.copyInt_(MfBigMathInt.eg_A, 1)
		MfBigMathInt.copyInt_(MfBigMathInt.eg_B, 0)
		MfBigMathInt.copyInt_(MfBigMathInt.eg_C, 0)
		MfBigMathInt.copyInt_(MfBigMathInt.eg_D, 1)
		loop
		{
			; while u is even
			while (!(MfBigMathInt.eg_u.m_InnerList[1] & 1))
			{ 
				MfBigMathInt.halve_(MfBigMathInt.eg_u)

				; if A==B==0 Mod 2
				if (!(MfBigMathInt.eg_A.m_InnerList[1] & 1) && !(MfBigMathInt.eg_B.m_InnerList[1] & 1))
				{ 
					MfBigMathInt.halve_(MfBigMathInt.eg_A)
					MfBigMathInt.halve_(MfBigMathInt.eg_B)
				}
				else
				{
					MfBigMathInt.add_(MfBigMathInt.eg_A, y)
					MfBigMathInt.halve_(MfBigMathInt.eg_A)
					MfBigMathInt.sub_(MfBigMathInt.eg_B, x)
					MfBigMathInt.halve_(MfBigMathInt.eg_B)
				}
			}

			; while v is even
			vl := v.m_InnerList
			while (!(vl[1] & 1))
			{ 
				MfBigMathInt.halve_(v)

				; if C==D==0 Mod 2
				if (!(MfBigMathInt.eg_C.m_InnerList[1] & 1) && !(MfBigMathInt.eg_D.m_InnerList[1] & 1))
				{ 
					MfBigMathInt.halve_(MfBigMathInt.eg_C)
					MfBigMathInt.halve_(MfBigMathInt.eg_D)
				}
				else
				{
					MfBigMathInt.add_(MfBigMathInt.eg_C, y)
					MfBigMathInt.halve_(MfBigMathInt.eg_C)
					MfBigMathInt.sub_(MfBigMathInt.eg_D, x)
					MfBigMathInt.halve_(MfBigMathInt.eg_D)
				}
			}

			; v<=u
			if (!MfBigMathInt.Greater(v, MfBigMathInt.eg_u))
			{ 
				MfBigMathInt.sub_(MfBigMathInt.eg_u, v)
				MfBigMathInt.sub_(MfBigMathInt.eg_A, MfBigMathInt.eg_C)
				MfBigMathInt.sub_(MfBigMathInt.eg_B, MfBigMathInt.eg_D)
			}
			else
			{ 	; v>u
				MfBigMathInt.sub_(v, MfBigMathInt.eg_u)
				MfBigMathInt.sub_(MfBigMathInt.eg_C, MfBigMathInt.eg_A)
				MfBigMathInt.sub_(MfBigMathInt.eg_D, MfBigMathInt.eg_B)
			}
			if (MfBigMathInt.EqualsInt(MfBigMathInt.eg_u, 0))
			{
				; make sure a (C)is nonnegative
				if (MfBigMathInt.Negative(MfBigMathInt.eg_C))
				{ 
					MfBigMathInt.add_(MfBigMathInt.eg_C, y)
					MfBigMathInt.sub_(MfBigMathInt.eg_D, x)
				}
				MfBigMathInt.multInt_(MfBigMathInt.eg_D, -1) ; make sure b (D) is nonnegative
				MfBigMathInt.copy_(a, MfBigMathInt.eg_C)
				MfBigMathInt.copy_(b, MfBigMathInt.eg_D)
				MfBigMathInt.leftShift_(v, g)
				return
			}
		}
	}
; 	End:eGCD_ ;}
;{ 	Negative
	; is bigInt x Negative?
	Negative(byref x) {
		return ((x.m_InnerList[x.count] >> (MfBigMathInt.bpe - 1)) & 1)
	}
; 	End:Negative ;}
;{ 	GreaterShift
	; is (x << (shift*bpe)) > y?
	; x and y are nonnegative bigInts
	; shift is a nonnegative integer
	GreaterShift(x, y, shift) {
		kx := x.m_Count
		ky := y.m_Count
		xl := x.m_InnerList
		yl := y.m_InnerList

		k := ((kx + shift) < ky) ? (kx + shift) : ky
		i := ky - 1 - shift
		i++ ; move to one base index
		while (i >= 1 && i <= kx)
		{
			if (xl[i] > 0)
			{
				return true ; if there are nonzeros in x to the left of the first column of y, then x is bigger
			}
			i++
		}


		i := kx - 1 + shift
		i++ ; move to one base index
		while (i <= ky)
		{
			if (yl[i] > 0)
			{
				return false ; if there are nonzeros in y to the left of the first column of x, then x is not bigger
			}
			i++
		}
		
		i := k - 1 ; zero based index
		while (i >= shift)
		{
			if (xl[((i - shift) + 1)] > yl[i + 1])
			{
				return true
			}
			else if (xl[((i - shift) + 1)] < yl[i + 1])
			{
				return false
			}
			i--
		}
		return false
	}
; 	End:GreaterShift ;}
;{ 	Greater
	; is x > y? (x and y both nonnegative)
	Greater(x, y) {
		xl := x.m_InnerList
		yl := y.m_InnerList

		k := (x.m_Count < y.m_Count) ? x.m_Count : y.m_Count
		i := x.m_Count
		while (i < y.m_Count)
		{
			if (yl[i + 1])
			{
				return false
			}
			i++
		}

		i := y.m_Count
		while (i < x.m_Count)
		{
			if (xl[i + 1])
			{
				return true ; x has more digits
			}
			i++
		}
		i := k -1
		i++ ; one based index
		while (i >= 1)
		{
			if (xl[i] > yl[i])
			{
				return true
			}
			else if (xl[i] < yl[i])
			{
				return false
			}
			i--
		}
		return false
	}
; 	End:Greater ;}
;{ 	divide_
	; divide x by y giving quotient q and remainder r.  (q=floor(x/y),  r=x Mod y).  All 4 are bigints.
	; x must have at least one leading zero element.
	; y must be nonzero.
	; q and r must be arrays that are exactly the same Count as x. (Or q can have more).
	; Must have x.Count >= y.Count >= 2.
	divide_(ByRef x, ByRef y, ByRef q, ByRef r) {
		MfBigMathInt.copy_(r, x)
		ky := y.m_Count
		xl := x.m_InnerList
		yl := y.m_InnerList
		ql := q.m_InnerList
		rl := r.m_InnerList
		; ky is number of elements in y, not including leading zeros
		while (ky >= 1 && yl[ky] = 0)
		{
			ky--
		}

		; normalize: ensure the most significant element of y has its highest bit set
		b := yl[ky]
		a := 0
		while (b)
		{
			b >>= 1
			a++
		}
		a := MfBigMathInt.bpe - a ; a is how many bits to shift so that the high order bit of y is leftmost in its array element

		; multiply both by 1<<a now, then divide both by that at the end
		MfBigMathInt.leftShift_(y, a)
		MfBigMathInt.leftShift_(r, a)

		kx := r.m_Count
		while(rl[kx] = 0 && kx > ky)
		{
			kx--
		}

		MfBigMathInt.copyInt_(q, 0) ; q=0
		while (!MfBigMathInt.GreaterShift(y, r, kx - ky))
		{
			MfBigMathInt.subShift_(r, y, kx - ky)
			ql[((kx - ky) + 1)]++
		}
		MfBigMathInt.rightShift_(y, a) ; undo the normalization step
		MfBigMathInt.rightShift_(r, a) ; undo the normalization step
		
		i := kx - 1 ; zero based index
		while (i >= ky)
		{
			if (rl[i + 1] = yl[ky])
			{
				ql[((i - ky) + 1)] := MfBigMathInt.mask
			}
			else
			{
				ql[((i - ky) + 1)] := floor((rl[i + 1] * MfBigMathInt.radix + rl[i]) / yl[ky])
			}
			loop
			{
				y2 := (ky > 1 ? yl[ky - 1] : 0) * ql[((i - ky) + 1)]
				c := y2 >> MfBigMathInt.bpe
				y2 := y2 & MfBigMathInt.mask
				y1 := c + ql[((i - ky) + 1)] * yl[ky]
				c := y1 >> MfBigMathInt.bpe
				y1 := y1 & MfBigMathInt.mask

				if (c = rl[i + 1] ? y1 = rl[i] ? y2 > (i > 1 ? rl[i - 1] : 0) : y1 > rl[i] : c > rl[i + 1])
				{
					ql[((i - ky) + 1)]--
				}
				else
				{
					break
				}
			}
			
			MfBigMathInt.linCombShift_(r, y, -ql[((i - ky) + 1)], i - ky) ; r=r-q.Item[i-ky] * MfBigMathInt.leftShift_(y, i - ky)
			if (MfBigMathInt.Negative(r))
			{
				MfBigMathInt.addShift_(r, y, i - ky)
				ql[((i - ky) + 1)]--
			}
			i--
		}
	}
; 	End:divide_ ;}
;{ 	carry_
	; do carries and borrows so each element of the bigInt x fits in bpe bits.
	carry_(x) {
		ll := x.m_InnerList
		k := x.m_Count
		c := 0
		i := 1
		while (i <= k)
		{
			c += ll[i]
			b := 0
			if (c < 0)
			{
				b := -(c >> MfBigMathInt.bpe)
				c += b * MfBigMathInt.radix
			}
			ll[i] := c & MfBigMathInt.mask
			c := (c >> MfBigMathInt.bpe) - b
			i++
		}
		x.m_Count := ll.Length()
	}
; 	End:carry_ ;}
;{ 	ModInt
	; return x Mod n for bigInt x and integer n.
	ModInt(x, n) {
		c := 0
		i := x.m_Count
		while (i >= 1)
		{
			tmp := c * MfBigMathInt.radix + x.m_InnerList[i]
			c := Mod(tmp, n)
			i--
		}
		return c
	}
; 	End:ModInt ;}
;{ Int2bigInt
	; convert the integer t into a bigInt with at least the given number of bits.
	; the returned array stores the bigInt in bpe-bit chunks, little endian (buff[0] is least significant word)
	; Pad the array with leading zeros so that it has at least minSize elements.
	; There will always be at least one leading 0 element.
	Int2bigInt(t, bits, minSize) {   
	  
	  k := ceil(bits / MfBigMathInt.bpe) + 1
	  k := minSize > k ? minSize : k
	  buff := new MfListVar(k)
	  MfBigMathInt.copyInt_(buff, t)
	  return buff
	}
; End:Int2bigInt ;}
;{ 	Str2bigInt
	; return the bigInt given a string representation in a given base.  
	; Pad the array with leading zeros so that it has at least minSize elements.
	; If base=-1, then it reads in a comma-separated list of array elements in decimal.
	; The array will always have at least one leading zero, unless base=-1.
	; Base 10 and base 16 conversion are fastest and about the same speed
	Str2bigInt(s, base, minSize) {
		if (MfObject.IsObjInstance(s, MfListVar))
		{
			sLst := s
		}
		else
		{
			sLst := MfListVar.FromString(s, false) ; string to list, ignore whitespace is false
		}
		
		k := sLst.m_Count
		if (base = -1)
		{
		 	; comma-separated list of array elements in decimal
		 	x := new MfListVar()
		 	xl := x.m_InnerList
		 	loop
		 	{
		 		y := new MfListVar(x.m_Count + 1)
		 		yl := y.m_InnerList
		 		i := 1 ; one base index
		 		while (i <= x.m_Count)
		 		{
		 			yl[i] := xl[i]
		 			i++
		 		}
		 		yl[1] := MfBigMathInt._ParseInt(sLst, 10)
		 		x := y
		 		d := sLst.IndexOf(",")
		 		if (d < 1)
		 		{
		 			break
		 		}
		 		sLst := sLst.SubList(d + 1)
		 		if (sLst.m_Count = 0)
		 		{
		 			break
		 		}
		 	}
		 	if (x.m_Count < minSize)
		 	{
		 		y := new MfListVar(minSize)
		 		MfBigMathInt.copy_(y, x)
		 		return y
		 	}
		 	return x
		}
		x := MfBigMathInt.Int2bigInt(0, base * k, 0)
		xl := x.m_InnerList
		i := 1 ; move to one base
		while (i <= k)
		{
			d := MfBigMathInt.digitStr.IndexOf(sLst.m_InnerList[i]) ; get zero based char index from char
			if (base <= 36 && d >= 36) ;convert lowercase to uppercase if base<=36
			{
				d -= 26
			}
			; stop at first illegal character
			if (d >= base || d < 0)
			{
				break
			}
			MfBigMathInt.multInt_(x, base)
			MfBigMathInt.addInt_(x, d)
			i++
		}
		k := x.m_Count
		; strip off leading zeros
		while (k > 0 && !xl[k])
		{
			k--
		}
		k := minSize > k + 1 ? minSize : k + 1
		y := new MfListVar(k)
		yl := y.m_InnerList
		kk := k < x.m_Count ? k : x.m_Count
		i := 1 ; move to one base
		while (i <= kk)
		{
			yl[i] := xl[i]
			i++
		}
		while (i <= k)
		{
			yl[i] := 0
			i++
		}
		return y
	}
	
; 	End:Str2bigInt ;}
;{ 	EqualsInt
	; is bigint x equal to integer y?
	; y must have less than bpe bits
	EqualsInt(x, y) {
		xl := x.m_InnerList
		if (xl[1] != y)
		{
			return 0
		}
		i := 2
		while (i <= x.m_Count)
		{
			if (xl[i])
			{
				return 0
			}
			i++
		}
		return 1
	}
; 	End:EqualsInt ;}
;{ 	Equals
	; are bigints x and y equal?
	; this works even if x and y are different m_Counts and have arbitrarily many leading zeros
	Equals(x, y) {
		 k := x.m_Count < y.m_Count ? x.m_Count : y.m_Count
		 xl := x.m_InnerList
		 yl := y.m_InnerList
		 i := 1
		 while (i <= k)
		 {
		 	if (xl[i] != yl[i])
		 	{
		 		return false
		 	}
		 	i++
		 }
		 if (x.m_Count > y.m_Count)
		 {
		 	while (i <= x.m_Count)
		 	{
		 		if (xl[i])
		 		{
		 			return false
		 		}
		 		i++
		 	}
		 }
		 else
		 {
		 	while (i < y.m_Count)
		 	{
		 		if (yl[i])
		 		{
		 			return false
		 		}
		 		i++
		 	}
		 }
		 return true
	}
; 	End:Equals ;}
;{ 	IsZero
	;is the bigInt x equal to zero?
	IsZero(x) {
		i := 1
		xl := x.m_InnerList
		while (i <= x.m_Count)
		{
			if (xl[i])
			{
				return false
			}
			i++
		}
		return true
	}
; 	End:IsZero ;}
;{ 	BigInt2str
	; convert a bigInt into a string in a given base, from base 2 up to base 95.
	;Base -1 prints the contents of the array representing the number.
	BigInt2str(x, base) {
		sb := new MfText.StringBuilder(64)
		xl := x.m_InnerList
		if (MfBigMathInt.s6.m_Count != x.m_Count)
		{
			MfBigMathInt.s6 := MfBigMathInt.Dup(x)
		}
		else
		{
			MfBigMathInt.copy_(MfBigMathInt.s6, x)
		}
		if (base = -1) ; return the list of array contents
		{
			i := x.m_Count
			while (i > 1)
			{
				sb.AppendString(xl[i])
				sb.AppendString(",")
				;s .= xl[i] . ","
				i--
			}
			sb.AppendString(xl[1])
			;s .= xl[1]
		}
		else ; return the given base
		{
			sb2 := new MfText.StringBuilder(64)
			while (!MfBigMathInt.IsZero(MfBigMathInt.s6))
			{
				t := MfBigMathInt.divInt_(MfBigMathInt.s6, base)
				;s := MfBigMathInt.digitStr.Item[t] . s
				sb2.AppendString(MfBigMathInt.digitStr.Item[t])
			}
			mStr := new MfMemoryString(sb2.Length)
			mStr.Append(sb2)

			sb.AppendString(mStr.Reverse())
			mStr := ""
			sb2 := ""
		}
		if (sb.Length = 0)
		{
			sb := ""
			return "0"
		}

		return sb.ToString()
	}
; 	End:BigInt2str ;}
;{ 	Dup
	; returns a duplicate of bigInt x
	Dup(x) {
		buff := new MfListVar(x.m_Count)
		MfBigMathInt.copy_(buff, x)
		return buff
	}
; 	End:Dup ;}
;{ 	copy_
	; do x=y on bigInts x and y.  x must be an big int
	; at least as big as y (not counting the leading zeros in y).
	copy_(ByRef x, y) {
		k := x.m_Count < y.m_Count ? x.m_Count : y.m_Count
		xl := x.m_InnerList
		yl := y.m_InnerList
		i := 1
		while (i <= k)
		{
			xl[i] := yl[i]
			i++
		}
		i := k + 1
		while (i <= x.m_Count)
		{
			xl[i] := 0
			i++
		}
	}
; 	End:copy_ ;}
;{ 	copyInt_
	; do x=y on bigInt x and integer y.
	copyInt_(ByRef x, n) {
		c := n
		xl := x.m_InnerList
		i := 1
		while (i <= x.m_Count)
		{
			xl[i] := c & MfBigMathInt.mask
			c >>= MfBigMathInt.bpe
			i++
		}
	}
; 	End:copyInt_ ;}
;{ 	addInt_
	; do x=x+n where x is a bigInt and n is an integer.
	; x must be large enough to hold the result.
	addInt_(ByRef x, n) {
		xl := x.m_InnerList
		xl[1] += n
		k := x.m_Count
		c := 0
		i := 1
		while (i <= k)
		{
			c += xl[i]
			b := 0
			if (c < 0)
			{
				b := -(c >> MfBigMathInt.bpe)
				c += b * MfBigMathInt.radix
			}
			xl[i] := c & MfBigMathInt.mask
			c := (c >> MfBigMathInt.bpe) - b
			if (!c)
			{
				; stop carrying as soon as the carry is zero
				return
			}
			i++
		}
	}
; 	End:addInt_ ;}
;{ 	rightShift_
	; right shift bigInt x by n bits.  0 <= n < bpe.
	rightShift_(ByRef x, n) {
		xl := x.m_InnerList
		k := n // MfBigMathInt.bpe
		if (k)
		{
			i := 1
			while (i <= x.m_Count - k)
			{
				xl[i] :=  xl[i + k]	
				i++
			}
			while (i <= x.m_Count)
			{
				xl[i] := 0
				i++
			}
			n := Mod(n, MfBigMathInt.bpe)
		}
		i := 1
		x.m_Count := xl.Length()
		while (i <= x.m_Count -1)
		{
			xl[i] := MfBigMathInt.mask & ((xl[i + 1] << (MfBigMathInt.bpe - n)) | (xl[i] >> n))
			i++
		}
		xl[i] >>= n
		x.m_Count := xl.Length()
	}
; 	End:rightShift_ ;}
;{ 	halve_
	halve_(ByRef x) {
		xl := x.m_InnerList
		i := 1
		while (i <= x.m_Count - 1)
		{
			xl[i] := MfBigMathInt.mask & ((xl[i + 1] << (MfBigMathInt.bpe - 1)) | (xl[i] >> 1))
			i++
		}
		; most significant bit stays the same
		xl[i] := (xl[i] >> 1) | (xl[i] & (MfBigMathInt.radix >> 1))
		x.m_Count := xl.Length()
	}
; 	End:halve_ ;}
;{ 	leftShift_
	; left shift bigInt x by n bits.
	leftShift_(byref x, n) {
		k := n // MfBigMathInt.bpe
		xl := x.m_InnerList
		if (k)
		{
			i := x.m_Count
			While (i >= k)
			{
				xl[i + 1] := xl[(i - k) + 1]
				i--
			}
			i++ ; one based index
			while (i >= 1)
			{
				xl[i] := 0
				i--
			}
			n := mod(n, MfBigMathInt.bpe)
		}
		if(!n)
		{
			return
		}
		; coumt may be different, use length()
		i := xl.Length() - 1 ; zero based index
		while (i > 0)
		{
			xl[i + 1] := MfBigMathInt.mask & ((xl[i + 1] << n) | (xl[i] >> (MfBigMathInt.bpe - n)))
			i--
		}
		i++ ; one based index
		xl[i] := MfBigMathInt.mask & (xl[i] << n)
		x.m_Count := xl.Length()

	}
; 	End:leftShift_ ;}
;{ 	multInt_
	; do x=x*n where x is a bigInt and n is an integer.
	; x must be large enough to hold the result.
	multInt_(ByRef x, n) {
		xl := x.m_InnerList
		if (!n)
		{
			return
		}
		k := x.m_Count
		c := 0
		i := 1
		while (i <= k)
		{
			c += xl[i] * n
			b := 0
			if (c < 0)
			{
				b := -(c >> MfBigMathInt.bpe)
				c += b * MfBigMathInt.radix
			}
			xl[i] := c & MfBigMathInt.mask
			c := (c >> MfBigMathInt.bpe) - b
			i++
		}
		x.m_Count := xl.Length()
	}
; 	End:multInt_ ;}
;{ 	divInt_
	; do x=floor(x/n) for bigInt x and integer n, and return the remainder
	divInt_(byRef x, n) {
		xl := x.m_InnerList
		r := 0
		i := x.m_Count 
		while (i >= 1)
		{
			s := r * MfBigMathInt.radix + xl[i]
			xl[i] := s // n
			r := Mod(s , n)
			i--
		}
		x.m_Count := xl.Length()
		return r
	}
; 	End:divInt_ ;}
;{ 	linComb_
	; do the linear combination x=a*x+b*y for bigInts x and y, and integers a and b.
	; x must be large enough to hold the answer.
	linComb_(ByRef x, y, a, b) {
		xl := x.m_InnerList
		yl := y.m_InnerList
		k := x.m_Count < y.m_Count ? x.m_Count : y.m_Count
		kk := x.m_Count
		c := 0
		i := 1
		while (i <= k)
		{
			c += a * xl[i] + b * yl[i]
			xl[i] := c & MfBigMathInt.mask
			c >>= MfBigMathInt.bpe
			i++
		}
		i := k + 1
		While (i <= kk)
		{
			c += a * xl[i]
			xl[i] := c & MfBigMathInt.mask
			c >>= MfBigMathInt.bpe
			i++
		}
	}
; 	End:linComb_ ;}
;{ 	linCombShift_
	; do the linear combination x=a*x+b*(y<<(ys*bpe)) for bigInts x and y, and integers a, b and ys.
	; x must be large enough to hold the answer.
	linCombShift_(ByRef x, y, b, ys) {
		xl := x.m_InnerList
		yl := y.m_InnerList
		k := x.m_Count < (ys + y.m_Count) ? x.m_Count : (ys + y.m_Count)
		kk := x.m_Count
		c := 0
		i := ys + 1
		while (i <= k)
		{
			c += xl[i] + b * yl[i - ys]
			xl[i] := c & MfBigMathInt.mask
			c >>= MfBigMathInt.bpe
			i++
		}
		i := k + 1
		while (c && i <= kk)
		{
			c += xl[i]
			xl[i] := c & MfBigMathInt.mask
			c >>= MfBigMathInt.bpe
			i++
		}
	}
; 	End:linCombShift_ ;}
;{ 	addShift_
	; do x=x+(y<<(ys*bpe)) for bigInts x and y, and integer ys.
	; x must be large enough to hold the answer.
	addShift_(ByRef x, y, ys) {
		xl := x.m_InnerList
		yl := y.m_InnerList
		k := x.m_Count < ys + y.m_Count ? x.m_Count : ys + y.m_Count
		kk := x.m_Count
		c := 0
		i := ys + 1
		while (i <= k)
		{
			c += xl[i] + yl[i - ys]
			xl[i] := c & MfBigMathInt.mask
			c >>= MfBigMathInt.bpe
			i++
		}
		i := k + 1
		while (c && i <= kk)
		{
			c += xl[i]
			xl[i] := c & MfBigMathInt.mask
			c >>= MfBigMathInt.bpe
			i++
		}
	}
; 	End:addShift_ ;}
;{ 	subShift_
	; do x=x-(y<<(ys*bpe)) for bigInts x and y, and integers a,b and ys.
	; x must be large enough to hold the answer.
	subShift_(ByRef x, y, ys) {
		xl := x.m_InnerList
		yl := y.m_InnerList
		k := x.m_Count < ys + y.m_Count ? x.m_Count : ys + y.m_Count
		kk := x.m_Count
		c := 0
		i := ys + 1
		while (i <= k)
		{
			c += xl[i] - yl[i - ys]
			xl[i] := c & MfBigMathInt.mask
			c >>= MfBigMathInt.bpe
			i++
		}
		i := k + 1
		while (c && i <= kk)
		{
			c += xl[i]
			xl[i] := c & MfBigMathInt.mask
			c >>= MfBigMathInt.bpe
			i++
		}
	}
; 	End:subShift_ ;}
;{ 	sub_
	; do x=x-y for bigInts x and y.
	; x must be large enough to hold the answer.
	; Negative answers will be 2s complement
	sub_(ByRef x, y) {
		xl := x.m_InnerList
		yl := y.m_InnerList
		k := x.m_Count < y.m_Count ? x.m_Count : y.m_Count
		c := 0
		i := 1
		while (i <= k)
		{
			c += xl[i] - yl[i]
			xl[i] := c & MfBigMathInt.mask
			c >>= MfBigMathInt.bpe
			i++
		}
		i := k + 1
		while (c && i <= x.m_Count)
		{
			c += xl[i]
			xl[i] := c & MfBigMathInt.mask
			c >>= MfBigMathInt.bpe
			i++
		}
	}
; 	End:sub_ ;}
;{ 	add_
	; do x=x+y for bigInts x and y.
	; x must be large enough to hold the answer.
	add_(ByRef x, y) {
		xl := x.m_InnerList
		yl := y.m_InnerList
		k := x.m_Count < y.m_Count ? x.m_Count : y.m_Count
		c := 0
		i := 1
		while (i <= k)
		{
			c += xl[i] + yl[i]
			xl[i] := c & MfBigMathInt.mask
			c >>= MfBigMathInt.bpe
			i++
		}
		i := k + 1
		while (c && i <= x.m_Count)
		{
			c += xl[i]
			xl[i] := c & MfBigMathInt.mask
			c >>= MfBigMathInt.bpe
			i++
		}
	}
; 	End:add_ ;}
;{ 	mult_
	; do x=x*y for bigInts x and y.  This is faster when y<x.
	mult_(ByRef x, y) {
		xl := x.m_InnerList
		yl := y.m_InnerList
		if (MfBigMathInt.ss.m_Count != 2 * x.m_Count)
		{
			MfBigMathInt.ss := new MfListVar(2 * x.m_Count)
		}
		MfBigMathInt.copyInt_(MfBigMathInt.ss, 0)
		ssl := MfBigMathInt.ss.m_InnerList
		i := 1
		while (i <= y.m_Count)
		{
			if (yl[i])
			{
				MfBigMathInt.linCombShift_(MfBigMathInt.ss, x, yl[i], i - 1)
			}
			i++
		}
		MfBigMathInt.copy_(x, MfBigMathInt.ss)
	}
; 	End:mult_ ;}
;{ 	mod_
	; do x=x Mod n for bigInts x and n.
	mod_(ByRef x, byRef n) {
		if (MfBigMathInt.s4.m_Count != x.m_Count)
		{
			MfBigMathInt.s4 := MfBigMathInt.Dup(x)
		}
		else
		{
			MfBigMathInt.copy_(MfBigMathInt.s4, x)
		}
		if (MfBigMathInts5.m_Count != x.m_Count)
		{
			MfBigMathInt.s5 := MfBigMathInt.Dup(x)
		}
		MfBigMathInt.divide_(MfBigMathInt.s4, n, MfBigMathInt.s5, x) ; x = remainder of s4 / n
	}
; 	End:mod_ ;}
;{ 	multMod_
	; do x=x*y Mod n for bigInts x,y,n.
	; for Greater speed, let y<x.
	multMod_(ByRef x, ByRef y, ByRef n) {
		yl := y.m_InnerList
		if (MfBigMathInt.s0.m_Count != 2 * x.m_Count)
		{
			MfBigMathInt.s0 := new MfListVar(2 * x.m_Count)
		}
		MfBigMathInt.copyInt_(MfBigMathInt.s0, 0)
		i := 1
		while (i <= y.m_Count)
		{
			if(yl[i])
			{
				MfBigMathInt.linCombShift_(MfBigMathInt.s0, x, yl[i], i - 1)
			}
			i++
		}
		MfBigMathInt.mod_(MfBigMathInt.s0, n)
		MfBigMathInt.copy_(x, MfBigMathInt.s0)
	}
; 	End:multMod_ ;}
;{ 	squareMod_
	; do x=x*x Mod n for bigInts x,n.
	squareMod_(byRef x, byRef n) {
		xl := x.m_InnerList
		kk := x.m_Count
		; ignore leading zeros in x
		while (kx > 0 && !xl[kx])
		{
			kx--
		}
		; k=# elements in the product, which is twice the elements in the larger of x and n
		k := kx > n.m_Count ? 2 * kx : 2 * n.m_Count
		if (MfBigMathInt.s0.m_Count != k)
		{
			MfBigMathInt.s0 := new MfListVar(k)
		}
		MfBigMathInt.copyInt_(MfBigMathInt.s0, 0)
		i := 0
		while (i < kx)
		{
			ixl := i + 1
			c := MfBigMathInt.s0.m_InnerList[(2 * i) + 1] + xl[ixl] * xl[ixl]
			MfBigMathInt.s0.m_InnerList[(2 * i) + 1] := c & MfBigMathInt.mask
			c >>= MfBigMathInt.bpe
			j := i + 1
			while (j < kx)
			{
				c := MfBigMathInt.s0.m_InnerList[i + j + 1] + 2 * xl[ixl] * xl[j + 1] + c
				MfBigMathInt.s0.m_InnerList[i + j + 1] := (c & MfBigMathInt.mask)
				c >>= MfBigMathInt.bpe
				j++
			}
			MfBigMathInt.s0.m_InnerList[i + kx + 1] := c
			i++
		}
		MfBigMathInt.mod_(MfBigMathInt.s0, n)
		MfBigMathInt.copy_(x, MfBigMathInt.s0)
	}
; 	End:squareMod_ ;}
;{ 	Trim
	; return x with exactly k leading zero elements
	Trim(x, k) {
		i := x.m_Count
		while (i > 0 && !x.m_InnerList[i])
		{
			i--
		}
		y := new MfListVar(i + k)
		MfBigMathInt.copy_(y, x)
		return y
	}
; 	End:Trim ;}
;{ 	powMod_
	; do x=x**y Mod n, where x,y,n are bigInts and ** is exponentiation.  0**0=1.
	; this is faster when n is odd.  x usually needs to have as many elements as n.
	powMod_(ByRef x, ByRef y, ByRef n) {
		yl := y.m_InnerList
		nl := n.m_InnerList
		if (MfBigMathInt.s7.m_Count != n.m_Count)
		{
			MfBigMathInt.s7 := MfBigMathInt.Dup(n)
		}
		; for even modulus, use a simple square-and-multiply algorithm,
		; rather than using the more complex Montgomery algorithm.
		if ((nl[1] & 1) = 0)
		{
			MfBigMathInt.copy_(MfBigMathInt.s7, x)
			MfBigMathInt.copyInt_(x, 1)
			while (!MfBigMathInt.EqualsInt(y, 0))
			{
				if (yl[1] & 1)
				{
					MfBigMathInt.multMod_(x, MfBigMathInt.s7, n)
				}
				MfBigMathInt.divInt_(y, 2)
				MfBigMathInt.squareMod_(MfBigMathInt.s7, n)
			}
			return
		}
		; calculate np from n for the Montgomery multiplications
		MfBigMathInt.copyInt_(MfBigMathInt.s7, 0)
		kn := n.m_Count
		while (kn > 0 && !nl[kn])
		{
			kn--
		}
		np := MfBigMathInt.radix - MfBigMathInt.InverseModInt(MfBigMathInt.ModInt(n, MfBigMathInt.radix), MfBigMathInt.radix)
		MfBigMathInt.s7.m_InnerList[kn + 1] := 1
		MfBigMathInt.multMod_(x, MfBigMathInt.s7, n) ; x = x * 2**(kn*bp) Mod n

		if (MfBigMathInt.s3.m_Count != x.m_Count)
		{
			MfBigMathInt.s3 := MfBigMathInt.Dup(x)
		}
		else
		{
			MfBigMathInt.copy_(MfBigMathInt.s3, x)
		}
		; first nonzero element of y
		k1 := y.m_Count ; one base index
		while (k1 > 1 & !yl[k1])
		{
			k1--
		}
		
		if (yl[k1] = 0)
		{
			; anything to the 0th power is 1
			MfBigMathInt.copyInt_(x, 1)
			return
		}
		k2 := 1 << (MfBigMathInt.bpe - 1)
		; k2=position of first 1 bit in yl[k1]
		while (k2 && !(yl[k1] & k2))
		{
			k2 >>= 1
		}
		loop
		{
			if (!(k2 >>= 1))
			{ 
				;look at next bit of y
				k1--
				if (k1 < 1)
				{
					MfBigMathInt.mont_(x, MfBigMathInt.one, n, np)
					return
				}
				k2 := 1 << (MfBigMathInt.bpe - 1)
			}
			MfBigMathInt.mont_(x, x, n, np)
			if (k2 & yl[k1]) ; if next bit is a 1
			{
				MfBigMathInt.mont_(x, MfBigMathInt.s3, n, np)
			}
		}
	}
; 	End:powMod_ ;}
;{ 	mont_
	; do x=x*y*Ri Mod n for bigInts x,y,n, 
	;   where Ri = 2**(-kn*bpe) Mod n, and kn is the 
	;   number of elements in the n array, not 
	;   counting leading zeros.  
	; x array must have at least as many elemnts as the n array
	; It's OK if x and y are the same variable.
	; must have:
	;   x,y < n
	;   n is odd
	;   np = -(n^(-1)) Mod radix
	mont_(byRef x, ByRef y, ByRef n, np) {
		xl := x.m_InnerList
		yl := y.m_InnerList
		nl := n.m_InnerList

		kn := n.m_Count
		ky := y.m_Count

		if (MfBigMathInt.sa.m_Count != kn)
		{
			MfBigMathInt.sa := new MfListVar(kn)
		}

		MfBigMathInt.copyInt_(MfBigMathInt.sa, 0)
		; ignore leading zeros of n
		while (kn > 0 && nl[kn] = 0)
		{
			kn--
		}
		; ignore leading zeros of y
		while (ky > 0 && yl[ky] = 0)
		{
			ky--
		}

		; sa will never have more than this many nonzero elements.
		ks := MfBigMathInt.sa.m_Count - 1

		; the following loop consumes 95% of the runtime for randTruePrime_() and powMod_() for large numbers
		i := 1
		while (i <= kn)
		{
			t := MfBigMathInt.sa.m_InnerList[1] + xl[i] * yl[1]
			ui := ((t & MfBigMathInt.mask) * np) & MfBigMathInt.mask ; the inner "& mask" was needed on Safari (but not MSIE) at one time
			c := (t + ui * nl[1]) >> MfBigMathInt.bpe
			t := xl[i]

			; do sa=(sa+x[i]*y+ui*n)/b   where b=2**bpe.  Loop is unrolled 5-fold for speed
			j := 1
			while (j < ky - 4)
			{
				jj := j + 1
				c += MfBigMathInt.sa.m_InnerList[jj] + ui * nl[jj] + t * yl[jj]
				MfBigMathInt.sa.m_InnerList[j] := c & MfBigMathInt.mask
				c >>= MfBigMathInt.bpe
				j++
				jj++
				c += MfBigMathInt.sa.m_InnerList[jj] + ui * nl[jj] + t * yl[jj]
				MfBigMathInt.sa.m_InnerList[j] := c & MfBigMathInt.mask
				c >>= MfBigMathInt.bpe
				j++
				jj++
				c += MfBigMathInt.sa.m_InnerList[jj] + ui * nl[jj] + t * yl[jj]
				MfBigMathInt.sa.m_InnerList[j] := c & MfBigMathInt.mask
				c >>= MfBigMathInt.bpe
				j++
				jj++
				c += MfBigMathInt.sa.m_InnerList[jj] + ui * nl[jj] + t * yl[jj]
				MfBigMathInt.sa.m_InnerList[j] := c & MfBigMathInt.mask
				c >>= MfBigMathInt.bpe
				j++
				jj++
				c += MfBigMathInt.sa.m_InnerList[jj] + ui * nl[jj] + t * yl[jj]
				MfBigMathInt.sa.m_InnerList[j] := c & MfBigMathInt.mask
				c >>= MfBigMathInt.bpe
				j++
			}
			while (j < ky)
			{
				jj := j + 1
				c += MfBigMathInt.sa.m_InnerList[jj] + ui * nl[jj] + t * y[jj]
				MfBigMathInt.sa.m_InnerList[j] := c & MfBigMathInt.mask
				c >>= MfBigMathInt.bpe
				j++
			}
			while (j < kn - 4)
			{
				jj := j + 1
				c += MfBigMathInt.sa.m_InnerList[jj] + ui * nl[jj]
				MfBigMathInt.sa.m_InnerList[j] := c & MfBigMathInt.mask
				c >>= MfBigMathInt.bpe
				j++
				jj++
				c += MfBigMathInt.sa.m_InnerList[jj] + ui * nl[jj]
				MfBigMathInt.sa.m_InnerList[j] := c & MfBigMathInt.mask
				c >>= MfBigMathInt.bpe
				j++
				jj++
				c += MfBigMathInt.sa.m_InnerList[jj] + ui * nl[jj]
				MfBigMathInt.sa.m_InnerList[j] := c & MfBigMathInt.mask
				c >>= MfBigMathInt.bpe
				j++
				jj++
				c += MfBigMathInt.sa.m_InnerList[jj] + ui * nl[jj]
				MfBigMathInt.sa.m_InnerList[j] := c & MfBigMathInt.mask
				c >>= MfBigMathInt.bpe
				j++
				jj++
				c += MfBigMathInt.sa.m_InnerList[jj] + ui * nl[jj]
				MfBigMathInt.sa.m_InnerList[j] := c & MfBigMathInt.mask
				c >>= MfBigMathInt.bpe
				j++
			}
			while (j < kn)
			{
				jj := j + 1
				c += MfBigMathInt.sa.m_InnerList[jj] + ui * nl[jj]
				MfBigMathInt.sa.m_InnerList[j] := c & MfBigMathInt.mask
				c >>= MfBigMathInt.bpe
				j++
			}
			while (j < ks)
			{
				jj := j + 1
				c += MfBigMathInt.sa.m_InnerList[jj]
				MfBigMathInt.sa.m_InnerList[j] := c & MfBigMathInt.mask
				c >>= MfBigMathInt.bpe
				j++
			}
			MfBigMathInt.sa.m_InnerList[j] := c & MfBigMathInt.mask
			i++
		}
		if (!MfBigMathInt.Greater(n, MfBigMathInt.sa))
		{
			MfBigMathInt.sub_(MfBigMathInt.sa, n)
		}
		MfBigMathInt.copy_(x, MfBigMathInt.sa)
	}
; 	End:mont_ ;}
; End:Methods ;}
	
;{ Internal Methods
	_ParseInt(s) {
		if (MfObject.IsObjInstance(s, MfListVar))
		{
			lst := s
		}
		else
		{
			
			lst := MfListVar.FromString(s, false) ; ignore whitespace
		}
		
		if (lst.m_Count = 0)
		{
			return 0
		}
		i := 0
		IsNeg := false
		StartIndex := 0
		ll := lst.m_InnerList
		if (ll[1] = "-")
		{
			i++
			StartIndex++
			IsNeg := true
		}
		if (ll[1] = "+")
		{
			i++
			StartIndex++
		}
		i++ ; Move to one base index
		while (i <= lst.m_Count)
		{
			if(Mfunc.IsInteger(ll[i]) = false)
			{
				break
			}
			i++

		}
		i-- ; Move to zero based index
		int := lst.ToString("",StartIndex, i)
		if (MfString.IsNullOrEmpty(int))
		{
			return 0
		}
		else if (int = 0)
		{
			return 0
		}
		else
		{
			int := int + 0
			return IsNeg? -int:int
		}
		
	}
;{ 	Random_
	; generates a random number between 0.0 and 1.0 with decimal percision of 16
	Random_() {
		wf := A_FormatFloat
		SetFormat, FloatFast, 0.16
		rand := 0.0
		rand := Mfunc.Random(0.0, 1.0)
		SetFormat, FloatFast, %wf%
		return rand
	}
; 	End:Random_ ;}
; End:Internal Methods ;}

;{ Internal Classes
;{ 	class DigitsChars
	class DigitsChars extends MfObject
	{
		m_htKeyChar := ""
		m_IndexLst := ""
		__new() {
			base.__new()
			if (this.__Class != "MfBigMathInt.DigitsChars" && this.__Class != "DigitsChars") {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfString"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			_digitStr := "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_=!@#$%^&*()[]{}|;:,.<>/?``~ \'""+-"
			this.m_htKeyChar := new MfHashtable(39)
			this.m_IndexLst := new MfListVar()
			i := 0
			Loop, Parse, _digitStr
			{
				if (i < 36 || i > 61)
				{
					this.m_htKeyChar.Add(A_LoopField, i) ; Add char and index
				}
				this.m_IndexLst.Add(A_LoopField) ; Add char and index
				i++
			
			}
		}
	;{ 	methods

		Contains(c) {
			return this.m_htKeyChar.Contains(c)
		}

		IndexOf(c) {
			; hash table is not case sensitive so lowercase a-z was skippped
			retval := this.m_htKeyChar.m_innerHashTable[c]
			if ((retval > 9) && (retval < 36) && (c ~= "[a-z]"))
			{
				retval += 26
			}
			return retval
		}
	/*
		Method: Is()
		Overrides MfObject.Is()
		
			OutputVar := instance.Is(ObjType)

		Is(ObjType)
			Gets if current instance of MfEnum.EnumItem is of the same type as ObjType or derived from ObjType.
		Parameters
			ObjType
				The object or type to compare to this instance Type.
				ObjType can be an instance of MfType or an object derived from MfObject or an instance of or a string containing
				the name of the object type such as "MfObject"
		Returns
			Returns true if current object instance is of the same Type as the ObjType or if current instance is derived
			from ObjType or if ObjType = "MfEnum.EnumItem" or ObjType = "EnumItem"; Otherwise false.
		Remarks
			If a string is used as the Type case is ignored so "MfObject" is the same as "mfobject"
	*/
		Is(ObjType) {
			typeName := MfType.TypeOfName(ObjType)
			if ((typeName = "MfBigMathInt.DigitsChars") || (typeName = "DigitsChars")) {
				return true
			}
			return base.Is(typeName)
		}
	; End:Is() ;}
; 	End:methods ;}
	;{	IsFixedSize[]
;{ 	Properties
	;{ Item
		/*!
			Property: CharIndex [get]
				Gets the CharIndex value associated with the this instance
			Value:
				Var representing the CharIndex property of the instance
			Remarks:
				Readonly Property
		*/
		Item[index]
		{
			get {
				return this.m_IndexLst.m_InnerList[index + 1]
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, "CharIndex")
				Throw ex
			}
		}
	; End:Item ;}
	}
; 	End:class DigitsChars ;
;{ Internal Classes

}