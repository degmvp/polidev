#!/usr/bin/env python3
# ==========================================================
# POLYDEV | Python Engineering
# ==========================================================
#
# Série:
# Python Engineering v1.0
#
# PYENG-10 — Configuração Profissional com ENV
#
# Tecnologia:
# Python 3.12+
#
# Categoria:
# Configuração • Engenharia de Software
#
# Objetivo
# ----------------------------------------------------------
# Implementar uma estrutura profissional de configuração
# utilizando variáveis de ambiente (ENV), permitindo separar
# configurações de desenvolvimento, homologação e produção
# sem alterar o código da aplicação.
#
# O que é Configuração via ENV?
# ----------------------------------------------------------
# Configuração por variáveis de ambiente é um padrão
# amplamente utilizado para armazenar parâmetros da
# aplicação fora do código-fonte.
#
# Essa abordagem aumenta a segurança, facilita implantações
# em diferentes ambientes e segue as recomendações do
# manifesto Twelve-Factor App.
#
# Quando utilizar
# ----------------------------------------------------------
# • APIs REST
# • Microsserviços
# • Docker
# • Kubernetes
# • Aplicações Cloud
# • Sistemas Corporativos
#
# Problema resolvido
# ----------------------------------------------------------
# Evita informações sensíveis dentro do código-fonte,
# simplifica mudanças entre ambientes e reduz riscos durante
# processos de implantação.
#
# Fluxo de execução
# ----------------------------------------------------------
#
#      Variáveis ENV
#             │
#             ▼
#      AppConfig.from_env()
#             │
#             ▼
#      Validação Config
#             │
#             ▼
#      Aplicação Executa
#
# Principais componentes
# ----------------------------------------------------------
# • os.getenv()
# • dataclass
# • Validação
# • ConfigError
# • DatabaseConfig
#
# Resultado esperado
# ----------------------------------------------------------
# Centralizar todas as configurações da aplicação em uma
# estrutura organizada, validada e preparada para ambientes
# profissionais.
#
# Observações
# ----------------------------------------------------------
# Este exemplo foi desenvolvido para fins educacionais.
# Em ambientes de produção recomenda-se utilizar arquivos
# .env, gerenciadores de segredos (Secrets Manager, Vault)
# e mecanismos de criptografia para credenciais críticas.
#
# ==========================================================
# Implementação
# ==========================================================

import os
from dataclasses import dataclass, field
from typing import List
from pathlib import Path


class ConfigError(Exception):
    """Erro de configuração."""
    pass


@dataclass
class DatabaseConfig:
    host: str = "localhost"
    port: int = 5432
    name: str = "app_db"
    user: str = "postgres"
    password: str = ""
    pool_size: int = 10

    @property
    def url(self) -> str:
        return (
            f"postgresql://{self.user}:{self.password}"
            f"@{self.host}:{self.port}/{self.name}"
        )


@dataclass
class AppConfig:
    """Configuração principal da aplicação."""

    env: str = "development"
    debug: bool = False
    secret_key: str = ""
    allowed_hosts: List[str] = field(default_factory=list)
    database: DatabaseConfig = field(
        default_factory=DatabaseConfig
    )

    @classmethod
    def from_env(cls) -> "AppConfig":
        """Carrega configuração das variáveis de ambiente."""

        db = DatabaseConfig(
            host=os.getenv("DB_HOST", "localhost"),
            port=int(os.getenv("DB_PORT", "5432")),
            name=os.getenv("DB_NAME", "app_db"),
            user=os.getenv("DB_USER", "postgres"),
            password=os.getenv("DB_PASSWORD", ""),
            pool_size=int(
                os.getenv("DB_POOL_SIZE", "10")
            ),
        )

        config = cls(
            env=os.getenv(
                "APP_ENV",
                "development"
            ),
            debug=os.getenv(
                "APP_DEBUG",
                "false"
            ).lower() == "true",
            secret_key=os.getenv(
                "APP_SECRET_KEY",
                ""
            ),
            allowed_hosts=os.getenv(
                "ALLOWED_HOSTS",
                "localhost"
            ).split(","),
            database=db,
        )

        config.validate()

        return config

    def validate(self):
        """Valida configurações obrigatórias."""

        errors = []

        if self.env == "production":

            if not self.secret_key:
                errors.append(
                    "APP_SECRET_KEY é obrigatório"
                )

            if self.debug:
                errors.append(
                    "DEBUG deve ser False em produção"
                )

        if errors:
            raise ConfigError(
                f"Erros de config: {'; '.join(errors)}"
            )

    @property
    def is_production(self) -> bool:
        return self.env == "production"


# Uso
config = AppConfig.from_env()

print(f"Ambiente: {config.env}")
print(f"Database URL: {config.database.url}")
print(f"Debug: {config.debug}")

# ==========================================================
# Fim do módulo PYENG-10
# ==========================================================
#
# Resumo
# ----------------------------------------------------------
# Neste módulo você aprendeu como organizar configurações
# profissionais utilizando variáveis de ambiente, dataclasses
# e validação automática para preparar aplicações para
# diferentes ambientes de execução.
#
# Série concluída
# ----------------------------------------------------------
# Python Engineering v1.0
#
# 10 módulos profissionais desenvolvidos cobrindo padrões
# modernos de concorrência, resiliência, desempenho,
# observabilidade e arquitetura de software.
#
# POLYDEV | Python Engineering v1.0
#
# Leia • Entenda • Execute seu código.
# ==========================================================