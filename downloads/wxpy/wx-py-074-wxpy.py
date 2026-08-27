import flet as ft

def main(page: ft.Page):

    resultado = ft.Text()

    def mudar(e):
        resultado.value = f"Escolha: {combo.value}"
        page.update()

    combo = ft.Dropdown(
        options=[
            ft.dropdown.Option("Python"),
            ft.dropdown.Option("Flet"),
            ft.dropdown.Option("Streamlit")
        ],
        on_change=mudar
    )

    page.add(combo, resultado)

ft.app(target=main)