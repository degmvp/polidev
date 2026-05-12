import streamlit as st

st.title("POLYDEV Streamlit 07")
st.subheader("Checkbox")

mostrar = st.checkbox("Mostrar mensagem especial")

if mostrar:
    st.success("POLYDEV: Leia • Entenda • Execute seu código")
else:
    st.info("Marque a opção para exibir a mensagem.")