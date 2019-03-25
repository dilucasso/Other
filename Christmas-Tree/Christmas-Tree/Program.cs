using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChristmasTree
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("#");
            for (int i = 1; i < 20; i++)
            {
                for (int j = 0; j < i; j++)
                {
                    if (j % 2 == 0)
                    {
                        Console.Write("_");
                    }
                    else
                    {
                        Console.Write("*");
                    }
                }
                Console.Write("\n");
            }
            Console.WriteLine(" |\n-\n * * * MERRY CHRISTMAS * * *");
            Console.ReadKey();
        }
    }
}