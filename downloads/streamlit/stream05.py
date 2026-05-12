import streamlit as st

st.title("POLYDEV Streamlit 05")
st.subheader("Controle com Slider")

valor = st.slider("Escolha um valor:", 0, 100, 50)

st.write("Valor selecionado:", valor)
st.progress(valor)