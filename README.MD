# POLYDEV – Portal de Conteúdos de Programação

## 📚 Sobre o Projeto

O **POLYDEV** é um portal de conteúdos de programação desenvolvido utilizando apenas tecnologias gratuitas e hospedagem estática.
O sistema permite disponibilizar conteúdos, arquivos para download, organização por categorias e ranking de downloads.

O projeto foi desenvolvido como laboratório de estudos envolvendo:

* HTML
* JavaScript
* GitHub Pages
* Supabase (Banco de Dados)
* Integração via API REST
* Sistema de downloads com estatísticas

---

## 🏗️ Arquitetura do Sistema

Usuário → GitHub Pages (HTML/JavaScript) → Supabase (Banco de Dados)

O frontend está hospedado no GitHub Pages e o backend (banco de dados e funções) está no Supabase.

---

## 📁 Estrutura do Projeto

```
polidev/
│
├── index.html
├── top.html
├── categorias.html
├── conteudos.html
├── conteudo.html
├── buscar.html
├── admin.html
├── guia.html
├── config.js
│
├── downloads/
│   ├── api_python_simples.py
│   ├── landing_page.html
│   ├── pyCharm01.py
│   └── trigger_auditoria.sql
│
├── zips/
│   └── programas_python.zip
│
└── README.md
```

---

## 🗄️ Banco de Dados (Supabase)

### Tabela categorias

* nome
* downloads

### Tabela conteudos

* id
* nome
* arquivo
* categoria
* descricao

### Função RPC

incrementar_download(categoria)

Responsável por incrementar o contador de downloads.

---

## ⬇️ Sistema de Downloads

Quando o usuário clica em download:

1. O sistema chama uma função no Supabase
2. O contador de downloads é incrementado
3. O arquivo ZIP é baixado
4. O ranking é atualizado na página TOP

---

## 📊 Página TOP

A página **top.html** mostra o ranking de categorias mais baixadas, ordenadas pelo número de downloads.

---

## 🔐 Arquivo config.js

Responsável por armazenar:

* URL do Supabase
* API KEY
* Funções de download
* Funções de ranking

---

## 💾 Rotina de Backup

Backup deve incluir:

* Repositório GitHub
* Pasta downloads
* Pasta zips
* config.js
* Export CSV tabelas Supabase
* Script SQL de estrutura

---

## 🎯 Objetivo do Projeto

O projeto POLYDEV tem como objetivo criar:

* Biblioteca de códigos
* Portal de ensino
* Repositório de exemplos
* Laboratório de programação
* Ambiente de testes web
* Documentação técnica

---

## 🚀 Versão

**POLYDEV 1.0 – Sistema funcional com downloads e ranking**

---

## 👨‍💻 Autor

Projeto desenvolvido para estudos de programação, banco de dados, web e arquitetura de sistemas.

POLYDEV – Leia • Entenda • Execute seu código
