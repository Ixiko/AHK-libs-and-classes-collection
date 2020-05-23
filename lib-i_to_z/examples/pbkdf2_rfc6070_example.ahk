; AutoHotkey Version: AutoHotkey 1.1
; Language:           English
; Platform:           Win7 SP1
; Author:             Antonio Bueno <user atnbueno at Google's free e-mail service>
; Description:        Test vectors for PBKDF2-HMAC-SHA1 from RFC 6070
; Last Modification:  2014-05-03

#Include pbkdf2.ahk

test(nTest, sPassword, sSalt, nIterations, nLength, sExpected)
{
	t := A_TickCount
	MsgBox, % "Test #" nTest "`n`nOutput  = " PBKDF2(sPassword, sSalt, nIterations, nLength) "`n(Expected " sExpected ")`nTime ellapsed: " (A_TickCount - t) " ms"
}

; Test vectors from RFC 6070
test(1, "password", "salt", 1, 20, "0C60C80F961F0E71F3A9B524AF6012062FE037A6")
test(2, "password", "salt", 2, 20, "EA6C014DC72D6F8CCD1ED92ACE1D41F0D8DE8957")
test(3, "password", "salt", 4096, 20, "4B007901B765489ABEAD49D926F721D065A429C1")
MsgBox, 36, , % "Test #4 consist of millions of iterations and will take several minutes. Do you want to skip it?"
IfMsgBox No
	test(4, "password", "salt", 16777216, 20, "EEFE3D61CD4DA4E4E9945B3D6BA2158C2634E984")
test(5, "passwordPASSWORDpassword", "saltSALTsaltSALTsaltSALTsaltSALTsalt", 4096, 25, "3D2EEC4FE41C849B80C8D83662C0E44A8B291A964CF2F07038")
; 7061737300776F7264 = "pass\0word", 7361006C74 = "sa\0lt"
test(6, "7061737300776F7264", "7361006C74", 4096, 16, "56FA6AA75548099DCC37D7F03425E0C3")
