[https://www.voidtools.com/support/everything/sdk/](url)  

Tested on  
System         : WIN10 19044.1706 X64  
AutoHotkey : 2.0-beta.3 U64  
Everything   : V1.4.1.969 (x64)  

Used to get content from or interact with the everything client  
the everything client must be running in the background  
Some methods may depend on different requestFlags, which I've commented out on the method, let's say 0x00000080  
**IsQueryReply method to be implemented  
GetRequestFlags is the result of multiple bitwise or, I don't know how to restore the original data to single hexadecimal.  
GetResultAttributes gets the result of summing multiple items, I don't know how to recover the single item result yet.**  
Some of the methods to get the time in some sorting methods will error, unknown reason SetSort(***ASCENDING)  

The comment is in Chinese, the method name can be intuitive to know the meaning  
If you are not sure, please check the definition on the everything sdk website  

用于获取 everything 客户端的内容或与之交互  
everything客户端必需在后台运行  
某些方法可能依赖于不同questFlags,我将注释在方法上了,比方说 0x00000080  
**IsQueryReply 方法待实现  
GetRequestFlags 获取的是多项按位或后的结果,暂不知如何还原成单项16进制的原始数据  
GetResultAttributes获取的是多项相加的结果,暂不知如何恢复单项结果**  
部分获取时间的方法在某些排序方式时会出错,未知原因 SetSort(*ASCENDING)  