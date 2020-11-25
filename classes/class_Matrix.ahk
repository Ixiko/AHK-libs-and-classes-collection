
/**
* AHK static Matrix calculations
* by IsNull 2012
* https://autohotkey.com/board/topic/80487-ahk-l-matrix-class/
* Gauss/Pivot Strategies implemented by horst/Babba
*/
class MatrixStatic {
   /**
   * Calculates the determinant (scalar) of the given Matrix
   *
   * Implementation Note:
   * The given matrix will be reduced by laplace expansion
   * until the matrix dimension is (2,2). The determinant of
   * the 2,2 matrix is then directly calculated
   */
   Det(m){

      det := 0

      colCnt := MatrixStatic.ColumnCount(m)
      if(!MatrixStatic.IsSquare(m) ||  colCnt < 2)
         throw new Exception("The matrix must be squared and its dimensions must be greater or equal than (2,2)!")

      if(colCnt == 2){
         ; a 2,2 Matrix, we can calculate the determinant directly
         det := m[1,1] * m[2,2] - m[2,1] * m[1,2]
      }else{
         ; Laplace expansion
         ; @see: http://en.wikipedia.org/wiki/Laplace_expansion

         i := 1 ;row
         k := 1 ;col
         det := 0
         curVal := 0 ; current Value where [i,k] is pointing at
         Loop, % colCnt
         {
            k := A_index

            curVal := m[i,k]

            if(curVal != 0) ; we can skip coz multiplication by zero
            {
               laplace := MatrixStatic.ExtractLaplace(m, [i,k]) ; extract a sub matrix by laplace
               cofactor := curVal * (((-1)**(i+k)) * MatrixStatic.Det(laplace))
               det += cofactor
            }
         }
      }

      return det
   }

    /**
   * Extract the sub-matrix, by laplace expansion
   *
   * m    -   Matrix   (n,n)       source matrix
   * pnt   -   Point   [row,col]   coord origin of Laplace
   *
   * returns Laplace-Matrix of [pnt]
   *
   * @see: http://en.wikipedia.org/wiki/Laplace_expansion
   */
   ExtractLaplace(m, pnt){
      laplace := {}

      colCnt := MatrixStatic.ColumnCount(m)
      rowCnt := MatrixStatic.RowCount(m)


        pntRow := pnt[1]
      pntCol := pnt[2]

      laplaceRow := 1
      laplaceCol := 1
      bincRow := false

      irow := 1
      Loop, % colCnt
      {
         irow := a_index
         bincRow := false
         laplaceCol := 1
         Loop, % colCnt
         {
            icol := a_index

            if(pntCol != icol && pntRow != irow) ; // omit values in the range of the laplace origin
            {
               laplace[laplaceRow, laplaceCol] := m[irow, icol]
               laplaceCol++
                    bincRow := true
            }
         }
            if(bincRow)
               laplaceRow++
      }

      return laplace
   }


   /**
   * Multiply each element in the matrix whith the given scalar
   */
   MultiplyScalar(A, n){
      add := {}

      isColVector := (MatrixStatic.RowCount(A) == 1)

      loop % MatrixStatic.RowCount(A)
      {
         rowi := a_index
         Loop, % MatrixStatic.ColumnCount(A)
         {
            if(isColVector)
               add[a_index] := A[A_Index] * n
            else
               add[rowi,a_index] := A[rowi,A_Index] * n
         }
      }
      return add
   }

   /**
   * Addition of A and B
   */
   Add(A, B){
      if(MatrixStatic.ColumnCount(A) != MatrixStatic.ColumnCount(B)
      || MatrixStatic.RowCount(A) != MatrixStatic.RowCount(B))
      {
         throw Exception("Matrix Addition Error: All dimensions must agree!")
      }

      add := {}

      isColVector := (MatrixStatic.RowCount(A) == 1)

      loop % MatrixStatic.RowCount(A)
      {
         rowi := a_index
         Loop, % MatrixStatic.ColumnCount(A)
         {
            if(isColVector)
               add[a_index] := A[A_Index] + B[A_Index]
            else
               add[rowi,a_index] := A[rowi,A_Index] + B[rowi,A_Index]
         }
      }
      return add
   }

   /**
   * Subtraction of B from A
   */
   Sub(A, B){
      if(MatrixStatic.ColumnCount(A) != MatrixStatic.ColumnCount(B)
      || MatrixStatic.RowCount(A) != MatrixStatic.RowCount(B))
      {
         throw Exception("Matrix Addition Error: All dimensions must agree!")
      }

      add := {}

      isColVector := (MatrixStatic.RowCount(A) == 1)

      loop % MatrixStatic.RowCount(A)
      {
         rowi := a_index
         Loop, % MatrixStatic.ColumnCount(A)
         {
            if(isColVector)
               add[a_index] := A[A_Index] - B[A_Index]
            else
               add[rowi,a_index] := A[rowi,A_Index] - B[rowi,A_Index]
         }
      }
      return add
   }

