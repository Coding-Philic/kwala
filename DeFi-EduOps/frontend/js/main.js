// main.js - admin actions
document.getElementById("adminRelease").addEventListener("click", async () => {
  const wallet = document.getElementById("adminStudentWallet").value.trim();
  if (!wallet) { alert("Enter student wallet"); return; }

  // We assume admin triggers KWALA manual trigger via KWALA console or via KWALA API.
  // For demo, we call a hypothetical endpoint that triggers KWALA manual run.
  const KWALA_MANUAL_TRIGGER = "https://YOUR_KWALA_MANUAL_TRIGGER_ENDPOINT/admin_release_funds";

  try {
    const res = await fetch(KWALA_MANUAL_TRIGGER, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ student_wallet: wallet })
    });
    document.getElementById("adminStatus").innerText = "Release request sent to KWALA.";
  } catch (err) {
    console.error(err);
    document.getElementById("adminStatus").innerText = "Failed to send request.";
  }
});
