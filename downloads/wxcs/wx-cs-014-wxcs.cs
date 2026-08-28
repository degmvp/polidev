🔹 cs14 – Async/Await
csharp
// cs14.cs
using System;
using System.Threading.Tasks;

class Program {
    static async Task Main() {
        await Task.Delay(1000);
        Console.WriteLine("Tarefa concluída!");
    }
}