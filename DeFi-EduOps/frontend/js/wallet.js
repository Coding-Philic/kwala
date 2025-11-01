// wallet.js - simple MetaMask helper
async function connectWallet() {
  if (!window.ethereum) {
    alert("MetaMask not found. Install it first.");
    return null;
  }
  try {
    const accounts = await window.ethereum.request({ method: "eth_requestAccounts" });
    return accounts[0];
  } catch (err) {
    console.error(err);
    return null;
  }
}

document.getElementById("connectWallet").addEventListener("click", async () => {
  const addr = await connectWallet();
  if (addr) {
    document.getElementById("walletAddress").innerText = addr;
    document.getElementById("wallet").value = addr;
  }
});
