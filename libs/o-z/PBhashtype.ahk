; ======================================================================
; G E T   T H E   H A S H   T Y P E   D A T A
; ======================================================================

; Check if the hash type is 1 (MD5).
if HashType = 1
{

  ; Specify the display hash type.
  DisplayHashType = MD5

  ; Specify the string length.
  HashLength = 32
}

; Check if the hash type is 2 (MD2).
if HashType = 2
{

  ; Specify the display hash type.
  DisplayHashType = MD2

  ; Specify the string length.
  HashLength = 32
}

; Check if the hash type is 3 (SHA1).
if HashType = 3
{

  ; Specify the display hash type.
  DisplayHashType = SHA1

  ; Specify the string length.
  HashLength = 40
}

; Check if the hash type is 4 (SHA256).
if HashType = 4
{

  ; Specify the display hash type.
  DisplayHashType = SHA256

  ; Specify the string length.
  HashLength = 64
}

; Check if the hash type is 5 (SHA384).
if HashType = 5
{

  ; Specify the display hash type.
  DisplayHashType = SHA384

  ; Specify the string length.
  HashLength = 96
}

; Check if the hash type is 6 (SHA512).
if HashType = 6
{

  ; Specify the display hash type.
  DisplayHashType = SHA512

  ; Specify the string length.
  HashLength = 128
}
