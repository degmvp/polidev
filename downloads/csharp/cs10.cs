🔹 cs10 – Herança
csharp
// cs10.cs
using System;

class Animal {
    public virtual void Som() => Console.WriteLine("Som genérico");
}

class Cachorro : Animal {
    public override void Som() => Console.WriteLine("Latido");
}

class Program {
    static void Main() {
        Animal a = new Cachorro();
        a.Som();
    }
}