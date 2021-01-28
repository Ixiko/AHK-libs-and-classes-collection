#include ..\sort_len.ahk
str := "Lorem ipsum dolor sit amet   consectetur  adipiscing elit Curabitur imperdiet non dolor eu malesuada Nulla id magna a elit venenatis hendrerit rhoncus malesuada orci Aliquam"
sort_len(str, A_Space, shortFirst:=true, omitEmpty:=true)
msgbox(str)