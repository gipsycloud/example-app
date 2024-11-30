const { Pool } = require("pg");

const pool = new Pool({
  user: process.env.DB_USERNAME,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: 5432,
});

(async () => {
  try {
    await pool.query("SELECT 1");
    console.log("Successfully connected to database.");
  } catch (error) {
    console.error("Database connection error:", error.message);
    process.exit(1);
  }
})();

module.exports = pool;
