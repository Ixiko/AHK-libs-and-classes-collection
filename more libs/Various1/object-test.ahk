; ahk: console
#NoEnv
#Warn All, StdOut

#Include <ansi>
#Include <arrays>
#Include <console>
#Include <datatable>
#Include <math>
#Include <string>
#Include <testcase>

#Include %A_ScriptDir%\..\object.ahk

class ObjectTest extends TestCase {

	@Test_ObjectClass() {
		this.assertTrue(IsFunc(Object.serialize))
		this.assertTrue(IsFunc(Object.deserialize))
		this.assertTrue(IsFunc("object_Serialize"))
		this.assertTrue(IsFunc("object_Deserialize"))
		this.assertTrue(IsFunc(Object.instanceOf))
		this.assertTrue(IsFunc(Object.compare))
		this.assertTrue(IsObject(Object.ini))
		this.assertTrue(IsFunc(Object.ini.__new))
		this.assertTrue(IsFunc(Object.ini.write))
	}

	@Test_Ini_Write_Read() {
		_ini := New Object.ini(A_Temp "\object-test.ini")
		_ini.write("MySection1", "MyKey1", "MyValue-A")
		_ini.write("MySection1", "MyKey2", "MyValue-B")
		_ini.write("MySection2", "MyKey3", "MyValue-C")
		_ini.write("MySection3", "MyKey4", "MyValue-D")
		this.assertEquals(_ini.read("MySection1", "MyKey1"), "MyValue-A")
		this.assertEquals(_ini.read("MySection1", "MyKey2"), "MyValue-B")
		this.assertEquals(_ini.read("MySection3", "MyKey4"), "MyValue-D")
		this.assertEquals(_ini.read("MySection2", "MyKey3"), "MyValue-C")
	}

	@Test_New() {
		this.assertException(Object, "__New")
	}

	@Test_Serialize_Object() {
		; ahklint-ignore-begin: W003
		o := { Herausgeber: "Xema"
			  , Nummer: "1234-5678-9012-3456"
			  , Deckung: 2.0e+6
			  , Waehrung: "EURO"
			  , Inhaber: { Name: "Mustermann"
						 , Vorname: "Max"
						 , maennlich: true
						 , Kinder: []
						 , Hobbys: [ "Reiten", "Golfen", "Lesen" ]
						 , Alter: 42
						 , Partner: "Erika" }
			  , Konto: { Nummer: 123456789
				   	   , BLZ: 10020003 } }
		; ahklint-ignore-end

		Object.serialize(o, A_Temp "\object-test.ini")

		IniRead _Herausgeber, %A_Temp%\object-test.ini,, Herausgeber
		this.assertEquals(_Herausgeber, "Xema")
		IniRead _Nummer, %A_Temp%\object-test.ini,, Nummer
		this.assertEquals(_Nummer, "1234-5678-9012-3456")
		IniRead _Deckung, %A_Temp%\object-test.ini,, Deckung
		this.assertEquals(_Deckung, 2.0e+6)
		IniRead _Waehrung, %A_Temp%\object-test.ini,, Waehrung
		this.assertEquals(_Waehrung, "EURO")
		IniRead _Name, %A_Temp%\object-test.ini, Inhaber, Name
		this.assertEquals(_Name, "Mustermann")
		IniRead _Vorname, %A_Temp%\object-test.ini, Inhaber, Vorname
		this.assertEquals(_Vorname, "Max")
		IniRead _maennlich, %A_Temp%\object-test.ini, Inhaber, maennlich
		this.assertEquals(_maennlich, true)
		IniRead _Kinder, %A_Temp%\object-test.ini, Inhaber.kinder
		this.assertEquals(_Kinder, "")
		IniRead _Hobbys, %A_Temp%\object-test.ini, Inhaber.hobbys, 1
		this.assertEquals(_Hobbys, "Reiten")
		IniRead _Hobbys, %A_Temp%\object-test.ini, Inhaber.hobbys, 2
		this.assertEquals(_Hobbys, "Golfen")
		IniRead _Hobbys, %A_Temp%\object-test.ini, Inhaber.hobbys, 3
		this.assertEquals(_Hobbys, "Lesen")
		IniRead _Hobbys, %A_Temp%\object-test.ini, Inhaber.hobbys, 4
		this.assertEquals(_Hobbys, "ERROR")
		IniRead _Alter, %A_Temp%\object-test.ini, Inhaber, Alter
		this.assertEquals(_Alter, 42)
		IniRead _Partner, %A_Temp%\object-test.ini, Inhaber, Partner
		this.assertEquals(_Partner, "Erika")
		IniRead _Nummer, %A_Temp%\object-test.ini, Konto, Nummer
		this.assertEquals(_Nummer, 123456789)
		IniRead _BLZ, %A_Temp%\object-test.ini, Konto, BLZ
		this.assertEquals(_BLZ, 10020003)
	}

	@Test_Serialize_Object2() {
		this.assertException(Object, "Serialize", "", ""
				, "FooBar", A_Temp "\object-test.ini")
	}

