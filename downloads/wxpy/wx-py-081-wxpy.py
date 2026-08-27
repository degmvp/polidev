import flet as ft

def main(page: ft.Page):

    email = ft.TextField(label="Email")
    senha = ft.TextField(
        label="Senha",
        password=True
    )

    resultado = ft.Text()

    def login(e):
        resultado.value = "Login realizado"
        page.update()

    page.add(
        email,
        senha,
        ft.ElevatedButton(
            "Entrar",
            on_click=login
        ),
        resultado
    )

ft.app(target=main)