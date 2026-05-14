🔹 cs09 – Classes
csharp
// cs09.cs
using System;

class Pessoa {
    public string Nome { get; set; }
    public void Falar() => Console.WriteLine($"Olá, eu sou {Nome}");
}

class Program {
    static void Main() {
        var p = new Pessoa { Nome = "Degmar" };
        p.Falar();
    }
}