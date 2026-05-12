import streamlit as st

st.title("POLYDEV Streamlit 13")
st.subheader("Layout com Colunas")

col1, col2, col3 = st.columns(3)

with col1:
    st.metric("Python", "34 programas")

with col2:
    st.metric("Pandas", "20 programas")

with col3:
    st.metric("Streamlit", "15 programas")