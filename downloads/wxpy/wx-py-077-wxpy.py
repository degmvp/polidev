import flet as ft

def main(page: ft.Page):

    coluna = ft.Column([
        ft.Text("Python"),
        ft.Text("Pandas"),
        ft.Text("Flet"),
        ft.Text("Streamlit")
    ])

    page.add(coluna)

ft.app(target=main)