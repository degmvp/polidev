# POLYDEV \| WX-TOOLS \| 022 \| Hex Inspector

**Arquivo:** `wxt-cpp-022-hex-inspector.cpp`\
**Executável:** `wxt-cpp-022-hex-inspector.exe`\
**Tecnologia:** C++17 / Windows 11 / Visual Studio 2022\
**Tipo:** laboratório binário via linha de comando

## Descrição

O **Hex Inspector** é uma ferramenta da coleção POLYDEV WX-TOOLS para
analisar, explorar e modificar arquivos binários pela linha de comando.

O banner demonstra seis funções principais:

-   `info`
-   `dump`
-   `read`
-   `find`
-   `strings`
-   `patch`

## `info`

Analisa um arquivo e apresenta estatísticas.

``` cmd
wxt-cpp-022-hex-inspector.exe info app.exe
```

A saída demonstrada inclui:

-   nome do arquivo;
-   tamanho em bytes e KiB;
-   tipo detectado;
-   entropia;
-   percentual de bytes zero;
-   quantidade de valores de byte distintos.

No exemplo, um executável Windows é identificado pelo cabeçalho `MZ`.

## `dump`

Produz um hex dump canônico acompanhado da representação ASCII.

``` cmd
wxt-cpp-022-hex-inspector.exe dump app.exe -n 64
```

O resultado apresenta:

``` text
offset | bytes hexadecimais | ASCII
```

Esse modo permite examinar diretamente a estrutura bruta de um arquivo.

## `read`

Realiza leitura de valores tipados em offsets do arquivo.

Exemplo demonstrado:

``` cmd
wxt-cpp-022-hex-inspector.exe read app.exe -s 0 -t u16le -t u16le -t u32le
```

O banner demonstra leituras de inteiros little-endian, exibindo offset,
tipo, valor decimal e representação hexadecimal.

A ferramenta é apresentada como capaz de trabalhar com valores tipados,
incluindo:

-   inteiros;
-   floats;
-   strings.

## `find`

Procura padrões dentro de arquivos.

``` cmd
wxt-cpp-022-hex-inspector.exe find app.exe hex:4D5A -m 5
```

No exemplo, procura-se o padrão hexadecimal:

``` text
4D 5A
```

correspondente a `MZ`.

A saída apresenta os offsets onde o padrão foi localizado.

## `strings`

Extrai strings presentes no arquivo.

``` cmd
wxt-cpp-022-hex-inspector.exe strings app.exe -n 12
```

O banner descreve extração de:

-   strings ASCII;
-   strings UTF-16LE.

A saída demonstra o offset seguido da string encontrada.

## `patch`

Modifica bytes de um arquivo.

Exemplo demonstrado:

``` cmd
wxt-cpp-022-hex-inspector.exe patch test.bin --offset 0 --bytes hex:575821 --apply
```

No exemplo, três bytes são escritos no offset zero:

``` text
50 4F 4C  ->  57 58 21
```

A operação demonstrada confirma a escrita e cria backup:

``` text
backup: test.bin.bak
```

O banner destaca três mecanismos de segurança para patch:

-   dry run;
-   backup;
-   verificação.

## Sequência rápida de exploração

``` cmd
wxt-cpp-022-hex-inspector.exe info app.exe

wxt-cpp-022-hex-inspector.exe dump app.exe -n 64

wxt-cpp-022-hex-inspector.exe read app.exe -s 0 -t u16le -t u16le -t u32le

wxt-cpp-022-hex-inspector.exe find app.exe hex:4D5A -m 5

wxt-cpp-022-hex-inspector.exe strings app.exe -n 12
```

## Exemplo de patch

``` cmd
wxt-cpp-022-hex-inspector.exe patch test.bin --offset 0 --bytes hex:575821 --apply
```

Por modificar o conteúdo do arquivo, `patch` deve ser utilizado
conscientemente e sobre arquivos apropriados para teste. O banner
demonstra criação de backup antes da alteração aplicada.

## Capacidades destacadas

``` text
BINÁRIO
HEX
STRINGS
PATCH
ANÁLISE
```

A ferramenta pode ser usada para estudar e explorar formatos como os
indicados no banner:

``` text
PE
ELF
BIN
HEX
RAW
```

## Visão funcional

``` text
HEX INSPECTOR
    |
    +-- info      -> análise e estatísticas
    +-- dump      -> hex dump + ASCII
    +-- read      -> leitura tipada
    +-- find      -> busca de padrões
    +-- strings   -> extração de strings
    +-- patch     -> alteração controlada de bytes
```

## Ambiente demonstrado

``` text
Windows 11
Visual Studio 2022
C++17
```

## Arquivos do componente

Padrão POLYDEV:

``` text
wxt-cpp-022-hex-inspector.cpp
wxt-cpp-022-hex-inspector.exe
wxt-cpp-022-hex-inspector.png
wxt-cpp-022-hex-inspector-README.md
```

------------------------------------------------------------------------

**POLYDEV \| WX-TOOLS \| 022 \| HEX INSPECTOR**
