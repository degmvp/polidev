import flet as ft

def main(page: ft.Page):
    page.title = "POLYDEV Flet 02"

    page.add(
        ft.Text("Título Principal", size=32),
        ft.Text("Subtítulo exemplo", size=22),
        ft.Text("Leia • Entenda • Execute seu código")
    )

ft.app(target=main)