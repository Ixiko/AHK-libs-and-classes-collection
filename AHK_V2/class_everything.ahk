/*

    Tested on
    System     : WIN10 19044.1706 X64
    AutoHotkey : 2.0-beta.3 U64
    Everything : V1.4.1.969 (x64)

    https://www.voidtools.com/support/everything/sdk/

    Used to get content from or interact with the everything client
    the everything client must be running in the background
    Some methods may depend on different requestFlags, which I've commented out on the method, for example 0x00000080
    IsQueryReply method to be implemented
    GetRequestFlags is the result of multiple bitwise or, I don't know how to restore the original data to single hexadecimal.
    GetResultAttributes gets the result of summing multiple items, I don't know how to recover the single item result yet.
    Some of the methods to get the time in some sorting methods will error, unknown reason SetSort(***ASCENDING)

    The comment is in Chinese, the method name can be intuitive to know the meaning
    If you are not sure, please check the definition on the everything sdk website

    用于获取 everything 客户端的内容或与之交互
    everything客户端必需在后台运行
    某些方法可能依赖于不同questFlags,我将注释在方法上了,比方说 0x00000080
    IsQueryReply 方法待实现
    GetRequestFlags 获取的是多项按位或后的结果,暂不知如何还原成单项16进制的原始数据
    GetResultAttributes获取的是多项相加的结果,暂不知如何恢复单项结果
    部分获取时间的方法在某些排序方式时会出错,未知原因 SetSort(***ASCENDING)
 */

class Everything
{
    ;排序类型 https://www.voidtools.com/support/everything/sdk/everything_getsort/
    sortType := {
            Current: (*) => this.GetSort(),
            NAME_ASCENDING: 1,
            NAME_DESCENDING: 2,
            PATH_ASCENDING: 3,
            PATH_DESCENDING: 4,
            SIZE_ASCENDING: 5,
            SIZE_DESCENDING: 6,
            EXTENSION_ASCENDING: 7,
            EXTENSION_DESCENDING: 8,
            TYPE_NAME_ASCENDING: 9,
            TYPE_NAME_DESCENDING: 10,
            DATE_CREATED_ASCENDING: 11,
            DATE_CREATED_DESCENDING: 12,
            DATE_MODIFIED_ASCENDING: 13,
            DATE_MODIFIED_DESCENDING: 14,
            ATTRIBUTES_ASCENDING: 15,
            ATTRIBUTES_DESCENDING: 16,
            FILE_LIST_FILENAME_ASCENDING: 17,
            FILE_LIST_FILENAME_DESCENDING: 18,
            RUN_COUNT_ASCENDING: 19,
            RUN_COUNT_DESCENDING: 20,
            DATE_RECENTLY_CHANGED_ASCENDING: 21,
            DATE_RECENTLY_CHANGED_DESCENDING: 22,
            DATE_ACCESSED_ASCENDING: 23,
            DATE_ACCESSED_DESCENDING: 24,
            DATE_RUN_ASCENDING: 25,
            DATE_RUN_DESCENDING: 26
        }

    ;请求类型 https://www.voidtools.com/support/everything/sdk/everything_getrequestflags/
    requestType := {
            Current: (*) => this.GetRequestFlags(),
            FILE_NAME: 0x00000001,
            PATH: 0x00000002,
            FULL_PATH_AND_FILE_NAME: 0x00000004,
            EXTENSION: 0x00000008,
            SIZE: 0x00000010,
            DATE_CREATED: 0x00000020,
            DATE_MODIFIED: 0x00000040,
            DATE_ACCESSED: 0x00000080,
            ATTRIBUTES: 0x00000100,
            FILE_LIST_FILE_NAME: 0x00000200,
            RUN_COUNT: 0x00000400,
            DATE_RUN: 0x00000800,
            DATE_RECENTLY_CHANGED: 0x00001000,
            HIGHLIGHTED_FILE_NAME: 0x00002000,
            HIGHLIGHTED_PATH: 0x00004000,
            HIGHLIGHTED_FULL_PATH_AND_FILE_NAME: 0x00008000
        }

    __New(dllPath := "")
    {
        if FileExist(dllPath)
            this.dll := dllPath
        else if FileExist(A_LineFile "\..\Everything64.dll")
            this.dll := A_LineFile "\..\Everything64.dll"
        else
            MsgBox("DLL未找到")

        this.hModule := DllCall("LoadLibrary", "str", this.dll)
        this.dll .= "\"
    }

