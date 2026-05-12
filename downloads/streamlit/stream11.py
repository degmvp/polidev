import streamlit as st
import pandas as pd

st.title("POLYDEV Streamlit 11")
st.subheader("Gráfico com Streamlit")

df = pd.DataFrame({
    "Ano": [2022, 2023, 2024, 2025],
    "Acessos": [100, 250, 480, 900]
})

st.dataframe(df)
st.line_chart(df.set_index("Ano"))