sq := sql(":memory:")
sq.exec("create table if not exists test (id integer, title TEXT COLLATE NOCASE);", sq.hdb)
; Batch writing
sq.list("test", [{ id: 1, title: "a" }, { id: 2, title: "b" }, { id: 3, title: "c" }])
; Write in
sq.set("INSERT INTO test (id, title) VALUES(4,'d');")
; Read
sq.get("SELECT * FROM test")