import streamlit as st

st.title("POLYDEV Streamlit 03")
st.subheader("Uso de Botões")

if st.button("Clique aqui"):
    st.success("Botão acionado com sucesso!")
else:
    st.warning("Aguardando o clique do usuário.")