	/*
	* Inverts the given Matrix
	* so that: A * inv(A) = I
	*/
	Inverse(A){
		if(!MatrixStatic.IsSquare(A))
			throw Exception("Only square matrices have an inverse! Your given matrix is not square.")

		size := MatrixStatic.ColumnCount(A)
		identity := MatrixStatic.Eye(size)

		inverse := MatrixStatic.Gauss(A, identity)
		return inverse
	}


   /*
   * Multiplies Matrix A with B.
   *
   * Note that A*B != B*A
   */
   Multiply(A, B){
      mul := {}
      if(MatrixStatic.ColumnCount(A) != MatrixStatic.RowCount(B))
      {
         throw Exception("Matrix Multiplication Error: Inner dimensions must agree!")
      }

      Loop, % MatrixStatic.RowCount(A)
      {
         rowi := A_index
         Loop, % MatrixStatic.ColumnCount(B)
         {
            aRow := MatrixStatic.RangeRow(A, rowi)
            bCol := MatrixStatic.RangeCol(B, A_index)
            bColT := MatrixStatic.Transpose(bCol)

            mul[rowi,A_index] := MatrixStatic.dotP(aRow,bColT)
         }
      }
      return mul
   }

   /*
   * Dot-Product (scalar product)
   */
   dotP(v1,v2){
      dotp := 0
      Loop, % v1.MaxIndex()
         dotp += v1[A_index] * v2[A_index]
      return dotp
   }

   /**
   * Returns the Column-Vector at the given index
   */
   RangeCol(m, colIndex){

      rowN := MatrixStatic.RowCount(m)
      col := []
      Loop % rowN{
         if (rowN = 1)
			col[1,1] := m[colIndex]
		else
			col[A_index,1] := m[A_index,colIndex]
      }

   return col
   }

   /*
   *  Returns the Row-Vector at the given index
   */
   RangeRow(m, rowIndex){
      rowN := MatrixStatic.RowCount(m)
		if (rowN = 1)
			return MatrixStatic.Clone(m)
		else
			return MatrixStatic.Clone(m[rowIndex])
   }

   /*
   * Returns a transposed Matrix of the given
   */
   Transpose(m){
      mt := {} ; transposed matrix
      i := 0
      for each, row in m
      {
         i := A_index

         if(MatrixStatic.ColumnCount(m) == 1){
            mt[i] := row[1]
         }else{
            if(IsObject(row))
            {
               for each, item in row
                  mt[A_index,i] := item
            }else{
               mt[i,1] := row
            }
         }
      }
      return mt
   }

	IsSquare(m){
		return IsObject(m) && MatrixStatic.ColumnCount(m) == MatrixStatic.RowCount(m)
	}

   /**
   * Returns the count of columns in the given Matrix
   */
   ColumnCount(m){
		return IsObject(m[1]) ? m[1].MaxIndex() : m.MaxIndex()
   }

   /**
   * Returns the count of rows in the given Matrix
   */
   RowCount(m){
      return IsObject(m[1]) ? m.MaxIndex() : 1
   }

   /**
   * Clones the given Matrix
   */
   Clone(m){
      mc := {}
      for each, row in m
      {
         if(IsObject(row))
         {
            rIndex := A_index
            for each, item in row
               mc[rIndex,A_index] := item
         }else
            mc[A_index] := row
      }
      return mc
   }

   /*
   * Generates an quadratic identity matrix with a size of [n]
   */
   Eye(n){
      eye := {}
      loop, % n
      {
         ri := A_Index
         loop, % n
            eye[ri,A_index] := (ri == a_index) ? 1 : 0
      }

      return eye
   }

   Zeros(n){
      return this.Fill(n, 0)
   }

   /*
   * Generates an quadratic matrix with a size of [n]
   * and each element set to [fillNum]
   */
   Fill(n, fillNum){
      filled := {}
      loop, % n
      {
         ri := A_Index
         loop, % n
            filled[ri,A_index] := fillNum
      }

      return filled
   }

