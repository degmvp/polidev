JV21_05 - Sequenced Collections

Descrição: Corrige uma dor antiga do Java: obter o primeiro ou último elemento de uma lista exigia métodos verbosos ou frágeis (como list.get(0) que lançava IndexOutOfBoundsException se a lista estivesse vazia, ou lidar com Deque). Agora, coleções que possuem ordem de encontro definida implementam SequencedCollection, trazendo métodos padronizados como getFirst(), getLast(), addFirst() e reversed().

import java.util.LinkedHashSet;
import java.util.SequencedCollection;

public class SequencedCollectionsExample {
    public static void main(String[] args) {
        SequencedCollection<String> languages = new LinkedHashSet<>();
        languages.add("Java");
        languages.add("Python");
        languages.add("C++");

        // Métodos novos e seguros
        System.out.println("Primeiro: " + languages.getFirst()); // Java
        System.out.println("Último: " + languages.getLast());   // C++

        // Inverte a coleção facilmente
        SequencedCollection<String> reversed = languages.reversed();
        System.out.println("Invertido: " + reversed);           // [C++, Python, Java]
    }
}