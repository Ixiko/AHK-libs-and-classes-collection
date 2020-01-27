#Include <BSON>

S := BSON.Dump.ToHexString({"Abc": "efg", "Hi": {"bye": 10}})
MsgBox, % S
O := BSON.Load.FromHexString(S)
MsgBox, % O.Abc "`n" O.Hi.bye
