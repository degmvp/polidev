import flet as ft

def main(page: ft.Page):

    lista = ft.ListView(expand=True)

    for i in range(1, 21):
        lista.controls.append(
            ft.Text(f"Item {i}")
        )

    page.add(lista)

ft.app(target=main)