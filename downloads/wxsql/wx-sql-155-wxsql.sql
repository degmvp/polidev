15. UPSERT
Insere um registro novo ou atualiza se ele já existir.

INSERT INTO clientes (email, nome)
VALUES ('deg@polydev.com', 'DEG')
ON CONFLICT (email)
DO UPDATE SET nome = EXCLUDED.nome;