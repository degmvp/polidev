create table auditoria(
    id serial primary key,
    tabela text,
    data timestamp default current_timestamp
);

create or replace function fn_auditoria()
returns trigger
language plpgsql
as $$
begin
    insert into auditoria(tabela)
    values (tg_table_name);
    return new;
end;
$$;

create trigger trg_auditoria
after insert on conteudos
for each row
execute function fn_auditoria();