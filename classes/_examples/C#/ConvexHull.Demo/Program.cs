/*
	@ masphei
	email : masphei@gmail.com
*/
// --------------------------------------------------------------------------
// 2016-05-11 <oss.devel@searchathing.com> : created csprj and splitted Main into a separate file
using System;
using System.Collections.Generic;
using System.Diagnostics;

namespace ConvexHull
{

    public class Demo
    {
        private static List<Point> _listPoints = null;

        public static void GrahamScanDemo()
        {
            var gs = new GrahamScan();

            var stopwatch = new Stopwatch();
            stopwatch.Start();
            var result = gs.ConvexHull(_listPoints);
            stopwatch.Stop();
            float elapsedTime = stopwatch.ElapsedMilliseconds;

            foreach (var value in result)
            {
                Console.Write("(" + value.X + "," + value.Y + ") ");
            }
            Console.WriteLine();
            Console.WriteLine("Elapsed time: {0} milliseconds", elapsedTime);
        }

        public static void JarvisMarchDemo()
        {
            var jm = new JarvisMarch();

            var stopwatch = new Stopwatch();
            stopwatch.Start();
            var result = jm.ConvexHull(_listPoints);
            stopwatch.Stop();
            float elapsedTime = stopwatch.ElapsedMilliseconds;

            foreach (var value in result)
            {
                Console.Write("(" + value.X + "," + value.Y + ") ");
            }
            Console.WriteLine();
            Console.WriteLine("Elapsed time: {0} milliseconds", elapsedTime);
            Console.ReadLine();
        }

        public static void Main()
        {
            _listPoints = new List<Point>
            {
                new Point(9, 1),
                new Point(4, 3),
                new Point(4, 5),
                new Point(3, 2),
                new Point(14, 2),
                new Point(4, 12),
                new Point(4, 10),
                new Point(5, 6),
                new Point(10, 2),
                new Point(1, 2),
                new Point(1, 10),
                new Point(5, 2),
                new Point(11, 2),
                new Point(4, 11),
                new Point(12, 4),
                new Point(3, 1),
                new Point(2, 6),
                new Point(2, 4),
                new Point(7, 8),
                new Point(5, 5)
            };


            Console.WriteLine("Graham Scan Results:");
            GrahamScanDemo();

            Console.WriteLine("\n\n==============================================\n\n");

            Console.WriteLine("Jarvis March Results:");
            JarvisMarchDemo();

            Console.WriteLine("Press enter to close...");
            Console.ReadLine();

        }

    }

}
