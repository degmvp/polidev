import flet as ft

def main(page: ft.Page):

    def clicar(e):
        resultado.value = "Botão acionado!"
        page.update()

    resultado = ft.Text()

    page.add(
        ft.ElevatedButton(
            "Clique Aqui",
            on_click=clicar
        ),
        resultado
    )

ft.app(target=main)