	@Depend_@Test_Deserialize_Object() {
		return "@Test_Serialize_Object"
	}
	@Test_Deserialize_Object() {
		o := Object.deserialize(A_Temp "\object-test.ini")
		this.assertEquals(o.herausgeber, "Xema")
		this.assertEquals(o.nummer, "1234-5678-9012-3456")
		this.assertEquals(o.deckung, 2.0e+6)
		this.assertEquals(o.waehrung, "EURO")
		this.assertEquals(o.inhaber.name, "Mustermann")
		this.assertEquals(o.inhaber.vorname, "Max")
		this.assertEquals(o.inhaber.maennlich, true)
		this.assertEquals(o.inhaber.kinder.maxIndex(), "")
		this.assertTrue(IsObject(o.inhaber.kinder))
		this.assertEquals(o.inhaber.hobbys[1], "Reiten")
		this.assertEquals(o.inhaber.hobbys[2], "Golfen")
		this.assertEquals(o.inhaber.hobbys[3], "Lesen")
		this.assertEquals(o.inhaber.alter, 42)
		this.assertEquals(o.inhaber.partner, "Erika")
		this.assertEquals(o.konto.nummer, 123456789)
		this.assertEquals(o.konto.BLZ, 10020003)
	}

	@Test_Check_Testclass() {
		this.assertTrue(IsObject(KKunde))
		this.assertTrue(IsObject(KKunde.KInhaber))
		this.assertTrue(IsObject(KKunde.KKonto))
	}

	@Test_Serialize_Class() {
		o := new KKunde()
		Object.serialize(o, A_Temp "\class-test.ini")

		; Class variable
		IniRead _M, %A_Temp%\class-test.ini, KInhaber, M
		this.assertEquals(_M, true)
		IniRead _W, %A_Temp%\class-test.ini, KInhaber, W
		this.assertEquals(_W, false)

		; Instance variable
		IniRead _Herausgeber, %A_Temp%\class-test.ini,, Herausgeber
		this.assertEquals(_Herausgeber, "Xema")
		IniRead _Nummer, %A_Temp%\class-test.ini,, Nummer
		this.assertEquals(_Nummer, "1234-5678-9012-3456")
		IniRead _Deckung, %A_Temp%\class-test.ini,, Deckung
		this.assertEquals(_Deckung, 2.0e+6)
		IniRead _Waehrung, %A_Temp%\class-test.ini,, Waehrung
		this.assertEquals(_Waehrung, "EURO")
		IniRead _Name, %A_Temp%\class-test.ini, Inhaber, Name
		this.assertEquals(_Name, "Mustermann")
		IniRead _Vorname, %A_Temp%\class-test.ini, Inhaber, Vorname
		this.assertEquals(_Vorname, "Max")
		IniRead _maennlich, %A_Temp%\class-test.ini, Inhaber, maennlich
		this.assertEquals(_maennlich, true)
		IniRead _Kinder, %A_Temp%\class-test.ini, Inhaber.kinder
		this.assertEquals(_Kinder, "")
		IniRead _Hobbys, %A_Temp%\class-test.ini, Inhaber.hobbys, 1
		this.assertEquals(_Hobbys, "Reiten")
		IniRead _Hobbys, %A_Temp%\class-test.ini, Inhaber.hobbys, 2
		this.assertEquals(_Hobbys, "Golfen")
		IniRead _Hobbys, %A_Temp%\class-test.ini, Inhaber.hobbys, 3
		this.assertEquals(_Hobbys, "Lesen")
		IniRead _Hobbys, %A_Temp%\class-test.ini, Inhaber.hobbys, 4
		this.assertEquals(_Hobbys, "ERROR")
		IniRead _Alter, %A_Temp%\class-test.ini, Inhaber, Alter
		this.assertEquals(_Alter, 42)
		IniRead _Partner, %A_Temp%\class-test.ini, Inhaber, Partner
		this.assertEquals(_Partner, "Erika")
		IniRead _Nummer, %A_Temp%\class-test.ini, Konto, Nummer
		this.assertEquals(_Nummer, 123456789)
		IniRead _BLZ, %A_Temp%\class-test.ini, Konto, BLZ
		this.assertEquals(_BLZ, 10020003)
	}

	@Test_Deserialize_Class() {
		o := Object.deserialize(A_Temp "\class-test.ini")
		this.assertEquals(o.herausgeber, "Xema")
		this.assertEquals(o.nummer, "1234-5678-9012-3456")
		this.assertEquals(o.deckung, 2.0e+6)
		this.assertEquals(o.waehrung, "EURO")
		this.assertEquals(o.inhaber.name, "Mustermann")
		this.assertEquals(o.inhaber.vorname, "Max")
		this.assertEquals(o.inhaber.maennlich, true)
		this.assertEquals(o.inhaber.kinder.maxIndex(), "")
		this.assertTrue(IsObject(o.inhaber.kinder))
		this.assertEquals(o.inhaber.hobbys[1], "Reiten")
		this.assertEquals(o.inhaber.hobbys[2], "Golfen")
		this.assertEquals(o.inhaber.hobbys[3], "Lesen")
		this.assertEquals(o.inhaber.alter, 42)
		this.assertEquals(o.inhaber.partner, "Erika")
		this.assertEquals(o.konto.nummer, 123456789)
		this.assertEquals(o.konto.BLZ, 10020003)
	}

