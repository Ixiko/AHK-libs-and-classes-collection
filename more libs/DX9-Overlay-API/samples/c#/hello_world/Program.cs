using System;
using DX9OverlayAPI;

namespace hello_world
{
    class Program
    {
        static int overlayText = -1;
        static int overlayBox = -1;
        static int overlayLine = -1;

        static void Main(string[] args)
        {
            DX9Overlay.SetParam("process", "GFXTest32.exe"); // Set the process name

            DX9Overlay.DestroyAllVisual();

            overlayText = DX9Overlay.TextCreateUnicode("Arial", 12, false, false, 200, 200, 0xFF00FFFF, "Hello world!\n€ÖÜŒœЄϿ", true, true); // Initialize 'overlayText'
            overlayBox = DX9Overlay.BoxCreate(200, 200, 100, 100, 0x50FF00FF, true); // Initialize 'overlayBox'
            overlayLine = DX9Overlay.LineCreate(0, 0, 300, 300, 5, 0xFFFFFFFF, true); // Initialize 'overlayLine'

            if (overlayText == -1 || overlayBox == -1 || overlayLine == -1)
            {
                Console.WriteLine("A error is occurred at the intializing.");
                Console.WriteLine("Press any key to close the application!");

                Console.ReadKey();
                return;
            }
            Console.WriteLine("Enter 'exit' to close the application!");
            string input = Console.ReadLine(); // Get the input

            while(input != "exit")
            {
                DX9Overlay.TextSetString(overlayText, input); // Set 'overlayText' string to the value of 'input'
                input = Console.ReadLine();
            }

            DX9Overlay.TextDestroy(overlayText); // Destroy text if the input is 'exit'
            DX9Overlay.BoxDestroy(overlayBox); // Destroy box if the input is 'exit'
            DX9Overlay.LineDestroy(overlayLine); // Destroy line if the input is 'exit'
        }
    }
}
