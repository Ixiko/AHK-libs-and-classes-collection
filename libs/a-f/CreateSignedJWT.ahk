; Title:
; Link:
; Author:
; Date:
; for:     	AHK_L

/*


*/

certificate := "C:\blah-blah-blah\certain-haiku-23150.p12"
privateKeyPassword := "notasecret"
clientEmail := "service@certain-haik.gserviceaccount.com"

jwt := CreateSignedJWT(certificate, privateKeyPassword, clientEmail)
response := GoogleOauth2(jwt)

niceElement := "――――――――――――――――――――――――――――――――"
MsgBox, % niceElement "`njwt: " niceElement "`n" jwt "`n`n" niceElement "`nresponse text: " niceElement "`n" response

CreateSignedJWT(certificate, privateKeyPassword, clientEmail) {
   DllCall("LoadLibrary", "str", "bcrypt.dll")
   DllCall("LoadLibrary", "str", "ncrypt.dll")
   DllCall("LoadLibrary", "str", "crypt32.dll")
   time := A_NowUTC
   EnvSub, time, 19700101000000, seconds
   expTime := time+3600
   header = {"alg":"RS256","typ":"JWT"}
   payload = {"iss":"%clientEmail%","scope":"https://www.googleapis.com/auth/prediction","aud":"https://oauth2.googleapis.com/token","iat":%time%,"exp":%expTime%}
   header := Base64URLenc(header)
   payload := Base64URLenc(payload)
   file := FileOpen(certificate, "r")
   bufLen := file.rawRead(buffer, file.Length)
   file.Close()
   VarSetCapacity(CRYPT_INTEGER_BLOB, A_PtrSize*2, 0)
   NumPut(bufLen, CRYPT_INTEGER_BLOB, 0, "uint")
   NumPut(&buffer, CRYPT_INTEGER_BLOB, A_PtrSize, "ptr")
   hCertStore := DllCall("crypt32\PFXImportCertStore", "ptr", &CRYPT_INTEGER_BLOB, "str", PrivateKeyPassword, "uint", 0)
   hContext := DllCall("crypt32\CertFindCertificateInStore", "ptr", hCertStore, "uint", (X509_ASN_ENCODING := 1)|(PKCS_7_ASN_ENCODING := 65536), "uint", 0, "uint", CERT_FIND_ANY := 0, "ptr", 0, "ptr", 0)
   DllCall("crypt32\CryptAcquireCertificatePrivateKey", "ptr", hContext, "uint", CRYPT_ACQUIRE_ONLY_NCRYPT_KEY_FLAG := 0x00040000, "ptr", 0, "ptr*", phKey, "uint*", dwKeySpec, "int*", bFreeHandle)
   DllCall("bcrypt\BCryptOpenAlgorithmProvider", "ptr*", hHashAlg, "ptr", &(BCRYPT_SHA256_ALGORITHM := "SHA256"), "ptr", 0, "uint", 0)
   DllCall("bcrypt\BCryptOpenAlgorithmProvider", "ptr*", hSignAlg, "ptr", &(BCRYPT_RSA_ALGORITHM := "RSA"), "ptr", 0, "uint", 0)
   DllCall("bcrypt\BCryptCreateHash", "ptr", hHashAlg, "ptr*", hHash, "ptr", 0, "uint", 0, "ptr", 0, "uint", 0 , "uint", 0)
   size := StrPut(header "." payload, "UTF-8")
   VarSetCapacity(pbInput, size, 0)
   StrPut(header "." payload, &pbInput, "UTF-8")
   size--
   DllCall("bcrypt\BCryptHashData", "ptr", hHash, "ptr", &pbInput, "uint", size, "uint", 0)
   DllCall("bcrypt\BCryptGetProperty", "ptr", hHashAlg, "ptr", &(BCRYPT_HASH_LENGTH := "HashDigestLength"), "uint*", cbHash, "uint", 4, "uint*", cbResult, "uint", 0)
   VarSetCapacity(pbHash, cbHash, 0)
   DllCall("bcrypt\BCryptFinishHash", "ptr", hHash, "ptr", &pbHash, "uint", cbHash, "uint", 0)
   VarSetCapacity(BCRYPT_PKCS1_PADDING_INFO, A_PtrSize, 0)
   NumPut(&BCRYPT_SHA256_ALGORITHM, BCRYPT_PKCS1_PADDING_INFO)
   DllCall("ncrypt\NCryptSignHash", "ptr", phKey, "ptr", &BCRYPT_PKCS1_PADDING_INFO, "ptr", &pbHash, "uint", cbHash, "ptr", 0, "uint", 0, "uint*", cbSignature, "uint", BCRYPT_PAD_PKCS1 := 2)
   VarSetCapacity(pbSignature, cbSignature, 0)
   DllCall("ncrypt\NCryptSignHash", "ptr", phKey, "ptr", &BCRYPT_PKCS1_PADDING_INFO, "ptr", &pbHash, "uint", cbHash, "ptr", &pbSignature, "uint", cbSignature, "uint*", cbSignature, "uint", BCRYPT_PAD_PKCS1 := 2)
   signature := Base64URLenc(&pbSignature, cbSignature)
   DllCall("bcrypt\BCryptDestroyHash", "ptr", hHash)
   DllCall("bcrypt\BCryptCloseAlgorithmProvider", "ptr", hSignAlg, "uint", 0)
   DllCall("bcrypt\BCryptCloseAlgorithmProvider", "ptr", hHashAlg, "uint", 0)
   DllCall("ncrypt\NCryptFreeObject", "ptr", phKey)
   DllCall("crypt32\CertFreeCertificateContext", "ptr", hContext)
   DllCall("crypt32\CertCloseStore", "ptr", hCertStore, "uint", CERT_CLOSE_STORE_FORCE_FLAG := 1)
   jwt := header "." payload "." signature

return jwt
}

GoogleOauth2(jwt) {
   HTTP := ComObjCreate("WinHTTP.WinHTTPRequest.5.1")
   HTTP.Open("POST", "https://oauth2.googleapis.com/token", true)
   HTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
   HTTP.Send("grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=" jwt)
   HTTP.WaitForResponse()
return  HTTP.ResponseText
}

Base64URLenc(pData, size := ""){
   if (size = "")   {
      VarSetCapacity(bin, StrPut(pData, "UTF-8"))
      size := StrPut(pData, &bin, "UTF-8") - 1
      pData := &bin
   }
   DllCall("crypt32\CryptBinaryToString", "ptr", pData, "uint", size, "uint", (CRYPT_STRING_BASE64 := 0x1)|(CRYPT_STRING_NOCRLF := 0x40000000), "ptr", 0, "uint*", chars)
   VarSetCapacity(outData, chars << !!A_IsUnicode, 0)
   DllCall("crypt32\CryptBinaryToString", "ptr", pData, "uint", size, "uint", (CRYPT_STRING_BASE64 := 0x1)|(CRYPT_STRING_NOCRLF := 0x40000000), "str", outData, "uint*", chars)
   outData := StrReplace(outData, "=")
   outData := StrReplace(outData, "+", "-")
   outData := StrReplace(outData, "/", "_")
   return outData
}