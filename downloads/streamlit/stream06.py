import streamlit as st

st.title("POLYDEV Streamlit 06")
st.subheader("Selectbox")

linguagem = st.selectbox(
    "Escolha uma linguagem:",
    ["Python", "C++", "Rust", "Go", "JavaScript"]
)

st.success(f"Você selecionou: {linguagem}")