; ahk: console
#NoEnv
SetBatchLines -1
#Warn All, StdOut

#Include <testcase-libs>
#Include <system>

#Include %A_ScriptDir%\..\bitset.ahk

class BitSetTest extends TestCase {

	requires() {
		return [TestCase, Arrays, System, Math
				, BitSet.requires()*]
	}

	@Test_bitSetClass() {
		this.assertEquals(BitSet.ADDRESS_BITS_PER_WORD, 6)
		This.assertEquals(BitSet.BITS_PER_WORD, 64)
		this.assertEquals(BitSet.BIT_INDEX_MASK, 63)
		this.assertEquals(BitSet.WORD_MASK, SL(0xffffffffffffffff))
		this.assertTrue(IsFunc(BitSet.wordIndex))
		this.assertTrue(IsFunc(BitSet.checkInvariants))
		this.assertTrue(IsFunc(BitSet.recalculateWordsInUse))
		this.assertTrue(IsFunc(BitSet.__new))
		this.assertTrue(IsFunc(BitSet.initWords))
		this.assertTrue(IsFunc(BitSet.valueOfLong))
		this.assertTrue(IsFunc(BitSet.toLongArray))
		this.assertTrue(IsFunc(BitSet.expandTo))
		this.assertTrue(IsFunc(BitSet.checkRange))
		this.assertTrue(IsFunc(BitSet.flip))
		this.assertTrue(IsFunc(BitSet.length))
		this.assertTrue(IsFunc(BitSet.nextSetBit))
	}

	@Test_new() {
		bs := new BitSet()
		this.assertTrue(IsObject(bs))
		this.assertEquals(bs.length(), 0)
		bs := new BitSet(0)
		this.assertTrue(IsObject(bs))
		this.assertEquals(bs.length(), 0)
		bs := new BitSet(16)
	    this.assertEquals(bs.length(), 0)
		bs.set(0)
		this.assertEquals(bs.length(), 1)
		bs.set(1)
		this.assertEquals(bs.length(), 2)
		bs.set(2)
		this.assertEquals(bs.length(), 3)
		bs.set(127)
		this.assertEquals(bs.length(), 128)
		bs := BitSet.valueOfLong([42])
		bs := BitSet.valueOfLong([0])
		this.assertException(BitSet, "__new",,, -1)
	}

	@Test_wordIndex() {
		this.assertEquals(BitSet.wordIndex(63), 0)
		this.assertEquals(BitSet.wordIndex(64), 1)
		this.assertEquals(BitSet.wordIndex(319), 4)
		this.assertEquals(BitSet.wordIndex(320), 5)
		this.assertEquals(BitSet.wordIndex(196 - 48 - 1) + 1, 3)
	}

	@Test_initWords() {
		bs := new BitSet(320)
		bs.initWords(320)
		this.assertEquals(bs.words.minIndex(), 0)
		this.assertEquals(bs.words.maxIndex(), 4)
	}

	@Test_length() {
		bs1 := new BitSet(8)
		bs2 := new BitSet(8)
		bs1.set(0)
		bs1.set(1)
		bs1.set(2)
		bs1.set(3)
		bs1.set(4)
		bs1.set(5)
		bs2.set(2)
		bs2.set(4)
		bs2.set(6)
		bs2.set(8)
		bs2.set(10)
		this.assertEquals(Arrays.equal(bs1.toByteArray(), [0, 1, 2, 3, 4, 5]))
		this.assertEquals(Arrays.equal(bs2.toByteArray(), [2, 4, 6, 8, 10]))
		this.assertEquals(bs1.length(), 6)
		this.assertEquals(bs2.length(), 11)

		bs := new BitSet(320)
		bs.set(320)
		this.assertEquals(bs.length(), 321)
	}

	@Test_nextSetBit() {
		bs := new BitSet([102])
		this.assertException(bs, "nextSetBit",,, -1)
		;        76543210
		;        --------
		; 102b = 01100110
		this.assertEquals(bs.nextSetBit(0), 1)
		this.assertEquals(bs.nextSetBit(1), 1)
		this.assertEquals(bs.nextSetBit(2), 2)
		this.assertEquals(bs.nextSetBit(3), 5)
		this.assertEquals(bs.nextSetBit(4), 5)
		this.assertEquals(bs.nextSetBit(5), 5)
		this.assertEquals(bs.nextSetBit(6), 6)
		this.assertEquals(bs.nextSetBit(7), -1)
	}

	@Test_nextClearBit() {
		bs := new BitSet([102])
		this.assertException(bs, "nextClearBit",,, -1)
		;        76543210
		;        --------
		; 102b = 01100110
		this.assertEquals(bs.nextClearBit(0), 0)
		this.assertEquals(bs.nextClearBit(1), 3)
		this.assertEquals(bs.nextClearBit(2), 3)
		this.assertEquals(bs.nextClearBit(3), 3)
		this.assertEquals(bs.nextClearBit(4), 4)
		this.assertEquals(bs.nextClearBit(5), 7)
		this.assertEquals(bs.nextClearBit(6), 7)
		this.assertEquals(bs.nextClearBit(7), 7)
		this.assertEquals(bs.nextClearBit(8), 8)
		bs2 := new BitSet(64)
		bs2.set(32)
		bs2.set(33)
		bs2.set(35)
		this.assertEquals(bs2.nextClearBit(32), 34)
		bs3 := new BitSet([254])
		this.assertEquals(bs3.nextClearBit(0), 0)
		this.assertEquals(bs3.nextClearBit(1), 8)
		this.assertEquals(bs3.nextClearBit(2), 8)
		this.assertEquals(bs3.nextClearBit(98), 98)
	}

