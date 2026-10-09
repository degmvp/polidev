# POLYDEV | WX-TOOLS | C++ | 009 — Disk Growth Tracker

## Visão geral

O **Disk Growth Tracker (009)** é um utilitário de linha de comando em C++ para registrar o tamanho de diretórios em **snapshots** e comparar dois estados, identificando exatamente o que cresceu no disco.

É indicado para monitorar consumo de espaço, investigar aumentos inesperados e acompanhar a evolução de diretórios específicos.

## Principais recursos

- Cria snapshots do tamanho de diretórios.
- Compara dois snapshots (`diff`).
- Mostra os diretórios que mais cresceram.
- Suporta profundidade configurável de análise.
- Permite filtrar por tamanho mínimo.
- Saída simples e direta no terminal.
- Leve e rápido.
- Implementado em C++ sem dependências externas.

## Uso

```text
dgt snap <dir> [-o arquivo.snap]

dgt diff antigo.snap novo.snap
         [--depth 2] [--top 20] [--min 1MB]
```

## Parâmetros

| Parâmetro | Função |
|---|---|
| `snap` | Cria um snapshot do diretório informado |
| `diff` | Compara dois snapshots |
| `--depth N` | Define o nível de profundidade da análise; padrão 2 |
| `--top N` | Mostra apenas os N maiores resultados; padrão 20 |
| `--min X` | Exibe apenas variações a partir de X, por exemplo `1MB`, `100MB`, `1GB` |
| `-o` | Define o nome do arquivo de snapshot |

## Exemplo completo

### 1. Snapshot inicial

```text
E:\@LIB-C++\bin>dgt snap "E:\@LIB-C++" -o antes.snap

Varrendo E:/@LIB-C++ (pode demorar)...
Snapshot salvo: antes.snap
  diretórios: 2
  total: 881.7 MB
```

### 2. Criando uma alteração de teste

```text
E:\@LIB-C++\bin>mkdir E:\@LIB-C++\TESTE_DGT

E:\@LIB-C++\bin>fsutil file createnew ^
E:\@LIB-C++\TESTE_DGT\arquivo_teste.bin 10485760

Arquivo E:\@LIB-C++\TESTE_DGT\arquivo_teste.bin criado
```

O comando cria um arquivo de aproximadamente **10 MB** em um novo diretório.

### 3. Segundo snapshot

```text
E:\@LIB-C++\bin>dgt snap "E:\@LIB-C++" -o depois.snap

Varrendo E:/@LIB-C++ (pode demorar)...
Snapshot salvo: depois.snap
  diretórios: 3
  total: 891.7 MB
```

### 4. Comparação

```text
E:\@LIB-C++\bin>dgt diff antes.snap depois.snap ^
  --depth 2 --top 20 --min 1MB

Antigo: 2026-09-12 14:57:41 (E:/@LIB-C++)
Novo:   2026-09-12 14:59:44 (E:/@LIB-C++)

+10.0 MB    TESTE_DGT

+10.0 MB    variação total
```

## Resultado do teste

Após criar um arquivo de 10 MB em uma nova pasta, o WX-TOOLS 009 identificou corretamente:

```text
+10.0 MB    TESTE_DGT
```

Isso demonstra o objetivo central da ferramenta: comparar dois momentos e indicar onde ocorreu o crescimento do armazenamento.

## Fluxo de utilização

```text
Snapshot inicial
      |
      v
Uso normal / alteração no disco
      |
      v
Novo snapshot
      |
      v
Comparação (diff)
      |
      v
Diretórios que cresceram
```

## Aplicações

O Disk Growth Tracker pode ser usado para:

- descobrir qual diretório está consumindo espaço;
- acompanhar crescimento de bancos, logs e caches;
- investigar aumentos inesperados de armazenamento;
- comparar o estado do disco antes e depois de uma instalação;
- monitorar diretórios de desenvolvimento;
- analisar crescimento periódico de pastas;
- auxiliar rotinas de manutenção.

## Tecnologia

| Item | Valor |
|---|---|
| Linguagem | C++ |
| Plataforma | Windows / Visual Studio 2022 |
| Tipo | Aplicação de linha de comando |
| Categoria | File Tools (`wxtcpp`) |
| Projeto | WX-TOOLS / C++ / 009 |
| Dependências externas | Nenhuma |

## Filosofia

**Controle o que cresce. Seu disco agradece.**

A ferramenta transforma dois snapshots simples em uma resposta objetiva sobre onde o espaço em disco aumentou.

---

**POLYDEV | WX-TOOLS | C++ | 009 — Disk Growth Tracker**  
*Pequenas ferramentas. Grandes resultados.*
