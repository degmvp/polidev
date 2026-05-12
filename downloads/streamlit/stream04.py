import streamlit as st

st.title("POLYDEV Streamlit 04")
st.subheader("Entrada de Dados")

nome = st.text_input("Digite seu nome:")
idade = st.number_input("Digite sua idade:", min_value=0, max_value=120)

if nome:
    st.write(f"Olá, {nome}. Sua idade é {idade} anos.")