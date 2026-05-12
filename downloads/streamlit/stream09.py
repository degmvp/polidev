import streamlit as st
import pandas as pd

st.title("POLYDEV Streamlit 09")
st.subheader("Exibindo DataFrame")

dados = {
    "Linguagem": ["Python", "C++", "Rust", "Go"],
    "Categoria": ["Script", "Sistema", "Sistema", "Backend"],
    "Nivel": ["Fácil", "Médio", "Avançado", "Médio"]
}

df = pd.DataFrame(dados)

st.dataframe(df)