    __Delete => (*) => DllCall("FreeLibrary", "UInt", this.hModule)

    ;释放库分配的任何内存
    CleanUp => (*) => DllCall(this.dll "Everything_CleanUp")

    ;删除所有运行历史记录
    DeleteRunHistory => (*) => this._GetTrue("Everything_DeleteRunHistory")

    ;退出
    Exit => (*) => this._GetTrue("Everything_Exit")

    ;检索 Everything 的内部版本号
    GetBuildNumber => (*) => this._GetTrue("Everything_GetBuildNumber")

    ;最后一个错误代码值 https://www.voidtools.com/support/everything/sdk/everything_getlasterror/
    GetLastError()
    {
        this.error := ""
        if !(value := DllCall(this.dll "Everything_GetLastError"))
            return 0	;"EVERYTHING_OK" The operation completed successfully.

        switch (value)
        {
            case 1: code := "EVERYTHING_ERROR_MEMORY", meaning := "Failed to allocate memory for the search query."
            case 2: code := "EVERYTHING_ERROR_IPC", meaning := "IPC is not available."
            case 3: code := "EVERYTHING_ERROR_REGISTERCLASSEX", meaning := "Failed to register the search query window class."
            case 4: code := "EVERYTHING_ERROR_CREATEWINDOW", meaning := "Failed to create the search query window."
            case 5: code := "EVERYTHING_ERROR_CREATETHREAD", meaning := "Failed to create the search query thread."
            case 6: code := "EVERYTHING_ERROR_INVALIDINDEX", meaning := "Invalid index. The index must be greater or equal to 0 and less than the number of visible results."
            case 7: code := "EVERYTHING_ERROR_INVALIDCALL", meaning := "Invalid call."
            case 8: code := "EVERYTHING_ERROR_INVALIDREQUEST", meaning := "Extension was not requested or is unavailable, Call Everything_SetRequestFlags with EVERYTHING_REQUEST_EXTENSION before calling Everything_Query."
            default:code := meaning := "未知"
        }
        this.error := Error("`n数值 : " value "`n代码 : " code "`n含义 : " meaning)
        return value
    }

    ;检索 Everything 的主版本号
    GetMajorVersion => (*) => this._GetTrue("Everything_GetMajorVersion")

    ;如果启用了匹配大小写，则该函数返回 TRUE
    GetMatchCase => (*) => DllCall(this.dll "Everything_GetMatchCase")

    ;如果启用了匹配完整路径，则该函数返回 TRUE
    GetMatchPath => (*) => DllCall(this.dll "Everything_GetMatchPath")

    ;如果启用了匹配整个单词，则该函数返回 TRUE
    GetMatchWholeWord => (*) => DllCall(this.dll "Everything_GetMatchWholeWord")

    ;返回最大结果数
    GetMax => (*) => DllCall(this.dll "Everything_GetMax")

    ;检索 Everything 的次要版本号
    GetMinorVersion => (*) => this._GetTrue("Everything_GetMinorVersion")

    ;返回可见文件结果的数量 使用Everything_SetRequestFlags时不支持
    GetNumFileResults => (*) => this._GetNum("Everything_GetNumFileResults")

    ;返回可见文件夹结果的数量 使用Everything_SetRequestFlags时不支持
    GetNumFolderResults => (*) => this._GetNum("Everything_GetNumFolderResults")

    ;返回可见文件和文件夹结果的数量
    GetNumResults => (*) => this._GetNum("Everything_GetNumResults")

    ;返回可用结果的第一项偏移量
    GetOffset => (*) => DllCall(this.dll "Everything_GetOffset")

    ;如果启用了正则表达式，则该函数返回 TRUE
    GetRegex => (*) => DllCall(this.dll "Everything_GetRegex")

    ;返回 IPC 查询答复的当前答复标识符
    GetReplyID => (*) => DllCall(this.dll "Everything_GetReplyID")

    ;返回 IPC 查询答复的当前答复窗口HWND
    GetReplyWindow => (*) => DllCall(this.dll "Everything_GetReplyWindow")

    ;返回所需的结果数据标志 ;暂时只能还原单项 https://www.voidtools.com/support/everything/sdk/everything_getrequestflags/
    GetRequestFlags => (*) => DllCall(this.dll "Everything_GetRequestFlags")

