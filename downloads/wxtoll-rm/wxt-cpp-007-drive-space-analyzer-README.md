# POLYDEV | WX-TOOLS | C++ | 007 — Drive Space Analyzer

## Visão geral

O **Drive Space Analyzer** é um utilitário de linha de comando da coleção **POLYDEV WX-TOOLS** para analisar rapidamente o uso de espaço em discos e diretórios.

A ferramenta mostra os maiores consumidores de armazenamento de forma clara e objetiva, ajudando a localizar diretórios e arquivos que merecem atenção durante processos de limpeza, organização ou auditoria.

## Objetivo

Analisar o uso de espaço em discos e diretórios e mostrar os maiores consumidores para facilitar a tomada de decisões.

## Principais recursos

- Análise de disco ou diretório.
- Listagem dos maiores diretórios.
- Listagem dos maiores arquivos.
- Exibição do tamanho total analisado.
- Contagem de arquivos e diretórios.
- Saída formatada e de fácil leitura.
- Execução rápida e leve.
- Não necessita instalação.

## Uso

```text
drivespace.exe <caminho> [opções]
```

## Exemplos

### Analisar o drive C

```text
drivespace.exe C:\
```

### Analisar um diretório específico

```text
drivespace.exe D:\Projetos
```

### Mostrar os 10 maiores resultados

```text
drivespace.exe C:\ --top 10
```

### Incluir análise de arquivos

```text
drivespace.exe C:\ --files
```

## Exemplo real

```text
E:\@LIB-C++\bin>drivespace.exe C:\

POLYDEV | WX-TOOLS - Drive Space Analyzer 1.0.0
Analisando: C:\

------------------------------------------------------------
Total: 162 GiB em 1.101.701 arquivos (295.947 diretórios)
------------------------------------------------------------

Maiores diretórios (top 5, inclui subdiretórios)

 56.9 GiB   Users
 56.7 GiB   Users\User
 50.0 GiB   Users\User\AppData
 45.6 GiB   Windows
 41.7 GiB   Users\User\AppData\Local
```

## Maiores arquivos

A análise também permite identificar arquivos individuais de grande tamanho.

Exemplo:

```text
Maiores arquivos (top 5)

12.4 GiB   pagefile.sys
 8.1 GiB   hiberfil.sys
 4.7 GiB   C:\Windows\Installer\...\.msi
 4.3 GiB   C:\Users\User\AppData\Local\...\cache
 3.9 GiB   C:\Windows\System32\...\install.wim
```

## Resultado

No exemplo analisado, os principais consumidores foram rapidamente identificados:

```text
Users   : 56.9 GiB
Windows : 45.6 GiB
```

Além disso, a ferramenta apresentou os maiores arquivos do sistema, permitindo investigar onde o espaço estava concentrado.

## Aplicações

O Drive Space Analyzer é indicado para:

- limpeza de disco;
- auditoria de espaço em servidores;
- organização de ambientes de desenvolvimento;
- identificação de diretórios que podem ser movidos para outro disco;
- investigação de falta de espaço;
- análise antes de operações de manutenção.

## Dicas

- Execute como administrador quando precisar acessar todos os diretórios.
- Analise diretórios específicos para obter resultados mais rápidos.
- Use a listagem dos maiores arquivos para localizar candidatos a limpeza ou movimentação.
- Combine o **Drive Space Analyzer (007)** com o **Driftwatch (008)** para acompanhar o crescimento do armazenamento ao longo do tempo.

## Relação com o Driftwatch

As duas ferramentas se complementam:

```text
007 — Drive Space Analyzer
      Mostra onde o espaço está sendo usado agora.

008 — Driftwatch
      Mostra o que cresceu entre dois momentos.
```

Assim, o 007 fornece uma fotografia atual do armazenamento e o 008 permite acompanhar sua evolução.

## Segurança

O objetivo da ferramenta é análise.

Ela fornece informações para que o usuário decida posteriormente quais arquivos ou diretórios podem ser limpos, movidos ou arquivados.

## Filosofia

**Conhecimento do seu ambiente começa pelo espaço em disco.**

O WX-TOOLS 007 transforma uma análise de armazenamento em informações práticas para manter sistemas mais leves e ambientes mais produtivos.

---

**POLYDEV | WX-TOOLS | C++ | 007 — Drive Space Analyzer**  
*Tecnologia a favor da produtividade.*