   /**
   * Checks if the given two matrices are equal
   */
   Equals(m,m2){
      equal := false

      mRowCnt := MatrixStatic.RowCount(m)
      mColCnt := MatrixStatic.ColumnCount(m)

      if(mRowCnt == MatrixStatic.RowCount(m2)
      && mColCnt == MatrixStatic.ColumnCount(m2)){

         equal := true
         isColVector := (mRowCnt == 1)


         loop % mRowCnt
         {
            rowi := a_index
            Loop, % mColCnt
            {
               if(isColVector)
               {
                  MsgBox "it is" %rowi% %A_Index%
                  if(m[A_Index] != m2[A_Index])
                  {
                     equal := false
                     break, 2 ; break the outer loop
                  }
               }else{
                  if(m[rowi,A_Index] != m2[rowi,A_Index])
                  {
                     equal := false
                     break, 2 ; break the outer loop
                  }
               }
            }
         }
      }
      return equal
   }

   /*
   * Returns a console/msgbox friendly string. Useful for debugging
   */
   ToString(m){

      if(!IsObject(m))
      {
         prnt := "No Matrix!"
      }else{
         prnt := "(" MatrixStatic.RowCount(m) "," MatrixStatic.ColumnCount(m) ") Matrix:`n---------`n"

         if(MatrixStatic.RowCount(m) != 1)
         {
            for each, row in m
            {
               for each, item in row
                  prnt .= item " "
               prnt .= "`n"
            }
         }else{
            for each, val in m
               prnt .= val " "
            prnt .= "`n"
         }
         prnt .= "---------"
      }

      return prnt
   }

   /**
   * Gets the mirror matrix for the straight line mirror y;
   * y := m*x + b
   *
   *
   * if b is NOT zero, you must move the vertices first with v = (0,-b)
   * 1. move vertices along v = (0,-b)  | --> move the mirror axis to the origin
   * 2. mirror with the matrix returned by this function |---> newVertex = M * vertex
   * 3. move vertices back along -v = (0,b) | --> move the vertices back
   */
   Mirror2D(m){
      angle := this.Mirror2DByAngle(ATan(m))
   }

   /**
   * Gets the mirror matrix for the straight line intersection the origin (0,0)
   * angle     =    angle to x axis, in radians
   */
   Mirror2DByAngle(angle){
      angle *= 2
      c := cos(angle)
      s := sin(angle)

      M := [[c, s]
           ,[s,-c]]

      return M
   }

   Rotate2D(angle){
      c := cos(angle)
      s := sin(angle)

      R := [[c,-s]
           ,[s, c]]

      return R
   }

   Rotate3DZ(angle){
      c := cos(angle)
      s := sin(angle)

      R := [[c,-s, 0]
           ,[s, c, 0]
           ,[0, 0, 1]]

      return R
   }

   Rotate3DY(angle){
      c := cos(angle)
      s := sin(angle)

      R := [[ c, 0, s]
           ,[ 0, 1, 0]
           ,[-s, 0, c]]

      return R
   }

   Rotate3DX(angle){
      c := cos(angle)
      s := sin(angle)

      R := [[ 1, 0, 0]
           ,[ 0, c,-s]
           ,[ 0, s, c]]

      return R
   }

   Mirror3D(axis){

      m1 := (axis == 1 || axis = "x") ? -1 : 1
      m2 := (axis == 2 || axis = "y") ? -1 : 1
      m3 := (axis == 3 || axis = "z") ? -1 : 1

      M := [[ m1, 0,  0]
           ,[ 0, m2,  0]
           ,[ 0,  0, m3]]

      return M
   }




	/*
	* Given a matrix a and an (optional) index pair i,
	* MatrixStatic.Pivot returns an index pair of a pivot located below and to the right of i if it finds some.
	*
	*/
	Pivot(a, i="")
	{
		colnum:=a[1].maxindex()
		rownum:=a.maxindex()

		if(i == "")
		   i1 := i2 := 1
		else
		{
		   i1 := i[1] + 1
		   i2 := i[2] + 1
		}

		p2 := i2
		while (p2 <= colnum)
		{
			p1 := i1
			x := abs(a[i1,p2])

			while (i1 + a_index <= rownum){
				y := abs(a[i1+a_index, p2])
				if(y > x)
				{
					x := y
					p1 := i1+a_index
				}
			}
			if(x)
				return [p1,p2]
			else
				p2++
		}
	}


	;=========================================================================


