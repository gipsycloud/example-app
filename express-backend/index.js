const express = require("express");
const app = express();
const cors = require("cors");
const port = 3000;

app.use(cors());

app.get("/api/v1/hello", (req, res) => {
  res.json({ message: "Mingalapa!" });
});

// default catch-all router
app.use((req, res) => {
  res.status(404).json({ error: "Route not found" });
});

const server = app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});

module.exports = { app, server };
