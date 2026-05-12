import flet as ft

def main(page: ft.Page):

    resultado = ft.Text()

    def marcar(e):
        resultado.value = f"Checkbox: {check.value}"
        page.update()

    check = ft.Checkbox(
        label="Ativar",
        on_change=marcar
    )

    page.add(check, resultado)

ft.app(target=main)