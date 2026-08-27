import flet as ft

def main(page: ft.Page):

    linha = ft.Row([
        ft.ElevatedButton("Botão 1"),
        ft.ElevatedButton("Botão 2"),
        ft.ElevatedButton("Botão 3")
    ])

    page.add(linha)

ft.app(target=main)