    ;检索可见结果的属性 0x00000100
    ;https://ss64.com/nt/attrib.html
    ;https://docs.microsoft.com/en-gb/windows/win32/fileio/file-attribute-constants
    GetResultAttributes(dwIndex := 0)
    {
        ; static FILE_ATTRIBUTE_READONLY := 1,
        ; FILE_ATTRIBUTE_HIDDEN := 2,
        ; FILE_ATTRIBUTE_SYSTEM := 4,
        ; FILE_ATTRIBUTE_DIRECTORY := 16,
        ; FILE_ATTRIBUTE_ARCHIVE := 32,
        ; FILE_ATTRIBUTE_ENCRYPTED := 64,
        ; FILE_ATTRIBUTE_NORMAL := 128,
        ; FILE_ATTRIBUTE_TEMPORARY := 256,
        ; FILE_ATTRIBUTE_SPARSE_FILE := 512,
        ; FILE_ATTRIBUTE_REPARSE_POINT := 1024,
        ; FILE_ATTRIBUTE_COMPRESSED := 2048,
        ; FILE_ATTRIBUTE_OFFLINE := 4096,
        ; FILE_ATTRIBUTE_NOT_CONTENT_INDEXED := 8192
        attributes := DllCall(this.dll "Everything_GetResultAttributes", "int", dwIndex)
        return attributes > 0 ? attributes : this.GetLastError() ? this._ThrowError("Everything_GetResultAttributes") : ""
    }

    ;返回结果的访问日期 0x00000080
    GetResultDateAccessed => (this, dwIndex := 0) => this._GetDate("Everything_GetResultDateAccessed", dwIndex)

    ;返回结果的创建日期 0x00000020
    GetResultDateCreated => (this, dwIndex := 0) => this._GetDate("Everything_GetResultDateCreated", dwIndex)

    ;返回结果的修改日期 0x00000040
    GetResultDateModified => (this, dwIndex := 0) => this._GetDate("Everything_GetResultDateModified", dwIndex)

    ;返回结果的最近修改日期 0x00001000
    GetResultDateRecentlyChanged => (this, dwIndex := 0) => this._GetDate("Everything_GetResultDateRecentlyChanged", dwIndex)

    ;返回结果的运行日期 0x00000800
    GetResultDateRun => (this, dwIndex := 0) => this._GetDate("Everything_GetResultDateRun", dwIndex)

    ;返回结果的扩展名 0x00000008
    GetResultExtension => (this, dwIndex := 0) => this._GetStr("Everything_GetResultExtension", dwIndex)

    ;返回结果的文件列表完整路径和文件名 0x00000200
    GetResultFileListFileName => (this, dwIndex := 0) => this._GetStr("Everything_GetResultFileListFileName", dwIndex)

    ;返回文件名 0x00000001
    GetResultFileName => (this, index := 0) => this._GetStr("Everything_GetResultFileName", index)

    ;返回文件全路径 0x00000002
    GetResultFullPathName(index := 0, lpString := 256)
    {
        value := Buffer(lpString * 2)
        if DllCall(this.dll "Everything_GetResultFullPathName", "int", index, "ptr", value, "int", lpString)
            return StrGet(value)
        else if this.GetLastError()
            this._ThrowError("Everything_GetResultFullPathName")
    }

    ;返回结果的突出显示的文件名部分 0x00002000
    GetResultHighlightedFileName => (this, index := 0) => this._GetStr("Everything_GetResultHighlightedFileName", index)

    ;返回结果的突出显示的完整路径和文件名 0x00004000
    GetResultHighlightedFullPathAndFileName => (this, index := 0) => this._GetStr("Everything_GetResultHighlightedFullPathAndFileName", index)

    ;返回结果的突出显示的完整路径和文件名 0x00008000
    GetResultHighlightedPath => (this, index := 0) => this._GetStr("Everything_GetResultHighlightedPath", index)

    ;返回可用结果数据的标志 ;暂时只能还原单项,不能还原多项
    GetResultListRequestFlags => (*) => DllCall(this.dll "Everything_GetResultListRequestFlags")

    ;返回结果的实际排序顺序
    GetResultListSort => (*) => DllCall(this.dll "Everything_GetResultListSort")

    ;返回可见结果的路径部分 比Everything_GetResultFullPathName 快
    GetResultPath => (this, index := 0) => this._GetStr("Everything_GetResultPath", index)

    ;返回可见结果的运行次数 0x00000400
    GetResultRunCount => (this, dwIndex := 0) => this._GetNum("Everything_GetResultRunCount", "int", dwIndex)

