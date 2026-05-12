import streamlit as st

st.title("POLYDEV Streamlit 10")
st.subheader("Upload de Arquivo")

arquivo = st.file_uploader("Escolha um arquivo TXT", type=["txt"])

if arquivo is not None:
    conteudo = arquivo.read().decode("utf-8")
    st.text_area("Conteúdo do arquivo:", conteudo, height=200)
else:
    st.info("Envie um arquivo TXT para visualizar o conteúdo.")