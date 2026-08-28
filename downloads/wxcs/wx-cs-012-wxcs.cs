🔹 cs12 – LINQ
csharp
// cs12.cs
using System;
using System.Linq;

class Program {
    static void Main() {
        var nums = new[] { 1, 2, 3, 4, 5 };
        var pares = nums.Where(n => n % 2 == 0);
        Console.WriteLine(string.Join(", ", pares));
    }
}