    ;返回可见结果的大小 0x00000010
    GetResultSize => (this, dwIndex := 0) => this._GetNum("Everything_GetResultSize", "int", dwIndex, "int64*")

    ;返回修订版号
    GetRevision => (*) => this._GetTrue("Everything_GetRevision")

    ;返回指定文件运行次数
    GetRunCountFromFileName => (this, lpFileName) => this._GetNum("Everything_GetRunCountFromFileName", "str", lpFileName)

    ;返回搜索文本
    GetSearch => (*) => StrGet(DllCall(this.dll "Everything_GetSearch"))

    ;返回排序方式 https://www.voidtools.com/support/everything/sdk/everything_getsort/
    GetSort => (*) => DllCall(this.dll "Everything_GetSort")

    ;返回计算机CPU类型
    ;(1)	x86 (32 bit).
    ;(2)	x64 (64 bit).
    ;(3)	ARM.
    GetTargetMachine => (*) => this._GetTrue("Everything_GetTargetMachine")

    ;返回文件结果的总数 使用Everything_SetRequestFlags时不支持
    GetTotFileResults => (*) => this._GetNum("Everything_GetTotFileResults")

    ;返回文件夹结果的总数 使用Everything_SetRequestFlags时不支持
    GetTotFolderResults => (*) => this._GetNum("Everything_GetTotFolderResults")

    ;返回文件和文件夹结果的总数
    GetTotResults => (*) => this._GetNum("Everything_GetTotResults")

    ;指定文件的运行计数递增 1
    IncRunCountFromFileName => (this, lpFileName) => this._GetNum("Everything_IncRunCountFromFileName", "str", lpFileName)

    ;如果 Everything 以管理员身份运行，则该函数返回非零值
    IsAdmin => (*) => this._GetNum("Everything_IsAdmin")

    ;如果设置和数据保存在 %APPDATA%\Everything 中，则该函数返回非零
    IsAppData => (*) => this._GetNum("Everything_IsAppData")

    ;检查数据库是否已完全加载
    IsDBLoaded => (*) => this._GetNum("Everything_IsDBLoaded")

    ;检查指定的文件信息是否已编制索引并启用了快速排序 ; https://www.voidtools.com/support/everything/sdk/everything_isfastsort/
    IsFastSort => (this, sortType := 1) => this._GetNum("Everything_IsFastSort", "int", sortType)

    ;检查指定的文件信息是否已编制索引 ; https://www.voidtools.com/support/everything/sdk/everything_isfileinfoindexed/
    IsFileInfoIndexed => (this, fileInfoType := 1) => DllCall(this.dll "Everything_IsFileInfoIndexed", "int", fileInfoType)

    ;检查是否为文件
    IsFileResult => (this, index := 0) => this._GetNum("Everything_IsFileResult", "int", index)

    ;检查是否为文件夹
    IsFolderResult => (this, index := 0) => this._GetNum("Everything_IsFolderResult", "int", index)

    ;检查消息是否为WM_COPYDATA消息 ;https://www.voidtools.com/support/everything/sdk/everything_isqueryreply/
    IsQueryReply(message, wParam, lParam, nId := 0)
    {
        ; return DllCall(this.dll "Everything_IsQueryReply", "uint", message, "prt", wParam, "ptr", lParam, "int", nId)
        ;待实现
    }

    ;是否为卷的根文件夹
    IsVolumeResult => (this, index := 0) => this._GetNum("Everything_IsVolumeResult", "int", index)

    ;使用当前搜索状态执行 Everything IPC 查询
    Query => (this, bWait := 1) => this._GetTrue("Everything_Query", "int", bWait)

    ;强制重新生成 Everything 索引
    RebuildDB => (*) => this._GetTrue("Everything_RebuildDB")

    ;将结果列表和搜索状态重置为默认状态，从而释放库分配的任何内存
    Reset => (*) => DllCall(this.dll "Everything_Reset")

    ;将索引保存到磁盘
    SaveDB => (*) => this._GetTrue("Everything_SaveDB")

    ;请求 Everything 将运行历史记录保存到磁盘
    SaveRunHistory => (*) => this._GetTrue("Everything_SaveRunHistory")

    ; 指定搜索区分大小写还是不区分大小写
    SetMatchCase => (this, bEnable := true) => DllCall(this.dll "Everything_SetMatchCase", "int", bEnable)

    ;指定是启用还是禁用完整路径匹配
    SetMatchPath => (this, bEnable) => DllCall(this.dll "Everything_SetMatchPath", "int", bEnable)

