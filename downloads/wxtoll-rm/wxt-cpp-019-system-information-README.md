# POLYDEV \| WX-TOOLS \| 019 \| POLYDEV_VM

**Imagem de documentação:** `wxt-cpp-019-system-information.png`\
**Ambiente:** Ubuntu 24.04 / POLYDEV_LAB\
**Objetivo:** executar código diretamente do navegador na VM

## Descrição

O **POLYDEV_VM** é o ambiente de execução do laboratório POLYDEV que
permite selecionar código no navegador, informar argumentos quando
necessário, executar o programa na VM e visualizar o resultado em tempo
real.

O fluxo documentado no banner é:

``` text
BROWSER
   |
   +-- escolher programa
   |
   +-- informar argumentos
   |
   +-- executar na VM
   |
   +-- compilação automática
   |
   +-- resultado no navegador
```

## Linguagens destacadas

O ambiente é apresentado como multilíngue, com suporte a:

``` text
C++
Python
C
Rust
Go
Java
Bash
```

## 1. Escolha o programa

No navegador, selecione o programa desejado no combo.

Exemplos mostrados:

``` text
wxt-cpp-001-file-organizer.cpp
wxt-cpp-002-duplicate-finder.cpp
wxt-cpp-003-directory-analyzer.cpp
teste.cpp
...
```

O banner utiliza como exemplo:

``` text
wxt-cpp-002-duplicate-finder.cpp
```

## 2. Informe os argumentos

Quando o programa exigir parâmetros, eles são informados no campo:

``` text
ARGUMENTOS DE EXECUÇÃO
```

O próprio banner orienta:

``` text
Deixe vazio para programas que não precisam de argumentos.
```

Portanto, a execução pode funcionar tanto com quanto sem argumentos,
dependendo da ferramenta selecionada.

## 3. Execute na VM

Após selecionar o programa e preencher os argumentos necessários,
utilize:

``` text
EXECUTAR NA VM
```

Para o exemplo C++, o banner demonstra:

``` text
g++
COMPILA E EXECUTA NA HORA
```

Ou seja, o código é compilado no ambiente Linux e executado
automaticamente.

## 4. Resultado em tempo real

A saída do programa é apresentada diretamente no navegador.

No exemplo do **Duplicate File Finder CLI**, o painel demonstra:

``` text
POLYDEV - DUPLICATE FILE FINDER CLI

Diretório: "/home/degsu/polydev_lab/scripts/cpp/."

Arquivos analisados: 4
Grupos duplicados: 1
Espaço potencialmente recuperável: 173.25 KB
Erros de leitura: 0
```

Isso permite testar ferramentas sem precisar operar diretamente um
terminal para cada execução.

## Fluxo completo

``` text
1. BROWSER
      |
      v
   selecionar código

2. PARÂMETROS
      |
      v
   informar argumentos, quando necessários

3. POLYDEV_VM
      |
      v
   compilar / executar

4. SAÍDA NO BROWSER
      |
      v
   visualizar o resultado
```

## Compilação on-the-fly

Uma das características centrais apresentadas é a compilação automática:

``` text
CÓDIGO REAL
ARGUMENTOS
COMPILAÇÃO ON-THE-FLY
RESULTADO EM TEMPO REAL
```

Para C++, o compilador mostrado é:

``` text
g++
```

## Características destacadas

### Simples

``` text
Sem terminal
Sem complicação
```

### Flexível

``` text
Funciona com ou sem argumentos
```

### Poderoso

``` text
Compilação on-the-fly
Ambiente Linux real
```

### Produtivo

``` text
Teste suas ferramentas diretamente no browser
```

### Ideal para aprender

``` text
Leitura
Prática
Resultado
```

## Ambiente POLYDEV_LAB

O banner identifica o laboratório como:

``` text
POLYDEV_LAB
Ubuntu 24.04
Node.js
GCC
Multi-linguagens
```

## Finalidade

O POLYDEV_VM transforma o navegador em uma interface simples para o
laboratório Linux:

``` text
Código fonte
     |
     v
Navegador
     |
     v
POLYDEV_VM
     |
     +-- compilação
     +-- execução
     |
     v
Resultado no navegador
```

A proposta é permitir:

``` text
COMPILE
EXECUTE
TESTE
APRENDA
SEM COMPLICAÇÃO
```

## Filosofia POLYDEV

Conforme registrado no banner:

``` text
FAÇA CERTO QUE FUNCIONA
```

e:

``` text
Código em Ação
Conhecimento em Evolução!
```

## Arquivos relacionados

``` text
wxt-cpp-019-system-information.png
```

Este item documenta o fluxo operacional do **POLYDEV_VM** e sua
integração entre navegador e ambiente Linux.

------------------------------------------------------------------------

**POLYDEV \| WX-TOOLS \| 019 \| POLYDEV_VM**
