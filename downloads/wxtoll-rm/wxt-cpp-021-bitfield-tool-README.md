# POLYDEV \| WX-TOOLS \| 021 \| Bitfield & Bitmask Inspector

**Arquivo:** `wxt-cpp-021-bitfield-tool.cpp`\
**Executável:** `wxt-cpp-021-bitfield-tool`\
**Versão:** `1.0.0`\
**Tecnologia:** C++

## Descrição

O **Bitfield & Bitmask Inspector** é uma ferramenta de linha de comando
para inspecionar, calcular, criar e decodificar valores de bitfield e
bitmask.

É útil em firmware, protocolos, registradores e estruturas de dados
compactas.

## Uso

``` cmd
wxt-cpp-021-bitfield-tool <comando> [opções]
```

## Comandos

``` text
calc      Avalia uma expressão bit a bit com precedência estilo C
show      Mostra um valor em hex, binário, bits ligados, runs e grade
mask      Cria uma máscara a partir de especificações de bits
decode    Decodifica um valor usando um arquivo de mapa (MAP)
encode    Monta um valor a partir de campos e decodifica o resultado
```

## Opções

``` text
-m, --map FILE    Arquivo de mapa
-w, --width N     Largura em bits: 8, 16, 32 ou 64
                  O padrão é 64

--base EXPR       Valor inicial utilizado por encode
                  O padrão é 0

--signed          Mostra também a interpretação em complemento de dois

-h, --help        Mostra a ajuda e sai
-V, --version     Mostra a versão e sai
```

## `calc` --- avaliar expressão

Exemplo demonstrado:

``` cmd
wxt-cpp-021-bitfield-tool calc "(0xF0 | 0x0F) & ~0x08" -w 8
```

Resultado:

``` text
= 247
hex:       0xF7
bin:       0b1111_0111
popcount:  7
set bits:  0, 1, 2, 4, 5, 6, 7
runs:      [0..2], [4..7]
```

O comando avalia expressões bitwise utilizando a mesma precedência
básica da linguagem C.

### Operadores

Do menor para o maior nível de precedência, conforme documentado no
banner:

``` text
|  ^  &  <<  >>  +  -  *  /  %  ~  !
```

Operadores/operandos podem utilizar:

-   decimal;
-   `0x` hexadecimal;
-   `0b` binário;
-   `0o` octal;
-   `_` como separador;
-   `k` em literais de caractere;
-   parênteses.

O cálculo é executado dentro da largura definida por `--width`,
funcionando como um registrador de N bits. Os demais comandos exigem que
o valor caiba na largura especificada.

## `show` --- inspecionar valor

Exemplo:

``` cmd
wxt-cpp-021-bitfield-tool show 0b1010_0011 -w 8
```

Resultado demonstrado:

``` text
= 163
hex:       0xA3
bin:       0b1010_0011
popcount:  4
set bits:  0, 1, 5, 7
runs:      [0..1], [5], [7]
bit grid:  7 6 5 4 | 3 2 1 0
           1 0 1 0 | 0 0 1 1
```

Esse comando facilita a visualização do valor, dos bits ativos e dos
intervalos consecutivos.

## `mask` --- criar máscara

Exemplo:

``` cmd
wxt-cpp-021-bitfield-tool mask 0,4..7 -w 8
```

Resultado:

``` text
= 241
hex:       0xF1
bin:       0b1111_0001
popcount:  5
set bits:  0, 4, 5, 6, 7
runs:      [0], [4..7]
```

É possível criar máscaras a partir de bits individuais ou intervalos.

## `encode` --- montar valor usando arquivo MAP

Exemplo demonstrado:

``` cmd
wxt-cpp-021-bitfield-tool encode -m uart.map ENABLE PARITY=odd BAUD=10 ADDR=42
```

Resultado:

``` text
UART_CTRL = 0x2AAA (dec 10922, 0b0010_1010_1010_1010)

BITS   FIELD    RAW   VALUE
15:8   ADDR     42    42 (0x2A)
7      ENABLE   1     set
6      -        -     -
5:4    PARITY   2     odd
3:0    BAUD     10    10
```

O comando monta o valor a partir de campos, enums e flags definidos no
arquivo de mapa.

## `decode` --- decodificar valor usando arquivo MAP

Exemplo:

``` cmd
wxt-cpp-021-bitfield-tool decode 0x2AAA -m uart.map
```

Resultado demonstrado:

``` text
UART_CTRL = 0x2AAA (dec 10922, 0b0010_1010_1010_1010)

BITS   FIELD    RAW   VALUE
15:8   ADDR     42    42 (0x2A)
7      ENABLE   1     set
6      -        -     -
5:4    PARITY   2     odd
3:0    BAUD     10    10
```

## Formato do arquivo MAP

O banner demonstra um arquivo de mapa no seguinte formato:

``` text
# comentário

name UART_CTRL
width 16

field BAUD   3:0  uint
field PARITY 5:4  enum none=0 even=1 odd=2
flag  ENABLE 7
field ADDR   15:8 uint
```

### Regras

``` text
msb >= lsb
bits dentro da largura
sem sobreposição
nomes únicos
```

## Especificações para `encode`

O formato documentado é:

``` text
FIELD=VALUE
```

O valor pode ser numérico ou o nome de um enum.

Exemplos:

``` text
PARITY=odd
BAUD=10
ADDR=42
```

Para flags de um bit:

``` text
NAME     liga a flag
+NAME    define a flag
-NAME    limpa a flag
```

## Exemplo completo

``` cmd
wxt-cpp-021-bitfield-tool encode -m uart.map ENABLE PARITY=odd BAUD=10 ADDR=42
wxt-cpp-021-bitfield-tool decode 0x2AAA -m uart.map
```

O resultado do `encode` e do `decode` deve ser consistente.

## Mais exemplos

``` cmd
wxt-cpp-021-bitfield-tool calc "(0xA4 << 3) | 0x05" -w 16

wxt-cpp-021-bitfield-tool mask 0,4..7,12

wxt-cpp-021-bitfield-tool show 0x1234 -w 16 --signed
```

## Códigos de saída

``` text
0    OK
1    uso incorreto (linha de comando)
2    erro de I/O
3    expressão ou mapa inválido
4    campo não encontrado
5    erro semântico
```

## Visão funcional

``` text
BITFIELD & BITMASK INSPECTOR
        |
        +-- calc
        |     +-- expressões bitwise
        |
        +-- show
        |     +-- hex / bin / set bits / runs / grade
        |
        +-- mask
        |     +-- bits individuais / intervalos
        |
        +-- encode
        |     +-- MAP -> valor
        |
        +-- decode
              +-- valor -> MAP
```

## Arquivos do componente

Padrão POLYDEV:

``` text
wxt-cpp-021-bitfield-tool.cpp
wxt-cpp-021-bitfield-tool.exe
wxt-cpp-021-bitfield-tool.png
wxt-cpp-021-bitfield-tool-README.md
```

------------------------------------------------------------------------

**POLYDEV \| WX-TOOLS \| 021 \| BITFIELD & BITMASK INSPECTOR**

*Bits pequenos. Ideias grandes.*
