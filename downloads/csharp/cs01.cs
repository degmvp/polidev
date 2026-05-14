//Programa c# 1 
using System;
using System.IO;

class Program
{
    static void Main()
    {
        // Exemplo 1: Ler arquivo TXT linha por linha
        string caminhoTxt = "exemplo.txt";
        Console.WriteLine("=== Conteúdo do arquivo TXT ===");
        if (File.Exists(caminhoTxt))
        {
            foreach (string linha in File.ReadLines(caminhoTxt))
            {
                Console.WriteLine(linha);
            }
        }
        else
        {
            Console.WriteLine("Arquivo TXT não encontrado.");
        }

        // Exemplo 2: Ler arquivo CSV e separar colunas
        string caminhoCsv = "exemplo.csv";
        Console.WriteLine("\n=== Conteúdo do arquivo CSV ===");
        if (File.Exists(caminhoCsv))
        {
            foreach (string linha in File.ReadLines(caminhoCsv))
            {
                string[] colunas = linha.Split(',');
                Console.WriteLine($"Coluna 1: {colunas[0]}, Coluna 2: {colunas[1]}");
            }
        }
        else
        {
            Console.WriteLine("Arquivo CSV não encontrado.");
        }
    }
}
