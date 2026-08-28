🔹 cs15 – Delegates e Eventos
csharp
// cs15.cs
using System;

class Publicador {
    // Delegate + evento
    public event Action<string> MensagemPublicada;

    public void Publicar(string msg) {
        MensagemPublicada?.Invoke(msg);
    }
}