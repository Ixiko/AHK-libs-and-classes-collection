mCrc(pptr, nbytes, poly, refin, width, init, xorout) {   ; v0.33 by SKAN on D44N/D44N @ tiny.cc/mcrc
Local
Static mCrcMcode := mCrc(0,0,0,0,0,0,0)

  If (!VarSetCapacity(mCrcMcode))
  {
    M1 := DllCall("Kernel32.dll\GlobalAlloc", "Int",0, "Ptr",MSz:=(A_PtrSize=8 ? 531 : 917), "UPtr")
    M2 := DllCall("Kernel32.dll\VirtualProtect", "Ptr",M1, "Ptr",MSZ, "Int",0x40, "IntP",0)
    M3 := DllCall("Crypt32.dll\CryptStringToBinary", "Str",A_PtrSize=8 ? "
    (  LTrim Join
       U1ZXQVRIi0QkSEyLVCRQTItcJFhIi1wkYEiLdCRoSIt8JHCFyQ+ECwEAADHJ6fYAAABBicxOD7YkIk0x4Un3wQEAAAB0C
       02JzEnR7EkxxOsGTYnMSdHsTYnhSffBAQAAAHQLTYnMSdHsSTHE6wZNicxJ0exNieFJ98EBAAAAdAtNicxJ0exJMcTrBk
       2JzEnR7E2J4Un3wQEAAAB0C02JzEnR7EkxxOsGTYnMSdHsTYnhSffBAQAAAHQLTYnMSdHsSTHE6wZNicxJ0exNieFJ98E
       BAAAAdAtNicxJ0exJMcTrBk2JzEnR7E2J4Un3wQEAAAB0C02JzEnR7EkxxOsGTYnMSdHsTYnhSffBAQAAAHQLTYnMSdHs
       STHE6wZNicxJ0exNieGDwQFEOcEPggH////pzgAAAESJ0UUx0um6AAAARYnUTg+2JCJJ0+RNMeFNhdl0CU+NJAlJMcTrB
       E+NJAlNieFNhdl0CU+NJAlJMcTrBE+NJAlNieFNhdl0CU+NJAlJMcTrBE+NJAlNieFNhdl0CU+NJAlJMcTrBE+NJAlNie
       FNhdl0CU+NJAlJMcTrBE+NJAlNieFNhdl0CU+NJAlJMcTrBE+NJAlNieFNhdl0CU+NJAlJMcTrBE+NJAlNieFNhdl0CU+
       NJAlJMcTrBE+NJAlNieFBg8IBRTnCD4I9////SSHZSTHxTIkPQVxfXlvD
    )" : "
    (  LTrim Join
       VYnlg+wMVleLRRSLVRiDfQgAD4SaAQAAx0X8AAAAAOl9AQAAi00Mi3X8D7YMMYnOMf8x8DH6icaJ14PmATH/hfZ0EonGi
       dcPrP4B0e8zdRwzfSDrConGidcPrP4B0e+J8In6icaJ14PmATH/hfZ0EonGidcPrP4B0e8zdRwzfSDrConGidcPrP4B0e
       +J8In6icaJ14PmATH/hfZ0EonGidcPrP4B0e8zdRwzfSDrConGidcPrP4B0e+J8In6icaJ14PmATH/hfZ0EonGidcPrP4
       B0e8zdRwzfSDrConGidcPrP4B0e+J8In6icaJ14PmATH/hfZ0EonGidcPrP4B0e8zdRwzfSDrConGidcPrP4B0e+J8In6
       icaJ14PmATH/hfZ0EonGidcPrP4B0e8zdRwzfSDrConGidcPrP4B0e+J8In6icaJ14PmATH/hfZ0EonGidcPrP4B0e8zd
       RwzfSDrConGidcPrP4B0e+J8In6icaJ14PmATH/hfZ0EonGidcPrP4B0e8zdRwzfSDrConGidcPrP4B0e+J8In6/0X8i0
       38O00QD4J3/v//6ckBAACLdSSLfSiJ8YlN+MdF9AAAAADppgEAAItNDIt19A+2DDGJzjH/i034D6X30+b2wSB0BIn3MfY
       x8DH6i3Usi30wIcYh13UEhfZ0EonGidcPpPcBAfYzdRwzfSDrConGidcPpPcBAfaJ8In6i3Usi30wIcYh13UEhfZ0EonG
       idcPpPcBAfYzdRwzfSDrConGidcPpPcBAfaJ8In6i3Usi30wIcYh13UEhfZ0EonGidcPpPcBAfYzdRwzfSDrConGidcPp
       PcBAfaJ8In6i3Usi30wIcYh13UEhfZ0EonGidcPpPcBAfYzdRwzfSDrConGidcPpPcBAfaJ8In6i3Usi30wIcYh13UEhf
       Z0EonGidcPpPcBAfYzdRwzfSDrConGidcPpPcBAfaJ8In6i3Usi30wIcYh13UEhfZ0EonGidcPpPcBAfYzdRwzfSDrCon
       GidcPpPcBAfaJ8In6i3Usi30wIcYh13UEhfZ0EonGidcPpPcBAfYzdRwzfSDrConGidcPpPcBAfaJ8In6i3Usi30wIcYh
       13UEhfZ0EonGidcPpPcBAfYzdRwzfSDrConGidcPpPcBAfaJ8In6/0X0i030O00QD4JO/v//i01EI0U0I1U4M0U8M1VAi
       QGJUQRfXonsXcM=
    )", "Int",A_PtrSize=8 ? 708 : 1224, "Int",0x1, "Ptr",M1, "IntP",MSZ, "Int",0, "Int",0)

    Return M1
  }
  
  DllCall(mCrcMcode, "Int",refin, "Ptr",pptr, "Int",nbytes, "UInt64",init, "UInt64",poly
      , "UInt64",width-8, "UInt64",1<<width-1, "UInt64",Format("0x{:x}", width=64 ? -1 : 2**width-1)
      , "UInt64",xorout, "UInt64P",CRC:=0)

Return Format("0x{:X}", CRC)
}
