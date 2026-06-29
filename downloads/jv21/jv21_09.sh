JV21_09 - Generational ZGC

Descrição: O Z Garbage Collector já era famoso por pausas menores que 1 milissegundo, independentemente do tamanho do Heap. No Java 21, ele ganhou gerações (Jovem e Velha). A premissa é que a maioria dos objetos morre jovem. Separar as gerações permite que o ZGC varra apenas a geração jovem na maioria das vezes, reduzindo drasticamente o custo de CPU, o uso de memória e melhorando a vazão (throughput) da aplicação.

Exemplo: (Não há código Java para GC, a configuração é via linha de comando)


# Para ativar o Generational ZGC ao rodar sua aplicação:
java -XX:+UseZGC -XX:+ZGenerational -jar minha-aplicacao.jar

# Parâmetro -Xlog para ver as gerações trabalhando:
java -XX:+UseZGC -XX:+ZGenerational -Xlog:gc*:file=gc.log -jar minha-aplicacao.jar