    ;指定搜索是匹配整个单词，还是可以在任何位置匹配
    SetMatchWholeWord => (this, bEnable := true) => DllCall(this.dll "Everything_SetMatchWholeWord", "int", bEnable)

    ;设置从Everything_Query返回的最大结果数
    SetMax => (this, dwMaxResults := 0xffffffff) => DllCall(this.dll "Everything_SetMax", "int", dwMaxResults)

    ;第一个结果偏移量设置为从对 Everything_Query 的调用返回。
    SetOffset => (this, dwOffset := 0xffffffff) => DllCall(this.dll "Everything_SetOffset", "int", dwOffset)

    ;启用或禁用正则表达式搜索
    SetRegex => (this, bEnabled := 0) => DllCall(this.dll "Everything_SetRegex", "int", bEnabled)

    ;设置唯一编号以标识下一个查询
    SetReplyID => (this, nId := 0) => DllCall(this.dll "Everything_SetReplyID", "int", nId)

    ;将接收 IPC 查询答复的窗口的句柄
    SetReplyWindow => (this, hWnd := 0) => DllCall(this.dll "Everything_SetReplyWindow", "int", hWnd)

    ;设置所需的结果数据类型 https://www.voidtools.com/support/everything/sdk/everything_setrequestflags/
    SetRequestFlags => (this, dwRequestFlags := 0x00000003) => DllCall(this.dll "Everything_SetRequestFlags", "int", dwRequestFlags)

    ;设置“按文件名索引的所有内容”中指定文件的运行计数
    SetRunCountFromFileName => (this, lpFileName, dwRunCount) => this._GetTrue("Everything_SetRunCountFromFileName", "str", lpFileName, "int", dwRunCount)

    ;设置 IPC 查询的搜索字符串
    SetSearch => (this, lpString := 0) => DllCall(this.dll "Everything_SetSearch", "str", lpString)

    ;设置结果的排序方式 https://www.voidtools.com/support/everything/sdk/everything_setsort/
    SetSort => (this, dwSortType := 1) => DllCall(this.dll "Everything_SetSort", "int", dwSortType)

    ;按路径和文件名对当前结果进行排序
    SortResultsByPath => (*) => DllCall(this.dll "Everything_SortResultsByPath")

    ;请求 Everything 重新扫描所有文件夹索引
    UpdateAllFolderIndexes => (*) => this._GetTrue("Everything_UpdateAllFolderIndexes")

    ;返回可为0的数值或者抛出错误
    _GetNum(method, params*)
    {
        if !params.Length
            num := DllCall(this.dll method)
        else if params.Length = 2
            num := DllCall(this.dll method, params[1], params[2])
        else if params.Length = 3
            DllCall(this.dll method, params[1], params[2], params[3], &num := 0)

        return num ? num : this.GetLastError() ? this._ThrowError(method) : 0
    }

    ;返回True或者抛出错误
    _GetTrue(method, params*)
    {
        if !params.Length
            var := DllCall(this.dll method)
        else if params.Length = 2
            var := DllCall(this.dll method, params[1], params[2])
        else if params.Length = 4
            var := DllCall(this.dll method, params[1], params[2], params[3], params[4])

        return var ? var : this.GetLastError() ? this._ThrowError(method) : ""
    }

    ;返回日期或者抛出错误 https://www.autoahk.com/archives/23149
    _GetDate(method, dwIndex)
    {
        date := Buffer(8, 0)
        date := Buffer(8, 0)
        DllCall(this.dll method, "int", dwIndex, "Ptr", date)

        hours := A_Now
        hours := DateDiff(hours, A_NowUTC, 'Hours')
        second := (NumGet(date, 4, "uint") << 32 | NumGet(date, 0, "uint")) // 10000000

        if !second	;error with some SetSort(***ASCENDING)
            return this.GetLastError() ? this._ThrowError(method) : ""

        time := "16010101"
        time := DateAdd(time, second, 'Seconds')
        time := DateAdd(time, hours, 'Hours')
        return time
    }

    ;返回字符串或者抛出错误
    _GetStr(method, index)
    {
        str := DllCall(this.dll method, "int", index)
        return str ? StrGet(str) : this.GetLastError() ? this._ThrowError(method) : ""
    }

    ;抛出错误
    _ThrowError(method)
    {
        this.error.Message .= "`n函数 : " method
        this.error.What := method
        throw (this.error)
    }
}