	@Test_toString() {
		bs := new BitSet()
		this.assertEquals(bs.toString(), "{}")
		this.assertEquals(bs.length(), 0)
		bs := new BitSet([102])
		this.assertEquals(bs.toString(), "{1, 2, 5, 6}")

		bs := new BitSet([1454, 102])
		this.assertEquals(bs.toString()
				, "{1, 2, 3, 5, 7, 8, 10, 65, 66, 69, 70}")
	}

	@Test_valueOfLongs() {
		bs := new BitSet().valueOfLong([1527])
		this.assertTrue(Arrays.equal(bs.toLongArray(), [1527]))
	}

	@Test_valueOfBytes() {
		bs := new BitSet().valueOfByte([9, 15, 0, 27])
		this.assertTrue(Arrays.equal(bs.toByteArray(), [9, 15, 0, 27]))
	}

	@Test_flip() {
		bs := new BitSet([102])
		bs.flip(0)
		this.assertEquals(bs.words[0], 103)
		bs.flip(1)
		this.assertEquals(bs.words[0], 101)
		bs.flip(1)
		this.assertEquals(bs.words[0], 103)
		this.assertException(bs, "flip", "", "IndexOutOfBoundsException", -1)

		bs := new BitSet([102])
		this.assertEquals(bs.words[0], 102)
		bs.flipRange(0, 7)
		this.assertEquals(bs.words[0], 25)
		bs.flipRange(1, 1)
		this.assertEquals(bs.words[0], 25)

		bs := new BitSet(320)
		bs.flipRange(90, 240)
		this.assertEquals(bs.toString(), "{90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239}") ; ahklint-ignore: W002
		this.assertTrue(Arrays.equal(bs.toLongArray()
				, [0, -67108864, -1, 281474976710655]))
	}

	@Test_set() {
		bs := new BitSet([102])
		bs.set(0)
		this.assertEquals(bs.words[0], 103)
		bs.set(4)
		this.assertEquals(bs.words[0], 119)
		bs.set(1)
		this.assertEquals(bs.words[0], 119)
		this.assertException(bs, "Set", "", "IndexOutOfBoundsException", -1)

		bs := new BitSet([102])
		bs.setRange(2, 6)
		this.assertEquals(bs.words[0], 126)

		bs := new BitSet()
		bs.set(127)
		this.assertTrue(bs.get(127))
		this.assertEquals(bs.length(), 128)
	}

	@Test_clear() {
		bs := new BitSet([102])
		this.assertException(bs, "clear",,, -1)
		bs.clear(1)
		this.assertEquals(bs.words[0], 100)
		bs.clear(6)
		this.assertEquals(bs.words[0], 36)
		bs.clear(3)
		this.assertEquals(bs.words[0], 36)
		this.assertException(bs, "Set", "", "IndexOutOfBoundsException", -1)

		bs := new BitSet([102])
		bs.clearRange(2, 6)
		this.assertEquals(bs.words[0], 66)

		bs.clearRange(2, 2)
		this.assertEquals(bs.words[0], 66)

		bs.clearRange(99, 123)
		this.assertEquals(bs.words[0], 66)

		bs.clear()
		this.assertEquals(bs.words[0], 0)

		bs.clear(999)
		this.assertEquals(bs.words[0], 0)

		bs.set(2)
		bs.clearRange(2, 123)
		this.assertEquals(bs.words[0], 0)
	}

	@Test_clearRange() {
		bs := new BitSet(320)
		bs.setRange(0, 320)
		this.assertTrue(Arrays.equal(bs.toLongArray(), [-1, -1, -1, -1, -1]))
		bs.clearRange(63, 216)
		this.assertEquals(bs.length(), 320)
		this.assertEquals(bs.toString()
				, "{0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269, 270, 271, 272, 273, 274, 275, 276, 277, 278, 279, 280, 281, 282, 283, 284, 285, 286, 287, 288, 289, 290, 291, 292, 293, 294, 295, 296, 297, 298, 299, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313, 314, 315, 316, 317, 318, 319}") ; ahklint-ignore: W002
		 ; TestCase.writeLine(Arrays.toString(bs.toLongArray()))
		; this.assertTrue(Arrays.equal(bs.toLongArray()
				; , [9223372036854775807, 0, 0, -16777216, -1])) ; QUESTION: Why
				; does Java get this data (4th word has another value)?
	}

	@Test_setValue() {
		bs := new BitSet([102])
		bs.setValue(0, true)
		this.assertEquals(bs.words[0], 103)
		bs.setValue(0, false)
		this.assertEquals(bs.words[0], 102)
		this.assertException(bs, "Set", "", "IndexOutOfBoundsException", -1)
	}

