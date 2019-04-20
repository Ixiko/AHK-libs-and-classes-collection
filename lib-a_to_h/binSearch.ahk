binSearch(arr,match,r,l=0){
    return arr[mid:=(l+r)//2]=match?mid
            :arr[mid]>match?binSearch(arr,match,mid-1,l)
            :arr[mid]<match?binSearch(arr,match,r,mid+1)
            :-1
}