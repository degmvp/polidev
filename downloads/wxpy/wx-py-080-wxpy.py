import flet as ft

def main(page: ft.Page):

    texto = ft.Text("Página Inicial")

    def mudar(e):
        texto.value = "Nova Tela"
        page.update()

    page.add(
        texto,
        ft.ElevatedButton(
            "Trocar Tela",
            on_click=mudar
        )
    )

ft.app(target=main)