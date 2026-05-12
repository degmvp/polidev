import flet as ft

def main(page: ft.Page):
    page.title = "POLYDEV Flet 01"

    texto = ft.Text(
        "Olá Mundo Flet!",
        size=30,
        color="yellow"
    )

    page.add(texto)

ft.app(target=main)