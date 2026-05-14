cs13 – Exception Handling
csharp
// cs13.cs
using System;

class Program {
    static void Main() {
        try {
            int x = int.Parse("abc");
        } catch (FormatException ex) {
            Console.WriteLine($"Erro: {ex.Message}");
        }
    }
}