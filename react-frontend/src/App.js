import React, { useState } from "react";
import "./App.css";

function App() {
  const [message, setMessage] = useState("Greeting 👋: ____");
  const [loading, setLoading] = useState(false);

  const handleConnectClick = async () => {
    setLoading(true);
    try {
      // const serverIp = process.env.REACT_APP_API_URL;
      const response = await fetch(
        `http://hello-discord-30691903.eu-west-2.elb.amazonaws.com:3000/api/v1/hello`
      );
      if (response.ok) {
        const data = await response.json();
        setMessage(`Greeting 👋: ${data.message}`);
      } else {
        setMessage("Error connecting to backend");
      }
    } catch (error) {
      setMessage("Error connecting to backend");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="App">
      <div className="message-box">
        <p>{message}</p>
        <button onClick={handleConnectClick} disabled={loading}>
          {loading ? "Connecting..." : "Connect to Backend"}
        </button>
      </div>
    </div>
  );
}

export default App;