	@Test_get() {
		bs := new BitSet([102])
		this.assertException(bs, "get",,, -1)
		this.assertEquals(bs.get(0), 0)
		this.assertEquals(bs.get(1), 1)
		this.assertEquals(bs.get(2), 1)
		this.assertEquals(bs.get(3), 0)
		this.assertEquals(bs.get(4), 0)
		this.assertEquals(bs.get(5), 1)
		this.assertEquals(bs.get(6), 1)
		this.assertEquals(bs.get(7), 0)
	}

	@Test_setRange() {
		bs := new BitSet(320)
		bs.setRange(1, 320)
		this.assertTrue(Arrays.equal(bs.toLongArray(), [-2, -1, -1, -1, -1]))
		bs.setRange(1,1)
		this.assertTrue(Arrays.equal(bs.toLongArray(), [-2, -1, -1, -1, -1]))
	}

	@Test_getRange() {
		bs := new BitSet([102])
		this.assertException(bs, "getRange",,, -5, 5)
		this.assertException(bs, "getRange",,, 5, -5)
		this.assertException(bs, "getRange",,, 5, 2)
		bs2 := bs.getRange(1, 6)
		this.assertEquals(bs2.words[0], 19)
		this.assertTrue(IsObject(bs.getRange(0, 0)))
		this.assertTrue(IsObject(bs.getRange(1, 99)))
		bs2 := new BitSet(320)
		bs2.setRange(63, 216)
		this.assertEquals(bs2.length(), 216)
		bs3 := bs2.getRange(48, 196)
		this.assertEquals(bs3.toString(), "{15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147}") ; ahklint-ignore: W002
		this.assertEquals(bs3.toLongArray().count(), 3)
		this.assertEquals(bs3.toLongArray()[1], -32768)
		this.assertEquals(bs3.toLongArray()[2], -1)
		this.assertEquals(bs3.toLongArray()[3], 1048575)
		this.assertTrue(Arrays.equal(bs3.toLongArray(), [-32768, -1, 1048575]))
	}

	@Test_useCase() {
		bits1 := new BitSet(16)
		bits2 := new BitSet(16)
		loop 16 {
			i := A_Index-1
			if (Mod(i, 2) = 0) {
				bits1.set(i)
			}
			if (Mod(i, 5) != 0) {
				bits2.set(i)
			}
		}
		this.assertEquals(bits1.toString(), "{0, 2, 4, 6, 8, 10, 12, 14}")
		this.assertEquals(bits2.toString()
				, "{1, 2, 3, 4, 6, 7, 8, 9, 11, 12, 13, 14}")

		bits2.and(bits1)
		this.assertEquals(bits2.toString(), "{2, 4, 6, 8, 12, 14}")

		bits2.or(bits1)
		this.assertEquals(bits2.toString(), "{0, 2, 4, 6, 8, 10, 12, 14}")

		bits2.xor(bits1)
		this.assertEquals(bits2.toString(), "{}")

		bits2.set(1)
		bits2.andNot(bits1)
		this.assertEquals(bits2.toString(), "{1}")
	}

	@Test_or() {
		bits1 := new BitSet(8)
		bits2 := new BitSet(64)
		this.assertEquals(bits1.or(bits1), "")
		bits1.set(0)
		bits1.set(1)
		bits1.set(2)
		bits1.set(3)
		bits1.set(4)
		bits1.set(5)
		bits2.set(64)
		bits1.or(bits2)
		this.assertEquals(bits1.toString(), "{0, 1, 2, 3, 4, 5, 64}")
	}

	@Test_and() {
		bits1 := new BitSet(8)
		bits2 := new BitSet(64)
		this.assertEquals(bits1.or(bits1), "")
		bits1.set(0)
		bits1.set(1)
		bits1.set(2)
		bits1.set(3)
		bits1.set(4)
		bits1.set(5)
		bits2.set(3)
		bits2.set(5)
		bits2.set(64)
		bits1.and(bits2)
		this.assertEquals(bits1.toString(), "{3, 5}")
		bits1.and(bits1)
		this.assertEquals(bits1.toString(), "{3, 5}")
		bits2.and(bits1)
		this.assertEquals(bits2.toString(), "{3, 5}")
		
	}

	@Test_xor() {
		bits1 := new BitSet(64)
		bits2 := new BitSet(8)
		this.assertEquals(bits1.or(bits1), "")
		bits1.set(0)
		bits1.set(1)
		bits1.set(2)
		bits1.set(3)
		bits1.set(4)
		bits1.set(5)
		bits1.set(64)
		bits2.set(3)
		bits2.set(5)
		bits2.xor(bits1)
		this.assertEquals(bits1.toString(), "{0, 1, 2, 3, 4, 5, 64}")
	}

	@Test_cardinality() {
		bits1 := new BitSet(64)
		bits1.set(0)
		bits1.set(1)
		bits1.set(2)
		bits1.set(3)
		bits1.set(4)
		bits1.set(5)
		bits1.set(64)
		this.assertEquals(bits1.cardinality(), 7)
	}
}

exitapp BitSetTest.runTests()
