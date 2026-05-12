import streamlit as st
import pandas as pd

st.set_page_config(page_title="POLYDEV Streamlit 15", layout="wide")

st.title("POLYDEV Streamlit 15")
st.subheader("App completo demonstrativo")

st.sidebar.title("Menu POLYDEV")
opcao = st.sidebar.selectbox(
    "Escolha uma opção:",
    ["Resumo", "Dados", "Gráfico", "Sobre"]
)

df = pd.DataFrame({
    "Curso": ["Python", "Pandas", "SQL", "Streamlit", "Rust"],
    "Programas": [34, 20, 25, 15, 20],
    "Status": ["Ativo", "Ativo", "Ativo", "Novo", "Ativo"]
})

if opcao == "Resumo":
    st.metric("Total de Cursos", len(df))
    st.metric("Total de Programas", df["Programas"].sum())

elif opcao == "Dados":
    st.dataframe(df)

elif opcao == "Gráfico":
    st.bar_chart(df.set_index("Curso")["Programas"])

elif opcao == "Sobre":
    st.info("POLYDEV | Leia • Entenda • Execute seu código")