🔹 cs11 – Interfaces
csharp
// cs11.cs
using System;

interface IOperacao {
    int Calcular(int x, int y);
}

class Soma : IOperacao {
    public int Calcular(int x, int y) => x + y;
}

class Program {
    static void Main() {
        IOperacao op = new Soma();
        Console.WriteLine(op.Calcular(3, 4));
    }
}