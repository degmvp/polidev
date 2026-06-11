10 - O Que é Row Overflow

Existe um limite aproximado de:

8060 bytes

por registro.

Quando esse limite é ultrapassado o SQL Server move parte dos dados para outra página.

Estrutura:

Registro Principal
      |
      +--> Página Overflow

A linha passa a armazenar apenas um ponteiro.
