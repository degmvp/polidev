🔹 cs08 – Recursão
csharp
// cs08.cs
using System;

class Program {
    static int Fatorial(int n) => n <= 1 ? 1 : n * Fatorial(n - 1);

    static void Main() {
        Console.WriteLine(Fatorial(5));
    }
}