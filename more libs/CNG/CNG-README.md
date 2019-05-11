# AHK implementation for CNG
Cryptography API: Next Generation (CNG) is the long-term replacement for the CryptoAPI.  
CNG is designed to be extensible at many levels and cryptography agnostic in behavior.


## Creating a Hash with CNG

### Hashing Algorithm
* MD2, MD4, MD5
* SHA1, SHA256, SHA384, SHA512
* PBKDF2


### Usage

##### Single Functions:
```AutoHotkey
MsgBox % bcrypt_md5("The quick brown fox jumps over the lazy dog")
; ==> 9e107d9d372bb6826bd81d3542a419d6

MsgBox % bcrypt_sha1_hmac("The quick brown fox jumps over the lazy dog", "Secret Salt")
; ==> d736602b0b10855afb5b0699232200a2284d9661

MsgBox % bcrypt_sha256_file("C:\Windows\notepad.exe")
; ==> da0acee8f60a460cfb5249e262d3d53211ebc4c777579e99c8202b761541110a

MsgBox % bcrypt_pbkdf2_sha512("The quick brown fox jumps over the lazy dog", "Secret Salt")
; ==> c69571bb7ac960be902e9ec59062e2a6b3b1827c98c2e725797cdaff15cc8714411527fc39f4967c9bf07b8f46182add813ac6f0e3bbda5ffdccdc4b334540c0
```
##### Class:
```AutoHotkey
MsgBox % bcrypt.hash("The quick brown fox jumps over the lazy dog", "MD5")
; ==> 9e107d9d372bb6826bd81d3542a419d6

MsgBox % bcrypt.hmac("The quick brown fox jumps over the lazy dog", "Secret Salt", "MD5")
; ==> ad8af8953b9f7f880887ab3bd7a7674a

MsgBox % bcrypt.file("C:\Windows\notepad.exe", "SHA1")
; ==> 40f2e778cf1effa957c719d2398e641eff20e613

MsgBox % bcrypt.pbkdf2("The quick brown fox jumps over the lazy dog", "Secret Salt", "SHA256", 4096, 32)
; ==> 70497e570c8cbe1c486e7f6ce755df4f5535dbe16e84337eb04946b1267b0d9d
```


### Source (minimum supported client)
* for Windows 7 see here -> [src/hash/win7](src/hash/win7)
* for Windows 10 see here -> [src/hash/win10](src/hash/win10)


## Info
* [AHK Thread](https://autohotkey.com/boards/viewtopic.php?f=6&t=23413)
* [Cryptography API: Next Generation (msdn)](https://msdn.microsoft.com/en-us/library/aa376210(v=vs.85).aspx)
* [Creating a Hash with CNG (msdn)](https://msdn.microsoft.com/en-us/library/aa376217(v=vs.85).aspx)


## Contributing
* thanks to AutoHotkey Community


## Questions / Bugs / Issues
Report any bugs or issues on the [AHK Thread](https://autohotkey.com/boards/viewtopic.php?f=6&t=23413). Same for any questions.


## Donations
[Donations are appreciated if I could help you](https://www.paypal.me/smithz)