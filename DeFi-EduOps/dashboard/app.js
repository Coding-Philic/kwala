# dashboard/app.py - simple admin dashboard (Streamlit)
import streamlit as st
import requests

st.set_page_config("DeFi-EduOps Admin", layout="wide")
st.title("DeFi-EduOps — Admin Dashboard")

st.markdown("## Recent events (manual demo)")
wallet = st.text_input("Student Wallet (for manual calls)")

if st.button("Trigger Release (simulate admin via KWALA)"):
    st.info("Triggering KWALA manual release (you need to wire actual KWALA endpoint).")
    # Example placeholder: call KWALA manual run endpoint if you have one
    # res = requests.post("https://YOUR_KWALA_MANUAL_TRIGGER_ENDPOINT/admin_release_funds", json={"student_wallet": wallet})
    # st.write(res.text)
    st.write("Demo: replace with actual KWALA trigger in production.")

st.markdown("### Notes")
st.write("- Use KWALA console to view workflow logs.")
st.write("- Deploy contracts on testnet and paste addresses into KWALA workflow.")
