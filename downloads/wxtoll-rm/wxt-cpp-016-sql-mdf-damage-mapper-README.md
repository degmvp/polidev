# POLYDEV | WX-TOOLS | C++ | 016 — SQL MDF Damage Mapper

## Visão geral

O **SQL MDF Damage Mapper** é uma ferramenta da coleção **POLYDEV WX-TOOLS**, desenvolvida para análise física de arquivos de dados do SQL Server.

Seu objetivo é varrer as páginas de arquivos **MDF/NDF**, classificá-las e localizar regiões com possíveis inconsistências, produzindo um mapa de diagnóstico que auxilia investigações e trabalhos de recuperação.

A operação é realizada em **modo somente leitura**, preservando o arquivo original.

## Principais recursos

- **Varredura física** — analisa as páginas do arquivo.
- **Classificação de páginas** — identifica páginas OK, suspeitas e inválidas.
- **Mapeamento de danos** — localiza regiões com inconsistências.
- **Relatório detalhado** — gera saída em CSV e resumo no console.
- **Suporte a MDF e NDF** — trabalha com arquivos de dados do SQL Server.
- **Somente leitura** — não modifica o arquivo analisado.
- **Investigação de recuperação** — complementa as ferramentas WX-TOOLS 013, 014 e 015.

## Exemplo de classificação

Durante a análise, páginas podem ser apresentadas de forma semelhante a:

```text
PageID    Type          Status
--------------------------------
1:0       FILE_HEADER   OK
1:8       DATA          OK
1:16      DATA          SUSPECT
1:23      INDEX         OK
1:248     DATA          SUSPECT
1:512     DATA          INVALID
```

Essa classificação permite identificar rapidamente áreas que merecem investigação mais detalhada antes de uma tentativa de recuperação.

## Fluxo de trabalho

O processo do WX-TOOLS 016 pode ser resumido em quatro etapas:

```text
DIAGNOSE
   |
ANALYZE
   |
RECOVER
   |
PRESERVE
```

Primeiro o arquivo é diagnosticado e suas páginas são analisadas. As regiões problemáticas podem então orientar as ferramentas de recuperação, sempre preservando o arquivo original.

## Relatório CSV

Além do resumo exibido no console, a ferramenta pode produzir um relatório CSV para análise posterior.

O relatório permite registrar informações como:

- identificação da página;
- tipo da página;
- classificação/status;
- regiões suspeitas;
- páginas inválidas;
- informações úteis para investigação física do arquivo.

## Integração com a suíte de recuperação

O **SQL MDF Damage Mapper** faz parte da sequência de ferramentas de recuperação física da coleção:

- **013 — SQL Page Recovery**
- **014 — SQL Row Recovery**
- **015 — SQL Table Recovery**
- **016 — SQL MDF Damage Mapper**

Enquanto as ferramentas anteriores trabalham progressivamente com páginas, registros e tabelas, o 016 acrescenta uma visão de diagnóstico do arquivo físico, ajudando a localizar onde os problemas estão concentrados.

## Compatibilidade

O projeto foi concebido para trabalhar com arquivos de dados de versões modernas do SQL Server, incluindo:

```text
SQL Server 2025
SQL Server 2022
SQL Server 2019
SQL Server 2017
```

## Segurança

O utilitário opera em **READ-ONLY**.

Ele não deve alterar o MDF/NDF analisado. Em trabalhos reais de recuperação, a prática recomendada é trabalhar sobre uma **cópia offline** do arquivo de dados e manter o original preservado.

## Aplicações

O WX-TOOLS 016 pode auxiliar em cenários como:

- investigação de corrupção física;
- localização de páginas suspeitas;
- identificação de regiões inválidas;
- análise preliminar antes da recuperação;
- documentação técnica de danos;
- geração de mapa para orientar ferramentas de recuperação.

## Filosofia

**Mapeia • Diagnostica • Localiza • Facilita a Recuperação**

O objetivo é transformar um arquivo potencialmente danificado em um cenário investigável, permitindo sair do problema em direção à solução sem modificar a fonte original.

---

**POLYDEV | WX-TOOLS | C++**  
*Developer Tools for a Better Tomorrow*
