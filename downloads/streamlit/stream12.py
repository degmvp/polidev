import streamlit as st

st.title("POLYDEV Streamlit 12")
st.subheader("Session State")

if "contador" not in st.session_state:
    st.session_state.contador = 0

if st.button("Incrementar"):
    st.session_state.contador += 1

if st.button("Zerar"):
    st.session_state.contador = 0

st.write("Contador:", st.session_state.contador)