   /***************************************
   *
   * Given matrices a and (optional) b   (b is allowed to be a vector), mat_rowechtrafo reduces a to row echelon form.
   * On b the same (only a-dependent) operations take place.
   ****************************************
   */
   ToRowEchelonForm(aorig, b=""){

      a := MatrixStatic.Clone(aorig)

      rownum := a.maxindex()
      colnum := a[1].maxindex()


      b_is_2d := IsObject(b[1])

      if (b_is_2d)
        colnum_b := b[1].maxindex()

      k := 1
      while(k < rownum){
         pivot := MatrixStatic.Pivot(a, pivot)
         p1 := pivot[1]
         p2 := pivot[2]

         if (!pivot)
             break

         if (p1 != k){
             swap  := a[k]
             a[k]  := a[p1]
             a[p1] := swap
             swap  := b[k]
             b[k]  := b[p1]
             b[p1] := swap

             pivot[1] := p1 := k
         }

         l1 := p1 + 1
         while(l1 <= rownum){
             l2 := p2 + 1
             fact := a[l1,p2] / a[p1,p2]


             while(l2 <= colnum){
                 a[l1,l2] -= fact * a[p1,l2]
                 l2 += 1
             }
             a[l1,p2] := 0

             if (b_is_2d)
                 while (a_index <= colnum_b)
                     b[l1,a_index] -= fact * b[p1,a_index]
             else
                 b[l1] -= fact * b[p1]
             l1++
         }
         k++
      }
      return a
   }


	;=========================================================================

	/**
	* Given a matrix a in row echelon form and a vector   b   (b is allowed to be a matrix),   mat_RowEchSol   returns a solution if it finds one.
	* In case b is matrix,   mat_RowEchSol   interprets the columns of   b   to be vectors and searches solutions to those vectors.
    If a solution to the ith column is found, it is inserted in the   output array   as ith column. Otherwise the   output array   lacks the ith column.
	*/
	RowEchelonSolve(a, b, pivot_row2col=""){

		rownum := a.maxindex()
		colnum := a[1].maxindex()

		if (!pivot_row2col){
			pivot_row2col := {}
			while (pivot := MatrixStatic.Pivot(a,pivot))
				pivot_row2col[pivot[1]] := pivot[2]
		}

		rnk := pivot_row2col.maxindex()
		if (rnk="")
		   rnk := 0


		if (!IsObject(b[1])){
			j1 := rownum
			while(j1 >= 1){
				if (b[j1] != 0)
				{
					if (j1 <= rnk)
						break
					else
						return
				}
				j1--
			}

			sol_vec:={}
			loop, % colnum
				sol_vec[a_index] := 0

			while (rnk>=1)
			{
				sol_vec[pivot_row2col[rnk]] := b[rnk] / a[rnk,pivot_row2col[rnk]]
				while (a_index<rnk)
					b[a_index] -= a[a_index,pivot_row2col[rnk]] * sol_vec[pivot_row2col[rnk]]
				rnk--
			}
		}else{

			valid_ix := {}
			colnum_b := b[1].maxindex()
			some_index := 1

			loop, % colnum_b
			{
				j2 := a_index
				j1 := rownum

				while (j1 >= 1){
					if (b[j1,j2] != 0){
						if (j1 <= rnk){
							valid_ix[some_index] := j2
							some_index += 1
						}
						break
					}
					j1--
				}
			}

			rnk_BkUp := rnk
			sol_vec := {}

			for count,i2 in valid_ix
			{
				loop, % colnum
					sol_vec[a_index,i2] := 0

				rnk := rnk_BkUP
				while(rnk >= 1){
					sol_vec[pivot_row2col[rnk],i2] := b[rnk,i2] / a[rnk,pivot_row2col[rnk]]
					while(a_index < rnk)
						b[a_index,i2] -= a[a_index,pivot_row2col[rnk]] * sol_vec[pivot_row2col[rnk],i2]
					rnk--
				}
			}
		}
		return sol_vec
	}


   /**
   * Gauss solve the System Ax = B.
   * The System A is first transformed into row echolon form (gaussian elimination)
   * Afterwards, the System is solved by substitiution.
   *
   * returns x, the solution of Ax = B
   */
   Gauss(A, B)   {
      workerB := this.Clone(B)
      rowechelon := MatrixStatic.ToRowEchelonForm(A, workerB)
      return MatrixStatic.RowEchelonSolve(rowechelon, workerB)
   }

}

/**
* AHK Matrix class
*
*/
class Matrix extends MatrixStatic {
   __new(m)
   {
      this.Prototype(m)
   }

   /**
   * Calculates the determinant (scalar) of the given Matrix
   *
   * Implementation Note:
   * The given matrix will be reduced by laplace expansion
   * until the matrix dimension is (2,2). The determinant of
   * the 2,2 matrix is then directly calculated
   */
   Det(m=0){
      if (this != Matrix)
         m := this
      return base.Det(m)
   }



