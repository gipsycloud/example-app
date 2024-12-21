const express = require("express");
const app = express();
const cors = require("cors");
const port = 3000;
const { pool, ping } = require("./db");
const { body, validationResult } = require("express-validator");

app.use(cors());
app.use(express.json());

app.get("/api/v1/hello", (req, res) => {
  res.json({
    message: "Bonjour!",
  });
});

app.get("/api/v1/users", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM users");
    res.json(result.rows);
  } catch (error) {
    console.error(error.message);
    res.status(500).json({
      error: "Internal server error",
    });
  }
});

app.post(
  "/api/v1/users",
  [
    body("name")
      .notEmpty({ ignore_whitespace: true })
      .withMessage("name must be provided")
      .isLength({ min: 5, max: 20 })
      .withMessage("name must be between 5 and 20 bytes"),
    body("email")
      .notEmpty()
      .withMessage("email must be provided")
      .isEmail()
      .withMessage("email must be valid")
      .isLength({ max: 30 })
      .withMessage("email must not exceed 30 bytes"),
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (errors.errors.length !== 0) {
        return res.status(400).json({
          errors: errors.array().map((err) => {
            return {
              field: err.path,
              message: err.msg,
            };
          }),
        });
      }
      const { name, email } = req.body;

      const result = await pool.query(
        "INSERT INTO users (name, email) VALUES ($1, $2) RETURNING id",
        [name, email],
      );
      res.status(201).json({
        id: result.rows[0].id,
        name: name,
        email: email,
      });
    } catch (error) {
      if (error.constraint === "users_email_key") {
        res.status(400).json({
          error: "Email already exists. Please use a different email.",
        });
      } else {
        console.error(error.message);
        res.status(500).json({ error: "Internal server error" });
      }
    }
  },
);

// default catch-all router
app.use((req, res) => {
  res.status(404).json({
    error: "Route not found",
  });
});

const startServer = async () => {
  try {
    await ping();
    console.log("Database is reachable!");

    const server = app.listen(port, () => {
      console.log(`Server is running on http://localhost:${port}`);
    });

    process.on("SIGINT", () => shutdown(server));
    process.on("SIGTERM", () => shutdown(server));
  } catch (error) {
    console.error(error.message);
    process.exit(1);
  }
};

const shutdown = (server) => {
  console.log("Received signal to shutdown.");
  pool.end(() => {
    console.log("Database connections closed.");
  });
  server.close(() => {
    console.log("Server closed.");
    process.exit(0);
  });
};

if (require.main == module) {
  startServer();
}

module.exports = { app };
