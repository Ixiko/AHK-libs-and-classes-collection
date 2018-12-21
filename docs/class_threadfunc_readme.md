# threadFunc

Please visit the [wiki](https://github.com/HelgeffegleH/threadFunc/wiki "threadFunc wiki").

For calling a function in a new (ahk) thread. Basic  usage:

```autohotkey
fn := new threadFunc("functionNameOrObject")
fn.call()
```
	
Example:

```autohotkey
fn:= new threadFunc("g")
f1::
	SendMode("Play")
	g()
	fn.call()
return
g(){
	Msgbox(A_SendMode)
}
esc::exitapp()
```