   /**
   * Multiply each element in this matrix whith the given scalar [n] and returns the new matrix
   */
   MultiplyScalar(m, n=0){

      if (this != Matrix)
      {
         n := m
         m := this
      }

      return new Matrix(base.MultiplyScalar(m, n))
   }

   /**
   * Add the given matrix to this one and return the new matrix
   */
   Add(m, B=0){

      if (this != Matrix)
      {
         B := m
         m := this
      }

      return new Matrix(base.Add(m, B))
   }

   /**
   * Subtract B from this matrix and returns the new matrix
   */
   Sub(B){

      if (this != Matrix)
      {
         B := m
         m := this
      }

      return new Matrix(base.Sub(m, B))
   }

   /*
   * Returns the Inverse of this Matrix
   * so that: A * inv(A) = I
   */
   Inverse(A=0){
      if (this != Matrix)
         A := this
      return new Matrix(base.Inverse(A))
   }


   /*
   * Multiplies this Matrix with B from right and returns the new matrix
   *
   */
   MultiplyRight(B){
      return new Matrix(base.Multiply(this, B))
   }

   /*
   * Multiplies this Matrix with B from left and returns the new matrix
   *
   */
   MultiplyLeft(B){
      return new Matrix(base.Multiply(B, this))
   }


   /**
   * Returns the Column-Vector at the given index
   */
   RangeCol(m, colIndex=0){

      if (this != Matrix)
      {
         colIndex := m
         m := this
      }

      return new Matrix(base.RangeCol(m, colIndex))
   }

   /*
   *  Returns the Row-Vector at the given index
   */
   RangeRow(m,rowIndex=0){

      if (this != Matrix)
      {
         rowIndex := m
         m := this
      }

      return new Matrix(base.RangeRow(m, rowIndex))
   }

   /*
   * Returns a transposed Matrix of this matrix
   */
   Transpose(m=0){
      if (this != Matrix)
         m := this
      return new Matrix(base.Transpose(m))
   }

   IsSquare(m=0){
      if (this != Matrix)
         m := this
      return base.IsSquare(m)
   }

   /**
   * Returns the count of columns in the given Matrix
   */
   ColumnCount(m=0){
      if (this != Matrix)
         m := this
      return base.ColumnCount(m)
   }

   /**
   * Returns the count of rows in the given Matrix
   */
   RowCount(m=0){
      if (this != Matrix)
         m := this
      return base.RowCount(m)
   }

   /**
   * Clones the given Matrix
   */
   Clone(m=0){
      if (this != Matrix)
         m := this
     return new Matrix(m)
   }

   Prototype(m){
      for each, row in m
      {
         if(IsObject(row))
         {
            rIndex := A_index
            for each, item in row
               this[rIndex,A_index] := item
         }else
            this[A_index] := row
      }
      return mc
   }


   Equals(m,m2=0){
      if (this != Matrix)
      {
         m2 := m
         m := this
      }
      return base.Equals(m,m2)
   }

   /*
   * Returns a console/msgbox friendly string. Useful for debugging
   */
   ToString(m=0){
      if (this != Matrix)
         m := this
      return base.ToString(m)
   }

   /*
   * Generates an quadratic identity matrix with a size of [n]
   */
   Eye(n){
     return new Matrix(base.Eye(n))
   }

   Zeros(n){
      return new Matrix(base.Zeros(n))
   }

   /*
   * Generates an quadratic matrix with a size of [n]
   * and each element set to [fillNum]
   */
   Fill(n, fillNum){
      return  new Matrix(base.Fill(n, fillNum))
   }


   Mirror2D(m){
      return new Matrix(base.Mirror2D(m))
   }

   /**
   * Gets the mirror matrix for the straight line intersection the origin (0,0)
   * angle     =    angle to x axis, in radians
   */
   Mirror2DByAngle(angle){
      return new Matrix(base.Mirror2DByAngle(angle))
   }

   Rotate2D(angle){
      return new Matrix(base.Rotate2D(angle))
   }

   Rotate3DZ(angle){
      return new Matrix(base.Rotate3DZ(angle))
   }

   Rotate3DY(angle){
      return new Matrix(base.Rotate3DY(angle))
   }

   Rotate3DX(angle){
      return new Matrix(base.Rotate3DX(angle))
   }

   Mirror3D(axis){
      return new Matrix(base.Mirror3D(axis))
   }

   Gauss(A, B=""){
      if(B="")
      {
         B := A
         A := this
      }
      return new Matrix(base.Gauss(A,B))
   }

   ToRowEchelonForm(a, b=""){
      if (this != Matrix)
      {
         b := a
         a := this
      }
      return base.ToRowEchelonForm(a, b)
   }
}