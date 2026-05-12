import flet as ft

def main(page: ft.Page):

    nome = ft.TextField(label="Digite seu nome")
    resultado = ft.Text()

    def enviar(e):
        resultado.value = f"Olá {nome.value}"
        page.update()

    page.add(
        nome,
        ft.ElevatedButton("Enviar", on_click=enviar),
        resultado
    )

ft.app(target=main)