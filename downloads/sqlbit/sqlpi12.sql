12 - Homogeneização de Dados

Prática muito utilizada em projetos de otimização.

Objetivos:

Reduzir tamanho das linhas
Aumentar registros por página
Reduzir espaço em disco
Evitar overflow
Melhorar utilização de memória

Exemplo:

Evitar:

VARCHAR(2000)

quando o valor médio possui:

30 bytes