; ahk: console
#NoEnv
#Warn All, StdOut

#Include <testcase-libs>
#Include <base64>

#Include %A_ScriptDir%\..\crypto.ahk

class CryptoTest extends TestCase {

	@Test_Class() {
		this.assertTrue(IsObject(Crypto))
		this.assertException(Crypto, "__New")
		this.assertTrue(IsFunc(Crypto.encrypt))
		this.assertTrue(IsFunc(Crypto.decrypt))
		this.assertTrue(IsFunc(Crypto.isValidAlgorithm))
	}

	@Test_Class_RC4() {
		this.assertTrue(IsObject(Crypto.RC4))
		this.assertException(Crypto.RC4, "__New")
		this.assertTrue(IsFunc(Crypto.RC4.encodeDecode))
	}

	@Test_Class_XOR() {
		this.assertTrue(IsObject(Crypto.XOR))
		this.assertException(Crypto.XOR, "__New")
		this.assertTrue(IsFunc(Crypto.XOR.encodeDecode))
	}

	@Test_Class_MD5() {
		this.assertTrue(IsObject(Crypto.MD5))
		this.assertException(Crypto.MD5, "__New")
		this.assertTrue(IsFunc(Crypto.MD5.encode))
	}

	@Test_RC4() {
		_msg := "Dummy"
		len := Crypto.RC4.encodeDecode(msg := _msg, "secret")
		this.assertEquals(len, 10)
		this.assertEquals(NumGet(msg, 0, "UChar"), 0x2e)
		this.assertEquals(NumGet(msg, 1, "UChar"), 0xd3)
		this.assertEquals(NumGet(msg, 2, "UChar"), 0x32)
		this.assertEquals(NumGet(msg, 3, "UChar"), 0xb5)
		this.assertEquals(NumGet(msg, 4, "UChar"), 0x71)
		this.assertEquals(NumGet(msg, 5, "UChar"), 0x90)
		this.assertEquals(NumGet(msg, 6, "UChar"), 0xe8)
		this.assertEquals(NumGet(msg, 7, "UChar"), 0x8f)
		this.assertEquals(NumGet(msg, 8, "UChar"), 0xd8)
		this.assertEquals(NumGet(msg, 9, "UChar"), 0xcb)
		Crypto.RC4.encodeDecode(msg, "secret")
		this.assertEquals(msg, _msg)
	}

	@Test_XOR() {
		_msg := "Dummy"
		len := Crypto.XOR.encodeDecode(msg := _msg, "secret")
		this.assertEquals(len, 10)
		this.assertEquals(NumGet(msg, 0, "UChar"), 0x37)
		this.assertEquals(NumGet(msg, 1, "UChar"), 0x00)
		this.assertEquals(NumGet(msg, 2, "UChar"), 0x10)
		this.assertEquals(NumGet(msg, 3, "UChar"), 0x00)
		this.assertEquals(NumGet(msg, 4, "UChar"), 0x0e)
		this.assertEquals(NumGet(msg, 5, "UChar"), 0x00)
		this.assertEquals(NumGet(msg, 6, "UChar"), 0x1f)
		this.assertEquals(NumGet(msg, 7, "UChar"), 0x00)
		this.assertEquals(NumGet(msg, 8, "UChar"), 0x1c)
		this.assertEquals(NumGet(msg, 9, "UChar"), 0x00)
		Crypto.XOR.encodeDecode(msg, "secret")
		this.assertEquals(msg, _msg)
	}

	@Test_MD5() {
		this.assertEquals(Crypto.MD5.encode(_msg := "")
				, "d41d8cd98f00b204e9800998ecf8427e")
		l0 := ("test").put(st0, "cp0")
		this.assertEquals(Crypto.MD5.encode(st0, l0)
				, "098f6bcd4621d373cade4e832627b4f6")
		l0 := ("Franz jagt im komplett verwahrlosten Taxi quer durch Bayern")
				.Put(st0)
		this.assertEquals(Crypto.MD5.encode(st0, l0)
				, "a3cca2b2aa1e3b5b3b5aad99a8529074")
		l0 := ("Frank jagt im komplett verwahrlosten Taxi quer durch Bayern")
				.Put(st0)
		this.assertEquals(Crypto.MD5.encode(st0, l0)
				, "7e716d0e702df0505fc72e2b89467910")
	}

	@Test_Constants() {
		this.assertTrue(Crypto.ALGORITHM_RC4, 1)
		this.assertTrue(Crypto.ALGORITHM_XOR, 2)
	}

	@Test_IsValidAlgorithm() {
		this.assertFalse(Crypto.isValidAlgorithm(0))
		this.assertTrue(Crypto.isValidAlgorithm(1))
		this.assertTrue(Crypto.isValidAlgorithm(2))
		this.assertFalse(Crypto.isValidAlgorithm(3))
		this.assertFalse(Crypto.isValidAlgorithm(-1))
		this.assertFalse(Crypto.isValidAlgorithm(4))
		this.assertFalse(Crypto.isValidAlgorithm(""))
		this.assertFalse(Crypto.isValidAlgorithm("RC4"))
	}

	@Test_Encrypt() {
		this.assertException(Crypto, "Encrypt", "", ""
				, m := "Dummy", "Cipher", "InvalidAlgorithm")
		this.assertEquals(Crypto.encrypt(m := "Dummy", "secret"
				, Crypto.ALGORITHM_RC4), "{RC4}LtMytXGQ6I/Yyw==")
		this.assertEquals(Crypto.encrypt(m := "Dummy", "secret"
				, Crypto.ALGORITHM_XOR), "{XOR}NwAQAA4AHwAcAA==")
		this.assertEquals(Crypto.encrypt(m := "marsreise"
				, "00481-827-6123453-74320", Crypto.ALGORITHM_RC4)
				, "{RC4}WNyp+ZJ91Yn2j9ls3wQEJaYG")
	}

	@Test_Decrypt() {
		; Ansi example:
		/*
		Crypto.Decrypt(m := "{xor}Njs6OjEyODIr", "_")
		VarSetCapacity(m, -1)
		this.AssertEquals(m, "dummy")
		*/

		Crypto.decrypt(m := "{RC4}LtMytXGQ6I/Yyw==", "secret")
		VarSetCapacity(m, -1)
		this.assertEquals(m, "Dummy")

		Crypto.decrypt(m := "{XOR}NwAQAA4AHwAcAA==", "secret")
		VarSetCapacity(m, -1)
		this.assertEquals(m, "Dummy")

		Crypto.decrypt(m := "{xor}KTZyb21yPS8yci8+bGZn", "_")
		VarSetCapacity(m, -1)
		Crypto.decrypt(m := "{xor}LzIyNCs2MTk=", "_")
		VarSetCapacity(m, -1)

		Crypto.decrypt(m := "{RC4}WNyp+ZJ91Yn2j9ls3wQEJaYG"
				, "00481-827-6123453-74320")
		VarSetCapacity(m, -1)
		this.assertEquals(m, "marsreise")

		Crypto.decrypt(m := "LtMytXGQ6I/Yyw==", "secret",, Crypto.ALGORITHM_RC4)
		VarSetCapacity(m, -1)
		this.assertEquals(m, "Dummy")
	}
}

exitapp CryptoTest.runTests()
