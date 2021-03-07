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

    public class JarvisMarch
    {
        private const int TurnRight = -1;
        private const int TurnNone = 0;
        public int Turn(Point p, Point q, Point r)
        {
            return ((q.X - p.X) * (r.Y - p.Y) - (r.X - p.X) * (q.Y - p.Y)).CompareTo(0);
        }

        public int Dist(Point p, Point q)
        {
            var dx = q.X - p.X;
            var dy = q.Y - p.Y;
            return dx * dx + dy * dy;
        }

        public Point NextHullPoint(List<Point> points, Point p)
        {
            var q = p;
            foreach (var r in points)
            {
                var t = Turn(p, q, r);
                if (t == TurnRight || t == TurnNone && Dist(p, r) > Dist(p, q))
                    q = r;
            }
            return q;
        }

        public double GetAngle(Point p1, Point p2)
        {
            float xDiff = p2.X - p1.X;
            float yDiff = p2.Y - p1.Y;
            return Math.Atan2(yDiff, xDiff) * 180.0 / Math.PI;
        }

        public List<Point> ConvexHull(List<Point> points)
        {
            var hull = new List<Point>();
            foreach (var p in points)
            {
                if (hull.Count == 0)
                    hull.Add(p);
                else
                {
                    if (hull[0].X > p.X)
                        hull[0] = p;
                    else if (hull[0].X == p.X)
                        if (hull[0].Y > p.Y)
                            hull[0] = p;
                }
            }

            var counter = 0;
            while (counter < hull.Count)
            {
                var q = NextHullPoint(points, hull[counter]);
                if (q != hull[0])
                {
                    hull.Add(q);
                }
                counter++;
            }
            return hull;
        }

    }

}