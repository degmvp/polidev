import streamlit as st

st.title("POLYDEV Streamlit 08")
st.subheader("Sidebar")

opcao = st.sidebar.radio(
    "Menu",
    ["Home", "Cursos", "Downloads", "Contato"]
)

st.write("Opção escolhida:", opcao)