import streamlit as st
import pandas as pd

st.title("POLYDEV Streamlit 14")
st.subheader("Mini Dashboard")

df = pd.DataFrame({
    "Categoria": ["Python", "Pandas", "SQL", "Streamlit"],
    "Downloads": [120, 85, 150, 60]
})

st.dataframe(df)

categoria = st.selectbox("Filtrar categoria:", df["Categoria"])

resultado = df[df["Categoria"] == categoria]

st.write("Resultado filtrado:")
st.dataframe(resultado)

st.bar_chart(df.set_index("Categoria"))