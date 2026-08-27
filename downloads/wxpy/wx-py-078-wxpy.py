import flet as ft

def main(page: ft.Page):

    card = ft.Container(
        content=ft.Text(
            "POLYDEV Card",
            size=25
        ),
        padding=20,
        bgcolor="blue",
        border_radius=10
    )

    page.add(card)

ft.app(target=main)