	@Test_Deserialize_Class2() {
		_ini =
		( LTrim RTrim0
			[]
			Deckung=3000
			Herausgeber=Mexa
			Nummer=0815-4711-0123-4567
			Waehrung=USD
			[__Class]
			__Class=KKunde
			[Inhaber]
			Alter=24
			M=0
			maennlich=0
			Name=Horstmannskoetter
			Partner=Kevin
			Vorname=Jaqueline
			W=1
			[Inhaber.hobbys]
			1=Tanzen
			2=Reisen
			[Inhaber.kinder]
			1=Chantal
			[KInhaber]
			M=0
			W=1
			[Konto]
			BLZ=50050010
			Nummer=16112017
		)
		f := FileOpen(A_Temp "\class-test.ini", "w")
		f.writeLine(_ini)
		f.close()

		o := Object.deserialize(A_Temp "\class-test.ini")
		this.assertEquals(o.herausgeber, "Mexa")
		this.assertEquals(o.nummer, "0815-4711-0123-4567")
		this.assertEquals(o.deckung, 3000)
		this.assertEquals(o.waehrung, "USD")
		this.assertEquals(o.inhaber.name, "Horstmannskoetter")
		this.assertEquals(o.inhaber.vorname, "Jaqueline")
		this.assertEquals(o.inhaber.maennlich, false)
		this.assertEquals(o.inhaber.kinder[1], "Chantal")
		this.assertEquals(o.inhaber.hobbys[1], "Tanzen")
		this.assertEquals(o.inhaber.hobbys[2], "Reisen")
		this.assertEquals(o.inhaber.alter, 24)
		this.assertEquals(o.inhaber.partner, "Kevin")
		this.assertEquals(o.konto.nummer, 16112017)
		this.assertEquals(o.konto.BLZ, 50050010)
	}

	@Test_InstanceOf() {
		o := new KKundeEx()
		this.assertTrue(Object.instanceOf(o, "KKundeEx"))
		this.assertTrue(Object.instanceOf(o, "KKunde"))
		this.assertFalse(Object.instanceOf(o, "SpecialClass"))
		this.assertTrue(Object.instanceOf(o.inhaber, "KKunde.KInhaber"))
	}

	@Test_Compare() {
		this.assertTrue(Object.compare({a: "a", b: "b", c: "c"}
				, {a: "a", b: "b", c: "c"}))
		this.assertFalse(Object.compare({a: "a", b: "b", c: "x"}
				, {a: "a", b: "b", c: "c"}))
		this.assertFalse(Object.compare({a: "a", b: "b"}
				, {a: "a", b: "b", c: "c"}))
		this.assertFalse(Object.compare({a: "a", b: "b", c: "c"}
				, {a: "a", c: "c"}))
		this.assertFalse(Object.compare({a: "a", b: "b", c: "c"}
				, {a: "a", b: "x", c: "c"}))
	}

	@Test_Serialize_Class2() {
		o := new KKunde()
		Object.serialize(o, A_Temp "\class-test.ini")
		o1 := Object.deserialize(A_Temp "\class-test.ini")
		o2 := Object.deserialize(A_Temp "\class-test.ini")
		o2 := Object.deserialize(A_Temp "\class-test.ini")
		this.assertTrue(o1, o2)
	}

	@AfterClass_Teardown() {
		FileDelete %A_Temp%\object-test.ini
		if (FileExist(A_Temp "\object-test.ini")) {
			this.fail("File " A_Temp "\object-test.ini could not be deleted")
		}
		FileDelete %A_Temp%\class-test.ini
		if (FileExist(A_Temp "\class-test.ini")) {
			this.fail("File " A_Temp "\class-test.ini could not be deleted")
		}
	}
}

; Testclass definitions
class KKunde {

	class KInhaber {
		static M := true
		static W := false

		Name := "Mustermann"
		Vorname := "Max"
		maennlich := KKunde.KInhaber.M
		Kinder := []
		Hobbys := [ "Reiten", "Golfen", "Lesen" ]
		Alter := 42
		Partner := "Erika"
	}

	class KKonto {
		Nummer := 123456789
		BLZ := 10020003
	}

	Herausgeber := "Xema"
	Nummer := "1234-5678-9012-3456"
	Deckung := 2.0e+6
	Waehrung := "EURO"
	Inhaber := new KKunde.KInhaber()
	Konto := new KKunde.KKonto()
}

class KKundeEx extends KKunde {

}

exitapp ObjectTest.runTests()
