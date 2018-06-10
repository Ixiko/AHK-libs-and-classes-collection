;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 对array进行排序，采用插入排序法
; 要求array参数的值必须通过Array.Insert()插入
; 曾经尝试过在函数中直接对array参数进行Remove()，但是未成功，因此改为新建一个Array，最后再赋值给array参数
; 
; gaochao.morgen@gmail.com
; 2014/2/9
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

InsertionSort(ByRef array)
{
	target := Array()

	count := 0
	for Index, Files in array
	{
		files%Index% := Files
		count += 1
	}

	j := 2
	while (j <= count)
	{
		key := files%j%
		i := j-1
	
		while (i >= 0 && key < files%i%)
		{
			k := i+1
			files%k% := files%i%
			i -= 1
		}

		k := i+1
		files%k% := key
		j += 1
	}
	
	Loop, %count%
	{
		target.Insert(files%A_Index%)
	}

	array := target
}

