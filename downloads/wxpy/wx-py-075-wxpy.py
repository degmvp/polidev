import flet as ft

def main(page: ft.Page):

    valor = ft.Text()

    def alterar(e):
        valor.value = f"Valor: {slider.value}"
        page.update()

    slider = ft.Slider(
        min=0,
        max=100,
        divisions=10,
        on_change=alterar
    )

    page.add(slider, valor)

ft.app(target=main)