#Include everything.ahk

;Set the path to Everything64.dll, Default in everything.ahk\..\Everything64.dll
;设置DLL路径,默认在函数所在文件夹下
ev := everything("D:\OneDrive\Program\AHK\lib\everything\Everything64.dll")

;You can test it in the main interface of everything and copy it over
;搜索词,可在everything中测试,然后将其复制过来
searchWord := A_WinDir "\System32  *.*"
ev.SetSearch(searchWord)	;Set search terms 搜索词

;requestType is the request type I added, Current() is the current type The call is GetRequestFlags(),   Parameters(num | num | num)
;requestType 是我添加的方法,Current()返回的是当前类型 参数(num | num | num)
requestType := ev.requestType.Current() | ev.requestType.EXTENSION | ev.requestType.DATE_CREATED

;Default only search file name and path, Here I add the EXTENSION type
;默认仅搜索文件及文件名,在这添加后缀名
ev.SetRequestFlags(requestType)

;Set the sorting method sortType is also related to the one I added, and requestType is the same
;设置排序方法,sortType也是我添加的方法,用法与requestType一样
ev.SetSort(ev.sortType.DATE_ACCESSED_ASCENDING)

;Execute query,All settings must be set before  (1 wait for result, 0 dont wait)
;执行查询,所有参数必需在此之前设置 (1 等待结果, 0 不等待)
ev.Query(1)
msg := ""
counts := lastIndex := 0

;Check if the 1000th item is a folder ,Everything index is starts at 0
;检测第1000个项目是否为文件夹,Everything 默认从0开始所以 -1
MsgBox ev.IsFolderResult(1000 - 1)

;Get properties every 500 files
;每隔500个文件获取其属性
loop
{
    index := A_Index - 1

    if ev.IsFolderResult(index) || index < lastIndex + 500
        continue
    else
        counts++

    msg .= "path : " ev.GetResultFullPathName(index)
    msg .= "`ndir : " ev.GetResultPath(index)
    msg .= "`nname : " ev.GetResultFileName(index)
    msg .= "`next : " ev.GetResultExtension(index)
    msg .= "`ncreatedTime : " ev.GetResultDateCreated(index) ;There have unknown errors
    msg .= "`n`n"

    if counts = 5
        break
    lastIndex := index
}
MsgBox(msg, "find " ev.GetNumResults() " files")	;show the msg

;catch errors
try
    ev.GetNumFolderResults()
catch
    MsgBox ev.error.message
try
    ev.GetResultDateAccessed()
catch
    MsgBox ev.error.message

;throw error
ev.GetTotFolderResults()