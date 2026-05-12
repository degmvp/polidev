import flet as ft

def main(page: ft.Page):

    contador = ft.Text("0", size=30)

    valor = 0

    def somar(e):
        nonlocal valor
        valor += 1
        contador.value = str(valor)
        page.update()

    page.add(
        contador,
        ft.ElevatedButton("+", on_click=somar)
    )

ft.app(target=main)