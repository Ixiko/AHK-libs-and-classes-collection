/*
	@ masphei
	email : masphei@gmail.com
*/
// --------------------------------------------------------------------------
// 2016-05-11 <oss.devel@searchathing.com> : created csprj and splitted Main into a separate file
using System;
using System.Collections.Generic;

namespace ConvexHull
{

    public class GrahamScan
    {
        private const int TurnLeft = 1;
        public int Turn(Point p, Point q, Point r)
        {
            return ((q.X - p.X) * (r.Y - p.Y) - (r.X - p.X) * (q.Y - p.Y)).CompareTo(0);
        }

        public void KeepLeft(List<Point> hull, Point r)
        {
            while (hull.Count > 1 && Turn(hull[hull.Count - 2], hull[hull.Count - 1], r) != TurnLeft)
            {
                hull.RemoveAt(hull.Count - 1);
            }
            if (hull.Count == 0 || hull[hull.Count - 1] != r)
            {
                hull.Add(r);
            }
        }

        public double GetAngle(Point p1, Point p2)
        {
            float xDiff = p2.X - p1.X;
            float yDiff = p2.Y - p1.Y;
            return Math.Atan2(yDiff, xDiff) * 180.0 / Math.PI;
        }

        public List<Point> MergeSort(Point p0, List<Point> arrPoint)
        {
            if (arrPoint.Count == 1)
            {
                return arrPoint;
            }
            var arrSortedInt = new List<Point>();
            var middle = (int)arrPoint.Count / 2;
            var leftArray = arrPoint.GetRange(0, middle);
            var rightArray = arrPoint.GetRange(middle, arrPoint.Count - middle);
            leftArray = MergeSort(p0, leftArray);
            rightArray = MergeSort(p0, rightArray);
            var leftPointer = 0;
            var rightPointer = 0;
            for (var i = 0; i < leftArray.Count + rightArray.Count; i++)
            {
                if (leftPointer == leftArray.Count)
                {
                    arrSortedInt.Add(rightArray[rightPointer]);
                    rightPointer++;
                }
                else if (rightPointer == rightArray.Count)
                {
                    arrSortedInt.Add(leftArray[leftPointer]);
                    leftPointer++;
                }
                else if (GetAngle(p0, leftArray[leftPointer]) < GetAngle(p0, rightArray[rightPointer]))
                {
                    arrSortedInt.Add(leftArray[leftPointer]);
                    leftPointer++;
                }
                else
                {
                    arrSortedInt.Add(rightArray[rightPointer]);
                    rightPointer++;
                }
            }
            return arrSortedInt;
        }

        public List<Point> ConvexHull(List<Point> points)
        {
            Point p0 = null;
            foreach (var value in points)
            {
                if (p0 == null)
                    p0 = value;
                else
                {
                    if (p0.Y > value.Y)
                        p0 = value;
                }
            }
            var order = new List<Point>();
            foreach (var value in points)
            {
                if (p0 != value)
                    order.Add(value);
            }

            order = MergeSort(p0, order);
            var result = new List<Point> {p0, order[0], order[1]};
            order.RemoveAt(0);
            order.RemoveAt(0);
            foreach (var value in order)
            {
                KeepLeft(result, value);
            }
            return result;
        }

    }

}