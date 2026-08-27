import flet as ft

def main(page: ft.Page):

    page.title = "POLYDEV Flet 15"

    titulo = ft.Text(
        "Dashboard POLYDEV",
        size=35
    )

    menu = ft.Row([
        ft.ElevatedButton("Python"),
        ft.ElevatedButton("Pandas"),
        ft.ElevatedButton("Flet"),
        ft.ElevatedButton("Streamlit")
    ])

    conteudo = ft.Column([
        ft.Text("34 Programas Python"),
        ft.Text("20 Programas Pandas"),
        ft.Text("15 Programas Flet"),
        ft.Text("15 Programas Streamlit")
    ])

    page.add(
        titulo,
        menu,
        conteudo
    )

ft.app(target=main)