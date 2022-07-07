﻿#Include 'WinHttpRequest.ahk'

class DownloadAsync {
	size := 0, totalsize := -1

	/**
	 * 异步下载, 可获取下载进度
	 * @param URL 待下载的URL地址, 包含http(s)头
	 * @param Filename 保存的文件路径
	 * @param OnStateChanged 下载状态回调函数
	 * @param OnProgress 下载进度回调函数
	 */
	__New(URL, Filename, OnStateChanged := 0, OnProgress := 0) {
		this.req := req := WinHttpRequest()
		req.Open('GET', URL, true)
		if (Type(Filename) = 'Buffer') {
			this.file := 0, this.buffer := Filename
		} else {
			this.file := file := FileOpen(Filename, 'w-wd')
			if (!file)
				throw Error('创建文件失败', -1)
		}
		if (OnProgress) {
			req2 := WinHttpRequest(), req2.Open('HEAD', URL, true)
			req2.OnResponseFinished := getFileSize.Bind(, ObjPtrAddRef(req2))
			req2.Send()
		}
		req.OnResponseDataAvailable := OnProgress ? receiveData : 0
		req.OnError := req.OnResponseFinished := finished
		req.Send()

		getFileSize(self, pself) {
			ObjRelease(pself)
			if (size := Integer(self.GetResponseHeader('Content-Length')))
				this.totalsize := size
		}
		receiveData(self, pvData, cbElements) => OnProgress(this.size += cbElements, this.totalsize)
		finished(self, msg := 0, data := 0) {
			if (msg) {
				if this.file
					this.file.Close(), this.file := 0, FileDelete(Filename)
				else
					this.buffer.Size := 0, this.buffer := 0
				OnStateChanged({msg: msg, err: data})
			} else {
				pSafeArray := ComObjValue(t := self.whr.ResponseBody)
				pvData := NumGet(pSafeArray + 8 + A_PtrSize, 'ptr')
				cbElements := NumGet(pSafeArray + 8 + A_PtrSize * 2, 'uint')
				if this.file
					this.file.RawWrite(pvData, cbElements), this.file.Close(), this.file := 0
				else {
					this.buffer.size := cbElements
					DllCall('RtlMoveMemory', 'ptr', this.buffer, 'ptr', pvData, 'uint', cbElements)
					this.buffer := 0
				}
				try OnStateChanged(0)
			}
			self.OnError := self.OnResponseDataAvailable := self.OnResponseFinished := 0
		}
	}
}