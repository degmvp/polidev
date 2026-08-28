🔹 cs06 – List<T>
csharp
// cs06.cs
using System;
using System.Collections.Generic;

class Program {
    static void Main() {
        var lista = new List<int> { 1, 2, 3 };
        lista.Add(4);
        lista.ForEach(Console.WriteLine);
    }
}