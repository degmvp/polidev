# POLYDEV \| WX-TOOLS \| 020 \| JSON Config Manager

**Arquivo:** `wxt-cpp-020-json-config-manager.cpp`\
**Executável:** `wxt-cpp-020-json-config-manager.exe`\
**Versão:** `1.0.0`\
**Tecnologia:** C++

## Descrição

O **JSON Config Manager** é uma ferramenta de linha de comando da
coleção POLYDEV WX-TOOLS para gerenciamento de arquivos JSON.

Conforme o banner de homologação, permite:

-   validar JSON;
-   consultar valores;
-   editar valores;
-   formatar JSON (`pretty`);
-   minificar JSON (`minify`).

## Versão

``` cmd
wxt-cpp-020-json-config-manager --version
```

Saída demonstrada:

``` text
wxt-cpp-020-json-config-manager 1.0.0
```

## `validate` --- validar JSON

Valida a estrutura de um arquivo JSON.

``` cmd
wxt-cpp-020-json-config-manager validate config.json
```

Resultado demonstrado:

``` text
config.json: ok
```

## `get` --- obter valor

Consulta um valor dentro do documento JSON.

``` cmd
wxt-cpp-020-json-config-manager get config.json opcoes.tema -r
```

Resultado demonstrado:

``` text
escuro
```

O exemplo mostra acesso a um valor aninhado usando:

``` text
opcoes.tema
```

## `set` --- definir valor

Altera um valor no documento JSON.

``` cmd
wxt-cpp-020-json-config-manager set config.json versao "2.0" -s
```

Conforme o banner:

``` text
(sem saída, grava no arquivo)
```

Portanto, o exemplo altera a chave `versao` para `"2.0"` e persiste a
modificação no arquivo.

## `pretty` --- formatar JSON

Gera uma versão formatada do documento.

``` cmd
wxt-cpp-020-json-config-manager pretty config.json -i 2 -o config-pretty.json
```

O exemplo gera JSON formatado utilizando:

``` text
2 espaços de indentação
```

Arquivo de saída:

``` text
config-pretty.json
```

## `minify` --- minificar JSON

Gera uma versão compactada do documento JSON.

``` cmd
wxt-cpp-020-json-config-manager minify config.json -o config-min.json
```

O resultado é um JSON gravado em uma única linha.

Arquivo de saída:

``` text
config-min.json
```

## Fluxo rápido de trabalho

``` cmd
wxt-cpp-020-json-config-manager validate config.json

wxt-cpp-020-json-config-manager get config.json opcoes.tema -r

wxt-cpp-020-json-config-manager set config.json versao "2.0" -s

wxt-cpp-020-json-config-manager pretty config.json -i 2 -o config-pretty.json

wxt-cpp-020-json-config-manager minify config.json -o config-min.json
```

## Exemplo conceitual

Um arquivo de configuração pode conter:

``` json
{
  "nome": "POLYDEV",
  "versao": "2.0",
  "opcoes": {
    "tema": "escuro",
    "idioma": "pt-BR"
  }
}
```

Consulta:

``` cmd
wxt-cpp-020-json-config-manager get config.json opcoes.tema -r
```

Retorno:

``` text
escuro
```

## Visão funcional

``` text
JSON CONFIG MANAGER
       |
       +-- validate  -> validar JSON
       +-- get       -> consultar valores
       +-- set       -> editar valores
       +-- pretty    -> formatar
       +-- minify    -> compactar
```

## Características destacadas

``` text
FUNCIONAL   - homologado
CONFIÁVEL   - pronto para uso
ÚTIL        - uso no dia a dia
```

O objetivo da ferramenta é fornecer gerenciamento simples e direto de
configurações JSON pela linha de comando.

## Arquivos do componente

Padrão POLYDEV:

``` text
wxt-cpp-020-json-config-manager.cpp
wxt-cpp-020-json-config-manager.exe
wxt-cpp-020-json-config-manager.png
wxt-cpp-020-json-config-manager-README.md
```

------------------------------------------------------------------------

**POLYDEV \| WX-TOOLS \| 020 \| JSON CONFIG MANAGER**

*Pequenas ferramentas. Grandes transformações.*
